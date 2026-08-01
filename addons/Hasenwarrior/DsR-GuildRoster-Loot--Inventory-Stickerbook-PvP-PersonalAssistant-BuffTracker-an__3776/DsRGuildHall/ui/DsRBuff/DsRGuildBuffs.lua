DsRGuildBuffs = DsRGuildBuffs or {}
local DsRBuff = DsRGuildBuffs

DsRBuff.hiddenShortly = false

local GroupBuffCounts = {}   -- key = abilityId, value = count
local LastStacks = {}

local function IsStackableAbility(abilityId)
    local data = DsRglobals.StackableSets[abilityId]
    return data ~= nil and data.stack == true
end

local function GetMaxStack(abilityId)
    local data = DsRglobals.StackableSets[abilityId]
    if data then
        return data.maxStack or 0
    end
    return 0
end

local function GetBuffColor(key)
    local c = DsRGuildLoot and DsRGuildLoot.sV and DsRGuildLoot.sV.DsRBuffMultiBuffColors
    if not c then
        return {1, 1, 1, 1} -- Fallback
    end

    local col = c[key]
    if not col then
        return c.Default or {1, 1, 1, 1}
    end

    return { col[1], col[2], col[3], col[4] }
end

------------------------------------------------------------
-- DEFAULT SAVEVARS ERSTELLEN
------------------------------------------------------------
local function EnsureRaidBuffCharDefaults()
    local lang       = GetCVar("language.2")
    local generalKey = (lang == "de") and "Allgemein" or "General"

    for _, CharName in pairs(DsRGuildLoot.sV.characters) do
        DsRGuildBuffsCharSettings["Default"][GetDisplayName()][CharName]                     = DsRGuildBuffsCharSettings["Default"][GetDisplayName()][CharName] or {}
        DsRGuildBuffsCharSettings["Default"][GetDisplayName()][CharName]["PvP"]              = DsRGuildBuffsCharSettings["Default"][GetDisplayName()][CharName]["PvP"] or {}
        DsRGuildBuffsCharSettings["Default"][GetDisplayName()][CharName]["PvP"]["Tank"]      = DsRGuildBuffsCharSettings["Default"][GetDisplayName()][CharName]["PvP"]["Tank"] or ""
        DsRGuildBuffsCharSettings["Default"][GetDisplayName()][CharName]["PvP"]["Heal"]      = DsRGuildBuffsCharSettings["Default"][GetDisplayName()][CharName]["PvP"]["Heal"] or ""
        DsRGuildBuffsCharSettings["Default"][GetDisplayName()][CharName]["PvP"]["DPS"]       = DsRGuildBuffsCharSettings["Default"][GetDisplayName()][CharName]["PvP"]["DPS"] or ""
        DsRGuildBuffsCharSettings["Default"][GetDisplayName()][CharName][generalKey]         = DsRGuildBuffsCharSettings["Default"][GetDisplayName()][CharName][generalKey] or {}
        DsRGuildBuffsCharSettings["Default"][GetDisplayName()][CharName][generalKey]["Tank"] = DsRGuildBuffsCharSettings["Default"][GetDisplayName()][CharName][generalKey]["Tank"] or ""
        DsRGuildBuffsCharSettings["Default"][GetDisplayName()][CharName][generalKey]["Heal"] = DsRGuildBuffsCharSettings["Default"][GetDisplayName()][CharName][generalKey]["Heal"] or ""
        DsRGuildBuffsCharSettings["Default"][GetDisplayName()][CharName][generalKey]["DPS"]  = DsRGuildBuffsCharSettings["Default"][GetDisplayName()][CharName][generalKey]["DPS"] or ""

        for _, raid in ipairs(DsRglobals.Raids) do
            local raidName = (lang == "de") and raid.de or raid.en

            if raidName and raidName ~= "" then
                DsRGuildBuffsCharSettings["Default"][GetDisplayName()][CharName][raidName]          = DsRGuildBuffsCharSettings["Default"][GetDisplayName()][CharName][raidName] or {}
                DsRGuildBuffsCharSettings["Default"][GetDisplayName()][CharName][raidName]["Tank"]  = DsRGuildBuffsCharSettings["Default"][GetDisplayName()][CharName][raidName]["Tank"]  or ""
                DsRGuildBuffsCharSettings["Default"][GetDisplayName()][CharName][raidName]["Heal"]  = DsRGuildBuffsCharSettings["Default"][GetDisplayName()][CharName][raidName]["Heal"]  or ""
                DsRGuildBuffsCharSettings["Default"][GetDisplayName()][CharName][raidName]["DPS"]   = DsRGuildBuffsCharSettings["Default"][GetDisplayName()][CharName][raidName]["DPS"]  or ""
            end
        end
    end
end

------------------------------------------------------------
-- WHITELIST AUS SAVEVARS
------------------------------------------------------------
local Whitelist = {}

