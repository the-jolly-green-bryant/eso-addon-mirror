-- TTDungeon_Sets.lua
-- Manages equipment set tracking and display for dungeon drops
-- Integrates with LibSets for collection information and shows completion status

-- Initialize addon namespace
TTDungeon = TTDungeon or {}

-- ================================================================================
-- Debug Logging
-- ================================================================================

-- Debug function specific to sets module
local function Debug(msg)
    if TTDungeon.savedVars and TTDungeon.savedVars.debugEnabled then
        d("[TTD Sets Extended] " .. tostring(msg))
    end
end

-- ================================================================================
-- Color Code Constants
-- ================================================================================

-- Define color codes for different collection states
local COLOR_UNLOCKED = "00FF00"  -- Green - All pieces collected
local COLOR_MISSING  = "FF0000"  -- Red - No pieces collected
local COLOR_PARTIAL  = "FFD700"  -- Gold - Some pieces collected
local COLOR_HEADER   = "66CCFF"  -- Light blue - Section headers

-- ================================================================================
-- Chat Integration
-- ================================================================================

-- Insert an item link into the current chat input without sending
-- Preserves existing chat text and channel
-- @param itemLink: The item link to insert
local function InsertItemLinkInChat(itemLink)
    if not itemLink or itemLink == "" then return end

    -- Get current chat state
    local currentText   = CHAT_SYSTEM.textEntry:GetText() or ""
    local currentChannel= CHAT_SYSTEM.currentChannel
    local currentTarget = CHAT_SYSTEM.currentTarget

    -- Append item link with space separator
    StartChatInput(currentText .. " " .. itemLink, currentChannel, currentTarget)
end

-- Handle shift-click on a set piece to link it in chat
-- @param pieceData: Data about the set piece including its ID
local function OnSlotShiftClick(pieceData)
    if not pieceData or not pieceData.id then return end
    
    local itemLink = ""
    -- Safely attempt to get item link
    pcall(function() 
        itemLink = GetItemSetCollectionPieceItemLink(pieceData.id, LINK_STYLE_BRACKETS, ITEM_TRAIT_TYPE_NONE) 
    end)
    
    if itemLink and itemLink ~= "" then
        InsertItemLinkInChat(itemLink)
    end
end

-- ================================================================================
-- Equipment Slot Icons
-- ================================================================================

-- Define icons for armor slots
-- Note: Head icon uses _d.dds variant for better visibility
local slotIcons = {
    [EQUIP_TYPE_HEAD]      = { name="Head",      icon="esoui/art/icons/gear_breton_light_head_d.dds" },
    [EQUIP_TYPE_SHOULDERS] = { name="Shoulders", icon="esoui/art/icons/gear_breton_light_shoulders_a.dds" },
    [EQUIP_TYPE_CHEST]     = { name="Chest",     icon="esoui/art/icons/gear_breton_light_robe_a.dds" },
    [EQUIP_TYPE_HAND]      = { name="Hands",     icon="esoui/art/icons/gear_breton_light_hands_a.dds" },
    [EQUIP_TYPE_WAIST]     = { name="Waist",     icon="esoui/art/icons/gear_breton_light_waist_a.dds" },
    [EQUIP_TYPE_LEGS]      = { name="Legs",      icon="esoui/art/icons/gear_breton_light_legs_a.dds" },
    [EQUIP_TYPE_FEET]      = { name="Feet",      icon="esoui/art/icons/gear_breton_light_feet_a.dds" },
    [EQUIP_TYPE_NECK]      = { name="Neck",      icon="esoui/art/icons/gear_argonian_neck_a.dds" },
    [EQUIP_TYPE_RING]      = { name="Ring",      icon="esoui/art/icons/gear_dunmer_ring_a.dds" },
}

-- Define icons for weapon types
local weaponIcons = {
    [WEAPONTYPE_AXE]             = { name="Axe",            icon="esoui/art/icons/gear_breton_dagger_d.dds" },
    [WEAPONTYPE_HAMMER]          = { name="Mace",           icon="esoui/art/icons/gear_ordinator_1hhammer_a.dds" },
    [WEAPONTYPE_SWORD]           = { name="Sword",          icon="esoui/art/icons/gear_altmer_1hsword_d.dds" },
    [WEAPONTYPE_DAGGER]          = { name="Dagger",         icon="esoui/art/icons/gear_breton_dagger_d.dds" },
    [WEAPONTYPE_BOW]             = { name="Bow",            icon="esoui/art/icons/gear_breton_bow_d.dds" },
    [WEAPONTYPE_SHIELD]          = { name="Shield",         icon="esoui/art/icons/gear_breton_shield_d.dds" },
    [WEAPONTYPE_FIRE_STAFF]      = { name="Fire Staff",     icon="esoui/art/icons/gear_breton_staff_d.dds" },
    [WEAPONTYPE_FROST_STAFF]     = { name="Frost Staff",    icon="esoui/art/icons/gear_breton_staff_d.dds" },
    [WEAPONTYPE_LIGHTNING_STAFF] = { name="Lightning Staff",icon="esoui/art/icons/gear_breton_staff_d.dds" },
    [WEAPONTYPE_HEALING_STAFF]   = { name="Resto Staff",    icon="esoui/art/icons/gear_breton_staff_d.dds" },
    [WEAPONTYPE_TWO_HANDED_AXE]    = { name="Battle Axe",  icon="esoui/art/icons/gear_breton_2haxe_d.dds" },
    [WEAPONTYPE_TWO_HANDED_HAMMER] = { name="Maul",        icon="esoui/art/icons/gear_breton_2hhammer_d.dds" },
    [WEAPONTYPE_TWO_HANDED_SWORD]  = { name="Greatsword", icon="esoui/art/icons/gear_breton_2hsword_d.dds" },
}

