--[[
  This file is part of Aenathel's Lazy Chat Linker, licensed under The MIT
  License. See the LICENSE file of this project for more information.
--]]

AenathelsLazyChatLinker = {}

-- AenathelsLazyChatLinker is a bit of a mouthful, so shorten it
local AELCL = AenathelsLazyChatLinker

AELCL.id = "AELCL"
AELCL.name = "AenathelsLazyChatLinker"
AELCL.author = "Aenathel (PC-EU)"
AELCL.title = "Aenathel's Lazy Chat Linker"

-- ESO UI API constants
local CHAT_SYSTEM = CHAT_SYSTEM
local LINK_STYLE_BRACKETS = LINK_STYLE_BRACKETS
local MOUSE_BUTTON_INDEX_LEFT = MOUSE_BUTTON_INDEX_LEFT

-- ESO UI API functions
local GetItemLink = GetItemLink
local GetString = GetString
local IsShiftKeyDown = IsShiftKeyDown
local ZO_InventorySlot_GetInventorySlotComponents = ZO_InventorySlot_GetInventorySlotComponents
local ZO_LinkHandler_InsertLink = ZO_LinkHandler_InsertLink

-- Lua API
local string = string

-- Saved variables
local savedVars = {}

AELCL.defaults = {
  addSpace = true,
}

-- Register add-on menu
local function RegisterAddonMenu()
  local panelName = string.format("%sSettingsPanel", AELCL.name)

  local LAM = LibAddonMenu2

  LAM:RegisterAddonPanel(panelName, {
    type = "panel",
    name = AELCL.title,
    author = AELCL.author,
    version = GetString(AELCL_ADDON_VERSION),
    website = GetString(AELCL_ADDON_WEBSITE),
    slashCommand = "/lcl",
  })

  LAM:RegisterOptionControls(panelName, {
    {
      type = "description",
      text = GetString(AELCL_SETTINGS_DESCRIPTION),
    },
    {
      type = "checkbox",
      name = GetString(AELCL_SETTINGS_ADD_SPACE),
      getFunc = function() return savedVars.addSpace end,
      setFunc = function(value) savedVars.addSpace = value end,
    }
  })
end

local function InsertItemLink(inventorySlot)
  inventorySlot = ZO_InventorySlot_GetInventorySlotComponents(inventorySlot)
  if inventorySlot then
    local itemLink = GetItemLink(inventorySlot.bagId, inventorySlot.slotIndex, LINK_STYLE_BRACKETS)
    if itemLink then
      if savedVars.addSpace then
        local text = CHAT_SYSTEM.textEntry:GetText()
        if text ~= "" then
          CHAT_SYSTEM.textEntry:SetText(text.." ")
        end
      end

      ZO_LinkHandler_InsertLink(itemLink)
    end
  end
end

local function InstallHook()
  SecurePostHook("ZO_InventorySlot_OnSlotClicked", function(inventorySlot, button)
    if button == MOUSE_BUTTON_INDEX_LEFT and IsShiftKeyDown() then
      InsertItemLink(inventorySlot)
    end
  end)
end

-- Called when the add-on is being loaded
function AELCL.Initialize()
  -- Create character-specific saved variables
  savedVars = ZO_SavedVars:New("AenathelsLazyChatLinker_SavedVariables", 1, nil, AELCL.defaults)

  RegisterAddonMenu()

  InstallHook()
end

-- Called when the add-on is loaded so we can initialize
function AELCL.OnAddOnLoaded(_, addonName)
  if addonName == AELCL.name then
    EVENT_MANAGER:UnregisterForEvent(AELCL.name, EVENT_ADD_ON_LOADED)

    AELCL.Initialize()
  end
end

-- Register event handlers
EVENT_MANAGER:RegisterForEvent(AELCL.name, EVENT_ADD_ON_LOADED, AELCL.OnAddOnLoaded)
