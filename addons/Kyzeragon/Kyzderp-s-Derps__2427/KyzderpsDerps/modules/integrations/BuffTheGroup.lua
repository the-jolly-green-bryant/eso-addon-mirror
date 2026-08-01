KyzderpsDerps = KyzderpsDerps or {}
KyzderpsDerps.AntiSpud = KyzderpsDerps.AntiSpud or {}
local Spud = KyzderpsDerps.AntiSpud

local enabledBTG = {}
local disabledBTG = {}

local function SetBTG(btgIndex, enable)
    btg.savedVars.trackedBuffs[btgIndex] = enable
    if (enable) then
        table.insert(enabledBTG, GetAbilityName(btgData.buffs[btgIndex]))
    else
        table.insert(disabledBTG, GetAbilityName(btgData.buffs[btgIndex]))
    end
    return enable
end

local function AreSkillsSlotted()
    local combatPrayer = false
    local empoweringGrasp = false
    local expansiveFrostCloak = false
    -- /script for i=3,8 do local id = GetSlotBoundId(i, HOTBAR_CATEGORY_PRIMARY) d(tostring(id) .. " " .. GetAbilityName(id)) end
    for i = 3, 8 do
        local id = GetSlotBoundId(i, HOTBAR_CATEGORY_PRIMARY)
        if (id == 118352) then
            empoweringGrasp = true
        elseif (id == 40094) then
            combatPrayer = true
        elseif (id == 86126) then
            expansiveFrostCloak = true
        end
    end
    for i = 3, 8 do
        local id = GetSlotBoundId(i, HOTBAR_CATEGORY_BACKUP)
        if (id == 118352) then
            empoweringGrasp = true
        elseif (id == 40094) then
            combatPrayer = true
        elseif (id == 86126) then
            expansiveFrostCloak = true
        end
    end

    return combatPrayer, empoweringGrasp, expansiveFrostCloak
end
Spud.AreSkillsSlotted = AreSkillsSlotted

local function UpdateBTGSkills(hasEnabled)
    if (btg == nil) then return end
    local combatPrayer, empoweringGrasp, expansiveFrostCloak = AreSkillsSlotted()

    if (KyzderpsDerps.savedOptions.antispud.equipped.buffTheGroup.minorBerserk) then
        local enabled = SetBTG(6, combatPrayer)
        hasEnabled = hasEnabled or enabled
    end
    if (KyzderpsDerps.savedOptions.antispud.equipped.buffTheGroup.majorResolve) then
        local enabled = SetBTG(12, expansiveFrostCloak)
        hasEnabled = hasEnabled or enabled
    end
    if (KyzderpsDerps.savedOptions.antispud.equipped.buffTheGroup.empower) then
        local enabled = SetBTG(15, empoweringGrasp)
        hasEnabled = hasEnabled or enabled
    end

    return hasEnabled
end
Spud.UpdateBTGSkills = UpdateBTGSkills

local function UpdateBuffTheGroup(equippedSets)
    if (btg == nil) then return end

    local hasEnabled = false
    enabledBTG = {}
    disabledBTG = {}

    if (KyzderpsDerps.savedOptions.antispud.equipped.buffTheGroup.pa) then
        local enabled = SetBTG(1, equippedSets["Powerful Assault"] ~= nil)
        hasEnabled = hasEnabled or enabled
    end
    if (KyzderpsDerps.savedOptions.antispud.equipped.buffTheGroup.majorSlayer) then
        SetBTG(2, equippedSets["Roaring Opportunist"] ~= nil or equippedSets["Master Architect"] ~= nil or equippedSets["War Machine"] ~= nil)
    end
    if (KyzderpsDerps.savedOptions.antispud.equipped.buffTheGroup.majorCourage) then
        SetBTG(3, equippedSets["Vestment of Olorime"] ~= nil or equippedSets["Spell Power Cure"] ~= nil)
    end
    if (KyzderpsDerps.savedOptions.antispud.equipped.buffTheGroup.spaulder and btgData.buffs[19] == zo_strformat(SI_ABILITY_NAME, GetAbilityName(163401))) then
        SetBTG(19, equippedSets["Spaulder of Ruin"] ~= nil)
    end
    if (KyzderpsDerps.savedOptions.antispud.equipped.buffTheGroup.pp) then
        SetBTG(1001, equippedSets["Pillager's Profit"] ~= nil)
    end

    hasEnabled = UpdateBTGSkills(hasEnabled)

    -- If nothing but slayer and courage are enabled, I (personally) want to see major slayer
    if (not hasEnabled and KyzderpsDerps.savedOptions.general.experimental) then
        SetBTG(2, true)
    end

    -- KyzderpsDerps:dbg("Enabled in BuffTheGroup: " .. table.concat(enabledBTG, ", "))
    -- KyzderpsDerps:dbg("Disabled in BuffTheGroup: " .. table.concat(disabledBTG, ", "))

    btg.CheckActivation()
end
Spud.UpdateBuffTheGroup = UpdateBuffTheGroup

function Spud.InitializeBTG()
    if (btg == nil) then return end
    EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "BTGSkills", EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED, function()
        UpdateBTGSkills(false)
        btg.CheckActivation()
    end)
end
