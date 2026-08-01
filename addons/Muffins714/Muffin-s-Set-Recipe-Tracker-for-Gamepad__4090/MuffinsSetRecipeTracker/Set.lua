-- Create a local shortcut for global
local MSRT = MuffinsSetRecipeTracker

-- Custom Tooltip Object
local MSRT_CustomTooltip = ZO_InitializingObject:Subclass()
local MSRTMythicCache -- Nil until first mythic tooltip scroll

function MSRT_CustomTooltip:Initialize(parent)
    self.parent = parent
    self.root = parent:GetNamedChild("Tip")
    self.anchors = {
        ZO_Anchor:New(select(2, self.root:GetAnchor(0))),
        ZO_Anchor:New(select(2, self.root:GetAnchor(1)))
    }

    self.control = CreateControlFromVirtual("$(parent)MSRTCollectedTooltip", parent, "MSRT_GamepadTooltip")
    self.control:SetWidth(parent:GetWidth())
    table.insert(self.anchors, ZO_Anchor:New(BOTTOMRIGHT, self.control, TOPRIGHT, 0, 0))

    self.tooltip = self.control:GetNamedChild("Tip")
    ZO_Tooltip:Initialize(self.tooltip, ZO_TOOLTIP_STYLES)

    self.control:SetHidden(true)
    parent.msrtTooltip = self

    ZO_PostHookHandler(parent, "OnEffectivelyHidden", function()
        self:Reset()
    end)

    if parent.tip and parent.tip.ClearLines then
        local originalClear = parent.tip.ClearLines
        parent.tip.ClearLines = function(tip, ...)
            originalClear(tip, ...)
            self:Reset()
        end
    end
end

