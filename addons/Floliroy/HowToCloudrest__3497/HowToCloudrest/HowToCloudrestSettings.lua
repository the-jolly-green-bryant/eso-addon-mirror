HowToCloudrest = HowToCloudrest or {}
local HowToCloudrest = HowToCloudrest

local LAM = LibAddonMenu2

local colorChoice = {
  [1] = {1,0,0},
  [2] = {0,1,0},
  [3]	= {0,0,1},
  [4]	= {1,0,1},
  [5]	= {0,1,1},
  [6]	= {1,1,0},
}
local colorChoiceLabel  = {
  [1] = "Red",
  [2]	= "Green",
  [3]	= "Blue",
  [4] = "Pink",
  [5] = "Cyan",
  [6] = "Yellow",
}

local defaultSettingsLabel = {
  [1] = "Show Everything",
  [2]	= "DD (Upstairs)",
  [3]	= "DD (Orb duty)",
  [4]	= "DD (Portal)",
  [5]	= "Heal (Group)",
  [6] = "Heal (Kite)",
  [7]	= "Tank (Portal)",
  [8]	= "Tank (Minis)",
  [9] = "Show nothing",
}

local defaultSettings = {
	-- Show Everything
	[1]	= 	function ()
				local sV = HowToCloudrest.savedVariables.Enable
				-- General
				sV.RazorThorns = true
				sV.HA = false

				-- Mini Frame
				sV.MiniFrame = true
				sV.MiniJump = true
				sV.MiniBash = true
				sV.MiniSkill = true

				sV.Announcement_MiniBash = true

				-- Siroria
				sV.DarkTalons = true
				sV.Flare = true

				-- Relequen
				sV.ReleHA = true
				sV.Overload = true
				sV.Overload_Tabulation = true

				-- Galenwe
				sV.Hoarfrost = true
				sV.ChillingComet = true

				-- Portal
				sV.Portal = true
				sV.Portal_Announcement = true
				sV.MalevolentCores = true
				sV.Spears = true

				-- Z'Maja
				sV.ZmajaJump = true

				sV.CrushingDarkness_Kite = true
				sV.CrushingDarkness_Next = true

				sV.ShadowSplash = true
				sV.BanefulMark = true

				sV.MaliciousSphere_Timer = true
				sV.MaliciousSphere_Announcement = true
				sV.MaliciousSphere_Tracking = true
				sV.MaliciousSphere_Execute = true

				sV.Creeper_Announcement = true
		end,
	-- DD (Upstairs)
	[2]	= 	function ()
				local sV = HowToCloudrest.savedVariables.Enable
				-- General
				sV.RazorThorns = true
				sV.HA = false

				-- Mini Frame
				sV.MiniFrame = true
				sV.MiniJump = true
				sV.MiniBash = true
				sV.MiniSkill = false

				sV.Announcement_MiniBash = false

				-- Siroria
				sV.DarkTalons = true
				sV.Flare = true

				-- Relequen
				sV.ReleHA = true
				sV.Overload = true
				sV.Overload_Tabulation = true

				-- Galenwe
				sV.Hoarfrost = true
				sV.ChillingComet = true

				-- Portal
				sV.Portal = false
				sV.Portal_Announcement = false
				sV.MalevolentCores = false
				sV.Spears = false

				-- Z'Maja
				sV.ZmajaJump = true

				sV.CrushingDarkness_Kite = true
				sV.CrushingDarkness_Next = false

				sV.ShadowSplash = false
				sV.BanefulMark = true

				sV.MaliciousSphere_Timer = false
				sV.MaliciousSphere_Announcement = false
				sV.MaliciousSphere_Tracking = false
				sV.MaliciousSphere_Execute = true

				sV.Creeper_Announcement = true
			end,
	-- DD (Orb duty)
	[3]	= 	function ()
				local sV = HowToCloudrest.savedVariables.Enable
				-- General
				sV.HA = false
				sV.RazorThorns = true

				-- Mini Frame
				sV.MiniFrame = true
				sV.MiniJump = true
				sV.MiniBash = true
				sV.MiniSkill = false

				sV.Announcement_MiniBash = false

				-- Siroria
				sV.DarkTalons = true
				sV.Flare = true

				-- Relequen
				sV.ReleHA = true
				sV.Overload = true
				sV.Overload_Tabulation = true

				-- Galenwe
				sV.Hoarfrost = true
				sV.ChillingComet = true

				-- Portal
				sV.Portal = false
				sV.Portal_Announcement = false
				sV.MalevolentCores = false
				sV.Spears = false

				-- Z'Maja
				sV.ZmajaJump = true

				sV.CrushingDarkness_Kite = true
				sV.CrushingDarkness_Next = false

				sV.ShadowSplash = false
				sV.BanefulMark = true

				sV.MaliciousSphere_Timer = true
				sV.MaliciousSphere_Announcement = true
				sV.MaliciousSphere_Tracking = true
				sV.MaliciousSphere_Execute = true

				sV.Creeper_Announcement = true
			end,
	-- DD (Portal)
	[4]	= 	function ()
				local sV = HowToCloudrest.savedVariables.Enable
				-- General
				sV.HA = false
				sV.RazorThorns = true

				-- Mini Frame
				sV.MiniFrame = true
				sV.MiniJump = true
				sV.MiniBash = true
				sV.MiniSkill = false

				sV.Announcement_MiniBash = false

				-- Siroria
				sV.DarkTalons = true
				sV.Flare = true

				-- Relequen
				sV.ReleHA = true
				sV.Overload = true
				sV.Overload_Tabulation = true

				-- Galenwe
				sV.Hoarfrost = true
				sV.ChillingComet = true

				-- Portal
				sV.Portal = true
				sV.Portal_Announcement = true
				sV.MalevolentCores = true
				sV.Spears = true

				-- Z'Maja
				sV.ZmajaJump = true

				sV.CrushingDarkness_Kite = true
				sV.CrushingDarkness_Next = false

				sV.ShadowSplash = false
				sV.BanefulMark = true

				sV.MaliciousSphere_Timer = false
				sV.MaliciousSphere_Announcement = false
				sV.MaliciousSphere_Tracking = false
				sV.MaliciousSphere_Execute = true

				sV.Creeper_Announcement = true
			   end,
	-- Heal (Group)
	[5]	= 	function ()
				local sV = HowToCloudrest.savedVariables.Enable
				-- General
				sV.HA = false
				sV.RazorThorns = true

				-- Mini Frame
				sV.MiniFrame = true
				sV.MiniJump = true
				sV.MiniBash = true
				sV.MiniSkill = false

				sV.Announcement_MiniBash = false

				-- Siroria
				sV.DarkTalons = true
				sV.Flare = true

				-- Relequen
				sV.ReleHA = true
				sV.Overload = true
				sV.Overload_Tabulation = true

				-- Galenwe
				sV.Hoarfrost = true
				sV.ChillingComet = true

				-- Portal
				sV.Portal = false
				sV.Portal_Announcement = false
				sV.MalevolentCores = false
				sV.Spears = false

				-- Z'Maja
				sV.ZmajaJump = true

				sV.CrushingDarkness_Kite = true
				sV.CrushingDarkness_Next = false

				sV.ShadowSplash = false
				sV.BanefulMark = true

				sV.MaliciousSphere_Timer = true
				sV.MaliciousSphere_Announcement = true
				sV.MaliciousSphere_Tracking = true
				sV.MaliciousSphere_Execute = true

				sV.Creeper_Announcement = true
			end,
	-- Heal (Kite)
	[6]	= 	function ()
				local sV = HowToCloudrest.savedVariables.Enable
				-- General
				sV.HA = false
				sV.RazorThorns = true

				-- Mini Frame
				sV.MiniFrame = true
				sV.MiniJump = true
				sV.MiniBash = true
				sV.MiniSkill = false

				sV.Announcement_MiniBash = false

				-- Siroria
				sV.DarkTalons = true
				sV.Flare = true

				-- Relequen
				sV.ReleHA = true
				sV.Overload = true
				sV.Overload_Tabulation = true

				-- Galenwe
				sV.Hoarfrost = true
				sV.ChillingComet = true

				-- Portal
				sV.Portal = false
				sV.Portal_Announcement = false
				sV.MalevolentCores = false
				sV.Spears = true

				-- Z'Maja
				sV.ZmajaJump = true

				sV.CrushingDarkness_Kite = true
				sV.CrushingDarkness_Next = true

				sV.ShadowSplash = false
				sV.BanefulMark = true

				sV.MaliciousSphere_Timer = false
				sV.MaliciousSphere_Announcement = false
				sV.MaliciousSphere_Tracking = false
				sV.MaliciousSphere_Execute = false

				sV.Creeper_Announcement = true
			end,
	-- Tank (Portal)
    [7]	= 	function ()
				local sV = HowToCloudrest.savedVariables.Enable
				-- General
				sV.HA = false
				sV.RazorThorns = true

				-- Mini Frame
				sV.MiniFrame = true
				sV.MiniJump = true
				sV.MiniBash = true
				sV.MiniSkill = false

				sV.Announcement_MiniBash = false

				-- Siroria
				sV.DarkTalons = true
				sV.Flare = true

				-- Relequen
				sV.ReleHA = true
				sV.Overload = true
				sV.Overload_Tabulation = true

				-- Galenwe
				sV.Hoarfrost = true
				sV.ChillingComet = true

				-- Portal
				sV.Portal = true
				sV.Portal_Announcement = true
				sV.MalevolentCores = true
				sV.Spears = true

				-- Z'Maja
				sV.ZmajaJump = true

				sV.CrushingDarkness_Kite = true
				sV.CrushingDarkness_Next = true

				sV.ShadowSplash = true
				sV.BanefulMark = true

				sV.MaliciousSphere_Timer = false
				sV.MaliciousSphere_Announcement = false
				sV.MaliciousSphere_Tracking = false
				sV.MaliciousSphere_Execute = false

				sV.Creeper_Announcement = true
			end,
	-- Tank (Minis)
	[8]	= 	function ()
				local sV = HowToCloudrest.savedVariables.Enable
				-- General
				sV.HA = false
				sV.RazorThorns = true

				-- Mini Frame
				sV.MiniFrame = true
				sV.MiniJump = true
				sV.MiniBash = true
				sV.MiniSkill = true

				sV.Announcement_MiniBash = true

				-- Siroria
				sV.DarkTalons = true
				sV.Flare = true

				-- Relequen
				sV.ReleHA = true
				sV.Overload = true
				sV.Overload_Tabulation = true

				-- Galenwe
				sV.Hoarfrost = true
				sV.ChillingComet = true

				-- Portal
				sV.Portal = false
				sV.Portal_Announcement = false
				sV.MalevolentCores = false
				sV.Spears = false

				-- Z'Maja
				sV.ZmajaJump = true

				sV.CrushingDarkness_Kite = true
				sV.CrushingDarkness_Next = true

				sV.ShadowSplash = false
				sV.BanefulMark = false

				sV.MaliciousSphere_Timer = false
				sV.MaliciousSphere_Announcement = false
				sV.MaliciousSphere_Tracking = false
				sV.MaliciousSphere_Execute = false

				sV.Creeper_Announcement = true
			   end,
	-- Show nothing
	[9]	= 	function ()
				local sV = HowToCloudrest.savedVariables.Enable
				-- General
				sV.RazorThorns = false
				sV.HA = false

				-- Mini Frame
				sV.MiniFrame = false
				sV.MiniJump = false
				sV.MiniBash = false
				sV.MiniSkill = false

				sV.Announcement_MiniBash = false

				-- Siroria
				sV.DarkTalons = false
				sV.Flare = false

				-- Relequen
				sV.ReleHA = false
				sV.Overload = false
				sV.Overload_Tabulation = false

				-- Galenwe
				sV.Hoarfrost = false
				sV.ChillingComet = false

				-- Portal
				sV.Portal = false
				sV.Portal_Announcement = false
				sV.MalevolentCores = false
				sV.Spears = false

				-- Z'Maja
				sV.ZmajaJump = false

				sV.CrushingDarkness_Kite = false
				sV.CrushingDarkness_Next = false

				sV.ShadowSplash = false
				sV.BanefulMark = false

				sV.MaliciousSphere_Timer = false
				sV.MaliciousSphere_Announcement = false
				sV.MaliciousSphere_Tracking = false
				sV.MaliciousSphere_Execute = false

				sV.Creeper_Announcement = false
	end,
}

