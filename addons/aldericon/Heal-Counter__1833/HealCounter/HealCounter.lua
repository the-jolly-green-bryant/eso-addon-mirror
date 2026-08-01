
-- whenever you mount up or down
function HealCounter.OnMountStateChange(eventCode, mounted)
	if HealCounter.SV.onlyTrackMounted == false or HealCounter.SV.displayScreen == false or HealCounter.SV.trackingAbility1 ~= 3 then
		return
	end

	HealCounter.debugLog("Mount Change: "..tostring(mounted), 2)

	HealCounter.playerIsMounted = mounted
end

-- Whenever you get rezzed
function HealCounter.OnSelfRez(eventCode, requesterCharacterName, timeLeftToAccept, requesterDisplayName)
	if HealCounter.SV.utilizePopup == false then
		return
	end

	HealCounter.debugLog("You just got rezzed by: "..requesterCharacterName, 1)

	HealCounter.selfTotalRezzed = HealCounter.selfTotalRezzed + 1
end

-- Whenever a group member becomes in or out of range
function HealCounter.OnGroupSupportRangeUpdate(eventCode, unitTag, status)
	--HealCounter.debugLog(GetUnitName(unitTag) .. " has just moved in or out of range; status: " .. tostring(status), 2)
	--HealCounter.debugLog("GetUnitDisplayName: "..GetUnitDisplayName(unitTag), 3)

	HealCounter.UpdateAtName(unitTag)

	if HealCounter.SV.displayScreen == false or HealCounter.SV.trackingAbility1 ~= 3 then
		return
	end
	
	local playerName = zo_strformat("<<1>>", GetUnitName(unitTag))

	if HealCounter.currentSession.players[playerName] ~= nil then
		HealCounter.currentSession.players[playerName].inSupportRange = status
	end
end

-- Everytime the user 'loads', either by transitioning between zones or just reloading
function HealCounter.OnPlayerActivated(eventCode, initial)
	HealCounter.playerInPvP = IsPlayerInAvAWorld()
	HealCounter:OnOff()
end

-- When the different layers of the screen are changed - quickslotting, settings, main display, etc.
function HealCounter.OnActionLayerChange(eventCode, layerIndex, activeLayerIndex)
	if HealCounter.SV.displayScreen == false then
		return
	end

	HealCounter.debugLog("Inside OnActionLayerChange: "..activeLayerIndex, 3)

	HealCounter.currentLayerIndex = activeLayerIndex

	if HealCounter.SV.preview == true then
		return
	end

	HealCounterWindow:SetHidden(activeLayerIndex > 2)
end

-- Whenever a player joines or leaves group
function HealCounter.OnGroupPlayerChange(eventCode, memberCharacterName)
	local memberCharacterName = zo_strformat("<<1>>", memberCharacterName)

	HealCounter.debugLog("Player either joined or left group: "..memberCharacterName, 2)

	HealCounter.InitializePlayerArray(memberCharacterName)

	-- if someone else joined / left, clear their data
	if HealCounter.currentSession.players[memberCharacterName] ~= nil then
		HealCounter.currentSession.players[memberCharacterName].set1A = 0
		HealCounter.currentSession.players[memberCharacterName].set1T = 0
		HealCounter.currentSession.players[memberCharacterName].set2A = 0
		HealCounter.currentSession.players[memberCharacterName].set2T = 0
		HealCounter.currentSession.players[memberCharacterName].set3A = 0
		HealCounter.currentSession.players[memberCharacterName].set3T = 0
		HealCounter.currentSession.players[memberCharacterName].ability1A = 0
		HealCounter.currentSession.players[memberCharacterName].ability1T = 0
		HealCounter.currentSession.players[memberCharacterName].playerInGroup = HealCounter.IsPlayerInGroup(memberCharacterName)
	end
end

-- Resets the current session
function HealCounter.OnResetButtonClicked()
	HealCounter.debugLog("Reset button has been clicked", 1)

	HealCounter.totalUniquePlayersHealed = 0
	HealCounter.totalPlayersRezzed = 0

	HealCounter.currentSession.players = {}
	HealCounter.currentSession.abilities = {}

	HealCounter.ClearSessionTables()
end

-- Resets High Scores (TPH & TPR)
function HealCounter.OnResetHighScores()
	HealCounter.SV.bestTotalHealed = 0
	HealCounter.SV.bestTotalRezzed = 0
end

function HealCounter.IsPlayerInGroup(playerName)
	if IsPlayerInGroup(playerName) or playerName == HealCounter.playerName then
		return true
	end

	return false
end