function MSRT_CustomTooltip:Layout(itemLink, fromSetBook) -- Use Item Sets Book toggle otherwise show normal tooltips like before
    self.tooltip:ClearLines()
    self:Reset()

    local settings = MSRT.GetSettings()
    ---------------------------------------------------------------------------------------------
    -- Collectible combination fragment check
    ---------------------------------------------------------------------------------------------
    --TODO Fix the combination fragments that require 2 items so it doesn't show if you already combined.
    local combinationId = GetItemLinkCombinationId(itemLink)
    local fragmentCollectibleId -- hoisted so we can check it below
    if not combinationId or combinationId == 0 then
        fragmentCollectibleId = GetCollectibleIdFromLink(itemLink)
        if fragmentCollectibleId and fragmentCollectibleId ~= 0 then
            local _, _, _, _, _, _, _, categoryType = GetCollectibleInfo(fragmentCollectibleId)
            if categoryType == COLLECTIBLE_CATEGORY_TYPE_COMBINATION_FRAGMENT then
                combinationId = GetCollectibleReferenceId(fragmentCollectibleId)
            end
        end
    end

    -- show already owned if the combined result is already unlocked
    if fragmentCollectibleId and not CanCombinationFragmentBeUnlocked(fragmentCollectibleId) then
        return
    end

    if combinationId and combinationId ~= 0 then
        local numComponents = GetCombinationNumCollectibleComponents(combinationId)
        local knownColor    = ZO_ColorDef:New(0.2, 1, 0.2)
        local unknownColor  = ZO_ColorDef:New(1, 0.2, 0.2)
        local owned         = 0
        local entries       = {}

        for i = 1, numComponents do
            local collectibleId = GetCombinationCollectibleComponentId(combinationId, i)
            local name, _, _, _, unlocked = GetCollectibleInfo(collectibleId)
            if unlocked then
                table.insert(entries, knownColor:Colorize(name))
                owned = owned + 1
            else
                table.insert(entries, unknownColor:Colorize(name))
            end
        end

        local fragSection = self.tooltip:AcquireSection(self.tooltip:GetStyle("msrtGamepadSection"))
        fragSection:AddLine(
            string.format("FRAGMENTS (%d/%d)", owned, numComponents),
            self.tooltip:GetStyle("bodyHeader")
        )
        fragSection:AddLine(table.concat(entries, ", "), {
            fontSize            = "$(GP_20)",
            fontColor           = ZO_ColorDef:New(1, 1, 1),
            wrapText            = true,
            horizontalAlignment = TEXT_ALIGN_CENTER,
        })
        self.tooltip:AddSection(fragSection)
        self:SetAnchors()
        self.control:SetHidden(false)
        self.control:SetHeight(fragSection:GetHeight())
        return
    end
    ---------------------------------------------------------------------------------------------
    -- Style page check
    ---------------------------------------------------------------------------------------------
    local collectId = GetItemLinkContainerCollectibleId(itemLink)
    if collectId and collectId ~= 0 then
        local setName = MSRT.UndauntedIndex[collectId] or MSRT.StylePageIndex[collectId]
        -- MSRT.UndauntedIndex must go first to ignore topLevelIndex 16 for Undaunted 2pc sets
        local setData = setName and (MSRT.UndauntedSets[setName] or MSRT.StyleSets[setName])
        if setName and setData then
            local knownColor   = ZO_ColorDef:New(0.2, 1, 0.2)
            local unknownColor = ZO_ColorDef:New(1, 0.2, 0.2)
            local owned        = 0
            local entries      = {}

            local sortedPieces = {}
            for id, slotName in pairs(setData.pieces) do
                table.insert(sortedPieces, { id = id, slotName = slotName })
            end
            table.sort(sortedPieces, function(a, b) return a.slotName < b.slotName end)

            for _, piece in ipairs(sortedPieces) do
                local isOwned = IsCollectibleUnlocked(piece.id)
                if isOwned then
                    table.insert(entries, knownColor:Colorize(piece.slotName))
                    owned = owned + 1
                else
                    table.insert(entries, unknownColor:Colorize(piece.slotName))
                end
            end

            local styleSection = self.tooltip:AcquireSection(self.tooltip:GetStyle("msrtGamepadSection"))
            styleSection:AddLine(
                string.format("%s (%d/%d)", zo_strupper(setName), owned, setData.total),
                self.tooltip:GetStyle("bodyHeader")
            )
            if not (settings.HideCompletedSetPage and owned == setData.total) then -- For completed style page set settings
                styleSection:AddLine(table.concat(entries, ", "), {
                    fontSize            = "$(GP_20)",
                    fontColor           = ZO_ColorDef:New(1, 1, 1),
                    wrapText            = true,
                    horizontalAlignment = TEXT_ALIGN_CENTER,
                })
            end
            self.tooltip:AddSection(styleSection)
            self:SetAnchors()
            self.control:SetHidden(false)
            self.control:SetHeight(styleSection:GetHeight())
            return
        end
    end

    ---------------------------------------------------------------------------------------------
    -- Collectible set filter
    ---------------------------------------------------------------------------------------------
    -- Set containers use a different API than regular set pieces
    local setId
    local numContainerSets = GetItemLinkNumContainerSetIds(itemLink)
    if numContainerSets and numContainerSets > 0 then
        setId = select(6, GetItemLinkContainerSetInfo(itemLink, 1))
    elseif IsItemLinkSetCollectionPiece(itemLink) then
        setId = select(6, GetItemLinkSetInfo(itemLink))
    end
    if not setId or setId == 0 then return end

    -- If in the Item Sets Book and toggles are off thn show nothing
    if fromSetBook and not settings.showSetBookPieces and not settings.showSetBookFragments then
        return
    end
    ---------------------------------------------------------------------------------------------
    -- Set information
    ---------------------------------------------------------------------------------------------
    if not fromSetBook or settings.showSetBookPieces then
        local total     = GetNumItemSetCollectionPieces(setId)
        local collected = GetNumItemSetCollectionSlotsUnlocked(setId)

        local section   = self.tooltip:AcquireSection(self.tooltip:GetStyle("msrtGamepadSection"))
        section:AddLine(string.format("COLLECTED (%d/%d)", collected, total), self.tooltip:GetStyle("bodyHeader"))
        if not (settings.HideCompletedSetPieces and collected == total) then -- For completed set settings
            local ItemCategories       = {
                [GAMEPAD_ITEM_CATEGORY_LIGHT_ARMOR]  = {},
                [GAMEPAD_ITEM_CATEGORY_MEDIUM_ARMOR] = {},
                [GAMEPAD_ITEM_CATEGORY_HEAVY_ARMOR]  = {},
                [GAMEPAD_ITEM_CATEGORY_JEWELRY]      = {},
                [GAMEPAD_ITEM_CATEGORY_WEAPONS]      = {},
            }

            local FilterTypeToCategory = {
                [EQUIPMENT_FILTER_TYPE_LIGHT]        = GAMEPAD_ITEM_CATEGORY_LIGHT_ARMOR,
                [EQUIPMENT_FILTER_TYPE_MEDIUM]       = GAMEPAD_ITEM_CATEGORY_MEDIUM_ARMOR,
                [EQUIPMENT_FILTER_TYPE_HEAVY]        = GAMEPAD_ITEM_CATEGORY_HEAVY_ARMOR,
                [EQUIPMENT_FILTER_TYPE_NECK]         = GAMEPAD_ITEM_CATEGORY_JEWELRY,
                [EQUIPMENT_FILTER_TYPE_RING]         = GAMEPAD_ITEM_CATEGORY_JEWELRY,
                [EQUIPMENT_FILTER_TYPE_BOW]          = GAMEPAD_ITEM_CATEGORY_WEAPONS,
                [EQUIPMENT_FILTER_TYPE_DESTRO_STAFF] = GAMEPAD_ITEM_CATEGORY_WEAPONS,
                [EQUIPMENT_FILTER_TYPE_ONE_HANDED]   = GAMEPAD_ITEM_CATEGORY_WEAPONS,
                [EQUIPMENT_FILTER_TYPE_RESTO_STAFF]  = GAMEPAD_ITEM_CATEGORY_WEAPONS,
                [EQUIPMENT_FILTER_TYPE_SHIELD]       = GAMEPAD_ITEM_CATEGORY_WEAPONS,
                [EQUIPMENT_FILTER_TYPE_TWO_HANDED]   = GAMEPAD_ITEM_CATEGORY_WEAPONS,
            }

            local knownColor           = ZO_ColorDef:New(0.2, 1, 0.2)
            local unknownColor         = ZO_ColorDef:New(1, 0.2, 0.2)

            for i = 1, total do
                local pieceId, slot = GetItemSetCollectionPieceInfo(setId, i)
                local filterType    = GetEquipmentFilterTypeForItemSetCollectionSlot(slot)
                local category      = FilterTypeToCategory[filterType]

                if category then
                    local pieceLink  = GetItemSetCollectionPieceItemLink(pieceId, LINK_STYLE_DEFAULT,
                        ITEM_TRAIT_TYPE_NONE)
                    local armorType  = GetItemLinkArmorType(pieceLink)
                    local equipType  = GetItemLinkEquipType(pieceLink)
                    local weaponType = GetItemLinkWeaponType(pieceLink)

                    local name
                    if not name or name == "" then
                        if armorType ~= ARMORTYPE_NONE or equipType ~= EQUIP_TYPE_INVALID then
                            name = GetString("SI_EQUIPTYPE", equipType)
                        end
                    end
                    if weaponType ~= WEAPONTYPE_NONE then
                        name = GetString("MSRT_WEAPONTYPE", weaponType)
                    end
                    if not name or name == "" then name = "UNKNOWN" end

                    local isCollected = IsItemSetCollectionSlotUnlocked(setId, slot)
                    local coloredName = (isCollected and knownColor or unknownColor):Colorize(name)
                    table.insert(ItemCategories[category], coloredName)
                end
            end

            local displayOrder = {
                GAMEPAD_ITEM_CATEGORY_LIGHT_ARMOR,
                GAMEPAD_ITEM_CATEGORY_MEDIUM_ARMOR,
                GAMEPAD_ITEM_CATEGORY_HEAVY_ARMOR,
                GAMEPAD_ITEM_CATEGORY_JEWELRY,
                GAMEPAD_ITEM_CATEGORY_WEAPONS,
            }

            local categoryLabels = {
                [GAMEPAD_ITEM_CATEGORY_LIGHT_ARMOR]  = "LIGHT ARMOR",
                [GAMEPAD_ITEM_CATEGORY_MEDIUM_ARMOR] = "MEDIUM ARMOR",
                [GAMEPAD_ITEM_CATEGORY_HEAVY_ARMOR]  = "HEAVY ARMOR",
            }

            for _, catId in ipairs(displayOrder) do
                local entries = ItemCategories[catId]
                if entries and #entries > 0 then
                    local label = categoryLabels[catId]
                    if label then
                        section:AddLine(label, {
                            fontSize            = "$(GP_18)",
                            fontColor           = ZO_ColorDef:New(1, 1, 1),
                            wrapText            = true,
                            horizontalAlignment = TEXT_ALIGN_CENTER,
                            uppercase           = true,
                        })
                    end
                    section:AddLine(table.concat(entries, ", "), {
                        fontSize            = "$(GP_20)",
                        fontColor           = ZO_ColorDef:New(1, 1, 1),
                        wrapText            = true,
                        horizontalAlignment = TEXT_ALIGN_CENTER,
                    })
                end
            end
        end
        self.tooltip:AddSection(section)
        section:AddLine('', self.tooltip:GetStyle("verticalPadding"))
    end
    if not fromSetBook or settings.showSetBookFragments then
        ---------------------------------------------------------------------------------------------
        -- Mythic fragment check show after COLLECTED under same item
        ---------------------------------------------------------------------------------------------
        if not MSRTMythicCache then
            MSRTMythicCache = {}
            local aId = GetNextAntiquityId()
            while aId do
                local aSetId = GetAntiquitySetId(aId)
                if aSetId and aSetId ~= 0 then
                    local itemId = GetItemRewardItemId(GetAntiquitySetRewardId(aSetId))
                    if itemId and itemId ~= 0 then
                        MSRTMythicCache[itemId] = aSetId
                    end
                end
                aId = GetNextAntiquityId(aId)
            end
        end

        local antiquitySetId = MSRTMythicCache[GetItemLinkItemId(itemLink)]
        if antiquitySetId then
            local entries      = {}
            local doneColor    = ZO_ColorDef:New(0.2, 1, 0.2)
            local haveColor    = ZO_ColorDef:New(1, 0.8, 0.1)
            local missingColor = ZO_ColorDef:New(1, 0.2, 0.2)

            for i = 1, GetNumAntiquitySetAntiquities(antiquitySetId) do
                local aId  = GetAntiquitySetAntiquityId(antiquitySetId, i)
                local name = GetAntiquityName(aId)
                local coloredName
                if DoesAntiquityNeedCombination(aId) then
                    coloredName = doneColor:Colorize(name)
                elseif DoesAntiquityHaveLead(aId) then
                    coloredName = haveColor:Colorize(name)
                else
                    coloredName = missingColor:Colorize(name)
                end
                table.insert(entries, coloredName)
            end

            local fragSection = self.tooltip:AcquireSection(self.tooltip:GetStyle("msrtGamepadSection"))
            fragSection:AddLine("FRAGMENTS", self.tooltip:GetStyle("bodyHeader"))
            fragSection:AddLine(table.concat(entries, ", "), {
                fontSize            = "$(GP_20)",
                fontColor           = ZO_ColorDef:New(1, 1, 1),
                wrapText            = true,
                horizontalAlignment = TEXT_ALIGN_CENTER,
            })
            self.tooltip:AddSection(fragSection)
        end

        self:SetAnchors()
    end
    self.control:SetHidden(false)
    self.control:SetHeight(self.tooltip:GetHeight())
