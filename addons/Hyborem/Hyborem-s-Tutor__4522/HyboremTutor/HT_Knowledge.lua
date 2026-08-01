HT_Knowledge = HT_Knowledge or {}

local LCK = LibCharacterKnowledge

-- Lookup table dla szybszego sprawdzania (sugestia Baertrama)
local INTERESTING = {
    [ITEMTYPE_RACIAL_STYLE_MOTIF] = true,
    [ITEMTYPE_RECIPE] = true,
    [ITEMTYPE_CRAFTED_ABILITY_SCRIPT] = true,
}

-- Lookup table dla kategorii (sugestia Baertrama)
local CATEGORY_MAP = {
    [ITEMTYPE_RACIAL_STYLE_MOTIF] = "MOTIF",
    [ITEMTYPE_RECIPE] = "RECIPE",
    [ITEMTYPE_CRAFTED_ABILITY_SCRIPT] = "SCRIPT",
    [ITEMTYPE_COLLECTIBLE] = "STYLE",
}

function HT_Knowledge.IsInterestingItem(bagId, slotIndex)
    local itemType = GetItemType(bagId, slotIndex)
    if INTERESTING[itemType] then return true end
    
    local itemLink = GetItemLink(bagId, slotIndex)
    if itemLink then
        local name = GetItemLinkName(itemLink):lower()
        if name:find("blueprint") or name:find("diagram") or name:find("pattern") or 
           name:find("praxis") or name:find("formula") or name:find("design") or name:find("sketch") then
            return true
        end
    end
    return false
end

function HT_Knowledge.IsInterestingItemByLink(itemLink)
    if not itemLink or type(itemLink) ~= "string" or not itemLink:find("|H") then return false end
    local itemType = GetItemLinkItemType(itemLink)
    if INTERESTING[itemType] then return true end
    
    local name = GetItemLinkName(itemLink):lower()
    if name:find("blueprint") or name:find("diagram") or name:find("pattern") or 
       name:find("praxis") or name:find("formula") or name:find("design") or name:find("sketch") then
        return true
    end
    return false
end

function HT_Knowledge.GetCategory(link)
    if not link then return "UNKNOWN" end
    local itype, stype = GetItemLinkItemType(link)
    
    if itype == ITEMTYPE_RACIAL_STYLE_MOTIF then
        if stype == SPECIALIZED_ITEMTYPE_RACIAL_STYLE_MOTIF_BOOK then 
            return "MOTIF_BOOK"
        elseif stype == SPECIALIZED_ITEMTYPE_RACIAL_STYLE_MOTIF_CHAPTER then 
            return "MOTIF_CHAPTER"
        else 
            return "MOTIF" 
        end
    end
    
    if itype == ITEMTYPE_RECIPE then
        if stype == SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_FOOD or 
           stype == SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_DRINK or
           stype == SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_LEGENDARY_FOOD or
           stype == SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_LEGENDARY_DRINK then
            return "RECIPE"
        else
            return "PLAN"
        end
    end
    
    if itype == ITEMTYPE_CRAFTED_ABILITY_SCRIPT then 
        return "SCRIPT" 
    end
    
    if itype == ITEMTYPE_COLLECTIBLE then 
        return "STYLE" 
    end
    
    local name = GetItemLinkName(link):lower()
    if name:find("blueprint") or name:find("diagram") or name:find("pattern") or 
       name:find("praxis") or name:find("formula") or name:find("design") or name:find("sketch") then
        return "PLAN"
    end
    
    return "UNKNOWN"
end

function HT_Knowledge.GetLCKIdByCharacterName(charName)
    if not charName or charName == "None selected" then return nil end
    
    if HT_LAM and HT_LAM.TranslateToLCKId then
        local apiId = nil
        for i = 1, GetNumCharacters() do
            local name, _, _, _, _, _, id = GetCharacterInfo(i)
            if name == charName then
                apiId = tostring(id)
                break
            end
        end
        if apiId and apiId ~= "0" then
            return HT_LAM.TranslateToLCKId(apiId)
        end
    end
    
    if LCK and LCK.GetCharacterList then
        local charlist = LCK.GetCharacterList()
        for _, entry in ipairs(charlist) do
            if entry.name == charName then
                return tostring(entry.id)
            end
        end
    end
    return nil
end

function HT_Knowledge.IsKnownByChar(itemLink, charName)
    if not itemLink or not charName or charName == "None selected" then return false end

    if LCK and LCK.GetItemKnowledgeForCharacter then
        local lckId = HT_Knowledge.GetLCKIdByCharacterName(charName)
        if lckId then
            local knowledge = LCK.GetItemKnowledgeForCharacter(itemLink, nil, lckId)
            if knowledge == LCK.KNOWLEDGE_KNOWN then return true end
            if knowledge == LCK.KNOWLEDGE_UNKNOWN then return false end
        end
    end

    local currentChar = GetUnitName("player")
    if charName ~= currentChar then return false end

    local cat = HT_Knowledge.GetCategory(itemLink)
    if cat == "RECIPE" or cat == "PLAN" then
        return IsItemLinkRecipeKnown(itemLink)
    end
    if cat == "MOTIF" or cat == "MOTIF_CHAPTER" or cat == "MOTIF_BOOK" or cat == "STYLE" then
        return IsItemLinkBookKnown(itemLink)
    end
    return false
end

function HT_Knowledge.GetPriceLimit(cat)
    local serverKey = GetWorldName()
    local vars = HyboremTutor_Vars and HyboremTutor_Vars[serverKey]
    if not vars then
        if cat:find("MOTIF") then return 5000 end
        if cat == "RECIPE" then return 20000 end
        if cat == "PLAN" then return 3000 end
        if cat == "SCRIPT" then return 5000 end
        if cat == "STYLE" then return 10000 end
        return 0
    end
    if cat:find("MOTIF") then return vars.lM or 5000 end
    if cat == "RECIPE" then return vars.lR or 20000 end
    if cat == "PLAN" then return vars.lP or 3000 end
    if cat == "SCRIPT" then return vars.lS or 5000 end
    if cat == "STYLE" then return vars.lST or 10000 end
    return 0
end

function HT_Knowledge.HasPriority(cat, slot)
    local serverKey = GetWorldName()
    local vars = HyboremTutor_Vars and HyboremTutor_Vars[serverKey]
    if not vars then return false end
    local p = vars["p"..slot]
    if not p then return false end
    if cat:find("MOTIF") then return p.m == true end
    if cat == "RECIPE" then return p.r == true end
    if cat == "PLAN" then return p.p == true end
    return false
end

function HT_Knowledge.GetAllCharacters()
    local names = { "None selected" }
    local seen = {}
    
    if LCK and LCK.GetCharacterList then
        local list = LCK.GetCharacterList()
        if list and type(list) == "table" then
            for _, entry in ipairs(list) do
                if entry and entry.name and entry.name ~= "" then
                    if not seen[entry.name] then
                        seen[entry.name] = true
                        table.insert(names, entry.name)
                    end
                end
            end
            if #names > 1 then return names end
        end
    end
    
    for i = 1, GetNumCharacters() do
        local name = GetCharacterInfo(i)
        if name and name ~= "" then
            local cleanName = name:gsub(" %([MF]%)$", "")
            if not seen[cleanName] then
                seen[cleanName] = true
                table.insert(names, cleanName)
            end
        end
    end
    
    local current = GetUnitName("player")
    if current and current ~= "" and not seen[current] and not seen[current:gsub(" %([MF]%)$", "")] then
        table.insert(names, current)
    end
    
    return names
end