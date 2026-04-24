# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
import logging
import os
import re
import sys

from celery.schedules import crontab
from flask_caching.backends.filesystemcache import FileSystemCache

logger = logging.getLogger()

# ============================================================
# DATABASE CONNECTION
# ============================================================
DATABASE_DIALECT  = os.getenv("DATABASE_DIALECT")
DATABASE_USER     = os.getenv("DATABASE_USER")
DATABASE_PASSWORD = os.getenv("DATABASE_PASSWORD")
DATABASE_HOST     = os.getenv("DATABASE_HOST")
DATABASE_PORT     = os.getenv("DATABASE_PORT")
DATABASE_DB       = os.getenv("DATABASE_DB")

EXAMPLES_USER     = os.getenv("EXAMPLES_USER")
EXAMPLES_PASSWORD = os.getenv("EXAMPLES_PASSWORD")
EXAMPLES_HOST     = os.getenv("EXAMPLES_HOST")
EXAMPLES_PORT     = os.getenv("EXAMPLES_PORT")
EXAMPLES_DB       = os.getenv("EXAMPLES_DB")

SQLALCHEMY_DATABASE_URI = (
    f"{DATABASE_DIALECT}://"
    f"{DATABASE_USER}:{DATABASE_PASSWORD}@"
    f"{DATABASE_HOST}:{DATABASE_PORT}/{DATABASE_DB}"
)
SQLALCHEMY_EXAMPLES_URI = (
    f"{DATABASE_DIALECT}://"
    f"{EXAMPLES_USER}:{EXAMPLES_PASSWORD}@"
    f"{EXAMPLES_HOST}:{EXAMPLES_PORT}/{EXAMPLES_DB}"
)

# ============================================================
# REDIS / CELERY / CACHE
# ============================================================
REDIS_HOST       = os.getenv("REDIS_HOST", "redis")
REDIS_PORT       = os.getenv("REDIS_PORT", "6379")
REDIS_CELERY_DB  = os.getenv("REDIS_CELERY_DB", "0")
REDIS_RESULTS_DB = os.getenv("REDIS_RESULTS_DB", "1")

RESULTS_BACKEND = FileSystemCache("/app/superset_home/sqllab")

CACHE_CONFIG = {
    "CACHE_TYPE": "RedisCache",
    "CACHE_DEFAULT_TIMEOUT": 300,
    "CACHE_KEY_PREFIX": "superset_",
    "CACHE_REDIS_HOST": REDIS_HOST,
    "CACHE_REDIS_PORT": REDIS_PORT,
    "CACHE_REDIS_DB": REDIS_RESULTS_DB,
}
DATA_CACHE_CONFIG      = CACHE_CONFIG
THUMBNAIL_CACHE_CONFIG = CACHE_CONFIG


class CeleryConfig:
    broker_url  = f"redis://{REDIS_HOST}:{REDIS_PORT}/{REDIS_CELERY_DB}"
    imports     = (
        "superset.sql_lab",
        "superset.tasks.scheduler",
        "superset.tasks.thumbnails",
        "superset.tasks.cache",
    )
    result_backend             = f"redis://{REDIS_HOST}:{REDIS_PORT}/{REDIS_RESULTS_DB}"
    worker_prefetch_multiplier = 1
    task_acks_late             = False
    beat_schedule              = {
        "reports.scheduler": {
            "task": "reports.scheduler",
            "schedule": crontab(minute="*", hour="*"),
        },
        "reports.prune_log": {
            "task": "reports.prune_log",
            "schedule": crontab(minute=10, hour=0),
        },
    }


CELERY_CONFIG = CeleryConfig

ALERT_REPORTS_NOTIFICATION_DRY_RUN = True
WEBDRIVER_BASEURL = (
    f"http://superset_app{os.environ.get('SUPERSET_APP_ROOT', '/')}/"
)
WEBDRIVER_BASEURL_USER_FRIENDLY = (
    f"http://localhost:8888/{os.environ.get('SUPERSET_APP_ROOT', '/')}/"
)
SQLLAB_CTAS_NO_LIMIT = True

log_level_text = os.getenv("SUPERSET_LOG_LEVEL", "INFO")
LOG_LEVEL = getattr(logging, log_level_text.upper(), logging.INFO)

if os.getenv("CYPRESS_CONFIG") == "true":
    base_dir      = os.path.dirname(__file__)
    module_folder = os.path.abspath(
        os.path.join(base_dir, "../../tests/integration_tests/")
    )
    sys.path.insert(0, module_folder)
    from superset_test_config import *  # noqa
    sys.path.pop(0)

try:
    import superset_config_docker
    from superset_config_docker import *  # noqa: F403
    logger.info(f"Loaded Docker config at [{superset_config_docker.__file__}]")
except ImportError:
    logger.info("Using default Docker config...")


# ============================================================
# FEATURE FLAGS
# ============================================================
FEATURE_FLAGS = {
    "ALERT_REPORTS": True,
    "ENABLE_TEMPLATE_PROCESSING": True,
    "EMBEDDED_SUPERSET": True,
}

