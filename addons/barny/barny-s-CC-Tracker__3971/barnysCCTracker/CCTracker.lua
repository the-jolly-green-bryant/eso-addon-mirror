local EM = EVENT_MANAGER

local beta = false

CCTracker = {
	["name"] = "barnysCCTracker",
	["version"] = {
		["patch"] = 1,
		["major"] = 1,
		["minor"] = 2,
	},
	["beta"] = beta,
	["menu"] = {},
	["SV"] = {},
	["activeEffects"] = {},
	["status"] = {
		["alive"] = 0,
		["dead"] = 0,
		["immunityToImmobilization"] = false,
		["zone"] = "",
		["subzone"] = "",
	},
	["ccActive"] = {},
	["UI"] = {},
	["couldBeRoot"] = {},
	["couldJustBeSnare"] = {},
	["inPVPZone"] = false,
	["PVEEventsRegistered"] = false,
}

CCTracker.versionString = string.format("%s.%s.%s", CCTracker.version.patch, CCTracker.version.major, CCTracker.version.minor)
CCTracker.versionCheck = tonumber(string.format("%s%02d%02d", CCTracker.version.patch, CCTracker.version.major, CCTracker.version.minor))

local function OnAddOnLoaded(eventCode, addOnName)
    --Check if that is your addons on Load, if not quit
    if(addOnName ~= CCTracker.name) then return end
 
    --Unregister Loaded Callback
    EM:UnregisterForEvent(CCTracker.name, EVENT_ADD_ON_LOADED)
 
    --create the default table
    --create the saved variable access object here and assign it to savedVars
	local worldName = GetWorldName()
	CCTracker.SV = ZO_SavedVars:NewCharacterIdSettings("CCTrackerSV", 1, nil, CCTracker.DEFAULT_SAVED_VARS, worldName)
	if CCTracker.SV.global then
		CCTracker.SV = ZO_SavedVars:NewAccountWide("CCTrackerSV", 1, nil, CCTracker.DEFAULT_SAVED_VARS, worldName)
		CCTracker.SV.global = true
	end
	if type(CCTracker.SV.UI.alpha) == "number" then
		local num = CCTracker.SV.UI.alpha
		CCTracker.SV.UI = CCTracker.DEFAULT_SAVED_VARS.UI
		CCTracker.SV.UI.alpha.alpha = num
	end
	CCTracker:Init()
end
 
