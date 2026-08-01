-- Constants -------------------------------------------------------------------
MOTA_NAME    = "MarkOfTheAfflicted"
MOTA_VERSION = "1.2.1"
MOTA_WEBSITE = "http://www.esoui.com/downloads/info1707-MarkOfTheAfflicted.html"

-- Local variables -------------------------------------------------------------
local MotA = ZO_Object:New()

-- Hotkey definition -----------------------------------------------------------
ZO_CreateStringId("SI_BINDING_NAME_MOTA_TITLE", GetString(MOTA_TITLE))
ZO_CreateStringId("SI_BINDING_NAME_MOTA_TOGGLE_TIMERS", GetString(MOTA_KEYBIND_TOGGLE))

-- Utilities -------------------------------------------------------------------
function MotA:SwapSavedVars(useAccountWide)
	if useAccountWide then
		if self.savedAccount == self.defaults then
			self.savedAccount = self.savedCharacter
		end

		self.savedVariables = self.savedAccount
	else
		self.savedVariables = self.savedCharacter
	end
end

-- Initialization --------------------------------------------------------------
function MotA:New()
	local norm                     = ZO_NORMAL_TEXT
	self.FONT_COLOR_NORMAL_DEFAULT = {norm.r, norm.g, norm.b, norm.a}

	self.defaults = {
		enable = {
			timers = true
		},
		timers = {
			position = {
				point    = LEFT,
				relPoint = LEFT,
				x        = 0,
				y        = 0
			},
			showAll               = false,
			hideInCombat          = true,
			notifications         = "none",
			notificationSound     = "Smithing_Finish_Research",
			labelFont             = "BOLD_FONT",
			labelOutline          = "soft-shadow-thick",
			labelSize             = 16,
			timeFont              = "MEDIUM_FONT",
			timeOutline           = "thick-outline",
			timeSize              = 14,
			labelColor            = self.FONT_COLOR_NORMAL_DEFAULT,
			timeColor             = {1, 1, 1, 1},
			vaBackgroundColor     = {0.310, 0.200, 0.424, 1},
			vaGlossColor          = {1, 1, 1, 1},
			wwBackgroundColor     = {0.851, 0.451, 0.145, 1},
			wwGlossColor          = {1, 1, 1, 1},
			labelAlignment        = "left",
			timerAction           = "fill",
			lockUI                = false,
			scale                 = 0.7,
			spacing               = 50
		}
	}

	self.defaultTimers = {
		timers = {}
	}

	self.savedVariables = {}
	self.savedAccount   = ZO_SavedVars:NewAccountWide("MotA_SavedVariables", 1.19, nil, self.defaults)
	self.savedCharacter = ZO_SavedVars:New("MotA_SavedVariables", 1.19, nil, self.defaults)
	self.savedTimers    = ZO_SavedVars:NewAccountWide("MotA_SavedTimers", 1.19, nil, self.defaultTimers)
	self:SwapSavedVars(self.savedAccount.accountWide)

	self:Initialize()

	return self
end

function MotA:Initialize()
	MotA_Settings:CreateMenu(self)
	MotA_Slash_Commands:Initialize(self)

	if self.savedVariables.enable.timers then
		MotA_Timers:Initialize(self)
	end
end

local function MotAOnAddonLoaded(event, addonName)
	if addonName == MOTA_NAME then
		MOTA = MotA:New()
	end
end
EVENT_MANAGER:RegisterForEvent(MOTA_NAME, EVENT_ADD_ON_LOADED, MotAOnAddonLoaded)
