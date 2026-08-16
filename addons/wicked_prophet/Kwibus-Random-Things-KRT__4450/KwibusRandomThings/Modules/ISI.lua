local KRT = KwibusRandomThings
local EM = EVENT_MANAGER
local WM = WINDOW_MANAGER
local ADDON_NAME = KRT.name

local DEFAULTS = { isi = {
    enabled = true,
    offsetX = 300,
    offsetY = 300,
    uiScale = 1.0,
    enableReposition = false,
    showArmorWeights = true,
    showArmorTraits = true,
    showAbilityWarning = true,
    showMissingGearWarning = true,
    showLocationTags = true,
    columnSpacing = 45,
    tagSpacing = 40,
    nameSpacing = 180,
    showInMenus = true,
    hideInCombat = false,
    bgOpacity = 25,
    colorMonster = { 1, 1, 1 },
    colorMythic = { 1, 1, 1 },
    colorRegular = { 1, 1, 1 },
} }

KRT.ISI = {
    id = "isi",
    defaults = DEFAULTS.isi,
    ui = nil,
    wLight = nil,
    wMedium = nil,
    wHeavy = nil,
    wTraitsShort = nil,
    labels = {},
}
local self = KRT.ISI

local cachedSV = nil
local function SV()
    if cachedSV then return cachedSV end
    cachedSV = KRT.sv.isi
    return cachedSV
end

-- Local CP colors
local CP_BLUE = {0.36, 0.64, 1.00, 1}
local CP_GREEN = {0.36, 1.00, 0.36, 1}
local CP_RED = {1.00, 0.36, 0.36, 1}

-- Fonts & metrics
local ROW_FONT = "ZoFontGame"
local HEADER_FONT = "ZoFontGame"
local ROW_H = 21
local STAT_COLOR = {0.925, 0.925, 1.000, 1}
local GREEN = {0.36, 1.00, 0.36, 1}
local RED = {1.00, 0.36, 0.36, 1}

-- Slots
local ARMOR_SLOTS = {
    EQUIP_SLOT_HEAD, EQUIP_SLOT_SHOULDERS, EQUIP_SLOT_CHEST,
    EQUIP_SLOT_HAND, EQUIP_SLOT_WAIST, EQUIP_SLOT_LEGS, EQUIP_SLOT_FEET,
}
local JEWELRY_SLOTS = { EQUIP_SLOT_NECK, EQUIP_SLOT_RING1, EQUIP_SLOT_RING2 }
local MAIN_BAR_SLOTS = { EQUIP_SLOT_MAIN_HAND, EQUIP_SLOT_OFF_HAND }
local BACK_BAR_SLOTS = { EQUIP_SLOT_BACKUP_MAIN, EQUIP_SLOT_BACKUP_OFF }

local TWO_HANDED_WEAPON_TYPES = {
    [WEAPONTYPE_TWO_HANDED_AXE] = true,
    [WEAPONTYPE_TWO_HANDED_HAMMER] = true,
    [WEAPONTYPE_TWO_HANDED_SWORD] = true,
    [WEAPONTYPE_BOW] = true,
    [WEAPONTYPE_FIRE_STAFF] = true,
    [WEAPONTYPE_FROST_STAFF] = true,
    [WEAPONTYPE_LIGHTNING_STAFF] = true,
    [WEAPONTYPE_HEALING_STAFF] = true,
}

local function isTwoHanded(itemLink)
    if not itemLink or itemLink == "" then return false end
    local weaponType = GetItemLinkWeaponType(itemLink)
    return TWO_HANDED_WEAPON_TYPES[weaponType] or false
end

-- Helper to properly format localized strings (removes ^m, ^f, ^p, and grammatic tags)
local function FormatLocalizedString(rawName)
    if not rawName or rawName == "" then return "" end
    return zo_strformat("<<1>>", rawName)
end

-- Capitalize first letter safely using ESO's string formatting specifier <<C:1>>
local function CapitalizeFirstLetter(str)
    if not str or str == "" then return "" end
    return zo_strformat("<<C:1>>", str)
end

-- Get localized full trait name dynamically from game string tables
local function GetArmorTraitNameFull(traitType)
    if not traitType or traitType == ITEM_TRAIT_TYPE_NONE then return "" end
    return FormatLocalizedString(GetString("SI_ITEMTRAITTYPE", traitType))
end

-- Get localized short trait representation
local function GetArmorTraitShort(traitType)
    local full = GetArmorTraitNameFull(traitType)
    if full == "" then return "" end
    
    local firstWord = full:match("^(%S+)") or full
    return (zo_strlen(firstWord) > 5) and zo_strsub(firstWord, 1, 4) or firstWord
end