-- ================================================================================
-- Set Information Functions
-- ================================================================================

-- Check if a set is a monster set (2-piece head/shoulder set)
-- Uses LibSets if available, falls back to hardcoded ID ranges
-- @param setId: The set ID to check
-- @return: true if monster set, false otherwise
local function IsMonsterSet(setId)
    if not setId then return false end
    
    -- Try LibSets first if available
    if LibSets and LibSets.IsMonsterSet then
        local ok, result = pcall(function() return LibSets.IsMonsterSet(setId) end)
        if ok and result ~= nil then
            return result
        end
    end
    
    -- Fallback to known monster set ID ranges
    return (setId>=166 and setId<=171)
        or (setId>=184 and setId<=185)
        or (setId>=260 and setId<=263)
        or (setId>=341 and setId<=342)
        or (setId>=432 and setId<=433)
end

-- Get the display name for a set
-- Uses LibSets or ESO API, with fallback to generic name
-- @param setId: The set ID
-- @return: Set name string
local function GetSetName(setId)
    if not setId then return "Unknown Set" end
    
    -- Try LibSets first
    if LibSets and LibSets.GetSetName then
        local ok, name = pcall(function() return LibSets.GetSetName(setId) end)
        if ok and name and name~="" then
            return name
        end
    end
    
    -- Try ESO API
    if GetItemSetInfo then
        local ok2, name2 = pcall(function() return GetItemSetInfo(setId) end)
        if ok2 and name2 and name2~="" then
            return name2
        end
    end
    
    -- Fallback to generic name with ID
    return "Set #" .. tostring(setId)
end

-- ================================================================================
-- Set Bonus Information
-- ================================================================================

-- Get all bonuses for a set
-- @param setId: The set ID
-- @return: Array of bonus tables with numRequired and description
local function GetSetBonuses(setId)
    local bonuses = {}
    if not setId or not GetNumItemSetBonusInfo then return bonuses end
    
    -- Get number of bonuses
    local num = 0
    pcall(function() num = GetNumItemSetBonusInfo(setId) end)
    
    if num and num > 0 then
        -- Retrieve each bonus
        for i = 1, num do
            local req, desc = nil, nil
            pcall(function() 
                _, req, desc = GetItemSetBonusInfo(setId, false, i)
            end)
            
            if req and desc and desc ~= "" then
                table.insert(bonuses, {numRequired = req, description = desc})
            end
        end
    end
    
    -- Sort bonuses by number of pieces required
    table.sort(bonuses, function(a, b) 
        if not a or not a.numRequired then return false end
        if not b or not b.numRequired then return true end
        return a.numRequired < b.numRequired 
    end)
    
    return bonuses
end

-- ================================================================================
-- Collection Information
-- ================================================================================

