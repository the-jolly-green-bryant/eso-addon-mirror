local WM = WINDOW_MANAGER

-- Slot types
local COLLECTILBE_SLOT_TYPE = {
  HAT             = "Hat",
  HAIR            = "Hair",
  HEAD_MARKINGS   = "Head Markings",
  FACIAL_HAIR     = "Facial Hair",
  MINOR_ADORNMENT = "Minor Adornment",
  MAJOR_ADORNMENT = "Major Adornment",
  COSTUME         = "Costume",
  BODY_MARKINGS   = "Body Markings",
  SKIN            = "Skin",
  PERSONALITY     = "Personality",
  PET             = "Pet",
  MOUNT           = "Mount",
  POLYMORPH       = "Polymorph"
}

-- Slot information
EQUIPED_ICONS = {
  -- Slot type, Slot Name, Slot Icon
  [1]  = { COLLECTILBE_SLOT_TYPE.HAT             , "Hat"                 , "icon" },
  [2]  = { COLLECTILBE_SLOT_TYPE.HAIR            , "Hair"                , "icon" },
  [3]  = { COLLECTILBE_SLOT_TYPE.HEAD_MARKINGS   , "Head Marking"        , "icon" },
  [4]  = { COLLECTILBE_SLOT_TYPE.FACIAL_HAIR     , "Facial Hair / Horns" , "icon" },
  [5]  = { COLLECTILBE_SLOT_TYPE.MINOR_ADORNMENT , "Minor Adornment"     , "icon" },
  [6]  = { COLLECTILBE_SLOT_TYPE.MAJOR_ADORNMENT , "Major Adornment"     , "icon" },
  [7]  = { COLLECTILBE_SLOT_TYPE.COSTUME         , "Costume"             , "icon" },
  [8]  = { COLLECTILBE_SLOT_TYPE.BODY_MARKINGS   , "Body Marking"        , "icon" },
  [9]  = { COLLECTILBE_SLOT_TYPE.SKIN            , "Skin"                , "icon" },
  [10] = { COLLECTILBE_SLOT_TYPE.PERSONALITY     , "Personality"         , "icon" },
  [11] = { COLLECTILBE_SLOT_TYPE.PET             , "Non-Combat Pet"      , "icon" },
  [12] = { COLLECTILBE_SLOT_TYPE.MOUNT           , "Mount"               , "icon" },
  [13] = { COLLECTILBE_SLOT_TYPE.POLYMORPH       , "Polymorph"           , "icon" },
}

-- Quick slots
HOTBAR_CATEGORIES = {
  [1] = { HOTBAR_CATEGORY_QUICKSLOT_WHEEL , "Quickslots" , "esoui/art/inventory/inventory_tabicon_quickslot_up.dds", "esoui/art/inventory/inventory_tabicon_quickslot_down.dds" },
  [2] = { HOTBAR_CATEGORY_MEMENTO_WHEEL   , "Mementos"   , "EsoUI/Art/treeicons/achievements_indexicon_collections_up.dds", "EsoUI/Art/treeicons/achievements_indexicon_collections_down.dds" },
  [3] = { HOTBAR_CATEGORY_EMOTE_WHEEL     , "Emotes"     , "EsoUI/Art/treeicons/tutorial_idexicon_emotes_up.dds", "EsoUI/Art/treeicons/tutorial_idexicon_emotes_down.dds" },
  [4] = { HOTBAR_CATEGORY_ALLY_WHEEL      , "Allies"     , "/esoui/art/inventory/inventory_tabicon_companion_up.dds", "/esoui/art/inventory/inventory_tabicon_companion_down.dds" },
  [5] = { HOTBAR_CATEGORY_TOOL_WHEEL      , "Tools"      , "/esoui/art/inventory/inventory_tabicon_tool_up.dds", "/esoui/art/inventory/inventory_tabicon_tool_down.dds" },
}

local function GetSlotIdFromType(slotType)
  for i = 1, #EQUIPED_ICONS do
    if slotType == EQUIPED_ICONS[i][1] then return i end
  end
  return 0
end

local function GetSlotType(colId)

  local collectible = ZO_COLLECTIBLE_DATA_MANAGER:GetCollectibleDataById(colId)
  if not collectible then return 0 end

  local collTypeName = collectible:GetCategoryTypeDisplayName()

  for i = 1, #EQUIPED_ICONS do
    if collTypeName == EQUIPED_ICONS[i][2] then
      return EQUIPED_ICONS[i][1]
    end
  end

  return 0
