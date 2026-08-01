AutoBanishPets = AutoBanishPets or {}
local AutoBanishPets = AutoBanishPets

----------------------
--INITIATE VARIABLES--
----------------------
AutoBanishPets.name = "AutoBanishPets"
AutoBanishPets.version = "0.8.0"
AutoBanishPets.variableVersion = 10
AutoBanishPets.defaultSettings = {
    ["notification"] = true,
    ["noPetsAllowed"] = false,
    ["exit"] = false,
    ["bank"] = {
        ["pets"] = true,
        ["vanityPets"] = false,
        ["assistants"] = false,
        [9245] = false,
        [9353] = false,
        [9911] = false,
        [9912] = false,
        [11113] = false,
        [11114] = false,
    },
    ["guildBank"] = {
        ["pets"] = true,
        ["vanityPets"] = false,
        ["assistants"] = false,
        [9245] = false,
        [9353] = false,
        [9911] = false,
        [9912] = false,
        [11113] = false,
        [11114] = false,
    },
    ["store"] = {
        ["pets"] = true,
        ["vanityPets"] = false,
        ["assistants"] = false,
        [9245] = false,
        [9353] = false,
        [9911] = false,
        [9912] = false,
        [11113] = false,
        [11114] = false,
    },
    ["guildStore"] = {
        ["pets"] = true,
        ["vanityPets"] = false,
        ["assistants"] = false,
        [9245] = false,
        [9353] = false,
        [9911] = false,
        [9912] = false,
        [11113] = false,
        [11114] = false,
    },
    ["fence"] = {
        ["pets"] = true,
        ["vanityPets"] = false,
        ["assistants"] = false,
        [9245] = false,
        [9353] = false,
        [9911] = false,
        [9912] = false,
        [11113] = false,
        [11114] = false,
    },
    ["craftStation"] = {
        ["pets"] = true,
        ["vanityPets"] = false,
        ["assistants"] = false,
        [9245] = false,
        [9353] = false,
        [9911] = false,
        [9912] = false,
        [11113] = false,
        [11114] = false,
    },
    ["dyeingStation"] = {
        ["pets"] = true,
        ["vanityPets"] = false,
        ["assistants"] = false,
        [9245] = false,
        [9353] = false,
        [9911] = false,
        [9912] = false,
        [11113] = true,
        [11114] = false,
    },
    ["retraitStation"] = {
        ["pets"] = true,
        ["vanityPets"] = false,
        ["assistants"] = false,
        [9245] = false,
        [9353] = false,
        [9911] = false,
        [9912] = false,
        [11113] = false,
        [11114] = false,
    },
    ["wayshrine"] = {
        ["pets"] = true,
        ["vanityPets"] = false,
        ["assistants"] = false,
        [9245] = false,
        [9353] = false,
        [9911] = false,
        [9912] = false,
        [11113] = false,
        [11114] = false,
    },
    ["quest"] = {
        ["pets"] = true,
        ["vanityPets"] = false,
        ["assistants"] = false,
        [9245] = false,
        [9353] = false,
        [9911] = false,
        [9912] = false,
        [11113] = false,
        [11114] = false,
    },
    ["combat"] = {
        ["pets"] = false,
        ["vanityPets"] = 2,
        ["assistants"] = 2,
        ["companions"] = {
            [9245] = 1,
            [9353] = 1,
            [9911] = 1,
            [9912] = 1,
            [11113] = 1,
            [11114] = 1,
        },
    },
    ["stealth"] = {
        ["pets"] = false,
        ["vanityPets"] = 1,
        ["assistants"] = 1,
        ["companions"] = {
            [9245] = 2,
            [9353] = 2,
            [9911] = 2,
            [9912] = 2,
            [11113] = 2,
            [11114] = 2,
        },
    },
    ["logout"] = {
        ["pets"] = false,
        ["vanityPets"] = false,
        ["assistants"] = false,
        [9245] = false,
        [9353] = false,
        [9911] = false,
        [9912] = false,
        [11113] = false,
        [11114] = false,
    },
    ["thievesTrove"] = {
        ["pets"] = false,
        ["vanityPets"] = false,
        ["assistants"] = false,
        [9245] = true,
        [9353] = false,
        [9911] = false,
        [9912] = true,
        [11113] = false,
        [11114] = false,
    },
    ["harvesting"] = {
        ["pets"] = false,
        ["vanityPets"] = false,
        ["assistants"] = false,
        [9245] = false,
        [9353] = true,
        [9911] = false,
        [9912] = false,
        [11113] = false,
        [11114] = true,
    },
    ["fishing"] = {
        ["pets"] = false,
        ["vanityPets"] = false,
        ["assistants"] = false,
        [9245] = false,
        [9353] = false,
        [9911] = true,
        [9912] = false,
        [11113] = false,
        [11114] = false,
    },
    ["steal"] = {
        ["pets"] = false,
        ["vanityPets"] = false,
        ["assistants"] = false,
        [9245] = true,
        [9353] = false,
        [9911] = true,
        [9912] = true,
        [11113] = true,
        [11114] = false,
    },
    ["arrested"] = {
        ["pets"] = false,
        ["vanityPets"] = false,
        ["assistants"] = false,
        [9245] = true,
        [9353] = false,
        [9911] = true,
        [9912] = false,
        [11113] = true,
        [11114] = false,
    },
    ["vampire"] = {
        ["pets"] = false,
        ["vanityPets"] = false,
        ["assistants"] = false,
        [9245] = false,
        [9353] = false,
        [9911] = false,
        [9912] = false,
        [11113] = false,
        [11114] = false,
    },
    ["werewolf"] = {
        ["pets"] = false,
        ["vanityPets"] = false,
        ["assistants"] = false,
        [9245] = false,
        [9353] = false,
        [9911] = false,
        [9912] = false,
        [11113] = false,
        [11114] = false,
    },
    ["location"] = {
        ["pets"] = false,
        ["vanityPets"] = false,
        ["assistants"] = false,
        [9245] = false,
        [9353] = true,
        [9911] = false,
        [9912] = true,
        [11113] = false,
        [11114] = true,
    },
    ["provisioning"] = {
        ["pets"] = false,
        ["vanityPets"] = false,
        ["assistants"] = false,
        [9245] = true,
        [9353] = false,
        [9911] = false,
        [9912] = false,
        [11113] = false,
        [11114] = true,
    }
}
local EM = EVENT_MANAGER
local messages = {
    ["banish"] = {
        ["pets"] = string.format("|cf10000%s|r", GetString(ABP_NOTIFICATION_PETS)),
        ["vanityPets"] = string.format("|cf10000%s|r", GetString(ABP_NOTIFICATION_VANITY_PETS)),
        ["assistants"] = string.format("|cf10000%s|r", GetString(ABP_NOTIFICATION_ASSISTANTS)),
        ["companions"] = string.format("|cf10000%s|r", GetString(ABP_NOTIFICATION_COMPANIONS)),
    },
    ["resummon"] = {
        ["pets"] = string.format("|c43ad53%s|r", GetString(ABP_NOTIFICATION_RESUMMON_PETS)),
        ["vanityPets"] = string.format("|c43ad53%s|r", GetString(ABP_NOTIFICATION_RESUMMON_VANITY_PETS)),
        ["assistants"] = string.format("|c43ad53%s|r", GetString(ABP_NOTIFICATION_RESUMMON_ASSISTANTS)),
        ["companions"] = string.format("|c43ad53%s|r", GetString(ABP_NOTIFICATION_RESUMMON_COMPANIONS)),
    },
}

