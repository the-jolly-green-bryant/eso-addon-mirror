local R = Conductor.Registry
local grimoires = {
    "BANNER_BEARER", "VAULT", "SMASH", "SOUL_BURST", "TORCHBEARER",
    "ULFSILDS_CONTINGENCY", "TRAVELING_KNIFE", "WIELD_SOUL",
    "ELEMENTAL_EXPLOSION", "MENDERS_BOND", "SHIELD_THROW", "TRAMPLE",
}
for _, key in ipairs(grimoires) do
    local name = key:gsub("_", " "):lower():gsub("(%a)([%w']*)", function(a,b) return string.upper(a)..b end)
    R:Register("SCRIBED_ABILITIES", key, {
        name=name, sourceType="SCRIBED_ABILITY", variableEffects=true,
        parseComponents={"GRIMOIRE","FOCUS_SCRIPT","SIGNATURE_SCRIPT","AFFIX_SCRIPT"},
        normalizedResponsibilities=true, craftedAbilityIds={}, needsIdValidation=true,
    })
end

-- Script components are normalized compositionally. These entries document the
-- effect mapping without enumerating every possible grimoire combination.
R:Register("SCRIBED_ABILITIES", "SCRIPT_COURAGE", {
    name="Courage Script", sourceType="SCRIPT", componentType="AFFIX_SCRIPT",
    provides={"MINOR_COURAGE"}, normalizedResponsibilities=true,
    needsIdValidation=true,
})
