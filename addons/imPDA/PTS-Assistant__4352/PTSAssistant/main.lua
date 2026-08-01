local Log
if not LibDebugLogger then
    Log = function(...) end
else
    local logger = LibDebugLogger:Create('IMP_PTSAssistant')
    logger:SetMinLevelOverride(LibDebugLogger.LOG_LEVEL_DEBUG)
    local level = LibDebugLogger.LOG_LEVEL_DEBUG
    Log = function(...) logger:Log(level, ...) end
end

-- ----------------------------------------------------------------------------

local itemTypeNames = {}
do
    string.startswith = function(self_, str)
        return self_:find('^' .. str) ~= nil
    end

    for name, value in zo_insecurePairs(_G) do
        if name:startswith('ITEMTYPE_') then
            itemTypeNames[value] = name
        end
    end
end

-- ----------------------------------------------------------------------------

local Node = {}

function Node:New(itemLink, parent)
    local itemId = GetItemLinkItemId(itemLink)
    local itemType = GetItemLinkItemType(itemLink)

    local instance = {
        itemLink = itemLink,
        itemId = itemId,
        itemType = itemType,
        itemName = GetItemLinkName(itemLink),
        itemTypeName = itemTypeNames[itemType],
        parent = parent,  -- TODO: add child for parent node
        children = {},
        replicable = nil,
    }

    setmetatable(instance, {__index = Node})

    return instance
end

function Node:AddAsAChild(itemLink)
    local childNode = Node:New(itemLink, self)

    table.insert(self.children, childNode)
    self.replicable = self.replicable or childNode.itemId == self.itemId  -- TODO: not the cleanest, but OK for now

    return childNode
end

function Node:IsRoot()
    return self.parent.itemLink == ''  -- TODO: better structure?
end

function Node:BuildPathFromRoot()  -- TODO: speed up
    if self:IsRoot() then return end

    local upstream = self.parent:BuildPathFromRoot()
    if upstream then
        return upstream .. ' > ' .. self.parent.itemLink
    else
        return self.parent.itemLink
    end
end

function Node:IsReplicable()
    local selfItemId = self.itemId
    local children = self.children

    for i = 1, #children do
        local child = children[i]
        if child.itemId == selfItemId then
            return true
        end
    end
end

-- ----------------------------------------------------------------------------

local TLC = IMP_PTSAssistant_TLC

local ui = {}

function ui:Initialize(addon)
    self.addon = addon

    local listControl = TLC:GetNamedChild('Listing'):GetNamedChild('ScrollableList')
    local filters = TLC:GetNamedChild('Filters')

    self.selections = {
        searchText = nil,
        showContainers = true,
    }

    local function OnSearchTextChanged(editBox, filter)
        local newText = editBox:GetText():lower()
        if newText == '' or newText:len() < 3 then newText = nil end
        if newText == self.selections[filter] then return end

        self.selections[filter] = newText
        self:Update()
    end

    local searchBox = filters:GetNamedChild('SearchContainerSearchBox')
    searchBox:SetHandler('OnTextChanged', function(editBox) OnSearchTextChanged(editBox, 'searchText') end)

    self.listControl = listControl

    self:CreateScrollListDataType()

    TLC:SetHandler('OnEffectivelyShown', function() self:Update() end)

    INVENTORY_FRAGMENT:RegisterCallback('StateChange', function(oldState, newState)
        if TLC:IsHidden() then
            if newState == SCENE_FRAGMENT_SHOWING or newState == SCENE_FRAGMENT_SHOWN then
                TLC:SetHidden(false)
            end
        else
            if newState == SCENE_FRAGMENT_HIDING or newState == SCENE_FRAGMENT_HIDDEN then
                TLC:SetHidden(true)
            end
        end
    end)

    local showContainersCheckbox = filters:GetNamedChild('ShowContainersCheckBox')
    ZO_CheckButton_SetLabelText(showContainersCheckbox, 'Show Containers')
    ZO_CheckButton_SetToggleFunction(showContainersCheckbox, function(c_, state)
        self.selections.showContainers = state
        self:Update()
    end)
    ZO_CheckButton_SetCheckState(showContainersCheckbox, self.selections.showContainers)

    if PP then
        TLC:SetAnchorOffsets(-16,  nil, 1)
        TLC:SetAnchorOffsets(-16, -300, 2)
    end

    self:Update()
