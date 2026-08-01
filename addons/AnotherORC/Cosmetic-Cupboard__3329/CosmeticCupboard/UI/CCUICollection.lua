
local WM = WINDOW_MANAGER

local COSMETIC_FILTER_ICONS = {
  [CC_COLLECTION_FILTER_ALL]              = { "All"             , "EsoUI/Art/inventory/inventory_tabicon_all_up.dds", "EsoUI/Art/inventory/inventory_tabicon_all_down.dds"},
  [CC_COLLECTION_FILTER_HAT]              = { "Hat"             , "EsoUI/art/treeicons/collection_indexicon_armor_up.dds", "EsoUI/art/treeicons/collection_indexicon_armor_down.dds"},
  [CC_COLLECTION_FILTER_HAIR]             = { "Hair"            , "esoui/art/inventory/inventory_tabicon_craftbag_clothing_up.dds", "esoui/art/inventory/inventory_tabicon_craftbag_clothing_down.dds"},
  [CC_COLLECTION_FILTER_HEAD_MARKINGS]    = { "Head Markings"   , "EsoUI/Art/dye/dyes_categoryicon_up.dds", "EsoUI/Art/dye/dyes_categoryicon_down.dds"},
  [CC_COLLECTION_FILTER_FACIAL_HAIR]      = { "Facial Hair"     , "EsoUI/Art/help/help_tabicon_emotes_up.dds", "EsoUI/Art/help/help_tabicon_emotes_down.dds"},
  [CC_COLLECTION_FILTER_MINOR_ADORNMENT]  = { "Minor Adornment" , "esoui/art/inventory/inventory_tabicon_craftbag_stylematerial_up.dds", "esoui/art/inventory/inventory_tabicon_craftbag_stylematerial_down.dds"},
  [CC_COLLECTION_FILTER_MAJOR_ADORNMENT]  = { "Major Adornment" , "EsoUI/Art/guild/guildheraldry_indexicon_background_up.dds", "EsoUI/Art/guild/guildheraldry_indexicon_background_down.dds"},
  [CC_COLLECTION_FILTER_COSTUME]          = { "Costume"         , "EsoUI/Art/collections/collections_tabicon_outfitstyles_up.dds", "EsoUI/Art/collections/collections_tabicon_outfitstyles_down.dds"},
  [CC_COLLECTION_FILTER_BODY_MARKINGS]    = { "Body Markings"   , "EsoUI/Art/dye/dyes_tabicon_costumedye_up.dds", "EsoUI/Art/dye/dyes_tabicon_costumedye_down.dds"},
  [CC_COLLECTION_FILTER_SKIN]             = { "Skin"            , "EsoUI/Art/mainmenu/menubar_character_up.dds", "EsoUI/Art/mainmenu/menubar_character_down.dds" },
  [CC_COLLECTION_FILTER_PERSONALITY]      = { "Personality"     , "EsoUI/Art/contacts/tabicon_friends_up.dds", "EsoUI/Art/contacts/tabicon_friends_down.dds"},
  [CC_COLLECTION_FILTER_PET]              = { "Pet"             , "EsoUI/Art/treeicons/store_indexicon_vanitypets_up.dds", "EsoUI/Art/treeicons/store_indexicon_vanitypets_down.dds"},
  [CC_COLLECTION_FILTER_MOUNT]            = { "Mount"           , "EsoUI/Art/mounts/tabicon_mounts_up.dds", "EsoUI/Art/mounts/tabicon_mounts_down.dds"},
  [CC_COLLECTION_FILTER_POLYMORPH]        = { "Polymorph"       , "EsoUI/Art/mainmenu/menubar_champion_up.dds", "EsoUI/Art/mainmenu/menubar_champion_down.dds"},
}

local MEMENTO_FILTER_ICONS = {
  [CC_MEMENTO_FILTER_ALL]     = { "All"     , "EsoUI/Art/inventory/inventory_tabicon_all_up.dds", "EsoUI/Art/inventory/inventory_tabicon_all_down.dds"},
  [CC_MEMENTO_FILTER_MEMENTO] = { "Memento" , "EsoUI/Art/treeicons/achievements_indexicon_collections_up.dds", "EsoUI/Art/treeicons/achievements_indexicon_collections_down.dds"},
  [CC_MEMENTO_FILTER_ALLIES]  = { "Allies"  , "/esoui/art/inventory/inventory_tabicon_companion_up.dds", "/esoui/art/inventory/inventory_tabicon_companion_down.dds"},
  [CC_MEMENTO_FILTER_TOOLS]   = { "Tools"   , "/esoui/art/inventory/inventory_tabicon_tool_up.dds", "/esoui/art/inventory/inventory_tabicon_tool_down.dds"}
}

