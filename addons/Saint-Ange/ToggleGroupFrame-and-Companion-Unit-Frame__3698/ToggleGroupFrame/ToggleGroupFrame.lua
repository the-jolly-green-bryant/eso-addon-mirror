ToggleGroupFrame = {}
local addon = { name = "ToggleGroupFrame", author = "Saint-Ange", version = "1.5.1" }

--------------------------------------------------------------------------------

local default = { state = 1, displayMethod = "Screen" }

--------------------------------------------------------------------------------

local function OnCombatStateChanged()
   local state = addon.sv.state

   if state == 1 then
      -- always show
      ZO_UnitFramesGroups:SetHidden(false)
   elseif state == 2 then
      -- always hide
      ZO_UnitFramesGroups:SetHidden(true)
   elseif state == 3 then
      -- hide in combat
      ZO_UnitFramesGroups:SetHidden(IsUnitInCombat("player"))
   elseif state == 4 then
      -- show in combat
      ZO_UnitFramesGroups:SetHidden(not IsUnitInCombat("player"))
   end
end

local function StateChangeMessage(message)
   local displayMethod = addon.sv.displayMethod

   if displayMethod == "Chat" then
      d(message)
   elseif displayMethod == "Screen" then
      CENTER_SCREEN_ANNOUNCE:AddMessage(1, CSA_CATEGORY_SMALL_TEXT, SOUNDS.GAMEPAD_MENU_FORWARD, message)
   elseif displayMethod == "None" then
      -- do nothing
   end
end

--------------------------------------------------------------------------------

ZO_CreateStringId("SI_BINDING_NAME_TOGGLE_GROUP_FRAME", "Cycle Group Frame Visibility")

SLASH_COMMANDS['/togglegroupframe'] = function()
   local state = addon.sv.state

   if state == 1 then
      addon.sv.state = 2
      StateChangeMessage("Always hidden")
   elseif state == 2 then
      addon.sv.state = 3
      StateChangeMessage("Hidden in combat")
   elseif state == 3 then
      addon.sv.state = 4
      StateChangeMessage("Shown in combat")
   elseif state == 4 then
      addon.sv.state = 1
      StateChangeMessage("Always shown")
   end

   OnCombatStateChanged()
end

SLASH_COMMANDS['/tgf'] = SLASH_COMMANDS['/togglegroupframe']

--------------------------------------------------------------------------------    settings menu

local LAM = LibAddonMenu2

local function OptionsMenu()
   local panelData = {
      type = "panel",
      name = addon.name,
      displayName = addon.name,
      author = addon.author,
      version = addon.version,
      registerForRefresh = true,
      registerForDefaults = true,
   }

   local optionsTable = {
      { type = "description", text = "" },
      {
         type = "dropdown",
         name = "Display State Change",
         choices = { "Chat", "Screen", "None" },
         getFunc = function() return addon.sv.displayMethod end,
         setFunc = function(value) addon.sv.displayMethod = value end,
         default = default.displayMethod,
      }
   }

   LAM:RegisterAddonPanel("ToggleGroupFrame_Settings", panelData)
   LAM:RegisterOptionControls("ToggleGroupFrame_Settings", optionsTable)
end

--------------------------------------------------------------------------------

local function Initialize()
   addon.sv = ZO_SavedVars:NewCharacterIdSettings("ToggleGroupFrame_SavedVars", 1, nil, default, GetWorldName())
   OnCombatStateChanged()
   OptionsMenu()
   EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_PLAYER_COMBAT_STATE, OnCombatStateChanged)
end

local function OnAddonLoaded(event, addon_name)
   if addon_name ~= addon.name then return end
   Initialize()
   EVENT_MANAGER:UnregisterForEvent(addon.name, EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)