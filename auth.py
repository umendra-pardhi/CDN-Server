
import os
import hmac
import stat
import logging

from pathlib import Path
from urllib.parse import urlsplit, unquote
from http.server import ThreadingHTTPServer, BaseHTTPRequestHandler


HOST = "0.0.0.0"
PORT = 8000

STATIC_DIR = Path("/srv/static").resolve()

API_KEY = os.environ.get("CDN_API_KEY", "")

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("cdn-auth")


if not API_KEY:
    raise RuntimeError("CDN_API_KEY is missing")


class AuthHandler(BaseHTTPRequestHandler):

    def send_result(self, status):

        self.send_response(status)
        self.send_header("Content-Length", "0")
        self.send_header("Cache-Control", "no-store")
        self.end_headers()

    def do_GET(self):

        # Internal health check
        if self.path == "/health":
            self.send_result(200)
            return

        if self.path != "/verify":
            self.send_result(404)
            return

        # Validate API key
        supplied = self.headers.get("X-API-Key", "")

        if not hmac.compare_digest(supplied, API_KEY):
            self.send_result(401)
            return

        # Original requested URL from Nginx
        original_uri = self.headers.get("X-Original-URI", "")

        try:
            raw_path = urlsplit(original_uri).path
            filename = unquote(raw_path.lstrip("/"), errors="strict")
        except (ValueError, UnicodeDecodeError):
            self.send_result(403)
            return

        # Only filenames, no directory traversal
        if (
            not filename
            or filename in (".", "..")
            or "/" in filename
            or "\\" in filename
            or "\x00" in filename
        ):
            self.send_result(403)
            return

        try:
            path = STATIC_DIR / filename

            # Reject symbolic links
            if path.is_symlink():
                self.send_result(403)
                return

            # Missing file: let Nginx return its normal 404
            if not path.exists():
                self.send_result(200)
                return

            resolved = path.resolve(strict=True)

            if resolved.parent != STATIC_DIR:
                self.send_result(403)
                return

            file_stat = resolved.stat()

            if not stat.S_ISREG(file_stat.st_mode):
                self.send_result(403)
                return

            # Authorized
            self.send_result(200)

        except (OSError, ValueError, RuntimeError):
            self.send_result(403)

    def log_message(self, fmt, *args):
        logger.info(
            "%s - %s",
            self.client_address[0],
            fmt % args
        )


class AuthServer(ThreadingHTTPServer):

    daemon_threads = True
    allow_reuse_address = True
    request_queue_size = 128


if __name__ == "__main__":

    server = AuthServer((HOST, PORT), AuthHandler)

    logger.info("CDN authentication service started")

    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        server.server_close()
