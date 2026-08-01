BattleStats = BattleStats or {}
BattleStats.BuildSheet = BattleStats.BuildSheet or {}

local BS = BattleStats
local Sheet = BattleStats.BuildSheet
local Util = BattleStats.Util

Sheet.name = "BattleStats_BuildSheet"

--==================================================
-- Lexicon (English) - compact v1
--==================================================
local BUFFS = {
    ["Major Berserk"]   = { kind = "dmg_done_mult", value = 0.10 },
    ["Minor Berserk"]   = { kind = "dmg_done_mult", value = 0.05 },
    ["Major Protection"] = { kind = "dmg_taken_mult", value = -0.10 },
    ["Minor Protection"] = { kind = "dmg_taken_mult", value = -0.05 },
    ["Major Force"]     = { kind = "crit_dmg_mult", value = 0.20 },
    ["Minor Force"]     = { kind = "crit_dmg_mult", value = 0.10 },
    ["Major Mending"]   = { kind = "healing_done_mult", value = 0.16 },
    ["Minor Mending"]   = { kind = "healing_done_mult", value = 0.08 },
    ["Major Vitality"]  = { kind = "healing_recv_mult", value = 0.12 },
    ["Minor Vitality"]  = { kind = "healing_recv_mult", value = 0.06 },

    ["Major Resolve"]   = { kind = "resist", value = 5948 },
    ["Minor Resolve"]   = { kind = "resist", value = 2974 },

    ["Major Prophecy"]  = { kind = "spell_crit", value = 2629 },
    ["Minor Prophecy"]  = { kind = "spell_crit", value = 1314 },
    ["Major Savagery"]  = { kind = "weapon_crit", value = 2629 },
    ["Minor Savagery"]  = { kind = "weapon_crit", value = 1314 },

    ["Major Courage"]   = { kind = "wsp_dmg", value = 430 },
    ["Minor Courage"]   = { kind = "wsp_dmg", value = 215 },

    -- We intentionally do not numerically model Expedition / Evasion / Fortitude / Endurance / Intellect here.
    -- They will still be listed as detected effects.
}

local DEBUFFS = {
    ["Major Breach"]       = { kind = "target_resist_down", value = 5948 },
    ["Minor Breach"]       = { kind = "target_resist_down", value = 2974 },
    ["Major Maim"]         = { kind = "target_dmg_done_mult", value = -0.10 },
    ["Minor Maim"]         = { kind = "target_dmg_done_mult", value = -0.05 },
    ["Major Vulnerability"] = { kind = "target_dmg_taken_mult", value = 0.10 },
    ["Minor Vulnerability"] = { kind = "target_dmg_taken_mult", value = 0.05 },
    ["Major Defile"]       = { kind = "target_heal_recv_mult", value = -0.12 },
    ["Minor Defile"]       = { kind = "target_heal_recv_mult", value = -0.06 },
    ["Major Brittle"]      = { kind = "target_crit_dmg_taken_mult", value = 0.20 },
    ["Minor Brittle"]      = { kind = "target_crit_dmg_taken_mult", value = 0.10 },
}

-- Status effects - listed only (no direct math in v1)
local STATUS = {
    ["Burning"] = true,
    ["Chilled"] = true,
    ["Concussed"] = true,
    ["Diseased"] = true,
    ["Poisoned"] = true,
    ["Sundered"] = true,
    ["Hemorrhaging"] = true,
    ["Overcharged"] = true,
}

--==================================================
-- Helpers
--==================================================
local function UptimeWeight(preset)
    if preset == "conservative" then return 0.50 end
    if preset == "aggressive" then return 0.85 end
    return 0.70 -- normal
end

local function IsInPvP()
    if type(_G.IsPlayerInAvAWorld) == "function" then
        if IsPlayerInAvAWorld() == true then return true end
    end
    -- Battleground fallback (API availability varies)
    if type(_G.IsActiveWorldBattleground) == "function" then
        if IsActiveWorldBattleground() == true then return true end
    end
    return false
end

local function SafeGet(fnName, ...)
    local fn = _G[fnName]
    if type(fn) ~= "function" then return nil end
    return fn(...)
end

local function AddDetected(map, key, source)
    if not map[key] then
        map[key] = { count = 0, sources = {} }
    end
    map[key].count = map[key].count + 1
    if source and source ~= "" then
        table.insert(map[key].sources, source)
    end
end

