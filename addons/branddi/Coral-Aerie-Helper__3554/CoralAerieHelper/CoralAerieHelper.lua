CoralAerieHelper = CoralAerieHelper or { }
local CoralAerieHelper = CoralAerieHelper

local EM		= GetEventManager()


CoralAerieHelper.name		= "CoralAerieHelper"
CoralAerieHelper.version		= "1.0.2"
CoralAerieHelper.varVersion 	= "1"

CoralAerieHelper.downTime	= 0

CoralAerieHelper.UPDATE_INTERVAL	= 100

CoralAerieHelper.staticStacks	= 0

CoralAerieHelper.addonLoaded = false

CoralAerieHelper.COLORS = {
	["UP"] = { -- Green
		0, 1, 0,
	},
	["DOWN"] = { -- Red
		1, 0, 0,
	},
	["BLUE"] = { -- Names
		0.5, 0.9, 0.9,
	},
}

CoralAerieHelper.iconsUp = false
CoralAerieHelper.icon1 = nil
CoralAerieHelper.icon2 = nil
CoralAerieHelper.icon3 = nil
CoralAerieHelper.icon4 = nil

CoralAerieHelper.defaults	= {
	["offsetX"]	= 500,
	["offsetY"]	= 500,
	["timerSize"]	= 48,
	["passiveHide"]	= false,
	["COLORS"]	= CoralAerieHelper.COLORS,
	["enablePurgeSoundEffect"]=false,
	["soundEffectPurge"] = "Duel_Boundary_Warning",
	["enableStormSoundEffect"]=false,
	["soundEffectStorm"] = "Duel_Boundary_Warning",
	["waveZones"] = true,

}



function CoralAerieHelper.OnPlayerCombatState(event, inCombat)

    CoralAerieHelper.checkIfAddonNeedsToBeLoadedOrUnloaded()

  if inCombat ~= CoralAerieHelper.inCombat then
    CoralAerieHelper.inCombat = inCombat
    if not inCombat then

        CoralAerieHelper.staticStacks=0
        CoralAerieHelper.currentPurgeable=0


        CoralAerieHelperFrameTime:SetText("")
        CoralAerieHelperFrameTime:SetColor(unpack(CoralAerieHelper.savedVars.COLORS.DOWN))
        CoralAerieHelper.active = false

        CoralAerieHelperFrameName1:SetHidden(true)
 	    CoralAerieHelperFrameName2:SetHidden(true)


    end
    if inCombat and CoralAerieHelper.boss3 then
        EM:RegisterForUpdate(CoralAerieHelper.name.."Update", CoralAerieHelper.UPDATE_INTERVAL, CoralAerieHelper.countDown)
        CoralAerieHelper.downTime = GetGameTimeMilliseconds()/1000 + 39	-- 40 seconds after starting combat with boss 3 procs
	    CoralAerieHelperFrameTime:SetColor(unpack(CoralAerieHelper.savedVars.COLORS.UP))
	    CoralAerieHelper.active = false
    end
    if inCombat and CoralAerieHelper.boss1 then
        EM:RegisterForUpdate(CoralAerieHelper.name.."Update", CoralAerieHelper.UPDATE_INTERVAL, CoralAerieHelper.countDown)
        CoralAerieHelper.downTime = GetGameTimeMilliseconds()/1000 + 0	-- 0 seconds after starting combat with boss 2 procs
	    CoralAerieHelperFrameTime:SetColor(unpack(CoralAerieHelper.savedVars.COLORS.DOWN))
	    CoralAerieHelper.active = false
    end


  end

end

function CoralAerieHelper.setPos()
	local x, y = CoralAerieHelper.savedVars.offsetX, CoralAerieHelper.savedVars.offsetY
	CoralAerieHelperFrame:ClearAnchors()
	CoralAerieHelperFrame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
end

function CoralAerieHelper.savePos()
	CoralAerieHelper.savedVars.offsetX = CoralAerieHelperFrame:GetLeft()
	CoralAerieHelper.savedVars.offsetY = CoralAerieHelperFrame:GetTop()
end

function CoralAerieHelper.hideOutOfCombat()
	if CoralAerieHelper.savedVars.passiveHide then
		CoralAerieHelperFrame:SetHidden(not IsUnitInCombat("player"))
	end
end

