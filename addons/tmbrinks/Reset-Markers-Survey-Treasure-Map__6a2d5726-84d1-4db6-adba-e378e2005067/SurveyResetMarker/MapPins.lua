local LMP = LibMapPins
local CCP = COMPASS_PINS
if (not LMP or not CCP) then return end

local LCA = LibCombatAlerts

SurveyResetMarker.pins = {
	PIN_TYPE_ID = "SRM_Pins",
	PIN_LEVEL = ZO_MapPin.PIN_ORDERS.PLAYERS - 1,
	PIN_TEXTURE = "/esoui/art/zonestories/completiontypeicon_pointofinterest.dds",
}
local SRMP = SurveyResetMarker.pins

function SRMP.Initialize( )
	-- Map Pins ----------------------------------------------------------------

	local mapCallback = function( )
		SRMP.AddPins(true)
	end

	local mapLayout = {
		level = SRMP.PIN_LEVEL,
		texture = SRMP.PIN_TEXTURE,
		tint = SRMP.GetPinColorDef,
		size = 32,
	}

	local mapTooltip = {
		creator = SRMP.PopulateMapTooltip,
		tooltip = ZO_MAP_TOOLTIP_MODE.INFORMATION,
	}

	LMP:AddPinType(SRMP.PIN_TYPE_ID, mapCallback, nil, mapLayout, mapTooltip)
	LMP:AddPinFilter(SRMP.PIN_TYPE_ID, GetString(SI_SRM_MAPPINS_FILTER_LABEL), false, SRMP.SV)

	-- Compass Pins ------------------------------------------------------------

	local compassCallback = function( )
		SRMP.AddPins(false)
	end

	local compassLayout = {
		maxDistance = 0.1,
		texture = SRMP.PIN_TEXTURE,
		mapPinTypeString = SRMP.PIN_TYPE_ID,
		additionalLayout = {
			update = function( pin )
				pin:GetNamedChild("Background"):SetColor(SRMP.GetPinColorUnpacked(pin))
			end,
			reset = function( pin )
				pin:GetNamedChild("Background"):SetColor(1, 1, 1, 1)
			end,
		},
		onToggleCallback = function( compassPinType, enabled )
			CCP:SetCompassPinEnabled(compassPinType, enabled)
			CCP:RefreshPins(compassPinType)
		end,
	}

	CCP:AddCustomPin(SRMP.PIN_TYPE_ID, compassCallback, compassLayout)
	LCA.MonitorZoneChanges("SRMP_ZoneChange", function()
		CCP:RefreshPins(SRMP.PIN_TYPE_ID)
	end)

	-- Test Mode ---------------------------------------------------------------

	SLASH_COMMANDS["/rmtestmaps"] = function( )
		if (SRMP.AddPins == SRMP.AddPinsTestMode and SRMP.AddPinsOriginal) then
			SRMP.AddPins = SRMP.AddPinsOriginal
		else
			SRMP.AddPinsOriginal = SRMP.AddPins
			SRMP.AddPins = SRMP.AddPinsTestMode
		end
		SRMP.Refresh()
	end
end

function SRMP.GetItemLink( pin )
	local itemId = pin.GetPinTypeAndTag and select(2, pin:GetPinTypeAndTag()) or pin.pinTag
	return string.format("|H0:item:%d:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", itemId or 0)
end

function SRMP.AddPins( isForMap )
	if (not LMP:IsEnabled(SRMP.PIN_TYPE_ID)) then return end

	local system = isForMap and LMP or CCP
	local zoneId = isForMap and GetZoneId(GetCurrentMapZoneIndex()) or LCA.GetZoneId()
	local zone = SRMP.MARKER_DATA[zoneId]

	if (zone) then -- Markers exist for this zone
		local displayed = { }
		local bagCache = SHARED_INVENTORY:GetOrCreateBagCache(BAG_BACKPACK)
		for _, data in pairs(bagCache) do
			local itemId = GetItemId(data.bagId, data.slotIndex)
			if (zone[itemId] and not displayed[itemId]) then -- Markers exist for this item
				displayed[itemId] = true
				for _, marker in ipairs(zone[itemId]) do
					local markerType, pos = SRMP.DecodeMarker(marker)
					if (markerType == 5 or markerType == 6) then
						system:CreatePin(SRMP.PIN_TYPE_ID, itemId, GetNormalizedWorldPosition(zoneId, unpack(pos)))
					end
				end
			end
		end
	end
end

function SRMP.AddPinsTestMode( isForMap )
	if (not LMP:IsEnabled(SRMP.PIN_TYPE_ID)) then return end

	local system = isForMap and LMP or CCP
	local zoneId = isForMap and GetZoneId(GetCurrentMapZoneIndex()) or LCA.GetZoneId()
	local zone = SRMP.MARKER_DATA[zoneId]

	if (zone) then -- Markers exist for this zone
		for itemId, markers in pairs(zone) do
			for _, marker in ipairs(markers) do
				local markerType, pos = SRMP.DecodeMarker(marker)
				if (markerType == 5 or markerType == 6) then
					system:CreatePin(SRMP.PIN_TYPE_ID, itemId, GetNormalizedWorldPosition(zoneId, unpack(pos)))
				end
			end
		end
	end
end

function SRMP.GetPinColorUnpacked( pin )
	local colorKey = select(2, GetItemLinkItemType(SRMP.GetItemLink(pin))) == SPECIALIZED_ITEMTYPE_TROPHY_SURVEY_REPORT and "survey" or "treasure"
	return LCA.UnpackRGBA(BitOr(SRMP.SV.colors[colorKey], 0xFF))
end

function SRMP.GetPinColorDef( pin )
	return ZO_ColorDef:New(SRMP.GetPinColorUnpacked(pin))
end

function SRMP.PopulateMapTooltip( pin )
	local itemLink = SRMP.GetItemLink(pin)
	local text = string.format("%d× %s", GetItemLinkInventoryCount(itemLink, INVENTORY_COUNT_BAG_OPTION_BACKPACK), itemLink)

	if (IsInGamepadPreferredMode()) then
		local InformationTooltip = ZO_MapLocationTooltip_Gamepad
		local baseSection = InformationTooltip.tooltip
		InformationTooltip:LayoutIconStringLine(baseSection, nil, text, baseSection:GetStyle("mapLocationTooltipContentName"))
	else
		InformationTooltip:AddLine(text)
	end
end

function SRMP.Refresh( )
	LMP:RefreshPins(SRMP.PIN_TYPE_ID)
	CCP:RefreshPins(SRMP.PIN_TYPE_ID)
end

function SRMP.GetEnabled( enabled )
	return SRMP.SV[SRMP.PIN_TYPE_ID]
end

function SRMP.SetEnabled( enabled )
	SRMP.SV[SRMP.PIN_TYPE_ID] = enabled
	LMP:SetEnabled(SRMP.PIN_TYPE_ID, enabled)
	SRMP.Refresh()
end
