local A = IAHelper
local LAM = LibAddonMenu2

local function Donate()
	SCENE_MANAGER:Show('mailSend')
	zo_callLater(function() 
		ZO_MailSendToField:SetText("@andy.s")
		ZO_MailSendSubjectField:SetText("Infinite Archive Helper")
		ZO_MailSendBodyField:SetText("You are awesome!")
		ZO_MailSendBodyField:TakeFocus()
	end, 250)
end

function A.BuildMenu(SV, defaults)

	local panel = {
		type = 'panel',
		name = 'Infinite Archive Helper',
		displayName = 'Infinite Archive Helper',
		author = '|cFFFF00@andy.s|r',
		version = string.format('|c00FF00%s|r', A.version),
		donation = Donate,
		registerForRefresh = true,
	}

	local options = {
		{
			type = "header",
			name = "|cFFFACDGeneral|r",
		},
		{
			type = "checkbox",
			name = "UI Locked",
			tooltip = "Unlock UI to reposition notifications.",
			getFunc = function() return A.uiLocked end,
			setFunc = function(value) A.ToggleUI(value) end,
		},
		{
			type = "checkbox",
			name = "Enable Data Sharing",
			tooltip = "When duo, allows to see other player's verses and visions choices. Requires |cFFFF00LibDataShare|r to work.",
			default = defaults.enableDataSharing,
			getFunc = function() return SV.enableDataSharing end,
			setFunc = function(value)
				SV.enableDataSharing = value or false
			end,
			requiresReload = true,
		},
		{
			type = "checkbox",
			name = "Enable Sounds",
			tooltip = "Play sounds for incoming attacks.",
			default = defaults.enableSounds,
			getFunc = function() return SV.enableSounds end,
			setFunc = function(value)
				SV.enableSounds = value or false
			end,
		},
		{
			type = "checkbox",
			name = "Track incoming attacks",
			tooltip = string.format("Show timers for incoming attacks. Most of them are colored |c%syellow|r, but the most dangerous ones are |c%sred|r. |c%sGreen|r color usually means you should move out of some area, and |c%sblue|r must be blocked. There are some other colors to help distinguish different attacks on bosses, and usually it's up to you if you prefer to block or dodge them.", IA_COLOR_YELLOW, IA_COLOR_RED, IA_COLOR_GREEN, IA_COLOR_BLUE),
			default = defaults.enableTimers,
			getFunc = function() return SV.enableTimers end,
			setFunc = function(value)
				SV.enableTimers = value or false
			end,
		},
		{
			type = "checkbox",
			name = "Track spawns",
			tooltip = "Notify when dangerous enemies spawn.",
			default = defaults.enableWave,
			getFunc = function() return SV.enableWave end,
			setFunc = function(value)
				SV.enableWave = value or false
			end,
		},
		{
			type = "checkbox",
			name = "Enable markers",
			tooltip = "Automatically place markers on dangerous mobs (solo or group leader only). You need to target them first, which means there is a (small) chance a wrong unit will be marked if it's in the way.",
			default = defaults.enableMarkers,
			getFunc = function() return SV.enableMarkers end,
			setFunc = function(value)
				SV.enableMarkers = value or false
			end,
		},
		{
			type = "checkbox",
			name = "Track Weakening Enchantment",
			tooltip = "Show weapon damage reduction on bosses.",
			default = defaults.enableWeakening,
			getFunc = function() return SV.enableWeakening end,
			setFunc = function(value)
				SV.enableWeakening = value or false
			end,
		},
		{
			type = "checkbox",
			name = "Track Major Cowardice",
			tooltip = "The only tracked source for now is nightblade's Mass Hysteria skill.",
			default = defaults.enableMajorCowardice,
			getFunc = function() return SV.enableMajorCowardice end,
			setFunc = function(value)
				SV.enableMajorCowardice = value or false
			end,
		},
		{
			type = "checkbox",
			name = "Track Scorching Support",
			tooltip = "Show cooldown for Scorching Support vision.",
			default = defaults.enableScorchingSupport,
			getFunc = function() return SV.enableScorchingSupport end,
			setFunc = function(value)
				SV.enableScorchingSupport = value or false
			end,
		},
		{
			type = "checkbox",
			name = "Enable Castbar",
			tooltip = "Currently only shows Storm Imps' channeled casts. Note: after arc 8 they become instant.",
			default = defaults.enableCastbar,
			getFunc = function() return SV.enableCastbar end,
			setFunc = function(value)
				SV.enableCastbar = value or false
			end,
		},
		{
			type = "checkbox",
			name = "Hide stage announcement",
			tooltip = "Hide default screen announcement at the beginning of every stage to reduce screen clutter.",
			default = defaults.hideStageAnnouncement,
			getFunc = function() return SV.hideStageAnnouncement end,
			setFunc = function(value)
				SV.hideStageAnnouncement = value or false
			end,
			requiresReload = true,
		},
		{
			type = "header",
			name = "|cFFFACDMisc|r",
		},
		{
			type = "checkbox",
			name = "Debug Mode",
			tooltip = "Display internal events in the game chat.",
			default = false,
			getFunc = function() return A.IsDebugMode() end,
			setFunc = function(value)
				A.SetDebugMode(value or false)
			end,
		},
	}

	local name = A.GetName() .. 'Menu'
	LAM:RegisterAddonPanel(name, panel)
	LAM:RegisterOptionControls(name, options)
end