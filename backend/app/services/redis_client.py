import json
import logging
from typing import Any

import redis

from app.core.config import settings

logger = logging.getLogger(__name__)

_redis: redis.Redis | None = None


def get_redis() -> redis.Redis:
    global _redis
    if _redis is None:
        _redis = redis.from_url(settings.redis_url, decode_responses=True)
    return _redis


def rate_limit_key(action: str, user_id: str) -> str:
    return f"rl:{action}:{user_id}"


def check_rate_limit(action: str, user_id: str, limit: int, window_sec: int) -> bool:
    """Return True if allowed, False if rate limited."""
    r = get_redis()
    key = rate_limit_key(action, user_id)
    pipe = r.pipeline()
    pipe.incr(key)
    pipe.expire(key, window_sec)
    count, _ = pipe.execute()
    return int(count) <= limit


def publish_user_event(user_id: str, event: dict[str, Any]) -> None:
    channel = f"user:{user_id}"
    payload = json.dumps(event, ensure_ascii=False)
    get_redis().publish(channel, payload)
