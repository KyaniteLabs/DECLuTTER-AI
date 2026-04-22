from __future__ import annotations

import os
from dataclasses import dataclass


@dataclass(frozen=True)
class RuntimeReadiness:
    firebase_admin_configured: bool
    cloud_storage_configured: bool
    multimodal_model_configured: bool
    ebay_api_configured: bool

    @property
    def ready_for_production(self) -> bool:
        return (
            self.firebase_admin_configured
            and self.cloud_storage_configured
            and self.multimodal_model_configured
            and self.ebay_api_configured
        )


class Settings:
    @staticmethod
    def readiness() -> RuntimeReadiness:
        return RuntimeReadiness(
            firebase_admin_configured=bool(os.getenv("FIREBASE_PROJECT_ID")),
            cloud_storage_configured=Settings._cloud_storage_configured(),
            multimodal_model_configured=bool(os.getenv("DECLUTTER_MODEL_PROVIDER")),
            ebay_api_configured=bool(
                os.getenv("EBAY_CLIENT_ID") and os.getenv("EBAY_CLIENT_SECRET")
            ),
        )

    @staticmethod
    def _cloud_storage_configured() -> bool:
        storage_backend = os.getenv("DECLUTTER_STORAGE_BACKEND", "local").strip().lower()
        return storage_backend == "s3" and bool(os.getenv("DECLUTTER_S3_BUCKET"))

    @staticmethod
    def cors_allow_origins() -> list[str]:
        raw_origins = os.getenv("DECLUTTER_CORS_ALLOW_ORIGINS", "")
        return [origin.strip() for origin in raw_origins.split(",") if origin.strip()]
