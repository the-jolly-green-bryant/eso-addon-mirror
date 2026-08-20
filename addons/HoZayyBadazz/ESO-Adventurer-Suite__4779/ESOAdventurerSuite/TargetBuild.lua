-- ESO Adventurer Suite
-- Copyright (c) 2026 HoZayyBadazz. All Rights Reserved.
-- Proprietary source. Unauthorized redistribution, republication, rebranding,
-- or public distribution of modified/derivative versions is prohibited.
-- Private personal-use modifications are permitted. See LICENSE.txt.

local EPC = ESOProgressionCoach
EPC.TargetBuild = EPC.TargetBuild or {}
local T = EPC.TargetBuild

T.validProfiles = { AUTO=true, DAMAGE=true, HEALER=true, TANK=true, SOLO=true }
T.profileLabels = { AUTO="AUTO", DAMAGE="DAMAGE", HEALER="HEALER", TANK="TANK", SOLO="SOLO" }

local function num(v, d) v=tonumber(v); if v==nil then return d or 0 end; return v end
local function trim(s)
    s=tostring(s or "")
    s=string.gsub(s, "^%s+", "")
    s=string.gsub(s, "%s+$", "")
    return s
end
local function lower(s) return string.lower(trim(s)) end
local function fmt(v) return tostring(math.floor(num(v,0)+0.5)) end

function T:Initialize()
    if not EPC.saved then return end
    local profile=string.upper(tostring(EPC.saved.targetProfile or "AUTO"))
    if not self.validProfiles[profile] then profile="AUTO" end
    EPC.saved.targetProfile=profile
    EPC.saved.targetSet1=trim(EPC.saved.targetSet1)
    EPC.saved.targetSet2=trim(EPC.saved.targetSet2)
    EPC.saved.targetLootAlerts=EPC.saved.targetLootAlerts ~= false
end

function T:GetConfiguredProfile()
    local profile=EPC.saved and string.upper(tostring(EPC.saved.targetProfile or "AUTO")) or "AUTO"
    if not self.validProfiles[profile] then profile="AUTO" end
    return profile
end

function T:GetEffectiveProfile(snapshot)
    local configured=self:GetConfiguredProfile()
    if configured~="AUTO" then return configured end
    local focus=EPC.Advisor and snapshot and select(1,EPC.Advisor:GetEffectiveFocus(snapshot)) or "AUTO"
    local role=snapshot and snapshot.combatRole or (EPC.Role and EPC.Role:GetRole()) or "DAMAGE"
    if focus=="SOLO" then return "SOLO" end
    if role=="HEALER" then return "HEALER" end
    if role=="TANK" then return "TANK" end
    return "DAMAGE"
end

function T:GetProfileLabel(snapshot)
    local p=self:GetEffectiveProfile(snapshot)
    return self.profileLabels[p] or p
end

function T:SetProfile(profile)
    if not EPC.saved then return false end
    profile=string.upper(trim(profile))
    if profile=="DPS" then profile="DAMAGE" end
    if not self.validProfiles[profile] then return false end
    EPC.saved.targetProfile=profile
    EPC:RequestRefresh("target-profile")
    return true
end

function T:SetTargetSet(index, name)
    if not EPC.saved then return end
    name=trim(name)
    if index==1 then EPC.saved.targetSet1=name else EPC.saved.targetSet2=name end
    EPC:RequestRefresh("target-set")
end

