BSCUDPoints = BSCUDPoints or {}
local BSCUDP = BSCUDPoints

BSCUDP.Name = "BSCs-UltiPoints"
-- AddonInfo
BSCUDP.NameMenu = "BSCs-UltiPoints"
BSCUDP.NameSpaced = "BSCUltiPoints"
BSCUDP.Author = "@BloodStainChild666"
BSCUDP.SavedVar = "BSCUDPSaved"
BSCUDP.VersionDisplay = "2.2.2"

--local ULT_INFO_PASSIVE_FRAGMENT = nil
--local bAddPFrag = false
local ULT_INFO_POINTS_FRAGMENT = nil
local bAddUFrag = false
local ULT_INFO_BASE_FRAGMENT = nil
local bAddBFrag = false
local function AddFragment(fragment)
	SCENE_MANAGER:GetScene("hud"):AddFragment(fragment)
	SCENE_MANAGER:GetScene("hudui"):AddFragment(fragment)	
end
local function RemoveFragment(fragment)
	SCENE_MANAGER:GetScene("hud"):RemoveFragment(fragment)
	SCENE_MANAGER:GetScene("hudui"):RemoveFragment(fragment)	
end

local bDeath = false

local CLASSID_DRAGONKNIGHT  = 1
local CLASSID_SORCERER		= 2 -- just cheaper ulti
local CLASSID_NIGHTBLADE	= 3
local CLASSID_WARDEN		= 4
local CLASSID_NECROMANCER	= 5
local CLASSID_TEMPLAR		= 6 
local CLASSID_ARCANIST		= 117

local active_classes = {
	[CLASSID_DRAGONKNIGHT] = false,
	[CLASSID_SORCERER] = false,
	[CLASSID_NIGHTBLADE] = false,
	[CLASSID_WARDEN] = false,
	[CLASSID_NECROMANCER] = false,
	[CLASSID_TEMPLAR] = false,
	[CLASSID_ARCANIST] = false,
}

local classid2Texture = {
    [CLASSID_DRAGONKNIGHT] = "esoui/art/icons/ability_dragonknight_024.dds",
    [CLASSID_NIGHTBLADE] = "esoui/art/icons/passive_sorcerer_002.dds",
    [CLASSID_WARDEN] = "esoui/art/icons/passive_warden_009.dds",
    [CLASSID_NECROMANCER] = "esoui/art/icons/passive_necromancer_011.dds",
    [CLASSID_TEMPLAR] = "esoui/art/icons/ability_templar_031.dds",
    [CLASSID_ARCANIST] = "esoui/art/icons/passive_arcanist_08.dds",
}

local PASSIVE_SKILLS = {
	[29473] = CLASSID_DRAGONKNIGHT, -- DK
	[45001] = CLASSID_DRAGONKNIGHT, -- DK
	[36587] = CLASSID_NIGHTBLADE, -- NB
	[45145] = CLASSID_NIGHTBLADE, -- NB
	[86062] = CLASSID_WARDEN, -- Warden
	[86063] = CLASSID_WARDEN, -- Warden
	[116284] = CLASSID_NECROMANCER, -- Necro
	[116285] = CLASSID_NECROMANCER, -- necro
	[31744] = CLASSID_TEMPLAR, -- Templar
	[45216] = CLASSID_TEMPLAR, -- Templar
	[185050] = CLASSID_ARCANIST, -- Arc
	[185058] = CLASSID_ARCANIST, -- Arc
}

local REGISTER_SKILLS = { 
	[29474] = CLASSID_DRAGONKNIGHT, -- DK
	[45005] = CLASSID_DRAGONKNIGHT, -- DK
	[36589] = CLASSID_NIGHTBLADE, -- NB
	[45146] = CLASSID_NIGHTBLADE, -- NB
	[88512] = CLASSID_WARDEN, -- Warden
	[88513] = CLASSID_WARDEN, -- Warden
	[120611] = CLASSID_NECROMANCER, -- Necro
	[120612] = CLASSID_NECROMANCER, -- necro
	[31746] = CLASSID_TEMPLAR, -- Templar
	[45217] = CLASSID_TEMPLAR, -- Templar
	[185070] = CLASSID_ARCANIST, -- Arc
	[185051] = CLASSID_ARCANIST, -- Arc
}

