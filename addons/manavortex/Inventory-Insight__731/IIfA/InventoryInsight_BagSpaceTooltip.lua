local CharBagFrame = ZO_Object:Subclass()
IIfA.CharBagFrame = CharBagFrame

local function ColorStart(colorHTML)
  return string.format("%s%s", "|c", string.sub(colorHTML, 1, 6))
end

function CharBagFrame:ComputeColorAndText(spaceCurr, spaceMax)
    local settings = IIFA_DATABASE[IIfA.currentAccount].settings
    local bagSpaceWarn = settings.BagSpaceWarn
    local bagSpaceAlert = settings.BagSpaceAlert
    local colorFull = settings.BagSpaceFull

    local usedBagPercent = tonumber(spaceCurr) * 100 / tonumber(spaceMax)
    local cs = IIfA.EMPTY_STRING

    if spaceCurr == spaceMax then
        cs = ColorStart(IIfA:GetColorHexFromTable(colorFull))
    else
        if usedBagPercent >= bagSpaceAlert.threshold then
            cs = ColorStart(IIfA:GetColorHexFromTable(bagSpaceAlert))
        elseif usedBagPercent >= bagSpaceWarn.threshold then
            cs = ColorStart(IIfA:GetColorHexFromTable(bagSpaceWarn))
        end
    end

    return cs .. spaceCurr
end

function CharBagFrame:SetQty(control, field, qty)
  -- Update a specific field (e.g., spaceUsed or spaceMax) in the UI control
  local ctl = control:GetNamedChild(field)
  ctl:SetText(qty)
end

function CharBagFrame:UpdateAssets()
  -- Access the assets table for the current character and server context
  local assets = IIFA_DATABASE[IIfA.currentAccount].servers[IIfA.currentServerType].assets[IIfA.currentCharacterId]

  if assets ~= nil then
    -- Update assets with current bag usage
    assets.spaceUsed = GetNumBagUsedSlots(BAG_BACKPACK)
    assets.spaceMax = GetBagSize(BAG_BACKPACK)
  end
end

function CharBagFrame:FillCharAndBank()
  self:UpdateAssets()

  local spaceUsed = self.currAssets.spaceUsed
  local spaceMax = self.currAssets.spaceMax
  local bankMax = GetBagSize(BAG_BANK)
  if IsESOPlusSubscriber() then
    bankMax = bankMax + GetBagSize(BAG_SUBSCRIBER_BANK)
  end
  local bankUsed = GetNumBagUsedSlots(BAG_BANK) + GetNumBagUsedSlots(BAG_SUBSCRIBER_BANK)

  self:SetQty(self.charControl, "spaceUsed", self:ComputeColorAndText(spaceUsed, spaceMax))
  self:SetQty(self.charControl, "spaceMax", spaceMax)

  self:SetQty(self.bankControl, "spaceUsed", self:ComputeColorAndText(bankUsed, bankMax))
  self:SetQty(self.bankControl, "spaceMax", bankMax)

  spaceUsed = spaceUsed + bankUsed + self.totSpaceUsed
  spaceMax = spaceMax + bankMax + self.totSpaceMax

  -- Housing chests
  local iChestCount = 0
  local bInOwnedHouse = IsOwnerOfCurrentHouse()

  -- Access houseChestSpace from the appropriate server
  local serverData = IIFA_DATABASE[IIfA.currentAccount].servers[IIfA.currentServerType]
  local houseChestSpace = serverData.houseChestSpace or {}

  for ctr = BAG_HOUSE_BANK_ONE, BAG_HOUSE_BANK_TEN do
    local tControl = self.houseChestControls[ctr]
    if IsCollectibleUnlocked(GetCollectibleForBag(ctr)) then
      local tempUsed
      if bInOwnedHouse then
        tempUsed = GetNumBagUsedSlots(ctr)
        houseChestSpace[ctr] = tempUsed
      else
        tempUsed = houseChestSpace[ctr] or nil
      end

      iChestCount = iChestCount + 1
      if tempUsed then
        tControl:SetHeight(26)
        self:SetQty(tControl, "spaceUsed", self:ComputeColorAndText(tempUsed, GetBagSize(ctr)))
        self:SetQty(tControl, "spaceMax", GetBagSize(ctr))
        local cName = GetCollectibleNickname(GetCollectibleForBag(ctr))
        cName = cName == IIfA.EMPTY_STRING and GetCollectibleName(GetCollectibleForBag(ctr)) or cName
        tControl:GetNamedChild("charName"):SetText(ZO_CachedStrFormat(SI_TOOLTIP_ITEM_TAG_FORMATER, cName))
        spaceUsed = spaceUsed + tempUsed
        spaceMax = spaceMax + GetBagSize(ctr)
      end
    else
      tControl:SetHeight(0)
      tControl:GetNamedChild("charName"):SetText("")
      houseChestSpace[ctr] = nil
    end
  end

  local iDivCount = (iChestCount > 0) and 3 or 2
  if iChestCount > 0 then
    self.divider3:SetHeight(3)
    if not next(houseChestSpace) then
      local alertText = ZO_ERROR_COLOR:Colorize("Enter House once")
      local tControl = self.houseChestControls[BAG_HOUSE_BANK_ONE]
      tControl:SetHeight(26)
      tControl:GetNamedChild("charName"):SetText(alertText)
    end
  end

  -- numchars + numChests + 4 (title line + bank + total + dividers)
  local iFrameHeight = ((GetNumCharacters() + 4 + iChestCount) * 26) + (iDivCount * 3)
  self.frame:SetHeight(iFrameHeight)

  self:SetQty(self.totControl, "spaceUsed", spaceUsed)
  self:SetQty(self.totControl, "spaceMax", spaceMax)