---------------------
--WRAPPER FUNCTIONS--
---------------------
-- Return true if daily
local function isDaily(journalIndex)
    return (GetJournalQuestRepeatType(journalIndex) == QUEST_REPEAT_DAILY)
end

-- RegisterForUpdate
local function RegisterUpdate(collectibleId, toggle, key, second)
    local delay
    local cooldownRemaining, cooldownDuration = GetCollectibleCooldownAndDuration(collectibleId)
    if (cooldownRemaining > second) then
        delay = cooldownRemaining
    else
        delay = second
    end

    local ns = string.format("%s_%s", AutoBanishPets.name, key)
    zo_callLater(
        function()
            EM:UnregisterForUpdate(ns)
            EM:RegisterForUpdate(ns, 100, function() AutoBanishPets.ToggleCollectible(collectibleId, toggle, key) end)
        end, delay)
end

-- UnregisterForUpdate
local function UnregisterUpdate(key)
    local ns = string.format("%s_%s", AutoBanishPets.name, key)
    EM:UnregisterForUpdate(ns)
    AutoBanishPets.isToggling[key] = false
end

-- Toggle collectible
-- Activate collectible if toggle == true, inactivate if toggle == false
function AutoBanishPets.ToggleCollectible(collectibleId, toggle, key)
    -- Get active collectibleId
    local activeId
    if (key == "vanityPets") then
        activeId = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_VANITY_PET)
    elseif (key == "assistants") then
        activeId = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_ASSISTANT)
    elseif (key == "companions") then
        activeId = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_COMPANION)
    end

    if not AutoBanishPets.isToggling[key] then -- So this is the first toggling
        -- Already active/inactive
        if (toggle and activeId ~= 0) or (not toggle and activeId == 0) then
            UnregisterUpdate(key)
        -- Player changed collectible manually during cooldown
        elseif (activeId ~= 0 and activeId ~= collectibleId) then
            UnregisterUpdate(key)
        -- Do not summon in combat
        elseif (toggle and IsUnitInCombat("player")) then
            UnregisterUpdate(key)
        -- Then toggle
        elseif (IsCollectibleActive(collectibleId) ~= toggle and not IsCollectibleBlocked(collectibleId)) then
            UseCollectible(collectibleId)
            AutoBanishPets.isToggling[key] = true
        end
    else
        -- Toggling done
        if (IsCollectibleActive(collectibleId) == toggle) then
            UnregisterUpdate(key)
            if AutoBanishPets.savedVariables.notification then
                if toggle then
                    df("[%s] %s", AutoBanishPets.name, messages.resummon[key])
                else
                    df("[%s] %s", AutoBanishPets.name, messages.banish[key])
                end
            end
        end
    end
