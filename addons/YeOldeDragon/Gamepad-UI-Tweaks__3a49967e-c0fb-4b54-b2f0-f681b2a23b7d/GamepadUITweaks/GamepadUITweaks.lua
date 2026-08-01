GamepadUITweaks = GamepadUITweaks or {}

GamepadUITweaks.DisplayName = "Gamepad UI Tweaks"
GamepadUITweaks.AddonName = "GamepadUITweaks"
GamepadUITweaks.Version = "1.0.7"
GamepadUITweaks.Author = "YeOldeDragon"
GamepadUITweaks.Website = "https://www.esoui.com/downloads/info4442-GamepadUITweaks.html"
GamepadUITweaks.Feedback = "https://www.esoui.com/downloads/info4442-GamepadUITweaks.html#comments"
local SAVED_VAR_NAME = "GamepadUITweaks_SV"

local SAVED_VAR_VERSION = 1

local DefaultSettings = {
	AttributeBarsWidth = nil,
	AttributesOffset = nil,
	DisableGlossBar = true,
	ControllerButtonStyle = "auto",
	ShowMainMenuCrownStore = true,
	ShowMainMenuTamrielTomes = true,
	ShowMainMenuAnnouncements = true,
	ShowMainMenuCollections = true,
	ShowMainMenuSocial = true,
	ShowMainMenuActivityFinder = true,
	ShowMainMenuCampaign = true,
	ShowMainMenuJournal = true,
	ShowMainMenuHelp = true,
	ShowMainMenuMail = false,
	ShowMainMenuQuestJournal = false,
	ShowMainMenuAntiquitiesJournal = false,
}

local YEOLDE_BLANK_TEXTURE = "/esoui/art/icons/blank.dds"

local GlossTextures = {
	"esoui/art/unitattributevisualizer/attributebar_dynamic_fill_gloss.dds",
	"esoui/art/unitattributevisualizer/attributebar_dynamic_leadingedge_gloss.dds",
	"esoui/art/unitattributevisualizer/attributebar_small_fill_center_gloss.dds",
	"esoui/art/unitattributevisualizer/attributebar_small_fill_leadingedge_gloss.dds",
	"esoui/art/unitattributevisualizer/targetbar_dynamic_fill_gloss.dds",
	"esoui/art/unitattributevisualizer/targetbar_dynamic_leadingedge_gloss.dds",
	"esoui/art/unitattributevisualizer/gamepad/gp_targetbar_dynamic_leadingedge_gloss.dds",
	"esoui/art/unitattributevisualizer/gamepad/gp_targetbar_dynamic_fill_gloss.dds",
	"esoui/art/unitattributevisualizer/gamepad/gp_attributebar_small_fill_leadingedge_gloss.dds",
	"esoui/art/unitattributevisualizer/gamepad/gp_attributebar_small_fill_center_gloss.dds",
	"esoui/art/unitattributevisualizer/gamepad/gp_attributebar_dynamic_leadingedge_gloss.dds",
	"esoui/art/unitattributevisualizer/gamepad/gp_attributebar_dynamic_fill_gloss.dds",
	"esoui/art/miscellaneous/timerbar_genericfill_leadingedge_gloss.dds",
	"esoui/art/miscellaneous/timerbar_genericfill_gloss.dds",
	"esoui/art/miscellaneous/progressbar_genericfill_leadingedge_gloss.dds",
	"esoui/art/miscellaneous/progressbar_genericfill_gloss.dds",
	"esoui/art/miscellaneous/gamepad/gp_dynamicbar30_leadingedge_gloss.dds",
	"esoui/art/miscellaneous/gamepad/gp_dynamicbar_medium_leadingedge_gloss.dds",
	"esoui/art/miscellaneous/gamepad/gp_dynamicbar30_gloss.dds",
	"esoui/art/miscellaneous/gamepad/gp_dynamicbar_medium_gloss.dds",
	"esoui/art/miscellaneous/gamepad/gp_championbar_leadingedge_gloss.dds",
	"esoui/art/miscellaneous/gamepad/gp_championbar_fill_gloss.dds",
	"esoui/art/itemtooltip/item_chargemeter_bar_leadingedge_gloss.dds",
}