CCUICollection = ZO_Object:Subclass()

function CCUICollection:New(...)
  local uiCollection = ZO_Object.New(self)
  uiCollection:Initialize(...)
  return uiCollection
end

function CCUICollection:Initialize(control)
  -- Predefine some variables
  control.owner = self
  self.control = control

  -- Default menu type
  self.tabs      = nil
  self.activeTab = nil
  self.currentTabDescriptor    = nil
  self.currentTabControl       = nil

  -- Current search
  self.search = ""

  -- Collections parameters
  self.collectionFilterControl = nil
  self.collectionFilters = nil
  self.collectionLists = {}
  self.collectionActiveFilter = nil
  self.collectionEmptyBox = nil

  self.collectionCurrentEquiped = {}
  self.collectionProfileEquiped = {}

  -- Memento parameters
  self.mementoFilters = nil
  self.mementoActiveFilter = nil
  self.mementoLists = {}
  self.mementoEptyBox = nil

  -- Emote parameters
  self.emoteList = nil

  -- Create the panel
  self:SetupCollectionPanels()

  -- Start events
  self:RegisterEvents()
end

function CCUICollection:SetupCollectionPanels()

  -- Initiate panels
  local colPanel = WM:GetControlByName("CC_Panel_CollectionCollectibles") 
  local memPanel = WM:GetControlByName("CC_Panel_CollectionMementos")
  local emoPanel = WM:GetControlByName("CC_Panel_CollectionEmotes")

  -- Get references to the panels
  self.panels = {}
  self.panels[CC_TAB_MENU_COLLECTIBLE] = colPanel
  self.panels[CC_TAB_MENU_MEMENTO]     = memPanel
  self.panels[CC_TAB_MENU_EMOTE]       = emoPanel

  -- Get the current worn collectibles
  self:GetCurrentWornCollectibles()

  -- Initate the panel type filter
  self:CreateCollectionTypeFilter()

  -- Create Collection panel
  self:CreateCollectionPanelFilter()
  self:CreateCollectionPanelLists()
  self:BuildCollectionPanelLists()

  -- Create a list of emotes
  self:CreateEmotePanel()
  self:BuildEmotePanel()

  -- Create list of mementos
  self:CreateMementoPanelFilter()
  self:CreateMementoPanelLists()
  self:BuildMementoPanelLists()

end

function CCUICollection:GetCurrentWornCollectibles()
  for _, item in pairs(COLLECTIBLE_CATAGORIES_APPEARANCE) do
    self.collectionCurrentEquiped[item[1]] = GetActiveCollectibleByType(item[1])
  end
end

function CCUICollection:CreateCollectionTypeFilter()

  -- CC_TypeIconTemplate
  local control  = WM:GetControlByName("CC_Panel_Collection")
  self.tabs      = control:GetNamedChild("Tabs")
  self.activeTab = control:GetNamedChild("TabsActive")

  local function PlayerDrivenCallback(tabData)
    self:OnTabFilterChanged(tabData)
  end

  self.collectionTabDescriptor =
  {
    activeTabText = GetString(CC_COLLECTION_TAB),
    menuType = CC_TAB_MENU_COLLECTIBLE
  }
  local collectionTabData = {
    activeTabText = GetString(CC_COLLECTION_TAB),
    descriptor  = self.collectionTabDescriptor,
    normal = "EsoUI/Art/treeicons/collection_indexicon_styleparlor_up.dds",
    pressed = "EsoUI/Art/treeicons/collection_indexicon_styleparlor_down.dds",
    callback = PlayerDrivenCallback,
  }

  self.emoteTabDescriptor =
  {
    activeTabText = GetString(CC_EMOTE_TAB),
    menuType = CC_TAB_MENU_EMOTE
  }
  local emoteTabData = {
    activeTabText = GetString(CC_EMOTE_TAB),
    descriptor  = self.emoteTabDescriptor,
    normal = "EsoUI/Art/treeicons/tutorial_idexicon_emotes_up.dds",
    pressed = "EsoUI/Art/treeicons/tutorial_idexicon_emotes_down.dds",
    callback = PlayerDrivenCallback,
  }

  self.mementoTabDescriptor =
  {
    activeTabText = GetString(CC_MEMENTO_TAB),
    menuType = CC_TAB_MENU_MEMENTO
  }
  local mementoTabData = {
    activeTabText = GetString(CC_MEMENTO_TAB),
    descriptor  = self.mementoTabDescriptor,
    normal = "EsoUI/Art/treeicons/achievements_indexicon_collections_up.dds",
    pressed = "EsoUI/Art/treeicons/achievements_indexicon_collections_down.dds",
    callback = PlayerDrivenCallback,
  }

  local tabData = {
    initialButtonAnchorPoint = RIGHT,
    buttonPadding = -5,
  }

  -- Set the data
  CC_TabFilter_SetData(self.tabs, tabData)

  -- Add a button
  CC_TabFilter_AddButton(self.tabs, emoteTabData)
  CC_TabFilter_AddButton(self.tabs, mementoTabData)
  CC_TabFilter_AddButton(self.tabs, collectionTabData)

  -- Select the first one
  CC_TabFilter_SelectDescriptor(self.tabs, self.collectionTabDescriptor)