function HowToCloudrest.UnlockUI(newValue)
	local sV = HowToCloudrest.savedVariables
	HowToCloudrest.SetDefaultUIValues()
	HowToCloudrest.SetMiniFrameDefault()
	-- General
	if (sV.Enable.HA) then
		HTC_Ha:SetHidden(not newValue)
	end

	if (sV.Enable.DarkTalons or sV.Enable.RazorThorns) then
		HTC_Rooted:SetHidden(not newValue)
	end

	if (sV.Enable.MiniFrame) then
		HTC_MiniFrame:SetHidden(not newValue)
	end
	if (sV.Enable.Announcement_MiniBash) then
		HTC_Announcement_MiniBash:SetHidden(not newValue)
	end

	-- Siroria
	if (sV.Enable.Flare) then
		HTC_Flare:SetHidden(not newValue)
	end

	-- Relequen
	if (sV.Enable.ReleHA) then
		HTC_ReleHA:SetHidden(not newValue)
	end
	if (sV.Enable.Overload) then
		HTC_OverloadTimer:SetHidden(not newValue)
	end

	-- Galenwe
	if (sV.Enable.Hoarfrost) then
		HTC_Hoarfrost:SetHidden(not newValue)
	end
	if (sV.Enable.ChillingComet) then
		HTC_ChillingComet:SetHidden(not newValue)
	end

	-- Portal
	if (sV.Enable.Portal) then
		HTC_Portal:SetHidden(not newValue)
	end
	if (sV.Enable.Portal_Announcement) then
		HTC_Portal_Announcement:SetHidden(not newValue)
	end

	-- Z'Maja
	if (sV.Enable.ZmajaJump) then
		HTC_ZmajaJump:SetHidden(not newValue)
	end

	if (sV.Enable.CrushingDarkness_Kite) then
		HTC_CrushingDarkness_Kite:SetHidden(not newValue)
	end
	if (sV.Enable.CrushingDarkness_Next) then
		HTC_CrushingDarkness_Next:SetHidden(not newValue)
	end

	if (sV.Enable.ShadowSplash) then
		HTC_ShadowSplash:SetHidden(not newValue)
	end
	if (sV.Enable.BanefulMark) then
		HTC_BanefulMark:SetHidden(not newValue)
	end

	if (sV.Enable.MaliciousSphere_Timer) then
		HTC_MaliciousSphere_Timer:SetHidden(not newValue)
	end
	if (sV.Enable.MaliciousSphere_Announcement) then
		HTC_MaliciousSphere_Announcement:SetHidden(not newValue)
	end
	if (sV.Enable.MaliciousSphere_Tracking) then
		HTC_MaliciousSphere_Tracking:SetHidden(not newValue)
	end

	if (sV.Enable.Creeper_Announcement) then
		HTC_Creeper_Announcement:SetHidden(not newValue)
	end
