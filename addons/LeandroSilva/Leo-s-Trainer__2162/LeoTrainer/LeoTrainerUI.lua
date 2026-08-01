
LeoTrainerUI.hidden = true

local function addLine(tooltip, text, color, alignment)
    if not color then color = ZO_TOOLTIP_DEFAULT_COLOR end
    local r, g, b = color:UnpackRGB()
    tooltip:AddLine(text, "LeoTrainerNormalFont", r, g, b, CENTER, MODIFY_TEXT_TYPE_NONE, alignment, alignment ~= TEXT_ALIGN_LEFT)
end

local function addLineTitle(tooltip, text, color)
    if not color then color = ZO_SELECTED_TEXT end
    local r, g, b = color:UnpackRGB()
    tooltip:AddLine(text, "ZoFontHeader3", r, g, b, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
end

local function addLineSubTitle(tooltip, text, color, alignment)
    if not color then color = ZO_SELECTED_TEXT end
    if not alignment then alignment = TEXT_ALIGN_CENTER end
    local r, g, b = color:UnpackRGB()
    tooltip:AddLine(text, "ZoFontWinH3", r, g, b, CENTER, MODIFY_TEXT_TYPE_NONE, alignment, true)
end

function LeoTrainerUI:OnWindowMoveStop()
    LeoTrainer.savedVariables.position = {
        left = LeoTrainerWindow:GetLeft(),
        top = LeoTrainerWindow:GetTop()
    }
end

function LeoTrainerUI:OnHide(control, hidden)
    if hidden then LeoTrainerUI.HideUI() end
end

function LeoTrainerUI:OnShow(control, hidden)
    if not hidden then LeoTrainerUI.ShowUI() end
end

function LeoTrainerUI:isHidden()
    return LeoTrainerUI.hidden
end

function LeoTrainerUI.RestorePosition()
    local position = LeoTrainer.savedVariables.position or { left = 200; top = 200; }
    local left = position.left
    local top = position.top

    LeoTrainerWindow:ClearAnchors()
    LeoTrainerWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
    LeoTrainerWindow:SetDrawLayer(DL_OVERLAY)
    LeoTrainerWindow:SetDrawTier(DT_MEDIUM)
end

function LeoTrainerUI.CloseUI()
    SCENE_MANAGER:HideTopLevel(LeoTrainerWindow)
end

function LeoTrainerUI.ShowUI()
    LeoTrainer.UpdateUI()
    LeoTrainer.hidden = false;
end

function LeoTrainerUI.HideUI()
    LeoTrainer.hidden = true;
end

function LeoTrainerUI.ToggleUI()
    SCENE_MANAGER:ToggleTopLevel(LeoTrainerWindow)
end

function LeoTrainer:OnMouseEnterTrait(control)
    InitializeTooltip(ItemTooltip, control, LEFT, 5, 0)
    ItemTooltip:SetLink(ZO_LinkHandler_CreateLink("",nil,ITEM_LINK_TYPE,control.materialItemID,30,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0))
    ItemTooltip:SetHidden(false)
end

local function copy(obj, seen)
    if type(obj) ~= 'table' then return obj end
    if seen and seen[obj] then return seen[obj] end
    local s = seen or {}
    local res = setmetatable({}, getmetatable(obj))
    s[obj] = res
    for k, v in pairs(obj) do res[copy(k, s)] = copy(v, s) end
    return res
end

LeoTrainerQueueList = ZO_SortFilterList:Subclass()
function LeoTrainerQueueList:New(control)

    ZO_SortFilterList.InitializeSortFilterList(self, control)

    local sorterKeys =
    {
        ["trainer"] = {},
        ["trainee"] = { tiebreaker = "trainer"},
        ["researchName"] = { tiebreaker = "trainee"},
        ["item"] = { tiebreaker = "researchName"},
    }

    self.masterList = {}
    self.currentSortKey = "trainee"
    self.currentSortOrder = ZO_SORT_ORDER_UP
    ZO_ScrollList_AddDataType(self.list, 1, "LeoTrainerQueueListTemplate", 32, function(control, data) self:SetupEntry(control, data) end)

    self.sortFunction = function(listEntry1, listEntry2)
        return ZO_TableOrderingFunction(listEntry1.data, listEntry2.data, self.currentSortKey, sorterKeys, self.currentSortOrder)
    end

    return self
end

function LeoTrainerQueueList:SetupEntry(control, data)

    control.data = data

    control.trainer = GetControl(control, "Trainer")
    control.trainer:SetText(data.trainer)
    control.trainer.knownList = data.knownList
    if data.knownList ~= nil and #data.knownList > 1 then
        control.trainer:SetHandler('OnMouseEnter', function(self)
            InitializeTooltip(InformationTooltip, self, LEFT, 5, 0)
            addLineTitle(InformationTooltip, "Trainers", ZO_TOOLTIP_DEFAULT_COLOR)
            ZO_Tooltip_AddDivider(InformationTooltip)

            for _, knowName in pairs(data.knownList) do
                addLine(InformationTooltip, knowName, LeoTrainer.const.colors.green)
            end

            addLine(InformationTooltip, zo_iconTextFormat("esoui/art/icons/icon_lmb.dds", 26, 26, "Change Trainer"))
            InformationTooltip:SetHidden(false)
        end)
        control.trainer:SetHandler('OnMouseUp', function(control, button, upInside)
            if not upInside or (button ~= MOUSE_BUTTON_INDEX_RIGHT and button ~= MOUSE_BUTTON_INDEX_LEFT) then return end
            local newTrainer
            for trainerIndex, trainer in pairs(data.knownList) do
                if trainer == data.trainer then
                    if trainerIndex < #data.knownList then
                        newTrainer = data.knownList[trainerIndex + 1]
                    else
                        newTrainer = data.knownList[1]
                    end
                    break
                end
            end
            LeoTrainer.savedVariables.queue[data.queueIndex].trainer = newTrainer
            LeoTrainer.queueScroll:RefreshData()
        end)
    end

    control.trainee = GetControl(control, "Trainee")
    control.trainee:SetText(data.trainee)

    control.researchName = GetControl(control, "Trait")
    control.researchName:SetText(data.researchName)

    control.item = GetControl(control, "Item")
    control.item:SetText(data.itemLink)
    control.item:SetHandler('OnMouseUp', function(control, button, upInside)
        if upInside == false then return end
        if button == MOUSE_BUTTON_INDEX_RIGHT then
            LeoTrainer.RemoveFromQueue(data.queueIndex)
        end
    end)

    ZO_SortFilterList.SetupRow(self, control, data)
end

function LeoTrainerQueueList:BuildMasterList()
    self.masterList = {}
    local list = LeoTrainer.GetQueue()
    if list then
        for k, v in ipairs(list) do
            local data = copy(v)
            data.queueIndex = k
            table.insert(self.masterList, data)
        end
    end
end

function LeoTrainerQueueList:SortScrollList()
    local scrollData = ZO_ScrollList_GetDataList(self.list)
    table.sort(scrollData, self.sortFunction)
end

function LeoTrainerQueueList:FilterScrollList()

    local scrollData = ZO_ScrollList_GetDataList(self.list)
    ZO_ClearNumericallyIndexedTable(scrollData)

    for i = 1, #self.masterList do
        local data = self.masterList[i]
        local canShow = true
        if canShow == true and LeoTrainer.inStation > 0 and data.craft ~= LeoTrainer.inStation then
            canShow = false
        end
        if LeoTrainer.inStation > 0 and data.trainer ~= "Anyone" and data.trainer ~= LeoAltholic.CharName then
            canShow = false
        end
        if canShow then
            table.insert(scrollData, ZO_ScrollList_CreateDataEntry(1, data))
        end
    end
end

local function getResearchData(link)
    if not link then return false end

    local craft, line
    local trait = GetItemLinkTraitInfo(link)
    local equipType = GetItemLinkEquipType(link)

    if trait == ITEM_TRAIT_TYPE_NONE or trait == ITEM_TRAIT_TYPE_ARMOR_INTRICATE or trait == ITEM_TRAIT_TYPE_ARMOR_ORNATE
        or trait == ITEM_TRAIT_TYPE_WEAPON_INTRICATE or trait == ITEM_TRAIT_TYPE_WEAPON_ORNATE
        or trait == ITEM_TRAIT_TYPE_JEWELRY_INTRICATE or trait == ITEM_TRAIT_TYPE_JEWELRY_ORNATE then return false end

    local armorType = GetItemLinkArmorType(link)
    local weaponType = GetItemLinkWeaponType(link)
    if trait == ITEM_TRAIT_TYPE_ARMOR_NIRNHONED then trait = 19 end
    if trait == ITEM_TRAIT_TYPE_WEAPON_NIRNHONED then trait = 9 end
    if weaponType == WEAPONTYPE_AXE then craft = CRAFTING_TYPE_BLACKSMITHING; line = 1;
    elseif weaponType == WEAPONTYPE_HAMMER then craft = CRAFTING_TYPE_BLACKSMITHING; line = 2;
    elseif weaponType == WEAPONTYPE_SWORD then craft = CRAFTING_TYPE_BLACKSMITHING; line = 3
    elseif weaponType == WEAPONTYPE_TWO_HANDED_AXE then craft = CRAFTING_TYPE_BLACKSMITHING; line = 4;
    elseif weaponType == WEAPONTYPE_TWO_HANDED_HAMMER then craft = CRAFTING_TYPE_BLACKSMITHING; line = 5;
    elseif weaponType == WEAPONTYPE_TWO_HANDED_SWORD then craft = CRAFTING_TYPE_BLACKSMITHING; line = 6;
    elseif weaponType == WEAPONTYPE_DAGGER then craft = CRAFTING_TYPE_BLACKSMITHING; line = 7;
    elseif weaponType == WEAPONTYPE_BOW then craft = CRAFTING_TYPE_WOODWORKING; line = 1;
    elseif weaponType == WEAPONTYPE_FIRE_STAFF then craft = CRAFTING_TYPE_WOODWORKING; line = 2;
    elseif weaponType == WEAPONTYPE_FROST_STAFF then craft = CRAFTING_TYPE_WOODWORKING; line = 3;
    elseif weaponType == WEAPONTYPE_LIGHTNING_STAFF then craft = CRAFTING_TYPE_WOODWORKING; line = 4;
    elseif weaponType == WEAPONTYPE_HEALING_STAFF then craft = CRAFTING_TYPE_WOODWORKING; line = 5;
    elseif weaponType == WEAPONTYPE_SHIELD then craft = CRAFTING_TYPE_WOODWORKING; line = 6;trait=trait-10;
    elseif equipType == EQUIP_TYPE_CHEST then line = 1
    elseif equipType == EQUIP_TYPE_FEET then line = 2
    elseif equipType == EQUIP_TYPE_HAND then line = 3
    elseif equipType == EQUIP_TYPE_HEAD then line = 4
    elseif equipType == EQUIP_TYPE_LEGS then line = 5
    elseif equipType == EQUIP_TYPE_SHOULDERS then line = 6
    elseif equipType == EQUIP_TYPE_WAIST then line = 7
    end

    if equipType == EQUIP_TYPE_NECK or equipType == EQUIP_TYPE_RING then
        craft = CRAFTING_TYPE_JEWELRYCRAFTING
        line = equipType == EQUIP_TYPE_NECK and 1 or 2
        if trait == ITEM_TRAIT_TYPE_JEWELRY_ARCANE then trait = 1
        elseif trait == ITEM_TRAIT_TYPE_JEWELRY_HEALTHY then trait = 2
        elseif trait == ITEM_TRAIT_TYPE_JEWELRY_ROBUST then trait = 3
        elseif trait == ITEM_TRAIT_TYPE_JEWELRY_TRIUNE then trait = 4
        elseif trait == ITEM_TRAIT_TYPE_JEWELRY_INFUSED then trait = 5
        elseif trait == ITEM_TRAIT_TYPE_JEWELRY_PROTECTIVE then trait = 6
        elseif trait == ITEM_TRAIT_TYPE_JEWELRY_SWIFT then trait = 7
        elseif trait == ITEM_TRAIT_TYPE_JEWELRY_HARMONY then trait = 8
        elseif trait == ITEM_TRAIT_TYPE_JEWELRY_BLOODTHIRSTY then trait = 9
        end
    else
        if armorType == ARMORTYPE_HEAVY then craft = CRAFTING_TYPE_BLACKSMITHING; line = line + 7; trait = trait - 10; end
        if armorType == ARMORTYPE_MEDIUM then craft = CRAFTING_TYPE_CLOTHIER; line = line + 7; trait = trait - 10; end
        if armorType == ARMORTYPE_LIGHT then craft = CRAFTING_TYPE_CLOTHIER; trait = trait - 10; end
    end
    if craft and line and trait then return craft, line, trait
    else return false end
end

local function scanItems(bag)
    local list = {}
    if not bag then bag = SHARED_INVENTORY:GenerateFullSlotData(nil,BAG_BACKPACK,BAG_BANK) end
    for _, data in pairs(bag) do
        local itemLink = GetItemLink(data.bagId,data.slotIndex)
        local type = GetItemType(data.bagId,data.slotIndex)

        if type == ITEMTYPE_ARMOR or type == ITEMTYPE_WEAPON then
            local traitType, _ = GetItemLinkTraitInfo(itemLink)
            local craft, line, trait = getResearchData(itemLink)
            table.insert(list, {
                bagId = data.bagId,
                slot = data.slotIndex,
                item = itemLink,
                craft = craft,
                line = line,
                trait = trait,
                selected = false
            })
        end
    end
    return list
end

local function getTraitResearchData(research, craft, line, trait)
    local isKnown = research.done[craft][line][trait] or false
    local isResearching = false
    local doneAt
    if isKnown == false then
        for _, researching in pairs(research.doing[craft]) do
            if researching.line == line and researching.trait == trait then
                doneAt = researching.doneAt
                isResearching = true
                break
            end
        end
    end
    return isKnown, isResearching, doneAt
end

local function isLineBeingResearched(research, craft, line)
    for _, researching in pairs(research.doing[craft]) do
        if researching.line == line then
            if researching.doneAt and researching.doneAt - GetTimeStamp() > 0 then
                return true
            end
        end
    end
    return false
end

local function getNumOngoingResearches(research, craft)
    local num = 0
    for _, researching in pairs(research.doing[craft]) do
        if researching.doneAt - GetTimeStamp() > 0 then
            num = num + 1
        end
    end
    return num
end

local function getFirstUnknownTraitCanBeTrained(craft, line, unknownTraits, trainer)
    for _, trait in pairs(unknownTraits) do

        if trainer == nil and #LeoTrainer.knowledge[craft][line][trait] > 0 then
            return trait, LeoTrainer.knowledge[craft][line][trait]
        elseif trainer ~= nil then
            for _, charName in pairs(LeoTrainer.knowledge[craft][line][trait]) do
                if charName == trainer then
                    return trait, LeoTrainer.knowledge[craft][line][trait]
                end
            end
        end
    end
    return nil, {}
end

function LeoTrainer.CreateUI()
    local traitIcons = {}
    for traitItemIndex = 1, GetNumSmithingTraitItems() do
        local traitType, _, icon, _, _, _, _ = GetSmithingTraitItemInfo(traitItemIndex)
        if traitType and traitType ~= ITEM_TRAIT_TYPE_NONE then
            traitIcons[traitType] = icon
        end
    end

    for _,craft in pairs(LeoAltholic.craftResearch) do
        local panel = WINDOW_MANAGER:GetControlByName('LeoTrainerWindowCraft'..craft.."Panel")
        if craft == CRAFTING_TYPE_JEWELRYCRAFTING then
            panel = WINDOW_MANAGER:GetControlByName('LeoTrainerWindowCraft6PanelCraft7Panel')
        end
        for line = 1, GetNumSmithingResearchLines(craft) do
            local lineName, lineIcon, numTraits = GetSmithingResearchLineInfo(craft, line)
            local labelLine = panel:GetNamedChild('Line' .. line)
            labelLine.tooltip = lineName
            labelLine:SetText("|t30:30:"..lineIcon.."|t")
            for trait = 1, numTraits do
                local traitType = GetSmithingResearchLineTraitInfo(craft, line, trait)
                local traitName = GetString('SI_ITEMTRAITTYPE', traitType)
                local i = trait
                local posY = 14 + (trait * 28)
                if craft == CRAFTING_TYPE_BLACKSMITHING and line <= 7 then
                    i = i + 10
                elseif craft == CRAFTING_TYPE_WOODWORKING and line <= 5 then
                    i = i + 10
                end
                local labelTrait = panel:GetNamedChild('Trait' .. i)
                labelTrait:SetText(traitName .. " |t28:28:"..traitIcons[traitType].."|t")
                labelTrait.materialItemID = LeoTrainer.const.traitMaterials[traitType]

                local t = WINDOW_MANAGER:CreateControl('LeoTrainerWindowCraft'..craft..'Line'..line..'Trait'..trait..'Texture', labelLine, CT_TEXTURE)
                t:SetAnchor(CENTER, labelLine, CENTER, 0, posY)
                t:SetDimensions(25,25)
                t:SetMouseEnabled(true)
                t:SetHandler('OnMouseExit', function(self)
                    ClearTooltip(InformationTooltip)
                    InformationTooltip:SetHidden(true)
                end)

            end

            local label = WINDOW_MANAGER:CreateControl('LeoTrainerWindowCraft'..craft..'Line'..line..'Count', labelLine, CT_LABEL)
            label:SetAnchor(CENTER, labelLine, CENTER, 8, 300)
            label:SetDimensions(25,25)
            label:SetFont("LeoTrainerLargeFont")
        end
    end
    LeoTrainer.queueScroll = LeoTrainerQueueList:New(LeoTrainerWindowQueuePanelQueueScroll)
    LeoTrainer.queueScroll:RefreshData()

    local LeoTrainerCharDropdown = CreateControlFromVirtual('LeoTrainerCharDropdown', LeoTrainerWindow, 'LeoTrainerCharDropdown')
    LeoTrainerCharDropdown:SetDimensions(200,35)
    LeoTrainerCharDropdown:SetAnchor(RIGHT, LeoTrainerWindowBlacksmithingButton, LEFT, -50, 4)
    LeoTrainerCharDropdown.m_comboBox:SetSortsItems(false)
    local charDropdown = ZO_ComboBox_ObjectFromContainer(LeoTrainerCharDropdown)
    charDropdown:ClearItems()

    local defaultItem
    for _, char in pairs(LeoAltholic.ExportCharacters()) do
        local entry = charDropdown:CreateItemEntry(char.bio.name, function()
            LeoTrainer.UpdateUI(char.bio.name)
        end)
        if char.bio.name == LeoAltholic.CharName then
            defaultItem = entry
        end
        charDropdown:AddItem(entry)
    end
    if defaultItem ~= nil then
        charDropdown:SelectItem(defaultItem)
    end
end

function LeoTrainer.UpdateUI(charName)

    if charName == nil then charName = LeoAltholic.CharName end

    local items = {}
    if LeoTrainer.savedVariables.researchItems then
        items = scanItems()
    end
    local traitIcons = {}
    for traitItemIndex = 1, GetNumSmithingTraitItems() do
        local traitType, _, icon, _, _, _, _ = GetSmithingTraitItemInfo(traitItemIndex)
        if traitType and traitType ~= ITEM_TRAIT_TYPE_NONE then
            traitIcons[traitType] = icon
        end
    end

    for _,craft in pairs(LeoAltholic.craftResearch) do
        local panel = WINDOW_MANAGER:GetControlByName('LeoTrainerWindowCraft'..craft.."Panel")
        if craft == CRAFTING_TYPE_JEWELRYCRAFTING then
            panel = WINDOW_MANAGER:GetControlByName('LeoTrainerWindowCraft6PanelCraft7Panel')
        end
        for line = 1, GetNumSmithingResearchLines(craft) do
            local lineName, lineIcon, numTraits = GetSmithingResearchLineInfo(craft, line)
            local knownTraits = 0
            for trait = 1, numTraits do
                local traitType = GetSmithingResearchLineTraitInfo(craft, line, trait)
                local traitName = GetString('SI_ITEMTRAITTYPE', traitType)

                local t = WINDOW_MANAGER:GetControlByName('LeoTrainerWindowCraft'..craft..'Line'..line..'Trait'..trait..'Texture')

                local isKnown = #LeoTrainer.knowledge[craft][line][trait] > 0
                local isUnknown = #LeoTrainer.knowledge[craft][line][trait] == 0
                local allKnown = #LeoTrainer.missingKnowledge[craft][line][trait] == 0

                local hasItem = false
                for _, itemData in pairs(items) do
                    if itemData.craft == craft and itemData.line == line and itemData.trait == trait then
                        if not LeoTrainer.savedVariables.onlyResearchFCO or (FCOIS and FCOIS.settingsVars.settings.isIconEnabled and FCOIS.IsIconEnabled(FCOIS_CON_ICON_RESEARCH) and FCOIS.IsMarked(itemData.bagId, itemData.slot, FCOIS_CON_ICON_RESEARCH)) then
                            hasItem = true
                            break
                        end
                    end
                end

                local myself = false
                for _,knowName in pairs(LeoTrainer.knowledge[craft][line][trait]) do
                    if knowName == charName then
                        myself = true
                        break
                    end
                end
                local icon
                local color
                if myself == true then
                    icon = 'esoui/art/buttons/accept_up.dds'
                    knownTraits = knownTraits + 1
                    if allKnown then
                        color = {0,1,0,1}
                    else
                        color = {1,1,0,1}
                    end
                else
                    icon = 'esoui/art/buttons/decline_up.dds'
                    if isUnknown then
                        color = {1,0,0,1}
                    else
                        color = {1,0.7,0,1}
                    end
                end
                if hasItem and not allKnown then
                    icon = 'esoui/art/buttons/pointsplus_up.dds'
                end

                t:SetColor(unpack(color))
                t:SetTexture(icon)
                t:SetHandler('OnMouseEnter', function(self)
                    InitializeTooltip(InformationTooltip, self, LEFT, 5, 0)
                    addLineTitle(InformationTooltip, lineName .." - ".. traitName, ZO_TOOLTIP_DEFAULT_COLOR)
                    ZO_Tooltip_AddDivider(InformationTooltip)

                    addLineSubTitle(InformationTooltip, "Trainers", ZO_TOOLTIP_DEFAULT_COLOR, TEXT_ALIGN_LEFT)
                    if allKnown then
                        addLine(InformationTooltip, "All", LeoTrainer.const.colors.green)
                    elseif isKnown then
                        for _, knowName in pairs(LeoTrainer.knowledge[craft][line][trait]) do
                            addLine(InformationTooltip, knowName, LeoTrainer.const.colors.green)
                        end
                    else
                        addLine(InformationTooltip, "None", LeoTrainer.const.colors.red)
                    end

                    addLineSubTitle(InformationTooltip, "Trainees", ZO_TOOLTIP_DEFAULT_COLOR, TEXT_ALIGN_LEFT)
                    if allKnown then
                        addLine(InformationTooltip, "None", LeoTrainer.const.colors.green)
                    elseif isUnknown then
                        addLine(InformationTooltip, "All", LeoTrainer.const.colors.red)
                    else
                        for _, knowName in pairs(LeoTrainer.missingKnowledge[craft][line][trait]) do
                            addLine(InformationTooltip, knowName, LeoTrainer.const.colors.red)
                        end
                    end
                    local inBag = ""
                    local inBank = ""
                    for _, itemData in pairs(items) do
                        if itemData.craft == craft and itemData.line == line and itemData.trait == trait then
                            if not LeoTrainer.savedVariables.onlyResearchFCO or (FCOIS and FCOIS.IsIconEnabled(FCOIS_CON_ICON_RESEARCH) and FCOIS.IsMarked(itemData.bagId, itemData.slot, FCOIS_CON_ICON_RESEARCH)) then
                                if itemData.bagId == BAG_BANK then
                                    inBank = inBank .."[".. itemData.item .. "] "
                                elseif itemData.bagId == BAG_BACKPACK then
                                    inBag = inBag .."["..  itemData.item .. "] "
                                end
                            end
                        end
                    end
                    if inBag ~= "" or inBank ~= "" then
                        addLineSubTitle(InformationTooltip, "Researchable Items", ZO_TOOLTIP_DEFAULT_COLOR, TEXT_ALIGN_LEFT)
                    end
                    if inBag ~= "" then
                        addLine(InformationTooltip, GetString(SI_INVENTORY_MENU_INVENTORY) ..": ".. inBag, LeoTrainer.const.colors.green)
                    end
                    if inBank ~= "" then
                        addLine(InformationTooltip, GetString(SI_CURRENCYLOCATION1) ..": ".. inBank, LeoTrainer.const.colors.green)
                    end
                    if not allKnown and not isUnknown then
                        addLine(InformationTooltip, zo_iconTextFormat("esoui/art/icons/icon_lmb.dds", 26, 26, "Queue 1"))
                        addLine(InformationTooltip, zo_iconTextFormat("esoui/art/icons/icon_rmb.dds", 26, 26, "Queue All"))
                    end
                    InformationTooltip:SetHidden(false)
                end)
                if isKnown then
                    t:SetHandler('OnMouseUp', function(control, button, upInside)
                        if not upInside or (button ~= MOUSE_BUTTON_INDEX_RIGHT and button ~= MOUSE_BUTTON_INDEX_LEFT) then return end
                        if #LeoTrainer.missingKnowledge[craft][line][trait] > 0 then
                            --local matReq = LeoTrainer.const.materialRequirements[craft][line]
                            local styleId = LeoTrainer.maxStyle(line)
                            if trait == 9 and LeoTrainer.savedVariables.trainNirnhoned == false then
                                LeoTrainer.log("Nirnhoned training is disabled in settings.")
                                return
                            end

                            local trainerName
                            local _, knownList = getFirstUnknownTraitCanBeTrained(craft, line, {trait}, trainer)
                            for _, knownName in pairs(knownList) do
                                if knownName == LeoTrainer.savedVariables.defaultTrainer then
                                    trainerName = knownName
                                    break
                                end
                            end
                            if traitName == nil then
                                trainerName = knownList[1]
                            end

                            for _, charName in pairs(LeoTrainer.missingKnowledge[craft][line][trait]) do
                                local traineeName = "Anyone"
                                if button == MOUSE_BUTTON_INDEX_RIGHT then
                                    traineeName = charName
                                end
                                LeoTrainer.AddToQueue({
                                    trainer = trainerName,
                                    trainee = traineeName,
                                    craft = craft,
                                    line = line,
                                    trait = trait,
                                    patternIndex = -1,
                                    materialIndex = 1,
                                    materialQuantity = -1,
                                    itemStyleId = styleId,
                                    traitIndex = traitType,
                                    useUniversalStyleItem = false,
                                    researchName = lineName .. " " .. traitName,
                                    itemLink = LeoTrainer.const.craftItems[craft][line][trait]
                                })
                                if button == MOUSE_BUTTON_INDEX_LEFT then
                                    break
                                end
                            end
                            LeoTrainer.queueScroll:RefreshData()
                        end
                    end)
                end
            end
            local labelCount = WINDOW_MANAGER:GetControlByName('LeoTrainerWindowCraft'..craft..'Line'..line..'Count')
            labelCount:SetText(knownTraits)
            if knownTraits < 2 then
                labelCount:SetColor(1,0,0,1)
            elseif knownTraits < 4 then
                labelCount:SetColor(1,0.7,0,1)
            elseif knownTraits < 6 then
                labelCount:SetColor(1,1,0,1)
            elseif knownTraits == 9 then
                labelCount:SetColor(0,1,0,1)
            else
                labelCount:SetColor(1,1,1,1)
            end
        end
    end
    LeoTrainer.queueScroll:RefreshData()
end

function LeoTrainer.GetQueue()
    return LeoTrainer.savedVariables.queue
end

function LeoTrainer.ClearQueue()
    LeoTrainer.savedVariables.queue = {}
    LeoTrainer.queueScroll:RefreshData()
end

function LeoTrainer.AddToQueue(data)
    for _, item in pairs(LeoTrainer.savedVariables.queue) do
        if data.trainer ~= "Anyone" and data.trainee ~= "Anyone" and item.trainer == data.trainer and item.trainee == data.trainee and item.craft == data.craft and
                item.line == data.line and item.trait == data.trait then
            return false
        end
    end
    table.insert(LeoTrainer.savedVariables.queue, data)
    return true
end

function LeoTrainer.RemoveFromQueue(pos)
    table.remove(LeoTrainer.savedVariables.queue, pos)
    LeoTrainer.queueScroll:RefreshData()
end

function LeoTrainer.FillMySlots()
    LeoTrainer.FillSlots(nil, LeoAltholic.CharName)
end

function LeoTrainer.FillKnownSlots()
    LeoTrainer.FillSlots(LeoAltholic.CharName, nil)
end

function LeoTrainer.FillSlots(trainer, trainee)
    local charList = LeoAltholic.ExportCharacters()
    local researchingLines = {}
    local knownCount = {}
    local unknownTraits = {}
    local items = {}
    if LeoTrainer.savedVariables.researchItems then
        items = scanItems()
    end
    local newAdded = 0
    for _, char in pairs(charList) do
        if (trainee == nil or trainee == char.bio.name) and trainer == nil or (trainer ~= nil and trainer ~= char.bio.name) then
            knownCount[char.bio.name] = {}
            unknownTraits[char.bio.name] = {}
            researchingLines[char.bio.name] = {}
            for _,craft in pairs(LeoAltholic.craftResearch) do
                if LeoTrainer.isTrackingSkill(char.bio.name, craft) and LeoTrainer.canFillSlotWithSkill(char.bio.name, craft) then
                    knownCount[char.bio.name][craft] = {}
                    unknownTraits[char.bio.name][craft] = {}
                    researchingLines[char.bio.name][craft] = {}
                    local lineList = {}
                    for line = 1, GetNumSmithingResearchLines(craft) do
                        knownCount[char.bio.name][craft][line] = 0
                        unknownTraits[char.bio.name][craft][line] = {}
                        researchingLines[char.bio.name][craft][line] = false
                        local lineName, _, numTraits = GetSmithingResearchLineInfo(craft, line)
                        for trait = 1, numTraits do
                            local isKnown, isResearching, doneAt = getTraitResearchData(char.research, craft, line, trait)
                            if isResearching and doneAt - GetTimeStamp() > 0 then
                                researchingLines[char.bio.name][craft][line] = true
                            elseif isKnown or (isResearching and doneAt - GetTimeStamp() <= 0) then
                                knownCount[char.bio.name][craft][line] = knownCount[char.bio.name][craft][line] + 1
                            elseif isKnown == false then
                                table.insert(unknownTraits[char.bio.name][craft][line], trait)
                            end
                        end
                        table.insert(lineList, {
                            line = line,
                            lineName = lineName,
                            count = knownCount[char.bio.name][craft][line],
                            unknownTraits = unknownTraits[char.bio.name][craft][line],
                            isResearching = isLineBeingResearched(char.research, craft, line)
                        })
                    end
                    table.sort(lineList, function(a, b)
                        return a.count < b.count
                    end)
                    local styleId
                    local max = char.research.done[craft].max - getNumOngoingResearches(char.research, craft)
                    for i = 1, max do
                        for j, lineData in ipairs(lineList) do
                            if not lineData.added and not lineData.isResearching then
                                local trait, knownList = getFirstUnknownTraitCanBeTrained(craft, lineData.line, lineData.unknownTraits, trainer)
                                local hasItem = false
                                if trait ~= nil and (trait ~= 9 or LeoTrainer.savedVariables.trainNirnhoned == true) then
                                    for itemIndex, itemData in ipairs(items) do
                                        if itemData.selected == false and itemData.craft == craft and itemData.line == lineData.line and itemData.trait == trait then
                                            if not LeoTrainer.savedVariables.onlyResearchFCO or
                                                    (FCOIS and FCOIS.IsIconEnabled(FCOIS_CON_ICON_RESEARCH) and
                                                            FCOIS.IsMarked(itemData.bagId, itemData.slot, FCOIS_CON_ICON_RESEARCH)) then
                                                hasItem = true
                                                items[itemIndex].selected = true
                                                break
                                            end
                                        end
                                    end
                                end
                                if trait ~= nil and (trait ~= 9 or LeoTrainer.savedVariables.trainNirnhoned == true) then
                                    if not hasItem then
                                        local traitType = GetSmithingResearchLineTraitInfo(craft, lineData.line, trait)
                                        local traitName = GetString('SI_ITEMTRAITTYPE', traitType)
                                        if not styleId then styleId = LeoTrainer.maxStyle(lineData.line) end
                                        local trainerName
                                        if trainer ~= nil then
                                            trainerName = trainer
                                        else
                                            for _, knownName in pairs(knownList) do
                                                if knownName == LeoTrainer.savedVariables.defaultTrainer then
                                                    trainerName = knownName
                                                    break
                                                end
                                            end
                                            if trainerName == nil then
                                                trainerName = knownList[1]
                                            end
                                        end
                                        local data = {
                                            trainer = trainerName,
                                            trainee = char.bio.name,
                                            craft = craft,
                                            line = lineData.line,
                                            trait = trait,
                                            patternIndex = -1,
                                            materialIndex = 1,
                                            materialQuantity = -1,
                                            itemStyleId = styleId,
                                            traitIndex = traitType,
                                            useUniversalStyleItem = false,
                                            researchName = lineData.lineName .. " " .. traitName,
                                            itemLink = LeoTrainer.const.craftItems[craft][lineData.line][trait],
                                            knownList = knownList
                                        }
                                        if trainer ~= nil then data.trainer = trainer end
                                        if trainee ~= nil then data.trainee = trainee end
                                        if LeoTrainer.AddToQueue(data) then
                                            newAdded = newAdded + 1
                                        end
                                    end
                                    lineList[j].added = true
                                    break
                                end
                            end
                        end
                    end
                    LeoTrainer.queueScroll:RefreshData()
                end
            end
        end
    end
    LeoTrainer.log(ZO_CachedStrFormat("Done filling research slots. Added <<1[1 item/$d items]>>", newAdded))
end