end

function CCUICollection:CreateCollectionPanelFilter()

  self.collectionFilterControl = WM:GetControlByName("CC_Panel_CollectionCollectiblesFilter")

  local function OnFilterChanged(filterType)
    self:OpenCollectionPanel(filterType, false)
  end

  local tabData = {
    initialButtonAnchorPoint = LEFT,
    buttonPadding = -4,
    normalSize    = 30,
    downSize      = 40,
  }

  -- Set the data
  CC_TabFilter_SetData(self.collectionFilterControl, tabData)

  self.collectionFilters = {}

  for i=1, #COSMETIC_FILTER_ICONS do

    self.collectionFilters[i] = {
      activeTabText = COSMETIC_FILTER_ICONS[i][1],
      descriptor    = COSMETIC_FILTER_ICONS[i][1],
      normal        = COSMETIC_FILTER_ICONS[i][2],
      pressed       = COSMETIC_FILTER_ICONS[i][3],
      callback = function(...) OnFilterChanged(i) end,
    }

    CC_TabFilter_AddButton(self.collectionFilterControl, self.collectionFilters[i])
  end

  CC_TabFilter_UpdateButtons(self.collectionFilterControl)
  CC_TabFilter_SelectDescriptor(self.collectionFilterControl, self.collectionFilters[1].descriptor)

  self.collectionActiveFilter = CC_COLLECTION_FILTER_ALL
end

function CCUICollection:CreateCollectionPanelLists()
  
  local scrollChildTemp = WM:GetControlByName("CC_Panel_CollectionCollectiblesContainerScrollChild")
  local boxControl = WM:CreateControl("CC_Panel_CollectionCollectiblesContainerBox", scrollChildTemp)
  boxControl:SetResizeToFitDescendents(true)
  boxControl:SetAnchor(TOPLEFT, nil, TOPLEFT, 0, 0)
  boxControl:SetAnchor(TOPRIGHT, nil, TOPRIGHT, 0, 0)

  local parentWidth, _ = scrollChildTemp:GetDimensions()
  local parentControl = boxControl

  self.collectionEmptyBox = WM:CreateControl("CC_Panel_CollectionCollectiblesContainer_Empty", boxControl)
  self.collectionEmptyBox:SetAnchor(TOPLEFT, boxControl, TOPLEFT, 0, 0)

  -- We start at two since, all is not used as a type
  for i = 2, #COSMETIC_FILTER_ICONS do

    -- Name of this collection type
    local collectionType = COSMETIC_FILTER_ICONS[i][1]

    -- Get the last child
    local relativeControl = parentControl:GetChild(parentControl:GetNumChildren())

    local controlName = string.format("CC_Favs_%s", collectionType)
    local control = WM:CreateControlFromVirtual(controlName, boxControl, "CC_CollectionList")

    local controlData = {
      title = collectionType,
      bullet = COSMETIC_FILTER_ICONS[i][2],
      showBullet = true,
      isGrid = true,
      width = 350,
      paddingX = 15,
      paddingY = 35,
      itemWidth = 77,
      itemHeight = 77,
    }

    CC_CollectionListTemplate_SetData(control, controlData)
    CC_CollectionListTemplate_UpdateLayout(control)

    control:ClearAnchors()
    control:SetAnchor(TOPLEFT, relativeControl, BOTTOMLEFT, 0, 0)

    -- Store list
    self.collectionLists[i] = control
  end
end

