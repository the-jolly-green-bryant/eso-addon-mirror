ImmersiveHUDHider = ImmersiveHUDHider or {}
local IHH = ImmersiveHUDHider

IHH.name = "ImmersiveHUDHider"
IHH.version = "2.0"

--------------------------------------------------
-- STATE
--------------------------------------------------

IHH.active = false
local AUIUnitFramesToHide = {}

--------------------------------------------------
-- UTILS
--------------------------------------------------
local function SafeSet(control, hidden, alpha, force)
	if control then
		-- set alpha if not passed directly
		if not alpha then
			if hidden then
				alpha = 0
			else
				alpha = 1
			end
		end

		-- fade alpha in/out
		if control.animation and control.animation:IsPlaying() then
			return
		end
		if control.fadeOut and control.fadeOut:IsPlaying() then
			return
		end
		if control.fadeIn and control.fadeIn:IsPlaying() then
			return
		end

		current_alpha = nil
		if control:GetAlpha() then
			current_alpha = control:GetAlpha()
		end

		if alpha == 0 and current_alpha == 1 and hidden == true then
			-- fade out
			local animation, timeline = CreateSimpleAnimation(ANIMATION_ALPHA, control, 0)
			animation:SetAlphaValues(1, 0)
			animation:SetEasingFunction(ZO_EaseInQuadratic)
			animation:SetDuration(IHH.saved.fadeRate)
			timeline:SetPlaybackType(ANIMATION_PLAYBACK_ONE_SHOT, 1)
			control.fadeOut = timeline
			control.fadeOut:PlayFromStart()
		elseif alpha == 1 and current_alpha == 0 and hidden == false then
			-- fade in
			local animation, timeline = CreateSimpleAnimation(ANIMATION_ALPHA, control, 0)
			animation:SetAlphaValues(0, 1)
			animation:SetEasingFunction(ZO_EaseInQuadratic)
			animation:SetDuration(IHH.saved.fadeRate)
			timeline:SetPlaybackType(ANIMATION_PLAYBACK_ONE_SHOT, 1)
			control.fadeIn = timeline
			control.fadeIn:PlayFromStart()
		end

		-- force hidden stat if passed
		if force then
			control:SetHidden(hidden)
		end
	end
end

--------------------------------------------------
-- DEFAULTS
--------------------------------------------------

local AUIUnitFramesToHide = {}

local hideChatChoices = { [1] = "Don't Hide Chat", [2] = "Hide Only Background (keep icons)", [3] = "Fully Hide Chat" }
local hideCrosshairChoices = {
	[1] = "Don't Adjust Crosshair (Pick me for compatibility with other Crosshair addons)",
	[2] = "Only Show in Combat",
	[3] = "Always Hide Crosshair",
}

IHH.defaults = {
	isHidden = false,

	-- Dynamic mode
	dynamicMode = false, --

	hideCrosshair = 1, --
	hideChat = 2, --

	hideCompass = true, --
	hideActionBar = true, --
	hideBuffs = true, --
	hideAttributeBar = true,
	hideLootLog = true, --
	hideQuestTracker = true, --
	hideTargetInfo = true, --
	hideGroupUnitFrames = true, --
	hideBossBar = true,
	hideChatBubbles = true,
	hideAllNamePlates = true,
	hideAllHealthBars = false,

	updateRate = 100,
	fadeRate = 500,

	hideAUI = true,
	hideMap = true, --
	hideBanditsUI = true,
	hideBanditsCompanions = true,
	hideSrendarr = true, --
	hideRavaloxTracker = true, --
	hideEventTracker = true, --
	hideFancyActionBar = true,
	hideCombatMetrics = true, --
}

--------------------------------------------------
-- DETECT
--------------------------------------------------

function IHH.Detect()
	IHH.hasAUI = AUI ~= nil

	IHH.hasBandits = BUI ~= nil
	IHH.hasSrendarr = Srendarr ~= nil
	IHH.hasRavalox = QUESTTRACKER ~= nil
	IHH.hasEventTracker = EVT ~= nil
	IHH.hasBanditsCompanions = BCUI ~= nil
	IHH.hasFancyActionBar = FancyActionBar ~= nil
	IHH.hasVEQ = VEQ ~= nil
	IHH.hasMap = AUI ~= nil or FyrMM ~= nil or BUI ~= nil or VOTANS_MINIMAP ~= nil

	IHH.hasCombatMetrics = CMX ~= nil
