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

    -- Step 1: saved variables (fallback to defaults if broken)
    local ok, err = pcall(function()
        ADK.savedVars = ZO_SavedVars:NewCharacterIdSettings(
            "AntiDK2_SavedVars", 1, nil, ADK.defaults
        )
    end)
    if not ok then
        CHAT_ROUTER:AddSystemMessage("|cFF2020[AntiDK2] SavedVars error:|r " .. tostring(err))
        ADK.savedVars = ADK.defaults
    end

    -- Step 2: UI (non-critical)
    local ok2, err2 = pcall(InitUI)
    if not ok2 then
        CHAT_ROUTER:AddSystemMessage("|cFF2020[AntiDK2] UI error:|r " .. tostring(err2))
    end

    -- Step 3: settings panel (non-critical)
    local ok3, err3 = pcall(function() ADK.Config.Settings.Init() end)
    if not ok3 then
        CHAT_ROUTER:AddSystemMessage("|cFF2020[AntiDK2] Settings error:|r " .. tostring(err3))
    end

    -- Step 4: combat event registration (always runs)
    local ok4, err4 = pcall(RegisterEvents)
    if not ok4 then
        CHAT_ROUTER:AddSystemMessage("|cFF2020[AntiDK2] Events error:|r " .. tostring(err4))
    else
        CHAT_ROUTER:AddSystemMessage("|c5BCEFA[AntiDK2]|r Combat tracking active.")
    end

    EVENT_MANAGER:RegisterForEvent(ADK.name .. "_PlayerDead", EVENT_PLAYER_DEAD,
        function() ResetAll() end)
end

EVENT_MANAGER:RegisterForEvent(ADK.name .. "_Load", EVENT_ADD_ON_LOADED, OnAddOnLoaded)