end

---------------------
--DISMISS FUNCTIONS--
---------------------
-- Dismiss combat pets
function AutoBanishPets.BanishPets()
    local unitClassId = AutoBanishPets.unitClassId
    local abilities = AutoBanishPets.abilities -- AutoBanishPetsAbilities.lua
    if not abilities[SKILL_TYPE_CLASS][unitClassId] then return end

    local isBanished = false
	for i = 1, GetNumBuffs("player") do
		local _, _, _, buffSlot, _, _, _, _, _, _, abilityId, _ = GetUnitBuffInfo("player", i)
        if abilities[SKILL_TYPE_CLASS][unitClassId][abilityId] then
            isBanished = true
            CancelBuff(buffSlot)
        end
	end
    -- Notify once
    if isBanished then
        if AutoBanishPets.savedVariables.notification then
            df("[%s] %s", AutoBanishPets.name, messages.banish["pets"])
        end
    end
end

-- Dismiss vanity pets
function AutoBanishPets.BanishVanityPets(collectibleId)
    local targetId
    local activeId = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_VANITY_PET)
    if (activeId == 0) then return end -- No active non-combat pet

    if not collectibleId then -- Manual banishment
        targetId = activeId
    else
        targetId = collectibleId
    end
    UnregisterUpdate("vanityPets")
    RegisterUpdate(targetId, false, "vanityPets", 0)
end

-- Dismiss assistants
function AutoBanishPets.BanishAssistants(collectibleId)
    local targetId
    local activeId = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_ASSISTANT)
    if (activeId == 0) then return end -- No active assistant

    if not collectibleId then -- Manual banishment
        targetId = activeId
    else
        targetId = collectibleId
    end
    UnregisterUpdate("assistants")
    RegisterUpdate(targetId, false, "assistants", 0)
end

-- Dismiss companions
function AutoBanishPets.BanishCompanions(collectibleId)
    local targetId
    local activeId = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_COMPANION)
    if (activeId == 0) then return end -- No active companion

    if not collectibleId then -- Manual banishment
        targetId = activeId
    else
        targetId = collectibleId
    end
    if (targetId ~= activeId) then return end -- Different companion
    -- TODO: Manage pending
    UnregisterUpdate("companions")
    RegisterUpdate(targetId, false, "companions", 0)
end

-- For Bindings.xml
function AutoBanishPets.BanishAll()
    AutoBanishPets.BanishPets()
    AutoBanishPets.BanishVanityPets()
    AutoBanishPets.BanishAssistants()
    AutoBanishPets.BanishCompanions()
end

-- Toggle No-Pets-Allowed
function AutoBanishPets.ToggleNPA(enable)
    local unitClassId = AutoBanishPets.unitClassId
    local abilities = AutoBanishPets.abilities -- AutoBanishPetsAbilities.lua
    if not abilities[SKILL_TYPE_CLASS][unitClassId] then return end

    if (AutoBanishPets.savedVariables.notification and enable ~= AutoBanishPets.savedVariables.noPetsAllowed) then
        if enable then
            df("[%s] |cf10000NO-PETS-ALLOWED|r: %s", AutoBanishPets.name, GetString(SI_CHECK_BUTTON_ON))
        else
            df("[%s] |c43ad53NO-PETS-ALLOWED|r: %s", AutoBanishPets.name, GetString(SI_CHECK_BUTTON_OFF))
        end
    end

    if enable then
        AutoBanishPets.BanishPets()
        EM:RegisterForEvent(AutoBanishPets.name .. "_NPA", EVENT_UNIT_CREATED, AutoBanishPets.BanishPets)
        EM:AddFilterForEvent(AutoBanishPets.name .. "_NPA", EVENT_UNIT_CREATED, REGISTER_FILTER_UNIT_TAG_PREFIX, "playerpet")
        AutoBanishPets.savedVariables.noPetsAllowed = true
    else
        EM:UnregisterForEvent(AutoBanishPets.name .. "_NPA", EVENT_UNIT_CREATED)
        AutoBanishPets.savedVariables.noPetsAllowed = false
    end
end

----------------------
--RESUMMON FUNCTIONS--
----------------------
-- Resummon combat pets
function AutoBanishPets.ResummonPets(collectibleId)
    -- Resummoning combat pets via API is not allowed
    return
end

-- Resummon vanity pets
function AutoBanishPets.ResummonVanityPets()
    if IsUnitInCombat("player") then
        return
    end

    local targetId = AutoBanishPets.lastId["vanityPets"]
    if targetId == 0 then return end

    UnregisterUpdate("vanityPets")
    RegisterUpdate(targetId, true, "vanityPets", 0)
end

