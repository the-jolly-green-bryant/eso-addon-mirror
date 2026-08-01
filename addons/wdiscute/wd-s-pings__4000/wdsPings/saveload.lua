function wdsPings.GetCurrentZoneID()
    local zoneid, senderx, sendery, senderz = GetUnitRawWorldPosition('player')
    return zoneid
end
function wdsPings.GetNumberOfPingsInCurrentZone()
    if (wdsPings.savedVariables.SavedPings[wdsPings.GetCurrentZoneID()] == nil) then return 0 end
    return #wdsPings.savedVariables.SavedPings[wdsPings.GetCurrentZoneID()]
end
function wdsPings.GetCurrentZoneNameWithColor(zoneid)
    if (zoneid == nil) then
        local zoneid2, x, y, z = GetUnitRawWorldPosition("player")
        zoneid = zoneid2
    end

    --Trials
    if (zoneid == 1478) then return "|c" .. "A8B5E0" .. "Lucent Citadel"       .. "|r" end
    if (zoneid == 1263) then return "|c" .. "4B908E" .. "Rockgrove"            .. "|r" end
    if (zoneid == 1427) then return "|c" .. "bea9df" .. "Sanity's Edge"        .. "|r" end
    if (zoneid == 975)  then return "|c" .. "ad9840" .. "Halls of Fabrication" .. "|r" end
    if (zoneid == 1051) then return "|c" .. "b7ecea" .. "Cloudrest"            .. "|r" end
    if (zoneid == 1344) then return "|c" .. "a7b8c4" .. "DreadSail Reef"       .. "|r" end
    if (zoneid == 1196) then return "|c" .. "ff746c" .. "Kyne's Aegis"         .. "|r" end
    if (zoneid == 1121) then return "|c" .. "deae36" .. "Sunspire"             .. "|r" end
    if (zoneid == 1000) then return "|c" .. "c1b7aa" .. "Asylum Sanctorium"    .. "|r" end


    --Zones  
    if (zoneid == 1011) then return "|c" .. "FFEE8C" .. "Summerset"            .. "" end
    if (zoneid == 849)  then return "|c" .. "E0AB8B" .. "Vvardenfell"          .. "|r" end
    if (zoneid == 41)   then return "|c" .. "877F7D" .. "Stonefalls"           .. "|r" end
    if (zoneid == 57)   then return "|c" .. "A7BF93" .. "Deshaan"              .. "|r" end
    if (zoneid == 1261) then return "|c" .. "363636" .. "Blackwood"            .. "|r" end
    if (zoneid == 117)  then return "|c" .. "32965d" .. "Shadowfen"            .. "|r" end
    if (zoneid == 1414) then return "|c" .. "c38560" .. "Telvanni Peninsula"   .. "|r" end
    if (zoneid == 101)  then return "|c" .. "e6e6e6" .. "Eastmarch"            .. "|r" end
    if (zoneid == 103)  then return "|c" .. "e7cd78" .. "The Rift"             .. "|r" end
    if (zoneid == 1086) then return "|c" .. "ffaf7a" .. "Northen Elsweyr"      .. "|r" end
    if (zoneid == 1133) then return "|c" .. "ff964f" .. "Southern Elsweyr"     .. "|r" end
    if (zoneid == 383)  then return "|c" .. "add0b3" .. "Grahtwood"            .. "|r" end
    if (zoneid == 108)  then return "|c" .. "ceffc9" .. "Greenshade"           .. "|r" end
    if (zoneid == 726)  then return "|c" .. "caf2c2" .. "Murkmire"             .. "|r" end
    if (zoneid == 382)  then return "|c" .. "fff8b8" .. "Reaper's march"       .. "|r" end
    if (zoneid == 58)   then return "|c" .. "218b82" .. "Malabal Tor"          .. "|r" end
    if (zoneid == 1443) then return "|c" .. "deb64b" .. "West Weald"           .. "|r" end
    if (zoneid == 823)  then return "|c" .. "e6dac5" .. "Gold Coast"           .. "|r" end
    if (zoneid == 816)  then return "|c" .. "dbb630" .. "Hew's Bane"           .. "|r" end
    if (zoneid == 381)  then return "|c" .. "ecbdc4" .. "Auridon"              .. "|r" end
    if (zoneid == 534)  then return "|c" .. "ba9561" .. "Stros M'Kai"          .. "|r" end
    if (zoneid == 537)  then return "|c" .. "9acd32" .. "Khenarthi's Roost"    .. "|r" end
    if (zoneid == 281)  then return "|c" .. "9acd32" .. "Bal Foyen"            .. "|r" end
    if (zoneid == 1318) then return "|c" .. "00a551" .. "High Isle"            .. "|r" end
    if (zoneid == 1383) then return "|c" .. "71bc75" .. "Galen"                .. "|r" end
    if (zoneid == 535)  then return "|c" .. "607d8b" .. "Betnikh"              .. "|r" end
    if (zoneid == 104)  then return "|c" .. "e6c3ab" .. "Alik'r Desert"        .. "|r" end
    if (zoneid == 3)    then return "|c" .. "888c8d" .. "Glenumbra"            .. "|r" end
    if (zoneid == 19)   then return "|c" .. "5c666b" .. "StormHaven"           .. "|r" end
    if (zoneid == 684)  then return "|c" .. "829ca5" .. "Wrothgar"             .. "|r" end
    if (zoneid == 92)   then return "|c" .. "18466f" .. "bangkorai"            .. "|r" end
    if (zoneid == 1160) then return "|c" .. "00688d" .. "Western Skyrim"       .. "|r" end
    if (zoneid == 1207) then return "|c" .. "004346" .. "The Reach"            .. "|r" end
    if (zoneid == 888)  then return "|c" .. "33756d" .. "Craglorn"             .. "|r" end
    if (zoneid == 1161) then return "|c" .. "003754" .. "Greymoor Caverns"     .. "|r" end
    if (zoneid == 1208) then return "|c" .. "0077a6" .. "Arkthzand Cavern"     .. "|r" end
    if (zoneid == 980)  then return "|c" .. "c4a484" .. "Clockwork City"       .. "|r" end
    if (zoneid == 347)  then return "|c" .. "20368f" .. "Coldharbour"          .. "|r" end
    if (zoneid == 1027) then return "|c" .. "f2bee0" .. "Arteum"               .. "|r" end
    if (zoneid == 1286) then return "|c" .. "ff9d5c" .. "The Deadlands"        .. "|r" end
    if (zoneid == 1282) then return "|c" .. "c46f43" .. "Fargrave"             .. "|r" end
    if (zoneid == 1413) then return "|c" .. "98fb98" .. "Apocrypha"            .. "|r" end
    if (zoneid == 181)  then return "|c" .. "ffefc1" .. "Cyrodiil"             .. "|r" end
    if (zoneid == 1283) then return "|c" .. "037c6e" .. "The Shambles"         .. "|r" end

    return "|cdddddd" .. GetPlayerActiveZoneName() .. "|r"
