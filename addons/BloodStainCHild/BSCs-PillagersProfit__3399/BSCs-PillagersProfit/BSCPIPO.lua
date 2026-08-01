BSCPillagers = BSCPillagers or {}
local BSCPIPO = BSCPillagers

BSCPIPO.Name = "BSCs-PillagersProfit"
-- AddonInfo
BSCPIPO.NameMenu = "BSCs-Pillagers Profit"
BSCPIPO.NameSpaced = "PillagersProfit"
BSCPIPO.Author = "@BloodStainChild666"
BSCPIPO.SavedVar = "BSCPPROSaved"
BSCPIPO.VersionDisplay = "2.1.0"

local CDPillagersProfitID = 172056
local CryptCannonSKILLLID = 195031
local SKILL_IDS = {
	[CDPillagersProfitID] = true,
	[CryptCannonSKILLLID] = true,
}

local PillagersProfitRange = 12
local CryptCannonRange = 28

local bActive = false
local BuffStartTime = 0
local PlayerCount = 0

local bAddonActive = false
local bAddonDebug = false
BSCPIPO.DebugCombat = false -- /script BSCPillagers.DebugCombat

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Check Armor
local NormalSetID = 649		-- Pillagers Profit
local PerfectSetID = 650	-- Pillagers Profit
local bPP = false
local KryptCannonSetID = 691	-- CryptCannon
local bKC = false
--https://esoapi.uesp.net/current/src/publicallingames/tooltip/itemtooltips.lua.html
local function CheckEquipment()
	local SIC_PP = 0
	local SIC_KC = 0
	for equipSlot = EQUIP_SLOT_ITERATION_BEGIN, EQUIP_SLOT_ITERATION_END do		
		if HasItemInSlot(BAG_WORN, equipSlot) then		
			local itemtype = GetItemType(BAG_WORN, equipSlot)			
			if itemtype == ITEMTYPE_ARMOR or itemtype == ITEMTYPE_WEAPON then
				local count = 1
				if itemtype == ITEMTYPE_WEAPON then 
					--local equipType = 
					if select(6, GetItemInfo(BAG_WORN, equipSlot)) == EQUIP_TYPE_TWO_HAND then
						count = 2 
					end
				end
				local setId = select(6, GetItemLinkSetInfo(GetItemLink(BAG_WORN, equipSlot)))
				if setId == NormalSetID or setId == PerfectSetID then
					SIC_PP = SIC_PP + count
				end
				if setId == KryptCannonSetID then
					SIC_KC = SIC_KC + count
				end
				if bAddonDebug then
					local hasSet, setName, numBonuses, numEquipped, maxEquipped, setId_1 = GetItemLinkSetInfo( GetItemLink(BAG_WORN, equipSlot), true)			
					d( "Slot["..equipSlot.."] - Name["..GetItemName(BAG_WORN, equipSlot).."] - Type["..GetItemType(BAG_WORN, equipSlot).."] - setName["..setName.."] - Bonus["..numBonuses.."] - Equip["..numEquipped.."/"..maxEquipped.."] - SetID["..setId_1.."]" )
				end				
			end
		end
	end	
	if BSCPIPO.SV_ACC.ENABLED then 
		bPP = true
		bKC = false
		bAddonActive = true
		BSCPillagersUI:SetHidden(false)
		BSCPillagersUI:GetNamedChild("Icon"):SetTexture("esoui/art/icons/ability_healer_030.dds")	
		return
	end		
	if SIC_KC >= 1 then
		bPP = false
		bKC = true
		bAddonActive = true
		BSCPillagersUI:SetHidden(false)		
		BSCPillagersUI:GetNamedChild("Icon"):SetTexture("esoui/art/icons/u38_ability_armor_ultimatetransfer.dds")
	elseif SIC_PP >= 5 then
		bPP = true
		bKC = false
		bAddonActive = true
		BSCPillagersUI:SetHidden(false)		
		BSCPillagersUI:GetNamedChild("Icon"):SetTexture("esoui/art/icons/ability_healer_030.dds")		
	else 
		bPP = false
		bKC = false
		bAddonActive = false
		BSCPillagersUI:SetHidden(true)
	end	