local HOTBAR_CATEGORY_SET =
{
    [HOTBAR_CATEGORY_PRIMARY] = true,
    [HOTBAR_CATEGORY_BACKUP] = true,
}
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
local defaultSV_ACC = {	
	-- passive UI 
	UI_ALPHA 		= 1,
	UI_ENABLE		= true,
	UI_LOCK 		= false,	
	UI_ALLWAYS		= true,
	-- ult points UI
	UI_LEFT_UP 		= 0,
	UI_TOP_UP  		= 80,
	UI_ALPHA_UP 	= 1,
	UI_ENABLE_UP 	= true,
	UI_HOTBAR_UP 	= -1,
	UI_LOCK_UP 		= false,
	--
	UI_FONT = "BOLD_FONT",
	UI_FONT_STYLE = "soft-shadow-thick", 
	UI_FONT_COLOR_N = {0, 255, 0, 255},
	UI_FONT_COLOR_C = {255, 0, 0, 255},
	FONT_SIZE = 28,
	--Base Reg UI
	UI_LEFT_BASE 	= 80,
	UI_TOP_BASE  	= 80,
	UI_ALPHA_BASE 	= 1,
	UI_ENABLE_BASE	= false,
	UI_LOCK_BASE	= false,
	UI_ALLWAYS_BASE = true,
	
	-- passive UI New
	DK_UIPosi_L = 0,
	DK_UIPosi_T = 0,
	SORC_UIPosi_L = 0,
	SORC_UIPosi_T = 0,
	NB_UIPosi_L = 0,
	NB_UIPosi_T = 0,
	WARDEN_UIPosi_L = 0,
	WARDEN_UIPosi_T = 0,
	NECRO_UIPosi_L = 0,
	NECRO_UIPosi_T = 0,
	TEMP_UIPosi_L = 0,
	TEMP_UIPosi_T = 0,
	ARCA_UIPosi_L = 0,
	ARCA_UIPosi_T = 0,
}
-------------------------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------------------------
local HOTBAR_ULTIMATE_COST = 
{
	[HOTBAR_CATEGORY_PRIMARY] = 0,
    [HOTBAR_CATEGORY_BACKUP] = 0,
    [HOTBAR_CATEGORY_OVERLOAD] = 0,
    [HOTBAR_CATEGORY_WEREWOLF] = 0,
    [HOTBAR_CATEGORY_TEMPORARY] = 0,
    [HOTBAR_CATEGORY_DAEDRIC_ARTIFACT] = 0,
    [HOTBAR_CATEGORY_COMPANION] = 0,
}
local function GetUltiMateCost()
	local choosenhotbar = GetActiveHotbarCategory()
	if BSCUDP.SV_ACC.UI_HOTBAR_UP ~= -1 then
		choosenhotbar = BSCUDP.SV_ACC.UI_HOTBAR_UP
	end
	local need_utl = 0
	if not HOTBAR_ULTIMATE_COST[choosenhotbar] or HOTBAR_ULTIMATE_COST[choosenhotbar] == 0 then
		need_utl = GetSlotAbilityCost(ACTION_BAR_ULTIMATE_SLOT_INDEX + 1, COMBAT_MECHANIC_FLAGS_ULTIMATE, choosenhotbar)
	else
		need_utl = HOTBAR_ULTIMATE_COST[choosenhotbar]
	end
	return need_utl
end
local function UpdateUltimateUI()	
	if not BSCUDP.SV_ACC.UI_ENABLE_UP then return end	
	local need_utl = GetUltiMateCost()
	local current_ult = GetUnitPower('player', POWERTYPE_ULTIMATE)
	if current_ult >= need_utl then
		BSCUDULTPointsUI:GetNamedChild("lblUlti"):SetColor(unpack(BSCUDP.SV_ACC.UI_FONT_COLOR_N))
	else
		BSCUDULTPointsUI:GetNamedChild("lblUlti"):SetColor(unpack(BSCUDP.SV_ACC.UI_FONT_COLOR_C))
	end
	BSCUDULTPointsUI:GetNamedChild("lblUlti"):SetText(current_ult)
end
-------------------------------------------------------------------------------------------------
-- ult gain
-------------------------------------------------------------------------------------------------
local classes_BuffStartTime = {
	[CLASSID_DRAGONKNIGHT] = 0,
	[CLASSID_SORCERER] = 0,
	[CLASSID_NIGHTBLADE] = 0,
	[CLASSID_WARDEN] = 0,
	[CLASSID_NECROMANCER] = 0,
	[CLASSID_TEMPLAR] = 0,
	[CLASSID_ARCANIST] = 0,
}