function DsRGuildBuffs:GetMySelectedRole()
	local role = GetSelectedLFGRole()
	if role == 1 then
		return "DPS"
	elseif role == 4 then
		return "Heal"
	elseif role == 2 then
		return "Tank"
    else
        return ""
	end
end

local function BuildWhitelist()
    Whitelist = {}
    WhitelistOrder = {}

    -- 1. Profil bestimmen (PvP / Raid / Allgemein)
    local profile = DsRGuildBuffs.GetCurrentBuffProfile()
    if not profile then return end

    -- 2. Rolle bestimmen (Tank / Heal / DPS)
    local role = DsRGuildBuffs:GetMySelectedRole()
    if role == "" then return end
    
    -- 3. SavedVars holen
    local buffData = DsRGuildBuffsCharSettings["Default"][GetDisplayName()][GetUnitName("player")]

    if not buffData then return end

    -- 4. Profil-Daten holen
    local raw = buffData[profile][role]
    if not raw or raw == "" then return end

    -- 5. IDs extrahieren und in Whitelist speichern
    for id in string.gmatch(raw, "%d+") do
        local num = tonumber(id)
        Whitelist[num] = true
        table.insert(WhitelistOrder, num)
    end
end

local function GetWhitelistInSavedOrder()
    return WhitelistOrder
end

------------------------------------------------------------
-- MULTI BUFF TIMER ENGINE
------------------------------------------------------------
local ActiveTimers = {}   -- key = abilityId, value = timer object

------------------------------------------------------------
-- UI: HAUPTFENSTER
------------------------------------------------------------
local BuffWindow
local BuffRows = {}

local function CreateBuffWindow()
    local win = WINDOW_MANAGER:CreateTopLevelWindow("DsRBuffWindow")
    win:SetDimensions(250, 400)
    win:SetClampedToScreen(true)
    win:SetMovable(true)
    win:SetMouseEnabled(true)

    local x = DsRGuildLoot.sV.DsRBuffuiX or 300
    local y = DsRGuildLoot.sV.DsRBuffuiY or 300

    win:ClearAnchors()
    win:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)

    win:SetHandler("OnMoveStop", function(self)
        DsRGuildLoot.sV.DsRBuffuiX = self:GetLeft()
        DsRGuildLoot.sV.DsRBuffuiY = self:GetTop()
    end)

    return win
end

local function UpdateGroupBuffCounts()
    GroupBuffCounts = {}

    local groupSize = GetGroupSize()
    if groupSize == 0 then return end

    for i = 1, groupSize do
        local unitTag = "group" .. i

        if DoesUnitExist(unitTag) then
            for effectSlot = 1, 200 do
                local effectName, _, _, _, _, _, _, _, _, _, abilityId = GetUnitBuffInfo(unitTag, effectSlot)
                if not effectName then break end

                if Whitelist[abilityId] then
                    GroupBuffCounts[abilityId] = (GroupBuffCounts[abilityId] or 0) + 1
                end
            end
        end
    end
end

------------------------------------------------------------
-- UI: BUFF-ZEILE
------------------------------------------------------------
local function CalculateRowWidth(row)
    local minX = math.huge
    local maxX = -math.huge

    local function scan(control)
        if control then
            local left = control:GetLeft()
            local right = control:GetRight()
            if left and right then
                if left < minX then minX = left end
                if right > maxX then maxX = right end
            end
        end
    end

    scan(row.icon)
    scan(row.countLabel)
    scan(row.FlauschIcon)
    scan(row.nameLabel)
    scan(row.bar)
    scan(row.timerLabel)

    if minX == math.huge or maxX == -math.huge then
        return row:GetWidth()
    end

    return maxX - minX
end

local function ReanchorRows()
    local iconSize      = DsRGuildLoot.sV.DsRBuffDDSsize or 32
    local spacing       = 2
    local maxPerColumn  = DsRGuildLoot.sV.DsRBuff_CurrentRow 

    local columnWidth = 0
    for _, abilityId in ipairs(GetWhitelistInSavedOrder()) do
        local row = BuffRows[abilityId]
        if row and row.currentWidth and row.currentWidth > columnWidth then
            columnWidth = row.currentWidth
        end
    end

    local index = 0

    for _, abilityId in ipairs(GetWhitelistInSavedOrder()) do
        local row = BuffRows[abilityId]
        if row then
            local col = math.floor(index / maxPerColumn)
            local rowInCol = index % maxPerColumn

            row:ClearAnchors()
            row:SetAnchor(
                TOPLEFT,
                BuffWindow,
                TOPLEFT,
                col * columnWidth,                     -- X‑Offset = Spalte
                rowInCol * (iconSize + spacing)        -- Y‑Offset = Zeile
            )

            index = index + 1
        end
    end
end

