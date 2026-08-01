if EzStalking == nil then EzStalking = { } end
local Ez = _G['EzStalking']
local L = Ez:GetLocale()

local libDialog = LibDialog

Ez.name         = 'EzStalking'
Ez.title        = 'Easy Stalking'
Ez.slash        = '/ezlog'
Ez.author       = 'muh'
Ez.version      = '1.4.5'
Ez.var_version  = 2

Ez.defaults = {
    account_wide = false,
    upload_reminder = false,

    log = {
        enabled = false,
        housing = false,
        battlegrounds = false,
        imperial_city = false,
        cyrodiil = false,
        arenas = false,
        dungeons = false,
        endless = false,
        trials = false,
        normal_difficulty = false,
        combat_only = false,
        use_dialog = false,
        remember_zone = false,
    },

    zone_id = { },

    indicator = {
        enabled = false,
        locked = true,

        position = {
            x = 500,
            y = 500,
        },
        color = {1, 0, 0, 0.7},
        unlocked_color = {0, 1, 1, 0.7}
    },
}

local ZoneType = { Overland = 0, Instance = 1, Cyrodiil = 2, ImperialCity = 3, Battleground = 4, House = 5 }
local InstanceType = { Uncategorized = 0, Trial = 1, Arena = 2, Dungeon = 3, Endless = 4}

Ez.defaults.zone_id[InstanceType.Trial] = { }
Ez.defaults.zone_id[InstanceType.Arena] = { }
Ez.defaults.zone_id[InstanceType.Dungeon] = { }
Ez.defaults.zone_id[InstanceType.Endless] = { }
Ez.zone_id = Ez.defaults.zone_id

local function current_zone()
    return GetZoneId(GetUnitZoneIndex("player"))
end

local function determine_zone_type()
    local zone_type = ZoneType.Overland

    if GetCurrentZoneDungeonDifficulty() ~= DUNGEON_DIFFICULTY_NONE then
        zone_type = ZoneType.Instance
    elseif GetCurrentHouseOwner() ~= "" then
        zone_type = ZoneType.House
    elseif IsActiveWorldBattleground() then
        zone_type = ZoneType.Battleground
    elseif IsInImperialCity() then
        zone_type = ZoneType.ImperialCity
    elseif IsInCyrodiil() then
        zone_type = ZoneType.Cyrodiil
    end

    return zone_type
end

local function determine_instance_type()
    local instance_type = InstanceType.Uncategorized
    local zone = current_zone()

    if IsInstanceEndlessDungeon() then
        instance_type = InstanceType.Endless
    elseif Ez.zone_id[InstanceType.Dungeon][zone] then
        instance_type = InstanceType.Dungeon
    elseif Ez.zone_id[InstanceType.Arena][zone] then
        instance_type = InstanceType.Arena
    elseif Ez.zone_id[InstanceType.Trial][zone] then
        instance_type = InstanceType.Trial
    elseif GetCurrentZoneDungeonDifficulty() == DUNGEON_DIFFICULTY_VETERAN then
        instance_type = InstanceType.Dungeon

        if IsPlayerInReviveCounterRaid() then
            local revive_counter = GetCurrentRaidStartingReviveCounters()
            local raid_id = GetCurrentParticipatingRaidId()

            if (revive_counter > 24 or raid_id < 4) and raid_id > 0 then
                instance_type = InstanceType.Trial
            elseif revive_counter <= 24 and raid_id >= 4 then
                instance_type = InstanceType.Arena
            end
        end

        Ez.zone_id[instance_type][zone] = true
    end

    return instance_type
end

