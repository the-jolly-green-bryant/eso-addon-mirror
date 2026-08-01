
function ConfirmMasterWrit:CheckBindButton(bagId, slotIndex)

    if GetItemType(bagId, slotIndex) ~= ITEMTYPE_MASTER_WRIT then
        --self:Debug("　　　　>false(ItemType)")
        return false
    end

    self:Debug("　　[CheckBindButton]")
    local itemLink = GetItemLink(bagId, slotIndex)
    local craftingType = self:GetCraftingTypeByLink(itemLink)
    if not self:ContainsNumber(craftingType, CRAFTING_TYPE_BLACKSMITHING,
                                             CRAFTING_TYPE_CLOTHIER,
                                             CRAFTING_TYPE_WOODWORKING,
                                             CRAFTING_TYPE_JEWELRYCRAFTING) then
        self:Debug("　　　　craftingType=" .. tostring(craftingType))
        self:Debug("　　　　>false(CraftingType)")
        return false
    end

    local stationName = self:GetStationName(craftingType)
    if stationName == nil then
        self:Debug("　　　　>false(StationName)")
        return false
    end


    local key, potency, quality, setId, traitType, styleId
          = string.match(itemLink, "|H%d:item:%d+:%d+:%d+:%d+:%d+:%d+:(%d+):(%d+):(%d+):(%d+):(%d+):(%d+):.*")
    if setId == nil then
        self:Debug("　　　　>false(SetId)")
        return false
    end
    setId = tonumber(setId)


    if self:Confirm(itemLink, true) == false then
        self:Debug("　　　　>false(Confirm)")
        return false
    end

    local toHide = self:IsDebug()
    if toHide then
        self.savedVariables.isDebug = false
    end
    local point = self:LoadPoint(craftingType, setId)
    if point == nil then
        self.savedVariables.isDebug = toHide
        self:Debug("　　　　>false(Point)")
        return false
    end

    local result = self:GetSmithingResult(key, quality, setId, traitType, styleId)
    if result then
        self.savedVariables.isDebug = toHide
        self:Debug("　　　　>false(Created)")
        return false
    end
    self.savedVariables.isDebug = toHide


    local setName = self:GetSetName(setId)
    self:Debug("　　　　>true")
    return true, craftingType, stationName, setId, setName
end




function ConfirmMasterWrit:ClearMarker()

    self:Debug("[ClearMarker]", self.disabledColor)
    CmwWindow:SetHidden(true)
    CmwWindow:Create3DRenderSpace()
    CmwWindow:Set3DRenderSpaceOrigin(0, 0, 0)

    for _, marker in pairs(self.markers) do
        marker:SetHidden(true)
    end
    self.markers = {}

    COMPASS_PINS.pinManager:RemovePins(self.name)
end




function ConfirmMasterWrit:GetBindButtonName()

    local houseOwner = GetCurrentHouseOwner()
    if (not houseOwner) or (houseOwner == "") then
        return nil
    end

    self:Debug("[GetBindButtonName]")
    local itemLink
    local craftingType
    local uniqueId
    local result
    local key, potency, quality, setId, traitType, styleId
    local icon
    local icons = {}
    local slotIndex = ZO_GetNextBagSlotIndex(BAG_BACKPACK, nil)
    while slotIndex do
        if GetItemType(BAG_BACKPACK, slotIndex) == ITEMTYPE_MASTER_WRIT then
            itemLink = GetItemLink(BAG_BACKPACK, slotIndex, LINK_STYLE_DEFAULT)
            craftingType = self:GetCraftingTypeByLink(itemLink)

            if icons[craftingType] == nil
                and self:ContainsNumber(craftingType, CRAFTING_TYPE_BLACKSMITHING,
                                                      CRAFTING_TYPE_CLOTHIER,
                                                      CRAFTING_TYPE_WOODWORKING,
                                                      CRAFTING_TYPE_JEWELRYCRAFTING)
                and self.savedVariables.stationMarkList[craftingType]
                and self:Confirm(itemLink, true) then

                icon = self:GetIconTexture(craftingType)
                uniqueId = Id64ToString(GetItemUniqueId(BAG_BACKPACK, slotIndex))
                result = self.masterWritItemList[uniqueId]
                if result ~= nil and result == false then
                    icons[craftingType] = zo_iconFormat(icon, 40, 40)

                else
                    key, potency, quality, setId, traitType, styleId
                        = string.match(itemLink, "|H%d:item:%d+:%d+:%d+:%d+:%d+:%d+:(%d+):(%d+):(%d+):(%d+):(%d+):(%d+):.*")
                    result = self:GetSmithingResult(key, quality, setId, traitType, styleId)
                    if (result == nil or result == false) then
                        icons[craftingType] = zo_iconFormat(icon, 40, 40)
                    end
                end

            end
        end
        slotIndex = ZO_GetNextBagSlotIndex(BAG_BACKPACK, slotIndex)
    end
    local txt = GetString(SI_WORLD_MAP_ACTION_SET_PLAYER_WAYPOINT)
    if self.allMarked then
        txt = GetString(SI_WORLD_MAP_ACTION_REMOVE_PLAYER_WAYPOINT)
    end
    for _, icon in pairs(icons) do
        txt = txt .. icon
    end
    return txt
