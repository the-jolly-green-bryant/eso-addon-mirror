local LCA = LibCombatAlerts

SurveyResetMarker = {
	name = "SurveyResetMarker",

	varVersion = "2",
	defaults = {
		locationVertical = false,
		colors = {
			survey = 0x33CCFF99,
			treasure = 0xFF00DD99,
			counter = 0x99999999,
		},
	},
}
local SurveyResetMarker = SurveyResetMarker


--------------------------------------------------------------------------------
-- Constants
--------------------------------------------------------------------------------

local MARKER_STYLES = {
	arrowGround = { "world-pointer", 300, 0, false },
	resetGround = { "world-rotate", 400, 0, false },
	resetVertical = { "world-teardrop-down", 200, 140, true },
	locationGround = { "world-rotate-chevrons", 500, 0, false },
	locationVertical = { "world-pointer-down", 300, 250, true },
}

local MARKER_TYPES = {
	[1] = { color = "survey", styles = { "resetGround", "resetVertical" } },
	[2] = { color = "survey", styles = { "arrowGround" }, count = true },
	[3] = { color = "treasure", styles = { "resetGround", "resetVertical" } },
	[4] = { color = "treasure", styles = { "arrowGround" }, count = true },
	[5] = { color = "treasure", styles = { "locationGround", "locationVertical" } },
	[6] = { color = "survey", styles = { "locationVertical" } },
}

local MARKER_DATA -- Loaded during EVENT_ADD_ON_LOADED


--------------------------------------------------------------------------------
-- Settings
--------------------------------------------------------------------------------

local SV

function SurveyResetMarker.InitializeSettings( )
	SurveyResetMarker.savedVars = ZO_SavedVars:NewAccountWide("SurveyResetMarkerSavedVars", SurveyResetMarker.varVersion, nil, SurveyResetMarker.defaults, nil, "$InstallationWide")
	SV = SurveyResetMarker.savedVars

	-- Migrate old "toggle" setting
	if (SV.toggle ~= nil) then
		SV.locationVertical = SV.toggle
		SV.toggle = nil
	end

	local LAM = LibAddonMenu2
	if (LAM) then
		local panelId = "SurveyResetMarkerSettings"

		SurveyResetMarker.settingsPanel = LAM:RegisterAddonPanel(panelId, {
			type = "panel",
			name = GetString(SI_SRM_TITLE),
			version = LCA.FormatVersion(LCA.GetAddOnVersion(SurveyResetMarker.name) * 10),
			author = "@tmbrinks",
			registerForRefresh = true,
		})

		local function MakeColorSetting( varName, label )
			return {
				type = "colorpicker",
				name = label,
				getFunc = function() return LCA.UnpackRGBA(SV.colors[varName]) end,
				setFunc = function( ... )
					SV.colors[varName] = LCA.PackRGBA(...)
					SurveyResetMarker.Refresh()
				end,
			}
		end

		local SRMP = SurveyResetMarker.pins

		LAM:RegisterOptionControls(panelId, {
			--------------------------------------------------------------------
			{
				type = "header",
				name = SI_GAMEPLAY_OPTIONS_GENERAL,
			},
			--------------------
			{
				type = "checkbox",
				name = SI_SRM_SETTING_MAPPINS,
				getFunc = SRMP and SRMP.GetEnabled or function() return false end,
				setFunc = SRMP and SRMP.SetEnabled or function() end,
				disabled = function() return not SRMP end,
			},
			--------------------
			{
				type = "checkbox",
				name = SI_SRM_SETTING_VERTICAL,
				getFunc = function() return SV.locationVertical end,
				setFunc = function( enabled )
					SV.locationVertical = enabled
					SurveyResetMarker.RedrawMarkers()
				end,
			},

			--------------------------------------------------------------------
			{
				type = "header",
				name = SI_SRM_SETTING_COLORS_HEADER,
			},
			--------------------
			MakeColorSetting("survey", SI_SRM_SETTING_COLORS_SURVEY),
			MakeColorSetting("treasure", SI_SRM_SETTING_COLORS_TREASURE),
			MakeColorSetting("counter", SI_SRM_SETTING_COLORS_COUNTER),
		})
	end
