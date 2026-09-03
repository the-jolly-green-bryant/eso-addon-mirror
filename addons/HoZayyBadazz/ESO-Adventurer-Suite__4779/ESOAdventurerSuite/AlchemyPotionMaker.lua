-- ESO Adventurer Suite
-- Floating Alchemy Potion & Poison Maker
-- v0.29.160

local EPC = ESOProgressionCoach
EPC.AlchemyPotionMaker = EPC.AlchemyPotionMaker or {}
local A = EPC.AlchemyPotionMaker
local wm = WINDOW_MANAGER

local PREFIX = "ESOAdventurerSuite_AlchemyPotionMaker"
local ICON_TEXTURE = "/esoui/art/crafting/alchemy_tabicon_reagent_up.dds"
local NORMAL_W, NORMAL_H = 64, 64
local PANEL_W, PANEL_H = 790, 620
local ROW_COUNT = 12
local EFFECT_POPUP_W, EFFECT_POPUP_H = 590, 620
local EFFECT_POPUP_ROWS = 17

local function safe(fn, fallback, ...)
    if type(fn) ~= "function" then return fallback end
    local ok, a,b,c,d,e,f,g,h = pcall(fn, ...)
    if not ok then return fallback end
    return a,b,c,d,e,f,g,h
end

local function num(v, fallback)
    v = tonumber(v)
    if v == nil then return fallback or 0 end
    return v
end

local function trim(v)
    local s = tostring(v or "")
    s = s:gsub("^%s+", ""):gsub("%s+$", "")
    return s
end

local function normalize(v)
    local s = string.lower(trim(v))
    s = s:gsub("[’`]", "'")
    s = s:gsub("[^%w']+", " ")
    s = s:gsub("%s+", " ")
    return trim(s)
end

local function notify(text, good)
    if EPC and type(EPC.Print) == "function" then EPC:Print(text) end
    if type(ZO_Alert) == "function" then
        pcall(ZO_Alert, good == false and UI_ALERT_CATEGORY_ERROR or UI_ALERT_CATEGORY_ALERT, nil, text)
    end
end

local TRAIT_ALIASES = {
    ["invisibility"] = "Invisible",
    ["invisible"] = "Invisible",
    ["lower spell power"] = "Cowardice",
    ["cowardice"] = "Cowardice",
    ["lower armor"] = "Fracture",
    ["fracture"] = "Fracture",
    ["lower spell resist"] = "Breach",
    ["lower spell resistance"] = "Breach",
    ["breach"] = "Breach",
    ["lower weapon power"] = "Maim",
    ["maim"] = "Maim",
    ["lower weapon crit"] = "Enervation",
    ["lower weapon critical"] = "Enervation",
    ["enervation"] = "Enervation",
    ["lower spell crit"] = "Uncertainty",
    ["lower spell critical"] = "Uncertainty",
    ["uncertainty"] = "Uncertainty",
    ["weapon crit"] = "Weapon Critical",
    ["weapon critical"] = "Weapon Critical",
    ["spell crit"] = "Spell Critical",
    ["spell critical"] = "Spell Critical",
    ["reduce speed"] = "Hindrance",
    ["reduced speed"] = "Hindrance",
    ["hindrance"] = "Hindrance",
    ["stun"] = "Entrapment",
    ["entrapment"] = "Entrapment",
    ["sustained restore health"] = "Lingering Health",
    ["lingering health"] = "Lingering Health",
    ["creeping ravage health"] = "Gradual Ravage Health",
    ["gradual ravage health"] = "Gradual Ravage Health",
    ["increase spell resistance"] = "Increase Spell Resist",
    ["increase spell resist"] = "Increase Spell Resist",
}

local function canonicalTrait(name)
    local key = normalize(name)
    if key == "" then return nil end
    return TRAIT_ALIASES[key] or trim(name)
end

-- Current ESO reagent catalog. Live item-link traits override these entries for
-- reagents the player actually owns, so future game changes continue to work
-- for carried materials without requiring a hardcoded item ID table.
local REAGENT_CATALOG = {
    {"Beetle Scuttle", "Breach", "Increase Armor", "Protection", "Vitality"},
    {"Blessed Thistle", "Restore Stamina", "Ravage Health", "Increase Weapon Power", "Speed"},
    {"Blue Entoloma", "Ravage Magicka", "Restore Health", "Cowardice", "Invisible"},
    {"Bugloss", "Increase Spell Resist", "Cowardice", "Restore Health", "Restore Magicka"},
    {"Butterfly Wing", "Restore Health", "Lingering Health", "Uncertainty", "Vitality"},
    {"Chaurus Egg", "Timidity", "Ravage Magicka", "Restore Stamina", "Detection"},
    {"Clam Gall", "Increase Spell Resist", "Hindrance", "Vulnerability", "Defile"},
    {"Columbine", "Restore Health", "Restore Stamina", "Restore Magicka", "Unstoppable"},
    {"Corn Flower", "Restore Magicka", "Ravage Health", "Increase Spell Power", "Detection"},
    {"Crimson Nirnroot", "Timidity", "Spell Critical", "Gradual Ravage Health", "Restore Health"},
    {"Dragon Rheum", "Restore Magicka", "Heroism", "Enervation", "Speed"},
    {"Dragon's Bile", "Heroism", "Vulnerability", "Invisible", "Vitality"},
    {"Dragon's Blood", "Lingering Health", "Restore Stamina", "Heroism", "Defile"},
    {"Dragonthorn", "Increase Weapon Power", "Fracture", "Restore Stamina", "Weapon Critical"},
    {"Emetic Russula", "Ravage Health", "Ravage Stamina", "Ravage Magicka", "Entrapment"},
    {"Fleshfly Larva", "Ravage Stamina", "Gradual Ravage Health", "Vulnerability", "Vitality"},
    {"Imp Stool", "Maim", "Increase Armor", "Ravage Stamina", "Enervation"},
    {"Lady's Smock", "Increase Spell Power", "Breach", "Restore Magicka", "Spell Critical"},
    {"Luminous Russula", "Ravage Stamina", "Restore Health", "Maim", "Hindrance"},
    {"Mountain Flower", "Increase Armor", "Maim", "Restore Health", "Restore Stamina"},
    {"Mudcrab Chitin", "Increase Spell Resist", "Protection", "Increase Armor", "Defile"},
    {"Namira's Rot", "Spell Critical", "Invisible", "Speed", "Unstoppable"},
    {"Nightshade", "Ravage Health", "Gradual Ravage Health", "Protection", "Defile"},
    {"Nirnroot", "Ravage Health", "Enervation", "Uncertainty", "Invisible"},
    {"Powdered Mother of Pearl", "Lingering Health", "Speed", "Vitality", "Protection"},
    {"Scrib Jelly", "Ravage Magicka", "Vulnerability", "Speed", "Lingering Health"},
    {"Spider Egg", "Hindrance", "Lingering Health", "Invisible", "Defile"},
    {"Stinkhorn", "Fracture", "Increase Weapon Power", "Ravage Health", "Ravage Stamina"},
    {"Torchbug Thorax", "Fracture", "Detection", "Enervation", "Vitality"},
    {"Vile Coagulant", "Timidity", "Ravage Health", "Restore Magicka", "Protection"},
    {"Violet Coprinus", "Breach", "Increase Spell Power", "Ravage Health", "Ravage Magicka"},
    {"Water Hyacinth", "Restore Health", "Weapon Critical", "Spell Critical", "Entrapment"},
    {"White Cap", "Cowardice", "Increase Spell Resist", "Ravage Magicka", "Detection"},
    {"Wormwood", "Weapon Critical", "Detection", "Hindrance", "Unstoppable"},
}

local COUNTERS = {
    ["Restore Health"] = "Ravage Health", ["Ravage Health"] = "Restore Health",
    ["Restore Magicka"] = "Ravage Magicka", ["Ravage Magicka"] = "Restore Magicka",
    ["Restore Stamina"] = "Ravage Stamina", ["Ravage Stamina"] = "Restore Stamina",
    ["Increase Armor"] = "Fracture", ["Fracture"] = "Increase Armor",
    ["Increase Spell Resist"] = "Breach", ["Breach"] = "Increase Spell Resist",
    ["Increase Weapon Power"] = "Maim", ["Maim"] = "Increase Weapon Power",
    ["Increase Spell Power"] = "Cowardice", ["Cowardice"] = "Increase Spell Power",
    ["Weapon Critical"] = "Enervation", ["Enervation"] = "Weapon Critical",
    ["Spell Critical"] = "Uncertainty", ["Uncertainty"] = "Spell Critical",
    ["Speed"] = "Hindrance", ["Hindrance"] = "Speed",
    ["Invisible"] = "Detection", ["Detection"] = "Invisible",
    ["Unstoppable"] = "Entrapment", ["Entrapment"] = "Unstoppable",
    ["Lingering Health"] = "Gradual Ravage Health", ["Gradual Ravage Health"] = "Lingering Health",
    ["Vitality"] = "Defile", ["Defile"] = "Vitality",
    ["Protection"] = "Vulnerability", ["Vulnerability"] = "Protection",
    ["Heroism"] = "Timidity", ["Timidity"] = "Heroism",
}

