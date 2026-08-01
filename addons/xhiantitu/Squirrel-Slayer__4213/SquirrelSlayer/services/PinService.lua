local addon = SquirrelSlayer
addon.Services.Pins = addon.Services.Pins or {}
local Pins = addon.Services.Pins

local mapPinsLibrary = rawget(_G, "LibMapPins") or (LibStub and LibStub("LibMapPins-1.0", true)) or nil
local pinLayout = { level = 50, texture = "SquirrelSlayer/icons/squirrel_pin.dds", size = 24 }

--- Retourne les SavedVariables de l'addon.
--- @return table|nil
local function GetSavedVariables()
    return addon.State.GetSV()
end

--- Affiche le tooltip d'un pin en fonction du nombre de kills fusionnés.
--- @param pin table
local function ShowPinTooltip(pin)
    local pinTag = pin.m_PinTag
    if pinTag and pinTag.count then
        InformationTooltip:AddLine(string.format(addon.GetString("pin_tooltip"), pinTag.count))
    end
end

--- Callback LibMapPins qui repeuple les pins visibles pour la carte courante.
local function PopulateMapPinsFromSavedSpots()
    local savedVariables = GetSavedVariables()
    if not savedVariables then return end

    local mapService = addon.Services.Map
    local currentRawMapKey = mapService.CurrentMapKey()
    local canonicalMapKey = mapService.CanonicalizeMapKey(currentRawMapKey)
    local spotList = savedVariables.spots[canonicalMapKey] or savedVariables.spots[currentRawMapKey]

    if not spotList then return end
    for _, spot in ipairs(spotList) do
        mapPinsLibrary:CreatePin(addon.Services.Spots.GetPinType(), spot, spot.x, spot.y)
    end
end

--- Force le rafraîchissement visuel des pins de l'addon.
function Pins.RefreshPins()
    if mapPinsLibrary and mapPinsLibrary.RefreshPins then
        mapPinsLibrary:RefreshPins(addon.Services.Spots.GetPinType())
    end
end

--- Enregistre le type de pin et branche les callbacks map.
function Pins.InitMapPins()
    if mapPinsLibrary and mapPinsLibrary.AddPinType then
        mapPinsLibrary:AddPinType(
            addon.Services.Spots.GetPinType(),
            PopulateMapPinsFromSavedSpots,
            nil,
            ZO_DeepTableCopy(pinLayout),
            { creator = ShowPinTooltip, tooltip = ZO_MAP_TOOLTIP_MODE.INFORMATION }
        )

        if mapPinsLibrary.AddPinFilter then
            mapPinsLibrary:AddPinFilter(addon.Services.Spots.GetPinType(), addon.GetString("filter_name"))
        end
        mapPinsLibrary:RefreshPins(addon.Services.Spots.GetPinType())
    end

    -- Sur changement de carte, on mémorise la région et on redessine.
    if CALLBACK_MANAGER then
        CALLBACK_MANAGER:RegisterCallback("OnWorldMapChanged", function()
            addon.Services.Map.RememberCurrentRegion()
            Pins.RefreshPins()
        end)
    end
end