end




function ConfirmMasterWrit:GetBindButtonVisible()

    if self.isBindButtonVisible ~= nil then
        return self.isBindButtonVisible
    end

    self:Debug("[GetBindButtonVisible]")

    if (not GetBankingBag() == BAG_BACKPACK) then
        self:Debug("　　>false(No Backpack)")
        return false
    end
    if (not PLAYER_INVENTORY:IsShowingBackpack()) then
        self:Debug("　　>false(No ShowingBackpack)")
        return false
    end
    local houseOwner = GetCurrentHouseOwner()
    if (not houseOwner) or (houseOwner == "") then
        self:Debug("　　>false(No HouseOwner)")
        return false
    end


    local result, craftingType, stationName, setId, setName
    local slotIndex = ZO_GetNextBagSlotIndex(BAG_BACKPACK, nil)
    while slotIndex do
        result, craftingType, stationName, setId, setName = self:CheckBindButton(BAG_BACKPACK, slotIndex)
        if result then
            self:Debug("　　>true")
            self.isBindButtonVisible = true
            return self.isBindButtonVisible
        end
        slotIndex = ZO_GetNextBagSlotIndex(BAG_BACKPACK, slotIndex)
    end

    self.isBindButtonVisible = false
    return self.isBindButtonVisible
end




function ConfirmMasterWrit:GetCraftingTypeByStationName(stationName)

    local keys = {
        {GetString(CMW_ST_BLACKSMITHING),   CRAFTING_TYPE_BLACKSMITHING},
        {GetString(CMW_ST_CLOTHIER),        CRAFTING_TYPE_CLOTHIER},
        {GetString(CMW_ST_WOODWORKING),     CRAFTING_TYPE_WOODWORKING},
        {GetString(CMW_ST_JEWELRY),         CRAFTING_TYPE_JEWELRYCRAFTING},
    }
    for i, key in ipairs(keys) do
        if string.match(stationName, key[1]) then
            return key[2]
        end
    end
    return nil
end




function ConfirmMasterWrit:GetCraftingTypeByText(masterWritText)

    local keys = {
        {GetString(CMW_BLACKSMITHING_WRIT),  CRAFTING_TYPE_BLACKSMITHING},
        {GetString(CMW_CLOTHIER_WRIT1),      CRAFTING_TYPE_CLOTHIER},
        {GetString(CMW_CLOTHIER_WRIT2),      CRAFTING_TYPE_CLOTHIER},
        {GetString(CMW_WOODWORKING),         CRAFTING_TYPE_WOODWORKING},
        {GetString(CMW_JEWELRYCRAFTING),     CRAFTING_TYPE_JEWELRYCRAFTING},
    }
    for i, key in ipairs(keys) do
        if string.match(masterWritText, key[1]) then
            return key[2]
        end
    end
    return nil
end




