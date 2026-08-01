BSCASynergy = BSCASynergy or {}
local BSCAS = BSCASynergy

local M_SLAYPER_PLAY_SOUND = false
local M_SLAYER_TIME_START = 0
local M_SLAYER_TIME_END = 0
local MAX_FILL_WIDTH = 0

local bUpdateUI = true
local bAddFragment = false
local bToggelUI = false
--
local debug_mode = false
function BSCAS.MSlayerDebugMode()
    debug_mode = not debug_mode
    BSCAS:PrintDebug("Debug Mode (Slayer) " .. (debug_mode and "Enabled!" or "Disabled!"))
end

function BSCAS.MSlayerUpdateUI()	
	-- Restore icon text Size etc
	-------------------------------------------------------------------------------------------------------------------------
	-- BackFrame "border"
	local UIFrame = BSCASMSlayerUI:GetNamedChild("Frame")
	UIFrame:SetHidden(false)
	UIFrame:SetDimensions(BSCAS.SV.UIMS_WIDTH, BSCAS.SV.UIMS_HIGHT)
	-------------------------------------------------------------------------------------------------------------------------
	-- icon of the buff if enabled
	local UIIcon = BSCASMSlayerUI:GetNamedChild("Icon")
	if BSCAS.SV.MSLAYER_ENABLE_ICON then	
		UIIcon:SetHidden(false)
	else
		UIIcon:SetHidden(true)		
	end
	UIIcon:SetTexture(GetAbilityIcon(BSCAS.LOKKE_ID))	
	UIIcon:SetDimensions(BSCAS.SV.UIMS_HIGHT -4, BSCAS.SV.UIMS_HIGHT -4) -- 2 border
	-------------------------------------------------------------------------------------------------------------------------
	-- BuffName text	
	local UIBuffName = BSCASMSlayerUI:GetNamedChild("BuffName")
	UIBuffName:ClearAnchors()
	if BSCAS.SV.MSLAYER_ENABLE_ICON then	
		UIBuffName:SetAnchor(LEFT, UIIcon, RIGHT, 8, 0)
	else
		UIBuffName:SetAnchor(LEFT, UIFrame, LEFT, 8, 0)
	end
	if BSCAS.SV.MSLAYER_ENABLE_NAME then
		UIBuffName:SetHidden(false)
	else
		UIBuffName:SetHidden(true)
	end
	UIBuffName:SetFont("$(MEDIUM_FONT)|$(KB_" .. BSCAS.FontCheck(math.floor(BSCAS.SV.UIMS_HIGHT / 2)) .. ")|soft-shadow-thin")	
	UIBuffName:SetDimensions(200, BSCAS.SV.UIMS_HIGHT -4)
	UIBuffName:SetText(zo_strformat("<<1>>", GetAbilityName(BSCAS.LOKKE_ID)))
	-------------------------------------------------------------------------------------------------------------------------
	-- cooldown text
	local UICooldown = BSCASMSlayerUI:GetNamedChild("Cooldown")
	UICooldown:ClearAnchors()
	UICooldown:SetAnchor(RIGHT, UIFrame, RIGHT, -10, 0)	
	UICooldown:SetHidden(false)
	UICooldown:SetFont("$(BOLD_FONT)|$(KB_" .. BSCAS.FontCheck(math.floor(BSCAS.SV.UIMS_HIGHT / 2)) .. ")|soft-shadow-thick")
	UICooldown:SetText(string.format("%.1fs", 0))		
	UICooldown:SetDimensions(64, BSCAS.SV.UIMS_HIGHT -4) 	
	-------------------------------------------------------------------------------------------------------------------------
	-- StatusBar
	local UIFill = BSCASMSlayerUI:GetNamedChild("Fill")
	UIFill:ClearAnchors()
	UIFill:SetHidden(false)

	if BSCAS.SV.MSLAYER_ENABLE_ICON then
		MAX_FILL_WIDTH = BSCAS.SV.UIMS_WIDTH - BSCAS.SV.UIMS_HIGHT
		UIFill:SetAnchor(LEFT, UIIcon, RIGHT, 0, 0)
	else
		MAX_FILL_WIDTH = BSCAS.SV.UIMS_WIDTH - 4
		UIFill:SetAnchor(LEFT, UIFrame, LEFT, 2, 0)
	end

	UIFill:SetDimensions(MAX_FILL_WIDTH, BSCAS.SV.UIMS_HIGHT - 4)
	UIFill:SetMinMax(0, 1)
	UIFill:SetValue(0)
	UIFill:SetColor(0, 1, 0, 1)
	
	UIFill:SetBarAlignment(BAR_ALIGNMENT_NORMAL) -- Standard (links → rechts) BAR_ALIGNMENT_NORMAL = 0, BAR_ALIGNMENT_REVERSE = 1, BAR_ALIGNMENT_CENTER = 2
	UIFill:SetGradientColors(0, 1, 0, 0.8,   1, 0, 0, 0.8)
	-------------------------------------------------------------------------------------------------------------------------
	BSCASMSlayerUI:SetAlpha(BSCAS.SV.UIMS_ALPHA)
end
function BSCAS.MSlayerOnMoveStop()
	BSCAS.SV.UIMS_LEFT = BSCASMSlayerUI:GetLeft()
	BSCAS.SV.UIMS_TOP = BSCASMSlayerUI:GetTop()
end
function BSCAS:MSlayerRestorePosition()
	BSCASMSlayerUI:ClearAnchors()
	BSCASMSlayerUI:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, BSCAS.SV.UIMS_LEFT, BSCAS.SV.UIMS_TOP)
	BSCASMSlayerUI:SetMovable(not BSCAS.SV.MSLAYER_LOCK_UI)
