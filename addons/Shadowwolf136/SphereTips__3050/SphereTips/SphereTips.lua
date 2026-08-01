SphereTips = {}

local ST = SphereTips
ST.name = "SphereTips"


local maxSphereCount = 3 -- pretty sure it doesn't spawn any more after 3 but just in case

local barOutline = 2 -- probably won't change this but whatever

local isEventTrackerLoaded = false
local mostRecentSphereDeath = 0

local SphereMaxHP

local IDtoName = {}
local SphereData = {}

local FreeHpBars = {}
local UsedBarCount = 0


------------- SETTINGS FUNCTIONS -------------
function ST.ToggleUI()
	local state = not SphereTipsUI:IsHidden()
	SphereTipsUI:SetHidden(state)
	for i = 1, maxSphereCount, 1 do
		local backdrop = SphereTipsUI:GetNamedChild("backdrop"..i)
		backdrop:SetHidden(state)
	end
	
	local timerText = SphereTipsTimerUI:GetNamedChild("timerText")
	local timerBackdrop = SphereTipsTimerUI:GetNamedChild("backdrop")
	if state then -- ui was shown, hide it
		SphereTipsTimerUI:SetHidden(true)
		timerBackdrop:SetHidden(true)
		EVENT_MANAGER:UnregisterForUpdate("PreviewTimer")
		timerText:SetText("")
	else -- ui was hidden, show it
		SphereTipsTimerUI:SetHidden(false)
		timerBackdrop:SetHidden(false)
		local previewCounter = 8
		timerText:SetText(previewCounter.."s")
		
		EVENT_MANAGER:RegisterForUpdate("PreviewTimer", 1000, function() 
		
			previewCounter = previewCounter - 1
			
			if previewCounter > 0 then
				timerText:SetText(previewCounter.."s")
			else
				timerText:SetText("Sphere Spawning  "..(4 + previewCounter).."s")
			end
			
			if previewCounter <= -4 then
				EVENT_MANAGER:UnregisterForUpdate("PreviewTimer")
			end
		end)
	end
end


function ST.ResizeUI()
	for i = 1, maxSphereCount, 1 do
		local backdrop = SphereTipsUI:GetNamedChild("backdrop"..i)
		local bar = backdrop:GetNamedChild("bar")
		
		SphereTipsUI:SetDimensions(ST.SavedVars.barWidth + barOutline * 2, (ST.SavedVars.barHeight + barOutline * 2) * maxSphereCount  + ST.SavedVars.barOffset * (maxSphereCount - 1))
		backdrop:SetDimensions(ST.SavedVars.barWidth + barOutline * 2, ST.SavedVars.barHeight + barOutline * 2)
		bar:SetDimensions(ST.SavedVars.barWidth, ST.SavedVars.barHeight)
	end
end


function ST.OffsetBars()
	for i = 2, maxSphereCount, 1 do -- offsetbox1 does not exist because first bar is not offset
		local offsetbox = SphereTipsUI:GetNamedChild("offsetbox"..i)
		
		SphereTipsUI:SetDimensions(ST.SavedVars.barWidth + barOutline * 2, (ST.SavedVars.barHeight + barOutline * 2) * maxSphereCount  + ST.SavedVars.barOffset * (maxSphereCount - 1))
		offsetbox:SetDimensions(69, ST.SavedVars.barOffset)
	end
end


function ST.SetBarColor()
	for i = 1, maxSphereCount, 1 do
		local backdrop = SphereTipsUI:GetNamedChild("backdrop"..i)
		local bar = backdrop:GetNamedChild("bar")
		bar:SetColor(unpack(ST.SavedVars.barColor))
	end
end


function ST.SetHealthTextColor()
	for i = 1, maxSphereCount, 1 do
		local backdrop = SphereTipsUI:GetNamedChild("backdrop"..i)
		local text = backdrop:GetNamedChild("healthText")
		text:SetColor(unpack(ST.SavedVars.healthTextColor))
	end
end