end
local function OnCombatEvent( _, result, _, _, _, _, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow )
	if not bAddonActive then return end
	if abilityId == CDPillagersProfitID and not bPP then return end
	if abilityId == CryptCannonSKILLLID and not bKC then return end
	if result == ACTION_RESULT_EFFECT_GAINED  then		
		if BSCPIPO.SV_ACC.OMCD and sourceType ~= COMBAT_UNIT_TYPE_PLAYER then return end
		
		bActive = true		
		BuffStartTime = (GetGameTimeMilliseconds()/1000)+(GetAbilityDuration(abilityId)/1000)
	end
	if BSCPIPO.DebugCombat then
		d(zo_strformat("CE abilityId[<<1>>] AbilityName[<<2>>] result[<<3>>] targetUnitId[<<4>>] sourceUnitId[<<5>>]", abilityId, GetAbilityName(abilityId), result, targetUnitId, sourceUnitId))
		d(zo_strformat("CE sourceName[<<1>>] sourceType[<<2>>] targetName[<<3>>] targetType[<<4>>] hitValue[<<5>>]", sourceName, sourceType, targetName, targetType, hitValue))
	end
end
local function GetDistance( unitTag1, unitTag2, useHeight )
	local zone1, x1, y1, z1 = GetUnitWorldPosition(unitTag1)
	local zone2, x2, y2, z2 = GetUnitWorldPosition(unitTag2)

	if (zone1 == 0 or zone1 ~= zone2) then
		return(-1)
	elseif (useHeight) then
		return(zo_sqrt((x1 - x2)^2 + (y1 - y2)^2 + (z1 - z2)^2) / 100)
	else
		return(zo_sqrt((x1 - x2)^2 + (z1 - z2)^2) / 100)
	end
end
local function CheckUnit(unitTag)
	if not IsUnitPlayer(unitTag) then 
		return false
	elseif not IsUnitOnline(unitTag) then
		return false
	elseif not IsUnitInGroupSupportRange(unitTag) then
		return false
	elseif IsUnitDead(unitTag) then 
		return false
	elseif IsUnitBeingResurrected(unitTag) then  
		return false
	elseif DoesUnitHaveResurrectPending(unitTag) then 
		return false
	elseif IsUnitReincarnating(unitTag) then 
		return false
	elseif IsUnitResurrectableByPlayer(unitTag) then
		return false
	else
		return true
	end
	return true
end
local function BSCPlaySound(soundname)
	if not BSCPIPO.SV_ACC.bPlaySound then return end
	PlaySound(soundname)
end
-- Get Nearby Players Count 12 Meters
local function UpdateForPP()
	PlayerCount = 0
	local dist = 0
	local DURATION = 0
	if IsUnitGrouped('player') then
		for i = 1, GetGroupSize() do
			local unitTag = GetGroupUnitTagByIndex(i)
			if unitTag then
				if CheckUnit(unitTag) then 
					if i ~= GetGroupIndexByUnitTag('player') then
						dist = GetDistance('player', unitTag, false)
						if dist <= PillagersProfitRange then
							PlayerCount = PlayerCount + 1
						end
					end
				end
			end
		end
	end
	
	DURATION = BuffStartTime - (GetGameTimeMilliseconds()/1000)
	if DURATION <= 0 then 
		DURATION = 0
		if bActive then
			BSCPlaySound(SOUNDS.BATTLEGROUND_MATCH_WON)
		end
		bActive = false
	end			
	local LB = BSCPillagersUI:GetNamedChild("Info")
	local BF = BSCPillagersUI:GetNamedChild("FrameBack")
	local UF = BSCPillagersUI:GetNamedChild("UltiInfo")
	local PI = BSCPillagersUI:GetNamedChild("PlayerInfo")		
	local ultig = 0
	if GetAPIVersion() >= 101046 then	
		local ultpersec = (GetUnitPower('player', POWERTYPE_ULTIMATE) / 100 * 2)
		ultig = ultpersec * 5
		if ultig >= 50 then
			UF:SetColor(0, 1, 0, 1)
		else
			UF:SetColor(1, 0, 0, 1)	
		end
	else
		local ultpersec = (GetUnitPower('player', POWERTYPE_ULTIMATE) / 100 * 5)
		if ultpersec >= 20 then
			ultpersec = 20
		end	
		ultig = ultpersec * 5
		if ultig >= 100 then
			UF:SetColor(0, 1, 0, 1)
		else
			UF:SetColor(1, 0, 0, 1)	
		end
	end
	UF:SetText("Ult Gain: "..string.format("%.0f", ultig))		
	LB:SetText(string.format("%.0f", DURATION))
	PI:SetText(PlayerCount)		
	if bActive then -- set Cooldown
		LB:SetColor(1, 0, 0, 1)
		BF:SetCenterColor(1, 0, 0, 1)
	else -- Set Player Count
		LB:SetColor(0, 1, 0, 1)				
		BF:SetCenterColor(0, 1, 0, 1)
	end