function ConfirmMasterWrit:GetIconTexture(craftingType, useMarker)

    local textures
    if useMarker then
        textures = {
            [CRAFTING_TYPE_BLACKSMITHING]   = "esoui/art/inventory/inventory_tabicon_craftbag_blacksmithing_down.dds",
            [CRAFTING_TYPE_CLOTHIER]        = "esoui/art/inventory/inventory_tabicon_craftbag_clothing_down.dds",
            [CRAFTING_TYPE_WOODWORKING]     = "esoui/art/inventory/inventory_tabicon_craftbag_woodworking_down.dds",
            [CRAFTING_TYPE_JEWELRYCRAFTING] = "esoui/art/inventory/inventory_tabIcon_craftbag_jewelrycrafting_down.dds",
        }
    else
        textures = {
            [CRAFTING_TYPE_BLACKSMITHING]   = "esoui/art/inventory/inventory_tabicon_craftbag_blacksmithing_up.dds",
            [CRAFTING_TYPE_CLOTHIER]        = "esoui/art/inventory/inventory_tabicon_craftbag_clothing_up.dds",
            [CRAFTING_TYPE_WOODWORKING]     = "esoui/art/inventory/inventory_tabicon_craftbag_woodworking_up.dds",
            [CRAFTING_TYPE_JEWELRYCRAFTING] = "esoui/art/inventory/inventory_tabIcon_craftbag_jewelrycrafting_up.dds",
        }
    end
    return textures[craftingType]
end




function ConfirmMasterWrit:GetItemSetId(txt)

    local setIds = LibSets.GetAllSetIds()
    local itemLink
    local hasSet, setName
    for setId, isExists in pairs(setIds) do
        if isExists and LibSets.GetSetType(setId) == LIBSETS_SETTYPE_CRAFTED then
            itemLink = LibSets.buildItemLink(LibSets.GetSetItemId(setId, EQUIP_TYPE_CHEST))
            hasSet, setName = GetItemLinkSetInfo(itemLink, false)
            self:Debug("　　　　" .. tostring(itemLink) .. "," .. tostring(hasSet) .. "," .. tostring(setName))
            if hasSet and setName and (string.match(txt, setName) or string.match(setName, txt)) then
                return setId, setName
            end
        end
    end
    return nil, nil
end




function ConfirmMasterWrit:GetSetName(setId)

    if setId == nil then
        return nil
    end

    setId = tonumber(setId)
    local setName = self.setNameList[setId]
    if setName then
        return setName
    end

    local itemLink = LibSets.buildItemLink(LibSets.GetSetItemId(setId, EQUIP_TYPE_CHEST))
    local hasSet, setName = GetItemLinkSetInfo(itemLink, false)
    self.setNameList[setId] = setName
    self.setIdList[setName] = setId

    return setName
end




function ConfirmMasterWrit:GetSetInfo(txt)

    --self:Debug("　　　　[GetSetInfo]")
    local setId = self.setIdList[txt]
    if setId then
        return setId, self:GetSetName(setId)
    end


    local setIds = LibSets.GetAllSetIds()
    local itemLink
    local hasSet, setName
    for setId, isExists in pairs(setIds) do
        if isExists and LibSets.GetSetType(setId) == LIBSETS_SETTYPE_CRAFTED then
            itemLink = LibSets.buildItemLink(LibSets.GetSetItemId(setId, EQUIP_TYPE_CHEST))
            hasSet, setName = GetItemLinkSetInfo(itemLink, false)
            --self:Debug("　　　　" .. tostring(itemLink) .. "," .. tostring(hasSet) .. "," .. tostring(setName))
            if hasSet and setName and (string.match(txt, setName) or string.match(setName, txt)) then
                self.setNameList[setId] = setName
                self.setIdList[setName] = setId
                return setId, setName
            end
        end
    end
    return nil, nil

end




function ConfirmMasterWrit:GetStationName(craftingType)

    --self:Debug("　　[GetStationName]")
    local list = {
        [CRAFTING_TYPE_BLACKSMITHING]   = GetString(CMW_ST_BLACKSMITHING),
        [CRAFTING_TYPE_CLOTHIER]        = GetString(CMW_ST_CLOTHIER),
        [CRAFTING_TYPE_WOODWORKING]     = GetString(CMW_ST_WOODWORKING),
        [CRAFTING_TYPE_JEWELRYCRAFTING] = GetString(CMW_ST_JEWELRY),
        [CRAFTING_TYPE_ALCHEMY]         = nil,
        [CRAFTING_TYPE_PROVISIONING]    = nil,
        [CRAFTING_TYPE_ENCHANTING]      = nil,
    }
    return list[craftingType]
end