-- Multi-language cleaning for "Perfected" prefix/suffix
local PERFECTED_PATTERNS = {
    -- English
    "^Perfected%s+",
    "%s+Perfected$",
    -- Russian (Совершенный, Совершенная, Совершенное, Совершенные)
    "^Совершенный%s+",
    "^Совершенная%s+",
    "^Совершенное%s+",
    "^Совершенные%s+",
    "%s+Совершенный$",
    "%s+Совершенная$",
    "%s+Совершенное$",
    "%s+Совершенные$",
    -- German
    "^Perfektioniertes%s+",
    "^Perfektionierte%s+",
    "^Perfektionierter%s+",
    -- French
    "^Parfait%s+",
    "^Parfaite%s+",
    "%s+parfait$",
    "%s+parfaite$",
}

local function CleanSetName(setName)
    local clean = FormatLocalizedString(setName)
    
    -- Strip brackets if present [Perfected] / [Совершенный]
    clean = clean:gsub("%[%s*.-%s*%]", "")
    
    -- Strip localized perfected words
    for _, pattern in ipairs(PERFECTED_PATTERNS) do
        clean = clean:gsub(pattern, "")
    end
    
    clean = zo_strtrim(clean)
    
    -- Capitalize first character reliably via <<C:1>>
    return CapitalizeFirstLetter(clean)
end

local function GetArmorWeightsAndTraits()
    local w = { light = 0, medium = 0, heavy = 0 }
    local traits = {}
    for _, slot in ipairs(ARMOR_SLOTS) do
        if HasItemInSlot(BAG_WORN, slot) then
            local at = GetItemArmorType(BAG_WORN, slot)
            if at == ARMORTYPE_LIGHT then w.light = w.light + 1
            elseif at == ARMORTYPE_MEDIUM then w.medium = w.medium + 1
            elseif at == ARMORTYPE_HEAVY then w.heavy = w.heavy + 1 end
            
            local traitType = GetItemTrait(BAG_WORN, slot)
            if traitType and traitType ~= ITEM_TRAIT_TYPE_NONE then
                traits[traitType] = (traits[traitType] or 0) + 1
            end
        end
    end
    local list = {}
    for t, c in pairs(traits) do table.insert(list, {traitType=t, count=c}) end
    table.sort(list, function(a, b)
        if a.count ~= b.count then return a.count > b.count end
        local an = GetArmorTraitShort(a.traitType)
        local bn = GetArmorTraitShort(b.traitType)
        return an < bn
    end)
    return w, list
end