local POTION_SOLVENTS = {"Natural Water", "Clear Water", "Pristine Water", "Cleansed Water", "Filtered Water", "Purified Water", "Cloud Mist", "Star Dew", "Lorkhan's Tears"}
local POISON_SOLVENTS = {"Grease", "Ichor", "Slime", "Gall", "Terebinth", "Pitch-Bile", "Tarblack", "Night-Oil", "Alkahest"}
local SOLVENT_RANK = {}
for i, name in ipairs(POTION_SOLVENTS) do SOLVENT_RANK[normalize(name)] = i end
for i, name in ipairs(POISON_SOLVENTS) do SOLVENT_RANK[normalize(name)] = i end

local EFFECTS = {}
do
    local seen = {}
    for _, row in ipairs(REAGENT_CATALOG) do
        for i = 2, #row do
            local t = canonicalTrait(row[i])
            if t and not seen[t] then seen[t] = true EFFECTS[#EFFECTS + 1] = t end
        end
    end
    table.sort(EFFECTS)
end

function A:EnsureSaved()
    EPC.saved = EPC.saved or {}
    local s = EPC.saved
    if s.alchemyPotionMakerEnabled == nil then s.alchemyPotionMakerEnabled = true end
    if s.alchemyPotionMakerIncludeBank == nil then s.alchemyPotionMakerIncludeBank = true end
    if s.alchemyPotionMakerIncludeCraftBag == nil then s.alchemyPotionMakerIncludeCraftBag = true end
    if s.alchemyPotionMakerUseThreeReagents == nil then s.alchemyPotionMakerUseThreeReagents = true end
    if s.alchemyPotionMakerMode == nil then s.alchemyPotionMakerMode = "POTION" end
    if s.alchemyPotionMakerEffect1 == nil then s.alchemyPotionMakerEffect1 = "Restore Health" end
    if s.alchemyPotionMakerEffect2 == nil then s.alchemyPotionMakerEffect2 = "" end
    if s.alchemyPotionMakerEffect3 == nil then s.alchemyPotionMakerEffect3 = "" end
    if s.alchemyPotionMakerLeft == nil then s.alchemyPotionMakerLeft = -1 end
    if s.alchemyPotionMakerTop == nil then s.alchemyPotionMakerTop = -1 end
    if s.alchemyPotionMakerPanelLeft == nil then s.alchemyPotionMakerPanelLeft = -1 end
    if s.alchemyPotionMakerPanelTop == nil then s.alchemyPotionMakerPanelTop = -1 end
    if s.alchemyPotionMakerAutoCraft == nil then s.alchemyPotionMakerAutoCraft = false end
    if s.alchemyPotionMakerAutoCraftMode == nil then s.alchemyPotionMakerAutoCraftMode = "ONE" end
    if s.alchemyPotionMakerAutoCraftQuantity == nil then s.alchemyPotionMakerAutoCraftQuantity = 1 end
end

function A:IsAtAlchemyStation()
    local craftingType = safe(GetCraftingInteractionType, nil)
    local alchemy = rawget(_G, "CRAFTING_TYPE_ALCHEMY")
    return alchemy ~= nil and craftingType == alchemy
end

function A:IsThirdSlotUnlocked()
    if EPC.saved and EPC.saved.alchemyPotionMakerUseThreeReagents == false then return false end
    if type(ZO_Alchemy_IsThirdAlchemySlotUnlocked) == "function" then
        return safe(ZO_Alchemy_IsThirdAlchemySlotUnlocked, false) == true
    end
    -- If the API is absent, keep the planner conservative instead of preparing
    -- a three-reagent recipe that the character may not be able to slot.
    return false
end

function A:RestorePosition()
    if not self.button or not GuiRoot then return end
    self:EnsureSaved()
    local x = num(EPC.saved.alchemyPotionMakerLeft, -1)
    local y = num(EPC.saved.alchemyPotionMakerTop, -1)
    self.button:ClearAnchors()
    self.button:SetDimensions(NORMAL_W, NORMAL_H)
    if x >= 0 and y >= 0 then
        self.button:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
    else
        self.button:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, -184, 245)
    end
end

function A:SavePosition()
    if not self.button or not EPC.saved then return end
    EPC.saved.alchemyPotionMakerLeft = math.max(0, num(self.button:GetLeft(), 0))
    EPC.saved.alchemyPotionMakerTop = math.max(0, num(self.button:GetTop(), 0))
end

function A:RestorePanelPosition()
    if not self.window or not GuiRoot then return end
    self:EnsureSaved()
    local x = num(EPC.saved.alchemyPotionMakerPanelLeft, -1)
    local y = num(EPC.saved.alchemyPotionMakerPanelTop, -1)
    self.window:ClearAnchors()
    if x >= 0 and y >= 0 then
        self.window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
    else
        self.window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    end
end

function A:SavePanelPosition()
    if not self.window or not EPC.saved then return end
    EPC.saved.alchemyPotionMakerPanelLeft = math.max(0, num(self.window:GetLeft(), 0))
    EPC.saved.alchemyPotionMakerPanelTop = math.max(0, num(self.window:GetTop(), 0))
end

function A:ResetPosition()
    self:EnsureSaved()
    EPC.saved.alchemyPotionMakerLeft = -1
    EPC.saved.alchemyPotionMakerTop = -1
    EPC.saved.alchemyPotionMakerPanelLeft = -1
    EPC.saved.alchemyPotionMakerPanelTop = -1
    self:RestorePosition()
    self:RestorePanelPosition()
end

function A:ForEachBagSlot(bagId, callback)
    if bagId == nil or type(callback) ~= "function" then return end
    if rawget(_G, "BAG_VIRTUAL") ~= nil and bagId == BAG_VIRTUAL and type(GetNextVirtualBagSlotId) == "function" then
        local last = nil
        local guard = 0
        while guard < 10000 do
            local slotIndex = safe(GetNextVirtualBagSlotId, nil, last)
            if slotIndex == nil and last == nil then slotIndex = safe(GetNextVirtualBagSlotId, nil, 0) end
            if slotIndex == nil then break end
            callback(bagId, slotIndex)
            last = slotIndex
            guard = guard + 1
        end
        return
    end
    local size = num(safe(GetBagSize, 0, bagId), 0)
    for slotIndex = 0, size - 1 do callback(bagId, slotIndex) end
end

function A:GetSlotCount(bagId, slotIndex)
    local stack = safe(GetSlotStackSize, nil, bagId, slotIndex)
    if stack ~= nil then return math.max(0, num(stack, 0)) end
    local _, stackCount = safe(GetItemInfo, nil, bagId, slotIndex)
    return math.max(0, num(stackCount, 0))
end