end

function wdsPings.ClearSavedPings()
    d("|cEAC8E9[wd's pings] Cleared all pings saved in " .. wdsPings.GetCurrentZoneNameWithColor(zoneid))
    wdsPings.headerLocked = true
    SaveLoadHeaderReference.data.name = 
   wdsPings.GetCurrentZoneNameWithColor(zoneid) .. "|r pings - |cA9DDB1Cleared all saved pings"
    SaveLoadHeaderReference:UpdateValue()
    wdsPings.headerString = "clear"
    zo_callLater(function() 
        if(wdsPings.headerString == "clear")then
            wdsPings.headerLocked = false
            wdsPings.updateSaveLoad()
        end
     end, 3500)
    local zoneid, playerx, playery, playerz = GetUnitRawWorldPosition('player')
    wdsPings.savedVariables.SavedPings[zoneid] = nil
end

function wdsPings.isNotGroupLeader()
    if(IsUnitGroupLeader('player'))then
        return false
    else
        return true
    end 
end

function wdsPings.SavePings(showInChat)
    local pingsToAdd = nil
    local zoneid = wdsPings.GetCurrentZoneID()

    if (#wdsPings.array == 0 and showInChat == true) then
        d("|cEAC8E9[wd's pings] There are no active pings to save in " .. wdsPings.GetCurrentZoneNameWithColor(zoneid))
        wdsPings.headerLocked = true
        SaveLoadHeaderReference.data.name = 
        "|cee5555[!] There's no active pings to save in " .. wdsPings.GetCurrentZoneNameWithColor() .. " |cee5555[!]"
        SaveLoadHeaderReference:UpdateValue()
        wdsPings.headerString = "save"
        zo_callLater(function() 
            if(wdsPings.headerString == "save")then
                wdsPings.headerLocked = false
                wdsPings.updateSaveLoad()
            end
         end, 3500)
        return
    end

    --check for new pings
    local skipPingMessage = 0
    local skipPing
    for i = 1, #wdsPings.array do
        skipPing = false
        if (wdsPings.savedVariables.SavedPings[zoneid] ~= nil) then
            for k = 1, #wdsPings.savedVariables.SavedPings[zoneid] do
                local distancex = wdsPings.savedVariables.SavedPings[zoneid][k][1] - wdsPings.array[i].x
                local distancey = wdsPings.savedVariables.SavedPings[zoneid][k][2] - wdsPings.array[i].y
                local distancez = wdsPings.savedVariables.SavedPings[zoneid][k][3] - wdsPings.array[i].z

                distancex = math.abs(distancex)
                distancey = math.abs(distancey)
                distancez = math.abs(distancez)

                if (distancex < 100 and distancey < 200 and distancez < 100) then
                    skipPing = true
                    skipPingMessage = skipPingMessage + 1
                end
            end
        end

        if (skipPing == false) then
            if(pingsToAdd == nil)then
                pingsToAdd = {}
            end
            pingsToAdd[#pingsToAdd + 1] = {
                [1] = wdsPings.array[i].x,
                [2] = wdsPings.array[i].y,
                [3] = wdsPings.array[i].z,
                [4] = wdsPings.array[i].tex
            }
        end
    end

    if (skipPingMessage > 0) then
        d("|cEAC8E9[wd's pings] " .. skipPingMessage .. " pings weren't added as they were overlapping existing saved pings.")
        wdsPings.headerLocked = true
        SaveLoadHeaderReference.data.name = 
        "|cee5555[!] " .. skipPingMessage .. " overlapping pings were not added [!]"
        SaveLoadHeaderReference:UpdateValue()
        wdsPings.headerString = "save2"
        zo_callLater(function() 
            if(wdsPings.headerString == "save2")then
                wdsPings.headerLocked = false
                wdsPings.updateSaveLoad()
            end
         end, 3500)
    end

    if (showInChat == true and pingsToAdd ~= nil) then
        d("|cEAC8E9[wd's pings] Added [" .. #pingsToAdd .. "] new pings in " .. wdsPings.GetCurrentZoneNameWithColor(zoneid) .. ".")
        wdsPings.headerLocked = true
        if(skipPingMessage > 0)then
            SaveLoadHeaderReference.data.name = 
        wdsPings.GetCurrentZoneNameWithColor(zoneid) .. "|r pings - |cA9DDB1added [" .. #pingsToAdd .. "]|r pings - |cee5555[" .. skipPingMessage .. "] skipped"
        else
            SaveLoadHeaderReference.data.name = 
        wdsPings.GetCurrentZoneNameWithColor(zoneid) .. "|r pings - |cA9DDB1added [" .. #pingsToAdd .. "]|r pings"
        end
        
        SaveLoadHeaderReference:UpdateValue()
        wdsPings.headerString = "save3"
        zo_callLater(function() 
            if(wdsPings.headerString == "save3")then
                wdsPings.headerLocked = false
                wdsPings.updateSaveLoad()
            end
         end, 3500)
    end

    if(pingsToAdd == nil)then
        pingsToAdd = {}
    end
    --add existing pings to array
    if (wdsPings.savedVariables.SavedPings[zoneid] ~= nil) then
        for j = 1, #wdsPings.savedVariables.SavedPings[zoneid] do
            pingsToAdd[#pingsToAdd + 1] =
            {
                [1] = wdsPings.savedVariables.SavedPings[zoneid][j][1],
                [2] = wdsPings.savedVariables.SavedPings[zoneid][j][2],
                [3] = wdsPings.savedVariables.SavedPings[zoneid][j][3],
                [4] = wdsPings.savedVariables.SavedPings[zoneid][j][4],
            }
        end
    end
    if(#pingsToAdd == 0)then
        wdsPings.savedVariables.SavedPings[zoneid] = nil
    else
        wdsPings.savedVariables.SavedPings[zoneid] = pingsToAdd
    end
    

end

function wdsPings.LoadPings(showInChat)
    local zoneid, senderx, sendery, senderz = GetUnitRawWorldPosition('player')

    wdsPings.RemovePing("0", false)

    if (wdsPings.settings.SavedPings[zoneid] == nil) then
        if (showInChat == true) then
            d("|cEAC8E9[wd's pings] There are no pings saved in " .. wdsPings.GetCurrentZoneNameWithColor(zoneid))
            wdsPings.headerLocked = true
            SaveLoadHeaderReference.data.name = wdsPings.GetCurrentZoneNameWithColor(zoneid) .. "|r pings - |cee5555 there's no pings to load"
            SaveLoadHeaderReference:UpdateValue()
            
            wdsPings.headerString = "load2"
            zo_callLater(function() 
                if(wdsPings.headerString == "load2")then
                    wdsPings.headerLocked = false
                    wdsPings.updateSaveLoad()
                end
             end, 3500)
        end
        return
    end

    if (showInChat == true) then
        if(wdsPings.GetNumberOfPingsInCurrentZone() == 1)then
            d("|cEAC8E9[wd's pings] Loaded [" .. wdsPings.GetNumberOfPingsInCurrentZone() .. "] ping for " .. wdsPings.GetCurrentZoneNameWithColor(zoneid))
            wdsPings.headerLocked = true
            SaveLoadHeaderReference.data.name = wdsPings.GetCurrentZoneNameWithColor(zoneid) .. "|r pings - |cA9DDB1loaded [" .. wdsPings.GetNumberOfPingsInCurrentZone() .. "] |r ping"
            SaveLoadHeaderReference:UpdateValue()
            
            wdsPings.headerString = "load"
            zo_callLater(function() 
                if(wdsPings.headerString == "load")then
                    wdsPings.headerLocked = false
                    wdsPings.updateSaveLoad()
                end
             end, 3500)
        else
            d("|cEAC8E9[wd's pings] Loaded [" .. wdsPings.GetNumberOfPingsInCurrentZone() .. "] pings for " .. wdsPings.GetCurrentZoneNameWithColor(zoneid))
            wdsPings.headerLocked = true
            SaveLoadHeaderReference.data.name = wdsPings.GetCurrentZoneNameWithColor(zoneid) .. "|r pings - |cA9DDB1loaded [" .. wdsPings.GetNumberOfPingsInCurrentZone() .. "] |r pings"
            SaveLoadHeaderReference:UpdateValue()
            
            wdsPings.headerString = "load2"
            zo_callLater(function() 
                if(wdsPings.headerString == "load2")then
                    wdsPings.headerLocked = false
                    wdsPings.updateSaveLoad()
                end
             end, 3500)
        end

    end

    for i = 1, #wdsPings.savedVariables.SavedPings[zoneid] do
        local x = wdsPings.savedVariables.SavedPings[tonumber(zoneid)][i][1]
        local y = wdsPings.savedVariables.SavedPings[tonumber(zoneid)][i][2]
        local z = wdsPings.savedVariables.SavedPings[tonumber(zoneid)][i][3]
        local tex = wdsPings.savedVariables.SavedPings[tonumber(zoneid)][i][4]

        wdsPings.array[#wdsPings.array + 1] = OSI.CreatePositionIcon(x, y, z, tex, wdsPings.settings.scalePermPing * 10,
            OSI.BASECOLOR, -0.3)
    end
end

function wdsPings.OnPlayerActivated()
    wdsPings.LoadPings(false)
end

function wdsPings.ShareClose()
    if (IsUnitGroupLeader('player') == false) then
        d("|cEAC8E9[wd's pings] |cee5555[!] group leader is required to share your pings [!]")
        return
    end

    wdsPings.GetNumberOfPingsInRange()
    wdsPings.share:SendData(30000000001)
    local _, playerx, playery, playerz = GetUnitRawWorldPosition('player')
    local pingTextureID
    local pingTextureIDString = ""
    local dataToShare = ""
    local distanceyString = ""
    local distanceString = ""
    local pingcount = 0

    for i = 1, #wdsPings.array do
        local point = wdsPings.array[i]
        local distance = math.floor(math.sqrt(((point.x - playerx) * (point.x - playerx)) +
        ((point.z - playerz) * (point.z - playerz))))
        local distancey = math.floor((point.y - playery) / 10)
        distance = math.floor(distance / 10)

        distanceString = tostring(distance)

        if (distance < 100) then
            distanceString = "0" .. tostring(distance)
        end

        if (distance < 10) then
            distanceString = "00" .. tostring(distance)
        end

        if (distance == 0) then
            distanceString = "000"
        end

        -- positive = even
        if (distancey > 0) then
            local _, rem = math.modf(distancey / 2)
            if (rem ~= 0) then
                distancey = distancey + 1
            end
        end

        -- negative = odd
        if (distancey < 0) then
            local _, rem = math.modf(distancey / 2)
            if (rem == 0) then
                distancey = distancey - 1
            end
        end

        distancey = math.abs(distancey)

        if (distancey < 10) then
            distanceyString = "0" .. tostring(distancey)
        else
            distanceyString = tostring(distancey)
        end

        pingTextureID = wdsPings.getTextureIdFromString(wdsPings.array[i].tex)

        if (pingTextureID < 10) then
            pingTextureIDString = "0" .. tostring(pingTextureID)
        else
            pingTextureIDString = tostring(pingTextureID)
        end

        if (distance < 999 and math.abs(distancey) < 99) then
            --10099120063
            --20718699279
            --2      07       18   440        693
            --type   pingid   y    distance   radpercent
            local radpluspi = math.atan2(point.x - playerx, point.z - playerz) + math.pi

            local radpercent = math.floor((radpluspi * 999) / (math.pi * 2))
            local radpercentString = tostring(radpercent)
            if (radpercent < 100) then
                radpercentString = "0" .. tostring(radpercent)
            end

            if (radpercent < 10) then
                radpercentString = "00" .. tostring(radpercent)
            end

            dataToShare = "4" .. pingTextureIDString .. distanceyString .. distanceString .. radpercentString
            wdsPings.share:QueueData(tonumber(dataToShare))
            pingcount = pingcount + 1
        end
    end

    local finishedstring = "39990000002"

    if(pingcount < 999)then
        finishedstring = "3" .. tostring(pingcount) .. "0000002"
    end

    if(pingcount < 100)then
        finishedstring = "30" .. tostring(pingcount) .. "0000002"
    end

    if(pingcount < 10)then
        finishedstring = "300" .. tostring(pingcount) .. "0000002"
    end

    if(pingcount == 0)then
        finishedstring = "30000000002"
    end

    wdsPings.share:QueueData(tonumber(finishedstring))

    if(SaveLoadHeaderReference == nil)then
        return
    end
    zo_callLater(function()
        if(wdsPings.headerString == "share")then
            wdsPings.headerLocked = false
            wdsPings.updateSaveLoad()
        end
    end, 3500)

    wdsPings.headerLocked = true
    SaveLoadHeaderReference.data.name = "|cEAC8E9[wd's pings] Re-shared [" .. wdsPings.GetNumberOfPingsInRange() .. "] pings in range."
    SaveLoadHeaderReference:UpdateValue()
    wdsPings.headerString = "share"

end

function wdsPings.GetNumberOfPingsInRange()
    local _, playerx, playery, playerz = GetUnitRawWorldPosition('player')
    local pingsInRange = 0
    for i = 1, #wdsPings.array do
        local point = wdsPings.array[i]
        local distance = math.floor(math.sqrt(((point.x - playerx) * (point.x - playerx)) +
        ((point.z - playerz) * (point.z - playerz))))
        local distancey = math.floor((point.y - playery) / 10)

        distance = math.floor(distance / 10)
        distancey = math.abs(distancey)

        if (distance < 999 and math.abs(distancey) < 99) then
            pingsInRange = pingsInRange + 1
        end
    end

    --d("pingsInRange: " .. pingsInRange)
    return pingsInRange
end

function wdsPings.ImportPings()

    local s = wdsPings.ImportString
    if(wdsPings.ImportString == "")then
        return
    end

    local t = {}
    local tf = {}
    local tff = {}

    for str in string.gmatch(s, "([^/]+)") do
        table.insert(t, str)
    end

    for i = 1, #t do
        local _, rem = math.modf(i / 2)
        if(rem == 0)then
            for str2 in string.gmatch(t[i], "([^,]+)") do
                tf[#tf+1] = str2
            end
            tff[math.floor(i / 2)] = tf
            tf = {}
        else
            tf[1] = t[i]
        end
    end

    local zoneid, _, _, _ = GetUnitRawWorldPosition('player')

    if(tostring(zoneid) == tostring(tff[1][1]))then
        for i = 1, #tff do
            local iconOSI = OSI.CreatePositionIcon(tff[i][2], tff[i][3], tff[i][4], wdsPings.GetIdFromElmsID(tff[i][5]), wdsPings.settings.scalePermPing * 10, OSI.BASECOLOR, -0.3)
            wdsPings.array[#wdsPings.array + 1] = iconOSI
        end
    end

    wdsPings.SavePings(false)

    ElmsHeader.data.name = "|cff746c[Beta]|r|cA9DDB1 Imported [" .. #tff .. "] pings from Elm's Markers|r"
    ElmsHeader:UpdateValue()
    wdsPings.submenuLocked = true
    zo_callLater(function()
        wdsPings.submenuLocked = false
        wdsPings.updateSaveLoad()
    end, 3500)
end

function wdsPings.GetIdFromElmsID(id)

    if(id == "1")then
        return "wdsPings/icons/1.dds"
    end
    if(id == "2")then
        return "wdsPings/icons/2.dds"
    end
    if(id == "3")then
        return "wdsPings/icons/3.dds"
    end
    if(id == "4")then
        return "wdsPings/icons/4.dds"
    end
    if(id == "5")then
        return "wdsPings/icons/5.dds"
    end
    if(id == "6")then
        return "wdsPings/icons/6.dds"
    end
    if(id == "7")then
        return "wdsPings/icons/7.dds"
    end
    if(id == "8")then
        return "wdsPings/icons/8.dds"
    end
    if(id == "9")then
        return "wdsPings/icons/9.dds"
    end
    if(id == "10")then
        return "wdsPings/icons/10.dds"
    end
    if(id == "11")then
        return "wdsPings/icons/11.dds"
    end
    if(id == "12")then
        return "wdsPings/icons/12.dds"
    end
    if(id == "13")then
        return "wdsPings/icons/Arrow.dds"
    end
    if(id == "14")then
        return "wdsPings/icons/default_ping.dds"
    end
    if(id == "15")then
        return "wdsPings/icons/Shield.dds"
    end
    if(id == "16")then
        return "wdsPings/icons/Shield_green.dds"
    end
    if(id == "17")then
        return "wdsPings/icons/Shield_orange.dds"
    end
    if(id == "18")then
        return "OdySupportIcons/icons/squares/square_orange_OT.dds"
    end
    if(id == "19")then
        return "wdsPings/icons/Shield_rose.dds"
    end
    if(id == "20")then
        return "wdsPings/icons/Shield_purple.dds"
    end
    if(id == "21")then
        return "OdySupportIcons/icons/squares/square_red_MT.dds"
    end
    if(id == "22")then
        return "wdsPings/icons/Shield_yellow.dds"
    end
    if(id == "23")then
        return "wdsPings/icons/default_ping.dds" -- diamond blue nothing
    end
    if(id == "24")then
        return "wdsPings/icons/default_ping.dds" -- diamond blue 1
    end
    if(id == "25")then
        return "wdsPings/icons/default_ping.dds" -- diamond blue 2
    end
    if(id == "26")then
        return "wdsPings/icons/default_ping.dds" -- diamond blue 3
    end
    if(id == "27")then
        return "wdsPings/icons/default_ping.dds" -- diamond blue 4
    end
    if(id == "28")then
        return "wdsPings/icons/default_ping_green.dds" -- diamond green
    end
    if(id == "29")then
        return "wdsPings/icons/default_ping_green.dds" -- diamond green 1
    end
    if(id == "30")then
        return "wdsPings/icons/default_ping_green.dds" -- diamond green 2
    end
    if(id == "31")then
        return "wdsPings/icons/default_ping_green.dds" -- diamond green 3
    end
    if(id == "32")then
        return "wdsPings/icons/default_ping_green.dds" -- diamond green 4
    end
    if(id == "33")then
        return "wdsPings/icons/default_ping_orange.dds" -- diamond orange
    end
    if(id == "34")then
        return "wdsPings/icons/default_ping_orange.dds" -- diamond orange 1
    end
    if(id == "35")then
        return "wdsPings/icons/default_ping_orange.dds" -- diamond orange 2
    end
    if(id == "36")then
        return "wdsPings/icons/default_ping_orange.dds" -- diamond orange 3
    end
    if(id == "37")then
        return "wdsPings/icons/default_ping_orange.dds" -- diamond orange 4
    end
    if(id == "38")then
        return "wdsPings/icons/default_ping_rose.dds" -- diamond pink
    end
    if(id == "39")then
        return "wdsPings/icons/default_ping_purple.dds" -- diamond red 
    end
    if(id == "40")then
        return "wdsPings/icons/default_ping_purple.dds" -- diamond red 1
    end
    if(id == "41")then
        return "wdsPings/icons/default_ping_purple.dds" -- diamond red 2
    end
    if(id == "42")then
        return "wdsPings/icons/default_ping_purple.dds" -- diamond red 3
    end
    if(id == "43")then
        return "wdsPings/icons/default_ping_purple.dds" -- diamond red 4
    end
    if(id == "44")then
        return "wdsPings/icons/default_ping_yellow.dds" -- diamond yellow
    end
    if(id == "45")then
        return "wdsPings/icons/default_ping_rose.dds"
    end
    if(id == "46")then
        return "wdsPings/icons/default_ping_rose.dds"
    end

    return "wdsPings/icons/default_ping.dds"
    

end

EVENT_MANAGER:RegisterForEvent(wdsPings.name, EVENT_PLAYER_ACTIVATED, wdsPings.OnPlayerActivated)