local GlobalCD = 0
local function OnCombatEvent( _, result, _, _, _, _, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow )	
	if hitValue <= 0 then return end
	if REGISTER_SKILLS[abilityId] ~= nil then
		if GetAPIVersion() >= 101047 then
			GlobalCD = (GetGameTimeMilliseconds() + GetAbilityCooldown(abilityId, 'player')) / 1000
		else
			classes_BuffStartTime[REGISTER_SKILLS[abilityId]] = (GetGameTimeMilliseconds() + GetAbilityCooldown(abilityId, 'player')) / 1000
		end
	end	
end

local bCombat = false
local function OnCombatState(_, inCombat)	
	bCombat = inCombat
end
local ACTION_SLOT_TYPE =
{
	[ACTION_SLOT_TYPE_HEAVY_ATTACK] = true,
	[ACTION_SLOT_TYPE_LIGHT_ATTACK] = true,
}
local BaseStartTime = 0
local function OnCombatEventULTBASE( _, result, _, _, _, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow )
	if result == ACTION_RESULT_DODGED or result == ACTION_RESULT_BLOCKED_DAMAGE then
		BaseStartTime = GetGameTimeSeconds() + 8
	end
	if not bCombat then return end
	if ACTION_SLOT_TYPE[abilityActionSlotType] then
		BaseStartTime = GetGameTimeSeconds() + 8
	end	
end
-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
local function UpdateUI()
	if BSCUDP.SV_ACC.UI_ENABLE then
		for index = 1, GetNumClasses(), 1 do	
			local _classId_ = GetClassIdByIndex(index)	
			
			local DURATION = 0
			if GetAPIVersion() >= 101047 then
				DURATION = GlobalCD - GetGameTimeSeconds()
			else
				DURATION = classes_BuffStartTime[_classId_] - GetGameTimeSeconds()
			end
			if DURATION <= 0 then 
				DURATION = 0 
			end
			
			local LB = BSCUDP.frames[_classId_]:GetNamedChild("Info")
			local BF = BSCUDP.frames[_classId_]:GetNamedChild("FrameBack")
			LB:SetText(string.format("%.0f", DURATION))		
			if DURATION == 0 then
				LB:SetColor(0, 1, 0, 1)	
				BF:SetCenterColor(0, 1, 0, 1)
			elseif DURATION < 3 then
				LB:SetColor(0.8, 1, 0, 1)
				BF:SetCenterColor(0.8, 1, 0, 1)
				if BSCUDP.SV_ACC.UI_ALLWAYS and active_classes[_classId_] then
					BSCUDP.frames[_classId_]:SetHidden(false)
				end
			else		
				LB:SetColor(1, 0, 0, 1)
				BF:SetCenterColor(1, 0, 0, 1)
				if BSCUDP.SV_ACC.UI_ALLWAYS and active_classes[_classId_] then
					BSCUDP.frames[_classId_]:SetHidden(true)
				end
			end
		end
	end
	if BSCUDP.SV_ACC.UI_ENABLE_BASE then
		local DURATION = BaseStartTime - GetGameTimeSeconds()
		if DURATION <= 0 then 
			DURATION = 0 
		end			
		local LB = BSCUDPointsUIBASE:GetNamedChild("Info")
		local BF = BSCUDPointsUIBASE:GetNamedChild("FrameBack")
		LB:SetText(string.format("%.0f", DURATION))		
		if DURATION == 0 then
			LB:SetColor(0, 1, 0, 1)	
			BF:SetCenterColor(0, 1, 0, 1)
		elseif DURATION < 3 then
			LB:SetColor(0.8, 1, 0, 1)
			BF:SetCenterColor(0.8, 1, 0, 1)
			if BSCUDP.SV_ACC.UI_ALLWAYS_BASE then
				BSCUDPointsUIBASE:SetHidden(false)
			end
		else
			LB:SetColor(1, 0, 0, 1)
			BF:SetCenterColor(1, 0, 0, 1)
			if BSCUDP.SV_ACC.UI_ALLWAYS_BASE then
				BSCUDPointsUIBASE:SetHidden(true)
			end
		end
	end
