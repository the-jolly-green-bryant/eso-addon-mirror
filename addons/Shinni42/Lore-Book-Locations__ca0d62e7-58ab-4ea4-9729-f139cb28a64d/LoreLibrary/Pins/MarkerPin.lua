
local MarkerPin = {}
zo_mixin(MarkerPin, ZO_CallbackObject)
LoreLibrary:RegisterModule("markerPin", MarkerPin)

--[[
Tracks a single "tracked book" (picked via the Lore Library's "Show On Map"
context menu/keybind - see UI/LoreLibraryMenu.lua and
UI/LoreLibraryGamepadMenu.lua) and draws it on the 2D world map using the
game's own custom map pin API (ZO_WorldMapPins_Manager:AddCustomPin) instead
of our own composite-based PinController. That gets the tracked-book pin
native mouse and gamepad tooltips (the book's title) and native gamepad
reticle magnetism/interact-keybind for free, at the cost of not showing on
third-party minimaps the way LOREBOOK/EIDETICBOOK pins do (those stay on the
old system - see MapPins.lua/MapPinController.lua).

Left-clicking (mouse) or interacting with (gamepad) a tracked-book pin
untracks it; so does discovering the book (see the "BookRemoved" listener
below).

Fires "LocationsChanged" (locations, bookId) whenever the tracked book
changes - CompassPins.lua and WorldPins.lua listen for that to show their own
tracked-book pins near the player, since compass/3D pins aren't part of the
world map's pin system and still need their own rendering.
]]--

local PIN_TYPE_STRING = "LORELIBRARY_TRACKED_BOOK_PIN"

-- reuses the Zone Story system's existing localized "Stop Tracking" string
-- rather than inventing our own, since the action is the same idea (drop an
-- explicitly-tracked thing) even though the tracked thing differs
local STOP_TRACKING_TEXT = GetString(SI_ZONE_STORY_STOP_TRACKING_ZONE_STORY_ACTION)

function MarkerPin:Initialize()
	self.locations = {}

	local pinManager = ZO_WorldMap_GetPinManager()
	pinManager:AddCustomPin(PIN_TYPE_STRING,
		function(mgr) self:AddPins(mgr) end,
		nil,
		LoreLibrary.mapPinLayout[LoreLibrary.MARKER],
		{
			-- the gamepad and keyboard tooltip objects ZO_WorldMap_GetTooltipForMode
			-- returns are different types (ZO_MapLocationTooltip_Gamepad vs
			-- InformationTooltip) with unrelated APIs: the keyboard one takes
			-- plain :AddLine calls, while the gamepad one has no :AddLine at
			-- all and instead needs content laid out into its .tooltip
			-- sub-object via ZO_MapInformationTooltip_Gamepad_Mixin's section
			-- helpers (see maptooltips.lua). Reuses the same styles and
			-- "Press <<1>> to ..." keybind-line format the base game's own
			-- delve/wayshrine pin tooltips use (AppendDelveInfo,
			-- AppendWayshrineTooltip) instead of the small generic content
			-- label style, so the title/hint read at the same size as any
			-- other pin's gamepad tooltip.
			creator = function(pin)
				local tooltip = ZO_WorldMap_GetTooltipForMode(ZO_MAP_TOOLTIP_MODE.INFORMATION)
				local title = LoreLibrary.GetBookTitle(self.bookId)

				if IsInGamepadPreferredMode() then
					local section = tooltip.tooltip:AcquireSection(tooltip.tooltip:GetStyle("delveMainSection"))
					if title then
						tooltip:LayoutStringLine(section, title, tooltip.tooltip:GetStyle("delveTooltipName"))
					end
					tooltip:LayoutKeybindStringLine(section, "UI_SHORTCUT_PRIMARY", "Press <<1>> to " .. STOP_TRACKING_TEXT, tooltip.tooltip:GetStyle("delveSkyshardHint"))
					tooltip.tooltip:AddSection(section)
				else
					if title then
						tooltip:AddLine(title, "", ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB())
					end
					tooltip:AddLine("Left-click to " .. STOP_TRACKING_TEXT, "", ZO_HIGHLIGHT_TEXT:UnpackRGB())
				end
			end,
			tooltip = ZO_MAP_TOOLTIP_MODE.INFORMATION,
		}
	)
	self.pinType = _G[PIN_TYPE_STRING]
	pinManager:SetCustomPinEnabled(self.pinType, true)

	ZO_MapPin.PIN_CLICK_HANDLERS[MOUSE_BUTTON_INDEX_LEFT][self.pinType] = {
		{
			name = STOP_TRACKING_TEXT,
			callback = function(pin) self:Untrack() end,
		},
	}

	LoreLibrary.settings:RegisterCallback("FilterChanged", function(pinTypeId)
		if pinTypeId == LoreLibrary.MARKER then
			pinManager:RefreshCustomPins(self.pinType)
		end
	end)

	-- discovering a tracked book removes its regular pin too, so it no
	-- longer makes sense to keep tracking it
	LoreLibrary.data:RegisterCallback("BookRemoved", function(zoneId, nodeId, pinTypeId, bookId)
		if bookId == self.bookId then
			self:Untrack()
		end
	end)
end

-- pinTypeAddCallback: called by the game's own pin manager on every map
-- redraw (ZO_WorldMap_UpdateMap already calls RefreshCustomPins for every
-- registered custom pin type) - draws one pin per tracked location.
-- GetNormalizedWorldPosition(location.zoneId, ...) resolves each location
-- correctly for whichever map is actually open (that's the same call
-- Main/Utils.lua's ShowLocationOnMap makes to pan to a single location,
-- sub-zone/delve locations included), and the pin itself is automatically
-- hidden by the game if the resulting position isn't on the current map, so
-- there's nothing left for this module to filter by zone/map.
--
-- Each pin's tag is the location table itself, not self.bookId: the game's
-- pin manager indexes custom pins by (pinType, pinTag) to know what to
-- release later (see RemovePins), so reusing the same tag (bookId) for every
-- location here would make every new pin overwrite the previous one's index
-- entry - RefreshCustomPins/RemovePins would then only ever find and release
-- the last pin created, leaking all the earlier ones as frozen, undeletable
-- pins. Locations are unique table references (fresh from
-- Data:GetBookLocations), so using them as the tag guarantees a distinct key
-- per pin.
function MarkerPin:AddPins(pinManager)
	if not LoreLibrary.settings:IsPinTypeEnabled(LoreLibrary.MARKER) then return end

	for _, location in ipairs(self.locations) do
		local normalizedX, normalizedY = GetNormalizedWorldPosition(location.zoneId, location.worldX * 100, location.worldZ * 100, location.worldY * 100)
		if normalizedX and normalizedY then
			pinManager:CreatePin(self.pinType, location, normalizedX, normalizedY)
		end
	end
end

-- bookId: id of the tracked book (used to resolve its title for the pin's
-- tooltip); locations: the full array as returned by
-- Data:GetBookLocations(bookId) - every zone the book can be found in, not
-- just the one the player picked from the menu
function MarkerPin:Track(bookId, locations)
	self.bookId = bookId
	self.locations = locations
	ZO_WorldMap_GetPinManager():RefreshCustomPins(self.pinType)
	self:FireCallbacks("LocationsChanged", locations, bookId)
end

function MarkerPin:Untrack()
	self.bookId = nil
	self.locations = {}
	ZO_WorldMap_GetPinManager():RefreshCustomPins(self.pinType)
	self:FireCallbacks("LocationsChanged", self.locations, self.bookId)
end
