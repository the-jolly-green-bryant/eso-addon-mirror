-- ============================================
-- ITEM FINDER - Cross-Character Inventory Search
-- ============================================
-- Caches items from all characters and allows searching
-- to find specific armor, weapons, jewelry, etc.

NWT.ItemFinder = {
    isOpen = false,
    sceneInitialized = false,
    searchText = "",
    results = {},
    selectedIndex = 1,
    scrollOffset = 0,
    lastNavTime = 0,
    navCooldown = 200,
    maxVisibleRows = 14,
}

-- Default saved variables structure
NWT.ITEM_FINDER_DEFAULTS = {
    characters = {},  -- [characterName] = { lastUpdated, items = {} }
}

-- ============================================
-- ITEM CACHING
-- ============================================
local function GetItemKey(bagId, slotIndex)
    local itemLink = GetItemLink(bagId, slotIndex)
    if not itemLink or itemLink == "" then return nil end
    
    local itemId = GetItemLinkItemId(itemLink)
    local itemName = GetItemLinkName(itemLink)
    local itemType = GetItemLinkItemType(itemLink)
    local equipType = GetItemLinkEquipType(itemLink)
    local quality = GetItemLinkDisplayQuality(itemLink)
    local level = GetItemLinkRequiredLevel(itemLink)
    local cpLevel = GetItemLinkRequiredChampionPoints(itemLink)
    local setInfo = GetItemLinkSetInfo(itemLink, false)
    local trait = GetItemLinkTraitInfo(itemLink)
    local icon = GetItemLinkIcon(itemLink)
    local stackCount = GetSlotStackSize(bagId, slotIndex)
    
    return {
        itemId = itemId,
        name = itemName,
        link = itemLink,
        type = itemType,
        equipType = equipType,
        quality = quality,
        level = level,
        cpLevel = cpLevel,
        setName = setInfo and GetItemLinkSetInfo(itemLink, false) or nil,
        trait = trait,
        icon = icon,
        count = stackCount or 1,
    }
end

local function GetEquipSlotName(slot)
    local slotNames = {
        [EQUIP_SLOT_HEAD] = "Head",
        [EQUIP_SLOT_CHEST] = "Chest",
        [EQUIP_SLOT_SHOULDERS] = "Shoulders",
        [EQUIP_SLOT_WAIST] = "Waist",
        [EQUIP_SLOT_LEGS] = "Legs",
        [EQUIP_SLOT_FEET] = "Feet",
        [EQUIP_SLOT_HAND] = "Hands",
        [EQUIP_SLOT_MAIN_HAND] = "Main Hand",
        [EQUIP_SLOT_OFF_HAND] = "Off Hand",
        [EQUIP_SLOT_BACKUP_MAIN] = "Backup Main",
        [EQUIP_SLOT_BACKUP_OFF] = "Backup Off",
        [EQUIP_SLOT_NECK] = "Necklace",
        [EQUIP_SLOT_RING1] = "Ring 1",
        [EQUIP_SLOT_RING2] = "Ring 2",
        [EQUIP_SLOT_COSTUME] = "Costume",
    }
    return slotNames[slot] or "Equipped"
end

local function GetItemTypeName(itemType)
    local typeNames = {
        [ITEMTYPE_ARMOR] = "Armor",
        [ITEMTYPE_WEAPON] = "Weapon",
        [ITEMTYPE_JEWELRY] = "Jewelry",  
        [ITEMTYPE_FOOD] = "Food",
        [ITEMTYPE_DRINK] = "Drink",
        [ITEMTYPE_POTION] = "Potion",
        [ITEMTYPE_POISON] = "Poison",
        [ITEMTYPE_CONTAINER] = "Container",
        [ITEMTYPE_SOUL_GEM] = "Soul Gem",
        [ITEMTYPE_GLYPH] = "Glyph",
        [ITEMTYPE_RECIPE] = "Recipe",
        [ITEMTYPE_FURNISHING] = "Furnishing",
        [ITEMTYPE_TROPHY] = "Trophy",
        [ITEMTYPE_TOOL] = "Tool",
        [ITEMTYPE_STYLE_MATERIAL] = "Style Material",
        [ITEMTYPE_RAW_MATERIAL] = "Raw Material",
        [ITEMTYPE_CLOTHIER_RAW_MATERIAL] = "Clothier Material",
        [ITEMTYPE_BLACKSMITHING_RAW_MATERIAL] = "Blacksmithing Material",
        [ITEMTYPE_WOODWORKING_RAW_MATERIAL] = "Woodworking Material",
        [ITEMTYPE_JEWELRY_RAW_MATERIAL] = "Jewelry Material",
    }
    return typeNames[itemType] or "Item"