Ez.remembered_zone = nil
Ez.previous_decision = nil
Ez.automatic_toggle = nil
local function determine_encounterlog_status()
    Ez.automatic_toggle = true
    local toggle = false
    local instance_difficulty = nil

    local zone_type = determine_zone_type()
    if zone_type == ZoneType.Instance then
        local instance_type = determine_instance_type()
        instance_difficulty = GetCurrentZoneDungeonDifficulty()

        if IsEncounterLogEnabled() then
            toggle = true
        elseif instance_type == InstanceType.Endless and Ez.settings.log.endless then
            toggle = true
        elseif instance_difficulty == DUNGEON_DIFFICULTY_NORMAL and Ez.settings.log.normal_difficulty then
            toggle = true
            -- disable logging if it is known that it is an InstanceType that should not be logged.
            if (instance_type == InstanceType.Dungeon and not Ez.settings.log.dungeons)
                or (instance_type == InstanceType.Arena and not Ez.settings.log.arenas)
                or (instance_type == InstanceType.Trial and not Ez.settings.log.trials)
            then
                toggle = false
            end
        elseif instance_difficulty == DUNGEON_DIFFICULTY_VETERAN
            and ((instance_type == InstanceType.Dungeon and Ez.settings.log.dungeons)
                or (instance_type == InstanceType.Arena and Ez.settings.log.arenas)
                or (instance_type == InstanceType.Trial and Ez.settings.log.trials))
        then
            toggle = true
        end
    elseif (zone_type == ZoneType.Battleground and Ez.settings.log.battlegrounds)
        or (zone_type == ZoneType.ImperialCity and Ez.settings.log.imperial_city)
        or (zone_type == ZoneType.Cyrodiil and Ez.settings.log.cyrodiil)
        or (zone_type == ZoneType.House and Ez.settings.log.housing)
    then
        toggle = true
    end

    if libDialog and (Ez.settings.log.use_dialog or (Ez.settings.log.normal_difficulty and instance_difficulty == DUNGEON_DIFFICULTY_NORMAL and not IsInstanceEndlessDungeon())) then
        if toggle then
            if Ez.previous_decision == nil or Ez.remembered_zone ~= current_zone() then
                Ez.toggle_logging(false)
                zo_callLater(function()
                    libDialog:ShowDialog(Ez.name, Ez.name .. "LoggingConfirmationDialog")
                end, 2000)
            elseif Ez.remembered_zone == current_zone() then
                Ez.toggle_logging(Ez.previous_decision)
            end
        elseif zone_type == ZoneType.Overland and not Ez.settings.log.remember_zone then
            Ez.toggle_logging(false)
            Ez.remembered_zone = nil
            Ez.previous_decision = nil
        else
            Ez.toggle_logging(false)
        end
    else
        Ez.toggle_logging(toggle)
    end
end

function Ez.toggle_logging(value)
    if Ez.settings.log.combat_only then
        Ez.combat_only_mode(value)
    else
        local toggle = (value == nil) and not IsEncounterLogEnabled() or value
        SetEncounterLogEnabled(toggle)
    end
end
EzStalking_keybind_toggle = Ez.toggle_logging

function Ez.confirmation_dialog_callback(value)
    Ez.previous_decision = value
    Ez.remembered_zone = current_zone()
end

local function initialize_confirmation_dialog()
    if libDialog then
        local dialog_name = Ez.name .. "LoggingConfirmationDialog"
        libDialog:RegisterDialog(Ez.name, dialog_name,
                                 L.dialog.logging.title, L.dialog.logging.text,
                                 function() -- callBackYes
                                    Ez.toggle_logging(true)
                                    Ez.confirmation_dialog_callback(true)
                                 end,
                                 function() -- callBackNo
                                    Ez.confirmation_dialog_callback(false)
                                 end)
    end
end

function Ez.set_anonymity(value)
    value = value and "1" or "0"
    SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_ENCOUNTER_LOG_APPEAR_ANONYMOUS, value)
end

local function print_help()
    CHAT_SYSTEM:AddMessage(L.message.slash_command.options)
    CHAT_SYSTEM:AddMessage(L.message.slash_command.toggle)
    if Ez.settings.indicator.enabled then
        CHAT_SYSTEM:AddMessage(L.message.slash_command.lock)
        CHAT_SYSTEM:AddMessage(L.message.slash_command.unlock)
    end
    CHAT_SYSTEM:AddMessage(L.message.slash_command.combat_only)
    CHAT_SYSTEM:AddMessage(L.message.slash_command.anonymous)
    CHAT_SYSTEM:AddMessage(L.message.slash_command.named)
    CHAT_SYSTEM:AddMessage(L.message.slash_command.note)