end


--------------------------------------------------------------------------------
-- Core logic
--------------------------------------------------------------------------------

local Canvas
local function GetCanvas( )
	if (not Canvas) then
		Canvas = LCA.WorldDrawing:New()
	end
	return Canvas
end

local function DecodeMarker( marker )
	local markerType, x, y, z, groundAngle, noCount = zo_strsplit(",", marker)
	return tonumber(markerType), { tonumber(x), tonumber(y), tonumber(z) }, tonumber(groundAngle), noCount == "noCount"
end

local function GetNumberTexture( number )
	return "world-num-" .. (number > 9 and "gt9" or number)
end

local DisplayedItemId = { }
local DisplayedSlot = { }
local NumberedPointers = { }

function SurveyResetMarker.RedrawMarkers( )
	if (Canvas) then -- No point in clearing a canvas if one hasn't been created
		Canvas:Clear()
	end

	DisplayedItemId = { }
	DisplayedSlot = { }
	NumberedPointers = { }

	local zone = MARKER_DATA[LCA.GetZoneId()]
	if (zone) then -- Markers exist for this zone
		local bagCache = SHARED_INVENTORY:GetOrCreateBagCache(BAG_BACKPACK)

		for _, data in pairs(bagCache) do
			local itemId = GetItemId(data.bagId, data.slotIndex)
			local markers = zone[itemId]

			if (markers) then -- Markers exist for this item
				DisplayedSlot[data.slotIndex] = itemId

				if (not DisplayedItemId[itemId]) then -- In case the same survey is split into multiple slots, display only once
					local count = GetItemLinkInventoryCount(GetItemLink(data.bagId, data.slotIndex), INVENTORY_COUNT_BAG_OPTION_BACKPACK)
					DisplayedItemId[itemId] = count

					for _, marker in ipairs(markers) do
						local markerType, pos, groundAngle, noCount = DecodeMarker(marker)
						local markerInfo = MARKER_TYPES[markerType]
						local color = SV.colors[markerInfo.color]

						for _, markerStyleName in ipairs(markerInfo.styles) do
							if (SV.locationVertical or markerStyleName ~= "locationVertical") then
								local texture, size, elevation, playerFacing = unpack(MARKER_STYLES[markerStyleName])

								local elementId = GetCanvas():PlaceTexture({
									texture = texture,
									pos = pos,
									groundAngle = groundAngle,
									color = color,
									size = size,
									elevation = elevation,
									playerFacing = playerFacing,
									disableDepthBuffers = true,
								})

								-- Map counter
								if (markerInfo.count and not noCount and playerFacing == false) then
									-- Store this marker's ID for future updates
									local pointers = NumberedPointers[itemId] or { }
									table.insert(pointers, elementId)
									NumberedPointers[itemId] = pointers

									-- Add count
									GetCanvas():UpdateTexture(elementId, { groundOverlay = {
										texture = GetNumberTexture(count),
										size = 150,
										offsetV = 40,
										color = SV.colors.counter,
									}})
								end
							end
						end
					end
				end
			end
		end
	end
end

