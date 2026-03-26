from pydantic import BaseModel, Field


class BindCodeResponse(BaseModel):
    code: str
    expires_at: str | None = None


class BindRequestBody(BaseModel):
    bind_code: str = Field(min_length=6, max_length=6)


class BindingOut(BaseModel):
    id: str
    parent_user_id: str
    child_user_id: str
    bind_code: str
    status: str
    created_at: str
    resolved_at: str | None = None

    model_config = {"from_attributes": True}
