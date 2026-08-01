--library header
LibSkillBlocker = {}
LibSkillBlocker.name = "LibSkillBlocker"
LibSkillBlocker.version = '1.1.0'

--library variables
LibSkillBlocker.hooksRegistered = false
LibSkillBlocker.isAnySkillBlockRegistered = false
LibSkillBlocker.blockedSkills = {}

--local library variables
local actionButtonKeybindStackTracebackPatternForSlotNum = 'keybind = \".*ACTION_BUTTON_(%d)'

--Chat output variables
local libName = LibSkillBlocker.name
local chatPre = "[" .. libName .. "]"


--Local speed up variables
local isAnySkillBlockRegistered = LibSkillBlocker.isAnySkillBlockRegistered
local blockedSkills =             LibSkillBlocker.blockedSkills
local hooksRegistered =           LibSkillBlocker.hooksRegistered

local checkIfHooksAreNeeded

--- local helper functions
local function checkIfIsAnySkillBlockRegistered()
  --Check if any skill is still registered
  if not isAnySkillBlockRegistered then return false end

  --Anything left in the blockedSkills?
  if ZO_IsTableEmpty(blockedSkills) == false then
    for _, abilityBlocks in pairs(blockedSkills) do
      --if NonContiguousCount(abilityBlocks.blocks) > 0 then
      if ZO_IsTableEmpty(abilityBlocks.blocks) == false then
        return true
      end
    end
  end
  return false
end

--- Library API functions
function LibSkillBlocker.GetRegisteredAbilityIds()
  if not isAnySkillBlockRegistered then return nil end
  return blockedSkills
end


function LibSkillBlocker.GetRegisteredAbilityId(abilityId)
  assert(abilityId ~= nil, string.format(chatPre .. " -GetRegisteredAbilityId: abilityId %q is missing!", tostring(abilityId)))
  if not isAnySkillBlockRegistered then return nil end
  return blockedSkills[abilityId]
end


function LibSkillBlocker.GetRegisteredAbilityIdsByAddon(addonName)
  assert(addonName ~= nil and addonName ~= "", string.format(chatPre .. " -GetRegisteredAbilityIdsByAddon: name %q is missing!", tostring(addonName)))
  if not isAnySkillBlockRegistered then return nil end

  local abilityIds
  for abilityId, abilityBlockData in pairs(blockedSkills) do
    local addonBlocks = abilityBlockData.blocks ~= nil and abilityBlockData.blocks[addonName]
    if addonBlocks ~= nil then
      abilityIds = abilityIds or {}
      abilityIds[abilityId] = addonBlocks
    end
  end
  return abilityIds
end

--Support for scribed skills
local function GetSlotBoundAbilityId(slotNum) -- NEW v1.09 by Notnear
    local slottedId = GetSlotBoundId(slotNum)

    local actionType = GetSlotType(slotNum)
    if actionType == ACTION_TYPE_CRAFTED_ABILITY then
        slottedId = GetAbilityIdForCraftedAbilityId(slottedId)
    end

    return slottedId
end

function LibSkillBlocker.IsSlotBlocked(slotNum)
  if not isAnySkillBlockRegistered or slotNum == nil then return false, nil end

  --if IsInGamepadPreferredMode() then return false end --Enable gamepad support
  local abilityId = GetSlotBoundAbilityId(slotNum) -- CHANGED v1.09 by Notnear
  if abilityId == nil then return false end

  local blockedSkillData = blockedSkills[abilityId]
  if blockedSkillData == nil then return false, nil end
  for _, blockData in pairs(blockedSkillData.blocks) do
    if blockData.func ~= nil and blockData.func(slotNum, abilityId, blockedSkillData.lastTrigger) == true then
      return true, blockData.showError
    end
  end
  return false, nil
end

--[[ Original v1.08
function LibSkillBlocker.IsSlotBlocked(slotNum)
  if not isAnySkillBlockRegistered or slotNum == nil then return false, nil end

  --if IsInGamepadPreferredMode() then return false end --Enable gamepad support
  local abilityId = GetSlotBoundId(slotNum)
  if abilityId == nil then return false end
  local blockedSkillData = blockedSkills[abilityId]
  if blockedSkillData == nil then return false, nil end
  for _, blockData in pairs(blockedSkillData.blocks) do
    if blockData.func ~= nil and blockData.func(slotNum, abilityId, blockedSkillData.lastTrigger) == true then
      return true, blockData.showError
    end
  end
  return false, nil
end
]]
local isSlotBlocked = LibSkillBlocker.IsSlotBlocked


