local LSD

local SetAbilityTracker = {}

local DebuffTracker = DebuffTracker

-- Credit goes to EPT by ExoY
DebuffTracker.SetAbilities = {

    [276] = { setName = "Tremorscale", abilityId = 80866},
	
	[389] = { setName = "Relequen", abilityId = 107203},
	
	[393] = { setName = "Relequen (Perfected)", abilityId = 107203},

    [455] = { setName = "Zen’s Redress", abilityId = 126597},

    [602] = { setName = "Crimson Oath’s Rive", abilityId = 159288},

    [622] = { setName = "Turning Tide", abilityId = 167061},

    [147] = { setName = "Martial Knowledge", abilityId = 127070},

    [180] = { setName = "Powerful Assault", abilityId = 61771},

    [634] = { setName = "Nunatak (Major Brittle)", abilityId = 145977},

    [232] = { setName = "Alkosh (Line-Breaker)", abilityId = 75753},

}

local function EnsureLSD()
    if not LSD then LSD = LibSetDetection end
    return LSD ~= nil
end

function SetAbilityTracker.GetSetIdsForAbility(abilityId)
    local setIds = {}

    for setId, setData in pairs(DebuffTracker.SetAbilities) do
        if type(setData.abilityId) == "table" then
            for _, abId in ipairs(setData.abilityId) do
                if abId == abilityId then
                    table.insert(setIds, setId)
                    break
                end
            end
        elseif setData.abilityId == abilityId then
            table.insert(setIds, setId)
        end
    end

    return setIds
end

function SetAbilityTracker.IsSetEquipped(setId)
    if not EnsureLSD() or not setId then return false end

    if LSD.AreUnitDataAvailable("player") then
        local setData = LSD.GetUnitSetData("player")
        if setData and setData[setId] and setData[setId].activeType and setData[setId].activeType ~= 0 then
            return true
        end
    end

    local availableUnitTags = LSD.GetAvailableUnitTags()
    for _, unitTag in ipairs(availableUnitTags) do
        if unitTag ~= "player" then
            local setData = LSD.GetUnitSetData(unitTag)
            if setData and setData[setId] and setData[setId].activeType and setData[setId].activeType ~= 0 then
                return true
            end
        end
    end

    return false
end




function SetAbilityTracker.ShouldTriggerReminder(abilityId)
    local setIds = SetAbilityTracker.GetSetIdsForAbility(abilityId)
    if not setIds or #setIds == 0 then return false end

    for _, setId in ipairs(setIds) do
        if SetAbilityTracker.IsSetEquipped(setId) then
            return true
        end
    end

    return false
end


return SetAbilityTracker

