-- CharacterMarkdown - API Layer - Vengeance (Update 50 PvP loadouts)

local CM = CharacterMarkdown
CM.api = CM.api or {}
CM.api.vengeance = {}

local api = CM.api.vengeance

local function CleanName(name)
    if not name or type(name) ~= "string" then
        return name or "Unknown"
    end
    return name:gsub("%^%w+$", "")
end

function api.GetLoadoutSummary()
    local result = {
        available = false,
        roles = {},
        equippedRole = nil,
    }

    local numRoles = CM.SafeCall(GetNumberOfVengeanceRolesAvailableToPlayer) or 0
    if numRoles <= 0 then
        return result
    end

    result.available = true

    for roleIndex = 1, numRoles do
        local roleName = CleanName(CM.SafeCall(GetVengeanceRoleNameAtIndex, roleIndex) or ("Role " .. tostring(roleIndex)))
        local isEquipped = CM.SafeCall(IsLoadoutRoleEquippedAtIndex, roleIndex) or false

        local perks = {}
        local numPerks = CM.SafeCall(GetNumberOfPerksAvailableToLoadoutRoleDef, roleIndex) or 0
        for perkIndex = 1, numPerks do
            local perkName = CM.SafeCall(GetVengeancePerkNameAtIndex, perkIndex, roleIndex)
            if perkName and perkName ~= "" then
                table.insert(perks, {
                    index = perkIndex,
                    name = CleanName(perkName),
                })
            end
        end

        local roleEntry = {
            index = roleIndex,
            name = roleName,
            isEquipped = isEquipped,
            perks = perks,
            perkCount = #perks,
        }
        table.insert(result.roles, roleEntry)
        if isEquipped then
            result.equippedRole = roleEntry
        end
    end

    return result
end

CM.DebugPrint("API", "Vengeance API module loaded")
