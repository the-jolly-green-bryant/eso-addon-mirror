BSCExecute = BSCExecute or {}
local BSCEC = BSCExecute
local BSCECUI = BSCExecute

BSCEC.Name = "BSCs-Execute"
BSCEC.NameSpaced = "BSCs Execute"
BSCEC.Author = "@BloodStainChild666"
BSCEC.DisplayVersion = "2.0.2"
BSCEC.Version = 1
BSCEC.SavedVar = "BSCECSaved"
BSCEC.bUIisHidden = true

default_setting = 
{
	Left = nil,
	Top = nil,
	Scale = 2,
	Alpha = 0.8,
	ExecuteP = 25,
	-- color
	textcolor_r = 255,
	textcolor_g = 0,
	textcolor_b = 0,
	textcolor_a = 255,
	--
	bEnableText = true,
	bEnableIcon = true,
	bOnlyDD = true,
	--
	MSShow = 0, -- time to show
	bShowAgainOnChange = false,
	sExecuteTxT = "Execute!",
	SkillExecuteValues = { },
	MinDifficulty = MONSTER_DIFFICULTY_NONE,
}

local HOTBAR_CATEGORY_SET =
{
    [HOTBAR_CATEGORY_PRIMARY] = true,
    [HOTBAR_CATEGORY_BACKUP] = true,
}

BSCEC.ActiveSkills = {}
BSCEC.ActiveSkillList = {}

function BSCEC:CheckHotbar()
    BSCEC.ActiveSkills = {}
    BSCEC.ActiveSkillList = {}
	for hotbarCategory in pairs(HOTBAR_CATEGORY_SET) do
		if HOTBAR_CATEGORY_SET[hotbarCategory] then
			local hotbar = ACTION_BAR_ASSIGNMENT_MANAGER:GetHotbar(hotbarCategory)
			if hotbar ~= nil then 
				 for actionSlotIndex, slotData in hotbar:SlotIterator() do
					if slotData:IsStillValid() then
						local skilldata = slotData:GetPlayerSkillData()
						if skilldata ~= nil then
							if skilldata:IsActive() then
								local actionId = slotData:GetActionId()
								if skilldata:IsCraftedAbility() then
									local name = zo_strformat("<<1>>", skilldata.skillProgressionData:GetName())
									BSCEC.ActiveSkills[actionId] = name
									table.insert(BSCEC.ActiveSkillList, name)
								else
									if actionId and actionId > 0 then
										local name = zo_strformat("<<1>>", GetAbilityName(actionId))
										BSCEC.ActiveSkills[actionId] = name
										table.insert(BSCEC.ActiveSkillList, name)
									end
								end
							end
						end
					end
				 end
			end
		end
	end
    if BSCEC_SkillsDropdown then
        BSCEC_SkillsDropdown:UpdateChoices(BSCEC.ActiveSkillList)
    end
	if BSCEC_SavedSkillsList then
		BSCEC_SavedSkillsList:UpdateValue()
	end
end

function BSCEC:GetListNames()
	return BSCEC.ActiveSkillList
end

local function GetCurrentExecuteThreshold()
    local threshold = BSCEC.SV_acc.ExecuteP
    for skillId, _ in pairs(BSCEC.ActiveSkills) do
        local value = BSCEC.SV_acc.SkillExecuteValues[skillId]
        if value and value < threshold then
            threshold = value
        end
    end
    return threshold
end

-------------------------------------------------------------------------------------------------
-- UI 
-------------------------------------------------------------------------------------------------
function BSCEC.OnMoveStop()
	BSCEC.SV_acc.Left = BSCECUI:GetLeft()
	BSCEC.SV_acc.Top = BSCECUI:GetTop()
end

function BSCEC.RestorePosition()
	if BSCEC.SV_acc.Left and BSCEC.SV_acc.Top then
		BSCECUI:ClearAnchors()
		BSCECUI:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, BSCEC.SV_acc.Left, BSCEC.SV_acc.Top)
	end
	BSCECUI:SetScale(BSCEC.SV_acc.Scale)
	BSCECUI:SetAlpha(BSCEC.SV_acc.Alpha)
end

function BSCEC.UpdateUI()
	local ecicon = BSCECUI:GetNamedChild("ECIcon")
	local ectext = BSCECUI:GetNamedChild("Label")
	
	if BSCEC.SV_acc.bEnableIcon == true then
		ecicon:SetHidden(false)
	else
		ecicon:SetHidden(true)
	end
	if BSCEC.SV_acc.bEnableText == true then
		ectext:SetHidden(false)
		ectext:SetColor(BSCEC.SV_acc.textcolor_r, BSCEC.SV_acc.textcolor_g, BSCEC.SV_acc.textcolor_b)
		ectext:SetText(BSCEC.SV_acc.sExecuteTxT)
	else
		ectext:SetHidden(true)
	end	
end 

