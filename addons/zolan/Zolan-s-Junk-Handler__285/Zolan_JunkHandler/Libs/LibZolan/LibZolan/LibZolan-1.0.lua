local MAJOR, MINOR = "LibZolan-1.0", 3
local LIBZ, oldminor = LibStub:NewLibrary(MAJOR, MINOR)
if not LIBZ then return end

LIBZ.table    = {}
LIBZ.settings = {}
LIBZ.colors   = {}

-- ZO
local CHAT_SYSTEM          = CHAT_SYSTEM
local SI_TOOLTIP_ITEM_NAME = SI_TOOLTIP_ITEM_NAME
local GetItemInfo          = GetItemInfo
local GetItemLevel         = GetItemLevel
local GetItemName          = GetItemName
local GetItemSoundCategory = GetItemSoundCategory
local GetItemTrait         = GetItemTrait
local GetItemType          = GetItemType
local d                    = d
local zo_strformat         = zo_strformat
local zo_strjoin           = zo_strjoin
-- Lua
local pairs                = pairs
local type                 = type

local colors = LIBZ.colors
colors.gold       = "|cFFD700" -- Gold
colors.faded_gold = "|c998100" -- Faded Gold
colors.light_blue = "|c88DDDD" -- Light Blue
colors.faded_blue = "|c44AAAA" -- Faded Blue

--------------------------------------------------
-- LIBZ Settings functions
--------------------------------------------------
local settings = LIBZ.settings
settings.outputChatTab = ''
settings.debugEnabled  = false
settings.debugPrefix   = 'LIBZOLAN'

function LIBZ:setSettings(settings)
    self:debug('LZ: setSettings')

    self.table:overrideValues(self.settings, settings)
end

function LIBZ:setSetting(settingName, settingValue)
    self:debug('LZ: setSetting')

    self.setting[settingName] = settingValue
end

function LIBZ:debug(message, isRaw)
    if self.settings.debugEnabled then
        if isRaw then
            d(message)
        else
            d(self.settings.debugPrefix..": "..message)
        end
    end
end

--------------------------------------------------
-- LIBZ.table functions
--------------------------------------------------
function LIBZ.table:isTable(tableObj)
    return type(tableObj) == 'table'
end

function LIBZ.table:overrideValues(destinationTable, overrideTable)
    for key, value in pairs(overrideTable) do
        if self:isTable(overrideTable[key]) and self:isTable(destinationTable[key]) then
            self:overrideValues(destinationTable[key], overrideTable[key])
        else
            destinationTable[key] = value
        end
    end

    return destinationTable
end

function LIBZ.table:setMissingValuesFromTemplate(destinationTable, templateTable)
    for key, value in pairs(templateTable) do
        if destinationTable[key] == nil then
            destinationTable[key] = value
        elseif self:isTable(templateTable[key]) then
            self:setMissingValuesFromTemplate(destinationTable[key], templateTable[key])
        end
    end

    return destinationTable
end

function LIBZ.table:removeValuesNotInTemplate(destinationTable, templateTable)
    for key, value in pairs(destinationTable) do
        if templateTable[key] == nil then
            destinationTable[key] = nil
        elseif self:isTable(destinationTable[key]) then
            self:removeValueNotInTemplate(destinationTable[key], templateTable[key])
        end
    end

    return destinationTable
end

--------------------------------------------------
-- LIBZ Chat Functions
--------------------------------------------------
function LIBZ:sendMessageToChat(formattedMessage, toCurrentBuffer)
    -- Default buffer to current buffer.
    local mainContainerNum = 1

    local container = CHAT_SYSTEM.containers[mainContainerNum]
    local tab       = nil
    local buffer    = container.currentBuffer

    local tabName = self.settings.outputChatTab

    if (not toCurrentBuffer) and tabName and tabName ~= '' then
        local containerNum, tabNum = self:getContainerAndTabNumFromTabName(
            tabName
        )

        if containerNum ~= nil and tabNum ~= nil then
            container = CHAT_SYSTEM.containers[containerNum]
            tab       = container.windows[tabNum]
            buffer    = tab.buffer
        end
    end

    buffer:AddMessage(formattedMessage)
end

function LIBZ:getContainerAndTabNumFromTabName(tabName)
    self:debug("LZ: getContainerAndTabNumFromTabName")

    for container = 1, GetNumChatContainers(), 1 do
        for tab = 1, GetNumChatContainerTabs(), 1 do
            if GetChatContainerTabInfo(container, tab) == tabName then
                return container, tab
            end
        end
    end

    return nil, nil
end

--------------------------------------------------
-- LIBZ Item Functions
--------------------------------------------------
function LIBZ:formatItemLink(itemLink)
    self:debug("LZ: formatItemLink")

    return zo_strformat(SI_TOOLTIP_ITEM_NAME, itemLink)
end

function LIBZ:getUniqueItemKey(bagID, slotID)
    -- ZL:debug("ZL: getUniqueItemKey")

    local itemLevel         = GetItemLevel(bagID, slotID)
    local itemName          = GetItemName(bagID, slotID)
    local itemSoundCategory = GetItemSoundCategory(bagID, slotID)
    local itemTrait         = GetItemTrait(bagID, slotID)
    local itemType          = GetItemType(bagID, slotID)

    local itemInfo          = { GetItemInfo(bagID, slotID) }
    local itemTexture       = itemInfo[1]
    local itemSellPrice     = itemInfo[3]
    local itemEquipType     = itemInfo[6]
    local itemStyle         = itemInfo[7]
    local itemQuality       = itemInfo[8]

    local itemKey = zo_strjoin(':',
        itemLevel,
        itemName,
        itemSoundCategory,
        itemTrait,
        itemType,
        itemSellPrice,
        itemEquipType,
        itemStyle,
        itemQuality
    )

    return itemKey
end