local function ScanText(text, detected, sourceLabel)
    if type(text) ~= "string" or text == "" then return end

    for k in pairs(BUFFS) do
        if string.find(text, k, 1, true) then
            AddDetected(detected.buffs, k, sourceLabel)
        end
    end
    for k in pairs(DEBUFFS) do
        if string.find(text, k, 1, true) then
            AddDetected(detected.debuffs, k, sourceLabel)
        end
    end
    for k in pairs(STATUS) do
        if string.find(text, k, 1, true) then
            AddDetected(detected.status, k, sourceLabel)
        end
    end
end

local function CollectSlottedSkills(detected)
    local getId = _G.GetSlotBoundId
    if type(getId) ~= "function" then
        return
    end

    local bars = {
        { name = "Front", cat = _G.HOTBAR_CATEGORY_PRIMARY },
        { name = "Back",  cat = _G.HOTBAR_CATEGORY_BACKUP },
    }

    for _, bar in ipairs(bars) do
        if bar.cat then
            for slot = 3, 7 do
                local id = getId(slot, bar.cat) or 0
                if id and id > 0 then
                    local n = SafeGet("GetAbilityName", id, "player") or SafeGet("GetAbilityName", id) or ""
                    local h = SafeGet("GetAbilityDescriptionHeader", id, "player") or SafeGet("GetAbilityDescriptionHeader", id) or ""
                    local d = SafeGet("GetAbilityDescription", id, nil, "player") or SafeGet("GetAbilityDescription", id) or ""

                    local label = string.format("%sBar S%d: %s", bar.name, slot, (n ~= "" and n or tostring(id)))
                    ScanText(h, detected, label)
                    ScanText(d, detected, label)
                end
            end
        end
    end
end

local function CollectEquippedSets(detected)
    if type(_G.GetItemLink) ~= "function" then return end
    if type(_G.GetItemLinkSetBonusInfo) ~= "function" then return end

    local EQUIP = _G.BAG_WORN
    if not EQUIP then return end

    -- Most equipment slots are 0..(count-1). We keep it conservative: try 0..20.
    for slotIndex = 0, 20 do
        local link = GetItemLink(EQUIP, slotIndex, _G.LINK_STYLE_DEFAULT) or ""
        if link ~= "" then
            -- Try to enumerate set bonus lines (up to 7 lines is typical)
            for idx = 1, 7 do
                local ok, _, text = pcall(function()
                    -- Some API variants return (isActive, numItems, bonusText)
                    return GetItemLinkSetBonusInfo(link, true, idx)
                end)
                if ok and type(text) == "string" and text ~= "" then
                    local label = string.format("SetBonus: %s", link)
                    ScanText(text, detected, label)
                end
            end

            -- Enchant / trait text is handled later; for v1 we only parse bonus text.
        end
    end
end

local function ApplyMode(detected, mode, preset)
    local weight = UptimeWeight(preset)

    local totals = {
        wsp_dmg = 0,
        spell_crit = 0,
        weapon_crit = 0,
        resist = 0,
        target_resist_down = 0,

        dmg_done_mult = 1.0,
        dmg_taken_mult = 1.0,
        crit_dmg_mult = 1.0,
        healing_done_mult = 1.0,
        healing_recv_mult = 1.0,
    }

    local function ApplyEffect(key, def)
        local w = 1.0
        if mode == "base" then
            -- Base: only treat Resolve / Brut/Sorc / Prophecy/Savagery as baseline if detected and PvP
            -- Otherwise base stays conservative.
            w = 0.0
        elseif mode == "likely" then
            w = weight
        else
            w = 1.0
        end

        -- If the effect appears to be while-slotted (source text), treat as always-on.
        local entry = detected.buffs[key] or detected.debuffs[key]
        local slotted = false
        if entry and entry.sources then
            for _, s in ipairs(entry.sources) do
                if type(s) == "string" and string.find(s, "Bar", 1, true) then
                    -- not enough to infer while-slotted
                end
            end
        end

        if mode == "base" then
            -- PvP baseline assumptions: only if the buff/debuff is detectable in your build sources.
            if Sheet._isPvP then
                if key == "Major Resolve" or key == "Minor Resolve" then w = 1.0 end
                if key == "Major Brutality" or key == "Major Sorcery" then w = 1.0 end
                if key == "Major Prophecy" or key == "Major Savagery" then w = 1.0 end
                if key == "Minor Prophecy" or key == "Minor Savagery" then w = 1.0 end
            end
        end

        -- Apply
        if def.kind == "wsp_dmg" then
            totals.wsp_dmg = totals.wsp_dmg + (def.value * w)
        elseif def.kind == "spell_crit" then
            totals.spell_crit = totals.spell_crit + (def.value * w)
        elseif def.kind == "weapon_crit" then
            totals.weapon_crit = totals.weapon_crit + (def.value * w)
        elseif def.kind == "resist" then
            totals.resist = totals.resist + (def.value * w)
        elseif def.kind == "target_resist_down" then
            totals.target_resist_down = totals.target_resist_down + (def.value * w)
        elseif def.kind == "dmg_done_mult" then
            totals.dmg_done_mult = totals.dmg_done_mult * (1.0 + (def.value * w))
        elseif def.kind == "dmg_taken_mult" then
            totals.dmg_taken_mult = totals.dmg_taken_mult * (1.0 + (def.value * w))
        elseif def.kind == "crit_dmg_mult" then
            totals.crit_dmg_mult = totals.crit_dmg_mult * (1.0 + (def.value * w))
        elseif def.kind == "healing_done_mult" then
            totals.healing_done_mult = totals.healing_done_mult * (1.0 + (def.value * w))
        elseif def.kind == "healing_recv_mult" then
            totals.healing_recv_mult = totals.healing_recv_mult * (1.0 + (def.value * w))
        end

        -- silence unused
        if slotted then end
    end

    for k, def in pairs(BUFFS) do
        if detected.buffs[k] then
            ApplyEffect(k, def)
        end
    end
    for k, def in pairs(DEBUFFS) do
        if detected.debuffs[k] then
            ApplyEffect(k, def)
        end
    end

    return totals
