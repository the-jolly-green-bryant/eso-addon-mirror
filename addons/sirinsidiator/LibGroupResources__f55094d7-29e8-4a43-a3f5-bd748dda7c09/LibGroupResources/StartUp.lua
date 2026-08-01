-- SPDX-FileCopyrightText: 2025 sirinsidiator
--
-- SPDX-License-Identifier: Artistic-2.0

local LGB = LibGroupBroadcast

local GroupResources = {}
local handler = LGB:RegisterHandler("LibGroupResources", "GroupResources")
handler:SetDisplayName("Group Resources")
handler:SetDescription("Sends information about your stamina and magicka to other group members.")
handler:SetApi(GroupResources)

function GroupResources:Initialize()
    local GroupResourceManager = GroupResources.GroupResourceManager
    local callbackManager = ZO_CallbackObject:New()
    local stamina = GroupResourceManager:New(handler, 10, "Stamina", COMBAT_MECHANIC_FLAGS_STAMINA, callbackManager, LGB)
    local magicka = GroupResourceManager:New(handler, 11, "Magicka", COMBAT_MECHANIC_FLAGS_MAGICKA, callbackManager, LGB)
    GroupResources.GroupResourceManager = nil
    GroupResources.Initialize = nil
    return stamina, magicka
end