local function CreateBuffRow(parent, abilityId)
    local row = WINDOW_MANAGER:CreateControl(nil, parent, CT_CONTROL)
    local iconSize = DsRGuildLoot.sV.DsRBuffDDSsize or 32
    row:SetDimensions(250, iconSize)

    ----------------------------------------------------
    -- SETTINGS LADEN
    ----------------------------------------------------
    local iconSize = DsRGuildLoot.sV.DsRBuffDDSsize or 32
    local textSize = DsRGuildLoot.sV.DsRBuffTXTsize or 18

    local nameCol  = DsRGuildLoot.sV.DsRBuffTXTcol or {1, 1, 1, 1}
    local timerCol = DsRGuildLoot.sV.DsRBuffTimercol or {1, 1, 1, 1}
    local barcol   = DsRGuildLoot.sV.DsRBuffBarColor or {0, 1, 0, 0.4}

    ----------------------------------------------------
    -- COUNT-LABEL (links vom Icon)
    ----------------------------------------------------
    row.countLabel = WINDOW_MANAGER:CreateControl(nil, row, CT_LABEL)
    row.countLabel:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    row.countLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    row.countLabel:SetText("")   -- wird später gesetzt

    ----------------------------------------------------
    -- FLAUSCH-ICON NUR FÜR @Prof_Flausch
    ----------------------------------------------------
    local countSize = DsRGuildLoot.sV.DsRBuffCountsize or 16
    local dynamicOffset = (countSize * 0.5)

    row.FlauschIcon = WINDOW_MANAGER:CreateControl(nil, row, CT_TEXTURE)

    if iconSize >= 32 then
        row.FlauschIcon:SetDimensions(32, 32)
    else
        row.FlauschIcon:SetDimensions(iconSize, iconSize)
    end
    row.FlauschIcon:ClearAnchors()
    row.FlauschIcon:SetAnchor(RIGHT, row.countLabel, LEFT, dynamicOffset, 0)
    row.FlauschIcon:SetTexture("/DsRGuildHall/misc/prof_flausch.dds")
    row.FlauschIcon:SetHidden(true)
    
    ----------------------------------------------------
    -- ICON
    ----------------------------------------------------
    row.icon = WINDOW_MANAGER:CreateControl(nil, row, CT_TEXTURE)
    row.icon:SetDimensions(iconSize, iconSize)
    row.icon:SetAnchor(LEFT, row, LEFT, 0, 0)

    if not DsRGuildLoot.sV.DsRBuffTxTonoff then
        ----------------------------------------------------
        -- PROGRESSBAR ALS HINTERGRUND
        ----------------------------------------------------
        row.bar = WINDOW_MANAGER:CreateControl(nil, row, CT_STATUSBAR)
        row.bar:SetAnchor(LEFT, row.icon, RIGHT, 6, 0)
        row.bar:SetDimensions(210, iconSize)
        row.bar:SetMinMax(0, 1)
        row.bar:SetColor(unpack(barcol))
        if row.bar.SetBarAlignment then
            row.bar:SetBarAlignment(STATUS_BAR_ALIGN_REVERSE)
        end

        ----------------------------------------------------
        -- NAME (über dem Balken)
        ----------------------------------------------------
        row.nameLabel = WINDOW_MANAGER:CreateControl(nil, row, CT_LABEL)
        row.nameLabel:SetAnchor(LEFT, row.icon, RIGHT, 10, 0)
        row.nameLabel:SetFont(string.format("$(BOLD_FONT)|%d|soft-shadow-thin", iconSize/4))
        row.nameLabel:SetColor(unpack(nameCol))
        row.nameLabel:SetDimensions(200, iconSize)
        row.nameLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        row.nameLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    end
    ----------------------------------------------------
    -- TIMER IM ICON
    ----------------------------------------------------
    row.timerLabel = WINDOW_MANAGER:CreateControl(nil, row, CT_LABEL)
    row.timerLabel:SetAnchor(CENTER, row.icon, CENTER, 0, 0)
    row.timerLabel:SetFont(string.format("$(BOLD_FONT)|%d|soft-shadow-thin", iconSize/1.5))
    row.timerLabel:SetColor(unpack(timerCol))
    row.timerLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    row.timerLabel:SetVerticalAlignment(TEXT_ALIGN_BOTTOM)
    row.timerLabel:SetDimensions(iconSize, iconSize)

    ----------------------------------------------------
    -- STACKABLE ICON
    ----------------------------------------------------
    if IsStackableAbility(abilityId) then
        row.stackOverlay = WINDOW_MANAGER:CreateControl(nil, row.icon, CT_TEXTURE)
        row.stackOverlay:SetTexture("/esoui/art/buttons/pointsplus_up.dds") -- Dreieck
        row.stackOverlay:SetAnchor(TOPLEFT, row.icon, TOPLEFT, -6, -3)
        row.stackOverlay:SetColor(1, 0.85, 0.1, 1) -- Gold

        row.stackOverlay:SetDrawLayer(DL_OVERLAY)
        row.stackOverlay:SetDrawTier(DT_HIGH)
        row.stackOverlay:SetDrawLevel(9999)

        -- Größe proportional zum Icon
        local iconWidth, iconHeight = row.icon:GetDimensions()
        local size = math.min(iconWidth, iconHeight) * 0.45
        row.stackOverlay:SetDimensions(size, size)
    end

    ----------------------------------------------------
    -- ABILITY-DATEN DIREKT LADEN
    ----------------------------------------------------
    local name = GetAbilityName(abilityId)
    local icon = GetAbilityIcon(abilityId)

    if not DsRGuildLoot.sV.DsRBuffTxTonoff then
        row.nameLabel:SetText(name ~= "" and name:gsub("%^.+", "") or ("ID " .. abilityId))
    end
    row.icon:SetTexture(icon ~= "" and icon or "/esoui/art/icons/icon_missing.dds")

    -- Dynamische Breite speichern
    row.currentWidth = CalculateRowWidth(row)

    return row
