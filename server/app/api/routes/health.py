from fastapi import APIRouter

from core.settings import Settings

router = APIRouter(prefix="/health", tags=["health"])


@router.get("/")
def healthcheck() -> dict[str, str]:
    return {"status": "ok"}


@router.get("/readiness")
def readiness() -> dict[str, object]:
    state = Settings.readiness()
    return {
        "ready_for_production": state.ready_for_production,
        "checks": {
            "firebase_admin_configured": state.firebase_admin_configured,
            "cloud_storage_configured": state.cloud_storage_configured,
            "multimodal_model_configured": state.multimodal_model_configured,
            "ebay_api_configured": state.ebay_api_configured,
        },
    }
