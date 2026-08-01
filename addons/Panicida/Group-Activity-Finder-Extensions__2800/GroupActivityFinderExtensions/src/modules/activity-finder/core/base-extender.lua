-- ============================================================================
-- Localized Globals
-- ============================================================================
local GAFE = GroupActivityFinderExtensions

local ACHIEVEMENTS = ACHIEVEMENTS
local CanExitInstanceImmediately = CanExitInstanceImmediately
local EVENT_MANAGER = EVENT_MANAGER
local GetAchievementInfo = GetAchievementInfo
local GetCategoryInfoFromAchievementId = GetCategoryInfoFromAchievementId
local GetCompletedQuestInfo = GetCompletedQuestInfo
local GetCurrentCharacterId = GetCurrentCharacterId
local GetFastTravelNodeInfo = GetFastTravelNodeInfo
local GetString = GetString
local GROUP_LIST = GROUP_LIST
local ITEM_SET_COLLECTIONS_DATA_MANAGER = ITEM_SET_COLLECTIONS_DATA_MANAGER
local KEYBIND_STRIP = KEYBIND_STRIP
local SCENE_MANAGER = SCENE_MANAGER
local ZO_ACTIVITY_FINDER_ROOT_MANAGER = ZO_ACTIVITY_FINDER_ROOT_MANAGER
local ZO_CheckButton_OnClicked = ZO_CheckButton_OnClicked
local ZO_Dialogs_ShowDialog = ZO_Dialogs_ShowDialog
local ZO_Dialogs_ShowPlatformDialog = ZO_Dialogs_ShowPlatformDialog
local ZO_FormatTime = ZO_FormatTime
local ZO_Object = ZO_Object
local ZO_PreHookHandler = ZO_PreHookHandler
local pairs = pairs
local table_insert = table.insert
local zo_strformat = zo_strformat

-- ============================================================================
-- Module Declaration
-- ============================================================================
local ActivityFinderExtender = ZO_Object:Subclass()

-- ============================================================================
-- Private Functions
-- ============================================================================

-- ============================================================================
-- Public Functions
-- ============================================================================

--- Creates a new ActivityFinderExtender instance.
--- @return table The new ActivityFinderExtender instance
function ActivityFinderExtender:New()
  local activityFinderExtender = ZO_Object.New(self)
  return activityFinderExtender
end

---@class initialize_params
---@field customExtensions any
---@field data any
---@field keybindStripGroup table
---@field onShown any
---@field rewardsVars any
---@field root string
---@field treeEntry any

--- Initializes the ActivityFinderExtender with the provided parameters.
--- @param params initialize_params Configuration parameters for initialization
function ActivityFinderExtender:Initialize(params)
  self.characterId = GetCurrentCharacterId()
  self.customExtensions = params.customExtensions
  self.data = params.data
  self.keybindStripGroup = params.keybindStripGroup or {}
  self.onShown = params.onShown
  self.rewardsVars = params.rewardsVars
  self.root = params.root
  self.textureSize = GAFE.SavedVars.textureSize

  -- Leave Group
  table_insert(self.keybindStripGroup, {
    alignment = KEYBIND_STRIP_ALIGN_CENTER,
    name = GetString(SI_GROUP_LEAVE),
    keybind = "UI_SHORTCUT_NEGATIVE",
    callback = function()
      ZO_Dialogs_ShowDialog("GROUP_LEAVE_DIALOG")
    end,
    visible = function()
      return GROUP_LIST.groupSize and GROUP_LIST.groupSize > 0
    end
  })

  -- Leave Instance
  table_insert(self.keybindStripGroup, {
    alignment = KEYBIND_STRIP_ALIGN_CENTER,
    name = GetString(SI_GROUP_MENU_LEAVE_INSTANCE_KEYBIND),
    keybind = "UI_SHORTCUT_QUATERNARY",
    callback = function()
      ZO_Dialogs_ShowDialog("INSTANCE_LEAVE_DIALOG")
    end,
    visible = CanExitInstanceImmediately
  })

  if params.treeEntry then self:InitializeSetupFunction(params.treeEntry) end
  self:InitializeRandomReward()
  self:InitializeEvents()
end

