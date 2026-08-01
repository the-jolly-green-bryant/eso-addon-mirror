Stacked
=======

ESO Addon: Automagically stack items together

## Configuration
Stacked may be configured via the ingame UI (`ESC > Settings > Addon Settings > Stacked`) or via ingame slash commands. Use `/stacked` or `/stacked help` to get a list of hints.

- `/stack` to start stacking manually
- `/stackgb` to start stacking the guild bank manually
- `/stacked showMessages true` to show, false to hide movement notices
- `/stacked showSlot true` to show, false to hide slot numbers in movement notices
- `/stacked showGBStackDetail true` to show, false to hide detailed messages when doing guild bank stacking
- `/stacked list` to list all items excluded from stacking
- `/stacked exclude 1234` to exclude the item with id 1234
- `/stacked include 1234` to re-include the item with id 1234

For example, to avoid stacking lockpicks into your bag you could check http://esohead.com for the item's id:
`http://esohead.com/items/30357-lockpick` shows the item id being `30357`. Ingame, use `/stacked exclude 30357` and it will no longer be stacked.
You may also add items to be excluded (or included) via `/stacked exclude itemLink`. Simply right-click the item in your inventory and select "Insert into chat" which will give you the item's link directly without any hassle.

## Because ZO requires it
This Add-on is not created by, affiliated with or sponsored by ZeniMax Media Inc. or its affiliates. The Elder Scrolls® and related logos are registered trademarks or trademarks of ZeniMax Media Inc. in the United States and/or other countries. All rights reserved.
