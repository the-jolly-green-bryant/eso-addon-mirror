-- Cosmetic Cupboard

CC = {
  name            = "CosmeticCupboard",
  displayName     = "Cosmetic Cupboard",
  version         = "v3.4",
  author          = 'AnotherORC',

  variableVersion = 3,

  CONSTS = {
    chatPrefix = "|cB759FF[CC]: |cFFFFFF",
    chatSuffix = "|r",
  },

  Default = {
    profiles = {},
  }
}

COLLECTIBLE_CATAGORIES_APPEARANCE = {
  [0] = { COLLECTIBLE_CATEGORY_TYPE_HAT,               0, "Hat"              },
  [1] = { COLLECTIBLE_CATEGORY_TYPE_HAIR,              1, "Hair"             },
  [2] = { COLLECTIBLE_CATEGORY_TYPE_HEAD_MARKING,      2, "Head Markings"    },
  [3] = { COLLECTIBLE_CATEGORY_TYPE_FACIAL_HAIR_HORNS, 3, "Facial Hair"      },
  [4] = { COLLECTIBLE_CATEGORY_TYPE_PIERCING_JEWELRY,  4, "Minor Adornment"  },
  [5] = { COLLECTIBLE_CATEGORY_TYPE_FACIAL_ACCESSORY,  5, "Major Adornment"  },
  [6] = { COLLECTIBLE_CATEGORY_TYPE_COSTUME,           6, "Costume"          },
  [7] = { COLLECTIBLE_CATEGORY_TYPE_BODY_MARKING,      7, "Body Markings"    },
  [8] = { COLLECTIBLE_CATEGORY_TYPE_SKIN,              8, "Skin"             },
  [9] = { COLLECTIBLE_CATEGORY_TYPE_PERSONALITY,       9, "Personality"      },
  [10] = { COLLECTIBLE_CATEGORY_TYPE_VANITY_PET,      10, 'Pet'              },
  [11] = { COLLECTIBLE_CATEGORY_TYPE_MOUNT,           11, 'Mount'            },
  [12] = { COLLECTIBLE_CATEGORY_TYPE_POLYMORPH,       12, 'Polymorph'        }
}

--[[
  Shows a tooltip next to the specified controller.
  This is used to provide more information about a stored
  cosmetic.

  @param control  Control to display next too
  @param itemLink Item link info to display
]]--
CC_UI = {} -- TODO: remove this reference.  It should be in the utils folder
function CC_UI.ShowToolTip(control, itemLink)

  local xPos = 0
  local yPos = 0

  local panel = control
  local centerX, centerY = panel:GetCenter()
  local rootCenterX, rootCenterY = GuiRoot:GetCenter()

  local pointX, relativeX
  local offset = 10

  if centerX < rootCenterX then
    pointX = LEFT
    relativeX = RIGHT
  else
    pointX = RIGHT
    relativeX = LEFT
    offset = -offset
  end

  PopupTooltip:ClearAnchors()
  PopupTooltip:SetAnchor(pointX, control, relativeX, offset, 0)

  ZO_PopupTooltip_SetLink(itemLink)
end

--[[
  Hides the tooltip if its visable
]]--
function CC_UI.HideToolTip()
  ZO_PopupTooltip_Hide()
end

function CC:SetIconHidden(value)

  local buttonBg = WINDOW_MANAGER:GetControlByName("CC_UI_ButtonBg")
  local button = WINDOW_MANAGER:GetControlByName("CC_UI_Button")

  buttonBg:SetHidden(not value)
  button:SetHidden(not value)

  CC.data:SetIconEnabled(value)
end

--[[
  Moves the UI elements to the saved position
]]--
function CC:SetUpUIPositions()
  local panelPositions = CC.data:GetPanelPositions()

  for name, pos in pairs(panelPositions) do
    local panel = WINDOW_MANAGER:GetControlByName(name)
    panel:ClearAnchors()
    panel:SetAnchor(pos[3], GuiRoot, pos[4], pos[1], pos[2])
  end

  -- Hide the icon
  self:SetIconHidden(CC.data:GetIconEnabled())
end

function CC:Initialize()

  -- Create the key bindings
  CC.bindings = CC_KeyBindings:New()
  CC.bindings:Initialize()

  -- Create and store our data manager
  CC.data   = CC_Data:New()
  CC.data:LoadData(CC.variableVersion)

  -- Create the addon settings menu
  CC:CreateAddonMenu()

  -- Load ui location settings
  CC:SetUpUIPositions()

  -- Create combo box
  CC_UI_MANAGER:SetupProfileCombo()

  -- Something I learnt from the master writ Crafter
  -- This feels dirt, but oh well
  if HodorReflexes and HodorReflexes.users then
    HodorReflexes.users["@AnotherORC"] =  {"AnotherORC", "|cffe200A|r|cffda00n|r|cffd300o|r|cffcc00t|r|cffc500h|r|cffbd00e|r|cffb600r|r|cffaf00O|r|cffa700R|r|cffa000C|r", "CosmeticCupboard/assets/lemno_garb_large.dds"}
  end
end