function CoralAerieHelper.hideFrame()
	CoralAerieHelperFrame:SetHidden(IsReticleHidden())
	if not IsReticleHidden() then CoralAerieHelper.hideOutOfCombat() end
end

function CoralAerieHelper.setFontSize(size)
	CoralAerieHelperFrameTime:SetFont(string.format('%s|%d|%s', '$(CHAT_FONT)', size, 'soft-shadow-thick'))
	CoralAerieHelperFrameName1:SetFont(string.format('%s|%d|%s', '$(CHAT_FONT)', size/2, 'soft-shadow-thick'))
	CoralAerieHelperFrameName2:SetFont(string.format('%s|%d|%s', '$(CHAT_FONT)', size/2, 'soft-shadow-thick'))
end

function CoralAerieHelper.countDown()
 	if not CoralAerieHelper.active and (CoralAerieHelper.downTime - GetGameTimeMilliseconds()/1000 > 0) then

 	    if CoralAerieHelper.boss1 then
 	        CoralAerieHelperFrameTime:SetText(string.format("%.1f", CoralAerieHelper.time(CoralAerieHelper.downTime)))
 	        displayStacks = CoralAerieHelper.staticStacks -1
 	        if displayStacks<1 then
 	            displayStacks=0
 	        end

 	        if ((CoralAerieHelper.downTime - GetGameTimeMilliseconds()/1000) < 1.5) then
 	            CoralAerieHelperFrameTime:SetColor(unpack(CoralAerieHelper.savedVars.COLORS.UP))
 	            CoralAerieHelperFrameName1:SetText(string.format("%s (%d)", "Safe Stacks",displayStacks))

 	        else
 	            CoralAerieHelperFrameName1:SetText(string.format("%s (%d)", "Have Stacks",displayStacks))

 	        end
 	        CoralAerieHelperFrameName1:SetHidden(false)
 	        CoralAerieHelperFrameName2:SetHidden(true)
 	    else
		    CoralAerieHelperFrameTime:SetText(string.format("%.1f", CoralAerieHelper.time(CoralAerieHelper.downTime)))

		    if CoralAerieHelper.name1 == "" then
		        if CoralAerieHelper.boss3 then
		            CoralAerieHelperFrameName1:SetHidden(false)
		            CoralAerieHelperFrameName1:SetText(string.format("%s", "Next Link"))

		        else
     	            CoralAerieHelperFrameName1:SetHidden(true)
     	        end
		    else
		        CoralAerieHelperFrameName1:SetHidden(false)
		        CoralAerieHelperFrameName1:SetText(string.format("%s", CoralAerieHelper.name1))
		    end


		    if CoralAerieHelper.name2 == "" or CoralAerieHelper.name1 == "" then
     	        CoralAerieHelperFrameName2:SetHidden(true)
		    else
		        CoralAerieHelperFrameName2:SetHidden(false)
		        CoralAerieHelperFrameName2:SetText(string.format("%s", CoralAerieHelper.name2))
		    end

		end
	else
		CoralAerieHelperFrameTime:SetColor(unpack(CoralAerieHelper.savedVars.COLORS.UP))
		CoralAerieHelperFrameTime:SetText("0.0")
	    if CoralAerieHelper.boss3 then
            if CoralAerieHelper.name1 == "" then
		        if CoralAerieHelper.boss3 then
		            CoralAerieHelperFrameName1:SetHidden(false)
		            CoralAerieHelperFrameName1:SetText(string.format("%s", "Next Link"))

		        else
     	            CoralAerieHelperFrameName1:SetHidden(true)
     	        end
		    else
		        CoralAerieHelperFrameName1:SetHidden(true)

		    end


		    if CoralAerieHelper.name2 == "" or CoralAerieHelper.name1 == "" then
     	        CoralAerieHelperFrameName2:SetHidden(true)
		    else
		        CoralAerieHelperFrameName2:SetHidden(true)

		    end

	    elseif CoralAerieHelper.boss1 then
	        CoralAerieHelperFrameName1:SetText(string.format("%s", "No Stacks"))
		    CoralAerieHelperFrameName1:SetHidden(false)
            CoralAerieHelperFrameName2:SetHidden(true)
	    elseif CoralAerieHelper.boss2 then
	        CoralAerieHelperFrameTime:SetText(string.format("%s", ""))
	        CoralAerieHelperFrameName1:SetText(string.format("%s", ""))
		    CoralAerieHelperFrameName1:SetHidden(false)
            CoralAerieHelperFrameName2:SetHidden(true)

	    else
		    CoralAerieHelperFrameName1:SetHidden(true)
            CoralAerieHelperFrameName2:SetHidden(true)
        end

		EM:UnregisterForUpdate(CoralAerieHelper.name.."Update")
	end
