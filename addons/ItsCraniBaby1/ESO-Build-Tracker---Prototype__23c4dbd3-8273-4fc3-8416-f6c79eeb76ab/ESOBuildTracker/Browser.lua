local A = ESOBuildTracker
A.tabs = { "Gear", "Skills", "Stats", "Builds" }
A.tabIndex, A.selection, A.scrollOffset = 1, 1, 0
A.menuStack = {}

function A.Row(title, subtitle, detail, action, key)
    return { title = title, subtitle = subtitle or "", detail = detail or "", action = action, key = key or title }
end

function A.ReportSection(snapshot, key)
    if A.reportSource ~= snapshot or not A.reportSections then
        A.reportSource, A.reportSections = snapshot, {}
        for _, section in ipairs(A.BuildReport(snapshot)) do A.reportSections[section.key] = section end
    end
    return A.reportSections[key] and A.reportSections[key].text or "No captured details."
end

local function StatusText(result)
    local text = result.status
    if #result.issues > 0 then text = text .. "\n" .. table.concat(result.issues, "\n") end
    return text
end

function A.TabRows()
    local snapshot, build = A.GetViewedSnapshot(), A.ActiveBuild()
    if A.tabIndex ~= 4 and not snapshot then
        return { A.Row("Waiting for character", "Select Refresh", "Load your character, then refresh the tracker.") }
    end
    local rows = {}
    if A.tabIndex == 1 then
        for _, captured in ipairs(snapshot.equipment) do
            local item = captured
            local goal = build and build.gear[item.key]
            local result = A.CompareGear(item, goal)
            local name = item.status == "equipped" and item.name or (item.status == "empty" and "Empty" or "Unavailable")
            local detail = StatusText(result) .. "\n\n" .. A.GearGoalText(goal) .. "\n\nCURRENT ITEM\n"
                .. (item.status == "equipped" and A.ReportSection(snapshot, "item:" .. item.key) or name)
            local row = A.Row(item.slotLabel, name .. "  |  " .. result.status, detail,
                function() A.EditGear(item.key) end, item.key)
            row.status = result.status
            rows[#rows + 1] = row
        end
    elseif A.tabIndex == 2 then
        for barIndex, bar in ipairs(snapshot.bars) do
            for skillIndex, captured in ipairs(bar.slots) do
                local bi, si, skill = barIndex, skillIndex, captured
                local goal = build and build.skills[bi][si]
                local result = A.CompareSkill(skill, goal)
                local title = bar.label .. " - " .. (skill.ultimate and "Ultimate" or "Slot " .. si)
                local name = skill.status == "slotted" and skill.name or (skill.status == "empty" and "Empty" or "Unavailable")
                local detail = StatusText(result) .. "\n\nTarget: " .. (goal and (goal.status == "empty" and "Empty" or goal.name) or "Not tracked")
                    .. "\n\nCURRENT SKILL\n" .. name
                if skill.rank then detail = detail .. "\nRank: " .. skill.rank end
                for i, label in ipairs({ "Focus", "Signature", "Affix" }) do
                    if skill.scripts and skill.scripts[i] then detail = detail .. "\n" .. label .. ": " .. skill.scripts[i].name end
                end
                if skill.description then detail = detail .. "\n\n" .. skill.description end
                if bi == 2 and snapshot.weaponSwapLocked then detail = detail .. "\n\nWeapon swapping was locked at capture." end
                local row = A.Row(title, name .. "  |  " .. result.status, detail, function() A.EditSkill(bi, si) end, "skill:" .. bi .. ":" .. si)
                row.status = result.status
                rows[#rows + 1] = row
            end
        end
    elseif A.tabIndex == 3 then
        local barKey = A.StatBarKey(snapshot)
        local targets = build and barKey and build.stats[barKey] or {}
        for _, captured in ipairs(snapshot.stats) do
            local stat = captured
            local minimum = targets and targets[stat.constant]
            local result = A.CompareStat(stat.value, minimum)
            local detail = "Observed: " .. tostring(stat.value or "Unavailable")
                .. "\nMinimum target: " .. tostring(minimum or "Not tracked")
                .. "\n\n" .. StatusText(result) .. "\n\nCaptured with: " .. A.ActiveBarName(snapshot)
                .. "\n" .. A.CaptureTimeText(snapshot)
                .. "\n\nTotals reflect buffs, passives, CP and the active bar at capture. Targets are saved separately for front and back bars. They are not included in permanent gear/skill completion."
            local row = A.Row(stat.label, tostring(stat.value or "Unavailable") .. "  |  " .. result.status,
                detail, function() A.EditStat(stat.constant, stat.label, barKey) end, stat.constant)
            row.status = result.status
            rows[#rows + 1] = row
        end
    else
        rows[#rows + 1] = A.Row("New build from this setup", "Copy viewed gear and skills as a starting target",
            "Create a named target from the setup shown at the top. Then edit individual requirements on the Gear and Skills tabs. Empty slots are initially untracked. Stats are set separately.", function() A.NewBuild(true) end)
        rows[#rows + 1] = A.Row("New blank build", "Track only the requirements you choose",
            "Create an empty target build, then select gear, skills and stats to track. You can keep up to ten builds per character.", function() A.NewBuild(false) end)
        for _, savedBuild in ipairs(A.saved.builds) do
            local target = savedBuild
            local progress = A.Progress(snapshot, target)
            local detail = target.name .. "\n\n" .. progress.matched .. " / " .. progress.total .. " tracked gear and skill slots match."
                .. "\nMissing: " .. progress.missing .. "\nNeeds changes: " .. progress.change .. "\nUnknown: " .. progress.unknown
                .. "\n\n" .. (target.notes ~= "" and target.notes or "No notes.")
                .. "\n\nComparison checks what is equipped and slotted. Inventory, bank ownership and set-bonus activation are not inferred."
            rows[#rows + 1] = A.Row(target.name, (build == target and "ACTIVE  |  " or "") .. progress.matched .. "/" .. progress.total .. " matching",
                detail, function() A.OpenBuildMenu(target.id) end, "build:" .. target.id)
        end
        rows[#rows + 1] = A.Row("Save live snapshot", "Record current gear and bars", "Keep a frozen record of the live character. Five snapshots are retained; saving a sixth replaces the oldest.", A.SaveSnapshot)
        rows[#rows + 1] = A.Row("Return to live setup", "Refresh the current character", "Leave historical snapshots and inspect the current setup.", A.RefreshLive)
        for index, savedSnapshot in ipairs(A.saved.snapshots) do
            local snapshotIndex, saved = index, savedSnapshot
            rows[#rows + 1] = A.Row(saved.label, A.CaptureTimeText(saved), "View this historical setup against your active target build. The saved setup is never changed by editing a target.", function()
                A.viewIndex = snapshotIndex; A.ShowTab(1)
            end, "snapshot:" .. saved.snapshotNumber)
        end
        rows[#rows + 1] = A.Row("Diagnostics", "Capture status and warnings", A.ReportSection(snapshot, "diagnostics"))
    end
    return rows
end

function A.CurrentRows()
    local menu = A.menuStack[#A.menuStack]
    return menu and (type(menu.rows) == "function" and menu.rows() or menu.rows) or A.TabRows()
end

function A.OpenMenu(title, rows)
    A.menuStack[#A.menuStack + 1] = { title = title, rows = rows, parentSelection = A.selection, parentOffset = A.scrollOffset }
    A.selection, A.scrollOffset = 1, 0
    A.RebuildPages()
end

function A.Back()
    local menu = table.remove(A.menuStack)
    if menu then
        A.selection, A.scrollOffset = menu.parentSelection, menu.parentOffset
        A.RebuildPages()
    else
        SCENE_MANAGER:HideCurrentScene()
    end
end

function A.ShowTab(index)
    A.tabIndex = ((index - 1) % #A.tabs) + 1
    A.menuStack = {}
    A.selection, A.scrollOffset = 1, 0
    A.RebuildPages()
end

function A.RefreshLive()
    A.viewIndex = 0
    if A.Refresh("manual refresh") then A.Notify("Live setup refreshed.") end
    A.RebuildPages()
end

function A.ActivateRow()
    local row = A.rows and A.rows[A.selection]
    if row and row.action then row.action() end
end