end


local function EnsureBuffRow(abilityId)
    if BuffRows[abilityId] then return BuffRows[abilityId] end
    if not BuffWindow then
        BuffWindow = CreateBuffWindow()
    end

    local row = CreateBuffRow(BuffWindow, abilityId)

    local count = 0
    for _ in pairs(BuffRows) do count = count + 1 end
    local iconSize = DsRGuildLoot.sV.DsRBuffDDSsize or 32
    local spacing = 2  -- kleiner Abstand zwischen Zeilen
    row:SetAnchor(TOPLEFT, BuffWindow, TOPLEFT, 0, count * (iconSize + spacing))

    BuffRows[abilityId] = row
    return row
end

local function CreateAllWhitelistRows()
    if not BuffWindow then
        BuffWindow = CreateBuffWindow()
    end

    local index = 0
    for _, abilityId in ipairs(GetWhitelistInSavedOrder()) do
        local row = EnsureBuffRow(abilityId)
        row:SetHidden(false)
        if not DsRGuildLoot.sV.DsRBuffTxTonoff then
            row.bar:SetValue(0)
        end
        row.timerLabel:SetText("")
        index = index + 1
    end
end

------------------------------------------------------------
-- Timer-Objekt erzeugen
------------------------------------------------------------
local function CreateTimer(abilityId, beginTime, endTime, effectName, iconName, effectType, statusEffectType, abilityType, sourceType, stackCount)
    local totalDuration = endTime - beginTime

    local function ClassifyBuff()
        if tostring(IsAbilityUltimate(abilityId)) == "true" then
            return "Ulti"
        elseif abilityType > 0 then
            local TypeName = DsRglobals.abilityTypes[abilityType].listname
            return string.gsub(TypeName, "%s+", "")
        elseif effectType == 1 and sourceType == 1 then
            return "SelfBuff"
        elseif effectType == 1 and sourceType == 3 then
            return "GroupBuff"
        elseif effectType == 1 then
            return "OtherBuff"
        else
            return "Default"
        end
    end

    local multi = DsRGuildLoot and DsRGuildLoot.sV and DsRGuildLoot.sV.DsRBuffMultiColor
    local buffClass

    if multi then
        buffClass = ClassifyBuff()
    else
        buffClass = "OneColor"
    end
    
    return {
        abilityId        = abilityId,
        endTime          = endTime,
        startTime        = beginTime,
        totalDuration    = totalDuration > 0 and totalDuration or 0.1,
        mode             = "slow",  -- slow = 1s, fast = 0.1s
        lastSecond       = nil,
        name             = effectName:gsub("%^.+", ""),
        icon             = iconName,
        effectType       = effectType,
        statusEffectType = statusEffectType,
        abilityType      = abilityType,
        sourceType       = sourceType,
        buffClass        = buffClass,
        stackCount       = stackCount or 1,
    }
end

------------------------------------------------------------
-- Globaler Update-Loop für ALLE Timer
------------------------------------------------------------
local function GetGroupUnitByAccName(accName)
    for i = 1, GetGroupSize() do
        local unitTag = "group" .. i
        if GetUnitDisplayName(unitTag) == accName then
            return unitTag
        end
    end
    return nil
end

local function DoesUnitHaveBuff(unitTag, abilityId)
    for slot = 1, 200 do
        local _, _, _, _, _, _, _, _, _, _, id = GetUnitBuffInfo(unitTag, slot)
        if not id then break end
        if id == abilityId then
            return true
        end
    end
    return false
end

local StackGradientColors = {
    {1, 0, 0},      -- Rot
    {1, 0.5, 0},    -- Orange
    {1, 1, 0},      -- Gelb
    {0.5, 1, 0},    -- Hellgrün
    {0, 1, 0},      -- Grün
}

