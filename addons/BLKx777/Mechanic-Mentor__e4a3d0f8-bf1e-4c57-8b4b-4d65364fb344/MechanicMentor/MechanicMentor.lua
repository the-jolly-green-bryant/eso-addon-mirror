MechanicMentor = MechanicMentor or {}
local DM = MechanicMentor

DM.name = "MechanicMentor"
DM.displayName = "Mechanic Mentor"
DM.author = "BLKx777"
DM.version = "1.0.9-syntax-hotfix-memory-refine"

if ZO_CreateStringId then
    ZO_CreateStringId("SI_BINDING_NAME_DUNGEONMECHANICS_SELECT", "Select")
    ZO_CreateStringId("SI_BINDING_NAME_DUNGEONMECHANICS_BACK", "Back")
    ZO_CreateStringId("SI_BINDING_NAME_DUNGEONMECHANICS_PREVIOUS", "Previous")
    ZO_CreateStringId("SI_BINDING_NAME_DUNGEONMECHANICS_NEXT", "Next")
    ZO_CreateStringId("SI_BINDING_NAME_DUNGEONMECHANICS_TAB_PREVIOUS", "Previous Tab")
    ZO_CreateStringId("SI_BINDING_NAME_DUNGEONMECHANICS_TAB_NEXT", "Next Tab")
end

DM.sceneName = "dungeonMechanicsAddonGuideScene"
local defaults = {
    lastDungeonId = nil,
    debug = false,
    quickSummary = true,
    quickSummaryFull = false,
    quickSummaryInCombat = false,
    quickPanelScale = 1.0,
    quickPanelOpacity = 64,
    roleHighlight = "All",
}

local function PCall(label, fn)
    local ok, result = pcall(fn)
    if not ok then
        DM.Debug(label .. " error: " .. tostring(result))
        return false
    end
    return result ~= false
end
DM.PCall = PCall

local function Plain(text)
    if not text then return "" end
    if type(text) == "table" then
        text = text.description or text.desc or text.text or text.name or text.title or ""
    end
    text = tostring(text)
    text = text:gsub(":contentReference%[%s*oaicite:%d+%]%s*{index=%d+}", "")
    text = text:gsub("|c%x%x%x%x%x%x", ""):gsub("|r", "")
    text = text:gsub("%s+", " ")
    text = text:gsub("^%s+", ""):gsub("%s+$", "")
    return text
end
DM.Plain = Plain

function DM.CleanBossName(name)
    local text = DM.Plain(name or "")
    if text == "" then return "Boss" end
    text = text:gsub("%s*%((Secret)%).*", "")
    text = text:gsub("%s*%-?%s*[Ss]ecret%s*$", "")
    text = text:gsub("%s+", " ")
    text = text:gsub("^%s+", ""):gsub("%s+$", "")
    return text ~= "" and text or "Boss"
end

function DM.Debug(msg)
    if DM.savedVars and DM.savedVars.debug then
        d("[Mechanic Mentor] " .. tostring(msg))
    end
end


function DM.GetAllTrials()
    local trials = {}
    local source = MechanicMentorTrials and MechanicMentorTrials.List or {}
    for i, trial in ipairs(source) do
        if trial and trial.name then
            table.insert(trials, trial)
        end
    end
    table.sort(trials, function(a, b)
        return (a.releaseOrder or 999) < (b.releaseOrder or 999)
    end)
    return trials
end