end
local function UpdateForCK()
	PlayerCount = 0
	local dist = 0
	local DURATION = 0
	if IsUnitGrouped('player') then
		for i = 1, GetGroupSize() do
			local unitTag = GetGroupUnitTagByIndex(i)
			if unitTag then
				if CheckUnit(unitTag) then 
					if i ~= GetGroupIndexByUnitTag('player') then
						dist = GetDistance('player', unitTag, false)
						if dist <= CryptCannonRange then
							PlayerCount = PlayerCount + 1
						end
					end
				end
			end
		end
	end
	DURATION = BuffStartTime - (GetGameTimeMilliseconds()/1000)
	if DURATION <= 0 then 
		DURATION = 0
		bActive = false
	end			
	local LB = BSCPillagersUI:GetNamedChild("Info")
	local BF = BSCPillagersUI:GetNamedChild("FrameBack")
	local UF = BSCPillagersUI:GetNamedChild("UltiInfo")
	local PI = BSCPillagersUI:GetNamedChild("PlayerInfo")	
	local ultig = zo_round(GetUnitPower('player', POWERTYPE_ULTIMATE) / GetGroupSize())
	if ultig >= zo_round(500 / GetGroupSize()) then
		UF:SetColor(0, 1, 0, 1)
	else
		UF:SetColor(1, 0, 0, 1)	
	end
	if PlayerCount == 0 then
		UF:SetText("Ult Gain: "..string.format("%.0f", 0))		
	else 
		UF:SetText("Ult Gain: "..string.format("%.0f", ultig))		
	end
	LB:SetText(string.format("%.0f", DURATION))
	PI:SetText(PlayerCount)		
	if bActive then -- set Cooldown
		LB:SetColor(1, 0, 0, 1)
		BF:SetCenterColor(1, 0, 0, 1)
	else -- Set Player Count
		LB:SetColor(0, 1, 0, 1)				
		BF:SetCenterColor(0, 1, 0, 1)
	end
end
local function UpdateUI()
	if not bAddonActive then return end	
	if bPP then 
		UpdateForPP()
	elseif bKC then 
		UpdateForCK()
	end	
end
local function ToggleUI(oldState, newState)
	if bAddonActive then 
		if newState == SCENE_SHOWN then
			BSCPillagersUI:SetHidden(false)
		elseif newState == SCENE_HIDDEN then
			BSCPillagersUI:SetHidden(true)
		end
	end
end
local function SlashCommand(text)
	local ftext = zo_strlower(text)
	if ftext == 'debug' then
		if not bAddonActive then
			bAddonActive = true
			bAddonDebug = true
			BSCPillagersUI:SetHidden(false)
		else 
			bAddonActive = false
			bAddonDebug = false
			BSCPillagersUI:SetHidden(true)
		end	
	elseif ftext == 'test' then
		if bActive then
			bActive = false	
		else
			bActive = true		
			BuffStartTime = (GetGameTimeMilliseconds()/1000) + (GetAbilityDuration(CDPillagersProfitID)/1000)
		end
	else
		CheckEquipment()
	end	