-- Get detailed collection information for a set
-- @param setId: The set ID
-- @return: Table with collection statistics and piece details
local function GetCollectionInfo(setId)
    -- Initialize collection structure
    local coll = {
        total = 0,
        unlocked = 0,
        pieces = {},
        byCategory = {
            [ARMORTYPE_LIGHT]  = { count = 0, unlocked = 0, items = {} },
            [ARMORTYPE_MEDIUM] = { count = 0, unlocked = 0, items = {} },
            [ARMORTYPE_HEAVY]  = { count = 0, unlocked = 0, items = {} },
            ["jewelry"]        = { count = 0, unlocked = 0, items = {} },
            ["weapons"]        = { count = 0, unlocked = 0, items = {} },
        }
    }
    
    if not setId or not (GetNumItemSetCollectionPieces and GetItemSetCollectionPieceInfo) then
        return coll
    end

    -- Get total number of pieces in the set
    local totalPieces = 0
    pcall(function() totalPieces = GetNumItemSetCollectionPieces(setId) end)
    
    if totalPieces and totalPieces > 0 then
        coll.total = totalPieces

        -- Get number of unlocked pieces
        local unlockedCount = 0
        pcall(function() unlockedCount = GetNumItemSetCollectionSlotsUnlocked(setId) end)
        
        if unlockedCount then
            coll.unlocked = unlockedCount
        end

        -- Process each piece
        for i = 1, totalPieces do
            local pieceId, slot = nil, nil
            pcall(function() pieceId, slot = GetItemSetCollectionPieceInfo(setId, i) end)
            
            if pieceId and slot then
                -- Get item link for this piece
                local link = ""
                pcall(function() link = GetItemSetCollectionPieceItemLink(pieceId, LINK_STYLE_DEFAULT, ITEM_TRAIT_TYPE_NONE) end)
                
                if link and link ~= "" then
                    -- Extract equipment information from link
                    local eType, wType, aType = EQUIP_TYPE_INVALID, WEAPONTYPE_NONE, ARMORTYPE_NONE
                    
                    pcall(function() eType = GetItemLinkEquipType(link) end)
                    pcall(function() wType = GetItemLinkWeaponType(link) end)
                    pcall(function() aType = GetItemLinkArmorType(link) end)

                    -- Check if piece is unlocked
                    local isUnlocked = false
                    pcall(function() isUnlocked = IsItemSetCollectionSlotUnlocked(setId, slot) end)

                    -- Determine label and icon based on piece type
                    local label, icon
                    if wType and wType ~= WEAPONTYPE_NONE then
                        -- Weapon piece
                        local wData = weaponIcons[wType]
                        if wData then
                            label = wData.name
                            icon = wData.icon
                        else
                            label = "Weapon?"
                            icon = "esoui/art/icons/icon_missing.dds"
                        end
                    elseif eType and (eType == EQUIP_TYPE_NECK or eType == EQUIP_TYPE_RING) then
                        -- Jewelry piece
                        local sData = slotIcons[eType]
                        if sData then
                            label = sData.name
                            icon = sData.icon
                        else
                            label = "Jewelry?"
                            icon = "esoui/art/icons/icon_missing.dds"
                        end
                    else
                        -- Armor piece
                        local eqData = slotIcons[eType]
                        if eqData then
                            label = eqData.name
                            icon = eqData.icon
                        else
                            label = "Armor?"
                            icon = "esoui/art/icons/icon_missing.dds"
                        end
                    end

                    -- Create piece data entry
                    local pieceData = {
                        id = pieceId,
                        slot = slot,
                        equipType = eType,
                        weaponType = wType,
                        armorType = aType,
                        isUnlocked = isUnlocked,
                        icon = icon,
                        label = label,
                    }
                    table.insert(coll.pieces, pieceData)

                    -- Categorize the piece
                    local catKey
                    if eType and (eType == EQUIP_TYPE_NECK or eType == EQUIP_TYPE_RING) then
                        catKey = "jewelry"
                    elseif wType and wType ~= WEAPONTYPE_NONE then
                        catKey = "weapons"
                    elseif aType and aType ~= ARMORTYPE_NONE then
                        catKey = aType
                    end
                    
                    -- Add to category statistics
                    if catKey and coll.byCategory[catKey] then
                        local cat = coll.byCategory[catKey]
                        cat.count = cat.count + 1
                        if isUnlocked then
                            cat.unlocked = cat.unlocked + 1
                        end
                        table.insert(cat.items, pieceData)
                    end
                end
            end
        end
    end
    return coll
end

-- ================================================================================
-- Tooltip Generation
-- ================================================================================

