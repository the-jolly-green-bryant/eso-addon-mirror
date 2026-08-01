-- =============================================================================
-- Localized Globals
-- =============================================================================
local EVENT_MANAGER = EVENT_MANAGER
local KEYBIND_STRIP = KEYBIND_STRIP
local GetFastTravelNodeInfo = GetFastTravelNodeInfo
local ZO_Dialogs_ShowPlatformDialog = ZO_Dialogs_ShowPlatformDialog
local ZO_PreHookHandler = ZO_PreHookHandler
local ipairs = ipairs

-- =============================================================================
-- Constants
-- =============================================================================
local KEYBIND = "UI_SHORTCUT_QUATERNARY"
local BUTTON_SIZE = 30
local BUTTON_X_OFFSET = 4
local BUTTON_Y_OFFSET = -45
local ICON_Y_OFFSET = -47

local WAYSHRINE_COMPLETE_ICON = "/esoui/art/icons/poi/poi_wayshrine_complete.dds"
local WAYSHRINE_GLOW_ICON = "/esoui/art/icons/poi/poi_wayshrine_glow.dds"
local WAYSHRINE_INCOMPLETE_ICON =
"/esoui/art/icons/poi/poi_wayshrine_incomplete.dds"

local ALLIANCE_CITIES = {
  { nodeIndex = 214, position = 0, texture = "/esoui/art/ava/ava_allianceflag_aldmeri.dds" },
  { nodeIndex = 56,  position = 2, texture = "/esoui/art/ava/ava_allianceflag_daggerfall.dds" },
  { nodeIndex = 28,  position = 4, texture = "/esoui/art/ava/ava_allianceflag_ebonheart.dds" },
}

-- =============================================================================
-- Module Declaration
-- =============================================================================
local GAFE = GroupActivityFinderExtensions
local Map = {}

-- =============================================================================
-- Private State
-- =============================================================================
local isFastTravel = false
local keybindStripGroup

-- =============================================================================
-- Private Functions
-- =============================================================================

--- Event handler for fast travel interaction start.
--- Sets the fast travel flag to true.
local function OnFastTravelStart()
  isFastTravel = true
end

--- Event handler for fast travel interaction end.
--- Sets the fast travel flag to false.
local function OnFastTravelEnd()
  isFastTravel = false
end

--- Displays teleport confirmation dialog for a wayshrine.
--- @param nodeIndex number The wayshrine node index to teleport to
local function TeleportTo(nodeIndex)
  local knownNode, name = GetFastTravelNodeInfo(nodeIndex)

  if knownNode then
    local dialogName = isFastTravel and "FAST_TRAVEL_CONFIRM" or "RECALL_CONFIRM"
    ZO_Dialogs_ShowPlatformDialog(
      dialogName,
      { nodeIndex = nodeIndex },
      { mainTextParams = { name } }
    )
  end
end

--- Creates alliance city fast travel button on the map UI.
--- @param parent any The parent control to attach the button to
--- @param nodeIndex number The wayshrine node index
--- @param position number The horizontal position multiplier
--- @param texture string The alliance flag texture path
local function CreateAllianceCityButton(parent, nodeIndex, position, texture)
  local knownNode, name = GetFastTravelNodeInfo(nodeIndex)
  local parentName = parent:GetName()

  LibPanicida.Controls.Texture(
    parentName .. "GAFE_Label" .. nodeIndex,
    parent,
    { BUTTON_SIZE, BUTTON_SIZE * 2 },
    { TOPLEFT, parent, TOPLEFT, position * BUTTON_SIZE + BUTTON_X_OFFSET,
      BUTTON_Y_OFFSET },
    texture
  )

  local button = LibPanicida.Controls.Button(
    parentName .. "GAFE_Button" .. nodeIndex,
    parent,
    { BUTTON_SIZE * 1.2, BUTTON_SIZE * 1.2 },
    { TOPLEFT, parent, TOPLEFT, position * BUTTON_SIZE + BUTTON_X_OFFSET +
    BUTTON_SIZE - 10, ICON_Y_OFFSET },
    nil,
    function() TeleportTo(nodeIndex) end,
    true,
    { name }
  )

  if knownNode then
    button:SetNormalTexture(WAYSHRINE_COMPLETE_ICON)
    button:SetMouseOverTexture(WAYSHRINE_GLOW_ICON)
  else
    button:SetNormalTexture(WAYSHRINE_INCOMPLETE_ICON)
  end
end

--- Handler for when the world map info panel is shown.
--- Adds keybind for favorite wayshrine and creates alliance city buttons.
local function OnShown()
  local favouriteNode = GAFE.SavedVars.map.favourite
  local _, favouriteNodeName = GetFastTravelNodeInfo(favouriteNode)

  keybindStripGroup = {
    {
      name = favouriteNodeName,
      keybind = KEYBIND,
      callback = function() TeleportTo(favouriteNode) end,
    },
    alignment = KEYBIND_STRIP_ALIGN_CENTER,
  }
  KEYBIND_STRIP:AddKeybindButtonGroup(keybindStripGroup)

  local parent = ZO_WorldMapInfo
  for _, city in ipairs(ALLIANCE_CITIES) do
    CreateAllianceCityButton(parent, city.nodeIndex, city.position, city.texture)
  end
end

--- Handler for when the world map info panel is hidden.
--- Removes the keybind group from the keybind strip.
local function OnHidden()
  KEYBIND_STRIP:RemoveKeybindButtonGroup(keybindStripGroup)
end

-- =============================================================================
-- Public Functions
-- =============================================================================

--- Initializes the Map module.
--- Sets up event handlers and hooks for map fast travel functionality.
function Map.Init()
  ZO_PreHookHandler(ZO_WorldMapInfo, "OnEffectivelyShown", OnShown)
  ZO_PreHookHandler(ZO_WorldMapInfo, "OnEffectivelyHidden", OnHidden)

  EVENT_MANAGER:RegisterForEvent(GAFE.name .. "_Map",
    EVENT_START_FAST_TRAVEL_INTERACTION, OnFastTravelStart)
  EVENT_MANAGER:RegisterForEvent(GAFE.name .. "_Map",
    EVENT_END_FAST_TRAVEL_INTERACTION, OnFastTravelEnd)
end

-- =============================================================================
-- Module Registration
-- =============================================================================
GAFE.Map = Map