end

local ARMOR_TYPE_TO_COLOR = {
    [ARMORTYPE_LIGHT]  = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_POWER_END, COMBAT_MECHANIC_FLAGS_MAGICKA)),
    [ARMORTYPE_MEDIUM] = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_POWER_END, COMBAT_MECHANIC_FLAGS_STAMINA)),
    [ARMORTYPE_HEAVY]  = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_POWER_END, COMBAT_MECHANIC_FLAGS_HEALTH)),
    [ARMORTYPE_NONE]   = ZO_ColorDef:New(1, 1, 1, 1),
}

function ui:CreateScrollListDataType()
    local function BuildTooltip(rowControl)
        local node = rowControl.dataEntry.data.node

        -- ('%d - %s'):format(node.itemId, itemLink)
        local tooltip = ('(%d) %s\n\n%s\n\nDouble click to get this item!'):format(
            node.itemId,
            node.itemLink,
            node:BuildPathFromRoot()
        )

        if node.replicable then
            tooltip = tooltip .. '\n\nInfinite container'
        end

        return tooltip
    end

    local function ShowTooltip(rowControl)
        ZO_Tooltips_ShowTextTooltip(rowControl, LEFT, BuildTooltip(rowControl))
    end

    local function RetrieveItem(itemId)
        self.addon:RetrieveItemByItemId(itemId)
    end

    -- local function LootEverythingFrom(itemId)
    --     self.addon:LootEverythingFrom(itemId)
    -- end

    local function ShowRMBMenu(rowControl)
        local node = rowControl.dataEntry.data.node

        local textSingleItem = 'Retrieve ' .. node.itemLink
        -- local textEverything = 'Retrieve all from ' .. node.parent.itemLink

        ClearMenu()

        AddCustomMenuItem(textSingleItem, function()
            RetrieveItem(node.itemId)
            ClearMenu()
        end)
        -- AddCustomMenuItem(textEverything, function() LootEverythingFrom(node.parent.id) end)

        ShowMenu()
    end

    local function OnMouseDown(rowControl, button)
        if button == MOUSE_BUTTON_INDEX_RIGHT then ShowRMBMenu(rowControl) end
    end

    local function OnMouseDoubleClick(rowControl, button)
        if button ~= MOUSE_BUTTON_INDEX_LEFT then return end

        local node = rowControl.dataEntry.data.node
        RetrieveItem(node.itemId)
    end

    local function LayoutRow(rowControl, data, scrollList)
        local node = data.node
        local itemLink = node.itemLink
        GetControl(rowControl, 'Icon'):SetTexture(GetItemLinkIcon(itemLink))
        -- GetControl(rowControl, 'Name'):SetText(('%d %s'):format(data.node.itemId, data.node.itemLink))
        GetControl(rowControl, 'Name'):SetText(itemLink)

        local info = '-'
        if GetItemLinkItemType(itemLink) == ITEMTYPE_ARMOR then
            local equipType = GetItemLinkEquipType(itemLink)
            local armorType = GetItemLinkArmorType(itemLink)  -- TODO: jewelery has no armor type
            local traitType = GetItemLinkTraitType(itemLink)
            info = ('%s, |c%s%s|r, %s'):format(
                GetString('SI_EQUIPTYPE', equipType),
                ARMOR_TYPE_TO_COLOR[armorType]:ToHex(),
                GetString('SI_ARMORTYPE', armorType),
                GetString('SI_ITEMTRAITTYPE', traitType)
            )
        elseif GetItemLinkItemType(itemLink) == ITEMTYPE_WEAPON then
            local equipType = GetItemLinkEquipType(itemLink)
            local weaponType = GetItemLinkWeaponType(itemLink)
            local traitType = GetItemLinkTraitType(itemLink)
            info = ('%s, %s, %s'):format(
                GetString('SI_EQUIPTYPE', equipType),
                GetString('SI_WEAPONTYPE', weaponType),
                GetString('SI_ITEMTRAITTYPE', traitType)
            )
        end

        GetControl(rowControl, 'Info'):SetText(info)
        -- GetControl(rowControl, 'Path'):SetText(node:BuildPathFromRoot())

        rowControl:SetHandler('OnMouseDown', OnMouseDown)
        rowControl:SetHandler('OnMouseDoubleClick', OnMouseDoubleClick)

        rowControl:SetHandler('OnMouseEnter', ShowTooltip)
        rowControl:SetHandler('OnMouseExit', ZO_Tooltips_HideTextTooltip)
    end

	local control = self.listControl
	local typeId = 1
	local templateName = 'IMP_PTSAssistant_Row_Template'
	local height = 32
	local setupFunction = LayoutRow
	local hideCallback = nil
	local dataTypeSelectSound = nil
	local resetControlCallback = nil

	ZO_ScrollList_AddDataType(control, typeId, templateName, height, setupFunction, hideCallback, dataTypeSelectSound, resetControlCallback)

    -- local selectTemplate = 'ZO_ThinListHighlight'
	-- local selectCallback = nil
	-- ZO_ScrollList_EnableSelection(control, selectTemplate, selectCallback)