end

local function GetQualityColor(quality)
    local colors = {
        [ITEM_DISPLAY_QUALITY_TRASH] = "777777",
        [ITEM_DISPLAY_QUALITY_NORMAL] = "FFFFFF",
        [ITEM_DISPLAY_QUALITY_MAGIC] = "2DC50E",
        [ITEM_DISPLAY_QUALITY_ARCANE] = "3A92FF",
        [ITEM_DISPLAY_QUALITY_ARTIFACT] = "A02EF7",
        [ITEM_DISPLAY_QUALITY_LEGENDARY] = "CCAA1A",
    }
    return colors[quality] or "FFFFFF"
end

-- Helper to scan a bag and add items to list
local function ScanBagForItems(bagId, location, itemList)
    local bagSize = GetBagSize(bagId)
    if not bagSize or bagSize == 0 then return 0 end
    
    local count = 0
    for slotIndex = 0, bagSize - 1 do
        if HasItemInSlot(bagId, slotIndex) then
            local itemInfo = GetItemKey(bagId, slotIndex)
            if itemInfo then
                itemInfo.location = location
                itemInfo.slotName = nil
                table.insert(itemList, itemInfo)
                count = count + 1
            end
        end
    end
    return count
end

function NWT.CacheCurrentCharacterItems()
    local charName = GetUnitName("player")
    if not charName or charName == "" then return end
    
    -- Initialize saved vars structure
    NWT.savedVars.itemFinder = NWT.savedVars.itemFinder or NWT.ITEM_FINDER_DEFAULTS
    NWT.savedVars.itemFinder.characters = NWT.savedVars.itemFinder.characters or {}
    
    local charData = {
        lastUpdated = GetTimeStamp(),
        className = GetUnitClassId("player") and GetClassName(GAME_UNIT_TYPE_PLAYER, GetUnitClassId("player")) or "Unknown",
        level = GetUnitLevel("player"),
        cpLevel = GetUnitEffectiveChampionPoints("player"),
        alliance = GetUnitAlliance("player"),
        items = {},
    }
    
    local equippedCount = 0
    local invCount = 0
    local bankCount = 0
    local storageCount = 0
    
    -- Scan equipped items
    for slot = EQUIP_SLOT_ITERATION_BEGIN, EQUIP_SLOT_ITERATION_END do
        if HasItemInSlot(BAG_WORN, slot) then
            local itemInfo = GetItemKey(BAG_WORN, slot)
            if itemInfo then
                itemInfo.location = "Equipped"
                itemInfo.slotName = GetEquipSlotName(slot)
                table.insert(charData.items, itemInfo)
                equippedCount = equippedCount + 1
            end
        end
    end
    
    -- Scan inventory (backpack)
    invCount = ScanBagForItems(BAG_BACKPACK, "Inventory", charData.items)
    
    -- Scan bank (regular + ESO+ bank)
    bankCount = ScanBagForItems(BAG_BANK, "Bank", charData.items)
    bankCount = bankCount + ScanBagForItems(BAG_SUBSCRIBER_BANK, "Bank", charData.items)
    
    -- Scan housing storage chests (1-10)
    local houseBankBags = {
        BAG_HOUSE_BANK_ONE, BAG_HOUSE_BANK_TWO, BAG_HOUSE_BANK_THREE,
        BAG_HOUSE_BANK_FOUR, BAG_HOUSE_BANK_FIVE, BAG_HOUSE_BANK_SIX,
        BAG_HOUSE_BANK_SEVEN, BAG_HOUSE_BANK_EIGHT, BAG_HOUSE_BANK_NINE,
        BAG_HOUSE_BANK_TEN
    }
    
    for i, bagId in ipairs(houseBankBags) do
        local chestCount = ScanBagForItems(bagId, "Storage " .. i, charData.items)
        storageCount = storageCount + chestCount
    end
    
    NWT.savedVars.itemFinder.characters[charName] = charData