end


-- add iteration for house chests
-- if GetBagSize == 0, you've run out of chests to iterate (break out of loop)
-- /script for i=BAG_HOUSE_BANK_ONE,BAG_MAX_VALUE do d(i .. GetCollectibleName(GetCollectibleForBag(i))) end
-- /script for i=BAG_HOUSE_BANK_ONE,BAG_MAX_VALUE do d(i .. " " .. IsCollectibleUnlocked(GetCollectibleForBag(i))) end

function CharBagFrame:RepaintSpaceUsed()
  -- Access the current account's server-specific data
  local serverData = IIFA_DATABASE[IIfA.currentAccount].servers[IIfA.currentServerType]
  local assets = serverData.assets

  -- Loop through all characters
  for i = 1, GetNumCharacters() do
    local _, _, _, _, _, _, charId, _ = GetCharacterInfo(i)
    local tControl = GetControl("IIFA_GUI_Bag_Grid_Row_" .. i)

    -- Skip the current character
    if charId ~= IIfA.currentCharacterId then
      if assets[charId] ~= nil then
        if assets[charId].spaceUsed ~= nil then
          self:SetQty(tControl, "spaceUsed", self:ComputeColorAndText(assets[charId].spaceUsed, assets[charId].spaceMax))
          self:SetQty(tControl, "spaceMax", assets[charId].spaceMax)
        end
      end
    end
  end
end