-- Resummon assistants
function AutoBanishPets.ResummonAssistants()
    if IsUnitInCombat("player") then
        return
    end
    -- Manage conflict between assistants and companions
    local activeCompanionId = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_COMPANION)
    if (activeCompanionId ~= 0) then return end

    local targetId = AutoBanishPets.lastId["assistants"]
    if targetId == 0 then return end

    UnregisterUpdate("assistants")
    RegisterUpdate(targetId, true, "assistants", 0)
end

-- Resummon companions
function AutoBanishPets.ResummonCompanions()
    if IsUnitInCombat("player") then
        return
    end
    -- Manage conflict between assistants and companions
    local activeAssistantId = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_ASSISTANT)
    if (activeAssistantId ~= 0) then return end

    local targetId = AutoBanishPets.lastId["companions"]
    if targetId == 0 then return end

    UnregisterUpdate("companions")
    RegisterUpdate(targetId, true, "companions", 0)
end

-- For Bindings.xml
function AutoBanishPets.ResummonAll()
    AutoBanishPets.ResummonPets()
    AutoBanishPets.ResummonCompanions()
    AutoBanishPets.ResummonAssistants()
    AutoBanishPets.ResummonVanityPets()
end

-------------------
--EVENT FUNCTIONS--
-------------------
-- Combat events
function AutoBanishPets.onCombat(eventCode, inCombat)
    local activeId, targetId
    local sV = AutoBanishPets.savedVariables

    -- Start
    if inCombat then
        -- Dismiss non-combat pets
        if (sV.combat.vanityPets > 1) then
            activeId = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_VANITY_PET)
            if (activeId ~= 0) then
                AutoBanishPets.BanishVanityPets(activeId)
            end
        end

        -- Dismiss assistants
        if (sV.combat.assistants > 1) then
            activeId = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_ASSISTANT)
            if (activeId ~= 0) then
                AutoBanishPets.BanishAssistants(activeId)
            end
        end
    -- End
    else
        -- Dismiss combat pets
        if sV.combat.pets then
            AutoBanishPets.BanishPets()
        end

        -- Resummon non-combat pets
        if (sV.combat.vanityPets > 2) then
            AutoBanishPets.ResummonVanityPets()
        end

        -- Resummon assistants
        if (sV.combat.assistants > 2) then
            AutoBanishPets.ResummonAssistants()
        end

        -- Dismiss/Resummon companions
        for k, v in pairs(sV.combat.companions) do
            -- Dismiss
            if (v > 1) then
                activeId = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_COMPANION)
                if (activeId == k) then
                    AutoBanishPets.BanishCompanions(k)
                end
            end
            -- Resummon
            if (v > 2) then
                AutoBanishPets.ResummonCompanions()
            end
        end
    end
end

-- Stealth events
function AutoBanishPets.onStealth(eventCode, unitTag, stealthState)
    local activeId, targetId
    local sV = AutoBanishPets.savedVariables

    -- Start
    if (stealthState > 0) then
        -- Dismiss combat pets
        if sV.stealth.pets then
            AutoBanishPets.BanishPets()
        end

        -- Dismiss non-combat pets
        if (sV.stealth.vanityPets > 1) then
            activeId = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_VANITY_PET)
            if (activeId ~= 0) then
                AutoBanishPets.BanishVanityPets(activeId)
            end
        end

        -- Dismiss assistants
        if (sV.stealth.assistants > 1) then
            activeId = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_ASSISTANT)
            if (activeId ~= 0) then
                AutoBanishPets.BanishAssistants(activeId)
            end
        end

        -- Dismiss companions
        for k, v in pairs(sV.stealth.companions) do
            -- Dismiss
            if (v > 1) then
                activeId = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_COMPANION)
                if (activeId == k) then
                    AutoBanishPets.BanishCompanions(k)
                end
            end
        end
    -- End
    else
        -- Resummon non-combat pets
        if (sV.stealth.vanityPets > 2) then
            AutoBanishPets.ResummonVanityPets()
        end

        -- Resummon assistants
        if (sV.stealth.assistants > 2) then
            AutoBanishPets.ResummonAssistants()
        end

        -- Resummon companions
        for k, v in pairs(sV.stealth.companions) do
            if (v > 2) then
                AutoBanishPets.ResummonCompanions()
            end
        end
    end
end