function ST.SetHealthTextFont()
	for i = 1, maxSphereCount, 1 do
		local backdrop = SphereTipsUI:GetNamedChild("backdrop"..i)
		local text = backdrop:GetNamedChild("healthText")
		if ST.SavedVars.healthTextFontOutline:find("none") then
			text:SetFont(ST.FontData.Fonts[ST.SavedVars.healthTextFont].."|"..ST.SavedVars.healthTextFontSize)
		else
			text:SetFont(ST.FontData.Fonts[ST.SavedVars.healthTextFont].."|"..ST.SavedVars.healthTextFontSize.."|"..ST.SavedVars.healthTextFontOutline)
		end
	end
end


function ST.SetTimerColor()
	local timerText = SphereTipsTimerUI:GetNamedChild("timerText")
	timerText:SetColor(unpack(ST.SavedVars.timerColor))
end


function ST.SetTimerFont()
	local timerText = SphereTipsTimerUI:GetNamedChild("timerText")
	if ST.SavedVars.timerFontOutline:find("none") then
		timerText:SetFont(ST.FontData.Fonts[ST.SavedVars.timerFont].."|"..ST.SavedVars.timerFontSize)
	else
		timerText:SetFont(ST.FontData.Fonts[ST.SavedVars.timerFont].."|"..ST.SavedVars.timerFontSize.."|"..ST.SavedVars.timerFontOutline)
	end
end

function ST.RepackColor(colorList)
	local r, g, b = unpack(colorList)
	return {r = r, g = g, b = b}
end
------------- SETTINGS FUNCTIONS -------------



local function UpdateVisibility()
	for i = 1, maxSphereCount, 1 do
		local backdrop = SphereTipsUI:GetNamedChild("backdrop"..i)
		backdrop:SetHidden(FreeHpBars[i])
	end
	
	if UsedBarCount >= 1 then
		SphereTipsUI:SetHidden(false)
	else
		SphereTipsUI:SetHidden(true)
	end
end


local function ResetBar(targetBarId)
	local backdrop = SphereTipsUI:GetNamedChild("backdrop"..targetBarId)
	local bar = backdrop:GetNamedChild("bar")
	local text = backdrop:GetNamedChild("healthText")
	text:SetText("100%")
	bar:SetDimensions(ST.SavedVars.barWidth, ST.SavedVars.barHeight)
	FreeHpBars[targetBarId] = true
end


local function UpdateHpBar(targetId)
	local backdrop = SphereTipsUI:GetNamedChild("backdrop"..SphereData[targetId].barId)
	local bar = backdrop:GetNamedChild("bar")
	local text = backdrop:GetNamedChild("healthText")
	text:SetText(string.format("%.1f", (SphereMaxHP - SphereData[targetId].damageTaken) / SphereMaxHP * 100).."%")
	bar:SetDimensions(ST.SavedVars.barWidth * ((SphereMaxHP - SphereData[targetId].damageTaken) / SphereMaxHP), ST.SavedVars.barHeight)
	
	if ST.SavedVars.rainbowMode == true then
		bar:SetColor(math.random(), math.random(), math.random(), 1)
	end
end


local function ResetTimer()
	SphereTipsTimerUI:SetHidden(true)
	EVENT_MANAGER:UnregisterForUpdate("NextSphereTimer")
	local timerText = SphereTipsTimerUI:GetNamedChild("timerText")
	timerText:SetText("")
end


local function ClearTables()
	IDtoName = {}
	SphereData = {}
	UsedBarCount = 0
	for i = 1, maxSphereCount, 1 do
		ResetBar(i)
	end
	UpdateVisibility()
end


local function GetFreeHpBar()
	if ST.SavedVars.invertBarOrder == false then
		for i = 1, maxSphereCount, 1 do
			if FreeHpBars[i] == true then
				FreeHpBars[i] = false
				UsedBarCount = UsedBarCount + 1
				return i
			end
		end
	else
		for i = maxSphereCount, 1, -1 do
			if FreeHpBars[i] == true then
				FreeHpBars[i] = false
				UsedBarCount = UsedBarCount + 1
				return i
			end
		end
	end
end


