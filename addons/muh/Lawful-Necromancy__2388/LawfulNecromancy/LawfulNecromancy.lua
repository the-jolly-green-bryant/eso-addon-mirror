if LawfulNecromancy == nil then LawfulNecromancy = { } end
local LawfulNecromancy = _G['LawfulNecromancy']
local L = LawfulNecromancy:GetLocale()

LawfulNecromancy = {
    name            = "LawfulNecromancy",
    author          = "muh",
    menuName        = "Lawful Citizen",
    var_version     = 1
}

LawfulNecromancy.defaults = {
    block_in_combat = true,
}

LawfulNecromancy.ability    = {
    necromancer = {
        -- [[ Gravelord ]]
        [122174] = true, -- Colossus
        [122395] = true,
        [122388] = true,

        [114860] = true, -- Blastbones
        [117690] = true,
        [117749] = true,

        [114317] = true, -- Skeletal Mage
        [118680] = true,
        [118726] = true,

        -- [[ Bone Tyrant ]]
        [115001] = true, -- Goliath
        [118664] = true,
        [118279] = true,

        -- [[ Living Death ]]
        [115710] = true, -- Spirit Mender
        [118912] = true,
        [118840] = true,
    },

    werewolf = {
        -- [[ Werewolf ]]
        [32455] = true, -- Werewolf Transformation
        [39075] = true,
        [39076] = true,
        },

    vampire = {
        -- [[ Vampire ]]
        [32624] = true, -- Blood Scion
        [38932] = true,
        [38931] = true,

        [132141] = true, -- Blood Frenzy
        [134160] = true,
        [135841] = true,

        [134583] = true, -- Vampiric Drain
        [135905] = true,
        [137259] = true,

        [32986] = true, -- Mist Form
        [38963] = true,
        [38965] = true,
    },
}

local NECROMANCER = 5 -- necro class ID

local function block_handler()
    return (LawfulNecromancy.variables.block_in_combat or not IsUnitInCombat("player")) and not IsWerewolf()
end

local function slash_handler()
    LawfulNecromancy.variables.block_in_combat = not LawfulNecromancy.variables.block_in_combat

    if LawfulNecromancy.variables.block_in_combat then
        CHAT_SYSTEM:AddMessage(L.slash.block_in_combat_enabled)
    else
        CHAT_SYSTEM:AddMessage(L.slash.block_in_combat_disabled)
    end
end

function LawfulNecromancy_temporary_unblock()
    LawfulNecromancy.block_skills(false)

    zo_callLater(function ()
        if IsUnitInCombat("player") then
            EVENT_MANAGER:RegisterForEvent(LawfulNecromancy.name, EVENT_PLAYER_COMBAT_STATE, LawfulNecromancy.on_player_combat_state)
        else
            LawfulNecromancy.block_skills(IsInJusticeEnabledZone())
        end
    end, 10000)
end

function LawfulNecromancy.block_skills(blocking)
    local lib_skill_blocker = nil

    if blocking then
        lib_skill_blocker = LibSkillBlocker.RegisterSkillBlock
    else
        lib_skill_blocker = LibSkillBlocker.UnregisterSkillBlock
    end

    if GetUnitClassId("player") == NECROMANCER then
        for i, _ in pairs(LawfulNecromancy.ability.necromancer) do
            lib_skill_blocker(LawfulNecromancy.name, i, block_handler)
        end
    end
--    if false --[[vampire]] then
        for i, _ in pairs(LawfulNecromancy.ability.vampire) do
            lib_skill_blocker(LawfulNecromancy.name, i, block_handler)
        end
--    elseif false --[[werewolf]] then
        for i, _ in pairs(LawfulNecromancy.ability.werewolf) do
            lib_skill_blocker(LawfulNecromancy.name, i, block_handler)
        end
--    end
end

function LawfulNecromancy.on_player_combat_state(_, in_combat)
    if not in_combat then
        EVENT_MANAGER:UnregisterForEvent(LawfulNecromancy.name, EVENT_PLAYER_COMBAT_STATE)
        LawfulNecromancy.block_skills(IsInJusticeEnabledZone())
    end
end

function LawfulNecromancy.on_player_activated()
    if LawfulNecromancy.variables.enabled then
        LawfulNecromancy.block_skills(IsInJusticeEnabledZone())
    end
end

function LawfulNecromancy.on_addon_loaded(event, name)
    if name ~= LawfulNecromancy.name then return end
    EVENT_MANAGER:UnregisterForEvent(LawfulNecromancy.name, EVENT_ADD_ON_LOADED)

    local vars = LawfulNecromancy.name .. "_SavedVariables"
    --LawfulNecromancy.character_variables = ZO_SavedVars:New(vars, 1, nil, LawfulNecromancy.variables)
    LawfulNecromancy.account_variables = ZO_SavedVars:NewAccountWide(vars, 1, nil, LawfulNecromancy.defaults)   
    LawfulNecromancy.variables = LawfulNecromancy.account_variables

    SLASH_COMMANDS["/lawfulcasting"] = slash_handler

    EVENT_MANAGER:RegisterForEvent(LawfulNecromancy.name, EVENT_PLAYER_ACTIVATED, LawfulNecromancy.on_player_activated)
end
EVENT_MANAGER:RegisterForEvent(LawfulNecromancy.name, EVENT_ADD_ON_LOADED, LawfulNecromancy.on_addon_loaded)