--Register Loaded Callback
EM:RegisterForEvent(CCTracker.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

ZO_CreateStringId("SI_BINDING_NAME_CCTRACKER_RESET", "Reset CCTracker")

function CCTracker:Init()

	if self.started then return end
	
	if LibChatMessage then
		self.debug = LibChatMessage("|c2a52beb|rarnys|c2a52beCC|rTracker", "|c2a52beBCC|r")
		self:HandleLibChatMessage()
		LibChatMessage:RegisterCustomChatLink("CC_ABILITY_IGNORE_LINK", function(linkStyle, linkType, name, id, zone, displayText)
			return ZO_LinkHandler_CreateLinkWithBrackets(displayText, nil, "CC_ABILITY_IGNORE_LINK", name, id, zone)
		end)
		self:InitLinkHandler()
	else 
		self:SetAllDebugFalse()
	end
	
	self.msg = LibNotification
	
	if NonContiguousCount(self.SV.additionalRoots) > 0 then
		self:PrintDebug("additionalRootList", "Importing additional root abilities to constants")
		for i = #self.SV.additionalRoots, 1, -1 do
			local rId = self.SV.additionalRoots[i]
			local inPossibleList, num = self:AbilityInList(rId, self.constants.possibleRoots)
			local inRootList, _ = self:AbilityInList(rId, self.constants.definiteRoots)
			local inSnaresList, _ = self:AbilityInList(rId, self.constants.definiteSnares)
			if inPossibleList then
				table.remove(self.constants.possibleRoots, num)
			end
			if not inRootList and not inSnaresList then
				table.insert(self.constants.definiteRoots, rId)
			else
				self:PrintDebug("additionalRootList", "Deleting skill "..rId..": "..self:CropZOSString(GetAbilityName(rId), "ability").." from additional roots. Already in definite list")
				table.remove(self.SV.additionalRoots, i)
			end
		end
	end
	
	if NonContiguousCount(self.SV.actualSnares) > 0 then
		self:PrintDebug("actualSnares", "Deleting snares from possible root constants and cleaning up actual snares list")
		for i = #self.SV.actualSnares, 1, -1 do
			local sId = self.SV.actualSnares[i]
			local inPossibleList, num = self:AbilityInList(sId, self.constants.possibleRoots)
			local inSnaresList, _ = self:AbilityInList(sId, self.constants.definiteSnares)
			local inRootList, _ = self:AbilityInList(sId, self.constants.definiteRoots)
			if inPossibleList then
				table.remove(self.constants.possibleRoots, num)
			end
			if not inSnaresList and not inRootList then
				table.insert(self.constants.definiteSnares, sId)
			else
				self:PrintDebug("actualSnares", "Deleting skill "..sId..": "..self:CropZOSString(GetAbilityName(sId), "ability").." from actual snares. Already in definite list")
				table.remove(self.SV.actualSnares, i)
			end
		end
	end
	
	self.started = true
	
	self.status.alive = GetFrameTimeMilliseconds()
	-- self.status.zone = self:CropZOSString(GetPlayerActiveZoneName(), "location")
	-- self.status.subzone = self:CropZOSString(GetPlayerActiveSubzoneName(), "location")
	
	self.ccAdded = {["combatEvents"] = 0, ["effectsChanged"] = 0, ["endTimeUpdated"] = 0,}
	
	self.currentCharacterName = self:CropZOSString(GetUnitName("player"), "name")
	self.ccVariables = self.CC_VARIABLES
	
	for aType, entry in pairs(self.ccVariables) do
		entry.tracked = self.SV.settings.tracked[entry.name]
		entry.active = false
	end
	
	self.UI = self:BuildUI()
	
	self.UI.SetUnlocked(self.SV.settings.unlocked)
	self.UI.HideLiveCCWindow(self.SV.debug.activeCCList)
	self.UI.FadeScenes("UI")
	self.audioVolume = GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_AUDIO_VOLUME)
	self:BuildMenu()
	self:CCChanged()
	
	self:CheckForCCRegister()
	
	if self.versionCheck ~= self.SV.lastAddOnVersion then self.SV.showBetaMessage = true end
	
	self:CreateNotifications()
end

	-----------------------------
	---- Register/Unregister ----
	-----------------------------

function CCTracker:CheckForCCRegister()
	for _, check in pairs(self.SV.settings.tracked) do
		if check == true then
			self:Register()
			break
		end
	end
end

