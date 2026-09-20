local A = ESOBuildTracker
local function Value(v) if v == nil then return "Unavailable" end return tostring(v) end
local function HasText(v) return v ~= nil and v ~= "" end
local function Heading(text) return "|c89d5ef" .. text .. "|r" end

function A.ActiveBarName(snapshot)
    if snapshot.activeHotbarCategory ~= HOTBAR_CATEGORY_PRIMARY and snapshot.activeHotbarCategory ~= HOTBAR_CATEGORY_BACKUP then
        return "Special / temporary bar"
    end
    if snapshot.activeWeaponPair == ACTIVE_WEAPON_PAIR_MAIN then return "Front bar" end
    if snapshot.activeWeaponPair == ACTIVE_WEAPON_PAIR_BACKUP then return "Back bar" end
    return "Unavailable"
end

function A.CaptureTimeText(snapshot)
    return (snapshot.capturedDateText or "Unknown date") .. " " .. (snapshot.capturedTimeText or "Unknown time")
end

function A.BuildReport(snapshot)
    if not snapshot then return { { key = "waiting", title = "Waiting for character", text = "Load your character, then refresh the tracker." } } end
    local sections = {}
    local function Add(key, title, lines)
        sections[#sections + 1] = { key = key, title = title, text = table.concat(lines, "\n") }
    end
    local equipped, empty = 0, 0
    for _, item in ipairs(snapshot.equipment) do
        if item.status == "equipped" then equipped = equipped + 1 elseif item.status == "empty" then empty = empty + 1 end
    end
    Add("overview", "Current setup overview", {
        Heading(snapshot.characterName),
        snapshot.raceName .. " / " .. snapshot.className .. " / Level " .. Value(snapshot.level) .. " / CP " .. Value(snapshot.championPoints),
        "Server: " .. Value(snapshot.world),
        "Captured: " .. A.CaptureTimeText(snapshot),
        "Active at capture: " .. A.ActiveBarName(snapshot),
        "Weapon swapping locked: " .. (snapshot.weaponSwapLocked == nil and "Unavailable" or snapshot.weaponSwapLocked and "Yes" or "No"),
        "", Heading("Captured equipment"),
        tostring(equipped) .. " occupied slots; " .. tostring(empty) .. " empty slots.",
        "Both normal skill bars are recorded, including when the back bar is locked.",
        "", Heading("Reading this report"),
        "Use the shoulder buttons to move through the report.",
        "Save records the live character, even while viewing an older snapshot.",
        "View cycles through Live and your five most recent saved snapshots.",
        "Snapshots are separated by character, account, and server.",
        "", (#snapshot.warnings == 0 and "No capture API warnings." or tostring(#snapshot.warnings) .. " capture warning(s). Check the Diagnostics page."),
    })
    for barIndex, bar in ipairs(snapshot.bars) do
        local lines = { "Normal weapon bar assignments at capture.", "" }
        for _, skill in ipairs(bar.slots) do
            local prefix = skill.ultimate and "Ultimate" or tostring(skill.position)
            if skill.status == "empty" then
                lines[#lines + 1] = prefix .. ". Empty"
            elseif skill.status == "unavailable" then
                lines[#lines + 1] = prefix .. ". Unavailable - check Diagnostics"
            else
                local rank = skill.rank and (" / Rank " .. tostring(skill.rank)) or ""
                lines[#lines + 1] = Heading(prefix .. ". " .. skill.name) .. rank
                if skill.morph == 0 then lines[#lines + 1] = "    Unmorphed skill" end
                if skill.scripts then
                    local scriptLabels = { "Focus", "Signature", "Affix" }
                    for i = 1, 3 do
                        local script = skill.scripts[i]
                        lines[#lines + 1] = "    " .. scriptLabels[i] .. ": " .. (script and script.name or "Unassigned / unavailable")
                    end
                end
                if skill.specialAction then lines[#lines + 1] = "    Special action; preserved by action type and ID." end
            end
            lines[#lines + 1] = ""
        end
        if barIndex == 2 and snapshot.weaponSwapLocked then lines[#lines + 1] = "Weapon swapping was locked at capture; recorded back-bar assignments may not be usable." end
        Add("bar" .. barIndex, bar.label, lines)
    end
    local gearLines = {}
    for _, item in ipairs(snapshot.equipment) do
        gearLines[#gearLines + 1] = Heading(item.slotLabel)
        if item.status == "equipped" then
            gearLines[#gearLines + 1] = item.name .. " / " .. item.qualityName .. " / " .. item.traitName
        elseif item.status == "empty" then
            gearLines[#gearLines + 1] = "Empty"
        else
            gearLines[#gearLines + 1] = "Unavailable - check Diagnostics"
        end
        gearLines[#gearLines + 1] = ""
    end
    Add("gear", "Equipped item checklist", gearLines)
    for _, item in ipairs(snapshot.equipment) do
        if item.status == "equipped" then
            local level = (item.requiredCP and item.requiredCP > 0) and ("CP " .. tostring(item.requiredCP)) or ("Level " .. Value(item.requiredLevel))
            local lines = {
                Heading(item.name),
                "Quality: " .. item.qualityName .. " / Requirement: " .. level,
                "Set: " .. (item.set and item.set.name or item.noSet and "None" or "Unavailable"),
            }
            if item.armorTypeName then lines[#lines + 1] = "Armor weight: " .. item.armorTypeName end
            if item.weaponTypeName then lines[#lines + 1] = "Weapon type: " .. item.weaponTypeName end
            if item.armorRating and item.armorRating > 0 then
                lines[#lines + 1] = "Armor rating (before condition loss): " .. tostring(item.armorRating)
                lines[#lines + 1] = "Item condition: " .. Value(item.conditionPercent) .. "%"
            end
            if item.weaponPower and item.weaponPower > 0 then lines[#lines + 1] = "Item weapon damage: " .. tostring(item.weaponPower) end
            if item.stack and item.stack > 1 then lines[#lines + 1] = "Stack: " .. tostring(item.stack) end
            lines[#lines + 1] = ""
            lines[#lines + 1] = Heading("Trait: " .. item.traitName)
            if HasText(item.traitDescription) then lines[#lines + 1] = item.traitDescription end
            lines[#lines + 1] = ""
            lines[#lines + 1] = Heading("Enchantment")
            if not item.enchantReadComplete then
                lines[#lines + 1] = "Unavailable - check Diagnostics"
            elseif not HasText(item.enchantName) and not HasText(item.enchantDescription) then
                lines[#lines + 1] = "None"
            else
                if HasText(item.enchantName) then lines[#lines + 1] = item.enchantName end
                if HasText(item.enchantDescription) then lines[#lines + 1] = item.enchantDescription end
            end
            if item.set then
                lines[#lines + 1] = ""
                lines[#lines + 1] = Heading("Set bonus descriptions")
                lines[#lines + 1] = "Bonuses apply only when their piece and effect conditions are met."
                for _, bonus in ipairs(item.set.bonuses) do
                    lines[#lines + 1] = ""
                    lines[#lines + 1] = "(" .. Value(bonus.required) .. " pieces" .. (bonus.perfectedOnly and ", perfected" or "") .. ") " .. (bonus.description or "Unavailable")
                end
            end
            Add("item:" .. item.key, item.slotLabel, lines)
        end
    end
    local stats = {
        "Captured with: " .. A.ActiveBarName(snapshot),
        "Captured: " .. A.CaptureTimeText(snapshot),
        "Combat at capture: " .. (snapshot.inCombat == nil and "Unavailable" or snapshot.inCombat and "Yes" or "No"),
        "", "These totals reflect active buffs, passives, CP, and the active bar at capture. Swap bars and refresh to record the other bar's totals.", "",
    }
    for _, stat in ipairs(snapshot.stats) do stats[#stats + 1] = stat.label .. ": " .. Value(stat.value) end
    Add("stats", "Observed character totals", stats)
    local diagnostics = {
        "Prototype " .. A.version .. " / Capture schema " .. A.schemaVersion,
        "Runtime API: " .. Value(snapshot.apiVersion) .. " / Reference API: " .. A.referenceAPIVersion,
        "Captured: " .. A.CaptureTimeText(snapshot),
        "Required slots readable: " .. (snapshot.coreDataComplete and "Yes" or "No"),
        "", "Capture worked in the user's Xbox session on 0.1.0. The new 0.2.0 interface and target editor need in-game verification.",
        "Empty slots are distinct from failed reads. Snapshots are local ESO saved data; document import and PC synchronization are later stages.",
        "", Heading("Capture warnings"),
    }
    if #snapshot.warnings == 0 then diagnostics[#diagnostics + 1] = "None" end
    for _, warning in ipairs(snapshot.warnings) do diagnostics[#diagnostics + 1] = warning end
    if A.captureError then diagnostics[#diagnostics + 1] = "Last failed capture: " .. A.captureError end
    Add("diagnostics", "Diagnostics", diagnostics)
    return sections
end