end

function hideAUIUnitFrames()
	local gCurrentTemplateData = AUI.UnitFrames.GetActiveTemplates()
	for _, templateData in pairs(gCurrentTemplateData) do
		for frameType, data in pairs(templateData.frameData) do
			control = data.control
			for _, templateData in pairs(gCurrentTemplateData) do
				for frameType, data in pairs(templateData.frameData) do
					control = data.control

					local timelastrun = 0
					control:SetHandler("OnUpdate", function(self, timerun)
						if (timerun - timelastrun) >= 0 then
							timelastrun = timerun
							for k, v in pairs(AUIUnitFramesToHide) do
								AUI.UnitFrames.HideFrame(v)
							end
						end
					end)

					break
				end
			end
			break
		end
	end
end

function hideTargetInfo(hidden)
	if hidden == true then
		-- Default target frame
		EVENT_MANAGER:RegisterForEvent("toggleTargetInfo", EVENT_RETICLE_TARGET_CHANGED, function()
			if ZO_TargetUnitFramereticleover then
				SafeSet(ZO_TargetUnitFramereticleover, hidden, nil, true)
			end
		end)

		-- AUI target frame
		if IHH.hasAUI and IHH.hideAUI then
			if AUI.UnitFrames.Target.IsEnabled() then
				table.insert(AUIUnitFramesToHide, 201)
				table.insert(AUIUnitFramesToHide, 202)
				table.insert(AUIUnitFramesToHide, 211)
				table.insert(AUIUnitFramesToHide, 212)
				hideAUIUnitFrames()
			end
		end
	else
		-- Reset main target hud
		EVENT_MANAGER:UnregisterForEvent("toggleTargetInfo", EVENT_RETICLE_TARGET_CHANGED, function()
			if ZO_TargetUnitFramereticleover then
				SafeSet(ZO_TargetUnitFramereticleover, hidden, nil, true)
			end
		end)

		-- Reset AUI target hud
		if IHH.hasAUI and IHH.hideAUI then
			if AUI.UnitFrames.Target.IsEnabled() then
				AUIUnitFramesToHide = {}
				hideAUIUnitFrames()
				AUI.UnitFrames.UpdateUI()
			end
		end
	end

	SafeSet(BUI_TargetFrame, hidden)
end

--------------------------------------------------
-- BANDITS
--------------------------------------------------

function IHH.ApplyBanditsAttributes(hidden)
	if not (IHH.saved.hideBanditsUI and IHH.hasBandits) then
		return
	end

	SafeSet(BUI_PlayerFrame, hidden)
end

function IHH.hideBanditsBuffs(hidden)
	if not (IHH.saved.hideBanditsUI and IHH.hasBandits and IHH.hideBuffs) then
		return
	end

	SafeSet(BUI_Buffs, hidden)
end

function IHH.hideBanditsMap(hidden)
	if not (IHH.saved.hideBanditsUI and IHH.hasBandits and IHH.hideMap) then
		return
	end

	SafeSet(BUI_Minimap, hidden)

	if BUI.MiniMap and BUI.init.MiniMap and BUI.Vars.MiniMap then
		if BUI.MiniMap.MapSceneIsShowing then
			SafeSet(ZO_WorldMap, false)
		else
			SafeSet(ZO_WorldMap, hidden)
		end
	end
end

function IHH.ApplyBanditsGroup(hidden)
	if not (IHH.saved.hideBanditsUI and IHH.hasBandits) then
		return
	end

	SafeSet(BUI_GroupSynergy, hidden)
end

function IHH.ApplyBanditsCompanions(hidden)
	if not (IHH.saved.hideBanditsCompanions and IHH.hasBanditsCompanions) then
		return
	end

	SafeSet(BCUI_CompanionFrame, hidden, nil, true)

	if hidden then
		EVENT_MANAGER:UnregisterForUpdate("BCUI_CompanionFrame", BCUI.Frames.SafetyCheck)
	else
		EVENT_MANAGER:RegisterForUpdate("BCUI_CompanionFrame", 5000, BCUI.Frames.SafetyCheck)
	end