local function MultiGradient(progress, colors)
    -- colors = { {r,g,b}, {r,g,b}, {r,g,b}, ... }

    local n = #colors
    if n == 1 then
        return unpack(colors[1])
    end

    -- Bereich bestimmen
    local segment = 1 / (n - 1)
    local index = math.floor(progress / segment) + 1

    if index >= n then
        return unpack(colors[n])
    end

    local t = (progress - (index - 1) * segment) / segment

    local c1 = colors[index]
    local c2 = colors[index + 1]

    local r = c1[1] + (c2[1] - c1[1]) * t
    local g = c1[2] + (c2[2] - c1[2]) * t
    local b = c1[3] + (c2[3] - c1[3]) * t

    return r, g, b
end


local function StartMultiTimerEngine()
    EVENT_MANAGER:RegisterForUpdate("DsRGuildBuffsMultiTimer", 100, function()
        local now = GetFrameTimeSeconds()

        ReanchorRows()

        local lastGroupScan = 0

        if now - lastGroupScan > 0.5 then
            UpdateGroupBuffCounts()
            lastGroupScan = now
        end

        ------------------------------------------------------------
        -- 1) ALLE WHITELIST-BUFFS ANZEIGEN (auch inaktiv)
        ------------------------------------------------------------
        for abilityId, _ in pairs(Whitelist) do
            local row = EnsureBuffRow(abilityId)

            ------------------------------------------------------------
            -- DYNAMISCHE UI-EINSTELLUNGEN
            ------------------------------------------------------------
            local iconSize  = DsRGuildLoot.sV.DsRBuffDDSsize or 32
            local textSize  = DsRGuildLoot.sV.DsRBuffTXTsize or 18
            local nameCol   = DsRGuildLoot.sV.DsRBuffTXTcol or {1, 1, 1, 1}
            local timerCol  = DsRGuildLoot.sV.DsRBuffTimercol or {1, 1, 1, 1}
            local countSize = DsRGuildLoot.sV.DsRBuffCountsize or 16
            local countCol  = DsRGuildLoot.sV.DsRBuffCountcol  or {1, 1, 1, 1}

            local totalWidth = 300
            local spacingIconToBar = 6

            local barWidth = totalWidth - iconSize - spacingIconToBar
            if barWidth < 20 then barWidth = 20 end

            local nameWidth = barWidth - 4
            if nameWidth < 10 then nameWidth = 10 end

            row:SetDimensions(totalWidth, iconSize)

            row.icon:SetDimensions(iconSize, iconSize)

            if not DsRGuildLoot.sV.DsRBuffTxTonoff or nil then
                row.bar:ClearAnchors()
                row.bar:SetAnchor(LEFT, row.icon, RIGHT, spacingIconToBar, 0)
                row.bar:SetDimensions(barWidth, iconSize)

                row.nameLabel:ClearAnchors()
                row.nameLabel:SetAnchor(LEFT, row.bar, LEFT, 2, 0)
                row.nameLabel:SetDimensions(nameWidth, iconSize)
                if IsStackableAbility(abilityId) then
                    row.nameLabel:SetColor(0.486, 0.745, 0.98, 1)
                    row.nameLabel:SetFont(string.format("$(BOLD_FONT)|%d|soft-shadow-thin", textSize))
                else
                    row.nameLabel:SetColor(unpack(nameCol))
                    row.nameLabel:SetFont(string.format("$(MEDIUM_FONT)|%d|soft-shadow-thin", textSize))
                end
            end

            row.timerLabel:ClearAnchors()
            row.timerLabel:SetAnchor(CENTER, row.icon, CENTER, 0, 0)
            row.timerLabel:SetFont(string.format("$(BOLD_FONT)|%d|soft-shadow-thin", iconSize/1.5))
            row.timerLabel:SetColor(unpack(timerCol))
            row.timerLabel:SetDimensions(iconSize, iconSize)

            row.countLabel:ClearAnchors()
            row.countLabel:SetAnchor(RIGHT, row.icon, LEFT, -4, 0)
            row.countLabel:SetFont(string.format("$(BOLD_FONT)|%d|soft-shadow-thin", countSize))
            local twoDigitWidth = row.countLabel:GetStringWidth("88")
            local countLabelWidth = twoDigitWidth + 4
            row.countLabel:SetDimensions(countLabelWidth, iconSize)
            row.countLabel:SetColor(unpack(countCol))

            row:SetHidden(false)

            -- Standardzustand für inaktive Buffs
            if not ActiveTimers[abilityId] then
                if not DsRGuildLoot.sV.DsRBuffTxTonoff then
                    row.bar:SetValue(0)
                end
                if IsStackableAbility(abilityId) then
                    row.timerLabel:SetText("0")
                else
                    row.timerLabel:SetText("")
                end
            end

            local count = GroupBuffCounts[abilityId] or 0
            row.countLabel:SetText(count > 0 and tostring(count) or "")

            -- FlauschIcon nur für @Prof_Flausch
            local hasPlayerBuff = false
            local countSize     = DsRGuildLoot.sV.DsRBuffCountsize or 16
            local dynamicOffset = (countSize * 0.5)

            row.FlauschIcon:ClearAnchors()
            row.FlauschIcon:SetAnchor(RIGHT, row.countLabel, LEFT, dynamicOffset, 0)
            if iconSize >= 32 then
                row.FlauschIcon:SetDimensions(32, 32)
            else
                row.FlauschIcon:SetDimensions(iconSize, iconSize)
            end

            local flauschUnit = GetGroupUnitByAccName("@Prof_Flausch")
            local hasPlayerBuff = false

            if flauschUnit then
                hasPlayerBuff = DoesUnitHaveBuff(flauschUnit, abilityId)
            end

            row.FlauschIcon:SetHidden(not hasPlayerBuff)

            row.currentWidth = CalculateRowWidth(row)
        end

        ------------------------------------------------------------
        -- 2) AKTIVE TIMER AKTUALISIEREN
        ------------------------------------------------------------
        for abilityId, timer in pairs(ActiveTimers) do
            local remaining = timer.endTime - now
            local row = EnsureBuffRow(abilityId)

            ------------------------------------------------------------
            -- DYNAMISCHE UI-EINSTELLUNGEN
            ------------------------------------------------------------
            local iconSize  = DsRGuildLoot.sV.DsRBuffDDSsize or 32
            local textSize  = DsRGuildLoot.sV.DsRBuffTXTsize or 18
            local nameCol   = DsRGuildLoot.sV.DsRBuffTXTcol or {1, 1, 1, 1}
            local timerCol  = DsRGuildLoot.sV.DsRBuffTimercol or {1, 1, 1, 1}
            local countSize = DsRGuildLoot.sV.DsRBuffCountsize or 16
            local countCol  = DsRGuildLoot.sV.DsRBuffCountcol  or {1, 1, 1, 1}
                    
            local totalWidth = 300
            local spacingIconToBar = 6
                    
            local barWidth = totalWidth - iconSize - spacingIconToBar
            if barWidth < 20 then barWidth = 20 end
                    
            local nameWidth = barWidth - 4
            if nameWidth < 10 then nameWidth = 10 end
                    
            row:SetDimensions(totalWidth, iconSize)
                    
            row.icon:SetDimensions(iconSize, iconSize)
            if not DsRGuildLoot.sV.DsRBuffTxTonoff then                    
                row.bar:ClearAnchors()
                row.bar:SetAnchor(LEFT, row.icon, RIGHT, spacingIconToBar, 0)
                row.bar:SetDimensions(barWidth, iconSize)
                    
                row.nameLabel:ClearAnchors()
                row.nameLabel:SetAnchor(LEFT, row.bar, LEFT, 2, 0)
                row.nameLabel:SetDimensions(nameWidth, iconSize)
                row.nameLabel:SetFont(string.format("$(MEDIUM_FONT)|%d|soft-shadow-thin", textSize))
                if IsStackableAbility(abilityId) then
                    -- row.nameLabel:SetColor(1, 0.85, 0.1, 1) -- Gold
                    row.nameLabel:SetColor(0.486, 0.745, 0.98, 1)
                else
                    row.nameLabel:SetColor(unpack(nameCol))
                end
            end     

            row.timerLabel:ClearAnchors()
            row.timerLabel:SetAnchor(CENTER, row.icon, CENTER, 0, 0)
            row.timerLabel:SetFont(string.format("$(BOLD_FONT)|%d|soft-shadow-thin", iconSize/1.5))
            row.timerLabel:SetColor(unpack(timerCol))
            row.timerLabel:SetDimensions(iconSize, iconSize)

            row.countLabel:ClearAnchors()
            row.countLabel:SetAnchor(RIGHT, row.icon, LEFT, -4, 0)
            row.countLabel:SetFont(string.format("$(BOLD_FONT)|%d|soft-shadow-thin", countSize))
            local twoDigitWidth = row.countLabel:GetStringWidth("88")
            local countLabelWidth = twoDigitWidth + 4
            row.countLabel:SetDimensions(countLabelWidth, iconSize)
            row.countLabel:SetColor(unpack(countCol))

            -- Stackbare Effekte haben keine Dauer → nicht löschen
            local isStackable = IsStackableAbility(abilityId)

            if remaining <= 0 and not isStackable then
                ActiveTimers[abilityId] = nil
                if not DsRGuildLoot.sV.DsRBuffTxTonoff then
                    row.bar:SetValue(0)
                end
                row.timerLabel:SetText("")
            else
                -- Moduswechsel
                if remaining <= 4 and timer.mode ~= "fast" then
                    timer.mode = "fast"
                elseif remaining > 4 and timer.mode ~= "slow" then
                    timer.mode = "slow"
                end

                -- Icon & Name
                row.icon:SetTexture(timer.icon)
                if not DsRGuildLoot.sV.DsRBuffTxTonoff then
                    row.nameLabel:SetText(timer.name)
                end

                -- Stack-Anzeige hat Vorrang
                if timer.stackCount and timer.stackCount > 0 then
                    row.timerLabel:SetText(timer.stackCount)
                else
                    -- Timer im Icon
                    if remaining >= 3 then
                        row.timerLabel:SetText(string.format("%d", math.floor(remaining)))
                    else
                        row.timerLabel:SetText(string.format("%.1f", remaining))
                    end
                end

                if not DsRGuildLoot.sV.DsRBuffTxTonoff then
                    local isStackable = IsStackableAbility(abilityId)
                
                    if isStackable then
                        local data = DsRglobals.StackableSets[abilityId]
                        local maxStack = (data and data.maxStack and data.maxStack > 0) and data.maxStack or 10
                        local current = timer.stackCount or 0
                    
                        local progress = math.min(current / maxStack, 1)
                        row.bar:SetValue(progress)
                    
                        -- Multi-Gradient Farbe holen
                        local r, g, b = MultiGradient(progress, StackGradientColors)
                        row.bar:SetColor(r, g, b, 0.4)
                    
                    else
                        -- normale Timer-Progressbar
                        local total = timer.totalDuration > 0 and timer.totalDuration or 0.1
                        row.bar:SetValue(remaining / total)
                    
                        local color = GetBuffColor(timer.buffClass)
                        row.bar:SetColor(unpack(color))
                    end
                end
            end

            local count = GroupBuffCounts[abilityId] or 0
            row.countLabel:SetText(count > 0 and tostring(count) or "1")

            -- FlauschIcon nur für @Prof_Flausch
            local hasPlayerBuff = false
            local countSize     = DsRGuildLoot.sV.DsRBuffCountsize or 16
            local dynamicOffset = (countSize * 0.5)

            row.FlauschIcon:ClearAnchors()
            row.FlauschIcon:SetAnchor(RIGHT, row.countLabel, LEFT, dynamicOffset, 0)
            if iconSize >= 32 then
                row.FlauschIcon:SetDimensions(32, 32)
            else
                row.FlauschIcon:SetDimensions(iconSize, iconSize)
            end

            local flauschUnit = GetGroupUnitByAccName("@Prof_Flausch")
            local hasPlayerBuff = false

            if flauschUnit then
                hasPlayerBuff = DoesUnitHaveBuff(flauschUnit, abilityId)
            end

            row.FlauschIcon:SetHidden(not hasPlayerBuff)

            row.currentWidth = CalculateRowWidth(row)
        end
    end)
