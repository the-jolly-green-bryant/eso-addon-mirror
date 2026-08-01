BulkBuy 1.8.2

- The Square Bulk Buy prompt now appears only when at least 2 items can be bought.
- If affordability or storage limits the quantity to 1, the prompt stays hidden.
- All 1.8.1 affordability, Craft Bag, stack-size, and confirmation-dialog behavior is unchanged.

BulkBuy 1.8.1

- Keeps the working native PS5 gamepad confirmation dialog from 1.8.0.
- Treats all recognized crafting-material item types as Craft Bag items.
- With ESO Plus or an active ESO Plus trial, crafting materials are limited only by affordability.
- Without Craft Bag access, crafting materials use live stack information and a 200-item fallback when ESO does not report a stack maximum.
- Vendor potions retain the 100-item fallback and poisons retain the 1000-item fallback.

BulkBuy 1.8.0

- Fixes the PS5 confirmation dialog appearing as a tiny keyboard-style box.
- Opens the confirmation with ZO_Dialogs_ShowGamepadDialog instead of the generic dialog function.
- Uses the standard GAMEPAD_DIALOGS.BASIC layout with native gamepad Accept/Cancel keybinds.

BulkBuy 1.7.9

- Moves the confirmation item and quantity into the large gamepad dialog title for PS5 readability.

BulkBuy 1.7.8

PS5/gamepad ESO add-on that adds a Square keybind for the item currently highlighted in a vendor's Buy list. It purchases the maximum quantity allowed by the player's currency and backpack capacity.

Changes in 1.7.6
- Detects active ESO Plus or an ESO Plus free trial through the ESO API.
- Style-material purchases ignore backpack capacity while Craft Bag access is active.
- Without Craft Bag access, style materials retain the normal partial-stack and empty-slot calculation.
- Affordability remains the final limit for Craft Bag style-material purchases.
- Vendor potions retain the 100-item fallback and poisons retain the 1000-item fallback.

Usage
- Open a vendor's Buy list in gamepad mode.
- Highlight the item to purchase.
- Press Square when the Bulk Buy prompt appears.
- Confirmation is enabled by default.
- /bbconfirm on|off changes confirmation behavior where slash-command input is available.

Important
- The manifest retains APIVersion 101047. Confirm the current console API value before publishing if the uploader reports it as outdated.
- Keep filenames and manifest paths exactly case-matched for PlayStation.
- Test unusual vendor entries, especially collectibles and items with special purchase requirements, before publishing broadly.

Disclaimer
This Add-on is not created by, affiliated with or sponsored by ZeniMax Media Inc. or its affiliates. The Elder Scrolls® and related logos are registered trademarks or trademarks of ZeniMax Media Inc. in the United States and/or other countries. All rights reserved.

Version 1.7.7
- Enlarged the gamepad confirmation dialog body text for improved TV readability.


Version 1.7.8
- Reworked the confirmation dialog font handling for console.
- Uses ZoFontGamepad54 for the confirmation body.
- Reapplies the font after the gamepad dialog finishes layout so ESO's template cannot immediately overwrite it.
- Centers the enlarged message and gives it additional width for TV readability.