end

function IHH.ApplySrendarr(hidden)
	if not (IHH.saved.hideSrendarr and IHH.hasSrendarr) then
		return
	end

	for i = 1, Srendarr.NUM_DISPLAY_FRAMES do
		if Srendarr.displayFrames[i] ~= nil then
			SafeSet(Srendarr.displayFrames[i], hidden, nil, true)
		end
	end

	if hidden then
		Srendarr.uiHidden = true
	else
		Srendarr.uiHidden = false
	end
end

function IHH.ApplyRavalox(hidden)
	if not (IHH.saved.hideRavaloxTracker and IHH.hasRavalox) then
		return
	end

	if QUESTTRACKER then
		SafeSet(QUESTTRACKER.questTreeWin, hidden)
	end

	if RavaloxQuestTrackerPanel then
		SafeSet(RavaloxQuestTrackerPanel, hidden)
	end
end

function IHH.ApplyEventTracker(hidden)
	if not (IHH.saved.hideEventTracker and IHH.hasEventTracker) then
		return
	end

	if ZO_EventTracker then
		SafeSet(ZO_EventTracker, hidden)
	end

	EVT_HIDE_UI = hidden

	if EVT_HIDE_UI then
		EVT.HideUI("Hide")
		EVENT_MANAGER:UnregisterForEvent(EVT.name, EVENT_PLAYER_COMBAT_STATE)
	end
end

function IHH.ApplyFancyActionBar(hidden)
	if not (IHH.saved.hideFancyActionBar and IHH.hasFancyActionBar) then
		return
	end

	local NAME = "FancyActionBar+"

	if hidden then
		FancyActionBar.UpdateScale(0)
	else
		FancyActionBar.UpdateScale(1)
	end
end

function hideChat(hidden)
	-- Hide only background
	if IHH.saved.hideChat == hideChatChoices[2] then
		SafeSet(ZO_ChatWindowBg, hidden, nil, true)
		SafeSet(ZO_ChatWindowMinBarBG, hidden, nil, true)

		-- Fully hide chat
	elseif IHH.saved.hideChat == hideChatChoices[3] then
		SafeSet(ZO_ChatWindowBg, hidden, nil, true)
		SafeSet(ZO_ChatWindowMinBarBG, hidden, nil, true)
		SafeSet(ZO_ChatWindowNotifications, hidden, nil, true)
		SafeSet(ZO_ChatWindowDivider, hidden, nil, true)
		SafeSet(ZO_ChatWindow, hidden, nil, true)
	end

	if not hidden then
		CHAT_SYSTEM:SetChannel(CHAT_SYSTEM.currentChannel) -- re-apply channel to fix not being able to type until switching channels
	end
end

function IHH.hideCrosshair()
	if IHH.saved.hideCrosshair == hideCrosshairChoices[2] then
		-- Show only in combat
		if IsUnitInCombat("player") then
			--ZO_ReticleContainerReticle:SetHidden(false)
			SafeSet(ZO_ReticleContainerReticle, false)
		else
			--ZO_ReticleContainerReticle:SetHidden(true)
			SafeSet(ZO_ReticleContainerReticle, true)
		end
	elseif IHH.saved.hideCrosshair == hideCrosshairChoices[3] then
		-- Always Hide
		ZO_ReticleContainerReticle:SetHidden(true)
	end
end

function IHH.hideVotansMinimap(hidden)
	-- votans
	if VOTANS_MINIMAP then
		if VOTANS_MINIMAP and WORLD_MAP_MANAGER:IsInMode(41) then
			SafeSet(ZO_WorldMap, hidden)
		else
			SafeSet(ZO_WorldMap, false)
		end
	end
end

