-- ESO Adventurer Suite
-- Endgame gear optimizer
local EPC = ESOProgressionCoach
EPC.GearOptimizer = EPC.GearOptimizer or {}
local G = EPC.GearOptimizer

G.PRESETS = {
    SINGLE_TARGET = { label = "SINGLE TARGET", frontTrait = "PRECISE", backTrait = "INFUSED", armorBias = "BALANCED" },
    AOE_TRASH = { label = "AOE / TRASH", frontTrait = "CHARGED", backTrait = "INFUSED", armorBias = "MEDIUM" },
    SOLO = { label = "SOLO", frontTrait = "PRECISE", backTrait = "INFUSED", armorBias = "SURVIVAL" },
    TRIAL = { label = "TRIAL", frontTrait = "PRECISE", backTrait = "INFUSED", armorBias = "BALANCED" },
}
G.PRESET_ORDER = { "SINGLE_TARGET", "AOE_TRASH", "SOLO", "TRIAL" }

function G:GetPreset()
    local key = tostring(EPC.saved and EPC.saved.gearOptimizerPreset or "TRIAL")
    if not self.PRESETS[key] then key = "TRIAL" end
    return key, self.PRESETS[key]
end

function G:SetPreset(key)
    key = tostring(key or "")
    if not self.PRESETS[key] or not EPC.saved then return false end
    EPC.saved.gearOptimizerPreset = key
    if EPC.Print then EPC:Print("Endgame Gear preset: " .. self.PRESETS[key].label) end
    return true
end

local function safe(fn, fallback, ...)
    if type(fn) ~= "function" then return fallback end
    local ok,a,b,c,d,e,f,g,h = pcall(fn, ...)
    if not ok then return fallback end
    return a,b,c,d,e,f,g,h
end
local function safeNumber(fn, fallback, ...)
    local value = safe(fn, fallback, ...)
    local number = tonumber(value)
    if number ~= nil then return number end
    return tonumber(fallback) or 0
end
local function lower(s) return string.lower(tostring(s or "")) end
local function same(a,b) return lower(a) == lower(b) and lower(a) ~= "" end

local BODY_SLOTS = {
    EQUIP_SLOT_HEAD, EQUIP_SLOT_CHEST, EQUIP_SLOT_SHOULDERS, EQUIP_SLOT_HAND,
    EQUIP_SLOT_WAIST, EQUIP_SLOT_LEGS, EQUIP_SLOT_FEET,
}
local EQUIP_TYPE_TO_SLOT = {
    [EQUIP_TYPE_HEAD]=EQUIP_SLOT_HEAD,[EQUIP_TYPE_CHEST]=EQUIP_SLOT_CHEST,
    [EQUIP_TYPE_SHOULDERS]=EQUIP_SLOT_SHOULDERS,[EQUIP_TYPE_HAND]=EQUIP_SLOT_HAND,
    [EQUIP_TYPE_WAIST]=EQUIP_SLOT_WAIST,[EQUIP_TYPE_LEGS]=EQUIP_SLOT_LEGS,
    [EQUIP_TYPE_FEET]=EQUIP_SLOT_FEET,[EQUIP_TYPE_NECK]=EQUIP_SLOT_NECK,
}

local SLOT_LABELS = {
    [EQUIP_SLOT_HEAD] = "Head",
    [EQUIP_SLOT_CHEST] = "Chest",
    [EQUIP_SLOT_SHOULDERS] = "Shoulders",
    [EQUIP_SLOT_HAND] = "Hands",
    [EQUIP_SLOT_WAIST] = "Waist",
    [EQUIP_SLOT_LEGS] = "Legs",
    [EQUIP_SLOT_FEET] = "Feet",
    [EQUIP_SLOT_NECK] = "Neck",
    [EQUIP_SLOT_RING1] = "Ring 1",
    [EQUIP_SLOT_RING2] = "Ring 2",
    [EQUIP_SLOT_MAIN_HAND] = "Front Bar",
    [EQUIP_SLOT_BACKUP_MAIN] = "Back Bar",
}

local function itemName(link)
    if not link or link == "" then return "Empty" end
    if type(GetItemLinkName) == "function" then
        local name = safe(GetItemLinkName, "", link)
        if name and name ~= "" then return tostring(name) end
    end
    return tostring(link)
end

function G:NotifyResult(message, isSuccess)
    message = tostring(message or "")
    if message == "" then return end
    if EPC and EPC.Print then EPC:Print(message) end
    if type(ZO_Alert) == "function" then
        local category = UI_ALERT_CATEGORY_ALERT or 1
        pcall(ZO_Alert, category, nil, message)
    end
end

function G:ScoreCurrentLoadout(profile, presetKey)
    profile = profile or self:GetProfile()
    presetKey = presetKey or select(1, self:GetPreset())
    local targetCounts = self:CollectWornSetCounts()
    local currentFrontType = type(GetItemWeaponType)=="function" and safe(GetItemWeaponType,WEAPONTYPE_NONE or 0,BAG_WORN,EQUIP_SLOT_MAIN_HAND) or nil
    local currentBackType = type(GetItemWeaponType)=="function" and safe(GetItemWeaponType,WEAPONTYPE_NONE or 0,BAG_WORN,EQUIP_SLOT_BACKUP_MAIN) or nil
    local slots = {
        EQUIP_SLOT_HEAD, EQUIP_SLOT_CHEST, EQUIP_SLOT_SHOULDERS, EQUIP_SLOT_HAND,
        EQUIP_SLOT_WAIST, EQUIP_SLOT_LEGS, EQUIP_SLOT_FEET, EQUIP_SLOT_NECK,
        EQUIP_SLOT_RING1, EQUIP_SLOT_RING2, EQUIP_SLOT_MAIN_HAND, EQUIP_SLOT_BACKUP_MAIN,
    }
    local total = 0
    for _,dest in ipairs(slots) do
        local bar = dest == EQUIP_SLOT_BACKUP_MAIN and "BACK" or "FRONT"
        local weaponType = dest == EQUIP_SLOT_BACKUP_MAIN and currentBackType or currentFrontType
        local score = self:ScoreItem(BAG_WORN,dest,dest,profile,targetCounts,weaponType,presetKey,bar)
        total = total + (tonumber(score) or 0)
    end
    return math.floor(total + 0.5)
end