end
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function BSCUDP:OnMoveStop()
	BSCUDP.SV_ACC.UI_LEFT_UP = BSCUDULTPointsUI:GetLeft()
	BSCUDP.SV_ACC.UI_TOP_UP = BSCUDULTPointsUI:GetTop()	
	BSCUDP.SV_ACC.UI_LEFT_BASE = BSCUDPointsUIBASE:GetLeft()
	BSCUDP.SV_ACC.UI_TOP_BASE = BSCUDPointsUIBASE:GetTop()	
end
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function BSCUDP:SetPosition()	
	if BSCUDP.SV_ACC.UI_LEFT_UP ~= 0 and BSCUDP.SV_ACC.UI_TOP_UP ~= 80 then
		BSCUDULTPointsUI:ClearAnchors()
		BSCUDULTPointsUI:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, BSCUDP.SV_ACC.UI_LEFT_UP, BSCUDP.SV_ACC.UI_TOP_UP)
	end
	BSCUDULTPointsUI:SetAlpha(BSCUDP.SV_ACC.UI_ALPHA_UP)
		
	if BSCUDP.SV_ACC.UI_LEFT_BASE ~= 80 and BSCUDP.SV_ACC.UI_TOP_BASE ~= 80 then
		BSCUDPointsUIBASE:ClearAnchors()
		BSCUDPointsUIBASE:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, BSCUDP.SV_ACC.UI_LEFT_BASE, BSCUDP.SV_ACC.UI_TOP_BASE)
	end
	BSCUDPointsUIBASE:SetAlpha(BSCUDP.SV_ACC.UI_ALPHA_BASE)
end
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
local function DeathRecapAddUltiPoints()
	BSCUDP.UltiLabel:SetHidden(false)
	BSCUDP.UltiLabel:SetText("Ultimate Points: " .. GetUnitPower('player', POWERTYPE_ULTIMATE))
end
local function CreateLable()
	-- font
	local fontSize = 23
	local font = string.format("$(BOLD_FONT)|$(KB_%s)|soft-shadow-thick", fontSize)		
	local parent = ZO_Death		
	BSCUDP.UltiLabel = WINDOW_MANAGER:CreateControl(nil, parent, CT_LABEL)
	BSCUDP.UltiLabel:SetAnchor(BOTTOM, parent, TOP, 0, 0) 
	BSCUDP.UltiLabel:SetFont(font)
end
function BSCUDP:UpdateEnableUP()
	if BSCUDP.SV_ACC.UI_ENABLE_UP then
		AddFragment(ULT_INFO_POINTS_FRAGMENT)
		bAddUFrag = true
	else
		RemoveFragment(ULT_INFO_POINTS_FRAGMENT)
		bAddUFrag = false
	end
end
function BSCUDP:UpdateEnableBase()
	if BSCUDP.SV_ACC.UI_ENABLE_BASE then
		AddFragment(ULT_INFO_BASE_FRAGMENT)
		bAddBFrag = true
	else
		RemoveFragment(ULT_INFO_BASE_FRAGMENT)
		bAddBFrag = false
	end
end
function BSCUDP:FontCheck(size)
    local thresholds = {54, 48, 40, 36, 34, 32, 30, 28, 26}
    for _, threshold in ipairs(thresholds) do
        if size > threshold then
            return threshold
        end
    end
    return size
end
local function OnActionSlotsFullUpdate(_, isHotbarSwap)
	if isHotbarSwap then
		local ActiveHotbar = GetActiveHotbarCategory()
		HOTBAR_ULTIMATE_COST[ActiveHotbar] = GetSlotAbilityCost(ACTION_BAR_ULTIMATE_SLOT_INDEX + 1, COMBAT_MECHANIC_FLAGS_ULTIMATE, ActiveHotbar)	
		UpdateUltimateUI()
	end
end
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- Passive UI
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function BSCUDP:UpdatePassiveUI()
	for index = 1, GetNumClasses(), 1 do	
		local _classId_ = GetClassIdByIndex(index)		
		BSCUDP.frames[_classId_]:SetHidden(true)	
		BSCUDP.frames[_classId_]:SetMovable(not BSCUDP.SV_ACC.UI_LOCK)
		BSCUDP.frames[_classId_]:SetAlpha(BSCUDP.SV_ACC.UI_ALPHA)	
		if active_classes[_classId_] and BSCUDP.SV_ACC.UI_ENABLE then
			BSCUDP.frames[_classId_]:SetHidden(false)			
			SCENE_MANAGER:GetScene("hud"):AddFragment(BSCUDP.fragments[_classId_])
			SCENE_MANAGER:GetScene("hudui"):AddFragment(BSCUDP.fragments[_classId_])
		else
			SCENE_MANAGER:GetScene("hud"):RemoveFragment(BSCUDP.fragments[_classId_])
			SCENE_MANAGER:GetScene("hudui"):RemoveFragment(BSCUDP.fragments[_classId_])			
		end
	end
