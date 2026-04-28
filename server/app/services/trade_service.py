from __future__ import annotations

import json
import math
import os
import sqlite3
import uuid
import warnings
from contextlib import contextmanager
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

from models.trade import TradeCreditStore


class TradeService:
    """Core trade matching and execution service."""

    def __init__(
        self,
        db_path: str | None = None,
        credit_store: TradeCreditStore | None = None,
    ) -> None:
        raw_path = db_path or os.getenv(
            "DECLUTTER_TRADE_DB_PATH",
            os.getenv("DECLUTTER_SESSION_DB_PATH", "/tmp/declutter_ai_trade.sqlite3"),
        )
        self.db_path = Path(raw_path)
        self.db_path.parent.mkdir(parents=True, exist_ok=True)
        self._credit_store = credit_store or TradeCreditStore(db_path=str(self.db_path))
        self._ensure_schema()

    def create_listing(
        self,
        user_id: str,
        item_label: str,
        description: str = "",
        condition: str = "good",
        valuation_median_usd: float = 0.0,
        trade_value_credits: float = 0.0,
        latitude: float | None = None,
        longitude: float | None = None,
        images: list[str] | None = None,
        tags: list[str] | None = None,
        wants_in_return: list[str] | None = None,
    ) -> dict[str, Any]:
        listing_id = str(uuid.uuid4())[:8]
        now = datetime.now(timezone.utc).isoformat()

        with self._db() as conn:
            conn.execute(
                """
                INSERT INTO trade_listings (
                    id, user_id, item_label, description, condition,
                    valuation_median_usd, trade_value_credits,
                    latitude, longitude, images, tags, wants_in_return,
                    status, created_at, updated_at
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """,
                (
                    listing_id, user_id, item_label, description, condition,
                    valuation_median_usd, trade_value_credits,
                    latitude, longitude,
                    json.dumps(images or []),
                    json.dumps(tags or []),
                    json.dumps(wants_in_return or []),
                    "available", now, now,
                ),
            )
        return self._listing_to_dict(listing_id)

    def find_nearby(
        self,
        latitude: float,
        longitude: float,
        radius_km: float = 5.0,
        exclude_user_id: str | None = None,
    ) -> list[dict[str, Any]]:
        with self._db() as conn:
            rows = conn.execute(
                """
                SELECT * FROM trade_listings
                WHERE status = 'available'
                AND latitude IS NOT NULL AND longitude IS NOT NULL
                """
            ).fetchall()

        results = []
        for row in rows:
            if exclude_user_id and row["user_id"] == exclude_user_id:
                continue
            dist = self._haversine(
                latitude, longitude, row["latitude"], row["longitude"]
            )
            if dist <= radius_km:
                d = self._row_to_dict(row)
                d["distance_km"] = round(dist, 2)
                results.append(d)

        results.sort(key=lambda x: x["distance_km"])
        return results

    def propose_trade(
        self,
        listing_id: str,
        requester_id: str,
        offered_listing_id: str | None = None,
        message: str = "",
        use_credits: bool = False,
        credit_amount: float = 0.0,
    ) -> dict[str, Any]:
        listing = self._get_listing(listing_id)
        if listing is None:
            raise ValueError(f"Listing {listing_id} not found")
        if listing["status"] != "available":
            raise ValueError("Listing is not available for trade")
        if listing["user_id"] == requester_id:
            raise ValueError("Cannot trade with yourself")

        if use_credits and credit_amount > 0:
            balance = self._credit_store.get_credit_balance(requester_id)
            if credit_amount > balance:
                raise ValueError(f"Insufficient credits: {credit_amount} > {balance}")

        match_id = str(uuid.uuid4())[:8]
        now = datetime.now(timezone.utc).isoformat()

        with self._db() as conn:
            conn.execute(
                """
                INSERT INTO trade_matches (
                    id, listing_id, requester_id, owner_id,
                    offered_listing_id, message, use_credits, credit_amount,
                    status, created_at, updated_at
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """,
                (
                    match_id, listing_id, requester_id, listing["user_id"],
                    offered_listing_id, message, use_credits, credit_amount,
                    "pending", now, now,
                ),
            )
            conn.execute(
                "UPDATE trade_listings SET status = ?, updated_at = ? WHERE id = ?",
                ("pending", now, listing_id),
            )

        return self._match_to_dict(match_id)

    def accept_trade(self, match_id: str, user_id: str) -> dict[str, Any]:
        match = self._get_match(match_id)
        if match is None:
            raise ValueError(f"Trade match {match_id} not found")
        if match["owner_id"] != user_id:
            raise ValueError("Only the listing owner can accept")
        if match["status"] != "pending":
            raise ValueError("Trade is not pending")

        now = datetime.now(timezone.utc).isoformat()

        with self._db() as conn:
            if match["use_credits"] and match["credit_amount"] > 0:
                self._credit_store.spend_credits(
                    match["requester_id"], match["listing_id"],
                    match["credit_amount"], trade_id=match_id,
                )
                self._credit_store.earn_credits(
                    match["owner_id"], match["listing_id"],
                    match["credit_amount"], trade_id=match_id,
                )

            conn.execute(
                "UPDATE trade_matches SET status = ?, updated_at = ? WHERE id = ?",
                ("completed", now, match_id),
            )
            conn.execute(
                "UPDATE trade_listings SET status = ?, updated_at = ? WHERE id = ?",
                ("completed", now, match["listing_id"]),
            )
            if match["offered_listing_id"]:
                conn.execute(
                    "UPDATE trade_listings SET status = ?, updated_at = ? WHERE id = ?",
                    ("completed", now, match["offered_listing_id"]),
                )

        return self._match_to_dict(match_id)

    def decline_trade(self, match_id: str, user_id: str) -> dict[str, Any]:
        match = self._get_match(match_id)
        if match is None:
            raise ValueError(f"Trade match {match_id} not found")
        if match["owner_id"] != user_id:
            raise ValueError("Only the listing owner can decline")
        if match["status"] != "pending":
            raise ValueError("Trade is not pending")

        now = datetime.now(timezone.utc).isoformat()

        with self._db() as conn:
            conn.execute(
                "UPDATE trade_matches SET status = ?, updated_at = ? WHERE id = ?",
                ("declined", now, match_id),
            )
            conn.execute(
                "UPDATE trade_listings SET status = ?, updated_at = ? WHERE id = ?",
                ("available", now, match["listing_id"]),
            )

        return self._match_to_dict(match_id)

    def _get_listing(self, listing_id: str) -> dict[str, Any] | None:
        with self._db() as conn:
            row = conn.execute(
                "SELECT * FROM trade_listings WHERE id = ?", (listing_id,)
            ).fetchone()
        return self._row_to_dict(row) if row else None

    def _get_match(self, match_id: str) -> dict[str, Any] | None:
        with self._db() as conn:
            row = conn.execute(
                "SELECT * FROM trade_matches WHERE id = ?", (match_id,)
            ).fetchone()
        return self._match_row_to_dict(row) if row else None

    def _listing_to_dict(self, listing_id: str) -> dict[str, Any]:
        row = self._get_listing(listing_id)
        if row is None:
            raise RuntimeError("Listing not found after insert")
        return row

    def _match_to_dict(self, match_id: str) -> dict[str, Any]:
        row = self._get_match(match_id)
        if row is None:
            raise RuntimeError("Match not found after insert")
        return row

    def _row_to_dict(self, row: sqlite3.Row) -> dict[str, Any]:
        return {
            "id": row["id"],
            "user_id": row["user_id"],
            "item_label": row["item_label"],
            "description": row["description"],
            "condition": row["condition"],
            "valuation_median_usd": row["valuation_median_usd"],
            "trade_value_credits": row["trade_value_credits"],
            "latitude": row["latitude"],
            "longitude": row["longitude"],
            "images": json.loads(row["images"]),
            "tags": json.loads(row["tags"]),
            "wants_in_return": json.loads(row["wants_in_return"]),
            "status": row["status"],
            "created_at": row["created_at"],
            "updated_at": row["updated_at"],
        }

    def _match_row_to_dict(self, row: sqlite3.Row) -> dict[str, Any]:
        return {
            "id": row["id"],
            "listing_id": row["listing_id"],
            "requester_id": row["requester_id"],
            "owner_id": row["owner_id"],
            "offered_listing_id": row["offered_listing_id"],
            "message": row["message"],
            "use_credits": bool(row["use_credits"]),
            "credit_amount": row["credit_amount"],
            "status": row["status"],
            "created_at": row["created_at"],
            "updated_at": row["updated_at"],
        }

    @staticmethod
    def _haversine(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
        R = 6371.0
        phi1 = math.radians(lat1)
        phi2 = math.radians(lat2)
        dphi = math.radians(lat2 - lat1)
        dlambda = math.radians(lon2 - lon1)
        a = (
            math.sin(dphi / 2) ** 2
            + math.cos(phi1) * math.cos(phi2) * math.sin(dlambda / 2) ** 2
        )
        c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
        return R * c

    def _ensure_schema(self) -> None:
        with self._db() as conn:
            conn.execute(
                """
                CREATE TABLE IF NOT EXISTS trade_listings (
                    id TEXT PRIMARY KEY,
                    user_id TEXT NOT NULL,
                    item_label TEXT NOT NULL,
                    description TEXT,
                    condition TEXT,
                    valuation_median_usd REAL,
                    trade_value_credits REAL,
                    latitude REAL,
                    longitude REAL,
                    images TEXT,
                    tags TEXT,
                    wants_in_return TEXT,
                    status TEXT NOT NULL DEFAULT 'available',
                    created_at TEXT NOT NULL,
                    updated_at TEXT NOT NULL
                )
                """
            )
            conn.execute(
                "CREATE INDEX IF NOT EXISTS idx_listings_status ON trade_listings(status)"
            )
            conn.execute(
                """
                CREATE TABLE IF NOT EXISTS trade_matches (
                    id TEXT PRIMARY KEY,
                    listing_id TEXT NOT NULL,
                    requester_id TEXT NOT NULL,
                    owner_id TEXT NOT NULL,
                    offered_listing_id TEXT,
                    message TEXT,
                    use_credits INTEGER DEFAULT 0,
                    credit_amount REAL DEFAULT 0,
                    status TEXT NOT NULL DEFAULT 'pending',
                    created_at TEXT NOT NULL,
                    updated_at TEXT NOT NULL
                )
                """
            )
            conn.execute(
                "CREATE INDEX IF NOT EXISTS idx_matches_listing ON trade_matches(listing_id)"
            )

    @contextmanager
    def _db(self):
        conn = sqlite3.connect(self.db_path)
        conn.row_factory = sqlite3.Row
        try:
            yield conn
            conn.commit()
        finally:
            conn.close()
