--Name Space
local HH = HouseHotkey

--Basic Info
HH.Name = "HouseHotkey"

local LRM = LibRadialMenu

local LIBRADIAL_WHEEL = HOTBAR_CATEGORY_MAX_VALUE + 100

local collectionsScene = "gamepadCollectionsBook"

local addonId = string.lower(HH.Name)

HH.settingsPanel = nil

--Setting
HH.Default = {
  CV = false,
  Command = {
    [HOTBAR_CATEGORY_QUICKSLOT_WHEEL] = {},
    [HOTBAR_CATEGORY_ALLY_WHEEL] = {},
    [HOTBAR_CATEGORY_MEMENTO_WHEEL] = {},
    [HOTBAR_CATEGORY_TOOL_WHEEL] = {},
    [HOTBAR_CATEGORY_EMOTE_WHEEL] = {},
    [LIBRADIAL_WHEEL] = {},
  },
}

local wheelOptions = {
  { name = GetString(SI_HOTBARCATEGORY10), data = HOTBAR_CATEGORY_QUICKSLOT_WHEEL},
  { name = GetString(SI_HOTBARCATEGORY13), data = HOTBAR_CATEGORY_ALLY_WHEEL},
  { name = GetString(SI_HOTBARCATEGORY12), data = HOTBAR_CATEGORY_MEMENTO_WHEEL},
  { name = GetString(SI_HOTBARCATEGORY14), data = HOTBAR_CATEGORY_TOOL_WHEEL},
  { name = GetString(SI_HOTBARCATEGORY11), data = HOTBAR_CATEGORY_EMOTE_WHEEL},
}

if LRM ~= nil then
  table.insert(wheelOptions, { name = HH.Lang.LRM_WHEEL, data = LIBRADIAL_WHEEL})
end

local PREVIEW_PRELOADED_HOUSES = {
  1060,   -- Mara's Kiss Public House
  1061,   -- The Rosy Lion
  1062,   -- The Ebony Flask Inn Room
  1063,   -- Barbed Hook Private Room
  1064,   -- Sisters of the Sands Inn Room
  1065,   -- Flaming Nix Deluxe Garret
  1066,   -- Black Vine Villa
  1069,   -- HumbleMud
  1070,   -- The Ample Domicile
  1072,   -- Snugpod
  1073,   -- Bouldertree Refuge
  1075,   -- Captain Margaux's Place
  1077,   -- Gardner House
  1078,   -- Kragenhome
  1081,   -- Moonmirth House
  1084,   -- Cyrodilic Jungle House
  1087,   -- Autumn's Gate
  1091,   -- Mournoth Keep
  1243,   -- Amaya Lake Lodge
  1310,   -- Exorcised Coven Cottage
}

local slotOptions = {
      { name = "1 - N", data = 4 },
      { name = "2 - NW", data = 5 },
      { name = "3 - W", data = 6 },
      { name = "4 - SW", data = 7 },
      { name = "5 - S", data = 8 },
      { name = "6 - SE", data = 1 },
      { name = "7 - E", data = 2 },
      { name = "8 - NE", data = 3 },
    }

local slotMapped = {
  [1] = "6 - SE",
  [2] = "7 - E",
  [3] = "8 - NE",
  [4] = "1 - N",
  [5] = "2 - NW",
  [6] = "3 - W",
  [7] = "4 - SW",
  [8] = "5 - S",
}

local function OnPlayerActivated(eventCode)
    EVENT_MANAGER:UnregisterForEvent("HouseHotkey_PlayerActivated", EVENT_PLAYER_ACTIVATED)
    local currentSearchState = HOUSE_TOURS_SEARCH_MANAGER:GetSearchState(HOUSE_TOURS_LISTING_TYPE_FAVORITE)
    if currentSearchState ~= ZO_HOUSE_TOURS_SEARCH_STATES.COMPLETE then
        HOUSE_TOURS_SEARCH_MANAGER:ExecuteSearch(HOUSE_TOURS_LISTING_TYPE_FAVORITE)
    end
    zo_callLater(HH.BuildMenu, 1500)
    
    if IsConsoleUI() then
      HOUSE_TOURS_GAMEPAD.listingPanelFragment:RegisterCallback("StateChange", HH.HookHouseTours)
    end
end