end
function BSCUDP.OnMoveStopPassive(index, frame)
	local L = frame:GetLeft()
	local T = frame:GetTop()	
	if index == CLASSID_DRAGONKNIGHT then
		BSCUDP.SV_ACC.DK_UIPosi_L = L
		BSCUDP.SV_ACC.DK_UIPosi_T = T
	elseif index == CLASSID_SORCERER then
		BSCUDP.SV_ACC.SORC_UIPosi_L = L
		BSCUDP.SV_ACC.SORC_UIPosi_T = T
	elseif index == CLASSID_NIGHTBLADE then
		BSCUDP.SV_ACC.NB_UIPosi_L = L
		BSCUDP.SV_ACC.NB_UIPosi_T = T
	elseif index == CLASSID_WARDEN then
		BSCUDP.SV_ACC.WARDEN_UIPosi_L = L
		BSCUDP.SV_ACC.WARDEN_UIPosi_T = T
	elseif index == CLASSID_NECROMANCER then
		BSCUDP.SV_ACC.NECRO_UIPosi_L = L
		BSCUDP.SV_ACC.NECRO_UIPosi_T = T
	elseif index == CLASSID_TEMPLAR then
		BSCUDP.SV_ACC.TEMP_UIPosi_L = L
		BSCUDP.SV_ACC.TEMP_UIPosi_T = T
	elseif index == CLASSID_ARCANIST then
		BSCUDP.SV_ACC.ARCA_UIPosi_L = L
		BSCUDP.SV_ACC.ARCA_UIPosi_T = T
	end	
end
local function CreatePassiveUI()
	local WM = GetWindowManager()
	BSCUDP.frames = { }	-- /script BSCUDPoints.frames[5]:SetHidden(false)
	BSCUDP.fragments = { }	
	local Posi = 0
	for index = 1, GetNumClasses(), 1 do	
		local _classId_ = GetClassIdByIndex(index)
		
		--if _classId_ ~= CLASSID_SORCERER and _classId_ ~= CLASSID_TEMPLAR then			
			local frame = WM:CreateControlFromVirtual("BSCUDPointsUI" .. _classId_, nil, "BSCUDPointsUI")
			frame:SetHandler("OnMoveStop", function() BSCUDPoints.OnMoveStopPassive(_classId_, frame) end)
			frame:GetNamedChild("Icon"):SetTexture(classid2Texture[_classId_] or "")	
		
			Posi = Posi + 60
			BSCUDP.fragments[_classId_] = ZO_HUDFadeSceneFragment:New(frame)		
			BSCUDP.frames[_classId_] = frame
			
			local L = 0
			local T = 0
			if _classId_ == CLASSID_DRAGONKNIGHT then
				L = BSCUDP.SV_ACC.DK_UIPosi_L
				T = BSCUDP.SV_ACC.DK_UIPosi_T
			elseif _classId_ == CLASSID_SORCERER then
				L = BSCUDP.SV_ACC.SORC_UIPosi_L
				T = BSCUDP.SV_ACC.SORC_UIPosi_T
			elseif _classId_ == CLASSID_NIGHTBLADE then
				L = BSCUDP.SV_ACC.NB_UIPosi_L
				T = BSCUDP.SV_ACC.NB_UIPosi_T
			elseif _classId_ == CLASSID_WARDEN then
				L = BSCUDP.SV_ACC.WARDEN_UIPosi_L
				T = BSCUDP.SV_ACC.WARDEN_UIPosi_T
			elseif _classId_ == CLASSID_NECROMANCER then
				L = BSCUDP.SV_ACC.NECRO_UIPosi_L
				T = BSCUDP.SV_ACC.NECRO_UIPosi_T
			elseif _classId_ == CLASSID_TEMPLAR then
				L = BSCUDP.SV_ACC.TEMP_UIPosi_L
				T = BSCUDP.SV_ACC.TEMP_UIPosi_T
			elseif _classId_ == CLASSID_ARCANIST then
				L = BSCUDP.SV_ACC.ARCA_UIPosi_L
				T = BSCUDP.SV_ACC.ARCA_UIPosi_T
			end
			
			frame:ClearAnchors()
			if L ~= 0 and T ~= 0 then
				frame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, L, T)	
			else
				frame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 600, 400 + Posi)
			end	
		--end
	end
