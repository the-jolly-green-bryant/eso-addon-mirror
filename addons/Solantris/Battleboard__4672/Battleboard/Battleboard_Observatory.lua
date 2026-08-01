-- Battleboard_Observatory.lua  (Observatory scene construction and rendering)
-- Part of Battleboard. Cross-file constants and helpers are read from Battleboard.__constants.

local BL = Battleboard
local _x = BL.__constants

local BG_ICON = _x.BG_ICON
local BLANK_ICON = _x.BLANK_ICON
local classIcons = _x.classIcons
local encounterClassOrder = _x.encounterClassOrder
local Num = _x.Num
local FormatBigNumber = _x.FormatBigNumber
local FormatMatchId = _x.FormatMatchId
local FormatTimestamp = _x.FormatTimestamp
local CreateLabel = _x.CreateLabel
local CreateSoftFill = _x.CreateSoftFill
local CONTENT_TOP = _x.CONTENT_TOP
local CONTENT_WIDTH = _x.CONTENT_WIDTH
local STRIP_WIDTH = _x.STRIP_WIDTH
local PAGE_TWO_PANEL_HEIGHT = _x.PAGE_TWO_PANEL_HEIGHT
local DATA_SUMMARY_STRIP_HEIGHT = _x.DATA_SUMMARY_STRIP_HEIGHT
local DATA_CONTRIBUTION_PANEL_HEIGHT = _x.DATA_CONTRIBUTION_PANEL_HEIGHT
local BuildEncounterSummary = _x.BuildEncounterSummary
local BuildClassSpreadRows = _x.BuildClassSpreadRows
local GetClassInsightSummary = _x.GetClassInsightSummary
local GetEncounterHallOfFame = _x.GetEncounterHallOfFame

local SCENE_CONTENT_TOP_INSET = 0
local SCENE_CONTENT_RIGHT_INSET = -15
local HEADER_BG_H = 30
local TABLE_PAD = 10
local COL_ROW_H = 20
local HDR_ROW_H = 22
local OBS_PANEL_H = 232

local ENCOUNTER_AGGREGATE_OPTIONS = {
    { key = "Averages", label = "Average" },
    { key = "Totals", label = "Totals" },
}

local CLASS_SPREAD_OPTIONS = {
    { key = "Popularity", label = "Popularity" },
    { key = "Survivability", label = "Survivability" },
    { key = "Deadliness", label = "Deadliness" },
    { key = "Brutality", label = "Brutality" },
    { key = "Supportiveness", label = "Supportiveness" },
}

local function NormalizeClassSpreadMode(mode)
    for _, option in ipairs(CLASS_SPREAD_OPTIONS) do
        if mode == option.key then return mode end
    end
    return "Popularity"
end

local function GetAlphabeticalClassOrder()
    local sorted = {}
    for i, classSpec in ipairs(encounterClassOrder or {}) do
        sorted[i] = classSpec
    end
    table.sort(sorted, function(a, b)
        return string.lower(tostring(a and a.label or "")) < string.lower(tostring(b and b.label or ""))
    end)
    return sorted
end

local TREND_TOOLTIPS = {
    mostPopular     = "Most unique players",
    leastPopular    = "Fewest unique players",
    mostSurvivable  = "Lowest average deaths",
    leastSurvivable = "Highest average deaths",
    mostDeadly      = "Highest average kills",
    leastDeadly     = "Lowest average kills",
    mostBrutal      = "Highest average damage by damage dealers",
    leastBrutal     = "Lowest average damage by damage dealers",
    mostSupportive  = "Highest average healing by healers",
    leastSupportive = "Lowest average healing by healers",
}

local function FormatEncounterClassSeenValue(value, mode)
    value = Num(value)
    if mode == "Totals" then
        return FormatBigNumber(math.floor(value + 0.5))
    end
    return string.format("%.2f", value)
end

local function FormatHallOfFameValue(value, key)
    value = Num(value)
    if key == "kd" then
        if value < 0 then return "--" end
        return string.format("%.2f", value)
    end
    return FormatBigNumber(math.floor(value + 0.5))
end

local function FormatHallOfFameUser(record)
    if not record then return "--" end
    local displayName = tostring(record.displayName or "")
    if displayName ~= "" then return displayName end
    local characterName = tostring(record.characterName or "")
    if characterName ~= "" then return characterName end
    return "--"
end