--When Loaded
local function OnAddOnLoaded(eventCode, addonName)
  if addonName ~= HH.Name then return end
	EVENT_MANAGER:UnregisterForEvent(HH.Name, EVENT_ADD_ON_LOADED)
  
  --Get Account/Character Setting
  HH.AV = ZO_SavedVars:NewAccountWide("HouseHotkey_Vars", 1, nil, HH.Default)
  HH.CV = ZO_SavedVars:NewCharacterIdSettings("HouseHotkey_Vars", 1, nil, HH.Default)
  HH.SwitchSV()

  --Hook Wheels
  HH.HookWheel()
  EVENT_MANAGER:RegisterForEvent("HouseHotkey_PlayerActivated", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
  if IsConsoleUI() then
    GAMEPAD_COLLECTIONS_BOOK_HOUSING_PANEL_FRAGMENT:RegisterCallback("StateChange", HH.showAssignOnHousing)
  end
end

--Account/Character Setting
function HH.SwitchSV()
  if HH.CV.CV then
    HH.SV = HH.CV
  else
    HH.SV = HH.AV
  end
end

function HH.showAssignOnHousing(oldState, newState)
  if (newState == SCENE_FRAGMENT_SHOWING) and HH.AddAssignHouse then 
    HH.AddAssignHouse(newState)
  elseif newState == SCENE_FRAGMENT_HIDDEN and HH.assign then
    KEYBIND_STRIP:RemoveKeybindButtonGroup(HH.assign)
  end
end

function HH.HookWheel()
  if IsInGamepadPreferredMode() then
      --GamePad Part
      local Old = UTILITY_WHEEL_GAMEPAD.menu.AddEntry
      UTILITY_WHEEL_GAMEPAD.menu.AddEntry = function(Self, name, inactiveIcon, activeIcon, callback, data)
        local Category = UTILITY_WHEEL_GAMEPAD:GetHotbarCategory()
        local Index = tonumber(data.slotNum)
        local New
        if HH.SV.Command[Category] then
          New = HH.SV.Command[Category][Index]
        end
        if New then
          Old(Self, New.name, New.icon, New.icon, function() HH.Execute(New.house, New.exterior, New.houseOwner) end, {name = New.name, slotNum = Index})  
        else
          Old(Self, name, inactiveIcon, activeIcon, callback, data)
        end
      end
  else
    --PC Part
    local Old = UTILITY_WHEEL_KEYBOARD.menu.AddEntry
    UTILITY_WHEEL_KEYBOARD.menu.AddEntry = function(Self, name, inactiveIcon, activeIcon, callback, data)
      local Category = UTILITY_WHEEL_KEYBOARD:GetHotbarCategory()
      local Index = tonumber(data.slotNum)
      local New
      if HH.SV.Command[Category] then
        New = HH.SV.Command[Category][Index]
      end
      if New then
        Old(Self, New.name, New.icon, New.icon, function() HH.Execute(New.house, New.exterior, New.houseOwner) end, {name = New.name, slotNum = Index})
      else
        Old(Self, name, inactiveIcon, activeIcon, callback, data)
      end
    end
  end
end

-- /script HouseHotkey.Execute()
function HH.Execute(Text, Exterior, HouseOwner)
  if HouseOwner ~= "self" and HouseOwner ~= HH.Lang.HOUSE_PREVIEW_EXPLAIN then
    JumpToSpecificHouse(HouseOwner, Text)
  else
    RequestJumpToHouse(Text, Exterior)
  end
end

--Icon
HH.IconList = {
  "/esoui/art/crafting/alchemy_tabicon_reagent_up.dds",
  "/esoui/art/crafting/alchemy_tabicon_solvent_up.dds",
  "/esoui/art/crafting/blueprints_tabicon_up.dds",
  "/esoui/art/crafting/designs_tabicon_up.dds",
  "/esoui/art/crafting/enchantment_tabicon_aspect_up.dds",
  "/esoui/art/crafting/enchantment_tabicon_deconstruction_up.dds",
  "/esoui/art/crafting/enchantment_tabicon_essence_up.dds",
  "/esoui/art/crafting/enchantment_tabicon_potency_up.dds",
  "/esoui/art/crafting/gamepad/gp_crafting_menuicon_designs.dds",
  "/esoui/art/crafting/gamepad/gp_crafting_menuicon_fillet.dds",
  "/esoui/art/crafting/gamepad/gp_crafting_menuicon_improve.dds",
  "/esoui/art/crafting/gamepad/gp_crafting_menuicon_refine.dds",
  "/esoui/art/crafting/gamepad/gp_jewelry_tabicon_icon.dds",
  "/esoui/art/crafting/gamepad/gp_reconstruct_tabicon.dds",
  "/esoui/art/crafting/jewelryset_tabicon_icon_up.dds",
  "/esoui/art/crafting/patterns_tabicon_up.dds",
  "/esoui/art/crafting/provisioner_indexicon_fish_up.dds",
  "/esoui/art/crafting/provisioner_indexicon_furnishings_up.dds",
  "/esoui/art/crafting/retrait_tabicon_up.dds",
  "/esoui/art/crafting/smithing_tabicon_armorset_up.dds",
  "/esoui/art/crafting/smithing_tabicon_weaponset_up.dds",
  "/esoui/art/writadvisor/advisor_tabicon_equip_up.dds",
  "/esoui/art/writadvisor/advisor_tabicon_quests_up.dds",
  "/esoui/art/companion/keyboard/category_u30_companions_up.dds",
  "/esoui/art/collections/collections_categoryicon_unlocked_up.dds",
  "/esoui/art/collections/collections_tabicon_housing_up.dds",
  "/esoui/art/companion/keyboard/companion_character_up.dds",
  "/esoui/art/companion/keyboard/companion_skills_up.dds",
  "/esoui/art/companion/keyboard/companion_overview_up.dds",
  "/esoui/art/guildfinder/keyboard/guildbrowser_guildlist_additionalfilters_up.dds",
  "/esoui/art/help/help_tabicon_cs_up.dds",
  "/esoui/art/help/help_tabicon_tutorial_up.dds",
  "/esoui/art/lfg/lfg_any_up_64.dds",
  "/esoui/art/lfg/lfg_tank_up_64.dds",
  "/esoui/art/lfg/lfg_dps_up_64.dds",
  "/esoui/art/lfg/lfg_healer_up_64.dds",
  "/esoui/art/lfg/lfg_indexicon_alliancewar_up.dds",
  "/esoui/art/lfg/lfg_indexicon_trial_up.dds",
  "/esoui/art/lfg/lfg_indexicon_zonestories_up.dds",
  "/esoui/art/lfg/lfg_tabicon_grouptools_up.dds",
  "/esoui/art/mail/mail_tabicon_inbox_up.dds",
  "/esoui/art/market/keyboard/tabicon_crownstore_up.dds",
  "/esoui/art/market/keyboard/tabicon_daily_up.dds",
  "/esoui/art/tradinghouse/tradinghouse_materials_jewelrymaking_rawplating_up.dds",
  "/esoui/art/tradinghouse/tradinghouse_sell_tabicon_up.dds",
  "/esoui/art/vendor/vendor_tabicon_fence_up.dds",
}

function HH.GetPreviewHouseOption()
  local previewHouse = {}
  local checkHouse = {}
  local lockedHouses = {}
  for index, entry in ipairs(PREVIEW_PRELOADED_HOUSES) do
    checkHouse = ZO_COLLECTIBLE_DATA_MANAGER:GetCollectibleDataById(entry)
    if checkHouse then
      if checkHouse:IsHouse() and checkHouse:IsLocked() then
        previewHouse = {
           name = "["..HH.Lang.HOUSE_RETURN.."] "..checkHouse:GetFormattedName(), data = {id = checkHouse:GetReferenceId(), owner = HH.Lang.HOUSE_PREVIEW_EXPLAIN}
        }
        break
      end
    end
  end
  if not checkHouse then
    lockedHouses = ZO_COLLECTIBLE_DATA_MANAGER:GetAllCollectibleDataObjects({ ZO_CollectibleCategoryData.IsHousingCategory }, { ZO_CollectibleData.IsLocked }, { ZO_CollectibleData.IsPurchasable })
    if #lockedHouses > 0 then
      previewHouse = {
         name = "["..HH.Lang.HOUSE_RETURN.."] "..lockedHouses[1]:GetFormattedName(), data = {id = lockedHouses[1]:GetReferenceId(), owner = HH.Lang.HOUSE_PREVIEW_EXPLAIN}
      }
    end
  end
  return previewHouse
end

function HH.GetHouseDropdownChoices()
    local collectibleData = ZO_COLLECTIBLE_DATA_MANAGER:GetAllCollectibleDataObjects({ ZO_CollectibleCategoryData.IsHousingCategory }, { ZO_CollectibleData.IsUnlocked })
    local ownedHouseItems = {}
    local previewHouse = HH.GetPreviewHouseOption()
    local counter = 0
    local counter2 = 1
    -- Owned houses
    for index, entry in ipairs(collectibleData) do
        if (entry:IsHouse()) then
            local referenceId = entry:GetReferenceId()
            if (not entry:IsLocked()) then
              local houseEntry = {
                name = entry:GetFormattedName(), data = {id = referenceId, owner = "self"}
              }
              ownedHouseItems[index] = houseEntry
              counter = counter + 1
            end
        end
    end

    --Favorite Houses
    local favoriteHouses = {}
    favoriteHouses = HOUSE_TOURS_SEARCH_MANAGER:GetSearchResults(HOUSE_TOURS_LISTING_TYPE_FAVORITE)
    for index, entry in ipairs(favoriteHouses) do
      local houseEntry = {
        name = "[FAV] "..entry:GetHouseName(), data = {id = entry:GetHouseId(), owner = entry:GetOwnerDisplayName()}
      }
      ownedHouseItems[counter + index] = houseEntry
      counter2 = counter2 + 1
    end

    -- Preview House
    if previewHouse then
      local total = counter + counter2
      ownedHouseItems[total] = previewHouse
    end

    return ownedHouseItems
end

function HH.Part(Index)
  local Positons = {"1 - N    ", "2 - NW", "3 - W   ", "4 - SW", "5 - S    ", "6 - SE  ", "7 - E    ", "8 - NE "}
  local Order = {4, 5, 6, 7, 8, 1, 2, 3}
  local StringList = {SI_HOTBARCATEGORY10, SI_HOTBARCATEGORY11, SI_HOTBARCATEGORY12, SI_HOTBARCATEGORY13, SI_HOTBARCATEGORY14}
  
  local Tep = GetString(StringList[Index - 9]).."\r\n  "
  if HH.SV.Command[Index] then

    for k, v in ipairs(Order) do
      local Content = HH.SV.Command[Index][v]
      local owner = " "
      if Content then
        local InOrOut = HH.Lang.HOUSE_INSIDE
        if Content.exterior then
          InOrOut = HH.Lang.HOUSE_OUTSIDE
        end
        if Content.houseOwner ~= "self" then
          owner = Content.houseOwner
          InOrOut = HH.Lang.HOUSE_INSIDE_ONLY
        else
          owner = " "
        end
        Tep = Tep..Positons[k].."  |t16:16:"..tostring(Content.icon).."|t  "..Content.name.." |c778899( "..Content.houseName.." )|  "..InOrOut.."|  "..owner.."|r\r\n  "
      end
    end
  end

  return Tep
end

--Menu Part

if not LibHarvensAddonSettings then
    d("LibHarvensAddonSettings is required!")
    return
end

local LAM = LibHarvensAddonSettings

function HH.BuildMenu()
  local houseItems = HH.GetHouseDropdownChoices()
  local HH_Lang = HH.Lang

  local panel = LAM:AddAddon(HH.Name, {
    allowDefaults = false,  -- Show "Reset to Defaults" button
    allowRefresh = false    -- Enable automatic control updates
  })

  --Option Part
  local Category, CategoryName, EntryIndex, EntryIndexName, Icon, IconName, Name, House, HouseName, HouseId, HouseOwner, Status
  local Category2, CategoryName2, EntryIndex2, EntryIndexName2
  panel:AddSetting {
    type = LAM.ST_CHECKBOX,
    label = HH_Lang.CHARACTER_SETTING,
    getFunction = function() return HH.CV.CV end,
    setFunction = function(var)
      HH.CV.CV = var
      HH.SwitchSV()
    end
  }
  --Create QuickSlot
  panel:AddSetting {
    type = LAM.ST_SECTION,
    label = HH_Lang.CREATE_QUICKSLOT,
  }
if #houseItems > 0 then
  --Category
  panel:AddSetting {
    type = LAM.ST_DROPDOWN,
    label = HH_Lang.WHEEL_CATEGORY,
    items = wheelOptions,
    getFunction = function() return CategoryName or GetString(SI_HOTBARCATEGORY10) end,
    setFunction = function(var, itemName, itemData)
      CategoryName = itemName
      Category = tonumber(itemData.data)
    end,
    default = GetString(SI_HOTBARCATEGORY10),
  }
  --Index
  panel:AddSetting {
    type = LAM.ST_DROPDOWN,
    label = HH_Lang.WHEEL_SLOT,
    items = function()
      if Category == LIBRADIAL_WHEEL and LRM ~= nil then
        local slotsObj = {}
        for i = 1, LRM.vars.numSlots do 
          table.insert(slotsObj, { name = tostring(i), data = i })
        end
        return slotsObj
      else
        return slotOptions
      end
    end,
    getFunction = function() return EntryIndexName or "1 - N" end,
    setFunction = function(var, itemName, itemData)
      EntryIndexName = itemName
      EntryIndex = tonumber(itemData.data)
    end,
  }
  --Icon Select
  panel:AddSetting {
    type = LAM.ST_ICONPICKER,
    label = HH_Lang.WHEEL_ICON,
    items = HH.IconList,
    getFunction = function() return Icon  end,
    setFunction = function(var, iconIndex, iconPath)
      IconName = iconPath
      Icon = iconIndex
    end,
  }
  --Name
  panel:AddSetting {
    type = LAM.ST_EDIT,
    label = HH_Lang.WHEEL_NAME,
    getFunction = function() return Name or "" end,
    setFunction = function(text) Name = text end,
    default = " "
  }

  --House Choice
  panel:AddSetting {
    type = LAM.ST_DROPDOWN,
    label = HH_Lang.HOUSE,
    items = houseItems,
    getFunction = function()
      return HouseName
    end,
    setFunction = function(control, itemName, itemData)
      HouseName = itemName
      HouseId = itemData.data.id
      HouseOwner = itemData.data.owner
      panel:UpdateControls()
    end
  }
  panel:AddSetting {
    type = LAM.ST_LABEL,
    label = function()
      if HouseOwner ~= "self" then
        return HouseOwner or " "
      end
      return HH_Lang.HOUSE_COLLECTED or " "
    end
  }

  --Jump to Interior or Exterior
  panel:AddSetting {
    type = LAM.ST_CHECKBOX,
    label = HH_Lang.HOUSE_EXTERIOR,
    getFunction = function() return UseExterior or false end,
    setFunction = function(var)
      UseExterior = var
    end,
    default = false,
    disable = function()
      return HouseOwner ~= "self"
    end
  }
  --Apply
  panel:AddSetting {
    type = LAM.ST_BUTTON,
    label = HH_Lang.WHEEL_APPLY,
    buttonText = HH_Lang.WHEEL_APPLY,
    clickHandler  = function()
      if not Name or Name == "" then
        Status = HH_Lang.STATUS_NO_NAME
      else
        HH.SV.Command[Category or HOTBAR_CATEGORY_QUICKSLOT_WHEEL][EntryIndex or 4] = {
          ["name"] = Name,
          ["icon"] = IconName or HH.IconList[1],
          ["house"] = HouseId or houseItems[1].data.id,
          ["exterior"] = UseExterior or false,
          ["houseName"] = HouseName or houseItems[1].name,
          ["houseOwner"] = HouseOwner or houseItems[1].data.owner or "self",
        }
        Status = HH.Lang.STATUS_ADDED
        panel:UpdateControls()
      end
    end
  }
  --Status
  panel:AddSetting {
    type = LAM.ST_LABEL,
    label = function()
      return Status or " "
    end
  }
    --Configured
    panel:AddSetting {
      type = LAM.ST_SECTION,
      label = HH_Lang.WHEEL_DESC,
    }
    
    local function retrieveCategory()
      local configured = {}
      for category in pairs(HH.SV.Command) do 
        if next(HH.SV.Command[category]) then
          local catName
          if category == LIBRADIAL_WHEEL then
            catName = HH_Lang.LRM_WHEEL
          else
            catName = GetString(_G["SI_HOTBARCATEGORY"..tostring(category)])
          end
          table.insert(configured, { name = catName, data = category })
        end
      end
      return configured
    end
    
  --Category
  panel:AddSetting {
    type = LAM.ST_DROPDOWN,
    label = HH_Lang.WHEEL_CATEGORY,
    items = function() return retrieveCategory() end,
    getFunction = function() return CategoryName2 or GetString(SI_HOTBARCATEGORY10) end,
    setFunction = function(var, itemName, itemData)
      CategoryName2 = itemName
      Category2 = tonumber(itemData.data)
      panel:UpdateControls()
    end,
  }
  
  local function retrieveConfigured(category)
      local configured = {}
      if not category then
        category = retrieveCategory()
        if next(category) then
          local jDex, ent = next(category)
          category = ent.data
        end
      end
      if not category then return configured end
      if HH.SV.Command[category] and next(HH.SV.Command[category]) then
        for index, entry in pairs(HH.SV.Command[category]) do
          local slotLocation
          if category == LIBRADIAL_WHEEL then
            slotLocation = tostring(index)
          else 
            slotLocation = slotMapped[index]
          end
          local owner
          if entry.houseOwner == "self" then
            owner = GetDisplayName()
          else
            owner = entry.houseOwner
          end
          table.insert(configured, { name = slotLocation..": "..entry.name..", "..owner, data = index })
        end
      end
      return configured
  end
  
  --Index
  local entryIndexDropdown = panel:AddSetting {
    type = LAM.ST_DROPDOWN,
    label = HH_Lang.WHEEL_SLOT,
    items = function() return retrieveConfigured(Category2) end,
    getFunction = function() 
      return EntryIndexName2
    end,
    setFunction = function(var, itemName, itemData)
      EntryIndexName2 = itemName
      if type(itemData.data) == "number" then
        EntryIndex2 = itemData.data
      else
        EntryIndex2 = tonumber(itemData.data)
      end

    end,
  }
  --Empty
  panel:AddSetting {
    type = LAM.ST_BUTTON,
    label = HH_Lang.WHEEL_EMPTY,
    buttonText = HH_Lang.WHEEL_EMPTY,
    clickHandler = function()
      HH.SV.Command[Category2 or HOTBAR_CATEGORY_QUICKSLOT_WHEEL] = {}
      panel:UpdateControls()
    end,
  }
  --Delete
  panel:AddSetting {
    type = LAM.ST_BUTTON,
    label = HH_Lang.WHEEL_DELETE,
    buttonText = HH_Lang.WHEEL_DELETE,
    clickHandler = function()
      if Category2 == nil then
        local category = retrieveCategory()
        if next(category) then
          local jDex, ent = next(category)
          Category2 = ent.data
        end
      end
      if EntryIndex2 == nil then
        local configured = retrieveConfigured(Category2)
        if next(configured) then
          local iDex, entry = next(configured)
          EntryIndex2 = entry.data
        end
      end
      if EntryIndex2 then
        HH.SV.Command[Category2 or HOTBAR_CATEGORY_QUICKSLOT_WHEEL][EntryIndex2] = nil
        panel:UpdateControls()
      else
        HH.SV.Command[Category2 or HOTBAR_CATEGORY_QUICKSLOT_WHEEL][4] = nil
        panel:UpdateControls()
      end
    end,
  }
  panel:AddSetting {
      type = LAM.ST_LABEL,
      label = function()
        local configured = ""
        for category in pairs(HH.SV.Command) do 
          local catName
          if category == LIBRADIAL_WHEEL then
            catName = HH_Lang.LRM_WHEEL
          else
            catName = GetString(_G["SI_HOTBARCATEGORY"..tostring(category)])
          end
          configured = configured .. "|cebc034"..catName.."|r\r\n"
          if next(HH.SV.Command[category]) then
            for index, entry in pairs(HH.SV.Command[category]) do
              local slotLocation
              if category == LIBRADIAL_WHEEL then
                slotLocation = tostring(index)
              else 
                slotLocation = slotMapped[index]
              end
              local owner
              if entry.houseOwner == "self" then
                owner = GetDisplayName()
              else
                owner = entry.houseOwner
              end
              local InOrOut = HH.Lang.HOUSE_INSIDE
              if entry.exterior then
                InOrOut = HH.Lang.HOUSE_OUTSIDE
              end
              configured = configured .. "|t48:48:"..tostring(entry.icon).."|t  " .. slotLocation..": "..entry.name..", "..owner.." - "..InOrOut.."|r\r\n"
            end
          end
        end
        return configured
      end
    }
    panel:AddSetting {
      type = LAM.ST_LABEL,
      label = ""
    }
  else
    panel:AddSetting {
      type = LAM.ST_LABEL,
      label = HH_Lang.NO_HOUSES,
    }
  end
  HH.settingsPanel = panel
end

-- Start Here
EVENT_MANAGER:RegisterForEvent(HH.Name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
