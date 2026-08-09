[B]Development note[/B]
This addon was developed with AI assistance for code generation. The author reviewed the output but cannot personally verify every generated line. Report issues on GitHub: https://github.com/solaegis/eso-combat-lock/issues

[center][color=da8a00]________________________________________________[/color][/center]

[center][size=5][B][color=da8a00]ESO COMBAT LOCK[/color][/B][/size][/center]

EsoCombatLock v1.2.0

Prevents accidental companion and assistant dismissals during combat by guarding your quickslot wheel. Optional post-combat auto-resummon, lock indicator HUD with combat halo and park preview, reorderable park priority, and quickslot activity alerts.

[color=2ea5f1][B]Ready for Update 51 and API 101051[/B] (also compatible with Update 50 / API 101050)[/color]

[center][color=da8a00]________________________________________________[/color][/center]

[B][size=4][color=da8a00]WHY THIS EXISTS[/color][/size][/B]

ZeniMax blocks companion summoning in combat. Addons cannot intercept the quickslot key directly. This addon changes what that key hits while you fight with a companion out: risky collectibles are blocked, and the guard parks on a safe substitute via a memento/empty/consumable cascade.

[center][color=da8a00]________________________________________________[/color][/center]

[B][size=4][color=da8a00]FEATURES[/color][/size][/B]

[LIST]
[*] Combat guard while companion, assistant, or vanity pet is active
[*] Reorderable Park priority for the combat park cascade (last safe, memento, empty, safe consumables, substitute)
[*] Combat substitute resource (default None -- revert to last safe slot; setting one promotes Substitute to the top of Park priority)
[*] Post-combat companion auto-resummon
[*] Optional lock indicator HUD in combat, with pulsing combat halo (color and intensity adjustable)
[*] Park preview icon beside the companion face showing what the quickslot key would activate
[*] Quickslot activity alerts in chat (key read from your bindings)
[*] LibAddonMenu-2.0 settings panel
[*] In-game gold donation via mail to @solaegis
[/LIST]

[center][color=da8a00]________________________________________________[/color][/center]

[B][size=4][color=da8a00]COMMANDS[/color][/size][/B]

[LIST]
[*]/ecl - status and help
[*]/ecl probe / /eclprobe - quickslot index probe
[*]/ecl settings / /eclsettings - open settings (requires LibAddonMenu)
[*]/ecl toggle - toggle the combat guard
[*]/ecl move - temporary indicator reposition (ends on combat or second /ecl move)
[*]/ecl reset - reset indicator position
[*]/ecl resetall - reset all settings to defaults
[*]/ecl testpress - test quickslot-press alert routing
[*]/ecl testglow - force combat halo on/off for diagnostics
[*]/ecl debug - toggle debug logging
[*]/esocombatlock - alias for /ecl
[/LIST]

[color=2ea5f1][B]Tip:[/B] Run [B]/eclprobe[/B] with a companion on your quickslot wheel, then enter combat to confirm the guard reverts risky slots.[/color]

[center][color=da8a00]________________________________________________[/color][/center]

[B][size=4][color=da8a00]INSTALL[/color][/size][/B]

Extract the EsoCombatLock folder into your AddOns directory, enable in the in-game Addons menu, then /reloadui.

[B][size=4][color=da8a00]OPTIONAL DEPENDENCY[/color][/size][/B]

LibAddonMenu-2.0 (settings UI only; core guard works without it)

[center][color=da8a00]________________________________________________[/color][/center]

[B][size=4][color=da8a00]CREDITS[/color][/size][/B]

[LIST]
[*] LibAddonMenu-2.0 by Seerah and community maintainers -- optional settings UI
[*] Quickslot wheel conventions verified against patterns used by AUI and ActionDurationReminder
[/LIST]

MIT License. Not affiliated with ZeniMax Media Inc.
This Add-On is not created by, affiliated with or sponsored by ZeniMax Media Inc. or its affiliates. The Elder Scrolls(R) and related logos are registered trademarks or trademarks of ZeniMax Media Inc. in the United States and/or other countries. All rights reserved.