local function OnUnitSpawn(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
	-- EVENT_COMBAT_EVENT filtered on ABILITY_ID 10298		boss spawn ability
	
	if hitValue == 1 then
		SphereData[targetUnitId] = {damageTaken = 0, spawnTime = GetGameTimeSeconds()}
	end
end


local function OnUnitDeath(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
	-- EVENT_COMBAT_EVENT filtered on COMBAT_RESULT 2260		ACTION_RESULT_DIED
	
	if SphereData[targetUnitId] ~= nil then
		if SphereData[targetUnitId].barId ~= nil then -- if it has a barId it must be a sphere
		
			ResetBar(SphereData[targetUnitId].barId)
			UsedBarCount = UsedBarCount - 1
			UpdateVisibility()
			
			if ST.SavedVars.killTimePrint == true then
				CHAT_SYSTEM:AddMessage("Sphere dead after ".. string.format("%.2f", tostring(GetGameTimeSeconds() - SphereData[targetUnitId].spawnTime)) .." seconds")
			end
			
			mostRecentSphereDeath = GetGameTimeSeconds()
			
			ResetTimer()
			if ST.SavedVars.showNextSphereTimer == true then
				SphereTipsTimerUI:SetHidden(false)
				local nextSphereCounter = 8
				
				local timerText = SphereTipsTimerUI:GetNamedChild("timerText")
				timerText:SetText(nextSphereCounter.."s")
				
				EVENT_MANAGER:RegisterForUpdate("NextSphereTimer", 1000, function()
					
					nextSphereCounter = nextSphereCounter - 1
					if nextSphereCounter > 0 then
						timerText:SetText(nextSphereCounter.."s")
					else
						timerText:SetText("Sphere Soon  "..(4 + nextSphereCounter).."s")
					end
					
					if nextSphereCounter <= -4 then
						ResetTimer()
					end
					
				end)
			end
		end
		
		SphereData[targetUnitId] = nil -- get rid of any unneeded data
		
	end
	
end


local function OnDamageDone(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
	-- EVENT_COMBAT_EVENT filtered on COMBAT_RESULT:
	-- 1			ACTION_RESULT_DAMAGE
	-- 2			ACTION_RESULT_CRITICAL_DAMAGE
	-- 1073741825	ACTION_RESULT_DOT_TICK
	-- 1073741826	ACTION_RESULT_DOT_TICK_CRITICAL
	
	if SphereData[targetUnitId] ~= nil then
		SphereData[targetUnitId].damageTaken = SphereData[targetUnitId].damageTaken + hitValue
		if SphereData[targetUnitId].barId ~= nil then
			UpdateHpBar(targetUnitId)
		end
	end
end


local function OnEffectChangedEvent(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)

	if IDtoName[unitId] == nil then -- originally used to check name of targetUnitId in COMBAT_EVENT, now used to make sure each enemy is only checked once
	
		IDtoName[unitId] = unitName
		
		if SphereData[unitId] ~= nil then -- identify what enemy the id is
			if unitName:find("Ordinated Protector^n") then -- sphere identified
				
				SphereData[unitId].barId = GetFreeHpBar()
				UpdateHpBar(unitId)
				UpdateVisibility()
				
				if SphereData[unitId].spawnTime > mostRecentSphereDeath then -- to make sure this timer doesn't override next sphere timer if this spawned before but got identified after the most recent sphere death
				
					ResetTimer()
					if ST.SavedVars.showPenaltySphereTimer == true and UsedBarCount < maxSphereCount then
						SphereTipsTimerUI:SetHidden(false)
						local penaltySphereCounter = 90 - math.floor(GetGameTimeSeconds() - SphereData[unitId].spawnTime + 0.5)
						
						local timerText = SphereTipsTimerUI:GetNamedChild("timerText")
						timerText:SetText(penaltySphereCounter.."s")
						
						EVENT_MANAGER:RegisterForUpdate("NextSphereTimer", 1000, function()
							
							penaltySphereCounter = penaltySphereCounter - 1
							timerText:SetText(penaltySphereCounter.."s")
							
							if penaltySphereCounter <= 0 then
								ResetTimer()
							end
							
						end)
					end
				end
				
			else -- id does not belong to a sphere
				SphereData[unitId] = nil -- clear out minis and spiders
			end
		end
	end
end


local function OnPlayerCombatStateChanged(eventCode, inCombat)

	if inCombat == false then -- player is taken out of combat state for a split second when ressed by someone else in combat
	
		zo_callLater(function()
		
			if IsUnitInCombat("boss1") == false then
				ClearTables()
				ResetTimer()
			end
		
		end, 2000)
	end
end


local function InitializeUI()
	local WM = GetWindowManager()
	------------- HEALTH BARS INITIALIZATION -------------
	local SphereTipsUI = WM:CreateTopLevelWindow("SphereTipsUI")
	SphereTipsUI:SetDimensions(ST.SavedVars.barWidth + barOutline * 2, (ST.SavedVars.barHeight + barOutline * 2) * maxSphereCount  + ST.SavedVars.barOffset * (maxSphereCount - 1))
    SphereTipsUI:SetMovable(not ST.SavedVars.isUIlocked)
    SphereTipsUI:SetMouseEnabled(not ST.SavedVars.isUIlocked)
	SphereTipsUI:SetHidden(true)
	SphereTipsUI:SetClampedToScreen(true)
	SphereTipsUI:SetHandler("OnMoveStop", function(control)
        ST.SavedVars.barXlocation = math.floor(SphereTipsUI:GetLeft())
	    ST.SavedVars.barYlocation  = math.floor(SphereTipsUI:GetTop())
    end)
	
	local barAnchor = SphereTipsUI
	
	for i = 1, maxSphereCount, 1 do
	
		FreeHpBars[i] = true
		local anchorLocation = BOTTOMLEFT
		
		if i == 1 then
			anchorLocation = TOPLEFT
		else
			local offsetbox = WM:CreateControl("$(parent)offsetbox"..i, SphereTipsUI, CT_BACKDROP)
			offsetbox:SetDimensions(69, ST.SavedVars.barOffset)
			offsetbox:SetAnchor(TOPLEFT, barAnchor, anchorLocation, 0, 0)
			offsetbox:SetHidden(true)
			
			barAnchor = offsetbox
		end
		
		local backdrop = WM:CreateControl("$(parent)backdrop"..i, SphereTipsUI, CT_BACKDROP)
		backdrop:SetDimensions(ST.SavedVars.barWidth + barOutline * 2, ST.SavedVars.barHeight + barOutline * 2)
		backdrop:SetAnchor(TOPLEFT, barAnchor, anchorLocation, 0, 0)
		backdrop:SetHidden(true)
		backdrop:SetDrawLayer(0)
		backdrop:SetEdgeTexture("", 1, 1, 2)
		backdrop:SetCenterColor(0, 0, 0, 0.5)
		backdrop:SetEdgeColor(0, 0, 0, 1)
		
		barAnchor = backdrop
		
		local bar = WM:CreateControl("$(parent)bar", backdrop, CT_TEXTURE)
		bar:SetDimensions(ST.SavedVars.barWidth, ST.SavedVars.barHeight)
		bar:SetColor(unpack(ST.SavedVars.barColor))
		bar:SetAnchor(TOPLEFT, backdrop, TOPLEFT, barOutline, barOutline)
		bar:SetTexture("")
		bar:SetHidden(false)
		bar:SetDrawLayer(1)
		
		local healthText = WM:CreateControl("$(parent)healthText", backdrop, CT_LABEL)
		healthText:SetText("100%")
		healthText:SetDimensions(200, 100)
		healthText:SetAnchor(CENTER, backdrop, CENTER, 0, 0)
		healthText:SetHorizontalAlignment(1)
		healthText:SetVerticalAlignment(1)
		healthText:SetHidden(false)
		
	end
	
	ST.SetHealthTextFont()
	ST.SetHealthTextColor()
	
	SphereTipsUI:ClearAnchors()
	SphereTipsUI:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, ST.SavedVars.barXlocation, ST.SavedVars.barYlocation)
	------------- HEALTH BARS INITIALIZATION -------------
	
	------------- TIMER INITIALIZATION -------------
	local SphereTipsTimerUI = WM:CreateTopLevelWindow("SphereTipsTimerUI")
	SphereTipsTimerUI:SetDimensions(200, 80)
	SphereTipsTimerUI:SetMovable(not ST.SavedVars.isUIlocked)
	SphereTipsTimerUI:SetMouseEnabled(not ST.SavedVars.isUIlocked)
	SphereTipsTimerUI:SetHidden(true)
	SphereTipsTimerUI:SetClampedToScreen(true)
	SphereTipsTimerUI:SetHandler("OnMoveStop", function(control)
        ST.SavedVars.timerXlocation = math.floor(SphereTipsTimerUI:GetLeft())
	    ST.SavedVars.timerYlocation  = math.floor(SphereTipsTimerUI:GetTop())
    end)
	
	local timerBackdrop = WM:CreateControl("$(parent)backdrop", SphereTipsTimerUI, CT_BACKDROP)
	timerBackdrop:SetDimensions(200, 80)
	timerBackdrop:SetAnchor(TOPLEFT, SphereTipsTimerUI, TOPLEFT, 0, 0)
	timerBackdrop:SetHidden(true)
	timerBackdrop:SetDrawLayer(0)
	timerBackdrop:SetEdgeTexture("", 1, 1, 2)
	timerBackdrop:SetCenterColor(0, 0, 0, 0)
	timerBackdrop:SetEdgeColor(0, 1, 0, 1)
	
	local timerText = WM:CreateControl("$(parent)timerText", SphereTipsTimerUI, CT_LABEL)
	timerText:SetText("")
	timerText:SetDimensions(600, 100)
	timerText:SetAnchor(TOPLEFT, SphereTipsTimerUI, TOPLEFT, 0, 0)
	timerText:SetHorizontalAlignment(0)
	timerText:SetVerticalAlignment(0)
	timerText:SetHidden(false)
	
	ST.SetTimerFont()
	ST.SetTimerColor()
	
	SphereTipsTimerUI:ClearAnchors()
	SphereTipsTimerUI:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, ST.SavedVars.timerXlocation, ST.SavedVars.timerYlocation)
	------------- TIMER INITIALIZATION -------------
	
end


local function InitializeCombatEvents()
	
	local difficulty = GetCurrentZoneDungeonDifficulty()
	if difficulty == 1 then -- 1 = DUNGEON_DIFFICULTY_NORMAL
		SphereMaxHP = 528102 -- Ordinated Protector health in normal
	elseif difficulty == 2 then -- 2 = DUNGEON_DIFFICULTY_VETERAN
		SphereMaxHP = 1078064 -- Ordinated Protector health in veteran
	end
	
	
	EVENT_MANAGER:RegisterForEvent("SphereTips_CombatEvent_UnitSpawn", EVENT_COMBAT_EVENT, OnUnitSpawn)
	EVENT_MANAGER:AddFilterForEvent("SphereTips_CombatEvent_UnitSpawn", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 10298) -- id of "boss" ability		twice on any spawn (llothis, felms, spheres, spiders)

	EVENT_MANAGER:RegisterForEvent("SphereTips_CombatEvent_UnitDeath", EVENT_COMBAT_EVENT, OnUnitDeath)
	EVENT_MANAGER:AddFilterForEvent("SphereTips_CombatEvent_UnitDeath", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, 2260) -- ACTION_RESULT_DIED
	
	EVENT_MANAGER:RegisterForEvent("SphereTips_CombatEvent_DirectDamage", EVENT_COMBAT_EVENT, OnDamageDone)
	EVENT_MANAGER:AddFilterForEvent("SphereTips_CombatEvent_DirectDamage", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, 1) -- ACTION_RESULT_DAMAGE
	EVENT_MANAGER:RegisterForEvent("SphereTips_CombatEvent_DirectDamage_Crit", EVENT_COMBAT_EVENT, OnDamageDone)
	EVENT_MANAGER:AddFilterForEvent("SphereTips_CombatEvent_DirectDamage_Crit", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, 2) -- ACTION_RESULT_CRITICAL_DAMAGE
	EVENT_MANAGER:RegisterForEvent("SphereTips_CombatEvent_DotTick", EVENT_COMBAT_EVENT, OnDamageDone)
	EVENT_MANAGER:AddFilterForEvent("SphereTips_CombatEvent_DotTick", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, 1073741825) -- ACTION_RESULT_DOT_TICK
	EVENT_MANAGER:RegisterForEvent("SphereTips_CombatEvent_DotTick_Crit", EVENT_COMBAT_EVENT, OnDamageDone)
	EVENT_MANAGER:AddFilterForEvent("SphereTips_CombatEvent_DotTick_Crit", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, 1073741826) -- ACTION_RESULT_DOT_TICK_CRITICAL
	
	EVENT_MANAGER:RegisterForEvent("SphereTips_EffectChangedEvent", EVENT_EFFECT_CHANGED, OnEffectChangedEvent)
	
	EVENT_MANAGER:RegisterForEvent("SphereTips_CombatStateTracker", EVENT_PLAYER_COMBAT_STATE, OnPlayerCombatStateChanged)
	
end


local function UnLoadCombatEvents()

	EVENT_MANAGER:UnregisterForEvent("SphereTips_CombatEvent_UnitSpawn", EVENT_COMBAT_EVENT)
	
	EVENT_MANAGER:UnregisterForEvent("SphereTips_CombatEvent_UnitDeath", EVENT_COMBAT_EVENT)

	EVENT_MANAGER:UnregisterForEvent("SphereTips_CombatEvent_DirectDamage", EVENT_COMBAT_EVENT)
	EVENT_MANAGER:UnregisterForEvent("SphereTips_CombatEvent_DirectDamage_Crit", EVENT_COMBAT_EVENT)
	EVENT_MANAGER:UnregisterForEvent("SphereTips_CombatEvent_DotTick", EVENT_COMBAT_EVENT)
	EVENT_MANAGER:UnregisterForEvent("SphereTips_CombatEvent_DotTick_Crit", EVENT_COMBAT_EVENT)
	
	EVENT_MANAGER:UnregisterForEvent("SphereTips_EffectChangedEvent", EVENT_EFFECT_CHANGED)
	
	EVENT_MANAGER:UnregisterForEvent("SphereTips_CombatStateTracker", EVENT_PLAYER_COMBAT_STATE)
end


local function OnZoneChanged()
	if GetPlayerActiveZoneName():find("Asylum Sanctorium") then
		if isEventTrackerLoaded == false then
			isEventTrackerLoaded = true
			
			InitializeCombatEvents()
		end
	else
		if isEventTrackerLoaded == true then
			isEventTrackerLoaded = false
			
			ClearTables()
			ResetTimer()
			UnLoadCombatEvents()
		end
	end
end


function OnAddOnLoaded(event, addonName)
    if addonName ~= ST.name then return end
    EVENT_MANAGER:UnregisterForEvent(ST.name, EVENT_ADD_ON_LOADED)
	
	ST.defaults = {
		
		barWidth = 200,
		barHeight = 30,
		barXlocation = 1800,
		barYlocation = 400,
		isUIlocked = true,
		barOffset = 20,
		invertBarOrder = false,
		barColor = {0.8, 0, 0},
		killTimePrint = false,
		timerXlocation = 1800,
		timerYlocation = 300,
		showNextSphereTimer = true,
		showPenaltySphereTimer = false,
		rainbowMode = false,
		timerColor = {1, 1, 1},
		timerFont = "Univers 67",
		timerFontSize = "26",
		timerFontOutline = "soft-shadow-thick",
		healthTextColor = {1, 1, 1},
		healthTextFont = "Univers 67",
		healthTextFontSize = "20",
		healthTextFontOutline = "soft-shadow-thick",
	}
	
	ST.SavedVars = ZO_SavedVars:NewAccountWide("SphereTipsSV", 1, nil, ST.defaults)
	
	
	CALLBACK_MANAGER:RegisterCallback("OnWorldMapChanged", OnZoneChanged)
	
	InitializeUI()
	SphereTips_LoadSettings()
end

EVENT_MANAGER:RegisterForEvent(ST.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)