function CCUICollection:BuildCollectionPanelLists()

  local function OnDragDrop()
    CC_CALLBACK_MANAGER:FireCallbacks(CC_ON_DRAG_DROP)
    EVENT_MANAGER:UnregisterForEvent("CC_ON_CURSOR_DROPPED", EVENT_CURSOR_DROPPED)
  end

  local function OnDragStart(collectibleId)
    CallSecureProtected("PickupCollectible", collectibleId)
    CC_CALLBACK_MANAGER:FireCallbacks(CC_ON_DRAG_START, CC_DRAG_TYPE_COLLECTIBLE, collectibleId)
    EVENT_MANAGER:RegisterForEvent("CC_ON_CURSOR_DROPPED", EVENT_CURSOR_DROPPED, OnDragDrop)
  end

  local function OnDoubleClick(collectionList, colId)
    local collData = ZO_COLLECTIBLE_DATA_MANAGER:GetCollectibleDataById(colId)
    collData:Use()
  end

  local function OnRightClick(colId)

    ClearMenu()

    local collData = ZO_COLLECTIBLE_DATA_MANAGER:GetCollectibleDataById(colId)
    if collData:IsActive() then
      AddCustomMenuItem("Put Away", function()
        collData:Use()
      end)
    else
      AddCustomMenuItem("Set Active", function()
        collData:Use()
      end)
    end



    AddCustomMenuItem("Link in Chat", function ()
      ZO_LinkHandler_InsertLink(zo_strformat(SI_TOOLTIP_ITEM_NAME, GetCollectibleLink(colId)))
    end)
    ShowMenu()
  end

  local function EnableCollectionList(anchor, filterType)

    local collectionList = self.collectionLists[filterType]

    if not collectionList then return end

    collectionList:ClearAnchors()
    collectionList:SetAnchor(TOPLEFT, anchor, BOTTOMLEFT, 0, 10)
    collectionList:SetHidden(false)

    local collectionData = COLLECTIBLE_CATAGORIES_APPEARANCE[filterType-2]
    local collectionType = collectionData[1]

    -- List of collectibles from this type
    local ownedCollectibles = CC_HELPER:GetSubCollectibleByType(collectionType)

    if ownedCollectibles then

      for i = 1, #ownedCollectibles do

        local collectilbeId = ownedCollectibles[i]
        local collectibleName = GetCollectibleName(collectilbeId)

        -- Only intrested in the items we search for
        if CC_StringMatch(collectibleName, self.search) then

          local itemData = {
            descriptor = string.format('col_%d', collectilbeId),
            texture  = GetCollectibleIcon(collectilbeId),
            itemLink = GetCollectibleLink(collectilbeId),
            onDragCallback = function(...) OnDragStart(collectilbeId)  end,
            doubleClickCallback = function() OnDoubleClick(collectionList, collectilbeId) end,
            rightClickCallback = function() OnRightClick(collectilbeId) end
          }

          CC_CollectionListTemplate_AddItem(collectionList, itemData)
        end
      end
    end

    CC_CollectionListTemplate_UpdateLayout(collectionList)

    -- Check the worn items
    if self.collectionCurrentEquiped[collectionType] ~= 0 then
      CC_CollectionListTemplate_SetState(collectionList, string.format('col_%d', self.collectionCurrentEquiped[collectionType]), CSTATE_CHECKED, true)
    end

    if self.collectionProfileEquiped[collectionType] ~= 0 and self.collectionProfileEquiped[collectionType] ~= nil then
      CC_CollectionListTemplate_SetState(collectionList, string.format('col_%d', self.collectionProfileEquiped[collectionType]), CSTATE_STARED, true)
    end
  end

  -- Clear the lists contents
  self:ResetCollectionPanels()

  -- Check if all filters are active
  local isAll = self.collectionActiveFilter == CC_COLLECTION_FILTER_ALL

  if isAll then

    local relativeAnchor = self.collectionEmptyBox
    for i=2, #COSMETIC_FILTER_ICONS do
      EnableCollectionList(relativeAnchor, i)
      relativeAnchor = self.collectionLists[i]
    end

  else
    local filterType = self.collectionActiveFilter
    local anchor     = self.collectionEmptyBox
    EnableCollectionList(anchor, filterType)
  end
end