end
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function BSCUDP:UpdateSettings()
	BSCUDULTPointsUI:SetMovable(not BSCUDP.SV_ACC.UI_LOCK_UP)
	BSCUDULTPointsUI:SetAlpha(BSCUDP.SV_ACC.UI_ALPHA_UP)
	BSCUDULTPointsUI:GetNamedChild("lblUlti"):SetFont("$("..BSCUDP.SV_ACC.UI_FONT..")|$(KB_".. BSCUDP:FontCheck(BSCUDP.SV_ACC.FONT_SIZE)..")|"..BSCUDP.SV_ACC.UI_FONT_STYLE)
	BSCUDPointsUIBASE:SetMovable(not BSCUDP.SV_ACC.UI_LOCK_BASE)
	BSCUDPointsUIBASE:SetAlpha(BSCUDP.SV_ACC.UI_ALPHA_BASE)
	UpdateUltimateUI()
	BSCUDP:UpdatePassiveUI()
end
local function SkillLineAdded(_, _skillType_, _skillLineIndex_, _advised_)
	BSCUDP:CheckSkillLines()
	BSCUDP:UpdatePassiveUI()
end
-- Prepeare for subclasing
function BSCUDP:CheckSkillLines() -- /script BSCUDPoints:CheckSkillLines()	
	local function CheckByClassID(_classId_)			
		for _classSkillLineIndex_ = 1, GetNumSkillLinesForClass(_classId_), 1 do 
			local _skillLineId_ = GetSkillLineIdForClass(_classId_, _classSkillLineIndex_)				
			local _skillType_, _skillLineIndex_ = GetSkillLineIndicesFromSkillLineId(_skillLineId_)				
			local _rank_, _isAdvised_, _isActive_, _isDiscovered_, _isAccountSkill_, _isInTraining_ =  GetSkillLineDynamicInfo(_skillType_, _skillLineIndex_)

			-- Active skill lines
			if _isActive_ then
				--d(GetSkillLineNameById(_skillLineId_))
				--d(IsPlayerClassSkillLineById(_skillLineId_))	
				for _skillIndex_ = 1, GetNumSkillAbilities(_skillType_, _skillLineIndex_), 1 do				
					if IsSkillAbilityPassive(_skillType_, _skillLineIndex_, _skillIndex_) 
					and IsSkillAbilityPurchased(_skillType_, _skillLineIndex_, _skillIndex_) then						
						local _showUpgrade_ = false
						local _abilityId_ = GetSkillAbilityId(_skillType_, _skillLineIndex_, _skillIndex_, _showUpgrade_)						
						if PASSIVE_SKILLS[_abilityId_] ~= nil then
							active_classes[_classId_] = true
						end		
						--d(zo_strformat("[<<1>>] Name[<<2>>]", _abilityId_, GetAbilityName(_abilityId_)))				
					end
				end	
			end			
		end	
	end
	if HasAccessToSubclassing() then
		--d("Sublcasing Enabled")		
		--Reset 
		for index = 1, GetNumClasses(), 1 do
			local _classId_ = GetClassIdByIndex(index)			
			active_classes[_classId_] = false
		end
		-- Check
		for index = 1, GetNumClasses(), 1 do
			local _classId_ = GetClassIdByIndex(index)			
			CheckByClassID(GetClassIdByIndex(_classId_))			
		end		
	else
		--d("Sublcasing Disabled")
		CheckByClassID(GetUnitClassId('player'))
	end
end
local function OnPlayerActivated()	
	UpdateUltimateUI()		
	BSCUDP:CheckSkillLines()
	BSCUDP:UpdatePassiveUI()
end
local ULT_GAIN_BASE_FILTERS = {
	[ACTION_RESULT_DAMAGE] = REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE,
	[ACTION_RESULT_CRITICAL_DAMAGE] = REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE,
	[ACTION_RESULT_DAMAGE_SHIELDED] = REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE,
	[ACTION_RESULT_BLOCKED_DAMAGE] = REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE,
	[ACTION_RESULT_DODGED] = REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE,
}