function IHH.hideMinimap(hidden)
	if IHH.saved.hideMap and IHH.hasMap then
		if hidden == true then
			if AUI then
				if AUI.Minimap.IsEnabled() then
					AUI.Minimap.Hide()
					AUI.Settings.Minimap.hidden = true
				end
			end
			if FyrMM then
				FyrMM.Visible = false
				FyrMM.AutoHidden = true
			end
			IHH.hideBanditsMap(hidden)

			IHH.hideVotansMinimap(hidden)
		else
			if AUI then
				if AUI.Minimap.IsEnabled() then
					AUI.Minimap.Show()
					AUI.Settings.Minimap.hidden = false
				end
			end
			if FyrMM then
				FyrMM.Visible = true
				FyrMM.AutoHidden = false
			end
			IHH.hideBanditsMap(hidden)

			IHH.hideVotansMinimap(hidden)
		end
	end
end

function IHH.hideAUIBuffs(hidden)
	if not (IHH.hasAUI and IHH.hideBuffs and IHH.hideAUI) then
		return
	end

	if AUI.Buffs.IsEnabled() then
		AUI_Buff:SetHidden(hidden)
		AUI.Buffs.RefreshAll()
	end
end

function IHH.hideAUIGroupUnitFrames(hidden)
	if not (IHH.hasAUI and IHH.hideGroupFrames and IHH.hideAUI) then
		return
	end

	-- AUI
	if hidden then
		if AUI.UnitFrames.Group.IsEnabled() then
			local gCurrentTemplateData = AUI.UnitFrames.GetActiveTemplates()
			for _, templateData in pairs(gCurrentTemplateData) do
				for frameType, data in pairs(templateData.frameData) do
					control = data.control
					for _, templateData in pairs(gCurrentTemplateData) do
						for frameType, data in pairs(templateData.frameData) do
							control = data.control

							if
								AUI.UnitFrames.IsGroupOrRaid(control.attributeId)
								or AUI.UnitFrames.IsMainCompanion(control.attributeId)
							then
								table.insert(AUIUnitFramesToHide, 301)
								table.insert(AUIUnitFramesToHide, 302)
								table.insert(AUIUnitFramesToHide, 303)
								hideAUIUnitFrames()
							end

							break
						end
					end
					break
				end
			end
		end
	else
		if AUI.UnitFrames.Group.IsEnabled() then
			ZO_UnitFramesGroups:SetHidden(true)
			AUIUnitFramesToHide = {}
			hideAUIUnitFrames()
		end
	end
end

function IHH.hideAUIAttributeBars(hidden)
	if not (IHH.hasAUI and IHH.hideAttributeBar and IHH.hideAUI) then
		return
	end

	if hidden then
		if AUI.UnitFrames.Player.IsEnabled() then
			local gCurrentTemplateData = AUI.UnitFrames.GetActiveTemplates()
			for _, templateData in pairs(gCurrentTemplateData) do
				for frameType, data in pairs(templateData.frameData) do
					control = data.control
					for _, templateData in pairs(gCurrentTemplateData) do
						for frameType, data in pairs(templateData.frameData) do
							control = data.control

							if AUI.UnitFrames.IsPlayer(control.attributeId) then
								table.insert(AUIUnitFramesToHide, 101)
								table.insert(AUIUnitFramesToHide, 102)
								table.insert(AUIUnitFramesToHide, 103)
								hideAUIUnitFrames()
							end

							break
						end
					end
					break
				end
			end
		end
	else
		if AUI.UnitFrames.Player.IsEnabled() then
			AUIUnitFramesToHide = {}
			hideAUIUnitFrames()
			AUI.UnitFrames.UpdateUI()
		end
	end
end

function IHH.hideCombatMetrics(hidden)
	if not (IHH.hasCombatMetrics and IHH.hideCombatMetrics) then
		return
	end

	SafeSet(CombatMetrics_LiveReport, hidden)
end

--------------------------------------------------
-- CORE APPLY
--------------------------------------------------