-- Whenever a buff occurs on a player in group, or a debuff to yourself
function HealCounter.OnEffectChanged(eventCode, changeType, eSlot, eName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, aType, statusEffectType, unitName, uId, abilityId, sourceUnitType)
	if HealCounter.frameRate <= HealCounter.SV.trackFPSNum then
		return
	end

	local set1 = HealCounter.SV.trackingSet1
	local set2 = HealCounter.SV.trackingSet2
	local set3 = HealCounter.SV.trackingSet3
	local ability1 = HealCounter.SV.trackingAbility1

	if (set1 ~= 1 or set2 ~= 1 or set3 ~= 1 or ability1 ~= 1) and HealCounter.SV.displayScreen == true then
		if HealCounter.majorcourage[abilityId] ~= nil or HealCounter.transmutation[abilityId] ~= nil or HealCounter.majoreva[abilityId] ~= nil or HealCounter.rapid[abilityId] ~= nil or HealCounter.minorberserk[abilityId] ~= nil or HealCounter.trk[abilityId] ~= nil or HealCounter.meritoriousService[abilityId] ~= nil then
			local playerName = zo_strformat("<<1>>", GetUnitName(unitTag))

			HealCounter.debugLog("Effect name: "..eName.." ("..abilityId.."); unit name: "..playerName, 2)
			HealCounter.debugLog("Effect Changed ability id: "..abilityId, 2)
			HealCounter.debugLog("Change Type: "..changeType, 2)

			HealCounter.UpdateAtName(unitTag)

			if HealCounter.currentSession.players[playerName] ~= nil and HealCounter.currentSession.players[playerName].playerInGroup == true then
				if changeType ~= EFFECT_RESULT_FADED then
					if (set1 == 3 or set1 == 8) and HealCounter.majorcourage[abilityId] ~= nil then
						HealCounter.currentSession.players[playerName].set1A = 1
						HealCounter.currentSession.players[playerName].set1T = GetTimeStamp()
					elseif set1 == 4 and HealCounter.transmutation[abilityId] ~= nil then
						HealCounter.currentSession.players[playerName].set1A = 1
						HealCounter.currentSession.players[playerName].set1T = GetTimeStamp()
					elseif set1 == 5 and HealCounter.majoreva[abilityId] ~= nil then
						HealCounter.currentSession.players[playerName].set1A = 1
						HealCounter.currentSession.players[playerName].set1T = GetTimeStamp()
					elseif set1 == 6 and HealCounter.trk[abilityId] ~= nil then
						HealCounter.currentSession.players[playerName].set1A = 1
						HealCounter.currentSession.players[playerName].set1T = GetTimeStamp()
					elseif set1 == 7 and HealCounter.meritoriousService[abilityId] ~= nil then
						HealCounter.currentSession.players[playerName].set1A = 1
						HealCounter.currentSession.players[playerName].set1T = GetTimeStamp()
					elseif set1 == 9 and HealCounter.symphonyOfBlades[abilityId] ~= nil then
						HealCounter.currentSession.players[playerName].set1A = 1
						HealCounter.currentSession.players[playerName].set1T = GetTimeStamp()
					end

					if (set2 == 3 or set2 == 8) and HealCounter.majorcourage[abilityId] ~= nil then
						HealCounter.currentSession.players[playerName].set2A = 1
						HealCounter.currentSession.players[playerName].set2T = GetTimeStamp()
					elseif set2 == 4 and HealCounter.transmutation[abilityId] ~= nil then
						HealCounter.currentSession.players[playerName].set2A = 1
						HealCounter.currentSession.players[playerName].set2T = GetTimeStamp()
					elseif set2 == 5 and HealCounter.majoreva[abilityId] ~= nil then
						HealCounter.currentSession.players[playerName].set2A = 1
						HealCounter.currentSession.players[playerName].set2T = GetTimeStamp()
					elseif set2 == 6 and HealCounter.trk[abilityId] ~= nil then
						HealCounter.currentSession.players[playerName].set2A = 1
						HealCounter.currentSession.players[playerName].set2T = GetTimeStamp()
					elseif set2 == 7 and HealCounter.meritoriousService[abilityId] ~= nil then
						HealCounter.currentSession.players[playerName].set2A = 1
						HealCounter.currentSession.players[playerName].set2T = GetTimeStamp()
					elseif set2 == 9 and HealCounter.symphonyOfBlades[abilityId] ~= nil then
						HealCounter.currentSession.players[playerName].set2A = 1
						HealCounter.currentSession.players[playerName].set2T = GetTimeStamp()
					end

					if (set3 == 3 or set3 == 8) and HealCounter.majorcourage[abilityId] ~= nil then
						HealCounter.currentSession.players[playerName].set3A = 1
						HealCounter.currentSession.players[playerName].set3T = GetTimeStamp()
					elseif set3 == 4 and HealCounter.transmutation[abilityId] ~= nil then
						HealCounter.currentSession.players[playerName].set3A = 1
						HealCounter.currentSession.players[playerName].set3T = GetTimeStamp()
					elseif set3 == 5 and HealCounter.majoreva[abilityId] ~= nil then
						HealCounter.currentSession.players[playerName].set3A = 1
						HealCounter.currentSession.players[playerName].set3T = GetTimeStamp()
					elseif set3 == 6 and HealCounter.trk[abilityId] ~= nil then
						HealCounter.currentSession.players[playerName].set3A = 1
						HealCounter.currentSession.players[playerName].set3T = GetTimeStamp()
					elseif set3 == 7 and HealCounter.meritoriousService[abilityId] ~= nil then
						HealCounter.currentSession.players[playerName].set3A = 1
						HealCounter.currentSession.players[playerName].set3T = GetTimeStamp()
					elseif set3 == 9 and HealCounter.symphonyOfBlades[abilityId] ~= nil then
						HealCounter.currentSession.players[playerName].set3A = 1
						HealCounter.currentSession.players[playerName].set3T = GetTimeStamp()
					end

					if ability1 == 3 and HealCounter.rapid[abilityId] ~= nil then
						HealCounter.currentSession.players[playerName].ability1A = 1
						HealCounter.currentSession.players[playerName].ability1T = GetTimeStamp()
					elseif ability1 == 4 and HealCounter.minorberserk[abilityId] ~= nil then
						HealCounter.currentSession.players[playerName].ability1A = 1
						HealCounter.currentSession.players[playerName].ability1T = GetTimeStamp()
					end
				else
					if (set1 == 3 or set1 == 8) and HealCounter.majorcourage[abilityId] ~= nil then
						HealCounter.currentSession.players[playerName].set1A = 0
						HealCounter.currentSession.players[playerName].set1T = 0
					elseif set1 == 4 and HealCounter.transmutation[abilityId] ~= nil then
						HealCounter.currentSession.players[playerName].set1A = 0
						HealCounter.currentSession.players[playerName].set1T = 0
					elseif set1 == 5 and HealCounter.majoreva[abilityId] ~= nil then
						HealCounter.currentSession.players[playerName].set1A = 0
						HealCounter.currentSession.players[playerName].set1T = 0
					elseif set1 == 6 and HealCounter.trk[abilityId] ~= nil then
						HealCounter.currentSession.players[playerName].set1A = 0
						HealCounter.currentSession.players[playerName].set1T = 0
					elseif set1 == 7 and HealCounter.meritoriousService[abilityId] ~= nil then
						HealCounter.currentSession.players[playerName].set1A = 0
						HealCounter.currentSession.players[playerName].set1T = 0
					elseif set1 == 9 and HealCounter.symphonyOfBlades[abilityId] ~= nil then
						HealCounter.currentSession.players[playerName].set1A = 0
						HealCounter.currentSession.players[playerName].set1T = 0
					end

					if (set2 == 3 or set2 == 8) and HealCounter.majorcourage[abilityId] ~= nil then
						HealCounter.currentSession.players[playerName].set2A = 0
						HealCounter.currentSession.players[playerName].set2T = 0
					elseif set2 == 4 and HealCounter.transmutation[abilityId] ~= nil then
						HealCounter.currentSession.players[playerName].set2A = 0
						HealCounter.currentSession.players[playerName].set2T = 0
					elseif set2 == 5 and HealCounter.majoreva[abilityId] ~= nil then
						HealCounter.currentSession.players[playerName].set2A = 0
						HealCounter.currentSession.players[playerName].set2T = 0
					elseif set2 == 6 and HealCounter.trk[abilityId] ~= nil then
						HealCounter.currentSession.players[playerName].set2A = 0
						HealCounter.currentSession.players[playerName].set2T = 0
					elseif set2 == 7 and HealCounter.meritoriousService[abilityId] ~= nil then
						HealCounter.currentSession.players[playerName].set2A = 0
						HealCounter.currentSession.players[playerName].set2T = 0
					elseif set2 == 9 and HealCounter.symphonyOfBlades[abilityId] ~= nil then
						HealCounter.currentSession.players[playerName].set2A = 0
						HealCounter.currentSession.players[playerName].set2T = 0
					end

					if (set3 == 3 or set3 == 8) and HealCounter.majorcourage[abilityId] ~= nil then
						HealCounter.currentSession.players[playerName].set3A = 0
						HealCounter.currentSession.players[playerName].set3T = 0
					elseif set3 == 4 and HealCounter.transmutation[abilityId] ~= nil then
						HealCounter.currentSession.players[playerName].set3A = 0
						HealCounter.currentSession.players[playerName].set3T = 0
					elseif set3 == 5 and HealCounter.majoreva[abilityId] ~= nil then
						HealCounter.currentSession.players[playerName].set3A = 0
						HealCounter.currentSession.players[playerName].set3T = 0
					elseif set3 == 6 and HealCounter.trk[abilityId] ~= nil then
						HealCounter.currentSession.players[playerName].set3A = 0
						HealCounter.currentSession.players[playerName].set3T = 0
					elseif set3 == 7 and HealCounter.meritoriousService[abilityId] ~= nil then
						HealCounter.currentSession.players[playerName].set3A = 0
						HealCounter.currentSession.players[playerName].set3T = 0
					elseif set3 == 9 and HealCounter.symphonyOfBlades[abilityId] ~= nil then
						HealCounter.currentSession.players[playerName].set3A = 0
						HealCounter.currentSession.players[playerName].set3T = 0
					end

					if ability1 == 3 and HealCounter.rapid[abilityId] ~= nil then
						HealCounter.currentSession.players[playerName].ability1A = 0
						HealCounter.currentSession.players[playerName].ability1T = 0
					elseif ability1 == 4 and HealCounter.minorberserk[abilityId] ~= nil then
						HealCounter.currentSession.players[playerName].ability1A = 0
						HealCounter.currentSession.players[playerName].ability1T = 0
					end
				end
			end
		else
			HealCounter.debugLog("Effect Changed ability id: "..abilityId, 3)
			HealCounter.debugLog("Change Type: "..changeType, 3)
		end
	end

	HealCounter.UpdateWindow()
