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
function G:Initialize() end