end
-- EVENT_EFFECT_CHANGED (eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
local function OnEffectChanged( _, changeType, _, _, unitTag, beginTime, endTime, _, _, _, _, _, _, unitName, unitId, abilityId, _)
	if changeType == EFFECT_RESULT_FADED then			
		M_SLAYER_TIME_START = 0
		M_SLAYER_TIME_END = 0
		M_SLAYPER_PLAY_SOUND = false	
	elseif changeType == EFFECT_RESULT_UPDATED then	
		M_SLAYER_TIME_START = beginTime
		M_SLAYER_TIME_END = endTime
		M_SLAYPER_PLAY_SOUND = true					
		bUpdateUI = true
	end	
	if debug_mode then
		BSCAS:PrintDebug(zo_strformat("ID[<<1>>] Name[<<2>>] changeType[<<3>>]", abilityId, GetAbilityName(abilityId), changeType))
	end
end
local function UpdateCooldown()
    if not bUpdateUI then return end

    local now = GetGameTimeMilliseconds() / 1000
    local duration = M_SLAYER_TIME_END - now
    if duration < 0 then duration = 0 end

    local total = M_SLAYER_TIME_END - M_SLAYER_TIME_START
    if total <= 0 then total = 1 end

    local ratio = duration / total
    local UIFill = BSCASMSlayerUI:GetNamedChild("Fill")
    local UICooldown = BSCASMSlayerUI:GetNamedChild("Cooldown")

    -- Sichtbarkeit
    if duration > 0 then
        if BSCAS.SV.MSLAYER_ENABLE_AUTO_HIDE and not bToggelUI then
			SCENE_MANAGER:GetScene("hud"):AddFragment(BSCAS.SlayerFragment)
			SCENE_MANAGER:GetScene("hudui"):AddFragment(BSCAS.SlayerFragment)
            BSCASMSlayerUI:SetHidden(false)
			bToggelUI = true
        end
    else
        bUpdateUI = false
        if BSCAS.SV.MSLAYER_ENABLE_AUTO_HIDE and bToggelUI then
			SCENE_MANAGER:GetScene("hud"):RemoveFragment(BSCAS.SlayerFragment)
			SCENE_MANAGER:GetScene("hudui"):RemoveFragment(BSCAS.SlayerFragment)
            BSCASMSlayerUI:SetHidden(true)
			bToggelUI = false
        end
    end

    -- Balken setzen (0–1)
    UIFill:SetValue(ratio)

    -- Farbverlauf Rot ↔ Grün
    UIFill:SetColor(1 - ratio, ratio, 0, 1)
	--UIFill:SetColor(1 - ratio, ratio, 0, BSCAS.SV.UIMS_ALPHA)

    -- Cooldown-Text nur aktualisieren, wenn sich was geändert hat
    local newText = string.format("%.1fs", duration)
    if UICooldown:GetText() ~= newText then
        UICooldown:SetText(newText)
    end

    -- Sound
    if duration <= BSCAS.SV.MSLAYER_SOUND_INC and BSCAS.SV.MSLAYER_SOUND_PLAY then
        if M_SLAYPER_PLAY_SOUND then
            M_SLAYPER_PLAY_SOUND = false
            BSCAS.PlaySound(BSCAS.SV.MSLAYER_SOUND_LOOP, BSCAS.SV.MSLAYER_SOUND_ID)
        end
    end
end

function BSCAS:MSlayerUIEnable()
	if BSCAS.SV.MSLAYER_CHECK and not BSCAS.SV.MSLAYER_ENABLE_AUTO_HIDE then 
		if not bAddFragment then
			SCENE_MANAGER:GetScene("hud"):AddFragment(BSCAS.SlayerFragment)
			SCENE_MANAGER:GetScene("hudui"):AddFragment(BSCAS.SlayerFragment)
		end
	else
		if bAddFragment then
			SCENE_MANAGER:GetScene("hud"):RemoveFragment(BSCAS.SlayerFragment)
			SCENE_MANAGER:GetScene("hudui"):RemoveFragment(BSCAS.SlayerFragment)
		end
		if BSCAS.SV.MSLAYER_ENABLE_AUTO_HIDE then
			BSCASMSlayerUI:SetHidden(true)
		end
	end
end

function BSCAS.MSlayerEnable()	
	if BSCAS.SV.MSLAYER_CHECK then 
		for abilityId in pairs(BSCAS.SLAYER_IDS) do
			local eventName = 'BSCAS_MSOEC'..abilityId
			EVENT_MANAGER:RegisterForEvent(eventName, EVENT_EFFECT_CHANGED, OnEffectChanged)
			EVENT_MANAGER:AddFilterForEvent(eventName, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, abilityId)
			EVENT_MANAGER:AddFilterForEvent(eventName, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, 'player')
		end
		EVENT_MANAGER:RegisterForUpdate('BSCAS_MSlayerUpdate', BSCAS.UPDATE_INTERVAL, UpdateCooldown)		
	else
		for abilityId in pairs(BSCAS.SLAYER_IDS) do
			local eventName = 'BSCAS_MSOEC'..abilityId
			EVENT_MANAGER:UnregisterForEvent(eventName, EVENT_EFFECT_CHANGED)
		end
		EVENT_MANAGER:UnregisterForUpdate('BSCAS_MSlayerUpdate')
	end	
	BSCAS:MSlayerUIEnable()
end

function BSCAS.MSlayerInit()
	BSCAS:MSlayerRestorePosition()
	BSCAS.MSlayerUpdateUI()	
	--
	BSCAS.SlayerFragment = ZO_SimpleSceneFragment:New(BSCASMSlayerUI)
	
	--
	BSCAS.MSlayerEnable()
end