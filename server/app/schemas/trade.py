from pydantic import BaseModel, Field


class TradeListingRequest(BaseModel):
    item_label: str = Field(min_length=1)
    description: str = Field(default="", max_length=2000)
    condition: str = Field(default="good")
    valuation_median_usd: float = Field(ge=0)
    trade_value_credits: float = Field(ge=0)
    latitude: float | None = None
    longitude: float | None = None
    images: list[str] = Field(default_factory=list)
    tags: list[str] = Field(default_factory=list)
    wants_in_return: list[str] = Field(default_factory=list)


class TradeListingResponse(BaseModel):
    id: str
    user_id: str
    item_label: str
    description: str
    condition: str
    valuation_median_usd: float
    trade_value_credits: float
    latitude: float | None = None
    longitude: float | None = None
    images: list[str]
    tags: list[str]
    wants_in_return: list[str]
    status: str
    created_at: str
    updated_at: str
    distance_km: float | None = None


class TradeMatchRequest(BaseModel):
    listing_id: str
    offered_listing_id: str | None = None
    message: str = Field(default="", max_length=1000)
    use_credits: bool = False
    credit_amount: float = Field(default=0.0, ge=0)


class TradeMatchResponse(BaseModel):
    id: str
    listing_id: str
    requester_id: str
    owner_id: str
    offered_listing_id: str | None = None
    message: str
    use_credits: bool
    credit_amount: float
    status: str
    created_at: str
    updated_at: str