-- Other events
function AutoBanishPets.onEventTriggered(eventCode, arg1, arg2)
    local sV = AutoBanishPets.savedVariables

    -- Dailies
    -- EVENT_QUEST_ADDED (number eventCode, number journalIndex, string questName, string objectiveName)
    -- EVENT_QUEST_COMPLETE_DIALOG (number eventCode, number journalIndex)
    if (eventCode == EVENT_QUEST_ADDED or eventCode == EVENT_QUEST_COMPLETE_DIALOG) then
        for k, v in pairs(sV.quest) do
            if (v and isDaily(arg1)) then
                if (k == "pets") then
                    AutoBanishPets.BanishPets()
                elseif (k == "vanityPets") then
                    AutoBanishPets.BanishVanityPets()
                elseif (k == "assistants") then
                    AutoBanishPets.BanishAssistants()
                else
                    AutoBanishPets.BanishCompanions(k)
                end
            end
        end
        return
    end

    -- Interaction
    if (eventCode == EVENT_CLIENT_INTERACT_RESULT) then
        -- Thieves Trove
        if AutoBanishPets.thievesTrove[arg2] then
            for k, v in pairs(sV.thievesTrove) do
                if (k == "pets") or (k == "vanityPets") or (k == "assistants") then
                    -- Do nothing
                elseif v then
                    AutoBanishPets.BanishCompanions(k)
                end
            end
        else
            -- Open the door which companions dislike
            for k, v in pairs(sV.location) do
                if (k == "pets") or (k == "vanityPets") or (k == "assistants") then
                    -- Do nothing
                elseif v then
                    for zoneId, _ in pairs(AutoBanishPets.locations[k]) do
                        if (arg2 == GetZoneNameById(zoneId)) then
                            AutoBanishPets.BanishCompanions(k)
                        end
                    end
                end
            end
        end
        return
    end

    -- Exit option for assistants
    -- Bankers
    if (eventCode == EVENT_CLOSE_BANK) then
        if sV.exit then
            local activeId = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_ASSISTANT)
            if AutoBanishPets.bankers[activeId] then
                AutoBanishPets.BanishAssistants(activeId)
            end
        end
        return
    end
    -- Merchants and fences
    if (eventCode == EVENT_CLOSE_STORE) then
        if sV.exit then
            local activeId = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_ASSISTANT)
            if AutoBanishPets.merchants[activeId] or AutoBanishPets.fences[activeId] then
                AutoBanishPets.BanishAssistants(activeId)
            end
        end
        return
    end
    -- Armory assistants
    -- TODO: There does not exist EVENT_CLOSE_ARMORY!

    -- CraftStation
    if (eventCode == EVENT_CRAFTING_STATION_INTERACT) then
        local activeId = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_ASSISTANT)
        if (AutoBanishPets.otherAssistants[activeId]) then return end

        for k, v in pairs(sV.craftStation) do
            if v then
                if (k == "pets") then
                    AutoBanishPets.BanishPets()
                elseif (k == "vanityPets") then
                    AutoBanishPets.BanishVanityPets()
                elseif (k == "assistants") then
                    AutoBanishPets.BanishAssistants()
                else
                    AutoBanishPets.BanishCompanions(k)
                end
            end
        end
        return
    end

    -- Others
    local eventKeys = {
        [EVENT_OPEN_BANK] = "bank",
        [EVENT_OPEN_GUILD_BANK] = "guildBank",
        [EVENT_OPEN_STORE] = "store",
        [EVENT_OPEN_TRADING_HOUSE] = "guildStore",
        [EVENT_OPEN_FENCE] = "fence",
        [EVENT_DYEING_STATION_INTERACT_START] = "dyeingStation",
        [EVENT_RETRAIT_STATION_INTERACT_START] = "retraitStation",
        [EVENT_START_FAST_TRAVEL_INTERACTION] = "wayshrine",
        [EVENT_JUSTICE_BEING_ARRESTED] = "arrested",
    }
    for k, v in pairs(sV[eventKeys[eventCode]]) do
        if v then
            if (k == "pets") then
                AutoBanishPets.BanishPets()
            elseif (k == "vanityPets") then
                AutoBanishPets.BanishVanityPets()
            elseif (k == "assistants") then
                AutoBanishPets.BanishAssistants()
            else
                AutoBanishPets.BanishCompanions(k)
            end
        end
    end
end

-- Trigger on Logout
function AutoBanishPets.onLogout()
    -- Dismiss combat pets
    AutoBanishPets.BanishPets()
    -- Assistants are disabled automatically at logout.
    -- We can also dismiss non-combat pets and companions
    -- but they are resummoned like zombies at next login.
    -- I don't know the reason :(
end

-- Trigger when skills are cast
function AutoBanishPets.onSkillCast()
    local activeId = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_COMPANION)
    if (activeId == 0) then return false end

    local slotNum = tonumber(debug.traceback():match('keybind = "ACTION_BUTTON_(%d)')) or tonumber(debug.traceback():match('keybind = "GAMEPAD_ACTION_BUTTON_(%d)'))
    local abilityId = GetSlotBoundId(slotNum)
    
    if (AutoBanishPets.savedVariables.vampire[activeId] and AutoBanishPets.abilities[SKILL_TYPE_WORLD][5][abilityId]) or
       (AutoBanishPets.savedVariables.werewolf[activeId] and AutoBanishPets.abilities[SKILL_TYPE_WORLD][6][abilityId]) then
        AutoBanishPets.BanishCompanions(activeId)
        ZO_Alert(ERROR, SOUNDS.GENERAL_ALERT_ERROR, string.format("%s blocked the criminal ability.", AutoBanishPets.name))
        return true
    end
