Guild Market Scanner DEV — v0.1.1
Author: MajesticMinxi

LEAN STORAGE OPTIMIZATION
- Keeps pricing accuracy while reducing SavedVariables size.
- Each guild snapshot becomes a compact numeric array.
- Keeps: listing count, median, Q1, Q3, updated timestamp.
- Removes per-guild min/max.
- Removes duplicated permanent cached price profiles.
- Price suggestions are calculated from compact guild snapshots when queried.
- Many guilds agreeing on a price still dominate the result.
- Isolated extreme guild prices can still be rejected as outliers.
- Future scans remain temporary, then compress to one snapshot per item/guild.

TEST
1. Update to v0.1.1.
2. Before scanning, compare SavedVariables size with ~10.1 MB.
3. Run /gmsprice Perfect Roe and compare the result.
4. If both are good, resume scanning.