end

CCUICharacter = ZO_Object:Subclass()

function CCUICharacter:New(...)
  local uiCharacter = ZO_Object.New(self)
  uiCharacter:Initialize(...)
  return uiCharacter
end

function CCUICharacter:Initialize(control)

  -- Predefine some variables
  control.owner = self
  self.control = control

  self.glowingControl = nil
  self.collectilbeControls = {}

  -- Quick slot filter
  self.filterData = {}
  self.filterController = nil
  self.selectedFilter = nil

  -- Quick slot items
  self.itemController = nil
  self.itemControllerList = {}
  self.isQuickGlowing = false

  self.titleNameData = {}
  self.outfitNameData = {}

  --[[

    self.quickSlotData = {
      ["Quickslots"] = {
          [1] = { itemType, itemId },
          [2] = { itemType, itemId },
          ...
      }
    }

  ]]--
  self.quickSlotData = {}  -- All quickslot data
  self.cosmeticData = {}
  self.titleData = nil
  self.outfitData = nil

  -- Populate with empty data
  for i = 1, 5 do
    self.quickSlotData[HOTBAR_CATEGORIES[i][2]] = {}
  end

  self.titleController = nil
  self.outfitController = nil

  self.dragCollectilbeId = nil

  -- Drag variables
  self.isDragging = false
  self.dragType = nil
  self.dragData = nil


  self:CreateMyscPanel()
  self:CreateEquipedIcons()

  -- Filters
  self:CreateQuickSlotItems()
  self:CreateQuickSlotFilters()

  -- Setup events
  self:SetupEvents()
end

function CCUICharacter:GetSlotControl(slotType)
  local slotIndex = GetSlotIdFromType(slotType)
  if slotIndex == 0 then return nil end
  return self.collectilbeControls[slotIndex]
end

--[[
  Handle events
]]--
do

  function CCUICharacter:SetupEvents()

    local function OnChangesMade()
      local control = WM:GetControlByName("CC_PanelOptionsPanelUnsavedLabel")
      control:SetHidden(false)
    end

    local function OnChangesSaved()
      local control = WM:GetControlByName("CC_PanelOptionsPanelUnsavedLabel")
      control:SetHidden(true)
    end

    local function OnDragStarted(dragType, data)

      -- Set the drag type
      self.dragType = dragType
      self.isDragging = true

      -- Check for a coll drag event
      if dragType == CC_DRAG_TYPE_COLLECTIBLE then
        -- Get the slot type being draged
        local slotType = GetSlotType(data)
        if slotType ~= 0 then
          self:ToggleSlotGlow(slotType)       -- We want to glow
        end

        -- Store the id of col being draged
        self.dragCollectilbeId = data

      elseif 
        dragType == CC_DRAG_TYPE_MEMENTO or
        dragType == CC_DRAG_TYPE_EMOTE or
        dragType == CC_DRAG_TYPE_COMPANION or
        dragType == CC_DRAG_TYPE_TOOL then

        -- Store the drag data
        self.dragData = data
        self:ToggleQuickSlotGlow()

      end
    end

    local function OnDragDrop()

      self.isDragging = false

      if self.glowingControl ~= nil then
        self.glowingControl:SetHidden(true)
      end

      if self.isQuickGlowing then
        self:ToggleQuickSlotGlow()
      end

      self.dragType = nil
      self.isDragging = false
    end

    CC_CALLBACK_MANAGER:RegisterCallback(CC_ON_CHANGES_MADE, OnChangesMade)
    CC_CALLBACK_MANAGER:RegisterCallback(CC_ON_CHANGES_SAVED, OnChangesSaved)

    CC_CALLBACK_MANAGER:RegisterCallback(CC_ON_DRAG_START, OnDragStarted)
    CC_CALLBACK_MANAGER:RegisterCallback(CC_ON_DRAG_DROP, OnDragDrop)
  end
end