function CharBagFrame:Initialize()
  self.frame = IIFA_CharBagFrame
  local tControl
  local prevControl = self.frame
  local currId = IIfA.currentCharacterId

  -- Determine server-specific data
  local serverData = IIFA_DATABASE[IIfA.currentAccount].servers[IIfA.currentServerType]
  serverData.assets = serverData.assets or {}
  self.parent = serverData

  local settingsData = IIFA_DATABASE[IIfA.currentAccount].settings -- Reference settings
  local assets = serverData.assets

  -- Initialize assets for the current character
  if assets[currId] == nil then
    assets[currId] = { spaceUsed = 0, spaceMax = 0 }
  else
    assets[currId].spaceUsed = assets[currId].spaceUsed or 0
    assets[currId].spaceMax = assets[currId].spaceMax or 0
  end

  -- Store colors
  self.ColorWarn = IIfA:GetColorHexFromTable(settingsData.BagSpaceWarn)
  self.ColorAlert = IIfA:GetColorHexFromTable(settingsData.BagSpaceAlert)
  self.ColorFull = IIfA:GetColorHexFromTable(settingsData.BagSpaceFull)

  self.currAssets = assets[currId]

  self.frame:SetAnchor(TOPLEFT, IIFA_GUI_Header_BagButton, TOPRIGHT, 5, 0)
  self.totSpaceUsed = 0
  self.totSpaceMax = 0

  -- Create controls for characters
  for i = 1, GetNumCharacters() do
    local charName, _, _, _, _, alliance, charId, _ = GetCharacterInfo(i)
    charName = ZO_CachedStrFormat(SI_UNIT_NAME, charName)
    tControl = CreateControlFromVirtual("IIFA_GUI_Bag_Grid_Row_" .. i, self.frame, "IIFA_CharBagRow")
    if i == 1 then
      tControl:SetAnchor(TOPLEFT, prevControl:GetNamedChild("_Title"), BOTTOMLEFT, 0, 30)
      prevControl:GetNamedChild("_Title"):SetText("Bag Space")
      prevControl:GetNamedChild("_TitleCharName"):SetText(GetString(SI_GROUP_LIST_PANEL_NAME_HEADER))
    else
      tControl:SetAnchor(TOPLEFT, prevControl, BOTTOMLEFT, 0, 2)
    end
    tControl:GetNamedChild("charName"):SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    tControl:GetNamedChild("charName"):SetText(GetAllianceColor(alliance):Colorize(charName))
    if charId == currId then
      self.charControl = tControl
    else
      if assets[charId] ~= nil then
        if assets[charId].spaceUsed ~= nil then
          self.totSpaceUsed = self.totSpaceUsed + assets[charId].spaceUsed
          self.totSpaceMax = self.totSpaceMax + assets[charId].spaceMax

          self:SetQty(tControl, "spaceUsed", self:ComputeColorAndText(assets[charId].spaceUsed, assets[charId].spaceMax))
          self:SetQty(tControl, "spaceMax", assets[charId].spaceMax)
        end
      end
    end
    prevControl = tControl
  end

  -- Add dividers and other controls
  tControl = CreateControlFromVirtual("IIFA_GUI_Bag_Row_Divider1", self.frame, "ZO_Options_Divider")
  tControl:SetDimensions(288, 3)
  tControl:SetAnchor(TOPLEFT, prevControl, BOTTOMLEFT, 0, 0)
  tControl:SetAlpha(1)
  self.divider1 = tControl

  tControl = CreateControlFromVirtual("IIFA_GUI_Bag_Row_Bank", self.frame, "IIFA_CharBagRow")
  tControl:GetNamedChild("charName"):SetText(GetString(SI_CURRENCYLOCATION1))
  tControl:SetAnchor(TOPLEFT, self.divider1, BOTTOMLEFT, 0, 0)
  self.bankControl = tControl

  tControl = CreateControlFromVirtual("IIFA_GUI_Bag_Row_Divider2", self.frame, "ZO_Options_Divider")
  tControl:SetDimensions(288, 3)
  tControl:SetAnchor(TOPLEFT, self.bankControl, BOTTOMLEFT, 0, 0)
  tControl:SetAlpha(1)
  self.divider2 = tControl

  self.houseChestControls = {}
  serverData.houseChestSpace = serverData.houseChestSpace or {}
  prevControl = self.divider2
  for ctr = BAG_HOUSE_BANK_ONE, BAG_HOUSE_BANK_TEN do
    tControl = CreateControlFromVirtual("IIFA_GUI_Bag_Row_House_Bank" .. ctr, self.frame, "IIFA_CharBagRow")
    tControl:SetAnchor(TOPLEFT, prevControl, BOTTOMLEFT, 0, 0)
    tControl:SetHeight(0)
    self.houseChestControls[ctr] = tControl
    prevControl = tControl
  end

  tControl = CreateControlFromVirtual("IIFA_GUI_Bag_Row_Divider3", self.frame, "ZO_Options_Divider")
  tControl:SetDimensions(288, 0)
  tControl:SetAnchor(TOPLEFT, prevControl, BOTTOMLEFT, 0, 0)
  tControl:SetAlpha(1)
  self.divider3 = tControl

  tControl = CreateControlFromVirtual("IIFA_GUI_Bag_Row_Tots", self.frame, "IIFA_CharBagRow")
  tControl:GetNamedChild("charName"):SetText("Totals")
  tControl:SetAnchor(TOPLEFT, self.divider3, BOTTOMLEFT, 0, 0)
  self.totControl = tControl

  self:FillCharAndBank()

  self.isInitialized = true
end

function CharBagFrame:Show(control)
  if not self.isInitialized then return end -- Check if initialized
  if not self.isShowing then
    self.isShowing = true
    self:FillCharAndBank() -- Populate data when showing the frame
    self.frame:SetHidden(false) -- Show the frame
  end
end

function CharBagFrame:Hide(control)
  if not self.isInitialized then return end -- Check if initialized
  if self.isShowing then
    self.isShowing = false
    self.frame:SetHidden(true) -- Hide the frame
  end
end