function CCTracker:Register()
	EM:RegisterForEvent(
		self.name.."CombatEvents",
		EVENT_COMBAT_EVENT,
		function(...)
			self:HandleCombatEvents(...)
		end
	)
	EM:AddFilterForEvent(
		self.name.."CombatEvents",
		EVENT_COMBAT_EVENT,
		REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE,
		COMBAT_UNIT_TYPE_PLAYER
	)		
	EM:RegisterForEvent(
		self.name.."EffectsChanged",
		EVENT_EFFECT_CHANGED,
		function(...)
			self:HandleEffectsChanged(...)
		end
	)
	EM:AddFilterForEvent(
		self.name.."EffectsChanged",
		EVENT_EFFECT_CHANGED,
		REGISTER_FILTER_UNIT_TAG,
		"player"
	)
	EM:RegisterForEvent(
		self.name.."PlayerDeactivated",
		EVENT_PLAYER_DEACTIVATED,
		function()
			self.status.zone = self:CropZOSString(GetPlayerActiveZoneName(), "location")
			self.status.subzone = self:CropZOSString(GetPlayerActiveSubzoneName(), "location")
			self.status.zoneId = GetUnitZoneIndex("player")
		end
	)
	EM:RegisterForEvent(
		self.name.."PlayerActivated",
		EVENT_PLAYER_ACTIVATED,
		function()
			local zName, sZName
			zName = self:CropZOSString(GetPlayerActiveZoneName(), "location")
			sZName = self:CropZOSString(GetPlayerActiveSubzoneName(), "location")
			self.status.zoneId = GetUnitZoneIndex("player")
			
			
			if NonContiguousCount(self.ccActive) then
				if zName ~= self.status.zone then
					self:ClearCCThatIsNotBuff()
				elseif sZName ~= self.status.subzone then
					self:ClearCCThatIsNotBuff()
				end
			end
			
			self.inPVPZone = self:IsInPvPZone()
			self:RegisterPVEEvents()
		end
	)
	EM:RegisterForEvent(
		self.name.."PlayerAlive",
		EVENT_PLAYER_ALIVE,
		function()
			self.status.alive = GetFrameTimeMilliseconds()
			self.status.dead = 0
		end
	)
	EM:RegisterForEvent(
		self.name.."PlayerDead",
		EVENT_PLAYER_DEAD,
		function()
			self.status.alive = 0
			self.status.dead = GetFrameTimeMilliseconds()
			-- Clear all CC when player dies
			self:ClearAllCC()
		end
	)
	EM:RegisterForEvent(
		self.name.."WeaponPairLockChanged",
		EVENT_WEAPON_PAIR_LOCK_CHANGED,
		function(e, isLocked)
			--clear knockbacks if not isLocked
			if self.ccVariables[17].active and not isLocked then
				local cache = {}
				local time = GetFrameTimeMilliseconds()
				for _, entry in ipairs(self.ccActive) do
					if entry.type ~= 17 then
						table.insert(cache, entry)
					elseif entry.isSubeffect then
						self:ClearSubeffects(entry.id, time)					
					end
				end
				self.ccActive = cache
				self:CCChanged()
				-- self:PrintDebug("enabled", "Eliminated knockbacks")
			end
		end
	)
	
	-- EM:RegisterForEvent(
		-- self.name.."AudioVolumeChange",
		-- EVENT_INTERFACE_SETTING_CHANGED ,
		-- function(_,_,settingId)
			-- self:PrintDebug("enabled", "Interface setting changed. Getting audio volume")
			-- if settingId == AUDIO_SETTING_AUDIO_VOLUME then
				-- local audioVolume = GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_AUDIO_VOLUME)
				-- if audioVolume ~= 0 then self.audioVolume = audioVolume end
			-- end
		-- end
	-- )
		
	-- EM:AddFilterForEvent(
		-- self.name.."AudioVolumeChange",
		-- EVENT_INTERFACE_SETTING_CHANGED ,
		-- REGISTER_FILTER_SETTING_SYSTEM_TYPE,
		-- SETTING_TYPE_AUDIO
	-- )
	
	self.registered = true
end

function CCTracker:RegisterPVEEvents()
	if self.inPVPZone and self.PVEEventsRegistered then
		EM:UnregisterForEvent(
			self.name.."TrialEndCCDelete")
		self.PVEEventsRegistered = false
	elseif not (self.inPVPZone and self.PVEEventsRegistered) then
		EM:RegisterForEvent(
			self.name.."TrialEndCCDelete",
			EVENT_RAID_TRIAL_COMPLETE,
			function()
				self:ClearAllCC()
			end
		)
		self.PVEEventsRegistered = true
	end		
end

function CCTracker:Unregister()		
	EM:UnregisterForEvent(
		self.name.."CombatEvents")
		
	EM:UnregisterForEvent(
		self.name.."EffectsChanged")
		
	EM:UnregisterForEvent(
		self.name.."PlayerAlive")
	
	EM:UnregisterForEvent(
		self.name.."PlayerActivated")
	
	-- EM:UnregisterForEvent(
		-- self.name.."PlayerDeactivated")
	
	EM:UnregisterForEvent(
		self.name.."ZoneChanged")
	
	EM:UnregisterForEvent(
		self.name.."PlayerDead")
	
	EM:UnregisterForEvent(
		self.name.."WeaponPairLockChanged")
	
	self.registered = false