-- Add set information lines to a tooltip (short version without source info)
-- @param tooltip: The tooltip control to add lines to
-- @param setId: The set ID to display
local function AddSetTooltipLines(tooltip, setId)
    -- Safety checks
    if not tooltip or not setId then return end
    
    -- Get set information
    local setName = GetSetName(setId)
    local isMonster = IsMonsterSet(setId)
    local coll = GetCollectionInfo(setId)
    local bonuses = GetSetBonuses(setId)

    -- 1) Header with set name
    local nameColor = isMonster and "FFD700" or "FFFFFF"  -- Gold for monster sets, white for others
    tooltip:AddLine("|c" .. nameColor .. setName .. "|r", "ZoFontHeader2")
    ZO_Tooltip_AddDivider(tooltip)

    -- 2) Type and Collection summary
    local setTypeText = isMonster and "Monster Set" or "Regular Set"
    tooltip:AddLine("|c" .. COLOR_HEADER .. "Type:|r " .. setTypeText, "ZoFontGameBold")

    -- Collection progress
    if coll and type(coll.total) == "number" and coll.total > 0 then
        local unlocked = type(coll.unlocked) == "number" and coll.unlocked or 0
        local total = coll.total
        
        -- Determine color based on collection progress
        local ccolor = COLOR_MISSING
        if unlocked > 0 then
            if unlocked == total then
                ccolor = COLOR_UNLOCKED
            else
                ccolor = COLOR_PARTIAL
            end
        end
        
        -- Calculate percentage
        local percent = 0
        if total > 0 then
            percent = math.floor(100 * unlocked / total)
        end
        
        tooltip:AddLine(string.format("|c%sCollection: %d/%d (%d%%)|r", 
            ccolor, unlocked, total, percent), "ZoFontGameBold")

        -- Transmute cost
        if GetItemReconstructionCurrencyOptionCost then
            local cost = 0
            pcall(function() cost = GetItemReconstructionCurrencyOptionCost(setId, CURT_CHAOTIC_CREATIA) end)
            if cost and cost > 0 then
                tooltip:AddLine(string.format("Transmute Cost: %d |t20:20:EsoUI/Art/currency/currency_transmute.dds|t", 
                    cost), "ZoFontGame")
            end
        end
    end

    -- 3) Divider before categories
    ZO_Tooltip_AddDivider(tooltip)

    -- 4) Collection slot categories
    local hasPieces = false
    if coll and coll.pieces and type(coll.pieces) == "table" then
        hasPieces = #coll.pieces > 0
    end
    
    if hasPieces then
        tooltip:AddLine("|c" .. COLOR_HEADER .. "Collection Slots:|r", "ZoFontGameBold")

        -- Define category display order
        local catDefs = {
            { type = ARMORTYPE_LIGHT,  label = "Light Armor"  },
            { type = ARMORTYPE_MEDIUM, label = "Medium Armor" },
            { type = ARMORTYPE_HEAVY,  label = "Heavy Armor"  },
            { type = "jewelry",        label = "Jewelry"      },
            { type = "weapons",        label = "Weapons"      },
        }
        
        -- Display each category with pieces
        for _, cdef in ipairs(catDefs) do
            if coll.byCategory and type(coll.byCategory) == "table" and coll.byCategory[cdef.type] then
                local cat = coll.byCategory[cdef.type]
                
                -- Safety checks for category data
                local count = type(cat.count) == "number" and cat.count or 0
                local unlocked = type(cat.unlocked) == "number" and cat.unlocked or 0
                
                if count > 0 then
                    -- Determine category color
                    local catColor = COLOR_MISSING
                    if unlocked > 0 then
                        if unlocked == count then
                            catColor = COLOR_UNLOCKED
                        else
                            catColor = COLOR_PARTIAL
                        end
                    end
                    
                    -- Add category header line
                    tooltip:AddLine(string.format("|c%s%s (%d/%d)|r", 
                        catColor, cdef.label, unlocked, count), "ZoFontGameBold")

                    -- Build piece list for this category
                    local parts = {}
                    if cat.items and type(cat.items) == "table" then
                        for _, piece in ipairs(cat.items) do
                            if piece then
                                local clr = piece.isUnlocked and COLOR_UNLOCKED or COLOR_MISSING
                                local icn = piece.icon or "esoui/art/icons/icon_missing.dds"
                                local lbl = piece.label or "Slot?"
                                local txt = string.format("|t20:20:%s|t |c%s%s|r", icn, clr, lbl)
                                table.insert(parts, txt)
                            end
                        end
                    end
                    
                    -- Add piece icons line
                    if #parts > 0 then
                        local line = "   " .. table.concat(parts, ",  ")
                        tooltip:AddLine(line, "ZoFontGame")
                    end
                end
            end
        end
    end

    -- 5) Set bonuses
    if bonuses and type(bonuses) == "table" and #bonuses > 0 then
        ZO_Tooltip_AddDivider(tooltip)
        tooltip:AddLine("|c" .. COLOR_HEADER .. "Set Bonuses:|r", "ZoFontGameBold")
        
        for _, b in ipairs(bonuses) do
            if b and type(b) == "table" and b.numRequired and b.description then
                tooltip:AddLine(string.format("|cFFD700(%d items)|r %s", 
                    b.numRequired, b.description), "ZoFontGame")
            end
        end
    end
end

-- ================================================================================
-- Scroll Management
-- ================================================================================

-- Clamp scroll offset for sets container
-- Handles inverted scroll based on user preference
-- @param self: The scroll control
local function ClampScrollOffset_Sets(self)
    if not self or not self.scrollChild then return end
    
    local scChild = self.scrollChild
    local cH = self:GetHeight()      -- Container height
    local sH = scChild:GetHeight()   -- Content height
    
    if sH <= cH then
        -- Content fits in container
        self.offsetY = 0
    else
        -- Calculate valid scroll range
        local minOffset = -(sH - cH)
        if self.offsetY > 0 then
            self.offsetY = 0
        elseif self.offsetY < minOffset then
            self.offsetY = minOffset
        end
    end
    
    -- Apply scroll offset
    scChild:ClearAnchors()
    scChild:SetAnchor(TOPLEFT, self, TOPLEFT, 0, self.offsetY)
end

-- ================================================================================
-- Extended Set Window
-- ================================================================================

-- Table to store open set detail windows
TTDungeon.setWindows = TTDungeon.setWindows or {}

