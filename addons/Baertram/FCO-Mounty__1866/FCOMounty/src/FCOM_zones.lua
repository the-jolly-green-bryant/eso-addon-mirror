if FCOM == nil then FCOM = {} end
local FCOMounty = FCOM

local function addZoneToSV(zoneName, subZoneName, addedNewZone, addedSubZoneToZone)
    local zoneData = FCOMounty.ZoneData
    if addedNewZone then
        FCOMounty.settingsVars.manuallyAddedZones[zoneName] = {
            [FCOM_ZONE_ID_STRING] = zoneData[zoneName][FCOM_ZONE_ID_STRING]
        }
    end
    if addedSubZoneToZone and subZoneName ~= nil then
        FCOMounty.settingsVars.manuallyAddedZones[zoneName] = FCOMounty.settingsVars.manuallyAddedZones[zoneName] or {}
        FCOMounty.settingsVars.manuallyAddedZones[zoneName][subZoneName] = zoneData[zoneName][subZoneName]
    end
    FCOMounty.preventerVars.ZoneDataWasUpdatedNowUpdateLAMDropdowns = true

    if addedSubZoneToZone and subZoneName ~= nil then
        if addedNewZone then
            d("[FCOMounty]Added the new zone \'".. zoneName .."\' and subZone \'".. subZoneName .."\' .\nPlease still use the slash command /fcomr to report this missing zone + subzone to the author so that others benefit from the data as well")
        else
            d("[FCOMounty]Added the subZone \'".. subZoneName .."\' to the existing zone \'".. zoneName .."\'.\nPlease still use the slash command /fcomr to report this missing zone + subzone to the author so that others benefit from the data as well")
        end
    elseif addedNewZone then
        d("[FCOMounty]Added the new zone \'".. zoneName .."\' to the ZoneData.\nPlease still use the slash command /fcomr to report this missing zone + subzone to the author so that others benefit from the data as well")
    end
end

--Try to add missing zone data to the table FCOMounty.ZoneData
function FCOMounty.EnhanceZoneDataByCurrentZone(zoneIndex)
    --d("FCOMounty.EnhanceZoneDataByCurrentZone")
    local isInDungeon, isInDelve = FCOMounty.isPlayerInDungeon()
    if isInDungeon or isInDelve then return false end
    local houseOwner = GetCurrentHouseOwner()
    if houseOwner and houseOwner ~= "" then return end

    local zoneId, parentZoneId
    zoneIndex = zoneIndex or GetCurrentMapZoneIndex()
    if not zoneIndex then return false end
    zoneId = GetZoneId(zoneIndex)
    if zoneId == nil or zoneId <= 0 then return false end
    parentZoneId = GetParentZoneId(zoneId)
    if parentZoneId == nil then return false end
    --We are only able to check the currently active subzone data! Not all data at the map.
    local zoneName, subzoneName, _, _ = FCOMounty.GetZoneAndSubzone()
    if zoneName ~= nil and zoneName ~= "" then
        --d("[FCOMounty]Current zoneName(ID): " ..tostring(zoneName) .. "(".. tostring(zoneId) .."), subzoneName: " ..tostring(subzoneName))
        local zoneData = FCOMounty.ZoneData
        local addedNewZone = false
        if zoneData[zoneName] == nil then
            addedNewZone = true
            FCOMounty.ZoneData[zoneName] = {}
        end
        FCOMounty.ZoneData[zoneName][FCOM_ZONE_ID_STRING] = zoneId
        if subzoneName ~= nil and subzoneName ~= "" then
            if zoneData[zoneName][subzoneName] == nil then
                FCOMounty.ZoneData[zoneName][subzoneName] = subzoneName .. "||" ..tostring(zoneId)
                addZoneToSV(zoneName, subzoneName, addedNewZone, true)
                return true, FCOMounty.ZoneData[zoneName][subzoneName]
            end
        else
            if addedNewZone == true then
                addZoneToSV(zoneName, nil, addedNewZone, false)
                return true, FCOMounty.ZoneData[zoneName]
            end
        end
    end
    return false