end

function CoralAerieHelper.time(nd)
	return math.floor((nd - GetGameTimeMilliseconds()/1000) * 10 + 0.5)/10
end




function CoralAerieHelper.addPurgable(targetUnitId, abilityId)

    if CoralAerieHelper.currentPurgeable==0 and CoralAerieHelper.savedVars.enablePurgeSoundEffect then
        PlaySound(CoralAerieHelper.savedVars.soundEffectPurge)
    end
    CoralAerieHelper.currentPurgeable=CoralAerieHelper.currentPurgeable+1



    CoralAerieHelperFrameTime:SetText(string.format("PURGE %d", CoralAerieHelper.currentPurgeable))
    CoralAerieHelperFrameTime:SetColor(unpack(CoralAerieHelper.savedVars.COLORS.DOWN))
    CoralAerieHelper.active = false

    CoralAerieHelperFrameName1:SetHidden(true)
 	CoralAerieHelperFrameName2:SetHidden(true)


end




function CoralAerieHelper.removePurgable(targetUnitId, abilityId)

    CoralAerieHelper.currentPurgeable=CoralAerieHelper.currentPurgeable-1
    if CoralAerieHelper.currentPurgeable<=0 then
        CoralAerieHelper.currentPurgeable=0

        CoralAerieHelperFrameTime:SetText("")
        CoralAerieHelperFrameTime:SetColor(unpack(CoralAerieHelper.savedVars.COLORS.DOWN))
        CoralAerieHelper.active = false

        CoralAerieHelperFrameName1:SetHidden(true)
 	    CoralAerieHelperFrameName2:SetHidden(true)
 	else
 	    CoralAerieHelperFrameTime:SetText(string.format("PURGE %d", CoralAerieHelper.currentPurgeable))
        CoralAerieHelperFrameTime:SetColor(unpack(CoralAerieHelper.savedVars.COLORS.DOWN))
        CoralAerieHelper.active = false

        CoralAerieHelperFrameName1:SetHidden(true)
 	    CoralAerieHelperFrameName2:SetHidden(true)
    end
end