end

-- Trigger after loading
function AutoBanishPets.onPlayerActivated()
    -- Refresh registerUpdates
    for _, v in ipairs({"vanityPets", "assistants", "companions"}) do
        UnregisterUpdate(v)
    end

    -- Locations which companions dislike
    for k, v in pairs(AutoBanishPets.savedVariables.location) do
        if (k == "pets") or (k == "vanityPets") or (k == "assistants") then
            -- Do nothing
        elseif v then
            if (AutoBanishPets.locations[k][GetZoneId(GetUnitZoneIndex("player"))]) then
                AutoBanishPets.BanishCompanions(k)
            end
        end
    end

    -- PVP/PVE zone detection
    if (IsPlayerInAvAWorld() or IsActiveWorldBattleground()) then
        if not AutoBanishPets.isInPVP then -- Zone changed from PVE to PVP
            AutoBanishPets:UnregisterEvents()
            AutoBanishPets.isInPVP = true
        end
    else
        if AutoBanishPets.isInPVP then -- Zone changed from PVP to PVE
            AutoBanishPets:RegisterEvents()
            AutoBanishPets.isInPVP = false
        end
    end

    -- Dismiss combat pets if "NO-PETS-ALLOWED" is active
    if AutoBanishPets.savedVariables.noPetsAllowed then
        AutoBanishPets.ToggleNPA(true)
    end

end

-- Trigger when UseCollectible activated
function AutoBanishPets:UseCollectible(collectibleId)
    local activeVanityPetId = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_VANITY_PET)
    if (activeVanityPetId ~= 0) then
        AutoBanishPets.lastId["vanityPets"] = activeVanityPetId
    end
    local activeAssistantId = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_ASSISTANT)
    if (activeAssistantId ~= 0) then
        AutoBanishPets.lastId["assistants"] = activeAssistantId
    end
    local activeCompanionId = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_COMPANION)
    if (activeCompanionId ~= 0) then
        AutoBanishPets.lastId["companions"] = activeCompanionId
    end

    if AutoBanishPets.savedVariables.location[collectibleId] and AutoBanishPets.locations[collectibleId][GetZoneId(GetUnitZoneIndex("player"))] then
        if (activeCompanionId ~= 0) and (activeCompanionId == collectibleId) then
            return false
        else
            ZO_Alert(ERROR, SOUNDS.GENERAL_ALERT_ERROR, string.format("%s blocked summoning the companion.", AutoBanishPets.name))
            return true
        end
    end
end

function AutoBanishPets:FastTravel(nodeId)
    local activeCompanionId = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_COMPANION)
    if (activeCompanionId ~= 0) and AutoBanishPets.savedVariables.location[activeCompanionId] and AutoBanishPets.wayshrines[activeCompanionId][nodeId] then
        AutoBanishPets.BanishCompanions(activeId)
        ZO_Alert(ERROR, SOUNDS.GENERAL_ALERT_ERROR, string.format("%s blocked fast travel.", AutoBanishPets.name))
        return true
    end
    return false
end

-- Trigger when food created
function AutoBanishPets.onFoodCreated()
    local activeId = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_COMPANION)
    if (activeId == 0) then return false end

    local maxIngredients = GetMaxRecipeIngredients()
    local selectedData = PROVISIONER.recipeTree:GetSelectedData()

    for i = 1, maxIngredients do
        local ingredientName, _, _, _, _ = GetRecipeIngredientItemInfo(selectedData.recipeListIndex, selectedData.recipeIndex, i)
        if AutoBanishPets.ingredients[activeId][ingredientName] then
            AutoBanishPets.BanishCompanions(activeId)
            ZO_Alert(ERROR, SOUNDS.GENERAL_ALERT_ERROR, string.format("%s blocked provisioning.", AutoBanishPets.name))
            return true
        end
    end
end

