local STLLang = Stylich.Lang
STLLang.msg = STLLang.msg or {}
local m = STLLang.msg

-- Appearance category labels
m.CATEGORY_TYPE_COSTUME = 'Costume'
m.CATEGORY_TYPE_POLYMORPH = 'Polymorph'
m.CATEGORY_TYPE_SKIN = 'Skin'
m.CATEGORY_TYPE_PERSONALITY = 'Personality'
m.CATEGORY_TYPE_HAT = 'Hat'
m.CATEGORY_TYPE_HAIR = 'Hair Style'
m.CATEGORY_TYPE_FACIAL_HAIR_HORNS = 'Facial Hair'
m.CATEGORY_TYPE_FACIAL_ACCESSORY = 'Major Adornments'
m.CATEGORY_TYPE_PIERCING_JEWELRY = 'Minor Adornments'
m.CATEGORY_TYPE_HEAD_MARKING = 'Head Marking'
m.CATEGORY_TYPE_BODY_MARKING = 'Body Marking'
m.CATEGORY_TYPE_VANITY_PET = 'Pet'
m.CATEGORY_TYPE_MOUNT = 'Mount'
m.GEAR_APPEARANCE = 'Appearance (Gear)'

-- Field / section labels
m.STYLE = 'Style'
m.OUTFIT = 'Outfit'
m.TITLE = 'Title'
m.HOTKEY = 'Hotkey'
m.MEMENTO = 'Memento'
m.REVEAL = 'Delay'
m.COMPANION = 'Companion'
m.COMPANION_NONE = '- None -'
m.COMPANION_KEEP = '- Keep -'
m.WEAPONS = 'Weapons'
m.APPLY_SECTION = 'ON APPLY'
m.OPTIONS = 'Options'

-- Dropdown entries
m.SLOT = 'Slot'
m.HOTKEY_NONE = '- None -'
m.MEMENTO_NONE = '- None -'
m.NO_OUTFIT = '- No outfit -'
m.NO_TITLE = '- No title -'
m.WEAPON_UNEQUIP = 'Empty slot (will unequip)'
m.WEAPON_NONE = 'Keep current weapon (this slot is left unchanged)'

-- Options panel
m.OPT_SHOW_BUTTON = 'Show floating button'
m.OPT_SHOW_DROPDOWN = 'Show quick-switch dropdown'
m.OPT_LOCK_BUTTON = 'Lock the floating button position'
m.OPT_PLAY_MEMENTOS = 'Play entrance mementos when applying a style'
m.OPT_HIDE_ON_MENUS = 'Hide Stylich when a menu is open'
m.OPT_CLOSE_COMBAT = 'Close the window when entering combat'
m.OPT_HELP =
	"|cFFAA33How to build a style|r\n"..
	"- Set your look in-game, then press the Update button to capture it.\n"..
	"- Or drag a weapon from your inventory onto a weapon slot.\n"..
	"- Right-click a weapon slot to cycle it: empty (unequip) or keep (leave your weapon).\n"..
	"- Pick an Outfit, a Title and an entrance Memento from the dropdowns.\n\n"..
	"|cFFAA33Entrance memento|r\n"..
	"When you apply a style, its memento plays to mask the change - your new look is revealed as the animation ends. If the memento is still on cooldown, the style won't switch (so the reveal always happens)."

-- Confirmation dialogs
m.CONFIRM_UPDATE_TITLE = 'Update style'
m.CONFIRM_UPDATE_TEXT = "Overwrite \"<<1>>\" with your current appearance?"
m.CONFIRM_DELETE_TITLE = 'Delete style'
m.CONFIRM_DELETE_TEXT = "Delete the style \"<<1>>\"?"

-- Button tooltips
m.TT_NEW = 'New style'
m.TT_RENAME = 'Rename / properties'
m.TT_UPDATE = 'Update from current look'
m.TT_APPLY = 'Apply style'
m.TT_DELETE = 'Delete style'
m.TT_OPTIONS = 'Options'
m.TT_REVEAL = "Delay before your new look appears under the entrance memento. Shorter = quicker reveal; longer lets the memento mask the change longer. Match it to your memento's length."

-- Keybind labels
m.BIND_SHOW = 'Toggle main window'
m.BIND_SLOT = 'Apply style slot'

-- Chat messages
m.MSG_NO_STYLE_SLOT = "Stylich: no style is assigned to hotkey slot <<1>>."
m.MSG_CREATED = "Stylich: created '<<1>>'."
m.MSG_MEMENTO_COOLDOWN = "Stylich: entrance memento not ready (<<1>>s) - style not applied."
m.MSG_WEAPON_NOT_FOUND = "Stylich: weapon not found: <<1>>."
m.MSG_WEAPON_DUP = "Stylich: that weapon is already assigned to another slot."
m.MSG_WEAPON_ONLY = "Stylich: only weapons can be dropped on a weapon slot."
m.MSG_NO_SPACE = "Stylich: not enough space in backpack to unequip <<1>>."
m.MSG_COMBAT_WEAPONS = "Stylich: weapons can't be swapped while in combat."