function CoralAerieHelper.combatEvent(eventCode,result,isError,abilityName,abilityGraphic,abilityActionSlotType,sourceName,sourceType,targetName,targetType,hitValue,powerType,damageType,combatEventLog,sourceUnitId,targetUnitId,abilityId)

    if targetUnitId ~= nil and CoralAerieHelper.units[targetUnitId] ~= nil then
      targetName = CoralAerieHelper.units[targetUnitId].name
    end

    if abilityId == 167569 or abilityId == 158201 then
        if ACTION_RESULT_EFFECT_GAINED == result or ACTION_RESULT_EFFECT_GAINED_DURATION == result then
            if targetType == COMBAT_UNIT_TYPE_PLAYER then
                targetName = 'YOU'

            elseif not targetName or targetName == "" then
                targetName = LibUnits2.GetNameForUnitId(targetUnitId)
            end

            CoralAerieHelper.downTime = GetGameTimeMilliseconds()/1000 + 12
            CoralAerieHelper.active = false
            CoralAerieHelper.name1 = targetName


            if targetType == COMBAT_UNIT_TYPE_PLAYER then -- Pinpoint Coral Aerie - Sarydil - Pinpoint (12000) single target attack
                CoralAerieHelperFrameTime:SetColor(unpack(CoralAerieHelper.savedVars.COLORS.DOWN))
            elseif abilityId == 167569 or abilityId == 158201  then
                CoralAerieHelperFrameTime:SetColor(unpack(CoralAerieHelper.savedVars.COLORS.UP))
            end

            EM:RegisterForUpdate(CoralAerieHelper.name.."Update", CoralAerieHelper.UPDATE_INTERVAL, CoralAerieHelper.countDown)
        elseif ACTION_RESULT_EFFECT_FADED == result then
            CoralAerieHelper.downTime = GetGameTimeMilliseconds()/1000
            CoralAerieHelper.name1 = ""
            CoralAerieHelper.active = false
        end
    end


    if abilityId == 149227 or abilityId == 149225  then -- 149227 & 149225 Coral boss 3 Pre-Mind Link
        desc = "Mind Link Pre"
        if ACTION_RESULT_EFFECT_GAINED == result or ACTION_RESULT_EFFECT_GAINED_DURATION == result then

            if targetType == COMBAT_UNIT_TYPE_PLAYER then
                targetName = 'YOU'

            elseif not targetName or targetName == "" then
                targetName = LibUnits2.GetNameForUnitId(targetUnitId)
            end


            if CoralAerieHelper.name1 == "" then --abilityId == 149227 then
            	CoralAerieHelper.name1 = targetName
            else
	            CoralAerieHelper.name2 = targetName
	        end


            EM:RegisterForUpdate(CoralAerieHelper.name.."Update", CoralAerieHelper.UPDATE_INTERVAL, CoralAerieHelper.countDown)
            CoralAerieHelper.downTime = GetGameTimeMilliseconds()/1000 + 4.0	-- Time for warning that the beam is coming
	        CoralAerieHelperFrameTime:SetColor(unpack(CoralAerieHelper.savedVars.COLORS.DOWN))
	        CoralAerieHelper.active = false

        elseif ACTION_RESULT_EFFECT_FADED == result then

        else

        end
    elseif abilityId == 167437 or abilityId == 167462  then -- 167437 & 167462 Coral Boss 3 Beam
        desc = "Mind Link Beam"
        if ACTION_RESULT_EFFECT_GAINED == result or ACTION_RESULT_EFFECT_GAINED_DURATION == result then

            if targetType == COMBAT_UNIT_TYPE_PLAYER then
                targetName = 'YOU'
            elseif not targetName or targetName == "" then
                targetName = LibUnits2.GetNameForUnitId(targetUnitId)
            end



            EM:RegisterForUpdate(CoralAerieHelper.name.."Update", CoralAerieHelper.UPDATE_INTERVAL, CoralAerieHelper.countDown)
            CoralAerieHelper.downTime = GetGameTimeMilliseconds()/1000 + 25	-- 25 seconds after Mind Link starts stays active
	        CoralAerieHelperFrameTime:SetColor(unpack(CoralAerieHelper.savedVars.COLORS.DOWN))
	        CoralAerieHelper.active = false

        elseif ACTION_RESULT_EFFECT_FADED == result then


            EM:RegisterForUpdate(CoralAerieHelper.name.."Update", CoralAerieHelper.UPDATE_INTERVAL, CoralAerieHelper.countDown)
            CoralAerieHelper.downTime = GetGameTimeMilliseconds()/1000 + 20	-- 20 seconds after Mind Link procs another can proc
	        CoralAerieHelperFrameTime:SetColor(unpack(CoralAerieHelper.savedVars.COLORS.UP))
	        CoralAerieHelper.active = false

	        CoralAerieHelper.name1 = ""
	        CoralAerieHelper.name2 = ""
        else

        end


    elseif abilityId == 162279 then -- 162279 Coral boss 2 stacks
        desc = "Building Static"
        if ACTION_RESULT_EFFECT_GAINED == result or ACTION_RESULT_EFFECT_GAINED_DURATION == result then

            if targetType == COMBAT_UNIT_TYPE_PLAYER then

                CoralAerieHelper.staticStacks = CoralAerieHelper.staticStacks +1


                EM:RegisterForUpdate(CoralAerieHelper.name.."Update", CoralAerieHelper.UPDATE_INTERVAL, CoralAerieHelper.countDown)
                CoralAerieHelper.downTime = GetGameTimeMilliseconds()/1000 + 8	-- 8 seconds after for each building static
                CoralAerieHelperFrameTime:SetColor(unpack(CoralAerieHelper.savedVars.COLORS.DOWN))
                CoralAerieHelper.active = false

            end



        elseif ACTION_RESULT_EFFECT_FADED == result then
            if targetType == COMBAT_UNIT_TYPE_PLAYER then
                CoralAerieHelper.staticStacks = 0 -- clear all stacks eachtime stacks expire
            end

        end


    elseif abilityId == 158185 then -- 162279 Coral boss 2 stacks
        desc = "Dagger Storm"
        if ACTION_RESULT_EFFECT_GAINED == result or ACTION_RESULT_EFFECT_GAINED_DURATION == result then


            if CoralAerieHelper.savedVars.enableStormSoundEffect then
                PlaySound(CoralAerieHelper.savedVars.soundEffectStorm)
            end
        end

    elseif abilityId == 168776 then -- Ignite - vCA second boss small fire circles --  PURGE
        desc = "IGNITED"
        if ACTION_RESULT_EFFECT_GAINED_DURATION == result then

            CoralAerieHelper.addPurgable(targetUnitId, abilityId)
        end
        if ACTION_RESULT_EFFECT_FADED == result then

            CoralAerieHelper.removePurgable(targetUnitId, abilityId)
        end

    elseif abilityId == 168897 then -- Aperture - vCA second boss --  PURGE
        desc = "APERTURE"
        if ACTION_RESULT_EFFECT_GAINED_DURATION == result then

            CoralAerieHelper.addPurgable(targetUnitId, abilityId)
        end
        if ACTION_RESULT_EFFECT_FADED == result then

            CoralAerieHelper.removePurgable(targetUnitId, abilityId)
        end

    end