-- Indices within PLAYER_ATTRIBUTE_BARS.bars[]
-- Order: [1]=Health, [2]=SiegeHealth, [3]=Magicka, [4]=Werewolf, [5]=Stamina, [6]=MountStamina
local PLAYER_HEALTH_BAR_INDEX = 1
local PLAYER_MAGICKA_BAR_INDEX = 3
local PLAYER_STAMINA_BAR_INDEX = 5

local function DisableGlossTextures()
	for _, texture in pairs(GlossTextures) do
		RedirectTexture(texture, YEOLDE_BLANK_TEXTURE)
	end
end

local function EnableGlossTextures()
	for _, texture in pairs(GlossTextures) do
		RedirectTexture(texture, texture)
	end
end

-- Called unconditionally at module load time, BEFORE EVENT_ADD_ON_LOADED and
-- before ESO's first render frame.  RedirectTexture calls persist across /reloadui,
-- so if gloss was disabled in a previous session the redirect (t→blank) is still
-- active at the start of the new session.  Resetting every texture to itself here
-- (t→t) overrides that persisted redirect early enough for the engine to pick it up
-- before it renders anything.  If DisableGlossBar is true, DisableGlossTextures()
-- will be called right after SV is loaded (in ApplyGlossBarSetting), also before
-- the first render, so there is no visible flash.
EnableGlossTextures()

local function ApplyGlossBarSetting()
	if GamepadUITweaks.SV and GamepadUITweaks.SV.DisableGlossBar then
		DisableGlossTextures()
	else
		EnableGlossTextures()
	end
end

local function InstallControllerButtonStyleHook()
	if type(GamepadUITweaks.InstallControllerButtonStyleHook) == "function" then
		GamepadUITweaks.InstallControllerButtonStyleHook()
	end
end

local function InstallControllerConsoleArtHook()
	if type(GamepadUITweaks.InstallControllerConsoleArtHook) == "function" then
		GamepadUITweaks.InstallControllerConsoleArtHook()
	end
end

local function ApplyControllerButtonStyle()
	if type(GamepadUITweaks.ApplyControllerButtonStyle) == "function" then
		GamepadUITweaks.ApplyControllerButtonStyle()
	end
end

local function InitializeUIBars()
	GamepadUITweaks.MagickaAttributeBG =
		GetControl(PLAYER_ATTRIBUTE_BARS.bars[PLAYER_MAGICKA_BAR_INDEX].control, "BgContainer")
	GamepadUITweaks.HealthAttributeBG =
		GetControl(PLAYER_ATTRIBUTE_BARS.bars[PLAYER_HEALTH_BAR_INDEX].control, "BgContainer")
	GamepadUITweaks.StaminaAttributeBG =
		GetControl(PLAYER_ATTRIBUTE_BARS.bars[PLAYER_STAMINA_BAR_INDEX].control, "BgContainer")

	ApplyGlossBarSetting()
end

