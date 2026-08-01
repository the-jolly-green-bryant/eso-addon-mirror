--[[
  This file is part of Aenathel's Keybinds, licensed under The MIT License.
  See the LICENSE file in the root of this project for more information.
--]]

AenathelsKeybinds = {}

local AenathelsKeybinds = AenathelsKeybinds

AenathelsKeybinds.id = "AEKB"
AenathelsKeybinds.name = "AenathelsKeybinds"
AenathelsKeybinds.author = "Aenathel (PC-EU)"
AenathelsKeybinds.title = "Aenathel's Keybinds"

AenathelsKeybinds.defaults = {
}

-- Dependencies
local chat = LibChatMessage(AenathelsKeybinds.title, AenathelsKeybinds.id)
local LAM = LibAddonMenu2

-- ESO UI constants
local EVENT_MANAGER = EVENT_MANAGER
local KEYBINDING_MANAGER = KEYBINDING_MANAGER
local SCENE_MANAGER = SCENE_MANAGER
local SCENE_SHOWN = SCENE_SHOWN
local SOUNDS_NEGATIVE_CLICK = SOUNDS.NEGATIVE_CLICK

-- ESO UI functions
local GetString = GetString
local PlaySound = PlaySound
local ZO_MenuBar_GetSelectedDescriptor = ZO_MenuBar_GetSelectedDescriptor
local ZO_MenuBar_SelectDescriptor = ZO_MenuBar_SelectDescriptor

-- Lua API
local sprintf = string.format
local type = type

function AenathelsKeybinds:Initialize()
  -- Enable chording so keybinds can use ctrl/alt/shift/command
  KEYBINDING_MANAGER:SetChordingAlwaysEnabled(true)

  self.savedVars = ZO_SavedVars:NewAccountWide("AenathelsKeybinds_SavedVariables", 1, nil, self.defaults)

  local settingsPanelName = AenathelsKeybinds.name .. "SettingsPanel"

  LAM:RegisterAddonPanel(settingsPanelName, {
    type = "panel",
    name = AenathelsKeybinds.title,
    author = AenathelsKeybinds.author,
    version = GetString(AEKB_ADDON_VERSION),
    website = GetString(AEKB_ADDON_WEBSITE),
  })

  LAM:RegisterOptionControls(settingsPanelName, {
    {
      type = "description",
      text = GetString(AEKB_SETTINGS_DESCRIPTION),
    },
    {
      type = "button",
      name = GetString(AEKB_SETTINGS_OPEN_CONTROLS),
      func = function() AenathelsKeybinds.OpenKeybindings(true) end,
    }
  })
end

function AenathelsKeybinds.PrintErrorWithSound(message)
  if type(message) == "number" then
    message = GetString(message)
  end

  chat:Print(sprintf("|cFF0000%s|r", message))
  PlaySound(SOUNDS_NEGATIVE_CLICK)
end

