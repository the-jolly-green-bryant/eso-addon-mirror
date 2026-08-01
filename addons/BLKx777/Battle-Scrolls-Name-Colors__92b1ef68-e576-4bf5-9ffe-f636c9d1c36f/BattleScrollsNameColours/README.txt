Battle Scrolls Name Colours v0.4.12-beta
Author: BLKx777

DESCRIPTION
Customised name colours for users with BATTLE SCROLLS installed.

Up to 50 selectable colour options with solid + gradient variant features to help your name stand out or just change to your favorite colour. Changes are only visible to other users who have this addon installed + are also using BATTLE SCROLLS.

These changes do not apply on Hodor similarly how the changes on Hodor do not apply on BATTLE SCROLLS.

There is no fee to pay. Just enjoy the shiny names! :)

~BLK

REQUIREMENTS
- Battle Scrolls
- LibGroupBroadcast
- LibAsync
- Optional: LibHarvensAddonSettings for Settings -> Addons menu controls.

SETTINGS
Open:
Settings -> Addons -> Battle Scrolls Name Colours

Controls:
- Enable name styling
- Show floating preview while editing
- Style selector: Plain colour / Gradient
- Solid Colour selector
- Gradient Start selector
- Gradient End selector

COLOUR PRESETS
This build includes 50 preset colours:
- Black, Near Black, Charcoal, Graphite, Slate, Steel, Ash, Silver, Pale Silver, White
- Blood, Crimson, Scarlet, Red, Rose, Coral
- Ember, Orange, Amber, Gold, Pale Gold, Yellow
- Lime, Toxic, Green, Emerald, Forest, Mint
- Teal, Turquoise, Aqua, Cyan, Ice Blue, Sky Blue, Azure, Royal Blue, Blue, Deep Blue
- Indigo, Violet, Purple, Magenta, Hot Pink, Pink, Rose Pink, Lavender
- Bronze, Copper, Tan, Ivory

STYLE BEHAVIOUR
Plain colour uses the Solid Colour selector only.
Gradient uses Gradient Start and Gradient End as a lightweight left-to-right per-character gradient.

VISIBILITY
You will see your own chosen colour/style locally.
Other group members will see your colour/style only if they also run this addon and Battle Scrolls.
Players who only run normal Battle Scrolls will still see the normal uncoloured name.

INSTALLATION
1. Install Battle Scrolls normally.
2. Install this folder as a separate ESO addon folder:
   BattleScrollsNameColours
3. Ensure folder and file casing exactly matches the manifest paths.
4. Enable Battle Scrolls Name Colours in the addon list.
5. Enable LibHarvensAddonSettings if you want the Settings -> Addons menu.
6. Adjust settings through the addon menu.

CHANGELOG
v0.4.12-beta
- Fixed LibGroupBroadcast payload overflow by sending compact preset colour IDs instead of 24-bit RGB values.
- Uses a new compact protocol layout: solid colour ID, style ID, gradient start ID, gradient end ID.
- Keeps the stable solid colour + standard gradient feature set only.

v0.4.10-beta
- Reverted custom-name/alternating test direction; this build remains solid colour + standard gradient only.
- Fixed LibGroupBroadcast protocol registration/send/receive path so other users with this addon can receive name colours.
- Added lightweight event-based profile resend on group/combat events.

v0.4.9-beta
- Cleaned source comments and developer-only debug output.
- No functional or visual changes from the working v0.4.8 beta.
