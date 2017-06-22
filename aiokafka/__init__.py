import sys

from .errors import ConsumerStoppedError, IllegalOperation

try:
    from asyncio import ensure_future
except ImportError:
    from asyncio import async as ensure_future

__version__ = '0.2.3.dev'
PY_35 = sys.version_info >= (3, 5)

from .client import AIOKafkaClient  # noqa
from .producer import AIOKafkaProducer  # noqa
from .consumer import AIOKafkaConsumer  # noqa
from aiokafka.fetcher import ConsumerRecord  # noqa

__all__ = [
    # Clients API
    "AIOKafkaProducer",
    "AIOKafkaConsumer",
    # Errors
    "ConsumerStoppedError", "IllegalOperation",
    # Structs
    "ConsumerRecord"
]

(AIOKafkaClient, ensure_future)