end
local enhanceZoneDataByCurrentZone = FCOMounty.EnhanceZoneDataByCurrentZone

--Return the zonedata
function FCOMounty.GetZoneData(zone, subzone)
    local zoneData = FCOMounty.ZoneData
    local zoneGiven     = zone ~= nil and type(zone) == "string" and zone ~= ""
    local subZoneGiven  = subzone ~= nil and subzone ~= "" and subzone ~= "zoneId" and subzone ~= FCOM_NONE_ENTRIES and subzone ~= FCOM_ALL_ENTRIES
    local subZoneNotOrALLGiven = subzone == nil or (subzone ~= nil and subzone == FCOM_ALL_ENTRIES)
    --d("[FCOMounty.GetZoneData] zone: " .. tostring(zone) .. ", subZone: " ..tostring(subzone))
    local debugOutput = false
    if zoneGiven and subZoneGiven then
        if zoneData[zone] and zoneData[zone][subzone] then
            return zoneData[zone][subzone]
        else
            debugOutput = true
        end
    elseif zoneGiven and (subZoneGiven or subZoneNotOrALLGiven) then
        if zoneData[zone] then
            return zoneData[zone]
        else
            debugOutput = true
        end
    end

    --Prevent endless loop
    if FCOMounty.preventerVars.GetZoneDataCallActive == true then return nil end

    --Show debug output about zone/subZone missing?
    local isInDungeon, isInDelve = FCOMounty.isPlayerInDungeon()
    local houseOwner = GetCurrentHouseOwner()
    if not isInDungeon and not isInDelve and (not houseOwner or (houseOwner and houseOwner == "")) then
        local zoneIndex = GetCurrentMapZoneIndex()
        if zoneIndex ~= nil then
            local zoneDataUpdated
            local wasZoneDataUpdated, _ = enhanceZoneDataByCurrentZone(zoneIndex)
            if wasZoneDataUpdated == true then
                FCOMounty.preventerVars.GetZoneDataCallActive = true
                zoneDataUpdated = FCOMounty.GetZoneData(zone, subzone)
                FCOMounty.preventerVars.GetZoneDataCallActive = false
            end
            local settings = FCOMounty.settingsVars.settings
            if debugOutput and settings.debug == true then
                d(">========================================>")
                d("[FCOMounty] The current zone data is missing.")
                d("Please use the chat command /fcomr ingame, AT THE SAME POSITION WHERE THIS ERROR MESSAGE IS SHOWN, to report the missing data as a bug.")
                d("Watch the chat for feedback about the missing data.")
                d("<========================================<")
            end
            return zoneDataUpdated, wasZoneDataUpdated
        end
    end
    --Return nil if nothing relevant was found
    return nil
end

--Map the zone and subzone to a "better explanatory name" as zone "Darkbrotherhood" e.g. should be "Goldcoast"
function FCOMounty.MapZoneAndSubZoneNames(zone, subzone)
    --Zone or subzone are given?
    if zone == nil or zone == "" then return zone, subzone end
    local zones = FCOMounty.ZoneData
    if zones == nil then return zone, subzone end
    local subZones = zones[zone]
    if subZones == nil then return zone, subzone end
    local mappedSubZoneName = ""
    if subzone ~= nil then
        local mappedSubZoneNameTmp = subZones[subzone] or ""
        --The subzone vale is a true/false-> No mapping name is given
        if type(mappedSubZoneNameTmp) == "boolean" then
            --Reset the mapped subzone name to empty string so the subzone name will be used
            mappedSubZoneName = ""
            --The subzone vale is a String-> A mapping name is given
        elseif type(mappedSubZoneNameTmp) == "string" and mappedSubZoneNameTmp ~= "" then
            --Reset the mapped subzone name to empty string so the subzone name will be used
            mappedSubZoneName = mappedSubZoneNameTmp
        end
    end
    local mappedZoneName = subZones[FCOM_ZONE_MAPPING_STRING] or ""
    if mappedZoneName == "" then mappedZoneName = zone end
    if mappedSubZoneName == "" then mappedSubZoneName = subzone end
    --Check if a mapped zonename exists
    return mappedZoneName, mappedSubZoneName
