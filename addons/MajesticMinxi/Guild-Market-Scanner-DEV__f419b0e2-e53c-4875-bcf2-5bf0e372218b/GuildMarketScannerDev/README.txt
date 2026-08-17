Guild Market Scanner DEV — v0.4.4
Author: MajesticMinxi

BUILD 044 — FINAL EXPORT MEASURER

This build is intentionally ADD-ONLY.

UNCHANGED:
- Scan Trader
- scanner paging
- compact DB
- pricing
- current Price export
- current Supply export
- Cloudflare transport

NEW:
/gmsmeasurefinal

It DOES NOT upload anything.

It measures a proposed final weekly format:

PRICE:
- one deterministic item ID
- suggested price
- trusted low/high range encoded as compact percentage deviations
- confidence
- all stats packed into one base62 number

OPPORTUNITY:
- uses all scanned guilds
- excludes materially underpriced guilds
- detects meaningful low-supply opportunities
- keeps only top 3 strong selling guilds per item
- same sparse records can be inverted server-side for:
  Best Guild to Sell
  What Should I Sell in This Guild?

It reports estimated safe ~4000-character PS5 browser pages for both layers.

TEST:
1. Install v0.4.4.
2. Confirm Scan Trader still appears.
3. Run /gmsmeasurefinal
4. Send screenshot of the three FINAL ... lines.
5. Do NOT export anything.
