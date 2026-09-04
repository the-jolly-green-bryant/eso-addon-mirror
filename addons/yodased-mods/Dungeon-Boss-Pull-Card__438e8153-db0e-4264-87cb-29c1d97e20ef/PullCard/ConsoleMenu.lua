local PC = PullCard

-- Primary interactive surface for console: native rows in the Add-ons
-- menu via LibConsoleMenu (LCM). This is the one thing confirmed working
-- end-to-end on real console hardware -- see HousingVote's own
-- ConsoleMenu.lua, which found this after a plain top-level window, with
-- either SetKeyboardEnabled or KEYBIND_STRIP, never captured real gamepad
-- input for either addon (both tried, both tested live, neither worked).
--
-- PullCard's card window (PullCard.lua) stays exactly what it always was:
-- a passive, always-visible readout. It never tries to take input focus
-- again. Every actual interaction -- browsing, Tips Library, settings,
-- hiding the card -- happens through the rows built here instead.
--
-- Unlike HousingVote's contest list, PullCard's boss/dungeon data is
-- static (loaded once from Data.lua at file load, not discovered over
-- time via mail/guild MOTD), so the whole menu tree is built once, in one
-- shot, at registration -- no periodic re-sync is needed.
--
-- Stays within LCM's confirmed constraints (per HousingVote's notes):
-- options are append-only and only confirmed to work at the ROOT menu,
-- and a row's `name` is a static string fixed once added -- live state
-- goes through `tooltip`/`disabled`, both confirmed to accept functions
-- that re-evaluate live.

local menu

-- ============================================================
-- shared tooltip formatting
-- ============================================================

local function FormatBossTooltip(bossName, data)
    if not bossName then
        return "No active boss. Walk up to a boss, or use Previous/Next Boss to browse."
    end
    if not data then
        return bossName .. "\n\nNo PullCard exists yet for this boss."
    end

    local summary = data.summary or "Watch the encounter flow, protect your team, and execute one clean mechanic cycle."
    local lines = {
        (data.dungeon or "Dungeon") .. " -- " .. (data.title or bossName),
        "",
        summary,
    }

    local roleText = PC:GetPlayerRoleText(data)
    if roleText ~= "" then
        table.insert(lines, "")
        table.insert(lines, "Your role: " .. roleText)
    end

    return table.concat(lines, "\n")
end

-- ============================================================
-- root rows
-- ============================================================

local function AddRootRows()
    menu:AddOptions({
        {
            type = "button",
            name = "Current Boss",
            tooltip = function() return FormatBossTooltip(PC.currentBossName, PC.currentBossData) end,
            disabled = function() return PC.currentBossName == nil end,
            func = function() PC:AnnounceBossToChat(PC.currentBossName, PC.currentBossData) end,
        },
        {
            type = "button",
            name = "< Previous Boss",
            tooltip = "Step back through the full boss list and show it on the card.",
            func = function() PC:Browse(-1) end,
        },
        {
            type = "button",
            name = "Next Boss >",
            tooltip = "Step forward through the full boss list and show it on the card.",
            func = function() PC:Browse(1) end,
        },
        {
            type = "button",
            name = "Explain to Group",
            tooltip = "Prefills party chat with a short TL;DR for the current boss, if one exists.",
            disabled = function()
                local data = PC.currentBossData
                return not data or not data.tldr or data.tldr == ""
            end,
            func = function() PC:PrefillGroupChat() end,
        },
        {
            type = "button",
            name = "Refresh",
            tooltip = "Re-check for a nearby detected boss.",
            func = function() PC:RefreshAuto() end,
        },
        {
            type = "button",
            name = "Hide Card",
            tooltip = "Hides the on-screen PullCard window.",
            func = function() PC:HideAllWindows() end,
        },
    })
end

-- ============================================================
-- Tips Library -- one submenu per (vanilla) dungeon, one row per boss.
-- Built once, in full, at registration -- see file header.
-- ============================================================

local function BuildBossRow(bossName)
    return {
        type = "button",
        name = bossName,
        tooltip = function()
            local data = PullCardData and PullCardData.bosses and PullCardData.bosses[bossName]
            return FormatBossTooltip(bossName, data)
        end,
        func = function()
            PC:SetBoss(bossName, "manual")
            PC:OpenWindow(true)
        end,
    }
end

local function BuildDungeonSubmenu(dungeonName, bossNames)
    local options = {}
    for _, bossName in ipairs(bossNames) do
        table.insert(options, BuildBossRow(bossName))
    end
    return {
        type = "submenu",
        name = dungeonName,
        options = options,
    }
end

local function AddTipsLibrary()
    local dungeonOrder, dungeonLookup = PC:GetDungeonCatalog(true)
    if not dungeonOrder or #dungeonOrder == 0 then return end

    local dungeonSubmenus = {}
    for _, dungeonName in ipairs(dungeonOrder) do
        local entry = dungeonLookup[dungeonName]
        if entry and entry.bosses and #entry.bosses > 0 then
            table.insert(dungeonSubmenus, BuildDungeonSubmenu(dungeonName, entry.bosses))
        end
    end

    if #dungeonSubmenus == 0 then return end

    menu:AddOptions({
        {
            type = "submenu",
            name = "Tips Library",
            options = dungeonSubmenus,
        },
    })
end

-- ============================================================
-- Settings -- mirrors the toggles in PullCard.lua's own settings window
-- ============================================================

local function AddSettingsSubmenu()
    menu:AddOptions({
        {
            type = "submenu",
            name = "Settings",
            options = {
                {
                    type = "button",
                    name = "Toggle Debug Text",
                    tooltip = function() return "Currently: " .. PC:GetOnOffText(PC.debugMode) end,
                    func = function() PC:ToggleDebug() end,
                },
                {
                    type = "button",
                    name = "Toggle Open On Login",
                    tooltip = function() return "Currently: " .. PC:GetOnOffText(PC.savedVars and PC.savedVars.openOnStartup) end,
                    func = function() PC:ToggleOpenOnStartupSetting() end,
                },
            },
        },
    })
end

-- ============================================================
-- registration
-- ============================================================

local function RegisterMenu()
    local LCM = LibConsoleMenu
    if not LCM or type(LCM.CreateAddonMenu) ~= "function" then
        return
    end

    menu = LCM:CreateAddonMenu(PC.name, {
        title = "PullCard",
        author = "yodased-mods",
        version = tostring(PC.version),
        category = "COMBAT",
    })

    AddRootRows()
    AddTipsLibrary()
    AddSettingsSubmenu()
end

function PC:InitConsoleMenu()
    if not IsConsoleUI or not IsConsoleUI() then
        return
    end
    RegisterMenu()
end