function BSCEC.HideUI()
    BSCECUI:SetHidden(true)
	BSCEC.bUIisHidden = true
	if BSCEC.SV_acc.MSShow > 0 then
		EVENT_MANAGER:UnregisterForUpdate("BSCExecute_UI")
	end
end

function BSCEC.ShowUI()
	if BSCEC.bUIisHidden == false then return end
	if BSCEC.SV_acc.bOnlyDD and GetSelectedLFGRole() ~= LFG_ROLE_DPS then return end

	BSCECUI:SetHidden(false)
	BSCEC.bUIisHidden = false
	
	if BSCEC.SV_acc.MSShow > 0 then
		EVENT_MANAGER:RegisterForUpdate("BSCExecute_UI", (BSCEC.SV_acc.MSShow * 1000), BSCEC.HideUI)
	end
end

-------------------------------------------------------------------------------------------------
-- events
-------------------------------------------------------------------------------------------------
local sTargedName = ""
function BSCEC.OnPlayerCombatState(eventCode, inCombat)
	if inCombat then		
		sTargedName = ""
	else
		BSCEC.HideUI()
		sTargedName = ""
	end
end

function BSCEC.OnReticleTargetChange(eventCode)
	if BSCEC.SV_acc.bShowAgainOnChange == false and BSCEC.SV_acc.MSShow > 0 then return end
	local difficulty = GetUnitDifficulty("reticleover")
    if difficulty < BSCEC.SV_acc.MinDifficulty then
        BSCEC.HideUI()
        return
    end

	local currentHP, maxHP, effectiveMaxHP = GetUnitPower("reticleover", POWERTYPE_HEALTH)
	local percentHP = math.floor((currentHP * 100 ) / maxHP)	
	local threshold = GetCurrentExecuteThreshold()
	
	if percentHP ~= 0 and percentHP <= threshold then
		BSCEC.ShowUI()
	else
		BSCEC.HideUI()
	end
end

function BSCEC.OnPowerUpdate(eventCode, unitTag, powerIndex, powerType, currentHP, maxHP, effectiveMaxHP)		
	local difficulty = GetUnitDifficulty("reticleover")
	if difficulty < BSCEC.SV_acc.MinDifficulty then
		BSCEC.HideUI()
		return
	end
	
	local percentHP = math.floor((currentHP * 100 ) / maxHP)		
	local sTName = GetUnitName("reticleover")
	local threshold = GetCurrentExecuteThreshold()
	if percentHP >= 1 and percentHP <= threshold and sTName ~= sTargedName then	
		sTargedName = sTName
		BSCEC.ShowUI()
	end
end

function BSCEC.OnPlayerActivated()	
    EVENT_MANAGER:UnregisterForEvent(BSCEC.Name, EVENT_PLAYER_ACTIVATED)
	BSCEC:CheckHotbar()
end

-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////// --- Init -- //////////////////////////////////////////////////////
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function BSCEC.init(event, addonName)	
	if addonName ~= BSCEC.Name then 		
		return 
	end			
	EVENT_MANAGER:UnregisterForEvent(BSCEC.Name, 	EVENT_ADD_ON_LOADED)
	--
	BSCEC.SV_acc = ZO_SavedVars:NewAccountWide(BSCEC.SavedVar, BSCEC.Version, nil, default_setting)
	if not BSCEC.SV_acc.SkillExecuteValues then
		BSCEC.SV_acc.SkillExecuteValues = {}
	end
	BSCEC:CheckHotbar()
	
	BSCEC.RestorePosition()
	BSCEC.UpdateUI()
	
	-- Command
	BSCEC.buildMenu()
	
	EVENT_MANAGER:RegisterForEvent(BSCEC.Name.."OnPlayerCombatState", EVENT_PLAYER_COMBAT_STATE, BSCEC.OnPlayerCombatState)	
	EVENT_MANAGER:RegisterForEvent(BSCEC.Name.."OnReticleTargetChange", EVENT_RETICLE_TARGET_CHANGED, BSCEC.OnReticleTargetChange)
    EVENT_MANAGER:RegisterForEvent(BSCEC.Name.."OnPowerUpdate",  EVENT_POWER_UPDATE, BSCEC.OnPowerUpdate)
    EVENT_MANAGER:AddFilterForEvent(BSCEC.Name.."OnPowerUpdate", EVENT_POWER_UPDATE, REGISTER_FILTER_POWER_TYPE, POWERTYPE_HEALTH)
	EVENT_MANAGER:AddFilterForEvent(BSCEC.Name.."OnPowerUpdate", EVENT_POWER_UPDATE, REGISTER_FILTER_UNIT_TAG, "reticleover")
	
	EVENT_MANAGER:RegisterForEvent(BSCEC.Name, EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED, function() BSCEC:CheckHotbar() end)
	
	
	--
	EVENT_MANAGER:RegisterForEvent(BSCEC.Name,    			EVENT_PLAYER_ACTIVATED,         BSCEC.OnPlayerActivated)
end

EVENT_MANAGER:RegisterForEvent(BSCEC.Name, EVENT_ADD_ON_LOADED, BSCEC.init)