end

function DsRGuildBuffs.RefreshUI()
    -- Whitelist neu laden
    BuildWhitelist()

    -- Alte Zeilen wirklich entfernen
    for abilityId, row in pairs(BuffRows) do
        if row then
            row:SetHidden(true)
            row:ClearAnchors()
            row:SetParent(nil)   -- WICHTIG!
        end
    end
    BuffRows = {}

    -- Neue Zeilen erzeugen
    CreateAllWhitelistRows()

    -- Neu anordnen
    ReanchorRows()
end

function DsRGuildBuffs.GetCurrentBuffProfile()
    local zoneId = GetZoneId(GetUnitZoneIndex("player"))
    local lang   = GetCVar("language.2")

    if IsInCyrodiil() or IsInImperialCity() then
        return "PvP"
    end

    -- Prüfungen (Raids)
    if GetCurrentZoneDungeonDifficulty() ~= DUNGEON_DIFFICULTY_NONE then
        local lang = GetCVar("language.2")

        for _, raid in ipairs(DsRglobals.Raids) do
            if raid.id == zoneId then
                local RaidName = (lang == "de") and raid.de or raid.en
                return tostring(RaidName)
            end
        end
    end

    -- Standard
	if lang == "de" then
		return "Allgemein"
	else
		return "General"
	end