--[[
  Panel Setup methods
]]--
do
  -- Initiate the equiped icons
  function CCUICharacter:CreateEquipedIcons()

    local parent = WINDOW_MANAGER:GetControlByName("CC_PanelCollectionsPanel")
    local control

    -- Create the panels
    for i = 1, #EQUIPED_ICONS do

      local index = i
      local slotType = EQUIPED_ICONS[index][1]

      -- Main collectilbes
      if i < 11 then

        local controlName = string.format("CC_PanelCollectionsPanel_%i", i)
        control = WM:CreateControlFromVirtual(controlName, parent, "CC_COSMETIC_ITEM")

        control:SetAnchor(TOPLEFT, parent, TOPLEFT, 10, ((i-1) * 2) +  40 + (i-1) * 60)
        control:SetAnchor(TOPRIGHT, parent, TOPRIGHT, -10, ((i-1) * 2) + 40 + (i-1) * 60)

        local titleLabel = control:GetNamedChild("Title")
        titleLabel:SetText(EQUIPED_ICONS[i][1])

        local highlight = control:GetNamedChild("Highlight")
        highlight:ClearAnchors();
        highlight:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)
        highlight:SetAnchor(BOTTOMRIGHT, control, BOTTOMRIGHT, 0, 0)

      -- Mysc collectibles
      else

        local names = {
          [11] = "Pet",
          [12] = "Mount",
          [13] = "Polymorph"
        }

        local controlName = string.format("CC_PanelMyscPanelMiscExtraCosmetics%s", names[i])
        control = WM:GetControlByName(controlName)
      end

      -- Empty icon by default
      local icon = control:GetNamedChild("Button")

      if not icon then return end

      icon:SetNormalTexture("EsoUI/Art/Quickslots/quickslot_emptySlot.dds")

      self.collectilbeControls[i] = control
    end
  end

  -- Initiate the quickslot filters
  function CCUICharacter:CreateQuickSlotFilters()

    local function OnTabSelected(index)
      self.selectedFilter = self.filterData[index].descriptor
      self:BuildQuickSlotPanel()
    end

    self.filterController = WM:GetControlByName("CC_PanelMyscPanelQuickSlotsIndex")

    local tabData = {
      initialButtonAnchorPoint = LEFT,
      buttonPadding = -4,
      normalSize    = 30,
      downSize      = 40,
    }
    CC_TabFilter_SetData(self.filterController, tabData)

    self.filterData = {}

    for i = 1, #HOTBAR_CATEGORIES do
      self.filterData[i] = {
        activeTabText = HOTBAR_CATEGORIES[i][2],
        descriptor    = HOTBAR_CATEGORIES[i][2],
        normal        = HOTBAR_CATEGORIES[i][3],
        pressed       = HOTBAR_CATEGORIES[i][4],
        callback = function(...) OnTabSelected(i) end,
      }

      CC_TabFilter_AddButton(self.filterController, self.filterData[i])
    end

    CC_TabFilter_UpdateButtons(self.filterController)
    CC_TabFilter_SelectDescriptor(self.filterController, self.filterData[1].descriptor)
  end

  -- Initiate the quickslot icons
  function CCUICharacter:CreateQuickSlotItems()

    local function OnDragDrop(slotId)
      ClearCursor()
      PlaySound(SOUNDS.OUTFIT_EQUIPPED_HIDE)

      if CC_UI_MANAGER:IsProfileSelected() then
        -- Slot the item!
        self:SetQuickSlot(slotId, self.dragData)
      else
        CC:SendToChat("You must create a profile before you can add collectibles.")
      end
    end

    local tabName = HOTBAR_CATEGORIES[1][2]
    local quickslotParent = WM:GetControlByName("CC_PanelMyscPanelQuickSlotsItems")
    local panelName = string.format("CC_QuickSlotGrid_%s", tabName)

    self.itemController = WM:CreateControlFromVirtual(panelName, quickslotParent, "CC_CollectionList")
    self.itemController:SetAnchor(TOPLEFT, nil, TOPLEFT, 0, 0)

    local width, _ = quickslotParent:GetDimensions()

    local controlData = {
      title = "Empty",
      showBullet = true,
      isRadial = true,
      width = width,
      height = width,
      gridHeight = 190,
      gridWidth = 190,
      paddingX = 0,
      paddingY = 10,
      itemWidth = 50,
      itemHeight = 50,
    }

    CC_CollectionListTemplate_SetData(self.itemController, controlData)
    CC_CollectionListTemplate_UpdateLayout(self.itemController)

    -- Fill with empty items
    for i = 1, 8 do

      local texture = "EsoUI/Art/Quickslots/quickslot_emptySlot.dds"
      local itemLink = nil

      local itemData = {
        texture  = texture,
        itemLink = itemLink,
        onDragCallback = function(...)  end,
        clickedCallback = function(...)
          if GetCursorContentType() ~= MOUSE_CONTENT_EMPTY then
            OnDragDrop(i)
          end
        end
      }


      self.itemControllerList[i] = CC_CollectionListTemplate_AddItem(self.itemController, itemData)

      local icon = self.itemControllerList[i]:GetNamedChild("Image")

      -- If directly draged
      icon:SetHandler("OnReceiveDrag", function()
        OnDragDrop(i)
      end)

      -- If clicked and droped
      icon:SetHandler("OnClicked", function(self)
        -- Check if the cursor is draging something
        if GetCursorContentType() ~= MOUSE_CONTENT_EMPTY then
          OnDragDrop(i)
        end
      end)
    end

    -- Test wheel
    do
      
    end

  end

  -- Initiate title and outfit
  function CCUICharacter:CreateMyscPanel()

    local function CreateDropDownControl(control)
      local dropdown = ZO_ComboBox_ObjectFromContainer(control)
      dropdown:ClearItems()
      dropdown:SetSortsItems(false) -- We do want to sort
      return dropdown
    end

    do

      local function GetSortedTitleList()

        local titleData = {}

        for i = 1, GetNumTitles() do
          local titleString = zo_strformat(GetTitle(i), GetRawUnitName("player"))
          titleData[i] = { titleString , i }
        end

        table.sort(titleData, function(a, b) return a[1]:lower() < b[1]:lower() end)
        return titleData
      end

      local function OnTitleSelected(titleIndex)
        self.titleData = titleIndex
        CC_CALLBACK_MANAGER:FireCallbacks(CC_ON_CHANGES_MADE)
      end

      -- Setup title
      local titleControl = WM:GetControlByName("CC_PanelMyscPanelMiscTitleSelectBox")
      local titleSelectControl = titleControl:GetNamedChild("TitleSelect")
      self.titleDropdown = CreateDropDownControl(titleSelectControl)

      -- Add default empt title
      local defaultTitleElement = ZO_ComboBox:CreateItemEntry(GetString(SI_STATS_NO_TITLE), function() OnTitleSelected(nil) end)
      self.titleDropdown:AddItem(defaultTitleElement, ZO_COMBOBOX_SUPPRESS_UPDATE)

      self.titleNameData = GetSortedTitleList()

      for i = 1, #self.titleNameData do
        self.titleDropdown:AddItem(ZO_ComboBox:CreateItemEntry(self.titleNameData[i][1], function() OnTitleSelected(self.titleNameData[i][2]) end), ZO_COMBOBOX_SUPPRESS_UPDATE)
      end
      
      -- Update all
      self.titleDropdown:UpdateItems()
      self.titleDropdown:SelectItem(defaultTitleElement)
    end

    do

      local function OnOutfitSelected(outfitIndex)
        self.outfitData = outfitIndex
        CC_CALLBACK_MANAGER:FireCallbacks(CC_ON_CHANGES_MADE)
      end

      local outfitControl = WM:GetControlByName("CC_PanelMyscPanelMiscOutfitSelectBox")
      local outfitSelectControl = outfitControl:GetNamedChild("OutfitSelect")
      self.outfitDropdown = CreateDropDownControl(outfitSelectControl)

      local defaultOutfitElement = ZO_ComboBox:CreateItemEntry("No Outfit", function() OnOutfitSelected(0) end)
      self.outfitDropdown:AddItem(defaultOutfitElement, ZO_COMBOBOX_SUPPRESS_UPDATE)

      for i = 1, GetNumUnlockedOutfits() do

        -- Check for a name
        if GetOutfitName(GAMEPLAY_ACTOR_CATEGORY_PLAYER, i) == "" then
          local outfitName = string.format("Outfit %i", i)
          self.outfitDropdown:AddItem(ZO_ComboBox:CreateItemEntry(outfitName, function() OnOutfitSelected(i) end), ZO_COMBOBOX_SUPPRESS_UPDATE)
        else
          local outfitName = GetOutfitName(GAMEPLAY_ACTOR_CATEGORY_PLAYER, i)
          self.outfitDropdown:AddItem(ZO_ComboBox:CreateItemEntry(outfitName, function() OnOutfitSelected(i) end), ZO_COMBOBOX_SUPPRESS_UPDATE)
        end

      end

      self.outfitDropdown:UpdateItems()
      self.outfitDropdown:SelectItem(defaultOutfitElement)
    end
  end
