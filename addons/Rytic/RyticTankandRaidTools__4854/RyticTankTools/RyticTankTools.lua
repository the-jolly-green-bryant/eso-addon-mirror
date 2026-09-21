RyticTank = RyticTank or {}
local RyticTank = RyticTank
RyticTank.name = "RyticTankTools"
RyticTank.version = "1.1"

RyticTank.defaults = {
    sets = {
        enabled=true,
        hideOutOfCombat=true,
        locked=true,
        preview=false,
        orientation="VERTICAL",
        iconSize=36,
        spacing=8,
        abbreviateNames=false,
        position={x=661,y=560},
    },
    block = {
        enabled=true,
        locked=true,
        preview=false,
        combatOnly=false,
        scale=1.0,
        position={x=800,y=500},
    },
    resources = {
        enabled=true,
        hideOutOfCombat=false,
        locked=true,
        preview=true,
        scale=0.85,
        warningHealth=20,
        warningStamina=20,
        warningMagicka=20,
        potionAlert=true,
        potionThreshold=30,
        potionHealth=true,
        potionStamina=true,
        potionMagicka=true,
        potionCombatOnly=true,
        potionReadyOnly=true,
        position={x=684,y=444},
    },
    stats = {
        enabled=true,
        savedFights={},
    },
}

local function OnLoaded(_, addonName)
    if addonName ~= RyticTank.name then return end
    EVENT_MANAGER:UnregisterForEvent("RyticTankToolsLoaded", EVENT_ADD_ON_LOADED)

    RyticTank.saved = ZO_SavedVars:NewAccountWide(
        "RyticTankSavedVariables", 1, GetWorldName(), RyticTank.defaults
    )

    if not RyticTank.saved.resources then
        RyticTank.saved.resources = ZO_DeepTableCopy(RyticTank.defaults.resources)
    end
    if not RyticTank.saved.stats then
        RyticTank.saved.stats = ZO_DeepTableCopy(RyticTank.defaults.stats)
    elseif RyticTank.saved.stats.enabled == nil then
        RyticTank.saved.stats.enabled = true
    end

    -- One-time Pic-2 layout migration. Defaults alone do not overwrite existing SavedVariables.
    if (RyticTank.saved.layoutDefaultsVersion or 0) < 2 then
        RyticTank.saved.resources.scale = 0.85
        RyticTank.saved.resources.position = {x=684, y=444}
        RyticTank.saved.sets.position = {x=661, y=560}
        RyticTank.saved.sets.orientation = "VERTICAL"
        RyticTank.saved.block.position = {x=800, y=500}
        RyticTank.saved.block.scale = 1.0
        RyticTank.saved.layoutDefaultsVersion = 2
    end

    if RyticTank.Settings and RyticTank.Settings.Initialize then
        local ok, err = pcall(RyticTank.Settings.Initialize)
        if not ok then
            d("|cFF3333RyticTankTools Settings error: "..tostring(err).."|r")
        end
    end

    if RyticTank.Sets and RyticTank.Sets.Initialize then
        local ok, err = pcall(RyticTank.Sets.Initialize)
        if not ok then
            d("|cFF3333RyticTankTools Sets error: "..tostring(err).."|r")
        end
    else
        d("|cFFAA00RyticTankTools: Sets module was not loaded.|r")
    end

    if RyticTank.Block and RyticTank.Block.Initialize then
        local ok, err = pcall(RyticTank.Block.Initialize)
        if not ok then
            d("|cFF3333RyticTankTools Block error: "..tostring(err).."|r")
        end
    else
        d("|cFFAA00RyticTankTools: Block module was not loaded.|r")
    end

    if RyticTank.Stats and RyticTank.Stats.Initialize then
        local ok, err = pcall(RyticTank.Stats.Initialize)
        if not ok then
            d("|cFF3333RyticTankTools Stats init error: "..tostring(err).."|r")
        end
    else
        d("|cFFAA00RyticTankTools: Stats module did not load.|r")
    end

    if RyticTank.Resources and RyticTank.Resources.Initialize then
        local ok, err = pcall(RyticTank.Resources.Initialize)
        if ok then
            d("|c00FF00RyticTankTools RSS + Sets loaded.|r")
        else
            d("|cFF3333RyticTankTools Resource error: "..tostring(err).."|r")
        end
    else
        d("|cFF3333RyticTankTools: Resource module did not load.|r")
    end
end

EVENT_MANAGER:RegisterForEvent("RyticTankToolsLoaded", EVENT_ADD_ON_LOADED, OnLoaded)