end

---------------------------------------------------------------------------------------------
-- Tooltip and Styles
---------------------------------------------------------------------------------------------

function MSRT_CustomTooltip:Reset()
    self.control:SetHidden(true)
    self.root:ClearAnchors()
    self.anchors[1]:AddToControl(self.root)
    self.anchors[2]:AddToControl(self.root)
end

function MSRT_CustomTooltip:SetAnchors()
    self.root:ClearAnchors()
    self.anchors[1]:AddToControl(self.root)
    self.anchors[3]:AddToControl(self.root)
end

ZO_TOOLTIP_STYLES.msrtGamepadSection = {
    paddingTop          = 0,
    customSpacing       = 5,
    fontSize            = "$(GP_20)",
    fontFace            = "$(GAMEPAD_MEDIUM_FONT)",
    fontColorField      = GAMEPAD_TOOLTIP_COLOR_GENERAL_COLOR_1,
    uppercase           = false,
    widthPercent        = 100,
    horizontalAlignment = TEXT_ALIGN_CENTER,
}

ZO_TOOLTIP_STYLES.verticalPadding = {
    customSpacing = 10,
    widthPercent  = 100,
}

local function GetOrCreateTooltip(container)
    if not container.msrtTooltip then
        container.msrtTooltip = MSRT_CustomTooltip:New(container)
    end
    return container.msrtTooltip