-----------------------
--(UN)REGISTER EVENTS--
-----------------------
-- Register events
function AutoBanishPets:RegisterEvents()
    local ns = AutoBanishPets.name
    local sV = AutoBanishPets.savedVariables
    -- Combat events
    EM:RegisterForEvent(ns .. "_COMBAT", EVENT_PLAYER_COMBAT_STATE, AutoBanishPets.onCombat)
    EM:AddFilterForEvent(ns .. "_COMBAT", EVENT_PLAYER_COMBAT_STATE, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
    -- Stealth events
    EM:RegisterForEvent(ns .. "_STEALTH", EVENT_STEALTH_STATE_CHANGED, AutoBanishPets.onStealth)
    EM:AddFilterForEvent(ns .. "_STEALTH", EVENT_STEALTH_STATE_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")
    -- Other events
    EM:RegisterForEvent(ns .. "_BANK", EVENT_OPEN_BANK, AutoBanishPets.onEventTriggered)
    EM:RegisterForEvent(ns .. "_BANK_CLOSE", EVENT_CLOSE_BANK, AutoBanishPets.onEventTriggered)
    EM:RegisterForEvent(ns .. "_GUILD_BANK", EVENT_OPEN_GUILD_BANK, AutoBanishPets.onEventTriggered)
    EM:RegisterForEvent(ns .. "_STORE", EVENT_OPEN_STORE, AutoBanishPets.onEventTriggered)
    EM:RegisterForEvent(ns .. "_STORE_CLOSE", EVENT_CLOSE_STORE, AutoBanishPets.onEventTriggered)
    EM:RegisterForEvent(ns .. "_GUILD_STORE", EVENT_OPEN_TRADING_HOUSE, AutoBanishPets.onEventTriggered)
    EM:RegisterForEvent(ns .. "_FENCE", EVENT_OPEN_FENCE, AutoBanishPets.onEventTriggered)
    EM:RegisterForEvent(ns .. "_CRAFT_STATION", EVENT_CRAFTING_STATION_INTERACT, AutoBanishPets.onEventTriggered)
    EM:RegisterForEvent(ns .. "_DYEING_STATION", EVENT_DYEING_STATION_INTERACT_START, AutoBanishPets.onEventTriggered)
    EM:RegisterForEvent(ns .. "_RETRAIT_STATION", EVENT_RETRAIT_STATION_INTERACT_START, AutoBanishPets.onEventTriggered)
    EM:RegisterForEvent(ns .. "_WAYSHRINE", EVENT_START_FAST_TRAVEL_INTERACTION, AutoBanishPets.onEventTriggered)
    EM:RegisterForEvent(ns .. "_QUEST_ADDED", EVENT_QUEST_ADDED, AutoBanishPets.onEventTriggered)
    EM:RegisterForEvent(ns .. "_QUEST_COMPLETE", EVENT_QUEST_COMPLETE_DIALOG, AutoBanishPets.onEventTriggered)
    EM:RegisterForEvent(ns .. "_ARRESTED", EVENT_JUSTICE_BEING_ARRESTED, AutoBanishPets.onEventTriggered)
    EM:RegisterForEvent(ns .. "_INTERACT", EVENT_CLIENT_INTERACT_RESULT, AutoBanishPets.onEventTriggered)
    -- Prehook
    -- Modify UseCollectible
    ZO_PreHook("UseCollectible", function(rowId)
        if rowId then
            return AutoBanishPets:UseCollectible(rowId)
        end
        return false
    end)
    -- Logout
    if sV.logout.pets then
        ZO_PreHook("Logout", AutoBanishPets.onLogout)
    end
    -- Skill Blocker
    if (sV.vampire[AutoBanishPets.companions[1]] or sV.werewolf[AutoBanishPets.companions[1]]
        or sV.vampire[AutoBanishPets.companions[2]] or sV.werewolf[AutoBanishPets.companions[2]]
        or sV.vampire[AutoBanishPets.companions[3]] or sV.werewolf[AutoBanishPets.companions[3]]
        or sV.vampire[AutoBanishPets.companions[4]] or sV.werewolf[AutoBanishPets.companions[4]]
        or sV.vampire[AutoBanishPets.companions[5]] or sV.werewolf[AutoBanishPets.companions[5]]
        or sV.vampire[AutoBanishPets.companions[6]] or sV.werewolf[AutoBanishPets.companions[6]]) then
        ZO_PreHook("ZO_ActionBar_CanUseActionSlots", AutoBanishPets.onSkillCast)
    end
    -- Block provisioning
    if (sV.provisioning[AutoBanishPets.companions[1]] or sV.provisioning[AutoBanishPets.companions[2]]
        or sV.provisioning[AutoBanishPets.companions[3]] or sV.provisioning[AutoBanishPets.companions[4]]
        or sV.provisioning[AutoBanishPets.companions[5]] or sV.provisioning[AutoBanishPets.companions[6]]) then
        ZO_PreHook(ZO_Provisioner, "Create", AutoBanishPets.onFoodCreated)
    end
    -- Block fast travel
    if (sV.location[AutoBanishPets.companions[1]] or sV.location[AutoBanishPets.companions[2]]
        or sV.location[AutoBanishPets.companions[3]] or sV.location[AutoBanishPets.companions[4]]
        or sV.location[AutoBanishPets.companions[5]] or sV.location[AutoBanishPets.companions[6]]) then
        ZO_PreHook("FastTravelToNode", function(rowId)
            if rowId then
                return AutoBanishPets:FastTravel(rowId)
            end
            return false
        end)
    end
    -- Slash command
    SLASH_COMMANDS["/abp"] = AutoBanishPets.BanishAll

end

-- Unregister events
function AutoBanishPets:UnregisterEvents()
    local ns = AutoBanishPets.name
    -- Combat events
    EM:UnregisterForEvent(ns .. "_COMBAT", EVENT_PLAYER_COMBAT_STATE)
    -- Stealth events
    EM:UnregisterForEvent(ns .. "_STEALTH", EVENT_STEALTH_STATE_CHANGED)
    -- Other events
    EM:UnregisterForEvent(ns .. "_BANK", EVENT_OPEN_BANK)
    EM:UnregisterForEvent(ns .. "_BANK_CLOSE", EVENT_CLOSE_BANK)
    EM:UnregisterForEvent(ns .. "_GUILD_BANK", EVENT_OPEN_GUILD_BANK)
    EM:UnregisterForEvent(ns .. "_STORE", EVENT_OPEN_STORE)
    EM:UnregisterForEvent(ns .. "_STORE_CLOSE", EVENT_CLOSE_STORE)
    EM:UnregisterForEvent(ns .. "_GUILD_STORE", EVENT_OPEN_TRADING_HOUSE)
    EM:UnregisterForEvent(ns .. "_FENCE", EVENT_OPEN_FENCE)
    EM:UnregisterForEvent(ns .. "_CRAFT_STATION", EVENT_CRAFTING_STATION_INTERACT)
    EM:UnregisterForEvent(ns .. "_DYEING_STATION", EVENT_DYEING_STATION_INTERACT_START)
    EM:UnregisterForEvent(ns .. "_RETRAIT_STATION", EVENT_RETRAIT_STATION_INTERACT_START)
    EM:UnregisterForEvent(ns .. "_WAYSHRINE", EVENT_START_FAST_TRAVEL_INTERACTION)
    EM:UnregisterForEvent(ns .. "_QUEST_ADDED", EVENT_QUEST_ADDED)
    EM:UnregisterForEvent(ns .. "_QUEST_COMPLETE", EVENT_QUEST_COMPLETE_DIALOG)
    EM:UnregisterForEvent(ns .. "_ARRESTED", EVENT_JUSTICE_BEING_ARRESTED)
    EM:UnregisterForEvent(ns .. "_INTERACT", EVENT_CLIENT_INTERACT_RESULT)

end

--------------------
--INITIALIZE ADDON--
--------------------
function AutoBanishPets:Initialize()
    AutoBanishPets.savedVariables = ZO_SavedVars:NewAccountWide("AutoBanishPetsSavedVars", AutoBanishPets.variableVersion, nil, AutoBanishPets.defaultSettings)
    AutoBanishPets.lastId = { -- Table for resummoning
        ["vanityPets"] = 0,
        ["assistants"] = 0,
        ["companions"] = 0,
    }
    AutoBanishPets.isToggling = { -- We need this for lagging :(
        ["vanityPets"] = false,
        ["assistants"] = false,
        ["companions"] = false,
    }
    AutoBanishPets.unitClassId = GetUnitClassId("player")
    AutoBanishPets.isInPVP = false
    AutoBanishPets.CreateSettingsWindow() -- AutoBanishPetsSettings.lua
    AutoBanishPets:RegisterEvents()
    EM:RegisterForEvent(AutoBanishPets.name, EVENT_PLAYER_ACTIVATED, AutoBanishPets.onPlayerActivated)

    -- Override StartInteraction
    local interactionManager = FISHING_MANAGER or INTERACTIVE_WHEEL_MANAGER
    local ZO_StartInteraction = interactionManager.StartInteraction
    interactionManager.StartInteraction = function(...)
        local activeId = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_COMPANION)
        if (activeId == 0) then
            return ZO_StartInteraction(...)
        end

        local _, interactableName, interactionBlocked, _, additionalInfo, _, _, isCriminalInteract = GetGameCameraInteractableActionInfo()
        -- Block harvesting something
        if AutoBanishPets.savedVariables.harvesting[activeId] and AutoBanishPets.harvests[activeId][interactableName] then
            AutoBanishPets.BanishCompanions(activeId)
            ZO_Alert(ERROR, SOUNDS.GENERAL_ALERT_ERROR, string.format("%s blocked the interaction.", AutoBanishPets.name))
            return true
        end
        -- Fishing
        if AutoBanishPets.savedVariables.fishing[activeId] and additionalInfo == ADDITIONAL_INTERACT_INFO_FISHING_NODE then
            AutoBanishPets.BanishCompanions(activeId)
            ZO_Alert(ERROR, SOUNDS.GENERAL_ALERT_ERROR, string.format("%s blocked the interaction.", AutoBanishPets.name))
            return true
        end
        -- Block stealing
        if AutoBanishPets.savedVariables.steal[activeId] and isCriminalInteract then
            AutoBanishPets.BanishCompanions(activeId)
            ZO_Alert(ERROR, SOUNDS.GENERAL_ALERT_ERROR, string.format("%s blocked the interaction.", AutoBanishPets.name))
            return true
        end
        return ZO_StartInteraction(...)
    end

    EM:UnregisterForEvent(AutoBanishPets.name, EVENT_ADD_ON_LOADED)
end

function AutoBanishPets.OnAddOnLoaded(event, addonName)
    if (addonName == AutoBanishPets.name) then
        AutoBanishPets:Initialize()
    end
end

EM:RegisterForEvent(AutoBanishPets.name, EVENT_ADD_ON_LOADED, AutoBanishPets.OnAddOnLoaded)