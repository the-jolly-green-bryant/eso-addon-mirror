local CC = CombatCoordination

----------------------------------------------------------------------------------------------------
-- ENABLE / REGISTER EVENTS
----------------------------------------------------------------------------------------------------
function CC.Enable()
    if not CC.SV.enableAddon then return end

    EVENT_MANAGER:RegisterForEvent(CC.NAME .. "EVENT_INVENTORY_SINGLE_SLOT_UPDATE", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function(...) CC.Events:OnInventorySingleSlotUpdate(...) end)
    EVENT_MANAGER:AddFilterForEvent(CC.NAME .. "EVENT_INVENTORY_SINGLE_SLOT_UPDATE", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_WORN, REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DEFAULT)

    EVENT_MANAGER:RegisterForEvent(CC.NAME .. "EVENT_PLAYER_ACTIVATED", EVENT_PLAYER_ACTIVATED, function(...) CC.Events:OnPlayerActivated(...) end)
    EVENT_MANAGER:RegisterForEvent(CC.NAME .. "EVENT_ACTION_SLOT_ABILITY_USED", EVENT_ACTION_SLOT_ABILITY_USED, function(...) CC.Events:OnActionSlotAbilityUsed(...) end)
    EVENT_MANAGER:RegisterForEvent(CC.NAME .. "EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED", EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED, function() CC.SkillBlocker:UpdateEquippedSkills() end)
    EVENT_MANAGER:RegisterForEvent(CC.NAME .. "EVENT_GROUP_MEMBER_JOINED", EVENT_GROUP_MEMBER_JOINED, function(...) CC.Events:OnGroupMemberJoined(...) end)
    EVENT_MANAGER:RegisterForEvent(CC.NAME .. "EVENT_GROUP_MEMBER_LEFT", EVENT_GROUP_MEMBER_LEFT, function(...) CC.Events:OnGroupMemberLeft(...) end)
    EVENT_MANAGER:RegisterForEvent(CC.NAME .. "EVENT_UNIT_DEATH_STATE_CHANGED", EVENT_UNIT_DEATH_STATE_CHANGED, function(...) CC.DeathMarker:OnDeathStateChanged(...) end)

    -- COMBAT EVENT
    for abilityId, _ in pairs(CC.Events.SkillModules) do
        local name = CC.NAME .. "EVENT_COMBAT_EVENT_" .. tostring(abilityId)
        EVENT_MANAGER:RegisterForEvent(name, EVENT_COMBAT_EVENT, function(...) CC.Events:OnCombatEvent(...) end)
        EVENT_MANAGER:AddFilterForEvent(name, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, abilityId)
    end

    -- EFFECT CHANGED
    local RegisteredBuffs = {}
    for buffId, _ in pairs(CC.Events.BuffModules) do RegisteredBuffs[buffId] = true end
    for buffId, _ in pairs(CC.SkillBlocker.BlockableBuffs) do RegisteredBuffs[buffId] = true end

    for buffId, _ in pairs(RegisteredBuffs) do
        local name = CC.NAME .. "EVENT_EFFECT_CHANGED_" .. tostring(buffId)
        EVENT_MANAGER:RegisterForEvent(name, EVENT_EFFECT_CHANGED, function(...) CC.Events:OnEffectChanged(...) end)
        EVENT_MANAGER:AddFilterForEvent(name, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player", REGISTER_FILTER_ABILITY_ID, buffId)
    end

    for _, Module in ipairs(CC.Modules) do
        if Module.CustomEnable then
            Module:CustomEnable()
        end
    end

    CC.CreateChatButton()

    CC.Events:OnPlayerActivated()
    CC.addOnLoaded = true
end

----------------------------------------------------------------------------------------------------
-- DISABLE (MASTERSWITCH OFF)
----------------------------------------------------------------------------------------------------
function CC.Disable()
    EVENT_MANAGER:UnregisterForEvent(CC.NAME .. "EVENT_INVENTORY_SINGLE_SLOT_UPDATE", EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
    EVENT_MANAGER:UnregisterForEvent(CC.NAME .. "EVENT_PLAYER_ACTIVATED", EVENT_PLAYER_ACTIVATED)
    EVENT_MANAGER:UnregisterForEvent(CC.NAME .. "EVENT_ACTION_SLOT_ABILITY_USED", EVENT_ACTION_SLOT_ABILITY_USED)
    EVENT_MANAGER:UnregisterForEvent(CC.NAME .. "EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED", EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED)
    EVENT_MANAGER:UnregisterForEvent(CC.NAME .. "EVENT_GROUP_MEMBER_JOINED", EVENT_GROUP_MEMBER_JOINED)
    EVENT_MANAGER:UnregisterForEvent(CC.NAME .. "EVENT_GROUP_MEMBER_LEFT", EVENT_GROUP_MEMBER_LEFT)
    EVENT_MANAGER:UnregisterForEvent(CC.NAME .. "EVENT_UNIT_DEATH_STATE_CHANGED", EVENT_UNIT_DEATH_STATE_CHANGED)

    -- COMBAT EVENT
    for abilityId, _ in pairs(CC.Events.SkillModules) do
        EVENT_MANAGER:UnregisterForEvent(CC.NAME .. "EVENT_COMBAT_EVENT_" .. tostring(abilityId), EVENT_COMBAT_EVENT)
    end

    -- EFFECT CHANGED
    local RegisteredBuffs = {}
    for buffId, _ in pairs(CC.Events.BuffModules) do RegisteredBuffs[buffId] = true end
    for buffId, _ in pairs(CC.SkillBlocker.BlockableBuffs) do RegisteredBuffs[buffId] = true end

    for buffId, _ in pairs(RegisteredBuffs) do
        EVENT_MANAGER:UnregisterForEvent(CC.NAME .. "EVENT_EFFECT_CHANGED_" .. tostring(buffId), EVENT_EFFECT_CHANGED)
    end

    for _, Module in ipairs(CC.Modules) do
        if Module.CustomDisable then
            Module:CustomDisable()
        end
    end

    CC.addOnLoaded = false
end

----------------------------------------------------------------------------------------------------
-- INIT ALL MODULES
----------------------------------------------------------------------------------------------------
function CC.EnableAllModules()
    for _, Module in ipairs(CC.Modules) do

        -- DATABASE FROM MODULES (AND DATABASE.LUA OFC)
        if Module.SkillData then
            for abilityName, Data in pairs(Module.SkillData) do
                if Module.Skills and Module.Skills[abilityName] then
                    for _, abilityId in ipairs(Module.Skills[abilityName]) do
                        Data.moduleName = Module.name
                        Data.name = Data.name or abilityName
                        CC.SkillData[abilityId] = Data
                    end
                end

                if Module.Buffs and Module.Buffs[abilityName] then
                    for _, buffId in ipairs(Module.Buffs[abilityName]) do
                        Data.moduleName = Module.name
                        Data.name = Data.name or abilityName
                        CC.SkillData[buffId] = Data
                    end
                end
            end
        end

        -- SKILL BLOCKER
        if Module.SkillBlocker then
            for abilityName, buffList in pairs(Module.SkillBlocker) do

                -- REG BLOCKER
                local function RegisterBlocker(abilityId)
                    CC.SkillBlocker.BlockableSkills[abilityId] = true
                    if buffList then
                        for _, buffId in ipairs(buffList) do
                            CC.SkillBlocker.BlockableBuffs[buffId] = CC.SkillBlocker.BlockableBuffs[buffId] or {}
                            CC.SkillBlocker.BlockableBuffs[buffId][abilityId] = true
                        end
                    end
                end

                if Module.Skills and Module.Skills[abilityName] then
                    for _, abilityId in ipairs(Module.Skills[abilityName]) do
                        RegisterBlocker(abilityId)
                    end
                elseif Module.Buffs and Module.Buffs[abilityName] then
                    for _, abilityId in ipairs(Module.Buffs[abilityName]) do
                        RegisterBlocker(abilityId)
                    end
                end
            end
        end

        -- CALLBACK FUNCTIONS FOR COMBAT EVENTS
        if Module.Skills then
            for _, abilityList in pairs(Module.Skills) do
                for _, abilityId in ipairs(abilityList) do
                    if Module.HandleCombatEvent then
                        CC.Events.SkillModules[abilityId] = Module
                    end
                end
            end
        end

        -- CALLBACK FUNCTIONS FOR EFFECT CHANGED
        if Module.Buffs then
            for _, buffList in pairs(Module.Buffs) do
                for _, buffId in ipairs(buffList) do
                    if Module.HandleEffectChanged then
                        CC.Events.BuffModules[buffId] = Module
                    end
                end
            end
        end

        -- BROADCAST LUT
        if Module.Broadcast then
            for broadcastName, broadcastId in pairs(Module.Broadcast) do

                -- REG IN BROADCAST
                local function RegisterBroadcast(abilityId)
                    CC.Broadcast.LutDataIn[broadcastId] = abilityId
                    CC.Broadcast.LutDataOut[abilityId] = broadcastId
                    if Module.HandleBroadcast then
                        CC.Broadcast.BroadcastModules[abilityId] = Module
                    end
                    if CC.SkillData[abilityId] then
                        CC.SkillData[abilityId].broadcastId = broadcastId
                    end
                end

                if Module.Skills and Module.Skills[broadcastName] then
                    for _, abilityId in ipairs(Module.Skills[broadcastName]) do
                        RegisterBroadcast(abilityId)
                    end
                elseif Module.Buffs and Module.Buffs[broadcastName] then
                    for _, buffId in ipairs(Module.Buffs[broadcastName]) do
                        RegisterBroadcast(buffId)
                    end
                else
                    if Module.HandleBroadcast then
                        CC.Broadcast.BroadcastModules[broadcastId] = Module
                    end
                end
            end
        end
    end
end

----------------------------------------------------------------------------------------------------
-- PREVIEW
----------------------------------------------------------------------------------------------------
function CC.TogglePreview()
    CC.enablePreview = not CC.enablePreview
    if CC.enablePreview then
        d(CC.CHAT .. " |c00FF00Preview Enabled|r")
    else
        d(CC.CHAT .. " |cFF0000Preview Disabled|r")
    end
end
SLASH_COMMANDS["/cc_preview"] = CC.TogglePreview

----------------------------------------------------------------------------------------------------
-- LIBCHATMENUBUTTON
----------------------------------------------------------------------------------------------------
function CC.CreateChatButton()
    -- YEAH YEAH I KNOW.. IT'S IN THE DEPENDENCIES. BUT I MIGHT CHANGE THAT.
    if not LibChatMenuButton or CC.ChatButton then return end

    local icon = CC.NAME .. "/icons/combatcoordination_border.dds"
    local tooltip = "Combat Coordination Info Panel"

    -- REGISTER BUTTOON
    CC.ChatButton = LibChatMenuButton.addChatButton(
        CC.NAME .. "ChatButton", icon, tooltip,
        function() CC.DisplayPanel:Toggle() end
    )
end

----------------------------------------------------------------------------------------------------
-- INITIALIZE ADDON
----------------------------------------------------------------------------------------------------
function CC.Initialize()
    for key, Data in pairs(CC) do
        if type(Data) == "table" and Data.Default then
            CC.Default[key] = Data.Default
        end
    end

    CC.SV = ZO_SavedVars:NewAccountWide(CC.SVName, CC.SVVersion, GetWorldName(), CC.Default)

    for key, Data in pairs(CC) do
        if type(Data) == "table" and Data.Default then
            Data.SV = CC.SV[key]
        end
    end

    math.randomseed(GetGameTimeMilliseconds())
    math.random() math.random() math.random()

    CC.EnableAllModules()
    CC.CreateSettings()
    CC.Enable()
end

----------------------------------------------------------------------------------------------------
-- JEFF; MY NAME IS JEFF!
----------------------------------------------------------------------------------------------------
EVENT_MANAGER:RegisterForEvent(CC.NAME, EVENT_ADD_ON_LOADED, function(eventCode, addonName)
    if addonName == CC.NAME then
        CC.Initialize()
        EVENT_MANAGER:UnregisterForEvent(CC.NAME, EVENT_ADD_ON_LOADED)
    end
end)