end

---------------------------------------------------------------------------------------------
-- Tooltip Hooking
---------------------------------------------------------------------------------------------
local function HookTooltip(method, getItemLink)
    local original = GAMEPAD_TOOLTIPS[method]
    if type(original) ~= "function" then return end

    GAMEPAD_TOOLTIPS[method] = function(self, tooltipType, ...)
        local result = original(self, tooltipType, ...)
        local link = getItemLink(...)
        if not link then return result end

        local container = self:GetTooltipContainer(tooltipType)
        if not container then return result end

        -- Style page check looks up MSRT.StylePageIndex filled by Data.lua and scanner
        local collectId = GetItemLinkContainerCollectibleId(link)
        if collectId and collectId ~= 0 and (MSRT.StylePageIndex[collectId] or MSRT.UndauntedIndex[collectId]) then
            GetOrCreateTooltip(container):Layout(link)
            return result
        end

        -- Collectible combination fragment like event vendor stuff
        local combinationId = GetItemLinkCombinationId(link)
        local fragmentCollectibleId
        if not combinationId or combinationId == 0 then
            fragmentCollectibleId = GetCollectibleIdFromLink(link)
            if fragmentCollectibleId and fragmentCollectibleId ~= 0 then
                local _, _, _, _, _, _, _, categoryType = GetCollectibleInfo(fragmentCollectibleId)
                if categoryType == COLLECTIBLE_CATEGORY_TYPE_COMBINATION_FRAGMENT then
                    combinationId = GetCollectibleReferenceId(fragmentCollectibleId)
                end
            end
        end
        if fragmentCollectibleId and not CanCombinationFragmentBeUnlocked(fragmentCollectibleId) then
            return result
        end
        if combinationId and combinationId ~= 0 then
            GetOrCreateTooltip(container):Layout(link)
            return result
        end

        -- Set containers use a different API than regular set pieces
        local numContainerSets = GetItemLinkNumContainerSetIds(link)
        if numContainerSets and numContainerSets > 0 then
            GetOrCreateTooltip(container):Layout(link)
            return result
        end

        -- Regular set collection piece filter
        if not IsItemLinkSetCollectionPiece(link) then return result end

        GetOrCreateTooltip(container):Layout(link)
        return result
    end