end

-- ============================================
-- SEARCH FUNCTIONALITY
-- ============================================
function NWT.SearchAllCharacterItems(searchTerm)
    if not searchTerm or searchTerm == "" then return {} end
    searchTerm = string.lower(searchTerm)
    
    local results = {}
    local itemFinder = NWT.savedVars.itemFinder
    if not itemFinder or not itemFinder.characters then return results end
    
    for charName, charData in pairs(itemFinder.characters) do
        for _, item in ipairs(charData.items or {}) do
            local itemNameLower = item.name and string.lower(item.name) or ""
            local setNameLower = item.setName and string.lower(tostring(item.setName)) or ""
            
            -- Search in item name or set name
            if string.find(itemNameLower, searchTerm, 1, true) or 
               string.find(setNameLower, searchTerm, 1, true) then
                table.insert(results, {
                    charName = charName,
                    charClass = charData.className,
                    charLevel = charData.cpLevel > 0 and ("CP" .. charData.cpLevel) or ("Lv" .. charData.level),
                    item = item,
                })
            end
        end
    end
    
    -- Sort by character name, then by item quality (descending)
    table.sort(results, function(a, b)
        if a.charName ~= b.charName then
            return a.charName < b.charName
        end
        return (a.item.quality or 0) > (b.item.quality or 0)
    end)
    
    return results
end