local function UpdateUIBarSize()
	if not GamepadUITweaks.MagickaAttributeBG then
		return
	end

	local width = tonumber(GamepadUITweaks.SV.AttributeBarsWidth) or 280
	local _, minHeight, _, maxHeight =
		PLAYER_ATTRIBUTE_BARS.bars[PLAYER_STAMINA_BAR_INDEX].control:GetDimensionConstraints()

	PLAYER_ATTRIBUTE_BARS.bars[PLAYER_STAMINA_BAR_INDEX].control:SetDimensionConstraints(
		width,
		minHeight,
		width,
		maxHeight
	)
	PLAYER_ATTRIBUTE_BARS.bars[PLAYER_HEALTH_BAR_INDEX].control:SetDimensionConstraints(
		width,
		minHeight,
		width,
		maxHeight
	)
	PLAYER_ATTRIBUTE_BARS.bars[PLAYER_MAGICKA_BAR_INDEX].control:SetDimensionConstraints(
		width,
		minHeight,
		width,
		maxHeight
	)

	PLAYER_ATTRIBUTE_BARS.bars[PLAYER_STAMINA_BAR_INDEX].control:SetWidth(width)
	PLAYER_ATTRIBUTE_BARS.bars[PLAYER_HEALTH_BAR_INDEX].control:SetWidth(width)
	PLAYER_ATTRIBUTE_BARS.bars[PLAYER_MAGICKA_BAR_INDEX].control:SetWidth(width)

	GamepadUITweaks.MagickaAttributeBG:SetDimensionConstraints(width, minHeight, width, maxHeight)
	GamepadUITweaks.HealthAttributeBG:SetDimensionConstraints(width, minHeight, width, maxHeight)
	GamepadUITweaks.StaminaAttributeBG:SetDimensionConstraints(width, minHeight, width, maxHeight)

	GamepadUITweaks.MagickaAttributeBG:SetWidth(width)
	GamepadUITweaks.HealthAttributeBG:SetWidth(width)
	GamepadUITweaks.StaminaAttributeBG:SetWidth(width)
end

local function UpdateUIBarDistanceOffset()
	local offset = 0
	local healthControl = GetControl(PLAYER_ATTRIBUTE_BARS.control, "Health")
	local attrOffset = tonumber(GamepadUITweaks.SV.AttributesOffset) or 180

	-- Magicka offset
	local magickaControl = PLAYER_ATTRIBUTE_BARS.bars[PLAYER_MAGICKA_BAR_INDEX]
	local magIsValidAnchor, _, _, _, _, magOffsetY, magAnchorConstrains = magickaControl.control:GetAnchor(0)
	if magIsValidAnchor then
		offset = 0 - attrOffset
		magickaControl.control:SetAnchor(RIGHT, healthControl, LEFT, offset, magOffsetY, magAnchorConstrains)
	end

	-- Stamina offset
	local staminaControl = PLAYER_ATTRIBUTE_BARS.bars[PLAYER_STAMINA_BAR_INDEX]
	local stamIsValidAnchor, _, _, _, _, stamOffsetY, stamAnchorConstrains = staminaControl.control:GetAnchor(0)
	if stamIsValidAnchor then
		offset = attrOffset
		staminaControl.control:SetAnchor(LEFT, healthControl, RIGHT, offset, stamOffsetY, stamAnchorConstrains)
	end
end

local function PreviewAttributeBars()
	EVENT_MANAGER:UnregisterForUpdate("GamepadUITweaks_PreviewBars")
	PLAYER_ATTRIBUTE_BARS:ForceShow(true)

	local scene = SCENE_MANAGER:GetCurrentScene()
	if scene and PLAYER_ATTRIBUTE_BARS_FRAGMENT then
		scene:AddFragment(PLAYER_ATTRIBUTE_BARS_FRAGMENT)
	end

	EVENT_MANAGER:RegisterForUpdate("GamepadUITweaks_PreviewBars", 2000, function()
		EVENT_MANAGER:UnregisterForUpdate("GamepadUITweaks_PreviewBars")
		PLAYER_ATTRIBUTE_BARS:ForceShow(false)
		if scene and PLAYER_ATTRIBUTE_BARS_FRAGMENT then
			scene:RemoveFragment(PLAYER_ATTRIBUTE_BARS_FRAGMENT)
		end
	end)
end

local function ApplyMainMenuTweaks()
	if type(GamepadUITweaks.ApplyMainMenuTweaks) == "function" then
		GamepadUITweaks.ApplyMainMenuTweaks()
	end
end

local function HookSelectMenuEntryForHiddenEntries()
	if type(GamepadUITweaks.HookSelectMenuEntryForHiddenEntries) == "function" then
		GamepadUITweaks.HookSelectMenuEntryForHiddenEntries()
	end