end

--[[
  Quickslot controls
]]--
function CCUICharacter:BuildQuickSlotPanel()

  -- Update icon title
  CC_CollectionListTemplate_SetTitle(self.itemController, self.selectedFilter)

  -- Update the icons
  self:BuildQuickSlotsIcons()
end

--[[
  UI Controls
]]--
do
  -- Update the collectilbe in a slot
  function CCUICharacter:SetSlotCollectible(slotType, collectibleId)

    -- Check if this is being set to nothing
    if collectibleId == nil then
      self.cosmeticData[slotType] = nil
    else

      -- Get the draged collectilbe
      local colType = GetSlotType(collectibleId)

      -- This does not belong in this slot
      if slotType ~= colType then return end

      -- Store
      self.cosmeticData[slotType] = collectibleId
    end

    self:BuildCollectionSlotIcons()
    CC_CALLBACK_MANAGER:FireCallbacks(CC_ON_CHANGES_MADE)
  end

  -- Update the item in the quickslot
  function CCUICharacter:SetQuickSlot(slotId, itemId)

    -- Check if the item is currently slotable
    local function CanSlot()
      -- Can always slot in this one.
      if self.selectedFilter == "Quickslots" then return true end

      if self.dragType == CC_DRAG_TYPE_MEMENTO then
        return self.selectedFilter == "Mementos"
      elseif self.dragType == CC_DRAG_TYPE_EMOTE then
        return self.selectedFilter == "Emotes"
      elseif self.dragType == CC_DRAG_TYPE_COMPANION then
        return self.selectedFilter == "Allies"
      elseif self.dragType == CC_DRAG_TYPE_TOOL then
        return self.selectedFilter == "Tools"
      end
    end

    -- Check if the slot already contains the collectible
    local function AlreadyContains(itemId)

      -- Get the selected filter items
      local items = self.quickSlotData[self.selectedFilter]

      for i = 1, 8 do

        local currentItem = items[i]

        -- We only want non nil
        if currentItem ~= nil then

          -- Check this is the same drag type
          if currentItem[1] == self.dragType and currentItem[2] == itemId then
            return i
          end
        end
      end

      return 0
    end

    if itemId ~= nil then
      -- We only slot if we can slot.
      if not CanSlot() then return end

      local itemControl = self.itemControllerList[slotId]
      local alreadySlot = AlreadyContains(itemId)

      -- There is already this item
      if alreadySlot > 0 then
        self.quickSlotData[self.selectedFilter][alreadySlot] = nil
      end

      -- Handle slot functions
      if self.dragType == CC_DRAG_TYPE_MEMENTO then
        self.quickSlotData[self.selectedFilter][slotId] = { CC_DRAG_TYPE_MEMENTO, itemId }
      elseif self.dragType == CC_DRAG_TYPE_EMOTE then
        self.quickSlotData[self.selectedFilter][slotId] = { CC_DRAG_TYPE_EMOTE, itemId }
      elseif self.dragType == CC_DRAG_TYPE_COMPANION then
        self.quickSlotData[self.selectedFilter][slotId] = { CC_DRAG_TYPE_COMPANION, itemId }
      elseif self.dragType == CC_DRAG_TYPE_TOOL then
        self.quickSlotData[self.selectedFilter][slotId] = { CC_DRAG_TYPE_TOOL, itemId }
      end
    else
      -- Remove it
      self.quickSlotData[self.selectedFilter][slotId] = nil
    end

    self:BuildQuickSlotsIcons()
    CC_CALLBACK_MANAGER:FireCallbacks(CC_ON_CHANGES_MADE)
  end

  -- Make a slot glow
  function CCUICharacter:ToggleSlotGlow(slotType)

    -- We started dragin again, but already had a highlight
    if self.glowingControl ~= nil then
      self.glowingControl:SetHidden(true)
    end

    -- Get the slot type
    local control = self.collectilbeControls[GetSlotIdFromType(slotType)]
    local controlGlow = control:GetNamedChild("Highlight")
    controlGlow:SetHidden(false)

    self.glowingControl = controlGlow
  end

  function CCUICharacter:ToggleQuickSlotGlow()

    local function Toggle()
      local toggle = not self.isQuickGlowing
      for i = 1, #self.itemControllerList do
        local glowControl = self.itemControllerList[i]:GetNamedChild("Highlight")
        glowControl:SetHidden(not toggle)
      end
      self.isQuickGlowing = toggle
    end

    -- Check to see if we are disabling
    if not self.isDragging and self.isQuickGlowing == true then
      Toggle()
      return
    end

    -- Always highlight
    if self.selectedFilter == "Quickslots" then
      Toggle()
      return
    end

    local shouldGlow = false

    -- We have started dragging.
    if self.dragType == CC_DRAG_TYPE_MEMENTO then

      -- Check for the correct panel type
      if self.selectedFilter == "Mementos" then
        shouldGlow = true
      end
    elseif self.dragType == CC_DRAG_TYPE_EMOTE then
      if self.selectedFilter == "Emotes" then
        shouldGlow = true
      end
    elseif self.dragType == CC_DRAG_TYPE_COMPANION then
      if self.selectedFilter == "Allies" then
        shouldGlow = true
      end
    elseif self.dragType == CC_DRAG_TYPE_TOOL then
      if self.selectedFilter == "Tools" then
        shouldGlow = true
      end
    end

    if shouldGlow then Toggle() end
  end