function IHH.ApplyCore(hidden)
	IHH.active = hidden

	-- Compass
	if IHH.saved.hideCompass then
		SafeSet(ZO_CompassFrame, hidden)
		SafeSet(ZO_CompassContainer, hidden)
		SafeSet(ZO_CompassFrameBG, hidden)
	end

	-- Action bar
	if IHH.saved.hideActionBar then
		SafeSet(ZO_ActionBar1, hidden)

		IHH.ApplyFancyActionBar(hidden)
	end

	-- Buffs
	if IHH.saved.hideBuffs then
		SafeSet(ZO_BuffDebuffTopLevelSelfContainer, hidden)

		if IHH.hasAUI then
			IHH.hideAUIBuffs(hidden)
		end

		if IHH.hasBandits then
			IHH.hideBanditsBuffs(hidden)
		end
	end

	-- Attributes
	if IHH.saved.hideAttributeBar then
		SafeSet(ZO_PlayerAttribute, hidden)

		-- AUI
		if IHH.hasAUI then
			IHH.hideAUIAttributeBars(hidden)
		end

		-- bandits
		IHH.ApplyBanditsAttributes(hidden)
	end

	-- Nameplates
	if IHH.saved.hideAllNamePlates then
	end

	if IHH.saved.hideAllHealthBars then
	end

	-- Chat bubbles
	if IHH.saved.hideChatBubbles then
	end

	-- Loot log
	if IHH.saved.hideLootLog then
		SafeSet(LootDropGui, hidden)
	end

	-- Quest tracker
	if IHH.saved.hideQuestTracker then
		SafeSet(ZO_FocusedQuestTrackerPanel, hidden)

		-- AUI
		if IHH.hasAUI then
			if AUI_Questtracker then
				SafeSet(AUI_Questtracker, hidden)
			end
		end

		-- Vestige's Epic Quest
		if IHH.hasVEQ then
			if VEQ.main then
				if hidden then
					VEQ.main:SetHidden(true)
				else
					VEQ.main:SetHidden(false)
				end
			end
		end
	end

	-- Target + group
	if IHH.saved.hideTargetInfo then
		hideTargetInfo(hidden)
	end

	if IHH.saved.hideGroupUnitFrames then
		SafeSet(ZO_UnitFramesGroups, hidden)

		-- AUI
		if IHH.hasAUI then
			IHH.hideAUIGroupUnitFrames(hidden)
		end

		-- bandits
		IHH.ApplyBanditsCompanions(hidden)
		IHH.ApplyBanditsGroup(hidden)
	end

	-- Boss bar
	if IHH.saved.hideBossBar then
		SafeSet(ZO_BossBar, hidden)
	end

	-- chat
	if IHH.saved.hideChat then
		hideChat(hidden)
	end

	-- Addons
	IHH.hideMinimap(hidden)
	IHH.ApplySrendarr(hidden)
	IHH.ApplyRavalox(hidden)
	IHH.ApplyEventTracker(hidden)
	if IHH.saved.hideCombatMetrics then
		IHH.hideCombatMetrics(hidden)
	end
end

--------------------------------------------------
-- DYNAMIC MODE (AUTO HIDE)
--------------------------------------------------

function IHH.UpdateDynamic(_, inCombat)
	if not IHH.saved.dynamicMode then
		return
	end

	if inCombat then
		IHH.ApplyCore(false) -- show in combat
	else
		IHH.ApplyCore(true) -- hide out of combat
	end
end

--------------------------------------------------
-- TOGGLE
--------------------------------------------------

function IHH.StartEnforcer()
	EVENT_MANAGER:RegisterForUpdate(IHH.name .. "_enforce", IHH.saved.updateRate, IHH.Enforce)
end

function IHH.StopEnforcer()
	EVENT_MANAGER:UnregisterForUpdate(IHH.name .. "_enforce")
end

function IHH.Enforce()
	if not IHH.active then
		return
	end

	IHH.ApplyCore(true)
end

function IHH.Toggle()
	local newState = not IHH.saved.isHidden
	IHH.saved.isHidden = newState

	if newState then
		IHH.StartEnforcer()
	else
		IHH.StopEnforcer()
	end

	IHH.ApplyCore(newState)
end

--------------------------------------------------
-- MENU
--------------------------------------------------

local DONATION_URL = "https://www.esoui.com/downloads/fileinfo.php?id=3628#donate"
local function Donate()
	RequestOpenUnsafeURL(DONATION_URL)
end