function ConfirmMasterWrit:LoadPoint(craftingType, setId)

    self:Debug("　　　　[LoadPoint(<<1>>:<<2>>, setId:<<3>>)]", craftingType,
                                                                self:GetStationName(craftingType),
                                                                setId)
    local zoneName = GetUnitZone("player") .. tostring(GetCurrentHouseOwner())
    local locationList = self.savedVariables.locationList
    local location = locationList[zoneName]
    if location == nil then
        return nil
    end

    local set = location[setId]
    if set == nil then
        return nil
    end

    local setName = set["setName(" .. GetCVar("language.2") .. ")"]
    self:Debug("　　　　　　setName=" .. tostring(setName))

    local point = set[craftingType]
    self:Debug("　　　　　　> point=" .. tostring(point))
    return point
end




function ConfirmMasterWrit:QuestTrackerChanged(unassistedData, assistedData)

    self:Debug("[QuestTrackerChanged]")
    zo_callLater(function()

        if (not Lib3D) then
            self:DebugIfMarify("|cFF0000" ..  "Lib3D nil !!!" .. "|r")
            return
        end
        if (not Lib3D:IsValidZone()) then
            self:Debug("|cFF0000" ..  "Lib3D not ValidZone !!!" .. "|r")
            zo_callLater(function()
                self:Debug("[QuestTrackerChanged]")
                self:QuestTrackerChanged(unassistedData, assistedData)
            end, 2000)
            return
        end
        if assistedData and assistedData.trackType == TRACK_TYPE_QUEST then
            CmwWindow:Create3DRenderSpace()
            CmwWindow:Set3DRenderSpaceOrigin(0, 0, 0)
            self.target = nil
            self.allMarked = false
            self:ClearMarker()
            self:UpdateMarker(assistedData.arg1)
        end
    end, 3000)
end




function ConfirmMasterWrit:ReticleUpdate(...)

    local action, interactName = GetGameCameraInteractableActionInfo()
    if action ~= GetString(SI_GAMECAMERAACTIONTYPE5) then
        return
    end
    if self.interactName == interactName then
        return
    end
    self.interactName = interactName


    self:Debug("[ReticleUpdate]")
    local stationName, _, stationSetName = string.match(interactName, "(.*)(%s*)[(](.*)[)]")
    --self:Debug("　　stationName=\"" .. tostring(stationName) .. "\"")
    --self:Debug("　　stationSetName=\"" .. tostring(stationSetName) .. "\"")
    if (not stationSetName) then
        return
    end


    local craftingType = self:GetCraftingTypeByStationName(stationName)
    if (not craftingType) then
        return
    end


    self:SavePoint(craftingType, stationSetName)
end




function ConfirmMasterWrit:SavePoint(craftingType, name, isPrioritize)

    self:Debug("　　[SavePoint(<<1>>:<<2>>, <<3>>)]", name,
                                                      craftingType,
                                                      self:GetStationName(craftingType))
    local stationName = self:GetStationName(craftingType)

    local setId, setName = self:GetSetInfo(name)
    if setId == nil then
        return
    end

    local houseOwner = GetCurrentHouseOwner()
    if (not houseOwner) or (houseOwner == "") then
        return
    end
    local lang = "(" .. GetCVar("language.2") .. ")"
    local zoneName = GetUnitZone("player") .. tostring(GetCurrentHouseOwner())

    local locationList = self.savedVariables.locationList
    local location = locationList[zoneName]
    if (not location) then
        location = {}
        locationList[zoneName] = location
        self:DebugIfMarify(zo_strformat("|c00FF7FNewLocation [<<1>>]|r", zoneName))
    end
    location["zoneName" .. lang] = zoneName


    local set = location[setId]
    if set == nil then
        set = {}
        location[setId] = set
        self:DebugIfMarify(zo_strformat("|c00FF7FNewSet <<1>>:<<2>> [<<3>>]|r", setId, setName, zoneName))
    end
    if set[craftingType] == nil then
        local icon = zo_iconFormat(self:GetIconTexture(craftingType), 28, 28)
        self:DebugIfMarify(zo_strformat("|c00FF7FNewStation <<1>><<2>>:<<3>> [<<4>>]|r", icon,
                                                                                         setId,
                                                                                         setName,
                                                                                         zoneName))
    end
    set["setName" .. lang] = setName


    if isPrioritize then
        local _, worldX, worldY, worldZ = GetUnitWorldPosition("player")
        self:Debug("　　　　zoneName<<1>>=<<2>>", lang, zoneName)
        self:Debug("　　　　worldX=" .. tostring(worldX)
                       .. " worldY=" .. tostring(worldY)
                       .. " worldZ=" .. tostring(worldZ))
        set[craftingType] = table.concat({worldX, worldY + 200, worldZ, "true"}, ",")
        return
    end

    local oldPrioritize
    if set[craftingType] then
        oldPrioritize = string.match(set[craftingType], "%d+,%d+,%d+,(.*)")
    end
    if oldPrioritize == nil then
        local _, worldX, worldY, worldZ = GetUnitWorldPosition("player")
        self:Debug("　　　　zoneName<<1>>=<<2>>", lang, zoneName)
        self:Debug("　　　　worldX=" .. tostring(worldX)
                       .. " worldY=" .. tostring(worldY)
                       .. " worldZ=" .. tostring(worldZ))
        set[craftingType] = table.concat({worldX, worldY + 200, worldZ}, ",")
    end