--- Initializes the setup function for tree entries to add custom icons and data.
--- @param treeEntry table The tree entry to extend with custom setup logic
function ActivityFinderExtender:InitializeSetupFunction(treeEntry)
  local baseSetupFunction = treeEntry.setupFunction
  self.pool = treeEntry.objectPool

  local function setupFunction(node, control, data, open)
    baseSetupFunction(node, control, data, open)

    local activityId = data.id
    local activityData = self.data[activityId]
    if activityData then
      self.position = 530

      -- Sets
      self:AddSets(activityData.sets, control)

      -- Survivor challenge (no death)
      self:AddAchievement(
        activityData.nd,
        control:GetName() .. "nd",
        control,
        "/esoui/art/treeicons/gamepad/gp_tutorial_idexicon_death.dds"
      )
      -- Speed challenge
      self:AddAchievement(
        activityData.tt,
        control:GetName() .. "tt",
        control,
        "/esoui/art/ava/overview_icon_underdog_score.dds"
      )
      -- Death challenge (hard mode)
      self:AddAchievement(
        activityData.hm,
        control:GetName() .. "hm",
        control,
        "/esoui/art/unitframes/target_veteranrank_icon.dds"
      )
      -- General Vanquisher (normal) / Conqueror (veteran)
      self:AddAchievement(
        activityData.id,
        control:GetName() .. "id",
        control,
        "/esoui/art/announcewindow/announcement_icon_up.dds"
      )

      -- Quest (skill point)
      self:AddQuest(
        activityData.q,
        control:GetName() .. "q",
        control,
        "/esoui/art/icons/achievements_indexicon_quests_up.dds"
      )

      -- Wayshrine
      self:AddWayshrine(activityData.node, control)
    elseif GAFE.SavedVars.developerMode then
      LibPanicida.Controls.Label(control:GetName() .. "TODO", control,
        { 125, 20 }, { LEFT, control, LEFT, 420, 0 },
        "ZoFontGameLarge", nil, { 0, 1 }, "ACTIVITY_ID " .. activityId)
    end

    if self.customExtensions then
      self.customExtensions(node, control, data, open)
    end
  end

  treeEntry.setupFunction = setupFunction
end

--- Initializes the random reward timer control.
function ActivityFinderExtender:InitializeRandomReward()
  self.singularSectionRewards = _G
      [self.root .. "Finder_Keyboard" .. "SingularSectionRewardsSectionHeader"]
  if self.singularSectionRewards then
    self.premiumRewardTimerControl = LibPanicida.Controls.Label(
      self.root .. "_RandomReward",
      self.singularSectionRewards,
      { 125, 20 }, { TOPLEFT, self.parent, TOPRIGHT, 10, 2 }, "ZoFontGameShadow",
      nil, { 0, 1 })
  end
end

--- Initializes event handlers for section visibility and keybind management.
function ActivityFinderExtender:InitializeEvents()
  self.isKeyboardListSectionVisible = false
  self.isSingularSectionVisible = false

  local function OnKeyboardListSectionShown()
    self.isKeyboardListSectionVisible = true
    KEYBIND_STRIP:AddKeybindButtonGroup(self.keybindStripGroup)

    if self.onCollapse then self:onCollapse() end
    if self.onShown then self.onShown() end
  end

  local function OnKeyboardListSectionHidden()
    self.isKeyboardListSectionVisible = false

    if not self.isSingularSectionVisible then
      KEYBIND_STRIP:RemoveKeybindButtonGroup(self.keybindStripGroup)
    end
  end

  local function OnSingularSectionShown()
    self.isSingularSectionVisible = true
    KEYBIND_STRIP:AddKeybindButtonGroup(self.keybindStripGroup)

    if self.onShown then self.onShown() end
  end

  local function OnSingularSectionHidden()
    self.isSingularSectionVisible = false

    if not self.isKeyboardListSectionVisible then
      KEYBIND_STRIP:RemoveKeybindButtonGroup(self.keybindStripGroup)
    end
  end

  local function OnUpdateGroupStatus()
    if self.isKeyboardListSectionVisible or self.isSingularSectionVisible then
      KEYBIND_STRIP:UpdateKeybindButtonGroup(self.keybindStripGroup)
    end
  end

  local keyboardSection = _G[self.root .. 'Finder_KeyboardListSection']
  if keyboardSection then
    ZO_PreHookHandler(
      keyboardSection,
      'OnEffectivelyShown',
      OnKeyboardListSectionShown
    )
    ZO_PreHookHandler(
      keyboardSection,
      'OnEffectivelyHidden',
      OnKeyboardListSectionHidden
    )
  end

  local singularSection = _G[self.root .. 'Finder_KeyboardSingularSection']
  if singularSection then
    ZO_PreHookHandler(singularSection, 'OnEffectivelyShown',
      OnSingularSectionShown)
    ZO_PreHookHandler(singularSection, 'OnEffectivelyHidden',
      OnSingularSectionHidden)
  end

  ZO_ACTIVITY_FINDER_ROOT_MANAGER:RegisterCallback("OnUpdateGroupStatus",
    OnUpdateGroupStatus)

  if self.singularSectionRewards then
    local eventName = self.root .. '_RandomEvent'
    local function OnRandomActivitySectionShown()
      local function Update()
        self:UpdatePurpleRewardTimer()
      end

      self:UpdatePurpleRewardTimer()
      EVENT_MANAGER:RegisterForUpdate(eventName, 1000, Update)
    end

    local function OnRandomActivitySectionHidden()
      EVENT_MANAGER:UnregisterForUpdate(eventName)
    end

    ZO_PreHookHandler(
      self.singularSectionRewards,
      'OnEffectivelyShown',
      OnRandomActivitySectionShown
    )
    ZO_PreHookHandler(
      self.singularSectionRewards,
      'OnEffectivelyHidden',
      OnRandomActivitySectionHidden
    )
  end