function KRT.ISI:GetEquippedSets()
    local setsById = {}
    local setInfoCache = {}

    local function addSetFromLink(link)
        if not link or link == "" then return nil end
        local hasSet, _, _, _, _, setId = GetItemLinkSetInfo(link, false)
        if not hasSet or not setId or setId == 0 then return nil end
        
        if not setInfoCache[setId] then
            local _, setName, _, _, max = GetItemLinkSetInfo(link, false)
            setInfoCache[setId] = { name = CleanSetName(setName), max = max or 0 }
        end
        
        if not setsById[setId] then
            setsById[setId] = { id=setId, name=setInfoCache[setId].name, max=setInfoCache[setId].max, num=0 }
        end
        return setId, setInfoCache[setId].name, setInfoCache[setId].max
    end

    for _, slot in ipairs(ARMOR_SLOTS) do
        local link = GetItemLink(BAG_WORN, slot)
        local id = addSetFromLink(link)
        if id then 
            setsById[id].num = (setsById[id].num or 0) + 1 
            if slot == EQUIP_SLOT_HEAD then setsById[id].hasHead = true end
            if slot == EQUIP_SLOT_SHOULDERS then setsById[id].hasShoulder = true end
        end
    end
    for _, slot in ipairs(JEWELRY_SLOTS) do
        local link = GetItemLink(BAG_WORN, slot)
        local id = addSetFromLink(link)
        if id then setsById[id].num = (setsById[id].num or 0) + 1 end
    end
    
    local baseById = {}
    for id, e in pairs(setsById) do baseById[id] = e.num or 0 end

    local weaponCountBySet = {}
    local function addWeaponCount(link, barKey)
        if not link or link == "" then return end
        local has, _, _, _, _, id = GetItemLinkSetInfo(link, false)
        if not has or not id or id == 0 then return end
        
        if not setInfoCache[id] then
            local _, setName, _, _, max = GetItemLinkSetInfo(link, false)
            setInfoCache[id] = { name = CleanSetName(setName), max = max or 0 }
        end

        if not weaponCountBySet[id] then
            weaponCountBySet[id] = { main=0, backup=0, name=setInfoCache[id].name, max=setInfoCache[id].max, id=id }
        end
        weaponCountBySet[id][barKey] = (weaponCountBySet[id][barKey] or 0) + (isTwoHanded(link) and 2 or 1)
    end
    
    for _, slot in ipairs(MAIN_BAR_SLOTS) do addWeaponCount(GetItemLink(BAG_WORN, slot), "main") end
    for _, slot in ipairs(BACK_BAR_SLOTS) do addWeaponCount(GetItemLink(BAG_WORN, slot), "backup") end

    for id, wc in pairs(weaponCountBySet) do
        if not setsById[id] then
            setsById[id] = { id=id, name=wc.name, max=(wc.max or 0), num=0 }
            baseById[id] = 0
        end
        local base = baseById[id] or 0
        setsById[id].frontBarNum = base + (wc.main or 0)
        setsById[id].backBarNum = base + (wc.backup or 0)
        setsById[id].num = math.max(setsById[id].frontBarNum, setsById[id].backBarNum)
    end
    
    for id, e in pairs(setsById) do
        e.bodyNum = baseById[id] or 0
        e.frontBarNum = e.frontBarNum or e.num
        e.backBarNum = e.backBarNum or e.num

        -- Categorize the set for sorting & coloring
        if (e.max or 0) == 1 then
            e.sortCategory = 2 -- Mythic
        elseif (e.max or 0) == 2 and (e.hasHead or e.hasShoulder) then
            e.sortCategory = 1 -- Monster Set
            e.sortSub = e.hasHead and 1 or 2 -- Head first, then shoulder
        elseif (e.frontBarNum or 0) > (e.bodyNum or 0) and (e.backBarNum or 0) > (e.bodyNum or 0) then
            e.sortCategory = 6 -- Both Bars Weapon Set (wp)
        elseif (e.frontBarNum or 0) > (e.backBarNum or 0) then
            e.sortCategory = 4 -- Front Bar Set
        elseif (e.backBarNum or 0) > (e.frontBarNum or 0) then
            e.sortCategory = 5 -- Back Bar Set
        else
            e.sortCategory = 3 -- Body Set
        end
    end

    local list = {}
    for _, e in pairs(setsById) do table.insert(list, e) end
    table.sort(list, function(a, b)
        local catA = a.sortCategory or 99
        local catB = b.sortCategory or 99

        if catA ~= catB then 
            return catA < catB 
        end

        if catA == 1 then
            local subA = a.sortSub or 9
            local subB = b.sortSub or 9
            if subA ~= subB then
                return subA < subB
            end
        end

        local nameA = a.name or ""
        local nameB = b.name or ""

        return nameA < nameB
    end)

    return list
end

function KRT.ISI:ApplyAnchor()
    if not self.ui then return end
    local sv = SV()
    self.ui:ClearAnchors()
    self.ui:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, sv.offsetX or 300, sv.offsetY or 300)
    self.ui:SetScale(sv.uiScale or 1.0)
end

function KRT.ISI:EnableDragging(enable)
    local ui = self.ui
    if not ui then return end
    ui:SetMouseEnabled(enable)
    ui:SetMovable(enable)
    if enable then
        ui:SetHandler("OnMoveStop", function(control)
            local sv = SV()
            sv.offsetX = control:GetLeft()
            sv.offsetY = control:GetTop()
        end)
    else
        ui:SetHandler("OnMoveStop", nil)
    end
end

