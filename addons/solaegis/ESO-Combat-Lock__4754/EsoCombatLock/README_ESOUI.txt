EsoCombatLock v1.0.1

[b]Development note[/b]
This addon was developed with AI assistance for code generation. The author reviewed the output but cannot personally verify every generated line. Report issues on GitHub: https://github.com/solaegis/eso-combat-lock/issues

Prevents accidental companion and assistant dismissals during combat by guarding your quickslot wheel. Optional post-combat auto-resummon, lock indicator HUD, and quickslot activity alerts.

[b]Why this exists[/b]

ZeniMax blocks companion summoning in combat. Addons cannot intercept the quickslot key directly. This addon changes what that key hits while you fight with a companion out: risky collectibles are blocked, and the guard parks on a safe substitute via a memento/empty/consumable cascade.

[b]Features[/b]

[list]
[*] Combat guard while companion, assistant, or vanity pet is active
[*] Park cascade: blocked memento -> any memento -> empty -> unusable safe -> consumable safe
[*] Combat substitute resource (default None -- revert to last safe slot)
[*] Post-combat companion auto-resummon
[*] Optional lock indicator HUD during armed combat
[*] Quickslot activity alerts (chat and/or center screen; key read from your bindings)
[*] LibAddonMenu-2.0 settings panel
[*] In-game gold donation via mail to @solaegis
[/list]

[b]Commands[/b]

[list]
[*]/ecl - status and help
[*]/eclprobe - quickslot index probe
[*]/ecl settings - open settings (requires LibAddonMenu)
[*]/ecl resetall - reset all settings to defaults
[*]/ecl testalert - test center-screen alert
[*]/ecl move - toggle indicator position lock
[*]/ecl reset - reset indicator position
[/list]

[b]Optional dependency[/b]

LibAddonMenu-2.0 (settings UI only; core guard works without it)

[b]Install[/b]

Extract the EsoCombatLock folder into your AddOns directory, enable in the in-game Addons menu, then /reloadui.

[b]First-run[/b]

Run /eclprobe with a companion on your quickslot wheel, then enter combat to confirm the guard reverts risky slots.

[b]Credits[/b]

[list]
[*] LibAddonMenu-2.0 by Seerah and community maintainers -- optional settings UI
[*] Quickslot wheel conventions verified against patterns used by AUI and ActionDurationReminder
[/list]

MIT License. Not affiliated with ZeniMax Media Inc.
This Add-On is not created by, affiliated with or sponsored by ZeniMax Media Inc. or its affiliates. The Elder Scrolls(R) and related logos are registered trademarks or trademarks of ZeniMax Media Inc. in the United States and/or other countries. All rights reserved.