end

--- Adds an achievement icon to the control.
--- @param achievementId number|nil The achievement ID to display
--- @param controlName string The name for the created control
--- @param parent table The parent control
--- @param texture string The texture path for the icon
--- @return table The created icon control
function ActivityFinderExtender:AddAchievement(achievementId, controlName, parent,
                                               texture)
  local function showAchievement()
    if GetCategoryInfoFromAchievementId(achievementId) ~= nil then
      SCENE_MANAGER:ShowBaseScene()
      ACHIEVEMENTS:ShowAchievement(achievementId)
    end
  end

  local text, hidden, tooltip = nil, false, nil
  if achievementId then
    local achievementName, _, _, icon, isCompleted, _, _ = GetAchievementInfo(
      achievementId)
    text = isCompleted and self:FormatTexture(texture) or ""
    tooltip = self:FormatTexture(icon) .. zo_strformat(achievementName)
    hidden = not isCompleted
  elseif GAFE.SavedVars.developerMode and achievementId == nil then
    text = "-"
    hidden = false
  end

  return self:AddIcon(controlName, parent, text, showAchievement, tooltip, hidden)
end

--- Adds a quest completion icon to the control.
--- @param questId number|nil The quest ID to check completion for
--- @param controlName string The name for the created control
--- @param parent table The parent control
--- @param texture string The texture path for the icon
--- @return table The created icon control
function ActivityFinderExtender:AddQuest(questId, controlName, parent, texture)
  local text, isQuestCompleted = nil, false
  if questId then
    isQuestCompleted = GetCompletedQuestInfo(questId) ~= "" and true or false
    text = isQuestCompleted and self:FormatTexture(texture) or ""
    parent.gafeQuest = not isQuestCompleted
    self.hasQuests = self.hasQuests or parent.gafeQuest
  elseif GAFE.SavedVars.developerMode and questId == nil then
    text = "-"
  end

  return self:AddIcon(controlName, parent, text, function() end, nil,
    parent.gafeQuest)
end

--- Adds a wayshrine fast travel button to the control.
--- @param nodeIndex number|nil The wayshrine node index
--- @param parent table The parent control
--- @return table The created button control
function ActivityFinderExtender:AddWayshrine(nodeIndex, parent)
  local knownNode, name = nil, nil

  local function FastTravel()
    ZO_Dialogs_ShowPlatformDialog("RECALL_CONFIRM", { nodeIndex = nodeIndex },
      { mainTextParams = { name } })
  end

  if nodeIndex then
    knownNode = GetFastTravelNodeInfo(nodeIndex)
  end

  local button = LibPanicida.Controls.Button(
    parent:GetName() .. "t",
    parent,
    { self.textureSize, self.textureSize },
    { RIGHT, parent, LEFT, -5, 0 },
    nil,
    FastTravel,
    true,
    nil,
    not knownNode
  )

  button:SetNormalTexture("/esoui/art/icons/poi/poi_wayshrine_complete.dds")
  button:SetMouseOverTexture("/esoui/art/icons/poi/poi_wayshrine_glow.dds")

  return button
end