-- Build the content for an extended set window
-- @param winData: Window data containing references and set ID
local function BuildSetWindowContent(winData)
    local scChild = winData.scChild
    local setId   = winData.setId
    if not scChild or not setId then return end

    -- Clear existing content
    for i = scChild:GetNumChildren() - 1, 0, -1 do
        local oldC = scChild:GetChild(i)
        if oldC then
            oldC:SetHidden(true)
            oldC:SetParent(nil)
        end
    end
    scChild:SetHeight(0)

    local rowWidth = scChild:GetWidth()
    local offsetY = 0
    local marginV = 5

    -- Helper function to add a text line
    local function AddLine(text, font)
        local row = CreateControl(nil, scChild, CT_CONTROL)
        row:SetAnchor(TOPLEFT, scChild, TOPLEFT, 0, offsetY)

        local label = CreateControl(nil, row, CT_LABEL)
        label:SetFont(font or "ZoFontGame")
        label:SetWrapMode(TEXT_WRAP_MODE_WORD)
        label:SetMaxLineCount(0)
        label:SetAnchor(TOPLEFT, row, TOPLEFT, 10, 0)
        label:SetWidth(rowWidth - 20)
        label:SetText(text)

        local h = label:GetTextHeight() or 20
        local finalH = h + marginV
        if finalH < 30 then finalH = 30 end
        row:SetDimensions(rowWidth, finalH)
        offsetY = offsetY + finalH
    end

    -- Get set information
    local setName = GetSetName(setId)
    local coll    = GetCollectionInfo(setId)
    local bonuses = GetSetBonuses(setId)

    -- Add header and divider
    AddLine(string.format("|cFFD700%s|r", setName), "ZoFontHeader2")
    AddLine("------------------------------------------------", "ZoFontGameSmall")

    -- Add shift-click instruction
    AddLine("|c999999(Shift+Click a slot to link in chat)|r", "ZoFontGameSmall")

    -- Add collection summary
    if coll and coll.total and coll.total > 0 then
        local color = COLOR_MISSING
        if coll.unlocked and coll.total and coll.unlocked == coll.total then
            color = COLOR_UNLOCKED
        elseif coll.unlocked and coll.unlocked > 0 then
            color = COLOR_PARTIAL
        end
        
        local pct = 0
        if coll.total > 0 then
            pct = math.floor(100 * (coll.unlocked or 0) / coll.total)
        end
        
        AddLine(string.format("|c%sCollection: %d/%d (%d%%)|r", 
                color, coll.unlocked or 0, coll.total, pct))
    end

    offsetY = offsetY + 10
    AddLine("|c66CCFFSlots:|r", "ZoFontGameBold")

    -- Define category display order
    local catDefs = {
        { type = ARMORTYPE_LIGHT,  label = "Light Armor" },
        { type = ARMORTYPE_MEDIUM, label = "Medium Armor"},
        { type = ARMORTYPE_HEAVY,  label = "Heavy Armor"},
        { type = "jewelry",        label = "Jewelry"    },
        { type = "weapons",        label = "Weapons"    },
    }
    
    -- Display each category with interactive pieces
    for _, cdef in ipairs(catDefs) do
        if coll and coll.byCategory and coll.byCategory[cdef.type] then
            local cat = coll.byCategory[cdef.type]
            if cat and cat.count and cat.count > 0 then
                -- Category header
                AddLine(string.format("%s (%d/%d)", cdef.label, cat.unlocked or 0, cat.count or 0), "ZoFontGameBold")

                -- Individual pieces
                if cat.items then
                    for _, piece in ipairs(cat.items) do
                        if piece then
                            local color = piece.isUnlocked and COLOR_UNLOCKED or COLOR_MISSING
                            local slotName = piece.label or "Slot?"
                            local slotIcon = piece.icon or "esoui/art/icons/icon_missing.dds"

                            -- Create clickable piece row
                            local row = CreateControl(nil, scChild, CT_CONTROL)
                            row:SetAnchor(TOPLEFT, scChild, TOPLEFT, 0, offsetY)

                            local lab = CreateControl(nil, row, CT_LABEL)
                            lab:SetFont("ZoFontGame")
                            lab:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
                            lab:SetMaxLineCount(1)
                            lab:SetAnchor(LEFT, row, LEFT, 20, 0)
                            lab:SetWidth(rowWidth - 60)
                            lab:SetText(string.format("|t20:20:%s|t |c%s%s|r", slotIcon, color, slotName))

                            -- Enable shift-click to link
                            lab:SetMouseEnabled(true)
                            lab:SetHandler("OnMouseDown", function(_, mouseButton)
                                if mouseButton == MOUSE_BUTTON_INDEX_LEFT and IsShiftKeyDown() then
                                    Debug("Shift+LeftClick on piece => " .. tostring(piece.id))
                                    OnSlotShiftClick(piece)
                                end
                            end)

                            local h = lab:GetTextHeight() or 20
                            if h < 30 then h = 30 end
                            row:SetDimensions(rowWidth, h)
                            offsetY = offsetY + h
                        end
                    end
                    offsetY = offsetY + 10
                end
            end
        end
    end

    -- Add set bonuses
    offsetY = offsetY + 10
    if bonuses and #bonuses > 0 then
        AddLine("|c66CCFFBonuses:|r", "ZoFontGameBold")
        for _, b in ipairs(bonuses) do
            if b and b.numRequired and b.description then
                AddLine(string.format("|cFFD700(%d items)|r %s", b.numRequired, b.description))
            end
        end
        offsetY = offsetY + 10
    end

    scChild:SetHeight(offsetY)
