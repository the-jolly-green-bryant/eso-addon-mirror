TC_Autocraft = ZO_Object:Subclass()

local LLC = LibLazyCrafting

local CRAFT_TOKEN = {
  [CRAFTING_TYPE_BLACKSMITHING]       = "BS",
  [CRAFTING_TYPE_CLOTHIER]            = "CL",
  [CRAFTING_TYPE_WOODWORKING]         = "WW",
  [CRAFTING_TYPE_JEWELRYCRAFTING]     = "JW"
}

local CRAFT_TOKEN_REVERSE = {
  ["BS"]         = CRAFTING_TYPE_BLACKSMITHING,
  ["CL"]         = CRAFTING_TYPE_CLOTHIER,
  ["WW"]         = CRAFTING_TYPE_WOODWORKING,
  ["JW"]         = CRAFTING_TYPE_JEWELRYCRAFTING,
}

function TC_Autocraft:New(...)
    local object = ZO_Object.New(self)
    object:Initialize(...)
    return object
end

function TC_Autocraft:GetPatternIndexFromResearchLine(craftingType, researchLineIndex)
    -- Get the research line's name (e.g., "Axe", "Chest", "Bow")
    local name, _, _, numTraits = GetSmithingResearchLineInfo(craftingType, researchLineIndex)
    if not name then
        return nil
    end
    local patternName
    -- Scan through patterns to find one with an exact match
    for patternIndex = 1, GetNumSmithingPatterns() do
        patternName = GetSmithingPatternInfo(patternIndex)
        if name == patternName then
          return patternIndex
        end
    end
    -- Fall back to approximately the same name
    for pIndex = 1, GetNumSmithingPatterns() do
        patternName = GetSmithingPatternInfo(pIndex)
        local found = string.find(name, patternName, 1, true)
        if found ~= nil then
            return pIndex
        end
    end
    return nil
end

local function findTraitType(craftingSkillType, researchLineIndex, traitIndex)
  local foundTraitType, description, _ = GetSmithingResearchLineTraitInfo(craftingSkillType, researchLineIndex, traitIndex)
	return foundTraitType or ITEM_TRAIT_TYPE_NONE
end

function TC_Autocraft:QueueItems(researchIndex, traitIndex)
  local craftingType = GetCraftingInteractionType()
  local patternIndex = self:GetPatternIndexFromResearchLine(craftingType, researchIndex)
  local traitType = findTraitType(craftingType, researchIndex, traitIndex)
  local request
  traitType = traitType + 1
  return self.interactionTable:CraftSmithingItemByLevel(patternIndex, false, 1, LLC_FREE_STYLE_CHOICE, traitType, false, craftingType, 0, 0, false)
end

local function getKeys(tbl)
  local keys = {}
  if not tbl then
    return {}
  end
  for k, _ in pairs(tbl) do
      table.insert(keys, k)
  end
  return keys
end

function TC_Autocraft:craftForType(scanResults, craftingType)
  local craftCounter = 0
  local request
  for rIndex, entry in pairs(scanResults[craftingType]) do
    if type(entry) == "table" then
      for tIndex, obj in pairs(entry[rIndex]) do
        if self.parent:DoesCharacterKnowTrait(craftingType, rIndex, tIndex) then
          request = self:QueueItems(rIndex, tIndex)
          if LLC.craftInteractionTables[craftingType]:isItemCraftable(craftingType, request) then
            self.interactionTable:craftItem(craftingType)
          end
          craftCounter = craftCounter + 1
        end
      end
    else
      if self.parent:DoesCharacterKnowTrait(craftingType, rIndex, entry) then
        request = self:QueueItems(rIndex, entry)
        if LLC.craftInteractionTables[craftingType]:isItemCraftable(craftingType, request) then
          self.interactionTable:craftItem(craftingType)
        end
        craftCounter = craftCounter + 1
      end
    end
  end
  if craftCounter == 0 then
    SCENE_MANAGER:ShowBaseScene()
    local skillName = ZO_GetCraftingSkillName(craftingType)
    d(self.parent.Lang.CRAFT_FAILED..skillName)
  end
  return craftCounter
end

function TC_Autocraft:CraftFromInput(scanResults)

  local craftCounter = 0
  local craftingType = GetCraftingInteractionType()
  for iDex, entry in pairs(scanResults) do
    local nextKey, itemTable = next(entry)
    local thisCraftType = CRAFT_TOKEN_REVERSE[nextKey]
    if craftingType == thisCraftType then
      for _, itemObj in pairs(itemTable) do
        local convertedObj = { [craftingType] = { [itemObj["researchIndex"]] = itemObj["traitIndex"] } }
        craftCounter = self:craftForType(convertedObj, craftingType)
      end
      scanResults[iDex] = nil
    end
  end
  if craftCounter > 0 then return true, scanResults end
  return false, scanResults