end

-- Builds the collection slots data
function CCUICharacter:BuildCollectionSlotIcons()

  local function EmptySlot(slotType)

    local control = self:GetSlotControl(slotType)

    if control then
      local button   = control:GetNamedChild("Button")
      local label    = control:GetNamedChild("Label")

      button:SetNormalTexture("EsoUI/Art/Quickslots/quickslot_emptySlot.dds")

      if label then
        label:SetText("")
      end

      control:SetHandler("OnMouseEnter", nil)
      control:SetHandler("OnMouseExit", nil)
      button:SetHandler("OnMouseEnter", nil)
      button:SetHandler("OnMouseExit", nil)
    end
  end

  for i = 1, #EQUIPED_ICONS do

    local slotType = EQUIPED_ICONS[i][1]
    EmptySlot(slotType)

    local collectibleId = self.cosmeticData[slotType]

    local control = self:GetSlotControl(slotType)

    if control then
        
      local button    = control:GetNamedChild("Button")
      local label     = control:GetNamedChild("Label")
      local highlight = control:GetNamedChild("Highlight")
      
      local star = control:GetNamedChild("Star")
      star:SetHidden(true)

      -- Beck for a collectible
      if collectibleId then
        local collectibleData = ZO_COLLECTIBLE_DATA_MANAGER:GetCollectibleDataById(collectibleId)
        button:SetNormalTexture(collectibleData:GetIcon())
  
        control:SetHandler("OnMouseEnter",
          function(self)
            CC_UI.ShowToolTip(control, GetCollectibleLink(collectibleId))
            highlight:SetHidden(false)
          end)
        control:SetHandler("OnMouseExit",
          function(self)
            CC_UI.HideToolTip()
            highlight:SetHidden(true)
          end)
        button:SetHandler("OnMouseEnter",
          function(self)
            CC_UI.ShowToolTip(control, GetCollectibleLink(collectibleId))
            highlight:SetHidden(false)
          end)
        button:SetHandler("OnMouseExit",
          function(self)
            CC_UI.HideToolTip()
            highlight:SetHidden(true)
          end)
  
        if label then
          label:SetText(collectibleData:GetFormattedName())
        end
      else
        control:SetHandler("OnMouseEnter",
        function(self)
          highlight:SetHidden(false)
        end)
        control:SetHandler("OnMouseExit",
          function(self)
            highlight:SetHidden(true)
          end)
        button:SetHandler("OnMouseEnter",
          function(self)
            highlight:SetHidden(false)
          end)
        button:SetHandler("OnMouseExit",
          function(self)
            highlight:SetHidden(true)
          end)
      end

      -- Setup drop controls
      do

        local function OnDragDrop(slotType)
          ClearCursor()
          PlaySound(SOUNDS.OUTFIT_EQUIPPED_HIDE)

          if CC_UI_MANAGER:IsProfileSelected() then
            self:SetSlotCollectible(slotType, self.dragCollectilbeId)
          else
            CC:SendToChat("You must create a profile before you can add collectibles.")
          end
        end

        -- If directly draged
        button:SetHandler("OnReceiveDrag", function(self)
          OnDragDrop(slotType)
        end)

        -- If clicked and droped
        button:SetHandler("OnClicked", function(self)
          -- Check if the cursor is draging something
          if GetCursorContentType() ~= MOUSE_CONTENT_EMPTY then
            OnDragDrop(slotType)
          end
        end)

        -- TODO: Open panel to collection type
        button:SetHandler("OnMouseUp", function(control, button, upInside, ctrl, alt, shift, command)
          if button == MOUSE_BUTTON_INDEX_RIGHT then
            -- self:SetSlotCollectible(slotType, nil)
            -- CC_UI.HideToolTip() -- Incase it's showing
            -- CC_CALLBACK_MANAGER:FireCallbacks(CC_ON_COLLECTIBLE_RIGHT_CLICKED)
            ClearMenu()
            AddCustomMenuItem("Clear", function()
              CC_UI.HideToolTip() -- Incase it's showing
              self:SetSlotCollectible(slotType, nil)
              CC_CALLBACK_MANAGER:FireCallbacks(CC_ON_COLLECTIBLE_RIGHT_CLICKED)
            end)

            AddCustomMenuItem("Show in Collections", function()
              CC_UI.HideToolTip() -- Incase it's showing
              CC_UI_MANAGER:OpenCollectionList(i+1)
            end)

            if collectibleId then
              AddCustomMenuItem("Link in Chat", function ()
                ZO_LinkHandler_InsertLink(zo_strformat(SI_TOOLTIP_ITEM_NAME, GetCollectibleLink(collectibleId)))
              end)
            end
            ShowMenu()

          elseif button == MOUSE_BUTTON_INDEX_LEFT then
            CC_UI_MANAGER:OpenCollectionList(i+1)
          end
        end)

        -- If directly draged
        control:SetHandler("OnReceiveDrag", function()
          if GetCursorContentType() ~= MOUSE_CONTENT_EMPTY then
            OnDragDrop(slotType)
          end
        end)

        -- If clicked and droped
        control:SetHandler("OnClicked", function()
          -- Check if the cursor is draging something
          if GetCursorContentType() ~= MOUSE_CONTENT_EMPTY then
            OnDragDrop(slotType)
          end
        end)

        -- TODO: Open panel to collection type
        control:SetHandler("OnMouseUp", function(control, button, upInside, ctrl, alt, shift, command)
          if button == MOUSE_BUTTON_INDEX_RIGHT then
            ClearMenu()
            AddCustomMenuItem("Clear", function()
              CC_UI.HideToolTip() -- Incase it's showing
              self:SetSlotCollectible(slotType, nil)
              CC_CALLBACK_MANAGER:FireCallbacks(CC_ON_COLLECTIBLE_RIGHT_CLICKED)
            end)

            AddCustomMenuItem("Show in Collections", function()
              CC_UI.HideToolTip() -- Incase it's showing
              CC_UI_MANAGER:OpenCollectionList(i+1)
            end)

            if collectibleId then
              AddCustomMenuItem("Link in Chat", function ()
                ZO_LinkHandler_InsertLink(zo_strformat(SI_TOOLTIP_ITEM_NAME, GetCollectibleLink(collectibleId)))
              end)
            end

            ShowMenu()
          elseif button == MOUSE_BUTTON_INDEX_LEFT then
            CC_UI_MANAGER:OpenCollectionList(i+1)
          end
        end)
      end
    end
  end