function KRT.ISI:EnsureOverlay()
    if self.ui then return end
    local win = WM:CreateTopLevelWindow("KwibusIsiibusUI")
    win:SetDimensions(300, 200)
    win:SetHidden(true)
    win:SetClampedToScreen(true)
    win:SetDrawLayer(DL_OVERLAY)
    win:SetDrawTier(DT_HIGH)
    win:SetDrawLevel(1)

    local bg = WM:CreateControl(nil, win, CT_BACKDROP)
    bg:SetAnchorFill()
    bg:SetCenterColor(0, 0, 0, 0.25)
    bg:SetEdgeColor(0, 0, 0, 0)
    bg:SetEdgeTexture("", 1, 1, 1)
    self.bg = bg

    local wLight = WM:CreateControl(nil, win, CT_LABEL)
    local wMedium = WM:CreateControl(nil, win, CT_LABEL)
    local wHeavy = WM:CreateControl(nil, win, CT_LABEL)
    local wTraitsShort = WM:CreateControl(nil, win, CT_LABEL)

    local wWarning = WM:CreateControl(nil, win, CT_LABEL)
    wWarning:SetFont("ZoFontGame")
    wWarning:SetColor(1, 0, 0, 1)
    wWarning:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    wWarning:SetAnchor(TOPLEFT, win, TOPLEFT, 0, 0)
    wWarning:SetHidden(true)
    self.wWarning = wWarning

    for _, lbl in ipairs({wLight, wMedium, wHeavy, wTraitsShort}) do
        lbl:SetFont(HEADER_FONT)
        lbl:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    end

    wLight:SetAnchor(TOPLEFT, win, TOPLEFT, 0, 0)
    wMedium:SetAnchor(LEFT, wLight, RIGHT, 10, 0)
    wHeavy:SetAnchor(LEFT, wMedium, RIGHT, 10, 0)
    wTraitsShort:SetAnchor(LEFT, wHeavy, RIGHT, 20, 0)

    self.wLight = wLight
    self.wMedium = wMedium
    self.wHeavy = wHeavy
    self.wTraitsShort = wTraitsShort
    self.ui = win

    for i = 1, 7 do
        local countLabel = WM:CreateControl(nil, win, CT_LABEL)
        local tagLabel = WM:CreateControl(nil, win, CT_LABEL)
        local nameLabel = WM:CreateControl(nil, win, CT_LABEL)

        countLabel:SetFont(ROW_FONT)
        countLabel:SetHeight(ROW_H)
        countLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        countLabel:SetAnchor(TOPLEFT, win, TOPLEFT, 0, 0)

        tagLabel:SetFont(ROW_FONT)
        tagLabel:SetHeight(ROW_H)
        tagLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        tagLabel:SetAnchor(LEFT, countLabel, RIGHT, 0, 0)

        nameLabel:SetFont(ROW_FONT)
        nameLabel:SetHeight(ROW_H)
        nameLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        nameLabel:SetAnchor(LEFT, tagLabel, RIGHT, 0, 0)

        nameLabel:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)

        self.labels[i] = {
            count = countLabel,
            tag = tagLabel,
            name = nameLabel,
        }
    end

    self:ApplyAnchor()
    self:EnableDragging(SV().enableReposition)

    self.fragment = ZO_HUDFadeSceneFragment:New(self.ui)
    self:UpdateSceneFragments()
end

function KRT.ISI:UpdateSceneFragments()
    if not self.fragment then return end
    local sv = SV()
    if not HUD_SCENE:HasFragment(self.fragment) then
        HUD_SCENE:AddFragment(self.fragment)
        HUD_UI_SCENE:AddFragment(self.fragment)
    end
    
    local menuScenes = { "inventory", "bank", "guildBank", "houseBank", "store", "tradinghouse", "craftingResults" }
    for _, sceneName in ipairs(menuScenes) do
        local scene = SCENE_MANAGER:GetScene(sceneName)
        if scene then
            if sv.showInMenus then
                if not scene:HasFragment(self.fragment) then scene:AddFragment(self.fragment) end
            else
                if scene:HasFragment(self.fragment) then scene:RemoveFragment(self.fragment) end
            end
        end
    end
end

