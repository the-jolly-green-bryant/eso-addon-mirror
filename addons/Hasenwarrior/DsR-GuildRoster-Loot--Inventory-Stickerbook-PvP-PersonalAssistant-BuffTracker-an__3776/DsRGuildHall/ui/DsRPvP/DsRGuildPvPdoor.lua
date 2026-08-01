DsRGuildPvPdoor = ZO_Object:Subclass()

local DsR_PinsDoor  = "DsR_Door"
local LMP          = LibMapPins

local pinColor

-------------------------------------------------------------------------------------------------------------------------------------------------
-- function RecordPosition()
--     local zone, subzone = LMP:GetZoneAndSubzone()
--     local x, z, heading = GetMapPlayerPosition("player")
--     DsRGuildPvPdoorSavedVars.doorsData = DsRGuildPvPdoorPins_SetLocalData(DsRGuildPvPdoorSavedVars.doorsData, zone, subzone, {x, z, heading})
-- end

-------------------------------------------------------------------------------------------------------------------------------------------------
local function SetPinColor(pin)
    return pinColor
end

-------------------------------------------------------------------------------------------------------------------------------------------------
local function PinCallback()
    if not LMP:IsEnabled(DsR_PinsDoor) or (GetMapType() > MAPTYPE_ZONE) then
        return
    end

    if not IsPlayerActivated() then
        return
    end

    local zone, subzone = LMP:GetZoneAndSubzone()
    local data = DsRGuildPvPdoorPins_GetLocalData(zone, subzone)

    if data ~= nil then
        for _, pinData in ipairs(data) do
            LMP:CreatePin(DsR_PinsDoor, pinData, pinData[1], pinData[2])
        end
    end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
local function ImpCallback(pinType)
    if GetMapType() > MAPTYPE_ZONE then
        return
    end

    if not IsPlayerActivated() then
        return
    end

    if not DsRGuildPvP.pvp.PvPdoorImperial then
        return
    end

    local zone, subzone = LMP:GetZoneAndSubzone()
    if zone == "cyrodiil" and subzone == "imperialcity_base" then
        local data = DsRGuildPvPdoorPins_GetImperialData()
        for _, pinData in ipairs(data) do
            if pinData.label == pinType then
                if LMP:IsEnabled(pinData.label) then
                    LMP:CreatePin(pinData.label, pinData, pinData.x, pinData.y)
                end
            end
        end
    end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
local function ScampCallback(pinType)
    if GetMapType() > MAPTYPE_ZONE then
        return
    end

    if not IsPlayerActivated() then
        return
    end

    if not DsRGuildPvP.pvp.PvPScampImperial then
        return
    end

    local zone, subzone = LMP:GetZoneAndSubzone()
    if subzone == "imperialsewer_ebonheart1_base"  or subzone == "imperialsewer_ebonheart2_base"  or subzone == "imperialsewer_ebonheart3_base"  or     -- Ebenerz
       subzone == "imperialsewer_aldmeri1_base"    or subzone == "imperialsewer_aldmeri2_base"    or subzone == "imperialsewer_aldmeri3_base"    or     -- Aldmeri
       subzone == "imperialsewer_daggerfall1_base" or subzone == "imperialsewer_daggerfall2_base" or subzone == "imperialsewer_daggerfall3_base" or     -- Dolchsturz
       subzone == "imperialsewers_ebon1_base"      or subzone == "imperialsewers_ebon2_base"      or subzone == "imperialsewers_aldmeri1_base"   or subzone == "imperialsewers_aldmeri2_base" or subzone == "imperialsewers_aldmeri3_base" or   -- Fraktionsbasis
       subzone == "imperialsewershub_base" then  -- Molag Bal
       
        local data = DsRGuildPvPdoorPins_GetScampData()
        for _, pinData in ipairs(data) do
            if pinData.label == pinType then
                if LMP:IsEnabled(pinData.label) then
                    LMP:CreatePin(pinData.label, pinData, pinData.x, pinData.y)
                end
            end
        end
    end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
local function Init(event, name)
    if DsRGuildPvP.pvp.PvPdoorOnOff then
        pinColor = ZO_ColorDef:New(DsRGuildPvP.pvp.PvPdoorPinRGB)
    
        local layout = {
            level   = DsRGuildPvP.pvp.PvPdoorPinLevel,
            texture = "/DsRGuildHall/misc/DsR_CastleDoor.dds",
            size    = DsRGuildPvP.pvp.PvPdoorPinSize,
            tint    = SetPinColor
        }
        LMP:AddPinType(DsR_PinsDoor, PinCallback, nil, layout, nil)

        local impData = DsRGuildPvPdoorPins_GetImperialData() 
        for _, data in ipairs(impData) do
            local impLayout = {
                level   = 40,
                texture = data.path,
                size    = data.size / 2,
                hex     = ZO_SELECTED_TEXT:ToHex()
            }
            LMP:AddPinType(data.label, function () ImpCallback(data.label) end, nil, impLayout, nil)
        end
    end

    if DsRGuildPvP.pvp.PvPScampImperial then
        local ScampData = DsRGuildPvPdoorPins_GetScampData() 
        for _, data in ipairs(ScampData) do
            local ScampLayout = {
                level   = 40,
                texture = data.path,
                size    = data.size / 2,
                hex     = ZO_SELECTED_TEXT:ToHex()
            }
            LMP:AddPinType(data.label, function () ScampCallback(data.label) end, nil, ScampLayout, nil)
        end
    end

    EVENT_MANAGER:UnregisterForEvent("DsRGuildPvPdoor", EVENT_ADD_ON_LOADED)
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- On addon loaded
-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPdoor.OnAddonLoaded(event, name)
    EVENT_MANAGER:RegisterForEvent("DsRGuildPvPdoor", EVENT_ADD_ON_LOADED, Init)
    -- zo_calllater muss sein, wenn die Doors etc nicht angezeigt werden!!!!
    -- EVENT_MANAGER:RegisterForEvent("DsRGuildPvPdoor", EVENT_ADD_ON_LOADED, zo_callLater(Init, 250))
end