function IHH.BuildMenu()
	local LAM = LibAddonMenu2

	local panel = {
		type = "panel",
		name = "Immersive HUD Hider",
		author = "Alfthebigheaded",
		version = IHH.version,
		website = "https://www.esoui.com/downloads/fileinfo.php?id=3628",
		feedback = "https://www.esoui.com/downloads/addcomment.php?action=addcomment&fileid=3628",
		donation = DONATION_URL,
	}

	LAM:RegisterAddonPanel("IHHPanel", panel)

	local options = {

		{
			type = "description",
			text = "Choose which elements of the HUD you would like hidden on toggle.",
		},
		{ type = "header", name = "Choose Which Elements To Hide" },

		{
			type = "checkbox",
			name = "Dynamic Combat Mode",
			tooltip = "Automatically hide HUD out of combat, and re-enable if you enter combat.",
			getFunc = function()
				return IHH.saved.dynamicMode
			end,
			setFunc = function(v)
				IHH.saved.dynamicMode = v
			end,
		},
		{
			type = "dropdown",
			name = "Hide Crosshair",
			tooltip = "Choose an option to hide crosshair. These options apply always, no matter whether the immersive hud hider toggle is enabled or disabled.",
			choices = hideCrosshairChoices,
			getFunc = function()
				return IHH.saved.hideCrosshair
			end,
			setFunc = function(newValue)
				IHH.saved.hideCrosshair = newValue
			end,
		},

		{
			type = "checkbox",
			name = "Hide Compass",
			getFunc = function()
				return IHH.saved.hideCompass
			end,
			setFunc = function(v)
				IHH.saved.hideCompass = v
			end,
		},

		{
			type = "checkbox",
			name = "Hide Action Bar",
			getFunc = function()
				return IHH.saved.hideActionBar
			end,
			setFunc = function(v)
				IHH.saved.hideActionBar = v
			end,
		},

		{
			type = "checkbox",
			name = "Hide Attribute Bars",
			getFunc = function()
				return IHH.saved.hideAttributeBar
			end,
			setFunc = function(v)
				IHH.saved.hideAttributeBar = v
			end,
		},

		{
			type = "checkbox",
			name = "Hide Buffs",
			getFunc = function()
				return IHH.saved.hideBuffs
			end,
			setFunc = function(v)
				IHH.saved.hideBuffs = v
			end,
		},

		{
			type = "checkbox",
			name = "Hide Target Info",
			getFunc = function()
				return IHH.saved.hideTargetInfo
			end,
			setFunc = function(v)
				IHH.saved.hideTargetInfo = v
			end,
		},

		{
			type = "checkbox",
			name = "Hide Group Unit Frames",
			getFunc = function()
				return IHH.saved.hideGroupUnitFrames
			end,
			setFunc = function(v)
				IHH.saved.hideGroupUnitFrames = v
			end,
		},

		{
			type = "checkbox",
			name = "Hide Quest Tracker",
			getFunc = function()
				return IHH.saved.hideQuestTracker
			end,
			setFunc = function(v)
				IHH.saved.hideQuestTracker = v
			end,
		},

		{
			type = "checkbox",
			name = "Hide Loot Log",
			getFunc = function()
				return IHH.saved.hideLootLog
			end,
			setFunc = function(v)
				IHH.saved.hideLootLog = v
			end,
		},

		{
			type = "dropdown",
			name = "Hide Chat",
			tooltip = "Choose an option to hide chat",
			choices = hideChatChoices,
			getFunc = function()
				return IHH.saved.hideChat
			end,
			setFunc = function(newValue)
				IHH.saved.hideChat = newValue
			end,
		},

		{
			type = "slider",
			name = "Update Rate",
			min = 5,
			max = 1000,
			step = 5,
			tooltip = "Rate to update the UI detection, measured in in milliseconds. A lower rate will make the UI hiding more responsive, but may cause a small performance drop on toggle.",
			getFunc = function()
				return IHH.saved.updateRate
			end,
			setFunc = function(v)
				IHH.saved.updateRate = v
			end,
		},

		{
			type = "slider",
			name = "Fade speed",
			min = 5,
			max = 1000,
			step = 5,
			tooltip = "Time to fade out UI elements on toggle. A higher rate will make the fade take longer, setting to 0 will make it instant. Note: Some elements do not support fading - these will always just be toggle instantly.",
			getFunc = function()
				return IHH.saved.fadeRate
			end,
			setFunc = function(v)
				IHH.saved.fadeRate = v
			end,
		},

		{ type = "header", name = "ADDON COMPATIBILITY" },
		{ type = "description", text = "Toggle compatibility for your installed addons." },

		{
			type = "checkbox",
			name = "Hide Mini Map",
			tooltip = "Toggle the minimap from multiple addons",
			disabled = function()
				return not IHH.hasMap
			end,
			warning = not IHH.hasMap and function()
				return "A supported minimap addon is not installed & enabled."
			end,
			getFunc = function()
				return IHH.saved.hideMap
			end,
			setFunc = function(v)
				IHH.saved.hideMap = v
			end,
		},

		{
			type = "checkbox",
			name = "Hide Srendarr Buffs",
			tooltip = "Toggle Srendarr widgets.",
			disabled = function()
				return not IHH.hasSrendarr
			end,
			warning = not IHH.hasSrendarr and function()
				return "Srendarr addon is not installed & enabled."
			end,
			getFunc = function()
				return IHH.saved.hideSrendarr
			end,
			setFunc = function(v)
				IHH.saved.hideSrendarr = v
			end,
		},

		{
			type = "checkbox",
			name = "Hide Ravalox Quest Tracker",
			tooltip = "Toggle the Ravalox Quest Tracker widget.",
			disabled = function()
				return not IHH.hasRavalox
			end,
			warning = not IHH.hasRavalox and function()
				return "Ravalox's Quest Tracker addon is not installed & enabled."
			end,
			getFunc = function()
				return IHH.saved.hideRavaloxTracker
			end,
			setFunc = function(v)
				IHH.saved.hideRavaloxTracker = v
			end,
		},

		{
			type = "checkbox",
			name = "Hide Combat Metrics",
			tooltip = "Toggle for Combat Metric's Live Report.",
			disabled = function()
				return not IHH.hasCombatMetrics
			end,
			warning = not IHH.hasCombatMetrics and function()
				return "Combat Metrics addon is not installed & enabled."
			end,
			getFunc = function()
				return IHH.saved.hideCombatMetrics
			end,
			setFunc = function(v)
				IHH.saved.hideCombatMetrics = v
			end,
		},

		{
			type = "checkbox",
			name = "Hide Event Tracker",
			tooltip = "Toggle the event tracker addon widget.",
			disabled = function()
				return not IHH.hasEventTracker
			end,
			warning = not IHH.hasEventTracker and function()
				return "Event Tracker addon is not installed & enabled."
			end,
			getFunc = function()
				return IHH.saved.hideEventTracker
			end,
			setFunc = function(v)
				IHH.saved.hideEventTracker = v
			end,
		},
	}

	LAM:RegisterOptionControls("IHHPanel", options)
end

--------------------------------------------------
-- INIT
--------------------------------------------------

function IHH.Initialize()
	IHH.saved = ZO_SavedVars:NewAccountWide("ImmersiveHUDHiderSavedVariables", 2, "AccountWide", IHH.defaults)

	IHH.Detect()

	IHH.ApplyCore(false)

	EVENT_MANAGER:RegisterForUpdate(IHH.name .. "_crosshair", IHH.saved.updateRate, IHH.hideCrosshair)

	IHH.BuildMenu()

	SLASH_COMMANDS["/immersivehud"] = IHH.Toggle
	SLASH_COMMANDS["/ihhdebug"] = function(search)
		for name, obj in pairs(_G) do
			pcall(function()
				if zo_strfind(name, search, 1, true) then
					if type(obj) == "userdata" and obj.SetHidden then
						d(name)
					end
				end
			end)
		end
	end
end

local function OnLoaded(_, addon)
	if addon == IHH.name then
		IHH.Initialize()
	end
end

EVENT_MANAGER:RegisterForEvent(IHH.name, EVENT_ADD_ON_LOADED, OnLoaded)