end




function ConfirmMasterWrit:ShowContextMenu(inventorySlot, slotActions)

    self:Debug("[ShowContextMenu]")

    if (not GetBankingBag() == BAG_BACKPACK) then
        self:Debug("　　>false(Bag)")
        return
    end

    if (not PLAYER_INVENTORY:IsShowingBackpack()) then
        self:Debug("　　>false(ShowingBackpack)")
        return
    end

    local houseOwner = GetCurrentHouseOwner()
    if (not houseOwner) or (houseOwner == "") then
        self:Debug("　　>false(House)")
        return
    end

    local slotType = ZO_InventorySlot_GetType(inventorySlot)
    if slotType ~= SLOT_TYPE_ITEM then
        return
    end

    local bagId, slotIndex = ZO_Inventory_GetBagAndIndex(inventorySlot)
    local result, craftingType, stationName, setId, setName = self:CheckBindButton(bagId, slotIndex)
    if result == false then
        return
    end

    local icon = zo_iconFormat(self:GetIconTexture(craftingType), 28, 28)
    local marker = self.markers[craftingType .. "-" .. setId]
    if marker then
        local format = GetString(SI_WORLD_MAP_ACTION_REMOVE_PLAYER_WAYPOINT) .. ": <<1>><<2>>"
        local title = zo_strformat(format, icon, setName)
        AddCustomMenuItem(title, function()
            COMPASS_PINS.pinManager:RemovePins(self.name)
            marker:SetHidden(true)
            self.markers[craftingType .. "-" .. setId] = nil
        end, MENU_ADD_OPTION_LABEL)

    else
        local format = GetString(SI_WORLD_MAP_ACTION_SET_PLAYER_WAYPOINT) .. ": <<1>><<2>>"
        local title = zo_strformat(format, icon, setName)
        AddCustomMenuItem(title, function()
            self.target = GenerateMasterWritBaseText(GetItemLink(bagId, slotIndex))
            self:UpdateMarker()
        end, MENU_ADD_OPTION_LABEL)
    end
end




function ConfirmMasterWrit:ShowMarker()

    self:ClearMarker()
    if (not self.allMarked) then
        if self:UpdateMarkerAll() then
            CmwWindow:SetHidden(false)
        end
    end
    self.allMarked = (not self.allMarked)
    KEYBIND_STRIP:UpdateKeybindButton(self.bindButton)
end




function ConfirmMasterWrit:StationInteract(eventCode, craftingType, sameStation)

    self:Debug("[StationInteract]")

    self:ClearMarker()
    if (not craftingType) then
        return
    elseif craftingType == CRAFTING_TYPE_ALCHEMY then
        return
    elseif craftingType == CRAFTING_TYPE_ENCHANTING then
        return
    end


    local _, interactName = GetGameCameraInteractableActionInfo()
    if (not interactName) then
        return
    end


    local stationSetName = string.match(interactName, ".*[(](.*)[)]")
    if (not stationSetName) then
        return
    end


    self.interactName = interactName
    self:SavePoint(craftingType, stationSetName, true)
end