end

local function FormatPercent(mult)
    local pct = (mult - 1.0) * 100.0
    if pct >= 0 then
        return string.format("+%.1f%%", pct)
    end
    return string.format("%.1f%%", pct)
end

local function BuildText()
    if not BS.SV then return "" end

    Sheet._isPvP = IsInPvP()

    local view = tostring(BS.SV.buildSheetDefaultView or "likely")
    if view ~= "base" and view ~= "likely" and view ~= "perfect" then
        view = "likely"
    end

    local preset = tostring(BS.SV.buildSheetUptimePreset or "normal")

    local detected = { buffs = {}, debuffs = {}, status = {} }
    CollectSlottedSkills(detected)
    CollectEquippedSets(detected)

    local totals = ApplyMode(detected, view, preset)

    local weapon = Util.GetWeaponDamage() or 0
    local spell = Util.GetSpellDamage() or 0
    local physRes = Util.GetDerivedStatValue("STAT_PHYSICAL_RESIST") or 0
    local spellRes = Util.GetDerivedStatValue("STAT_SPELL_RESIST") or 0
    local wpen = Util.GetDerivedStatValue("STAT_PHYSICAL_PENETRATION") or 0
    local spen = Util.GetDerivedStatValue("STAT_SPELL_PENETRATION") or 0

    local effWeapon = weapon + totals.wsp_dmg
    local effSpell = spell + totals.wsp_dmg

    local effPhysRes = physRes + totals.resist
    local effSpellRes = spellRes + totals.resist

    local effWPen = wpen + totals.target_resist_down
    local effSPen = spen + totals.target_resist_down

    local sampleHit = tonumber(BS.SV.buildSheetSampleHit) or 1000
    local assumeBlock = (BS.SV.buildSheetAssumeBlocking == true)

    -- Approximation aligned with common player mental model: 33k ~= 50%.
    local armorPct = 0
    do
        local maxRes = math.max(tonumber(effPhysRes) or 0, tonumber(effSpellRes) or 0)
        armorPct = math.min(0.50, (maxRes / 66000))
    end

    local afterArmor = sampleHit * (1.0 - armorPct)
    local afterBlock = assumeBlock and (afterArmor * 0.50) or afterArmor
    local afterProt = afterBlock * totals.dmg_taken_mult

    local lines = {}
    table.insert(lines, "|cFFD700Build Stat Sheet|r (Compact)")
    table.insert(lines, string.format("Context: %s", Sheet._isPvP and "PvP" or "PvE"))
    table.insert(lines, string.format("View: %s   Likely preset: %s", string.upper(view), preset))
    table.insert(lines, "")

    table.insert(lines, "|cFFFFFFOffense|r")
    table.insert(lines, string.format("Weapon/Spell Dmg (modeled): %s / %s", Util.FormatValue(effWeapon), Util.FormatValue(effSpell)))
    table.insert(lines, string.format("Penetration (effective): W %s | S %s", Util.FormatValue(effWPen), Util.FormatValue(effSPen)))
    table.insert(lines, string.format("Damage Done Mult: %s", FormatPercent(totals.dmg_done_mult)))
    table.insert(lines, string.format("Crit Damage Mult: %s", FormatPercent(totals.crit_dmg_mult)))
    table.insert(lines, "")

    table.insert(lines, "|cFFFFFFDefense|r")
    table.insert(lines, string.format("Resist (modeled): PH %s | SP %s", Util.FormatValue(effPhysRes), Util.FormatValue(effSpellRes)))
    table.insert(lines, string.format("Damage Taken Mult: %s", FormatPercent(totals.dmg_taken_mult)))
    table.insert(lines, "")

    table.insert(lines, "|cFFFFFFSample Hit|r")
    table.insert(lines, string.format("Incoming %d → after armor (~%.0f%%) %d%s → after buffs %d",
        sampleHit,
        armorPct * 100,
        math.floor(afterBlock + 0.5),
        assumeBlock and " (blocking)" or "",
        math.floor(afterProt + 0.5)
    ))
    table.insert(lines, "")

    table.insert(lines, "|cFFFFFFHealing|r")
    table.insert(lines, string.format("Healing Done Mult: %s", FormatPercent(totals.healing_done_mult)))
    table.insert(lines, string.format("Healing Received/Shield Mult: %s", FormatPercent(totals.healing_recv_mult)))
    table.insert(lines, "")

    local function AppendDetected(title, map)
        local keys = {}
        for k in pairs(map) do table.insert(keys, k) end
        table.sort(keys)
        if #keys == 0 then return end
        table.insert(lines, "|cFFFFFF" .. title .. "|r")
        for _, k in ipairs(keys) do
            table.insert(lines, "• " .. k)
        end
        table.insert(lines, "")
    end

    AppendDetected("Detected Buffs", detected.buffs)
    AppendDetected("Detected Debuffs", detected.debuffs)
    AppendDetected("Detected Status Effects", detected.status)

    table.insert(lines, "|c888888Note: This sheet models effects from skill and set text. If a buff is already active, modeled gains may already be included in your in-game stat sheet.|r")

    return table.concat(lines, "\n")
