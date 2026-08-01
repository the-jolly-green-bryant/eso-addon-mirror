-- Constants -------------------------------------------------------------------
SCHOLAR_NAME    = "Scholar"
SCHOLAR_VERSION = "1.7.0"
SCHOLAR_WEBSITE = "http://www.esoui.com/downloads/info1670-Scholar.html"

-- Local variables -------------------------------------------------------------
local Scholar = ZO_Object:New()

-- Hotkey definition -----------------------------------------------------------
ZO_CreateStringId("SI_BINDING_NAME_SCHOLAR_TITLE", GetString(SCHOLAR_TITLE))
ZO_CreateStringId("SI_BINDING_NAME_SCHOLAR_TOGGLE_TIMERS", GetString(SCHOLAR_KEYBIND_TOGGLE))

-- Utilities -------------------------------------------------------------------
function Scholar:SwapSavedVars(useAccountWide)
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
function Scholar:New()
	local norm                     = ZO_NORMAL_TEXT
	self.FONT_COLOR_NORMAL_DEFAULT = {norm.r, norm.g, norm.b, norm.a}

	self.defaults = {
		enable = {
			timers      = true,
			stableTimer = false
		},
		timers = {
			position = {
				point    = RIGHT,
				relPoint = RIGHT,
				x        = 0,
				y        = 0
			},
			completed = {},
			riding    = {
				inv = -1,
				sta = -1,
				spd = -1
			},
			hideInCombat          = true,
			autoClear             = false,
			notifications         = "none",
			notificationSound     = "Smithing_Finish_Research",
			useAbbr               = false,
			type                  = "time_remaining",
			labelFont             = "BOLD_FONT",
			labelOutline          = "soft-shadow-thick",
			labelSize             = 16,
			timeFont              = "MEDIUM_FONT",
			timeOutline           = "thick-outline",
			timeSize              = 14,
			labelColor            = self.FONT_COLOR_NORMAL_DEFAULT,
			timeColor             = {1, 1, 1, 1},
			clBackgroundColor     = {0.529, 1, 1, 1},
			clGlossColor          = {1, 1, 1, 1},
			smBackgroundColor     = {0.529, 1, 1, 1},
			smGlossColor          = {1, 1, 1, 1},
			wwBackgroundColor     = {0.529, 1, 1, 1},
			wwGlossColor          = {1, 1, 1, 1},
			jcBackgroundColor     = {0.529, 1, 1, 1},
			jcGlossColor          = {1, 1, 1, 1},
			labelAlignment        = "right",
			timerAction           = "fill",
			sort                  = "desc",
			lockUI                = false,
			scale                 = 0.7,
			spacing               = 50,
			stableBackgroundColor = {0.533, 6, 1, 1},
			stableGlossColor      = {1, 1, 1, 1}
		}
	}

	self.savedVariables = {}
	self.savedAccount   = ZO_SavedVars:NewAccountWide("Scholar_SavedVariables", 1.10, nil, self.defaults)
	self.savedCharacter = ZO_SavedVars:New("Scholar_SavedVariables", 1.10, nil, self.defaults)
	self:SwapSavedVars(self.savedAccount.accountWide)

	self:Initialize()

	return self
end

function Scholar:Initialize()
	Scholar_Settings:CreateMenu(self)
	Scholar_Slash_Commands:Initialize(self)

	-- Load modules
	if self.savedVariables.enable.timers or self.savedVariables.enable.stableTimer then
		Scholar_Timers:Initialize(self)
	end
end

local function ScholarOnAddonLoaded(event, addonName)
	if addonName == SCHOLAR_NAME then
		SCHOLAR = Scholar:New()
	end
end
EVENT_MANAGER:RegisterForEvent(SCHOLAR_NAME, EVENT_ADD_ON_LOADED, ScholarOnAddonLoaded)
