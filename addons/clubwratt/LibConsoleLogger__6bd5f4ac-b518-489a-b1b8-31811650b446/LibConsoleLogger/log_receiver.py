#!/usr/bin/env python3
"""Simple log receiver for LibConsoleLogger exports.

Important: LibConsoleLogger sends data in multiple HTTP GETs (chunks). Each request's `d=` param
is a URL-safe base64 string (RFC 4648: '-' and '_' instead of '+' and '/') that may start/end
mid-line. This receiver MUST NOT inject extra newlines or otherwise transform the stream, or the
reconstructed export will be corrupted.

Optional filtering:
- If you pass `--filter`, output becomes a filtered *view* of the stream (line-based).
- For a faithful reconstruction, do NOT use `--filter`.
"""

import argparse
import base64
import http.server
import re
import sys
import urllib.parse

parser = argparse.ArgumentParser(description="Receive LibConsoleLogger exports over HTTP.")
parser.add_argument("port", nargs="?", type=int, default=7878, help="Port to listen on (default: 7878)")
parser.add_argument(
    "--filter",
    dest="filter_pattern",
    default=None,
    help="Regex filter (only output lines that match). Example: --filter 'GUILD|NODE'",
)
args = parser.parse_args()

PORT = args.port
FILTER_RE = re.compile(args.filter_pattern) if args.filter_pattern else None
PENDING = ""


class Handler(http.server.BaseHTTPRequestHandler):
    def log_message(self, format, *args):
        pass  # Suppress default logging

    def do_GET(self):
        global PENDING

        # Parse query string manually so '+' from legacy (non-URL-safe) exports survives.
        parsed = urllib.parse.urlparse(self.path)
        b64 = None
        for part in parsed.query.split("&"):
            if part.startswith("d="):
                # Preserve '+' and only unquote %XX escapes.
                b64 = urllib.parse.unquote(part[2:])
                break

        # Decode and write data WITHOUT adding a newline.
        if b64:
            try:
                # altchars maps URL-safe '-_' to '+/'; legacy '+/' input still decodes.
                decoded = base64.b64decode(b64, altchars=b"-_").decode("utf-8", errors="replace")
                if FILTER_RE is None:
                    sys.stdout.write(decoded)
                    sys.stdout.flush()
                else:
                    # Chunk boundaries can split lines; buffer and filter only on full lines.
                    PENDING += decoded
                    while True:
                        nl = PENDING.find("\n")
                        if nl < 0:
                            break
                        line = PENDING[: nl + 1]
                        PENDING = PENDING[nl + 1 :]
                        if FILTER_RE.search(line):
                            sys.stdout.write(line)
                    sys.stdout.flush()
            except Exception:
                # Keep receiver resilient; a bad chunk shouldn't kill the server.
                pass

        # Auto-close response (lets the in-game webview close itself per chunk)
        self.send_response(200)
        self.send_header("Content-Type", "text/html; charset=utf-8")
        self.send_header("Cache-Control", "no-store")
        self.end_headers()
        html = """<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Logs submitted</title>
    <style>
      :root {
        --bg: #0f8a3a;
        --fg: #f0fff4;
        --card-bg: rgba(255, 255, 255, 0.14);
        --card-border: rgba(255, 255, 255, 0.22);
      }

      html,
      body {
        height: 100%;
        margin: 0;
      }

      body {
        background: radial-gradient(1200px 700px at 50% 35%, rgba(255, 255, 255, 0.18), transparent 55%),
          var(--bg);
        display: flex;
        align-items: center;
        justify-content: center;
        font-family: system-ui, -apple-system, Segoe UI, Roboto, Helvetica, Arial, sans-serif;
        color: var(--fg);
      }

      .card {
        width: min(520px, calc(100vw - 40px));
        padding: 34px 28px;
        border-radius: 18px;
        background: var(--card-bg);
        border: 1px solid var(--card-border);
        box-shadow: 0 18px 50px rgba(0, 0, 0, 0.28);
        backdrop-filter: blur(10px);
        text-align: center;
      }

      .icon {
        width: 90px;
        height: 90px;
        margin: 0 auto 16px auto;
        border-radius: 999px;
        border: 3px solid rgba(240, 255, 244, 0.85);
        display: flex;
        align-items: center;
        justify-content: center;
      }

      .icon svg {
        width: 44px;
        height: 44px;
        stroke: var(--fg);
        stroke-width: 6;
        fill: none;
        stroke-linecap: round;
        stroke-linejoin: round;
      }

      h1 {
        margin: 0;
        font-size: 22px;
        font-weight: 650;
        letter-spacing: 0.2px;
      }

      p {
        margin: 10px 0 0 0;
        font-size: 14px;
        opacity: 0.88;
      }
    </style>
  </head>
  <body>
    <div class="card" role="status" aria-live="polite">
      <div class="icon" aria-hidden="true">
        <svg viewBox="0 0 52 52">
          <path d="M14 27 L22 35 L38 18" />
        </svg>
      </div>
      <h1>Logs submitted successfully</h1>
      <p>You can close this window.</p>
    </div>
    <script>
      // Keep the chunked export flow smooth: auto-close when allowed, but
      // render a decent success screen if the webview/browser stays open.
      setTimeout(function () {
        try {
          window.close();
        } catch (e) {}
      }, 200);
    </script>
  </body>
</html>
"""
        self.wfile.write(html.encode("utf-8", errors="replace"))


if FILTER_RE is None:
    print(f"Listening on port {PORT}", file=sys.stderr)
else:
    print(f"Listening on port {PORT} (filter={args.filter_pattern})", file=sys.stderr)
http.server.HTTPServer(("0.0.0.0", PORT), Handler).serve_forever()