end

local function UpdateScrollListControl(control, data, rowType)
	-- local dataCopy = ZO_DeepTableCopy(data)
    local dataCopy = data
	local dataList = ZO_ScrollList_GetDataList(control)

	ZO_ScrollList_Clear(control)

    -- local task = LibAsync:Create('UpdateDuelsScrollList')

    local function CreateAndAddDataEntry(index)
        local value = dataCopy[index]
        local entry = ZO_ScrollList_CreateDataEntry(rowType, value)

		table.insert(dataList, entry)
    end

    -- task:For(#dataCopy, 1, -1):Do(CreateAndAddDataEntry):Then(function() ZO_ScrollList_Commit(control) end):Then(HideWarning)

    for i = 1, #dataCopy do
        CreateAndAddDataEntry(i)
    end

    table.sort(dataList, function(a, b) return a.data.node.itemId < b.data.node.itemId end)

    ZO_ScrollList_Commit(control)
end

function ui:FiltersPassed(node)
    if not self.selections.showContainers then
        if node.itemType == ITEMTYPE_CONTAINER then return end
    end

    return true
end

function ui:Update()
    -- TODO
    -- if self.dirty then
    -- end

    self.dataRows = {}

    -- local searchText
    -- if self.selections.searchText and self.selections.searchText:len() >= 3 then
    --     searchText = self.selections.searchText
    -- end

    local searchText = self.selections.searchText

    for _, node in pairs(self.addon:Search(searchText)) do  -- TODO: Search is bad
        if self:FiltersPassed(node) then
            table.insert(
                self.dataRows,
                {
                    node = node,
                    -- id = node.itemId,
                    -- name = node.itemName,
                    -- itemLink = node.itemLink,
                    -- path = node:BuildPathFromRoot(),
                }
            )
        end
    end

    local SOME_ID = 1
    UpdateScrollListControl(self.listControl, self.dataRows, SOME_ID)
end

function ui:ToggleVisibility()
    local isHidden = TLC:IsHidden()
    TLC:SetHidden(not isHidden)
end

-- ----------------------------------------------------------------------------

local function FindItemWithItemId(bagId, itemId)
    for slotIndex = 0, GetNumBagUsedSlots(bagId) do
        if GetItemId(bagId, slotIndex) == itemId then
            return slotIndex
        end
    end
end

local function FindItemsWithItemId(bagId, itemId)
    local indicies = {}

    for slotIndex = 0, GetNumBagUsedSlots(bagId) do
        if GetItemId(bagId, slotIndex) == itemId then
            indicies[#indicies+1] = slotIndex
        end
    end

    return indicies
end

local function UseItemWithItemId(itemId)
    local bagId = BAG_BACKPACK

    local slotIndex = FindItemWithItemId(bagId, itemId)
    if not slotIndex then
        return
    end

    -- TODO: CanUseItem, ClearCursor()?
    if GetItemCooldownInfo(bagId, slotIndex) > 0 then
        return
    end

    return CallSecureProtected('UseItem', bagId, slotIndex)
end

local Item = {}

function Item:New(bagId, slotIndex)
    local itemLink = GetItemLink(bagId, slotIndex)

    local instance = {
        bagId = bagId,
        slotIndex = slotIndex,
        itemLink = itemLink,
        itemId = GetItemLinkItemId(itemLink),
        uniqueId = GetItemUniqueId(bagId, slotIndex),
        content = {},
    }

    setmetatable(instance, {__index = Item})

    return instance
end

function Item:__eq(otherItem)
    if not otherItem.uniqueId then return false end

    return AreId64sEqual(self.uniqueId, otherItem.uniqueId)
end

function Item:Use()
    if self.lost then return end

    if not self:IsValid() then
        local candidates = FindItemsWithItemId(self.bagId, self.itemId)
        for _, candidateSlotIndex in ipairs(candidates) do
            if AreId64sEqual(GetItemUniqueId(self.bagId, candidateSlotIndex), self.uniqueId) then
                self.slotIndex = candidateSlotIndex
                break
            end
        end
        -- item can't be found anymore
        self.lost = true
        return
    end

    if GetItemCooldownInfo(self.bagId, self.slotIndex) > 0 then
        return
    end

    return CallSecureProtected('UseItem', self.bagId, self.slotIndex)
end

function Item:IsValid()
    return AreId64sEqual(self.uniqueId, GetItemUniqueId(self.bagId, self.slotIndex))
end

function Item:IsContains(itemId)
    return self.content[itemId] ~= nil
end

-- ----------------------------------------------------------------------------

local EVENT_NAMESPACE = 'IMP_PTSAssistant_EventNamespace'

local STATUS_READY = 1
local STATUS_BUSY = 2

local TASK_RESEARCH_CONTAINER = 1
local TASK_RETRIEVE_ITEM = 2
local TASK_TYPE_WAIT_FOR_LOOT = 3

local HEARTBEAT_DELAY = 1200

local addon = {}

function addon:ResearchContainer(bagId, slotIndex, isRoot)
    if false then return end  -- TODO: restrict access to some funtions

    if not IsItemUsable(bagId, slotIndex) then Log('Item unusable') return end

    local containerItemLink = GetItemLink(bagId, slotIndex)
    if GetItemLinkItemType(containerItemLink) ~= ITEMTYPE_CONTAINER then Log('Not a container') return end

    local node = Node:New(containerItemLink)
    if isRoot then
        self.root.children[#self.root.children+1] = node
    end

    self:AddTask(TASK_RESEARCH_CONTAINER, node)

    self:Heartbeat()
end

function addon:AddTask(taskType, ...)
    self.queue[#self.queue+1] = {taskType, {...}}
end

function addon:AddTaskNext(taskType, ...)
    table.insert(self.queue, self.queueIndex+1, {taskType, {...}})
end

function addon:AddTaskRaw(task)
    self.queue[#self.queue+1] = task
end

function addon:HandleResearchContainerTask()
    Log('`HandleResearchContainer` called')
    local currentTask = self.queue[self.queueIndex]

    local itemToUseNode = currentTask[2][1]
    local itemIdToUse = itemToUseNode.itemId
    self.pending = currentTask[2][1].itemName

    error('FIX NEEDED')
    if not UseItemWithItemId(itemIdToUse) then  -- TODO: change!
        Log('Item %s was not used successfully, will retry later', GetItemLinkName(itemToUseNode.itemLink))
        self:AddTaskRaw(currentTask)

        self.pending = nil
        self.status = STATUS_READY
        self:Heartbeat()
    else
        self.researched[itemIdToUse] = true
    end
end

function addon:HandleRetrieveItemTask()
    Log('`HandleRetrieveItem` called')
    local currentTask = self.queue[self.queueIndex]
    local itemToLootItemId = currentTask[2][2]

    local bagId = BAG_BACKPACK
    local containerToOpenNode = currentTask[2][1]
    local containerToOpenItemId = containerToOpenNode.itemId

    local indicies = FindItemsWithItemId(bagId, containerToOpenItemId)
    Log('Found %d containers with requested item POTENTIALLY inside', #indicies)  -- TODO: name for item

    local candidates = {}
    for _, slotIndex in ipairs(indicies) do
        local candidateUniqueId = Id64ToString(GetItemUniqueId(bagId, slotIndex))

        local candidate = self.cache[candidateUniqueId] or Item:New(bagId, slotIndex)
        self.cache[candidateUniqueId] = candidate

        table.insert(candidates, candidate)
    end

    local choosenCandidate
    for _, candidate in ipairs(candidates) do
        if not candidate.lost then
            if candidate:IsContains(itemToLootItemId) then
                Log('Found requested item inside of cached container, will try it first')  -- TODO: name for item
                choosenCandidate = candidate
                break
            end

            if not next(candidate.content) then
                Log('Content of this container is unknown, will try it if nothing better found')
                choosenCandidate = candidate
            end
        end
    end

    if not choosenCandidate then
        Log('No candidate was choosen!')
        self:AddTaskNext(TASK_RETRIEVE_ITEM, containerToOpenNode.parent, containerToOpenNode.itemId)

        self.status = STATUS_READY
        self:Heartbeat()
        return
    end
    Log('Item with uniqueId %d choosen', choosenCandidate.uniqueId)

    self.pending = currentTask[2][1].itemName
    currentTask[2][3] = choosenCandidate
    if not choosenCandidate:Use() then
        Log('Item %d was not used successfully, will retry later', choosenCandidate.uniqueId)
        self:AddTaskRaw(currentTask)

        self.pending = nil
        self.status = STATUS_READY
        self:Heartbeat()
    end
end

function addon:HandleWaitForLoot()
    Log('`HandleWaitForLoot` called')

    local currentTask = self.queue[self.queueIndex]
    local lootedItems = currentTask[2][1]

    local unreceivedItemIds = {}
    for _, itemId in ipairs(lootedItems) do
        if not FindItemWithItemId(itemId) then
            unreceivedItemIds[#unreceivedItemIds+1] = itemId
        end
    end

    for _, unreceivedItemId in ipairs(unreceivedItemIds) do
        self:RetrieveItemByItemId(unreceivedItemId)  -- TODO: loot multiple items
    end

    self.status = STATUS_READY
    self:Heartbeat()
end

function addon:Heartbeat()
    Log('Heartbeat')

    if self.status == STATUS_BUSY then Log('Busy') return end
    if #self.queue == self.queueIndex then Log('End of the queue') return end

    local function internal()
        if self.status == STATUS_BUSY then return end
        if #self.queue == self.queueIndex then return end

        self.status = STATUS_BUSY
        self.lastOperationTimepoint = GetGameTimeMilliseconds()

        self.queueIndex = self.queueIndex + 1
        local currentTask = self.queue[self.queueIndex]

        local taskType = currentTask[1]
        if taskType == TASK_RESEARCH_CONTAINER then
            self:HandleResearchContainerTask()
        elseif taskType == TASK_RETRIEVE_ITEM then
            self:HandleRetrieveItemTask()
        elseif taskType == TASK_TYPE_WAIT_FOR_LOOT then
            self:HandleWaitForLoot()
        else
            error('Wrong task type')
        end
    end

    if GetGameTimeMilliseconds() - self.lastOperationTimepoint >= HEARTBEAT_DELAY * 1.1 then
        Log('Last operation was long ago, calling next')
        internal()
    else
        Log('Calling next operation with delay')
        zo_callLater(internal, HEARTBEAT_DELAY)
    end
end

function addon:OnLootUpdated()
    Log('EVENT_LOOT_UPDATED')
    if self.status ~= STATUS_BUSY then Log('This looting will not be handled') return end

    local currentTask = self.queue[self.queueIndex]
    local taskType = currentTask[1]
    -- TODO: check if correct container opened

    if taskType == TASK_RESEARCH_CONTAINER then
        Log('Looting: research container')
        local openedContainer = currentTask[2][1]

        local bagId = BAG_BACKPACK
        local freeSlots = GetNumBagFreeSlots(bagId) - 1  -- 1 less for a safety :)
        local lootData = LOOT_SHARED:GetSortedLootData()  -- TODO: can redo in the future to better fit my use case
        local lootedEverything = true

        for _, data in ipairs(lootData) do
            local lootId = data.lootId

            local itemLink = GetLootItemLink(lootId)
            local childNode = openedContainer:AddAsAChild(itemLink)

            local itemId = GetItemLinkItemId(itemLink)
            local itemType = GetItemLinkItemType(itemLink)
            local reseachedBefore = self.researched[itemId]

            -- if not reseacrhed before, then add to task queue
            if itemType == ITEMTYPE_CONTAINER and not reseachedBefore then
                if freeSlots > 0 then
                    freeSlots = freeSlots - 1  -- assume it looted normally, TODO: addon-wide counter of free space
                    self:AddTask(TASK_RESEARCH_CONTAINER, childNode)
                    LootItemById(lootId)
                else
                    lootedEverything = false
                    self:AddTaskRaw(currentTask)
                end
            end
        end

        EndLooting()  -- Is it OK to close loot window like this?
        EndInteraction(INTERACTION_LOOT)

        if lootedEverything then
            local slotIndex = FindItemWithItemId(bagId, openedContainer.itemId)
            DestroyItem(bagId, slotIndex)
        end
    elseif taskType == TASK_RETRIEVE_ITEM then
        Log('Looting: retrieve item')
        local itemIdToRetrieve = currentTask[2][2]
        local itemRetrieved = false

        local containerOpened = currentTask[2][3]
        containerOpened.content = {}
        local content = containerOpened.content
        local cached = 0

        local lootData = LOOT_SHARED:GetSortedLootData()  -- TODO: can redo in the future to better fit my use case
        for _, data in ipairs(lootData) do
            local lootId = data.lootId

            local itemLink = GetLootItemLink(lootId)
            local itemId = GetItemLinkItemId(itemLink)

            if not itemRetrieved and itemId == itemIdToRetrieve then
                Log('Looting %s', GetItemLinkName(itemLink))
                LootItemById(lootId)
                itemRetrieved = true  -- TODO: check if it is so
            else
                content[itemId] = true
                cached = cached + 1
            end
        end
        Log('Added %d items to cache', cached)
        Log('Item was not looted (not found in container)')

        -- next task will not find item and repeat looting again (TODO: test more)
        -- self:AddTaskNext(TASK_TYPE_WAIT_FOR_LOOT, {itemIdToRetrieve})

        EndLooting()  -- Is it OK to close loot window like this?
        EndInteraction(INTERACTION_LOOT)
        Log('End looting')
    end

    self.status = STATUS_READY
    self:Heartbeat()
end

-- function addon:OnLootReceived()
--     self.received[itemId] = true
-- end

local function WalkTree(parentNode, branch)
    local children = branch[2] or {}

    for i = 1, #children do
        local childBranch = children[i]
        local childNode = parentNode:AddAsAChild(childBranch[1])
        WalkTree(childNode, childBranch)
    end
end

function addon:SV2Tree()
    -- local rootContainers = self.root.children
    -- local svTree = self.sv.tree

    -- for i = 1, #svTree do
    --     local svNode = svTree[i]
    --     local rootNode = Node:New(svNode[1])
    --     rootContainers[i] = rootNode
    --     WalkTree(rootNode, svNode)
    -- end

    self.root = Node:New('')
    WalkTree(self.root, self.sv.tree)
end

function BuildTree(node, branch)
    for i = 1, #node.children do
        local child = node.children[i]
        local children = {}
        branch[i] = {
            child.itemLink,
            children,
        }
        BuildTree(child, children)
        if #branch[i][2] == 0 then branch[i][2] = nil end
    end
end

function addon:Tree2SV()
    local children = {}
    self.sv.tree = {
        '',
        children
    }
    BuildTree(self.root, children)
end

local function TraverseTree(startingNode, tbl, cb)
    for i = 1, #startingNode.children do
        local child = startingNode.children[i]
        local key = cb(child)

        if not tbl[key] then tbl[key] = {} end
        table.insert(tbl[key], child)
        -- tbl[key] = child  -- TODO: hashing to prevent overlapping

        TraverseTree(child, tbl, cb)
    end
end

function addon:BuildLookupTableItemName()
    local lookupTable = {}

    -- TODO: better hash function to avoid duplication
    TraverseTree(self.root, lookupTable, function(node)
        local itemLink = node.itemLink
        local info = ''  -- TODO: optimize
        if GetItemLinkItemType(itemLink) == ITEMTYPE_ARMOR then
            local armorType = GetItemLinkArmorType(itemLink)
            local equipType = GetItemLinkEquipType(itemLink)
            local traitType = GetItemLinkTraitType(itemLink)
            info = ('%s%s%s%s'):format(
                GetString('SI_EQUIPTYPE', equipType),
                GetString('SI_ARMORTYPE', armorType),
                GetString('SI_ITEMTRAITTYPE', traitType),
                node.itemId
            )
        end
        return (node.itemName..info):lower()
    end)
    self.lookupTableItemName = lookupTable
end

function addon:BuildLookupTableItemId()
    local lookupTable = {}

    TraverseTree(self.root, lookupTable, function(node) return node.itemId end)
    self.lookupTableItemId = lookupTable
end

local function StringIncludesMultiple(str, searchTerms)
    for i = 1, #searchTerms do
        if not PlainStringFind(str, searchTerms[i]) then return end
    end

    return true
end

function addon:Search(q)
    -- if not q then return self.lookupTableItemName end

    local searchTerms = {}
    if q then
        q = q:lower()
        for w in q:gmatch('%S+') do
            searchTerms[#searchTerms+1] = w
        end
    end

    local result = {}

    for str, nodeCandidates in pairs(self.lookupTableItemName) do
        -- if not q or PlainStringFind(str, q) then
        if #searchTerms == 0 or StringIncludesMultiple(str, searchTerms) then
            -- for _, nodeCandidate in ipairs(nodeCandidates) do
            --     if nodeCandidate.parent.itemId ~= nodeCandidate.itemId then  -- only no short-circuit nodes
            --         result[#result+1] = nodeCandidate
            --     end
            -- end
            local nodeCandidate = nodeCandidates[1]
            if nodeCandidate.parent.itemId ~= nodeCandidate.itemId then  -- only no short-circuit nodes
                result[#result+1] = nodeCandidate
            end
            --[[ FOR TESTING
            if nodeCandidate.replicable then
                result[#result+1] = nodeCandidate
            end
            --]]
        end
    end

    return result
end

function addon:SearchByItemId(itemId)
    if not itemId then return end

    for _, nodeCandidate in ipairs(self.lookupTableItemId[itemId]) do
        if nodeCandidate.parent.itemId ~= nodeCandidate.itemId then  -- only no short-circuit nodes allowed
            return nodeCandidate
        end
    end

    -- TODO: handle it later
    error('Only short-circuit nodes found!')
end

function addon:RetrieveItemByItemId(itemId)
    local leafNode = self:SearchByItemId(itemId)
    if not leafNode then return end

    local bagId = BAG_BACKPACK
    local slotIndex = FindItemWithItemId(bagId, itemId)
    if not slotIndex then
        -- TODO: do not create task if root container is absent
        self:AddTaskNext(TASK_RETRIEVE_ITEM, leafNode.parent, itemId)
        -- table.insert(self.queue, self.queueIndex+1, {TASK_RETRIEVE_ITEM, {leafNode.parent, itemId}})
        self:RetrieveItemByItemId(leafNode.parent.itemId)  -- TODO: retrieve by node
    else
        return  -- it is already in the backpack
    end

    self:Heartbeat()
end

function addon:LootEverythingFrom(node)
    if node.itemType ~= ITEMTYPE_CONTAINER then return end

    -- TODO: finish
end

function addon:Initialize()
    self.status = STATUS_READY
    self.lastOperationTimepoint = 0

    self.queue = {}
    self.queueIndex = 0

    self.root = {
        children = {}
    }

    self.cache = {}

    -- PTSAssistantSV = PTSAssistantSV or {}
    -- local apiVersion = GetAPIVersion()
    -- PTSAssistantSV[apiVersion] = PTSAssistantSV[apiVersion] or {
    --     tree = {
    --         '',
    --         {},
    --     },
    --     researched = {},
    --     -- received = {},
    -- }
    -- self.sv = PTSAssistantSV[apiVersion]

    self.sv = PTSAssistantData[101049]
    self.researched = self.sv.researched

    self:SV2Tree()
    self:BuildLookupTableItemName()

    ui:Initialize(addon)
    self.ui = ui

    self:BuildLookupTableItemId()

    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_LOOT_UPDATED, function() self:OnLootUpdated() end)
    -- EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_LOOT_RECEIVED, function() self:OnLootReceived() end)

    IMP_PTSAssistant = self

    ZO_PreHook(LOOT_WINDOW, 'UpdateLootWindow', function()
        local name, targetType, actionName, isOwned = GetLootTargetInfo()
        local pendingOpened = name == self.pending

        if pendingOpened then
            self.pending = nil
            return true
        end
    end)
end

EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_ADD_ON_LOADED, function(_, addonName)
    if addonName ~= 'PTSAssistant' then return end
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_ADD_ON_LOADED)

    if GetWorldName() ~= 'PTS' then return end

    addon:Initialize()
end)