end

function HealCounter.ScreenNotification(message, timeOnScreen)
	local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT, SOUNDS.NONE)
	messageParams:SetText(message)
	messageParams:SetLifespanMS(timeOnScreen)
	CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
end

-- Can do a lot; anytime someone around you does an action
function HealCounter.OnCombat(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
	if HealCounter.frameRate <= HealCounter.SV.trackFPSNum then
		return
	end

	if abilityName == '' or sourceName == '' or targetName == '' or abilityId == '' then
		return
	end

	HealCounter.UpdateWindow()
	
	local target = zo_strformat("<<1>>", targetName)
	local source = zo_strformat("<<1>>", sourceName)
	local ability = zo_strformat("<<1>>", abilityName)

	HealCounter.debugLog("Ability Name: "..abilityName.." ("..abilityId..")", 2)
	--d("Ability Name: "..abilityName.." ("..abilityId..")")

	HealCounter.debugLog("Ability Name: "..abilityName,3)
	HealCounter.debugLog("Ability ID: "..abilityId, 3)
	HealCounter.debugLog("Source: "..source,3)
	HealCounter.debugLog("Source Type: "..sourceType,3)
	HealCounter.debugLog("Target: "..target,3)
	HealCounter.debugLog("Target Type: "..targetType,3)
	HealCounter.debugLog("Hit Value: "..hitValue,3)
	HealCounter.debugLog("ActionResult: "..result, 3)

	if sourceType ~= 1 then
		return
	end

	if HealCounter.SV.siegeNotification == true and HealCounter.siege[abilityId] ~= nil and hitValue > 1 and targetType == COMBAT_UNIT_TYPE_OTHER then
		local playerName = target

		if HealCounter.SV.purgeName == false then
			if HealCounter.currentSession.players[playerName] ~= nil and HealCounter.currentSession.players[playerName].atName ~= 'Unknown' then
				playerName = HealCounter.currentSession.players[playerName].atName
			end
		end

		HealCounter.ScreenNotification('You just hit ' .. playerName .. " for " .. hitValue, 1000)
	end

	--[[if hitValue > 0 then
		if HealCounter.siege[abilityId] == nil then
			HealCounter.debugLog("Ability: "..ability.."("..abilityId..")",1)
		end
	end]]

	if HealCounter.SV.trackingLevel == 2 then
		-- Yourself, Group Member, Other Players
		if targetType ~= COMBAT_UNIT_TYPE_PLAYER and targetType ~= COMBAT_UNIT_TYPE_GROUP and targetType ~= COMBAT_UNIT_TYPE_OTHER then
			HealCounter.debugLog("Returning1: "..targetType, 3)
			return
		end
	elseif HealCounter.SV.trackingLevel == 3 then
		if targetType ~= COMBAT_UNIT_TYPE_GROUP and targetType ~= COMBAT_UNIT_TYPE_PLAYER then
			HealCounter.debugLog("Returning2: "..targetType, 3)
			return
		end
	end

	HealCounter.InitializePlayerArray(target)

	local set1 = HealCounter.SV.trackingSet1
	local set2 = HealCounter.SV.trackingSet2
	local set3 = HealCounter.SV.trackingSet3
	local ability1 = HealCounter.SV.trackingAbility1

	if HealCounter.currentSession.players[target] ~= nil and (set1 ~= 1 or set2 ~= 1 or set3 ~= 1 or ability1 ~= 1) and HealCounter.SV.utilizePopup == true then
		if HealCounter.earthgore[abilityId] ~= nil or HealCounter.majorcourage[abilityId] ~= nil or HealCounter.transmutation[abilityId] ~= nil or HealCounter.majoreva[abilityId] ~= nil or HealCounter.rapid[abilityId] ~= nil or HealCounter.minorberserk[abilityId] ~= nil or HealCounter.trk[abilityId] ~= nil or HealCounter.meritoriousService[abilityId] ~= nil then
			if set1 == 2 and HealCounter.earthgore[abilityId] ~= nil then
				HealCounter.currentSession.players[target].set1 = HealCounter.currentSession.players[target].set1 + 1
			elseif (set1 == 3 or set1 == 8) and HealCounter.majorcourage[abilityId] ~= nil then
				HealCounter.currentSession.players[target].set1 = HealCounter.currentSession.players[target].set1 + 1
			elseif set1 == 4 and HealCounter.transmutation[abilityId] ~= nil then
				HealCounter.currentSession.players[target].set1 = HealCounter.currentSession.players[target].set1 + 1
			elseif set1 == 5 and HealCounter.majoreva[abilityId] ~= nil then
				HealCounter.currentSession.players[target].set1 = HealCounter.currentSession.players[target].set1 + 1
			elseif set1 == 6 and HealCounter.trk[abilityId] ~= nil then
				HealCounter.currentSession.players[target].set1 = HealCounter.currentSession.players[target].set1 + 1
			elseif set1 == 7 and HealCounter.meritoriousService[abilityId] ~= nil then
				HealCounter.currentSession.players[target].set1 = HealCounter.currentSession.players[target].set1 + 1
			end

			if set2 == 2 and HealCounter.earthgore[abilityId] ~= nil then
				HealCounter.currentSession.players[target].set2 = HealCounter.currentSession.players[target].set2 + 1
			elseif (set2 == 3 or set2 == 8) and HealCounter.majorcourage[abilityId] ~= nil then
				HealCounter.currentSession.players[target].set2 = HealCounter.currentSession.players[target].set2 + 1
			elseif set2 == 4 and HealCounter.transmutation[abilityId] ~= nil then
				HealCounter.currentSession.players[target].set2 = HealCounter.currentSession.players[target].set2 + 1
			elseif set2 == 5 and HealCounter.majoreva[abilityId] ~= nil then
				HealCounter.currentSession.players[target].set2 = HealCounter.currentSession.players[target].set2 + 1
			elseif set2 == 6 and HealCounter.trk[abilityId] ~= nil then
				HealCounter.currentSession.players[target].set2 = HealCounter.currentSession.players[target].set2 + 1
			elseif set2 == 7 and HealCounter.meritoriousService[abilityId] ~= nil then
				HealCounter.currentSession.players[target].set2 = HealCounter.currentSession.players[target].set2 + 1
			end

			if set3 == 2 and HealCounter.earthgore[abilityId] ~= nil then
				HealCounter.currentSession.players[target].set3 = HealCounter.currentSession.players[target].set3 + 1
			elseif (set3 == 3 or set3 == 8) and HealCounter.majorcourage[abilityId] ~= nil then
				HealCounter.currentSession.players[target].set3 = HealCounter.currentSession.players[target].set3 + 1
			elseif set3 == 4 and HealCounter.transmutation[abilityId] ~= nil then
				HealCounter.currentSession.players[target].set3 = HealCounter.currentSession.players[target].set3 + 1
			elseif set3 == 5 and HealCounter.majoreva[abilityId] ~= nil then
				HealCounter.currentSession.players[target].set3 = HealCounter.currentSession.players[target].set3 + 1
			elseif set3 == 6 and HealCounter.trk[abilityId] ~= nil then
				HealCounter.currentSession.players[target].set3 = HealCounter.currentSession.players[target].set3 + 1
			elseif set3 == 7 and HealCounter.meritoriousService[abilityId] ~= nil then
				HealCounter.currentSession.players[target].set3 = HealCounter.currentSession.players[target].set3 + 1
			end

			if ability1 == 3 and HealCounter.rapid[abilityId] ~= nil then
				HealCounter.currentSession.players[target].ability1 = HealCounter.currentSession.players[target].ability1 + 1
			elseif ability1 == 4 and HealCounter.minorberserk[abilityId] ~= nil then
				HealCounter.currentSession.players[target].ability1 = HealCounter.currentSession.players[target].ability1 + 1
			end
		end
	end

	if HealCounter.siegeShield[abilityId] ~= nil and HealCounter.SV.trackingAbility1 == 5 and HealCounter.SV.displayScreen == true then
		HealCounter.debugLog("Siege Shield used!", 1)

		HealCounter.siegeShieldTimestamp = GetTimeStamp()
	end

	if result ~= ACTION_RESULT_HEAL and result ~= ACTION_RESULT_CRITICAL_HEAL then
		return
	end

	HealCounter.debugLog("You just healed " .. target .. " for " .. hitValue .. " with " .. abilityName, 1)

	if HealCounter.earthgore[abilityId] ~= nil and HealCounter.earthgoreTimestamp == 0 and (HealCounter.SV.trackingSet1 == 2 or HealCounter.SV.trackingSet2 == 2 or HealCounter.SV.trackingSet3 == 2) and HealCounter.SV.displayScreen == true then
		HealCounter.debugLog("Earthgore used!", 1)

		HealCounter.earthgoreTimestamp = GetTimeStamp()
	end

	local wasCrit = false

	if result == ACTION_RESULT_CRITICAL_HEAL then
		wasCrit = true
	end

	if HealCounter.currentSession.players[target].atName == 'Unknown' and HealCounter.SV.trackingLevel == 1 then
		if targetType == COMBAT_UNIT_TYPE_NONE then
			HealCounter.currentSession.players[target].atName = "NPC"
		end
	end

	HealCounter.UpdateAbilityInfo(abilityId, abilityName, hitValue, wasCrit)
	HealCounter.UpdatePlayerHealInfo(target, hitValue);
end

-- Whenever you rez someone
function HealCounter:OnRez(targetCharacterName, result, targetDisplayName)
	HealCounter.InitializePlayerArray(targetCharacterName)

	HealCounter.UpdateWindow()

	if (HealCounter.SV.utilizePopup == false and HealCounter.SV.displayScreen == false) or (HealCounter.SV.utilizePopup == false and HealCounter.SV.showTotalPlayersRezzed == false) then
		return
	end

	HealCounter.debugLog("Target Character Name: "..targetCharacterName, 3)
	HealCounter.debugLog("Target Display Name: "..targetDisplayName, 3)
	HealCounter.debugLog("Result:"..result, 3)

	if HealCounter.SV.rezNotification == true then
		local playerName = targetCharacterName

		if HealCounter.SV.purgeName == false then
			if HealCounter.currentSession.players[playerName] ~= nil and HealCounter.currentSession.players[playerName].atName ~= 'Unknown' then
				playerName = HealCounter.currentSession.players[playerName].atName
			end
		end

		local message = playerName .. " has "

		if result == RESURRECT_RESULT_SUCCESS then
			message = message .. "accepted"
		else
			message = message .. "declined"
		end

		message = message .. " your rez request"

		HealCounter.ScreenNotification(message, 2500)
	end

	if HealCounter.SV.rezType == false then
		if result ~= RESURRECT_RESULT_SUCCESS then
			return
		end
	end

	if HealCounter.SV.trackingLevel == 3 then
		if HealCounter.currentSession.players[targetCharacterName].playerInGroup == false then
			return
		end
	end

	HealCounter.debugLog("You just rezzed "..targetCharacterName, 1)
	HealCounter.totalPlayersRezzed = HealCounter.totalPlayersRezzed + 1

	-- see how much of each player I rezzed
	HealCounter.currentSession.players[targetCharacterName].numRezzed = HealCounter.currentSession.players[targetCharacterName].numRezzed + 1

	HealCounter.UpdateWindow()
end

-- Updates the player's At Name
function HealCounter.UpdateAtName(unitTag)
	local playerName = zo_strformat("<<1>>", GetUnitName(unitTag))

	if playerName == '' then
		return
	end

	HealCounter.InitializePlayerArray(playerName)

	if HealCounter.currentSession.players[playerName] ~= nil then
		if HealCounter.currentSession.players[playerName].atName == 'Unknown' then
			local unitType = GetUnitType(unitTag)

			if unitType == COMBAT_UNIT_TYPE_NONE then
				HealCounter.currentSession.players[playerName].atName = "NPC"
			elseif unitType == COMBAT_UNIT_TYPE_PLAYER then
				HealCounter.currentSession.players[playerName].atName = GetUnitDisplayName(unitTag)
			end
		end

		if HealCounter.currentSession.players[playerName].playerInGroup == true and HealCounter.currentSession.players[playerName].unitTag ~= unitTag and unitTag ~= nil then
			HealCounter.currentSession.players[playerName].unitTag = unitTag
		end
	end
end

-- Puts the unit (player / NPC) in session
function HealCounter.InitializePlayerArray(playerName)
	local playerName = zo_strformat("<<1>>", playerName)

	if string.len(playerName) <= 0 or playerName == 'Offline' then
		return
	end
	
	if HealCounter.currentSession.players[playerName] == nil then
		HealCounter.debugLog("Initializing Player: "..playerName, 2)

		local defaultPlayerArray = {}

		defaultPlayerArray.ability1A = 0
		defaultPlayerArray.ability1T = 0
		defaultPlayerArray.set1A = 0
		defaultPlayerArray.set1T = 0
		defaultPlayerArray.set2A = 0
		defaultPlayerArray.set2T = 0
		defaultPlayerArray.set3A = 0
		defaultPlayerArray.set3T = 0
		defaultPlayerArray.set1 = 0
		defaultPlayerArray.set2 = 0
		defaultPlayerArray.set3 = 0
		defaultPlayerArray.ability1 = 0
		defaultPlayerArray.numRezzed = 0
		defaultPlayerArray.numHealed = 0
		defaultPlayerArray.numHealedTPH = 0
		defaultPlayerArray.atName = 'Unknown'
		defaultPlayerArray.unitTag = nil
		defaultPlayerArray.playerInGroup = HealCounter.IsPlayerInGroup(playerName)
		defaultPlayerArray.inSupportRange = false

		HealCounter.currentSession.players[playerName] = defaultPlayerArray
	end
end

-- Puts the ability in session
function HealCounter.InitializeAbilityArray(abilityId, abilityName)
	local abilityName = zo_strformat("<<1>>", abilityName)

	if string.len(abilityName) <= 0 then
		return
	end
	
	if HealCounter.currentSession.abilities[abilityId] == nil then
		HealCounter.debugLog("Initializing Ability: "..abilityName.." ("..abilityId..")", 1)

		local defaultAbilityArray = {}

		defaultAbilityArray.Name = abilityName
		defaultAbilityArray.used = 0
		defaultAbilityArray.totalHealed = 0
		defaultAbilityArray.minHeal = 0
		defaultAbilityArray.maxHeal = 0
		defaultAbilityArray.totalCrit = 0

		HealCounter.currentSession.abilities[abilityId] = defaultAbilityArray
	end
end

-- Updates ability session data
function HealCounter.UpdateAbilityInfo(abilityId, abilityName, healedValue, wasCrit)
	HealCounter.InitializeAbilityArray(abilityId, abilityName)

	HealCounter.currentSession.abilities[abilityId].used = HealCounter.currentSession.abilities[abilityId].used + 1
	HealCounter.currentSession.abilities[abilityId].totalHealed = HealCounter.currentSession.abilities[abilityId].totalHealed + healedValue

	if healedValue < HealCounter.currentSession.abilities[abilityId].minHeal or HealCounter.currentSession.abilities[abilityId].minHeal == 0 then
		HealCounter.currentSession.abilities[abilityId].minHeal = healedValue
	end
	
	if healedValue > HealCounter.currentSession.abilities[abilityId].maxHeal or HealCounter.currentSession.abilities[abilityId].maxHeal == 0 then
		HealCounter.currentSession.abilities[abilityId].maxHeal = healedValue
	end
	
	if wasCrit == true then
		HealCounter.currentSession.abilities[abilityId].totalCrit = HealCounter.currentSession.abilities[abilityId].totalCrit + 1
	end
end

-- Updates session information being tracked
function HealCounter.UpdatePlayerHealInfo(playerName, healedValue)
	local playerName = zo_strformat("<<1>>", playerName)

	HealCounter.debugLog("Inside UpdateHealInfo for: "..playerName, 2)

	HealCounter.InitializePlayerArray(playerName)
	
	if HealCounter.currentSession.players[playerName].numHealedTPH == 0 and HealCounter.currentSession.players[playerName].atName ~= "NPC" then
		HealCounter.currentSession.players[playerName].numHealedTPH = 1
		HealCounter.totalUniquePlayersHealed = HealCounter.totalUniquePlayersHealed + 1

		if HealCounter.healStreak[HealCounter.totalUniquePlayersHealed] ~= nil then
			HealCounter.currentLevel = HealCounter.totalUniquePlayersHealed

			if HealCounter.SV.systemMessages == true then
				d("New Heal Counter Level: "..HealCounter.healStreak[HealCounter.totalUniquePlayersHealed].." ("..HealCounter.totalUniquePlayersHealed..")")
			end
		end
	end

	HealCounter.currentSession.players[playerName].numHealed = HealCounter.currentSession.players[playerName].numHealed + 1
end

-- Updates the Purge Indicator
function HealCounter.doPurgeCalculations(unitTag)
	-- don't do purge calculations while moving it around
	if HealCounter.SV.unlocked == true or HealCounter.SV.purgeIndicator == 1 then
		return
	end

	if IsUnitDead('player') == true then
		HealCounterPurgeIndicator:SetHidden(true)
		HealCounterPurgeIndicatorPurgeImage:SetHidden(true)
		HealCounterPurgeIndicatorPurgeLabel:SetHidden(true)
		return
	end

	local playerPurgeTracker = 0
	local debuffFound = ''

	for buffIndex = 1, GetNumBuffs(unitTag) do
		local buffName, _, _, _, _, _, _, effectType, _, _, abilityId = GetUnitBuffInfo(unitTag, buffIndex)

		--[[if string.find(buffName, 'ESO') or string.find(buffName, 'Frothgar') or string.find(buffName, 'Boon') or string.find(buffName, 'Minor') or string.find(buffName, 'Purge') then
			
		else
			d("(De)Buff: "..tostring(buffName))
		end]]

		if effectType == BUFF_EFFECT_TYPE_DEBUFF then
			if HealCounter.SV.purgePVPDebuffs == true and HealCounter.playerInPvP == true then
				buffName = zo_strformat("<<1>>", buffName)
				buffName = string.lower(buffName)

				if string.find(buffName, 'maim') or string.find(buffName, 'defile') or string.find(buffName, 'poison') or string.find(buffName, 'immobilize') then
					playerPurgeTracker = playerPurgeTracker + 1

					if HealCounter.SV.purgeImage == true and debuffFound == '' then
						debuffFound = buffName
					end
				end
			else
				playerPurgeTracker = playerPurgeTracker + 1
			end
		end
	end

	if playerPurgeTracker > 0 then
		if HealCounter.SV.purgeImage == true and HealCounter.SV.purgePVPDebuffs == true and HealCounter.playerInPvP == true then
			local purgeName = ''

			if string.find(debuffFound, 'immobilize') then
				HealCounterPurgeIndicatorPurgeImage:SetTexture('esoui/art/icons/ability_debuff_root.dds')
				purgeName = 'Immobilize'
			elseif string.find(debuffFound, 'poison') then
				HealCounterPurgeIndicatorPurgeImage:SetTexture('esoui/art/icons/crafting_poison_002_red_005.dds')
				purgeName = 'Poison'
			elseif string.find(debuffFound, 'maim') then
				HealCounterPurgeIndicatorPurgeImage:SetTexture('esoui/art/icons/ability_debuff_major_maim.dds')
				purgeName = 'Maim'
			elseif string.find(debuffFound, 'defile') then
				HealCounterPurgeIndicatorPurgeImage:SetTexture('esoui/art/icons/ability_debuff_major_defile.dds')
				purgeName = 'Defile'
			end

			HealCounterPurgeIndicator:SetHidden(false)
			HealCounterPurgeIndicatorPurgeImage:SetHidden(false)
			HealCounterPurgeIndicatorPurgeLabel:SetHidden(false)
			HealCounterPurgeIndicatorPurgeLabel:SetColor(255, 0, 0, 255)
			HealCounterPurgeIndicatorPurgeLabel:SetText("Purge " .. purgeName .. " (" .. playerPurgeTracker .. ")")
		else
			local displayName = ''

			if HealCounter.playerInPvP == true or unitTag == 'player' then
				displayName = HealCounter.playerName

				if HealCounter.SV.purgeName == false then
					displayName = HealCounter.playerUserID
				end
			else
				displayName = zo_strformat("<<1>>", GetUnitName(unitTag))

				if HealCounter.SV.purgeName == false then
					displayName = zo_strformat("<<1>>", GetUnitDisplayName(unitTag))
				end
			end

			if displayName == '' or displayName == nil then
				return
			end

			HealCounterPurgeIndicator:SetHidden(false)
			HealCounterPurgeIndicatorPurgeLabel:SetHidden(false)
			HealCounterPurgeIndicatorPurgeImage:SetHidden(true)
			HealCounterPurgeIndicatorPurgeLabel:SetColor(255, 0, 0, 255)
			HealCounterPurgeIndicatorPurgeLabel:SetText("Purge " .. displayName .. " (" .. playerPurgeTracker .. ")")
		end
	elseif playerPurgeTracker <= 0 then
		HealCounterPurgeIndicator:SetHidden(true)
	end
end

-- update who's in group
function HealCounter.updateGroupMembers()
	-- if you left or joined, clear group buff data
	for playerName, playerInfo in pairs(HealCounter.currentSession.players) do
		HealCounter.currentSession.players[playerName].playerInGroup = HealCounter.IsPlayerInGroup(playerName)
	end
end

-- Update the display window
function HealCounter.UpdateWindow()
	HealCounter.frameRate = GetFramerate()

	if HealCounter.frameRate <= HealCounter.SV.trackFPSNum then
		return
	end

	local currentTime = GetTimeStamp()

	if HealCounter.SV.showTotalPlayersHealed == true then
		HealCounterWindowTPH:SetText("TPH: "..HealCounter.totalUniquePlayersHealed)
	end

	if HealCounter.SV.showTotalPlayersRezzed == true then
		HealCounterWindowTPR:SetText("TPR: "..HealCounter.totalPlayersRezzed)
	end

	if HealCounter.SV.bestTotalHealed < HealCounter.totalUniquePlayersHealed then
		HealCounter.SV.bestTotalHealed = HealCounter.totalUniquePlayersHealed
	end

	if HealCounter.SV.bestTotalRezzed < HealCounter.totalPlayersRezzed then
		HealCounter.SV.bestTotalRezzed = HealCounter.totalPlayersRezzed
	end
	
	local set1 = tonumber(HealCounter.SV.trackingSet1)
	local set2 = tonumber(HealCounter.SV.trackingSet2)
	local set3 = tonumber(HealCounter.SV.trackingSet3)

	if set1 == 1 then
		HealCounterWindowSet1:SetHidden(true)
	end

	if set2 == 1 then
		HealCounterWindowSet2:SetHidden(true)
	end

	if set3 == 1 then
		HealCounterWindowSet3:SetHidden(true)
	end

	if (set1 == 2 or set2 == 2 or set3 == 2) and HealCounter.SV.displayScreen == true then
		local earthgoreText = 'Ready'
		local earthgoreSeconds = 0

		if HealCounter.earthgoreTimestamp ~= 0 then
			local egDiff = GetDiffBetweenTimeStamps(currentTime, HealCounter.earthgoreTimestamp)

			HealCounter.debugLog("Earthgore Timestamp: "..HealCounter.earthgoreTimestamp, 3)
			HealCounter.debugLog("Current Time: "..currentTime, 3)
			HealCounter.debugLog("Earthgore Diff: "..egDiff, 3)

			earthgoreSeconds = 35 - egDiff

			if egDiff >= 35 then
				HealCounter.debugLog("Earthgore Ready!", 1)

				HealCounter.earthgoreTimestamp = 0
			else
				earthgoreText = 'Used'
			end
		end

		if set1 == 2 then
			HealCounterWindowSet1:SetText("EG: "..earthgoreText.." ("..earthgoreSeconds..")")
		end

		if set2 == 2 then
			HealCounterWindowSet2:SetText("EG: "..earthgoreText.." ("..earthgoreSeconds..")")
		end

		if set3 == 2 then
			HealCounterWindowSet3:SetText("EG: "..earthgoreText.." ("..earthgoreSeconds..")")
		end
	end

	local GroupSize = GetGroupSize()
	local set1Percentage = 0
	local set1Total = 0
	local set2Percentage = 0
	local set2Total = 0
	local set3Percentage = 0
	local set3Total = 0
	local inRange = 0
	local ability1Total = 0

	if GroupSize > 0 and HealCounter.playerInGroup == false then
		HealCounter.updateGroupMembers()
		HealCounter.playerInGroup = true
	elseif GroupSize <= 0 and HealCounter.playerInGroup == true then
		HealCounter.updateGroupMembers()
		HealCounter.playerInGroup = false
	end
	
	if GroupSize <= 0 then
		GroupSize = 1
	end

	local ability1 = HealCounter.SV.trackingAbility1

	if HealCounter.SV.purgeIndicator ~= 1 then
		if HealCounter.SV.purgeIndicator == 2 and HealCounter.playerInPvP == false then
			HealCounter.doPurgeCalculations('player')
		elseif HealCounter.SV.purgeIndicator == 3 and HealCounter.playerInPvP == true then
			HealCounter.doPurgeCalculations('player')
		elseif HealCounter.SV.purgeIndicator == 4 then
			HealCounter.doPurgeCalculations('player')
		end
	end

	if ((set1 ~= 1 or set2 ~= 1 or set3 ~= 1 or (ability1 ~= 1 and ability1 ~= 4)) and HealCounter.SV.displayScreen == true) or (HealCounter.SV.purgeIndicator ~= 1 and HealCounter.SV.purgeTrackingLevel == true and HealCounter.playerInPvP == false) then
		if HealCounter.currentSession.players ~= nil then
			for playerName, playerInfo in pairs(HealCounter.currentSession.players) do
				if HealCounter.currentSession.players[playerName].playerInGroup == true then
					if HealCounter.SV.purgeTrackingLevel == true and HealCounter.playerInPvP == false and playerInfo.unitTag ~= nil then
						HealCounter.doPurgeCalculations(playerInfo.unitTag)
					end

					if playerInfo.set1A == 1 then
						local diffNum = 30

						if set1 == 3 then
							diffNum = 15
						elseif set1 == 4 then
							diffNum = 30
						elseif set1 == 5 then
							diffNum = 10
						elseif set1 == 7 then
							diffNum = 130
						elseif set1 == 8 then
							diffNum = 35
						elseif set1 == 9 then
							diffNum = 10
						end

						local diff = GetDiffBetweenTimeStamps(currentTime, playerInfo.set1T)

						if diff > diffNum then
							HealCounter.currentSession.players[playerName].set1A = 0
							HealCounter.currentSession.players[playerName].set1T = 0
						else
							set1Total = set1Total + 1
						end
					end

					if playerInfo.set2A == 1 then
						local diffNum = 30

						if set2 == 3 then
							diffNum = 15
						elseif set2 == 4 then
							diffNum = 30
						elseif set2 == 5 then
							diffNum = 10
						elseif set2 == 7 then
							diffNum = 130
						elseif set2 == 8 then
							diffNum = 35
						elseif set2 == 9 then
							diffNum = 10
						end

						local diff = GetDiffBetweenTimeStamps(currentTime, playerInfo.set2T)

						if diff > diffNum then
							HealCounter.currentSession.players[playerName].set2A = 0
							HealCounter.currentSession.players[playerName].set2T = 0
						else
							set2Total = set2Total + 1
						end
					end

					if playerInfo.set3A == 1 then
						local diffNum = 30

						if set3 == 3 then
							diffNum = 15
						elseif set3 == 4 then
							diffNum = 30
						elseif set3 == 5 then
							diffNum = 10
						elseif set3 == 7 then
							diffNum = 130
						elseif set3 == 8 then
							diffNum = 35
						elseif set3 == 9 then
							diffNum = 10
						end

						local diff = GetDiffBetweenTimeStamps(currentTime, playerInfo.set3T)

						if diff > diffNum then
							HealCounter.currentSession.players[playerName].set3A = 0
							HealCounter.currentSession.players[playerName].set3T = 0
						else
							set3Total = set3Total + 1
						end
					end

					if playerInfo.ability1A == 1 and ability1 ~= 2 then
						local diff = GetDiffBetweenTimeStamps(currentTime, playerInfo.ability1T)
						local diffNum = 20

						if ability1 == 3 then
							diffNum = 35
						elseif ability1 == 4 then
							diffNum = 10
						end

						if diff > diffNum then
							HealCounter.currentSession.players[playerName].ability1A = 0
							HealCounter.currentSession.players[playerName].ability1T = 0
						else
							ability1Total = ability1Total + 1
						end
					elseif playerInfo.ability1A == 0 and ability1 == 3 then
						local doRapidsTracking = true

						if HealCounter.SV.onlyTrackMounted == true and HealCounter.playerIsMounted == false then
							doRapidsTracking = false
						end

						if doRapidsTracking == true then
							if playerInfo.inSupportRange == true and IsUnitInGroupSupportRange("player") == true then
								inRange = inRange + 1
							elseif GroupSize == 1 or playerName == HealCounter.playerName then
								inRange = inRange + 1
							end
						end
					end
				end
			end
		end
	end

	if (set1 == 3 or set1 == 4 or set1 == 5 or set1 == 6 or set1 == 7 or set1 == 8 or set1 == 9) and HealCounter.SV.displayScreen == true then
		if set1Total > 0 then
			set1Percentage = (set1Total / GroupSize) * 100

			if set1Percentage < 0 then
				set1Percentage = 0
			end
			
			set1Percentage = tonumber(string.format("%.0f", set1Percentage))
		end

		local set1Text = 'SET1'

		if set1 == 3 then
			set1Text = "SPC"
		elseif set1 == 4 then
			set1Text = "TRS"
		elseif set1 == 5 then
			set1Text = "GOS"
		elseif set1 == 6 then
			set1Text = "TRK"
		elseif set1 == 7 then
			set1Text = "MS"
		elseif set1 == 8 then
			set1Text = "OLO"
		elseif set1 == 9 then
			set1Text = "SB"
		end

		HealCounterWindowSet1:SetText(set1Text .. ": "..set1Percentage.."% ("..set1Total.."/"..GroupSize..")")
	end

	if (set2 == 3 or set2 == 4 or set2 == 5 or set2 == 6 or set2 == 7 or set2 == 8 or set2 == 9) and HealCounter.SV.displayScreen == true then
		if set2Total > 0 then
			set2Percentage = (set2Total / GroupSize) * 100

			if set2Percentage < 0 then
				set2Percentage = 0
			end

			set2Percentage = tonumber(string.format("%.0f", set2Percentage))
		end

		local set2Text = 'SET1'

		if set2 == 3 then
			set2Text = "SPC"
		elseif set2 == 4 then
			set2Text = "TRS"
		elseif set2 == 5 then
			set2Text = "GOS"
		elseif set2 == 6 then
			set2Text = "TRK"
		elseif set2 == 7 then
			set2Text = "MS"
		elseif set2 == 8 then
			set2Text = "OLO"
		elseif set2 == 9 then
			set2Text = "SB"
		end

		HealCounterWindowSet2:SetText(set2Text .. ": "..set2Percentage.."% ("..set2Total.."/"..GroupSize..")")
	end

	if (set3 == 3 or set3 == 4 or set3 == 5 or set3 == 6 or set3 == 7 or set3 == 8 or set3 == 9) and HealCounter.SV.displayScreen == true then
		if set3Total > 0 then
			set3Percentage = (set3Total / GroupSize) * 100

			if set3Percentage < 0 then
				set3Percentage = 0
			end

			set3Percentage = tonumber(string.format("%.0f", set3Percentage))
		end

		local set3Text = 'SET1'

		if set3 == 3 then
			set3Text = "SPC"
		elseif set3 == 4 then
			set3Text = "TRS"
		elseif set3 == 5 then
			set3Text = "GOS"
		elseif set3 == 6 then
			set3Text = "TRK"
		elseif set3 == 7 then
			set3Text = "MS"
		elseif set3 == 8 then
			set3Text = "OLO"
		elseif set3 == 9 then
			set3Text = "SB"
		end

		HealCounterWindowSet3:SetText(set3Text .. ": "..set3Percentage.."% ("..set3Total.."/"..GroupSize..")")
	end

	if ability1 ~= 1 and HealCounter.SV.displayScreen == true then
		local ability1Text = 'AB1'

		if ability1 == 3 then
			ability1Text = "RPD"
		elseif ability1 == 4 then
			ability1Text = "CBP"
		elseif ability1 == 5 then
			ability1Text = "SS"
		end

		if ability1 == 3 and HealCounter.SV.onlyTrackMounted == true and HealCounter.playerIsMounted == false then
			ability1Text = ability1Text .. ": NTM"
		elseif ability1 == 3 then
			ability1Text = ability1Text .. ": " .. inRange .. "/" .. GroupSize

			if HealCounter.SV.showAbilityNum == true then
				ability1Text = ability1Text .. " (" .. ability1Total .. "/" .. GroupSize .. ")"
			end
		elseif ability1 == 4 then
			local ability1Percentage = 0

			if ability1Total > 0 then
				ability1Percentage = (ability1Total / GroupSize) * 100

				if ability1Percentage < 0 then
					ability1Percentage = 0
				end

				ability1Percentage = tonumber(string.format("%.0f", ability1Percentage))
			end

			ability1Text = ability1Text .. ": " .. ability1Percentage .. "% (" .. ability1Total .. "/" .. GroupSize ..")"
		elseif ability1 == 5 then
			local siegeShieldText = 'Ready'
			local siegeShieldSeconds = 0

			if HealCounter.siegeShieldTimestamp ~= 0 then
				local ssDiff = GetDiffBetweenTimeStamps(currentTime, HealCounter.siegeShieldTimestamp)

				HealCounter.debugLog("Siege Shield Timestamp: "..HealCounter.siegeShieldTimestamp, 3)
				HealCounter.debugLog("Current Time: "..currentTime, 3)
				HealCounter.debugLog("Earthgore Diff: "..ssDiff, 3)

				siegeShieldSeconds = 20 - ssDiff

				if ssDiff >= 20 then
					HealCounter.debugLog("Siege Shield Ready!", 1)

					HealCounter.siegeShieldTimestamp = 0
				else
					siegeShieldText = 'Used'
				end
			end

			ability1Text = ability1Text .. ": "..siegeShieldText.." ("..siegeShieldSeconds..")"
		end

		HealCounterWindowAbility1:SetText(ability1Text)
	end
end

function HealCounter.OnPlayerCombatState(event, inCombat)
	if HealCounter.SV.totalPlayersHealedCombat == false then
		return
	end

	if inCombat ~= HealCounter.playerInCombat then
		HealCounter.playerInCombat = inCombat

		if inCombat then
			HealCounter.totalUniquePlayersHealed = 0

			if HealCounter.currentSession.players ~= nil then
				for playerName, playerInfo in pairs(HealCounter.currentSession.players) do
					HealCounter.currentSession.players[playerName].numHealedTPH = 0
				end
			end
		end
	end
end

-- so that ESO can register the addon
EVENT_MANAGER:RegisterForEvent(HealCounter.name, EVENT_ADD_ON_LOADED, HealCounter.OnAddOnLoaded)