--Library Register/Unregister skill block - API functions
function LibSkillBlocker.RegisterSkillBlock(blockName, abilityId, customBlockHandler, showError)
  assert(blockName ~= nil and blockName ~= "" and abilityId ~= nil, string.format(chatPre .. " -RegisterSkillBlock: name %q or abilityId %q are missing!", tostring(blockName), tostring(abilityId)))
  if showError == nil then showError = true end

  blockedSkills[abilityId] = blockedSkills[abilityId] or { blocks = {} }
  customBlockHandler = customBlockHandler or function() return true end
  blockedSkills[abilityId].blocks[blockName] = { func = customBlockHandler, showError = showError }
  isAnySkillBlockRegistered = true

  checkIfHooksAreNeeded()
  return true
end

function LibSkillBlocker.UnregisterSkillBlock(blockName, abilityId)
  assert(blockName ~= nil and blockName ~= "" and abilityId ~= nil, string.format(chatPre .. " -UnregisterSkillBlock: name %q or abilityId %q are missing!", tostring(blockName), tostring(abilityId)))
  --Nothing registered yet? Nothing to do here
  if not isAnySkillBlockRegistered then return end

  if blockedSkills[abilityId] ~= nil and blockedSkills[abilityId].blocks ~= nil then
    blockedSkills[abilityId].blocks[blockName] = nil

    --Is still anything registered now?
    isAnySkillBlockRegistered = checkIfIsAnySkillBlockRegistered()
    return true
  end
  return false
end


--- Action button HOOKed functions
function LibSkillBlocker.CanUseActionSlots()
  if not isAnySkillBlockRegistered then return false end --Skipp PreHook if no skill block is registered, to prevent performance loss due to debug.traceback() calls of each slot usage!

  --Use debug.traceback() to find the slotNum of the pressed actionButton! -> This is quite performance heavy and should only be used if anything is really blocked!
  local slotNum = tonumber(debug.traceback():match(actionButtonKeybindStackTracebackPatternForSlotNum))

  if slotNum ~= nil then
    local isBlocked, showError = isSlotBlocked(slotNum)
    if not isBlocked then return false end
    if showError == true then
      ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, SI_RESPECRESULT6) --"Invalid ability". SI_RESPECRESULT10 = You do not meet the requirement for that ability
    end
    ZO_ActionBar_OnActionButtonUp(slotNum)
    return true
  end
  return false
end
local canUseActionSlots = LibSkillBlocker.CanUseActionSlots

--[[
function LibSkillBlocker.RecordButtonDown(slotNum)
  if not isAnySkillBlockRegistered then return false end -- Skip PreHook as not needed

  local abilityId = GetSlotBoundId(slotNum)
  if not blockedSkills[abilityId] then return end
  blockedSkills[abilityId].lastTrigger = GetGameTimeMilliseconds()
end
local recordButtonDown = LibSkillBlocker.RecordButtonDown
]]
function LibSkillBlocker.RecordButtonDown(slotNum)
  if not isAnySkillBlockRegistered then return false end -- Skip PreHook as not needed

  local abilityId = GetSlotBoundAbilityId(slotNum) --fix provided by PhnxZ, 2026-01-02 on esoui.com
  if not blockedSkills[abilityId] then return end
  blockedSkills[abilityId].lastTrigger = GetGameTimeMilliseconds()
end
local recordButtonDown = LibSkillBlocker.RecordButtonDown


function LibSkillBlocker.RecordButtonUp(slotNum)
  if not isAnySkillBlockRegistered then return false end -- Skip PreHook as not needed

  local abilityId = GetSlotBoundAbilityId(slotNum)
  if not blockedSkills[abilityId] then return end
  blockedSkills[abilityId].lastTrigger = nil
end
local recordButtonUp = LibSkillBlocker.RecordButtonUp

checkIfHooksAreNeeded = function()
  if isAnySkillBlockRegistered and not hooksRegistered then
    ZO_PreHook("ZO_ActionBar_CanUseActionSlots",      canUseActionSlots)
    ZO_PreHook("ZO_ActionBar_OnActionButtonDown",     recordButtonDown)
    ZO_PreHook("ZO_ActionBar_OnActionButtonUp",       recordButtonUp)
    hooksRegistered = true
  end
end

--AddOn loading
function LibSkillBlocker.OnAddonLoaded(_, addonName)
  if addonName ~= libName then return end
  EVENT_MANAGER:UnregisterForEvent(libName .. "_EVENT_ADD_ON_LOADED", EVENT_ADD_ON_LOADED)
  checkIfHooksAreNeeded()
end

EVENT_MANAGER:RegisterForEvent(libName, EVENT_ADD_ON_LOADED, LibSkillBlocker.OnAddonLoaded)
