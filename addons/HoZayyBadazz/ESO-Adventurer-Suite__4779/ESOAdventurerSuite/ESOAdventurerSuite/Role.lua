-- ESO Adventurer Suite
-- Copyright (c) 2026 HoZayyBadazz. All Rights Reserved.
-- Proprietary source. Unauthorized redistribution, republication, rebranding,
-- or public distribution of modified/derivative versions is prohibited.
-- Private personal-use modifications are permitted. See LICENSE.txt.

local EPC = ESOProgressionCoach
EPC.Role = EPC.Role or {}
local R = EPC.Role

R.validModes = { AUTO = true, DAMAGE = true, HEALER = true, TANK = true }
R.labels = { AUTO = "Auto", DAMAGE = "Damage", HEALER = "Healer", TANK = "Tank" }

function R:Initialize()
    if not EPC.saved then return end
    local mode = string.upper(tostring(EPC.saved.combatRoleMode or "AUTO"))
    EPC.saved.combatRoleMode = self.validModes[mode] and mode or "AUTO"
end

function R:SetMode(mode)
    if not EPC.saved then return end
    mode = string.upper(tostring(mode or "AUTO"))
    if not self.validModes[mode] then return end
    EPC.saved.combatRoleMode = mode
    EPC:RequestRefresh("role-mode")
end

function R:GetMode()
    local mode = EPC.saved and string.upper(tostring(EPC.saved.combatRoleMode or "AUTO")) or "AUTO"
    if not self.validModes[mode] then mode = "AUTO" end
    return mode
end

function R:GetAutoRole()
    if type(GetSelectedLFGRole) == "function" then
        local ok, role = pcall(GetSelectedLFGRole)
        if ok then
            if LFG_ROLE_TANK ~= nil and role == LFG_ROLE_TANK then return "TANK" end
            if LFG_ROLE_HEAL ~= nil and role == LFG_ROLE_HEAL then return "HEALER" end
            if LFG_ROLE_DPS ~= nil and role == LFG_ROLE_DPS then return "DAMAGE" end
        end
    end
    return "DAMAGE"
end

function R:GetRole()
    local mode = self:GetMode()
    if mode ~= "AUTO" then return mode end
    return self:GetAutoRole()
end

function R:GetDisplayLabel(resourceRole)
    local role = self:GetRole()
    if role == "HEALER" then return "Healer" end
    if role == "TANK" then return "Tank" end
    if resourceRole == "STAMINA" then return "Stamina DPS" end
    return "Magicka DPS"
end

function R:GetRoleShortLabel(resourceRole)
    local role = self:GetRole()
    if role == "HEALER" then return "HEALER" end
    if role == "TANK" then return "TANK" end
    return resourceRole == "STAMINA" and "STAM DPS" or "MAG DPS"
end

function R:GetRolePriorities(snapshot)
    local role = self:GetRole()
    local result = { role = role, build = {}, gear = {}, skills = {}, activity = {}, combat = {} }
    if role == "HEALER" then
        result.build = {
            "Prioritize sustain, group buffs, debuffs, and reliable burst healing over personal parse damage",
            "Keep a Restoration Staff bar or equivalent healing toolkit ready for group content",
            "Use COMBAT to judge HPS, critical-heal rate, and whether your healing output is consistent across the encounter",
        }
        result.gear = {
            "Favor complete support sets that improve group sustain, damage, or survivability",
            "Check that healing-focused weapons, traits, and enchants support your current content",
            "Keep enough Magicka recovery and resource sustain to heal through long boss phases",
        }
        result.skills = {
            "Keep burst heal, heal-over-time, and group utility options available",
            "Match Champion slottables to healing, sustain, and the mechanics of the content",
            "Keep class utility that buffs allies or weakens enemies available when appropriate",
        }
        result.activity = { "Prioritize group activities where healer queues and support rewards are valuable", "Use dungeon and trial content to benchmark healing under real pressure" }
        result.combat = { "Primary: HPS and total healing", "Secondary: critical-heal rate and personal DPS", "Group view: observed healing leader plus your own contribution" }
    elseif role == "TANK" then
        result.build = {
            "Prioritize survivability, block sustain, taunt uptime, debuffs, and group utility over personal DPS",
            "Keep enough Health and resistances for the content without sacrificing all sustain",
            "Use COMBAT to watch damage taken, blocked-hit rate, healing received/output, and encounter duration",
        }
        result.gear = {
            "Favor complete tank/support sets that improve mitigation or group damage",
            "Heavy Armor and defensive traits are useful signals, but the exact mix depends on encounter mechanics",
            "Keep tank weapons and enchants aligned with taunt, debuff, and sustain needs",
        }
        result.skills = {
            "Keep a reliable taunt, defensive cooldown, self-heal, and resource tool available",
            "Match Champion slottables to mitigation, block sustain, and encounter damage type",
            "Keep group debuffs and utility skills available instead of filling every slot with personal damage",
        }
        result.activity = { "Prioritize dungeons and trials when you want tank practice and group progression", "Use harder bosses to measure survivability instead of judging the build from overland damage" }
        result.combat = { "Primary: damage taken per second and blocked-hit rate", "Secondary: HPS and personal DPS", "Group rankings remain observed estimates because ESO may not expose every teammate event" }
    else
        result.build = {
            "Prioritize damage uptime, resource sustain, and a rotation that matches your chosen content",
            "Use complete set bonuses and Champion slottables that support your damage profile",
            "Use COMBAT after boss fights to compare DPS, crit rate, and top damage sources",
        }
        result.gear = {
            "Favor complete damage sets and weapon pairings that match your resource build",
            "Use traits and enchants that support your chosen damage setup and content",
            "Check penetration, critical chance, and weapon/spell damage together rather than chasing one stat alone",
        }
        result.skills = {
            "Keep your main spammable, damage-over-time effects, buffs, and execute tools organized by bar",
            "Match Champion slottables to direct, DoT, AoE, or single-target emphasis",
            "Keep enough sustain or defensive utility to maintain damage through mechanics",
        }
        result.activity = { "Prioritize activities that match your selected XP, gold, or progression goal", "Use bosses and dungeons to collect repeatable combat samples" }
        result.combat = { "Primary: DPS and total damage", "Secondary: critical-event rate and HPS", "Group view: observed damage leader plus your own contribution" }
    end
    return result
end
