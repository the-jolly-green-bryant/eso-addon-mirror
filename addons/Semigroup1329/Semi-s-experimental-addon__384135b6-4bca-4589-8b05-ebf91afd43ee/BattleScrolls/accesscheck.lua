local SemisPlaygroundAllowList = {
    ["@Semigroup"] = true,
    ["@Semigroup1329"] = true,
    ["@ShellingPlace71"] = true,
    ["@WiIdWhim"] = true,
    ["@HEROni"] = true,
    ["@Jehlina89"] = true,
    ["@D14 Diabolos"] = true,
    ["@PumaDAsceDE"] = true,
    ["@InVictus2321"] = true,
    ["@Kyle_Pragmatic"] = true
}

function SemisPlaygroundCheckAccess()
    local displayName = GetDisplayName()
    if SemisPlaygroundAllowList[displayName] then
        return true
    else
        return false
    end
end