local function CreateObservatoryPanel(parent, name, title, x, y, w, h)
    local panel = WINDOW_MANAGER:CreateControl("Battleboard" .. name .. "Panel", parent, CT_CONTROL)
    panel:SetDimensions(w, h)
    panel:SetAnchor(TOPLEFT, parent, TOPLEFT, x, y)

    local bg = CreateSoftFill(panel, "Battleboard" .. name .. "PanelBg", 0, 0, 0, 0.50)
    bg:SetAnchorFill(panel)

    for _, side in ipairs({"Top","Bottom","Left","Right"}) do
        local b = WINDOW_MANAGER:CreateControl("Battleboard" .. name .. "PanelBorder" .. side, panel, CT_BACKDROP)
        if side == "Top" then
            b:SetAnchor(TOPLEFT, panel, TOPLEFT, 0, 0)
            b:SetAnchor(TOPRIGHT, panel, TOPRIGHT, 0, 0)
            b:SetHeight(1)
        elseif side == "Bottom" then
            b:SetAnchor(BOTTOMLEFT, panel, BOTTOMLEFT, 0, 0)
            b:SetAnchor(BOTTOMRIGHT, panel, BOTTOMRIGHT, 0, 0)
            b:SetHeight(1)
        elseif side == "Left" then
            b:SetAnchor(TOPLEFT, panel, TOPLEFT, 0, 0)
            b:SetAnchor(BOTTOMLEFT, panel, BOTTOMLEFT, 0, 0)
            b:SetWidth(1)
        elseif side == "Right" then
            b:SetAnchor(TOPRIGHT, panel, TOPRIGHT, 0, 0)
            b:SetAnchor(BOTTOMRIGHT, panel, BOTTOMRIGHT, 0, 0)
            b:SetWidth(1)
        end
        b:SetCenterColor(1, 0.82, 0.28, 0.32)
        b:SetEdgeColor(0, 0, 0, 0)
    end

    local hdr = WINDOW_MANAGER:CreateControl("Battleboard" .. name .. "PanelHeader", panel, CT_CONTROL)
    hdr:SetDimensions(w - TABLE_PAD * 2, HEADER_BG_H)
    hdr:SetAnchor(TOPLEFT, panel, TOPLEFT, TABLE_PAD, 0)
    local hdrEdge = WINDOW_MANAGER:CreateControl("Battleboard" .. name .. "PanelHeaderEdge", hdr, CT_BACKDROP)
    hdrEdge:SetAnchor(BOTTOMLEFT, hdr, BOTTOMLEFT, 0, 0)
    hdrEdge:SetAnchor(BOTTOMRIGHT, hdr, BOTTOMRIGHT, 0, 0)
    hdrEdge:SetHeight(2)
    hdrEdge:SetCenterColor(0.549019607843, 0.541176470588, 0.450980392157, 1)
    hdrEdge:SetEdgeColor(0, 0, 0, 0)

    local label = CreateLabel(hdr, "Battleboard" .. name .. "PanelHeaderLabel", title, "ZoFontGameBold", {0.92, 0.84, 0.62, 1})
    label:SetAnchorFill(hdr)
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    panel.header = hdr
    panel.headerLabel = label

    return panel
end

local function AddObservatoryHeaderTooltip(panel, name, text)
    if not panel or not panel.header then return nil end
    local hitbox = WINDOW_MANAGER:CreateControl("Battleboard" .. name .. "HeaderTooltip", panel.header, CT_CONTROL)
    hitbox:SetDimensions(150, HEADER_BG_H)
    hitbox:SetAnchor(LEFT, panel.header, LEFT, 0, 0)
    hitbox:SetMouseEnabled(true)
    hitbox:SetHandler("OnMouseEnter", function(ctrl)
        ZO_Tooltips_ShowTextTooltip(ctrl, BOTTOM, text)
    end)
    hitbox:SetHandler("OnMouseExit", function()
        ZO_Tooltips_HideTextTooltip()
    end)
    return hitbox
end