function DM.OpenTrialsFromAddonMenu()
    DM.CreateScene()
    DM.contentMode = "trial"
    DM.trials = DM.GetAllTrials()
    DM.selectedTrialIndex = zo_clamp(DM.selectedTrialIndex or 1, 1, #(DM.trials or {}))
    DM.selectedBossIndex = 1
    DM.selectedMechanicIndex = 1
    DM.mechanicScrollIndex = 1
    DM.level = 1
    DM.OpenFromAddonMenu()
end

function DM.GetSelectedTrialData()
    if not DM.trials then DM.trials = DM.GetAllTrials() end
    return DM.trials and DM.trials[DM.selectedTrialIndex or 1] or nil
end

function DM.GetAllDungeons()
    local dungeons = {}
    local function addFrom(tbl, isBase)
        if not tbl then return end
        for zoneId, data in pairs(tbl) do
            if data and data.name and data.bosses then
                table.insert(dungeons, { zoneId = zoneId, name = Plain(data.name), data = data, isBase = isBase })
            end
        end
    end
    addFrom(TTDungeon and TTDungeon.BaseDungeonInfo_en, true)
    addFrom(TTDungeon and TTDungeon.DLCDungeonInfo_en, false)
    table.sort(dungeons, function(a, b) return tostring(a.name) < tostring(b.name) end)
    return dungeons
end


function DM.SetDungeonCategory(category)
    DM.contentMode = "dungeon"
    if category ~= "dlc" then category = "base" end
    DM.dungeonCategory = category
    DM.dungeons = DM.GetFilteredDungeons(category)
    DM.selectedDungeonIndex = zo_clamp(DM.selectedDungeonIndex or 1, 1, #(DM.dungeons or {}))
    local dng = DM.dungeons and DM.dungeons[DM.selectedDungeonIndex]
    if dng then
        DM.selectedDungeonId = dng.zoneId
        if DM.savedVars then DM.savedVars.lastDungeonId = dng.zoneId end
    end
    DM.selectedBossIndex = 1
    DM.selectedMechanicIndex = 1
    DM.mechanicScrollIndex = 1
    DM.level = 1
    DM.RefreshUI()
end

function DM.GetFilteredDungeons(category)
    local all = DM.GetAllDungeons()
    local filtered = {}
    local wantBase = category ~= "dlc"
    for _, dng in ipairs(all) do
        if dng.isBase == wantBase then table.insert(filtered, dng) end
    end
    return filtered
end

function DM.SwitchDungeonCategory(delta)
    if (DM.level or 1) ~= 1 then return end
    if (DM.dungeonCategory or "base") == "base" then
        DM.SetDungeonCategory("dlc")
    else
        DM.SetDungeonCategory("base")
    end
end

function DM.GetDungeonByZoneId(zoneId)
    if not zoneId then return nil end
    if TTDungeon and TTDungeon.BaseDungeonInfo_en and TTDungeon.BaseDungeonInfo_en[zoneId] then return TTDungeon.BaseDungeonInfo_en[zoneId] end
    if TTDungeon and TTDungeon.DLCDungeonInfo_en and TTDungeon.DLCDungeonInfo_en[zoneId] then return TTDungeon.DLCDungeonInfo_en[zoneId] end
    return nil
end

function DM.GetCurrentDungeon()
    if not GetUnitZoneIndex or not GetZoneId then return nil end
    local zoneIndex = GetUnitZoneIndex("player")
    if not zoneIndex or zoneIndex <= 0 then return nil end
    local zoneId = GetZoneId(zoneIndex)
    local data = DM.GetDungeonByZoneId(zoneId)
    if data then return { zoneId = zoneId, name = Plain(data.name), data = data } end
    return nil
end

function DM.SetDungeonByIndex(index)
    if not DM.dungeons then DM.dungeons = DM.GetFilteredDungeons(DM.dungeonCategory or "base") end
    index = zo_clamp(index or 1, 1, #(DM.dungeons or {}))
    DM.selectedDungeonIndex = index
    local dng = DM.dungeons[index]
    if dng then
        DM.selectedDungeonId = dng.zoneId
        if DM.savedVars then DM.savedVars.lastDungeonId = dng.zoneId end
    end
    DM.selectedBossIndex = 1
    DM.selectedMechanicIndex = 1
    DM.level = 1
    DM.RefreshUI()
end

function DM.GetSelectedDungeonData()
    if DM.contentMode == "trial" then return nil end
    if not DM.selectedDungeonId then return nil end
    return DM.GetDungeonByZoneId(DM.selectedDungeonId)
end

function DM.GetSelectedBoss()
    if DM.contentMode == "trial" then
        local trial = DM.GetSelectedTrialData()
        if not trial or not trial.bosses then return nil end
        return trial.bosses[DM.selectedBossIndex or 1]
    end
    local dungeon = DM.GetSelectedDungeonData()
    if not dungeon or not dungeon.bosses then return nil end
    return dungeon.bosses[DM.selectedBossIndex or 1]
end

function DM.GetSelectedMechanicText()
    local boss = DM.GetSelectedBoss()
    if not boss or not boss.mechanics then return nil end
    return boss.mechanics[DM.selectedMechanicIndex or 1]
end

function DM.DeriveMechanicName(raw)
    local text = Plain(raw)
    if text == "" then return "Mechanic" end

    -- v0.4.4: mechanic titles must be exactly:
    -- MECHANIC TYPE: MECHANIC NAME
    -- Nothing after the first real separator belongs in the yellow title.
    text = text:gsub("^%s*[-•]+%s*", "")
    text = text:gsub("%s+", " ")
    text = text:gsub("^%s+", ""):gsub("%s+$", "")

    -- Some strings may already begin with a category prefix, for example
    -- "Heavy Attack: Fire Breath – ...". Drop that prefix before deriving
    -- the mechanic name so the title does not become "HEAVY ATTACK: Heavy Attack".
    local prefix, afterColon = text:match("^([^:]+):%s*(.+)$")
    if prefix and afterColon then
        local p = string.lower(prefix)
        if p:find("heavy") or p:find("interrupt") or p:find("adds") or p:find("one shot") or
           p:find("aoe") or p:find("avoid") or p:find("environment") or p:find("healer") or
           p:find("tank") or p:find("portal") or p:find("crowd") or p:find("control") or
           p:find("debuff") or p:find("timer") or p:find("execute") or p:find("movement") then
            text = afterColon
        end
    end

    -- Cut at the first descriptive separator. Keep only the mechanic name in
    -- the yellow title, e.g. "HEAVY ATTACK: Fire Breath". Anything after
    -- dash/separator belongs only in the description below.
    local cutAt = nil
    local function consider(pos)
        if pos and (not cutAt or pos < cutAt) then cutAt = pos end
    end
    -- UTF dash characters must be searched literally; Lua patterns are not
    -- reliable for them on console.
    consider(text:find("—", 1, true))
    consider(text:find("–", 1, true))
    consider(text:find(" -- ", 1, true))
    consider(text:find(" - ", 1, true))
    -- Fallback: action notes often start after a dash without clean spacing.
    consider(text:find("%-", 1))
    local name = cutAt and text:sub(1, cutAt - 1) or text

    -- Remove action hints and trailing clutter from the mechanic name only.
    name = Plain(name)
    name = name:gsub("%s*%([^%)]*%)%s*$", "")
    name = name:gsub("%s+", " ")
    name = name:gsub("^%s+", ""):gsub("%s+$", "")

    if name == "" then
        local words = {}
        for word in text:gmatch("%S+") do
            table.insert(words, word)
            if #words >= 3 then break end
        end
        name = table.concat(words, " ")
    end

    if #name > 42 then name = name:sub(1, 39):gsub("%s+%S*$", "") .. "..." end
    return name ~= "" and name or "Mechanic"
end

DM.MechanicTypes = {
    heavy = { label = "Heavy Attack", chat = "Block", color = "EAD38C" },
    interrupt = { label = "Interrupt", chat = "Interrupt", color = "FFB04F" },
    aoe = { label = "AoE / Avoid", chat = "Avoid", color = "FF7A4C" },
    stack = { label = "Stack", chat = "Stack", color = "92D0FF" },
    spread = { label = "Spread", chat = "Spread", color = "92D0FF" },
    adds = { label = "Adds", chat = "Adds", color = "FFD13D" },
    execute = { label = "Execute", chat = "Execute", color = "FF6060" },
    oneshot = { label = "One Shot", chat = "One Shot", color = "FF3333" },
    tank = { label = "Tank", chat = "Tank", color = "B0E5FF" },
    healer = { label = "Healer", chat = "Heal", color = "6BFF92" },
    dps = { label = "DPS Check", chat = "DPS", color = "FF993D" },
    portal = { label = "Portal", chat = "Portal", color = "B28CFF" },
    cc = { label = "Crowd Control", chat = "CC", color = "BDE0FF" },
    movement = { label = "Movement", chat = "Move", color = "DAD9FF" },
    timer = { label = "Timer", chat = "Timer", color = "E5D69E" },
    environmental = { label = "Environmental", chat = "Hazard", color = "FF8C2E" },
    debuff = { label = "Debuff", chat = "Debuff", color = "EA89FF" },
    lookaway = { label = "Look Away", chat = "Look Away", color = "F2F2C7" },
    generic = { label = "Mechanic", chat = "Mechanic", color = "E5D69E" },
}

function DM.GetMechanicType(raw)
    local explicitType = nil
    if type(raw) == "table" then
        explicitType = string.lower(Plain(raw.type or raw.mechanicType or raw.category or ""))
        raw = raw.description or raw.desc or raw.text or raw.name or raw.title or ""
    end
    local text = string.lower(Plain(raw or ""))
    local action = text:match("%(([^%)]+)%)") or text
    if explicitType and explicitType ~= "" then
        if explicitType:find("heavy") then return DM.MechanicTypes.heavy end
        if explicitType:find("interrupt") or explicitType:find("bash") then return DM.MechanicTypes.interrupt end
        if explicitType:find("aoe") or explicitType:find("avoid") then return DM.MechanicTypes.aoe end
        if explicitType:find("stack") then return DM.MechanicTypes.stack end
        if explicitType:find("spread") then return DM.MechanicTypes.spread end
        if explicitType:find("add") then return DM.MechanicTypes.adds end
        if explicitType:find("execute") or explicitType:find("enrage") then return DM.MechanicTypes.execute end
        if explicitType:find("one") and explicitType:find("shot") then return DM.MechanicTypes.oneshot end
        if explicitType:find("tank") then return DM.MechanicTypes.tank end
        if explicitType:find("heal") then return DM.MechanicTypes.healer end
        if explicitType:find("dps") then return DM.MechanicTypes.dps end
        if explicitType:find("portal") or explicitType:find("phase") then return DM.MechanicTypes.portal end
        if explicitType:find("crowd") or explicitType:find("control") or explicitType:find("cc") then return DM.MechanicTypes.cc end
        if explicitType:find("movement") or explicitType:find("move") then return DM.MechanicTypes.movement end
        if explicitType:find("timer") then return DM.MechanicTypes.timer end
        if explicitType:find("environment") or explicitType:find("hazard") then return DM.MechanicTypes.environmental end
        if explicitType:find("debuff") then return DM.MechanicTypes.debuff end
        if explicitType:find("look") then return DM.MechanicTypes.lookaway end
    end
    if text:find("one%-shot") or text:find("one shot") or text:find("lethal") or text:find("instant kill") or text:find("will kill") then return DM.MechanicTypes.oneshot end
    if text:find("execute") or text:find("enrage") or (text:find("%d+%%") and (text:find("health") or text:find("burn"))) then return DM.MechanicTypes.execute end
    if action:find("interrupt") or text:find("bash") or text:find("interrupt") then return DM.MechanicTypes.interrupt end
    if action:find("block") or text:find("heavy attack") or text:find("heavy melee") or text:find("heavy strike") or text:find("must be blocked") or text:find("block to") then return DM.MechanicTypes.heavy end
    if action:find("kill") or text:find(" add") or text:find("adds") or text:find("summon") or text:find("spawns") or text:find("spawn") or text:find("waves") then return DM.MechanicTypes.adds end
    if text:find("tank:") or text:find("taunt") or text:find("hold aggro") then return DM.MechanicTypes.tank end
    if action:find("heal") or text:find("healer") or text:find("heal ") or text:find("healing") or text:find("damage over time") or text:find("dot") then return DM.MechanicTypes.healer end
    if text:find("dps check") or text:find("burn") or text:find("damage check") or text:find("destroy") then return DM.MechanicTypes.dps end
    if text:find("portal") or text:find("teleport") or text:find("realm") or text:find("phase") then return DM.MechanicTypes.portal end
    if text:find("stun") or text:find("fear") or text:find("pin") or text:find("break free") or text:find("snare") or text:find("root") then return DM.MechanicTypes.cc end
    if text:find("stack") or text:find("group together") or text:find("group up") then return DM.MechanicTypes.stack end
    if text:find("spread") or text:find("separate") or text:find("away from group") then return DM.MechanicTypes.spread end
    if text:find("look away") or text:find("avoid looking") or text:find("do not look") or text:find("gaze") then return DM.MechanicTypes.lookaway end
    if text:find("timer") or text:find("seconds") or text:find("after ") or text:find("every ~") or text:find("every %d+") then return DM.MechanicTypes.timer end
    if text:find("environment") or text:find("trap") or text:find("lava") or text:find("fire") or text:find("poison") or text:find("ground") or text:find("arena") then return DM.MechanicTypes.environmental end
    if text:find("debuff") or text:find("curse") or text:find("disease") or text:find("plague") or text:find("poisoned") then return DM.MechanicTypes.debuff end
    if action:find("dodge") or action:find("avoid") or action:find("move") or action:find("roll") or text:find("aoe") or text:find("red circle") or text:find("cone") or text:find("cleave") or text:find("move out") then return DM.MechanicTypes.aoe end
    if text:find("kite") or text:find("move") or text:find("run") or text:find("chase") then return DM.MechanicTypes.movement end
    return DM.MechanicTypes.generic
end

function DM.GetMechanicDisplay(raw)
    local t = DM.GetMechanicType(raw)
    if type(raw) == "table" then
        local typeLabel = DM.Plain(raw.type or raw.mechanicType or raw.category or t.label or "MECHANIC")
        local name = DM.Plain(raw.name or raw.title or "Mechanic")
        local desc = DM.Plain(raw.description or raw.desc or raw.text or raw.detail or "")
        if name == "" then name = "Mechanic" end
        if desc == "" then desc = name end
        return {
            type = string.upper(typeLabel),
            name = name,
            description = desc,
            mechanicType = t,
            source = "structured",
        }
    end
    local name = DM.DeriveMechanicName(raw)
    local desc = DM.Plain(raw or "")
    return {
        type = string.upper(t.label or "MECHANIC"),
        name = name,
        description = desc,
        mechanicType = t,
        source = "legacy",
    }
end

function DM.IsHardModeMechanic(raw, display)
    if type(raw) == "table" and raw.hardMode == true then return true end
    local text = ""
    if display then text = (display.type or "") .. " " .. (display.name or "") .. " " .. (display.description or "") end
    if text == "" then
        if type(raw) == "table" then
            text = DM.Plain((raw.type or "") .. " " .. (raw.name or raw.title or "") .. " " .. (raw.description or raw.desc or raw.text or raw.detail or ""))
        else
            text = DM.Plain(raw or "")
        end
    end
    text = string.lower(text)
    return text:find("hard mode", 1, true) or text:find("hardmode", 1, true) or text:find(" hm ", 1, true) or text:find("%(hm%)", 1, true)
end

function DM.GetSelectedRoleHighlight()
    local role = DM.savedVars and DM.savedVars.roleHighlight or "All"
    role = string.lower(tostring(role or "All"))
    if role == "dps" or role == "healer" or role == "tank" then return role end
    return "all"
end

function DM.GetMechanicRole(raw, display)
    if type(raw) == "table" and type(raw.roles) == "table" then
        local selected = DM.GetSelectedRoleHighlight and DM.GetSelectedRoleHighlight() or "all"
        local firstRole = nil
        for _, role in ipairs(raw.roles) do
            local r = string.lower(tostring(role or ""))
            if r == "dps" or r == "healer" or r == "tank" then
                firstRole = firstRole or r
                if selected ~= "all" and r == selected then return r end
            end
        end
        if selected == "all" and firstRole then return firstRole end
    end
    local text = ""
    if display then text = (display.type or "") .. " " .. (display.name or "") .. " " .. (display.description or "") end
    if text == "" then
        if type(raw) == "table" then
            text = DM.Plain((raw.type or "") .. " " .. (raw.name or raw.title or "") .. " " .. (raw.description or raw.desc or raw.text or raw.detail or ""))
        else
            text = DM.Plain(raw or "")
        end
    end
    text = string.lower(text)
    if text:find("tank") or text:find("taunt") or text:find("face") or text:find("frontal") or text:find("cleave") or text:find("heavy") or text:find("block") then return "tank" end
    if text:find("healer") or text:find("heal") or text:find("dot") or text:find("damage over time") or text:find("cleanse") or text:find("purge") then return "healer" end
    if text:find("dps") or text:find("burn") or text:find("kill") or text:find("destroy") or text:find("adds") or text:find("interrupt") then return "dps" end
    return "all"
end

function DM.GetRoleColor(role)
    if role == "tank" then return 0.38, 0.68, 1.00 end
    if role == "healer" then return 0.34, 1.00, 0.48 end
    if role == "dps" then return 1.00, 0.35, 0.30 end
    return 0.98, 0.82, 0.38
end

function DM.SafeChatInput(message)
    -- Chat/share linking is disabled on PS5 because gamepad chat input is
    -- protected and can throw UI errors. Keep this as a safe no-op in case
    -- old helper functions are accidentally called.
    return
end

function DM.LinkSelectedMechanic()
    if (DM.level or 1) ~= 3 then return end
    local boss = DM.GetSelectedBoss()
    local raw = DM.GetSelectedMechanicText()
    if not boss or not raw then return end
    local display = DM.GetMechanicDisplay and DM.GetMechanicDisplay(raw) or nil
    local mechanicName = (display and display.name and display.name ~= "") and display.name or DM.DeriveMechanicName(raw)
    DM.SafeChatInput(string.format("%s, Mechanic: %s", DM.CleanBossName(boss.name), mechanicName))
end

function DM.LinkBossSummary()
    local boss = DM.GetSelectedBoss()
    if not boss or not boss.mechanics then return end
    local lines = { string.format("%s, Mechanics", Plain(boss.name)) }
    local len = #lines[1]
    for _, raw in ipairs(boss.mechanics) do
        local t = DM.GetMechanicType(raw)
        local line = string.format("- [%s] %s: %s", t.chat or "Mechanic", DM.DeriveMechanicName(raw), Plain(raw))
        len = len + #line + 1
        if len > 850 then table.insert(lines, "- Continued in Mechanic Mentor guide."); break end
        table.insert(lines, line)
    end
    DM.SafeChatInput(table.concat(lines, "\n"))
end


function DM.NormalizeBossLookupName(name)
    local raw = tostring(name or "")
    DM.normalizedNameCache = DM.normalizedNameCache or {}
    local cached = DM.normalizedNameCache[raw]
    if cached ~= nil then return cached end

    local text = DM.Plain(raw)
    text = string.lower(text)
    text = text:gsub("%b()", "")
    text = text:gsub("boss%s*#%d+", "")
    text = text:gsub("secret%s*#%d+", "")
    text = text:gsub("[^%w%s%-']", "")
    text = text:gsub("%f[%w]the%f[%W]", "")
    text = text:gsub("%s+", " ")
    text = text:gsub("^%s+", ""):gsub("%s+$", "")
    DM.normalizedNameCache[raw] = text
    return text
end

function DM.BuildBossLookup()
    local lookup = {}
    local function add(tbl)
        if not tbl then return end
        for zoneId, dungeon in pairs(tbl) do
            if dungeon and dungeon.bosses then
                for bossIndex, boss in ipairs(dungeon.bosses) do
                    local clean = DM.CleanBossName and DM.CleanBossName(boss.name) or DM.Plain(boss.name)
                    local key = DM.NormalizeBossLookupName(clean)
                    if key ~= "" and not lookup[key] then
                        lookup[key] = { boss = boss, dungeon = dungeon, zoneId = zoneId, bossIndex = bossIndex }
                    end
                end
            end
        end
    end
    add(TTDungeon and TTDungeon.BaseDungeonInfo_en)
    add(TTDungeon and TTDungeon.DLCDungeonInfo_en)
    -- Trial boss lookup support. Trial boss names will start matching the quick
    -- summary panel as trial data is filled in future data passes.
    local trials = MechanicMentorTrials and MechanicMentorTrials.List or {}
    for trialIndex, trial in ipairs(trials) do
        if trial and trial.bosses then
            for bossIndex, boss in ipairs(trial.bosses) do
                local clean = DM.CleanBossName and DM.CleanBossName(boss.name) or DM.Plain(boss.name)
                local key = DM.NormalizeBossLookupName(clean)
                if key ~= "" and not lookup[key] then
                    lookup[key] = { boss = boss, trial = trial, trialIndex = trialIndex, bossIndex = bossIndex }
                end
            end
        end
    end
    DM.bossLookup = lookup
    DM.bossNameMatchCache = {}
end

function DM.InvalidateQuickSummary()
    DM.lastQuickBossRef = nil
    DM.lastQuickBossName = nil
    DM.lastQuickFullMode = nil
end

function DM.GetTargetBossMatch()
    if not DoesUnitExist or not DoesUnitExist("reticleover") then return nil end
    if IsUnitDead and IsUnitDead("reticleover") then return nil end
    local name = GetUnitName and GetUnitName("reticleover") or nil
    if not name or name == "" then return nil end
    return DM.MatchBossName(name)
end


function DM.MatchBossName(name)
    if not name or name == "" then return nil end
    if not DM.bossLookup then DM.BuildBossLookup() end
    local key = DM.NormalizeBossLookupName(name)
    if not DM.bossLookup or key == "" then return nil end

    DM.bossNameMatchCache = DM.bossNameMatchCache or {}
    local cached = DM.bossNameMatchCache[key]
    if cached ~= nil then return cached or nil end

    local direct = DM.bossLookup[key]
    if direct then
        DM.bossNameMatchCache[key] = direct
        return direct
    end

    local best, bestLen = nil, 0
    if #key >= 5 then
        for bossKey, data in pairs(DM.bossLookup) do
            if #bossKey >= 5 and (key:find(bossKey, 1, true) or bossKey:find(key, 1, true)) then
                local score = math.min(#key, #bossKey)
                if score > bestLen then best, bestLen = data, score end
            end
        end
    end
    DM.bossNameMatchCache[key] = best or false
    return best
end

function DM.GetBossUnitMatch()
    if not DoesUnitExist or not GetUnitName then return nil end
    -- Boss frames usually use boss1...boss6 when ESO has registered an encounter
    -- or boss unit in the area. This is closer to Crutch Alerts style detection
    -- than requiring the player to keep the reticle on the boss.
    for i = 1, 6 do
        local tag = "boss" .. i
        if DoesUnitExist(tag) and not (IsUnitDead and IsUnitDead(tag)) then
            local name = GetUnitName(tag)
            local match = DM.MatchBossName(name)
            if match then return match end
        end
    end
    return nil
end

function DM.GetQuickActionLabel(raw, mechanicType)
    local text = string.lower(DM.Plain(raw or ""))
    local action = string.upper(mechanicType and (mechanicType.chat or mechanicType.label) or "MECHANIC")
    if text:find("kill") or text:find("adds") or text:find("summon") or text:find("spawns") or text:find("wraith") or text:find("spider") then return "KILL" end
    if text:find("interrupt") or text:find("bash") then return "INTERRUPT" end
    if text:find("break free") or text:find("pinned") or text:find("pinning") then return "BREAK FREE" end
    if text:find("block") or text:find("heavy") or text:find("cleave") then return "BLOCK" end
    if text:find("move") or text:find("avoid") or text:find("dodge") or text:find("aoe") or text:find("circle") then return "AVOID" end
    if text:find("heal") or text:find("healer") or text:find("dot") then return "HEAL" end
    return action
end

function DM.DeriveQuickMechanicName(raw, action)
    local text = DM.Plain(raw or "")
    if text == "" then return "Mechanic" end

    -- If the string has a setup prefix like "Boss faces tank:", use the
    -- detail after the colon, then cut at the first dash.
    local beforeColon, afterColon = text:match("^([^:]+):%s*(.+)$")
    if afterColon then
        local b = string.lower(DM.Plain(beforeColon))
        if b:find("boss") or b:find("tank") or b:find("player") then
            text = afterColon
        end
    end

    local first = text:match("^([^–—]+)[–—]")
    if not first then first = text:match("^([^%-]+)%s+%-%s+") end
    if first then
        first = DM.Plain(first)
        if #first > 0 then
            if #first > 52 then first = first:sub(1, 49):gsub("%s+%S*$", "") .. "..." end
            return first
        end
    end

    if text:find("Agony") then return "Agony" end
    if text:find("Blood Craze") then return "Blood Craze" end
    if text:find("Frenzy of Blows") then return "Frenzy of Blows" end
    if text:lower():find("orb") then return "Orbs" end

    local name = DM.DeriveMechanicName(text)
    name = DM.Plain(name)
    if #name > 52 then name = name:sub(1, 49):gsub("%s+%S*$", "") .. "..." end
    if name ~= "" and name ~= "Mechanic" then return name end

    if action == "KILL" then return "Adds" end
    if action == "BLOCK" then return "Heavy Attack" end
    if action == "INTERRUPT" then return "Interrupt" end
    if action == "BREAK FREE" then return "Control Effect" end
    if action == "AVOID" then return "AoE" end
    return "Mechanic"
end

function DM.BuildQuickBullet(raw)
    local display = DM.GetMechanicDisplay(raw)
    local t = display.mechanicType or DM.GetMechanicType(raw)
    local action = DM.GetQuickActionLabel(raw, t)
    local name = display.source == "structured" and display.name or DM.DeriveQuickMechanicName(raw, action)
    return action .. ": " .. name
end

function DM.BuildFullQuickBullet(raw)
    local display = DM.GetMechanicDisplay(raw)
    local t = display.mechanicType or DM.GetMechanicType(raw)
    local action = DM.GetQuickActionLabel(raw, t)
    local name = display.source == "structured" and display.name or DM.DeriveQuickMechanicName(raw, action)
    local text = display.description or ""
    text = DM.Plain(text):gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
    if display.source ~= "structured" and name ~= "" then
        local escaped = name:gsub("([%%%^%$%(%)%%.%[%]%*%+%-%?])", "%%%1")
        text = text:gsub("^" .. escaped .. "%s*[–—%-:]%s*", "")
    end
    if #text > 180 then text = text:sub(1, 177):gsub("%s+%S*$", "") .. "..." end
    return action .. ": " .. name .. " — " .. text
end

function DM.BuildQuickSummaryBullets(boss)
    if not boss or not boss.mechanics then return {} end
    local fullMode = DM.savedVars and DM.savedVars.quickSummaryFull == true
    local cacheKey = fullMode and "full" or "summary"
    boss._mmQuickBullets = boss._mmQuickBullets or {}
    if boss._mmQuickBullets[cacheKey] then return boss._mmQuickBullets[cacheKey] end

    local bullets = {}
    for _, raw in ipairs(boss.mechanics) do
        if fullMode then
            table.insert(bullets, DM.BuildFullQuickBullet(raw))
        else
            table.insert(bullets, DM.BuildQuickBullet(raw))
        end
    end
    boss._mmQuickBullets[cacheKey] = bullets
    return bullets
end

function DM.IsSupportedMechanicInstance()
    -- Prevent reused NPC/boss assets in overland, houses, arenas, or other UI contexts
    -- from triggering the quick mechanics panel. The panel is only allowed inside
    -- dungeon/trial-style instances.
    if IsUnitInDungeon and IsUnitInDungeon("player") then
        return true
    end
    if GetCurrentZoneDungeonDifficulty then
        local difficulty = GetCurrentZoneDungeonDifficulty()
        if difficulty and difficulty ~= 0 then
            return true
        end
    end
    return false
end

function DM.UpdateQuickSummary()
    if not DM.savedVars or DM.savedVars.quickSummary == false then
        if DM.HideQuickSummaryPanel then DM.HideQuickSummaryPanel() end
        return
    end
    if not (DM.IsSupportedMechanicInstance and DM.IsSupportedMechanicInstance()) then
        if DM.HideQuickSummaryPanel then DM.HideQuickSummaryPanel() end
        return
    end
    if IsUnitInCombat and IsUnitInCombat("player") and not (DM.savedVars and DM.savedVars.quickSummaryInCombat == true) then
        if DM.HideQuickSummaryPanel then DM.HideQuickSummaryPanel() end
        return
    end
    -- Hide while the full guide is open so the two UI systems do not overlap.
    if DM.root and not DM.root:IsHidden() then
        if DM.HideQuickSummaryPanel then DM.HideQuickSummaryPanel() end
        return
    end
    local match = DM.GetBossUnitMatch() or DM.GetTargetBossMatch()
    if not match or not match.boss then
        if DM.HideQuickSummaryPanel then DM.HideQuickSummaryPanel() end
        return
    end
    local bossName = (DM.CleanBossName and DM.CleanBossName(match.boss.name)) or DM.Plain(match.boss.name)
    local fullMode = DM.savedVars and DM.savedVars.quickSummaryFull == true
    if DM.lastQuickBossRef == match.boss and DM.lastQuickFullMode == fullMode and DM.quickRoot and not DM.quickRoot:IsHidden() then
        return
    end
    local bullets = DM.BuildQuickSummaryBullets(match.boss)
    DM.lastQuickBossRef = match.boss
    DM.lastQuickBossName = bossName
    DM.lastQuickFullMode = fullMode
    if DM.SetQuickSummaryPanel then DM.SetQuickSummaryPanel(bossName, bullets, fullMode) end
end

function DM.RegisterQuickSummaryEvents()
    if DM.quickSummaryEventsRegistered then return end
    if EVENT_MANAGER then
        if EVENT_RETICLE_TARGET_CHANGED then
            EVENT_MANAGER:RegisterForEvent(DM.name .. "QuickTarget", EVENT_RETICLE_TARGET_CHANGED, function() DM.UpdateQuickSummary() end)
        end
        if EVENT_PLAYER_COMBAT_STATE then
            EVENT_MANAGER:RegisterForEvent(DM.name .. "QuickCombat", EVENT_PLAYER_COMBAT_STATE, function() DM.UpdateQuickSummary() end)
        end
        if EVENT_BOSSES_CHANGED then
            EVENT_MANAGER:RegisterForEvent(DM.name .. "QuickBosses", EVENT_BOSSES_CHANGED, function() DM.UpdateQuickSummary() end)
        end
        EVENT_MANAGER:RegisterForUpdate(DM.name .. "QuickPoll", 1500, function() DM.UpdateQuickSummary() end)
    end
    DM.quickSummaryEventsRegistered = true
end

function DM.InitializeSelection()
    DM.dungeonCategory = DM.dungeonCategory or "base"
    DM.dungeons = DM.GetFilteredDungeons(DM.dungeonCategory)
    local current = DM.GetCurrentDungeon()
    local targetZoneId = current and current.zoneId or (DM.savedVars and DM.savedVars.lastDungeonId)
    DM.selectedDungeonIndex = 1
    for i, dng in ipairs(DM.dungeons or {}) do
        if dng.zoneId == targetZoneId then DM.selectedDungeonIndex = i; break end
    end
    if DM.dungeons and DM.dungeons[DM.selectedDungeonIndex] then DM.selectedDungeonId = DM.dungeons[DM.selectedDungeonIndex].zoneId end
    DM.selectedBossIndex = 1
    DM.selectedMechanicIndex = 1
    DM.mechanicScrollIndex = 1
    DM.level = 1
end

function DM.CreateScene()
    if DM.scene then return end
    if DM.CreateUI then DM.CreateUI() end
    if not DM.root then return end
    DM.fragment = ZO_FadeSceneFragment:New(DM.root)
    DM.scene = ZO_Scene:New(DM.sceneName, SCENE_MANAGER)
    -- Add common gamepad menu fragments when they exist. These are guarded so
    -- older/newer API variants do not hard-error.
    if FRAGMENT_GROUP and FRAGMENT_GROUP.GAMEPAD_DRIVEN_UI_WINDOW and DM.scene.AddFragmentGroup then
        DM.scene:AddFragmentGroup(FRAGMENT_GROUP.GAMEPAD_DRIVEN_UI_WINDOW)
    end
    if GAMEPAD_NAV_QUADRANT_2_3_4_BACKGROUND_FRAGMENT then DM.scene:AddFragment(GAMEPAD_NAV_QUADRANT_2_3_4_BACKGROUND_FRAGMENT) end
    if GAMEPAD_GENERIC_FOOTER_FRAGMENT then DM.scene:AddFragment(GAMEPAD_GENERIC_FOOTER_FRAGMENT) end
    if GAMEPAD_MENU_SOUND_FRAGMENT then DM.scene:AddFragment(GAMEPAD_MENU_SOUND_FRAGMENT) end
    DM.scene:AddFragment(DM.fragment)
    DM.scene:RegisterCallback("StateChange", function(oldState, newState)
        if newState == SCENE_SHOWING then DM.OnSceneShowing() end
        if newState == SCENE_HIDING then DM.OnSceneHiding() end
    end)
end

function DM.Open()
    DM.CreateScene()
    -- Gamepad/console scenes must be entered from the gamepad menu stack.
    -- Opening our scene directly from chat leaves the camera in world-input mode,
    -- which is why movement closes the window and button input does not route.
    if IsInGamepadPreferredMode and IsInGamepadPreferredMode() and SCENE_MANAGER then
        if SCENE_MANAGER:GetScene("mainMenuGamepad") then
            SCENE_MANAGER:Show("mainMenuGamepad")
            zo_callLater(function()
                if DM.scene then SCENE_MANAGER:Push(DM.sceneName) end
                DM.RefreshUI()
            end, 80)
            return
        end
    end
    if DM.scene then SCENE_MANAGER:Show(DM.sceneName) elseif DM.root then DM.root:SetHidden(false) end
    DM.RefreshUI()
end

function DM.Close()
    if SCENE_MANAGER and DM.scene and SCENE_MANAGER:GetCurrentScene() == DM.scene then
        SCENE_MANAGER:HideCurrentScene()
    elseif DM.root then
        DM.root:SetHidden(true)
    end
end

function DM.OpenFromAddonMenu()
    DM.CreateScene()
    DM.level = DM.level or 1
    -- When launched from the native Add-Ons page, push our scene on the UI stack so
    -- controller input remains in menu mode and player movement is suppressed.
    if SCENE_MANAGER and DM.scene then
        local current = SCENE_MANAGER:GetCurrentScene()
        if current and current.GetName and current:GetName() ~= DM.sceneName then
            local ok = pcall(function() SCENE_MANAGER:Push(DM.sceneName) end)
            if not ok then SCENE_MANAGER:Show(DM.sceneName) end
        else
            SCENE_MANAGER:Show(DM.sceneName)
        end
    elseif DM.root then
        DM.root:SetHidden(false)
    end
    zo_callLater(function() DM.RefreshUI() end, 50)
end

function DM.OpenCurrentDungeonFromAddonMenu()
    DM.contentMode = "dungeon"
    DM.CreateScene()
    local current = DM.GetCurrentDungeon and DM.GetCurrentDungeon() or nil
    if current and current.zoneId then
        local category = (TTDungeon and TTDungeon.BaseDungeonInfo_en and TTDungeon.BaseDungeonInfo_en[current.zoneId]) and "base" or "dlc"
        DM.dungeonCategory = category
        DM.dungeons = DM.GetFilteredDungeons(category)
        DM.selectedDungeonIndex = 1
        for i, dng in ipairs(DM.dungeons or {}) do
            if dng.zoneId == current.zoneId then DM.selectedDungeonIndex = i; break end
        end
        DM.selectedDungeonId = current.zoneId
        DM.selectedBossIndex = 1
        DM.selectedMechanicIndex = 1
        DM.mechanicScrollIndex = 1
        DM.level = 2
    else
        DM.level = 1
        DM.InitializeSelection()
    end
    DM.OpenFromAddonMenu()
end

function DM.RegisterLibAddonMenuLauncher()
    if DM._lamRegistered then return true end
    local LAM = LibAddonMenu2 or LibAddonMenu
    if not LAM then return false end

    local panelName = "MechanicMentorOptionsPanel"
    local panelData = {
        type = "panel",
        name = "Mechanic Mentor",
        displayName = "Mechanic Mentor",
        author = DM.author,
        version = DM.version,
        registerForRefresh = true,
        registerForDefaults = true,
    }
    local optionsData = {
        {
            type = "button",
            name = "Dungeon List",
            tooltip = "Open the full dungeon list.",
            func = function() DM.contentMode = "dungeon"; DM.level = 1; DM.OpenFromAddonMenu() end,
            width = "full",
        },
        {
            type = "button",
            name = "Current Dungeon",
            tooltip = "If you are inside a known dungeon, jump directly to its boss list.",
            func = function() DM.OpenCurrentDungeonFromAddonMenu() end,
            width = "full",
        },
        {
            type = "button",
            name = "Trials List",
            tooltip = "Open the trial list, sorted from oldest release to newest.",
            func = function() DM.OpenTrialsFromAddonMenu() end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Boss Quick Summary",
            tooltip = "Show the mechanics quick panel when targeting a boss found in the Mechanic Mentor database.",
            getFunc = function() return DM.savedVars and DM.savedVars.quickSummary ~= false end,
            setFunc = function(value)
                if DM.savedVars then DM.savedVars.quickSummary = value end
                if not value and DM.HideQuickSummaryPanel then DM.HideQuickSummaryPanel() end
                if value and DM.UpdateQuickSummary then DM.UpdateQuickSummary() end
            end,
            default = true,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Show Mechanics UI During Combat",
            tooltip = "When enabled, the mechanics quick panel can remain visible during combat, but only inside dungeon or trial instances. When disabled, it hides while you are in combat.",
            getFunc = function() return DM.savedVars and DM.savedVars.quickSummaryInCombat == true end,
            setFunc = function(value)
                if DM.savedVars then DM.savedVars.quickSummaryInCombat = value end
                if not value and IsUnitInCombat and IsUnitInCombat("player") and DM.HideQuickSummaryPanel then DM.HideQuickSummaryPanel() end
                if value and DM.UpdateQuickSummary then DM.UpdateQuickSummary() end
            end,
            default = false,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Use Full Mechanics In Quick Panel",
            tooltip = "When enabled, the mechanics quick panel uses fuller mechanic lines as a tutorial view. When disabled, it uses short summary bullets.",
            getFunc = function() return DM.savedVars and DM.savedVars.quickSummaryFull == true end,
            setFunc = function(value)
                if DM.savedVars then DM.savedVars.quickSummaryFull = value end
                if DM.InvalidateQuickSummary then DM.InvalidateQuickSummary() end; if DM.UpdateQuickSummary then DM.UpdateQuickSummary() end
            end,
            default = false,
            width = "full",
        },
        {
            type = "dropdown",
            name = "Role Highlight",
            tooltip = "Highlight mechanics that appear most relevant to a selected role. DPS = red, Healer = green, Tank = blue.",
            choices = { "All", "DPS", "Healer", "Tank" },
            getFunc = function() return (DM.savedVars and DM.savedVars.roleHighlight) or "All" end,
            setFunc = function(value)
                if DM.savedVars then DM.savedVars.roleHighlight = value end
                if DM.RefreshUI then DM.RefreshUI() end
                if DM.InvalidateQuickSummary then DM.InvalidateQuickSummary() end; if DM.UpdateQuickSummary then DM.UpdateQuickSummary() end
            end,
            width = "full",
        },
        {
            type = "slider",
            name = "Quick Panel Scale",
            tooltip = "Adjust the size of the mechanics quick summary panel.",
            min = 80,
            max = 140,
            step = 5,
            getFunc = function() return math.floor(((DM.savedVars and DM.savedVars.quickPanelScale) or 1.0) * 100) end,
            setFunc = function(value)
                if DM.savedVars then DM.savedVars.quickPanelScale = value / 100 end
                if DM.InvalidateQuickSummary then DM.InvalidateQuickSummary() end; if DM.UpdateQuickSummary then DM.UpdateQuickSummary() end
            end,
            width = "full",
        },
        {
            type = "slider",
            name = "Quick Panel Opacity",
            tooltip = "Adjust the background opacity of the mechanics quick summary panel.",
            min = 30,
            max = 100,
            step = 5,
            getFunc = function() return (DM.savedVars and DM.savedVars.quickPanelOpacity) or 64 end,
            setFunc = function(value)
                if DM.savedVars then DM.savedVars.quickPanelOpacity = value end
                if DM.InvalidateQuickSummary then DM.InvalidateQuickSummary() end; if DM.UpdateQuickSummary then DM.UpdateQuickSummary() end
            end,
            width = "full",
        },
        {
            type = "description",
            text = "MECHANIC MENTOR BY BLKX777.\n\nIF YOU ENCOUNTER BUGS OR HAVE ANY SUGGESTIONS FOR IMPROVEMENTS PLEASE MESSAGE BLKX777 ON PSN.\n\nTHANK YOU FOR YOUR SUPPORT!",
        },
    }

    local ok = pcall(function()
        if LAM.RegisterAddonPanel then
            LAM:RegisterAddonPanel(panelName, panelData)
            LAM:RegisterOptionControls(panelName, optionsData)
        elseif LAM.RegisterPanel then
            LAM:RegisterPanel(panelName, panelData)
            LAM:RegisterOptionControls(panelName, optionsData)
        else
            error("Unsupported LibAddonMenu API")
        end
    end)
    DM._lamRegistered = ok
    return ok
end

function DM.TryInjectAddonMenuEntry()
    -- This is intentionally separate from LibAddonMenu. Some console builds expose
    -- the Add-Ons list object but not LAM. Each path is guarded to avoid UI errors.
    if DM._addonMenuInjected then return true end
    DM.CreateScene()
    local label = "Mechanic Mentor"
    local descriptor = "DUNGEON_MECHANICS_ADDON_LAUNCHER"
    local icon = "/MechanicMentor/Icons/generic.dds"
    local function data()
        return {
            name = label,
            text = label,
            header = label,
            title = label,
            descriptor = descriptor,
            icon = icon,
            normal = icon,
            selected = icon,
            callback = function() DM.OpenFromAddonMenu() end,
            onSelected = function() DM.OpenFromAddonMenu() end,
            narrationText = label,
        }
    end
    local function listHasEntry(list)
        if not list or not list.GetNumItems or not list.GetEntryData then return false end
        local count = list:GetNumItems() or 0
        for i = 1, count do
            local entry = list:GetEntryData(i)
            if entry then
                local entryData = entry.data or entry
                if entryData.descriptor == descriptor or entryData.name == label or entryData.text == label then
                    return true
                end
            end
        end
        return false
    end

    local function addToList(list)
        if not list or not list.AddEntry then return false end
        if listHasEntry(list) then return true end
        return DM.PCall("Add Mechanic Mentor launcher to Add-Ons list", function()
            list:AddEntry("ZO_GamepadMenuEntryTemplate", data())
            if list.Commit then list:Commit() end
            return true
        end)
    end
    local candidates = {
        _G.GAMEPAD_ADDONS,
        _G.GAMEPAD_ADD_ONS,
        _G.GAMEPAD_ADDON_MANAGER,
        _G.ADDONS_MENU_GAMEPAD,
        _G.ZO_GamepadAddons,
        _G.ZO_GamepadAddOnManager,
    }
    local did = false
    for _, obj in ipairs(candidates) do
        if obj then
            did = addToList(obj.categoryList) or did
            did = addToList(obj.navigationList) or did
            did = addToList(obj.list) or did
            if obj.navigationTree and obj.navigationTree.AddNode then
                did = DM.PCall("Add Mechanic Mentor launcher to Add-Ons tree", function()
                    obj.navigationTree:AddNode("ZO_GamepadMenuEntryTemplate", data(), nil)
                    if obj.navigationTree.Commit then obj.navigationTree:Commit() end
                    return true
                end) or did
            end
        end
    end
    if did then DM._addonMenuInjected = true end
    return did
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= DM.name then return end
    EVENT_MANAGER:UnregisterForEvent(DM.name, EVENT_ADD_ON_LOADED)
    DM.savedVars = ZO_SavedVars:NewAccountWide("MechanicMentorSavedVars", 2, nil, defaults)
    DM.InitializeSelection()
    DM.CreateScene()
    if DM.CreateQuickSummaryUI then DM.CreateQuickSummaryUI() end
    -- Boss lookup is now built lazily only when the quick panel actually needs it.
    DM.RegisterQuickSummaryEvents()
    if DM.root then DM.root:SetHidden(true) end
    -- Supported access target for this test: Menu > Add-Ons > Mechanic Mentor > Dungeon List.
    zo_callLater(function() DM.RegisterLibAddonMenuLauncher(); DM.TryInjectAddonMenuEntry() end, 1000)
    zo_callLater(function() DM.RegisterLibAddonMenuLauncher(); DM.TryInjectAddonMenuEntry() end, 3000)
    SLASH_COMMANDS["/mechanicmentor"] = function() DM.OpenFromAddonMenu() end -- rescue only
end

EVENT_MANAGER:RegisterForEvent(DM.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