function ConfirmMasterWrit:UpdateFloorMark(control, itemLink)

    local houseOwner = GetCurrentHouseOwner()
    if (not houseOwner) or (houseOwner == "") then
        return
    end

    self:Debug("　　[UpdateFloorMark]")
    local floorMark = control:GetNamedChild("CMW_FloortMark")
    if floorMark then
        floorMark:SetHidden(true)
    end

    if (not self.savedVariables.floorMark) then
        return
    end

    local craftingType = self:GetCraftingTypeByLink(itemLink)
    if craftingType == nil then
        return
    end
    if self.savedVariables.stationMarkList[craftingType] == false then
        return
    end

    local stationName = self:GetStationName(craftingType)
    if stationName == nil then
        return
    end

    local key, potency, quality, setId, traitType, styleId
          = string.match(itemLink, "|H%d:item:%d+:%d+:%d+:%d+:%d+:%d+:(%d+):(%d+):(%d+):(%d+):(%d+):(%d+):.*")
    if setId == nil then
        return false
    end
    setId = tonumber(setId)

    local point = self:LoadPoint(craftingType, setId)
    if point == nil then
        return false
    end

    if self:Confirm(itemLink, true) == false then
        return false
    end

    local _, worldY = string.match(point, "(%d+),(%d+),(%d+)")
    local _, _, playerY = GetUnitWorldPosition("player")


    floorMark = control:GetNamedChild("CMW_FloortMark")
    if floorMark == nil then
        floorMark = WINDOW_MANAGER:CreateControl(control:GetName() .. "CMW_FloortMark", control, CT_TEXTURE)
        floorMark:SetDrawLayer(3)
        floorMark:ClearAnchors()
    end
    if tonumber(worldY) < playerY then
        floorMark:SetTexture("esoui/art/buttons/gamepad/gp_downarrow.dds")
        floorMark:SetDimensions(20, 20)
        floorMark:SetAnchor(LEFT, control:GetNamedChild('Bg'), LEFT, 90, 0)
        floorMark:SetColor(0.3, 0.3, 0.3, 0.9)

    elseif tonumber(worldY) > (playerY + 400) then
        floorMark:SetTexture("esoui/art/buttons/gamepad/gp_uparrow.dds")
        floorMark:SetDimensions(20, 20)
        floorMark:SetAnchor(LEFT, control:GetNamedChild('Bg'), LEFT, 90, 0)
        floorMark:SetColor(0.3, 0.3, 0.3, 0.9)

    else
        floorMark:SetTexture("esoui/art/buttons/gamepad/gp_menu_rightarrow.dds")
        floorMark:SetDimensions(28, 28)
        floorMark:SetAnchor(LEFT, control:GetNamedChild('Bg'), LEFT, 87, 0)
        floorMark:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_SELECTED))
    end
    floorMark:SetHidden(false)
    return

end




function ConfirmMasterWrit:UpdateMarker(questIndex)

    self:Debug("[UpdateMarker]")
    self:ClearMarker()
    EVENT_MANAGER:UnregisterForUpdate(self.name)
    self.pinTag.isHidden = true

    if self.target then
        self:ClearMarker()
        if self:UpdateMarkerPoint(self.target, true) then
            CmwWindow:SetHidden(false)
            self:UpdateMarkerOrientation()
            return
        end
    elseif self.allMarked then
        self:ClearMarker()
        if self:UpdateMarkerAll() then
            CmwWindow:SetHidden(false)
        end
        return
    end


    if (not questIndex) then
        for i = 1, MAX_JOURNAL_QUESTS do
            if GetTrackedIsAssisted(TRACK_TYPE_QUEST, i) then
                questIndex = i
            end
        end
    end
    if (not questIndex) then
        return
    end

    local questName = GetJournalQuestName(questIndex)
    if (not string.match(questName, GetString(CMW_CRAFTING_MASTER))) then
        return
    end

    for conditionIndex = 1, GetJournalQuestNumConditions(questIndex, 1) do
        local conditionText, _, _, _, _, _, isVisible = GetJournalQuestConditionInfo(questIndex, 1, conditionIndex)
        self:ClearMarker()
        if isVisible and self:UpdateMarkerPoint(conditionText, true) then
            self:UpdateMarkerOrientation()
            return
        end
    end
end