end

--Get the zone and subZone string from libMapPins
--[[
function FCOMounty.GetZoneAndSubzone()
    --Single function code taken from library libMapPins, original authors: Garkin, Ayantir, Fyrakin, Sensi
    --> All credits go to them!
    -- Returns zone and subzone derived from map texture. Format: zone, subZone
    local zone, subzone =  select(3,(GetMapTileTexture()):lower():find("maps/([%w%-]+)/([%w%-]+_[%w%-]+)"))
    --d(">mapTextzone: " ..tostring(GetMapTileTexture()) .. ", zone: "..tostring(zone) .. ", subZone: " .. tostring(subzone))
    return zone, subzone
end
]]

--[[
    Possible texture names are e.g.
    /art/maps/southernelsweyr/els_dragonguard_island05_base_8.dds
    /art/maps/murkmire/tsofeercavern01_1.dds
    /art/maps/housing/blackreachcrypts.base_0.dds
    /art/maps/housing/blackreachcrypts.base_1.dds
    Art/maps/skyrim/blackreach_base_0.dds
    Textures/maps/summerset/alinor_base.dds
]]
function FCOMounty.GetZoneAndSubzone(mapTileTextureName)
    local libZone = FCOMounty.libZone
    local zoneName, subzoneName, mapTileTextureNameLower, mapTileTextureNameLowerOrigUnchanged = libZone:GetZoneNameByMapTexture(mapTileTextureName, nil, false)
    return zoneName, subzoneName, mapTileTextureNameLower, mapTileTextureNameLowerOrigUnchanged
end

--Get the zone and subZone string from libMapPins and post them into the chat
function FCOMounty.zone2Chat()
    local zone, subZone, mapTileTextureNameLower = FCOMounty.GetZoneAndSubzone()
    if zone == nil then zone = "<missing>" end
    if subZone == nil then subZone = "<missing>" end
    if mapTileTextureNameLower == nil or mapTileTextureNameLower == "" then mapTileTextureNameLower = "<missing>" end
    local libZone = FCOMounty.libZone
    local currentZoneId, currentZoneParentId, currentZoneIndex, currentZoneParentIndex = libZone:GetCurrentZoneIds()
    d("[FCOMounty] Current zone: " .. tostring(zone) .. ", current subzone: " .. tostring(subZone) .. ", map tile texture name: " ..tostring(mapTileTextureNameLower) .. ", zoneId: " ..tostring(currentZoneId).. ", parentZoneId: " ..tostring(currentZoneParentId) .. ", zoneIndex: " ..tostring(currentZoneIndex).. ", parentZoneIndex: " ..tostring(currentZoneParentIndex))
end

