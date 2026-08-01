EyeSafetyLockpicking = {}

local this = EyeSafetyLockpicking
this.name = "EyeSafetyLockpicking"
this.version = "1.2.1"
this.author = "grin3671"

-- Stored names of "Chest" and related actions for different languages
-- // TODO: Confirm work on Japanese translation
-- // TODO: add unofficial/other translations?
local chestInteractions = {
  ["de"] = {
    ["name"] = "Truhe",
    ["action"] = "Aufschließen"
  },
  ["en"] = {
    ["name"] = "Chest",
    ["action"] = "Unlock"
  },
  ["es"] = {
    ["name"] = "Cofre",
    ["action"] = "Abrir"
  },
  ["fr"] = {
    ["name"] = "Coffre",
    ["action"] = "Déverrouiller"
  },
  ["jp"] = {
    ["name"] = "宝箱", -- unconfirmed
    ["action"] = "解除する" -- unconfirmed
  },
  ["ru"] = {
    ["name"] = "Сундук",
    ["action"] = "Открыть замок"
  },
  ["zh"] = {
    ["name"] = "箱子",
    ["action"] = "解锁"
  }
}

-- Prepare Local Variables
local isChestVisionPurchased = false
local isChestLastInteraction = false
local isAlreadyInitialized = false
local GameCameraOverlayBackdrop = nil -- texture created via CreateBackdrop()
local lang = GetCVar("language.2") -- game client language
local DEFAULT_SETTINGS = {
  ["BackdropTransparency"] = 20
}

-- ### Part 1. Initialization
-- - The AddonLoadedEvent fires `Initialize()`
-- - `Initialize()` checks skill knowledge via `CheckSkillKnowledge()` and starts the skill changes listener.
-- - `CheckSkillKnowledge()` starts main functions via `ActivateEyeProtection()` or closes all possible changes.
-- ### Part 2. Main Functions
-- - `ActivateEyeProtection()` creates the Backdrop via `CreateBackdrop()` and starts the Interaction and LockpickBegin listeners.
-- - The Interaction listener changes the variable `isChestLastInteraction` if player interacts with locked chest.
-- - `OnLockpickBegin()`, fired via LockpickBegin listener, changes visibility of the Backdrop and starts listening for closing events.
-- - `OnLockpickEnd()` hides the Backdrop and stops listeners of lockpicking closing events.
-- ### Part 3. Support Functions
-- - `RegisterChatCommand()` helps add a command via `LibSlashCommander` or, as a fallback, `SLASH_COMMANDS`.
-- - `SetBackdropTransparency(i)` changes the transparency of the Backdrop according to player input or SavedVariables.


local function SetBackdropTransparency(i)
  local i = tonumber(i)
  if not i then
    d("Please insert number after command name! Ex. /esl 20")
    return
  end
  -- i should be from 0 to 100
  i = i > 100 and 100 or i
  i = i < 0 and 0 or i
  GameCameraOverlayBackdrop:SetAlpha((100 - i) / 100)
  this.settings["BackdropTransparency"] = i
end

local function CreateBackdrop()
  -- Create new TopLevelControl in GuiRoot. It's local because it will not be used later.
  local GameCameraOverlay = WINDOW_MANAGER:CreateControl("ESL_GameCameraOverlay", GuiRoot, CT_TOPLEVELCONTROL)
  GameCameraOverlay:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT)
  GameCameraOverlay:SetAnchor(BOTTOMRIGHT, GuiRoot, BOTTOMRIGHT)
  -- Create Backdrop. It's global because it will be changed a lot later.
  GameCameraOverlayBackdrop = WINDOW_MANAGER:CreateControlFromVirtual("ESL_GameCameraOverlayBackdrop", GameCameraOverlay, "ZO_TintableBackground")
  GameCameraOverlayBackdrop:SetHidden(true)
  SetBackdropTransparency(this.settings["BackdropTransparency"])
end

local function OnLockpickEnd()
  GameCameraOverlayBackdrop:SetHidden(true)
  EVENT_MANAGER:UnregisterForEvent(this.name, EVENT_LOCKPICK_SUCCESS)
  EVENT_MANAGER:UnregisterForEvent(this.name, EVENT_LOCKPICK_FAILED)