end

-- Show an extended window with detailed set information
-- @param setId: The set ID to display
function TTDungeon.ShowExtendedSetWindow(setId)
    if not setId then return end
    local key = "TTD_SetWindow_" .. tostring(setId)
    
    -- Check if window already exists
    if TTDungeon.setWindows[key] then
        local w = TTDungeon.setWindows[key]
        w.ui:SetHidden(false)
        return
    end

    -- Create new window
    local ui = CreateControl(key, GuiRoot, CT_TOPLEVELCONTROL)
    ui:SetDimensions(500, 400)
    ui:SetClampedToScreen(true)
    ui:SetMouseEnabled(true)
    ui:SetMovable(true)
    ui:SetResizeHandleSize(16)
    ui:SetHidden(false)
    ui:ClearAnchors()
    ui:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)

    -- Window background
    local backdrop = CreateControl(nil, ui, CT_BACKDROP)
    backdrop:SetAnchorFill(ui)
    backdrop:SetCenterColor(0, 0, 0, 0.8)
    backdrop:SetEdgeTexture("EsoUI/Art/Tooltips/UI-Border.dds", 128, 16, 16)
    backdrop:SetEdgeColor(1, 1, 1, 1)

    -- Title container
    local titleContainer = CreateControl(nil, ui, CT_CONTROL)
    titleContainer:SetResizeToFitDescendents(true)
    titleContainer:SetAnchor(TOPLEFT, ui, TOPLEFT, 0, 0)
    titleContainer:SetAnchor(TOPRIGHT, ui, TOPRIGHT, 0, 0)

    -- Close button
    local closeBtn = CreateControl(nil, titleContainer, CT_BUTTON)
    closeBtn:SetDimensions(32, 32)
    closeBtn:SetAnchor(TOPRIGHT, titleContainer, TOPRIGHT, -5, 5)
    closeBtn:SetNormalTexture("EsoUI/Art/Buttons/closebutton_up.dds")
    closeBtn:SetPressedTexture("EsoUI/Art/Buttons/closebutton_down.dds")
    closeBtn:SetMouseOverTexture("EsoUI/Art/Buttons/closebutton_over.dds")
    closeBtn:SetHandler("OnClicked", function() ui:SetHidden(true) end)

    -- Title label
    local titleLabel = CreateControl(nil, titleContainer, CT_LABEL)
    titleLabel:SetFont("ZoFontWinH2")
    titleLabel:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    titleLabel:SetMaxLineCount(1)
    titleLabel:SetAnchor(TOPLEFT, titleContainer, TOPLEFT, 10, 10)
    titleLabel:SetAnchor(TOPRIGHT, titleContainer, TOPRIGHT, -50, 10)
    titleLabel:SetText("Extended Set Window")

    -- Scrollable content area
    local scroll = CreateControl(nil, ui, CT_SCROLL)
    scroll:SetAnchor(TOPLEFT, titleContainer, BOTTOMLEFT, 0, 0)
    scroll:SetAnchor(BOTTOMRIGHT, ui, BOTTOMRIGHT, -10, -10)
    scroll:SetMouseEnabled(true)
    scroll.offsetY = 0
    
    -- Mouse wheel handler
    scroll:SetHandler("OnMouseWheel", function(self, delta)
        local step = 20
        if TTDungeon.savedVars and TTDungeon.savedVars.invertScroll then
            self.offsetY = self.offsetY + (delta * step)
        else
            self.offsetY = self.offsetY - (delta * step)
        end
        ClampScrollOffset_Sets(self)
    end)
    
    -- Allow window dragging from scroll area
    scroll:SetHandler("OnMouseDown", function(_, btn)
        if btn == MOUSE_BUTTON_INDEX_LEFT then
            ui:StartMoving()
        end
    end)
    scroll:SetHandler("OnMouseUp", function(_, btn)
        if btn == MOUSE_BUTTON_INDEX_LEFT then
            ui:StopMovingOrResizing()
        end
    end)

    -- Scroll child for content
    local scChild = CreateControl(nil, scroll, CT_CONTROL)
    scChild:SetAnchor(TOPLEFT, scroll, TOPLEFT, 0, 0)
    scChild:SetDimensions(scroll:GetWidth(), 0)
    scroll.scrollChild = scChild

    -- Store window data
    local wData = {
        ui = ui,
        setId = setId,
        scroll = scroll,
        scChild = scChild
    }
    TTDungeon.setWindows[key] = wData

    -- Handle resize to rebuild content
    ui:SetHandler("OnResizeStop", function() BuildSetWindowContent(wData) end)

    -- Build initial content
    BuildSetWindowContent(wData)
end

-- ================================================================================
-- Set List UI Functions
-- ================================================================================