end

function Ez.slash_command(arg)
    local notify_anonymity = nil
    if (arg == '') then
        Ez.toggle_logging()
    elseif (arg == L.slash_command.anonymous --[['anonymous']]) or (arg == zo_strsub(L.slash_command.anonymous, 1, 1) --[['a']]) then
        Ez.set_anonymity(true)
        notify_anonymity = L.message.anonymity.anonymous
    elseif (arg == L.slash_command.named --[['named']]) or (arg == zo_strsub(L.slash_command.named, 1, 1) --[['n']]) then
        Ez.set_anonymity(false)
        notify_anonymity = L.message.anonymity.named
    elseif (arg == L.slash_command.unlock) and Ez.settings.indicator.enabled then
            Ez.UI.lock(false)
    elseif (arg == L.slash_command.lock) and Ez.settings.indicator.enabled then
            Ez.UI.lock(true)
    elseif (arg == L.slash_command.combat_only) then
        Ez.settings.log.combat_only = not Ez.settings.log.combat_only
        CHAT_SYSTEM:AddMessage(L.message.slash_command.combat_only_info .. (Ez.settings.log.combat_only and "true" or "false"))
    else
        print_help()
    end
    if notify_anonymity ~= nil then
        CHAT_SYSTEM:AddMessage(L.message.anonymity.preamble .. " |cffffff" .. notify_anonymity .. "|r")
    end
end

function Ez.enable_automatic_logging(value)
    if value then
        EVENT_MANAGER:RegisterForEvent(Ez.name, EVENT_PLAYER_ACTIVATED, function()
            zo_callLater(function()
                determine_encounterlog_status()
            end, 1000)
        end)
    else
        EVENT_MANAGER:UnregisterForEvent(Ez.name, EVENT_PLAYER_ACTIVATED)
    end
end

function Ez.combat_only_mode(value)
    if value then
        EVENT_MANAGER:RegisterForEvent(Ez.name, EVENT_PLAYER_COMBAT_STATE, function(_, in_combat)
            Ez.automatic_toggle = true
            SetEncounterLogEnabled(in_combat)
        end)
    else
        EVENT_MANAGER:UnregisterForEvent(Ez.name, EVENT_PLAYER_COMBAT_STATE)
    end
end

function Ez:initialize()
    Ez.UI:initialize()
    Ez.Menu:initialize()

    SLASH_COMMANDS[Ez.slash] = Ez.slash_command

    ZO_PostHook("SetEncounterLogEnabled", function()
            if Ez.settings.indicator.enabled then
                Ez.UI.toggle_fg_color()
                if not Ez.settings.indicator.locked then
                    CHAT_SYSTEM:AddMessage(L.message.indicator.warn_unlocked)
                end
            end

            if Ez.remembered_zone == current_zone() and not Ez.automatic_toggle and not (Ez.previous_decision == nil) then
                Ez.previous_decision = not Ez.previous_decision
            end

            Ez.automatic_toggle = false
            return false
      end)

    initialize_confirmation_dialog()

    Ez.enable_automatic_logging(Ez.settings.log.enabled)
end

local function on_addon_loaded(_, name)
    if name ~= Ez.name then return end
    EVENT_MANAGER:UnregisterForEvent(Ez.name, EVENT_ADD_ON_LOADED)

    local var_file = "EzStalking_SavedVars"
    Ez.settings = ZO_SavedVars:NewAccountWide(var_file, Ez.var_version, nil, Ez.defaults)
    Ez.zone_id = Ez.settings.zone_id
    if not Ez.settings.account_wide then
        Ez.settings = ZO_SavedVars:NewCharacterIdSettings(var_file, Ez.var_version, nil, Ez.defaults)
    end

    Ez:initialize()
end

EVENT_MANAGER:RegisterForEvent(Ez.name, EVENT_ADD_ON_LOADED, on_addon_loaded)