function T:GetTargetSets()
    local out={}
    if not EPC.saved then return out end
    local a,b=trim(EPC.saved.targetSet1),trim(EPC.saved.targetSet2)
    if a~="" then out[#out+1]=a end
    if b~="" and lower(b)~=lower(a) then out[#out+1]=b end
    return out
end

function T:FindEquippedSet(snapshot, wanted)
    if not snapshot or not snapshot.gear then return nil end
    local target=lower(wanted)
    for _,key in ipairs(snapshot.gear.setOrder or {}) do
        local set=snapshot.gear.sets and snapshot.gear.sets[key]
        if set and lower(set.name)==target then return set end
    end
    return nil
end

local function completeSetPieces(set)
    if not set then return 0,5 end
    local equipped=num(set.equipped,0)+num(set.perfectedEquipped,0)
    local target=num(set.maxEquipped,0)>0 and math.min(5,num(set.maxEquipped,5)) or 5
    return equipped,target
end

function T:Evaluate(snapshot, model)
    snapshot=snapshot or {}
    local gear=snapshot.gear or {}
    local targetSets=self:GetTargetSets()
    local missing={}
    local achieved={}
    local score=0

    -- 40 points: set completion. Custom targets are authoritative when configured.
    if #targetSets>0 then
        local each=40/#targetSets
        for _,name in ipairs(targetSets) do
            local set=self:FindEquippedSet(snapshot,name)
            local have,need=completeSetPieces(set)
            local ratio=math.min(1, have/math.max(1,need))
            score=score+(each*ratio)
            if have>=need then
                achieved[#achieved+1]=string.format("%s: %d/%d equipped",name,have,need)
            else
                missing[#missing+1]=string.format("%s: %d/%d equipped — need %d more",name,have,need,math.max(0,need-have))
            end
        end
    else
        local complete=num(gear.completeSetCount,0)
        score=score+math.min(40,complete*20)
        if complete>=2 then achieved[#achieved+1]="Two complete equipped set bonuses detected"
        else missing[#missing+1]=string.format("Complete %d more combat set bonus%s",2-complete,(2-complete)==1 and "" or "es") end
    end

    -- 15 points: enchants, 15 traits, 10 quality, 10 CP, 10 role/build readiness.
    local equipped=math.max(1,num(gear.equippedCount,0))
    local enchantRatio=math.min(1,num(gear.enchantedCount,0)/equipped)
    local traitRatio=math.min(1,num(gear.traitCount,0)/equipped)
    score=score+enchantRatio*15+traitRatio*15
    if enchantRatio<0.9 then missing[#missing+1]=string.format("Enchant more equipped pieces (%d/%d detected)",num(gear.enchantedCount,0),equipped) end
    if traitRatio<0.9 then missing[#missing+1]=string.format("Finish useful traits on equipped pieces (%d/%d detected)",num(gear.traitCount,0),equipped) end

    local avg=num(gear.averageQuality,0)
    local legendary=ITEM_DISPLAY_QUALITY_LEGENDARY or ITEM_QUALITY_LEGENDARY or 5
    local qualityRatio=legendary>0 and math.min(1,avg/legendary) or 0
    score=score+qualityRatio*10
    if qualityRatio<0.8 then missing[#missing+1]="Improve the quality of the weakest pieces after the set/trait plan is correct" end

    local cp=model and model.champion or snapshot.champion or {}
    local cpRatio=num(cp.totalSlots,0)>0 and math.min(1,num(cp.slottedCount,0)/num(cp.totalSlots,1)) or (snapshot.level and snapshot.level<50 and 1 or 0)
    score=score+cpRatio*10
    if snapshot.level and snapshot.level>=50 and cpRatio<1 then missing[#missing+1]=string.format("Fill %d empty Champion slottable slot%s",num(cp.emptySlots,0),num(cp.emptySlots,0)==1 and "" or "s") end

    local readiness=math.min(1, num(model and model.buildScore,0)/100)
    score=score+readiness*10
    if readiness<0.85 then missing[#missing+1]="Raise build readiness by fixing the highest-priority BUILD/SKILLS recommendation" end

    score=math.max(0,math.min(100,math.floor(score+0.5)))
    local status=score>=95 and "COMPLETE" or (score>=80 and "CLOSE" or (score>=60 and "BUILDING" or "EARLY"))
    return {
        profile=self:GetEffectiveProfile(snapshot),
        profileLabel=self:GetProfileLabel(snapshot),
        score=score,
        status=status,
        targetSets=targetSets,
        missing=missing,
        achieved=achieved,
        nextGap=missing[1],
    }
end

function T:EvaluateItemLink(itemLink)
    if not itemLink or itemLink=="" then return nil end
    local targets=self:GetTargetSets()
    if #targets==0 then return nil end
    if type(GetItemLinkSetInfo)~="function" then return nil end
    local ok,hasSet,setName=pcall(GetItemLinkSetInfo,itemLink,true)
    if not ok or not hasSet or not setName then return nil end
    for _,wanted in ipairs(targets) do
        if lower(setName)==lower(wanted) then
            return {tag="TARGET KEEP", reason="Matches target set: "..wanted, setName=setName}
        end
    end
    return nil
end

function T:OnInventorySlotUpdate(bagId,slotIndex,isNewItem)
    if not EPC.saved or EPC.saved.targetLootAlerts==false or not isNewItem then return end
    if BAG_BACKPACK and bagId~=BAG_BACKPACK then return end
    if type(GetItemLink)~="function" then return end
    local link=EPC:Safe(GetItemLink,"",bagId,slotIndex,LINK_STYLE_BRACKETS or 1)
    local verdict=self:EvaluateItemLink(link)
    if verdict then EPC:Print(string.format("|c66FF99%s|r — %s",verdict.tag,verdict.reason)) end
end