end

-- Freezing attempt to unify these for now
-- function TC_Autocraft:ScanUnknownTraitsForCrafting(charId)
--   local craftingType = GetCraftingInteractionType()
--   self.parent:ScanUnknownTraitsForCrafting(charId, craftingType, function(scanResults)
--     local craftCounter = self:craftForType(scanResults, craftingType, charId)
--   end)
-- end

function TC_Autocraft:ScanUnknownTraitsForCrafting(charId)
  local craftingType = GetCraftingInteractionType()
  local nirnCraftTypes = { CRAFTING_TYPE_BLACKSMITHING, CRAFTING_TYPE_CLOTHIER, CRAFTING_TYPE_WOODWORKING }
  local tempResearchTable = {
    rCounter = {},
    rObjects = {}
  }
  local mask = self.parent.bitwiseChars[charId]
  local char = self.parent.AV.activelyResearchingCharacters[charId]
  if not char then
    d(self.parent.Lang.LOG_INTO_CHAR)
    return
  end
  if not char["maxSimultResearch"] then
    d(self.parent.Lang.LOG_INTO_CHAR)
    return
  end
  local research = char.research or {}
  local researchLineLimit = GetNumSmithingResearchLines(craftingType)
  local traitLimit = 9
  if not self.parent.AV.settings.autoCraftNirnhoned and self.parent.isValueInTable(nirnCraftTypes, craftingType) then
    traitLimit = 8
  end
  local key
  local trait
  if not self.lastCrafted[charId] then
    self.lastCrafted[charId] = {}
  end
  if not self.lastCrafted[charId][craftingType] then
    self.lastCrafted[charId][craftingType] = {}
  end
  if not self.rIndices[charId] then
    self.rIndices[charId] = {}
  end
  if not self.rObjects[charId] then
    self.rObjects[charId] = {}
  end
  if not self.rIndices[charId][craftingType] then
    for r = 1, researchLineLimit do
      if not self.lastCrafted[charId][craftingType][r] then
        for t = 1, traitLimit do
          key = self.parent:GetTraitKey(craftingType, r, t)
          trait = self.parent.AV.traitTable[key] or 0
          if self.parent.charBitMissing(trait, mask) and not research[key] then
            if not tempResearchTable.rCounter[r] then
              tempResearchTable.rCounter[r] = 0
            end
            tempResearchTable.rCounter[r] =  tempResearchTable.rCounter[r] + 1
            if not tempResearchTable.rObjects[r] then
              tempResearchTable.rObjects[r] = {}
            end
            table.insert(tempResearchTable.rObjects[r], t)
          end
        end
      end
    end
    self.rIndices[charId][craftingType] = self.parent.sortKeysByValue(tempResearchTable.rCounter)
    self.rObjects[charId] = tempResearchTable.rObjects
  end

  --Sort by minimum research duration
  local traitCounter = 0
  for i = 1, #self.rIndices[charId][craftingType] do
    local rIndex = self.rIndices[charId][craftingType][i]
    if not self.lastCrafted[charId][craftingType][rIndex] then
      self.lastCrafted[charId][craftingType][rIndex] = {}
    end
    for j = 1, #self.rObjects[charId][rIndex] do
      local tIndex = self.rObjects[charId][rIndex][j]
      if not self.lastCrafted[charId][craftingType][rIndex][tIndex] then
        if self.parent:DoesCharacterKnowTrait(craftingType, rIndex, tIndex) then
          local request = self:QueueItems(rIndex, tIndex)
          if LibLazyCrafting.craftInteractionTables[craftingType]:isItemCraftable(craftingType, request) then
            self.interactionTable:craftItem(craftingType)
            self.lastCrafted[charId][craftingType][rIndex][tIndex] = true
            traitCounter = traitCounter + 1
            break
          end
        end
      end
    end
    if traitCounter >= char["maxSimultResearch"][craftingType] then
      return
    end
  end
  --No successful crafts
  if traitCounter == 0 then
    SCENE_MANAGER:ShowBaseScene()
    local skillName = ZO_GetCraftingSkillName(craftingType)
    d(self.parent.Lang.CRAFT_FAILED..skillName)
  end
end

