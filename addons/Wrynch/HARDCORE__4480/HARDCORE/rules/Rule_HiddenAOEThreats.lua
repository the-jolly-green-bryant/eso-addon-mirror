local HARDCORE = HARDCORE

local ID = "HiddenAOEThreats"

local function GetSV()
    HARDCORE = HARDCORE or {}
    if not HARDCORE.aoeSaved then
        HARDCORE.aoeSaved = ZO_SavedVars:NewCharacterIdSettings("HARDCORE_AOE_SV", 1, nil, {
            prev = {
                combatCues = nil
            }
        }, GetWorldName())
    end
    return HARDCORE.aoeSaved
end

local function toSetting(v)
    return v and "1" or "0"
end

local function getCombatCues()
    return GetSetting_Bool(SETTING_TYPE_COMBAT, COMBAT_SETTING_MONSTER_TELLS_ENABLED)
end

local function setCombatCues(enabledBool)
    SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_MONSTER_TELLS_ENABLED, toSetting(enabledBool))
end

local Rule = {
    id = ID,
    title = "Hide enemy area attack telegraphs",
    icon = "/esoui/art/treeicons/u46_helpcategory_update46_down.dds",
    defaultEnabled = true
}

function Rule:OnEnable()
    local sv = GetSV()
    sv.prev.combatCues = getCombatCues()
    setCombatCues(false)
end

function Rule:OnDisable()
    local sv = GetSV()
    if sv.prev.combatCues ~= nil then
        setCombatCues(sv.prev.combatCues)
    end
    sv.prev.combatCues = nil
end

HARDCORE.RuleManager:RegisterRule(Rule)