function KRT.ISI:UpdateOverlay()
    if not SV().enabled then
        if self.ui then self.ui:SetHidden(true) end
        return
    end

    self:EnsureOverlay()

    local inCombat = IsUnitInCombat("player")
    if SV().hideInCombat and inCombat and not SV().enableReposition then
        self.ui:SetHidden(true)
    else
        self.ui:SetHidden(false)
    end

    -- Apply background opacity (0 = transparent, 100 = full black)
    local opacity = (SV().bgOpacity ~= nil) and SV().bgOpacity or 25
    local alpha = math.max(0, math.min(1, opacity / 100))
    self.bg:SetCenterColor(0, 0, 0, alpha)

    -- Show green border when repositioning is active as a visual hitbox
    if SV().enableReposition then
        self.bg:SetEdgeColor(0, 1, 0, 0.8)
    else
        self.bg:SetEdgeColor(0, 0, 0, 0)
    end

    local y = 0
    local invalidFront, invalidBack = false, false
    
    if SV().showAbilityWarning ~= false then
        local frontHbManager = ACTION_BAR_ASSIGNMENT_MANAGER:GetHotbar(HOTBAR_CATEGORY_PRIMARY)
        if frontHbManager then
            for i = 1, 6 do
                local slotData = frontHbManager:GetSlotData(ACTION_BAR_FIRST_NORMAL_SLOT_INDEX + i)
                local skillData = slotData and slotData:GetPlayerSkillData()
                if skillData then
                    local progData = skillData:GetPointAllocatorProgressionData()
                    if progData then
                        local abilityId = progData:GetAbilityId()
                        if not CanAbilityBeUsedFromHotbar(abilityId, HOTBAR_CATEGORY_PRIMARY) then
                            invalidFront = true; break
                        end
                    end
                end
            end
        end
        local backHbManager = ACTION_BAR_ASSIGNMENT_MANAGER:GetHotbar(HOTBAR_CATEGORY_BACKUP)
        if backHbManager then
            for i = 1, 6 do
                local slotData = backHbManager:GetSlotData(ACTION_BAR_FIRST_NORMAL_SLOT_INDEX + i)
                local skillData = slotData and slotData:GetPlayerSkillData()
                if skillData then
                    local progData = skillData:GetPointAllocatorProgressionData()
                    if progData then
                        local abilityId = progData:GetAbilityId()
                        if not CanAbilityBeUsedFromHotbar(abilityId, HOTBAR_CATEGORY_BACKUP) then
                            invalidBack = true; break
                        end
                    end
                end
            end
        end
    end

    local missingSlots = {}
    if SV().showMissingGearWarning ~= false then
        local slotNames = {
            [EQUIP_SLOT_HEAD] = FormatLocalizedString(GetString(SI_EQUIPSLOT0)),
            [EQUIP_SLOT_CHEST] = FormatLocalizedString(GetString(SI_EQUIPSLOT2)),
            [EQUIP_SLOT_SHOULDERS] = FormatLocalizedString(GetString(SI_EQUIPSLOT3)),
            [EQUIP_SLOT_HAND] = FormatLocalizedString(GetString(SI_EQUIPSLOT13)),
            [EQUIP_SLOT_WAIST] = FormatLocalizedString(GetString(SI_EQUIPSLOT14)),
            [EQUIP_SLOT_LEGS] = FormatLocalizedString(GetString(SI_EQUIPSLOT8)),
            [EQUIP_SLOT_FEET] = FormatLocalizedString(GetString(SI_EQUIPSLOT9)),
            [EQUIP_SLOT_NECK] = FormatLocalizedString(GetString(SI_EQUIPSLOT12)),
            [EQUIP_SLOT_RING1] = FormatLocalizedString(GetString(SI_EQUIPSLOT11)),
            [EQUIP_SLOT_RING2] = FormatLocalizedString(GetString(SI_EQUIPSLOT11)),
        }
        for _, slot in ipairs(ARMOR_SLOTS) do
            if not HasItemInSlot(BAG_WORN, slot) then table.insert(missingSlots, slotNames[slot] or "Armor") end
        end
        for _, slot in ipairs(JEWELRY_SLOTS) do
            if not HasItemInSlot(BAG_WORN, slot) then table.insert(missingSlots, slotNames[slot] or "Jewelry") end
        end

        local fbMain = GetItemLink(BAG_WORN, EQUIP_SLOT_MAIN_HAND)
        local fbOff = GetItemLink(BAG_WORN, EQUIP_SLOT_OFF_HAND)
        if fbMain == "" or (not isTwoHanded(fbMain) and fbOff == "") then
            table.insert(missingSlots, "FB weapon")
        end

        local bbMain = GetItemLink(BAG_WORN, EQUIP_SLOT_BACKUP_MAIN)
        local bbOff = GetItemLink(BAG_WORN, EQUIP_SLOT_BACKUP_OFF)
        if bbMain == "" or (not isTwoHanded(bbMain) and bbOff == "") then
            table.insert(missingSlots, "BB weapon")
        end
    end

    local warnings = {}
    if invalidFront or invalidBack then
        local msg = {}
        if invalidFront then table.insert(msg, "FB") end
        if invalidBack then table.insert(msg, "BB") end
        table.insert(warnings, "Invalid ability! (" .. table.concat(msg, ", ") .. ")")
    end
    if #missingSlots > 0 then
        if #missingSlots > 3 then
            local displaySlots = {}
            for i = 1, 3 do table.insert(displaySlots, missingSlots[i]) end
            table.insert(warnings, "Missing: " .. table.concat(displaySlots, ", ") .. " (+" .. (#missingSlots - 3) .. ")")
        else
            table.insert(warnings, "Missing: " .. table.concat(missingSlots, ", "))
        end
    end

    if #warnings > 0 then
        self.wWarning:SetText(table.concat(warnings, "\n"))
        self.wWarning:SetHidden(false)
        y = 20 * #warnings + 5
    else
        self.wWarning:SetHidden(true)
    end

    if SV().showArmorWeights then
        self.wLight:ClearAnchors()
        self.wLight:SetAnchor(TOPLEFT, self.ui, TOPLEFT, 0, y)
        self.wLight:SetHidden(false)
        self.wMedium:SetHidden(false)
        self.wHeavy:SetHidden(false)

        local weights, traitsList = GetArmorWeightsAndTraits()
        self.wLight:SetText(tostring(weights.light))
        self.wLight:SetColor(unpack(CP_BLUE))
        self.wMedium:SetText(tostring(weights.medium))
        self.wMedium:SetColor(unpack(CP_GREEN))
        self.wHeavy:SetText(tostring(weights.heavy))
        self.wHeavy:SetColor(unpack(CP_RED))

        if SV().showArmorTraits ~= false then
            local traitTxt = ""
            local distinct = 0
            for _, t in ipairs(traitsList) do
                if t.count and t.count > 0 then distinct = distinct + 1 end
            end
            local parts, shown = {}, 0
            for _, t in ipairs(traitsList) do
                if t.count and t.count > 0 then
                    local label = (distinct <= 2) and GetArmorTraitNameFull(t.traitType) or GetArmorTraitShort(t.traitType)
                    parts[#parts + 1] = string.format("%dx %s", t.count, label)
                    shown = shown + 1
                    if distinct > 2 and shown >= 4 then break end
                end
            end
            traitTxt = table.concat(parts, ", ")
            self.wTraitsShort:SetText(traitTxt)
            self.wTraitsShort:SetColor(unpack(STAT_COLOR))
            self.wTraitsShort:SetHidden(traitTxt == "")
        else
            self.wTraitsShort:SetHidden(true)
        end
        y = y + 25
    else
        self.wLight:SetHidden(true)
        self.wMedium:SetHidden(true)
        self.wHeavy:SetHidden(true)
        self.wTraitsShort:SetHidden(true)
    end

    local sets = self:GetEquippedSets()
    for i = 1, 7 do
        local entry = sets[i]
        
        local countLabel = self.labels[i].count
        local tagLabel   = self.labels[i].tag
        local nameLabel  = self.labels[i].name

        if entry then
            countLabel:SetAnchor(TOPLEFT, self.ui, TOPLEFT, 0, y)

            local SPECIAL_GREEN_SET_IDS = {
                [163] = true, -- Armor of the Trainee
                [548] = true, -- Druid's Braid
                [181] = true, -- Willpower
                [153] = true, -- Blessing of the Potentates
                [216] = true, -- Eyes of Mara
            }
            
            local isSpecialGreen = SPECIAL_GREEN_SET_IDS[entry.id] or false

            local isComplete = (entry.num or 0) >= (entry.max or 0)
            local isMonsterOneOfTwo = not isComplete and (entry.max or 0) == 2 and (entry.num or 0) == 1 and (entry.hasHead or entry.hasShoulder)
            local countColor = (isSpecialGreen or isComplete or isMonsterOneOfTwo) and GREEN or RED

            local tagStr = ""
            if SV().showLocationTags ~= false then
                local locs = {}
                local hasWeapons = false
                
                local hasFrontWeapon = (entry.frontBarNum or 0) > (entry.bodyNum or 0)
                local hasBackWeapon = (entry.backBarNum or 0) > (entry.bodyNum or 0)

                if hasFrontWeapon and hasBackWeapon then
                    table.insert(locs, "(wp)")
                    hasWeapons = true
                else
                    if hasFrontWeapon then
                        table.insert(locs, "(fb)")
                        hasWeapons = true
                    end
                    if hasBackWeapon then
                        table.insert(locs, "(bb)")
                        hasWeapons = true
                    end
                end

                if not hasWeapons and (entry.bodyNum or 0) > 0 then
                    table.insert(locs, "(b)")
                end
                
                if #locs > 0 then
                    tagStr = "|c00FFFF" .. table.concat(locs, " ") .. "|r"
                end
            end

            countLabel:SetText(zo_strformat("<<1>>/<<2>>", entry.num or 0, entry.max or 0))
            countLabel:SetColor(unpack(countColor))
            countLabel:SetHidden(false)

            tagLabel:SetText(tagStr)
            tagLabel:SetHidden(false)

            -- Determine set name color based on sortCategory (1 = Monster, 2 = Mythic, 3+ = Regular)
            local nameColor = SV().colorRegular or { 1, 1, 1 }
            if entry.sortCategory == 1 then
                nameColor = SV().colorMonster or { 1, 1, 1 }
            elseif entry.sortCategory == 2 then
                nameColor = SV().colorMythic or { 1, 1, 1 }
            end

            nameLabel:SetText(entry.name or "")
            nameLabel:SetColor(unpack(nameColor))
            nameLabel:SetHidden(false)
            
            local colWidth = SV().columnSpacing or 45
            local tagWidth = (SV().showLocationTags ~= false) and (SV().tagSpacing or 40) or 0
            local nameWidth = SV().nameSpacing or 180

            countLabel:SetWidth(colWidth)
            tagLabel:SetWidth(tagWidth)
            nameLabel:SetWidth(nameWidth)

            y = y + ROW_H
        else
            countLabel:SetHidden(true)
            tagLabel:SetHidden(true)
            nameLabel:SetHidden(true)
        end
    end

    -- Option A: Calculate backdrop width from column settings + 10px padding
    local totalWidth = (SV().columnSpacing or 45) + ((SV().showLocationTags ~= false) and (SV().tagSpacing or 40) or 0) + (SV().nameSpacing or 180) + 10
    self.ui:SetDimensions(totalWidth, y)
    self.bg:SetDimensions(totalWidth, y)
end

function KRT.ISI:Initialize()
    self:UpdateOverlay()

    local function OnInventoryUpdate()
        KRT.DebounceNextFrame("IsiibusUpdate", function() self:UpdateOverlay() end)
    end
    local function OnCombatStateChanged(eventCode, inCombat)
        if SV().hideInCombat and self.ui and not SV().enableReposition then
            self.ui:SetHidden(inCombat)
        end
    end

    EM:RegisterForEvent(ADDON_NAME .. "_ISI", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, OnInventoryUpdate)
    EM:AddFilterForEvent(ADDON_NAME .. "_ISI", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_WORN)
    EM:RegisterForEvent(ADDON_NAME .. "_ISI2", EVENT_INVENTORY_FULL_UPDATE, OnInventoryUpdate)
    EM:RegisterForEvent(ADDON_NAME .. "_ISI3", EVENT_ACTION_SLOTS_FULL_UPDATE, OnInventoryUpdate)
    EM:RegisterForEvent(ADDON_NAME .. "_ISI4", EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED, OnInventoryUpdate)
    EM:RegisterForEvent(ADDON_NAME .. "_ISICombat", EVENT_PLAYER_COMBAT_STATE, OnCombatStateChanged)
end

function KRT.ISI:GetLAMSubmenu()
    return {
        type = "submenu",
        name = "Isiibus Equipped",
        controls = {
            {
                type = "checkbox",
                name = "Enable Isiibus Equipped",
                tooltip = "Shows equipped sets and armor weights on the screen.",
                getFunc = function() return SV().enabled end,
                setFunc = function(value) SV().enabled = value; self:UpdateOverlay() end,
            },
            {
                type = "checkbox",
                name = "Enable repositioning drag",
                tooltip = "Shows a background box allowing you to move the overlay.",
                getFunc = function() return SV().enableReposition end,
                setFunc = function(value)
                    SV().enableReposition = value
                    self:EnableDragging(value)
                    self:UpdateOverlay()
                end,
                disabled = function() return not SV().enabled end,
            },
            {
                type = "slider",
                name = "UI Scale (%)",
                min = 10,
                max = 200,
                step = 1,
                decimals = 0,
                getFunc = function() return math.floor((SV().uiScale or 1.0) * 100) end,
                setFunc = function(value) 
                    SV().uiScale = value / 100.0
                    self:ApplyAnchor()
                end,
                disabled = function() return not SV().enabled end,
            },
            {
                type = "slider",
                name = "Background Opacity (%)",
                tooltip = "Adjusts background opacity from 0 (fully transparent) to 100 (solid black).",
                min = 0,
                max = 100,
                step = 1,
                getFunc = function() return (SV().bgOpacity ~= nil) and SV().bgOpacity or 25 end,
                setFunc = function(value) 
                    SV().bgOpacity = value 
                    self:UpdateOverlay() 
                end,
                disabled = function() return not SV().enabled end,
            },
            {
                type = "checkbox",
                name = "Show Armor Weights",
                getFunc = function() return SV().showArmorWeights end,
                setFunc = function(value) SV().showArmorWeights = value; self:UpdateOverlay() end,
                disabled = function() return not SV().enabled end,
            },
            {
                type = "checkbox",
                name = "Show Armor Traits",
                tooltip = "Displays armor traits alongside your armor weights.",
                getFunc = function() 
                    if SV().showArmorTraits == nil then return true else return SV().showArmorTraits end 
                end,
                setFunc = function(value) SV().showArmorTraits = value; self:UpdateOverlay() end,
                disabled = function() return not SV().enabled end,
            },
            {
                type = "checkbox",
                name = "Show Missing Gear Warning",
                tooltip = "Displays a red warning if you are missing armor, jewelry, or weapons.",
                getFunc = function() 
                    if SV().showMissingGearWarning == nil then return true else return SV().showMissingGearWarning end 
                end,
                setFunc = function(value) SV().showMissingGearWarning = value; self:UpdateOverlay() end,
                disabled = function() return not SV().enabled end,
            },
            {
                type = "checkbox",
                name = "Show Invalid Ability Warning",
                tooltip = "Displays a red warning if you have a weapon ability slotted but are holding the wrong weapon.",
                getFunc = function() 
                    if SV().showAbilityWarning == nil then return true else return SV().showAbilityWarning end 
                end,
                setFunc = function(value) SV().showAbilityWarning = value; self:UpdateOverlay() end,
                disabled = function() return not SV().enabled end,
            },
            {
                type = "checkbox",
                name = "Show Set Location Tags",
                tooltip = "Shows (b), (fb), or (bb) to indicate where a set is equipped.",
                getFunc = function() 
                    if SV().showLocationTags == nil then return true else return SV().showLocationTags end 
                end,
                setFunc = function(value) SV().showLocationTags = value; self:UpdateOverlay() end,
                disabled = function() return not SV().enabled end,
            },
            {
                type = "slider",
                name = "Count Column Width",
                tooltip = "Adjusts the gap between the piece counts and the tags.",
                min = 20,
                max = 100,
                step = 1,
                getFunc = function() return SV().columnSpacing or 45 end,
                setFunc = function(value) SV().columnSpacing = value; self:UpdateOverlay() end,
                disabled = function() return not SV().enabled end,
            },
            {
                type = "slider",
                name = "Tag Column Width",
                tooltip = "Adjusts the width of the location tags column.",
                min = 10,
                max = 50,
                step = 1,
                getFunc = function() return SV().tagSpacing or 40 end,
                setFunc = function(value) SV().tagSpacing = value; self:UpdateOverlay() end,
                disabled = function() return not SV().enabled end,
            },
            {
                type = "slider",
                name = "Set Name Column Width",
                tooltip = "Adjusts the max width allowed for set names before truncation.",
                min = 100,
                max = 200,
                step = 1,
                getFunc = function() return SV().nameSpacing or 180 end,
                setFunc = function(value) SV().nameSpacing = value; self:UpdateOverlay() end,
                disabled = function() return not SV().enabled end,
            },
            {
                type = "checkbox",
                name = "Show in Inventory/Bank",
                tooltip = "Displays the overlay while interacting with your inventory, bank, or storage chests.",
                getFunc = function() return SV().showInMenus end,
                setFunc = function(value) SV().showInMenus = value; self:UpdateSceneFragments() end,
                disabled = function() return not SV().enabled end,
            },
            {
                type = "checkbox",
                name = "Hide in Combat",
                tooltip = "Automatically hides the overlay when you enter combat.",
                getFunc = function() return SV().hideInCombat end,
                setFunc = function(value) SV().hideInCombat = value; self:UpdateOverlay() end,
                disabled = function() return not SV().enabled end,
            },
            {
                type = "button",
                name = "Reset horizontal position",
                func = function()
                    if not KRT.ISI.ui then return end
                    local rootW = GuiRoot:GetWidth()
                    local w = KRT.ISI.ui:GetWidth() * (SV().uiScale or 1.0)
                    SV().offsetX = (rootW - w) / 2
                    KRT.ISI:ApplyAnchor()
                end,
                width = "half",
                disabled = function() return not SV().enabled or not SV().enableReposition end,
            },
            {
                type = "button",
                name = "Reset vertical position",
                func = function()
                    if not KRT.ISI.ui then return end
                    local rootH = GuiRoot:GetHeight()
                    local h = KRT.ISI.ui:GetHeight() * (SV().uiScale or 1.0)
                    SV().offsetY = (rootH - h) / 2
                    KRT.ISI:ApplyAnchor()
                end,
                width = "half",
                disabled = function() return not SV().enabled or not SV().enableReposition end,
            },
            {
                type = "submenu",
                name = "Color Options",
                controls = {
                    {
                        type = "colorpicker",
                        name = "Monster Set Color",
                        tooltip = "Color for Monster set names (Head / Shoulders).",
                        getFunc = function() return unpack(SV().colorMonster or { 1, 1, 1 }) end,
                        setFunc = function(r, g, b) 
                            SV().colorMonster = { r, g, b } 
                            self:UpdateOverlay() 
                        end,
                        disabled = function() return not SV().enabled end,
                    },
                    {
                        type = "colorpicker",
                        name = "Mythic Item Color",
                        tooltip = "Color for Mythic item names.",
                        getFunc = function() return unpack(SV().colorMythic or { 1, 1, 1 }) end,
                        setFunc = function(r, g, b) 
                            SV().colorMythic = { r, g, b } 
                            self:UpdateOverlay() 
                        end,
                        disabled = function() return not SV().enabled end,
                    },
                    {
                        type = "colorpicker",
                        name = "Regular Set Color",
                        tooltip = "Color for standard 3-piece and 5-piece set names.",
                        getFunc = function() return unpack(SV().colorRegular or { 1, 1, 1 }) end,
                        setFunc = function(r, g, b) 
                            SV().colorRegular = { r, g, b } 
                            self:UpdateOverlay() 
                        end,
                        disabled = function() return not SV().enabled end,
                    },
                },
            },
        }
    }
end

KRT:RegisterModule(KRT.ISI)