local function getGamepadCraftKeyIcon()
	local key
	for i =1, 4 do
		key = GetActionBindingInfo(3, 1, 3, i)
		if IsKeyCodeGamepadKey(key) then
			break
		end
	end
	return GetGamepadIconPathForKeyCode(key) or  GetMouseIconPathForKeyCode(key) or GetKeyboardIconPathForKeyCode(key) or ""
end

function TC_Autocraft:CreateGamepadUI()
  TC_SCREEN:SetHidden(false)
  local label = GetControl("TC_SCREENBackdropOutput")
  label:SetText(self.parent.Lang.CRAFT_ALL)
  self.autoCraftBtn = {
    alignment = KEYBIND_STRIP_ALIGN_LEFT,
    {
        name = self.parent.Lang.CRAFT_SPECIFIC,
        keybind = "UI_SHORTCUT_TERTIARY",
        order = 2400,
        callback = function()
          if not self.selectedAutoCraft or self.selectedAutoCraft == self.parent.Lang.CRAFT_ALL then
            self.selectedAutoCraft = select(2, next(self.parent.AV.activelyResearchingCharacters)).name
          else
            charId = self.parent.GetCharIdByName(self.selectedAutoCraft)
            local char = select(2, next(self.parent.AV.activelyResearchingCharacters, charId))
            if char then
              self.selectedAutoCraft = char.name
            else
              self.selectedAutoCraft = self.parent.Lang.CRAFT_ALL
            end
          end
          local label = GetControl("TC_SCREENBackdropOutput")
          label:SetText(self.selectedAutoCraft)
        end,
      },
    {
        name = self.parent.Lang.CRAFT_ALL,
        keybind = "UI_SHORTCUT_QUATERNARY",
        order = 2500,
        callback = function()
          if not self.selectedAutoCraft then
            for id, char in pairs(self.parent.AV.activelyResearchingCharacters) do
              self:ScanUnknownTraitsForCrafting(id)
            end
          else
            local charId = self.parent.GetCharIdByName(self.selectedAutoCraft)
            self:ScanUnknownTraitsForCrafting(charId)
          end
        end,
      },
    }
  KEYBIND_STRIP:AddKeybindButtonGroup(self.autoCraftBtn)
  self.showing = true
end

function TC_Autocraft:RemoveGamepadUI()
  KEYBIND_STRIP:RemoveKeybindButtonGroup(self.autoCraftBtn)
  TC_SCREEN:SetHidden(true)
  self.showing = false
end

function TC_Autocraft:RemoveKeyboardUI()
  local smithingSceneName = "smithing"
  local toplevel = ZO_SmithingTopLevel
  local smithing_scene = SCENE_MANAGER:GetScene(smithingSceneName)
  if self.allFragment then
    smithing_scene:RemoveFragment(self.allFragment)
  end
  if self.altFragment then
    smithing_scene:RemoveFragment(self.altFragment)
  end
end

function TC_Autocraft:CreateKeyboardUI()
  local smithingSceneName = "smithing"
  local toplevel = ZO_SmithingTopLevel
  local allBtnOrientation = TOP
  local altBtnOrientation = BOTTOM
  local offsetX = 0
  local offsetY = 40
  local font = "ZoFontGameLarge"
  local smithing_scene = SCENE_MANAGER:GetScene(smithingSceneName)
  local allBtnParent = GetControl("TC_ALL_CTL")
  if not allBtnParent then
    allBtnParent = CreateControlFromVirtual("TC_ALL_CTL", toplevel, "TC_ALL_PARENT")
  end
  local altBtnParent = GetControl("TC_ALT_CTL")
  if not altBtnParent then
    altBtnParent = CreateControlFromVirtual("TC_ALT_CTL", toplevel, "TC_ALT_PARENT")
  end
  allBtn = CreateControl(nil, allBtnParent, CT_BUTTON)
  allBtn:SetText(self.parent.Lang.CRAFT_ALL)
  allBtn:SetFont(font)
  allBtn:SetDimensions( allBtnParent:GetWidth() , allBtnParent:GetHeight() )
  allBtn:SetNormalTexture("EsoUI/Art/Buttons/ESO_buttonLarge_normal.dds")
  allBtn:SetPressedTexture("EsoUI/Art/Buttons/ESO_buttonlLarge_mouseDown.dds")
  allBtn:SetMouseOverTexture("EsoUI/Art/Buttons/ESO_buttonLarge_mouseOver.dds")
  allBtn:SetDisabledTexture("EsoUI/Art/Buttons/ESO_buttonLarge_disabled.dds")
  allBtn:SetAnchor(allBtnOrientation, toplevel, allBtnOrientation, 100, 0)
  allBtn:SetHandler("OnClicked", function()
    for id, char in pairs(self.parent.AV.activelyResearchingCharacters) do
      self:ScanUnknownTraitsForCrafting(id)
    end
  end)
  self.allFragment = ZO_SimpleSceneFragment:New(allBtn)
  smithing_scene:AddFragment(self.allFragment)
  for id, char in pairs(self.parent.AV.activelyResearchingCharacters) do
    altBtn = CreateControl(nil, altBtnParent, CT_BUTTON)
    altBtn:SetAnchor(altBtnOrientation, allBtn, altBtnOrientation, offsetX, offsetY)
    altBtn:SetState( NORMAL )
    altBtn:SetDimensions( altBtnParent:GetWidth() , altBtnParent:GetHeight() )
    altBtn:SetNormalTexture("EsoUI/Art/Buttons/ESO_buttonLarge_normal.dds")
    altBtn:SetPressedTexture("EsoUI/Art/Buttons/ESO_buttonlLarge_mouseDown.dds")
    altBtn:SetMouseOverTexture("EsoUI/Art/Buttons/ESO_buttonLarge_mouseOver.dds")
    altBtn:SetDisabledTexture("EsoUI/Art/Buttons/ESO_buttonLarge_disabled.dds")
    offsetY = offsetY + offsetY
    altBtn:SetText(char.name)
    altBtn:SetFont(font)
    altBtn:SetHandler("OnClicked", function()
      self:ScanUnknownTraitsForCrafting(id)
    end)
    self.altFragment = ZO_SimpleSceneFragment:New(altBtn)
    smithing_scene:AddFragment(self.altFragment)
  end