end

-- Builds the quick slot data
function CCUICharacter:BuildQuickSlotsIcons()

  local function EmptySlot(slotId)
    local itemControl = self.itemControllerList[slotId]
    local icon = itemControl:GetNamedChild("Image")
    icon:SetTexture("EsoUI/Art/Quickslots/quickslot_emptySlot.dds")

    itemControl:SetHandler("OnMouseEnter", nil)
    itemControl:SetHandler("OnMouseExit", nil)
  end

  -- Data for the current selected slot!
  local slotData = self.quickSlotData[self.selectedFilter]

  if slotData == nil then return end

  -- Loop through each container
  for i = 1, 8 do

    -- Remove the content of the slot already
    EmptySlot(i)

    local control = self.itemControllerList[i]
    local icon = control:GetNamedChild("Image")
    local highlight = control:GetNamedChild("Highlight")

    -- Check for something in this slot
    if slotData[i] ~= nil then

      local slotType = slotData[i][1]
      local slotData = slotData[i][2]

      -- Check for slot types
      if slotType == CC_DRAG_TYPE_MEMENTO or slotType == CC_DRAG_TYPE_COMPANION or slotType == CC_DRAG_TYPE_TOOL then
        local mementoData = ZO_COLLECTIBLE_DATA_MANAGER:GetCollectibleDataById(slotData)
        local mementoIcon = mementoData:GetIcon()
        icon:SetTexture(mementoIcon)

        control:SetHandler("OnMouseEnter", function() 
          CC_UI.ShowToolTip(control, GetCollectibleLink(slotData))
          highlight:SetHidden(false)
        end)

        control:SetHandler("OnMouseExit", function() 
          CC_UI.HideToolTip()
          highlight:SetHidden(true)
        end)

        control:SetHandler("OnMouseUp", function(_, button)
          if button == MOUSE_BUTTON_INDEX_RIGHT then
            ClearMenu()
            AddCustomMenuItem("Clear", function()
              CC_UI.HideToolTip() -- Incase it's showing
              self:SetQuickSlot(i, nil)
            end)
            ShowMenu()
          end
        end)

      elseif slotType == CC_DRAG_TYPE_EMOTE then
        local emoteIndex = GetEmoteIndex(slotData)
        local slashName, emoteCategory, emoteId, displayName, _ = GetEmoteInfo(emoteIndex)
        local emoteIcon = PLAYER_EMOTE_MANAGER:GetSharedEmoteIconForCategory(emoteCategory)

        icon:SetTexture(emoteIcon)

        control:SetHandler("OnMouseEnter",
          function(self)
            ZO_Tooltips_ShowTextTooltip(self, TOP, slashName)
          end)

        control:SetHandler("OnMouseExit",
          function(self)
              ZO_Tooltips_HideTextTooltip()
          end)

        control:SetHandler("OnMouseUp", function(se, button, upInside, ctrl, alt, shift, command)
          if button == MOUSE_BUTTON_INDEX_RIGHT then
            ClearMenu()
            AddCustomMenuItem("Clear", function()
              CC_UI.HideToolTip() -- Incase it's showing
              self:SetQuickSlot(i, nil)
            end)
            ShowMenu()
          end
        end)
      end
    else
      control:SetHandler("OnMouseEnter", function() 
        highlight:SetHidden(false)
      end)

      control:SetHandler("OnMouseExit", function() 
        highlight:SetHidden(true)
      end)

      control:SetHandler("OnMouseUp", function(_, button)
        if button == MOUSE_BUTTON_INDEX_RIGHT then
          ClearMenu()
          AddCustomMenuItem("Clear", function()
            self:SetQuickSlot(i, nil)
          end)
          ShowMenu()
        end
      end)
    end
  end
