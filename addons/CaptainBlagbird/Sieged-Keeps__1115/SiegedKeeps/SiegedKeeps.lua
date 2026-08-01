--[[

Sieged Keeps
by CaptainBlagbird
https://github.com/CaptainBlagbird

--]]

-- Addon info
SiegedKeeps = {}
SiegedKeeps.name = "SiegedKeeps"

-- Libraries
local LMP = LibMapPins

-- Constatnts
local NUM_KEEPS = 144  -- GetNumKeeps() returns 93 which isn't what we need
local COLOR_AD = "|cF9F280"
local COLOR_DC = "|c7CA4C5"
local COLOR_EP = "|cDC564A"
local COLOR_ESO = "|cC5C29E"
local PIN_TYPE_SIEGE = SiegedKeeps.name.."_PinTypeSiege"
local PIN_ICON_DIR = "SiegedKeeps/icons/"
local PIN_ICON_AD       = PIN_ICON_DIR.."pin_AD.dds"
local PIN_ICON_DC       = PIN_ICON_DIR.."pin_DC.dds"
local PIN_ICON_EP       = PIN_ICON_DIR.."pin_EP.dds"
local PIN_ICON_AD_DC    = PIN_ICON_DIR.."pin_AD_DC.dds"
local PIN_ICON_AD_EP    = PIN_ICON_DIR.."pin_AD_EP.dds"
local PIN_ICON_DC_EP    = PIN_ICON_DIR.."pin_DC_EP.dds"
local PIN_ICON_AD_DC_EP = PIN_ICON_DIR.."pin_AD_DC_EP.dds"

-- Settings (TODO: Maybe move to settings menu)
local REFRESH_INTERVAL_MS = 5000
local PIN_SIZE = 70
local PIN_SIZE_RESOURCE = 40
local PIN_LEVEL = 10

-- Local variables
local isRefreshing = false


-- Get the battleground context that matches the displayed AvA map
local function GetDisplayedBattlegroundContext()
    local bgQuery = BGQUERY_UNKNOWN
    if IsPlayerInAvAWorld() then
        bgQuery = BGQUERY_LOCAL
    -- elseif false then  -- TODO: Detect map displaying white keeps
        -- bgQuery = BGQUERY_UNKNOWN
    elseif GetAssignedCampaignId() ~= NONE then
        bgQuery = BGQUERY_ASSIGNED_CAMPAIGN
    end
    return bgQuery
end

-- Stop refreshing in interval if not yet stopped
local function StopRefreshing()
    if isRefreshing then
        isRefreshing = not EVENT_MANAGER:UnregisterForUpdate(SiegedKeeps.name)
    end
end

-- Start refreshing in interval if not yet started
local function StartRefreshing()
    if not isRefreshing then
        isRefreshing = EVENT_MANAGER:RegisterForUpdate(SiegedKeeps.name, REFRESH_INTERVAL_MS, function() LMP:RefreshPins(PIN_TYPE_SIEGE) end)
    end
end

-- Callback function which is called every time the map is viewed, creates quest pins
local function MapCallbackQuestPins()
    -- Only continue if map is open
    if ZO_WorldMap:IsHidden() then
        StopRefreshing()
        return
    end
    -- Only continue if current map is the Cyrodiil overview
    if LMP:GetZoneAndSubzone(true) ~= "cyrodiil/ava_whole" then
        StopRefreshing()
        return
    end
    -- Only continue if a valid battleground context is set
    local bgQuery = GetDisplayedBattlegroundContext()
    if bgQuery == BGQUERY_UNKNOWN then
        StopRefreshing()
        return
    end
    
    for i=1, NUM_KEEPS, 1 do
        local ad = GetNumSieges(i, bgQuery, ALLIANCE_ALDMERI_DOMINION)
        local ep = GetNumSieges(i, bgQuery, ALLIANCE_EBONHEART_PACT)
        local dc = GetNumSieges(i, bgQuery, ALLIANCE_DAGGERFALL_COVENANT)
        if ad+ep+dc > 0 then
            -- Smaller icon for resources
            if GetKeepType(i) == KEEPTYPE_RESOURCE then
                LMP:SetLayoutKey(PIN_TYPE_SIEGE, "size", PIN_SIZE_RESOURCE)
            else
                LMP:SetLayoutKey(PIN_TYPE_SIEGE, "size", PIN_SIZE)
            end
             
            -- Set correct pin icon
            if ad > 0 and dc > 0 and ep > 0 then
                LMP:SetLayoutKey(PIN_TYPE_SIEGE, "texture", PIN_ICON_AD_DC_EP)
            elseif ad > 0 and dc > 0 then
                LMP:SetLayoutKey(PIN_TYPE_SIEGE, "texture", PIN_ICON_AD_DC)
            elseif ad > 0 and ep > 0 then
                LMP:SetLayoutKey(PIN_TYPE_SIEGE, "texture", PIN_ICON_AD_EP)
            elseif dc > 0 and ep > 0 then
                LMP:SetLayoutKey(PIN_TYPE_SIEGE, "texture", PIN_ICON_DC_EP)
            elseif ad > 0 then
                LMP:SetLayoutKey(PIN_TYPE_SIEGE, "texture", PIN_ICON_AD)
            elseif dc > 0 then
                LMP:SetLayoutKey(PIN_TYPE_SIEGE, "texture", PIN_ICON_DC)
            elseif ep > 0 then
                LMP:SetLayoutKey(PIN_TYPE_SIEGE, "texture", PIN_ICON_EP)
            else -- Never reached
            end
            
            -- Create tooltip text
            local pinInfo = {COLOR_ESO.."Siege: "}
            if ad > 0 then pinInfo[1] = pinInfo[1]..COLOR_AD..tostring(ad).."  " end
            if dc > 0 then pinInfo[1] = pinInfo[1]..COLOR_DC..tostring(dc).."  " end
            if ep > 0 then pinInfo[1] = pinInfo[1]..COLOR_EP..tostring(ep) end
            pinInfo[1] = pinInfo[1]:gsub("%s+$", "")
            
            -- Get keep position and create pin
            local pinType, normalizedX, normalizedY = GetKeepPinInfo(i, bgQuery)
            if LMP:IsEnabled(PIN_TYPE_SIEGE) then
                LMP:CreatePin(PIN_TYPE_SIEGE, pinInfo, normalizedX, normalizedY)
            end
        end
    end
    
    -- Make sure refreshing is running
    StartRefreshing()
end

-- Event handler function for EVENT_PLAYER_ACTIVATED
local function OnPlayerActivated(eventCode)
    -- Get tootip of each individual pin
    local pinTooltipCreator = {
        creator = function(pin)
            local _, pinTag = pin:GetPinTypeAndTag()
            for _, lineData in ipairs(pinTag) do
                SetTooltipText(InformationTooltip, lineData)
            end
        end,
        tooltip = 1,
    }
    local pinLayout = {size = PIN_SIZE, level = PIN_LEVEL}
    LMP:AddPinType(PIN_TYPE_SIEGE, MapCallbackQuestPins, nil, pinLayout, pinTooltipCreator)
    -- Make sure the pins are updated every time the map is opened by using an action layer event
    EVENT_MANAGER:RegisterForEvent(SiegedKeeps.name, EVENT_ACTION_LAYER_PUSHED, function() LMP:RefreshPins(PIN_TYPE_SIEGE) end)
    
    EVENT_MANAGER:UnregisterForEvent(SiegedKeeps.name, EVENT_PLAYER_ACTIVATED)
end
EVENT_MANAGER:RegisterForEvent(SiegedKeeps.name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)