--- Adds set collection completion icons to the control.
--- @param setsIds table|nil Array of set IDs to check completion for
--- @param parent table The parent control
--- @return table The created icon control
function ActivityFinderExtender:AddSets(setsIds, parent)
  local text, hasAllSets = nil, true
  if setsIds then
    for _, setId in pairs(setsIds) do
      local setCollectionData = ITEM_SET_COLLECTIONS_DATA_MANAGER
          :GetItemSetCollectionData(setId)
      local numUnlockedPieces = setCollectionData:GetNumUnlockedPieces()
      local numPieces = setCollectionData:GetNumPieces()
      hasAllSets = hasAllSets and numUnlockedPieces == numPieces
    end

    text = hasAllSets and
        self:FormatTexture(
          "/esoui/art/crafting/smithing_tabicon_armorset_up.dds") or
        ""
    parent.gafeSets = not hasAllSets
  elseif GAFE.SavedVars.developerMode then
    text = "-"
  end

  return self:AddIcon(parent:GetName() .. "sets", parent, text, nil, nil,
    parent.gafeSets)
end

--- Formats a texture path into an ESO texture string.
--- @param texture string The texture path
--- @param size number|nil Optional size override (defaults to self.textureSize)
--- @return string The formatted texture string
function ActivityFinderExtender:FormatTexture(texture, size)
  if size == nil then size = self.textureSize end
  return "|t" .. size .. ":" .. size .. ":" .. texture .. "|t"
end

--- Adds a generic icon button to the control.
--- @param controlName string The name for the created control
--- @param parent table The parent control
--- @param text string|nil The text/texture to display
--- @param func function|nil The callback function when clicked
--- @param tooltip string|nil Optional tooltip text
--- @param hidden boolean|nil Whether the control should be hidden
--- @return table The created button control
function ActivityFinderExtender:AddIcon(controlName, parent, text, func, tooltip,
                                        hidden)
  local position = self.position
  self.position = position - self.textureSize

  return LibPanicida.Controls.Button(
    controlName,
    parent,
    { self.textureSize, self.textureSize },
    { LEFT, parent, LEFT, self.position, 0 },
    text,
    func,
    true,
    { tooltip },
    hidden
  )
end

--- Updates the premium reward timer display.
function ActivityFinderExtender:UpdatePurpleRewardTimer()
  local timeUntilNextReward = self.GetTimeUntilNextReward(self.characterId,
    self.rewardsVars)

  if timeUntilNextReward > 0 then
    self.premiumRewardTimerControl:SetHidden(false)

    local textStartTime = ZO_FormatTime(
      timeUntilNextReward,
      TIME_FORMAT_STYLE_SHOW_LARGEST_TWO_UNITS,
      TIME_FORMAT_PRECISION_SECONDS
    )

    self.premiumRewardTimerControl:SetText(GAFE.Loc("NextReward") ..
      " " .. textStartTime)
  else
    self.premiumRewardTimerControl:SetHidden(true)
  end
end

--- Checks or unchecks all activities matching the provided filter function.
--- @param checkFunc function Filter function that returns true for activities to check
function ActivityFinderExtender:CheckAllWhere(checkFunc)
  local m_active = self.pool.m_Active
  for _, obj in pairs(m_active) do
    if checkFunc(obj) and obj.check:GetState() == 0 then
      ZO_CheckButton_OnClicked(obj.check)
      ZO_ACTIVITY_FINDER_ROOT_MANAGER:ToggleLocationSelected(obj.node.data)
    elseif (not checkFunc(obj)) and obj.check:GetState() ~= 0 then
      ZO_CheckButton_OnClicked(obj.check)
      ZO_ACTIVITY_FINDER_ROOT_MANAGER:ToggleLocationSelected(obj.node.data)
    end
  end
end

--- Calculates the time remaining until the next daily reward reset.
--- @param characterId string The character ID to check rewards for
--- @param rewardsVars table The rewards saved variables table
--- @return number The number of seconds until next reward, or 0 if available now
function ActivityFinderExtender.GetTimeUntilNextReward(characterId, rewardsVars)
  local completedTimeStamp = rewardsVars.randomRewards[characterId]
  local today = LibPanicida.Utils.GetDailyResetDay()

  if LibPanicida.Utils.GetDailyResetDay(completedTimeStamp or 0) >= today then
    return GAFE.RewardTracker.GetTimeUntilDailyReset()
  end

  return 0
end

-- ============================================================================
-- Module Registration
-- ============================================================================
GAFE.ActivityFinderExtender = ActivityFinderExtender