end

local function InitializeExtension()
	GamepadUITweaks.SV = ZO_SavedVars:NewAccountWide(SAVED_VAR_NAME, SAVED_VAR_VERSION, nil, DefaultSettings)

	InitializeUIBars()

	-- Grab default values directly from the UI if not yet saved
	if GamepadUITweaks.SV.AttributesOffset == nil then
		local _, _, _, _, magOffsetX, _, _ = PLAYER_ATTRIBUTE_BARS.bars[PLAYER_MAGICKA_BAR_INDEX].control:GetAnchor(0)
		GamepadUITweaks.SV.AttributesOffset = math.abs(magOffsetX)
	end

	if GamepadUITweaks.SV.AttributeBarsWidth == nil then
		GamepadUITweaks.SV.AttributeBarsWidth = PLAYER_ATTRIBUTE_BARS.bars[PLAYER_MAGICKA_BAR_INDEX].control:GetWidth()
	end

	UpdateUIBarSize()
	UpdateUIBarDistanceOffset()

	ApplyMainMenuTweaks()
	HookSelectMenuEntryForHiddenEntries()
	InstallControllerButtonStyleHook()
	InstallControllerConsoleArtHook()
	ApplyControllerButtonStyle()

	EVENT_MANAGER:RegisterForEvent("GamepadUITweaks_ControllerStyle_GamepadType", EVENT_GAMEPAD_TYPE_CHANGED, ApplyControllerButtonStyle)
	EVENT_MANAGER:RegisterForEvent("GamepadUITweaks_ControllerStyle_MostRecent", EVENT_MOST_RECENT_GAMEPAD_TYPE_CHANGED, ApplyControllerButtonStyle)
	EVENT_MANAGER:RegisterForEvent("GamepadUITweaks_ControllerStyle_PreferredMode", EVENT_GAMEPAD_PREFERRED_MODE_CHANGED, ApplyControllerButtonStyle)

	EVENT_MANAGER:RegisterForEvent("GamepadUITweaks_MainMenuApply", EVENT_PLAYER_ACTIVATED, function()
		EVENT_MANAGER:UnregisterForEvent("GamepadUITweaks_MainMenuApply", EVENT_PLAYER_ACTIVATED)
		ApplyMainMenuTweaks()
	end)

	-- if type(GamepadUITweaks.RegisterOptions) == "function" then
	-- 	GamepadUITweaks.RegisterOptions({
	-- 		UpdateUIBarSize = UpdateUIBarSize,
	-- 		PreviewAttributeBars = PreviewAttributeBars,
	-- 		UpdateUIBarDistanceOffset = UpdateUIBarDistanceOffset,
	-- 		ApplyMainMenuTweaks = ApplyMainMenuTweaks,
	-- 		DisableGlossTextures = DisableGlossTextures,
	-- 		ApplyGlossBarSetting = ApplyGlossBarSetting,
	-- 	})
	-- end
	if type(GamepadUITweaks.CreateSettingsMenu) == "function" then
		GamepadUITweaks.CreateSettingsMenu({
			UpdateUIBarSize = UpdateUIBarSize,
			PreviewAttributeBars = PreviewAttributeBars,
			UpdateUIBarDistanceOffset = UpdateUIBarDistanceOffset,
			ApplyMainMenuTweaks = ApplyMainMenuTweaks,
			DisableGlossTextures = DisableGlossTextures,
			ApplyGlossBarSetting = ApplyGlossBarSetting,
			ApplyControllerButtonStyle = ApplyControllerButtonStyle,
		})
	end
end

EVENT_MANAGER:RegisterForEvent(GamepadUITweaks.AddonName, EVENT_ADD_ON_LOADED, function(event, addonName)
	if addonName == GamepadUITweaks.AddonName then
		EVENT_MANAGER:UnregisterForEvent(GamepadUITweaks.AddonName, EVENT_ADD_ON_LOADED)
		InitializeExtension()
	end
end)