function CCUICollection:CreateEmotePanel()

  local scrollChildTemp = WM:GetControlByName("CC_Panel_CollectionEmotesContainerScrollChild")
  local father = WM:GetControlByName("CC_Panel_CollectionEmotesContainer")

  local boxControl = WM:CreateControl("CC_Panel_CollectionEmotesContainerBox", scrollChildTemp)
  boxControl:SetResizeToFitDescendents(true)
  boxControl:SetDimensionConstraints(father:GetWidth(), 100, 500, 0)
  boxControl:SetAnchor(TOPLEFT, nil, TOPLEFT, 0, 0)

  local listData = {
    title = "Emotes",
    isGrid = false,
    width = 350,
    paddingX = 15,
    paddingY = 35,
    itemWidth =  350,
    itemHeight =  80,
    buttonTemplate = "CC_EmoteTemplate"
  }

  -- Create a CC list
  local controlName = "CC_Emote_List"
  self.emoteList = WM:CreateControlFromVirtual(controlName, boxControl, "CC_CollectionList")

  CC_CollectionListTemplate_SetData(self.emoteList, listData)
  CC_CollectionListTemplate_UpdateLayout(self.emoteList)

  self.emoteList:ClearAnchors()
  self.emoteList:SetAnchor(TOPLEFT, nil, TOPLEFT, 0, 10)
end

function CCUICollection:BuildEmotePanel()

  local function OnDragDrop()
    CC_CALLBACK_MANAGER:FireCallbacks(CC_ON_DRAG_DROP)
    EVENT_MANAGER:UnregisterForEvent("CC_ON_CURSOR_DROPPED", EVENT_CURSOR_DROPPED)
  end

  local function OnDragStart(emoteId)
    CallSecureProtected("PickupEmoteById", emoteId)
    CC_CALLBACK_MANAGER:FireCallbacks(CC_ON_DRAG_START, CC_DRAG_TYPE_EMOTE, emoteId)
    EVENT_MANAGER:RegisterForEvent("CC_ON_CURSOR_DROPPED", EVENT_CURSOR_DROPPED, OnDragDrop)
  end

  -- Clear the contents of the emotes list
  CC_CollectionListTemplate_Reset(self.emoteList)

  for i = 1, GetNumEmotes() do

    local slashName, emoteCategory, emoteId, displayName, _ = GetEmoteInfo(i)

    local emoteCollectibleId =  GetEmoteCollectibleId(i)
    local isLocked = true

    -- Oh, no... This might be locked
    if emoteCollectibleId then
      local collectibleData = ZO_COLLECTIBLE_DATA_MANAGER:GetCollectibleDataById(emoteCollectibleId)
      if collectibleData:IsUnlocked() then
        isLocked = false
      end
    else
      isLocked = false
    end

    -- Only intrested in the items we search for
    if (CC_StringMatch(slashName, self.search) or CC_StringMatch(displayName, self.search)) and not isLocked then

      local icon = PLAYER_EMOTE_MANAGER:GetSharedEmoteIconForCategory(emoteCategory)

      local emoteData = {
        texture  = icon,
        title = slashName,
        titleSize = 20,
        titleColor = { 1, 1, 1, 1 },
        onDragCallback = function(...) OnDragStart(emoteId) end,
      }

      CC_CollectionListTemplate_AddItem(self.emoteList, emoteData)
    end
  end

  CC_CollectionListTemplate_UpdateLayout(self.emoteList)
end

function CCUICollection:CreateMementoPanelFilter()

  local filterControl = WM:GetControlByName("CC_Panel_CollectionMementosFilter")

  local function OnFilterChanged(filterType)
    self.mementoActiveFilter = filterType
    self:BuildMementoPanelLists()
  end

  local tabData = {
    initialButtonAnchorPoint = LEFT,
    buttonPadding = -4,
    normalSize    = 30,
    downSize      = 40,
  }

  -- Set the data
  CC_TabFilter_SetData(filterControl, tabData)

  self.mementoFilters = {}

  for i = 1, #MEMENTO_FILTER_ICONS do

    self.mementoFilters[i] = {
      activeTabText = MEMENTO_FILTER_ICONS[i][1],
      descriptor    = MEMENTO_FILTER_ICONS[i][1],
      normal        = MEMENTO_FILTER_ICONS[i][2],
      pressed       = MEMENTO_FILTER_ICONS[i][3],
      callback = function(...) OnFilterChanged(i) end,
    }

    CC_TabFilter_AddButton(filterControl, self.mementoFilters[i])
  end

  CC_TabFilter_UpdateButtons(filterControl)
  CC_TabFilter_SelectDescriptor(filterControl, self.mementoFilters[1].descriptor)

  self.mementoActiveFilter = CC_COLLECTION_FILTER_ALL