end

------------------------------------------------------------
-- UI automatisch ausblenden, wenn Menüs geöffnet sind
------------------------------------------------------------
local hideCounter = 0   -- zählt, wie viele Menüs gerade offen sind
local wasVisible = false

local function UpdateUIVisibility(hidden)
    if not BuffWindow then return end

    if hidden then
        -- Erstes Menü öffnet sich → Zustand merken
        if hideCounter == 0 then
            wasVisible = not BuffWindow:IsHidden()
        end

        hideCounter = hideCounter + 1

        -- Nur verstecken, wenn es vorher sichtbar war
        if wasVisible and not BuffWindow:IsHidden() then
            BuffWindow:SetHidden(true)
        end
    else
        -- Ein Menü schließt sich
        hideCounter = math.max(0, hideCounter - 1)

        -- Erst wenn ALLE Menüs zu sind → wiederherstellen
        if hideCounter == 0 and wasVisible then
            BuffWindow:SetHidden(false)
        end
    end
end

------------------------------------------------------------
-- Buff-Tracking: Jeder Buff startet seinen eigenen Timer
------------------------------------------------------------
local function OnEffectChanged(eventCode, changeType, effectSlot, effectName, unitTag,
                               beginTime, endTime, stackCount, iconName, buffType,
                               effectType, abilityType, statusEffectType, unitName,
                               unitId, abilityId, sourceType)

    -- Nur Whitelist-Buffs
    if not Whitelist[abilityId] then return end

    -- Gruppenbuffs nicht als Timer starten
    if string.match(unitTag, "^group%d+$") then
        return
    end

    -- Stack korrekt bestimmen (ESO liefert bei FADED nil!)
    local newStack = (stackCount ~= nil) and stackCount or 0

    -- Stack speichern
    LastStacks[abilityId] = newStack

    -- Buff FADED → Timer löschen + Stack auf 0
    if changeType == EFFECT_RESULT_FADED then
        if ActiveTimers[abilityId] then
            ActiveTimers[abilityId].stackCount = 0
            ActiveTimers[abilityId] = nil   -- WICHTIG!
        end
        return
    end

    -- Timer starten / aktualisieren
    if unitTag == "player" then
        if not ActiveTimers[abilityId] then
            ActiveTimers[abilityId] = CreateTimer(
                abilityId, beginTime, endTime, effectName, iconName,
                effectType, statusEffectType, abilityType, sourceType,
                newStack
            )
        else
            ActiveTimers[abilityId].endTime    = endTime
            ActiveTimers[abilityId].stackCount = newStack
        end
    end
