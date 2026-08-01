WMO = {
    name            = "WhereIsMyOlorime",
    author          = "Branddi",
    color           = "DDFFEE",            
    menuName        = "WhereIsMyOlorime",
}


WMO.olorimeInUse = false

WMO.olorimeUptimeTotal = {0,0,0,0,0,0,0,0,0,0,0,0,0}
WMO.lastInCombatState = -1

WMO.olorimeIconPlacedTime = GetGameTimeSeconds()

WMO.WhereIsMyOlorimeicon1 = nil




function WMO.GetOlorimeWarningTime()
    local time = GetGameTimeSeconds()-WMO.olorimeIconPlacedTime

    if time <= 0 then
        return 0
    else
        if time > 5 then
            return 0
        else
            return time -- between 0 and 5 seconds indicate time when Olo is on the ground and available for pickup
        end
    end
end


function WMO.GetOloTime(unit)
	local value = 0
	for i=1,GetNumBuffs(unit) do
		local buffName, timeStarted, timeEnding, _, stacks, _, buffType, effectType, _, _, abilityId, _, _ = GetUnitBuffInfo(unit,i)

        if abilityId == 109966 then -- olorime major courage 10994
            if timeEnding-timeStarted<2 then
				value = 20
            else
                if (timeEnding-GetGameTimeSeconds())>20 then
					value = 20
                else
					value = (timeEnding-GetGameTimeSeconds())
                end
            end
        else
        end
    end
    return value
end

function WMO.clearIcon()

		if WMO.WhereIsMyOlorimeicon1==nil then
		else
			OSI.DiscardPositionIcon(WMO.WhereIsMyOlorimeicon1)
			WMO.WhereIsMyOlorimeicon1=nil
		end
end

function WMO.placeIcon(unit,type)
    --d("WMO.placeIcon()")

	local zone, x, y, z = GetUnitWorldPosition(unit)
	--d("x"..x.."y"..y.."z"..z)
	WMO.clearIcon()
	WMO.WhereIsMyOlorimeicon1 = OSI.CreatePositionIcon(x,y,z, type,150, {1, 1, 1})
end



WMO.TimerRunning = false
function WMO.StartTimer()
    if WMO.TimerRunning == false then
        EVENT_MANAGER:RegisterForUpdate(WMO.name, 200, WMO.UpdateDuration)
    end
end

function WMO.StopTimer()
    if WMO.TimerRunning == true then
        EVENT_MANAGER:UnregisterForUpdate(WMO.name)
    end
end


function WMO.combatEvent(eventCode,result,isError,abilityName,abilityGraphic,abilityActionSlotType,sourceName,sourceType,targetName,targetType,hitValue,powerType,damageType,combatEventLog,sourceUnitId,targetUnitId,abilityId)
	--if abilityId == 109966 then
	--    d("major courage event found 109966")
	--end
    if abilityId == 109994 then
	    if IsUnitInCombat("player") and WMO.olorimeInUse==false then
	        --d("starting olorime olorime set in use event found 109994 targetName:"..targetName.." sourceName:"..sourceName.." result:"..result)
	        WMO.olorimeInUse=true
            WMO.StartTimer()
	    end
	end


end


-->>>>>>>>>>>>>>>>>>>>>>>>> UPDATE UI <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<--

function WMO.UpdateDuration()

    local inCombat

    inCombat = IsUnitInCombat("player")

    local playerTimeRemaining = WMO.GetOloTime("player")
    --d(playerTimeRemaining)
	for i=1, 12 do

		local searchBy = "group"..i
		if not IsUnitGrouped("player") then
			searchBy = "player"
		end


		local timeRemaining = WMO.GetOloTime(searchBy)


        if timeRemaining-2 > WMO.olorimeUptimeTotal[i] and timeRemaining>18 and WMO.olorimeInUse and inCombat and playerTimeRemaining<12 then
        -- olorime is the only Major Courage buff with 20 seconds so we look for people with 18+ seconds of Major courage (if they create another major courage that lasts longer this will break)

            if WMO.WhereIsMyOlorimeicon1==nil or GetGameTimeSeconds()-WMO.olorimeIconPlacedTime>4.5 then

                    -- only update icon after 4 seconds of the last one placed

                    --d("Olorime was recently added to: "..searchBy)
                    WMO.placeIcon(searchBy,"WhereIsMyOlorime/icons/circle_yellow.dds")
                    WMO.olorimeIconPlacedTime = GetGameTimeSeconds()

            end
        end
        WMO.olorimeUptimeTotal[i] = timeRemaining


    end


    if WMO.WhereIsMyOlorimeicon1==nil then
    else
        if GetGameTimeSeconds()-WMO.olorimeIconPlacedTime>4.5 or playerTimeRemaining > 12 then -- olo icons after 4.5 seconds
            WMO.clearIcon()
            WMO.olorimeIconPlacedTime=0
        end
    end


end

-->>>>>>>>>>>>>>>>>>>>>>>>> UPDATE UI <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<--


function WMO.combatSwitch()

    if (not (WMO.lastInCombatState == IsUnitInCombat("player"))) then
        WMO.lastInCombatState = IsUnitInCombat("player")
        if WMO.lastInCombatState then
            WMO.olorimeInUse = false
            WMO.StopTimer()

            WMO.olorimeUptimeTotal = {0,0,0,0,0,0,0,0,0,0,0,0,0}

			WMO.clearIcon()
			WMO.olorimeIconPlacedTime=0


        end
    end


end



------------------- INITIALIZE --------------------------


function WMO.OnAddOnLoaded(event, addonName)
    if addonName ~= WMO.name then return end
    EVENT_MANAGER:UnregisterForEvent(WMO.name, EVENT_ADD_ON_LOADED)

	WMO.combatSwitch()

	EVENT_MANAGER:RegisterForEvent(WMO.name, EVENT_PLAYER_COMBAT_STATE,WMO.combatSwitch)

	EVENT_MANAGER:RegisterForEvent(WMO.name.."ECE", EVENT_COMBAT_EVENT, WMO.combatEvent)
    EVENT_MANAGER:AddFilterForEvent(WMO.name.."ECE", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 109994, REGISTER_FILTER_IS_ERROR, false)

end

EVENT_MANAGER:RegisterForEvent(WMO.name, EVENT_ADD_ON_LOADED, WMO.OnAddOnLoaded)