end

--[[
  Data Setters
]]--
function CCUICharacter:SetTitle(titleIndex)

  if titleIndex == nil then
    self.titleDropdown:SetSelectedItemText(GetString(SI_STATS_NO_TITLE))
    return
  end

  self.titleData = titleIndex
  local titleName = ""

  if self.titleData == 0 then
    titleName = GetString(SI_STATS_NO_TITLE)
  else
    titleName = zo_strformat(GetTitle(titleIndex), GetRawUnitName("player"))
  end

  self.titleDropdown:SetSelectedItemText(titleName)
end

function CCUICharacter:SetOutfit(outfitIndex)

  if outfitIndex == nil then
    self.outfitDropdown:SetSelectedItemText("No Outfit")
    return
  end

  self.outfitData = outfitIndex

  -- Get player outfit
  local outfitName = GetOutfitName(GAMEPLAY_ACTOR_CATEGORY_PLAYER, self.outfitData)

  -- Check for a name
  if outfitName == "" then
    outfitName = string.format("Outfit %i", outfitIndex)
  end

  self.outfitDropdown:SetSelectedItemText(outfitName)
end

function CCUICharacter:SetCollectibleData(collectibleData)
  -- Update the display
  self.cosmeticData = collectibleData or {}
  self:BuildCollectionSlotIcons()
end

function CCUICharacter:SetQuickSlotData(quickslotData)

  if quickslotData == nil then
    self.quickSlotData = {}
    for i = 1, #HOTBAR_CATEGORIES do
      self.quickSlotData[HOTBAR_CATEGORIES[i][2]] = {}
    end

    self:BuildQuickSlotsIcons()
    return
  end

  -- Update the display
  self.quickSlotData = quickslotData
  self:BuildQuickSlotsIcons()
end

--[[
  Data Getters
]]--
function CCUICharacter:GetCollectibleData()
  return self.cosmeticData
end

function CCUICharacter:GetQuickSlotData()
  return self.quickSlotData
end

function CCUICharacter:GetTitle()
  return self.titleData
end

function CCUICharacter:GetOutfit()
  return self.outfitData
end
