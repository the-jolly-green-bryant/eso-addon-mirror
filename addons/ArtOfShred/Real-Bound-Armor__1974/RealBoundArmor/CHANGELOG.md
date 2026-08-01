### Version 2.2

- Updated API version for Greymoor.
- Added a 50ms delay when EVENT_EFFECT_FADED for one of the Bound Armor morphs is detected. This double checks that Bound Armor was actually removed and not just recasted by the player correcting potential issues with the outfit swapping off when this happened.
- Registered a handler for EVENT_PLAYER_ACTIVATED to handle swapping outfits if the player uses a Wayshrine and the buff fades during that timeframe, logs out with the ability on, etc.

---

### Version 2.1

- Changed the call for LibAddonMenu2.0 to NOT use LibStub.
- Slightly adjusted the addon description.

---

### Version 2.0

- Updated API version for Dragonhold and incremented the saved variables version to fix an issue with one of the default values.
- Removed old Bound Armor AbilityIds.
- Removed embedded LibAddonMenu, you will have to download LAM now if you don't have it.

---

### Version 1.0

- Initial release