function G:ReportVerifiedChanges(beforeLinks, beforeScore, requested, profile, presetKey, presetLabel)
    local confirmed = 0
    local details = {}
    for _,item in ipairs(requested or {}) do
        local dest = item.dest
        local before = beforeLinks[dest] or ""
        local after = safe(GetItemLink,"",BAG_WORN,dest,LINK_STYLE_DEFAULT or 0)
        if after ~= before and after ~= "" then
            confirmed = confirmed + 1
            details[#details+1] = string.format("%s: %s -> %s", SLOT_LABELS[dest] or ("Slot "..tostring(dest)), itemName(before), itemName(after))
        end
    end
    local afterScore = self:ScoreCurrentLoadout(profile,presetKey)
    local delta = afterScore - (tonumber(beforeScore) or 0)
    if confirmed > 0 then
        self:NotifyResult(string.format("GEAR UPDATED: %d change%s confirmed | Score %d -> %d (%+d)", confirmed, confirmed == 1 and "" or "s", tonumber(beforeScore) or 0, afterScore, delta), true)
        for _,line in ipairs(details) do if EPC and EPC.Print then EPC:Print("  " .. line) end end
    else
        self:NotifyResult(string.format("NO GEAR CHANGES CONFIRMED | Score %d -> %d", tonumber(beforeScore) or 0, afterScore), false)
        if EPC and EPC.Print then EPC:Print("Endgame Gear: ESO did not confirm any requested swaps. Check inventory space, locked items, and equipment restrictions.") end
    end
    if EPC and EPC.RequestRefresh then EPC:RequestRefresh("endgame-gear-verified") end
end

function G:GetProfile()
    local classId = safeNumber(GetUnitClassId, 0, "player")
    local mag = safeNumber(GetUnitPower, 0, "player", POWERTYPE_MAGICKA)
    local stam = safeNumber(GetUnitPower, 0, "player", POWERTYPE_STAMINA)
    local magicka = mag >= stam
    return {
        id = (classId == 2 and magicka) and "MAG_SORC_PVE" or (magicka and "MAGICKA_PVE" or "STAMINA_PVE"),
        classId = classId,
        magicka = magicka,
        label = (classId == 2 and magicka) and "Magicka Sorcerer PvE Endgame" or (magicka and "Magicka PvE Endgame" or "Stamina PvE Endgame"),
    }
end

function G:GetTargetSets()
    local result = {}
    if EPC.TargetBuild and type(EPC.TargetBuild.GetTargetSets) == "function" then
        for _,name in ipairs(EPC.TargetBuild:GetTargetSets() or {}) do
            if tostring(name or "") ~= "" then result[#result+1] = tostring(name) end
        end
    end
    return result
end

local function setNameFor(link)
    if type(GetItemLinkSetInfo) ~= "function" then return "" end
    local hasSet,name = safe(GetItemLinkSetInfo, false, link, true)
    return hasSet == true and tostring(name or "") or ""
end

local function effectiveItemLevel(bag, slot)
    local cp = safeNumber(GetItemRequiredChampionPoints, 0, bag, slot)
    local level = safeNumber(GetItemRequiredLevel, 0, bag, slot)
    if cp > 0 then return 50 + math.min(160,cp)/10 end
    return math.min(50,level)
end

local function traitScore(link, equipType, profile, presetKey, weaponBar)
    if type(GetItemLinkTraitInfo) ~= "function" then return 0 end
    local trait = safeNumber(GetItemLinkTraitInfo, ITEM_TRAIT_TYPE_NONE or 0, link)
    if equipType == EQUIP_TYPE_RING or equipType == EQUIP_TYPE_NECK then
        if trait == (ITEM_TRAIT_TYPE_JEWELRY_BLOODTHIRSTY or -1) then return presetKey == "SOLO" and 125 or 165 end
        if trait == (ITEM_TRAIT_TYPE_JEWELRY_INFUSED or -2) then return presetKey == "SOLO" and 145 or 125 end
        if trait == (ITEM_TRAIT_TYPE_JEWELRY_ARCANE or -3) and profile.magicka then return 70 end
        if trait == (ITEM_TRAIT_TYPE_JEWELRY_ROBUST or -4) and not profile.magicka then return 70 end
        return 10
    end
    local armorType = safeNumber(GetItemLinkArmorType, ARMORTYPE_NONE or 0, link)
    if armorType ~= (ARMORTYPE_NONE or 0) then
        if trait == (ITEM_TRAIT_TYPE_ARMOR_DIVINES or -10) then return presetKey == "SOLO" and 125 or 165 end
        if trait == (ITEM_TRAIT_TYPE_ARMOR_INFUSED or -11) then return presetKey == "SOLO" and 115 or 75 end
        if trait == (ITEM_TRAIT_TYPE_ARMOR_REINFORCED or -12) then return presetKey == "SOLO" and 80 or 10 end
        return 5
    end
    local wt = safeNumber(GetItemLinkWeaponType, WEAPONTYPE_NONE or 0, link)
    if wt ~= (WEAPONTYPE_NONE or 0) then
        local front = weaponBar ~= "BACK"
        if trait == (ITEM_TRAIT_TYPE_WEAPON_PRECISE or -20) then
            if presetKey == "AOE_TRASH" then return front and 115 or 70 end
            return front and 165 or 80
        end
        if trait == (ITEM_TRAIT_TYPE_WEAPON_INFUSED or -21) then return front and 105 or 175 end
        if trait == (ITEM_TRAIT_TYPE_WEAPON_CHARGED or -22) then return (presetKey == "AOE_TRASH" and front) and 170 or 105 end
        if trait == (ITEM_TRAIT_TYPE_WEAPON_NIRNHONED or -23) then return (presetKey == "AOE_TRASH" and front) and 135 or 95 end
        return 10
    end
    return 0
end

local function armorScore(link, profile, presetKey)
    local armorType = safeNumber(GetItemLinkArmorType, ARMORTYPE_NONE or 0, link)
    if armorType == (ARMORTYPE_NONE or 0) then return 0 end
    if profile.magicka then
        if presetKey == "AOE_TRASH" then
            if armorType == (ARMORTYPE_MEDIUM or -2) then return 80 end
            if armorType == (ARMORTYPE_LIGHT or -1) then return 65 end
        elseif presetKey == "SOLO" then
            if armorType == (ARMORTYPE_LIGHT or -1) then return 75 end
            if armorType == (ARMORTYPE_MEDIUM or -2) then return 60 end
            if armorType == (ARMORTYPE_HEAVY or -3) then return 35 end
        else
            if armorType == (ARMORTYPE_LIGHT or -1) then return 78 end
            if armorType == (ARMORTYPE_MEDIUM or -2) then return 72 end
        end
    else
        if armorType == (ARMORTYPE_MEDIUM or -2) then return 75 end
        if armorType == (ARMORTYPE_LIGHT or -1) then return 35 end
    end
    return 5
end

local function weaponScore(link, profile, currentWeaponType, presetKey, weaponBar)
    local wt = safeNumber(GetItemLinkWeaponType, WEAPONTYPE_NONE or 0, link)
    if wt == (WEAPONTYPE_NONE or 0) then return 0 end
    if currentWeaponType and currentWeaponType ~= (WEAPONTYPE_NONE or 0) and wt == currentWeaponType then return 165 end
    if profile.magicka then
        if presetKey == "AOE_TRASH" then
            if wt == (WEAPONTYPE_LIGHTNING_STAFF or -2) then return 145 end
            if wt == (WEAPONTYPE_FIRE_STAFF or -1) then return 125 end
        elseif presetKey == "SOLO" then
            if wt == (WEAPONTYPE_LIGHTNING_STAFF or -2) then return 138 end
            if wt == (WEAPONTYPE_FIRE_STAFF or -1) then return 128 end
        else
            if wt == (WEAPONTYPE_FIRE_STAFF or -1) then return 142 end
            if wt == (WEAPONTYPE_LIGHTNING_STAFF or -2) then return 130 end
        end
    end
    return 0
end

function G:ScoreItem(bag,slot,dest,profile,targetCounts,currentWeaponType,presetKey,weaponBar)
    local _,_,_,meets,locked,equipType,_,fq,dq = safe(GetItemInfo,nil,bag,slot)
    if not equipType or equipType == EQUIP_TYPE_INVALID or meets == false or locked == true then return nil end
    if type(IsItemPlayerLocked)=="function" and safe(IsItemPlayerLocked,false,bag,slot)==true then return nil end
    local link = safe(GetItemLink,"",bag,slot,LINK_STYLE_DEFAULT or 0)
    if link == "" then return nil end
    local quality = tonumber(fq) or tonumber(dq) or 0
    local score = effectiveItemLevel(bag,slot)*22 + quality*38
    score = score + traitScore(link,equipType,profile,presetKey,weaponBar) + armorScore(link,profile,presetKey) + weaponScore(link,profile,currentWeaponType,presetKey,weaponBar)
    local setName = setNameFor(link)
    for _,wanted in ipairs(self:GetTargetSets()) do
        if same(setName,wanted) then
            local current = targetCounts[lower(wanted)] or 0
            local setBase = (presetKey == "SOLO") and 820 or 1050
            score = score + setBase
            if current < 5 then score = score + ((presetKey == "SOLO") and 580 or 760) end
            if current == 4 then score = score + ((presetKey == "SOLO") and 760 or 1150) end
        end
    end
    return score,equipType,link,setName
end

function G:CollectWornSetCounts()
    local counts = {}
    local slots = {unpack(BODY_SLOTS)}
    slots[#slots+1]=EQUIP_SLOT_NECK; slots[#slots+1]=EQUIP_SLOT_RING1; slots[#slots+1]=EQUIP_SLOT_RING2
    slots[#slots+1]=EQUIP_SLOT_MAIN_HAND; slots[#slots+1]=EQUIP_SLOT_OFF_HAND
    slots[#slots+1]=EQUIP_SLOT_BACKUP_MAIN; slots[#slots+1]=EQUIP_SLOT_BACKUP_OFF
    for _,slot in ipairs(slots) do
        local link = safe(GetItemLink,"",BAG_WORN,slot,LINK_STYLE_DEFAULT or 0)
        if link ~= "" then
            local n = setNameFor(link)
            if n ~= "" then counts[lower(n)] = (counts[lower(n)] or 0) + 1 end
        end
    end
    return counts
end

function G:GetWornScore(slot,profile,targetCounts,currentWeaponType,presetKey,weaponBar)
    local score = self:ScoreItem(BAG_WORN,slot,slot,profile,targetCounts,currentWeaponType,presetKey,weaponBar)
    return tonumber(score) or -1
end

function G:BuildPlan()
    local plan,best,rings,frontWeapons,backWeapons = {},{}, {}, {}, {}
    if not BAG_BACKPACK or type(GetBagSize)~="function" then return plan end
    local profile = self:GetProfile()
    local presetKey = select(1, self:GetPreset())
    local targetCounts = self:CollectWornSetCounts()
    local currentFrontType = type(GetItemWeaponType)=="function" and safe(GetItemWeaponType,WEAPONTYPE_NONE or 0,BAG_WORN,EQUIP_SLOT_MAIN_HAND) or nil
    local currentBackType = type(GetItemWeaponType)=="function" and safe(GetItemWeaponType,WEAPONTYPE_NONE or 0,BAG_WORN,EQUIP_SLOT_BACKUP_MAIN) or nil

    -- The currently equipped loadout is the optimizer baseline. A worn piece is
    -- never replaced just because something exists in the backpack; a backpack
    -- candidate has to beat the equipped piece for the selected endgame preset.
    local fixedSlots = {
        EQUIP_SLOT_HEAD, EQUIP_SLOT_CHEST, EQUIP_SLOT_SHOULDERS, EQUIP_SLOT_HAND,
        EQUIP_SLOT_WAIST, EQUIP_SLOT_LEGS, EQUIP_SLOT_FEET, EQUIP_SLOT_NECK,
    }
    for _,dest in ipairs(fixedSlots) do
        local score,equipType,link,setName = self:ScoreItem(BAG_WORN,dest,dest,profile,targetCounts,currentFrontType,presetKey,"FRONT")
        if score then
            best[dest] = {bag=BAG_WORN,slot=dest,dest=dest,score=score,equipType=equipType,link=link,setName=setName,worn=true}
        end
    end

    -- Rings are evaluated as a two-slot pool so a strong ring you already wear
    -- remains eligible alongside every ring in the backpack.
    for _,dest in ipairs({EQUIP_SLOT_RING1,EQUIP_SLOT_RING2}) do
        local score,equipType,link,setName = self:ScoreItem(BAG_WORN,dest,dest,profile,targetCounts,currentFrontType,presetKey,"FRONT")
        if score then rings[#rings+1] = {bag=BAG_WORN,slot=dest,dest=dest,score=score,equipType=equipType,link=link,setName=setName,worn=true} end
    end

    -- Front/back weapons each start with what is actually equipped on that bar.
    local frontScore,frontEquip,frontLink,frontSet = self:ScoreItem(BAG_WORN,EQUIP_SLOT_MAIN_HAND,EQUIP_SLOT_MAIN_HAND,profile,targetCounts,currentFrontType,presetKey,"FRONT")
    if frontScore then frontWeapons[#frontWeapons+1] = {bag=BAG_WORN,slot=EQUIP_SLOT_MAIN_HAND,dest=EQUIP_SLOT_MAIN_HAND,score=frontScore,equipType=frontEquip,link=frontLink,setName=frontSet,worn=true} end
    local backScore,backEquip,backLink,backSet = self:ScoreItem(BAG_WORN,EQUIP_SLOT_BACKUP_MAIN,EQUIP_SLOT_BACKUP_MAIN,profile,targetCounts,currentBackType,presetKey,"BACK")
    if backScore then backWeapons[#backWeapons+1] = {bag=BAG_WORN,slot=EQUIP_SLOT_BACKUP_MAIN,dest=EQUIP_SLOT_BACKUP_MAIN,score=backScore,equipType=backEquip,link=backLink,setName=backSet,worn=true} end

    local count = safeNumber(GetBagSize, 0, BAG_BACKPACK)
    local evaluated = 0
    for slot=0,count-1 do
        local score,equipType,link,setName = self:ScoreItem(BAG_BACKPACK,slot,nil,profile,targetCounts,currentFrontType,presetKey,"FRONT")
        if score then
            evaluated = evaluated + 1
            local c={bag=BAG_BACKPACK,slot=slot,score=score,equipType=equipType,link=link,setName=setName,worn=false}
            if equipType==EQUIP_TYPE_RING then
                rings[#rings+1]=c
            elseif equipType==EQUIP_TYPE_MAIN_HAND or equipType==EQUIP_TYPE_ONE_HAND or equipType==EQUIP_TYPE_TWO_HAND or equipType==EQUIP_TYPE_OFF_HAND then
                local fs = select(1,self:ScoreItem(BAG_BACKPACK,slot,nil,profile,targetCounts,currentFrontType,presetKey,"FRONT")) or -1
                local bs = select(1,self:ScoreItem(BAG_BACKPACK,slot,nil,profile,targetCounts,currentBackType,presetKey,"BACK")) or -1
                frontWeapons[#frontWeapons+1]={bag=BAG_BACKPACK,slot=slot,score=fs,equipType=equipType,link=link,setName=setName,worn=false}
                backWeapons[#backWeapons+1]={bag=BAG_BACKPACK,slot=slot,score=bs,equipType=equipType,link=link,setName=setName,worn=false}
            else
                local dest=EQUIP_TYPE_TO_SLOT[equipType]
                local current=dest and best[dest] or nil
                if dest and (not current or score > current.score + 30) then best[dest]=c end
            end
        end
    end

    for dest,c in pairs(best) do
        if c.bag ~= BAG_WORN then c.dest=dest; plan[#plan+1]=c end
    end

    table.sort(rings,function(a,b) return a.score>b.score end)
    local chosen={}
    for _,c in ipairs(rings) do
        if #chosen>=2 then break end
        local duplicate=false
        for _,picked in ipairs(chosen) do
            if picked.bag==c.bag and picked.slot==c.slot then duplicate=true break end
        end
        if not duplicate then chosen[#chosen+1]=c end
    end
    local occupied={}
    for _,c in ipairs(chosen) do if c.worn and c.dest then occupied[c.dest]=true end end
    local openSlots={}
    for _,dest in ipairs({EQUIP_SLOT_RING1,EQUIP_SLOT_RING2}) do if not occupied[dest] then openSlots[#openSlots+1]=dest end end
    table.sort(openSlots,function(a,b)
        return self:GetWornScore(a,profile,targetCounts,currentFrontType,presetKey,"FRONT") < self:GetWornScore(b,profile,targetCounts,currentFrontType,presetKey,"FRONT")
    end)
    local openIndex=1
    for _,c in ipairs(chosen) do
        if not c.worn and openSlots[openIndex] then c.dest=openSlots[openIndex]; plan[#plan+1]=c; openIndex=openIndex+1 end
    end

    table.sort(frontWeapons,function(a,b) return a.score>b.score end)
    table.sort(backWeapons,function(a,b) return a.score>b.score end)
    local bestFront=frontWeapons[1]
    local usedBackpackSlot=nil
    if bestFront and not bestFront.worn then
        bestFront.dest=EQUIP_SLOT_MAIN_HAND; plan[#plan+1]=bestFront; usedBackpackSlot=bestFront.slot
    end
    local bestBack=nil
    for _,c in ipairs(backWeapons) do
        if c.worn or c.slot~=usedBackpackSlot then bestBack=c break end
    end
    if bestBack and not bestBack.worn then bestBack.dest=EQUIP_SLOT_BACKUP_MAIN; plan[#plan+1]=bestBack end

    table.sort(plan,function(a,b) return a.score>b.score end)
    self.lastProfile=profile
    self.lastPreset=presetKey
    self.lastBackpackCandidates=evaluated
    return plan
end

function G:EquipBestArmorWeight(weightKey)
    if safe(IsUnitInCombat,false,"player") == true then
        self:NotifyResult("Best Armor: leave combat before changing equipment.", false)
        return false
    end
    if type(RequestEquipItem) ~= "function" or not BAG_BACKPACK then
        self:NotifyResult("Best Armor: ESO's equipment API is unavailable.", false)
        return false
    end
    local wanted = {
        LIGHT = ARMORTYPE_LIGHT,
        MEDIUM = ARMORTYPE_MEDIUM,
        HEAVY = ARMORTYPE_HEAVY,
    }
    local armorType = wanted[string.upper(tostring(weightKey or ""))]
    if armorType == nil then return false end

    local profile = self:GetProfile()
    local presetKey = select(1, self:GetPreset())
    local targetCounts = self:CollectWornSetCounts()
    local best = {}
    local beforeLinks = {}
    for _, dest in ipairs(BODY_SLOTS) do
        beforeLinks[dest] = safe(GetItemLink,"",BAG_WORN,dest,LINK_STYLE_DEFAULT or 0)
        local currentLink = beforeLinks[dest]
        if currentLink ~= "" and safeNumber(GetItemLinkArmorType, ARMORTYPE_NONE or 0, currentLink) == armorType then
            local score,equipType,link,setName = self:ScoreItem(BAG_WORN,dest,dest,profile,targetCounts,nil,presetKey,"FRONT")
            if score then best[dest] = {bag=BAG_WORN,slot=dest,dest=dest,score=score,link=link,worn=true} end
        end
    end

    local count = safeNumber(GetBagSize, 0, BAG_BACKPACK)
    for slot=0,count-1 do
        local link = safe(GetItemLink,"",BAG_BACKPACK,slot,LINK_STYLE_DEFAULT or 0)
        if link ~= "" and safeNumber(GetItemLinkArmorType, ARMORTYPE_NONE or 0, link) == armorType then
            local score,equipType = self:ScoreItem(BAG_BACKPACK,slot,nil,profile,targetCounts,nil,presetKey,"FRONT")
            local dest = equipType and EQUIP_TYPE_TO_SLOT[equipType] or nil
            if score and dest and (not best[dest] or score > best[dest].score) then
                best[dest] = {bag=BAG_BACKPACK,slot=slot,dest=dest,score=score,link=link,worn=false}
            end
        end
    end

    local requested = {}
    for _,dest in ipairs(BODY_SLOTS) do
        local item = best[dest]
        if item and not item.worn then
            if pcall(RequestEquipItem,item.bag,item.slot,BAG_WORN,dest) then
                requested[#requested+1] = {dest=dest, expected=item.link}
            end
        end
    end
    if #requested == 0 then
        self:NotifyResult("BEST " .. string.upper(tostring(weightKey)) .. ": no armor upgrades found in backpack.", false)
        return false
    end
    self:NotifyResult(string.format("BEST %s: requested %d armor change%s.", string.upper(tostring(weightKey)), #requested, #requested == 1 and "" or "s"), true)
    if type(zo_callLater) == "function" then
        zo_callLater(function()
            local confirmed = 0
            for _,item in ipairs(requested) do
                local after = safe(GetItemLink,"",BAG_WORN,item.dest,LINK_STYLE_DEFAULT or 0)
                if after ~= "" and after ~= beforeLinks[item.dest] then confirmed = confirmed + 1 end
            end
            self:NotifyResult(string.format("BEST %s: %d/%d change%s confirmed.", string.upper(tostring(weightKey)), confirmed, #requested, #requested == 1 and "" or "s"), confirmed > 0)
            if EPC and EPC.RequestRefresh then EPC:RequestRefresh("best-armor-weight") end
        end, 900)
    end
    return true
end

function G:EquipBestRecommended()
    if safe(IsUnitInCombat,false,"player")==true then self:NotifyResult("Endgame Gear: leave combat before changing equipment.", false); return false end
    if type(RequestEquipItem)~="function" then self:NotifyResult("Endgame Gear: ESO's equipment API is unavailable.", false); return false end
    local profile=self:GetProfile()
    local targets=self:GetTargetSets()
    local presetKey,preset = self:GetPreset()
    local minimumTargets = presetKey == "SOLO" and 1 or 2
    if #targets<minimumTargets then
        self:NotifyResult("Endgame Gear: configure " .. tostring(minimumTargets) .. " Target Set" .. (minimumTargets == 1 and "" or "s") .. " first so the optimizer can preserve complete set bonuses.", false)
        return false
    end
    local beforeScore = self:ScoreCurrentLoadout(profile,presetKey)
    local plan=self:BuildPlan()
    if #plan==0 then
        self:NotifyResult(string.format("NO UPGRADES FOUND | Current score: %d", beforeScore), false)
        if EPC and EPC.Print then EPC:Print("Endgame Gear: your current loadout is already the best configuration I can build from worn + backpack gear for "..profile.label.." ["..preset.label.."].") end
        return false
    end

    local beforeLinks = {}
    local requested = {}
    local equipped=0
    for _,item in ipairs(plan) do
        beforeLinks[item.dest] = safe(GetItemLink,"",BAG_WORN,item.dest,LINK_STYLE_DEFAULT or 0)
        if pcall(RequestEquipItem,item.bag,item.slot,BAG_WORN,item.dest) then
            equipped=equipped+1
            requested[#requested+1] = {dest=item.dest, expected=item.link}
        end
    end
    if equipped>0 then
        self:NotifyResult(string.format("GEAR OPTIMIZER: requested %d change%s...", equipped, equipped==1 and "" or "s"), true)
        if type(zo_callLater) == "function" then
            zo_callLater(function()
                self:ReportVerifiedChanges(beforeLinks,beforeScore,requested,profile,presetKey,preset.label)
            end, 900)
        else
            self:ReportVerifiedChanges(beforeLinks,beforeScore,requested,profile,presetKey,preset.label)
        end
        return true
    end
    self:NotifyResult("Endgame Gear: ESO did not accept the equipment changes.", false)
    return false
end


local function isWeaponDestination(dest)
    return dest == EQUIP_SLOT_MAIN_HAND or dest == EQUIP_SLOT_OFF_HAND or dest == EQUIP_SLOT_BACKUP_MAIN or dest == EQUIP_SLOT_BACKUP_OFF
end

local function isJewelryDestination(dest)
    return dest == EQUIP_SLOT_NECK or dest == EQUIP_SLOT_RING1 or dest == EQUIP_SLOT_RING2
end

function G:EquipPlanSubset(label, predicate)
    if safe(IsUnitInCombat,false,"player") == true then
        self:NotifyResult(label .. ": leave combat before changing the loadout.", false)
        return false
    end
    if type(RequestEquipItem) ~= "function" then
        self:NotifyResult(label .. ": ESO's equipment API is unavailable.", false)
        return false
    end
    local plan = self:BuildPlan()
    local requested = {}
    local beforeLinks = {}
    for _,item in ipairs(plan or {}) do
        if predicate(item.dest, item) then
            beforeLinks[item.dest] = safe(GetItemLink,"",BAG_WORN,item.dest,LINK_STYLE_DEFAULT or 0)
            if pcall(RequestEquipItem,item.bag,item.slot,BAG_WORN,item.dest) then
                requested[#requested+1] = {dest=item.dest, expected=item.link}
            end
        end
    end
    if #requested == 0 then
        self:NotifyResult(label .. ": no upgrades found in worn + backpack gear.", false)
        return false
    end
    self:NotifyResult(string.format("%s: requested %d change%s.", label, #requested, #requested == 1 and "" or "s"), true)
    if type(zo_callLater) == "function" then
        zo_callLater(function()
            local confirmed = 0
            for _,item in ipairs(requested) do
                local after = safe(GetItemLink,"",BAG_WORN,item.dest,LINK_STYLE_DEFAULT or 0)
                if after ~= "" and after ~= beforeLinks[item.dest] then confirmed = confirmed + 1 end
            end
            self:NotifyResult(string.format("%s: %d/%d change%s confirmed.", label, confirmed, #requested, #requested == 1 and "" or "s"), confirmed > 0)
            if EPC and EPC.RequestRefresh then EPC:RequestRefresh("best-loadout-subset") end
        end, 900)
    end
    return true
end

function G:EquipBestWeapons()
    return self:EquipPlanSubset("BEST WEAPONS", function(dest) return isWeaponDestination(dest) end)
end

function G:EquipBestJewelry()
    return self:EquipPlanSubset("BEST JEWELRY", function(dest) return isJewelryDestination(dest) end)
end

local function containsAny(text, words)
    text = lower(text)
    for _,word in ipairs(words or {}) do
        if string.find(text, lower(word), 1, true) then return true end
    end
    return false
end

function G:CollectPurchasedActiveAbilities()
    local out = {}
    if type(GetNumSkillTypes) ~= "function" or type(GetNumSkillLines) ~= "function" or type(GetNumSkillAbilities) ~= "function" or type(GetSkillAbilityInfo) ~= "function" then
        return out
    end
    for skillType=1,safeNumber(GetNumSkillTypes,0) do
        for skillLine=1,safeNumber(GetNumSkillLines,0,skillType) do
            local count = safeNumber(GetNumSkillAbilities,0,skillType,skillLine)
            for skillIndex=1,count do
                local skipCrafted = type(IsCraftedAbilitySkill) == "function" and safe(IsCraftedAbilitySkill,false,skillType,skillLine,skillIndex) == true
                if not skipCrafted then
                    local name,texture,earnedRank,passive,ultimate,purchased,progressionIndex,rank = safe(GetSkillAbilityInfo,nil,skillType,skillLine,skillIndex)
                    if purchased == true and passive ~= true and name and name ~= "" then
                        local abilityName = tostring(name)
                        local abilityIndex = nil
                        local abilityId = type(GetSkillAbilityId) == "function" and safeNumber(GetSkillAbilityId,0,skillType,skillLine,skillIndex,false) or 0
                        if progressionIndex and type(GetAbilityProgressionInfo) == "function" and type(GetAbilityProgressionAbilityInfo) == "function" then
                            local _,morphChoice,currentRank = safe(GetAbilityProgressionInfo,nil,progressionIndex)
                            local morphedName,_,idx = safe(GetAbilityProgressionAbilityInfo,nil,progressionIndex,tonumber(morphChoice) or 0,tonumber(currentRank) or tonumber(rank) or 1)
                            if morphedName and morphedName ~= "" then abilityName = tostring(morphedName) end
                            abilityIndex = tonumber(idx)
                        end
                        if (not abilityIndex or abilityIndex <= 0) and abilityId > 0 and type(GetAbilityIndex) == "function" then
                            abilityIndex = safeNumber(GetAbilityIndex,0,abilityId)
                        end
                        if abilityIndex and abilityIndex > 0 then
                            out[#out+1] = {
                                name=abilityName, abilityIndex=abilityIndex, abilityId=abilityId,
                                ultimate=ultimate == true, skillType=skillType, skillLine=skillLine,
                            }
                        end
                    end
                end
            end
        end
    end
    return out
end

local SORC_MAG_PRIORITY = {
    {"Crystal Fragments","Crystal Shard"},
    {"Daedric Prey","Haunting Curse","Daedric Curse"},
    {"Volatile Familiar","Unstable Familiar"},
    {"Twilight Tormentor","Twilight Matriarch","Winged Twilight"},
    {"Barbed Trap","Bound Aegis","Critical Surge","Unstable Wall of Elements","Elemental Blockade"},
}
local SORC_MAG_ULTIMATES = {"Greater Storm Atronach","Summon Charged Atronach","Summon Storm Atronach","Power Overload","Energy Overload","Overload"}

function G:ScoreFallbackAbility(a, profile)
    local score = 0
    local n = lower(a.name)
    if a.skillType == SKILL_TYPE_CLASS then score = score + 500 end
    if a.skillType == SKILL_TYPE_WEAPON then score = score + 260 end
    if a.skillType == SKILL_TYPE_GUILD then score = score + 120 end
    if profile.magicka then
        if containsAny(n,{"crystal","curse","prey","familiar","twilight","wall","surge","mage","orb","trap"}) then score=score+360 end
        if containsAny(n,{"stamina","poison","bow","dual wield"}) then score=score-120 end
    else
        if containsAny(n,{"weapon","poison","trap","blade","bow","stamina"}) then score=score+300 end
    end
    return score
end


function G:GetWornBuildContext()
    local profile = self:GetProfile()
    local role = EPC.Role and EPC.Role:GetRole() or "DAMAGE"
    local sets = {}
    local seen = {}
    if type(GetItemLink) == "function" then
        local slots = {
            EQUIP_SLOT_HEAD, EQUIP_SLOT_CHEST, EQUIP_SLOT_SHOULDERS, EQUIP_SLOT_HAND,
            EQUIP_SLOT_WAIST, EQUIP_SLOT_LEGS, EQUIP_SLOT_FEET, EQUIP_SLOT_NECK,
            EQUIP_SLOT_RING1, EQUIP_SLOT_RING2, EQUIP_SLOT_MAIN_HAND, EQUIP_SLOT_BACKUP_MAIN,
        }
        for _,slot in ipairs(slots) do
            local link = safe(GetItemLink,"",BAG_WORN,slot,LINK_STYLE_DEFAULT or 0)
            local setName = setNameFor(link)
            if setName ~= "" and not seen[setName] then
                seen[setName] = true
                sets[#sets+1] = setName
            end
        end
    end
    table.sort(sets,function(a,b) return lower(a) < lower(b) end)
    local frontType = type(GetItemWeaponType)=="function" and safe(GetItemWeaponType,WEAPONTYPE_NONE or 0,BAG_WORN,EQUIP_SLOT_MAIN_HAND) or 0
    local backType = type(GetItemWeaponType)=="function" and safe(GetItemWeaponType,WEAPONTYPE_NONE or 0,BAG_WORN,EQUIP_SLOT_BACKUP_MAIN) or 0
    local function weaponLabel(w)
        if w == (WEAPONTYPE_FIRE_STAFF or -101) then return "Inferno Staff" end
        if w == (WEAPONTYPE_FROST_STAFF or -102) then return "Ice Staff" end
        if w == (WEAPONTYPE_LIGHTNING_STAFF or -103) then return "Lightning Staff" end
        if w == (WEAPONTYPE_HEALING_STAFF or -104) then return "Restoration Staff" end
        if w == (WEAPONTYPE_BOW or -105) then return "Bow" end
        if w == (WEAPONTYPE_DUAL_WIELD or -106) then return "Dual Wield" end
        if w == (WEAPONTYPE_TWO_HANDED_SWORD or -107) or w == (WEAPONTYPE_TWO_HANDED_AXE or -108) or w == (WEAPONTYPE_TWO_HANDED_HAMMER or -109) then return "Two Handed" end
        if w == (WEAPONTYPE_ONE_HAND_AND_SHIELD or -110) then return "One Hand + Shield" end
        return "Weapon"
    end
    return {
        profile=profile, role=role, sets=sets, frontWeaponType=frontType, backWeaponType=backType,
        frontWeapon=weaponLabel(frontType), backWeapon=weaponLabel(backType),
    }
end

function G:ScoreAbilityForCurrentBuild(a, context)
    local profile = context.profile or self:GetProfile()
    local role = context.role or "DAMAGE"
    local score = self:ScoreFallbackAbility(a, profile)
    local n = lower(a.name)
    local setText = lower(table.concat(context.sets or {}, " "))

    if role == "HEALER" then
        if containsAny(n,{"heal","healing","regeneration","ward","ritual","orb","prayer","combat prayer","matriarch"}) then score=score+700 end
        if a.skillType == SKILL_TYPE_WEAPON and (context.frontWeapon == "Restoration Staff" or context.backWeapon == "Restoration Staff") then score=score+220 end
        if containsAny(n,{"taunt","puncture"}) then score=score-260 end
    elseif role == "TANK" then
        if containsAny(n,{"taunt","puncture","armor","ward","shield","resolve","dark deal","vigor","block"}) then score=score+700 end
        if context.frontWeapon == "One Hand + Shield" or context.backWeapon == "One Hand + Shield" then
            if a.skillType == SKILL_TYPE_WEAPON then score=score+260 end
        end
        if containsAny(n,{"execute","spammable"}) then score=score-100 end
    else
        if containsAny(n,{"crystal fragments","daedric prey","haunting curse","barbed trap","wall of elements","elemental blockade","critical surge","bound aegis"}) then score=score+520 end
        if profile.magicka and (context.frontWeapon == "Inferno Staff" or context.frontWeapon == "Lightning Staff" or context.backWeapon == "Inferno Staff" or context.backWeapon == "Lightning Staff") then
            if containsAny(n,{"wall of elements","elemental blockade","force pulse","crushing shock"}) then score=score+320 end
        end
    end

    -- Light set-synergy signals. These do not hard-code one meta; they bias toward
    -- skills that make sense with common damage/support themes in the worn sets.
    if containsAny(setText,{"orders wrath","law of julianos","new moon acolyte","mother's sorrow","medusa"}) then
        if containsAny(n,{"crystal","curse","prey","trap","wall","surge","familiar","twilight"}) then score=score+180 end
    end
    if containsAny(setText,{"healer","spell power cure","olorime","roaring opportunist"}) and role == "HEALER" then
        if containsAny(n,{"heal","prayer","regeneration","orb","matriarch"}) then score=score+180 end
    end
    return score
end

function G:BuildBestAbilityView()
    local context = self:GetWornBuildContext()
    local pool = self:CollectPurchasedActiveAbilities()
    local normal, ults = {}, {}
    for _,a in ipairs(pool) do
        local entry = {ability=a, score=self:ScoreAbilityForCurrentBuild(a, context)}
        if a.ultimate then ults[#ults+1]=entry else normal[#normal+1]=entry end
    end
    local sorter = function(x,y)
        if x.score == y.score then return lower(x.ability.name) < lower(y.ability.name) end
        return x.score > y.score
    end
    table.sort(normal, sorter)
    table.sort(ults, sorter)
    local chosen = {}
    for i=1,math.min(5,#normal) do chosen[#chosen+1]=normal[i].ability end
    local ultimate = ults[1] and ults[1].ability or nil
    return {context=context, abilities=chosen, ultimate=ultimate, purchased=#pool}
end

function G:ChooseBestAbilities()
    local view = self:BuildBestAbilityView()
    return view.abilities or {}, view.ultimate
end

function G:EquipBestAbilities()
    if safe(IsUnitInCombat,false,"player") == true then
        self:NotifyResult("BEST ABILITIES: leave combat before changing action-bar skills.", false)
        return false
    end
    if type(CallSecureProtected) ~= "function" then
        self:NotifyResult("BEST ABILITIES: ESO's secure slot API is unavailable.", false)
        return false
    end
    local chosen,ultimate = self:ChooseBestAbilities()
    if #chosen == 0 then
        self:NotifyResult("BEST ABILITIES: no purchased active abilities were available to slot.", false)
        return false
    end
    local first = tonumber(ACTION_BAR_FIRST_NORMAL_SLOT_INDEX) or 3
    local ultimateSlot = tonumber(ACTION_BAR_ULTIMATE_SLOT_INDEX) or (first + 5)
    local successCount = 0
    for i=1,math.min(5,#chosen) do
        local ok,result = pcall(CallSecureProtected,"SelectSlotAbility",chosen[i].abilityIndex,first+i-1)
        if ok and result ~= false then successCount=successCount+1 end
    end
    if ultimate then
        local ok,result = pcall(CallSecureProtected,"SelectSlotAbility",ultimate.abilityIndex,ultimateSlot)
        if ok and result ~= false then successCount=successCount+1 end
    end
    if successCount == 0 then
        self:NotifyResult("BEST ABILITIES: ESO did not accept the requested bar changes. Make sure you are out of combat and not in UI lockdown.", false)
        return false
    end
    local names={}
    for i,a in ipairs(chosen) do if i<=5 then names[#names+1]=tostring(i).."="..a.name end end
    if ultimate then names[#names+1]="ULT="..ultimate.name end
    self:NotifyResult("BEST ABILITIES: "..table.concat(names," | "), true)
    if EPC and EPC.AbilityOverlays and EPC.AbilityOverlays.Refresh then EPC.AbilityOverlays:Refresh() end
    return true
end


-- Full current-build skill respec / rebuild (v0.25.53)
-- Uses ESO's native full allocation request so the change is one user-initiated
-- transaction.  The planner intentionally spends points only on combat-relevant
-- skills; surplus points remain available for crafting or personal preferences.
function G:GetTotalSkillPointBudget()
    local available = type(GetAvailableSkillPoints) == "function" and safeNumber(GetAvailableSkillPoints,0) or 0
    local allocated = 0
    local mgr = rawget(_G,"SKILL_POINT_ALLOCATION_MANAGER")
    if mgr and type(mgr.GetNumPointsAllocatedInSkillLine) == "function" and type(GetNumSkillTypes) == "function" and type(GetNumSkillLines) == "function" then
        for skillType=1,safeNumber(GetNumSkillTypes,0) do
            for skillLine=1,safeNumber(GetNumSkillLines,0,skillType) do
                local ok,value = pcall(mgr.GetNumPointsAllocatedInSkillLine,mgr,skillType,skillLine)
                if ok then allocated = allocated + (tonumber(value) or 0) end
            end
        end
    end
    -- Fallback for clients where the allocation manager method signature differs.
    if allocated <= 0 and type(GetNumSkillTypes) == "function" and type(GetNumSkillLines) == "function" and type(GetNumSkillAbilities) == "function" then
        for skillType=1,safeNumber(GetNumSkillTypes,0) do
            for skillLine=1,safeNumber(GetNumSkillLines,0,skillType) do
                for skillIndex=1,safeNumber(GetNumSkillAbilities,0,skillType,skillLine) do
                    local _,_,_,passive,_,purchased,progressionIndex,rank = safe(GetSkillAbilityInfo,nil,skillType,skillLine,skillIndex)
                    if purchased == true then
                        if passive == true then allocated = allocated + math.max(1,tonumber(rank) or 1)
                        else
                            allocated = allocated + 1
                            if progressionIndex and type(GetAbilityProgressionInfo) == "function" then
                                local _,morphChoice = safe(GetAbilityProgressionInfo,nil,progressionIndex)
                                if (tonumber(morphChoice) or 0) > 0 then allocated = allocated + 1 end
                            end
                        end
                    end
                end
            end
        end
    end
    return math.max(0,available + allocated), available, allocated
end

function G:ScorePassiveForCurrentBuild(entry, context)
    local n = lower(entry.name or "")
    local role = context.role or "DAMAGE"
    local profile = context.profile or self:GetProfile()
    local score = 0
    if entry.skillType == SKILL_TYPE_CLASS then score = score + 820
    elseif entry.skillType == SKILL_TYPE_RACIAL then score = score + 760
    elseif entry.skillType == SKILL_TYPE_WEAPON then score = score + 580
    elseif entry.skillType == SKILL_TYPE_ARMOR then score = score + 500
    elseif entry.skillType == SKILL_TYPE_GUILD then score = score + 300
    elseif entry.skillType == SKILL_TYPE_WORLD then score = score + 180
    elseif entry.skillType == SKILL_TYPE_AVA then score = score + 140
    elseif entry.skillType == SKILL_TYPE_TRADESKILL then score = score - 1400 end

    if role == "TANK" then
        if containsAny(n,{"health","armor","resist","block","shield","stamina","constitution","heavy"}) then score=score+600 end
        if containsAny(n,{"healing received","mitigation","defense"}) then score=score+420 end
    elseif role == "HEALER" then
        if containsAny(n,{"heal","healing","magicka","recovery","restoration","support","spell","critical"}) then score=score+560 end
        if containsAny(n,{"damage done"}) then score=score+80 end
    else
        if profile.magicka then
            if containsAny(n,{"magicka","spell","critical","penetration","recovery","damage","light armor","elemental"}) then score=score+560 end
            if containsAny(n,{"stamina cost","bow","dual wield"}) then score=score-180 end
        else
            if containsAny(n,{"stamina","weapon","critical","penetration","recovery","damage","medium armor","martial"}) then score=score+560 end
            if containsAny(n,{"magicka cost"}) then score=score-120 end
        end
    end
    return score
end

local function easAbilityNameById(id, fallback)
    if tonumber(id) and tonumber(id) > 0 and type(GetAbilityName) == "function" then
        local name = safe(GetAbilityName,"",tonumber(id))
        if name and name ~= "" then return tostring(name) end
    end
    return tostring(fallback or "")
end

function G:ChooseBuildMorph(skillType,skillLine,skillIndex,progressionId,context,currentMorph,canMorph)
    local base = rawget(_G,"MORPH_SLOT_BASE") or 0
    local m1 = rawget(_G,"MORPH_SLOT_MORPH_1") or 1
    local m2 = rawget(_G,"MORPH_SLOT_MORPH_2") or 2
    if not progressionId or progressionId <= 0 or type(GetProgressionSkillMorphSlotAbilityId) ~= "function" then
        return base, type(GetSkillAbilityId)=="function" and safeNumber(GetSkillAbilityId,0,skillType,skillLine,skillIndex,false) or 0
    end
    -- Only spend the extra point on a morph when ESO reports that the
    -- progression has actually reached the morph point. Existing morphs may
    -- still be changed during a full respec.
    if canMorph ~= true and (tonumber(currentMorph) or base) == base then
        local baseId = safeNumber(GetProgressionSkillMorphSlotAbilityId,0,progressionId,base)
        if baseId <= 0 and type(GetSkillAbilityId)=="function" then
            baseId = safeNumber(GetSkillAbilityId,0,skillType,skillLine,skillIndex,false)
        end
        return base,baseId
    end
    local id1 = safeNumber(GetProgressionSkillMorphSlotAbilityId,0,progressionId,m1)
    local id2 = safeNumber(GetProgressionSkillMorphSlotAbilityId,0,progressionId,m2)
    if id1 <= 0 and id2 <= 0 then
        local baseId = safeNumber(GetProgressionSkillMorphSlotAbilityId,0,progressionId,base)
        return base,baseId
    end
    local function morphScore(id,slot)
        if id <= 0 then return -100000 end
        local pseudo={name=easAbilityNameById(id,""),skillType=skillType,skillLine=skillLine,ultimate=false}
        local score=self:ScoreAbilityForCurrentBuild(pseudo,context)
        if slot == currentMorph then score=score+25 end
        return score
    end
    local s1,s2=morphScore(id1,m1),morphScore(id2,m2)
    if s2 > s1 then return m2,id2 end
    return m1,id1
end

local function easSkillLineName(skillType, skillLine, lineId)
    if tonumber(lineId) and tonumber(lineId) > 0 and type(GetSkillLineNameById) == "function" then
        local name = safe(GetSkillLineNameById,"",tonumber(lineId))
        if name and name ~= "" then return tostring(name) end
    end
    if type(GetSkillLineInfo) == "function" then
        local name = safe(GetSkillLineInfo,"",skillType,skillLine)
        if name and name ~= "" then return tostring(name) end
    end
    return ""
end

function G:GetWeaponSkillFamily(weaponType)
    local w=tonumber(weaponType) or 0
    if w==(WEAPONTYPE_FIRE_STAFF or -101) or w==(WEAPONTYPE_FROST_STAFF or -102) or w==(WEAPONTYPE_LIGHTNING_STAFF or -103) then return "destruction staff" end
    if w==(WEAPONTYPE_HEALING_STAFF or -104) then return "restoration staff" end
    if w==(WEAPONTYPE_BOW or -105) then return "bow" end
    if w==(WEAPONTYPE_DUAL_WIELD or -106) then return "dual wield" end
    if w==(WEAPONTYPE_TWO_HANDED_SWORD or -107) or w==(WEAPONTYPE_TWO_HANDED_AXE or -108) or w==(WEAPONTYPE_TWO_HANDED_HAMMER or -109) then return "two handed" end
    if w==(WEAPONTYPE_ONE_HAND_AND_SHIELD or -110) then return "one hand and shield" end
    return ""
end

function G:IsPlannedAbilityCompatibleWithWeapon(entry, weaponType)
    if not entry or entry.skillType ~= SKILL_TYPE_WEAPON then return true end
    local family=self:GetWeaponSkillFamily(weaponType)
    if family=="" then return false end
    local line=lower(entry.skillLineName or "")
    if family=="one hand and shield" then
        return containsAny(line,{"one hand and shield","one hand & shield","sword and shield"})
    end
    if family=="two handed" then return containsAny(line,{"two handed","two-handed"}) end
    return string.find(line,family,1,true)~=nil
end

function G:ScoreAbilityForWeaponBar(entry, context, isBackup)
    local score=self:ScoreAbilityForCurrentBuild(entry,context)
    local weaponType=isBackup and context.backWeaponType or context.frontWeaponType
    if not self:IsPlannedAbilityCompatibleWithWeapon(entry,weaponType) then return -1000000 end
    local n=lower(entry.name or "")
    local role=context.role or "DAMAGE"
    -- Primary/front emphasizes frequent attacks, executes and burst. Backup/back
    -- emphasizes DoTs, buffs, shields, healing and setup. Pets that disappear
    -- when unslotted are intentionally competitive on both bars.
    local persistentPet=containsAny(n,{"familiar","clannfear","twilight","tormentor","matriarch"})
    if isBackup then
        if containsAny(n,{"wall","blockade","stampede","volley","hail","trap","curse","prey","surge","armor","resolve","shield","ward","heal","regeneration","ritual","orb","vigor","buff","debuff"}) then score=score+330 end
        if containsAny(n,{"execute","spammable","crystal fragment","crushing shock","force pulse","rapid strikes","wrecking blow"}) then score=score-160 end
    else
        if containsAny(n,{"execute","spammable","crystal fragment","crushing shock","force pulse","rapid strikes","wrecking blow","snipe","whip","jabs","flurry"}) then score=score+300 end
        if role=="DAMAGE" and containsAny(n,{"heal","regeneration","ritual"}) then score=score-120 end
    end
    if persistentPet then score=score+240 end
    return score
end

function G:BuildPlannedWeaponBar(active, context, isBackup)
    local normals,ults={},{}
    for _,e in ipairs(active or {}) do
        local score=self:ScoreAbilityForWeaponBar(e,context,isBackup)
        if score>-900000 then
            local row={entry=e,score=score}
            if e.ultimate then ults[#ults+1]=row else normals[#normals+1]=row end
        end
    end
    local function sorter(a,b)
        if a.score==b.score then return lower(a.entry.name)<lower(b.entry.name) end
        return a.score>b.score
    end
    table.sort(normals,sorter); table.sort(ults,sorter)
    local chosen={}
    for i=1,math.min(5,#normals) do chosen[#chosen+1]=normals[i].entry end
    return chosen, ults[1] and ults[1].entry or nil
end

function G:BuildFullSkillPlan()
    local context=self:GetWornBuildContext()
    local budget,available,allocated=self:GetTotalSkillPointBudget()
    local active,passives={},{}
    local playerLevel = type(GetUnitLevel)=="function" and safeNumber(GetUnitLevel,1,"player") or 1
    if type(GetNumSkillTypes) ~= "function" or type(GetNumSkillLines) ~= "function" or type(GetNumSkillAbilities) ~= "function" then
        return {context=context,budget=budget,available=available,allocated=allocated,active={},passives={},spent=0}
    end
    for skillType=1,safeNumber(GetNumSkillTypes,0) do
        for skillLine=1,safeNumber(GetNumSkillLines,0,skillType) do
            local lineRank,_,isActive,isDiscovered = safe(GetSkillLineDynamicInfo,nil,skillType,skillLine)
            if isDiscovered ~= false and isActive ~= false then
                local lineId=type(GetSkillLineId)=="function" and safeNumber(GetSkillLineId,0,skillType,skillLine) or 0
                for skillIndex=1,safeNumber(GetNumSkillAbilities,0,skillType,skillLine) do
                    local skipCrafted=type(IsCraftedAbilitySkill)=="function" and safe(IsCraftedAbilitySkill,false,skillType,skillLine,skillIndex)==true
                    local autoGrant=type(IsSkillAbilityAutoGrant)=="function" and safe(IsSkillAbilityAutoGrant,false,skillType,skillLine,skillIndex)==true
                    if not skipCrafted and not autoGrant then
                        local name,_,_,passive,ultimate,purchased,progressionIndex,currentRank=safe(GetSkillAbilityInfo,nil,skillType,skillLine,skillIndex)
                        local neededRank=type(GetSkillAbilityLineRankNeededToUnlock)=="function" and safeNumber(GetSkillAbilityLineRankNeededToUnlock,0,skillType,skillLine,skillIndex) or 0
                        local neededLevel=type(GetSkillAbilityCharacterLevelNeededToUnlock)=="function" and safeNumber(GetSkillAbilityCharacterLevelNeededToUnlock,0,skillType,skillLine,skillIndex) or 0
                        local unlocked=(tonumber(lineRank) or 0)>=neededRank and playerLevel>=neededLevel
                        if unlocked and name and name~="" then
                            if passive==true then
                                local maxRanks=type(GetNumPassiveSkillRanks)=="function" and safeNumber(GetNumPassiveSkillRanks,1,skillType,skillLine,skillIndex) or 1
                                if type(GetUpgradeSkillHighestRankAvailableAtSkillLineRank)=="function" then
                                    maxRanks=math.min(maxRanks, safeNumber(GetUpgradeSkillHighestRankAvailableAtSkillLineRank,maxRanks,skillType,skillLine,skillIndex,tonumber(lineRank) or 0))
                                end
                                local e={name=tostring(name),skillType=skillType,skillLine=skillLine,skillIndex=skillIndex,skillLineId=lineId,skillLineName=easSkillLineName(skillType,skillLine,lineId),maxRank=math.max(1,maxRanks),currentRank=purchased==true and math.max(1,tonumber(currentRank) or 1) or 0}
                                e.score=self:ScorePassiveForCurrentBuild(e,context)
                                passives[#passives+1]=e
                            else
                                local progressionId=type(GetProgressionSkillProgressionId)=="function" and safeNumber(GetProgressionSkillProgressionId,0,skillType,skillLine,skillIndex) or 0
                                local currentMorph=rawget(_G,"MORPH_SLOT_BASE") or 0
                                local progressionRank=tonumber(currentRank) or 1
                                local canMorph=false
                                if progressionIndex and type(GetAbilityProgressionInfo)=="function" then
                                    local _,mc,pr=safe(GetAbilityProgressionInfo,nil,progressionIndex)
                                    currentMorph=tonumber(mc) or currentMorph
                                    progressionRank=tonumber(pr) or progressionRank
                                end
                                if progressionIndex and type(GetAbilityProgressionXPInfo)=="function" then
                                    local _,_,_,atMorph=safe(GetAbilityProgressionXPInfo,nil,progressionIndex)
                                    canMorph=(atMorph==true) or ((tonumber(currentMorph) or (rawget(_G,"MORPH_SLOT_BASE") or 0)) ~= (rawget(_G,"MORPH_SLOT_BASE") or 0))
                                else
                                    canMorph=((tonumber(currentMorph) or (rawget(_G,"MORPH_SLOT_BASE") or 0)) ~= (rawget(_G,"MORPH_SLOT_BASE") or 0))
                                end
                                local morphSlot,abilityId=self:ChooseBuildMorph(skillType,skillLine,skillIndex,progressionId,context,currentMorph,canMorph)
                                local displayName=easAbilityNameById(abilityId,name)
                                local e={name=displayName,baseName=tostring(name),skillType=skillType,skillLine=skillLine,skillIndex=skillIndex,skillLineId=lineId,skillLineName=easSkillLineName(skillType,skillLine,lineId),progressionId=progressionId,progressionIndex=progressionIndex,progressionRank=progressionRank,morphSlot=morphSlot,abilityId=abilityId,ultimate=ultimate==true,purchased=purchased==true,currentMorph=currentMorph,canMorph=canMorph}
                                e.score=self:ScoreAbilityForCurrentBuild(e,context)
                                active[#active+1]=e
                            end
                        end
                    end
                end
            end
        end
    end
    table.sort(active,function(a,b) if a.score==b.score then return lower(a.name)<lower(b.name) end return a.score>b.score end)
    table.sort(passives,function(a,b) if a.score==b.score then return lower(a.name)<lower(b.name) end return a.score>b.score end)

    -- Plan Primary and Backup independently from their equipped weapon types.
    -- The purchase list is the union of both bar plans, so the respec buys the
    -- skills needed by either weapon rather than taking a generic top-ten list.
    local frontWanted,frontUltWanted=self:BuildPlannedWeaponBar(active,context,false)
    local backWanted,backUltWanted=self:BuildPlannedWeaponBar(active,context,true)
    local chosen,chosenMap={},{}
    local chosenUlts={}
    local spent=0
    local baseMorph=rawget(_G,"MORPH_SLOT_BASE") or 0
    local function entryKey(e)
        if not e then return nil end
        return tonumber(e.progressionId) or (tostring(e.skillType)..":"..tostring(e.skillLine)..":"..tostring(e.skillIndex))
    end
    local function addActive(e,target)
        if not e then return false end
        local key=entryKey(e)
        if chosenMap[key] then return true end
        -- Secure the base skill first. Morph upgrades are budgeted only after
        -- both weapon bars (5 normal skills + Ultimate each) are complete.
        local cost=1
        if spent+cost>budget then return false end
        target[#target+1]=e; chosenMap[key]=true; spent=spent+cost
        return true
    end

    -- Reserve Ultimates BEFORE normal skills/passives. An earlier build could
    -- consume the point budget on normal abilities and leave Backup Ultimate
    -- empty even though a legal class Ultimate was available.
    addActive(frontUltWanted,chosenUlts)
    addActive(backUltWanted,chosenUlts)

    -- Interleave normal skills so both bars develop together.
    for i=1,5 do addActive(frontWanted[i],chosen); addActive(backWanted[i],chosen) end

    -- Build the FINAL bars from skills that are actually in the purchase plan.
    -- If one bar's fifth choice was skipped by the point budget, keep searching
    -- the selected pool (then the remaining ranked pool) for another compatible
    -- ability instead of staging an unpurchased skill and leaving slot 5 blank.
    local function rebuildBar(isBackup, originalWanted)
        local result,used={},{}
        local function tryAdd(e, allowPurchase)
            if not e or #result>=5 or e.ultimate then return false end
            local key=entryKey(e)
            if used[key] then return false end
            if self:ScoreAbilityForWeaponBar(e,context,isBackup)<=-900000 then return false end
            if not chosenMap[key] then
                if not allowPurchase or not addActive(e,chosen) then return false end
            end
            used[key]=true
            result[#result+1]=e
            return true
        end
        -- Keep each bar's highest-ranked intended choices first.
        for _,e in ipairs(originalWanted or {}) do tryAdd(e,false) end
        -- Reuse skills selected for the other bar when compatible. This both
        -- fills all five slots and avoids wasting skill points on duplicates.
        for _,e in ipairs(chosen) do tryAdd(e,false) end
        -- If still short and points remain, purchase the next legal candidates.
        for _,e in ipairs(active or {}) do
            if #result>=5 then break end
            tryAdd(e,true)
        end
        return result
    end

    frontWanted=rebuildBar(false,frontWanted)
    backWanted=rebuildBar(true,backWanted)

    -- Ultimate fallback: if a bar-specific Ultimate could not be purchased, use
    -- any already-selected legal Ultimate before leaving the slot empty.
    local function finalUltimate(isBackup,wanted)
        local function compatible(e)
            return e and e.ultimate and self:ScoreAbilityForWeaponBar(e,context,isBackup)>-900000
        end
        if wanted and chosenMap[entryKey(wanted)] and compatible(wanted) then return wanted end
        for _,e in ipairs(chosenUlts) do if compatible(e) then return e end end
        -- Last chance: purchase the next legal Ultimate if budget permits.
        local candidates={}
        for _,e in ipairs(active or {}) do
            if e.ultimate and compatible(e) then
                candidates[#candidates+1]={entry=e,score=self:ScoreAbilityForWeaponBar(e,context,isBackup)}
            end
        end
        table.sort(candidates,function(a,b) return a.score>b.score end)
        for _,row in ipairs(candidates) do
            if addActive(row.entry,chosenUlts) then return row.entry end
        end
        return nil
    end
    frontUltWanted=finalUltimate(false,frontUltWanted)
    backUltWanted=finalUltimate(true,backUltWanted)

    -- Bar completeness has priority over morphs/passives. Once the 12 bar
    -- targets are secured, spend remaining points on the recommended morphs.
    -- If there is not enough budget for a morph, keep the legal base ability
    -- rather than sacrificing slot 5 or an Ultimate.
    local morphedSeen={}
    local function budgetMorph(e)
        if not e then return end
        local key=entryKey(e)
        if morphedSeen[key] then return end
        morphedSeen[key]=true
        if e.morphSlot and e.morphSlot~=baseMorph then
            if spent+1<=budget then
                spent=spent+1
            else
                e.morphSlot=baseMorph
                if type(GetProgressionSkillMorphSlotAbilityId)=="function" and (tonumber(e.progressionId) or 0)>0 then
                    local baseId=safeNumber(GetProgressionSkillMorphSlotAbilityId,0,e.progressionId,baseMorph)
                    if baseId>0 then e.abilityId=baseId end
                elseif type(GetSkillAbilityId)=="function" then
                    local baseId=safeNumber(GetSkillAbilityId,0,e.skillType,e.skillLine,e.skillIndex,false)
                    if baseId>0 then e.abilityId=baseId end
                end
                e.name=e.baseName or e.name
            end
        end
    end
    for _,e in ipairs(chosenUlts) do budgetMorph(e) end
    for _,e in ipairs(chosen) do budgetMorph(e) end

    local desiredPassiveRanks={}
    for _,e in ipairs(passives) do
        if e.score>0 then
            local can=math.min(e.maxRank,math.max(0,budget-spent))
            if can>0 then desiredPassiveRanks[e]=can spent=spent+can end
        end
    end
    return {context=context,budget=budget,available=available,allocated=allocated,allActive=active,allPassives=passives,chosen=chosen,chosenUlts=chosenUlts,chosenMap=chosenMap,frontWanted=frontWanted,backWanted=backWanted,frontUltWanted=frontUltWanted,backUltWanted=backUltWanted,desiredPassiveRanks=desiredPassiveRanks,spent=spent}
end

local function easProtectedOrDirect(functionName,...)
    local fn=rawget(_G,functionName)
    if type(fn)=="function" then
        local ok,a,b=pcall(fn,...)
        if ok then return true,a,b end
    end
    if type(CallSecureProtected)=="function" then
        local ok,a,b=pcall(CallSecureProtected,functionName,...)
        if ok and a~=false then return true,a,b end
    end
    return false
end


function G:ResolvePlannedAbilityIndex(entry)
    if not entry then return nil end
    local progressionIndex=tonumber(entry.progressionIndex)
    if (not progressionIndex or progressionIndex<=0) and type(GetProgressionSkillProgressionIndex)=="function" then
        progressionIndex=safeNumber(GetProgressionSkillProgressionIndex,0,entry.skillType,entry.skillLine,entry.skillIndex)
    end
    if progressionIndex and progressionIndex>0 and type(GetAbilityProgressionInfo)=="function" and type(GetAbilityProgressionAbilityInfo)=="function" then
        local _,morph,rank=safe(GetAbilityProgressionInfo,nil,progressionIndex)
        local _,_,abilityIndex=safe(GetAbilityProgressionAbilityInfo,nil,progressionIndex,tonumber(morph) or 0,tonumber(rank) or 1)
        if tonumber(abilityIndex) and tonumber(abilityIndex)>0 then return tonumber(abilityIndex) end
    end
    if tonumber(entry.abilityId) and tonumber(entry.abilityId)>0 and type(GetAbilityIndex)=="function" then
        local idx=safeNumber(GetAbilityIndex,0,entry.abilityId)
        if idx>0 then return idx end
    end
    return nil
end

function G:IsAbilityLegalForBar(abilityId, abilityIndex, slot, category)
    abilityId=tonumber(abilityId) or 0
    abilityIndex=tonumber(abilityIndex) or 0
    if abilityId<=0 or abilityIndex<=0 then return false end
    if type(IsActionSlotMutable)=="function" and safe(IsActionSlotMutable,false,slot,category)~=true then return false end
    if type(IsActionSlotRestricted)=="function" and safe(IsActionSlotRestricted,false,slot,category)==true then return false end
    -- This is the important weapon/category compatibility check. It catches
    -- weapon skills that cannot be used on the requested front/back bar.
    if type(CanAbilityBeUsedFromHotbar)=="function" and safe(CanAbilityBeUsedFromHotbar,false,abilityId,category)~=true then return false end
    return true
end

function G:BuildCompatiblePurchasedBar(category, context)
    local pool=self:CollectPurchasedActiveAbilities()
    local normal,ults={},{}
    for _,a in ipairs(pool) do
        local abilityId=tonumber(a.abilityId) or 0
        a.abilityId=abilityId
        local first=tonumber(ACTION_BAR_FIRST_NORMAL_SLOT_INDEX) or 3
        local probeSlot=a.ultimate and (tonumber(ACTION_BAR_ULTIMATE_SLOT_INDEX) or (first+5)) or first
        if self:IsAbilityLegalForBar(abilityId,a.abilityIndex,probeSlot,category) then
            if (not a.skillLineName or a.skillLineName=="") and a.skillType and a.skillLine then
                local lineId=type(GetSkillLineId)=="function" and safeNumber(GetSkillLineId,0,a.skillType,a.skillLine) or 0
                a.skillLineName=easSkillLineName(a.skillType,a.skillLine,lineId)
            end
            local isBackup=category==(rawget(_G,"HOTBAR_CATEGORY_BACKUP") or 1)
            local score=self:ScoreAbilityForWeaponBar(a,context,isBackup)
            if score>-900000 then
                local row={ability=a,score=score}
                if a.ultimate then ults[#ults+1]=row else normal[#normal+1]=row end
            end
        end
    end
    local function sorter(x,y)
        if x.score==y.score then return lower(x.ability.name)<lower(y.ability.name) end
        return x.score>y.score
    end
    table.sort(normal,sorter); table.sort(ults,sorter)
    local chosen={}
    for i=1,math.min(5,#normal) do chosen[#chosen+1]=normal[i].ability end
    return chosen,ults[1] and ults[1].ability or nil
end

function G:StagePlannedHotbarsInRespec(plan)
    if not plan then return false,0,{"missing plan"} end
    local barMgr=rawget(_G,"ACTION_BAR_ASSIGNMENT_MANAGER")
    local skillsMgr=rawget(_G,"SKILLS_DATA_MANAGER")
    if not barMgr or type(barMgr.GetHotbar)~="function" or not skillsMgr or type(skillsMgr.GetSkillDataByIndices)~="function" then
        return false,0,{"ESO action-bar assignment manager unavailable"}
    end

    -- IMPORTANT: ZO_ActionBarAssignmentManager_Hotbar uses its own 1-indexed
    -- Skills-UI slot range. ESO's source converts the legacy ACTION_BAR_*
    -- constants by +1 before using them with hotbar:ClearSlot()/AssignSkillToSlot().
    -- The public action-bar APIs (GetSlotBoundId/SelectSlotAbility) still use the
    -- normal ACTION_BAR_* indexes, so this +1 conversion belongs ONLY here.
    local actionFirst=tonumber(ACTION_BAR_FIRST_NORMAL_SLOT_INDEX) or 3
    local actionUlt=tonumber(ACTION_BAR_ULTIMATE_SLOT_INDEX) or (actionFirst+5)
    local first=actionFirst+1
    local ultSlot=actionUlt+1
    local PRIMARY=rawget(_G,"HOTBAR_CATEGORY_PRIMARY") or 0
    local BACKUP=rawget(_G,"HOTBAR_CATEGORY_BACKUP") or 1
    local changed=0
    local failures={}

    local function getSkillData(entry)
        if not entry then return nil end
        local ok,data=pcall(skillsMgr.GetSkillDataByIndices,skillsMgr,entry.skillType,entry.skillLine,entry.skillIndex)
        if ok then return data end
        return nil
    end

    local function stageCategory(category,label,wanted,ultimate)
        local okBar,hotbar=pcall(barMgr.GetHotbar,barMgr,category)
        if not okBar or not hotbar then
            failures[#failures+1]=label.." bar unavailable"
            return
        end

        -- Rebuild all six skill slots on this specific hotbar inside ESO's
        -- pending respec state. This is the same hotbar model the vanilla
        -- Skills screen commits with SKILLS_AND_ACTION_BAR_MANAGER:ApplyChanges().
        if type(hotbar.ClearSlot)=="function" then
            for i=1,5 do
                local slot=first+(i-1)
                pcall(hotbar.ClearSlot,hotbar,slot)
            end
            pcall(hotbar.ClearSlot,hotbar,ultSlot)
        end

        for i=1,5 do
            local entry=wanted and wanted[i]
            if entry then
                local skillData=getSkillData(entry)
                local slot=first+(i-1)
                if skillData and type(hotbar.AssignSkillToSlot)=="function" then
                    local ok,result=pcall(hotbar.AssignSkillToSlot,hotbar,slot,skillData)
                    if ok and result~=false then
                        changed=changed+1
                    else
                        failures[#failures+1]=label.." "..i.."="..tostring(entry.name)
                    end
                else
                    failures[#failures+1]=label.." "..i.."="..tostring(entry.name)
                end
            else
                failures[#failures+1]=label.." "..i.." missing from build plan"
            end
        end

        if ultimate then
            local skillData=getSkillData(ultimate)
            if skillData and type(hotbar.AssignSkillToSlot)=="function" then
                local ok,result=pcall(hotbar.AssignSkillToSlot,hotbar,ultSlot,skillData)
                if ok and result~=false then
                    changed=changed+1
                else
                    failures[#failures+1]=label.." Ultimate="..tostring(ultimate.name)
                end
            else
                failures[#failures+1]=label.." Ultimate="..tostring(ultimate.name)
            end
        else
            failures[#failures+1]=label.." Ultimate missing from build plan"
        end
    end

    stageCategory(PRIMARY,"Primary",plan.frontWanted,plan.frontUltWanted)

    local backUnlocked=true
    if type(GetWeaponSwapUnlockedLevel)=="function" and type(GetUnitLevel)=="function" then
        backUnlocked=safeNumber(GetUnitLevel,1,"player")>=safeNumber(GetWeaponSwapUnlockedLevel,15)
    end
    if backUnlocked then
        stageCategory(BACKUP,"Backup",plan.backWanted,plan.backUltWanted)
    else
        failures[#failures+1]="Backup weapon bar is not unlocked"
    end

    local expected=backUnlocked and 12 or 6
    local complete=(changed>=expected and #failures==0)
    return complete,changed,failures
end

function G:GetPlannedBuildVerification(plan)
    if not plan then return nil end
    local base=rawget(_G,"MORPH_SLOT_BASE") or 0
    local expectedSkills,confirmedSkills=0,0
    local expectedMorphs,confirmedMorphs=0,0
    local expectedPassiveRanks,confirmedPassiveRanks=0,0
    local seen={}

    local function verifyActive(e)
        if not e then return end
        local key=string.format("%s:%s:%s",tostring(e.skillType),tostring(e.skillLine),tostring(e.skillIndex))
        if seen[key] then return end
        seen[key]=true
        expectedSkills=expectedSkills+1
        local _,_,_,passive,_,purchased,progressionIndex,rank=safe(GetSkillAbilityInfo,nil,e.skillType,e.skillLine,e.skillIndex)
        if passive~=true and purchased==true then confirmedSkills=confirmedSkills+1 end
        local wantedMorph=tonumber(e.morphSlot) or base
        if wantedMorph~=base then
            expectedMorphs=expectedMorphs+1
            progressionIndex=tonumber(progressionIndex) or tonumber(e.progressionIndex)
            if progressionIndex and progressionIndex>0 then
                local _,currentMorph=safe(GetAbilityProgressionInfo,nil,progressionIndex)
                if tonumber(currentMorph)==wantedMorph then confirmedMorphs=confirmedMorphs+1 end
            end
        end
    end

    for _,e in ipairs(plan.chosen or {}) do verifyActive(e) end
    for _,e in ipairs(plan.chosenUlts or {}) do verifyActive(e) end

    for e,desired in pairs(plan.desiredPassiveRanks or {}) do
        desired=math.max(0,tonumber(desired) or 0)
        if desired>0 and e then
            expectedPassiveRanks=expectedPassiveRanks+desired
            local _,_,_,passive,_,purchased,_,rank=safe(GetSkillAbilityInfo,nil,e.skillType,e.skillLine,e.skillIndex)
            if passive==true and purchased==true then
                confirmedPassiveRanks=confirmedPassiveRanks+math.min(desired,math.max(1,tonumber(rank) or 1))
            end
        end
    end

    local first=tonumber(rawget(_G,"SKILL_BAR_FIRST_NORMAL_SLOT_INDEX")) or tonumber(ACTION_BAR_FIRST_NORMAL_SLOT_INDEX) or 3
    local ultSlot=tonumber(rawget(_G,"SKILL_BAR_ULTIMATE_SLOT_INDEX")) or tonumber(ACTION_BAR_ULTIMATE_SLOT_INDEX) or (first+5)
    local PRIMARY=rawget(_G,"HOTBAR_CATEGORY_PRIMARY") or 0
    local BACKUP=rawget(_G,"HOTBAR_CATEGORY_BACKUP") or 1
    local primaryCount,backupCount=0,0
    if type(GetSlotBoundId)=="function" then
        for i=1,5 do
            if safeNumber(GetSlotBoundId,0,first+i-1,PRIMARY)>0 then primaryCount=primaryCount+1 end
            if safeNumber(GetSlotBoundId,0,first+i-1,BACKUP)>0 then backupCount=backupCount+1 end
        end
        if safeNumber(GetSlotBoundId,0,ultSlot,PRIMARY)>0 then primaryCount=primaryCount+1 end
        if safeNumber(GetSlotBoundId,0,ultSlot,BACKUP)>0 then backupCount=backupCount+1 end
    end

    local backRequired=true
    if type(GetWeaponSwapUnlockedLevel)=="function" and type(GetUnitLevel)=="function" then
        backRequired=safeNumber(GetUnitLevel,1,"player")>=safeNumber(GetWeaponSwapUnlockedLevel,15)
    end
    local complete=confirmedSkills>=expectedSkills
        and confirmedMorphs>=expectedMorphs
        and confirmedPassiveRanks>=expectedPassiveRanks
        and primaryCount>=6
        and ((not backRequired) or backupCount>=6)
    return {
        complete=complete,
        expectedSkills=expectedSkills, confirmedSkills=confirmedSkills,
        expectedMorphs=expectedMorphs, confirmedMorphs=confirmedMorphs,
        expectedPassiveRanks=expectedPassiveRanks, confirmedPassiveRanks=confirmedPassiveRanks,
        primaryCount=primaryCount, backupCount=backupCount, backRequired=backRequired,
    }
end

function G:ConfirmFullSkillBuild(plan)
    local v=self:GetPlannedBuildVerification(plan)
    if not v then return false end
    local state=v.complete and "BUILD CONFIRMED" or "BUILD INCOMPLETE"
    local msg=string.format(
        "%s: Skills %d/%d | Morphs %d/%d | Passive ranks %d/%d | Primary %d/6 | Backup %d/6.",
        state,v.confirmedSkills,v.expectedSkills,v.confirmedMorphs,v.expectedMorphs,
        v.confirmedPassiveRanks,v.expectedPassiveRanks,v.primaryCount,v.backupCount)
    if not v.backRequired then msg=msg:gsub(" | Backup %d/6%."," | Backup locked.") end
    self:NotifyResult(msg,v.complete)
    return v.complete
end

function G:VerifyPlannedHotbars(plan, quiet)
    if not plan or type(GetSlotBoundId)~="function" then return false end
    local first=tonumber(rawget(_G,"SKILL_BAR_FIRST_NORMAL_SLOT_INDEX")) or tonumber(ACTION_BAR_FIRST_NORMAL_SLOT_INDEX) or 3
    local ultSlot=tonumber(rawget(_G,"SKILL_BAR_ULTIMATE_SLOT_INDEX")) or tonumber(ACTION_BAR_ULTIMATE_SLOT_INDEX) or (first+5)
    local PRIMARY=rawget(_G,"HOTBAR_CATEGORY_PRIMARY") or 0
    local BACKUP=rawget(_G,"HOTBAR_CATEGORY_BACKUP") or 1
    local primaryCount,backupCount=0,0
    for i=1,5 do
        if safeNumber(GetSlotBoundId,0,first+i-1,PRIMARY)>0 then primaryCount=primaryCount+1 end
        if safeNumber(GetSlotBoundId,0,first+i-1,BACKUP)>0 then backupCount=backupCount+1 end
    end
    if safeNumber(GetSlotBoundId,0,ultSlot,PRIMARY)>0 then primaryCount=primaryCount+1 end
    if safeNumber(GetSlotBoundId,0,ultSlot,BACKUP)>0 then backupCount=backupCount+1 end
    if not quiet then
        self:NotifyResult(string.format("BEST BUILD BAR VERIFY: Primary %d/6, Backup %d/6.",primaryCount,backupCount), backupCount>0 and primaryCount>0)
    end
    return primaryCount>0 and backupCount>0
end

function G:ApplyPlannedHotbars(plan, quiet)
    if not plan or safe(IsUnitInCombat,false,"player")==true or type(CallSecureProtected)~="function" then return false,0 end
    local first=tonumber(ACTION_BAR_FIRST_NORMAL_SLOT_INDEX) or 3
    local ultSlot=tonumber(ACTION_BAR_ULTIMATE_SLOT_INDEX) or (first+5)
    local PRIMARY=rawget(_G,"HOTBAR_CATEGORY_PRIMARY") or 0
    local BACKUP=rawget(_G,"HOTBAR_CATEGORY_BACKUP") or 1
    local context=plan.context or self:GetWornBuildContext()
    local changed=0
    local labels={}

    local function applyCategory(category,label)
        local chosen,ultimate=self:BuildCompatiblePurchasedBar(category,context)
        for i=1,5 do
            local slot=first+(i-1)
            local a=chosen[i]
            if a and self:IsAbilityLegalForBar(a.abilityId,a.abilityIndex,slot,category) then
                local ok,result=pcall(CallSecureProtected,"SelectSlotAbility",a.abilityIndex,slot,category)
                if ok and result~=false then changed=changed+1; labels[#labels+1]=label.." "..i.."="..tostring(a.name) end
            end
        end
        if ultimate and self:IsAbilityLegalForBar(ultimate.abilityId,ultimate.abilityIndex,ultSlot,category) then
            local ok,result=pcall(CallSecureProtected,"SelectSlotAbility",ultimate.abilityIndex,ultSlot,category)
            if ok and result~=false then changed=changed+1; labels[#labels+1]=label.." U="..tostring(ultimate.name) end
        end
    end

    applyCategory(PRIMARY,"Primary")
    -- Back bar may be unavailable at low level; don't force it.
    local backUnlocked=true
    if type(GetWeaponSwapUnlockedLevel)=="function" and type(GetUnitLevel)=="function" then
        backUnlocked=safeNumber(GetUnitLevel,1,"player")>=safeNumber(GetWeaponSwapUnlockedLevel,15)
    end
    if backUnlocked then applyCategory(BACKUP,"Backup") end

    if not quiet then
        if changed>0 then
            self:NotifyResult(string.format("BEST BUILD BAR: applied %d validated slot%s. %s",changed,changed==1 and "" or "s",table.concat(labels," | ")),true)
        else
            self:NotifyResult("BEST BUILD BAR: no legal purchased abilities were accepted for the current weapon bars.",false)
        end
    end
    if EPC and EPC.AbilityOverlays and EPC.AbilityOverlays.Refresh then EPC.AbilityOverlays:Refresh() end
    return changed>0,changed
end

function G:ApplyFullSkillPlan(plan)
    plan=plan or self:BuildFullSkillPlan()
    if safe(IsUnitInCombat,false,"player")==true then
        self:NotifyResult("RESPEC BUILD: leave combat first.",false)
        return false
    end

    local FULL=rawget(_G,"SKILL_POINT_ALLOCATION_MODE_FULL")
    local mgr=rawget(_G,"SKILLS_AND_ACTION_BAR_MANAGER")
    local allocMgr=rawget(_G,"SKILL_POINT_ALLOCATION_MANAGER")
    local skillsMgr=rawget(_G,"SKILLS_DATA_MANAGER")
    if FULL==nil or not mgr or not allocMgr or not skillsMgr then
        self:NotifyResult("RESPEC BUILD: ESO's current Skills respec managers are unavailable.",false)
        return false
    end

    -- Update 49+: NEVER directly prepare a RESPEC_PAYMENT_TYPE_GOLD request here.
    -- Vanilla ESO first enters a shrine-free respec session with StartSkillRespecFromUI(),
    -- then edits SKILL_POINT_ALLOCATION_MANAGER state and commits through
    -- SKILLS_AND_ACTION_BAR_MANAGER:ApplyChanges(). Calling Prepare... with GOLD
    -- before that session is active produces RESPEC_RESULT_NOT_AT_SKILL_RESPEC_SHRINE.
    local function allocationReady()
        return type(mgr.DoesSkillPointAllocationModeBatchSave)=="function"
            and mgr:DoesSkillPointAllocationModeBatchSave()==true
    end

    local function applyIntoCurrentRespecSession()
        -- Force full allocation mode if ESO started another legal batch mode.
        if type(mgr.SetSkillPointAllocationMode)=="function" then
            mgr:SetSkillPointAllocationMode(FULL)
        end
        if not allocationReady() then return false end

        if type(allocMgr.ClearPointsOnAllSkillLines)~="function" then
            self:NotifyResult("RESPEC BUILD: ESO's clear-all skill allocator is unavailable.",false)
            return false
        end
        allocMgr:ClearPointsOnAllSkillLines()

        local base=rawget(_G,"MORPH_SLOT_BASE") or 0
        local purchasedActives,morphedActives,passiveRanks=0,0,0
        local failures={}

        local function getAllocator(e)
            if type(skillsMgr.GetSkillDataByIndices)~="function" then return nil end
            local ok,data=pcall(skillsMgr.GetSkillDataByIndices,skillsMgr,e.skillType,e.skillLine,e.skillIndex)
            if not ok or not data or type(data.GetPointAllocator)~="function" then return nil end
            local ok2,a=pcall(data.GetPointAllocator,data)
            if ok2 then return a end
            return nil
        end

        -- Purchase the exact combat actives selected by the planner. Because all
        -- points were cleared above, each selected active must be repurchased.
        for _,e in ipairs(plan.chosen or {}) do
            local a=getAllocator(e)
            if a then
                local bought=false
                if type(a.CanPurchase)=="function" and type(a.Purchase)=="function" then
                    local okCan,can=pcall(a.CanPurchase,a)
                    if okCan and can==true then
                        local okBuy=pcall(a.Purchase,a)
                        bought=okBuy==true
                        if bought then purchasedActives=purchasedActives+1 end
                    end
                end
                local wantedMorph=tonumber(e.morphSlot) or base
                if wantedMorph~=base and type(a.CanMorph)=="function" and type(a.Morph)=="function" then
                    local okCan,can=pcall(a.CanMorph,a)
                    if okCan and can==true then
                        local okMorph=pcall(a.Morph,a,wantedMorph)
                        if okMorph then morphedActives=morphedActives+1 end
                    end
                end
                if not bought and type(a.IsPurchased)=="function" then
                    local okPurchased,isPurchased=pcall(a.IsPurchased,a)
                    if not okPurchased or not isPurchased then failures[#failures+1]=tostring(e.name) end
                end
            else
                failures[#failures+1]=tostring(e.name)
            end
        end
        for _,e in ipairs(plan.chosenUlts or {}) do
            local a=getAllocator(e)
            if a then
                local bought=false
                if type(a.CanPurchase)=="function" and type(a.Purchase)=="function" then
                    local okCan,can=pcall(a.CanPurchase,a)
                    if okCan and can==true then
                        local okBuy=pcall(a.Purchase,a)
                        bought=okBuy==true
                        if bought then purchasedActives=purchasedActives+1 end
                    end
                end
                local wantedMorph=tonumber(e.morphSlot) or base
                if wantedMorph~=base and type(a.CanMorph)=="function" and type(a.Morph)=="function" then
                    local okCan,can=pcall(a.CanMorph,a)
                    if okCan and can==true then
                        local okMorph=pcall(a.Morph,a,wantedMorph)
                        if okMorph then morphedActives=morphedActives+1 end
                    end
                end
            else
                failures[#failures+1]=tostring(e.name)
            end
        end

        -- Rebuild the recommended passive ranks from zero.
        for _,e in ipairs(plan.allPassives or {}) do
            local desired=tonumber(plan.desiredPassiveRanks and plan.desiredPassiveRanks[e]) or 0
            if desired>0 then
                local a=getAllocator(e)
                if a then
                    local rank=0
                    if type(a.CanPurchase)=="function" and type(a.Purchase)=="function" then
                        local okCan,can=pcall(a.CanPurchase,a)
                        if okCan and can==true and pcall(a.Purchase,a) then
                            rank=1
                            passiveRanks=passiveRanks+1
                        end
                    end
                    while rank<desired and type(a.CanIncreaseRank)=="function" and type(a.IncreaseRank)=="function" do
                        local okCan,can=pcall(a.CanIncreaseRank,a)
                        if not okCan or can~=true then break end
                        if not pcall(a.IncreaseRank,a) then break end
                        rank=rank+1
                        passiveRanks=passiveRanks+1
                    end
                end
            end
        end

        -- Stage BOTH Primary and Backup bars before ApplyChanges(). ESO's current
        -- respec manager submits pending hotbar assignments together with the
        -- purchased skills/morphs/passives, which makes the backup bar persist.
        local barsOk,barsChanged,barFailures=self:StagePlannedHotbarsInRespec(plan)
        if not barsOk then
            self:NotifyResult("RESPEC BUILD STOPPED: both unlocked weapon bars must be complete before confirmation. Staged "..tostring(barsChanged or 0).."/12 slots. "..table.concat(barFailures or {},", "),false)
            return false
        end

        if type(mgr.HasAnyPendingChanges)=="function" then
            local okPending,pending=pcall(mgr.HasAnyPendingChanges,mgr)
            if okPending and pending~=true then
                self:NotifyResult("RESPEC BUILD: ESO entered respec mode, but no valid skill changes were produced.",false)
                return false
            end
        end

        if type(mgr.ApplyChanges)~="function" then
            self:NotifyResult("RESPEC BUILD: ESO's current ApplyChanges function is unavailable.",false)
            return false
        end

        -- The build is fully staged at this point, but NOTHING is committed yet.
        -- Show one final confirmation only after skills, morphs, passives, Primary,
        -- and Backup bars are all ready. ApplyChanges() runs only from Confirm.
        local function commitFinishedBuild()
            local okApply,err=pcall(mgr.ApplyChanges,mgr)
            if not okApply then
                self:NotifyResult("RESPEC BUILD: ESO rejected the final confirmed respec: "..tostring(err),false)
                return false
            end

            self._lastAppliedFullSkillPlan=plan
            local msg=string.format("RESPEC BUILD CONFIRMED: %d actives/ultimates, %d morphs, %d passive ranks, plus both weapon bars submitted to ESO.",purchasedActives,morphedActives,passiveRanks)
            if #failures>0 then msg=msg.." Skipped: "..table.concat(failures,", ") end
            self:NotifyResult(msg,true)

            if type(zo_callLater)=="function" then
                -- ESO can finish the server-side respec shortly after the final confirm.
                zo_callLater(function() self:VerifyPlannedHotbars(plan,true) end,900)
                zo_callLater(function() self:ConfirmFullSkillBuild(plan) end,2400)
            else
                self:ConfirmFullSkillBuild(plan)
            end
            if EPC and EPC.RequestRefresh then EPC:RequestRefresh("full-skill-respec") end
            return true
        end

        local dialogName="EPC_CONFIRM_FULL_SKILL_BUILD"
        if type(ZO_Dialogs_RegisterCustomDialog)=="function" and type(ZO_Dialogs_ShowDialog)=="function" then
            if not self._fullSkillConfirmDialogRegistered then
                ZO_Dialogs_RegisterCustomDialog(dialogName,
                {
                    title={ text="CONFIRM RESPEC BUILD" },
                    mainText={ text="The full build is ready. Confirm to permanently apply the recommended skills, morphs, passives, Primary bar, and Backup bar." },
                    buttons=
                    {
                        {
                            text=SI_DIALOG_CONFIRM,
                            callback=function(dialog)
                                local data=dialog and dialog.data
                                if data and type(data.commit)=="function" then data.commit() end
                            end,
                        },
                        {
                            text=SI_DIALOG_CANCEL,
                            callback=function()
                                self:NotifyResult("RESPEC BUILD: final confirmation cancelled. ESO's staged respec was not committed.",false)
                            end,
                        },
                    },
                })
                self._fullSkillConfirmDialogRegistered=true
            end

            self:NotifyResult("RESPEC BUILD READY: review complete. Confirm the final dialog to apply the respec.",true)
            ZO_Dialogs_ShowDialog(dialogName,{ commit=commitFinishedBuild })
            return true
        end

        -- Fallback for clients where the custom-dialog helpers are unavailable:
        -- keep the staged respec intact and make the required final action explicit.
        self:NotifyResult("RESPEC BUILD READY: everything is staged, but the confirmation dialog API is unavailable. Open Skills and press Confirm/Apply to commit the respec.",false)
        return false
    end

    if allocationReady() then
        return applyIntoCurrentRespecSession()
    end

    if type(StartSkillRespecFromUI)~="function" then
        self:NotifyResult("RESPEC BUILD: this ESO client does not expose StartSkillRespecFromUI().",false)
        return false
    end

    self._pendingFullSkillPlan=plan
    self:NotifyResult("RESPEC BUILD: starting ESO's free skill respec mode...",true)
    local started=easProtectedOrDirect("StartSkillRespecFromUI")
    if not started then
        self:NotifyResult("RESPEC BUILD: ESO would not start respec mode. Leave combat/leaderboard/Vengeance content and try again.",false)
        return false
    end

    -- StartSkillRespecFromUI has a short server/cast transition. Poll only until
    -- vanilla ESO reports batch-save respec mode, then perform the planned edits.
    local tries=0
    local function waitForRespec()
        tries=tries+1
        if allocationReady() then
            self._pendingFullSkillPlan=nil
            applyIntoCurrentRespecSession()
            return
        end
        if tries>=40 then
            self:NotifyResult("RESPEC BUILD: ESO did not enter free respec mode. Try again after the respec cooldown ends.",false)
            return
        end
        if type(zo_callLater)=="function" then zo_callLater(waitForRespec,200) end
    end
    if type(zo_callLater)=="function" then
        zo_callLater(waitForRespec,200)
        return true
    end
    self:NotifyResult("RESPEC BUILD: ESO needs zo_callLater for the respec transition on this client.",false)
    return false
end

function G:RespecAndApplyBestBuild()
    if safe(IsUnitInCombat,false,"player")==true then
        self:NotifyResult("RESPEC BUILD: leave combat first.",false)
        return false
    end
    if EPC and EPC.RefreshNow then EPC:RefreshNow("pre-skill-respec-build") end
    local now=type(GetFrameTimeMilliseconds)=="function" and safeNumber(GetFrameTimeMilliseconds,0) or 0
    local plan=(self._pendingFullSkillPlan and self._respecConfirmUntil and now<=self._respecConfirmUntil) and self._pendingFullSkillPlan or self:BuildFullSkillPlan()

    -- Start-to-finish workflow: when launched from the Codex/world, move into
    -- ESO's native Skills scene first, then begin the protected respec flow.
    if EPC and EPC.Journal and EPC.Journal.window and not EPC.Journal.window:IsHidden() and type(EPC.Journal.Hide)=="function" then
        EPC.Journal:Hide()
    end
    if SCENE_MANAGER and type(SCENE_MANAGER.Show)=="function" then
        pcall(function() SCENE_MANAGER:Show("skills") end)
    end
    self:NotifyResult("RESPEC BUILD: opening Skills and preparing the best detected build...",true)
    if type(zo_callLater)=="function" then
        zo_callLater(function()
            self:ApplyFullSkillPlan(plan)
        end,250)
        return true
    end
    return self:ApplyFullSkillPlan(plan)
end

function G:ScorePotion(bag,slot,profile)
    local itemType = type(GetItemType) == "function" and safeNumber(GetItemType,0,bag,slot) or 0
    if itemType ~= (ITEMTYPE_POTION or -9999) then return nil end
    local link = safe(GetItemLink,"",bag,slot,LINK_STYLE_DEFAULT or 0)
    if link == "" then return nil end
    local name = itemName(link)
    local _,_,stack,meets,locked,_,_,fq,dq = safe(GetItemInfo,nil,bag,slot)
    if meets == false or locked == true then return nil end
    local quality = tonumber(fq) or tonumber(dq) or 0
    local score = effectiveItemLevel(bag,slot)*25 + quality*80 + math.min(200,tonumber(stack) or 1)
    local n=lower(name)
    if profile.magicka then
        if containsAny(n,{"spell power","sorcery","prophecy","magicka","essence of spell"}) then score=score+900 end
        if containsAny(n,{"tri-stat","tri stat","health magicka stamina"}) then score=score+600 end
    else
        if containsAny(n,{"weapon power","brutality","savagery","stamina","essence of weapon"}) then score=score+900 end
        if containsAny(n,{"tri-stat","tri stat","health magicka stamina"}) then score=score+600 end
    end
    if containsAny(n,{"health","essence of health"}) then score=score+180 end
    return score,name,link
end

function G:EquipBestPotions()
    if safe(IsUnitInCombat,false,"player") == true then
        self:NotifyResult("BEST POTIONS: leave combat before changing quickslots.", false)
        return false
    end
    if type(CallSecureProtected) ~= "function" or not BAG_BACKPACK then
        self:NotifyResult("BEST POTIONS: ESO's quickslot API is unavailable.", false)
        return false
    end
    local profile=self:GetProfile()
    local candidates={}
    local count=safeNumber(GetBagSize,0,BAG_BACKPACK)
    for slot=0,count-1 do
        local score,name,link=self:ScorePotion(BAG_BACKPACK,slot,profile)
        if score then candidates[#candidates+1]={bag=BAG_BACKPACK,slot=slot,score=score,name=name,link=link} end
    end
    table.sort(candidates,function(a,b) if a.score==b.score then return lower(a.name)<lower(b.name) end return a.score>b.score end)
    if #candidates==0 then
        self:NotifyResult("BEST POTIONS: no usable potions found in the backpack.", false)
        return false
    end
    local utilitySize=tonumber(ACTION_BAR_UTILITY_BAR_SIZE) or 8
    local firstBase=tonumber(ACTION_BAR_FIRST_UTILITY_BAR_SLOT)
    local slotsToFill=math.min(4,utilitySize,#candidates)
    local succeeded=0
    local labels={}
    for i=1,slotsToFill do
        local actionSlot = firstBase and (firstBase+i) or i
        local c=candidates[i]
        local ok,result
        if HOTBAR_CATEGORY_QUICKSLOT_WHEEL ~= nil then
            ok,result=pcall(CallSecureProtected,"SelectSlotItem",c.bag,c.slot,actionSlot,HOTBAR_CATEGORY_QUICKSLOT_WHEEL)
        end
        if not ok or result==false then ok,result=pcall(CallSecureProtected,"SelectSlotItem",c.bag,c.slot,actionSlot) end
        if ok and result~=false then succeeded=succeeded+1; labels[#labels+1]=tostring(i).."="..c.name end
    end
    if succeeded==0 then
        self:NotifyResult("BEST POTIONS: ESO did not accept the quickslot changes. Try while out of combat with the quickslot wheel closed.", false)
        return false
    end
    if type(SetCurrentQuickslot)=="function" then pcall(SetCurrentQuickslot,1) end
    self:NotifyResult("BEST POTIONS: "..table.concat(labels," | "), true)
    return true
end

function G:Initialize() end