function BL.BuildObservatoryPage(root)
    local contentWidth = STRIP_WIDTH or CONTENT_WIDTH
    BL.observatoryPageContainer = WINDOW_MANAGER:CreateControl("BattleboardObservatoryPageContainer", root, CT_CONTROL)
    BL.observatoryPageContainer:SetDimensions(contentWidth, PAGE_TWO_PANEL_HEIGHT)
    if BL.filterStrip then
        BL.observatoryPageContainer:SetAnchor(TOPLEFT, BL.filterStrip, TOPLEFT, 0, CONTENT_TOP)
    else
        BL.observatoryPageContainer:SetAnchor(TOPLEFT, root, TOPLEFT, SCENE_CONTENT_RIGHT_INSET, CONTENT_TOP + SCENE_CONTENT_TOP_INSET)
    end
    BL.observatoryPageContainer:SetHidden(true)

    local OBS_GAP = 8
    local OBS_FOOTER_H = 50
    local OBS_CLASSES_W = 300
    local OBS_CONTENT_BASE_H = math.min(
        PAGE_TWO_PANEL_HEIGHT - OBS_FOOTER_H - OBS_GAP,
        Num(DATA_SUMMARY_STRIP_HEIGHT) + OBS_GAP + Num(DATA_CONTRIBUTION_PANEL_HEIGHT) + OBS_GAP + OBS_PANEL_H
    )
    local OBS_BASE_STACK_PANEL_H = math.floor((OBS_CONTENT_BASE_H - OBS_GAP * 2) / 3)
    local OBS_BASE_REPRESENTATION_PANEL_H = OBS_BASE_STACK_PANEL_H - 40
    local OBS_ENCOUNTER_PANEL_H = OBS_BASE_STACK_PANEL_H + 24
    local OBS_BASE_HALL_PANEL_H = OBS_CONTENT_BASE_H - OBS_GAP * 2 - OBS_ENCOUNTER_PANEL_H - OBS_BASE_REPRESENTATION_PANEL_H
    local OBS_REPRESENTATION_PANEL_H = OBS_BASE_REPRESENTATION_PANEL_H - 25
    local OBS_HALL_PANEL_H = OBS_BASE_HALL_PANEL_H - 25
    local OBS_CONTENT_H = OBS_HALL_PANEL_H + OBS_GAP + OBS_ENCOUNTER_PANEL_H + OBS_GAP + OBS_REPRESENTATION_PANEL_H
    local OBS_CLASSES_H = OBS_CONTENT_H
    local OBS_ENCOUNTER_W = contentWidth - OBS_CLASSES_W - OBS_GAP
    local OBS_HALL_Y = 0
    local OBS_ENCOUNTER_Y = OBS_HALL_PANEL_H + OBS_GAP
    local OBS_REPRESENTATION_Y = OBS_ENCOUNTER_Y + OBS_ENCOUNTER_PANEL_H + OBS_GAP

    BL.observatoryClassesPanel = CreateObservatoryPanel(BL.observatoryPageContainer, "ObservatoryClasses", "TRENDS", 0, 0, OBS_CLASSES_W, OBS_CLASSES_H)
    BL.observatoryClassInsightRows = {}
    do
        local rows = {
            { key = "mostPopular",     label = "Most popular" },
            { key = "leastPopular",    label = "Least popular" },
            { key = "mostSurvivable",  label = "Most survivable" },
            { key = "leastSurvivable", label = "Least survivable" },
            { key = "mostDeadly",      label = "Most deadly" },
            { key = "leastDeadly",     label = "Least deadly" },
            { key = "mostBrutal",      label = "Most brutal" },
            { key = "leastBrutal",     label = "Least brutal" },
            { key = "mostSupportive",  label = "Most supportive" },
            { key = "leastSupportive", label = "Least supportive" },
        }
        local tileGap = 8
        local tileW = math.floor((OBS_CLASSES_W - TABLE_PAD * 2 - tileGap) / 2)
        local tileH = math.floor((OBS_CLASSES_H - HEADER_BG_H - TABLE_PAD * 2 - tileGap * 4) / 5)
        local iconSize = 54
        for i, spec in ipairs(rows) do
            local col = (i - 1) % 2
            local row = math.floor((i - 1) / 2)
            local tileX = TABLE_PAD + col * (tileW + tileGap)
            local tileY = HEADER_BG_H + TABLE_PAD + row * (tileH + tileGap)

            local tile = WINDOW_MANAGER:CreateControl("BattleboardObservatoryClassInsightTile_" .. spec.key, BL.observatoryClassesPanel, CT_CONTROL)
            tile:SetDimensions(tileW, tileH)
            tile:SetAnchor(TOPLEFT, BL.observatoryClassesPanel, TOPLEFT, tileX, tileY)

            local label = CreateLabel(tile, "BattleboardObservatoryClassInsightLabel_" .. spec.key, spec.label, "ZoFontGameBold", {0.92, 0.84, 0.62, 1})
            label:SetAnchor(TOPLEFT, tile, TOPLEFT, 4, 8)
            label:SetDimensions(tileW - 8, 24)
            label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
            label:SetVerticalAlignment(TEXT_ALIGN_CENTER)

            local icon = WINDOW_MANAGER:CreateControl("BattleboardObservatoryClassInsightIcon_" .. spec.key, tile, CT_TEXTURE)
            icon:SetTexture(BLANK_ICON)
            icon:SetDimensions(iconSize, iconSize)
            icon:SetAnchor(CENTER, tile, CENTER, 0, 10)
            icon:SetMouseEnabled(false)

            local iconHitbox = WINDOW_MANAGER:CreateControl("BattleboardObservatoryClassInsightIconHitbox_" .. spec.key, tile, CT_CONTROL)
            iconHitbox:SetDimensions(iconSize, iconSize)
            iconHitbox:SetAnchor(CENTER, icon, CENTER, 0, 0)
            iconHitbox:SetMouseEnabled(true)
            iconHitbox:SetDrawLayer(DL_CONTROLS)
            iconHitbox:SetDrawTier(DT_HIGH)

            BL.observatoryClassInsightRows[spec.key] = { tile = tile, icon = icon, iconHitbox = iconHitbox, label = label }
        end
    end

    BL.observatoryEncounterPanel = CreateObservatoryPanel(BL.observatoryPageContainer, "ObservatoryEncounter", "REPRESENTATION", OBS_CLASSES_W + OBS_GAP, OBS_ENCOUNTER_Y, OBS_ENCOUNTER_W, OBS_ENCOUNTER_PANEL_H)
    BL.observatoryEncounterTooltip = AddObservatoryHeaderTooltip(BL.observatoryEncounterPanel, "ObservatoryEncounter", "By unique characters")
    if BL.observatoryEncounterPanel.headerLabel then
        BL.observatoryEncounterPanel.headerLabel:ClearAnchors()
        BL.observatoryEncounterPanel.headerLabel:SetAnchorFill(BL.observatoryEncounterPanel.header)
        BL.observatoryEncounterPanel.headerLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    end
    if BL.observatoryEncounterPanel.header and WINDOW_MANAGER.CreateControlFromVirtual and ZO_ComboBox_ObjectFromContainer then
        BL.observatoryEncounterAggregateDropdown = WINDOW_MANAGER:CreateControlFromVirtual("BattleboardObservatoryEncounterAggregateDropdown", BL.observatoryEncounterPanel.header, "ZO_ComboBox")
        BL.observatoryEncounterAggregateDropdown:SetDimensions(78, 24)
        BL.observatoryEncounterAggregateDropdown:SetAnchor(RIGHT, BL.observatoryEncounterPanel.header, RIGHT, 0, 0)
        BL.observatoryEncounterAggregateDropdownCombo = ZO_ComboBox_ObjectFromContainer(BL.observatoryEncounterAggregateDropdown)
        if BL.observatoryEncounterAggregateDropdownCombo then
            BL.observatoryEncounterAggregateDropdownCombo:SetSortsItems(false)
            for _, option in ipairs(ENCOUNTER_AGGREGATE_OPTIONS) do
                local item = BL.observatoryEncounterAggregateDropdownCombo:CreateItemEntry(option.label, function()
                    BL.observatoryEncounterAggregateMode = option.key
                    BL.RefreshObservatoryPage()
                end)
                BL.observatoryEncounterAggregateDropdownCombo:AddItem(item, ZO_COMBOBOX_SUPPRESS_UPDATE)
            end
            BL.observatoryEncounterAggregateDropdownCombo:SetSelectedItem(BL.observatoryEncounterAggregateMode == "Totals" and "Totals" or "Average")
        end
    elseif BL.observatoryEncounterPanel.header then
        BL.observatoryEncounterAggregateDropdown = CreateLabel(BL.observatoryEncounterPanel.header, "BattleboardObservatoryEncounterAggregateDropdownFallback", BL.observatoryEncounterAggregateMode or "Averages", "ZoFontGame", {0.80, 0.76, 0.64, 1})
        BL.observatoryEncounterAggregateDropdown:SetDimensions(78, 20)
        BL.observatoryEncounterAggregateDropdown:SetAnchor(RIGHT, BL.observatoryEncounterPanel.header, RIGHT, 0, 0)
    end
    BL.observatoryEncounterClassAverageTableLabels = {}
    do
        local TW = OBS_ENCOUNTER_W - TABLE_PAD * 2
        local LABEL_W = 130
        local OBS_ENC_COLS = {
            { key = "today",   label = "Today"   },
            { key = "week",    label = "7 day"   },
            { key = "thirty",  label = "30 day"  },
            { key = "overall", label = "Overall" },
        }
        local ENC_COL_W = math.floor((TW - LABEL_W) / #OBS_ENC_COLS)
        local tableY = HEADER_BG_H + TABLE_PAD

        for i, col in ipairs(OBS_ENC_COLS) do
            local cx = TABLE_PAD + LABEL_W + (i - 1) * ENC_COL_W
            local hdr = CreateLabel(BL.observatoryEncounterPanel, "BattleboardObservatoryEncColHdr_" .. col.key, col.label, "ZoFontGameBold", {0.92, 0.84, 0.62, 1})
            hdr:SetAnchor(TOPLEFT, BL.observatoryEncounterPanel, TOPLEFT, cx, tableY)
            hdr:SetDimensions(ENC_COL_W, HDR_ROW_H)
            hdr:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
            hdr:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        end

        local hdrDiv = WINDOW_MANAGER:CreateControl("BattleboardObservatoryEncHdrDiv", BL.observatoryEncounterPanel, CT_BACKDROP)
        hdrDiv:SetDimensions(TW, 1)
        hdrDiv:SetAnchor(TOPLEFT, BL.observatoryEncounterPanel, TOPLEFT, TABLE_PAD, tableY + HDR_ROW_H + 2)
        hdrDiv:SetCenterColor(0.549019607843, 0.541176470588, 0.450980392157, 0.6)
        hdrDiv:SetEdgeColor(0, 0, 0, 0)

        local rowY = tableY + HDR_ROW_H + 6
        for _, classSpec in ipairs(GetAlphabeticalClassOrder()) do
            local ry = rowY
            rowY = rowY + COL_ROW_H + 2

            local icon = WINDOW_MANAGER:CreateControl("BattleboardObservatoryEncClassIcon_" .. classSpec.key, BL.observatoryEncounterPanel, CT_TEXTURE)
            icon:SetTexture(classIcons[classSpec.key] or BG_ICON)
            icon:SetDimensions(17, 17)
            icon:SetAnchor(TOPLEFT, BL.observatoryEncounterPanel, TOPLEFT, TABLE_PAD, ry + 1)

            local nameLabel = CreateLabel(BL.observatoryEncounterPanel, "BattleboardObservatoryEncClassName_" .. classSpec.key, classSpec.label, "ZoFontGame", {0.86, 0.84, 0.75, 1})
            nameLabel:SetAnchor(TOPLEFT, BL.observatoryEncounterPanel, TOPLEFT, TABLE_PAD + 22, ry)
            nameLabel:SetDimensions(LABEL_W - 22, COL_ROW_H)
            nameLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
            nameLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)

            BL.observatoryEncounterClassAverageTableLabels[classSpec.key] = {}
            for i, col in ipairs(OBS_ENC_COLS) do
                local cx = TABLE_PAD + LABEL_W + (i - 1) * ENC_COL_W
                local cell = CreateLabel(BL.observatoryEncounterPanel, "BattleboardObservatoryEncCell_" .. classSpec.key .. "_" .. col.key, "--", "ZoFontGame", {0.86, 0.84, 0.75, 1})
                cell:SetAnchor(TOPLEFT, BL.observatoryEncounterPanel, TOPLEFT, cx, ry)
                cell:SetDimensions(ENC_COL_W, COL_ROW_H)
                cell:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
                cell:SetVerticalAlignment(TEXT_ALIGN_CENTER)
                BL.observatoryEncounterClassAverageTableLabels[classSpec.key][col.key] = cell
            end
        end

        local totalDiv = WINDOW_MANAGER:CreateControl("BattleboardObservatoryEncTotalDiv", BL.observatoryEncounterPanel, CT_BACKDROP)
        totalDiv:SetDimensions(TW, 1)
        totalDiv:SetAnchor(TOPLEFT, BL.observatoryEncounterPanel, TOPLEFT, TABLE_PAD, rowY + 1)
        totalDiv:SetCenterColor(0.549019607843, 0.541176470588, 0.450980392157, 0.42)
        totalDiv:SetEdgeColor(0, 0, 0, 0)

        local totalY = rowY + 4
        local totalLabel = CreateLabel(BL.observatoryEncounterPanel, "BattleboardObservatoryEncTotalLabel", "Total", "ZoFontGameBold", {0.92, 0.84, 0.62, 1})
        totalLabel:SetAnchor(TOPLEFT, BL.observatoryEncounterPanel, TOPLEFT, TABLE_PAD + 22, totalY)
        totalLabel:SetDimensions(LABEL_W - 22, COL_ROW_H)
        totalLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        totalLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)

        BL.observatoryEncounterTotalRowLabels = {}
        for i, col in ipairs(OBS_ENC_COLS) do
            local cx = TABLE_PAD + LABEL_W + (i - 1) * ENC_COL_W
            local cell = CreateLabel(BL.observatoryEncounterPanel, "BattleboardObservatoryEncTotalCell_" .. col.key, "--", "ZoFontGameBold", {0.92, 0.84, 0.62, 1})
            cell:SetAnchor(TOPLEFT, BL.observatoryEncounterPanel, TOPLEFT, cx, totalY)
            cell:SetDimensions(ENC_COL_W, COL_ROW_H)
            cell:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
            cell:SetVerticalAlignment(TEXT_ALIGN_CENTER)
            BL.observatoryEncounterTotalRowLabels[col.key] = cell
        end
        BL.observatoryEncounterTotalRowControls = { divider = totalDiv, label = totalLabel, cells = BL.observatoryEncounterTotalRowLabels }
    end

    BL.observatoryHallPanel = CreateObservatoryPanel(BL.observatoryPageContainer, "ObservatoryHallOfFame", "HALL OF FAME", OBS_CLASSES_W + OBS_GAP, OBS_HALL_Y, OBS_ENCOUNTER_W, OBS_HALL_PANEL_H)
    BL.observatoryHallTooltip = AddObservatoryHeaderTooltip(BL.observatoryHallPanel, "ObservatoryHallOfFame", "Best witnessed")
    BL.observatoryHallRows = {}
    do
        local specs = {
            { key = "damage",  label = "Damage" },
            { key = "healing", label = "Healing" },
            { key = "kills",   label = "Kills" },
            { key = "kd",      label = "KD" },
        }
        local blockGap = 8
        local blockW = math.floor((OBS_ENCOUNTER_W - TABLE_PAD * 2 - blockGap * (#specs - 1)) / #specs)
        local blockH = OBS_HALL_PANEL_H - HEADER_BG_H - TABLE_PAD * 2
        local blockY = HEADER_BG_H + TABLE_PAD
        local iconSize = 40

        for i, spec in ipairs(specs) do
            local blockX = TABLE_PAD + (i - 1) * (blockW + blockGap)
            local block = WINDOW_MANAGER:CreateControl("BattleboardObservatoryHallBlock_" .. spec.key, BL.observatoryHallPanel, CT_CONTROL)
            block:SetDimensions(blockW, blockH)
            block:SetAnchor(TOPLEFT, BL.observatoryHallPanel, TOPLEFT, blockX, blockY)

            local bg = CreateSoftFill(block, "BattleboardObservatoryHallBlockBg_" .. spec.key, 0.050, 0.044, 0.036, 0.62)
            bg:SetAnchorFill(block)

            local header = CreateLabel(block, "BattleboardObservatoryHallHeader_" .. spec.key, spec.label, "ZoFontGameBold", {0.92, 0.84, 0.62, 1})
            header:SetAnchor(TOPLEFT, block, TOPLEFT, 6, 4)
            header:SetDimensions(blockW - 12, 26)
            header:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
            header:SetVerticalAlignment(TEXT_ALIGN_CENTER)

            local classIcon = WINDOW_MANAGER:CreateControl("BattleboardObservatoryHallClassIcon_" .. spec.key, block, CT_TEXTURE)
            classIcon:SetTexture(BLANK_ICON)
            classIcon:SetDimensions(iconSize, iconSize)
            classIcon:SetAnchor(TOP, block, TOP, 0, 42)

            local user = CreateLabel(block, "BattleboardObservatoryHallUser_" .. spec.key, "--", "ZoFontGameBold", {0.86, 0.84, 0.75, 1})
            user:SetAnchor(TOPLEFT, block, TOPLEFT, 6, 90)
            user:SetDimensions(blockW - 12, 22)
            user:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
            user:SetVerticalAlignment(TEXT_ALIGN_CENTER)

            local value = CreateLabel(block, "BattleboardObservatoryHallValue_" .. spec.key, "--", "ZoFontWinH1", {0.92, 0.84, 0.62, 1})
            value:SetAnchor(TOP, user, BOTTOM, 0, 2)
            value:SetDimensions(blockW - 12, 32)
            value:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
            value:SetVerticalAlignment(TEXT_ALIGN_CENTER)
            if value.SetScale then value:SetScale(0.88) end

            local total = CreateLabel(block, "BattleboardObservatoryHallTotal_" .. spec.key, "", "ZoFontGameSmall", {0.62, 0.59, 0.50, 1})
            total:SetAnchor(TOP, value, BOTTOM, 0, 0)
            total:SetDimensions(blockW - 12, 20)
            total:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
            total:SetVerticalAlignment(TEXT_ALIGN_CENTER)

            BL.observatoryHallRows[spec.key] = {
                block = block,
                classIcon = classIcon,
                user = user,
                value = value,
                total = total,
            }
        end
    end

    BL.observatoryRepresentationPanel = CreateObservatoryPanel(BL.observatoryPageContainer, "ObservatoryRepresentation", "CLASS SPREAD", OBS_CLASSES_W + OBS_GAP, OBS_REPRESENTATION_Y, OBS_ENCOUNTER_W, OBS_REPRESENTATION_PANEL_H)
    BL.observatoryClassSpreadTooltip = AddObservatoryHeaderTooltip(BL.observatoryRepresentationPanel, "ObservatoryClassSpread", "By unique characters")
    if BL.observatoryRepresentationPanel.header and WINDOW_MANAGER.CreateControlFromVirtual and ZO_ComboBox_ObjectFromContainer then
        BL.observatoryClassSpreadDropdown = WINDOW_MANAGER:CreateControlFromVirtual("BattleboardObservatoryClassSpreadDropdown", BL.observatoryRepresentationPanel.header, "ZO_ComboBox")
        BL.observatoryClassSpreadDropdown:SetDimensions(126, 24)
        BL.observatoryClassSpreadDropdown:SetAnchor(RIGHT, BL.observatoryRepresentationPanel.header, RIGHT, 0, 0)
        BL.observatoryClassSpreadDropdownCombo = ZO_ComboBox_ObjectFromContainer(BL.observatoryClassSpreadDropdown)
        if BL.observatoryClassSpreadDropdownCombo then
            BL.observatoryClassSpreadDropdownCombo:SetSortsItems(false)
            for _, option in ipairs(CLASS_SPREAD_OPTIONS) do
                local item = BL.observatoryClassSpreadDropdownCombo:CreateItemEntry(option.label, function()
                    BL.observatoryClassSpreadMode = option.key
                    BL.RefreshObservatoryPage()
                end)
                BL.observatoryClassSpreadDropdownCombo:AddItem(item, ZO_COMBOBOX_SUPPRESS_UPDATE)
            end
            BL.observatoryClassSpreadDropdownCombo:SetSelectedItem(NormalizeClassSpreadMode(BL.observatoryClassSpreadMode))
        end
    elseif BL.observatoryRepresentationPanel.header then
        BL.observatoryClassSpreadDropdown = CreateLabel(BL.observatoryRepresentationPanel.header, "BattleboardObservatoryClassSpreadDropdownFallback", NormalizeClassSpreadMode(BL.observatoryClassSpreadMode), "ZoFontGame", {0.80, 0.76, 0.64, 1})
        BL.observatoryClassSpreadDropdown:SetDimensions(126, 20)
        BL.observatoryClassSpreadDropdown:SetAnchor(RIGHT, BL.observatoryRepresentationPanel.header, RIGHT, 0, 0)
        BL.observatoryClassSpreadDropdown:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
        BL.observatoryClassSpreadDropdown:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    end
    BL.observatoryRepresentationRows = {}
    do
        local blockGap = 6
        local blockW = math.floor((OBS_ENCOUNTER_W - TABLE_PAD * 2 - blockGap * 6) / 7)
        local blockH = OBS_REPRESENTATION_PANEL_H - HEADER_BG_H - TABLE_PAD * 2
        local blockY = HEADER_BG_H + TABLE_PAD
        local iconSize = 30

        for i = 1, 7 do
            local blockX = TABLE_PAD + (i - 1) * (blockW + blockGap)
            local block = WINDOW_MANAGER:CreateControl("BattleboardObservatoryRepresentationBlock_" .. i, BL.observatoryRepresentationPanel, CT_CONTROL)
            block:SetDimensions(blockW, blockH)
            block:SetAnchor(TOPLEFT, BL.observatoryRepresentationPanel, TOPLEFT, blockX, blockY)

            local bg = CreateSoftFill(block, "BattleboardObservatoryRepresentationBlockBg_" .. i, 0.050, 0.044, 0.036, 0.62)
            bg:SetAnchorFill(block)

            local rank = CreateLabel(block, "BattleboardObservatoryRepresentationRank_" .. i, tostring(i), "ZoFontWinH2", {0.92, 0.84, 0.62, 1})
            rank:SetAnchor(TOPLEFT, block, TOPLEFT, 4, 2)
            rank:SetDimensions(blockW - 8, 24)
            rank:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
            rank:SetVerticalAlignment(TEXT_ALIGN_CENTER)

            local icon = WINDOW_MANAGER:CreateControl("BattleboardObservatoryRepresentationIcon_" .. i, block, CT_TEXTURE)
            icon:SetTexture(BLANK_ICON)
            icon:SetDimensions(iconSize, iconSize)
            icon:SetAnchor(TOP, rank, BOTTOM, 0, 2)

            local value = CreateLabel(block, "BattleboardObservatoryRepresentationValue_" .. i, "--", "ZoFontWinH2", {0.92, 0.84, 0.62, 1})
            value:SetAnchor(TOP, icon, BOTTOM, 0, 6)
            value:SetDimensions(blockW - 8, 28)
            value:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
            value:SetVerticalAlignment(TEXT_ALIGN_CENTER)

            BL.observatoryRepresentationRows[i] = {
                block = block,
                rank = rank,
                icon = icon,
                value = value,
            }
        end
    end

    BL.observatoryFooter = WINDOW_MANAGER:CreateControl("BattleboardObservatoryFooter", BL.observatoryPageContainer, CT_CONTROL)
    BL.observatoryFooter:SetDimensions(contentWidth, OBS_FOOTER_H)
    BL.observatoryFooter:SetAnchor(TOPLEFT, BL.observatoryPageContainer, TOPLEFT, 0, OBS_CONTENT_H + OBS_GAP)

    BL.observatoryFooterDivider = WINDOW_MANAGER:CreateControl("BattleboardObservatoryFooterDivider", BL.observatoryFooter, CT_BACKDROP)
    BL.observatoryFooterDivider:SetDimensions(contentWidth, 1)
    BL.observatoryFooterDivider:SetAnchor(TOPLEFT, BL.observatoryFooter, TOPLEFT, 0, 0)
    BL.observatoryFooterDivider:SetCenterColor(0.549019607843, 0.541176470588, 0.450980392157, 0.42)
    BL.observatoryFooterDivider:SetEdgeColor(0, 0, 0, 0)

    BL.observatoryUniquePlayersLabel = CreateLabel(BL.observatoryFooter, "BattleboardObservatoryUniquePlayersLabel", "Total unique players: --", "ZoFontGameBold", {0.92, 0.84, 0.62, 1})
    BL.observatoryUniquePlayersLabel:SetAnchor(RIGHT, BL.observatoryFooter, RIGHT, -10, 0)
    BL.observatoryUniquePlayersLabel:SetDimensions(360, OBS_FOOTER_H)
    BL.observatoryUniquePlayersLabel:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    BL.observatoryUniquePlayersLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)

end

function BL.RefreshObservatoryPage()
    BL.BuildUI()

    local todayText = FormatTimestamp(GetTimeStamp())

    if BL.observatoryClassInsightRows then
        local insight = GetClassInsightSummary(todayText)
        for key, controls in pairs(BL.observatoryClassInsightRows) do
            local classKey = insight and insight[key]
            if controls.icon then
                controls.icon:SetTexture(classKey and (classIcons[classKey] or BLANK_ICON) or BLANK_ICON)
            end
            if controls.iconHitbox then
                controls.iconHitbox:SetMouseEnabled(classKey ~= nil)
                controls.iconHitbox:SetHidden(classKey == nil)
                if classKey then
                    controls.iconHitbox:SetHandler("OnMouseEnter", function(ctrl)
                        ZO_Tooltips_ShowTextTooltip(ctrl, BOTTOM, TREND_TOOLTIPS[key] or "Trend calculation")
                    end)
                    controls.iconHitbox:SetHandler("OnMouseExit", function()
                        ZO_Tooltips_HideTextTooltip()
                    end)
                else
                    controls.iconHitbox:SetHandler("OnMouseEnter", nil)
                    controls.iconHitbox:SetHandler("OnMouseExit", nil)
                end
            end
        end
    end

    local mode = BL.observatoryEncounterAggregateMode == "Totals" and "Totals" or "Averages"
    BL.observatoryEncounterAggregateMode = mode
    if BL.observatoryEncounterAggregateDropdownCombo then
        BL.observatoryEncounterAggregateDropdownCombo:SetSelectedItem(mode == "Totals" and "Totals" or "Average")
    elseif BL.observatoryEncounterAggregateDropdown and BL.observatoryEncounterAggregateDropdown.SetText then
        BL.observatoryEncounterAggregateDropdown:SetText(mode == "Totals" and "Totals" or "Average")
    end

    local encounterSummary = BuildEncounterSummary(todayText)
    local rows = BL.observatoryEncounterClassAverageTableLabels
    if rows then
        local AVG_WINDOWS = {
            { key = "today",  data = encounterSummary.today  },
            { key = "week",   data = encounterSummary.week   },
            { key = "thirty", data = encounterSummary.thirty },
        }
        local allData = encounterSummary.all
        for _, classSpec in ipairs(encounterClassOrder) do
            local row = rows[classSpec.key]
            if row then
                for _, win in ipairs(AVG_WINDOWS) do
                    local cell = row[win.key]
                    if cell then
                        local d = win.data
                        if d and d.matchCount > 0 then
                            local v
                            if mode == "Totals" and d.classTotals then
                                v = d.classTotals[classSpec.key]
                            elseif d.classAverages then
                                v = d.classAverages[classSpec.key]
                            end
                            cell:SetText(v ~= nil and FormatEncounterClassSeenValue(v, mode) or "--")
                        else
                            cell:SetText("--")
                        end
                    end
                end

                local overallCell = row["overall"]
                if overallCell then
                    if allData then
                        local v
                        if mode == "Totals" and allData.classTotals then
                            v = allData.classTotals[classSpec.key]
                        elseif allData.classAverages then
                            v = allData.classAverages[classSpec.key]
                        end
                        overallCell:SetText(v ~= nil and FormatEncounterClassSeenValue(v, mode) or "--")
                    else
                        overallCell:SetText("--")
                    end
                end
            end
        end

        local totalRows = BL.observatoryEncounterTotalRowLabels
        local showTotalRow = mode == "Totals"
        if BL.observatoryEncounterTotalRowControls then
            local controls = BL.observatoryEncounterTotalRowControls
            if controls.divider then controls.divider:SetHidden(not showTotalRow) end
            if controls.label then controls.label:SetHidden(not showTotalRow) end
            if controls.cells then
                for _, cell in pairs(controls.cells) do
                    if cell then cell:SetHidden(not showTotalRow) end
                end
            end
        end
        if totalRows then
            local function setTotalCell(key, data)
                local cell = totalRows[key]
                if not cell then return end
                if not showTotalRow then return end
                if not data or Num(data.matchCount) <= 0 then
                    cell:SetText("--")
                    return
                end

                local totalValue = 0
                if mode == "Totals" then
                    totalValue = Num(data.characterCount)
                else
                    for _, classSpec in ipairs(encounterClassOrder) do
                        totalValue = totalValue + Num(data.classAverages and data.classAverages[classSpec.key])
                    end
                end
                cell:SetText(FormatEncounterClassSeenValue(totalValue, mode))
            end

            for _, win in ipairs(AVG_WINDOWS) do
                setTotalCell(win.key, win.data)
            end
            setTotalCell("overall", allData)
        end
    end

    if BL.observatoryUniquePlayersLabel then
        local uniquePlayers = Num(encounterSummary and encounterSummary.all and encounterSummary.all.playerCount)
        BL.observatoryUniquePlayersLabel:SetText("Total unique players: " .. FormatBigNumber(uniquePlayers))
    end

    if BL.observatoryHallRows then
        local hall = GetEncounterHallOfFame(todayText)
        for key, controls in pairs(BL.observatoryHallRows) do
            local record = hall[key]
            if record then
                if controls.classIcon then
                    controls.classIcon:SetTexture(classIcons[Num(record.classId)] or BLANK_ICON)
                end
                if controls.user then
                    controls.user:SetText(FormatHallOfFameUser(record))
                end
                if controls.value then
                    controls.value:SetText(FormatHallOfFameValue(record.value, key))
                end
                if controls.total then
                    controls.total:SetText(record.matchId and ("Match " .. FormatMatchId(record.matchId)) or "Match --")
                end
            else
                if controls.classIcon then controls.classIcon:SetTexture(BLANK_ICON) end
                if controls.user then controls.user:SetText("--") end
                if controls.value then controls.value:SetText("--") end
                if controls.total then controls.total:SetText("Match --") end
            end
        end
    end

    if BL.observatoryRepresentationRows then
        local spreadMode = NormalizeClassSpreadMode(BL.observatoryClassSpreadMode)
        BL.observatoryClassSpreadMode = spreadMode
        if BL.observatoryClassSpreadDropdownCombo then
            BL.observatoryClassSpreadDropdownCombo:SetSelectedItem(spreadMode)
        elseif BL.observatoryClassSpreadDropdown and BL.observatoryClassSpreadDropdown.SetText then
            BL.observatoryClassSpreadDropdown:SetText(spreadMode)
        end

        local classRows = BuildClassSpreadRows(spreadMode, todayText)

        for i, controls in ipairs(BL.observatoryRepresentationRows) do
            local row = classRows[i]
            if row and row.value ~= nil then
                if controls.rank then controls.rank:SetText(tostring(i)) end
                if controls.icon then controls.icon:SetTexture(classIcons[row.key] or BLANK_ICON) end
                if controls.value then controls.value:SetText(tostring(row.text or "--")) end
            else
                if controls.rank then controls.rank:SetText(tostring(i)) end
                if controls.icon then controls.icon:SetTexture(BLANK_ICON) end
                if controls.value then controls.value:SetText("--") end
            end
        end
    end
end
