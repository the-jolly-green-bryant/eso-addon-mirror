local ADK = AntiDK2

-- ── Reset everything (player death, end-of-combat) ────────────────────────────
local function ResetAll()
    ADK.Combat.Events.Corrosive.Reset()
    ADK.Combat.Events.Wings.Reset()
    ADK.Combat.Events.MoltenWhip.Reset()
    ADK.Combat.Events.PowerLash.Reset()
    ADK.UI.Stuns.Reset()
end

-- ── Register all combat event listeners ──────────────────────────────────────
local function RegisterEvents()
    ADK.Combat.Events.Corrosive.Register()
    ADK.Combat.Events.Wings.Register()
    ADK.Combat.Events.MoltenWhip.Register()
    ADK.Combat.Events.PowerLash.Register()
    ADK.Combat.Events.ShatteringRocks.Register()
    ADK.Combat.Events.Fossilize.Register()
    ADK.Combat.Events.DragonknightStandard.Register()
end

-- ── Build all UI panels ───────────────────────────────────────────────────────
local function InitUI()
    local modules = {
        { "ADK.UI.Popups",          function() ADK.UI.Popups.Init()          end },
        { "ADK.UI.Corrosive",       function() ADK.UI.Corrosive.Init()       end },
        { "ADK.UI.Stuns",           function() ADK.UI.Stuns.Init()           end },
        { "ADK.UI.Wings",           function() ADK.UI.Wings.Init()           end },
        { "ADK.UI.MoltenStacks",    function() ADK.UI.MoltenStacks.Init()    end },
        { "ADK.UI.PowerLashStacks", function() ADK.UI.PowerLashStacks.Init() end },
    }
    for _, entry in ipairs(modules) do
        local ok, err = pcall(entry[2])
        if not ok then
            error(entry[1] .. " failed: " .. tostring(err), 2)
        end
    end
end

-- ── Entry point ───────────────────────────────────────────────────────────────
local function OnAddOnLoaded(_, addOnName)
    if addOnName ~= ADK.name then return end
    EVENT_MANAGER:UnregisterForEvent(ADK.name .. "_Load", EVENT_ADD_ON_LOADED)

    local ok, err = pcall(function()
        -- Saved variables (per character)
        ADK.savedVars = ZO_SavedVars:NewCharacterIdSettings(
            "AntiDK2_SavedVars", 1, nil, ADK.defaults
        )

        InitUI()
        ADK.Config.Settings.Init()
        RegisterEvents()

        -- Reset on player death
        EVENT_MANAGER:RegisterForEvent(ADK.name .. "_PlayerDead", EVENT_PLAYER_DEAD,
            function() ResetAll() end)
    end)

    if not ok then
        -- Report any init error to chat so it can be diagnosed
        CHAT_ROUTER:AddSystemMessage("|cFF2020[AntiDK2] Init error:|r " .. tostring(err))
    end
end

EVENT_MANAGER:RegisterForEvent(ADK.name .. "_Load", EVENT_ADD_ON_LOADED, OnAddOnLoaded)
