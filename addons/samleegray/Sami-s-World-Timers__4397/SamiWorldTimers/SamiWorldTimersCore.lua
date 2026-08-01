local SWT = SamiWorldTimers

SWT.core = SWT.core or {}

local core = SWT.core
local util = SWT.util

local function markSortedDirty()
    SWT.sortedDirty = true
end

function core.getSortedBosses()
    if SWT.sortedDirty then
        local tab = {}
        for name in pairs(SWT.bossTimes) do
            tab[#tab + 1] = name
        end
        table.sort(tab, function(a, b) return SWT.bossTimes[a] < SWT.bossTimes[b] end)
        SWT.sortedBosses = tab
        SWT.sortedDirty = false
    end
    return SWT.sortedBosses
end

local function buildOutput()
    local outputLines = {}

    for _, name in ipairs(core.getSortedBosses()) do
        local timeLeft = SWT.bossTimes[name] - os.time()

        if timeLeft < -SWT.settings.timeoutDuration then
            SWT.bossTimes[name] = nil
            markSortedDirty()
            break
        end

        local line
        if timeLeft > 0 then
            line = util.formatTime(timeLeft) .. " " .. name .. "\n"
            if timeLeft < SWT.settings.alertDuration then
                line = util.colorText(line, SWT.settings.alertColour)
            elseif timeLeft < SWT.settings.warningDuration then
                line = util.colorText(line, SWT.settings.warningColour)
            end
        else
            line = "-" .. util.formatTime(math.abs(timeLeft)) .. " " .. name .. " is about to spawn!" .. "\n"
            line = util.colorText(line, SWT.settings.alertColour)
        end

        outputLines[#outputLines + 1] = line
    end

    return table.concat(outputLines)
end

function SWT.updateTimer()
    local output = buildOutput()

    if not next(SWT.bossTimes) then
        EVENT_MANAGER:UnregisterForUpdate(SWT.name .. "Boss Tracker")
    end

    SWT.ui.setText(output)
end

function SWT.addTimer(name, respawnTime)
    SWT.bossTimes[name] = os.time() + respawnTime
    markSortedDirty()
    EVENT_MANAGER:RegisterForUpdate(SWT.name .. "Boss Tracker", 500, SWT.updateTimer)
end

function SWT.manualAdd(name)
    local respawnTime = 300
    if util.getCurrentZoneId() == 1133 then respawnTime = 570 end

    if name == "" then
        local bossesAmount = 0
        for _ in pairs(SWT.bossTimes) do
            bossesAmount = bossesAmount + 1
        end

        name = "Boss" .. tostring(bossesAmount + 1)
    end

    SWT.addTimer(name, respawnTime)
end

ZO_CreateStringId("SI_BINDING_NAME_SAMI_WORLD_TIMERS_MANUAL_BOSS", "Add boss timer manually")

SLASH_COMMANDS["/samiwt"] = function(args)
    SWT.manualAdd(args)
end
