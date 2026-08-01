-- SPDX-FileCopyrightText: 2025 sirinsidiator
--
-- SPDX-License-Identifier: Artistic-2.0

local GroupResources = LibGroupBroadcast:GetHandlerApi("GroupResources")
local stamina, magicka = GroupResources:Initialize()

function GroupResources:RegisterForStaminaChanges(callback)
    return stamina:RegisterForChanges(callback)
end

function GroupResources:UnregisterForStaminaChanges(callback)
    return stamina:UnregisterForChanges(callback)
end

function GroupResources:GetStamina(unitTag)
    return stamina:GetValues(unitTag)
end

function GroupResources:GetLastStaminaUpdateTime(unitTag)
    return stamina:GetLastUpdateTime(unitTag)
end

function GroupResources:RegisterForMagickaChanges(callback)
    return magicka:RegisterForChanges(callback)
end

function GroupResources:UnregisterForMagickaChanges(callback)
    return magicka:UnregisterForChanges(callback)
end

function GroupResources:GetMagicka(unitTag)
    return magicka:GetValues(unitTag)
end

function GroupResources:GetLastMagickaUpdateTime(unitTag)
    return magicka:GetLastUpdateTime(unitTag)
end