end

function TC_Autocraft:CreateUI()
  if not IsInGamepadPreferredMode() then
    EVENT_MANAGER:RegisterForEvent(self.parent.Name, EVENT_CRAFTING_STATION_INTERACT, function()
      self:CreateKeyboardUI()
    end)
  else
    SCENE_MANAGER:RegisterCallback("SceneStateChanged", function(scene, newState)
      local sceneName = scene:GetName()
      if sceneName == "gamepad_smithing_root" and newState == SCENE_SHOWING then
        self:CreateGamepadUI()
      elseif self.showing then
        self:RemoveGamepadUI()
      end
    end)
  end
end

function TC_Autocraft:Initialize(parent, isCrafter)
  self.parent = parent
  if not LLC then
    return
  end
  self.lastCrafted = {}
  self.rIndices = {}
  self.rObjects = {}
  local origSelf = self
  if not LLC:GetRequestingAddon(parent.Name) then
    local styles = self.parent:GetCommonStyles()
    self.interactionTable = LLC:AddRequestingAddon(parent.Name, false, function (event, craftingType, requestTable)
--       local finalVerdict = true
--       local reasons
--       local requests = origSelf.interactionTable:getAddonCraftingQueue(station)
--       local remainingRequests = {
--           [CRAFTING_TYPE_BLACKSMITHING] = {},
--           [CRAFTING_TYPE_CLOTHIER] = {},
--           [CRAFTING_TYPE_WOODWORKING] = {},
--           [CRAFTING_TYPE_JEWELRYCRAFTING] = {}
--       }
--       local canCraft = {
--           [CRAFTING_TYPE_BLACKSMITHING] = true,
--           [CRAFTING_TYPE_CLOTHIER] = true,
--           [CRAFTING_TYPE_WOODWORKING] = true,
--           [CRAFTING_TYPE_JEWELRYCRAFTING] = true
--       }
--       if requests and next(requests) then
--         for i, request in pairs(requests) do
--           iDex, req = next(request)
--           if req then
--             if req.station == craftingType then
--               reasons = LLC.craftInteractionTables[craftingType].getNonCraftableReasons(req)
--               if reasons and next(reasons) then
--                 canCraft[craftingType] = reasons.finalVerdict
--                 if not reasons.finalVerdict then
--                   requests[i][iDex] = nil
--                 end
--               end
--             else
--               table.insert(remainingRequests[req.station], req)
--             end
--           end
--         end
--       end
--       if not canCraft[craftingType] then
--         ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, "|cc42a04["..parent.Name.."]|r "..parent.Lang.REQUEST_NOT_PROCESSED)
--       end
      return
    end, parent.Author, styles)
  end
  if isCrafter then
    self:CreateUI()
  end
end

function TC_Autocraft:Destroy()
  if IsInGamepadPreferredMode() then
    self:RemoveGamepadUI()
  else
    self:RemoveKeyboardUI()
  end
  if self.parent and self.parent.autocraft then
    self.parent.autocraft = nil
  end
end