end

function HowToCloudrest.CreateSettingsWindow()
	local panelData = {
		type = "panel",
		name = "HowToCloudrest",
		displayName = "HowTo|cff00ffCloudrest|r",
		author = "Floliroy, |cc0c0c0@|rn|cc0c0c0ogetrandom|r, XL_Olsen",
		version = HowToCloudrest.version,
		slashCommand = "/HowToCloudrest",
		registerForRefresh = true,
		registerForDefaults = true,
	}

	local cntrlOptionsPanel = LAM:RegisterAddonPanel("HowToCloudrest_Settings", panelData)
	local Unlock = {
		Everything = false,
		-- General
		HA = false,

		MiniFrame = false,
		Announcement_MiniBash = false,

		Rooted = false,

		-- Siroria
		Flare = false,

		-- Relequen
		ReleHA = false,
		DirectCurrent = false,
		Overload = false,
		OverloadOverlay = false,

		-- Galenwe
		Hoarfrost = false,
		ChillingComet = false,
		GlacialSpikes = false,

		-- Portal
		Portal = false,
		Portal_Announcement = false,

		-- Z'Maja
		ZmajaJump = false,

		CrushingDarkness_Kite = false,
		CrushingDarkness_Next = false,

		ShadowSplash = false,
		BanefulMark = false,

		MaliciousSphere_Timer = false,
		MaliciousSphere_Announcement = false,
		MaliciousSphere_Tracking = false,

		Creeper_Announcement = false,
	}

	local sV = HowToCloudrest.savedVariables

	local optionsData = {
		{
			type = "dropdown",
			name = "Default 'enabled' profiles",
			tooltip = "'Enabled' profiles are presets of which UI elements are recommended to be shown for the specific selected role.",
			choices = defaultSettingsLabel,
			default = defaultSettingsLabel[1],
			getFunc = function() return sV.defaultSettingsChoice end,
			setFunc = function(selected)
				for index, name in ipairs(defaultSettingsLabel) do
					if name == selected then
						sV.defaultSettingsChoice = name
						if Unlock.Everything then
							HowToCloudrest.UnlockUI(not Unlock.Everything)
						end
						defaultSettings[index]()
						if Unlock.Everything then
							HowToCloudrest.UnlockUI(Unlock.Everything)
						end
						break
					end
				end
			end,
		},
		{
			type = "description",
			text = "|cff0000WARNING:|r These profiles overrides the 'enabled' settings you already customized. However it does not change sizes or placement of elements you've already customized. The profiles are cannot be changed (i.e. there's no way to save a profile yet!).",
		},
		{
			type = "checkbox",
			name = "Unlock Everything",
			tooltip = "Use it to set the position of all enabled notifications.",
			default = false,
			getFunc = function() return Unlock.Everything end,
			setFunc = function(newValue)
				Unlock.Everything = newValue
				HowToCloudrest.SetDefaultUIValues()
				HowToCloudrest.UnlockUI(newValue)
			end,
		},
		{
			type = "description",
			text = "Test Center Screen Announcement (CSA):",
		},
		{
			type = "button",
			name = "Test CSA",
			func =
				function ()
					local CSA = CENTER_SCREEN_ANNOUNCE
					local messageParams = CSA:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT, SOUNDS.SKILL_LINE_ADDED)
					messageParams:SetText("Test Center Screen Announcement")
					messageParams:SetPriority(1)
					CSA:AddMessageWithParams(messageParams)
				end,
		},
		{
			type = "submenu",
			name = "General",
			controls = {
				{
					type = "header",
					name = "Rooted alert options",
				},
				{
					type = "checkbox",
					name = "Enable Razor Thorns alert",
					tooltip = "Show alert when Creepers has rooted you with Razor Thorns.",
					default = true,
					getFunc = function() return sV.Enable.RazorThorns end,
					setFunc = function(newValue)
						sV.Enable.RazorThorns = newValue
						if (Unlock.Everything or Unlock.Rooted) then
							HTC_Rooted:SetHidden(not newValue)
						else
							HTC_Rooted:SetHidden(newValue)
						end
					end,
				},
				{
					type = "checkbox",
					name = "Enable Dark Talons alert",
					tooltip = "Show alert when Siroria casts Dark Talons on you (rooted).",
					default = true,
					getFunc = function() return sV.Enable.DarkTalons end,
					setFunc = function(newValue)
						sV.Enable.DarkTalons = newValue
						if (Unlock.Everything or Unlock.Rooted) then
							HTC_Rooted:SetHidden(not newValue)
						else
							HTC_Rooted:SetHidden(newValue)
						end
					end,
				},
				{
					type = "checkbox",
					name = "Unlock Rooted alert",
					tooltip = "Set the position of rooting notifications (Creepers' Razor Thorns & Sirorias' Dark Talons).",
					default = false,
					getFunc = function() return Unlock.Rooted end,
					setFunc = function(newValue)
						Unlock.Rooted = newValue
						HowToCloudrest.SetDefaultUIValues()
						HTC_Rooted:SetHidden(not newValue)
					end,
				},
				{
					type = "slider",
					name = "Rooted alert size",
					tooltip = "Set the size of Creeper and Dark Talons ROOTED alerts.",
					getFunc = function() return sV.FontSize_Rooted end,
					setFunc = function(newValue)
						sV.FontSize_Rooted = newValue
						HowToCloudrest.SetAllFontSizes()
					end,
					min = 22,
					max = 58,
					step = 2,
					default = 32,
					width = "full",
				},
			}
		},
		{
			type = "submenu",
			name = "Mini Boss Options",
			controls = {
				{
					type = "header",
					name = "General",
				},
				{
					type = "checkbox",
					name = "Enable Mini Boss Frame",
					tooltip = "Show the Mini Boss Frame containing information about mini jump, interrupts, and special skills.",
					default = true,
					getFunc = function() return sV.Enable.MiniFrame end,
					setFunc = function(newValue)
						sV.Enable.MiniFrame = newValue
						if (Unlock.Everything or Unlock.MiniFrame) then
							HTC_MiniFrame:SetHidden(not newValue)
						else
							HTC_MiniFrame:SetHidden(newValue)
						end
					end,
				},
				{
					type = "checkbox",
					name = "Unlock Mini Boss Frame",
					tooltip = "Set the position of the Mini Boss Frame.",
					default = false,
					getFunc = function() return Unlock.MiniFrame end,
					setFunc = function(newValue)
						Unlock.MiniFrame = newValue
						HowToCloudrest.SetMiniFrameDefault()
						HowToCloudrest.SetDefaultUIValues()
						HTC_MiniFrame:SetHidden(not newValue)
					end,
				},
				{
					type = "slider",
					name = "Mini Boss frame size",
					tooltip = "Set the size of the Mini Boss Frame.",
					getFunc = function() return sV.Size_MiniFrame end,
					setFunc = function(newValue)
						sV.Size_MiniFrame = newValue
						HowToCloudrest.SetSize_MiniFrame()
					end,
					min = 1,
					max = 12,
					step = 1,
					default = 5,
					decimals = 0,
					width = "full",
				},
				{
					type = "divider",
				},
				{
					type = "checkbox",
					name = "Enable Mini Jump Tracking",
					tooltip = "Show a timer that tells you when the Mini Boss jumps are off cooldown.",
					default = true,
					getFunc = function() return sV.Enable.MiniJump end,
					setFunc = function(newValue)
						sV.Enable.MiniJump = newValue
						HowToCloudrest.SetMiniFrameDefault()
					end,
				},
				{
					type = "checkbox",
					name = "Enable Mini Bash Tracking",
					tooltip = "Show a timer that tells you when Galenwe Glacial Spikes & Relequen Direct Current are off cooldown.",
					default = true,
					getFunc = function() return sV.Enable.MiniBash end,
					setFunc = function(newValue)
						sV.Enable.MiniBash = newValue
						HowToCloudrest.SetMiniFrameDefault()
					end,
				},
				{
					type = "checkbox",
					name = "Enable Mini Boss skill tracking",
					tooltip = "Show a timer that tells you when Siroria Standard & Galenwe Donut are off cooldown.",
					default = true,
					getFunc = function() return sV.Enable.MiniSkill end,
					setFunc = function(newValue)
						sV.Enable.MiniSkill = newValue
						HowToCloudrest.SetMiniFrameDefault()
					end,
				},
				{
					type = "divider"
				},
				{
					type = "checkbox",
					name = "Enable Mini Boss BASH alerts",
					tooltip = "Show an alert when Relequens Direct Current & Galenwes Glacial Spikes are being channeled.",
					default = true,
					getFunc = function() return sV.Enable.Announcement_MiniBash end,
					setFunc = function(newValue)
						sV.Enable.Announcement_MiniBash = newValue
						if (Unlock.Everything or Unlock.Announcement_MiniBash) then
							HTC_Announcement_MiniBash:SetHidden(not newValue)
						else
							HTC_Announcement_MiniBash:SetHidden(newValue)
						end
					end,
				},
				{
					type = "checkbox",
					name = "Unlock Mini Boss BASH alerts",
					tooltip = "Set the position of Relequens Direct Current & Galenwes Glacial Spikes interrupt alerts.",
					default = false,
					getFunc = function() return Unlock.Announcement_MiniBash end,
					setFunc = function(newValue)
						Unlock.Announcement_MiniBash = newValue
						HowToCloudrest.SetDefaultUIValues()
						HTC_Announcement_MiniBash:SetHidden(not newValue)
					end,
				},
				{
					type = "slider",
					name = "Mini Boss BASH size",
					tooltip = "Set the size of Mini Boss BASH alerts",
					getFunc = function() return sV.FontSize_BashAnnouncement end,
					setFunc = function(newValue)
						sV.FontSize_BashAnnouncement = newValue
						HowToCloudrest.SetAllFontSizes()
					end,
					min = 22,
					max = 58,
					step = 2,
					default = 32,
					width = "full",
				},
				{
					type = "divider",
				},
				{	type = "checkbox",
					name = "Enable Mini Boss Heavy Attack alert",
					tooltip = "Tracks all Heavy Attacks from mini bosses.",
					default = true,
					getFunc = function() return sV.Enable.HA end,
					setFunc = function(newValue)
						sV.Enable.HA = newValue
						if (Unlock.Everything or Unlock.HA) then
							HTC_Ha:SetHidden(not newValue)
						else
							HTC_Ha:SetHidden(newValue)
						end
					end,
				},
				{
					type = "checkbox",
					name = "Unlock Mini Boss Heavy Attack alert",
					tooltip = "Set the position of the Heavy Attacks timer.",
					default = false,
					getFunc = function() return Unlock.HA end,
					setFunc = function(newValue)
						Unlock.HA = newValue
						HowToCloudrest.SetDefaultUIValues()
						HTC_Ha:SetHidden(not newValue)
					end,
				},
				{
					type = "slider",
					name = "Mini Heavy Attack alert size",
					tooltip = "Set the size of Mini Heavy Attack alert.",
					getFunc = function() return sV.FontSize_HA end,
					setFunc = function(newValue)
								sV.FontSize_HA = newValue
								HowToCloudrest.SetAllFontSizes()
							end,
					min = 22,
					max = 58,
					step = 2,
					default = 32,
					width = "full",
				},

				-- {
				-- 	type = "desciption",
				-- 	name = "Siroria",
				-- },

				{
					type = "header",
					name = "Siroria",
				},
				{
					type = "checkbox",
                    name = "Enable Roaring Flare alert",
                    tooltip = "Show on who is Roaring Flare, and display right and left for execute.",
                    default = true,
                    getFunc = function() return sV.Enable.Flare end,
                    setFunc = function(newValue)
						sV.Enable.Flare = newValue
						if (Unlock.Everything or Unlock.Flare) then
							HTC_Flare:SetHidden(not newValue)
						else
							HTC_Flare:SetHidden(newValue)
						end
                    end,
                },
                {
					type = "checkbox",
                    name = "Unlock Roaring Flare alert",
                    tooltip = "Use it to set the position of Roaring Flare notifications.",
                    default = false,
                    getFunc = function() return Unlock.Flare end,
                    setFunc = function(newValue)
                        Unlock.Flare = newValue
                        HowToCloudrest.SetDefaultUIValues()
                        HTC_Flare:SetHidden(not newValue)
                    end,
                },
                {
					type = "slider",
                    name = "Flare alert size",
                    tooltip = "Set the size of Hoarfrost notifications.",
                    getFunc = function() return sV.FontSize_Flare end,
                    setFunc = function(newValue)
                        sV.FontSize_Flare = newValue
                        HowToCloudrest.SetAllFontSizes()
                    end,
                    min = 22,
                    max = 58,
                    step = 2,
                    default = 40,
                    width = "full",
				},
				{
					type = "header",
					name = "Relequen",
				},
				{
					type = "checkbox",
					name = "Enable Relequen Heavy Attack alert",
					tooltip = "Show a timer when you need to look out for AoE from Relequens Heavy Attack.",
					default = true,
					getFunc = function() return sV.Enable.ReleHA end,
					setFunc = function(newValue)
						sV.Enable.ReleHA = newValue
						if (Unlock.Everything or Unlock.ReleHA) then
							HTC_ReleHA:SetHidden(not newValue)
						else
							HTC_ReleHA:SetHidden(newValue)
						end
					end,
				},
				{
					type = "checkbox",
					name = "Unlock Relequen Heavy Attack alert",
					tooltip = "Set the position of the Relequen Heavy Attack alert.",
					default = false,
					getFunc = function() return Unlock.ReleHA end,
					setFunc = function(newValue)
						Unlock.ReleHA = newValue
						HowToCloudrest.SetDefaultUIValues()
						HTC_ReleHA:SetHidden(not newValue)
					end,
				},
				{
					type = "slider",
					name = "Relequen Heavy Attack alert size",
					tooltip = "Set the size of Relequen Heavy Attack alert.",
					getFunc = function() return sV.FontSize_ReleHA end,
					setFunc = function(newValue)
								sV.FontSize_ReleHA = newValue
								HowToCloudrest.SetAllFontSizes()
							end,
					min = 22,
					max = 58,
					step = 2,
					default = 32,
					width = "full",
				},
				{
					type = "divider",
				},
				{
					type = "checkbox",
					name = "Enable Overload alert",
					tooltip = "Tracks Overload mechanic and duration for yourself.",
					default = true,
					getFunc = function() return sV.Enable.Overload end,
					setFunc = function(newValue)
						sV.Enable.Overload = newValue
						if (Unlock.Everything or Unlock.Overload) then
							HTC_OverloadTimer:SetHidden(not newValue)
						else
							HTC_OverloadTimer:SetHidden(newValue)
						end
					end,
				},
				{
					type = "checkbox",
					name = "Unlock Overload alert",
					tooltip = "Set the position of the Overload alert.",
					default = false,
					getFunc = function() return Unlock.Overload end,
					setFunc = function(newValue)
						Unlock.Overload = newValue
						HowToCloudrest.SetDefaultUIValues()
						HTC_OverloadTimer:SetHidden(not newValue)
					end,
				},
				{
					type = "slider",
					name = "Overload alert size",
					tooltip = "Set the size of the overload alerts",
					getFunc = function() return sV.FontSize_Overload end,
					setFunc = function(newValue)
						sV.FontSize_Overload = newValue
						HowToCloudrest.SetAllFontSizes()
					end,
					min = 22,
					max = 58,
					step = 2,
					default = 50,
					width = "full",
				},
				{
					type = "checkbox",
					name = "Enable Overload Overlay",
					tooltip = "Shows a colored overlay on the sides of your screen while having Overload.",
					default = false,
					getFunc = function() return sV.Enable.Overload_Overlay end,
					setFunc = function(newValue)
						sV.Enable.Overload_Overlay = newValue
					end,
				},
				{
					type = "checkbox",
					name = "Show Overload Overlay",
					tooltip = "Use it to show the Overload Overlay to check the color.",
					default = false,
					getFunc = function() return Unlock.OverloadOverlay end,
					setFunc = function(newValue)
						Unlock.OverloadOverlay = newValue
						HowToCloudrest.SetDefaultUIValues()
						HTC_Overload:SetHidden(not newValue)
					end,
				},
				{	type = "checkbox",
					name = "Enable Overload Blinking/Tabulation",
					tooltip = "When enabled, the overload 'DONT SWITCH' text will blink, making it easier to track.",
					default = true,
					getFunc = function() return sV.Enable.Overload_Tabulation end,
					setFunc = function(newValue)
						sV.Enable.Overload_Tabulation = newValue
					end,
				},
				{
					type = "slider",
					name = "Overload Blinking/Tabulation frequency",
					tooltip = "Set the frequency of the overload blinking/tabulation.",
					getFunc = function() return sV.OverloadFrequency end,
					setFunc = function(newValue)
						sV.OverloadFrequency = newValue
					end,
					min = 1,
					max = 20,
					step = 1,
					default = 5,
					width = "full",
				},
				{
					type = "dropdown",
					name = "Overload Overlay Color",
					tooltip = "Choose the Color that you want for the overload overlay.",
					choices = colorChoiceLabel,
					default = colorChoiceLabel[4],
					getFunc = function() return colorChoiceLabel[sV.overloadColorChoice] end,
					setFunc = function(selected)
						for index, name in ipairs(colorChoiceLabel) do
							if name == selected then
								sV.overloadColorChoice = index
								sV.overloadColor = colorChoice[index]
								local c = sV.overloadColor
								HowToCloudrest.SetOverloadOverlay(c[1], c[2], c[3])
								break
							end
						end
					end,
				},

				{
					type = "header",
					name = "Galenwe",
				},
				{
					type = "checkbox",
                    name = "Enable Hoarfrost alert",
                    tooltip = "Track when Hoarfrost needs to be dropped, and when it is dropped by another person.",
                    default = true,
                    getFunc = function() return sV.Enable.Hoarfrost end,
                    setFunc = function(newValue)
						sV.Enable.Hoarfrost = newValue
						if (Unlock.Everything or Unlock.Hoarfrost) then
							HTC_Hoarfrost:SetHidden(not newValue)
						else
							HTC_Hoarfrost:SetHidden(newValue)
						end
                    end,
                },
                {
					type = "checkbox",
                    name = "Unlock Hoarfrost alert",
                    tooltip = "Use it to set the position of Hoarfrost notifications.",
                    default = false,
                    getFunc = function() return Unlock.Hoarfrost end,
                    setFunc = function(newValue)
                        Unlock.Hoarfrost = newValue
                        HowToCloudrest.SetDefaultUIValues()
                        HTC_Hoarfrost:SetHidden(not newValue)
                    end,
                },
                {
					type = "slider",
                    name = "Hoarfrost alert size",
                    tooltip = "Set the size of Hoarfrost notifications.",
                    getFunc = function() return sV.FontSize_Hoarfrost end,
                    setFunc = function(newValue)
                        sV.FontSize_Hoarfrost = newValue
                        HowToCloudrest.SetAllFontSizes()
                    end,
                    min = 22,
                    max = 58,
                    step = 2,
                    default = 40,
                    width = "full",
				},
				{
					type = "divider",
				},
				{
					type = "checkbox",
                    name = "Enable Chilling Comet alert",
                    tooltip = "Tells you when Chilling Comet is cast on you.",
                    default = true,
                    getFunc = function() return sV.Enable.ChillingComet end,
                    setFunc = function(newValue)
						sV.Enable.ChillingComet = newValue
						if (Unlock.Everything or Unlock.ChillingComet) then
							HTC_ChillingComet:SetHidden(not newValue)
						else
							HTC_ChillingComet:SetHidden(newValue)
						end
                    end,
                },
                {
					type = "checkbox",
                    name = "Unlock Chilling Comet alert",
                    tooltip = "Set the position of the Chilling Comet alert.",
                    default = false,
                    getFunc = function() return Unlock.ChillingComet end,
                    setFunc = function(newValue)
                        Unlock.ChillingComet = newValue
                        HowToCloudrest.SetDefaultUIValues()
                        HTC_ChillingComet:SetHidden(not newValue)
                    end,
                },
                {
					type = "slider",
                    name = "ChillingComet alert size",
                    tooltip = "Set the size of Chilling Comet alert.",
                    getFunc = function() return sV.FontSize_ChillingComet end,
                    setFunc = function(newValue)
                        sV.FontSize_ChillingComet = newValue
                        HowToCloudrest.SetAllFontSizes()
                    end,
                    min = 22,
                    max = 58,
                    step = 2,
                    default = 40,
                    width = "full",
                },
			} -- Mini Boss submenu end
		},
		{
			type = "submenu",
			name = "Portal Options",
			controls = {
				{
					type = "checkbox",
					name = "Enable Portal Tracking",
					tooltip = "Show the timers for the portal, and which group is up next.",
					default = false,
					getFunc = function() return sV.Enable.Portal end,
					setFunc = function(newValue)
						sV.Enable.Portal = newValue
						if (Unlock.Everything or Unlock.Portal) then
							HTC_Portal:SetHidden(not newValue)
						else
							HTC_Portal:SetHidden(newValue)
						end
					end
				},
				{
					type = "checkbox",
					name = "Unlock Portal Tracking",
					tooltip = "Set the position of the portal timer.",
					default = false,
					getFunc = function() return Unlock.Portal end,
					setFunc = function(newValue)
						Unlock.Portal = newValue
						HowToCloudrest.SetDefaultUIValues()
						HTC_Portal:SetHidden(not newValue)
					end,
				},
				{
					type = "slider",
					name = "Portal Tracking size",
					tooltip = "Set the size of the portal timer",
					getFunc = function() return sV.FontSize_Portal end,
					setFunc = function(newValue)
						sV.FontSize_Portal = newValue
						HowToCloudrest.SetAllFontSizes()
					end,
					min = 22,
					max = 58,
					step = 2,
					default = 32,
					width = "full",
				},
				{
					type = "divider",
				},
				{
					type = "checkbox",
					name = "Enable Portal Spawn Announcement",
					tooltip = "Show alert when portals spawn.",
					default = false,
					getFunc = function() return sV.Enable.Portal_Announcement end,
					setFunc = function(newValue)
						sV.Enable.Portal_Announcement = newValue
						if (Unlock.Everything or Unlock.Portal_Announcement) then
							HTC_Portal_Announcement:SetHidden(not newValue)
						else
							HTC_Portal_Announcement:SetHidden(newValue)
						end
					end
				},
				{
					type = "checkbox",
					name = "Unlock Portal Spawn Announcement",
					tooltip = "Set the position of the portal spawn announcment.",
					default = false,
					getFunc = function() return Unlock.Portal_Announcement end,
					setFunc = function(newValue)
						Unlock.Portal_Announcement = newValue
						HowToCloudrest.SetDefaultUIValues()
						HTC_Portal_Announcement:SetHidden(not newValue)
					end,
				},
				{
					type = "slider",
					name = "Portal Spawn Announcement size",
					tooltip = "Set the size of the portal spawn announcment.",
					getFunc = function() return sV.FontSize_Portal_Announcement end,
					setFunc = function(newValue)
						sV.FontSize_Portal_Announcement = newValue
						HowToCloudrest.SetAllFontSizes()
					end,
					min = 22,
					max = 58,
					step = 2,
					default = 32,
					width = "full",
				},
			}
		},
		{
			type = "submenu",
			name = "Z'Maja Options",
			controls = {
				{
					type = "checkbox",
					name = "Enable Zmaja Jump Tracking",
					tooltip = "Show a timer when Zmaja is about to go to her next position.",
					default = true,
					getFunc = function() return sV.Enable.ZmajaJump end,
					setFunc = function(newValue)
						sV.Enable.ZmajaJump = newValue
						if (Unlock.Everything or Unlock.ZmajaJump) then
							HTC_ZmajaJump:SetHidden(not newValue)
						else
							HTC_ZmajaJump:SetHidden(newValue)
						end
					end,
				},
				{	type = "checkbox",
					name = "Unlock Zmaja Jump Tracking",
					tooltip = "Set the position of the Next Jump timer.",
					default = false,
					getFunc = function() return Unlock.ZmajaJump end,
					setFunc = function(newValue)
						Unlock.ZmajaJump = newValue
						HowToCloudrest.SetDefaultUIValues()
						HTC_ZmajaJump:SetHidden(not newValue)
					end,
				},
				{	type = "slider",
					name = "Zmaja Jump Tracking size",
					tooltip = "Set the size of Next Jump notification.",
					getFunc = function() return sV.FontSize_ZmajaJump end,
					setFunc = function(newValue)
							sV.FontSize_ZmajaJump = newValue
							HowToCloudrest.SetAllFontSizes()
						end,
					min = 22,
					max = 58,
					step = 2,
					default = 32,
					width = "full",
				},
				{
					type = "divider",
				},
				{
					type = "checkbox",
					name = "Enable Crushing Darkness (Kite) Tracking",
					tooltip = "Tells you when and how long you have to kite Z'Maja's Crushing Dark ability.",
					default = false,
					getFunc = function() return sV.Enable.CrushingDarkness_Kite end,
					setFunc = function(newValue)
						sV.Enable.CrushingDarkness_Kite = newValue
						if (Unlock.Everything or Unlock.CrushingDarkness_Kite) then
							HTC_CrushingDarkness_Kite:SetHidden(not newValue)
						else
							HTC_CrushingDarkness_Kite:SetHidden(newValue)
						end
					end
				},
				{
					type = "checkbox",
					name = "Unlock Crushing Darkness (Kite) Tracking",
					tooltip = "Set the position of the Crushing Darkness kite reminder.",
					default = false,
					getFunc = function() return Unlock.CrushingDarkness_Kite end,
					setFunc = function(newValue)
						Unlock.CrushingDarkness_Kite = newValue
						HowToCloudrest.SetDefaultUIValues()
						HTC_CrushingDarkness_Kite:SetHidden(not newValue)
					end,
				},
				{	type = "slider",
					name = "Crushing Darkness (Kite) Tracking size",
					tooltip = "Set the size of Crushing Darkness (Kite) notification.",
					getFunc = function() return sV.FontSize_CrushingDarkness_Kite end,
					setFunc = function(newValue)
							sV.FontSize_CrushingDarkness_Kite = newValue
							HowToCloudrest.SetAllFontSizes()
						end,
					min = 22,
					max = 58,
					step = 2,
					default = 40,
					width = "full",
				},
				{
					type = "divider",
				},
				{
					type = "checkbox",
					name = "Enable Crushing Darkness (Kite) Timer",
					tooltip = "Tracks the timer of Z'Maja's Crushing Dark (kite) ability.",
					default = false,
					getFunc = function() return sV.Enable.CrushingDarkness_Next end,
					setFunc = function(newValue)
						sV.Enable.CrushingDarkness_Next = newValue
						if (Unlock.Everything or Unlock.CrushingDarkness_Next) then
							HTC_CrushingDarkness_Next:SetHidden(not newValue)
						else
							HTC_CrushingDarkness_Next:SetHidden(newValue)
						end
					end
				},
				{
					type = "checkbox",
					name = "Unlock Crushing Darkness (Kite) Timer",
					tooltip = "Set the position of the next kite timer.",
					default = false,
					getFunc = function() return Unlock.CrushingDarkness_Next end,
					setFunc = function(newValue)
						Unlock.CrushingDarkness_Next = newValue
						HowToCloudrest.SetDefaultUIValues()
						HTC_CrushingDarkness_Next:SetHidden(not newValue)
					end,
				},
				{	type = "slider",
					name = "Crushing Darkness (Kite) Timer size",
					tooltip = "Set the size of next kite timer.",
					getFunc = function() return sV.FontSize_CrushingDarkness_Next end,
					setFunc = function(newValue)
							sV.FontSize_CrushingDarkness_Next = newValue
							HowToCloudrest.SetAllFontSizes()
						end,
					min = 22,
					max = 58,
					step = 2,
					default = 32,
					width = "full",
				},
				{
					type = "divider",
				},
				{
					type = "checkbox",
					name = "Enable Shadow Splash (Interrupt) alert",
					tooltip = "Tells you when to interrupt Z'Maja's Shadow Splash ability (Drop from ceiling).",
					default = false,
					getFunc = function() return sV.Enable.ShadowSplash end,
					setFunc = function(newValue)
						sV.Enable.ShadowSplash = newValue
						if (Unlock.Everything or Unlock.ShadowSplash) then
							HTC_ShadowSplash:SetHidden(not newValue)
						else
							HTC_ShadowSplash:SetHidden(newValue)
						end
					end
				},
				{
					type = "checkbox",
					name = "Unlock Shadow Splash (Interrupt) alert",
					tooltip = "Set the position of the Shadow Splash interrupt reminder.",
					default = false,
					getFunc = function() return Unlock.ShadowSplash end,
					setFunc = function(newValue)
						Unlock.ShadowSplash = newValue
						HowToCloudrest.SetDefaultUIValues()
						HTC_ShadowSplash:SetHidden(not newValue)
					end,
				},
				{
					type = "slider",
					name = "Shadow Splash (Interrupt) alert size",
					tooltip = "Set the size of ZMaja's Shadow Splash BASH alerts",
					getFunc = function() return sV.FontSize_ShadowSplash end,
					setFunc = function(newValue)
						sV.FontSize_ShadowSplash = newValue
						HowToCloudrest.SetAllFontSizes()
					end,
					min = 22,
					max = 58,
					step = 2,
					default = 32,
					width = "full",
				},
				{
					type = "divider",
				},
				{
					type = "checkbox",
					name = "Enable Baneful Mark (Execute) Timer",
					tooltip = "Shows a timer when Z'Maja will cast the next Baneful Mark during execute.",
					default = false,
					getFunc = function() return sV.Enable.BanefulMark end,
					setFunc = function(newValue)
						sV.Enable.BanefulMark = newValue
						if (Unlock.Everything or Unlock.BanefulMark) then
							HTC_BanefulMark:SetHidden(not newValue)
						else
							HTC_BanefulMark:SetHidden(newValue)
						end
					end
				},
				{
					type = "checkbox",
					name = "Unlock Baneful Mark (Execute) Timer",
					tooltip = "Set the position of the Baneful Mark (Execute) timer.",
					default = false,
					getFunc = function() return Unlock.BanefulMark end,
					setFunc = function(newValue)
						Unlock.BanefulMark = newValue
						HowToCloudrest.SetDefaultUIValues()
						HTC_BanefulMark:SetHidden(not newValue)
					end,
				},
				{
					type = "slider",
					name = "Baneful Mark (Execute) Timer size",
					tooltip = "Set the size of the Baneful Mark (Execute) timer",
					getFunc = function() return sV.FontSize_BanefulMark end,
					setFunc = function(newValue)
						sV.FontSize_BanefulMark = newValue
						HowToCloudrest.SetAllFontSizes()
					end,
					min = 22,
					max = 58,
					step = 2,
					default = 32,
					width = "full",
				},
				{
					type = "divider",
				},
				{
					type = "checkbox",
					name = "Enable Malicious Sphere (Orbs) Timer",
					tooltip = "Tells you when Z'Maja will spawn Malicious Spheres (Orbs), and how long until they charge the group if not killed.",
					default = false,
					getFunc = function() return sV.Enable.MaliciousSphere_Timer end,
					setFunc = function(newValue)
						sV.Enable.MaliciousSphere_Timer = newValue
						if (Unlock.Everything or Unlock.MaliciousSphere_Timer) then
							HTC_MaliciousSphere_Timer:SetHidden(not newValue)
						else
							HTC_MaliciousSphere_Timer:SetHidden(newValue)
						end
					end
				},
				{
					type = "checkbox",
					name = "Unlock Malicious Sphere (Orbs) Timer",
					tooltip = "Set the position of the Malicious Sphere (Orbs) timer.",
					default = false,
					getFunc = function() return Unlock.MaliciousSphere_Timer end,
					setFunc = function(newValue)
						Unlock.MaliciousSphere_Timer = newValue
						HowToCloudrest.SetDefaultUIValues()
						HTC_MaliciousSphere_Timer:SetHidden(not newValue)
					end,
				},
				{
					type = "slider",
					name = "Malicious Sphere (Orbs) Timer size",
					tooltip = "Set the size of Malicious Sphere (Orbs) timer",
					getFunc = function() return sV.FontSize_MaliciousSphere_Timer end,
					setFunc = function(newValue)
						sV.FontSize_MaliciousSphere_Timer = newValue
						HowToCloudrest.SetAllFontSizes()
					end,
					min = 22,
					max = 58,
					step = 2,
					default = 32,
					width = "full",
				},
				{
					type = "divider",
				},
				{
					type = "checkbox",
					name = "Enable Malicious Sphere (Orbs) Announcement",
					tooltip = "Tells you when Z'Maja is spawning Malicious Spheres (Orbs).",
					default = false,
					getFunc = function() return sV.Enable.MaliciousSphere_Announcement end,
					setFunc = function(newValue)
						sV.Enable.MaliciousSphere_Announcement = newValue
						if (Unlock.Everything or Unlock.MaliciousSphere_Announcement) then
							HTC_MaliciousSphere_Announcement:SetHidden(not newValue)
						else
							HTC_MaliciousSphere_Announcement:SetHidden(newValue)
						end
					end
				},
				{
					type = "checkbox",
					name = "Unlock Malicious Sphere (Orbs) Announcement",
					tooltip = "Set the position of the Malicious Sphere (Orbs) announcement.",
					default = false,
					getFunc = function() return Unlock.MaliciousSphere_Announcement end,
					setFunc = function(newValue)
						Unlock.MaliciousSphere_Announcement = newValue
						HowToCloudrest.SetDefaultUIValues()
						HTC_MaliciousSphere_Announcement:SetHidden(not newValue)
					end,
				},
				{
					type = "slider",
					name = "Malicious Sphere (Orbs) Announcement size",
					tooltip = "Set the size of Malicious Sphere (Orbs) announcement",
					getFunc = function() return sV.FontSize_MaliciousSphere_Announcement end,
					setFunc = function(newValue)
						sV.FontSize_MaliciousSphere_Announcement = newValue
						HowToCloudrest.SetAllFontSizes()
					end,
					min = 22,
					max = 58,
					step = 2,
					default = 32,
					width = "full",
				},
				{
					type = "divider",
				},
				{
					type = "checkbox",
					name = "Enable Malicious Sphere (Orbs) Tracking",
					tooltip = "Tells you how many orbs are left to kill.",
					default = false,
					getFunc = function() return sV.Enable.MaliciousSphere_Tracking end,
					setFunc = function(newValue)
						sV.Enable.MaliciousSphere_Tracking = newValue
						if (Unlock.Everything or Unlock.MaliciousSphere_Tracking) then
							HTC_MaliciousSphere_Tracking:SetHidden(not (sV.Enable.MaliciousSphere_Execute or newValue))
						else
							HTC_MaliciousSphere_Tracking:SetHidden(newValue)
						end
					end
				},
				{
					type = "checkbox",
					name = "Enable Malicious Sphere Execute Tracking",
					tooltip = "Tells you how many orbs are left to kill in execute.",
					default = false,
					getFunc = function() return sV.Enable.MaliciousSphere_Execute end,
					setFunc = function(newValue)
						sV.Enable.MaliciousSphere_Execute = newValue
						if (Unlock.Everything or Unlock.MaliciousSphere_Tracking) then
							HTC_MaliciousSphere_Tracking:SetHidden(not (sV.Enable.MaliciousSphere_Tracking or newValue))
						else
							HTC_MaliciousSphere_Tracking:SetHidden(newValue)
						end
					end
				},
				{
					type = "checkbox",
					name = "Unlock Malicious Sphere (Orbs) Tracking",
					tooltip = "Set the position of the Malicious Sphere (Orbs) tracker.",
					default = false,
					getFunc = function() return Unlock.MaliciousSphere_Tracking end,
					setFunc = function(newValue)
						Unlock.MaliciousSphere_Tracking = newValue
						HowToCloudrest.SetDefaultUIValues()
						HTC_MaliciousSphere_Tracking:SetHidden(not newValue)
					end,
				},
				{
					type = "slider",
					name = "Malicious Sphere (Orbs) Tracking size",
					tooltip = "Set the size of the Malicious Sphere (Orbs) tracker",
					getFunc = function() return sV.FontSize_MaliciousSphere_Tracking end,
					setFunc = function(newValue)
						sV.FontSize_MaliciousSphere_Tracking = newValue
						HowToCloudrest.SetAllFontSizes()
					end,
					min = 32,
					max = 80,
					step = 2,
					default = 32,
					width = "full",
				},
				{
					type = "divider",
				},
				{
					type = "checkbox",
					name = "Enable Creeper Spawn Announcement",
					tooltip = "Tells you when Z'Maja is spawning Creepers.",
					default = false,
					getFunc = function() return sV.Enable.Creeper_Announcement end,
					setFunc = function(newValue)
						sV.Enable.Creeper_Announcement = newValue
						if (Unlock.Everything or Unlock.Creeper_Announcement) then
							HTC_Creeper_Announcement:SetHidden(not newValue)
						else
							HTC_Creeper_Announcement:SetHidden(newValue)
						end
					end
				},
				{
					type = "checkbox",
					name = "Unlock Creeper Spawn Announcement",
					tooltip = "Set the position of the Creeper Spawn announcement.",
					default = false,
					getFunc = function() return Unlock.Creeper_Announcement end,
					setFunc = function(newValue)
						Unlock.Creeper_Announcement = newValue
						HowToCloudrest.SetDefaultUIValues()
						HTC_Creeper_Announcement:SetHidden(not newValue)
					end,
				},
				{
					type = "slider",
					name = "Creeper Spawn Announcement size",
					tooltip = "Set the size of Creeper Spawn announcement",
					getFunc = function() return sV.FontSize_Creeper_Announcement end,
					setFunc = function(newValue)
						sV.FontSize_Creeper_Announcement = newValue
						HowToCloudrest.SetAllFontSizes()
					end,
					min = 22,
					max = 58,
					step = 2,
					default = 32,
					width = "full",
				},
			} -- Z'Maja submenu end
		},

	}

	LAM:RegisterOptionControls("HowToCloudrest_Settings", optionsData)
end