function AenathelsKeybinds.OpenAddOnSettings()
  local function openAddonSettingsMenu()
    local gameMenu = ZO_GameMenu_InGame.gameMenu
    local settingsTitle = GetString(SI_GAME_MENU_SETTINGS)
    local settingsMenu = gameMenu.headerControls[settingsTitle]

    if settingsMenu then
      local children = settingsMenu:GetChildren()
      local panelName = LAM.util.L["PANEL_NAME"]

      for i = 1, (children and #children or 0) do
        local childNode = children[i]

        if childNode then
          local data = childNode:GetData()

          if data and data.name == panelName then
            childNode:GetTree():SelectNode(childNode)
            break
          end
        end
      end
    end
  end

  if SCENE_MANAGER:GetScene("gameMenuInGame"):GetState() == SCENE_SHOWN then
    openAddonSettingsMenu()
  else
    SCENE_MANAGER:CallWhen("gameMenuInGame", SCENE_SHOWN, openAddonSettingsMenu)
    SCENE_MANAGER:Show("gameMenuInGame")
  end
end

do
  local addonKeybindings = false

  function AenathelsKeybinds.OpenKeybindings(addons)
    if addons ~= nil then addonKeybindings = addons end

    local function openKeybindingsMenu()
      local gameMenu = ZO_GameMenu_InGame.gameMenu
      local controlsTitle = GetString(SI_GAME_MENU_CONTROLS)
      local controlsMenu = gameMenu.headerControls[controlsTitle]

      if controlsMenu then
        local children = controlsMenu:GetChildren()
        local childNode = children[addonKeybindings and #children or 1]

        childNode:GetTree():SelectNode(childNode)
      end
    end

    if SCENE_MANAGER:GetScene("gameMenuInGame"):GetState() == SCENE_SHOWN then
      if addons == nil then addonKeybindings = not addonKeybindings end

      openKeybindingsMenu()
    else
      SCENE_MANAGER:CallWhen("gameMenuInGame", SCENE_SHOWN, openKeybindingsMenu)
      SCENE_MANAGER:Show("gameMenuInGame")
    end
  end
end

do
  -- Console support is currently not a priority.
  local MAIN_MENU_KEYBOARD = MAIN_MENU_KEYBOARD

  local TRAVERSAL_ORDER_NEXT = 1
  local TRAVERSAL_ORDER_PREVIOUS = 2

  local REVERSE_TRAVERSAL_ORDER = {
    [TRAVERSAL_ORDER_NEXT] = TRAVERSAL_ORDER_PREVIOUS,
    [TRAVERSAL_ORDER_PREVIOUS] = TRAVERSAL_ORDER_NEXT,
  }

  local function GetNextIndex(index, length, traversalOrder)
    if traversalOrder == TRAVERSAL_ORDER_NEXT then
      if index == length then
        return 1
      else
        return index + 1
      end
    elseif traversalOrder == TRAVERSAL_ORDER_PREVIOUS then
      if index == 1 then
        return length
      else
        return index - 1
      end
    else
      error("Invalid traversal order")
    end
  end

  local MENU_BAR_BUTTON_CONTROL_INDEX = 1
  local MENU_BAR_BUTTON_DESCRIPTOR_INDEX = 3

  local function GetMenuBarButtons(menuBar)
    return menuBar.m_object.m_buttons
  end

  local function GetMenuBarButtonData(button)
    return button[MENU_BAR_BUTTON_CONTROL_INDEX].m_object.m_buttonData
  end

  local function GetCurrentMenuBarButtonIndex(menuBar)
    local buttons = GetMenuBarButtons(menuBar)
    local currentDescriptor = ZO_MenuBar_GetSelectedDescriptor(menuBar)

    for index, button in ipairs(buttons) do
      if button[MENU_BAR_BUTTON_DESCRIPTOR_INDEX] == currentDescriptor then
        return index
      end
    end

    return nil
  end

  local function IsMenuBarButtonVisible(button)
    local buttonData = GetMenuBarButtonData(button)

    if buttonData.hidden then return false end

    return not buttonData.visible or buttonData.visible(buttonData)
  end

  local function GetNextMenuBarDescriptor(menuBar, traversalOrder)
    local currentButtonIndex = GetCurrentMenuBarButtonIndex(menuBar)
    if not currentButtonIndex then return end

    local buttons = GetMenuBarButtons(menuBar)

    local buttonIndex = currentButtonIndex

    repeat
      buttonIndex = GetNextIndex(buttonIndex, #buttons, traversalOrder)

      local button = buttons[buttonIndex]

      if IsMenuBarButtonVisible(button) then
        return button[MENU_BAR_BUTTON_DESCRIPTOR_INDEX]
      end
    until (buttonIndex == currentButtonIndex)

    return nil
  end

  local function SelectNextMenuBarButton(menuBar, traversalOrder)
    local descriptor = GetNextMenuBarDescriptor(menuBar, traversalOrder)
    if descriptor then
      ZO_MenuBar_SelectDescriptor(menuBar, descriptor)
    end
  end

  local function GetSceneGroupMenuBarIconData(sceneGroupName)
    return MAIN_MENU_KEYBOARD.sceneGroupInfo[sceneGroupName].menuBarIconData
  end

  local function GetCurrentMenuBarIconDataIndex(sceneGroupName)
    local sceneGroup = SCENE_MANAGER:GetSceneGroup(sceneGroupName)
    local sceneName = sceneGroup:GetSceneName(sceneGroup.activeScene)

    local menuBarIconData = GetSceneGroupMenuBarIconData(sceneGroupName)

    for i = 1, #menuBarIconData do
      if menuBarIconData[i].descriptor == sceneName then
        return i
      end
    end

    return nil
  end

  local function GetNextSceneName(sceneGroupName, traversalOrder)
    local currentIconIndex = GetCurrentMenuBarIconDataIndex(sceneGroupName)

    local iconIndex = currentIconIndex
    local menuBarIconData = GetSceneGroupMenuBarIconData(sceneGroupName)

    repeat
      iconIndex = GetNextIndex(iconIndex, #menuBarIconData, traversalOrder)

      local iconData = menuBarIconData[iconIndex]

      if iconData.visible == nil or iconData.visible() then
        return iconData.descriptor
      end
    until (iconIndex == currentIconIndex)

    return nil
  end

  function AenathelsKeybinds.ToggleSceneGroupTab(sceneGroupName, sceneName)
    if SCENE_MANAGER:IsShowing(sceneName) then
      SCENE_MANAGER:ShowBaseScene()
    else
      MAIN_MENU_KEYBOARD:ShowSceneGroup(sceneGroupName, sceneName)
    end
  end

  local function ToggleMainMenuCategoryTab(menuBar, sceneName, category, descriptor)
    if SCENE_MANAGER:IsShowing(sceneName) then
      local currentDescriptor = ZO_MenuBar_GetSelectedDescriptor(menuBar)

      if currentDescriptor == descriptor then
        -- Panel is open and requested tab is selected, so toggle the
        -- category, which ends up closing the panel.
        MAIN_MENU_KEYBOARD:ToggleCategory(category)
      else
        -- Panel is open, but requested tab is not selected, so just
        -- select the right tab and do nothing further.
        ZO_MenuBar_SelectDescriptor(menuBar, descriptor)
      end
    else
      -- Panel is not open, so open it and then select the right fragment.
      -- This approach prevents a bug where the scene will fail to initialize
      -- and therefore ends up being empty, which is rather confusing.
      SCENE_MANAGER:CallWhen(sceneName, SCENE_SHOWN, function() ZO_MenuBar_SelectDescriptor(menuBar, descriptor) end)
      MAIN_MENU_KEYBOARD:ShowCategory(category)
    end
  end

  local mainMenuCategoryData = {
    [MENU_CATEGORY_INVENTORY] = {
      menuBar = ZO_PlayerInventoryMenuBar,
      sceneName = "inventory",
    },
    [MENU_CATEGORY_MAP] = {
      menuBar = ZO_WorldMapInfoMenuBar,
      sceneName = "worldMap",
    },
  }

  function AenathelsKeybinds.ToggleMainMenuCategoryTab(category, tab)
    local data = mainMenuCategoryData[category]
    if not data then return end

    ToggleMainMenuCategoryTab(data.menuBar, data.sceneName, category, tab)
  end

  local menuBarButtonCategories = {
    [MENU_CATEGORY_MAP] = ZO_WorldMapInfoMenuBar,
    [MENU_CATEGORY_INVENTORY] = ZO_PlayerInventoryMenuBar,
  }

  local function TryShowNextTabUsingSceneGroup(traversalOrder)
    local sceneGroupName = MAIN_MENU_KEYBOARD.sceneShowGroupName
    if SCENE_MANAGER:IsSceneGroupShowing(sceneGroupName) then
      local sceneName = GetNextSceneName(sceneGroupName, traversalOrder)
      if sceneName then
        MAIN_MENU_KEYBOARD:ShowSceneGroup(sceneGroupName, sceneName)
        return true
      end
    end

    return false
  end

  local function TryShowNextTabUsingCategory(traversalOrder)
    local menuBar = menuBarButtonCategories[MAIN_MENU_KEYBOARD.lastCategory]
    if menuBar then
      SelectNextMenuBarButton(menuBar, traversalOrder)
      return true
    else
      return false
    end
  end

  local sceneMenuBars = {
    alchemy = ZO_AlchemyTopLevelModeMenuBar,
    bank = ZO_PlayerBankMenuBar,
    enchanting = ZO_EnchantingTopLevelModeMenuBar,
    fence_keyboard = ZO_Fence_Keyboard_WindowMenuBar,
    guildBank = ZO_GuildBankMenuBar,
    houseBank = ZO_HouseBankMenuBar,
    provisioner = ZO_ProvisionerTopLevelTabs,
    -- Also used for clothing, jewelry crafting, and woodworking scenes.
    smithing = ZO_SmithingTopLevelModeMenuBar,
    store = ZO_StoreWindowMenuBar,
    tradinghouse = ZO_TradingHouseMenuBar,
  }

  local function TryShowNextTabUsingMenuBar(traversalOrder)
    local sceneName = SCENE_MANAGER:GetCurrentSceneName()
    local menuBar = sceneMenuBars[sceneName]
    if not menuBar then return false end

    local descriptor = GetNextMenuBarDescriptor(menuBar, traversalOrder)
    ZO_MenuBar_SelectDescriptor(menuBar, descriptor)

    return true
  end

  local CHAMPION_PERKS = CHAMPION_PERKS

  local specialSceneHandlers = {
    championPerks = function(traversalOrder)
      if CHAMPION_PERKS:HasChosenConstellation() then
        if traversalOrder == TRAVERSAL_ORDER_NEXT then
          CHAMPION_PERKS:CycleToRightNode()
        elseif traversalOrder == TRAVERSAL_ORDER_PREVIOUS then
          CHAMPION_PERKS:CycleToLeftNode()
        else
          error("Invalid traversal order")
        end
      end

      return true
    end,
  }

  local function TryShowNextTabUsingScene(traversalOrder)
    local sceneName = SCENE_MANAGER:GetCurrentSceneName()
    local handler = specialSceneHandlers[sceneName]
    if not handler then return false end

    return handler(traversalOrder)
  end

  local function ShowNextTab(traversalOrder)
    if MAIN_MENU_KEYBOARD:IsShowing() then
      if TryShowNextTabUsingSceneGroup(traversalOrder) then return end
      if TryShowNextTabUsingCategory(traversalOrder) then return end
    else
      if TryShowNextTabUsingMenuBar(traversalOrder) then return end
      if TryShowNextTabUsingScene(traversalOrder) then return end
    end
  end

  function AenathelsKeybinds.ShowNextTab()
    ShowNextTab(TRAVERSAL_ORDER_NEXT)
  end

  function AenathelsKeybinds.ShowPreviousTab()
    ShowNextTab(TRAVERSAL_ORDER_PREVIOUS)
  end

  local sceneSubMenuBarData = {
    bank = {
      menuBar = ZO_PlayerBankMenuBar,
      submenuBars = {
        [SI_BANK_WITHDRAW] = ZO_PlayerBankTabs,
        [SI_BANK_DEPOSIT] = ZO_PlayerInventoryTabs,
      },
    },
    fence_keyboard = {
      menuBar = ZO_Fence_Keyboard_WindowMenuBar,
      submenuBars = {
        [SI_STORE_MODE_SELL] = ZO_PlayerInventoryTabs,
        [SI_FENCE_LAUNDER_TAB] = ZO_PlayerInventoryTabs,
      },
    },
    guildBank = {
      menuBar = ZO_GuildBankMenuBar,
      submenuBars = {
        [SI_BANK_WITHDRAW] = ZO_GuildBankTabs,
        [SI_BANK_DEPOSIT] = ZO_PlayerInventoryTabs,
      },
    },
    houseBank = {
      menuBar = ZO_HouseBankMenuBar,
      submenuBars = {
        [SI_BANK_WITHDRAW] = ZO_HouseBankTabs,
        [SI_BANK_DEPOSIT] = ZO_PlayerInventoryTabs,
      },
    },
    inventory = {
      menuBar = ZO_PlayerInventoryMenuBar,
      submenuBars = {
        [SI_INVENTORY_MODE_ITEMS] = ZO_PlayerInventoryTabs,
        [SI_INVENTORY_MODE_CRAFT_BAG] = ZO_CraftBagTabs,
        [SI_INVENTORY_MODE_CURRENCY] = ZO_InventoryWalletTabs,
        [SI_INVENTORY_MODE_QUICKSLOTS] = ZO_QuickSlotTabs,
      },
    },
    -- Also used for clothing, jewelry crafting, and woodworking scenes.
    smithing = {
      menuBar = ZO_SmithingTopLevelModeMenuBar,
      submenuBars = {
        [SMITHING_MODE_CREATION] = ZO_SmithingTopLevelCreationPanelTabs,
        [SMITHING_MODE_DECONSTRUCTION] = ZO_SmithingTopLevelDeconstructionPanelInventoryTabs,
        [SMITHING_MODE_IMPROVEMENT] = ZO_SmithingTopLevelImprovementPanelInventoryTabs,
        [SMITHING_MODE_RESEARCH] = ZO_SmithingTopLevelResearchPanelTabs,
      },
    },
    store = {
      menuBar = ZO_StoreWindowMenuBar,
      submenuBars = {
        [SI_STORE_MODE_SELL] = ZO_PlayerInventoryTabs,
        [SI_STORE_MODE_BUY] = ZO_StoreWindowTabs,
      },
    },
    tradinghouse = {
      menuBar = ZO_TradingHouseMenuBar,
      submenuBars = {
        [ZO_TRADING_HOUSE_MODE_SELL] = ZO_PlayerInventoryTabs,
      },
    },
  }

  local function TryShowNextSubtabUsingMenuBar(traversalOrder)
    local sceneName = SCENE_MANAGER:GetCurrentSceneName()
    local data = sceneSubMenuBarData[sceneName]
    if not data then return false end

    local mode = ZO_MenuBar_GetSelectedDescriptor(data.menuBar)
    local submenuBar = data.submenuBars[mode]
    if not submenuBar then return false end

    -- Subtabs are in opposite order
    local reverseTraversalOrder = REVERSE_TRAVERSAL_ORDER[traversalOrder]

    local descriptor = GetNextMenuBarDescriptor(submenuBar, reverseTraversalOrder)
    ZO_MenuBar_SelectDescriptor(submenuBar, descriptor)

    return true
  end

  local function ShowNextSubtab(traversalOrder)
    if TryShowNextSubtabUsingMenuBar(traversalOrder) then return end
  end

  function AenathelsKeybinds.ShowNextSubtab()
    ShowNextSubtab(TRAVERSAL_ORDER_NEXT)
  end

  function AenathelsKeybinds.ShowPreviousSubtab()
    ShowNextSubtab(TRAVERSAL_ORDER_PREVIOUS)
  end
end

do
  local CHAT_SYSTEM = CHAT_SYSTEM

  function AenathelsKeybinds.WriteInChat(channel)
    CHAT_SYSTEM:SetChannel(channel)
    CHAT_SYSTEM.textEntry:Open()
  end
end

do
  local BATTLEGROUND_FINDER_KEYBOARD = BATTLEGROUND_FINDER_KEYBOARD
  local DUNGEON_FINDER_KEYBOARD = DUNGEON_FINDER_KEYBOARD
  local GROUP_LIST_FRAGMENT = GROUP_LIST_FRAGMENT
  local GROUP_MENU_KEYBOARD = GROUP_MENU_KEYBOARD
  local TIMED_ACTIVITIES_FRAGMENT = TIMED_ACTIVITIES_FRAGMENT

  AenathelsKeybinds.GROUP_MENU_CATEGORY_GROUP = "group"
  AenathelsKeybinds.GROUP_MENU_CATEGORY_ENDEAVORS = "endeavors"
  AenathelsKeybinds.GROUP_MENU_CATEGORY_DUNGEON_FINDER = "dungeon_finder"
  AenathelsKeybinds.GROUP_MENU_CATEGORY_BATTLEGROUNDS = "battlegrounds"

  local categoryFragments = {
    [AenathelsKeybinds.GROUP_MENU_CATEGORY_GROUP] = function() return GROUP_LIST_FRAGMENT end,
    [AenathelsKeybinds.GROUP_MENU_CATEGORY_ENDEAVORS] = function() return TIMED_ACTIVITIES_FRAGMENT end,
    [AenathelsKeybinds.GROUP_MENU_CATEGORY_DUNGEON_FINDER] = function() return DUNGEON_FINDER_KEYBOARD:GetFragment() end,
    [AenathelsKeybinds.GROUP_MENU_CATEGORY_BATTLEGROUNDS] = function() return BATTLEGROUND_FINDER_KEYBOARD:GetFragment() end,
  }

  -- TODO: There is a bug (I think) in the ESO UI that causes the wrong node in
  -- the navigation tree to be selected when selecting the Dungeon Finder or
  -- Battlegrounds entries. I think it has something to do with Endeavors
  -- having Daily and Weekly subentries, but I'm not totally sure yet.
  function AenathelsKeybinds.ShowGroupMenuCategory(category)
    local categoryFragment = categoryFragments[category]()

    if SCENE_MANAGER:IsShowing("groupMenuKeyboard") then
      -- Assuming that there will always be a selected node here.
      local nodeData = GROUP_MENU_KEYBOARD.navigationTree:GetSelectedData()

      if nodeData.categoryFragment == categoryFragment then
        SCENE_MANAGER:ShowBaseScene()
      else
        GROUP_MENU_KEYBOARD:SetCurrentCategory(categoryFragment)
      end
    else
      GROUP_MENU_KEYBOARD:SetCategoryOnShow(categoryFragment)
      SCENE_MANAGER:Show("groupMenuKeyboard")
    end
  end
end

do
  local sceneSearchBoxes = {
    achievements = ZO_AchievementsContentsSearchBox,
    collectionsBook = ZO_CollectionsBook_TopLevelSearchBox,
    friendsList = ZO_KeyboardFriendsListSearchBox,
    guildRoster = ZO_GuildRosterSearchBox,
    helpTutorials = ZO_HelpSearchBox,
    itemSetsBook = ZO_ItemSetsBook_Keyboard_TopLevelFiltersSearchBox,
    mailSend = ZO_PlayerInventorySearchBox,
    outfitStylesBook = ZO_OutfitStylesBook_Keyboard_TopLevelSearchBox,
    restyle_station_keyboard = ZO_RestyleStationTopLevel_KeyboardSearchBox,
    guildHistory = "ZO_GuildHistoryVotanSearchBox",
    loreLibrary = "Lorebook_ResearchBox",
    AGS_guilds = "AwesomeGuildStoreGuildsUtilsSearchBox",
    AGS_guildTraders = "AwesomeGuildStoreGuildTradersUtilsSearchBox",
  }

  local function TryGetSceneSearchBox(sceneName)
    local searchBox = sceneSearchBoxes[sceneName]

    return type(searchBox) == "string" and GetControl(searchBox) or searchBox
  end

  local menuBarSearchBoxData = {
    bank = {
      menuBar = ZO_PlayerBankMenuBar,
      controls = {
        [SI_BANK_WITHDRAW] = ZO_PlayerBank,
        [SI_BANK_DEPOSIT] = ZO_PlayerInventory,
      },
    },
    fence_keyboard = {
      menuBar = ZO_Fence_Keyboard_WindowMenuBar,
      controls = {
        [SI_STORE_MODE_SELL] = ZO_PlayerInventory,
        [SI_FENCE_LAUNDER_TAB] = ZO_PlayerInventory,
      },
    },
    guildBank = {
      menuBar = ZO_GuildBankMenuBar,
      controls = {
        [SI_BANK_WITHDRAW] = ZO_GuildBank,
        [SI_BANK_DEPOSIT] = ZO_PlayerInventory,
      },
    },
    houseBank = {
      menuBar = ZO_HouseBankMenuBar,
      controls = {
        [SI_BANK_WITHDRAW] = ZO_HouseBank,
        [SI_BANK_DEPOSIT] = ZO_PlayerInventory,
      },
    },
    inventory = {
      menuBar = ZO_PlayerInventoryMenuBar,
      controls = {
        [SI_INVENTORY_MODE_ITEMS] = ZO_PlayerInventory,
        [SI_INVENTORY_MODE_CRAFT_BAG] = ZO_CraftBag,
        [SI_INVENTORY_MODE_QUICKSLOTS] = ZO_QuickSlot,
      },
    },
    -- Also used for clothing, jewelry crafting, and woodworking scenes.
    smithing = {
      menuBar = ZO_SmithingTopLevelModeMenuBar,
      controls = {
        [SMITHING_MODE_DECONSTRUCTION] = ZO_SmithingTopLevelDeconstructionPanelInventory,
        [SMITHING_MODE_IMPROVEMENT] = ZO_SmithingTopLevelImprovementPanelInventory,
      },
    },
    store = {
      menuBar = ZO_StoreWindowMenuBar,
      controls = {
        [SI_STORE_MODE_BUY] = ZO_StoreWindow,
        [SI_STORE_MODE_SELL] = ZO_PlayerInventory,
      },
    },
    tradinghouse = {
      menuBar = ZO_TradingHouseMenuBar,
      controls = {
        [ZO_TRADING_HOUSE_MODE_BROWSE] = "ZO_TradingHouseItemNameSearchBox",
        [ZO_TRADING_HOUSE_MODE_SELL] = ZO_PlayerInventory,
        [ZO_TRADING_HOUSE_MODE_LISTINGS] = ZO_TradingHousePostedItemsList,
      },
    },
  }

  local function TryGetMenuBarSearchBox(sceneName)
    local data = menuBarSearchBoxData[sceneName]
    if not data then return nil end

    local descriptor = ZO_MenuBar_GetSelectedDescriptor(data.menuBar)
    local control = data.controls[descriptor]
    if not control then return nil end

    if type(control) == "string" then return GetControl(control) end

    return control:GetNamedChild("SearchBox") or control:GetNamedChild("SearchFiltersTextSearchBox") or control:GetNamedChild("VotanSearchBox")
  end

  local directSearchBoxNames = {
    gameMenuInGame = {
      "AddonSelectorSearchBox",
      "LAMAddonSettingsWindowSearchFilterEdit",
      "ZO_KeybindingsKeybinderSearchBox",
    },
  }

  local function TryGetDirectSearchBox(sceneName)
    local searchBoxNames = directSearchBoxNames[sceneName]
    if not searchBoxNames then return nil end

    for i = 1, #searchBoxNames do
      local searchBox = GetControl(searchBoxNames[i])
      if searchBox and not searchBox:IsHidden() then return searchBox end
    end

    return nil
  end

  function AenathelsKeybinds.FocusSearchBox()
    local sceneName = SCENE_MANAGER:GetCurrentSceneName()
    local searchBox = TryGetSceneSearchBox(sceneName) or TryGetMenuBarSearchBox(sceneName) or TryGetDirectSearchBox(sceneName)
    if not searchBox then return end

    searchBox:TakeFocus()
  end
end

do
  local CanLeaveCurrentLocationViaTeleport = CanLeaveCurrentLocationViaTeleport
  local GetHousingPrimaryHouse = GetHousingPrimaryHouse
  local IsInCampaign = IsInCampaign
  local RequestJumpToHouse = RequestJumpToHouse

  function AenathelsKeybinds.TravelToPrimaryHouse()
    local houseId = GetHousingPrimaryHouse()

    if houseId then
      if CanLeaveCurrentLocationViaTeleport() and not IsInCampaign() then
        RequestJumpToHouse(houseId)
      else
        AenathelsKeybinds.PrintErrorWithSound(AEKB_ERROR_CANNOT_TRAVEL_TO_PRIMARY_HOUSE)
      end
    else
      AenathelsKeybinds.PrintErrorWithSound(AEKB_ERROR_NO_PRIMARY_HOUSE_SET)
    end
  end
end

function AenathelsKeybinds.OnAddOnLoaded(_, addonName)
  if addonName == AenathelsKeybinds.name then
    EVENT_MANAGER:UnregisterForEvent(AenathelsKeybinds.name, EVENT_ADD_ON_LOADED)

    AenathelsKeybinds:Initialize()
  end
end

EVENT_MANAGER:RegisterForEvent(AenathelsKeybinds.name, EVENT_ADD_ON_LOADED, AenathelsKeybinds.OnAddOnLoaded)