end

--==================================================
-- UI
--==================================================
function Sheet.Init()
    if Sheet._initialized then return end
    Sheet._initialized = true

    if not WINDOW_MANAGER or not GuiRoot then return end

    local win = WINDOW_MANAGER:CreateTopLevelWindow("BattleStats_BuildSheet")
    win:SetHidden(true)
    win:SetMouseEnabled(false)
    win:SetMovable(false)
    win:SetClampedToScreen(true)
    win:SetDimensions(900, 650)
    win:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)

    local bg = WINDOW_MANAGER:CreateControl("$(parent)BG", win, CT_BACKDROP)
    bg:SetAnchorFill(win)
    bg:SetCenterColor(0, 0, 0, 0.70)
    bg:SetEdgeColor(0, 0, 0, 0.90)

    local label = WINDOW_MANAGER:CreateControl("$(parent)Label", win, CT_LABEL)
    label:SetAnchor(TOPLEFT, win, TOPLEFT, 20, 20)
    label:SetAnchor(BOTTOMRIGHT, win, BOTTOMRIGHT, -20, -20)
    label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    label:SetVerticalAlignment(TEXT_ALIGN_TOP)
    label:SetText("")
    label:SetFont("ZoFontGame|22|soft-shadow-thick")
    label:SetWrapMode(TEXT_WRAP_MODE_TRUNCATE)

    Sheet.window = win
    Sheet.label = label

    -- Slash command toggles
    SLASH_COMMANDS["/bsheet"] = function() Sheet.Toggle() end
    SLASH_COMMANDS["/buildsheet"] = function() Sheet.Toggle() end

    Sheet.Refresh()
end

function Sheet.Refresh()
    if not Sheet.label then return end
    if not BS.SV or BS.SV.buildSheetEnabled ~= true then
        Sheet.label:SetText("Build Stat Sheet is disabled in settings.")
        return
    end
    Sheet.label:SetText(BuildText())
end

function Sheet.Toggle()
    if not Sheet.window then return end
    if not BS.SV or BS.SV.buildSheetEnabled ~= true then
        Util.ChatMsg("BattleStats: Build Stat Sheet is disabled in settings.")
        return
    end
    local hidden = Sheet.window:IsHidden()
    if hidden then
        Sheet.Refresh()
    end
    Sheet.window:SetHidden(not hidden)
end