function A:GetLiveTraits(link)
    local out, seen = {}, {}
    if type(GetItemLinkReagentTraitInfo) ~= "function" or not link or link == "" then return out end
    for i = 1, 4 do
        local known, name = safe(GetItemLinkReagentTraitInfo, nil, link, i)
        local trait = canonicalTrait(name)
        -- The name can be available even when the character has not personally
        -- discovered the trait. We only need the game's current effect identity.
        if trait and not seen[trait] then
            seen[trait] = true
            out[#out + 1] = trait
        end
    end
    return out
end

function A:GetStaticTraits(name)
    local key = normalize(name)
    for _, row in ipairs(REAGENT_CATALOG) do
        if normalize(row[1]) == key then
            local out = {}
            for i = 2, #row do out[#out + 1] = canonicalTrait(row[i]) end
            return out
        end
    end
    return {}
end

function A:ScanMaterials()
    self:EnsureSaved()
    local reagentsByName, solvents = {}, { POTION = {}, POISON = {} }
    local reagentType = rawget(_G, "ITEMTYPE_REAGENT")
    local potionBase = rawget(_G, "ITEMTYPE_POTION_BASE")
    local poisonBase = rawget(_G, "ITEMTYPE_POISON_BASE")
    local bags, seenBags = {}, {}
    local function addBag(id)
        if id ~= nil and not seenBags[id] then seenBags[id] = true bags[#bags + 1] = id end
    end
    addBag(rawget(_G, "BAG_BACKPACK"))
    if EPC.saved.alchemyPotionMakerIncludeBank ~= false then
        addBag(rawget(_G, "BAG_BANK"))
        addBag(rawget(_G, "BAG_SUBSCRIBER_BANK"))
    end
    if EPC.saved.alchemyPotionMakerIncludeCraftBag ~= false then addBag(rawget(_G, "BAG_VIRTUAL")) end

    for _, bagId in ipairs(bags) do
        self:ForEachBagSlot(bagId, function(bag, slot)
            local link = tostring(safe(GetItemLink, "", bag, slot, LINK_STYLE_DEFAULT or 0) or "")
            if link == "" then return end
            local itemType = num(safe(GetItemLinkItemType, -1, link), -1)
            local count = self:GetSlotCount(bag, slot)
            if count <= 0 then return end
            local name = tostring(safe(GetItemLinkName, "", link) or "")
            if name == "" then name = tostring(safe(GetItemName, "", bag, slot) or "") end
            local key = normalize(name)
            if reagentType ~= nil and itemType == reagentType then
                local entry = reagentsByName[key]
                if not entry then
                    entry = { name = name, key = key, count = 0, locations = {}, traits = {} }
                    reagentsByName[key] = entry
                end
                entry.count = entry.count + count
                entry.locations[#entry.locations + 1] = { bagId = bag, slotIndex = slot, count = count, link = link }
                local live = self:GetLiveTraits(link)
                if #live > #entry.traits then entry.traits = live end
            elseif potionBase ~= nil and itemType == potionBase then
                solvents.POTION[#solvents.POTION + 1] = { name = name, key = key, count = count, bagId = bag, slotIndex = slot, link = link }
            elseif poisonBase ~= nil and itemType == poisonBase then
                solvents.POISON[#solvents.POISON + 1] = { name = name, key = key, count = count, bagId = bag, slotIndex = slot, link = link }
            end
        end)
    end

    local reagentList = {}
    for _, entry in pairs(reagentsByName) do
        if #entry.traits == 0 then entry.traits = self:GetStaticTraits(entry.name) end
        reagentList[#reagentList + 1] = entry
    end
    table.sort(reagentList, function(a,b) return tostring(a.name) < tostring(b.name) end)

    for _, mode in ipairs({"POTION", "POISON"}) do
        table.sort(solvents[mode], function(a,b)
            local ar = SOLVENT_RANK[a.key] or (num(safe(GetItemLinkRequiredChampionPoints, 0, a.link), 0) * 100 + num(safe(GetItemLinkRequiredLevel, 0, a.link), 0))
            local br = SOLVENT_RANK[b.key] or (num(safe(GetItemLinkRequiredChampionPoints, 0, b.link), 0) * 100 + num(safe(GetItemLinkRequiredLevel, 0, b.link), 0))
            if ar == br then return a.count > b.count end
            return ar > br
        end)
    end

    self.reagentsByName = reagentsByName
    self.reagentList = reagentList
    self.solvents = solvents
    self.lastScanAt = num(safe(GetFrameTimeMilliseconds, 0), 0)
    return reagentList, solvents
end

function A:GetSolventProficiencyIndex()
    -- NON_COMBAT_BONUS_ALCHEMY_LEVEL is zero-based for solvent proficiency.
    -- Convert it to the 1..9 indices used by our solvent tables.
    local bonusType = rawget(_G, "NON_COMBAT_BONUS_ALCHEMY_LEVEL")
    local bonus = num(safe(GetNonCombatBonus, 0, bonusType), 0)
    return math.max(1, math.min(9, bonus + 1))
end

function A:IsSolventLevelUsable(solvent)
    if not solvent then return false end
    local solventRank = SOLVENT_RANK[solvent.key] or 999
    if solventRank > self:GetSolventProficiencyIndex() then return false end

    -- A character can own account/bank solvents above the level that character
    -- can actually use. Filter those before presenting a recipe as READY.
    local requiredCP = num(safe(GetItemLinkRequiredChampionPoints, 0, solvent.link), 0)
    local requiredLevel = num(safe(GetItemLinkRequiredLevel, 0, solvent.link), 0)
    local playerCP = num(safe(GetUnitChampionPoints, 0, "player"), 0)
    local playerLevel = num(safe(GetUnitLevel, 1, "player"), 1)
    if requiredCP > 0 then
        if playerCP < requiredCP then return false end
    elseif requiredLevel > 0 and playerLevel < requiredLevel then
        return false
    end
    return true
end

function A:GetUsableSolvents(mode)
    mode = mode == "POISON" and "POISON" or "POTION"
    if not self.solvents then self:ScanMaterials() end
    local list = self.solvents and self.solvents[mode] or {}
    local out = {}
    for _, solvent in ipairs(list) do
        if self:IsSolventLevelUsable(solvent) then out[#out + 1] = solvent end
    end
    return out
end

function A:GetBestSolvent(mode)
    local list = self:GetUsableSolvents(mode)
    return list[1]
end

function A:GetExpectedSolventName(mode)
    local rank = self:GetSolventProficiencyIndex()
    local list = mode == "POISON" and POISON_SOLVENTS or POTION_SOLVENTS
    return list[rank] or list[#list]
end

function A:GetCatalogWithOwnership()
    local out, present = {}, {}
    local owned = self.reagentsByName or {}
    for _, row in ipairs(REAGENT_CATALOG) do
        local key = normalize(row[1])
        local live = owned[key]
        local traits = {}
        if live and #live.traits > 0 then
            for _, t in ipairs(live.traits) do traits[#traits + 1] = canonicalTrait(t) end
        else
            for i = 2, #row do traits[#traits + 1] = canonicalTrait(row[i]) end
        end
        out[#out + 1] = { name = live and live.name or row[1], key = key, traits = traits, owned = live }
        present[key] = true
    end
    -- Future reagents not yet in the static catalog still participate in "Can
    -- Make Now" and exact matching as soon as the game exposes their traits.
    for key, live in pairs(owned) do
        if not present[key] and #live.traits > 0 then
            out[#out + 1] = { name = live.name, key = key, traits = live.traits, owned = live }
        end
    end
    table.sort(out, function(a,b) return tostring(a.name) < tostring(b.name) end)
    return out
end

function A:GetActiveEffects(combo)
    local counts, all = {}, {}
    for _, reagent in ipairs(combo or {}) do
        for _, rawTrait in ipairs(reagent.traits or {}) do
            local trait = canonicalTrait(rawTrait)
            if trait then
                counts[trait] = (counts[trait] or 0) + 1
                all[trait] = true
            end
        end
    end
    local active = {}
    for trait, count in pairs(counts) do
        if count >= 2 then
            local counter = COUNTERS[trait]
            if not counter or not all[counter] then active[#active + 1] = trait end
        end
    end
    table.sort(active)
    return active
end

function A:HasDesiredEffects(active, desired)
    local set = {}
    for _, t in ipairs(active or {}) do set[t] = true end
    for _, t in ipairs(desired or {}) do if t ~= "" and not set[t] then return false end end
    return true
end

function A:GetOwnedLocation(reagent)
    if not reagent then return nil end
    local owned = reagent.owned or (self.reagentsByName and self.reagentsByName[reagent.key])
    if not owned or not owned.locations then return nil end
    -- Prefer backpack, then craft bag, then bank. All are valid crafting sources
    -- at a normal Alchemy station, but backpack gives the most predictable UI.
    local backpack = rawget(_G, "BAG_BACKPACK")
    local virtual = rawget(_G, "BAG_VIRTUAL")
    local best
    for _, loc in ipairs(owned.locations) do
        if loc.count and loc.count > 0 then
            if loc.bagId == backpack then return loc end
            if not best or (loc.bagId == virtual and best.bagId ~= backpack) then best = loc end
        end
    end
    return best
end

function A:BuildResult(combo, active, mode, selectedCount)
    local solvent = self:GetBestSolvent(mode)
    local missing, maxCraftable = {}, solvent and solvent.count or 0
    for _, reagent in ipairs(combo) do
        local owned = reagent.owned or (self.reagentsByName and self.reagentsByName[reagent.key])
        if not owned or num(owned.count, 0) < 1 then
            missing[#missing + 1] = reagent.name .. " x1"
        else
            maxCraftable = math.min(maxCraftable, num(owned.count, 0))
        end
    end
    if not solvent then missing[#missing + 1] = self:GetExpectedSolventName(mode) .. " x1 (solvent)" end
    local names = {}
    for _, reagent in ipairs(combo) do names[#names + 1] = reagent.name end
    local activeCount = #active
    return {
        combo = combo,
        effects = active,
        effectsText = table.concat(active, " + "),
        reagentsText = table.concat(names, " + "),
        mode = mode,
        solvent = solvent,
        ready = #missing == 0,
        missing = missing,
        missingCount = #missing,
        maxCraftable = #missing == 0 and math.max(0, maxCraftable) or 0,
        extraCount = math.max(0, activeCount - num(selectedCount, activeCount)),
    }
end

function A:BuildCanMakeResults()
    self:ScanMaterials()
    local mode = EPC.saved.alchemyPotionMakerMode == "POISON" and "POISON" or "POTION"
    local solvent = self:GetBestSolvent(mode)
    if not solvent then return {} end
    local list = self.reagentList or {}
    local wrappers = {}
    for _, entry in ipairs(list) do wrappers[#wrappers + 1] = { name = entry.name, key = entry.key, traits = entry.traits, owned = entry } end
    local bestByEffects = {}
    local allowThree = self:IsThirdSlotUnlocked()
    local function consider(combo)
        local active = self:GetActiveEffects(combo)
        if #active == 0 then return end
        local result = self:BuildResult(combo, active, mode, #active)
        if not result.ready or result.maxCraftable < 1 then return end
        local key = table.concat(active, "|")
        local old = bestByEffects[key]
        if not old or result.maxCraftable > old.maxCraftable or (result.maxCraftable == old.maxCraftable and #combo < #old.combo) then
            bestByEffects[key] = result
        end
    end
    for i = 1, #wrappers - 1 do
        for j = i + 1, #wrappers do consider({wrappers[i], wrappers[j]}) end
    end
    if allowThree then
        for i = 1, #wrappers - 2 do
            for j = i + 1, #wrappers - 1 do
                for k = j + 1, #wrappers do consider({wrappers[i], wrappers[j], wrappers[k]}) end
            end
        end
    end
    local out = {}
    for _, result in pairs(bestByEffects) do out[#out + 1] = result end
    table.sort(out, function(a,b)
        if #a.effects ~= #b.effects then return #a.effects > #b.effects end
        if a.maxCraftable ~= b.maxCraftable then return a.maxCraftable > b.maxCraftable end
        return a.effectsText < b.effectsText
    end)
    return out
end

function A:GetDesiredEffects()
    self:EnsureSaved()
    local out, seen = {}, {}
    for _, key in ipairs({"alchemyPotionMakerEffect1", "alchemyPotionMakerEffect2", "alchemyPotionMakerEffect3"}) do
        local value = canonicalTrait(EPC.saved[key])
        if value and value ~= "" and not seen[value] then seen[value] = true out[#out + 1] = value end
    end
    return out
end

function A:BuildExactResults()
    self:ScanMaterials()
    local desired = self:GetDesiredEffects()
    if #desired == 0 then return {} end
    local mode = EPC.saved.alchemyPotionMakerMode == "POISON" and "POISON" or "POTION"
    local catalog = self:GetCatalogWithOwnership()
    local allowThree = self:IsThirdSlotUnlocked()
    local out = {}
    local function consider(combo)
        local active = self:GetActiveEffects(combo)
        if #active == 0 or not self:HasDesiredEffects(active, desired) then return end
        out[#out + 1] = self:BuildResult(combo, active, mode, #desired)
    end
    for i = 1, #catalog - 1 do
        for j = i + 1, #catalog do consider({catalog[i], catalog[j]}) end
    end
    if allowThree then
        for i = 1, #catalog - 2 do
            for j = i + 1, #catalog - 1 do
                for k = j + 1, #catalog do consider({catalog[i], catalog[j], catalog[k]}) end
            end
        end
    end
    table.sort(out, function(a,b)
        if a.ready ~= b.ready then return a.ready end
        if a.extraCount ~= b.extraCount then return a.extraCount < b.extraCount end
        if a.missingCount ~= b.missingCount then return a.missingCount < b.missingCount end
        if #a.combo ~= #b.combo then return #a.combo < #b.combo end
        if a.maxCraftable ~= b.maxCraftable then return a.maxCraftable > b.maxCraftable end
        return a.reagentsText < b.reagentsText
    end)
    if #out > 160 then
        local limited = {}
        for i = 1, 160 do limited[i] = out[i] end
        out = limited
    end
    return out
end

function A:GetAutoCraftLabel()
    self:EnsureSaved()
    if EPC.saved.alchemyPotionMakerAutoCraft ~= true then return "OFF" end
    local mode = tostring(EPC.saved.alchemyPotionMakerAutoCraftMode or "ONE")
    if mode == "MAX" then return "ON / MAX" end
    if mode == "CUSTOM" then
        return "ON / x" .. tostring(math.max(1, math.floor(num(EPC.saved.alchemyPotionMakerAutoCraftQuantity, 1))))
    end
    return "ON / x1"
end

function A:GetStatusText()
    self:EnsureSaved()
    if not self.reagentList or not self.solvents then self:ScanMaterials() end
    local mode = EPC.saved.alchemyPotionMakerMode == "POISON" and "POISON" or "POTION"
    local solvent = self:GetBestSolvent(mode)
    local solventText = solvent and string.format("%s x%d", solvent.name, solvent.count) or ("NONE (need " .. self:GetExpectedSolventName(mode) .. ")")
    return string.format("%s | Solvent: %s | Reagents: %d | 3rd: %s | Auto: %s",
        mode == "POISON" and "POISON" or "POTION",
        solventText,
        #(self.reagentList or {}),
        self:IsThirdSlotUnlocked() and "YES" or "NO",
        self:GetAutoCraftLabel())
end

function A:ReportMissing(result)
    if not result then return end
    if result.ready then return end
    local text = #result.missing > 0 and table.concat(result.missing, ", ") or "unknown materials"
    notify("ALCHEMY MAKER missing: " .. text .. ". Recipe: " .. tostring(result.reagentsText), false)
end

function A:PrepareResult(result, quietSuccess)
    if not result then return false, nil end
    if not result.ready then self:ReportMissing(result) return false, nil end
    if not self:IsAtAlchemyStation() then
        notify("Open an Alchemy Station before preparing ingredients.", false)
        return false, nil
    end
    local alchemy = rawget(_G, "ALCHEMY")
    if type(alchemy) ~= "table" or type(alchemy.AddItemToCraft) ~= "function" then
        alchemy = rawget(_G, "GAMEPAD_ALCHEMY")
    end
    if type(alchemy) ~= "table" or type(alchemy.AddItemToCraft) ~= "function" then
        notify("Alchemy crafting controller is not available on this UI mode.", false)
        return false, nil
    end

    if type(alchemy.ClearSelections) == "function" then
        local ok = pcall(alchemy.ClearSelections, alchemy)
        if not ok then notify("Could not clear the current Alchemy slots.", false) return false, nil end
    end

    local function canAdd(bagId, slotIndex)
        if bagId == nil or slotIndex == nil then return false end
        if type(alchemy.CanItemBeAddedToCraft) == "function" then
            local ok, allowed = pcall(alchemy.CanItemBeAddedToCraft, alchemy, bagId, slotIndex)
            if ok then return allowed ~= false end
        end
        return true
    end

    local function add(bagId, slotIndex, label, quiet)
        if bagId == nil or slotIndex == nil then return false end
        if not canAdd(bagId, slotIndex) then
            if not quiet then notify("Alchemy cannot slot " .. tostring(label) .. " for this character/station.", false) end
            return false
        end
        local ok, added = pcall(alchemy.AddItemToCraft, alchemy, bagId, slotIndex)
        if not ok or added == false then
            if not quiet then notify("Could not add " .. tostring(label) .. " to the Alchemy table.", false) end
            return false
        end
        return true
    end

    local solvent
    local candidates = self:GetUsableSolvents(result.mode)
    if result.solvent and self:IsSolventLevelUsable(result.solvent) then
        local preferred = result.solvent
        local reordered = { preferred }
        for _, candidate in ipairs(candidates) do
            if candidate ~= preferred then reordered[#reordered + 1] = candidate end
        end
        candidates = reordered
    end
    for _, candidate in ipairs(candidates) do
        if add(candidate.bagId, candidate.slotIndex, candidate.name, true) then
            solvent = candidate
            break
        end
    end
    if not solvent then
        notify("No usable " .. string.lower(result.mode == "POISON" and "poison" or "potion") .. " solvent could be slotted. Need a solvent your character's level and Solvent Proficiency can use (up to " .. self:GetExpectedSolventName(result.mode) .. ").", false)
        return false, nil
    end

    local reagentLocations = {}
    for _, reagent in ipairs(result.combo or {}) do
        local loc = self:GetOwnedLocation(reagent)
        if not loc or not add(loc.bagId, loc.slotIndex, reagent.name) then return false, nil end
        reagentLocations[#reagentLocations + 1] = { bagId = loc.bagId, slotIndex = loc.slotIndex, name = reagent.name }
    end

    if type(alchemy.OnSlotChanged) == "function" then pcall(alchemy.OnSlotChanged, alchemy) end
    local craftable = type(alchemy.IsCraftable) ~= "function" or safe(alchemy.IsCraftable, false, alchemy) == true
    local craftInfo = {
        result = result,
        solvent = solvent,
        reagents = reagentLocations,
    }
    self.lastPreparedCraft = craftInfo
    if craftable then
        if not quietSuccess then notify("ALCHEMY MAKER loaded: " .. result.reagentsText .. ". Press ESO's CRAFT button to make it.", true) end
    else
        notify("Ingredients were loaded, but ESO does not consider this mixture craftable yet. Check Alchemy passives/solvent requirements.", false)
    end
    return craftable, craftInfo
end

function A:GetMaxCraftIterations(craftInfo)
    if not craftInfo or not craftInfo.solvent or type(GetMaxIterationsPossibleForAlchemyItem) ~= "function" then return 0 end
    local r1, r2, r3 = craftInfo.reagents[1], craftInfo.reagents[2], craftInfo.reagents[3]
    if not r1 or not r2 then return 0 end
    local ok, maximum = pcall(GetMaxIterationsPossibleForAlchemyItem,
        craftInfo.solvent.bagId, craftInfo.solvent.slotIndex,
        r1.bagId, r1.slotIndex,
        r2.bagId, r2.slotIndex,
        r3 and r3.bagId or nil, r3 and r3.slotIndex or nil)
    if not ok then return 0 end
    return math.max(0, math.floor(num(maximum, 0)))
end

function A:GetRequestedAutoCraftIterations(maximum)
    self:EnsureSaved()
    maximum = math.max(0, math.floor(num(maximum, 0)))
    if maximum <= 0 then return 0 end
    local mode = tostring(EPC.saved.alchemyPotionMakerAutoCraftMode or "ONE")
    if mode == "MAX" then return maximum end
    if mode == "CUSTOM" then
        return math.min(maximum, math.max(1, math.floor(num(EPC.saved.alchemyPotionMakerAutoCraftQuantity, 1))))
    end
    return 1
end

function A:AutoCraftResult(result)
    self:EnsureSaved()
    if EPC.saved.alchemyPotionMakerAutoCraft ~= true then return self:PrepareResult(result) end
    if type(ZO_CraftingUtils_IsPerformingCraftProcess) == "function" and safe(ZO_CraftingUtils_IsPerformingCraftProcess, false) == true then
        notify("Alchemy is already crafting. Wait for the current craft to finish.", false)
        return false
    end
    if type(CraftAlchemyItem) ~= "function" then
        notify("ESO's Alchemy craft function is unavailable. Ingredients were not crafted automatically.", false)
        return self:PrepareResult(result)
    end

    local craftable, info = self:PrepareResult(result, true)
    if not craftable or not info then return false end
    local maximum = self:GetMaxCraftIterations(info)
    local iterations = self:GetRequestedAutoCraftIterations(maximum)
    if iterations < 1 then
        notify("This mixture cannot be crafted with the currently slotted materials.", false)
        return false
    end
    local r1, r2, r3 = info.reagents[1], info.reagents[2], info.reagents[3]
    local ok, err = pcall(CraftAlchemyItem,
        info.solvent.bagId, info.solvent.slotIndex,
        r1.bagId, r1.slotIndex,
        r2.bagId, r2.slotIndex,
        r3 and r3.bagId or nil, r3 and r3.slotIndex or nil,
        iterations)
    if not ok then
        notify("Auto Craft could not start: " .. tostring(err or "unknown Alchemy error"), false)
        return false
    end
    notify(string.format("ALCHEMY AUTO CRAFT: started %d iteration%s of %s.", iterations, iterations == 1 and "" or "s", tostring(result.effectsText ~= "" and result.effectsText or result.reagentsText)), true)
    return true
end

function A:ActivateResult(result)
    if not result then return false end
    self:EnsureSaved()
    if EPC.saved.alchemyPotionMakerAutoCraft == true then return self:AutoCraftResult(result) end
    return self:PrepareResult(result)
end

function A:SetMode(mode)
    self:EnsureSaved()
    EPC.saved.alchemyPotionMakerMode = mode == "POISON" and "POISON" or "POTION"
    self.currentPage = 1
    self:RefreshWindow(true)
    self:RefreshStatus()
end

function A:ToggleMode()
    self:SetMode(EPC.saved.alchemyPotionMakerMode == "POISON" and "POTION" or "POISON")
end

function A:SetView(view)
    self.currentView = view == "EXACT" and "EXACT" or "READY"
    self.currentPage = 1
    self:RefreshWindow(true)
end

function A:SetEffect(slot, value)
    self:EnsureSaved()
    slot = math.max(1, math.min(3, num(slot, 1)))
    EPC.saved["alchemyPotionMakerEffect" .. slot] = value or ""
    self.currentPage = 1
    self:RefreshWindow(true)
end

function A:CreateEffectPopup()
    if self.effectPopup or not wm or not GuiRoot then return end
    local popup = wm:CreateTopLevelWindow("EAS_AlchemyPotionMakerEffectPopup")
    popup:SetDimensions(EFFECT_POPUP_W, EFFECT_POPUP_H)
    popup:SetMouseEnabled(true)
    popup:SetMovable(false)
    popup:SetClampedToScreen(true)
    if popup.SetDrawTier then popup:SetDrawTier(rawget(_G, "DT_HIGH") or DT_HIGH) end
    if popup.SetDrawLayer then popup:SetDrawLayer(rawget(_G, "DL_OVERLAY") or DL_OVERLAY) end
    if popup.SetDrawLevel then popup:SetDrawLevel(12000) end
    popup:SetHidden(true)
    self.effectPopup = popup

    local bg = wm:CreateControl(nil, popup, CT_BACKDROP)
    bg:SetAnchorFill(popup)
    bg:SetCenterColor(0.008, 0.014, 0.024, 0.995)
    bg:SetEdgeColor(0.82, 0.62, 0.18, 1)
    bg:SetEdgeTexture(nil, 2, 2, 1)

    local title = wm:CreateControl(nil, popup, CT_LABEL)
    title:SetFont("ZoFontWinH2")
    title:SetAnchor(TOPLEFT, popup, TOPLEFT, 18, 12)
    title:SetDimensions(EFFECT_POPUP_W - 80, 36)
    title:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    title:SetColor(0.94, 0.84, 0.38, 1)
    self.effectPopupTitle = title

    local close = wm:CreateControl(nil, popup, CT_BUTTON)
    close:SetDimensions(38, 38)
    close:SetAnchor(TOPRIGHT, popup, TOPRIGHT, -10, 8)
    close:SetFont("ZoFontWinH3")
    close:SetText("X")
    close:SetHandler("OnClicked", function() popup:SetHidden(true) end)

    self.effectPopupButtons = {}
    local colW = math.floor((EFFECT_POPUP_W - 54) / 2)
    for i = 1, EFFECT_POPUP_ROWS * 2 do
        local col = i > EFFECT_POPUP_ROWS and 2 or 1
        local row = ((i - 1) % EFFECT_POPUP_ROWS) + 1
        local btn = wm:CreateControl(nil, popup, CT_BUTTON)
        btn:SetDimensions(colW, 30)
        btn:SetAnchor(TOPLEFT, popup, TOPLEFT, 18 + (col - 1) * (colW + 12), 58 + (row - 1) * 31)
        btn:SetFont("ZoFontGame")
        btn:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        btn:SetHandler("OnClicked", function(control)
            local value = control.effectValue
            if value ~= nil then self:SetEffect(self.effectPopupSlot or 1, value) end
            popup:SetHidden(true)
        end)
        self.effectPopupButtons[i] = btn
    end

    local note = wm:CreateControl(nil, popup, CT_LABEL)
    note:SetFont("ZoFontGameSmall")
    note:SetAnchor(BOTTOMLEFT, popup, BOTTOMLEFT, 18, -10)
    note:SetDimensions(EFFECT_POPUP_W - 36, 24)
    note:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    note:SetColor(0.68, 0.76, 0.84, 1)
    note:SetText("This selector is a separate top-level overlay so it always stays above the Potion Maker.")
end

function A:ShowEffectMenu(owner, slot)
    self:CreateEffectPopup()
    if not self.effectPopup then return end
    self.effectPopupSlot = math.max(1, math.min(3, num(slot, 1)))
    if self.effectPopupTitle then self.effectPopupTitle:SetText("SELECT EFFECT " .. tostring(self.effectPopupSlot)) end

    local choices = {}
    if self.effectPopupSlot == 1 then
        choices[#choices + 1] = { label = "Restore Health (Default)", value = "Restore Health" }
    else
        choices[#choices + 1] = { label = "-- NONE --", value = "" }
    end
    for _, effect in ipairs(EFFECTS) do
        if not (self.effectPopupSlot == 1 and effect == "Restore Health") then
            choices[#choices + 1] = { label = effect, value = effect }
        end
    end

    for i, btn in ipairs(self.effectPopupButtons or {}) do
        local choice = choices[i]
        btn.effectValue = choice and choice.value or nil
        btn:SetHidden(choice == nil)
        if choice then
            btn:SetText(choice.label)
            local current = tostring(EPC.saved["alchemyPotionMakerEffect" .. self.effectPopupSlot] or "")
            if current == choice.value then btn:SetFont("ZoFontGameBold") else btn:SetFont("ZoFontGame") end
        end
    end

    self.effectPopup:ClearAnchors()
    self.effectPopup:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    self.effectPopup:SetHidden(false)
    if self.effectPopup.BringWindowToTop then self.effectPopup:BringWindowToTop() end
end

function A:RefreshStatus()
    if not self.button then return end
    if not self:IsAtAlchemyStation() and not self.layoutMode then
        if self.countLabel then self.countLabel:SetText("0") end
        return
    end
    local count = 0
    if self:IsAtAlchemyStation() then
        local ok, results = pcall(function() return self:BuildCanMakeResults() end)
        if ok and type(results) == "table" then
            count = #results
            self.cachedReadyResults = results
        end
    end
    if self.countLabel then self.countLabel:SetText(count > 99 and "99+" or tostring(count)) end
    if self.glow then
        if self.layoutMode then self.glow:SetEdgeColor(1.00, 0.72, 0.22, 1)
        elseif count > 0 then self.glow:SetEdgeColor(0.20, 0.85, 0.62, 1)
        else self.glow:SetEdgeColor(0.28, 0.36, 0.46, 0.9) end
    end
end

function A:RefreshVisibility()
    self:EnsureSaved()
    self:CreateIcon()
    if not self.button then return end
    local layout = self.layoutMode == true or (EPC and EPC.unitFramesMoveMode == true)
    local show = layout or (EPC.saved.alchemyPotionMakerEnabled ~= false and self:IsAtAlchemyStation())
    self.button:SetHidden(not show)
    if show then
        if layout then
            if self.countLabel then self.countLabel:SetText("MOVE") end
            if self.glow then self.glow:SetEdgeColor(1.00, 0.72, 0.22, 1) end
        else
            self:RefreshStatus()
        end
    end
    if not show and self.window and not self.window:IsHidden() then self.window:SetHidden(true) end
end

function A:SetLayoutMode(active)
    active = active == true
    self:EnsureSaved()
    self:CreateIcon()
    self.layoutMode = active
    if not self.button then return end
    self.button:SetDimensions(NORMAL_W, NORMAL_H)
    self.button:SetMovable(true)
    self.button:SetMouseEnabled(true)
    if self.layoutDragHandle then
        self.layoutDragHandle:SetMouseEnabled(active)
        self.layoutDragHandle:SetHidden(not active)
    end
    if active then
        self.button:SetHidden(false)
        if self.button.SetTopLevel then self.button:SetTopLevel(true) end
        if self.button.SetDrawTier and DT_HIGH then self.button:SetDrawTier(DT_HIGH) end
        if self.button.SetDrawLayer and DL_OVERLAY then self.button:SetDrawLayer(DL_OVERLAY) end
        if self.button.SetDrawLevel then self.button:SetDrawLevel(950) end
        if self.button.BringWindowToTop then self.button:BringWindowToTop() end
        if self.countLabel then self.countLabel:SetText("MOVE") end
        if self.glow then self.glow:SetEdgeColor(1.00, 0.72, 0.22, 1) end
        if self.window and not self.window:IsHidden() then self.window:SetHidden(true) end
    else
        self:RefreshVisibility()
    end
end

function A:RaiseForLayout()
    if self.layoutMode ~= true or not self.button or self.button:IsHidden() then return end
    if self.button.SetTopLevel then self.button:SetTopLevel(true) end
    if self.button.SetDrawTier and DT_HIGH then self.button:SetDrawTier(DT_HIGH) end
    if self.button.SetDrawLayer and DL_OVERLAY then self.button:SetDrawLayer(DL_OVERLAY) end
    if self.button.SetDrawLevel then self.button:SetDrawLevel(950) end
    if self.button.BringWindowToTop then self.button:BringWindowToTop() end
end

function A:CreateIcon()
    if self.button or not wm or not GuiRoot then return end
    local b = wm:CreateTopLevelWindow("EAS_AlchemyPotionMakerIcon")
    b:SetDimensions(NORMAL_W, NORMAL_H)
    b:SetMouseEnabled(true)
    b:SetMovable(true)
    b:SetClampedToScreen(true)
    b:SetDrawTier(DT_HIGH)
    b:SetDrawLayer(DL_OVERLAY)
    b:SetDrawLevel(900)
    b:SetHidden(true)
    self.button = b

    local bg = wm:CreateControl(nil, b, CT_BACKDROP)
    bg:SetAnchorFill(b)
    bg:SetCenterColor(0.018, 0.026, 0.040, 0.96)
    bg:SetEdgeColor(0.28, 0.36, 0.46, 0.9)
    bg:SetEdgeTexture(nil, 1, 1, 1)
    self.glow = bg

    local icon = wm:CreateControl(nil, b, CT_TEXTURE)
    icon:SetDimensions(46, 46)
    icon:SetAnchor(CENTER, b, CENTER, 0, 0)
    icon:SetTexture(ICON_TEXTURE)
    self.icon = icon

    local count = wm:CreateControl(nil, b, CT_LABEL)
    count:SetFont("ZoFontGameBold")
    count:SetAnchor(BOTTOMRIGHT, bg, BOTTOMRIGHT, -3, -1)
    count:SetDimensions(34, 20)
    count:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    count:SetColor(0.70, 1.00, 0.75, 1)
    count:SetText("0")
    self.countLabel = count

    b:SetHandler("OnMouseDown", function(control, button)
        if button ~= MOUSE_BUTTON_INDEX_LEFT then return end
        if self.layoutMode == true or (EPC and EPC.unitFramesMoveMode == true) then return end
        self.pressLeft = num(control:GetLeft(), 0)
        self.pressTop = num(control:GetTop(), 0)
        if control.StartMoving then control:StartMoving() end
    end)
    b:SetHandler("OnMouseUp", function(control, button, upInside)
        if button ~= MOUSE_BUTTON_INDEX_LEFT then return end
        if self.layoutMode == true or (EPC and EPC.unitFramesMoveMode == true) then return end
        if control.StopMoving then control:StopMoving() end
        local left, top = num(control:GetLeft(), 0), num(control:GetTop(), 0)
        self:SavePosition()
        local moved = math.abs(left - num(self.pressLeft, left)) > 4 or math.abs(top - num(self.pressTop, top)) > 4
        self.pressLeft, self.pressTop = nil, nil
        if upInside ~= false and not moved then self:ToggleWindow() end
    end)
    b:SetHandler("OnMoveStop", function(control)
        if control.StopMoving then control:StopMoving() end
        self:SavePosition()
    end)

    local handle = wm:CreateControl(nil, b, CT_CONTROL)
    handle:SetAnchorFill(b)
    handle:SetMouseEnabled(false)
    handle:SetHidden(true)
    if handle.SetDrawLayer and DL_OVERLAY then handle:SetDrawLayer(DL_OVERLAY) end
    if handle.SetDrawLevel then handle:SetDrawLevel(2000) end
    handle:SetHandler("OnMouseDown", function(_, button)
        if button ~= MOUSE_BUTTON_INDEX_LEFT then return end
        if self.layoutMode ~= true and not (EPC and EPC.unitFramesMoveMode == true) then return end
        self.layoutDragging = true
        if b.BringWindowToTop then b:BringWindowToTop() end
        if b.StartMoving then b:StartMoving() end
    end)
    handle:SetHandler("OnMouseUp", function(_, button)
        if button ~= MOUSE_BUTTON_INDEX_LEFT or self.layoutDragging ~= true then return end
        self.layoutDragging = false
        if b.StopMoving then b:StopMoving() end
        self:SavePosition()
    end)
    self.layoutDragHandle = handle

    b:SetHandler("OnMouseEnter", function(control)
        if InformationTooltip and type(InitializeTooltip) == "function" then
            InitializeTooltip(InformationTooltip, control, TOPRIGHT, 0, 0, TOPLEFT)
            InformationTooltip:AddLine("ALCHEMY POTION & POISON MAKER", "ZoFontWinH4")
            InformationTooltip:AddLine("At an Alchemy Station, click to see mixtures you can make now or choose exact effects and see the reagents/solvent you need.", "ZoFontGame")
            InformationTooltip:AddLine("Click a READY recipe to auto-slot the solvent and reagents. You still press ESO's Craft button.", "ZoFontGameSmall")
        end
    end)
    b:SetHandler("OnMouseExit", function() if InformationTooltip and type(ClearTooltip)=="function" then ClearTooltip(InformationTooltip) end end)
    self:RestorePosition()
end

local function setButtonText(button, text)
    if not button then return end
    if type(button.SetText) == "function" then button:SetText(text) end
end

function A:CreateWindow()
    if self.window or not wm or not GuiRoot then return end
    local w = wm:CreateTopLevelWindow("EAS_AlchemyPotionMakerWindow")
    w:SetDimensions(PANEL_W, PANEL_H)
    w:SetMouseEnabled(true)
    w:SetMovable(true)
    w:SetClampedToScreen(true)
    -- Keep the maker below the dedicated effect/options popup. A separate
    -- top-level overlay is used for selectors so parent draw order can never
    -- hide the options behind this window.
    if w.SetDrawTier then w:SetDrawTier(rawget(_G, "DT_MEDIUM") or rawget(_G, "DT_LOW") or DT_HIGH) end
    if w.SetDrawLayer then w:SetDrawLayer(rawget(_G, "DL_CONTROLS") or DL_CONTROLS) end
    if w.SetDrawLevel then w:SetDrawLevel(120) end
    w:SetHidden(true)
    self.window = w

    local bg = wm:CreateControl(nil, w, CT_BACKDROP)
    bg:SetAnchorFill(w)
    bg:SetCenterColor(0.012, 0.018, 0.030, 0.985)
    bg:SetEdgeColor(0.22, 0.72, 0.92, 0.95)
    bg:SetEdgeTexture(nil, 2, 2, 1)

    local titleBar = wm:CreateControl(nil, w, CT_CONTROL)
    titleBar:SetDimensions(PANEL_W - 50, 46)
    titleBar:SetAnchor(TOPLEFT, w, TOPLEFT, 8, 6)
    titleBar:SetMouseEnabled(true)
    titleBar:SetHandler("OnMouseDown", function(_, button) if button==MOUSE_BUTTON_INDEX_LEFT and w.StartMoving then w:StartMoving() end end)
    titleBar:SetHandler("OnMouseUp", function(_, button) if button==MOUSE_BUTTON_INDEX_LEFT then if w.StopMoving then w:StopMoving() end self:SavePanelPosition() end end)

    local title = wm:CreateControl(nil, titleBar, CT_LABEL)
    title:SetFont("ZoFontWinH2")
    title:SetAnchor(LEFT, titleBar, LEFT, 12, 0)
    title:SetDimensions(PANEL_W - 90, 40)
    title:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    title:SetColor(0.94, 0.84, 0.38, 1)
    title:SetText("ALCHEMY POTION & POISON MAKER")

    local close = wm:CreateControl(nil, w, CT_BUTTON)
    close:SetDimensions(38, 38)
    close:SetAnchor(TOPRIGHT, w, TOPRIGHT, -8, 8)
    close:SetFont("ZoFontWinH3")
    close:SetText("X")
    close:SetHandler("OnClicked", function() w:SetHidden(true) if self.effectPopup then self.effectPopup:SetHidden(true) end end)

    local mode = wm:CreateControl(nil, w, CT_BUTTON)
    mode:SetDimensions(150, 34)
    mode:SetAnchor(TOPLEFT, w, TOPLEFT, 18, 56)
    mode:SetFont("ZoFontGameBold")
    mode:SetHandler("OnClicked", function() self:ToggleMode() end)
    self.modeButton = mode

    local readyTab = wm:CreateControl(nil, w, CT_BUTTON)
    readyTab:SetDimensions(180, 34)
    readyTab:SetAnchor(LEFT, mode, RIGHT, 12, 0)
    readyTab:SetFont("ZoFontGameBold")
    readyTab:SetText("CAN MAKE NOW")
    readyTab:SetHandler("OnClicked", function() self:SetView("READY") end)
    self.readyTab = readyTab

    local exactTab = wm:CreateControl(nil, w, CT_BUTTON)
    exactTab:SetDimensions(180, 34)
    exactTab:SetAnchor(LEFT, readyTab, RIGHT, 8, 0)
    exactTab:SetFont("ZoFontGameBold")
    exactTab:SetText("MAKE EXACT")
    exactTab:SetHandler("OnClicked", function() self:SetView("EXACT") end)
    self.exactTab = exactTab

    local rescan = wm:CreateControl(nil, w, CT_BUTTON)
    rescan:SetDimensions(150, 34)
    rescan:SetAnchor(LEFT, exactTab, RIGHT, 8, 0)
    rescan:SetFont("ZoFontGame")
    rescan:SetText("RESCAN MATERIALS")
    rescan:SetHandler("OnClicked", function() self:RefreshWindow(true) self:RefreshStatus() end)

    local status = wm:CreateControl(nil, w, CT_LABEL)
    status:SetFont("ZoFontGame")
    status:SetAnchor(TOPLEFT, w, TOPLEFT, 20, 98)
    status:SetDimensions(PANEL_W - 235, 42)
    status:SetColor(0.72, 0.82, 0.92, 1)
    status:SetText("")
    self.statusLabel = status

    local autoCraft = wm:CreateControl(nil, w, CT_BUTTON)
    autoCraft:SetDimensions(185, 34)
    autoCraft:SetAnchor(TOPRIGHT, w, TOPRIGHT, -20, 100)
    autoCraft:SetFont("ZoFontGameBold")
    autoCraft:SetHandler("OnClicked", function()
        EPC.saved.alchemyPotionMakerAutoCraft = EPC.saved.alchemyPotionMakerAutoCraft ~= true
        self:RefreshWindow(false)
    end)
    autoCraft:SetHandler("OnMouseEnter", function(control)
        if InformationTooltip and type(InitializeTooltip) == "function" then
            InitializeTooltip(InformationTooltip, control, BOTTOM, 0, -8, TOP)
            InformationTooltip:AddLine("Auto Craft", "ZoFontWinH4")
            InformationTooltip:AddLine("OFF: clicking READY only loads ingredients. ON: clicking READY loads and immediately crafts using the amount selected in Suite Settings.", "ZoFontGame")
        end
    end)
    autoCraft:SetHandler("OnMouseExit", function() if InformationTooltip and type(ClearTooltip) == "function" then ClearTooltip(InformationTooltip) end end)
    self.autoCraftButton = autoCraft

    local exactBar = wm:CreateControl(nil, w, CT_CONTROL)
    exactBar:SetDimensions(PANEL_W - 40, 42)
    exactBar:SetAnchor(TOPLEFT, status, BOTTOMLEFT, 0, 2)
    self.exactBar = exactBar

    local effectButtons = {}
    for i = 1, 3 do
        local btn = wm:CreateControl(nil, exactBar, CT_BUTTON)
        btn:SetDimensions(205, 34)
        if i == 1 then btn:SetAnchor(LEFT, exactBar, LEFT, 0, 0) else btn:SetAnchor(LEFT, effectButtons[i-1], RIGHT, 8, 0) end
        btn:SetFont("ZoFontGame")
        btn:SetHandler("OnClicked", function(control) self:ShowEffectMenu(control, i) end)
        effectButtons[i] = btn
    end
    self.effectButtons = effectButtons

    local clearEffects = wm:CreateControl(nil, exactBar, CT_BUTTON)
    clearEffects:SetDimensions(105, 34)
    clearEffects:SetAnchor(LEFT, effectButtons[3], RIGHT, 8, 0)
    clearEffects:SetFont("ZoFontGame")
    clearEffects:SetText("CLEAR")
    clearEffects:SetHandler("OnClicked", function()
        EPC.saved.alchemyPotionMakerEffect1 = "Restore Health"
        EPC.saved.alchemyPotionMakerEffect2 = ""
        EPC.saved.alchemyPotionMakerEffect3 = ""
        self.currentPage = 1
        self:RefreshWindow(true)
    end)

    local divider = wm:CreateControl(nil, w, CT_BACKDROP)
    divider:SetDimensions(PANEL_W - 40, 1)
    divider:SetAnchor(TOPLEFT, exactBar, BOTTOMLEFT, 0, 5)
    divider:SetCenterColor(0.18, 0.42, 0.55, 0.8)
    divider:SetEdgeColor(0,0,0,0)

    self.rows = {}
    local firstY = 190
    for i = 1, ROW_COUNT do
        local row = wm:CreateControl(nil, w, CT_BUTTON)
        row:SetDimensions(PANEL_W - 40, 31)
        row:SetAnchor(TOPLEFT, w, TOPLEFT, 20, firstY + (i - 1) * 32)
        row:SetMouseEnabled(true)
        local rowBg = wm:CreateControl(nil, row, CT_BACKDROP)
        rowBg:SetAnchorFill(row)
        rowBg:SetCenterColor(i % 2 == 0 and 0.025 or 0.018, i % 2 == 0 and 0.038 or 0.030, i % 2 == 0 and 0.052 or 0.044, 0.94)
        rowBg:SetEdgeColor(0.10, 0.18, 0.24, 0.8)
        rowBg:SetEdgeTexture(nil, 1, 1, 1)
        local label = wm:CreateControl(nil, row, CT_LABEL)
        label:SetFont("ZoFontGame")
        label:SetAnchor(LEFT, row, LEFT, 8, 0)
        label:SetDimensions(PANEL_W - 58, 29)
        label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        label:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
        row.label = label
        row.bg = rowBg
        row:SetHandler("OnMouseEnter", function(control)
            if control.result and InformationTooltip and type(InitializeTooltip)=="function" then
                InitializeTooltip(InformationTooltip, control, LEFT, -8, 0, RIGHT)
                InformationTooltip:AddLine(control.result.ready and "READY - CLICK TO LOAD" or "MISSING MATERIALS", "ZoFontWinH4")
                InformationTooltip:AddLine("Effects: " .. tostring(control.result.effectsText), "ZoFontGame")
                InformationTooltip:AddLine("Reagents: " .. tostring(control.result.reagentsText), "ZoFontGame")
                local sol = control.result.solvent and control.result.solvent.name or self:GetExpectedSolventName(control.result.mode)
                InformationTooltip:AddLine("Solvent: " .. tostring(sol), "ZoFontGame")
                if control.result.ready then
                    InformationTooltip:AddLine("Can craft at least " .. tostring(control.result.maxCraftable) .. " iteration(s) with current materials. " .. (EPC.saved.alchemyPotionMakerAutoCraft == true and "Click to load and Auto Craft." or "Click to auto-slot ingredients."), "ZoFontGameSmall")
                else
                    InformationTooltip:AddLine("Need: " .. table.concat(control.result.missing or {}, ", "), "ZoFontGameSmall")
                end
            end
        end)
        row:SetHandler("OnMouseExit", function() if InformationTooltip and type(ClearTooltip)=="function" then ClearTooltip(InformationTooltip) end end)
        row:SetHandler("OnClicked", function(control)
            if not control.result then return end
            if control.result.ready then self:ActivateResult(control.result) else self:ReportMissing(control.result) end
        end)
        self.rows[i] = row
    end

    local prev = wm:CreateControl(nil, w, CT_BUTTON)
    prev:SetDimensions(90, 32)
    prev:SetAnchor(BOTTOMLEFT, w, BOTTOMLEFT, 20, -18)
    prev:SetFont("ZoFontGameBold")
    prev:SetText("< PREV")
    prev:SetHandler("OnClicked", function() self.currentPage = math.max(1, num(self.currentPage,1)-1) self:RefreshRows() end)
    self.prevButton = prev

    local page = wm:CreateControl(nil, w, CT_LABEL)
    page:SetDimensions(180, 32)
    page:SetAnchor(LEFT, prev, RIGHT, 8, 0)
    page:SetFont("ZoFontGame")
    page:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    page:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    self.pageLabel = page

    local nextBtn = wm:CreateControl(nil, w, CT_BUTTON)
    nextBtn:SetDimensions(90, 32)
    nextBtn:SetAnchor(LEFT, page, RIGHT, 8, 0)
    nextBtn:SetFont("ZoFontGameBold")
    nextBtn:SetText("NEXT >")
    nextBtn:SetHandler("OnClicked", function()
        local pages = math.max(1, math.ceil(#(self.currentResults or {}) / ROW_COUNT))
        self.currentPage = math.min(pages, num(self.currentPage,1)+1)
        self:RefreshRows()
    end)
    self.nextButton = nextBtn

    local help = wm:CreateControl(nil, w, CT_LABEL)
    help:SetDimensions(370, 40)
    help:SetAnchor(BOTTOMRIGHT, w, BOTTOMRIGHT, -20, -14)
    help:SetFont("ZoFontGameSmall")
    help:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    help:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    help:SetColor(0.66, 0.72, 0.80, 1)
    help:SetText("READY = load ingredients.\nAuto Craft is optional and OFF by default.")

    w:SetHandler("OnMoveStop", function(control) if control.StopMoving then control:StopMoving() end self:SavePanelPosition() end)
    self:RestorePanelPosition()
end

function A:RefreshRows()
    if not self.rows then return end
    local results = self.currentResults or {}
    local pages = math.max(1, math.ceil(#results / ROW_COUNT))
    self.currentPage = math.max(1, math.min(pages, num(self.currentPage, 1)))
    local startIndex = (self.currentPage - 1) * ROW_COUNT + 1
    for i, row in ipairs(self.rows) do
        local result = results[startIndex + i - 1]
        row.result = result
        row:SetHidden(result == nil)
        if result then
            local prefix = result.ready and string.format("|c55E6A5READY x%d|r", result.maxCraftable) or "|cFF8866MISSING|r"
            local text = string.format("%s  %s  |c9FB8C8%s|r", prefix, result.effectsText ~= "" and result.effectsText or "Unknown effect", result.reagentsText)
            row.label:SetText(text)
            if row.bg then
                if result.ready then row.bg:SetEdgeColor(0.12, 0.55, 0.38, 0.9) else row.bg:SetEdgeColor(0.55, 0.25, 0.20, 0.9) end
            end
        end
    end
    if self.pageLabel then self.pageLabel:SetText(string.format("PAGE %d / %d   (%d results)", self.currentPage, pages, #results)) end
    if self.prevButton then self.prevButton:SetEnabled(self.currentPage > 1) end
    if self.nextButton then self.nextButton:SetEnabled(self.currentPage < pages) end
end

function A:RefreshWindow(forceScan)
    self:EnsureSaved()
    self:CreateWindow()
    if not self.window then return end
    if forceScan then self.reagentList, self.reagentsByName, self.solvents = nil, nil, nil end
    local mode = EPC.saved.alchemyPotionMakerMode == "POISON" and "POISON" or "POTION"
    setButtonText(self.modeButton, mode == "POISON" and "MODE: POISON" or "MODE: POTION")
    if self.statusLabel then self.statusLabel:SetText(self:GetStatusText()) end
    if self.autoCraftButton then setButtonText(self.autoCraftButton, "AUTO CRAFT: " .. self:GetAutoCraftLabel()) end
    self.currentView = self.currentView == "EXACT" and "EXACT" or "READY"
    if self.exactBar then self.exactBar:SetHidden(self.currentView ~= "EXACT") end
    if self.readyTab then setButtonText(self.readyTab, self.currentView == "READY" and "[ CAN MAKE NOW ]" or "CAN MAKE NOW") end
    if self.exactTab then setButtonText(self.exactTab, self.currentView == "EXACT" and "[ MAKE EXACT ]" or "MAKE EXACT") end
    if self.effectButtons then
        for i, btn in ipairs(self.effectButtons) do
            local v = tostring(EPC.saved["alchemyPotionMakerEffect" .. i] or "")
            setButtonText(btn, string.format("EFFECT %d: %s", i, v ~= "" and v or "NONE"))
        end
    end
    if self.currentView == "EXACT" then self.currentResults = self:BuildExactResults()
    else
        if not forceScan and self.cachedReadyResults then self.currentResults = self.cachedReadyResults else self.currentResults = self:BuildCanMakeResults() end
    end
    self:RefreshRows()
end

function A:OpenWindow()
    self:EnsureSaved()
    if EPC.saved.alchemyPotionMakerEnabled == false then
        notify("Alchemy Potion & Poison Maker is disabled in Suite Settings.", false)
        return
    end
    if not self:IsAtAlchemyStation() then
        notify("Open an Alchemy Station first. The floating potion icon appears there automatically.", false)
        return
    end
    self:CreateWindow()
    self.currentView = self.currentView or "READY"
    self.currentPage = 1
    self:RefreshWindow(true)
    self.window:SetHidden(false)
    if self.window.BringWindowToTop then self.window:BringWindowToTop() end
end

function A:ToggleWindow()
    self:CreateWindow()
    if not self.window then return end
    if self.window:IsHidden() then self:OpenWindow() else self.window:SetHidden(true) if self.effectPopup then self.effectPopup:SetHidden(true) end end
end

function A:ScheduleRefresh(delay)
    if not EVENT_MANAGER then return end
    EVENT_MANAGER:UnregisterForUpdate(PREFIX .. "_Refresh")
    EVENT_MANAGER:RegisterForUpdate(PREFIX .. "_Refresh", math.max(80, num(delay, 250)), function()
        EVENT_MANAGER:UnregisterForUpdate(PREFIX .. "_Refresh")
        self.reagentList, self.reagentsByName, self.solvents = nil, nil, nil
        self.cachedReadyResults = nil
        self:RefreshVisibility()
        if self.window and not self.window:IsHidden() and self:IsAtAlchemyStation() then self:RefreshWindow(true) end
    end)
end

function A:RegisterEvents()
    if self.eventsRegistered or not EVENT_MANAGER then return end
    self.eventsRegistered = true
    if rawget(_G, "EVENT_CRAFTING_STATION_INTERACT") then
        EVENT_MANAGER:RegisterForEvent(PREFIX .. "_StationOpen", EVENT_CRAFTING_STATION_INTERACT, function(_, craftingType)
            if craftingType == rawget(_G, "CRAFTING_TYPE_ALCHEMY") then
                if type(zo_callLater)=="function" then zo_callLater(function() self:RefreshVisibility() end, 120) else self:RefreshVisibility() end
            end
        end)
    end
    if rawget(_G, "EVENT_END_CRAFTING_STATION_INTERACT") then
        EVENT_MANAGER:RegisterForEvent(PREFIX .. "_StationClose", EVENT_END_CRAFTING_STATION_INTERACT, function()
            if self.window then self.window:SetHidden(true) end
            if self.effectPopup then self.effectPopup:SetHidden(true) end
            if type(zo_callLater)=="function" then zo_callLater(function() self:RefreshVisibility() end, 80) else self:RefreshVisibility() end
        end)
    end
    if rawget(_G, "EVENT_INVENTORY_SINGLE_SLOT_UPDATE") then
        EVENT_MANAGER:RegisterForEvent(PREFIX .. "_Inventory", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function()
            if self:IsAtAlchemyStation() then self:ScheduleRefresh(350) end
        end)
    end
    if rawget(_G, "EVENT_CRAFT_COMPLETED") then
        EVENT_MANAGER:RegisterForEvent(PREFIX .. "_CraftComplete", EVENT_CRAFT_COMPLETED, function(_, craftingType)
            if craftingType == rawget(_G, "CRAFTING_TYPE_ALCHEMY") then self:ScheduleRefresh(250) end
        end)
    end
end

function A:Initialize()
    self:EnsureSaved()
    self:CreateIcon()
    self:RegisterEvents()
    self.currentView = "READY"
    self.currentPage = 1
    self:RefreshVisibility()
end