-- ============================================
-- UI UPDATE
-- ============================================
local function UpdateItemFinderUI()
    local ui = ATK_ItemFinder_UI
    if not ui then return end
    local finder = NWT.ItemFinder
    local maxVisible = finder.maxVisibleRows
    
    -- Update search status
    local content = ui:GetNamedChild("Content")
    if not content then return end
    
    local leftCol = content:GetNamedChild("LeftCol")
    if leftCol then
        local searchLabel = leftCol:GetNamedChild("SearchLabel")
        if searchLabel then
            if finder.searchText ~= "" then
                searchLabel:SetText("|cFFFFFFSearch:|r |cFF6600" .. finder.searchText .. "|r")
            else
                searchLabel:SetText("|c888888Press [A] to search...|r")
            end
        end
        
        local countLabel = leftCol:GetNamedChild("CountLabel")
        if countLabel then
            countLabel:SetText("|cFFFFFFResults:|r " .. #finder.results)
        end
        
        -- Character summary
        local itemFinder = NWT.savedVars.itemFinder
        local charCount = 0
        local totalItems = 0
        if itemFinder and itemFinder.characters then
            for charName, charData in pairs(itemFinder.characters) do
                charCount = charCount + 1
                totalItems = totalItems + #(charData.items or {})
            end
        end
        
        local charsLabel = leftCol:GetNamedChild("CharsLabel")
        if charsLabel then
            charsLabel:SetText("|cFFFFFFCharacters:|r " .. charCount)
        end
        
        local totalLabel = leftCol:GetNamedChild("TotalLabel")
        if totalLabel then
            totalLabel:SetText("|cFFFFFFTotal Items:|r " .. ZO_CommaDelimitNumber(totalItems))
        end
        
        -- Show character list
        local charList = leftCol:GetNamedChild("CharList")
        if charList and itemFinder and itemFinder.characters then
            local charIndex = 1
            for charName, charData in pairs(itemFinder.characters) do
                if charIndex <= 8 then
                    local row = charList:GetNamedChild("Row" .. charIndex)
                    if row then
                        local timeAgo = GetTimeStamp() - (charData.lastUpdated or 0)
                        local timeStr = ""
                        if timeAgo < 3600 then
                            timeStr = math.floor(timeAgo / 60) .. "m ago"
                        elseif timeAgo < 86400 then
                            timeStr = math.floor(timeAgo / 3600) .. "h ago"
                        else
                            timeStr = math.floor(timeAgo / 86400) .. "d ago"
                        end
                        row:SetText("|cFFFFFF" .. charName .. "|r |c888888(" .. #(charData.items or {}) .. " items, " .. timeStr .. ")|r")
                        row:SetHidden(false)
                    end
                end
                charIndex = charIndex + 1
            end
            -- Hide unused rows
            for i = charIndex, 8 do
                local row = charList:GetNamedChild("Row" .. i)
                if row then row:SetHidden(true) end
            end
        end
    end
    
    -- Update results list
    local rightCol = content:GetNamedChild("RightCol")
    if rightCol then
        local list = rightCol:GetNamedChild("List")
        if list then
            local emptyLabel = list:GetNamedChild("Empty")
            
            if #finder.results == 0 then
                if emptyLabel then 
                    if finder.searchText == "" then
                        emptyLabel:SetText("Search for items across all characters")
                    else
                        emptyLabel:SetText("No items found matching '" .. finder.searchText .. "'")
                    end
                    emptyLabel:SetHidden(false) 
                end
            else
                if emptyLabel then emptyLabel:SetHidden(true) end
            end
            
            for i = 1, maxVisible do
                local row = list:GetNamedChild("Row" .. i)
                if row then
                    local resultIndex = finder.scrollOffset + i
                    local result = finder.results[resultIndex]
                    if result then
                        local item = result.item
                        local qualityColor = GetQualityColor(item.quality)
                        local locationText
                        if item.location == "Equipped" then
                            locationText = "|cFFD700" .. (item.slotName or "Equipped") .. "|r"
                        elseif item.location == "Bank" then
                            locationText = "|c00AAFF" .. item.location .. "|r"
                        elseif item.location and item.location:find("Storage") then
                            locationText = "|c9932CC" .. item.location .. "|r"
                        else
                            locationText = "|c888888" .. (item.location or "Inv") .. "|r"
                        end
                        
                        -- Highlight selected row
                        local prefix = ""
                        if resultIndex == finder.selectedIndex then
                            prefix = "|cFF6600► |r"
                        end
                        
                        row:SetText(prefix .. "|c" .. qualityColor .. item.name .. "|r |c666666- " .. result.charName .. " (" .. locationText .. ")|r")
                        row:SetHidden(false)
                    else
                        row:SetText("")
                        row:SetHidden(true)
                    end
                end
            end
        end
    end
    
    -- Footer
    local footer = ui:GetNamedChild("Footer")
    if footer then
        footer:SetText("|cFF6600[A]|r Search   |cFF6600[X]|r Clear   |cFF6600[Y]|r Rescan   |c888888[B] Back|r")
    end
end

local function ItemFinderNavigate(direction)
    local finder = NWT.ItemFinder
    local maxVisible = finder.maxVisibleRows
    if #finder.results == 0 then return end
    
    if direction == "up" then
        finder.selectedIndex = finder.selectedIndex - 1
        if finder.selectedIndex < 1 then 
            finder.selectedIndex = #finder.results 
            finder.scrollOffset = math.max(0, #finder.results - maxVisible)
        elseif finder.selectedIndex <= finder.scrollOffset then 
            finder.scrollOffset = finder.selectedIndex - 1 
        end
    elseif direction == "down" then
        finder.selectedIndex = finder.selectedIndex + 1
        if finder.selectedIndex > #finder.results then 
            finder.selectedIndex = 1 
            finder.scrollOffset = 0
        elseif finder.selectedIndex > finder.scrollOffset + maxVisible then 
            finder.scrollOffset = finder.selectedIndex - maxVisible 
        end
    end
    UpdateItemFinderUI()
end

NWT.ItemFinder.UpdateDirectionalInput = function(self)
    local now = GetGameTimeMilliseconds()
    if (now - self.lastNavTime) < self.navCooldown then return end
    local y = DIRECTIONAL_INPUT:GetY(ZO_DI_LEFT_STICK)
    if math.abs(y) > 0.5 then
        ItemFinderNavigate(y > 0 and "up" or "down")
        self.lastNavTime = now
        PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
    end
end

function NWT.SetupItemFinderDirectionalInput() 
    DIRECTIONAL_INPUT:Activate(NWT.ItemFinder, ATK_ItemFinder_UI) 
end

function NWT.RemoveItemFinderDirectionalInput() 
    DIRECTIONAL_INPUT:Deactivate(NWT.ItemFinder) 
end

-- ============================================
-- SEARCH PROMPT
-- ============================================
local function ItemFinderSearchPrompt()
    local finder = NWT.ItemFinder
    
    -- If already have search text, clear it
    if finder.searchText ~= "" then
        finder.searchText = ""
        finder.results = {}
        finder.selectedIndex = 1
        finder.scrollOffset = 0
        PlaySound(SOUNDS.POSITIVE_CLICK)
        UpdateItemFinderUI()
        return
    end
    
    -- Create edit box if needed
    if not finder.searchEditBox then
        local eb = WINDOW_MANAGER:CreateControl("ItemFinderSearchEditBox", ATK_ItemFinder_UI, CT_EDITBOX)
        eb:SetDimensions(400, 40)
        eb:SetAnchor(CENTER, ATK_ItemFinder_UI, CENTER, 0, 0)
        eb:SetFont("ZoFontGamepad27")
        eb:SetMaxInputChars(50)
        eb:SetVirtualKeyboardType(VIRTUAL_KEYBOARD_TYPE_DEFAULT)
        eb:SetHandler("OnEnter", function(self)
            local txt = self:GetText()
            if txt and txt ~= "" then
                finder.searchText = txt
                finder.results = NWT.SearchAllCharacterItems(txt)
                finder.selectedIndex = 1
                finder.scrollOffset = 0
                PlaySound(SOUNDS.POSITIVE_CLICK)
                NWT.SyncHiddenItemFinderList()
                UpdateItemFinderUI()
            end
            self:SetHidden(true)
            self:LoseFocus()
        end)
        eb:SetHandler("OnEscape", function(self)
            self:SetHidden(true)
            self:LoseFocus()
        end)
        finder.searchEditBox = eb
    end
    
    finder.searchEditBox:SetText("")
    finder.searchEditBox:SetHidden(false)
    finder.searchEditBox:TakeFocus()
end

-- ============================================
-- SCENE SETUP
-- ============================================
local ATK_HiddenItemFinderListScreen = ZO_Gamepad_ParametricList_Screen:Subclass()
function ATK_HiddenItemFinderListScreen:New(control) return ZO_Gamepad_ParametricList_Screen.New(self, control) end
function ATK_HiddenItemFinderListScreen:Initialize(control) ZO_Gamepad_ParametricList_Screen.Initialize(self, control, false, true, ITEM_FINDER_SCENE) end
function ATK_HiddenItemFinderListScreen:PerformUpdate() end

function ATK_HiddenItemFinderListScreen:InitializeKeybindStripDescriptors()
    self.keybindStripDescriptor = {
        { 
            alignment = KEYBIND_STRIP_ALIGN_LEFT, 
            name = "Search", 
            keybind = "UI_SHORTCUT_PRIMARY", 
            callback = function() 
                ItemFinderSearchPrompt() 
                PlaySound(SOUNDS.POSITIVE_CLICK) 
            end 
        },
        { 
            alignment = KEYBIND_STRIP_ALIGN_LEFT, 
            name = "Clear", 
            keybind = "UI_SHORTCUT_SECONDARY", 
            callback = function() 
                NWT.ItemFinder.searchText = ""
                NWT.ItemFinder.results = {}
                NWT.ItemFinder.selectedIndex = 1
                NWT.ItemFinder.scrollOffset = 0
                NWT.SyncHiddenItemFinderList() 
                UpdateItemFinderUI() 
                PlaySound(SOUNDS.POSITIVE_CLICK) 
            end 
        },
        { 
            alignment = KEYBIND_STRIP_ALIGN_LEFT, 
            name = "Rescan", 
            keybind = "UI_SHORTCUT_TERTIARY", 
            callback = function() 
                NWT.CacheCurrentCharacterItems()
                if NWT.ItemFinder.searchText ~= "" then
                    NWT.ItemFinder.results = NWT.SearchAllCharacterItems(NWT.ItemFinder.searchText)
                end
                UpdateItemFinderUI() 
                PlaySound(SOUNDS.POSITIVE_CLICK) 
            end 
        },
    }
    ZO_Gamepad_AddBackNavigationKeybindDescriptors(self.keybindStripDescriptor, GAME_NAVIGATION_TYPE_BUTTON, function() NWT.CloseItemFinder() end)
end

function NWT.SyncHiddenItemFinderList()
    if not NWT.HiddenItemFinderList then return end
    local finder = NWT.ItemFinder
    NWT.HiddenItemFinderList:Clear()
    for i, res in ipairs(finder.results) do
        local ed = ZO_GamepadEntryData:New(res.item.name or "Item")
        ed.index = i
        NWT.HiddenItemFinderList:AddEntry("ZO_GamepadItemEntryTemplate", ed)
    end
    NWT.HiddenItemFinderList:Commit()
    if finder.selectedIndex and finder.selectedIndex <= #finder.results then 
        NWT.HiddenItemFinderList:SetSelectedIndexWithoutAnimation(finder.selectedIndex) 
    end
end

function NWT.InitItemFinderScene()
    if NWT.ItemFinder.sceneInitialized then return end
    local ui = ATK_ItemFinder_UI
    if not ui then return end
    
    local hc = WINDOW_MANAGER:CreateControlFromVirtual("ATK_HiddenItemFinderList", GuiRoot, "ATK_HouseList_Screen")
    hc:SetHidden(true)
    hc:SetAlpha(0)
    
    ITEM_FINDER_SCENE = ZO_Scene:New("itemFinderScene", SCENE_MANAGER)
    ITEM_FINDER_SCENE:AddFragment(ZO_HUDFadeSceneFragment:New(ui))
    ITEM_FINDER_SCENE:AddFragment(ZO_SimpleSceneFragment:New(hc))
    ITEM_FINDER_SCENE:AddFragmentGroup(FRAGMENT_GROUP.GAMEPAD_DRIVEN_UI_WINDOW)
    
    NWT.HiddenItemFinderListScreen = ATK_HiddenItemFinderListScreen:New(hc)
    NWT.HiddenItemFinderList = NWT.HiddenItemFinderListScreen:GetMainList()
    NWT.HiddenItemFinderList:AddDataTemplate("ZO_GamepadItemEntryTemplate", function(c, d) 
        local l = c:GetNamedChild("Label") 
        if l then l:SetText(d.name or "") end 
    end, ZO_GamepadMenuEntryTemplateParametricListFunction)
    
    NWT.HiddenItemFinderList:SetOnSelectedDataChangedCallback(function(list, sd)
        if sd and sd.index then
            local finder = NWT.ItemFinder
            finder.selectedIndex = sd.index
            if finder.selectedIndex <= finder.scrollOffset then 
                finder.scrollOffset = finder.selectedIndex - 1
            elseif finder.selectedIndex > finder.scrollOffset + finder.maxVisibleRows then 
                finder.scrollOffset = finder.selectedIndex - finder.maxVisibleRows 
            end
            UpdateItemFinderUI()
        end
    end)
    
    ITEM_FINDER_SCENE:RegisterCallback("StateChange", function(os, ns)
        if ns == SCENE_SHOWING then 
            NWT.ItemFinder.isOpen = true 
            NWT.ItemFinder.selectedIndex = 1
            NWT.ItemFinder.scrollOffset = 0
            NWT.SyncHiddenItemFinderList() 
            UpdateItemFinderUI()
            NWT.SetupItemFinderDirectionalInput()
        elseif ns == SCENE_HIDDEN then 
            NWT.ItemFinder.isOpen = false 
            NWT.RemoveItemFinderDirectionalInput()
        end
    end)
    
    NWT.ItemFinder.sceneInitialized = true
end

function NWT.OpenItemFinder()
    if NWT.ItemFinder.isOpen then return end
    if not ITEM_FINDER_SCENE then NWT.InitItemFinderScene() end
    SCENE_MANAGER:Push("itemFinderScene")
end

function NWT.CloseItemFinder()
    if ITEM_FINDER_SCENE then SCENE_MANAGER:Hide("itemFinderScene") end
end

-- ============================================
-- AUTO-CACHE ON LOGIN
-- ============================================
function NWT.InitItemFinderEvents()
    -- Cache items shortly after login (give time for inventory to load)
    zo_callLater(function()
        NWT.CacheCurrentCharacterItems()
    end, 5000)  -- 5 second delay
end