end

local function OnLockpickBegin()
  -- Backdrop should be visible only when interacting with chests (not doors or safeboxes)
  if isChestLastInteraction then
    -- isChestLastInteraction = false
    GameCameraOverlayBackdrop:SetHidden(false)
    EVENT_MANAGER:RegisterForEvent(this.name, EVENT_LOCKPICK_SUCCESS, OnLockpickEnd)
    EVENT_MANAGER:RegisterForEvent(this.name, EVENT_LOCKPICK_FAILED, OnLockpickEnd)
  end
end

local function ActivateEyeProtection()
  -- Prevent repeated runs
  isAlreadyInitialized = true

  -- Create Backdrop in Lockpick Scene
  CreateBackdrop()

  -- Get Name of Last Interaction (Fires when "E" or "Tab" pressed or corresponding buttons on gamepad and may be "nil")
  -- This PreHook was taken from Jack of all Trades addon
  -- // TODO: Check if it fires multiple times when skills is reset and "keen eye" learned again
  ZO_PreHook(INTERACTIVE_WHEEL_MANAGER, "StartInteraction", function()
    local action, interactableName = GetGameCameraInteractableActionInfo()
    -- d(zo_strformat("<<1>>: <<2>> -- <<3>>", "[TEST] StartInteraction", tostring(interactableName), tostring(action)))
    isChestLastInteraction = interactableName == chestInteractions[lang]["name"] and action == chestInteractions[lang]["action"]
  end)

  -- Watch Lockpick Begining to change Backdrop Visibility
  EVENT_MANAGER:RegisterForEvent(this.name, EVENT_BEGIN_LOCKPICK, OnLockpickBegin)
end

local function CheckSkillKnowledge()
  local skillGroup, skillLine, skillIndex = GetSpecificSkillAbilityKeysByAbilityId(139771)
  local _, _, _, _, _, purchased = GetSkillAbilityInfo(skillGroup, skillLine, skillIndex) -- Chest Highlighting
  isChestVisionPurchased = purchased

  -- Run Main Function if all stars aligns
  if isChestVisionPurchased and not isAlreadyInitialized then
    ActivateEyeProtection()
  end

  -- Handle possible skill reset to revert changes
  if not isChestVisionPurchased and isAlreadyInitialized then
    -- Hooks can't be stopped and Controls can't be removed.
    GameCameraOverlayBackdrop:SetHidden(true)
    EVENT_MANAGER:UnregisterForEvent(this.name, EVENT_BEGIN_LOCKPICK)
  end
end

local function RegisterChatCommand(command, callback, description)
  local LSC = LibSlashCommander
  if not LSC then
    SLASH_COMMANDS[command] = function(input) callback(input) end
  else
    LSC:Register(command, function(input) callback(input) end, description)
  end
end

local function Initialize()
  -- Load SV from file or DEFAULT_SETTINGS
  this.settings = ZO_SavedVars:NewAccountWide(this.name .. "SavedVariables", 1, nil, DEFAULT_SETTINGS)

  -- Do not prolong loading time, just wait for character
  EVENT_MANAGER:RegisterForEvent(this.name, EVENT_PLAYER_ACTIVATED, function()
    EVENT_MANAGER:UnregisterForEvent(this.name, EVENT_PLAYER_ACTIVATED)

    -- Get Current State of Skill and Watch any Changes
    CheckSkillKnowledge()
    EVENT_MANAGER:RegisterForEvent(this.name, EVENT_ABILITY_LIST_CHANGED, CheckSkillKnowledge)

    RegisterChatCommand("/esl", SetBackdropTransparency, "Set background transparency (0-100)")
  end)
end

EVENT_MANAGER:RegisterForEvent(this.name, EVENT_ADD_ON_LOADED, function(event, addonName)
  if addonName ~= this.name then return end
  EVENT_MANAGER:UnregisterForEvent(this.name, EVENT_ADD_ON_LOADED)
  Initialize()
end)