-- Show tooltip for a set when hovering
-- @param control: The control to anchor tooltip to
-- @param setId: The set ID to show info for
local function ShowSetTooltip(control, setId)
    if not control or not setId then return end
    InitializeTooltip(InformationTooltip, control, TOPRIGHT, 0, 0, TOPLEFT)
    AddSetTooltipLines(InformationTooltip, setId)
end

-- Hide the set tooltip
local function HideSetTooltip()
    ClearTooltip(InformationTooltip)
end

-- Get progress string for a set
-- @param setId: The set ID
-- @return: Colored progress string like "[5/9]"
local function GetProgressString(setId)
    if not setId then return "|cAAAAAA[N/A]|r" end
    
    local c = GetCollectionInfo(setId)
    if not c or not c.total or c.total == 0 then
        return "|cAAAAAA[N/A]|r"
    end
    
    -- Determine color based on progress
    local color = COLOR_MISSING
    if c.unlocked and c.total and c.unlocked == c.total then
        color = COLOR_UNLOCKED
    elseif c.unlocked and c.unlocked > 0 then
        color = COLOR_PARTIAL
    end
    
    return string.format("|c%s[%d/%d]|r", color, c.unlocked or 0, c.total or 0)
end

-- Create a row for a set in the sets list
-- @param setId: The set ID to create row for
-- @return: The created control or nil
function TTDungeon.CreateSetRow(setId)
    local parent = TTDungeon.setsScrollChild
    if not parent then
        Debug("CreateSetRow => setsScrollChild is nil!")
        return nil
    end

    local rowHeight = 30
    local rowWidth = parent:GetWidth()
    
    -- Create row container
    local row = CreateControl(nil, parent, CT_CONTROL)
    row:SetDimensions(rowWidth, rowHeight)
    row:SetMouseEnabled(false)

    -- Background for hover effect
    local bg = CreateControl(nil, row, CT_BACKDROP)
    bg:SetAnchorFill(row)
    bg:SetCenterColor(0, 0, 0, 0)
    bg:SetEdgeColor(0, 0, 0, 0)
    row.bg = bg

    -- Interactive button
    local btn = CreateControl(nil, row, CT_BUTTON)
    btn:SetAnchorFill(row)
    btn:SetNormalTexture("EsoUI/Art/Buttons/wood_up.dds")
    btn:SetPressedTexture("EsoUI/Art/Buttons/wood_down.dds")
    btn:SetMouseOverTexture("EsoUI/Art/Buttons/wood_over.dds")

    -- Mouse handlers
    btn:SetHandler("OnMouseEnter", function()
        bg:SetCenterColor(0.3, 0.3, 0.3, 0.3)
        bg:SetEdgeColor(0.5, 0.5, 0.5, 0.5)
        ShowSetTooltip(btn, setId)
    end)
    btn:SetHandler("OnMouseExit", function()
        bg:SetCenterColor(0, 0, 0, 0)
        bg:SetEdgeColor(0, 0, 0, 0)
        HideSetTooltip()
    end)
    btn:SetHandler("OnClicked", function(_, mouseButton)
        if mouseButton == MOUSE_BUTTON_INDEX_LEFT then
            TTDungeon.ShowExtendedSetWindow(setId)
        end
    end)

    -- Get set information
    local setName = GetSetName(setId)
    local isMonster = IsMonsterSet(setId)

    -- Set name label
    local nameLabel = CreateControl(nil, btn, CT_LABEL)
    nameLabel:SetDimensions(rowWidth - 80, rowHeight)
    nameLabel:SetAnchor(LEFT, btn, LEFT, 10, 0)
    nameLabel:SetFont("ZoFontGameBold")
    nameLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    nameLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    nameLabel:SetText(string.format("|c%s%s|r", isMonster and "FFD700" or "FFFFFF", setName))

    -- Progress label
    local progressLabel = CreateControl(nil, btn, CT_LABEL)
    progressLabel:SetDimensions(65, rowHeight)
    progressLabel:SetAnchor(RIGHT, btn, RIGHT, -10, 0)
    progressLabel:SetFont("ZoFontGame")
    progressLabel:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    progressLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    progressLabel:SetText(GetProgressString(setId))

    return row
end

-- ================================================================================
-- Tab Management
-- ================================================================================

-- Clear all sets from the sets tab
function TTDungeon.ClearSetsTab()
    if TTDungeon.setsEntries then
        for _, ctrl in ipairs(TTDungeon.setsEntries) do
            ctrl:SetHidden(true)
            ctrl:SetParent(nil)
        end
    end
    TTDungeon.setsEntries = {}

    if TTDungeon.setsScrollChild then
        TTDungeon.setsScrollChild:SetHeight(0)
    end
end