function BSCUDP.init(event, addonName)	
	if addonName ~= BSCUDP.Name then
		return 
	end	
	EVENT_MANAGER:UnregisterForEvent(BSCUDP.Name, EVENT_ADD_ON_LOADED)
	
	BSCUDP.SV_ACC = ZO_SavedVars:NewAccountWide(BSCUDP.SavedVar, 1, nil, defaultSV_ACC)	
	CreateLable()		
	-- Create UI Fragments
	CreatePassiveUI()		-- Create New passive UI
	
	ULT_INFO_POINTS_FRAGMENT = ZO_HUDFadeSceneFragment:New(BSCUDULTPointsUI)
	ULT_INFO_BASE_FRAGMENT = ZO_HUDFadeSceneFragment:New(BSCUDPointsUIBASE)
			
	EVENT_MANAGER:RegisterForEvent(BSCUDP.Name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
	
	-- Skill Line change check
	EVENT_MANAGER:RegisterForEvent(BSCUDP.Name, EVENT_SKILL_LINE_ADDED, SkillLineAdded)
	-- on Armory load Check
	EVENT_MANAGER:RegisterForEvent(BSCUDP.Name, EVENT_ARMORY_BUILD_RESTORE_RESPONSE, function(...) 
		BSCUDP:CheckSkillLines()
		BSCUDP:UpdatePassiveUI()
	end)
	
	EVENT_MANAGER:RegisterForEvent(BSCUDP.Name, EVENT_PLAYER_DEAD, function(...) DeathRecapAddUltiPoints() bDeath = true end)	
	EVENT_MANAGER:RegisterForEvent(BSCUDP.Name, EVENT_PLAYER_ALIVE, function(...) BSCUDP.UltiLabel:SetHidden(true) bDeath = false end)
	EVENT_MANAGER:RegisterForEvent(BSCUDP.Name, EVENT_POWER_UPDATE, function(...) 
		-- Updaet Movable UI	
		UpdateUltimateUI()
		if bDeath then 
			DeathRecapAddUltiPoints() 
		end 
	end)
	EVENT_MANAGER:AddFilterForEvent(BSCUDP.Name, EVENT_POWER_UPDATE, REGISTER_FILTER_POWER_TYPE, POWERTYPE_ULTIMATE)
	-- ult check to manage if we have 1 bar set that reduce the cost
	EVENT_MANAGER:RegisterForEvent(BSCUDP.Name, EVENT_ACTION_SLOTS_FULL_UPDATE, OnActionSlotsFullUpdate)
	
	-- for ult gain
	EVENT_MANAGER:RegisterForEvent(BSCUDP.Name, EVENT_COMBAT_EVENT, OnCombatEvent)	
	EVENT_MANAGER:AddFilterForEvent(BSCUDP.Name, EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_POWER_ENERGIZE)
	EVENT_MANAGER:AddFilterForEvent(BSCUDP.Name, EVENT_COMBAT_EVENT, REGISTER_FILTER_POWER_TYPE, POWERTYPE_ULTIMATE)
	EVENT_MANAGER:AddFilterForEvent(BSCUDP.Name, EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
		
	-- Ult gain basic LA/HA/BLOCK/ROLL
	local nCount = 1
	for FILTER, TYPE in pairs(ULT_GAIN_BASE_FILTERS) do	
		local eventName = BSCUDP.Name..'ULTACTION_'..nCount	
		EVENT_MANAGER:RegisterForEvent(eventName, EVENT_COMBAT_EVENT, OnCombatEventULTBASE)	
		EVENT_MANAGER:AddFilterForEvent(eventName, EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, FILTER, TYPE, COMBAT_UNIT_TYPE_PLAYER)
		nCount = nCount + 1
	end	
	--
	EVENT_MANAGER:RegisterForEvent(BSCUDP.Name, EVENT_PLAYER_COMBAT_STATE, 	OnCombatState)	
		
	EVENT_MANAGER:RegisterForUpdate(BSCUDP.Name, 200, UpdateUI)	

	BSCUDP:InitMenu()
	BSCUDP:UpdateEnableUP()
	BSCUDP:UpdateEnableBase()
	BSCUDP:UpdateSettings()
	BSCUDP:SetPosition()
end

EVENT_MANAGER:RegisterForEvent(BSCUDP.Name, EVENT_ADD_ON_LOADED, BSCUDP.init)