end


function CoralAerieHelper.IdentifyUnit( unitTag, unitName, unitId )

	if (not CoralAerieHelper.units[unitId] and
    (string.sub(unitTag, 1, 5) == "group" or string.sub(unitTag, 1, 6) == "player")) then
		CoralAerieHelper.units[unitId] = {
			tag = unitTag,
			name = GetUnitDisplayName(unitTag) or unitName,
		}
    CoralAerieHelper.unitsTag[unitTag] = {
      id = unitId,
      name = GetUnitDisplayName(unitTag) or unitName,
    }
	end
end



function CoralAerieHelper.BossesChanged( eventCode )
    local playerWorldZone, playerWorldX, playerWorldY, playerWorldZ = GetUnitWorldPosition("player")
    --zid = GetCurrentMapZoneIndex()
    if playerWorldZone==1301 then
	--if zid == 870 then
	    local bossName = string.lower(GetUnitName("boss1"))

        if bossName=="varallion" then
            CoralAerieHelper.boss3=true
            CoralAerieHelperFrame:SetHidden(false)

            if CoralAerieHelper.iconsUp == false then
                if  CoralAerieHelper.savedVars.waveZones then
                    CoralAerieHelper.iconsUp=true
                    CoralAerieHelper.icon1 = OSI.CreatePositionIcon(60764,29676-75,133431, "odysupporticons/icons/squares/squaretwo_red_one.dds",150, {1, 1, 1})
                    CoralAerieHelper.icon2 = OSI.CreatePositionIcon(58962,29676-75,133212, "odysupporticons/icons/squares/squaretwo_red_two.dds",150, {1, 1, 1})
                    CoralAerieHelper.icon3 = OSI.CreatePositionIcon(58967,29676-75,131423, "odysupporticons/icons/squares/squaretwo_red_three.dds",150, {1, 1, 1})
                    CoralAerieHelper.icon4 = OSI.CreatePositionIcon(60751,29676-75,131528, "odysupporticons/icons/squares/squaretwo_red_four.dds",150, {1, 1, 1})
                end


            end
        elseif bossName=="maligalig" then
            CoralAerieHelper.boss1=true
            CoralAerieHelperFrame:SetHidden(false)

        elseif bossName=="sarydil" then
            CoralAerieHelper.boss2=true
            CoralAerieHelperFrame:SetHidden(false)
            CoralAerieHelperFrameTime:SetText("")
            CoralAerieHelperFrameName1:SetText("")
            CoralAerieHelperFrameName2:SetText("")

        else
            CoralAerieHelper.boss3=false
            CoralAerieHelper.boss2=false
            CoralAerieHelper.boss1=false
            CoralAerieHelperFrame:SetHidden(true)
        end

    else

        if CoralAerieHelper.iconsUp == true then
            CoralAerieHelper.iconsUp = false

            OSI.DiscardPositionIcon(CoralAerieHelper.icon1 )
            OSI.DiscardPositionIcon(CoralAerieHelper.icon2 )
            OSI.DiscardPositionIcon(CoralAerieHelper.icon3 )
            OSI.DiscardPositionIcon(CoralAerieHelper.icon4 )
        end

        CoralAerieHelperFrame:SetHidden(true)
	end
end

function CoralAerieHelper.EffectChanged(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType )
  CoralAerieHelper.IdentifyUnit(unitTag, unitName, unitId)
end