end	
local function OnPlayerActivated()	
	CheckEquipment()
end
function BSCPIPO:OnMoveStop()
	BSCPIPO.SV_ACC.UI_LEFT = BSCPillagersUI:GetLeft()
	BSCPIPO.SV_ACC.UI_TOP = BSCPillagersUI:GetTop()
end
function BSCPIPO:SetPosition()
	if BSCPIPO.SV_ACC.UI_LEFT ~= -250 and BSCPIPO.SV_ACC.UI_TOP ~= 0 then
		BSCPillagersUI:ClearAnchors()
		BSCPillagersUI:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, BSCPIPO.SV_ACC.UI_LEFT, BSCPIPO.SV_ACC.UI_TOP)
	end
	BSCPillagersUI:SetMovable(not BSCPIPO.SV_ACC.LOCK_UI)
	BSCPillagersUI:SetAlpha(BSCPIPO.SV_ACC.UI_ALPHA)
	CheckEquipment()
end
local defaultSV_ACC = {	
	UI_LEFT = -250,
	UI_TOP  = 0,
	UI_ALPHA = 1,
	LOCK_UI = false,
	bPlaySound = false,
	OMCD = false,
}
function BSCPIPO.init(event, addonName)	
	if addonName ~= BSCPIPO.Name then
		return 
	end
	EVENT_MANAGER:UnregisterForEvent(BSCPIPO.Name, 	EVENT_ADD_ON_LOADED)
	-- Command
	SLASH_COMMANDS['/bscpipo'] = SlashCommand
	--
	BSCPIPO.SV_ACC = ZO_SavedVars:NewAccountWide(BSCPIPO.SavedVar, 1, nil, defaultSV_ACC)	
	BSCPIPO:InitMenu()
	BSCPIPO:SetPosition()
	--
	EVENT_MANAGER:RegisterForEvent(BSCPIPO.Name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
	-- Hide on opening menu
	SCENE_MANAGER:GetScene("hud"):RegisterCallback("StateChange", ToggleUI)
	SCENE_MANAGER:GetScene("hudui"):RegisterCallback("StateChange", ToggleUI)
	-- Combat Events
	for abilityId in pairs(SKILL_IDS) do	
		local eventName = 'BSCPIPO_CE'..abilityId			
		EVENT_MANAGER:RegisterForEvent(eventName,  EVENT_COMBAT_EVENT, OnCombatEvent)
		EVENT_MANAGER:AddFilterForEvent(eventName, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, abilityId)	
	end		
	-- 
	EVENT_MANAGER:RegisterForEvent(BSCPIPO.Name, EVENT_INVENTORY_FULL_UPDATE, function(...) CheckEquipment() end )
	EVENT_MANAGER:AddFilterForEvent(BSCPIPO.Name, EVENT_INVENTORY_FULL_UPDATE, REGISTER_FILTER_BAG_ID, BAG_WORN)
	EVENT_MANAGER:AddFilterForEvent(BSCPIPO.Name, EVENT_INVENTORY_FULL_UPDATE, REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DEFAULT)
	--
	EVENT_MANAGER:RegisterForEvent(BSCPIPO.Name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function(...) CheckEquipment() end )	
	EVENT_MANAGER:AddFilterForEvent(BSCPIPO.Name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_WORN)
	EVENT_MANAGER:AddFilterForEvent(BSCPIPO.Name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DEFAULT)	
	--
	EVENT_MANAGER:RegisterForUpdate(BSCPIPO.Name, 200, UpdateUI)
end
EVENT_MANAGER:RegisterForEvent(BSCPIPO.Name, EVENT_ADD_ON_LOADED, BSCPIPO.init)