LCA.MonitorZoneChanges(SurveyResetMarker.name, function( zoneId )
	EVENT_MANAGER:UnregisterForEvent(SurveyResetMarker.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)

	local zone = MARKER_DATA[zoneId]
	if (zone) then
		EVENT_MANAGER:RegisterForEvent(SurveyResetMarker.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function( _, bagId, slotIndex )
			local itemId = GetItemId(bagId, slotIndex)
			if (zone[itemId] and not DisplayedItemId[itemId]) or -- Undisplayed map entered inventory
			   (DisplayedSlot[slotIndex] and DisplayedSlot[slotIndex] ~= itemId) then -- Displayed map left inventory
				SurveyResetMarker.Refresh()
			elseif (NumberedPointers[itemId]) then -- Numbered pointers exist for this item which has been changed
				local count = GetItemLinkInventoryCount(GetItemLink(bagId, slotIndex), INVENTORY_COUNT_BAG_OPTION_BACKPACK)
				DisplayedItemId[itemId] = count
				for _, elementId in ipairs(NumberedPointers[itemId]) do
					GetCanvas():UpdateTexture(elementId, {
						groundOverlay = { texture = GetNumberTexture(count) },
					})
				end
			end
		end)
		EVENT_MANAGER:AddFilterForEvent(SurveyResetMarker.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_BACKPACK)
	end
end)


--------------------------------------------------------------------------------
-- Utilities
--------------------------------------------------------------------------------

function SurveyResetMarker.Msg( text )
	CHAT_ROUTER:AddSystemMessage(string.format("[%s] %s", GetString(SI_SRM_TITLE), text))
end

function SurveyResetMarker.ToggleTest( )
	if (SV.test) then
		SV.test = false
		SurveyResetMarker.Msg("Test Mode Off")
	else
		SV.test = true
		SurveyResetMarker.Msg("Test Mode On")
	end
end

function SurveyResetMarker.Ping( ) -- For testing resets
	if (SV.test) then
		SurveyResetMarker.Msg("Sub-zone Changed!")
	end
end

function SurveyResetMarker.Diagnostics( )
	local totalUnique = 0
	local totalMaps = 0
	for _, count in pairs(DisplayedItemId) do
		totalUnique = totalUnique + 1
		totalMaps = totalMaps + count
	end
	SurveyResetMarker.Msg(string.format("%s-%06d (LCA-%06d)\nDisplaying markers for %d unique maps (%d total copies)",
		SurveyResetMarker.name,
		LCA.GetAddOnVersion("SurveyResetMarker"),
		LCA.GetAddOnVersion("LibCombatAlerts"),
		totalUnique, totalMaps
	))
end


--------------------------------------------------------------------------------
-- Map and compass pins
--------------------------------------------------------------------------------

function SurveyResetMarker.InitializePins( )
	local SRMP = SurveyResetMarker.pins
	if (SRMP) then
		SRMP.MARKER_TYPES = MARKER_TYPES
		SRMP.MARKER_DATA = MARKER_DATA
		SRMP.SV = SV
		SRMP.DecodeMarker = DecodeMarker
		SRMP.Initialize()
		SurveyResetMarker.Refresh = function( )
			SurveyResetMarker.RedrawMarkers()
			SRMP.Refresh()
		end
	else
		SurveyResetMarker.Refresh = SurveyResetMarker.RedrawMarkers
	end
end


--------------------------------------------------------------------------------
-- Startup
--------------------------------------------------------------------------------

EVENT_MANAGER:RegisterForEvent(SurveyResetMarker.name, EVENT_ADD_ON_LOADED, function( _, addonName )
	if (addonName ~= SurveyResetMarker.name) then return end
	EVENT_MANAGER:UnregisterForEvent(SurveyResetMarker.name, EVENT_ADD_ON_LOADED)

	MARKER_DATA = SurveyResetMarker.MARKER_DATA

	SurveyResetMarker.InitializeSettings()
	SurveyResetMarker.InitializePins()

	EVENT_MANAGER:RegisterForEvent(SurveyResetMarker.name, EVENT_PLAYER_ACTIVATED, SurveyResetMarker.RedrawMarkers)
	EVENT_MANAGER:RegisterForEvent(SurveyResetMarker.name, EVENT_CURRENT_SUBZONE_LIST_CHANGED, SurveyResetMarker.Ping)

	SLASH_COMMANDS["/rmtest"] = SurveyResetMarker.ToggleTest
	SLASH_COMMANDS["/rmdiag"] = SurveyResetMarker.Diagnostics
end)