function CoralAerieHelper.checkIfAddonNeedsToBeLoadedOrUnloaded()
    local playerWorldZone, playerWorldX, playerWorldY, playerWorldZ = GetUnitWorldPosition("player")
    --local zid = GetCurrentMapZoneIndex()
    --d("playerWorldZone"..playerWorldZone)
	if playerWorldZone==1301 then
	--if zid == 870 or zid == 871 then -- coral aries
	    CoralAerieHelper.LoadAddon()
	else
	    CoralAerieHelper.UnloadAddon()
	end
end




function CoralAerieHelper.LoadAddon()
    if CoralAerieHelper.addonLoaded == false then
        d("Coral Aerie Helper Loaded")

        EM:RegisterForEvent(CoralAerieHelper.name.."ECE", EVENT_COMBAT_EVENT, CoralAerieHelper.combatEvent)

        EM:RegisterForEvent(CoralAerieHelper.name .. "_EventBossChanged", EVENT_BOSSES_CHANGED, CoralAerieHelper.BossesChanged)

        EM:RegisterForEvent(CoralAerieHelper.name .. "_Buffs", EVENT_EFFECT_CHANGED, CoralAerieHelper.EffectChanged)
	    CoralAerieHelper.addonLoaded=true
	end
end
function CoralAerieHelper.UnloadAddon()
    if CoralAerieHelper.addonLoaded == true then
        --d("Coral Aerie Helper Unloaded")


        CoralAerieHelper.BossesChanged()


        EM:UnregisterForEvent(CoralAerieHelper.name.."ECE", EVENT_COMBAT_EVENT)

        EM:UnregisterForEvent(CoralAerieHelper.name .. "_EventBossChanged", EVENT_BOSSES_CHANGED)

        EM:UnregisterForEvent(CoralAerieHelper.name .. "_Buffs", EVENT_EFFECT_CHANGED)
	    CoralAerieHelper.addonLoaded=false
	end
end

--[[]
function CoralAerieHelper.Status()
    if CoralAerieHelper.addonLoaded then
        d("CAH Loaded")
    else
        d("CAH Unloaded")
    end
end
--]]


function CoralAerieHelper.Init(event, addon)
	if addon ~= CoralAerieHelper.name then return end

    CoralAerieHelper.units = {}
    CoralAerieHelper.unitsTag = {}

    LibUnits2.RefreshUnits()

	CoralAerieHelper.inCombat = IsUnitInCombat("player")
	CoralAerieHelper.boss3 = false
	CoralAerieHelper.boss2 = false
	CoralAerieHelper.boss1 = false
	CoralAerieHelper.name1 = ""
	CoralAerieHelper.name2 = ""

	CoralAerieHelper.currentPurgeable=0

	EM:UnregisterForEvent(CoralAerieHelper.name.."Load", EVENT_ADD_ON_LOADED)

	CoralAerieHelper.savedVars = ZO_SavedVars:New(CoralAerieHelper.name.."SavedVars", CoralAerieHelper.varVersion, nil, CoralAerieHelper.defaults)
	
	CoralAerieHelper.setFontSize(CoralAerieHelper.savedVars.timerSize)
	CoralAerieHelper.setPos()
	CoralAerieHelperFrame:SetHidden(true)
	CoralAerieHelperFrameTime:SetColor(unpack(CoralAerieHelper.savedVars.COLORS.UP))
    CoralAerieHelperFrameTime:SetHorizontalAlignment(TEXT_ALIGN_LEFT)


    CoralAerieHelperFrameName1:SetColor(unpack(CoralAerieHelper.savedVars.COLORS.BLUE))
    CoralAerieHelperFrameName2:SetColor(unpack(CoralAerieHelper.savedVars.COLORS.BLUE))
    CoralAerieHelperFrameName1:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    CoralAerieHelperFrameName2:SetHorizontalAlignment(TEXT_ALIGN_LEFT)

	CoralAerieHelper.setupMenu()


	EM:RegisterForEvent(CoralAerieHelper.name.."PassiveHide", EVENT_PLAYER_COMBAT_STATE, CoralAerieHelper.OnPlayerCombatState)


	--SLASH_COMMANDS["/cahstatus"] = CoralAerieHelper.Status

end

EM:RegisterForEvent(CoralAerieHelper.name.."Load", EVENT_ADD_ON_LOADED, CoralAerieHelper.Init)
