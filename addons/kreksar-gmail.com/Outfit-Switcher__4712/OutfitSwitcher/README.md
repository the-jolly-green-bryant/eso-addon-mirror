[size=6][b]Outfit Switcher[/b][/size]
[i]by @Kreksar5 and Claude.ai[/i]

[color=orange][b]AI-ASSISTED ADDON.[/b][/color] Written with Claude.ai. This addon has been reviewed and tested in-game by the author for functionality.

A tiny ESO addon that lets you swap between your unlocked outfit slots with a single slash command.

For the full version history, see the Change Log tab, or CHANGELOG.md included in the download.

[size=5][b]Usage[/b][/size]

[code]/outfit <number>[/code]

[list]
[*][b]/outfit 1[/b] — switches to outfit slot 1.
[*]If you type a slot number higher than what your account has unlocked, the addon tells you how many slots you actually have and does nothing else.
[*]If you type anything that isn't a positive whole number (letters, decimals, 0, negative numbers, empty input, etc.), the addon tells you what's wrong instead of erroring or silently failing.
[*]Works identically in keyboard and gamepad mode. Feedback is both printed to chat and raised as an on-screen alert, so you'll see it even if your chat window is closed (common in gamepad play).
[/list]

[size=5][b]Requirements[/b][/size]

[list]
[*]The Outfit System (Update 17 / "Homestead", 2017) must be available — it is on all live accounts today.
[*]No dependencies, no SavedVariables, no settings menu. Nothing to configure.
[/list]

[size=5][b]How It Works[/b][/size]

[list]
[*][b]Check how many outfit slots are unlocked[/b] — GetNumUnlockedOutfits()
[*][b]Swap to a given slot[/b] — EquipOutfit(GAMEPLAY_ACTOR_CATEGORY_PLAYER, outfitIndex)
[*][b]Confirm what actually happened[/b] — EVENT_OUTFIT_EQUIP_RESPONSE (EquipOutfitResult)
[*][b]Show feedback in both keyboard and gamepad mode[/b] — ZO_Alert(category, soundId, message)
[/list]

ZO_Alert automatically routes to the gamepad or keyboard alert-text system depending on which UI mode is currently active, so there's no need for separate gamepad/keyboard code paths in an addon this small.

EquipOutfit doesn't succeed or fail synchronously — the game confirms the result asynchronously via EVENT_OUTFIT_EQUIP_RESPONSE. The addon tracks which slot it just requested and reports the confirmed outcome once that event fires: success, already-equipped, invalid slot, locked slot, or outfit switching being unavailable right now (e.g. certain restricted situations).

[size=5][b]Verification Notes[/b][/size]

Per the usual standard for this addon family: every API call below was confirmed against the ESOUI wiki, the Update 17 API patch notes, and/or the esoui/esoui GitHub source before being used — nothing here is guessed.

[list]
[*]GetNumUnlockedOutfits() — confirmed via Update 17 API patch notes.
[*]EquipOutfit(actorCategory, outfitIndex) — confirmed via ESOUI wiki API page.
[*]GAMEPLAY_ACTOR_CATEGORY_PLAYER — confirmed via esoui/esoui source (interactwindow_shared.lua).
[*]ZO_Alert, UI_ALERT_CATEGORY_ERROR, UI_ALERT_CATEGORY_ALERT — confirmed via esoui/esoui source (interactwindow_shared.lua, tradinghouse_keyboard.lua).
[*]SOUNDS.NEGATIVE_CLICK, SOUNDS.POSITIVE_CLICK — confirmed via ESOUI wiki Sounds page.
[*]zo_strtrim — confirmed via esoui/esoui source (localization.lua).
[*]EVENT_OUTFIT_EQUIP_RESPONSE and the EquipOutfitResult enum values (EQUIP_OUTFIT_RESULT_SUCCESS, _OUTFIT_ALREADY_EQUIPPED, _OUTFIT_INVALID, _OUTFIT_LOCKED, _OUTFIT_SWITCHING_UNAVAILABLE) — confirmed via ESOUI wiki Events page and esoui/esoui's ESOUIDocumentation.txt.
[/list]

[size=5][b]Known Limitations[/b][/size]

[list]
[*]EVENT_OUTFIT_EQUIP_RESPONSE doesn't report which outfit index it's responding to, so the addon tracks the last-requested slot itself and assumes the response belongs to it. If something else in the game or another addon triggers its own outfit equip in the brief window before the response arrives, the reported slot number in the message could be wrong (the success/failure state itself would still be accurate).
[/list]