end

function CCUICollection:CreateMementoPanelLists()

  local scrollChildTemp = WM:GetControlByName("CC_Panel_CollectionMementosContainerScrollChild")
  local father = WM:GetControlByName("CC_Panel_CollectionMementosContainer") 

  local boxControl = WM:CreateControl("CC_Panel_CollectionMementosContainerBox", scrollChildTemp)
  boxControl:SetResizeToFitDescendents(true)
  boxControl:SetAnchor(TOPLEFT, nil, TOPLEFT, 0, 0)
  boxControl:SetAnchor(TOPRIGHT, nil, TOPRIGHT, 0, 0)

  self.mementoEmptyBox = WM:CreateControl("CC_Panel_CollectionMementosContainer_Empty", boxControl)
  self.mementoEmptyBox:SetAnchor(TOPLEFT, boxControl, TOPLEFT, 0, 0)

  for i = 2, #MEMENTO_FILTER_ICONS do
    local mementoType = MEMENTO_FILTER_ICONS[i][1]

    local relativeControl = boxControl:GetChild(boxControl:GetNumChildren())

    local controlName = string.format("CC_Favs_memento_%s", mementoType)
    local control = WM:CreateControlFromVirtual(controlName, boxControl, "CC_CollectionList")

    local listData = {
      title = mementoType,
      bullet = MEMENTO_FILTER_ICONS[i][2],
      showBullet = true,
      isGrid = true,
      width = 350,
      paddingX = 15,
      paddingY = 35,
      itemWidth = 77,
      itemHeight = 77,
    }

    CC_CollectionListTemplate_SetData(control, listData)
    CC_CollectionListTemplate_UpdateLayout(control)

    control:ClearAnchors()
    control:SetAnchor(TOPLEFT, relativeControl, BOTTOMLEFT, 0, 0)

    self.mementoLists[i] = control
  end


  --[[
  -- Create a CC list
  local controlName = "CC_Memento_List"
  self.mementoList = WM:CreateControlFromVirtual(controlName, boxControl, "CC_CollectionList")

  CC_CollectionListTemplate_SetData(self.mementoList, listData)
  CC_CollectionListTemplate_UpdateLayout(self.mementoList)

  self.mementoList:ClearAnchors()
  self.mementoList:SetAnchor(TOPLEFT, nil, TOPLEFT, 0, 10)
  ]]
end