end

---------------------------------------------------------------------------------------------
-- Background auto grouping for style pages
---------------------------------------------------------------------------------------------
function MSRT.StylePageDatabase()
    -- Style pages are collectibles not recipes, so I scanned from Outfit Style collectible category
    local total = GetTotalCollectiblesByCategoryType(COLLECTIBLE_CATEGORY_TYPE_OUTFIT_STYLE)
    if not total or total == 0 then return end

    -- topLevelIndex 15
    local armorSlots = {
        [1] = "Head",
        [2] = "Chest",
        [3] = "Legs",
        [4] = "Shoulders",
        [5] = "Feet",
        [6] = "Hands",
        [7] = "Waist"
    }
    -- topLevelIndex 16
    local weaponFallback = {
        [1] = "Two Handed",
        [2] = "One Handed",
        [3] = "Shield",
        [4] = "Bow",
        [5] = "Staff"
    }

    for i = 1, total do
        local collectibleId = GetCollectibleIdFromType(COLLECTIBLE_CATEGORY_TYPE_OUTFIT_STYLE, i)

        if collectibleId and collectibleId ~= 0 and not MSRT.StylePageIndex[collectibleId] then
            local name, description, _, _, _, _, _, categoryType = GetCollectibleInfo(collectibleId)

            if categoryType == COLLECTIBLE_CATEGORY_TYPE_OUTFIT_STYLE
                and not (description and string.find(description, "^Learned from the")) -- This filter ignores reg motifs description
            then
                local topLevelIndex, categoryIndex = GetCategoryInfoFromCollectibleId(collectibleId)

                local slotName

                if topLevelIndex == 15 then
                    slotName = armorSlots[categoryIndex]
                elseif topLevelIndex == 16 then -- This is used to manually fix topLevelIndex to the correct label
                    slotName = name:match("(Greatsword)$")
                        or name:match("(Battle Axe)$")
                        or name:match("(Maul)$")
                        or name:match("(Sword)$")
                        or name:match("(Axe)$")
                        or name:match("(Mace)$")
                        or name:match("(Dagger)$")
                        or name:match("(Bow)$")
                        or name:match("(Shield)$")
                        or name:match("(Staff)$")
                        or weaponFallback[categoryIndex]
                end

                local baseSetName = description and (
                    description:match("in the (.+) style%.")
                    or description:match("^Part of (.+)'s style")
                    or description:match("^Part of the (.+) [Ss]tyle")
                )
                -- Data.lua is used to manually fix sets ESO does not describe cleanly
                if slotName and baseSetName then
                    local existingSet = MSRT.StyleSets[baseSetName]
                    local renamedSlotName = existingSet and existingSet.renames and existingSet.renames[collectibleId]
                    local excludedByRule = existingSet and existingSet.exclude
                        and existingSet.exclude.topLevelIndex
                        and existingSet.exclude.topLevelIndex[topLevelIndex]

                    if existingSet and existingSet.curated then
                        -- Curated set is used excludes pages manually
                    elseif excludedByRule and not renamedSlotName then
                        -- Matches the set's exclude rule
                    else
                        if not existingSet then
                            existingSet = { total = 0, pieces = {} }
                            MSRT.StyleSets[baseSetName] = existingSet
                        end
                        existingSet.pieces = existingSet.pieces or {}

                        -- rename to override the auto detected label
                        if renamedSlotName then
                            slotName = renamedSlotName
                        end

                        -- If label is already used in the set add a number instead of duplicating label
                        local baseSlotName = slotName
                        local matches = 0
                        for _, existingSlotName in pairs(existingSet.pieces) do
                            if existingSlotName == baseSlotName or existingSlotName:match("^" .. baseSlotName .. " %d+$") then
                                matches = matches + 1
                            end
                        end
                        if matches > 0 then
                            slotName = baseSlotName .. " " .. (matches + 1)
                        end

                        existingSet.pieces[collectibleId] = slotName
                        MSRT.StylePageIndex[collectibleId] = baseSetName
                    end
                end
            end
        end
    end

    for setName, data in pairs(MSRT.StyleSets) do
        if not data.curated then
            local count = 0
            for _ in pairs(data.pieces or {}) do count = count + 1 end
            data.total = count
        end
    end