--Report missing zone data at the ESOUI website, addon author portal, FCOMounty as new bug
function FCOMounty.reportMissingZoneData()
    local isInDungeon = IsUnitInDungeon("player")
    local houseOwner = GetCurrentHouseOwner()
    if isInDungeon or (houseOwner and houseOwner ~= "") then
        d("[FCOMounty]|cFF0000ERROR|r - FCOMounty does not work inside dungeons/delves/houses.\nValid zones and subZones are only worldmaps overland or city areas.")
        return
    end
    local zone, subZone, mapTileTextureNameLowerOrig, mapTileTextureNameLowerOrigUnchanged = FCOMounty.GetZoneAndSubzone()
    local zoneDataKnown, wasZoneDataUpdated
    local isStillMissing = false
    --Check if the zone and subZone are missing yet
    if zone == nil or subZone == nil or mapTileTextureNameLowerOrig == nil or mapTileTextureNameLowerOrig == "" then
        isStillMissing = true
    else
        --zone and subzone were found, so check if they are in the FCOMounty data already
        --Disable chat debut output temporarily to skip error message showing to use chat command /fcomr, which we currently use already!
        local settings = FCOMounty.settingsVars.settings
        local settingsDebugWasActive = false
        if settings.debug == true then
            settingsDebugWasActive = true
            FCOMounty.settingsVars.settings = false
        end
        zoneDataKnown, wasZoneDataUpdated = FCOMounty.GetZoneData(zone, subZone)
        --Reenable the debug settings if they were enabled before
        if settingsDebugWasActive == true then
            FCOMounty.settingsVars.settings = true
        end
        --Is the zoneData already in FCOMounty data?
        if not zoneDataKnown then
            isStillMissing = true
        end
    end
    --Not missing: Show the error message to the user
    if not isStillMissing then
        if wasZoneDataUpdated ~= nil and wasZoneDataUpdated == true then
            d(string.format("|cFF0000The zone |r\'%s\'|cFF0000 and/or subzone |r\'%s\'|cFF0000 you are reporting are/is missing within FCOMounty data!|r\n\n|cFFFFFFA popup will open where you need to acknowledge the open of the FCOMounty bug create website. At this website the missing information will be reported to the FCOMounty addon author as a bug report.|r\n|cFFFFFFSome data will be pre-entered (zoneid, zonename, subzonename, client language) and you simply need to send it via this website to the author.\nThe data will be added locally to the table for now and will be used until next zone change/reloadui!|r", tostring(zone), tostring(subZone)))
        else
            d(string.format("|c00FF00The zone |r\'%s\'|c00FF00 and subzone |r\'%s\'|c00FF00 you wanted to report already exist!|r\nBefore reporting missing zone and subzones make sure to open the FCOMounty settings and press the button \'Current zone\'.\nIf the zone and subzone are already supported the button will change the dropdown boxes to the zone and subzone automatically.\n\n|cFFFFFFIf the dropdownbox values do not change the zone or subzone are still missing.|r\n|cFFFFFFOnly then you won't see this text here but a popup which will open a website.|r\n|cFFFFFFAt this website the missing information will be reported to the FCOMounty addon author as a bug report.|r\n|cFFFFFFSome data will be pre-entered (zoneid, zonename, subzonename, client language) and you simply need to send it via this website to the author.\nThe data will be added locally to the table for now and will be used until next zone change/reloadui!|r", tostring(zone), tostring(subZone)))
        end
        return
    else
        d(string.format("|cFF0000The zone |r\'%s\'|cFF0000 and/or subzone |r\'%s\'|cFF0000 you are reporting are/is missing within FCOMounty data!|r\n\n|cFFFFFFA popup will open where you need to acknowledge the open of the FCOMounty bug create website. At this website the missing information will be reported to the FCOMounty addon author as a bug report.|r\n|cFFFFFFSome data will be pre-entered (zoneid, zonename, subzonename, client language) and you simply need to send it via this website to the author.|r", tostring(zone), tostring(subZone)))
    end
    --Missing:
    --Create the string of the esoui report feature/bug panel of FCOMounty.
    --https://www.esoui.com/portal.php?id=136&a=bugreport&title=Missing%20zonedata&addonid=1866&message=zoneId:%20123456\nsubZoneId:%207890123\ntexturename:%20esoui/data/test/texture_map_01.dds
    local addonId = FCOMounty.addonVars.bugReportAddonId
    local bugReportPattern = FCOMounty.addonVars.bugReportURL
    local libZone = FCOMounty.libZone
    local zoneId = GetZoneId(GetCurrentMapZoneIndex())
    local zoneName = libZone:GetZoneName(zoneId, "en")
    --Missing zoneData: skyrim(1160)/westernskryim_base [Western Skyrim]
    local bugReportTitle = "Missing zoneData: " ..tostring(zone) .. "("..tostring(zoneId)  .. ")/" .. tostring(subZone) .. " ["..zoneName.."]"
    local bugReportText = "Zone: " ..tostring(zone) .. "%0D%0AZoneId: " ..tostring(zoneId) .. "%0D%0ASubZone: " ..tostring(subZone) .. "%0D%0ATextureFile: " ..tostring(mapTileTextureNameLowerOrig) .. "%0D%0AClient language: " ..tostring(GetCVar("language.2"))
    local bugReportURL = string.format(bugReportPattern, addonId, bugReportTitle, bugReportText)
    if bugReportURL ~= "" then
        --Show the URL open dialog
        RequestOpenUnsafeURL(bugReportURL)
    end
end
