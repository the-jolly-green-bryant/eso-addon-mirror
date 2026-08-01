UnchainedHelper = UnchainedHelper or { }
local UnchainedHelper = UnchainedHelper



-- # add this to codes combat alerts
-- ids = {
--  [111634] = { -2, 2 }, -- Blackrose -- Footsoldier Heavy Attack
-- # aded to codes combat alerts



UnchainedHelper.name		= "UnchainedHelper"
UnchainedHelper.version		= "1.0.5"
UnchainedHelper.varVersion 	= "1"

UnchainedHelper.defaults	= {
	["wavesInChat"]	= false,
	["hintsInChatArena1"] = false,
	["hintsInChatArena2"] = false,
	["hintsInChatArena3"] = false,
	["hintsInChatArena4"] = false,
	["hintsInChatArena5"] = false,
	["tankHints"] = false,
	["healerHints"] = false,
	["dpsHints"] = false,
	["tankPosition"] = true,
	["dpsPosition"] = true,
	["nonchainAddsPosition"] = true,
	["chainAddsPosition"] = true,
	["miniPosition"] = true,
	["bossPosition"] = true,
	["removeMarkerSeconds"] = 8,
	["nextMarkerSeconds"] = 15,
	["displayPurge"] = true,
	["offsetX"]	= 500,
	["offsetY"]	= 500,
	["soundEffectPurge"] = "Duel_Boundary_Warning",
    ["footsoldierHeavy"] = true,
    ["wardenPortals"] = false,
    ["spawnNumbers"] = false,

    ["bossColor"] = "red",
    ["nochainColor"] = "green",
    ["chainColor"] = "blue",
    ["wardenPortalColor"] = "white",
    ["highDps332"] = true,
}



UnchainedHelper.inCombat = false

UnchainedHelper.currentPurgeable=0 -- how many people need purges

UnchainedHelper.eraseIconTime = 0
UnchainedHelper.icon1 = nil
UnchainedHelper.icon2 = nil
UnchainedHelper.icon3 = nil
UnchainedHelper.icon4 = nil
UnchainedHelper.icon5 = nil
UnchainedHelper.icon6 = nil
UnchainedHelper.icon7 = nil
UnchainedHelper.icon8 = nil
UnchainedHelper.icon9 = nil
UnchainedHelper.icon10 = nil

UnchainedHelper.currentRound = 0
UnchainedHelper.currentWave = 0

UnchainedHelper.lastPortalSpawn = 0


UnchainedHelper.drawNextFightIconTime = 0
UnchainedHelper.nextStage = 0
UnchainedHelper.nextRound = 0
UnchainedHelper.nextWave = 0


function UnchainedHelper.savePos()
	UnchainedHelper.savedVars.offsetX = UnchainedHelperFrame:GetLeft()
	UnchainedHelper.savedVars.offsetY = UnchainedHelperFrame:GetTop()
end

function UnchainedHelper.setPos()
	local x, y = UnchainedHelper.savedVars.offsetX, UnchainedHelper.savedVars.offsetY
	UnchainedHelperFrame:ClearAnchors()
	UnchainedHelperFrame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
end


function UnchainedHelper.addPurgable(targetUnitId, abilityId)
    if UnchainedHelper.currentPurgeable == 0 then
        if UnchainedHelper.savedVars.soundEffectPurge=="No Sound Effect" then
        end
            PlaySound(UnchainedHelper.savedVars.soundEffectPurge)
        else
    end
    UnchainedHelper.currentPurgeable=UnchainedHelper.currentPurgeable+1
    UnchainedHelperFramePurge:SetText(string.format("Purge %d", UnchainedHelper.currentPurgeable))
    if UnchainedHelper.savedVars.displayPurge then
        UnchainedHelperFrame:SetHidden(false)
    else
        UnchainedHelperFrame:SetHidden(true)
    end
end



function UnchainedHelper.removePurgable(targetUnitId, abilityId)
    UnchainedHelper.currentPurgeable=UnchainedHelper.currentPurgeable-1
    if UnchainedHelper.currentPurgeable<=0 then
        UnchainedHelper.currentPurgeable=0

        UnchainedHelperFramePurge:SetText("")
        UnchainedHelperFrame:SetHidden(true)
 	else
 	    UnchainedHelperFramePurge:SetText(string.format("Purge %d", UnchainedHelper.currentPurgeable))
        if UnchainedHelper.savedVars.displayPurge then
            UnchainedHelperFrame:SetHidden(false)
        else
            UnchainedHelperFrame:SetHidden(true)
        end
    end
end







function UnchainedHelper.combatEvent(eventCode,result,isError,abilityName,abilityGraphic,abilityActionSlotType,sourceName,sourceType,targetName,targetType,hitValue,powerType,damageType,combatEventLog,sourceUnitId,targetUnitId,abilityId)
    if abilityId == 109992 then -- poison bloom - vBRP -- AUTO PURGE
        desc = "POISONBLOOM"
        if ACTION_RESULT_EFFECT_GAINED_DURATION == result then
            --d(targetName.."("..targetUnitId.."/"..targetType..") src:"..sourceName.." ("..sourceUnitId..") ability:"..abilityName.."("..abilityId..") A "..desc)
            UnchainedHelper.addPurgable(targetUnitId, abilityId)
        end
        if ACTION_RESULT_EFFECT_FADED == result then
            --d(targetName.."("..targetUnitId.."/"..targetType..") src:"..sourceName.." ("..sourceUnitId..") ability:"..abilityName.."("..abilityId..") A faded "..desc)
            UnchainedHelper.removePurgable(targetUnitId, abilityId)
        end
    elseif abilityId == 113150 then -- ARROWPOISON - vBRP -- AUTO PURGE
        desc = "ARROWPOISON"
        if ACTION_RESULT_EFFECT_GAINED_DURATION == result then
            --d(targetName.."("..targetUnitId.."/"..targetType..") src:"..sourceName.." ("..sourceUnitId..") ability:"..abilityName.."("..abilityId..") A "..desc)
            UnchainedHelper.addPurgable(targetUnitId, abilityId)
        end
        if ACTION_RESULT_EFFECT_FADED == result then
            --d(targetName.."("..targetUnitId.."/"..targetType..") src:"..sourceName.." ("..sourceUnitId..") ability:"..abilityName.."("..abilityId..") A faded "..desc)
            UnchainedHelper.removePurgable(targetUnitId, abilityId)
        end
    end
end



function UnchainedHelper.OnPlayerCombatState(event, inCombat)
    if inCombat ~= UnchainedHelper.inCombat then
        UnchainedHelper.inCombat = inCombat
        if not inCombat then
            UnchainedHelper.currentPurgeable=0
            UnchainedHelperFramePurge:SetText("")
            UnchainedHelperFrame:SetHidden(true)
        end
    end
end

function UnchainedHelper.hideFrame()
	UnchainedHelperFramePurge:SetHidden(IsReticleHidden())
end


function UnchainedHelper.marker(x,y,z,type,number,portal)
    if UnchainedHelper.savedVars.spawnNumbers==false then
        number = ""
    end

    if type == "1" then
        icon = OSI.CreatePositionIcon(x,y,z, "UnchainedHelper/icons/circle_white1.dds",150, {1, 1, 1})
    elseif type == "2" then
        icon = OSI.CreatePositionIcon(x,y,z, "UnchainedHelper/icons/circle_white2.dds",150, {1, 1, 1})
    elseif type == "3" then
        icon = OSI.CreatePositionIcon(x,y,z, "UnchainedHelper/icons/circle_white3.dds",150, {1, 1, 1})
    elseif type == "4" then
        icon = OSI.CreatePositionIcon(x,y,z, "UnchainedHelper/icons/circle_white4.dds",150, {1, 1, 1})
    elseif type == "5" then
        icon = OSI.CreatePositionIcon(x,y,z, "UnchainedHelper/icons/circle_white5.dds",150, {1, 1, 1})
    elseif type == "6" then
        icon = OSI.CreatePositionIcon(x,y,z, "UnchainedHelper/icons/circle_white6.dds",150, {1, 1, 1})
    elseif type == "7" then
        icon = OSI.CreatePositionIcon(x,y,z, "UnchainedHelper/icons/circle_white7.dds",150, {1, 1, 1})
    elseif type == "8" then
        icon = OSI.CreatePositionIcon(x,y,z, "UnchainedHelper/icons/circle_white8.dds",150, {1, 1, 1})
    elseif type == "9" then
        icon = OSI.CreatePositionIcon(x,y,z, "UnchainedHelper/icons/circle_white9.dds",150, {1, 1, 1})



    elseif portal == true and UnchainedHelper.savedVars.wardenPortals then
        if UnchainedHelper.savedVars.wardenPortalColor=="portal" then
            number=""
        end
        icon = OSI.CreatePositionIcon(x,y,z, "UnchainedHelper/icons/circle_"..UnchainedHelper.savedVars.wardenPortalColor..number..".dds",150, {1, 1, 1})
    elseif type == "chain" and UnchainedHelper.savedVars.chainAddsPosition  then
        icon = OSI.CreatePositionIcon(x,y,z, "UnchainedHelper/icons/circle_"..UnchainedHelper.savedVars.chainColor..number..".dds",150, {1, 1, 1})
    elseif type == "nochain" and UnchainedHelper.savedVars.nonchainAddsPosition then
        icon = OSI.CreatePositionIcon(x,y,z, "UnchainedHelper/icons/circle_"..UnchainedHelper.savedVars.nochainColor..number..".dds",150, {1, 1, 1})
    elseif type == "boss" and UnchainedHelper.savedVars.bossPosition then
        icon = OSI.CreatePositionIcon(x,y,z, "UnchainedHelper/icons/circle_"..UnchainedHelper.savedVars.bossColor..number..".dds",150, {1, 1, 1})
    elseif type == "elite" and UnchainedHelper.savedVars.miniPosition then
        icon = OSI.CreatePositionIcon(x,y,z, "UnchainedHelper/icons/circle_"..UnchainedHelper.savedVars.bossColor..number..".dds",150, {1, 1, 1})
    elseif type == "group" and UnchainedHelper.savedVars.dpsPosition then
        icon = OSI.CreatePositionIcon(x,y,z, "UnchainedHelper/icons/x_white.dds",150, {1, 1, 1})
    elseif type == "tank" and UnchainedHelper.savedVars.tankPosition then
        icon = OSI.CreatePositionIcon(x,y,z, "UnchainedHelper/icons/x_pink.dds",150, {1, 1, 1})
    end


    if UnchainedHelper.icon1==nil then
        UnchainedHelper.icon1 = icon
    elseif UnchainedHelper.icon2==nil then
        UnchainedHelper.icon2 = icon
    elseif UnchainedHelper.icon3==nil then
        UnchainedHelper.icon3 = icon
    elseif UnchainedHelper.icon4==nil then
        UnchainedHelper.icon4 = icon
    elseif UnchainedHelper.icon5==nil then
        UnchainedHelper.icon5 = icon
    elseif UnchainedHelper.icon6==nil then
        UnchainedHelper.icon6 = icon
    elseif UnchainedHelper.icon7==nil then
        UnchainedHelper.icon7 = icon
    elseif UnchainedHelper.icon8==nil then
        UnchainedHelper.icon8 = icon
    elseif UnchainedHelper.icon9==nil then
        UnchainedHelper.icon9 = icon
    elseif UnchainedHelper.icon10==nil then
        UnchainedHelper.icon10 = icon
    end
end


function UnchainedHelper.NotifyNewWave(nextFight)
    --d("nextFlight:",nextFight)
	local s = UnchainedHelper.GetCurrentStage()
	local r = UnchainedHelper.currentRound
	local w = UnchainedHelper.currentWave

    if nextFight==1 then
    	s = UnchainedHelper.nextStage
	    r = UnchainedHelper.nextRound
	    w = UnchainedHelper.nextWave
	    --d(string.format("Unchained Next Arena: %s. Round: %s. Wave: %s.", s, r, w))

	    UnchainedHelper.drawNextFightIconTime = 0
        UnchainedHelper.nextStage = 0
        UnchainedHelper.nextRound = 0
        UnchainedHelper.nextWave = 0
    else
        UnchainedHelper.nextStage = s
        if UnchainedHelper.savedVars.wavesInChat then
            if s==0 then
            else
    	    d(string.format("BRP: %s.%s.%s", s, r, w))
    	    end
    	end
    end

    UnchainedHelper.ClearIcons()

    if s == 1 and r == 1 and w == 1 then
        UnchainedHelper.marker(104111,60951,70730,"nochain", "1",false) -- footsoldier
        UnchainedHelper.marker(104147,60951,66109,"nochain", "2",false) -- footsoldier
        UnchainedHelper.marker(102946,60951,66175,"nochain", "3",false) -- footsoldier


        UnchainedHelper.marker(102637,60951,66181,"chain", "4",true) -- archer
        UnchainedHelper.marker(103023,60951,70699, "chain", "5",true) -- archer
        UnchainedHelper.marker(102669,60951,70674,"chain", "6",true) -- archer

        UnchainedHelper.marker(103307,60951,68357,"group", "",false) -- group



        if nextFight==0 then
            UnchainedHelper.eraseIconTime = GetGameTimeMilliseconds() + UnchainedHelper.savedVars.removeMarkerSeconds * 1000 -- remove icons after X seconds
            UnchainedHelper.drawNextFightIconTime= GetGameTimeMilliseconds() + (UnchainedHelper.savedVars.removeMarkerSeconds+UnchainedHelper.savedVars.nextMarkerSeconds) * 1000  -- display next fight after 15 seconds
            UnchainedHelper.nextRound = 1
            UnchainedHelper.nextWave = 2
        end
    elseif s == 1 and r == 1 and w == 2 then
        UnchainedHelper.marker(105911,60951,68075,"elite", "1",false) -- cleaver
        UnchainedHelper.marker(104147,60951,66109,"chain", "2",true) -- archer
        UnchainedHelper.marker(102669,60951,70674, "chain", "3",false) -- archer
        UnchainedHelper.marker(102637,60951,66181, "chain", "4",false) -- archer
        UnchainedHelper.marker(105916,60951,67793, "group", "",false) -- group


        if nextFight==0 then
            UnchainedHelper.eraseIconTime = GetGameTimeMilliseconds() + UnchainedHelper.savedVars.removeMarkerSeconds * 1000 -- remove icons after X seconds
            UnchainedHelper.drawNextFightIconTime= GetGameTimeMilliseconds() + (UnchainedHelper.savedVars.removeMarkerSeconds+UnchainedHelper.savedVars.nextMarkerSeconds) * 1000  -- display next fight after 15 seconds
            UnchainedHelper.nextRound = 1
            UnchainedHelper.nextWave = 3
        end
    elseif s == 1 and r == 1 and w == 3 then

        UnchainedHelper.marker(105786,60955,67598,"elite", "1",false) -- dreadknight
        UnchainedHelper.marker(102842,60950,66256,"chain", "2",false) -- archer
        UnchainedHelper.marker(104111,60951,70730, "chain", "3",true) -- archer
        UnchainedHelper.marker(103023,60951,70699, "chain", "4",false) -- archer
        UnchainedHelper.marker(105916,60951,67793, "group", "",false) -- group


        if nextFight==0 then
            UnchainedHelper.eraseIconTime = GetGameTimeMilliseconds() + UnchainedHelper.savedVars.removeMarkerSeconds * 1000 -- remove icons after X seconds
            UnchainedHelper.drawNextFightIconTime= GetGameTimeMilliseconds() + (UnchainedHelper.savedVars.removeMarkerSeconds+UnchainedHelper.savedVars.nextMarkerSeconds) * 1000  -- display next fight after 15 seconds
            UnchainedHelper.nextRound = 2
            UnchainedHelper.nextWave = 1
            if UnchainedHelper.savedVars.hintsInChatArena1 and (UnchainedHelper.savedVars.tankHints or UnchainedHelper.savedVars.dpsHints or UnchainedHelper.savedVars.healerHints) then
                d("UG1.1.3: dps stay against gate until tank chains in archers, else they may start taking aim out of chain range, this strat repeats several times in this arena")
            end
        end
    elseif s == 1 and r == 2 and w == 1 then

        UnchainedHelper.marker(102637,60951,66181,"nochain", "1",false) -- footsoldier
        UnchainedHelper.marker(102669,60951,70674,"nochain", "2",false) -- footsoldier
        UnchainedHelper.marker(103023,60951,70699,"chain", "3",true) -- archer
        UnchainedHelper.marker(105786,60955,67598, "chain", "4",true) -- archer
        UnchainedHelper.marker(104111,60951,70730, "elite", "5",false) -- mage
        UnchainedHelper.marker(104082,60951,70087, "group", "",false) -- group




        if nextFight==0 then
            UnchainedHelper.eraseIconTime = GetGameTimeMilliseconds() + UnchainedHelper.savedVars.removeMarkerSeconds * 1000 -- remove icons after X seconds
            UnchainedHelper.drawNextFightIconTime= GetGameTimeMilliseconds() + (UnchainedHelper.savedVars.removeMarkerSeconds+UnchainedHelper.savedVars.nextMarkerSeconds) * 1000  -- display next fight after 15 seconds
            UnchainedHelper.nextRound = 2
            UnchainedHelper.nextWave = 2
        end
    elseif s == 1 and r == 2 and w == 2 then

        UnchainedHelper.marker(102669,60951,70674, "chain", "1",true) -- archer
        UnchainedHelper.marker(104147,60951,66109, "chain", "2",true) -- archer
        UnchainedHelper.marker(104111,60951,70730,"nochain", "3",false) -- footsoldier
        UnchainedHelper.marker(103023,60951,70699, "nochain", "4",false) -- footsoldier
        UnchainedHelper.marker(102946,60951,66175, "nochain", "5",false) -- footsoldier
        UnchainedHelper.marker(102637,60951,66181, "nochain", "6",false) -- footsoldier
        UnchainedHelper.marker(105786,60955,67598, "nochain", "7",false) -- footsoldier
        UnchainedHelper.marker(105911,60951,68075, "nochain", "8",false) -- footsoldier
        UnchainedHelper.marker(103307,60951,68357, "group", "",false) -- group


        if nextFight==0 then
            UnchainedHelper.eraseIconTime = GetGameTimeMilliseconds() + UnchainedHelper.savedVars.removeMarkerSeconds * 1000 -- remove icons after X seconds
            UnchainedHelper.drawNextFightIconTime= GetGameTimeMilliseconds() + (UnchainedHelper.savedVars.removeMarkerSeconds+UnchainedHelper.savedVars.nextMarkerSeconds) * 1000  -- display next fight after 15 seconds
            UnchainedHelper.nextRound = 2
            UnchainedHelper.nextWave = 3
        end

    elseif s == 1 and r == 2 and w == 3 then


        UnchainedHelper.marker(104111,60951,70730,"chain", "1",true) -- archer
        UnchainedHelper.marker(102669,60951,70674, "chain", "2",false) -- archer
        UnchainedHelper.marker(104147,60951,66109,"chain", "3",true) -- archer
        UnchainedHelper.marker(102637,60951,66181, "chain", "4",false) -- archer

        UnchainedHelper.marker(105911,60951,68075, "elite", "5",false) -- dreadknight

        UnchainedHelper.marker(103307,60951,68357, "group", "",false) -- group


        if nextFight==0 then
            UnchainedHelper.eraseIconTime = GetGameTimeMilliseconds() + UnchainedHelper.savedVars.removeMarkerSeconds * 1000 -- remove icons after X seconds
            UnchainedHelper.drawNextFightIconTime= GetGameTimeMilliseconds() + (UnchainedHelper.savedVars.removeMarkerSeconds+UnchainedHelper.savedVars.nextMarkerSeconds) * 1000  -- display next fight after 15 seconds
            UnchainedHelper.nextRound = 3
            UnchainedHelper.nextWave = 1
        end
    elseif s == 1 and r == 3 and w == 1 then

        UnchainedHelper.marker(104111,60951,70730,"chain", "1",true) -- archer
        UnchainedHelper.marker(102669,60951,70674, "chain", "2",false) -- archer
        UnchainedHelper.marker(104147,60951,66109,"chain", "3",true) -- archer
        UnchainedHelper.marker(102637,60951,66181, "chain", "4",false) -- archer

        UnchainedHelper.marker(105786,60955,67598, "elite", "5",false) -- cleaver

        UnchainedHelper.marker(105916,60951,67793, "group", "",false) -- group


        if nextFight==0 then
            UnchainedHelper.eraseIconTime = GetGameTimeMilliseconds() + UnchainedHelper.savedVars.removeMarkerSeconds * 1000 -- remove icons after X seconds
            UnchainedHelper.drawNextFightIconTime= GetGameTimeMilliseconds() + (UnchainedHelper.savedVars.removeMarkerSeconds+UnchainedHelper.savedVars.nextMarkerSeconds) * 1000  -- display next fight after 15 seconds
            UnchainedHelper.nextRound = 3
            UnchainedHelper.nextWave = 2
        end
    elseif s == 1 and r == 3 and w == 2 then

        UnchainedHelper.marker(104111,60951,70730, "chain", "1",false) -- archer
        UnchainedHelper.marker(104147,60951,66109, "chain", "2",true) -- archer
        UnchainedHelper.marker(102669,60951,70674, "elite", "3",false) -- cleaver
        UnchainedHelper.marker(102946,60951,66175, "elite", "4",false) -- mage

        UnchainedHelper.marker(102962,60951,66815, "group", "",false) -- group

        if nextFight==0 then
            UnchainedHelper.eraseIconTime = GetGameTimeMilliseconds() + UnchainedHelper.savedVars.removeMarkerSeconds * 1000 -- remove icons after X seconds
            UnchainedHelper.drawNextFightIconTime= GetGameTimeMilliseconds() + (UnchainedHelper.savedVars.removeMarkerSeconds+UnchainedHelper.savedVars.nextMarkerSeconds) * 1000  -- display next fight after 15 seconds
            UnchainedHelper.nextRound = 3
            UnchainedHelper.nextWave = 3

        end

    elseif s == 1 and r == 3 and w == 3 then

        UnchainedHelper.marker(102669,60951,70674, "chain", "1",false) -- archer
        UnchainedHelper.marker(105911,60951,68075, "chain", "2",true) -- archer
        UnchainedHelper.marker(102637,60951,66181, "chain", "3",true) -- archer
        UnchainedHelper.marker(105786,60955,67598, "elite", "4",false) -- dreadknight
        UnchainedHelper.marker(104147,60951,66109, "elite", "5",false) -- mage

        UnchainedHelper.marker(104158,60950,66667, "group", "",false) -- group

        if nextFight==0 then
            UnchainedHelper.eraseIconTime = GetGameTimeMilliseconds() + UnchainedHelper.savedVars.removeMarkerSeconds * 1000 -- remove icons after X seconds
            UnchainedHelper.drawNextFightIconTime= GetGameTimeMilliseconds() + (UnchainedHelper.savedVars.removeMarkerSeconds+UnchainedHelper.savedVars.nextMarkerSeconds) * 1000  -- display next fight after 15 seconds
            UnchainedHelper.nextRound = 4
            UnchainedHelper.nextWave = 1
            if UnchainedHelper.savedVars.hintsInChatArena1 and (UnchainedHelper.savedVars.tankHints) then
                d("UG1.3.3: tank stack everything on mage")
            end
            if UnchainedHelper.savedVars.hintsInChatArena1 and (UnchainedHelper.savedVars.dpsHints or UnchainedHelper.savedVars.healerHints) then
                d("UG1.3.3: dps ult on mage and dreadknight")
            end
        end

    elseif s == 1 and r == 4 and w == 1 then

        UnchainedHelper.marker(103023,60951,70699, "elite", "1",false) -- cleaver
        UnchainedHelper.marker(102946,60951,66175, "elite", "2",false) -- cleaver
        UnchainedHelper.marker(105911,60951,68075, "chain", "3",true) -- archer
        UnchainedHelper.marker(103307,60951,68357, "group", "",false) -- group

        if nextFight==0 then
            UnchainedHelper.eraseIconTime = GetGameTimeMilliseconds() + UnchainedHelper.savedVars.removeMarkerSeconds * 1000 -- remove icons after X seconds
            UnchainedHelper.drawNextFightIconTime= GetGameTimeMilliseconds() + (UnchainedHelper.savedVars.removeMarkerSeconds+UnchainedHelper.savedVars.nextMarkerSeconds) * 1000  -- display next fight after 15 seconds
            UnchainedHelper.nextRound = 4
            UnchainedHelper.nextWave = 2
        end


    elseif s == 1 and r == 4 and w == 2 then


        UnchainedHelper.marker(102669,60951,70674, "elite", "1",false) -- mage
        UnchainedHelper.marker(102637,60951,66181, "elite", "2",false) -- mage
        UnchainedHelper.marker(105911,60951,68075, "elite", "3",false) -- cleaver

        UnchainedHelper.marker(104111,60951,70730, "chain", "4",false) -- archer
        UnchainedHelper.marker(104147,60951,66109, "chain", "5",true) -- archer

        UnchainedHelper.marker(102817,60951,69539, "tank", "",false) -- tank

        UnchainedHelper.marker(102815,60951,66762, "group", "",false) -- group

        if nextFight==0 then
            UnchainedHelper.eraseIconTime = GetGameTimeMilliseconds() + UnchainedHelper.savedVars.removeMarkerSeconds * 1000 -- remove icons after X seconds
            UnchainedHelper.drawNextFightIconTime= GetGameTimeMilliseconds() + (UnchainedHelper.savedVars.removeMarkerSeconds+UnchainedHelper.savedVars.nextMarkerSeconds) * 1000  -- display next fight after 15 seconds
            UnchainedHelper.nextRound = 4
            UnchainedHelper.nextWave = 3
            if UnchainedHelper.savedVars.hintsInChatArena1 and (UnchainedHelper.savedVars.tankHints) then
                d("UG1.4.2: tank chain archer to dps's mage, no taunt, move to other mage/cleaver build 2nd stack")
            end
        end


    elseif s == 1 and r == 4 and w == 3 then

        UnchainedHelper.marker(104111,60951,70730, "elite", "1",false) -- dreadknight
        UnchainedHelper.marker(104147,60951,66109, "elite", "2",false) -- dreadnight

        UnchainedHelper.marker(102669,60951,70674, "chain", "3",true) -- archer
        UnchainedHelper.marker(105786,60955,67598, "chain", "4",true) -- archer

        UnchainedHelper.marker(103307,60951,68357, "group", "",false) -- group

        if nextFight==0 then
            UnchainedHelper.eraseIconTime = GetGameTimeMilliseconds() + UnchainedHelper.savedVars.removeMarkerSeconds * 1000 -- remove icons after X seconds
            UnchainedHelper.drawNextFightIconTime= GetGameTimeMilliseconds() + (UnchainedHelper.savedVars.removeMarkerSeconds+UnchainedHelper.savedVars.nextMarkerSeconds) * 1000  -- display next fight after 15 seconds
            UnchainedHelper.nextRound = 5
            UnchainedHelper.nextWave = 1
        end


    elseif s == 1 and r == 5 and w == 1 then

        UnchainedHelper.marker(103753,60951,68455, "boss", "1",false) -- boss

        UnchainedHelper.marker(103500,60951,68410, "tank", "",false) -- tank

        UnchainedHelper.marker(104089,60951,68447, "group", "",false) -- healer
        UnchainedHelper.marker(103738,60951,68016, "group", "",false) -- right dps
        UnchainedHelper.marker(103772,60951,68887, "group", "",false) -- left dps

        if nextFight==0 then
            UnchainedHelper.eraseIconTime = GetGameTimeMilliseconds() + (UnchainedHelper.savedVars.removeMarkerSeconds/2)*1000 -- remove icons after X/2 seconds

            UnchainedHelper.drawNextFightIconTime= GetGameTimeMilliseconds() + (UnchainedHelper.savedVars.removeMarkerSeconds+UnchainedHelper.savedVars.nextMarkerSeconds) * 1000  -- display next fight after 15 seconds

            UnchainedHelper.nextStage = 2
            UnchainedHelper.nextRound = 1
            UnchainedHelper.nextWave = 1
        end



    elseif s == 2 and r == 1 and w == 1 then

        UnchainedHelper.marker(90086,57147,61117, "chain", "1",false) -- spider
        UnchainedHelper.marker(92896,57158,62884, "chain", "2",false) -- spider
        UnchainedHelper.marker(88236,57144,62666, "chain", "3",true) -- spider

        UnchainedHelper.marker(92962,57149,64405, "nochain", "4",false) -- hackwing
        UnchainedHelper.marker(88345,57153,64110, "nochain", "5",false) -- hackwing

        UnchainedHelper.marker(89653,57151,61676, "group", "",false) -- group

        if nextFight==0 then
            UnchainedHelper.eraseIconTime = GetGameTimeMilliseconds() + UnchainedHelper.savedVars.removeMarkerSeconds * 1000 -- remove icons after X seconds
            UnchainedHelper.drawNextFightIconTime= GetGameTimeMilliseconds() + (UnchainedHelper.savedVars.removeMarkerSeconds+UnchainedHelper.savedVars.nextMarkerSeconds) * 1000  -- display next fight after 15 seconds
            UnchainedHelper.nextRound = 1
            UnchainedHelper.nextWave = 2
        end


    elseif s == 2 and r == 1 and w == 2 then


        UnchainedHelper.marker(88236,57144,62666, "elite", "1",false) -- crocadile
        UnchainedHelper.marker(92896,57158,62884, "elite", "2",false) -- crocodile

        UnchainedHelper.marker(90086,57147,61117, "chain", "3",false) -- hover
        UnchainedHelper.marker(88345,57153,64110, "chain", "4",false) -- spider

        UnchainedHelper.marker(92962,57149,64405, "chain", "5",false) -- spider

        UnchainedHelper.marker(88304,57154,63792, "chain", "6",false) -- hover


        UnchainedHelper.marker(89653,57151,61676, "group", "",false) -- group

        if nextFight==0 then
            UnchainedHelper.eraseIconTime = GetGameTimeMilliseconds() + UnchainedHelper.savedVars.removeMarkerSeconds * 1000 -- remove icons after X seconds
            UnchainedHelper.drawNextFightIconTime= GetGameTimeMilliseconds() + (UnchainedHelper.savedVars.removeMarkerSeconds+UnchainedHelper.savedVars.nextMarkerSeconds) * 1000  -- display next fight after 15 seconds
            UnchainedHelper.nextRound = 1
            UnchainedHelper.nextWave = 3
        end

    elseif s == 2 and r == 1 and w == 3 then

        UnchainedHelper.marker(90086,57147,61117, "elite", "1",false) -- beastmaster

        UnchainedHelper.marker(88345,57153,64110, "nochain", "2",false) -- hackwing
        UnchainedHelper.marker(92962,57149,64405, "nochain", "3",false) -- hackwing
        UnchainedHelper.marker(92896,57158,62884, "nochain", "4",false) -- hackwing

        UnchainedHelper.marker(89653,57151,61676, "group", "",false) -- group

        if nextFight==0 then
            UnchainedHelper.eraseIconTime = GetGameTimeMilliseconds() + UnchainedHelper.savedVars.removeMarkerSeconds * 1000 -- remove icons after X seconds
            UnchainedHelper.drawNextFightIconTime= GetGameTimeMilliseconds() + (UnchainedHelper.savedVars.removeMarkerSeconds+UnchainedHelper.savedVars.nextMarkerSeconds) * 1000  -- display next fight after 15 seconds
            UnchainedHelper.nextRound = 2
            UnchainedHelper.nextWave = 1
        end

    elseif s == 2 and r == 2 and w == 1 then

        UnchainedHelper.marker(92967,57153,63974, "chain", "1",false) -- spider
        UnchainedHelper.marker(90086,57147,61117, "chain", "2",false) -- spider
        UnchainedHelper.marker(88236,57144,62666, "chain", "3",false) -- hover
        UnchainedHelper.marker(92896,57158,62884, "chain", "4",false) -- hover
        UnchainedHelper.marker(88304,57154,63792, "chain", "5",true) -- Spider
        UnchainedHelper.marker(89784,57152,61143, "chain", "6",false) -- hover

        UnchainedHelper.marker(89653,57151,61676, "group", "",false) -- group

        if nextFight==0 then
            UnchainedHelper.eraseIconTime = GetGameTimeMilliseconds() + UnchainedHelper.savedVars.removeMarkerSeconds * 1000 -- remove icons after X seconds
            UnchainedHelper.drawNextFightIconTime= GetGameTimeMilliseconds() + (UnchainedHelper.savedVars.removeMarkerSeconds+UnchainedHelper.savedVars.nextMarkerSeconds) * 1000  -- display next fight after 15 seconds
            UnchainedHelper.nextRound = 2
            UnchainedHelper.nextWave = 2
        end

    elseif s == 2 and r == 2 and w == 2 then


        UnchainedHelper.marker(90086,57147,61117, "elite", "1",false) -- Haj
        UnchainedHelper.marker(92962,57149,64405, "elite", "2",false) -- crocodile

        UnchainedHelper.marker(88345,57153,64110, "chain", "3",true) -- spider
        UnchainedHelper.marker(88236,57144,62666, "chain", "4",true) -- spider

        UnchainedHelper.marker(92896,57158,62884, "chain", "5",false) -- spider

        UnchainedHelper.marker(89653,57151,61676, "group", "",false) -- group

        if nextFight==0 then
            UnchainedHelper.eraseIconTime = GetGameTimeMilliseconds() + UnchainedHelper.savedVars.removeMarkerSeconds * 1000 -- remove icons after X seconds
            UnchainedHelper.drawNextFightIconTime= GetGameTimeMilliseconds() + (UnchainedHelper.savedVars.removeMarkerSeconds+UnchainedHelper.savedVars.nextMarkerSeconds) * 1000  -- display next fight after 15 seconds
            UnchainedHelper.nextRound = 2
            UnchainedHelper.nextWave = 3
            if UnchainedHelper.savedVars.hintsInChatArena2 and (UnchainedHelper.savedVars.tankHints or UnchainedHelper.savedVars.dpsHints or UnchainedHelper.savedVars.healerHints) then
                d("UH2.2.2: dps Haj from front, ults")
            end
        end

    elseif s == 2 and r == 2 and w == 3 then

        UnchainedHelper.marker(92967,57153,63974, "chain", "1",false) -- spider
        UnchainedHelper.marker(88236,57144,62666, "chain", "2",true) -- spider
        UnchainedHelper.marker(88304,57154,63792, "chain", "3",true) -- spider

        UnchainedHelper.marker(89784,57152,61143, "elite", "4",false) -- beastmaster

        UnchainedHelper.marker(89653,57151,61676, "group", "",false) -- group

        if nextFight==0 then
            UnchainedHelper.eraseIconTime = GetGameTimeMilliseconds() + UnchainedHelper.savedVars.removeMarkerSeconds * 1000 -- remove icons after X seconds
            UnchainedHelper.drawNextFightIconTime= GetGameTimeMilliseconds() + (UnchainedHelper.savedVars.removeMarkerSeconds+UnchainedHelper.savedVars.nextMarkerSeconds) * 1000  -- display next fight after 15 seconds
            UnchainedHelper.nextRound = 3
            UnchainedHelper.nextWave = 1
        end

    elseif s == 2 and r == 3 and w == 1 then

        UnchainedHelper.marker(92967,57153,63974, "nochain", "1",false) -- hackwing
        UnchainedHelper.marker(88304,57154,63792, "nochain", "2",false) -- hackwing

        UnchainedHelper.marker(88345,57153,64110, "chain", "3",true) -- spider
        UnchainedHelper.marker(92962,57149,64405, "chain", "4",false) -- spider

        UnchainedHelper.marker(89784,57152,61143, "elite", "5",false) -- troll

        UnchainedHelper.marker(89653,57151,61676, "group", "",false) -- group

        if nextFight==0 then
            UnchainedHelper.eraseIconTime = GetGameTimeMilliseconds() + UnchainedHelper.savedVars.removeMarkerSeconds * 1000 -- remove icons after X seconds
            UnchainedHelper.drawNextFightIconTime= GetGameTimeMilliseconds() + (UnchainedHelper.savedVars.removeMarkerSeconds+UnchainedHelper.savedVars.nextMarkerSeconds) * 1000  -- display next fight after 15 seconds
            UnchainedHelper.nextRound = 3
            UnchainedHelper.nextWave = 2
        end

    elseif s == 2 and r == 3 and w == 2 then

        UnchainedHelper.marker(90086,57147,61117, "elite", "1",false) -- troll
        UnchainedHelper.marker(88345,57153,64110, "elite", "2",false) -- crocodile
        UnchainedHelper.marker(92962,57149,64405, "elite", "3",false) -- crocodile

        UnchainedHelper.marker(89653,57151,61676, "group", "",false) -- group

        if nextFight==0 then
            UnchainedHelper.eraseIconTime = GetGameTimeMilliseconds() + UnchainedHelper.savedVars.removeMarkerSeconds * 1000 -- remove icons after X seconds
            UnchainedHelper.drawNextFightIconTime= GetGameTimeMilliseconds() + (UnchainedHelper.savedVars.removeMarkerSeconds+UnchainedHelper.savedVars.nextMarkerSeconds) * 1000  -- display next fight after 15 seconds
            UnchainedHelper.nextRound = 3
            UnchainedHelper.nextWave = 3
        end


    elseif s == 2 and r == 3 and w == 3 then

        UnchainedHelper.marker(88236,57144,62666, "elite", "1",false) -- troll
        UnchainedHelper.marker(92896,57158,62884, "elite", "2",false) -- beastmaster

        UnchainedHelper.marker(90671,57145,63240, "group", "",false) -- group

        if nextFight==0 then
            UnchainedHelper.eraseIconTime = GetGameTimeMilliseconds() + UnchainedHelper.savedVars.removeMarkerSeconds * 1000 -- remove icons after X seconds
            UnchainedHelper.drawNextFightIconTime= GetGameTimeMilliseconds() + (UnchainedHelper.savedVars.removeMarkerSeconds+UnchainedHelper.savedVars.nextMarkerSeconds) * 1000  -- display next fight after 15 seconds
            UnchainedHelper.nextRound = 4
            UnchainedHelper.nextWave = 1
        end


    elseif s == 2 and r == 4 and w == 1 then

        UnchainedHelper.marker(90086,57147,61117, "chain", "1",false) -- spider
        UnchainedHelper.marker(88345,57153,64110, "chain", "2",true) -- spider
        UnchainedHelper.marker(92962,57149,64405, "chain", "3",false) -- Spider
        UnchainedHelper.marker(89784,57152,61143, "chain", "4",false) -- spider

        UnchainedHelper.marker(92896,57158,62884, "elite", "5",false) -- croc
        UnchainedHelper.marker(88236,57144,62666, "elite", "6",false) -- croc

        UnchainedHelper.marker(89653,57151,61676, "group", "",false) -- group

        if nextFight==0 then
            UnchainedHelper.eraseIconTime = GetGameTimeMilliseconds() + UnchainedHelper.savedVars.removeMarkerSeconds * 1000 -- remove icons after X seconds
            UnchainedHelper.drawNextFightIconTime= GetGameTimeMilliseconds() + (UnchainedHelper.savedVars.removeMarkerSeconds+UnchainedHelper.savedVars.nextMarkerSeconds) * 1000  -- display next fight after 15 seconds
            UnchainedHelper.nextRound = 4
            UnchainedHelper.nextWave = 2
        end

    elseif s == 2 and r == 4 and w == 2 then

        UnchainedHelper.marker(92967,57153,63974, "elite", "1",false) -- beastmaster
        UnchainedHelper.marker(90086,57147,61117, "elite", "2",false) -- wama
        UnchainedHelper.marker(88304,57154,63792, "elite", "3",false) -- beastmaster

        UnchainedHelper.marker(88345,57153,64110, "chain", "4",false) -- spider
        UnchainedHelper.marker(92962,57149,64405, "chain", "5",false) -- spider

        UnchainedHelper.marker(89784,57152,61143, "chain", "6",false) -- spider

        UnchainedHelper.marker(90578,57147,63146, "tank", "",false) -- MT

        UnchainedHelper.marker(89653,57151,61676, "group", "",false) -- group

        if nextFight==0 then
            UnchainedHelper.eraseIconTime = GetGameTimeMilliseconds() + UnchainedHelper.savedVars.removeMarkerSeconds * 1000 -- remove icons after X seconds
            UnchainedHelper.drawNextFightIconTime= GetGameTimeMilliseconds() + (UnchainedHelper.savedVars.removeMarkerSeconds+UnchainedHelper.savedVars.nextMarkerSeconds) * 1000  -- display next fight after 15 seconds
            UnchainedHelper.nextRound = 5
            UnchainedHelper.nextWave = 1
            if UnchainedHelper.savedVars.hintsInChatArena2 and (UnchainedHelper.savedVars.tankHints) then
                d("UH2.4.2: tank - no taunt wama, stack beastmasters in middle")
            end
            if UnchainedHelper.savedVars.hintsInChatArena2 and (UnchainedHelper.savedVars.dpsHints or UnchainedHelper.savedVars.healerHints) then
                d("UH2.4.2: dps kill wama, then join tank, no ultimates")
            end
        end

    elseif s == 2 and r == 5 and w == 1 then

        UnchainedHelper.marker(90143,57142,63344, "boss", "1",false) -- tames

        UnchainedHelper.marker(90162,57143,63171,  "tank", "",false) -- MT

        UnchainedHelper.marker(90140,57150,63755, "group", "",false) -- group

        if nextFight==0 then
            UnchainedHelper.eraseIconTime = GetGameTimeMilliseconds() + (UnchainedHelper.savedVars.removeMarkerSeconds/2) * 1000 -- remove icons after X seconds

            UnchainedHelper.drawNextFightIconTime= GetGameTimeMilliseconds() + (UnchainedHelper.savedVars.removeMarkerSeconds+UnchainedHelper.savedVars.nextMarkerSeconds) * 1000  -- display next fight after 15 seconds

            UnchainedHelper.nextStage = 3
            UnchainedHelper.nextRound = 1
            UnchainedHelper.nextWave = 1

        end

    elseif s == 3 and r == 1 and w == 1 then

        UnchainedHelper.marker(97750,53899,47033, "nochain", "1",false) -- Bloodfiend
        UnchainedHelper.marker(96204,53905,47039, "nochain", "2",false) -- Bloodfiend

        UnchainedHelper.marker(97440,53909,51627, "nochain", "3",false) -- Bloodfiend
        UnchainedHelper.marker(96027,53908,51601, "nochain", "4",false) -- Bloodfiend

        UnchainedHelper.marker(99234,53909,49000, "chain", "5",true) -- Cold Mage

        UnchainedHelper.marker(97037,53906,49474, "group", "",false) -- group

        if nextFight==0 then
            UnchainedHelper.eraseIconTime = GetGameTimeMilliseconds() + UnchainedHelper.savedVars.removeMarkerSeconds * 1000 -- remove icons after X seconds
            UnchainedHelper.drawNextFightIconTime= GetGameTimeMilliseconds() + (UnchainedHelper.savedVars.removeMarkerSeconds+UnchainedHelper.savedVars.nextMarkerSeconds) * 1000  -- display next fight after 15 seconds
            UnchainedHelper.nextRound = 1
            UnchainedHelper.nextWave = 2
        end
    elseif s == 3 and r == 1 and w == 2 then

        UnchainedHelper.marker(99271,53908,48506, "chain", "1",true) -- Infuser
        UnchainedHelper.marker(96599,53917,47065, "chain", "2",true) -- Infuser
        UnchainedHelper.marker(96337,53916,51631, "chain", "3",true) -- Infuser

        UnchainedHelper.marker(97037,53906,49474, "group", "",false) -- group


        if nextFight==0 then
            UnchainedHelper.eraseIconTime = GetGameTimeMilliseconds() + UnchainedHelper.savedVars.removeMarkerSeconds * 1000 -- remove icons after X seconds
            UnchainedHelper.drawNextFightIconTime= GetGameTimeMilliseconds() + (UnchainedHelper.savedVars.removeMarkerSeconds+UnchainedHelper.savedVars.nextMarkerSeconds) * 1000  -- display next fight after 15 seconds
            UnchainedHelper.nextRound = 1
            UnchainedHelper.nextWave = 3
        end

    elseif s == 3 and r == 1 and w == 3 then

        UnchainedHelper.marker(96204,53905,47039, "chain", "1",true) -- Infuserws
        UnchainedHelper.marker(96027,53908,51601, "chain", "2",true) -- Infuser

        UnchainedHelper.marker(99234,53909,49000, "elite", "3",false) -- Gargoyle



        UnchainedHelper.marker(97037,53906,49474, "group", "",false) -- group


        if nextFight==0 then
            UnchainedHelper.eraseIconTime = GetGameTimeMilliseconds() + UnchainedHelper.savedVars.removeMarkerSeconds * 1000 -- remove icons after X seconds
            UnchainedHelper.drawNextFightIconTime= GetGameTimeMilliseconds() + (UnchainedHelper.savedVars.removeMarkerSeconds+UnchainedHelper.savedVars.nextMarkerSeconds) * 1000  -- display next fight after 15 seconds
            UnchainedHelper.nextRound = 2
            UnchainedHelper.nextWave = 1


        end

    elseif s == 3 and r == 2 and w == 1 then

        UnchainedHelper.marker(97698,53898,47113, "nochain", "1",false) -- bloodfiend
        UnchainedHelper.marker(96204,53905,47039, "nochain", "2",false) -- bloodfiend
        UnchainedHelper.marker(99234,53909,49000, "nochain", "3",false) -- bloodfiend
        UnchainedHelper.marker(97440,53909,51627, "nochain", "4",false) -- bloodfiend
        UnchainedHelper.marker(96027,53908,51601, "nochain", "5",false) -- bloodfiend
        UnchainedHelper.marker(99271,53908,48506, "nochain", "6",false) -- bloodfiend

        UnchainedHelper.marker(96599,53917,47065, "chain", "7",true) -- Infuser
        UnchainedHelper.marker(96337,53916,51631, "chain", "8",true) -- INfuser

        UnchainedHelper.marker(97037,53906,49474, "group", "",false) -- group


        if nextFight==0 then
            UnchainedHelper.eraseIconTime = GetGameTimeMilliseconds() + UnchainedHelper.savedVars.removeMarkerSeconds * 1000 -- remove icons after X seconds
            UnchainedHelper.drawNextFightIconTime= GetGameTimeMilliseconds() + (UnchainedHelper.savedVars.removeMarkerSeconds+UnchainedHelper.savedVars.nextMarkerSeconds) * 1000  -- display next fight after 15 seconds
            UnchainedHelper.nextRound = 2
            UnchainedHelper.nextWave = 2
        end

    elseif s == 3 and r == 2 and w == 2 then

        UnchainedHelper.marker(96599,53917,47065, "chain", "1",true) -- cold mage
        UnchainedHelper.marker(96337,53916,51631, "chain", "2",true) -- cold mage

        UnchainedHelper.marker(97037,53906,49474, "group", "",false) -- group


        if nextFight==0 then
            UnchainedHelper.eraseIconTime = GetGameTimeMilliseconds() + UnchainedHelper.savedVars.removeMarkerSeconds * 1000 -- remove icons after X seconds
            UnchainedHelper.drawNextFightIconTime= GetGameTimeMilliseconds() + (UnchainedHelper.savedVars.removeMarkerSeconds+UnchainedHelper.savedVars.nextMarkerSeconds) * 1000  -- display next fight after 15 seconds
            UnchainedHelper.nextRound = 2
            UnchainedHelper.nextWave = 3
        end

    elseif s == 3 and r == 2 and w == 3 then

        UnchainedHelper.marker(97698,53898,47113, "elite", "1",false) -- gargoyle

        UnchainedHelper.marker(97440,53909,51627, "nochain", "2",false) -- bat
        UnchainedHelper.marker(96027,53908,51601, "nochain", "3",false) -- bat

        UnchainedHelper.marker(97037,53906,49474, "group", "",false) -- group
        UnchainedHelper.marker(97694,53907,47613, "group", "",false) -- group

        if nextFight==0 then
            UnchainedHelper.eraseIconTime = GetGameTimeMilliseconds() + UnchainedHelper.savedVars.removeMarkerSeconds * 1000 -- remove icons after X seconds
            UnchainedHelper.drawNextFightIconTime= GetGameTimeMilliseconds() + (UnchainedHelper.savedVars.removeMarkerSeconds+UnchainedHelper.savedVars.nextMarkerSeconds) * 1000  -- display next fight after 15 seconds
            UnchainedHelper.nextRound = 3
            UnchainedHelper.nextWave = 1
            if UnchainedHelper.savedVars.hintsInChatArena3 and (UnchainedHelper.savedVars.tankHints or UnchainedHelper.savedVars.dpsHints or UnchainedHelper.savedVars.healerHints) then
                d("UH:3.2.3: Gargoyle leave AOE under your feet, stay out of combat area until AOE's drop then move to stack locations. This strat repeats in arena 3")
            end
        end


    elseif s == 3 and r == 3 and w == 1 then

        UnchainedHelper.marker(97698,53898,47113, "chain", "1",true) -- cold mage
        UnchainedHelper.marker(99234,53909,49000, "chain", "2",true) -- infuser
        UnchainedHelper.marker(96027,53908,51601, "chain", "3",false) -- cold mage
        UnchainedHelper.marker(96599,53917,47065, "chain", "4",true) -- infuser

        UnchainedHelper.marker(97037,53906,49474, "group", "",false) -- group


        if nextFight==0 then
            UnchainedHelper.eraseIconTime = GetGameTimeMilliseconds() + UnchainedHelper.savedVars.removeMarkerSeconds * 1000 -- remove icons after X seconds
            UnchainedHelper.drawNextFightIconTime= GetGameTimeMilliseconds() + (UnchainedHelper.savedVars.removeMarkerSeconds+UnchainedHelper.savedVars.nextMarkerSeconds) * 1000  -- display next fight after 15 seconds
            UnchainedHelper.nextRound = 3
            UnchainedHelper.nextWave = 2
        end
    elseif s == 3 and r == 3 and w == 2 then

        UnchainedHelper.marker(99271,53908,48506, "elite", "6",false) -- Gargoyle

        if UnchainedHelper.savedVars.highDps332 then
            -- note: techically these sawns are part of 3.3.3 however with high dps they spawn almost at the same time as 3.3.2
            UnchainedHelper.marker(97698,53898,47113, "chain", "1",true) -- cold mage
            UnchainedHelper.marker(97440,53909,51627, "chain", "2",true) -- coldmage
            UnchainedHelper.marker(96599,53917,47065, "chain", "3",true) -- infuser

            UnchainedHelper.marker(96204,53905,47039, "nochain", "4",false) -- bloodfiend
            UnchainedHelper.marker(99234,53909,49000, "nochain", "5",false) -- bloodfiend
            UnchainedHelper.marker(96027,53908,51601, "nochain", "6",false) -- bloodfiend
        end

        if nextFight==0 then
            UnchainedHelper.eraseIconTime = GetGameTimeMilliseconds() + UnchainedHelper.savedVars.removeMarkerSeconds * 1000 -- remove icons after X seconds
            UnchainedHelper.drawNextFightIconTime= GetGameTimeMilliseconds() + (UnchainedHelper.savedVars.removeMarkerSeconds+UnchainedHelper.savedVars.nextMarkerSeconds) * 1000  -- display next fight after 15 seconds
            UnchainedHelper.nextRound = 3
            UnchainedHelper.nextWave = 3

        end

    elseif s == 3 and r == 3 and w == 3 then

        UnchainedHelper.marker(97698,53898,47113, "chain", "1",true) -- cold mage
        UnchainedHelper.marker(97440,53909,51627, "chain", "2",true) -- coldmage
        UnchainedHelper.marker(96599,53917,47065, "chain", "3",true) -- infuser

        UnchainedHelper.marker(96204,53905,47039, "nochain", "4",false) -- bloodfiend
        UnchainedHelper.marker(99234,53909,49000, "nochain", "5",false) -- bloodfiend
        UnchainedHelper.marker(96027,53908,51601, "nochain", "6",false) -- bloodfiend



        UnchainedHelper.marker(97037,53906,49474, "group", "",false) -- group


        if nextFight==0 then
            UnchainedHelper.eraseIconTime = GetGameTimeMilliseconds() + UnchainedHelper.savedVars.removeMarkerSeconds * 1000 -- remove icons after X seconds
            UnchainedHelper.drawNextFightIconTime= GetGameTimeMilliseconds() + (UnchainedHelper.savedVars.removeMarkerSeconds+UnchainedHelper.savedVars.nextMarkerSeconds) * 1000  -- display next fight after 15 seconds
            UnchainedHelper.nextRound = 4
            UnchainedHelper.nextWave = 1
        end



    elseif s == 3 and r == 4 and w == 1 then

        UnchainedHelper.marker(96204,53905,47039, "chain", "1",true) -- Infuser
        UnchainedHelper.marker(99234,53909,49000, "chain", "2",true) -- Infuser
        UnchainedHelper.marker(97440,53909,51627, "chain", "3",true) -- Infuser
        UnchainedHelper.marker(96027,53908,51601, "chain", "4",false) -- Infuser

        UnchainedHelper.marker(97698,53898,47113, "nochain", "5",false) -- Bat
        UnchainedHelper.marker(99271,53908,48506, "nochain", "6",false) -- Bloodfiend
        UnchainedHelper.marker(96599,53917,47065, "nochain", "7",false) -- Bat
        UnchainedHelper.marker(96337,53916,51631, "nochain", "8",false) -- Bloodfiend

        UnchainedHelper.marker(97037,53906,49474, "group", "",false) -- group


        if nextFight==0 then
            UnchainedHelper.eraseIconTime = GetGameTimeMilliseconds() + UnchainedHelper.savedVars.removeMarkerSeconds * 1000 -- remove icons after X seconds
            UnchainedHelper.drawNextFightIconTime= GetGameTimeMilliseconds() + (UnchainedHelper.savedVars.removeMarkerSeconds+UnchainedHelper.savedVars.nextMarkerSeconds) * 1000  -- display next fight after 15 seconds
            UnchainedHelper.nextRound = 4
            UnchainedHelper.nextWave = 2
            if UnchainedHelper.savedVars.hintsInChatArena3 and (UnchainedHelper.savedVars.tankHints or UnchainedHelper.savedVars.dpsHints or UnchainedHelper.savedVars.healerHints) then
                d("UH:3.4.1: dps AOE 4 Infuser stack, ulti, bash")
            end
        end


    elseif s == 3 and r == 4 and w == 2 then

        UnchainedHelper.marker(99271,53908,48506, "chain", "1",true) -- cold mage
        UnchainedHelper.marker(96599,53917,47065, "chain", "2",true) -- cold mage

        UnchainedHelper.marker(97037,53906,49474, "group", "",false) -- group

        if nextFight==0 then
            UnchainedHelper.eraseIconTime = GetGameTimeMilliseconds() + UnchainedHelper.savedVars.removeMarkerSeconds * 1000 -- remove icons after X seconds
            UnchainedHelper.drawNextFightIconTime= GetGameTimeMilliseconds() + (UnchainedHelper.savedVars.removeMarkerSeconds+UnchainedHelper.savedVars.nextMarkerSeconds) * 1000  -- display next fight after 15 seconds
            UnchainedHelper.nextRound = 4
            UnchainedHelper.nextWave = 3
        end


    elseif s == 3 and r == 4 and w == 3 then


        UnchainedHelper.marker(96204,53905,47039, "elite", "1",false) -- gargoyle
        UnchainedHelper.marker(97440,53909,51627, "elite", "2",false) -- gargoyle

        UnchainedHelper.marker(96754,53893,47759, "group", "",false) -- group
        UnchainedHelper.marker(97037,53906,49474, "group", "",false) -- group

        if nextFight==0 then
            UnchainedHelper.eraseIconTime = GetGameTimeMilliseconds() + UnchainedHelper.savedVars.removeMarkerSeconds * 1000 -- remove icons after X seconds
            UnchainedHelper.drawNextFightIconTime= GetGameTimeMilliseconds() + (UnchainedHelper.savedVars.removeMarkerSeconds+UnchainedHelper.savedVars.nextMarkerSeconds) * 1000  -- display next fight after 15 seconds
            UnchainedHelper.nextRound = 5
            UnchainedHelper.nextWave = 1
            if UnchainedHelper.savedVars.hintsInChatArena3 and (UnchainedHelper.savedVars.tankHints or UnchainedHelper.savedVars.dpsHints or UnchainedHelper.savedVars.healerHints) then
                d("UG3.4.3: charge left gargoyle after AOE drops, no big ult")
            end
        end


    elseif s == 3 and r == 5 and w == 1 then

        UnchainedHelper.marker(97038,53900,49381, "boss", "1",false) -- lady minara

        UnchainedHelper.marker(97471,53903,49410, "tank", "",false) -- group

        UnchainedHelper.marker(96759,53912,49394, "group", "",false) -- group


        if nextFight==0 then
            UnchainedHelper.eraseIconTime = GetGameTimeMilliseconds() + (UnchainedHelper.savedVars.removeMarkerSeconds/2) * 1000 -- remove icons after X seconds

            UnchainedHelper.drawNextFightIconTime= GetGameTimeMilliseconds() + (UnchainedHelper.savedVars.removeMarkerSeconds+UnchainedHelper.savedVars.nextMarkerSeconds) * 1000  -- display next fight after 15 seconds

            UnchainedHelper.nextStage = 4
            UnchainedHelper.nextRound = 1
            UnchainedHelper.nextWave = 1

            if UnchainedHelper.savedVars.hintsInChatArena3 and (UnchainedHelper.savedVars.tankHints) then
                d("UG3.5.1: tank take swarm out of center then return directly to stack, turn Minara around quickly as she cleaves")
                d("UG3.5.1: tank chaining adds in priority over colosus taunt")
            end
            if UnchainedHelper.savedVars.hintsInChatArena3 and (UnchainedHelper.savedVars.tankHints or UnchainedHelper.savedVars.dpsHints or UnchainedHelper.savedVars.healerHints) then
                d("UG3.5.1: dps help bash Minara, dodge colosus heavy and focus, save ultimates for the moment the 3rd colosus dies (or nearly dead), burn ~35% to 0 before 4th colosus")
            end
        end
    elseif s == 4 and r == 1 and w == 1 then

        UnchainedHelper.marker(106159,50675,38636, "nochain", "1",false) -- footsoldier
        UnchainedHelper.marker(110637,50693,38991, "nochain", "2",false) -- foot

        UnchainedHelper.marker(106210,50675,37042, "chain", "3",true) -- spider

        UnchainedHelper.marker(110767,50694,37519, "chain", "4",true) -- spider

        UnchainedHelper.marker(108147,50695,35527, "elite", "5",false) -- cleaver

        UnchainedHelper.marker(108360,50675,36934, "group", "",false) -- group

        if nextFight==0 then
            UnchainedHelper.eraseIconTime = GetGameTimeMilliseconds() + UnchainedHelper.savedVars.removeMarkerSeconds * 1000 -- remove icons after X seconds
            UnchainedHelper.drawNextFightIconTime= GetGameTimeMilliseconds() + (UnchainedHelper.savedVars.removeMarkerSeconds+UnchainedHelper.savedVars.nextMarkerSeconds) * 1000  -- display next fight after 15 seconds
            UnchainedHelper.nextRound = 1
            UnchainedHelper.nextWave = 2
        end

    elseif s == 4 and r == 1 and w == 2 then


        UnchainedHelper.marker(110767,50694,37519, "chain", "1",false) -- Infuser

        UnchainedHelper.marker(107711,50682,35435, "nochain", "2",false) -- Crocodile

        UnchainedHelper.marker(110684,50676,38578, "elite", "3",false) -- Incenerator
        UnchainedHelper.marker(106222,50677,38148, "elite", "4",false) -- Incenerator

        UnchainedHelper.marker(109838,50675,38169, "tank", "",false) -- tank

        UnchainedHelper.marker(106826,50675,38114, "group", "",false) -- group


        if nextFight==0 then
            UnchainedHelper.eraseIconTime = GetGameTimeMilliseconds() + UnchainedHelper.savedVars.removeMarkerSeconds * 1000 -- remove icons after X seconds
            UnchainedHelper.drawNextFightIconTime= GetGameTimeMilliseconds() + (UnchainedHelper.savedVars.removeMarkerSeconds+UnchainedHelper.savedVars.nextMarkerSeconds) * 1000  -- display next fight after 15 seconds
            UnchainedHelper.nextRound = 1
            UnchainedHelper.nextWave = 3
        end


    elseif s == 4 and r == 1 and w == 3 then

        UnchainedHelper.marker(106210,50675,37042, "chain", "1",true) -- Hover

        UnchainedHelper.marker(110767,50694,37519, "chain", "2",true) -- Horver

        UnchainedHelper.marker(110684,50676,38578, "nochain", "3",false) -- Bloodfiend
        UnchainedHelper.marker(106222,50677,38148, "nochain", "4",false) -- Bloodfiend

        UnchainedHelper.marker(108147,50695,35527, "boss", "5",false) -- Beastmaster

        UnchainedHelper.marker(108369,50675,37029, "group", "",false) -- group


        if nextFight==0 then
            UnchainedHelper.eraseIconTime = GetGameTimeMilliseconds() + UnchainedHelper.savedVars.removeMarkerSeconds * 1000 -- remove icons after X seconds
            UnchainedHelper.drawNextFightIconTime= GetGameTimeMilliseconds() + (UnchainedHelper.savedVars.removeMarkerSeconds+UnchainedHelper.savedVars.nextMarkerSeconds) * 1000  -- display next fight after 15 seconds
            UnchainedHelper.nextRound = 2
            UnchainedHelper.nextWave = 1
        end

    elseif s == 4 and r == 2 and w == 1 then


        UnchainedHelper.marker(106210,50675,37042, "nochain", "1",false) -- archer

        UnchainedHelper.marker(110767,50694,37519, "nochain", "2",false) -- archer

        UnchainedHelper.marker(108147,50695,35527, "elite", "3",false) -- cleaver
        UnchainedHelper.marker(106159,50675,38636, "elite", "4",false) -- incinerator

        UnchainedHelper.marker(108638,50675,37960, "tank", "",false) -- tank

        UnchainedHelper.marker(106807,50675,38642, "group", "",false) -- group


        if nextFight==0 then
            UnchainedHelper.eraseIconTime = GetGameTimeMilliseconds() + UnchainedHelper.savedVars.removeMarkerSeconds * 1000 -- remove icons after X seconds
            UnchainedHelper.drawNextFightIconTime= GetGameTimeMilliseconds() + (UnchainedHelper.savedVars.removeMarkerSeconds+UnchainedHelper.savedVars.nextMarkerSeconds) * 1000  -- display next fight after 15 seconds
            UnchainedHelper.nextRound = 2
            UnchainedHelper.nextWave = 2
            if UnchainedHelper.savedVars.hintsInChatArena4 and (UnchainedHelper.savedVars.tankHints) then
                d("UG4.2.1: tank stay mid, taunt archers, cleaver but do not chain")
            end
            if UnchainedHelper.savedVars.hintsInChatArena4 and (UnchainedHelper.savedVars.tankHints or UnchainedHelper.savedVars.dpsHints) then
                d("UG4.2.1: dps single target Mage, then single target cleaver avoid archers")
            end
        end

    elseif s == 4 and r == 2 and w == 2 then

        UnchainedHelper.marker(106159,50675,38636, "nochain", "1",false) -- footsoldier
        UnchainedHelper.marker(108147,50695,35527, "nochain", "2",false) -- footsoldier

        UnchainedHelper.marker(107711,50682,35435, "nochain", "3",true) -- archer

        UnchainedHelper.marker(110767,50694,37519, "elite", "4",false) -- dreadknight

        UnchainedHelper.marker(108656,50675,37895, "group", "",false) -- group


        if nextFight==0 then
            UnchainedHelper.eraseIconTime = GetGameTimeMilliseconds() + UnchainedHelper.savedVars.removeMarkerSeconds * 1000 -- remove icons after X seconds
            UnchainedHelper.drawNextFightIconTime= GetGameTimeMilliseconds() + (UnchainedHelper.savedVars.removeMarkerSeconds+UnchainedHelper.savedVars.nextMarkerSeconds) * 1000  -- display next fight after 15 seconds
            UnchainedHelper.nextRound = 2
            UnchainedHelper.nextWave = 3
            if UnchainedHelper.savedVars.hintsInChatArena4 and (UnchainedHelper.savedVars.tankHints) then
                d("UG4.2.2: taunt dreadnight and footsoldiers as possible, wait for dreadknight to be around 50% to chain in archers")
            end
            if UnchainedHelper.savedVars.hintsInChatArena4 and (UnchainedHelper.savedVars.tankHints or UnchainedHelper.savedVars.dpsHints or UnchainedHelper.savedVars.healerHints) then
                d("UG4.2.2: dps/tank - goal is to kill the dreadknight and archers at the same time as the archer deaths triggers the boss spawn")
            end
        end
    elseif s == 4 and r == 2 and w == 3 then

        UnchainedHelper.marker(106159,50675,38636, "elite", "1",false) -- incinerator

        UnchainedHelper.marker(108484,50676,37765,"boss", "2",false) -- boss spawn

        UnchainedHelper.marker(108737,50675,37764, "group", "",false) -- three
        UnchainedHelper.marker(108319,50675,37783, "group", "",false) -- four
        UnchainedHelper.marker(108494,50675,37944, "group", "",false) -- group

        UnchainedHelper.marker(110684,50676,38578, "elite", "3",false) -- incinerator

        if UnchainedHelper.savedVars.tankPosition then
        UnchainedHelper.marker(108472,50675,37441, "tank", "",false) -- tank
        end


        if nextFight==0 then
            UnchainedHelper.eraseIconTime = GetGameTimeMilliseconds() + (UnchainedHelper.savedVars.removeMarkerSeconds/2) * 1000 -- remove icons after X seconds
            UnchainedHelper.drawNextFightIconTime= GetGameTimeMilliseconds() + (UnchainedHelper.savedVars.removeMarkerSeconds+UnchainedHelper.savedVars.nextMarkerSeconds) * 1000  -- display next fight after 15 seconds
            UnchainedHelper.nextRound = 3
            UnchainedHelper.nextWave = 1
            if UnchainedHelper.savedVars.hintsInChatArena4 and (UnchainedHelper.savedVars.tankHints or UnchainedHelper.savedVars.dpsHints or UnchainedHelper.savedVars.healerHints) then
                d("UH4.2.3: strat1: tank or healer stand facing both mages and interrupt both mages, until boss dies")
                d("UH4.2.3: strat2: dps burn boss at spawn fast, healer heals thru the mage channels")
                d("UH4.2.3: strat3: tank bring boss to right mage, where dps + tank kill it, while healer goes to left mage and bashes")
                d("UH4.2.3: strat4: healer taunts mages and drags them over the boss spawn where it dies")
            end
        end


    elseif s == 4 and r == 3 and w == 1 then

        UnchainedHelper.marker(106159,50675,38636, "nochain", "1",false) -- hackwing
        UnchainedHelper.marker(106210,50675,37042, "nochain", "2",false) -- hackwing

        UnchainedHelper.marker(110767,50694,37519, "nochain", "3",false) -- hackwing
        UnchainedHelper.marker(110637,50693,38991, "nochain", "4",false) -- hackwing

        UnchainedHelper.marker(108147,50695,35527, "elite", "5",false) -- beastmaster



        UnchainedHelper.marker(108375,50675,36853, "group", "",false) -- group


        if nextFight==0 then
            UnchainedHelper.eraseIconTime = GetGameTimeMilliseconds() + UnchainedHelper.savedVars.removeMarkerSeconds * 1000 -- remove icons after X seconds
            UnchainedHelper.drawNextFightIconTime= GetGameTimeMilliseconds() + (UnchainedHelper.savedVars.removeMarkerSeconds+UnchainedHelper.savedVars.nextMarkerSeconds) * 1000  -- display next fight after 15 seconds
            UnchainedHelper.nextRound = 3
            UnchainedHelper.nextWave = 2
        end
    elseif s == 4 and r == 3 and w == 2 then


        UnchainedHelper.marker(108147,50695,35527, "chain", "1",true) -- spider
        UnchainedHelper.marker(110767,50694,37519, "chain", "2",false) -- spider
        UnchainedHelper.marker(110637,50693,38991, "chain", "3",false) -- spider
        UnchainedHelper.marker(107711,50682,35435, "chain", "4",true) -- spider

        UnchainedHelper.marker(106159,50675,38636, "elite", "5",false) -- Haj

        UnchainedHelper.marker(108656,50675,37895, "group", "",false) -- group


        if nextFight==0 then
            UnchainedHelper.eraseIconTime = GetGameTimeMilliseconds() + UnchainedHelper.savedVars.removeMarkerSeconds * 1000 -- remove icons after X seconds
            UnchainedHelper.drawNextFightIconTime= GetGameTimeMilliseconds() + (UnchainedHelper.savedVars.removeMarkerSeconds+UnchainedHelper.savedVars.nextMarkerSeconds) * 1000  -- display next fight after 15 seconds
            UnchainedHelper.nextRound = 3
            UnchainedHelper.nextWave = 3
            if UnchainedHelper.savedVars.hintsInChatArena4 and (UnchainedHelper.savedVars.tankHints or UnchainedHelper.savedVars.dpsHints or UnchainedHelper.savedVars.healerHints) then
                d("UH4.3.2: dps burn Haj, if ult wait for charge, face Haj for 50% more damage")
            end
        end
    elseif s == 4 and r == 3 and w == 3 then

        UnchainedHelper.marker(108525,50675,37765, "boss", "1",false) -- tames

        UnchainedHelper.marker(108147,50695,35527, "nochain", "2",false) -- crocodile
        UnchainedHelper.marker(110684,50676,38578, "nochain", "3",false) -- crocodile

        UnchainedHelper.marker(108491,50675,37475,  "tank", "",false) -- tank

        UnchainedHelper.marker(108514,50675,37902, "group", "",false) -- group


        if nextFight==0 then
            UnchainedHelper.eraseIconTime = GetGameTimeMilliseconds() + (UnchainedHelper.savedVars.removeMarkerSeconds/2) * 1000 -- remove icons after X seconds
            UnchainedHelper.drawNextFightIconTime= GetGameTimeMilliseconds() + (UnchainedHelper.savedVars.removeMarkerSeconds+UnchainedHelper.savedVars.nextMarkerSeconds) * 1000  -- display next fight after 15 seconds
            UnchainedHelper.nextRound = 4
            UnchainedHelper.nextWave = 1
            if UnchainedHelper.savedVars.hintsInChatArena4 and (UnchainedHelper.savedVars.dpsHints or UnchainedHelper.savedVars.healerHints) then
                d("UH4.3.2: dps burn tames ignore all others")
            end
        end



    elseif s == 4 and r == 4 and w == 1 then

        UnchainedHelper.marker(108147,50695,35527, "chain", "1",true) -- cold mage

        UnchainedHelper.marker(106159,50675,38636, "nochain", "2",false) -- bloodfiend
        UnchainedHelper.marker(106210,50675,37042, "nochain", "3",false) -- bat

        UnchainedHelper.marker(110767,50694,37519, "nochain", "4",false) -- bat
        UnchainedHelper.marker(110637,50693,38991, "nochain", "5",false) -- bloodfiend

        UnchainedHelper.marker(108656,50675,37895, "group", "",false) -- group


        if nextFight==0 then
            UnchainedHelper.eraseIconTime = GetGameTimeMilliseconds() + UnchainedHelper.savedVars.removeMarkerSeconds * 1000 -- remove icons after X seconds
            UnchainedHelper.drawNextFightIconTime= GetGameTimeMilliseconds() + (UnchainedHelper.savedVars.removeMarkerSeconds+UnchainedHelper.savedVars.nextMarkerSeconds) * 1000  -- display next fight after 15 seconds
            UnchainedHelper.nextRound = 4
            UnchainedHelper.nextWave = 2
        end
    elseif s == 4 and r == 4 and w == 2 then

        UnchainedHelper.marker(106210,50675,37042, "chain", "1",true) -- Infuser
        UnchainedHelper.marker(108147,50695,35527, "chain", "2",true) -- Infuser

        UnchainedHelper.marker(110637,50693,38991, "elite", "3",false) -- gargoyle

        UnchainedHelper.marker(108656,50675,37895, "group", "",false) -- group


        if nextFight==0 then
            UnchainedHelper.eraseIconTime = GetGameTimeMilliseconds() + UnchainedHelper.savedVars.removeMarkerSeconds * 1000 -- remove icons after X seconds
            UnchainedHelper.drawNextFightIconTime= GetGameTimeMilliseconds() + (UnchainedHelper.savedVars.removeMarkerSeconds+UnchainedHelper.savedVars.nextMarkerSeconds) * 1000  -- display next fight after 15 seconds
            UnchainedHelper.nextRound = 4
            UnchainedHelper.nextWave = 3
        end
    elseif s == 4 and r == 4 and w == 3 then

        UnchainedHelper.marker(106159,50675,38636, "chain", "1",true) -- infuser

        UnchainedHelper.marker(110637,50693,38991, "chain", "2",true) -- coldmage

        UnchainedHelper.marker(108525,50675,37765, "elite", "3",false) -- minara

        UnchainedHelper.marker(108491,50675,37475,  "tank", "",false) -- tank

        UnchainedHelper.marker(108514,50675,37902, "group", "",false) -- group



        if nextFight==0 then
            UnchainedHelper.eraseIconTime = GetGameTimeMilliseconds() + UnchainedHelper.savedVars.removeMarkerSeconds * 1000 -- remove icons after X seconds
            UnchainedHelper.drawNextFightIconTime= GetGameTimeMilliseconds() + (UnchainedHelper.savedVars.removeMarkerSeconds+UnchainedHelper.savedVars.nextMarkerSeconds) * 1000  -- display next fight after 15 seconds
            UnchainedHelper.nextRound = 5
            UnchainedHelper.nextWave = 1
            if UnchainedHelper.savedVars.hintsInChatArena4 and (UnchainedHelper.savedVars.tankHints or UnchainedHelper.savedVars.dpsHints or UnchainedHelper.savedVars.healerHints) then
                d("UH4.4.3: tank chain in adds, dps burn Minara")
            end
        end

   elseif s == 4 and r == 5 and w == 1 then

        UnchainedHelper.marker(108126,50675,37531,"boss", "1",false) -- boss spawn

        UnchainedHelper.marker(107872,50675,37583, "group", "",false) -- group

        UnchainedHelper.marker(109218,50675,37836, "tank", "",false) -- tank



        if nextFight==0 then
            UnchainedHelper.eraseIconTime = GetGameTimeMilliseconds() + (UnchainedHelper.savedVars.removeMarkerSeconds/2) * 1000 -- remove icons after X seconds
            UnchainedHelper.drawNextFightIconTime= GetGameTimeMilliseconds() + (UnchainedHelper.savedVars.removeMarkerSeconds+UnchainedHelper.savedVars.nextMarkerSeconds) * 1000  -- display next fight after 15 seconds
            UnchainedHelper.nextRound = 5
            UnchainedHelper.nextWave = 2
            if UnchainedHelper.savedVars.hintsInChatArena4 and (UnchainedHelper.savedVars.tankHints) then
                d("UH4.5.1: tank move boss 1 to next to Tames spawm")
            end
            if UnchainedHelper.savedVars.hintsInChatArena4 and (UnchainedHelper.savedVars.dpsHints) then
                d("UH4.5.1: dps Battlemage such that Tames will be in AOE")
            end
        end
   elseif s == 4 and r == 5 and w == 2 then

        UnchainedHelper.marker(109032,50675,37540,"boss", "",false) -- tames spawn


        if nextFight==0 then
            UnchainedHelper.eraseIconTime = GetGameTimeMilliseconds() + (UnchainedHelper.savedVars.removeMarkerSeconds/2) * 1000 -- remove icons after X seconds
            UnchainedHelper.drawNextFightIconTime= GetGameTimeMilliseconds() + (UnchainedHelper.savedVars.removeMarkerSeconds+UnchainedHelper.savedVars.nextMarkerSeconds) * 1000  -- display next fight after 15 seconds
            UnchainedHelper.nextRound = 5
            UnchainedHelper.nextWave = 3
            if UnchainedHelper.savedVars.hintsInChatArena4 and (UnchainedHelper.savedVars.tankHints) then
                d("UH4.5.2: tank try to hold adds mid, if possible face Haj away from group")
            end
            if UnchainedHelper.savedVars.hintsInChatArena4 and (UnchainedHelper.savedVars.tankHints or UnchainedHelper.savedVars.dpsHints or UnchainedHelper.savedVars.healerHints) then
                d("UH4.5.2: dps on Tames spawn tab target, all ultimates, cleave Battlemage before second meteor")
            end
        end
   elseif s == 4 and r == 5 and w == 3 then

        UnchainedHelper.marker(108524,50675,37267,"boss", "",false) -- minara spawn



        if nextFight==0 then
            UnchainedHelper.eraseIconTime = GetGameTimeMilliseconds() + (UnchainedHelper.savedVars.removeMarkerSeconds/2) * 1000 -- remove icons after X seconds

            UnchainedHelper.drawNextFightIconTime= GetGameTimeMilliseconds() + (UnchainedHelper.savedVars.removeMarkerSeconds+UnchainedHelper.savedVars.nextMarkerSeconds) * 1000  -- display next fight after 15 seconds

            UnchainedHelper.nextStage = 5
            UnchainedHelper.nextRound = 1
            UnchainedHelper.nextWave = 1


            if UnchainedHelper.savedVars.hintsInChatArena4 and (UnchainedHelper.savedVars.tankHints) then
                d("UH4.5.3: tank taunt Minara, hopefully your dps will be done with Tames soon")
                d("UH4.5.3: tank chain Minara's adds, prevent Minara from spawning colosus")
            end
        end


   elseif s == 5 and r == 1 and w == 1 then

        UnchainedHelper.marker(96253,48130,32732, "chain", "1",true) -- convict
        UnchainedHelper.marker(96371,48125,28909, "chain", "2",true) -- convict

        UnchainedHelper.marker(95348,48132,32684, "nochain", "3",false) -- prisoner
        UnchainedHelper.marker(95566,48112,28918, "nochain", "4",false) -- prisoner



        UnchainedHelper.marker(95631,48088,30679, "tank", "",false) -- group

        if nextFight==0 then
            UnchainedHelper.eraseIconTime = GetGameTimeMilliseconds() + UnchainedHelper.savedVars.removeMarkerSeconds * 1000 -- remove icons after X seconds
            UnchainedHelper.drawNextFightIconTime= GetGameTimeMilliseconds() + (UnchainedHelper.savedVars.removeMarkerSeconds+UnchainedHelper.savedVars.nextMarkerSeconds) * 1000  -- display next fight after 15 seconds
            UnchainedHelper.nextRound = 1
            UnchainedHelper.nextWave = 2
            if UnchainedHelper.savedVars.hintsInChatArena5 and (UnchainedHelper.savedVars.tankHints) then
                d("UH5.1.1: taunt prisoner x2, use chain on convicts as they channel to interrupt x2 (this strat repeats)")
            end

        end


   elseif s == 5 and r == 1 and w == 2 then

        UnchainedHelper.marker(95858,48142,32705, "chain", "1",true) -- convict
        UnchainedHelper.marker(95910,48142,28889, "chain", "2",true) -- convict

        UnchainedHelper.marker(96755,48120,30730, "elite", "3",false) -- soul void

        UnchainedHelper.marker(95631,48088,30679, "tank", "",false) -- group

        if nextFight==0 then
            UnchainedHelper.eraseIconTime = GetGameTimeMilliseconds() + UnchainedHelper.savedVars.removeMarkerSeconds * 1000 -- remove icons after X seconds
            UnchainedHelper.drawNextFightIconTime= GetGameTimeMilliseconds() + (UnchainedHelper.savedVars.removeMarkerSeconds+UnchainedHelper.savedVars.nextMarkerSeconds) * 1000  -- display next fight after 15 seconds
            UnchainedHelper.nextRound = 1
            UnchainedHelper.nextWave = 3
        end
   elseif s == 5 and r == 1 and w == 3 then


        UnchainedHelper.marker(95588,48095,31201, "boss", "1",false) -- vengefull revenant boss

        if nextFight==0 then
            UnchainedHelper.eraseIconTime = GetGameTimeMilliseconds() + (UnchainedHelper.savedVars.removeMarkerSeconds/2) * 1000 -- remove icons after X seconds
            UnchainedHelper.drawNextFightIconTime= GetGameTimeMilliseconds() + (UnchainedHelper.savedVars.removeMarkerSeconds+UnchainedHelper.savedVars.nextMarkerSeconds) * 1000  -- display next fight after 15 seconds
            UnchainedHelper.nextRound = 2
            UnchainedHelper.nextWave = 1
            if UnchainedHelper.savedVars.hintsInChatArena5 and (UnchainedHelper.savedVars.dpsHints) then
                d("UH5.1.3: dps burn boss/adds, ignore totem")
            end
        end
   elseif s == 5 and r == 2 and w == 1 then

        UnchainedHelper.marker(96253,48130,32732, "nochain", "1",false) -- prisoner
        UnchainedHelper.marker(96371,48125,28909, "nochain", "2",false) -- prisoner

        UnchainedHelper.marker(95631,48091,30258, "elite", "3",false) -- soul void

        UnchainedHelper.marker(95631,48088,30679, "tank", "",false) -- group



        if nextFight==0 then
            UnchainedHelper.eraseIconTime = GetGameTimeMilliseconds() + UnchainedHelper.savedVars.removeMarkerSeconds * 1000 -- remove icons after X seconds
            UnchainedHelper.drawNextFightIconTime= GetGameTimeMilliseconds() + (UnchainedHelper.savedVars.removeMarkerSeconds+UnchainedHelper.savedVars.nextMarkerSeconds) * 1000  -- display next fight after 15 seconds
            UnchainedHelper.nextRound = 2
            UnchainedHelper.nextWave = 2
        end
   elseif s == 5 and r == 2 and w == 2 then

        UnchainedHelper.marker(96253,48130,32732, "nochain", "1",false) -- prisoner

        UnchainedHelper.marker(96755,48120,30730, "boss", "2",false) -- vengefull revenant boss


        if nextFight==0 then
            UnchainedHelper.eraseIconTime = GetGameTimeMilliseconds() + (UnchainedHelper.savedVars.removeMarkerSeconds/2) * 1000 -- remove icons after X seconds
            UnchainedHelper.drawNextFightIconTime= GetGameTimeMilliseconds() + (UnchainedHelper.savedVars.removeMarkerSeconds+UnchainedHelper.savedVars.nextMarkerSeconds) * 1000  -- display next fight after 15 seconds
            UnchainedHelper.nextRound = 2
            UnchainedHelper.nextWave = 3
        end
   elseif s == 5 and r == 2 and w == 3 then

        UnchainedHelper.marker(95858,48142,32705, "chain", "1",true) -- convict
        UnchainedHelper.marker(95910,48142,28889, "chain", "2",true) -- convict

        UnchainedHelper.marker(95588,48095,31201, "elite", "3",false) -- soul void

        UnchainedHelper.marker(95631,48088,30679, "tank", "",false) -- group


        if nextFight==0 then
            UnchainedHelper.eraseIconTime = GetGameTimeMilliseconds() + UnchainedHelper.savedVars.removeMarkerSeconds * 1000 -- remove icons after X seconds
            UnchainedHelper.drawNextFightIconTime= GetGameTimeMilliseconds() + (UnchainedHelper.savedVars.removeMarkerSeconds+UnchainedHelper.savedVars.nextMarkerSeconds) * 1000  -- display next fight after 15 seconds
            UnchainedHelper.nextRound = 3
            UnchainedHelper.nextWave = 1
            if UnchainedHelper.savedVars.hintsInChatArena5 and (UnchainedHelper.savedVars.dpsHints) then
                d("UH5.2.3: dps burn adds, ignore totem")
            end
        end

   elseif s == 5 and r == 3 and w == 1 then

        UnchainedHelper.marker(95566,48112,28918, "nochain", "1",false) -- prisoner

        UnchainedHelper.marker(95858,48142,32705, "chain", "2",true) -- convict
        UnchainedHelper.marker(95910,48142,28889, "chain", "3",true) -- convict

        UnchainedHelper.marker(95631,48091,30258, "elite", "4",false) -- soul void

        UnchainedHelper.marker(95631,48088,30679, "tank", "",false) -- group

        if nextFight==0 then
            UnchainedHelper.eraseIconTime = GetGameTimeMilliseconds() + UnchainedHelper.savedVars.removeMarkerSeconds * 1000 -- remove icons after X seconds
            UnchainedHelper.drawNextFightIconTime= GetGameTimeMilliseconds() + (UnchainedHelper.savedVars.removeMarkerSeconds+UnchainedHelper.savedVars.nextMarkerSeconds) * 1000  -- display next fight after 15 seconds
            UnchainedHelper.nextRound = 3
            UnchainedHelper.nextWave = 2
        end
   elseif s == 5 and r == 3 and w == 2 then

        UnchainedHelper.marker(95858,48142,32705, "elite", "1",false) -- soul void
        UnchainedHelper.marker(95910,48142,28889, "elite", "2",false) -- soul void

        UnchainedHelper.marker(96755,48120,30730, "chain", "3",true) -- convict

        UnchainedHelper.marker(95631,48088,30679, "tank", "",false) -- group


        if nextFight==0 then
            UnchainedHelper.eraseIconTime = GetGameTimeMilliseconds() + UnchainedHelper.savedVars.removeMarkerSeconds * 1000 -- remove icons after X seconds
            UnchainedHelper.drawNextFightIconTime= GetGameTimeMilliseconds() + (UnchainedHelper.savedVars.removeMarkerSeconds+UnchainedHelper.savedVars.nextMarkerSeconds) * 1000  -- display next fight after 15 seconds
            UnchainedHelper.nextRound = 3
            UnchainedHelper.nextWave = 3
        end


   elseif s == 5 and r == 3 and w == 3 then

        UnchainedHelper.marker(96253,48130,32732, "nochain", "1",false) -- prisoner

        UnchainedHelper.marker(96371,48125,28909, "chain", "2",true) -- convict

        UnchainedHelper.marker(95588,48095,31201, "boss", "3",false) -- vengefull


        if nextFight==0 then
            UnchainedHelper.eraseIconTime = GetGameTimeMilliseconds() + UnchainedHelper.savedVars.removeMarkerSeconds * 1000 -- remove icons after X seconds
            UnchainedHelper.drawNextFightIconTime= GetGameTimeMilliseconds() + (UnchainedHelper.savedVars.removeMarkerSeconds+UnchainedHelper.savedVars.nextMarkerSeconds) * 1000  -- display next fight after 15 seconds
            UnchainedHelper.nextRound = 4
            UnchainedHelper.nextWave = 1
            if UnchainedHelper.savedVars.hintsInChatArena5 and (UnchainedHelper.savedVars.dpsHints) then
                d("UH5.3.3: dps boss/adds, ignore totem")
            end
        end

   elseif s == 5 and r == 4 and w == 1 then

        UnchainedHelper.marker(95348,48132,32684, "chain", "1",true) -- convict
        UnchainedHelper.marker(95566,48112,28918, "chain", "2",true) -- convict

        UnchainedHelper.marker(95858,48142,32705, "nochain", "3",false) -- prisoner
        UnchainedHelper.marker(95910,48142,28889, "nochain", "4",false) -- prisoner

        UnchainedHelper.marker(95631,48091,30258, "elite", "5",false) -- soul void

        UnchainedHelper.marker(95631,48088,30679, "tank", "",false) -- group


        if nextFight==0 then
            UnchainedHelper.eraseIconTime = GetGameTimeMilliseconds() + UnchainedHelper.savedVars.removeMarkerSeconds * 1000 -- remove icons after X seconds
            UnchainedHelper.drawNextFightIconTime= GetGameTimeMilliseconds() + (UnchainedHelper.savedVars.removeMarkerSeconds+UnchainedHelper.savedVars.nextMarkerSeconds) * 1000  -- display next fight after 15 seconds
            UnchainedHelper.nextRound = 4
            UnchainedHelper.nextWave = 2
        end
   elseif s == 5 and r == 4 and w == 2 then

        UnchainedHelper.marker(96371,48125,28909, "nochain", "1",false) -- prisoner
        UnchainedHelper.marker(96253,48130,32732, "nochain", "2",false) -- prisoner

        UnchainedHelper.marker(95348,48132,32684, "elite", "3",false) -- soul void
        UnchainedHelper.marker(95566,48112,28918, "elite", "4",false) -- soul void


        UnchainedHelper.marker(95631,48088,30679, "tank", "",false) -- group

        if nextFight==0 then
            UnchainedHelper.eraseIconTime = GetGameTimeMilliseconds() + UnchainedHelper.savedVars.removeMarkerSeconds * 1000 -- remove icons after X seconds
            UnchainedHelper.drawNextFightIconTime= GetGameTimeMilliseconds() + (UnchainedHelper.savedVars.removeMarkerSeconds+UnchainedHelper.savedVars.nextMarkerSeconds) * 1000  -- display next fight after 15 seconds
            UnchainedHelper.nextRound = 4
            UnchainedHelper.nextWave = 3
        end



   elseif s == 5 and r == 4 and w == 3 then

        UnchainedHelper.marker(95566,48112,28918, "nochain", "1",false) -- prisoner

        UnchainedHelper.marker(95858,48142,32705, "chain", "2",true) -- convict
        UnchainedHelper.marker(95910,48142,28889, "chain", "3",true) -- convict

        UnchainedHelper.marker(95588,48095,31201, "boss", "4",false) -- boss


        if nextFight==0 then
            UnchainedHelper.eraseIconTime = GetGameTimeMilliseconds() + UnchainedHelper.savedVars.removeMarkerSeconds * 1000 -- remove icons after X seconds
            UnchainedHelper.drawNextFightIconTime= GetGameTimeMilliseconds() + (UnchainedHelper.savedVars.removeMarkerSeconds+UnchainedHelper.savedVars.nextMarkerSeconds) * 1000  -- display next fight after 15 seconds
            UnchainedHelper.nextRound = 5
            UnchainedHelper.nextWave = 1
            if UnchainedHelper.savedVars.hintsInChatArena5 and (UnchainedHelper.savedVars.dpsHints) then
                d("UH5.4.3: dps boss/adds, ignore totem")
            end
        end
   elseif s == 5 and r == 5 and w == 1 then

        UnchainedHelper.marker(96014,48098,30701, "boss", "1",false) -- boss

        UnchainedHelper.marker(95666,48090,30661, "tank", "",false) -- tank

        UnchainedHelper.marker(96171,48097,30710, "group", "",false) -- group


        if nextFight==0 then
            UnchainedHelper.eraseIconTime = GetGameTimeMilliseconds() + (UnchainedHelper.savedVars.removeMarkerSeconds/2) * 1000 -- remove icons after X seconds
            if UnchainedHelper.savedVars.hintsInChatArena5 and (UnchainedHelper.savedVars.dpsHints) then
                d("UH5.5.1: one dps range totems, other dps stay on boss")
            end
            if UnchainedHelper.savedVars.hintsInChatArena5 and (UnchainedHelper.savedVars.tankHints or UnchainedHelper.savedVars.dpsHints or UnchainedHelper.savedVars.healerHints) then
                d("UH5.5.1: Drakeeh jumps are brought to middle, everyone get out then go back in (except for jumps during ghost phase)")
            end
            if UnchainedHelper.savedVars.hintsInChatArena5 and (UnchainedHelper.savedVars.tankHints or UnchainedHelper.savedVars.dpsHints or UnchainedHelper.savedVars.healerHints) then
                d("UH5.5.1: healer if you have one, let Drakeeh channel for more dps, just stand in voids, major breach totems")
            end
        end
   end
end




function UnchainedHelper.GetCurrentStage()

	local x, y = GetMapPlayerPosition('player');

	if x > 0.54 and x < 0.64 and y > 0.79 and y < 0.89 then
		return 1
	elseif x > 0.3 and x < 0.4 and y > 0.69 and y < 0.8 then
		return 2
	elseif x > 0.41 and x < 0.52 and y > 0.43 and y < 0.53 then
		return 3
	elseif x > 0.63 and x < 0.73 and y > 0.22 and y < 0.32 then
		return 4
	elseif x > 0.4 and x < 0.5 and y > 0.08 and y < 0.18 then
		return 5
	else
		return 0
	end

end


function UnchainedHelper.Announcement(_, title, _)

	if title == 'Final Round' or title == 'Letzte Runde' or title == 'Dernière manche' or title == 'Последний раунд' or title == '最終ラウンド' then
		UnchainedHelper.currentRound = 5
		UnchainedHelper.currentWave = 0
	else
		local round = string.match(title, '^.+%s(%d)$')
		if round then
			UnchainedHelper.currentRound = tonumber(round)
			UnchainedHelper.currentWave = 0
		end
	end

end



function UnchainedHelper.PortalSpawn(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)

	if result == ACTION_RESULT_EFFECT_GAINED then
		local t = GetGameTimeMilliseconds()
		if t - UnchainedHelper.lastPortalSpawn > 4000 then
			UnchainedHelper.currentWave = UnchainedHelper.currentWave + 1
			UnchainedHelper.NotifyNewWave(0)

        -- change from 4000 to 1000 because of 3.3.2 -> 3.3.3 transition which is very fast
        elseif UnchainedHelper.GetCurrentStage()==3 and UnchainedHelper.currentRound == 3 and UnchainedHelper.currentWave==2 and t - UnchainedHelper.lastPortalSpawn > 1000 then
            UnchainedHelper.currentWave = UnchainedHelper.currentWave + 1
			UnchainedHelper.NotifyNewWave(0)

		end
		UnchainedHelper.lastPortalSpawn = t
	end
end


function UnchainedHelper.ClearIcons()

    UnchainedHelper.eraseIconTime = 0
    UnchainedHelper.iconsUp = false
    if UnchainedHelper.icon1==nil then
    else
        OSI.DiscardPositionIcon(UnchainedHelper.icon1)
        UnchainedHelper.icon1=nil
    end

    if UnchainedHelper.icon2==nil then
    else
        OSI.DiscardPositionIcon(UnchainedHelper.icon2)
        UnchainedHelper.icon2=nil
    end

    if UnchainedHelper.icon3==nil then
    else
        OSI.DiscardPositionIcon(UnchainedHelper.icon3)
        UnchainedHelper.icon3=nil
    end

    if UnchainedHelper.icon4==nil then
    else
        OSI.DiscardPositionIcon(UnchainedHelper.icon4)
        UnchainedHelper.icon4=nil
    end


    if UnchainedHelper.icon5==nil then
    else
        OSI.DiscardPositionIcon(UnchainedHelper.icon5)
        UnchainedHelper.icon5=nil
    end


    if UnchainedHelper.icon6==nil then
    else
        OSI.DiscardPositionIcon(UnchainedHelper.icon6)
        UnchainedHelper.icon6=nil
    end

    if UnchainedHelper.icon7==nil then
    else
        OSI.DiscardPositionIcon(UnchainedHelper.icon7)
        UnchainedHelper.icon7=nil
    end

    if UnchainedHelper.icon8==nil then
    else
        OSI.DiscardPositionIcon(UnchainedHelper.icon8)
        UnchainedHelper.icon8=nil
    end

    if UnchainedHelper.icon9==nil then
    else
        OSI.DiscardPositionIcon(UnchainedHelper.icon9)
        UnchainedHelper.icon9=nil
    end

    if UnchainedHelper.icon10==nil then
    else
        OSI.DiscardPositionIcon(UnchainedHelper.icon10)
        UnchainedHelper.icon10=nil
    end
end

function UnchainedHelper.UpdateTimer()
    if UnchainedHelper.eraseIconTime==0 or UnchainedHelper.eraseIconTime > GetGameTimeMilliseconds() then
    else
       UnchainedHelper.ClearIcons()
    end

    if UnchainedHelper.drawNextFightIconTime==0 or UnchainedHelper.drawNextFightIconTime > GetGameTimeMilliseconds() then
    else
       UnchainedHelper.NotifyNewWave(1)
    end
end


function UnchainedHelper.AddFootsoldierHeavy()
    if CombatAlertsData then
        if CombatAlertsData.dodge then
            if CombatAlertsData.dodge.ids then
                if CombatAlertsData.dodge.ids[111634] then
                    --CombatAlertsData.dodge.ids[111634]={ -2, 2 } -- footsolider heavy for dps only
                else
                    CombatAlertsData.dodge.ids[111634]={ -2, 2 } -- footsolider heavy for dps only
                end

                if CombatAlertsData.dodge.ids[110814] then
                    --CombatAlertsData.dodge.ids[110814]={ -2, 1 } -- battlemage heavy for tank and dps
                else
                    CombatAlertsData.dodge.ids[110814]={ -2, 1 } -- battlemage heavy for tank and dps
                end

                if CombatAlertsData.dodge.ids[111541] then
                    --CombatAlertsData.dodge.ids[111541]={ -2, 1 } -- minara shield charge
                else
                    CombatAlertsData.dodge.ids[111541]={ -2, 1 } -- minara shield charge
                end

                if CombatAlertsData.dodge.ids[113396] then
                    --CombatAlertsData.dodge.ids[113396]={ -2, 1 } -- prisoner heavy for tanks and dps
                else
                    CombatAlertsData.dodge.ids[113396]={ -2, 1 } -- prisoner heavy for tanks and dps
                end
            end
        end
    end
end


function UnchainedHelper.RemoveFootsoldierHeavy()
    if CombatAlertsData then
        if CombatAlertsData.dodge then
            if CombatAlertsData.dodge.ids then
                if CombatAlertsData.dodge.ids[111634] then
                    --d("Footsoldier Heavy attack removed")
                    CombatAlertsData.dodge.ids[111634]=nil
                else
                end

                if CombatAlertsData.dodge.ids[113396] then
                    -- remove prisoner heavy
                    CombatAlertsData.dodge.ids[113396]=nil
                else
                end
            end
        end
    end
end

function UnchainedHelper.PlayerActivated()

	if GetZoneId(GetUnitZoneIndex("player")) == 1082 then
	    d("Unchained Helper Active "..UnchainedHelper.version)

        EVENT_MANAGER:RegisterForEvent(UnchainedHelper.name .. "Ability" .. 114578, EVENT_COMBAT_EVENT, UnchainedHelper.PortalSpawn)
	    EVENT_MANAGER:AddFilterForEvent(UnchainedHelper.name .. "Ability" .. 114578, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 114578)

        EVENT_MANAGER:RegisterForEvent(UnchainedHelper.name .. "Announcement", EVENT_DISPLAY_ANNOUNCEMENT, UnchainedHelper.Announcement)
        EVENT_MANAGER:RegisterForUpdate(UnchainedHelper.name.."Update", 1000, UnchainedHelper.UpdateTimer)
      	EVENT_MANAGER:RegisterForEvent(UnchainedHelper.name.."PassiveHide", EVENT_PLAYER_COMBAT_STATE, UnchainedHelper.OnPlayerCombatState)

        EVENT_MANAGER:RegisterForEvent(UnchainedHelper.name.."ECE"..109992, EVENT_COMBAT_EVENT, UnchainedHelper.combatEvent)
        EVENT_MANAGER:AddFilterForEvent(UnchainedHelper.name.."ECE", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 109992, REGISTER_FILTER_IS_ERROR, false)

        EVENT_MANAGER:RegisterForEvent(UnchainedHelper.name.."ECE"..113150, EVENT_COMBAT_EVENT, UnchainedHelper.combatEvent)
        EVENT_MANAGER:AddFilterForEvent(UnchainedHelper.name.."ECE", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 113150, REGISTER_FILTER_IS_ERROR, false)


        UnchainedHelperFramePurge:SetText("")
        UnchainedHelperFrame:SetHidden(true)


        if UnchainedHelper.savedVars.footsoldierHeavy then -- add heavy attack notification for Footsoldiers
            UnchainedHelper.AddFootsoldierHeavy()
        end


        UnchainedHelper.nextStage = 1
        UnchainedHelper.nextRound = 1
        UnchainedHelper.nextWave = 1
        UnchainedHelper.NotifyNewWave(1)

    else

        EVENT_MANAGER:UnregisterForEvent(UnchainedHelper.name .. "Ability" .. 114578, EVENT_COMBAT_EVENT)
        EVENT_MANAGER:UnregisterForEvent(UnchainedHelper.name .. "Announcement", EVENT_DISPLAY_ANNOUNCEMENT)
        EVENT_MANAGER:UnregisterForUpdate(UnchainedHelper.name.."Update")
        EVENT_MANAGER:UnregisterForEvent(UnchainedHelper.name.."PassiveHide", EVENT_PLAYER_COMBAT_STATE)
	    EVENT_MANAGER:UnregisterForEvent(UnchainedHelper.name.."ECE"..109992, EVENT_COMBAT_EVENT)
        EVENT_MANAGER:UnregisterForEvent(UnchainedHelper.name.."ECE"..113150, EVENT_COMBAT_EVENT)

        UnchainedHelperFramePurge:SetText("")
        UnchainedHelperFrame:SetHidden(true)

        UnchainedHelper.RemoveFootsoldierHeavy() -- remove heavy attack notification for Footsoldiers

    end
end


function UnchainedHelper.Init(event, addon)
	if addon ~= UnchainedHelper.name then return end

	UnchainedHelper.inCombat = IsUnitInCombat("player")

	UnchainedHelper.currentPurgeable=0

    UnchainedHelper.savedVars = ZO_SavedVars:New(UnchainedHelper.name.."SavedVars", UnchainedHelper.varVersion, nil, UnchainedHelper.defaults)
    UnchainedHelper.setPos()
	UnchainedHelper.setupMenu()

	EVENT_MANAGER:UnregisterForEvent(UnchainedHelper.name.."Load", EVENT_ADD_ON_LOADED)
	EVENT_MANAGER:RegisterForEvent(UnchainedHelper.name .. "_PlayerActivated", EVENT_PLAYER_ACTIVATED, UnchainedHelper.PlayerActivated)
end

EVENT_MANAGER:RegisterForEvent(UnchainedHelper.name.."Load", EVENT_ADD_ON_LOADED, UnchainedHelper.Init)











--[[
    --------------- ARENA 5 TEMPLATE ----------------
    elseif s == 5 and r == 6 and w == 6 then

        UnchainedHelper.marker(96253,48130,32732, "1",false) -- one
        UnchainedHelper.marker(95348,48132,32684, "2",false) -- two
        UnchainedHelper.marker(95566,48112,28918, "3",false) -- three
        UnchainedHelper.marker(96371,48125,28909, "4",false) -- four
        UnchainedHelper.marker(95858,48142,32705, "5",false) -- five
        UnchainedHelper.marker(95910,48142,28889, "6",false) -- six
        UnchainedHelper.marker(96755,48120,30730, "7",false) -- seven
        UnchainedHelper.marker(95588,48095,31201, "8",false) -- eight
        UnchainedHelper.marker(95631,48091,30258, "9",false) -- nine
        UnchainedHelper.marker(96244,48099,30895, "group", "",false) -- group

        if nextFight==0 then
            UnchainedHelper.eraseIconTime = GetGameTimeMilliseconds() + UnchainedHelper.savedVars.removeMarkerSeconds * 1000 -- remove icons after X seconds
            UnchainedHelper.drawNextFightIconTime= GetGameTimeMilliseconds() + (UnchainedHelper.savedVars.removeMarkerSeconds+UnchainedHelper.savedVars.nextMarkerSeconds) * 1000  -- display next fight after 15 seconds
            UnchainedHelper.nextRound = 1
            UnchainedHelper.nextWave = 2
        end





    --------------- ARENA 4 TEMPLATE ----------------
    elseif s == 4 and r == 6 and w == 6 then

        UnchainedHelper.marker(106159,50675,38636, "1",false) -- one
        UnchainedHelper.marker(106210,50675,37042, "2",false) -- two
        UnchainedHelper.marker(108147,50695,35527, "3",false) -- three
        UnchainedHelper.marker(110767,50694,37519, "4",false) -- four
        UnchainedHelper.marker(110637,50693,38991, "5",false) -- five
        UnchainedHelper.marker(110684,50676,38578, "6",false) -- six
        UnchainedHelper.marker(106222,50677,38148, "7",false) -- seven
        UnchainedHelper.marker(107711,50682,35435, "8",false) -- eight
        UnchainedHelper.marker(0,53916,51631, "9",false) -- nine
        UnchainedHelper.marker(108656,50675,37895, "group", "",false) -- group

        if nextFight==0 then
            UnchainedHelper.eraseIconTime = GetGameTimeMilliseconds() + UnchainedHelper.savedVars.removeMarkerSeconds * 1000 -- remove icons after X seconds
            UnchainedHelper.drawNextFightIconTime= GetGameTimeMilliseconds() + (UnchainedHelper.savedVars.removeMarkerSeconds+UnchainedHelper.savedVars.nextMarkerSeconds) * 1000  -- display next fight after 15 seconds
            UnchainedHelper.nextRound = 1
            UnchainedHelper.nextWave = 2
        end



    --------------- ARENA 3 TEMPLATE ----------------
    elseif s == 3 and r == 6 and w == 6 then

        UnchainedHelper.marker(97698,53898,47113, "1","",false) -- one
        UnchainedHelper.marker(96204,53905,47039, "2","",false) -- two
        UnchainedHelper.marker(99234,53909,49000, "3","",false) -- three
        UnchainedHelper.marker(97440,53909,51627, "4","",false) -- four
        UnchainedHelper.marker(96027,53908,51601, "5","",false) -- five
        UnchainedHelper.marker(99271,53908,48506, "6","",false) -- six
        UnchainedHelper.marker(96599,53917,47065, "7","",false) -- seven
        UnchainedHelper.marker(96579,53925,51589, "8","",false) -- eight
        UnchainedHelper.marker(96337,53916,51631, "9","",false) -- nine
        UnchainedHelper.marker(97037,53906,49474, "group", "",false) -- group

        if nextFight==0 then
            UnchainedHelper.eraseIconTime = GetGameTimeMilliseconds() + UnchainedHelper.savedVars.removeMarkerSeconds * 1000 -- remove icons after X seconds
            UnchainedHelper.drawNextFightIconTime= GetGameTimeMilliseconds() + (UnchainedHelper.savedVars.removeMarkerSeconds+UnchainedHelper.savedVars.nextMarkerSeconds) * 1000  -- display next fight after 15 seconds
            UnchainedHelper.nextRound = 1
            UnchainedHelper.nextWave = 2
        end




    --------------- ARENA 2 TEMPLATE ----------------
    elseif s == 2 and r == 6 and w == 6 then
        UnchainedHelper.marker(92967,57153,63974, "1",false) -- one
        UnchainedHelper.marker(90086,57147,61117, "2",false) -- two
        UnchainedHelper.marker(88345,57153,64110, "3",false) -- three
        UnchainedHelper.marker(88236,57144,62666, "4",false) -- four
        UnchainedHelper.marker(92962,57149,64405, "5",false) -- five
        UnchainedHelper.marker(92896,57158,62884, "6",false) -- six
        UnchainedHelper.marker(88304,57154,63792, "7",false) -- seven
        UnchainedHelper.marker(89784,57152,61143, "8",false) -- eight
        UnchainedHelper.marker(89653,57151,61676, "group", "",false) -- group
        if nextFight==0 then
            UnchainedHelper.eraseIconTime = GetGameTimeMilliseconds() + UnchainedHelper.savedVars.removeMarkerSeconds * 1000 -- remove icons after X seconds
            UnchainedHelper.drawNextFightIconTime= GetGameTimeMilliseconds() + (UnchainedHelper.savedVars.removeMarkerSeconds+UnchainedHelper.savedVars.nextMarkerSeconds) * 1000  -- display next fight after 15 seconds
            UnchainedHelper.nextRound = 1
            UnchainedHelper.nextWave = 2
        end


    --------------- ARENA 1 TEMPLATE ----------------
    elseif s == 1 and r == 6 and w == 6 then
        UnchainedHelper.marker(104111,60951,70730, "1",false) -- one
        UnchainedHelper.marker(103023,60951,70699, "2",false) -- two
        UnchainedHelper.marker(102669,60951,70674, "3",false) -- three
        UnchainedHelper.marker(104147,60951,66109, "4",false) -- four
        UnchainedHelper.marker(102946,60951,66175, "5",false) -- five
        UnchainedHelper.marker(102637,60951,66181, "6",false) -- six
        UnchainedHelper.marker(105786,60955,67598, "7",false) -- seven
        UnchainedHelper.marker(105911,60951,68075, "8",false) -- eight
        UnchainedHelper.marker(104158,60950,66667, "group", "",false) -- group
        if nextFight==0 then
            UnchainedHelper.eraseIconTime = GetGameTimeMilliseconds() + UnchainedHelper.savedVars.removeMarkerSeconds * 1000 -- remove icons after X seconds
            UnchainedHelper.drawNextFightIconTime= GetGameTimeMilliseconds() + (UnchainedHelper.savedVars.removeMarkerSeconds+UnchainedHelper.savedVars.nextMarkerSeconds) * 1000  -- display next fight after 15 seconds
            UnchainedHelper.nextRound = 4
            UnchainedHelper.nextWave = 2
        end
    end
    --]]