function CCUICollection:BuildMementoPanelLists()


  -- Companion cat type : 27
  -- Memento Type : 2

  local function OnDragDrop()
    CC_CALLBACK_MANAGER:FireCallbacks(CC_ON_DRAG_DROP)
    EVENT_MANAGER:UnregisterForEvent("CC_ON_CURSOR_DROPPED", EVENT_CURSOR_DROPPED)
  end

  local function OnDragStart(collectibleId, dragType)
    CallSecureProtected("PickupCollectible", collectibleId)
    CC_CALLBACK_MANAGER:FireCallbacks(CC_ON_DRAG_START, dragType, collectibleId)
    EVENT_MANAGER:RegisterForEvent("CC_ON_CURSOR_DROPPED", EVENT_CURSOR_DROPPED, OnDragDrop)
  end

  local function OnDoubleClick(collectibleId)
    local collData = ZO_COLLECTIBLE_DATA_MANAGER:GetCollectibleDataById(collectibleId)
    collData:Use()
  end

  local function OnRightClick(collectibleId)
    local collData = ZO_COLLECTIBLE_DATA_MANAGER:GetCollectibleDataById(collectibleId)

    ClearMenu()
    AddCustomMenuItem("Use", function()
      collData:Use()
    end)
    AddCustomMenuItem("Link in Chat", function ()
      ZO_LinkHandler_InsertLink(zo_strformat(SI_TOOLTIP_ITEM_NAME, GetCollectibleLink(collectibleId)))
    end)
    ShowMenu()
  end

  local function ResetMementoLists()
    for i = 2, #MEMENTO_FILTER_ICONS do
      local control = self.mementoLists[i]
      if control then
        control:SetHidden(true)
        CC_CollectionListTemplate_Reset(control)
      end
    end
  end

  local function EnableMementoList(anchor, filterType)

    local function GetCollectilbeData()
      if filterType == CC_MEMENTO_FILTER_ALLIES then
        return CC_HELPER:GetAllieCollectibles()
      elseif filterType == CC_MEMENTO_FILTER_MEMENTO then
        return CC_HELPER:GetMementoCollectibles()
      elseif filterType == CC_MEMENTO_FILTER_TOOLS then
        return CC_HELPER:GetToolCollectibles()
      end
    end

    local function GetDragType()
      if filterType == CC_MEMENTO_FILTER_ALLIES then
        return CC_DRAG_TYPE_COMPANION
      elseif filterType == CC_MEMENTO_FILTER_MEMENTO then
        return CC_DRAG_TYPE_MEMENTO
      elseif filterType == CC_MEMENTO_FILTER_TOOLS then
        return CC_DRAG_TYPE_TOOL
      end
    end

    local mementoList = self.mementoLists[filterType]

    if not mementoList then return end

    mementoList:ClearAnchors()
    mementoList:SetAnchor(TOPLEFT, anchor, BOTTOMLEFT, 0, 10)
    mementoList:SetHidden(false)

    local ownedMementos = GetCollectilbeData()
    local dragType = GetDragType()

    if ownedMementos then
      for i = 1, #ownedMementos do

        local collectilbeId = ownedMementos[i]
        local collectibleName = GetCollectibleName(collectilbeId)

            -- Only intrested in the items we search for
        if CC_StringMatch(collectibleName, self.search) then

          local itemData = {
            texture  = GetCollectibleIcon(collectilbeId),
            itemLink = GetCollectibleLink(collectilbeId),
            onDragCallback = function(...) OnDragStart(collectilbeId, dragType)  end,
            doubleClickCallback = function(...) OnDoubleClick(collectilbeId) end,
            rightClickCallback = function() OnRightClick(collectilbeId) end
          }

          CC_CollectionListTemplate_AddItem(mementoList, itemData)
        end
        
      end
    end

    CC_CollectionListTemplate_UpdateLayout(mementoList)
  end

  ResetMementoLists()

  local isAll = self.mementoActiveFilter == CC_MEMENTO_FILTER_ALL

  if isAll then
    local relativeAnchor = self.mementoEmptyBox

    for i = 2, #MEMENTO_FILTER_ICONS do
      EnableMementoList(relativeAnchor, i)
      relativeAnchor = self.mementoLists[i]
    end
  
  else
    local filterType = self.mementoActiveFilter
    local anchor = self.mementoEmptyBox
    EnableMementoList(anchor, filterType)
  end

  --[[

  -- Clear the contents of the emotes list
  CC_CollectionListTemplate_Reset(self.mementoList)

  local COMPANION_TOOL_TYPE_INDEX = 27
  local mementos = CC.GetCollectiblesByType(COLLECTIBLE_CATEGORY_TYPE_MEMENTO)

  for i = 1, #mementos do

    local collectilbeId = mementos[i]
    local collectibleName = GetCollectibleName(collectilbeId)

    -- Only intrested in the items we search for
    if CC_StringMatch(collectibleName, self.search) then

      local itemData = {
        texture  = GetCollectibleIcon(collectilbeId),
        itemLink = GetCollectibleLink(collectilbeId),
        onDragCallback = function(...) OnDragStart(collectilbeId)  end,
      }

      CC_CollectionListTemplate_AddItem(self.mementoList, itemData)
    end
  end
  ]]
end