end

---------------------------------------------------------------------------------------------
-- Undaunted style pages
---------------------------------------------------------------------------------------------

function MSRT.UndauntedDatabase()
    local total = GetTotalCollectiblesByCategoryType(COLLECTIBLE_CATEGORY_TYPE_OUTFIT_STYLE)
    if not total or total == 0 then return end

    local slotAliases = {
        [1] = { "Mask" },
        [4] = { "Shoulder" },
    }

    for i = 1, total do
        local collectibleId = GetCollectibleIdFromType(COLLECTIBLE_CATEGORY_TYPE_OUTFIT_STYLE, i)

        if collectibleId and collectibleId ~= 0 and not MSRT.UndauntedIndex[collectibleId] then
            local name, description, _, _, _, _, _, categoryType = GetCollectibleInfo(collectibleId)

            if categoryType == COLLECTIBLE_CATEGORY_TYPE_OUTFIT_STYLE
                and description -- This filter is only for Undaunted 2 piece sets
                and (
                    string.find(description, "^Obtained rarely by completing the dungeon Veteran ")
                    or string.find(description, "^Purchased from Glirion")
                    or string.find(description, "^Purchased from Maj")
                    or string.find(description, "^Purchased from Urgarlag")
                )
            then
                local topLevelIndex, categoryIndex = GetCategoryInfoFromCollectibleId(collectibleId)

                if topLevelIndex == 15 then
                    local aliases = slotAliases[categoryIndex]
                    if aliases then
                        local slotName
                        local baseSetName
                        for _, alias in ipairs(aliases) do
                            local stripped = name:match("^(.-)%s+" .. alias .. "%s*$")
                            if stripped then
                                slotName = alias
                                baseSetName = zo_strformat("<<1>>", stripped)
                                break
                            end
                        end

                        if baseSetName and slotName then
                            if not MSRT.UndauntedSets[baseSetName] then
                                MSRT.UndauntedSets[baseSetName] = { total = 0, pieces = {} }
                            end
                            MSRT.UndauntedSets[baseSetName].pieces[collectibleId] = slotName
                            MSRT.UndauntedSets[baseSetName].total = MSRT.UndauntedSets[baseSetName].total + 1
                            MSRT.UndauntedIndex[collectibleId] = baseSetName
                        end
                    end
                end
            end
        end
    end
