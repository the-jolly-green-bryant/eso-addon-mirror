local C = Conductor
C.UltimatePatternRegistry = C.UltimatePatternRegistry or {}
local Registry = C.UltimatePatternRegistry

Registry.PATTERNS = {
    ALTERNATING_TEAMS = { id="ALTERNATING_TEAMS", label="Alternating Ultimate Teams", sequence={"ULTIMATE_TEAM_1","ULTIMATE_TEAM_2"} },
    SUPPORT_WITH_DD_TEAMS = { id="SUPPORT_WITH_DD_TEAMS", label="Support Package with DD Teams", sequence={"SUPPORT_PACKAGE_1","DD_TEAM_1","SUPPORT_PACKAGE_2","DD_TEAM_2"} },
    SUPPORT_ROTATION_ALL_DDS = { id="SUPPORT_ROTATION_ALL_DDS", label="Support Rotation then All DDs", sequence={"MAJOR_SLAYER","WARHORN","MAJOR_VULNERABILITY","DAMAGE_ULTIMATES"} },
    FULL_OPENING_BURN = { id="FULL_OPENING_BURN", label="Full Opening Burn", sequence={"MAJOR_SLAYER","WARHORN","MAJOR_VULNERABILITY","DAMAGE_ULTIMATES","HOLD"} },
    OPENING_RECOVERY_EXECUTE = { id="OPENING_RECOVERY_EXECUTE", label="Opening, Recovery, Execute", sequence={"OPENING_BURN","RECOVERY","EXECUTE_BURN"} },
    CUSTOM = { id="CUSTOM", label="Custom Sequence", sequence={} },
}
function Registry:Get(id) return self.PATTERNS[tostring(id or "")] end
function Registry:GetItems()
    local items = {}
    for _, id in ipairs({"ALTERNATING_TEAMS","SUPPORT_WITH_DD_TEAMS","SUPPORT_ROTATION_ALL_DDS","FULL_OPENING_BURN","OPENING_RECOVERY_EXECUTE","CUSTOM"}) do
        local pattern=self.PATTERNS[id]; items[#items+1]={name=pattern.label,data=id}
    end
    return items
end
