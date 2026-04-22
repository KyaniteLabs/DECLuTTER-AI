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
            cloud_storage_configured=bool(os.getenv("DECLUTTER_STORAGE_BUCKET")),
            multimodal_model_configured=bool(os.getenv("DECLUTTER_MODEL_PROVIDER")),
            ebay_api_configured=bool(os.getenv("EBAY_CLIENT_ID") and os.getenv("EBAY_CLIENT_SECRET")),
        )