end

local function OnZoneChanged()
    -- Profil neu bestimmen
    local profile = DsRGuildBuffs.GetCurrentBuffProfile()

    -- Whitelist neu laden
    BuildWhitelist()

    -- Masterlist neu bauen
    if BuffWindow then
        CreateAllWhitelistRows()
    end

    -- UI aktualisieren
    DsRGuildBuffs.RefreshUI()
end

------------------------------------------------------------
-- LFG GROUP ROLE SETZEN
------------------------------------------------------------
function DsRGuildBuffs:SetRoleDD()
    UpdateSelectedLFGRole(LFG_ROLE_DPS, true)
    DsRGuildBuffs.RefreshUI()
end

function DsRGuildBuffs:SetRoleTank()
    UpdateSelectedLFGRole(LFG_ROLE_TANK, true)
    DsRGuildBuffs.RefreshUI()
end

function DsRGuildBuffs:SetRoleHeal()
    UpdateSelectedLFGRole(LFG_ROLE_HEAL, true)
    DsRGuildBuffs.RefreshUI()
end

------------------------------------------------------------
-- ADDON LOAD
------------------------------------------------------------
function DsRGuildBuffs.OnAddOnLoaded(_, addonName)
    if not DsRGuildLoot or not DsRGuildLoot.sV or not DsRGuildLoot.sV.DsRBuffEnable then
        return
    end

    DsRGuildBuffs.configCHAR = ZO_SavedVars:New("DsRGuildBuffsCharSettings", 1, nil, {})
    EnsureRaidBuffCharDefaults()

    BuildWhitelist()
    BuffWindow = CreateBuffWindow()
    CreateAllWhitelistRows()
    StartMultiTimerEngine()

    EVENT_MANAGER:RegisterForEvent("DsRGuildBuffsMultiTimerBuff", EVENT_EFFECT_CHANGED, OnEffectChanged)
    EVENT_MANAGER:RegisterForEvent("DsRGuildBuffsZoneChange", EVENT_PLAYER_ACTIVATED, OnZoneChanged)
    
    DsRGuildBuffs.RefreshUI()

    ZO_PreHookHandler(ZO_MainMenuCategoryBar, "OnShow", function() UpdateUIVisibility(true) end)
    ZO_PreHookHandler(ZO_InteractWindow,      "OnShow", function() UpdateUIVisibility(true) end)
    ZO_PreHookHandler(ZO_GameMenu_InGame,     "OnShow", function() UpdateUIVisibility(true) end)
    ZO_PreHookHandler(ZO_KeybindStripControl, "OnShow", function() UpdateUIVisibility(true) end)

    ZO_PreHookHandler(ZO_MainMenuCategoryBar, "OnHide", function() UpdateUIVisibility(false) end)
    ZO_PreHookHandler(ZO_InteractWindow,      "OnHide", function() UpdateUIVisibility(false) end)
    ZO_PreHookHandler(ZO_GameMenu_InGame,     "OnHide", function() UpdateUIVisibility(false) end)
    ZO_PreHookHandler(ZO_KeybindStripControl, "OnHide", function() UpdateUIVisibility(false) end)

end