end

function CCTracker:HandleCombatEvents	(_, res,  err,	aName, _, _, sName, _, tName, 
										 _,	hVal, 	_,		_, _, _, 	_, aId,   _)
	
	----------------------------------------
	-- useful debug section do not delete!--
	----------------------------------------
	
	-- local checkInList, k = self:AbilityInList(aId, self.couldJustBeSnare)
	-- if checkInList and GetFrameTimeMilliseconds() == self.couldJustBeSnare[k].time then
		-- self:PrintDebug("actualSnares", "Root in list "..aId..": "..aName.." - "..res)
	-- end
	
	local time = GetFrameTimeMilliseconds()
		
	if self.status.alive == 0 or (self.status.dead ~= 0 and self.status.dead <= time) then
		return
	elseif self.constants.ignore[aId] or self.SV.ignored[aId] or self:IsSpecialIgnore(aId) then
		self:PrintDebug("ignoreList", "Ignored CC from ignore-list "..aId..": "..self:CropZOSString(aName, "ability"))
		return
	else
	-- elseif self:CropZOSString(tName, "name") == self.currentCharacterName then
	
		aName = self:CropZOSString(aName, "ability")
		
		if aId == self.constants.breakFree and self:DoesBreakFreeWork() then			-- remove stuns, fear and charm if player breaks free
			self:BreakFreeDetected()
			return
		elseif aId == self.constants.rollDodge.abilityId and res == ACTION_RESULT_EFFECT_GAINED then	-- remove roots when player uses dodgeroll
			self:RolldodgeDetected()
			return
		end	
		
		-- self:ClearOutdatedLists(time, "Combat events")
		
		if res == ACTION_RESULT_EFFECT_FADED then
			if aId == self.constants.rollDodge.buffId then
				self.status.immunityToImmobilization = false
				return
			elseif self.activeEffects[aId] and self.activeEffects[aId].subeffects and next(self.activeEffects[aId].subeffects) then
				local subs = self.activeEffects[aId].subeffects
				for i = #subs, 1, -1 do
					local id = subs[i]
					local inActiveList, number = self:AbilityInList(id, self.ccActive)
					if inActiveList then
						self:SnareRootCheck(id, number, aName)
						
						-----------------------------------------------------------------------------
						-- removing ability from all possible subeffects it may have been saved to --
						-----------------------------------------------------------------------------
						if self.ccActive[number].isSubeffect then self:ClearSubeffects(id, time) end
						
						table.remove(self.ccActive, number)
						self:CCChanged()
						self:PrintDebug("ccActive", zo_strformat("Removing subeffect ability <<1>> from ccActive list and from activeEffect <<2>>", self:CropZOSString(GetAbilityName(id), "ability"), self:CropZOSString(GetAbilityName(aId), "ability")))
					end
				end
				self.activeEffects[aId] = nil
				self:PrintDebug("ccActive", "Cleared active effect "..aId.." - "..aName)
				return
			else
				local inList, num = self:AbilityInList(aId, self.ccActive)
				if inList then
					self:SnareRootCheck(aId, num, aName)
					if self.ccActive[num].isSubeffect then self:ClearSubeffects(aId, time) end
					table.remove(self.ccActive, num)
					self:CCChanged()
					self:PrintDebug("ccActive", "Removing ability "..aName.." from ccActive list")
					return
				else
					self.activeEffects[aId] = nil
					return
				end
			end
		elseif res == ACTION_RESULT_EFFECT_GAINED then
			if aId == self.constants.rollDodge.buffId then
				self.status.immunityToImmobilization = true
				return
			elseif not self.activeEffects[aId] then
				local newEffect = {["name"] = aName, ["time"] = time}
				self.activeEffects[aId] = newEffect
				self:PrintDebug("ccActive", zo_strformat("Added new active effect <<1>> at time <<2>>", aName, time))
			end
			return
			
			-- adding timers to combat events if there is an effect gained with duration
		elseif res == ACTION_RESULT_EFFECT_GAINED_DURATION and self.activeEffects[aId] then
			local inList, num = self:AbilityInList(aId, self.ccActive)
			if inList then
				local endTime = self.ccActive[num].startTime + hVal
				self.ccActive[num].endTime = endTime
				self.ccActive[num].duration = endTime - self.ccActive[num].startTime
				self:UpdateTimers()
				self:CCChanged()
				-- calling clearing of said CC after it ended
				zo_callLater(function() self:ClearOutdatedLists(endTime, "CombatEvent") end,
					hVal
				)
			end
		elseif not err then
			if res == ACTION_RESULT_SNARED and not (self:AbilityInList(aId, self.constants.definiteSnares) or self:AbilityInList(aId, self.SV.actualSnares)) and self:IsRoot(aId) then
				res = 2480
				if self.status.immunityToImmobilization then
					self:PrintDebug("roots", "actualSnares", "Someone tried to root you, when you were immune to immobilization. What a foolish rookie mistake, it's probably just a snare though.")
					table.insert(self.SV.actualSnares, aId)
					local inList, num = self:AbilityInList(aId, self.SV.additionalRoots)
					if inList then
						table.remove(self.SV.additionalRoots, num)
					end
					return
				end
			end
			for ccType, check in pairs(self.ccVariables) do
				if check.res == res and check.tracked and not self.constants.exceptions[aId] then
					-- self:PrintDebug("ccCache", "Caching cc result")
					local isSubeffect = false
					local mainEffects = {}
					for eId, entry in pairs(self.activeEffects) do
						-- self:PrintDebug("ccActive", "Checking for active effects at time: "..time)
						if entry.time == time then
							-- self:PrintDebug("ccActive", "Found active effect and will add "..aId.." to active effect "..eId)
							if not entry.subeffects then
								-- self:PrintDebug("ccActive", "Initializing subeffects for effect "..eId)
								entry.subeffects = {}
							end
							table.insert(entry.subeffects, aId)
							self:PrintDebug("ccActive", zo_strformat("Added new subeffect <<4>> to ability <<1>> - <<2>> at time <<3>>", eId, self:CropZOSString(GetAbilityName(eId), "ability"), time, aName))
							isSubeffect = true
							table.insert(mainEffects, eId)
							-- self:PrintDebug("ccActive", "Adding effect "..aId.." to subeffects for effect "..eId)
						end
					end
					
					-- trying direct import of abilities from combat events
					local newAbility = {
						["id"] = aId,
						["type"] = ccType,
						["startTime"] = time,
						["endTime"] = 0,
						-- ["cacheId"] = 0,
						["isSubeffect"] = isSubeffect,
					}
					if next(mainEffects) then newAbility.mainEffects = mainEffects end
					local inList, num = self:AbilityInList(aId, self.ccActive)
					if not inList then
						-- if not self:TypeInList(newAbility.type) then
						if not self.ccVariables[ccType].active and (self.SV.sound[self.ccVariables[ccType].name].enabled or (self.SV.sound.MuteOnHardCC and self.ccVariables[ccType].isHardCC)) then
							check.playSound = true
						end
						table.insert(self.ccActive, newAbility)
						self:PrintDebug("ccActive", "New cc from combat events "..aName.." - ID: "..aId.." - "..check.name)
						
						self.ccAdded.combatEvents = self.ccAdded.combatEvents + 1
						self:PrintDebug("ccAdded", "So far I've added "..self.ccAdded.combatEvents.." cc abilities from combatEvents and "..self.ccAdded.effectsChanged.." from effectsChanged")
						if check.playSound then self:CCChanged(check.playSound) end
					end
					--------------------------
					-- IGNORE CC CHAT LINKS --
					--------------------------
					if self.SV.settings.ccIgnoreLinks then
						self:PrintIgnoreLink(aName, aId)
					end
					break
				-- else
					-- if not self.ccCache then self.ccCache = {} end
					-- local newAbility = {["type"] = ccType, ["recorded"] = time, ["id"] = aId, ["name"] = aName}
					-- table.insert(self.ccCache, newAbility)
					-- self:PrintDebug("ccCache", "Caching ability "..aName.." ID: "..aId)
					-- break
				end
			end
		end
	-- else return
	end
