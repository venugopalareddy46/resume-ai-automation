#!/usr/bin/env python3

import logging
import os
import sys
import time
from datetime import datetime, timezone

import requests


HEALTH_URL = os.getenv(
    "HEALTH_URL",
    "https://api.venugopalareddy.in/health",
)

TIMEOUT = int(os.getenv("HEALTH_TIMEOUT", "10"))

LOG_FILE = os.getenv(
    "HEALTH_LOG_FILE",
    "monitoring/health_monitor.log",
)


logging.basicConfig(
    filename=LOG_FILE,
    level=logging.INFO,
    format="%(asctime)s | %(levelname)s | %(message)s",
)


def check_health():
    """Check the application health endpoint."""

    start_time = time.perf_counter()

    try:
        response = requests.get(
            HEALTH_URL,
            timeout=TIMEOUT,
        )

        response_time = time.perf_counter() - start_time

        if response.ok:
            try:
                data = response.json()
                application = data.get("application", "unknown")
                version = data.get("version", "unknown")
                pod = data.get("pod", "unknown")
            except ValueError:
                application = "unknown"
                version = "unknown"
                pod = "unknown"

            message = (
                f"STATUS=UP | "
                f"HTTP={response.status_code} | "
                f"APP={application} | "
                f"VERSION={version} | "
                f"POD={pod} | "
                f"RESPONSE_TIME={response_time:.3f}s"
            )

            logging.info(message)
            print(message)

            return True

        message = (
            f"STATUS=DOWN | "
            f"HTTP={response.status_code} | "
            f"RESPONSE_TIME={response_time:.3f}s"
        )

        logging.error(message)
        print(message)

        return False

    except requests.RequestException as exc:
        response_time = time.perf_counter() - start_time

        message = (
            f"STATUS=DOWN | "
            f"ERROR={exc} | "
            f"RESPONSE_TIME={response_time:.3f}s"
        )

        logging.error(message)
        print(message)

        return False


def main():
    print(f"Checking: {HEALTH_URL}")

    healthy = check_health()

    if healthy:
        print("Application health check: PASS")
        sys.exit(0)

    print("Application health check: FAIL")
    sys.exit(1)


if __name__ == "__main__":
    main()