# ============================================================
# GUEST TOKEN
# ============================================================
GUEST_ROLE_NAME             = "Gamma"
GUEST_TOKEN_JWT_SECRET      = "fossil-super-secret-jwt-key"
GUEST_TOKEN_JWT_ALGO        = "HS256"
GUEST_TOKEN_HEADER_NAME     = "X-GuestToken"
GUEST_TOKEN_JWT_EXP_SECONDS = 86400

# ============================================================
# CORS
# ============================================================
ENABLE_CORS = True
CORS_OPTIONS = {
    "supports_credentials": True,
    "allow_headers": ["*"],
    "expose_headers": ["*"],
    "resources": ["*"],
    "origins": ["*"],  # Restrict to your frontend URL in production
}

# ============================================================
# IFRAME / BROWSER SECURITY (development)
# ============================================================
TALISMAN_ENABLED = False
OVERRIDE_HTTP_HEADERS = {"X-Frame-Options": "ALLOWALL"}


def _apply_dev_headers(app):
    @app.after_request
    def _add_headers(response):
        response.headers["X-Frame-Options"]         = "ALLOWALL"
        response.headers["Content-Security-Policy"] = "frame-ancestors 'self' *"
        return response


FLASK_APP_MUTATOR = lambda app: _apply_dev_headers(app)


# ============================================================
# JINJA CONTEXT — {{ get_fossil_context('tenant') }} in SQL
# ============================================================
def get_fossil_context(target_key):
    """
    Reads the structured username and returns the value for a key.
    Username format: "role:subtenant:tenant:KAJ:subtenant:BEKASIUTARA"
    Usage in Superset SQL: {{ get_fossil_context('tenant') }}
    """
    from flask import g
    try:
        username = getattr(getattr(g, "user", None), "username", None)
        if username:
            parts = username.split(":")
            for i in range(0, len(parts) - 1, 2):
                if parts[i].lower() == target_key.lower():
                    return parts[i + 1]
    except Exception:
        pass
    return "NULL"


JINJA_CONTEXT_ADDONS = {
    "get_fossil_context": get_fossil_context,
}


# ============================================================
# POSTGRESQL NATIVE RLS
# ============================================================
# We use DB_CONNECTION_MUTATOR to inject a psycopg2 connection_factory
# that runs set_config() immediately after every new connection is made.
# This is the only reliable way to set custom GUC parameters in Supabase.

from flask import g as flask_g
import psycopg2
import psycopg2.extensions
import re

_SAFE_VALUE = re.compile(r'^[A-Za-z0-9_\-]+$')


def _safe(val):
    return val if (val and _SAFE_VALUE.match(str(val))) else ""


class FossilRLSConnection(psycopg2.extensions.connection):
    """
    Custom psycopg2 connection that injects RLS context before every query.
    Uses Flask's request ID to detect when the request changes, so it
    re-injects on every new request even on a pooled connection.
    """
    def cursor(self, *args, **kwargs):
        cur = super().cursor(*args, **kwargs)

        try:
            from flask import has_app_context, g, request
            if not has_app_context():
                return cur

            # Use the Flask request object's identity as a per-request key.
            # When a new HTTP request comes in, request object changes
            # → we re-inject the RLS context for that new request.
            current_request_id = id(request)
            if getattr(self, '_last_request_id', None) == current_request_id:
                return cur  # Same request, already injected

            self._last_request_id = current_request_id

            username = getattr(getattr(g, "user", None), "username", None)
            if username and "role:" in username:
                parts = username.split(":")
                ctx = {}
                for i in range(0, len(parts) - 1, 2):
                    ctx[parts[i].lower()] = parts[i + 1]

                role_type  = _safe(ctx.get("role", ""))
                tenant     = _safe(ctx.get("tenant", ""))
                subtenant  = _safe(ctx.get("subtenant", ""))
                donor_code = _safe(ctx.get("donor", ""))

                if role_type:
                    cur.execute("SELECT set_config('app.current_role',      %s, false)", (role_type,))
                    cur.execute("SELECT set_config('app.current_tenant',    %s, false)", (tenant,))
                    cur.execute("SELECT set_config('app.current_subtenant', %s, false)", (subtenant,))
                    cur.execute("SELECT set_config('app.current_donor',     %s, false)", (donor_code,))
                    logging.warning(f"FOSSIL RLS SET: role={role_type!r} tenant={tenant!r} subtenant={subtenant!r}")

        except Exception as exc:
            logging.error(f"FOSSIL RLS connection factory error: {exc}")

        return cur

def DB_CONNECTION_MUTATOR(url, params, headers, username, source=None):
    host = url.host or ""
    if "supabase" not in host and "pooler" not in host:
        return url, params

    # Inject our custom connection factory
    connect_args = params.get("connect_args", {})
    connect_args["connection_factory"] = FossilRLSConnection
    params["connect_args"] = connect_args

    logging.warning(f"FOSSIL MUTATOR: injecting RLS connection factory for host={host!r}")
    return url, params