function CC.LoadProfileData()

  local function GetCollectionData()

    local collectilbeData = {}

    -- Loop through all collectibles
    for i = 0, #COLLECTIBLE_CATAGORIES_APPEARANCE do
      -- Convert to the correct index
      local index = i + 1

      local collectilbeId = GetActiveCollectibleByType(COLLECTIBLE_CATAGORIES_APPEARANCE[i][1])

      -- Check for collectible
      if collectilbeId > 0 then
        collectilbeData[EQUIPED_ICONS[index][1]] = collectilbeId
      end
    end

    return collectilbeData
  end

  local function GetTitleIndex()
    local index = GetCurrentTitleIndex()
    if index == nil then index = 0 end
    return index
  end

  local function GetOutfitIndex()
    local index = GetEquippedOutfitIndex()
    if index == nil then index = 0 end
    return index
  end

  local function GetQuickslotData()

    local function GetSlotType(slotIndex, slotType)

      local slotLink = GetSlotItemLink(slotIndex, slotType)
      local slotId = GetSlotBoundId(slotIndex, slotType)

      -- This is true when there is a collectilbe OR an item in this slot
      if slotLink and slotLink ~= '' then
        -- Collectibles contain the string `collectible`
        if string.match(slotLink, 'collectible') == nil then return nil end

        if GetCollectibleCategoryType(slotId) == CC_COMPANION_COLLECTIBLE_TYPE or GetCollectibleCategoryType(slotId) == CC_ASSISTANT_COLLECTIBLE_TYPE then
          return CC_DRAG_TYPE_COMPANION, slotId
        end

        local collectibleData = ZO_COLLECTIBLE_DATA_MANAGER:GetCollectibleDataById(slotId)

        if collectibleData:GetSpecializedCategoryType() == CC_TOOL_COLLECTIBLE_TYPE then
            return CC_DRAG_TYPE_TOOL, slotId
        end

        return CC_DRAG_TYPE_MEMENTO, slotId
      end

      -- Check for an id
      if slotId then
        local emoteInfo = PLAYER_EMOTE_MANAGER:GetEmoteItemInfo(slotId)
        if emoteInfo == nil then return nil end
        return CC_DRAG_TYPE_EMOTE, slotId
      end

      return nil
    end

    local quickslotsData = {}

    -- Loop through quickslots
    for i = 1, #HOTBAR_CATEGORIES do

      local hotbarInfo = HOTBAR_CATEGORIES[i]
      local hotbarType = hotbarInfo[1]
      local hotbarId = hotbarInfo[2]

      -- Create container for slot data
      quickslotsData[hotbarId] = {}

      -- Loop through each wheel
      for j = 1, 8 do

        -- Slot type or nil
        local slotDataType, slotId = GetSlotType(j, hotbarType)

        if slotDataType then
          quickslotsData[hotbarId][j] = { slotDataType , slotId }
        end
      end
    end

    return quickslotsData
  end

  -- Update the UI
  CC_UI_MANAGER:SetCollectibleData(GetCollectionData())
  CC_UI_MANAGER:SetQuickslotData(GetQuickslotData())
  CC_UI_MANAGER:SetTitleData(GetTitleIndex())
  CC_UI_MANAGER:SetOutfitData(GetOutfitIndex())
end

function CC.OnDragFinished(control)

  local name = control:GetName()

  local centerX, centerY = control:GetCenter()
  local rootCenterX, rootCenterY = GuiRoot:GetCenter()
  local rootWidth, rootHeight = GuiRoot:GetDimensions()
  local relPoint
  local relX
  local relY

  if centerX > rootCenterX then
      relX = (centerX-rootWidth)/rootWidth
      if centerY > rootCenterY then
          relY = (centerY-rootHeight)/rootHeight
          relPoint = BOTTOMRIGHT
      else
          relY = centerY/rootHeight
          relPoint = TOPRIGHT
      end
  else
      relX = centerX/rootWidth
      if centerY > rootCenterY then
          relY = (centerY-rootHeight)/rootHeight
          relPoint = BOTTOMLEFT
      else
          relY = centerY/rootHeight
          relPoint = TOPLEFT
      end
  end

  CC.data:StorePosition(name, { control:GetLeft(), control:GetTop(), relX, relY, relPoint })
end

function CC.OnAddOnLoaded(event, addonName)
  if addonName == CC.name then
    CC:Initialize()
  end
end

function CC.CommandParse(args)
  local options = {}
	local searchResult = { string.match(args, "^(%S*)%s*(.-)$") }
	for i,v in pairs(searchResult) do
		if (v ~= nil and v ~= "") then
			options[i] = string.lower(v)
		end
	end

  if #options == 0 then
    CC_UI_MANAGER:Show()
  else
    if options[1] == "save" then

    elseif options[1] == "load" then

    elseif options[1] == "test" then
      SCENE_MANAGER:ShowScene("collectionsBook", 1)
      -- ZO_GameMenu_CharacterSelect_Reset()
    end
  end
end

SLASH_COMMANDS["/cc"] = CC.CommandParse
EVENT_MANAGER:RegisterForEvent(CC.name, EVENT_ADD_ON_LOADED, CC.OnAddOnLoaded)

