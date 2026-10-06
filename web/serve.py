"""Локальный сервер для разработки: как `python3 -m http.server`, но без кэша,
чтобы браузер всегда брал свежие скрипты после правок."""
import functools
import http.server
import sys
from pathlib import Path

PORT = int(sys.argv[1]) if len(sys.argv) > 1 else 8080


class NoCacheHandler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header("Cache-Control", "no-store")
        super().end_headers()


handler = functools.partial(NoCacheHandler, directory=Path(__file__).parent)
print(f"http://localhost:{PORT}")
http.server.ThreadingHTTPServer(("", PORT), handler).serve_forever()