end

	--------------------------------
	---- Handle Effects Changed ----
	--------------------------------

function CCTracker:HandleEffectsChanged(_,changeType,_,eName,_,beginTime,endTime,_,_,_,buffType,abilityType,_,unitName,_,aId,sType)
	--  self:PrintDebug("enabled", unitName.." - "..GetUnitName("player"))
	
	local time = GetFrameTimeMilliseconds()
		
	if self.status.alive == 0 or (self.status.dead ~= 0 and self.status.dead <= time) then
		return
	elseif self.SV.ignored[aId] or self.constants.ignore[aId] or self:IsSpecialIgnore(aId) then
		self:PrintDebug("ignoreList", "Ignored CC from ignore-list "..aId..": "..self:CropZOSString(eName, "ability"))
		return
	else
		local eName = self:CropZOSString(eName, "ability")
		local playCCSound = false
		local ccChanged = false
		
		-- self:ClearOutdatedLists(time, "Effect changed")
		
		if IsUnitDeadOrReincarnating("player") then
			self:ClearAllCC()
			return
		elseif changeType == EFFECT_RESULT_FADED then
			if aId == self.constants.rollDodge.buffId then
				self.status.immunityToImmobilization = false
				return
			end
			local inList, num = self:AbilityInList(aId, self.ccActive)
			if inList then
				self:SnareRootCheck(aId, num, eName)
				table.remove(self.ccActive, num)
				ccChanged = true
			end
		elseif changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_FULL_REFRESH or changeType == EFFECT_RESULT_UPDATED then
			if aId == self.constants.rollDodge.buffId then
				self.status.immunityToImmobilization = true
				return
			end
			local inList, num = self:AbilityInList(aId, self.ccActive)
			if inList then
				self.ccActive[num].endTime = endTime*1000
				self.ccActive[num].duration = self.ccActive[num].endTime - self.ccActive[num].startTime
				self:PrintDebug("ccActive", "Adjusting endTime of ability "..aId.." - "..eName)
				self.ccAdded.endTimeUpdated = self.ccAdded.endTimeUpdated + 1
				self:PrintDebug("ccAdded", "Updated endTime of "..self.ccAdded.endTimeUpdated.." cc abilities")
				
				-- calling clearing of said CC after it ended
				zo_callLater(function() self:ClearOutdatedLists(endTime*1000, "Effect changed") end,
					(endTime-beginTime)*1000
				)
			else
				if abilityType == ABILITY_TYPE_SNARE and not (self:AbilityInList(aId, self.constants.definiteSnares) or self:AbilityInList(aId, self.SV.actualSnares)) and self:IsRoot(aId) then
					abilityType = "root"
					if self.status.immunityToImmobilization then
						self:PrintDebug("roots", "actualSnares", "Someone tried to root you, when you were immune to immobilization. That was a rookie mistake")
						table.insert(self.SV.actualSnares, aId)
						local inList, num = self:AbilityInList(aId, self.SV.additionalRoots)
						if inList then
							table.remove(self.SV.additionalRoots, num)
						end
						return
					end
				end
				if self.ccVariables[abilityType] and self.ccVariables[abilityType].tracked then
					local ending = ((endTime-beginTime~=0) and endTime) or 0
					local newAbility = {
						["id"] = aId,
						["type"] = abilityType,
						["startTime"] = time,
						["endTime"] = ending*1000,
						["duration"] = ending*1000 - time,
					}
					-- if self.ccCache and next(self.ccCache) then
						-- for i = #self.ccCache, 1, -1 do
							-- if self.ccCache[i].type == abilityType then
								-- newAbility.cacheId = self.ccCache[i].id
								-- table.remove(self.ccCache, i)
								-- self:PrintDebug("ccCache", "Clearing CC cache position "..i)
								-- break
							-- elseif self.ccCache and self.ccCache[i].type == "charm" and self.ccVariables.charm.tracked then
								-- newAbility.type = "charm"
								-- newAbility.cacheId = self.ccCache[i].id
								-- table.remove(self.ccCache, i)
								-- self:PrintDebug("ccCache", "Clearing CC cache position "..i..". Charm was detected")
								-- break
							-- end
						-- end
					-- else
						-- newAbility.cacheId = 0
					-- end
					-- if not self:TypeInList(newAbility.type) then
					if not self.ccVariables[abilityType].active then
						if self.SV.sound[self.ccVariables[abilityType].name].enabled then
							self.ccVariables[abilityType].playSound = true
							playCCSound = true
						elseif self.SV.sound.MuteOnHardCC and self.ccVariables[abilityType].isHardCC then
							playCCSound = true
						end
						ccChanged = true
					end
					table.insert(self.ccActive, newAbility)
					self:PrintDebug("ccActive", "New cc "..eName.." - ID: "..newAbility.id.." - "..self.ccVariables[newAbility.type].name)
					self.ccAdded.effectsChanged = self.ccAdded.effectsChanged + 1
					self:PrintDebug("ccAdded", "So far I've added "..self.ccAdded.combatEvents.." cc abilities from combatEvents and "..self.ccAdded.effectsChanged.." from effectsChanged")
					
					-- calling clearing of said CC after it ended
					if ending ~= 0 then
						self:UpdateTimers()
						zo_callLater(function() self:ClearOutdatedLists(endTime*1000, "Effect changed") end,
							(endTime-beginTime)*1000
						)
					end
					--------------------------
					-- IGNORE CC CHAT LINKS --
					--------------------------
					if self.SV.settings.ccIgnoreLinks then
						self:PrintIgnoreLink(eName, newAbility.id)
					end
				end
			end
			-- if self.ccCache and next(self.ccCache) then
				-- local debugMessageSent = false
				-- for i = #self.ccCache, 1, -1 do
					-- inList, num = self:AbilityInList(self.ccCache[i].id, self.ccActive)
					-- if inList then
						-- self.ccActive[num].endTime = endTime*1000
						-- self:PrintDebug("ccActive", "Adjusting endTime of ability "..aId.." - "..self.ccCache[i].name)
					-- else
						-- local ending = ((endTime-beginTime~=0) and endTime) or 0
						-- local newAbility = {["id"] = aId, ["type"] = self.ccCache[i].type, ["endTime"] = ending*1000, ["cacheId"] = self.ccCache[i].id }
						-- if not self:TypeInList(newAbility.type) then
							-- if self.SV.sound[self.ccVariables[newAbility.type].name].enabled then
								-- self.ccVariables[newAbility.type].playSound = true
								-- playCCSound = true
							-- end
							-- ccChanged = true
						-- end
						-- table.insert(self.ccActive, newAbility)
						-- self:PrintDebug("ccActive", "ccCache", "New cc from cache "..self.ccCache[i].name.." - ID: "..self.ccCache[i].id.." - "..self.ccVariables[self.ccCache[i].type].name)
						-- self.ccAdded.effectsChanged = self.ccAdded.effectsChanged + 1
						-- self:PrintDebug("ccAdded", "So far I've added "..self.ccAdded.combatEvents.." cc abilities from combatEvents and "..self.ccAdded.effectsChanged.." from effectsChanged")
						--------------------
						-- IGNORE CC CHAT LINKS --
						--------------------
						-- if self.SV.settings.ccIgnoreLinks then
							-- self:PrintIgnoreLink(name, newAbility.cacheId)
						-- end
						-- if not debugMessageSent then
							-- self:PrintDebug("ccActive", "ccCache", "Adding "..i.." additional CC abilities from combat events")
							-- debugMessageSent = true
							-- self.debug:Print("CC ability detected from combat event. Clearing CC cache position "..i)
						-- end
					-- end
				-- end
				-- self.ccCache = {}
			-- end
			if ccChanged then self:CCChanged(playCCSound) end
		end
	end
end