-- Initialize the scrollable container for sets
function TTDungeon.InitializeSetsScroll()
    if not TTDungeon.setsContainer then return end
    if TTDungeon.setsScroll then return end  -- Already initialized

    -- Create scroll container
    local setsScroll = CreateControl("TTD_SetsScroll", TTDungeon.setsContainer, CT_SCROLL)
    setsScroll:SetAnchor(TOPLEFT, TTDungeon.setsContainer, TOPLEFT, 5, 5)
    setsScroll:SetDimensions(TTDungeon.setsContainer:GetWidth() - 10, TTDungeon.setsContainer:GetHeight() - 10)
    setsScroll:SetMouseEnabled(true)
    setsScroll.offsetY = 0
    
    -- Mouse wheel handler
    setsScroll:SetHandler("OnMouseWheel", function(self, delta)
        local step = 20
        if TTDungeon.savedVars and TTDungeon.savedVars.invertScroll then
            self.offsetY = self.offsetY + (delta * step)
        else
            self.offsetY = self.offsetY - (delta * step)
        end
        ClampScrollOffset_Sets(self)
    end)

    -- Create scroll child
    local setsScrollChild = CreateControl("TTD_SetsScrollChild", setsScroll, CT_CONTROL)
    setsScrollChild:SetAnchor(TOPLEFT, setsScroll, TOPLEFT, 0, 0)
    setsScrollChild:SetWidth(setsScroll:GetWidth())
    setsScrollChild:SetHeight(0)
    setsScroll.scrollChild = setsScrollChild

    -- Store references
    TTDungeon.setsScroll = setsScroll
    TTDungeon.setsScrollChild = setsScrollChild
    Debug("Sets scroll initialized")
end

-- Populate the sets tab with dungeon sets
-- @param setIdList: Array of set IDs to display
function TTDungeon.PopulateSetsTab(setIdList)
    -- Initialize scroll if needed
    TTDungeon.InitializeSetsScroll()
    
    -- Clear existing content
    TTDungeon.ClearSetsTab()

    if not setIdList or #setIdList == 0 then
        Debug("PopulateSetsTab => empty.")
        return
    end
    Debug("PopulateSetsTab => #sets=" .. #setIdList)

    -- Separate monster sets from regular sets
    local monsterSets, normalSets = {}, {}
    for _, sid in ipairs(setIdList) do
        if IsMonsterSet(sid) then
            table.insert(monsterSets, sid)
        else
            table.insert(normalSets, sid)
        end
    end

    -- Combine lists with monster sets first
    local finalList = {}
    for _, msid in ipairs(monsterSets) do table.insert(finalList, msid) end
    for _, nsid in ipairs(normalSets) do table.insert(finalList, nsid) end

    local offsetY = 10
    TTDungeon.setsEntries = {}

    -- Add instructions label
    local instructionsLabel = CreateControl(nil, TTDungeon.setsScrollChild, CT_LABEL)
    instructionsLabel:SetFont("ZoFontGameSmall")
    instructionsLabel:SetColor(0.7, 0.7, 0.7, 1)
    instructionsLabel:SetText("Hover: Info, Click: Expand")
    instructionsLabel:SetAnchor(TOPLEFT, TTDungeon.setsScrollChild, TOPLEFT, 10, offsetY)
    table.insert(TTDungeon.setsEntries, instructionsLabel)

    offsetY = offsetY + 25

    -- Add divider
    local divider = CreateControl(nil, TTDungeon.setsScrollChild, CT_TEXTURE)
    divider:SetDimensions(TTDungeon.setsScrollChild:GetWidth() - 20, 2)
    divider:SetAnchor(TOPLEFT, TTDungeon.setsScrollChild, TOPLEFT, 10, offsetY)
    divider:SetTexture("EsoUI/Art/Miscellaneous/horizontalDivider.dds")
    divider:SetColor(0.5, 0.5, 0.5, 0.5)
    table.insert(TTDungeon.setsEntries, divider)
    offsetY = offsetY + 10

    -- Create rows for each set
    for _, setId in ipairs(finalList) do
        local row = TTDungeon.CreateSetRow(setId)
        if row then
            row:ClearAnchors()
            row:SetAnchor(TOPLEFT, TTDungeon.setsScrollChild, TOPLEFT, 0, offsetY)
            offsetY = offsetY + row:GetHeight() + 2
            table.insert(TTDungeon.setsEntries, row)
        end
    end

    -- Set final container height
    offsetY = offsetY + 10
    if TTDungeon.setsScrollChild then
        TTDungeon.setsScrollChild:SetHeight(offsetY)
        ClampScrollOffset_Sets(TTDungeon.setsScroll)
    end
end

-- ================================================================================
-- Initialization
-- ================================================================================

-- Initialize the sets module when addon loads
local function OnAddOnLoaded(event, addonName)
    if addonName ~= "TTDungeon" then return end
    EVENT_MANAGER:UnregisterForEvent("TTDungeon_Sets", EVENT_ADD_ON_LOADED)
    Debug("TTDungeon_Sets loaded. Short instructions & shift-click note in extended window.")
end

EVENT_MANAGER:RegisterForEvent("TTDungeon_Sets", EVENT_ADD_ON_LOADED, OnAddOnLoaded)