end

---------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------
function MSRT_Initialize()
    MSRT.StylePageDatabase()
    MSRT.UndauntedDatabase()
    HookTooltip("LayoutItem", function(link) return link end)
    HookTooltip("LayoutBagItem", function(bag, slot) return GetItemLink(bag, slot) end)
    HookTooltip("LayoutGuildStoreSearchResult", function(link) return link end)
    HookTooltip("LayoutLink", function(link, ...) return link end)
    -- Event
    HookTooltip("LayoutStoreWindowItem", function(buyData) return buyData and buyData.itemLink end)

    -- Hook to Item Sets Book scene
    local _originalOnGridListSelectedDataChanged = ZO_ItemSetsBook_Gamepad_Base.OnGridListSelectedDataChanged
    ZO_ItemSetsBook_Gamepad_Base.OnGridListSelectedDataChanged = function(self, previousData, newData)
        _originalOnGridListSelectedDataChanged(self, previousData, newData)

        local container = GAMEPAD_TOOLTIPS:GetTooltipContainer(GAMEPAD_RIGHT_TOOLTIP)
        if not container then return end

        if newData and not newData.isEmptyCell then
            local itemLink = newData:GetItemLink()
            if itemLink and itemLink ~= "" then
                GetOrCreateTooltip(container):Layout(itemLink, true) -- true = fromSetBook
            end
        else
            local existing = container.msrtTooltip
            if existing then existing:Reset() end
        end
    end
end
