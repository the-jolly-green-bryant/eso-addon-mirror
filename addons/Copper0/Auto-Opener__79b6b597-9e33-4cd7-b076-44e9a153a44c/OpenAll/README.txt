PS5 Container Opener
Version 1.3.1-fast2

PS5 Container Opener opens backpack containers one at a time at the fastest
reliable rate allowed by ESO. It automatically loots their contents and keeps
running while the player moves around.

Commands:
  /opencontainers - Start opening containers in the background
  /cancelopen     - Cancel the current run

The add-on automatically pauses during combat, loading screens, death, and
conflicting vendor, bank, mail, trading, or crafting interfaces. It resumes
when the blocked activity ends. ESO's own item-use cooldown cannot be bypassed.

The backpack is rescanned before every opening, allowing all items in stacked
containers to be processed safely even when inventory slots change.

This Add-on is not created by, affiliated with or sponsored by ZeniMax Media
Inc. or its affiliates. The Elder Scrolls® and related logos are registered
trademarks or trademarks of ZeniMax Media Inc. in the United States and/or
other countries. All rights reserved.


Version 1.3.1 changes:
- Hides the shared keyboard/gamepad loot interface immediately after looting.
- Verifies that a container was actually consumed before increasing the opened count.
- Retries temporary rejected or timed-out item uses without inflating the final total.


Tuning change:
- Reduced afterLootDelayMs from 25 ms to 25 ms.


Fast2 timing changes:
- afterLootDelayMs: 25 ms -> 0 ms
- retryDelayMs: 150 ms -> 25 ms
- verificationDelayMs: 45 ms -> 15 ms
- Loot window handling is unchanged.
