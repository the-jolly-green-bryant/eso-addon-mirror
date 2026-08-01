--[[
This Add-on is not created by, affiliated with or sponsored by ZeniMax Media Inc. or its affiliates. 
The Elder Scrolls® and related logos are registered trademarks or trademarks of ZeniMax Media Inc. in the United States and/or other countries. 
All rights reserved

You can read the full terms at https://account.elderscrollsonline.com/add-on-terms]]

--[[
Acknowledgments

A VERY SPECIAL thanks to Sempiternal Way guild (NA).

I'd like to thank the following people for helping me, either with testing or giving me ideas:
- @ChaosFractal
- @SeaUnicorn
- @Ce-Nex
- @Skittle
- @gracefully_lyris

Thanks to the following for the test run:
- @Kwix
- @Inarre
- @FrozenCrab
- @Ikael
- @Nezzzy
- @Nimnitz
- @D-oboe94
- @MasAmedda

Thanks to the following addons, I learned a lot from examining their code:
- Asylum Tracker by init3
]]

-- Initialized the addon names
CloudrestMiniHelper = {}
CloudrestMiniHelper.name = "CloudrestMiniHelper"
CloudrestMiniHelper.panelName = "Cloudrest_Mini_Helper"
CloudrestMiniHelper.version = 1.1

-- For the addon settings menu
CloudrestMiniHelper.LAM2 = LibAddonMenu2

-- Initializes various things; variables aptly named
CloudrestMiniHelper.isInCR = false
CloudrestMiniHelper.bashTimer = 2

CloudrestMiniHelper.siroria = {
	jumpTimestamp = 0,
	bashTimestamp = 0,
	skillTimestamp = 0,
	timeBetweenJump = 20,
	timeBetweenBash = 0, -- Siroria doesn't have interrupt
	timeBetweenSkill = 43,
	up = false,
	interrupted = false,
	jumpTime = 6,
	bashTime = 0,
	skillTime = 2,
	deathTimestamp = 0
}

CloudrestMiniHelper.galenwe = {
	jumpTimestamp = 0,
	bashTimestamp = 0,
	skillTimestamp = 0,
	timeBetweenJump = 19,
	timeBetweenBash = 18 + CloudrestMiniHelper.bashTimer, -- 18 + however much the ok timer is
	timeBetweenSkill = 21,
	up = false,
	interrupted = false,
	jumpTime = 5,
	bashTime = 3,
	skillTime = 2,
	deathTimestamp = 0
}

CloudrestMiniHelper.relequen = {
	jumpTimestamp = 0,
	bashTimestamp = 0,
	skillTimestamp = 0,
	timeBetweenJump = 17,
	timeBetweenBash = 17,
	timeBetweenSkill = 15,
	up = false,
	interrupted = false,
	jumpTime = 4,
	bashTime = 3,
	skillTime = 5,
	deathTimestamp = 0
}

-- Saved beyond session variables
CloudrestMiniHelper.accountWideDefaults={
	accountWide=false
}

CloudrestMiniHelper.defaults={
	unlocked=true,
	displayLeft=0,
	displayTop=0,
	trackJump=true,
	trackBash=true,
	trackSkill=true
}

CloudrestMiniHelper.siroriaJump = { -- Fiery Crash
	[106601] = true
}

CloudrestMiniHelper.siroriaSkill = { -- Standard of Might
	[104902] = true
}

CloudrestMiniHelper.galenweJump = { -- Icy Teleport
	[106682] = true
}

CloudrestMiniHelper.galenweBash = { -- Glacial Spikes
	[106405] = true
}

CloudrestMiniHelper.galenweSkill = { -- Icy Cage
	[106378] = true
}

CloudrestMiniHelper.relequenJump = { -- Flux Burst
	[105796] = true
}

CloudrestMiniHelper.relequenBash = { -- Direct Current
	[105380] = true
}

function CloudrestMiniHelper:Initialize()
	EVENT_MANAGER:RegisterForEvent(CloudrestMiniHelper.name, EVENT_PLAYER_ACTIVATED, CloudrestMiniHelper.OnPlayerActivated)
end

-- Loads the addon; only hit once
function CloudrestMiniHelper.OnAddOnLoaded(event, addonName)
	-- The event fires each time *any* addon loads; but we only care about when our own addon loads.
	if addonName ~= CloudrestMiniHelper.name then
		return
	end

	EVENT_MANAGER:UnregisterForEvent(CloudrestMiniHelper.name, EVENT_ADD_ON_LOADED)
	
	CloudrestMiniHelper.DS = ZO_SavedVars:NewAccountWide("CloudrestMiniHelperTrackerSettings", 1.0, "AccountWide", CloudrestMiniHelper.accountWideDefaults)

	if CloudrestMiniHelper.DS.accountWide then
		CloudrestMiniHelper.SV = ZO_SavedVars:NewAccountWide("CloudrestMiniHelperTrackerSettings", 1.0, "Settings", CloudrestMiniHelper.defaults)
	else
		CloudrestMiniHelper.SV = ZO_SavedVars:NewCharacterIdSettings("CloudrestMiniHelperTrackerSettings", 1.0, "Settings", CloudrestMiniHelper.defaults)
	end
	
	CloudrestMiniHelper:InitializeAddonMenu()
	CloudrestMiniHelper:Initialize()
	CloudrestMiniHelper:InitControls()
end

function CloudrestMiniHelper.OnEffectChanged(eventCode, changeType, eSlot, eName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, aType, statusEffectType, unitName, uId, abilityId, sourceUnitType)
	CloudrestMiniHelper.UpdateMiniStatus(unitName, abilityId)
end

function CloudrestMiniHelper.OnCombat(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
	CloudrestMiniHelper.UpdateAbilities(result, abilityId)
end

-- Side Bosses
function CloudrestMiniHelper.OnUnitDeathStateChanged(eventCode, unitTag, isDead)
	if isDead == false then
		return
	end
	
	if unitTag:find("player") or unitTag:find("group") then
		local isAllDead = true

		for i = 1, GetGroupSize() do
			local tag = GetGroupUnitTagByIndex(i)

			if IsUnitDead(tag) == false then
				isAllDead = false
			end
		end
		
		if isAllDead == true then
			CloudrestMiniHelper.ResetAll()
		end
		
		return
	end
	
	local unitName = GetUnitName(unitTag)

	if unitName:find("Siroria") then
		CloudrestMiniHelper.ResetMini(CloudrestMiniHelper.siroria)
	elseif unitName:find("Galenwe") then
		CloudrestMiniHelper.ResetMini(CloudrestMiniHelper.galenwe)
	elseif unitName:find("Relequen") then
		CloudrestMiniHelper.ResetMini(CloudrestMiniHelper.relequen)
	end
end

function CloudrestMiniHelper.OnPlayerActivated(eventCode, initial)
	if GetUnitZone("player") == GetZoneNameById(1051) then
		CloudrestMiniHelper.isInCR = true
	else
		CloudrestMiniHelper.isInCR = false
	end
	
	CloudrestMiniHelper:OnOff()
	CloudrestMiniHelper.ResetAll()
end

function CloudrestMiniHelper:OnOff()
	if CloudrestMiniHelper.isInCR == true then
		EVENT_MANAGER:RegisterForEvent(CloudrestMiniHelper.name, EVENT_COMBAT_EVENT, CloudrestMiniHelper.OnCombat)
		EVENT_MANAGER:RegisterForEvent(CloudrestMiniHelper.name, EVENT_EFFECT_CHANGED, CloudrestMiniHelper.OnEffectChanged)
		EVENT_MANAGER:RegisterForUpdate(CloudrestMiniHelper.name, 1000, CloudrestMiniHelper.UpdateWindow)
		EVENT_MANAGER:RegisterForEvent(CloudrestMiniHelper.name, EVENT_UNIT_DEATH_STATE_CHANGED, CloudrestMiniHelper.OnUnitDeathStateChanged)
	else
		EVENT_MANAGER:UnregisterForEvent(CloudrestMiniHelper.name, EVENT_COMBAT_EVENT)
		EVENT_MANAGER:UnregisterForEvent(CloudrestMiniHelper.name, EVENT_EFFECT_CHANGED)
		EVENT_MANAGER:UnregisterForUpdate(CloudrestMiniHelper.name, CloudrestMiniHelper.UpdateWindow)
		EVENT_MANAGER:UnregisterForEvent(CloudrestMiniHelper.name, EVENT_UNIT_DEATH_STATE_CHANGED)
	end
end

function CloudrestMiniHelper.ResetAll()
	CloudrestMiniHelper.ResetMini(CloudrestMiniHelper.siroria)
	CloudrestMiniHelper.ResetMini(CloudrestMiniHelper.galenwe)
	CloudrestMiniHelper.ResetMini(CloudrestMiniHelper.relequen)
end

function CloudrestMiniHelper.ResetMini(mini)
	mini.jumpTimestamp = 0
	mini.bashTimestamp = 0
	mini.skillTimestamp = 0
	mini.up = false
	mini.interrupted = false
	mini.deathTimestamp = 0
end

function CloudrestMiniHelper.UpdateMiniStatus(unitName, abilityId)
	if unitName:find("Siroria") then
		CloudrestMiniHelper.siroria.up = true
		CloudrestMiniHelper.siroria.deathTimestamp = GetTimeStamp()
	elseif unitName:find("Galenwe") then
		CloudrestMiniHelper.galenwe.up = true
		CloudrestMiniHelper.galenwe.deathTimestamp = GetTimeStamp()
	elseif unitName:find("Relequen") then
		CloudrestMiniHelper.relequen.up = true
		CloudrestMiniHelper.relequen.deathTimestamp = GetTimeStamp()
	end
end

function CloudrestMiniHelper.UpdateAbilities(result, abilityId)
	if result == ACTION_RESULT_BEGIN then
		if CloudrestMiniHelper.siroriaJump[abilityId] ~= nil then
			CloudrestMiniHelper.siroria.jumpTimestamp = GetTimeStamp() + CloudrestMiniHelper.siroria.jumpTime
		end
		
		if CloudrestMiniHelper.galenweJump[abilityId] ~= nil then
			CloudrestMiniHelper.galenwe.jumpTimestamp = GetTimeStamp() + CloudrestMiniHelper.galenwe.jumpTime
		end
		
		if CloudrestMiniHelper.relequenJump[abilityId] ~= nil then
			CloudrestMiniHelper.relequen.jumpTimestamp = GetTimeStamp() + CloudrestMiniHelper.relequen.jumpTime
		end
	
		if CloudrestMiniHelper.galenweBash[abilityId] ~= nil then
			CloudrestMiniHelper.galenwe.bashTimestamp = GetTimeStamp() + CloudrestMiniHelper.galenwe.bashTime
		end

		if CloudrestMiniHelper.relequenBash[abilityId] ~= nil then
			CloudrestMiniHelper.relequen.bashTimestamp = GetTimeStamp() + CloudrestMiniHelper.relequen.bashTime
		end

		if CloudrestMiniHelper.siroriaSkill[abilityId] ~= nil then
			CloudrestMiniHelper.siroria.skillTimestamp = GetTimeStamp() + CloudrestMiniHelper.siroria.skillTime
		end

		if CloudrestMiniHelper.galenweSkill[abilityId] ~= nil then
			CloudrestMiniHelper.galenwe.skillTimestamp = GetTimeStamp() + CloudrestMiniHelper.galenwe.skillTime
		end
	elseif result == ACTION_RESULT_EFFECT_FADED then
		if CloudrestMiniHelper.galenweBash[abilityId] ~= nil then
			CloudrestMiniHelper.galenwe.bashTimestamp = GetTimeStamp()
			CloudrestMiniHelper.galenwe.interrupted = true
		end

		if CloudrestMiniHelper.relequenBash[abilityId] ~= nil then
			CloudrestMiniHelper.relequen.bashTimestamp = GetTimeStamp()
			CloudrestMiniHelper.relequen.interrupted = true
		end
	end
end

-- Update the display window
function CloudrestMiniHelper.UpdateWindow()
	-- if all of them are down OR you're not tracking anything, listen to setting
	if (CloudrestMiniHelper.siroria.up == false and CloudrestMiniHelper.galenwe.up == false and CloudrestMiniHelper.relequen.up == false) or (CloudrestMiniHelper.SV.trackJump == false and CloudrestMiniHelper.SV.trackBash == false and CloudrestMiniHelper.SV.trackSkill == false) then
		CMHWindow:SetHidden(not CloudrestMiniHelper.SV.unlocked)
		
		return
	end

	-- if any of them are up AND you're tracking something
	if (CloudrestMiniHelper.siroria.up == true or CloudrestMiniHelper.galenwe.up == true or CloudrestMiniHelper.relequen.up == true) and (CloudrestMiniHelper.SV.trackJump == true or CloudrestMiniHelper.SV.trackBash == true or CloudrestMiniHelper.SV.trackSkill == true) then
		CMHWindow:SetHidden(false)

		if CloudrestMiniHelper.siroria.up == true then
			CloudrestMiniHelper.UpdateMiniUI(CloudrestMiniHelper.siroria, CMHWindowSiroria, CMHWindowSiroria_Jump, CMHWindowSiroria_Bash, CMHWindowSiroria_Skill)
		else
			CMHWindowSiroria:SetHidden(true)
			CMHWindowSiroria_Jump:SetHidden(true)
			CMHWindowSiroria_Bash:SetHidden(true)
			CMHWindowSiroria_Skill:SetHidden(true)
		end
		
		if CloudrestMiniHelper.galenwe.up == true then
			CloudrestMiniHelper.UpdateMiniUI(CloudrestMiniHelper.galenwe, CMHWindowGalenwe, CMHWindowGalenwe_Jump, CMHWindowGalenwe_Bash, CMHWindowGalenwe_Skill)
		else
			CMHWindowGalenwe:SetHidden(true)
			CMHWindowGalenwe_Jump:SetHidden(true)
			CMHWindowGalenwe_Bash:SetHidden(true)
			CMHWindowGalenwe_Skill:SetHidden(true)
		end
		
		if CloudrestMiniHelper.relequen.up == true then
			CloudrestMiniHelper.UpdateMiniUI(CloudrestMiniHelper.relequen, CMHWindowRelequen, CMHWindowRelequen_Jump, CMHWindowRelequen_Bash, CMHWindowRelequen_Skill)
		else
			CMHWindowRelequen:SetHidden(true)
			CMHWindowRelequen_Jump:SetHidden(true)
			CMHWindowRelequen_Bash:SetHidden(true)
			CMHWindowRelequen_Skill:SetHidden(true)
		end
	else
		CMHWindow:SetHidden(true)
	end
end

function CloudrestMiniHelper.UpdateMiniUI(mini, miniName, miniJump, miniBash, miniSkill)
	local currentTime = GetTimeStamp()
	
	-- if all else fail, this makes the mini go down
	if mini.deathTimestamp ~= 0 then
		local deathDiff = GetDiffBetweenTimeStamps(currentTime, mini.deathTimestamp)
	
		if deathDiff >= 15 then
			CloudrestMiniHelper.ResetMini(mini)
			return
		end
	end

	miniName:SetHidden(false)

	miniJump:SetHidden(true)
	miniBash:SetHidden(true)
	miniSkill:SetHidden(true)

	if CloudrestMiniHelper.SV.trackJump == true then
		miniJump:SetHidden(false)
	
		if mini.jumpTimestamp ~= 0 then
			local jumpDiff = GetDiffBetweenTimeStamps(currentTime, mini.jumpTimestamp)
			
			if jumpDiff <= 0 then
				miniJump:SetText("NOW")
			elseif jumpDiff > mini.timeBetweenJump then
				miniJump:SetText("INC")
			else
				miniJump:SetText(mini.timeBetweenJump - jumpDiff)
			end
		else
			miniJump:SetText("-")
		end
	end
	
	if CloudrestMiniHelper.SV.trackBash == true then
		miniBash:SetHidden(false)
	
		if mini.bashTimestamp ~= 0 then
			local bashDiff = GetDiffBetweenTimeStamps(currentTime, mini.bashTimestamp)
			
			if mini.interrupted == true then
				miniBash:SetText("OK")
				
				zo_callLater(function() mini.interrupted = false end, CloudrestMiniHelper.bashTimer * 1000)
			elseif bashDiff <= 0 then
				miniBash:SetText("BASH")
			elseif bashDiff > mini.timeBetweenBash then
				miniBash:SetText("INC")
			else
				miniBash:SetText(mini.timeBetweenBash - bashDiff)
			end
		else
			miniBash:SetText("-")
		end
	end

	if CloudrestMiniHelper.SV.trackSkill == true then
		miniSkill:SetHidden(false)
	
		if mini.skillTimestamp ~= 0 then
			local skillDiff = GetDiffBetweenTimeStamps(currentTime, mini.skillTimestamp)
			
			if skillDiff <= 0 then
				miniSkill:SetText("NOW")
			elseif skillDiff > mini.timeBetweenSkill then
				miniSkill:SetText("INC")
			else
				miniSkill:SetText(mini.timeBetweenSkill - skillDiff)
			end
		else
			miniSkill:SetText("-")
		end
	end
end

function CloudrestMiniHelper:InitControls()
	CMHWindow:ClearAnchors();
	CMHWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, CloudrestMiniHelper.SV.displayLeft, CloudrestMiniHelper.SV.displayTop)

	CMHWindow:SetMouseEnabled(CloudrestMiniHelper.SV.unlocked) 
	CMHWindow:SetMovable(CloudrestMiniHelper.SV.unlocked)
	CMHWindow:SetHidden(not CloudrestMiniHelper.SV.unlocked)
	
	CMHWindowHeader_Jump:SetHidden(not CloudrestMiniHelper.SV.trackJump)
	CMHWindowSiroria_Jump:SetHidden(not CloudrestMiniHelper.SV.trackJump)
	CMHWindowGalenwe_Jump:SetHidden(not CloudrestMiniHelper.SV.trackJump)
	CMHWindowRelequen_Jump:SetHidden(not CloudrestMiniHelper.SV.trackJump)
	
	CMHWindowHeader_Bash:SetHidden(not CloudrestMiniHelper.SV.trackBash)
	CMHWindowSiroria_Bash:SetHidden(not CloudrestMiniHelper.SV.trackBash)
	CMHWindowGalenwe_Bash:SetHidden(not CloudrestMiniHelper.SV.trackBash)
	CMHWindowRelequen_Bash:SetHidden(not CloudrestMiniHelper.SV.trackBash)
	
	CMHWindowHeader_Skill:SetHidden(not CloudrestMiniHelper.SV.trackSkill)
	CMHWindowSiroria_Skill:SetHidden(not CloudrestMiniHelper.SV.trackSkill)
	CMHWindowGalenwe_Skill:SetHidden(not CloudrestMiniHelper.SV.trackSkill)
	CMHWindowRelequen_Skill:SetHidden(not CloudrestMiniHelper.SV.trackSkill)
end

-- Saves the positioning of the display window
function CloudrestMiniHelper.DisplayOnMoveStop()
	CloudrestMiniHelper.SV.displayLeft = CMHWindow:GetLeft();
	CloudrestMiniHelper.SV.displayTop = CMHWindow:GetTop();
end

-- Creates the addon settings menu
function CloudrestMiniHelper:InitializeAddonMenu()
	local panelData = {
		type = "panel",
		name = "Cloudrest Mini Helper",
		displayName = "|c66ccffCloudrest Mini Helper",
		author = "|c4779ce@aldericon|r & |c00AC82@ChaosFractal|r",
		version = string.format("%.2f", CloudrestMiniHelper.version),
		slashCommand = "/cmh",
		registerForRefresh = true,
		registerForDefaults = true
	}

	local optionsPanel = self.LAM2:RegisterAddonPanel(CloudrestMiniHelper.panelName, panelData)
	local optionsData = {}

	table.insert(optionsData, {
		type = "description",
		text = "Cloudrest Mini Help tracks the jumps, interruptable attacks and unique skill that each of the minis - Siroria, Galenwe and Relequen - use in Cloudrest.",
	})
	table.insert(optionsData, {
		type = "header",
		name = "Cloudrest Mini Helper Options",
	})
	table.insert(optionsData, {
		type = "checkbox",
		name = "Same settings for all characters",
		tooltip = "ON - Each character has the same set of settings, OFF - Separate settings for each character",
		requiresReload = true,
		default = self.accountWideDefaults.accountWide,
		getFunc = function() return self.DS.accountWide end,
		setFunc = function(newValue) self.DS.accountWide = newValue end,
	})
	table.insert(optionsData, {
		type = "checkbox",
		name = "Turn OFF when satisfied with frame positions",
		tooltip = "ON - various displays can moved on the screen by left clicking and dragging, OFF - all locked in place and cannot be moved",
		default = self.defaults.unlocked,
		disabled = function()
			if self.SV.trackJump == false and self.SV.trackBash == false and self.SV.trackSkill == false then
				return true
			end
		end,
		getFunc = function()
			if self.SV.trackJump == false and self.SV.trackBash == false and self.SV.trackSkill == false then
				self.SV.unlocked = false
			end
			
			return self.SV.unlocked
		end,
		setFunc = function(newValue) self.SV.unlocked = newValue self:InitControls() end,
	})
	table.insert(optionsData, {
		type = "checkbox",
		name = "Track Jumps",
		tooltip = "ON - track jumps of all minis, OFF - do not track any mini jumps",
		default = self.defaults.trackJump,
		getFunc = function() return self.SV.trackJump end,
		setFunc = function(newValue) self.SV.trackJump = newValue self:InitControls() end,
	})
	table.insert(optionsData, {
		type = "checkbox",
		name = "Track Bashes",
		tooltip = "ON - track bashes of all minis, OFF - do not track any mini bashes",
		default = self.defaults.trackBash,
		getFunc = function() return self.SV.trackBash end,
		setFunc = function(newValue) self.SV.trackBash = newValue self:InitControls() end,
	})
	table.insert(optionsData, {
		type = "checkbox",
		name = "Track Skills",
		tooltip = "ON - track skill of all minis, OFF - do not track any mini skill",
		default = self.defaults.trackSkill,
		getFunc = function() return self.SV.trackSkill end,
		setFunc = function(newValue) self.SV.trackSkill = newValue self:InitControls() end,
	})

	self.LAM2:RegisterOptionControls(CloudrestMiniHelper.panelName, optionsData)	
end

-- so that ESO can register the addon
EVENT_MANAGER:RegisterForEvent(CloudrestMiniHelper.name, EVENT_ADD_ON_LOADED, CloudrestMiniHelper.OnAddOnLoaded)