function CCUICollection:RegisterEvents()

  local function OnSearchUpdate(other)
    self.search = other:GetText()
    self:UpdatePanels()
  end

  local searchField = WM:GetControlByName("CC_Panel_CollectionSearchBox")
  searchField:SetHandler("OnTextChanged", function(self)
    ZO_CollectionsBook_OnSearchTextChanged(self)
    OnSearchUpdate(self)
  end)

  local function OnCollectibleEquipAttempt(_, result, isAttemptingActivation)

    if result == COLLECTIBLE_USAGE_BLOCK_REASON_NOT_BLOCKED then

      zo_callLater(function()  
        for i, item in pairs(COLLECTIBLE_CATAGORIES_APPEARANCE) do

          local collectionType = item[1]
          local currentActive  = GetActiveCollectibleByType(collectionType)
          local previousActive = self.collectionCurrentEquiped[collectionType]

          if currentActive == 0 then
            CC_CollectionListTemplate_SetState(self.collectionLists[i + 2], string.format('col_%d', previousActive), CSTATE_CHECKED, false)
            self.collectionCurrentEquiped[collectionType] = currentActive
          else
            if currentActive ~= previousActive then
              CC_CollectionListTemplate_SetState(self.collectionLists[i + 2], string.format('col_%d', previousActive), CSTATE_CHECKED, false)
              CC_CollectionListTemplate_SetState(self.collectionLists[i + 2], string.format('col_%d', currentActive),  CSTATE_CHECKED, true)
  
              self.collectionCurrentEquiped[collectionType] = currentActive
            end
          end
        end
      end, 1000)
    end

  end

  local function OnOutfitUpdate()
    local data = CC_UI_MANAGER:GetCurrentProfileData()
    data = data['collectibles']

    for i = 1, #EQUIPED_ICONS do

      local slotType = EQUIPED_ICONS[i][1]
      local slotId = COLLECTIBLE_CATAGORIES_APPEARANCE[i - 1][1]

      -- Disable the current acctive
      if self.collectionProfileEquiped[slotId] ~= 0 and self.collectionProfileEquiped[slotId] ~= nil then
        CC_CollectionListTemplate_SetState(self.collectionLists[i + 1], string.format('col_%d', self.collectionProfileEquiped[slotId]),  CSTATE_STARED, false)
        self.collectionProfileEquiped[slotId] = 0
      end

      -- Only if there is data here.
      if data then
        local colId = data[slotType]
        if colId then
          CC_CollectionListTemplate_SetState(self.collectionLists[i + 1], string.format('col_%d', colId),  CSTATE_STARED, true)
          self.collectionProfileEquiped[slotId] = colId
        end
      end
    end
  end

  EVENT_MANAGER:RegisterForEvent(CC.name .. 'collectible_equip',  EVENT_COLLECTIBLE_USE_RESULT, OnCollectibleEquipAttempt)

  -- Update collection
  CC_CALLBACK_MANAGER:RegisterCallback(CC_ON_PROFILE_CHANGED, OnOutfitUpdate)
  CC_CALLBACK_MANAGER:RegisterCallback(CC_ON_CHANGES_SAVED, OnOutfitUpdate)
  CC_CALLBACK_MANAGER:RegisterCallback(CC_ON_DRAG_DROP, OnOutfitUpdate)
  CC_CALLBACK_MANAGER:RegisterCallback(CC_ON_COLLECTIBLE_RIGHT_CLICKED, OnOutfitUpdate)
end

function CCUICollection:UpdatePanels()

  local currentType = self.currentTabDescriptor.menuType

  if currentType == CC_TAB_MENU_COLLECTIBLE then
    self:BuildCollectionPanelLists()
  elseif currentType == CC_TAB_MENU_EMOTE then
    self:BuildEmotePanel()
  elseif currentType == CC_TAB_MENU_MEMENTO then
    self:BuildMementoPanelLists()
  end
end

function CCUICollection:OnTabFilterChanged(tabData)

  self.activeTab:SetText(tabData.activeTabText)

  self.currentTabDescriptor = tabData.descriptor

  -- Display the correct panel
  self:ToggleMenuPanel()
end

function CCUICollection:ToggleMenuPanel()

  if self.currentTabControl ~= nil then
    self.currentTabControl:SetHidden(true)
  end

  -- Display the correct panel
  local newPanel = self.panels[self.currentTabDescriptor.menuType]

  if newPanel then
    newPanel:SetHidden(false)
    self.currentTabControl = newPanel
  end

  -- Search can be reset
  self:UpdatePanels()
end

function CCUICollection:ResetCollectionPanels()
  for key, _ in pairs(COSMETIC_FILTER_ICONS) do
    if key ~= CC_COLLECTION_FILTER_ALL then
      local control = self.collectionLists[key]
      if control then
        control:SetHidden(true)
        CC_CollectionListTemplate_Reset(self.collectionLists[key])
      end
    end
  end
end

-- Open a speecific window type
function CCUICollection:OpenCollectionPanel(collectionType, updateFilter)
  if self.collectionFilters[collectionType] ~= nil or collectionType == CC_COLLECTION_FILTER_ALL then

    if updateFilter then
      -- Update filter
      CC_TabFilter_UpdateButtons(self.collectionFilterControl)
      CC_TabFilter_SelectDescriptor(self.collectionFilterControl, self.collectionFilters[collectionType].descriptor)
    end

    if self.currentTabDescriptor ~= self.collectionTabDescriptor then
      CC_TabFilter_SelectDescriptor(self.tabs, self.collectionTabDescriptor)
    end
    
    -- Update panel
    self.collectionActiveFilter = collectionType
    self:BuildCollectionPanelLists()
  end
end