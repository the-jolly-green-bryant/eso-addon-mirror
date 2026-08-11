local CC = CombatCoordination

----------------------------------------------------------------------------------------------------
-- ENABLE / REGISTER EVENTS
----------------------------------------------------------------------------------------------------
function CC.Enable()
    if not CC.SV.enableAddon then return end

    EVENT_MANAGER:RegisterForEvent(CC.NAME .. "EVENT_INVENTORY_SINGLE_SLOT_UPDATE", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function(...) CC.Events:OnInventorySingleSlotUpdate(...) end)
    EVENT_MANAGER:RegisterForEvent(CC.NAME .. "EVENT_PLAYER_ACTIVATED", EVENT_PLAYER_ACTIVATED, function(...) CC.Events:OnPlayerActivated(...) end)
    EVENT_MANAGER:RegisterForEvent(CC.NAME .. "EVENT_ACTION_SLOT_ABILITY_USED", EVENT_ACTION_SLOT_ABILITY_USED, function(...) CC.Events:OnActionSlotAbilityUsed(...) end)
    EVENT_MANAGER:RegisterForEvent(CC.NAME .. "EVENT_COMBAT_EVENT", EVENT_COMBAT_EVENT, function(...) CC.Events:OnCombatEvent(...) end)
    EVENT_MANAGER:RegisterForEvent(CC.NAME .. "EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED", EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED, function() CC.SkillBlocker:UpdateEquippedSkills() end)
    EVENT_MANAGER:RegisterForEvent(CC.NAME .. "EVENT_EFFECT_CHANGED", EVENT_EFFECT_CHANGED, function(...) CC.Events:OnEffectChanged(...) end)
    EVENT_MANAGER:RegisterForEvent(CC.NAME .. "EVENT_GROUP_MEMBER_JOINED", EVENT_GROUP_MEMBER_JOINED, function(...) CC.Events:OnGroupMemberJoined(...) end)
    EVENT_MANAGER:RegisterForEvent(CC.NAME .. "EVENT_GROUP_MEMBER_LEFT", EVENT_GROUP_MEMBER_LEFT, function(...) CC.Events:OnGroupMemberLeft(...) end)
    EVENT_MANAGER:RegisterForEvent(CC.NAME .. "EVENT_UNIT_DEATH_STATE_CHANGED", EVENT_UNIT_DEATH_STATE_CHANGED, function(...) CC.DeathMarker:OnDeathStateChanged(...) end)

    -- FILTER
    EVENT_MANAGER:AddFilterForEvent(CC.NAME .. "EVENT_EFFECT_CHANGED", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")
    EVENT_MANAGER:AddFilterForEvent(CC.NAME .. "EVENT_INVENTORY_SINGLE_SLOT_UPDATE", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_WORN)

    CC.CreateChatButton()

    CC.addOnLoaded = true
end

----------------------------------------------------------------------------------------------------
-- DISABLE (MASTERSWITCH OFF)
----------------------------------------------------------------------------------------------------
function CC.Disable()

    EVENT_MANAGER:UnregisterForEvent(CC.NAME .. "EVENT_INVENTORY_SINGLE_SLOT_UPDATE", EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
    EVENT_MANAGER:UnregisterForEvent(CC.NAME .. "EVENT_PLAYER_ACTIVATED", EVENT_PLAYER_ACTIVATED)
    EVENT_MANAGER:UnregisterForEvent(CC.NAME .. "EVENT_ACTION_SLOT_ABILITY_USED", EVENT_ACTION_SLOT_ABILITY_USED)
    EVENT_MANAGER:UnregisterForEvent(CC.NAME .. "EVENT_COMBAT_EVENT", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(CC.NAME .. "EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED", EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED)
    EVENT_MANAGER:UnregisterForEvent(CC.NAME .. "EVENT_EFFECT_CHANGED", EVENT_EFFECT_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(CC.NAME .. "EVENT_GROUP_MEMBER_JOINED", EVENT_GROUP_MEMBER_JOINED)
    EVENT_MANAGER:UnregisterForEvent(CC.NAME .. "EVENT_GROUP_MEMBER_LEFT", EVENT_GROUP_MEMBER_LEFT)
    EVENT_MANAGER:UnregisterForEvent(CC.NAME .. "EVENT_UNIT_DEATH_STATE_CHANGED", EVENT_UNIT_DEATH_STATE_CHANGED)

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
                if Module.CombatEvent and Module.CombatEvent[abilityName] then
                    for _, abilityId in ipairs(Module.CombatEvent[abilityName]) do
                        Data.moduleName = Module.name
                        Data.name = Data.name or abilityName

                        CC.SkillData[abilityId] = Data
                    end
                end
            end
        end

        -- SKILL BLOCKER
        if Module.SkillBlocker then
            for abilityName, buffList in pairs(Module.SkillBlocker) do
                if Module.CombatEvent and Module.CombatEvent[abilityName] then
                    for _, abilityId in ipairs(Module.CombatEvent[abilityName]) do
                        CC.SkillBlocker.BlockableSkills[abilityId] = true

                        if buffList then
                            for _, buffId in ipairs(buffList) do
                                CC.SkillBlocker.BlockableBuffs[buffId] = CC.SkillBlocker.BlockableBuffs[buffId] or {}
                                CC.SkillBlocker.BlockableBuffs[buffId][abilityId] = true
                            end
                        end
                    end
                end
            end
        end

        -- CALLBACK FUNCTIONS FOR COMBAT EVENTS
        if Module.CombatEvent then
            for _, abilityList in pairs(Module.CombatEvent) do
                for _, abilityId in ipairs(abilityList) do
                    if Module.HandleCombatEvent then
                        CC.Events.CallbackModules[abilityId] = Module
                    end
                end
            end
        end

        -- BROADCAST LUT
        if Module.Broadcast then
            for broadcastName, broadcastId in pairs(Module.Broadcast) do
                -- EVENT ID AND PROTOCOL ID
                if Module.CombatEvent and Module.CombatEvent[broadcastName] then
                    for _, abilityId in ipairs(Module.CombatEvent[broadcastName]) do

                        CC.Broadcast.LutDataIn[broadcastId] = abilityId
                        CC.Broadcast.LutDataOut[abilityId] = broadcastId

                        if Module.HandleBroadcast then
                            CC.Broadcast.CallbackModules[abilityId] = Module
                        end

                        if CC.SkillData[abilityId] then
                            CC.SkillData[abilityId].broadcastId = broadcastId
                        end
                    end
                -- PROTOCOL ID (PING, TIMERS, DRAWSHAPE..)
                else
                    if Module.HandleBroadcast then
                        CC.Broadcast.CallbackModules[broadcastId] = Module
                    end
                end
            end
        end

        -- HAS ITS OWN SPECIAL SNOWFLAKE ENABLE? I GUESS I REMOVED THEM ALL BY NOW. MAYBE.
        -- EDIT: NOPE.. CUSTOM MENU STILL RUNS IT
        if Module.CustomEnable then
            Module:CustomEnable()
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

    if not CC.SV.enableAddon then return end

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