function ConfirmMasterWrit:UpdateMarkerAll()

    self:Debug("[UpdateMarkerAll]")
    local houseOwner = GetCurrentHouseOwner()
    if (not houseOwner) or (houseOwner == "") then
        return
    end


    self:Debug("　　allMarked=" .. tostring(self.allMarked))
    self.target = nil
    local itemLink
    local masterWritText
    local marker
    local uniqueId
    local result
    local key, potency, quality, setId, traitType, styleId
    local craftingType
    local isShown = false
    local slotIndex = ZO_GetNextBagSlotIndex(BAG_BACKPACK, nil)
    while slotIndex do
        if GetItemType(BAG_BACKPACK, slotIndex) == ITEMTYPE_MASTER_WRIT then
            itemLink = GetItemLink(BAG_BACKPACK, slotIndex, LINK_STYLE_DEFAULT)
            craftingType = self:GetCraftingTypeByLink(itemLink)
            if self.savedVariables.stationMarkList[craftingType] then
                masterWritText = GenerateMasterWritBaseText(itemLink)
                marker = self:UpdateMarkerPoint(masterWritText, false)
                if marker then
                    uniqueId = Id64ToString(GetItemUniqueId(BAG_BACKPACK, slotIndex))
                    result = self.masterWritItemList[uniqueId]
                    if result then
                        marker:SetHidden(true)
                    elseif self:Confirm(itemLink, true) == false then
                        marker:SetHidden(true)
                    else
                        key, potency, quality, setId, traitType, styleId
                            = string.match(itemLink, "|H%d:item:%d+:%d+:%d+:%d+:%d+:%d+:(%d+):(%d+):(%d+):(%d+):(%d+):(%d+):.*")
                        if self:GetSmithingResult(key, quality, setId, traitType, styleId) then
                            marker:SetHidden(true)
                        else
                            isShown = true
                        end
                    end
                end
            end
        end
        slotIndex = ZO_GetNextBagSlotIndex(BAG_BACKPACK, slotIndex)
    end
    return isShown
end




function ConfirmMasterWrit:UpdateMarkerOrientation()

    for _, marker in pairs(self.markers) do
        if (not marker:IsHidden()) then
            marker:Set3DRenderSpaceOrientation(0, self.heading, 0)
            self.heading = self.heading + 0.2
            if (self.heading - GetPlayerCameraHeading()) >= 8.9 then
                self.heading = GetPlayerCameraHeading()
            end
        end
    end
end




function ConfirmMasterWrit:UpdateMarkerPoint(masterWritText, isOnce)

    self:Debug("　　[UpdateMarkerPoint]")

    local craftingType = self:GetCraftingTypeByText(masterWritText)
    if craftingType == nil then
        return false
    end

    local setId, setName = self:GetSetInfo(masterWritText)
    if setId == nil then
        return false
    end

    local point = self:LoadPoint(craftingType, setId)
    if point == nil then
        return false
    end

    if self.markers[craftingType .. "-" .. setId] then
        return false
    end


    local color = self.pinTag.color
    local texture = self:GetIconTexture(craftingType, true)
    local worldX, worldY, worldZ, isPrioritize = string.match(point, "(%d+),(%d+),(%d+)")
    local guiX, guiY, guiZ = WorldPositionToGuiRender3DPosition(worldX, worldY, worldZ)
    local _, _, playerY = GetUnitWorldPosition("player")
    local markerName = "Marker" .. craftingType .. "-" .. setId
    local marker = GetControl(CmwWindow, markerName)
    if marker == nil then
        marker = WINDOW_MANAGER:CreateControl("$(parent)" .. markerName, CmwWindow, CT_TEXTURE)
        marker:Create3DRenderSpace()
        marker:Set3DLocalDimensions(1.4, 1.4)
        marker:SetTexture(texture)
        marker:SetColor(color[1], color[2], color[3], color[4])
    end
    marker:Set3DRenderSpaceOrigin(tonumber(guiX), tonumber(guiY), tonumber(guiZ))
    marker:SetHidden(false)
    self.heading = GetPlayerCameraHeading()
    EVENT_MANAGER:RegisterForUpdate(self.name, 100, function(...) self:UpdateMarkerOrientation() end)

    if isOnce then
        local localX, localZ = Lib3D:WorldToLocal(worldX / 100, worldZ / 100)
        self.pinTag.isHidden = false
        self.pinTag.x = tonumber(localX)
        self.pinTag.y = tonumber(localZ)
        self.pinTag.texture = texture
        local compassCallback = function(pinManager)
            local pinTag = ConfirmMasterWrit.pinTag
            pinManager:CreatePin(ConfirmMasterWrit.name, pinTag, pinTag.x, pinTag.y)
        end
        COMPASS_PINS:AddCustomPin(self.name, compassCallback, self.compassPinLayout)
        COMPASS_PINS:RefreshPins(self.name)
    end

    self:Debug("　　　　>" .. craftingType .. "-" .. setId)
    self.markers[craftingType .. "-" .. setId] = marker
    return marker
end

