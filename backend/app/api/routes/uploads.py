import uuid

from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel, Field

from app.api.deps import get_current_user
from app.core.config import settings
from app.models.user import User

router = APIRouter(prefix="/uploads", tags=["uploads"])


class PresignBody(BaseModel):
    filename: str = Field(min_length=1, max_length=255)
    content_type: str = Field(default="application/octet-stream")


class PresignResponse(BaseModel):
    upload_url: str
    object_key: str
    expires_in: int = 300


@router.post("/presign", response_model=PresignResponse)
def presign_upload(body: PresignBody, user: User = Depends(get_current_user)) -> PresignResponse:
    if not settings.cos_secret_id or not settings.cos_secret_key or not settings.cos_bucket:
        raise HTTPException(501, "Object storage not configured")
    try:
        from qcloud_cos import CosConfig, CosS3Client
    except ImportError:
        raise HTTPException(501, "COS SDK not available")

    ext = ""
    if "." in body.filename:
        ext = "." + body.filename.rsplit(".", 1)[-1].lower()[:8]
    key = f"avatars/{user.id}/{uuid.uuid4().hex}{ext}"

    config = CosConfig(
        Region=settings.cos_region,
        SecretId=settings.cos_secret_id,
        SecretKey=settings.cos_secret_key,
        Scheme="https",
    )
    client = CosS3Client(config)
    url = client.get_presigned_url(
        Method="PUT",
        Bucket=settings.cos_bucket,
        Key=key,
        Expired=300,
    )
    return PresignResponse(upload_url=url, object_key=key, expires_in=300)
