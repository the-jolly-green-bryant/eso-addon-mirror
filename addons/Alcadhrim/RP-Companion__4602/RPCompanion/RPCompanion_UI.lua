function RPCompanion:ShowTab(tabName)
    if not self.tabs then return end

    for name, control in pairs(self.tabs) do
        control:SetHidden(name ~= tabName)
    end

    self.currentTab = tabName
end

function RPCompanion:CreateScrollableList(parent, width, height, anchorTo, uniqueName)
    local wm = WINDOW_MANAGER

    local backdrop = wm:CreateControl(uniqueName .. "Backdrop", parent, CT_BACKDROP)
    backdrop:SetDimensions(width, height)
    backdrop:SetAnchor(TOPLEFT, anchorTo, BOTTOMLEFT, 0, 10)
    backdrop:SetCenterColor(0, 0, 0, 0.35)
    backdrop:SetEdgeColor(0.55, 0.45, 0.30, 1)
    backdrop:SetEdgeTexture(nil, 1, 1, 1, 0)

    local scroll = wm:CreateControlFromVirtual(uniqueName, backdrop, "ZO_ScrollContainer")
    scroll:SetAnchorFill(backdrop)

    local content = scroll:GetNamedChild("ScrollChild")
    return backdrop, content
end

function RPCompanion:ClearListContent(content)
    if not content then return end

    local numChildren = content:GetNumChildren()
    for i = numChildren, 1, -1 do
        local child = content:GetChild(i)
        if child then
            child:SetHidden(true)
            child:ClearAnchors()
            child:SetParent(nil)
        end
    end
end

function RPCompanion:ClampValue(value, minValue, maxValue)
    if value < minValue then return minValue end
    if value > maxValue then return maxValue end
    return value
end

function RPCompanion:UpdateAlignmentBar(fillControl, value, minValue, maxValue)
    if not fillControl then return end

    local ratio = (value - minValue) / (maxValue - minValue)
    if ratio < 0 then ratio = 0 end
    if ratio > 1 then ratio = 1 end

    local totalWidth = 760
    local fillWidth = math.floor(totalWidth * ratio)
    if fillWidth < 2 then fillWidth = 2 end

    fillControl:SetWidth(fillWidth)
end

function RPCompanion:CreateAlignmentScale(parent, prefix, titleText, x, y, leftText, rightText, fieldName, minValue, maxValue, defaultValue, labelFunc)
    local wm = WINDOW_MANAGER

    local title = wm:CreateControl(prefix .. "Title", parent, CT_LABEL)
    title:SetFont("ZoFontGameBold")
    title:SetText(titleText)
    title:SetAnchor(TOPLEFT, parent, TOPLEFT, x, y)

    local leftLabel = wm:CreateControl(prefix .. "LeftLabel", parent, CT_LABEL)
    leftLabel:SetFont("ZoFontGameSmall")
    leftLabel:SetText(leftText)
    leftLabel:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 0, 6)

    local rightLabel = wm:CreateControl(prefix .. "RightLabel", parent, CT_LABEL)
    rightLabel:SetFont("ZoFontGameSmall")
    rightLabel:SetText(rightText)
    rightLabel:SetAnchor(TOPRIGHT, parent, TOPLEFT, x + 760, y + 24)

    local valueLabel = wm:CreateControl(prefix .. "ValueLabel", parent, CT_LABEL)
    valueLabel:SetFont("ZoFontGame")
    valueLabel:SetAnchor(TOPLEFT, leftLabel, BOTTOMLEFT, 0, 8)
    valueLabel:SetDimensions(760, 24)
    valueLabel:SetText("")

    local barBg = wm:CreateControl(prefix .. "BarBg", parent, CT_BACKDROP)
    barBg:SetDimensions(760, 18)
    barBg:SetAnchor(TOPLEFT, valueLabel, BOTTOMLEFT, 0, 10)
    barBg:SetCenterColor(0.08, 0.08, 0.08, 0.85)
    barBg:SetEdgeColor(0.55, 0.45, 0.30, 1)
    barBg:SetEdgeTexture(nil, 1, 1, 1, 0)

    local barFill = wm:CreateControl(prefix .. "BarFill", barBg, CT_BACKDROP)
    barFill:SetAnchor(LEFT, barBg, LEFT, 0, 0)
    barFill:SetDimensions(2, 18)
    barFill:SetCenterColor(0.75, 0.65, 0.35, 0.95)
    barFill:SetEdgeColor(0.75, 0.65, 0.35, 0.95)
    barFill:SetEdgeTexture(nil, 1, 1, 1, 0)

    local marker = wm:CreateControl(prefix .. "Marker", barBg, CT_BACKDROP)
    marker:SetDimensions(2, 18)
    marker:SetAnchor(CENTER, barBg, CENTER, 0, 0)
    marker:SetCenterColor(1, 1, 1, 0.7)
    marker:SetEdgeColor(1, 1, 1, 0.7)
    marker:SetEdgeTexture(nil, 1, 1, 1, 0)

    local function RefreshOne()
        local profile = self:GetActiveProfile()
        local current = tonumber(profile[fieldName] or defaultValue) or defaultValue
        current = self:ClampValue(current, minValue, maxValue)
        profile[fieldName] = current
        valueLabel:SetText(labelFunc(current) .. " (" .. tostring(current) .. ")")
        self:UpdateAlignmentBar(barFill, current, minValue, maxValue)
    end

    local function ChangeValue(delta)
        local profile = self:GetActiveProfile()
        local current = tonumber(profile[fieldName] or defaultValue) or defaultValue
        current = self:ClampValue(current + delta, minValue, maxValue)
        profile[fieldName] = current
        RefreshOne()
    end

    local minus10 = wm:CreateControlFromVirtual(prefix .. "Minus10", parent, "ZO_DefaultButton")
    minus10:SetDimensions(70, 26)
    minus10:SetAnchor(TOPLEFT, barBg, BOTTOMLEFT, 0, 10)
    minus10:SetText("-10")
    minus10:SetHandler("OnClicked", function()
        ChangeValue(-10)
    end)

    local minus1 = wm:CreateControlFromVirtual(prefix .. "Minus1", parent, "ZO_DefaultButton")
    minus1:SetDimensions(70, 26)
    minus1:SetAnchor(LEFT, minus10, RIGHT, 8, 0)
    minus1:SetText("-1")
    minus1:SetHandler("OnClicked", function()
        ChangeValue(-1)
    end)

    local plus1 = wm:CreateControlFromVirtual(prefix .. "Plus1", parent, "ZO_DefaultButton")
    plus1:SetDimensions(70, 26)
    plus1:SetAnchor(LEFT, minus1, RIGHT, 16, 0)
    plus1:SetText("+1")
    plus1:SetHandler("OnClicked", function()
        ChangeValue(1)
    end)

    local plus10 = wm:CreateControlFromVirtual(prefix .. "Plus10", parent, "ZO_DefaultButton")
    plus10:SetDimensions(70, 26)
    plus10:SetAnchor(LEFT, plus1, RIGHT, 8, 0)
    plus10:SetText("+10")
    plus10:SetHandler("OnClicked", function()
        ChangeValue(10)
    end)

    local resetBtn = wm:CreateControlFromVirtual(prefix .. "Reset", parent, "ZO_DefaultButton")
    resetBtn:SetDimensions(110, 26)
    resetBtn:SetAnchor(LEFT, plus10, RIGHT, 16, 0)
    resetBtn:SetText("Réinitialiser")
    resetBtn:SetHandler("OnClicked", function()
        local profile = self:GetActiveProfile()
        profile[fieldName] = defaultValue
        RefreshOne()
    end)

    return {
        valueLabel = valueLabel,
        barFill = barFill,
        refresh = RefreshOne,
    }
end

function RPCompanion:RefreshJournalList()
    if not self.journalListContent then return end

    local content = self.journalListContent
    self:ClearListContent(content)

    local last
    local entries = self.savedVars.journal or {}

    if #entries == 0 then
        local label = WINDOW_MANAGER:CreateControl(nil, content, CT_LABEL)
        label:SetFont("ZoFontGame")
        label:SetText("Aucune entrée de journal.")
        label:SetAnchor(TOPLEFT, content, TOPLEFT, 10, 10)
        content:SetHeight(40)
        return
    end

    for i, entry in ipairs(entries) do
        local rowBg = WINDOW_MANAGER:CreateControl(nil, content, CT_BACKDROP)
        rowBg:SetDimensions(720, 70)
        rowBg:SetCenterColor(0.12, 0.12, 0.12, 0.7)
        rowBg:SetEdgeColor(0.5, 0.42, 0.28, 1)
        rowBg:SetEdgeTexture(nil, 1, 1, 1, 0)

        if not last then
            rowBg:SetAnchor(TOPLEFT, content, TOPLEFT, 10, 10)
        else
            rowBg:SetAnchor(TOPLEFT, last, BOTTOMLEFT, 0, 8)
        end

        local dateLabel = WINDOW_MANAGER:CreateControl(nil, rowBg, CT_LABEL)
        dateLabel:SetFont("ZoFontGameSmall")
        dateLabel:SetText(entry.date or "")
        dateLabel:SetAnchor(TOPLEFT, rowBg, TOPLEFT, 10, 8)

        local textLabel = WINDOW_MANAGER:CreateControl(nil, rowBg, CT_LABEL)
        textLabel:SetFont("ZoFontGame")
        textLabel:SetText(entry.text or "")
        textLabel:SetDimensions(520, 32)
        textLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        textLabel:SetVerticalAlignment(TEXT_ALIGN_TOP)
        textLabel:SetAnchor(TOPLEFT, dateLabel, BOTTOMLEFT, 0, 4)

        local deleteBtn = WINDOW_MANAGER:CreateControlFromVirtual("RPCompanionJournalDelete" .. tostring(i) .. tostring(GetFrameTimeMilliseconds() or 0), rowBg, "ZO_DefaultButton")
        deleteBtn:SetDimensions(120, 26)
        deleteBtn:SetAnchor(RIGHT, rowBg, RIGHT, -10, 0)
        deleteBtn:SetText("Supprimer")
        deleteBtn:SetHandler("OnClicked", function()
            self:DeleteJournalEntry(i)
            self:RefreshUI()
        end)

        last = rowBg
    end

    local rowCount = #entries
    content:SetHeight(math.max(100, 10 + (rowCount * 78)))
end

function RPCompanion:RefreshEncounterList()
    if not self.encounterListContent then return end

    local content = self.encounterListContent
    self:ClearListContent(content)

    local last
    local entries = self.savedVars.encounters or {}

    if #entries == 0 then
        local label = WINDOW_MANAGER:CreateControl(nil, content, CT_LABEL)
        label:SetFont("ZoFontGame")
        label:SetText("Aucune rencontre enregistrée.")
        label:SetAnchor(TOPLEFT, content, TOPLEFT, 10, 10)
        content:SetHeight(40)
        return
    end

    for i, entry in ipairs(entries) do
        local rowBg = WINDOW_MANAGER:CreateControl(nil, content, CT_BACKDROP)
        rowBg:SetDimensions(720, 86)
        rowBg:SetCenterColor(0.12, 0.12, 0.12, 0.7)
        rowBg:SetEdgeColor(0.5, 0.42, 0.28, 1)
        rowBg:SetEdgeTexture(nil, 1, 1, 1, 0)

        if not last then
            rowBg:SetAnchor(TOPLEFT, content, TOPLEFT, 10, 10)
        else
            rowBg:SetAnchor(TOPLEFT, last, BOTTOMLEFT, 0, 8)
        end

        local nameLabel = WINDOW_MANAGER:CreateControl(nil, rowBg, CT_LABEL)
        nameLabel:SetFont("ZoFontGameBold")
        nameLabel:SetText(entry.name or "")
        nameLabel:SetAnchor(TOPLEFT, rowBg, TOPLEFT, 10, 8)

        local dateLabel = WINDOW_MANAGER:CreateControl(nil, rowBg, CT_LABEL)
        dateLabel:SetFont("ZoFontGameSmall")
        dateLabel:SetText(entry.date or "")
        dateLabel:SetAnchor(TOPLEFT, nameLabel, BOTTOMLEFT, 0, 2)

        local noteLabel = WINDOW_MANAGER:CreateControl(nil, rowBg, CT_LABEL)
        noteLabel:SetFont("ZoFontGame")
        noteLabel:SetText(entry.note or "")
        noteLabel:SetDimensions(500, 36)
        noteLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        noteLabel:SetVerticalAlignment(TEXT_ALIGN_TOP)
        noteLabel:SetAnchor(TOPLEFT, dateLabel, BOTTOMLEFT, 0, 4)

        local deleteBtn = WINDOW_MANAGER:CreateControlFromVirtual("RPCompanionEncounterDelete" .. tostring(i) .. tostring(GetFrameTimeMilliseconds() or 0), rowBg, "ZO_DefaultButton")
        deleteBtn:SetDimensions(120, 26)
        deleteBtn:SetAnchor(RIGHT, rowBg, RIGHT, -10, 0)
        deleteBtn:SetText("Supprimer")
        deleteBtn:SetHandler("OnClicked", function()
            self:DeleteEncounter(i)
            self:RefreshUI()
        end)

        last = rowBg
    end

    local rowCount = #entries
    content:SetHeight(math.max(100, 10 + (rowCount * 94)))
end

function RPCompanion:RefreshProfileList()
    if not self.profileListContent then return end

    local content = self.profileListContent
    self:ClearListContent(content)

    local names = self:GetSortedProfileNames()
    local activeName = self:GetActiveProfileName()
    local last

    if #names == 0 then
        local label = WINDOW_MANAGER:CreateControl(nil, content, CT_LABEL)
        label:SetFont("ZoFontGame")
        label:SetText("Aucun profil.")
        label:SetAnchor(TOPLEFT, content, TOPLEFT, 10, 10)
        content:SetHeight(40)
        return
    end

    for index, name in ipairs(names) do
        local rowBg = WINDOW_MANAGER:CreateControl(nil, content, CT_BACKDROP)
        rowBg:SetDimensions(720, 52)
        rowBg:SetCenterColor(0.12, 0.12, 0.12, 0.7)
        rowBg:SetEdgeColor(0.5, 0.42, 0.28, 1)
        rowBg:SetEdgeTexture(nil, 1, 1, 1, 0)

        if not last then
            rowBg:SetAnchor(TOPLEFT, content, TOPLEFT, 10, 10)
        else
            rowBg:SetAnchor(TOPLEFT, last, BOTTOMLEFT, 0, 8)
        end

        local label = WINDOW_MANAGER:CreateControl(nil, rowBg, CT_LABEL)
        label:SetFont("ZoFontGameBold")
        local suffix = ""
        if name == activeName then
            suffix = " [ACTIF]"
        end
        label:SetText(name .. suffix)
        label:SetAnchor(LEFT, rowBg, LEFT, 10, 0)

        local useBtn = WINDOW_MANAGER:CreateControlFromVirtual("RPCompanionProfileUse" .. tostring(index) .. tostring(GetFrameTimeMilliseconds() or 0), rowBg, "ZO_DefaultButton")
        useBtn:SetDimensions(100, 26)
        useBtn:SetAnchor(RIGHT, rowBg, RIGHT, -140, 0)
        useBtn:SetText("Utiliser")
        useBtn:SetHandler("OnClicked", function()
            self:SetActiveProfile(name)
            self:RefreshUI()
            self:ShowTab("fiche")
        end)

        if name ~= "Principal" then
            local deleteBtn = WINDOW_MANAGER:CreateControlFromVirtual("RPCompanionProfileDelete" .. tostring(index) .. tostring(GetFrameTimeMilliseconds() or 0), rowBg, "ZO_DefaultButton")
            deleteBtn:SetDimensions(100, 26)
            deleteBtn:SetAnchor(RIGHT, rowBg, RIGHT, -20, 0)
            deleteBtn:SetText("Supprimer")
            deleteBtn:SetHandler("OnClicked", function()
                self:DeleteProfile(name)
                self:RefreshUI()
            end)
        end

        last = rowBg
    end

    local rowCount = #names
    content:SetHeight(math.max(100, 10 + (rowCount * 60)))
end

function RPCompanion:RefreshCompatibleList()
    if not self.compatibleListContent then return end

    local content = self.compatibleListContent
    self:ClearListContent(content)

    local names = {}
    for displayName, _ in pairs(self.savedVars.compatibleUsers or {}) do
        table.insert(names, displayName)
    end
    table.sort(names)

    local last

    if #names == 0 then
        local label = WINDOW_MANAGER:CreateControl(nil, content, CT_LABEL)
        label:SetFont("ZoFontGame")
        label:SetText("Aucun utilisateur compatible détecté.")
        label:SetAnchor(TOPLEFT, content, TOPLEFT, 10, 10)
        content:SetHeight(40)
        return
    end

    for i, displayName in ipairs(names) do
        local data = self.savedVars.compatibleUsers[displayName] or {}

        local rowBg = WINDOW_MANAGER:CreateControl(nil, content, CT_BACKDROP)
        rowBg:SetDimensions(720, 58)
        rowBg:SetCenterColor(0.12, 0.12, 0.12, 0.7)
        rowBg:SetEdgeColor(0.5, 0.42, 0.28, 1)
        rowBg:SetEdgeTexture(nil, 1, 1, 1, 0)

        if not last then
            rowBg:SetAnchor(TOPLEFT, content, TOPLEFT, 10, 10)
        else
            rowBg:SetAnchor(TOPLEFT, last, BOTTOMLEFT, 0, 8)
        end

        local nameLabel = WINDOW_MANAGER:CreateControl(nil, rowBg, CT_LABEL)
        nameLabel:SetFont("ZoFontGameBold")
        nameLabel:SetText(displayName)
        nameLabel:SetAnchor(TOPLEFT, rowBg, TOPLEFT, 10, 8)

        local infoLabel = WINDOW_MANAGER:CreateControl(nil, rowBg, CT_LABEL)
        infoLabel:SetFont("ZoFontGameSmall")
        infoLabel:SetText("Dernière réponse : " .. tostring(data.lastSeen or "?"))
        infoLabel:SetAnchor(TOPLEFT, nameLabel, BOTTOMLEFT, 0, 4)

        local shareBtn = WINDOW_MANAGER:CreateControlFromVirtual("RPCompanionCompatibleShare" .. tostring(i) .. tostring(GetFrameTimeMilliseconds() or 0), rowBg, "ZO_DefaultButton")
        shareBtn:SetDimensions(100, 24)
        shareBtn:SetAnchor(RIGHT, rowBg, RIGHT, -20, 0)
        shareBtn:SetText("Partager")
        shareBtn:SetHandler("OnClicked", function()
            if self.networkTargetEdit then
                self.networkTargetEdit:SetText(displayName)
            end
            self:PrepareWhisper(displayName, self:BuildProfileMessage())
        end)

        last = rowBg
    end

    local rowCount = #names
    content:SetHeight(math.max(100, 10 + (rowCount * 66)))
end

function RPCompanion:RefreshReceivedProfilesList()
    if not self.receivedListContent then return end

    local content = self.receivedListContent
    self:ClearListContent(content)

    local names = {}
    for displayName, _ in pairs(self.savedVars.receivedProfiles or {}) do
        table.insert(names, displayName)
    end
    table.sort(names)

    local last

    if #names == 0 then
        local label = WINDOW_MANAGER:CreateControl(nil, content, CT_LABEL)
        label:SetFont("ZoFontGame")
        label:SetText("Aucune fiche reçue.")
        label:SetAnchor(TOPLEFT, content, TOPLEFT, 10, 10)
        content:SetHeight(40)
        return
    end

    for i, displayName in ipairs(names) do
        local data = self.savedVars.receivedProfiles[displayName] or {}

        local rowBg = WINDOW_MANAGER:CreateControl(nil, content, CT_BACKDROP)
        rowBg:SetDimensions(720, 118)
        rowBg:SetCenterColor(0.12, 0.12, 0.12, 0.7)
        rowBg:SetEdgeColor(0.5, 0.42, 0.28, 1)
        rowBg:SetEdgeTexture(nil, 1, 1, 1, 0)

        if not last then
            rowBg:SetAnchor(TOPLEFT, content, TOPLEFT, 10, 10)
        else
            rowBg:SetAnchor(TOPLEFT, last, BOTTOMLEFT, 0, 8)
        end

        local senderLabel = WINDOW_MANAGER:CreateControl(nil, rowBg, CT_LABEL)
        senderLabel:SetFont("ZoFontGameBold")
        senderLabel:SetText(displayName .. " -> " .. tostring(data.characterName or "-"))
        senderLabel:SetAnchor(TOPLEFT, rowBg, TOPLEFT, 10, 8)

        local metaLabel = WINDOW_MANAGER:CreateControl(nil, rowBg, CT_LABEL)
        metaLabel:SetFont("ZoFontGameSmall")
        metaLabel:SetText("Profil : " .. tostring(data.profileName or "-") .. " | Reçu : " .. tostring(data.receivedAt or "?"))
        metaLabel:SetAnchor(TOPLEFT, senderLabel, BOTTOMLEFT, 0, 2)

        local detail = string.format(
            "Race: %s | Alliance: %s | Statut: %s",
            tostring(data.race or "-"),
            tostring(data.alliance or "-"),
            tostring(data.status or "-")
        )

        local detailLabel = WINDOW_MANAGER:CreateControl(nil, rowBg, CT_LABEL)
        detailLabel:SetFont("ZoFontGame")
        detailLabel:SetText(detail)
        detailLabel:SetDimensions(500, 18)
        detailLabel:SetAnchor(TOPLEFT, metaLabel, BOTTOMLEFT, 0, 4)

        local currentLabel = WINDOW_MANAGER:CreateControl(nil, rowBg, CT_LABEL)
        currentLabel:SetFont("ZoFontGameSmall")
        currentLabel:SetText("Actuellement : " .. tostring(data.current or "-"))
        currentLabel:SetDimensions(500, 18)
        currentLabel:SetAnchor(TOPLEFT, detailLabel, BOTTOMLEFT, 0, 4)

        local alignLabel = WINDOW_MANAGER:CreateControl(nil, rowBg, CT_LABEL)
        alignLabel:SetFont("ZoFontGameSmall")
        alignLabel:SetText(
            "Alignement : " ..
            self:GetLawChaosLabel(data.alignmentLawChaos or 0) .. " / " ..
            self:GetGoodEvilLabel(data.alignmentGoodEvil or 0) ..
            " | Moralité : " .. self:GetMoralityLabel(data.morality or 50)
        )
        alignLabel:SetDimensions(500, 18)
        alignLabel:SetAnchor(TOPLEFT, currentLabel, BOTTOMLEFT, 0, 4)

        local viewBtn = WINDOW_MANAGER:CreateControlFromVirtual("RPCompanionReceivedView" .. tostring(i) .. tostring(GetFrameTimeMilliseconds() or 0), rowBg, "ZO_DefaultButton")
        viewBtn:SetDimensions(100, 24)
        viewBtn:SetAnchor(RIGHT, rowBg, RIGHT, -20, 0)
        viewBtn:SetText("Voir")
        viewBtn:SetHandler("OnClicked", function()
            self.selectedReceivedProfile = displayName
            self:RefreshReceivedProfileDetail()
        end)

        last = rowBg
    end

    local rowCount = #names
    content:SetHeight(math.max(100, 10 + (rowCount * 126)))
end

function RPCompanion:RefreshReceivedProfileDetail()
    if not self.receivedDetailLabel then return end

    local key = self.selectedReceivedProfile
    if not key or not self.savedVars.receivedProfiles or not self.savedVars.receivedProfiles[key] then
        self.receivedDetailLabel:SetText("Sélectionne une fiche reçue pour voir les détails.")
        return
    end

    local data = self.savedVars.receivedProfiles[key]

    local text =
        "Expéditeur : " .. tostring(data.sender or "-") .. "\n" ..
        "Profil : " .. tostring(data.profileName or "-") .. "\n" ..
        "Nom : " .. tostring(data.characterName or "-") .. "\n" ..
        "Titre : " .. tostring(data.title or "-") .. "\n" ..
        "Race : " .. tostring(data.race or "-") .. "\n" ..
        "Alliance : " .. tostring(data.alliance or "-") .. "\n" ..
        "Statut : " .. tostring(data.status or "-") .. "\n" ..
        "Alignement Loyal/Chaotique : " .. self:GetLawChaosLabel(data.alignmentLawChaos or 0) .. " (" .. tostring(data.alignmentLawChaos or 0) .. ")\n" ..
        "Alignement Bon/Mauvais : " .. self:GetGoodEvilLabel(data.alignmentGoodEvil or 0) .. " (" .. tostring(data.alignmentGoodEvil or 0) .. ")\n" ..
        "Moralité : " .. self:GetMoralityLabel(data.morality or 50) .. " (" .. tostring(data.morality or 50) .. ")\n" ..
        "Reçu le : " .. tostring(data.receivedAt or "-") .. "\n\n" ..
        "Biographie :\n" .. tostring(data.biography or "-") .. "\n\n" ..
        "Actuellement :\n" .. tostring(data.current or "-") .. "\n\n" ..
        "Aspect :\n" .. tostring(data.appearance or "-")

    self.receivedDetailLabel:SetText(text)
end

function RPCompanion:RefreshAlignmentFields()
    if self.lawChaosScale then self.lawChaosScale.refresh() end
    if self.goodEvilScale then self.goodEvilScale.refresh() end
    if self.moralityScale then self.moralityScale.refresh() end
end

function RPCompanion:RefreshFicheFields()
    local profile = self:GetActiveProfile()

    if self.profileLabel then
        self.profileLabel:SetText("Profil actif : " .. self:GetActiveProfileName())
    end

    if self.ficheNameEdit then self.ficheNameEdit:SetText(profile.characterName or "") end
    if self.ficheTitleEdit then self.ficheTitleEdit:SetText(profile.title or "") end
    if self.ficheRaceEdit then self.ficheRaceEdit:SetText(profile.race or "") end
    if self.ficheAllianceEdit then self.ficheAllianceEdit:SetText(profile.alliance or "") end
    if self.ficheStatusEdit then self.ficheStatusEdit:SetText(profile.status or "") end
    if self.ficheBioEdit then self.ficheBioEdit:SetText(profile.biography or "") end
    if self.ficheCurrentEdit then self.ficheCurrentEdit:SetText(profile.current or "") end
    if self.ficheAppearanceEdit then self.ficheAppearanceEdit:SetText(profile.appearance or "") end
end

function RPCompanion:RefreshUI()
    if not self.window then return end

    self:RefreshFicheFields()
    self:RefreshAlignmentFields()
    self:RefreshJournalList()
    self:RefreshEncounterList()
    self:RefreshProfileList()
    self:RefreshCompatibleList()
    self:RefreshReceivedProfilesList()
    self:RefreshReceivedProfileDetail()
end

function RPCompanion:CreateUI()
    local wm = WINDOW_MANAGER

    local window = wm:CreateTopLevelWindow("RPCompanionWindow")
    window:SetDimensions(920, 880)
    window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    window:SetMovable(true)
    window:SetMouseEnabled(true)
    window:SetClampedToScreen(true)
    window:SetHidden(true)

    local bg = wm:CreateControl("RPCompanionBackground", window, CT_BACKDROP)
    bg:SetAnchorFill(window)
    bg:SetCenterColor(0.08, 0.08, 0.08, 0.93)
    bg:SetEdgeColor(0.75, 0.65, 0.45, 1)
    bg:SetEdgeTexture(nil, 2, 2, 2, 0)

    local titleBar = wm:CreateControl("RPCompanionTitleBar", window, CT_BACKDROP)
    titleBar:SetAnchor(TOPLEFT, window, TOPLEFT, 0, 0)
    titleBar:SetAnchor(TOPRIGHT, window, TOPRIGHT, 0, 0)
    titleBar:SetHeight(44)
    titleBar:SetCenterColor(0.45, 0.35, 0.22, 1)

    local title = wm:CreateControl("RPCompanionTitle", titleBar, CT_LABEL)
    title:SetFont("ZoFontWinH1")
    title:SetText("RP Companion")
    title:SetAnchor(LEFT, titleBar, LEFT, 18, 0)

    local closeBtn = wm:CreateControlFromVirtual("RPCompanionCloseButton", titleBar, "ZO_DefaultButton")
    closeBtn:SetDimensions(90, 28)
    closeBtn:SetAnchor(RIGHT, titleBar, RIGHT, -10, 0)
    closeBtn:SetText("Fermer")
    closeBtn:SetHandler("OnClicked", function()
        window:SetHidden(true)
    end)

    local profileLabel = wm:CreateControl("RPCompanionProfileLabelTop", window, CT_LABEL)
    profileLabel:SetFont("ZoFontGame")
    profileLabel:SetColor(0.95, 0.92, 0.82, 1)
    profileLabel:SetAnchor(TOPLEFT, titleBar, BOTTOMLEFT, 18, 14)
    self.profileLabel = profileLabel

    local tabBar = wm:CreateControl("RPCompanionTabBar", window, CT_CONTROL)
    tabBar:SetDimensions(880, 36)
    tabBar:SetAnchor(TOPLEFT, profileLabel, BOTTOMLEFT, 0, 12)

    local function CreateTabButton(name, text, x, key)
        local btn = wm:CreateControlFromVirtual(name, tabBar, "ZO_DefaultButton")
        btn:SetDimensions(140, 30)
        btn:SetAnchor(LEFT, tabBar, LEFT, x, 0)
        btn:SetText(text)
        btn:SetHandler("OnClicked", function()
            self:ShowTab(key)
        end)
    end

    CreateTabButton("RPCompanionTabFiche", "Fiche", 0, "fiche")
    CreateTabButton("RPCompanionTabAlignment", "Alignement", 148, "alignment")
    CreateTabButton("RPCompanionTabJournal", "Journal", 296, "journal")
    CreateTabButton("RPCompanionTabEncounters", "Rencontres", 444, "encounters")
    CreateTabButton("RPCompanionTabProfiles", "Profils", 592, "profiles")
    CreateTabButton("RPCompanionTabNetwork", "Réseau", 740, "network")

    local content = wm:CreateControl("RPCompanionContent", window, CT_CONTROL)
    content:SetDimensions(880, 740)
    content:SetAnchor(TOPLEFT, tabBar, BOTTOMLEFT, 0, 14)

    self.tabs = {}

    -- ONGLET FICHE
    local ficheTab = wm:CreateControl("RPCompanionFicheTab", content, CT_CONTROL)
    ficheTab:SetAnchorFill(content)
    self.tabs.fiche = ficheTab

    local ficheBg = wm:CreateControl("RPCompanionFicheBg", ficheTab, CT_BACKDROP)
    ficheBg:SetAnchorFill(ficheTab)
    ficheBg:SetCenterColor(0, 0, 0, 0.45)
    ficheBg:SetEdgeColor(0.55, 0.45, 0.30, 1)
    ficheBg:SetEdgeTexture(nil, 1, 1, 1, 0)

    local function CreateFieldLabel(name, text, x, y)
        local label = wm:CreateControl(name, ficheBg, CT_LABEL)
        label:SetFont("ZoFontGameBold")
        label:SetText(text)
        label:SetAnchor(TOPLEFT, ficheBg, TOPLEFT, x, y)
        return label
    end

    local function CreateFieldEdit(name, x, y, w, h, multi)
        local controlType = multi and "ZO_DefaultEditMultiLine" or "ZO_DefaultEdit"
        local edit = wm:CreateControlFromVirtual(name, ficheBg, controlType)
        edit:SetDimensions(w, h)
        edit:SetAnchor(TOPLEFT, ficheBg, TOPLEFT, x, y)
        edit:SetMouseEnabled(true)
        edit:SetHandler("OnMouseDown", function(control)
            if control.TakeFocus then
                control:TakeFocus()
            end
        end)
        return edit
    end

    CreateFieldLabel("RPCompanionFicheNameLabel", "Nom", 20, 20)
    self.ficheNameEdit = CreateFieldEdit("RPCompanionFicheNameEdit", 20, 45, 250, 28, false)

    CreateFieldLabel("RPCompanionFicheTitleLabel", "Titre", 300, 20)
    self.ficheTitleEdit = CreateFieldEdit("RPCompanionFicheTitleEdit", 300, 45, 250, 28, false)

    CreateFieldLabel("RPCompanionFicheRaceLabel", "Race", 580, 20)
    self.ficheRaceEdit = CreateFieldEdit("RPCompanionFicheRaceEdit", 580, 45, 250, 28, false)

    CreateFieldLabel("RPCompanionFicheAllianceLabel", "Alliance", 20, 90)
    self.ficheAllianceEdit = CreateFieldEdit("RPCompanionFicheAllianceEdit", 20, 115, 250, 28, false)

    CreateFieldLabel("RPCompanionFicheStatusLabel", "Statut", 300, 90)
    self.ficheStatusEdit = CreateFieldEdit("RPCompanionFicheStatusEdit", 300, 115, 250, 28, false)

    CreateFieldLabel("RPCompanionFicheBioLabel", "Biographie", 20, 165)

    local bioBg = WINDOW_MANAGER:CreateControl("RPCompanionFicheBioBG", ficheBg, CT_BACKDROP)
    bioBg:SetDimensions(810, 300)
    bioBg:SetAnchor(TOPLEFT, ficheBg, TOPLEFT, 20, 190)
    bioBg:SetCenterColor(0, 0, 0, 0.4)
    bioBg:SetEdgeColor(0.55, 0.45, 0.30, 1)
    bioBg:SetEdgeTexture(nil, 1, 1, 1, 0)

    local bioScroll = WINDOW_MANAGER:CreateControlFromVirtual("RPCompanionFicheBioScroll", bioBg, "ZO_ScrollContainer")
    bioScroll:SetAnchorFill(bioBg)

    local bioContent = bioScroll:GetNamedChild("ScrollChild")
    self.ficheBioEdit = WINDOW_MANAGER:CreateControlFromVirtual("RPCompanionFicheBioEdit", bioContent, "ZO_DefaultEditMultiLine")
    self.ficheBioEdit:SetDimensions(780, 1000)
    self.ficheBioEdit:SetAnchor(TOPLEFT, bioContent, TOPLEFT, 0, 0)
    self.ficheBioEdit:SetMouseEnabled(true)
    self.ficheBioEdit:SetMaxInputChars(5000)
    self.ficheBioEdit:SetHandler("OnMouseDown", function(control)
        if control.TakeFocus then
            control:TakeFocus()
        end
    end)

    CreateFieldLabel("RPCompanionFicheCurrentLabel", "Actuellement", 20, 510)
    self.ficheCurrentEdit = CreateFieldEdit("RPCompanionFicheCurrentEdit", 20, 535, 810, 70, true)

    CreateFieldLabel("RPCompanionFicheAppearanceLabel", "Aspect", 20, 620)
    self.ficheAppearanceEdit = CreateFieldEdit("RPCompanionFicheAppearanceEdit", 20, 645, 810, 50, true)

    local saveFicheBtn = wm:CreateControlFromVirtual("RPCompanionSaveFicheButton", ficheBg, "ZO_DefaultButton")
    saveFicheBtn:SetDimensions(220, 32)
    saveFicheBtn:SetAnchor(BOTTOM, ficheBg, BOTTOM, 0, -15)
    saveFicheBtn:SetText("Sauvegarder la fiche")
    saveFicheBtn:SetHandler("OnClicked", function()
        local function SafeGetText(control)
            if control and control.GetText then
                local ok, value = pcall(function()
                    return control:GetText()
                end)
                if ok and value then
                    return tostring(value)
                end
            end
            return ""
        end

        local profile = self:GetActiveProfile()
        if not profile then
            d("|cFF6666[RP]|r Erreur : profil introuvable.")
            return
        end

        profile.characterName = SafeGetText(self.ficheNameEdit)
        profile.title = SafeGetText(self.ficheTitleEdit)
        profile.race = SafeGetText(self.ficheRaceEdit)
        profile.alliance = SafeGetText(self.ficheAllianceEdit)
        profile.status = SafeGetText(self.ficheStatusEdit)
        profile.biography = SafeGetText(self.ficheBioEdit)
        profile.current = SafeGetText(self.ficheCurrentEdit)
        profile.appearance = SafeGetText(self.ficheAppearanceEdit)

        d("|c88FF88[RP]|r Fiche sauvegardée.")
        self:RefreshUI()
    end)

    -- ONGLET ALIGNEMENT
    local alignmentTab = wm:CreateControl("RPCompanionAlignmentTab", content, CT_CONTROL)
    alignmentTab:SetAnchorFill(content)
    alignmentTab:SetHidden(true)
    self.tabs.alignment = alignmentTab

    local alignmentBg = wm:CreateControl("RPCompanionAlignmentBg", alignmentTab, CT_BACKDROP)
    alignmentBg:SetAnchorFill(alignmentTab)
    alignmentBg:SetCenterColor(0, 0, 0, 0.45)
    alignmentBg:SetEdgeColor(0.55, 0.45, 0.30, 1)
    alignmentBg:SetEdgeTexture(nil, 1, 1, 1, 0)

    self.lawChaosScale = self:CreateAlignmentScale(
        alignmentBg,
        "RPCompanionLawChaos",
        "Loyal ↔ Chaotique",
        20, 20,
        "Loyal",
        "Chaotique",
        "alignmentLawChaos",
        -100, 100, 0,
        function(value) return self:GetLawChaosLabel(value) end
    )

    self.goodEvilScale = self:CreateAlignmentScale(
        alignmentBg,
        "RPCompanionGoodEvil",
        "Bon ↔ Mauvais",
        20, 210,
        "Bon",
        "Mauvais",
        "alignmentGoodEvil",
        -100, 100, 0,
        function(value) return self:GetGoodEvilLabel(value) end
    )

    self.moralityScale = self:CreateAlignmentScale(
        alignmentBg,
        "RPCompanionMorality",
        "Moralité",
        20, 400,
        "Très basse",
        "Exemplaire",
        "morality",
        0, 100, 50,
        function(value) return self:GetMoralityLabel(value) end
    )

    local alignmentHelp = wm:CreateControl("RPCompanionAlignmentHelp", alignmentBg, CT_LABEL)
    alignmentHelp:SetFont("ZoFontGame")
    alignmentHelp:SetDimensions(820, 140)
    alignmentHelp:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    alignmentHelp:SetVerticalAlignment(TEXT_ALIGN_TOP)
    alignmentHelp:SetAnchor(TOPLEFT, alignmentBg, TOPLEFT, 20, 560)
    alignmentHelp:SetText(
        "Ajuste ici la tendance générale de ton personnage.\n\n" ..
        "- Loyal ↔ Chaotique : rapport à l'ordre, aux codes et aux règles.\n" ..
        "- Bon ↔ Mauvais : rapport à l'altruisme, à l'empathie ou à la cruauté.\n" ..
        "- Moralité : niveau global d'éthique personnelle."
    )

    -- ONGLET JOURNAL
    local journalTab = wm:CreateControl("RPCompanionJournalTab", content, CT_CONTROL)
    journalTab:SetAnchorFill(content)
    journalTab:SetHidden(true)
    self.tabs.journal = journalTab

    local journalBg = wm:CreateControl("RPCompanionJournalBg", journalTab, CT_BACKDROP)
    journalBg:SetAnchorFill(journalTab)
    journalBg:SetCenterColor(0, 0, 0, 0.45)
    journalBg:SetEdgeColor(0.55, 0.45, 0.30, 1)
    journalBg:SetEdgeTexture(nil, 1, 1, 1, 0)

    local journalInput = wm:CreateControlFromVirtual("RPCompanionJournalInput", journalBg, "ZO_DefaultEditMultiLine")
    journalInput:SetDimensions(840, 90)
    journalInput:SetAnchor(TOPLEFT, journalBg, TOPLEFT, 20, 20)
    journalInput:SetMouseEnabled(true)
    journalInput:SetHandler("OnMouseDown", function(control)
        if control.TakeFocus then
            control:TakeFocus()
        end
    end)

    local addJournalBtn = wm:CreateControlFromVirtual("RPCompanionAddJournalButton", journalBg, "ZO_DefaultButton")
    addJournalBtn:SetDimensions(180, 30)
    addJournalBtn:SetAnchor(TOPLEFT, journalInput, BOTTOMLEFT, 0, 10)
    addJournalBtn:SetText("Ajouter au journal")
    addJournalBtn:SetHandler("OnClicked", function()
        local text = journalInput:GetText() or ""
        if text ~= "" then
            self:AddJournalEntry(text)
            journalInput:SetText("")
            self:RefreshUI()
        end
    end)

    local _, journalContent = self:CreateScrollableList(journalBg, 840, 500, addJournalBtn, "RPCompanionJournalScroll")
    self.journalListContent = journalContent

    -- ONGLET RENCONTRES
    local encountersTab = wm:CreateControl("RPCompanionEncountersTab", content, CT_CONTROL)
    encountersTab:SetAnchorFill(content)
    encountersTab:SetHidden(true)
    self.tabs.encounters = encountersTab

    local encountersBg = wm:CreateControl("RPCompanionEncountersBg", encountersTab, CT_BACKDROP)
    encountersBg:SetAnchorFill(encountersTab)
    encountersBg:SetCenterColor(0, 0, 0, 0.45)
    encountersBg:SetEdgeColor(0.55, 0.45, 0.30, 1)
    encountersBg:SetEdgeTexture(nil, 1, 1, 1, 0)

    local encounterName = wm:CreateControlFromVirtual("RPCompanionEncounterName", encountersBg, "ZO_DefaultEdit")
    encounterName:SetDimensions(320, 28)
    encounterName:SetAnchor(TOPLEFT, encountersBg, TOPLEFT, 20, 20)
    encounterName:SetMouseEnabled(true)
    encounterName:SetHandler("OnMouseDown", function(control)
        if control.TakeFocus then
            control:TakeFocus()
        end
    end)

    local encounterNote = wm:CreateControlFromVirtual("RPCompanionEncounterNote", encountersBg, "ZO_DefaultEditMultiLine")
    encounterNote:SetDimensions(840, 90)
    encounterNote:SetAnchor(TOPLEFT, encounterName, BOTTOMLEFT, 0, 12)
    encounterNote:SetMouseEnabled(true)
    encounterNote:SetHandler("OnMouseDown", function(control)
        if control.TakeFocus then
            control:TakeFocus()
        end
    end)

    local addEncounterBtn = wm:CreateControlFromVirtual("RPCompanionAddEncounterButton", encountersBg, "ZO_DefaultButton")
    addEncounterBtn:SetDimensions(180, 30)
    addEncounterBtn:SetAnchor(TOPLEFT, encounterNote, BOTTOMLEFT, 0, 10)
    addEncounterBtn:SetText("Ajouter rencontre")
    addEncounterBtn:SetHandler("OnClicked", function()
        local name = encounterName:GetText() or ""
        local note = encounterNote:GetText() or ""
        if name ~= "" then
            self:AddEncounter(name, note)
            encounterName:SetText("")
            encounterNote:SetText("")
            self:RefreshUI()
        end
    end)

    local _, encounterContent = self:CreateScrollableList(encountersBg, 840, 480, addEncounterBtn, "RPCompanionEncounterScroll")
    self.encounterListContent = encounterContent

    -- ONGLET PROFILS
    local profilesTab = wm:CreateControl("RPCompanionProfilesTab", content, CT_CONTROL)
    profilesTab:SetAnchorFill(content)
    profilesTab:SetHidden(true)
    self.tabs.profiles = profilesTab

    local profilesBg = wm:CreateControl("RPCompanionProfilesBg", profilesTab, CT_BACKDROP)
    profilesBg:SetAnchorFill(profilesTab)
    profilesBg:SetCenterColor(0, 0, 0, 0.45)
    profilesBg:SetEdgeColor(0.55, 0.45, 0.30, 1)
    profilesBg:SetEdgeTexture(nil, 1, 1, 1, 0)

    local profileNameInput = wm:CreateControlFromVirtual("RPCompanionProfileNameInput", profilesBg, "ZO_DefaultEdit")
    profileNameInput:SetDimensions(260, 28)
    profileNameInput:SetAnchor(TOPLEFT, profilesBg, TOPLEFT, 20, 20)
    profileNameInput:SetMouseEnabled(true)
    profileNameInput:SetHandler("OnMouseDown", function(control)
        if control.TakeFocus then
            control:TakeFocus()
        end
    end)

    local createProfileBtn = wm:CreateControlFromVirtual("RPCompanionCreateProfileButton", profilesBg, "ZO_DefaultButton")
    createProfileBtn:SetDimensions(160, 28)
    createProfileBtn:SetAnchor(LEFT, profileNameInput, RIGHT, 10, 0)
    createProfileBtn:SetText("Créer profil")
    createProfileBtn:SetHandler("OnClicked", function()
        local name = profileNameInput:GetText() or ""
        if name ~= "" and self:CreateProfile(name) then
            profileNameInput:SetText("")
            self:RefreshUI()
        end
    end)

    local _, profileContent = self:CreateScrollableList(profilesBg, 840, 580, profileNameInput, "RPCompanionProfileScroll")
    self.profileListContent = profileContent

    -- ONGLET RESEAU
    local networkTab = wm:CreateControl("RPCompanionNetworkTab", content, CT_CONTROL)
    networkTab:SetAnchorFill(content)
    networkTab:SetHidden(true)
    self.tabs.network = networkTab

    local networkBg = wm:CreateControl("RPCompanionNetworkBg", networkTab, CT_BACKDROP)
    networkBg:SetAnchorFill(networkTab)
    networkBg:SetCenterColor(0, 0, 0, 0.45)
    networkBg:SetEdgeColor(0.55, 0.45, 0.30, 1)
    networkBg:SetEdgeTexture(nil, 1, 1, 1, 0)

    local targetLabel = wm:CreateControl("RPCompanionNetworkTargetLabel", networkBg, CT_LABEL)
    targetLabel:SetFont("ZoFontGameBold")
    targetLabel:SetText("Cible @UserID")
    targetLabel:SetAnchor(TOPLEFT, networkBg, TOPLEFT, 20, 20)

    self.networkTargetEdit = wm:CreateControlFromVirtual("RPCompanionNetworkTargetEdit", networkBg, "ZO_DefaultEdit")
    self.networkTargetEdit:SetDimensions(260, 28)
    self.networkTargetEdit:SetAnchor(TOPLEFT, targetLabel, BOTTOMLEFT, 0, 6)
    self.networkTargetEdit:SetMouseEnabled(true)
    self.networkTargetEdit:SetHandler("OnMouseDown", function(control)
        if control.TakeFocus then
            control:TakeFocus()
        end
    end)

    local pingBtn = wm:CreateControlFromVirtual("RPCompanionNetworkPingButton", networkBg, "ZO_DefaultButton")
    pingBtn:SetDimensions(150, 28)
    pingBtn:SetAnchor(LEFT, self.networkTargetEdit, RIGHT, 10, 0)
    pingBtn:SetText("Tester addon")
    pingBtn:SetHandler("OnClicked", function()
        local target = self.networkTargetEdit:GetText() or ""
        if target ~= "" then
            self:PrepareWhisper(target, self:BuildPingMessage())
        end
    end)

    local shareBtn = wm:CreateControlFromVirtual("RPCompanionNetworkShareButton", networkBg, "ZO_DefaultButton")
    shareBtn:SetDimensions(150, 28)
    shareBtn:SetAnchor(LEFT, pingBtn, RIGHT, 10, 0)
    shareBtn:SetText("Partager ma fiche")
    shareBtn:SetHandler("OnClicked", function()
        local target = self.networkTargetEdit:GetText() or ""
        if target ~= "" then
            self:PrepareWhisper(target, self:BuildProfileMessage())
        end
    end)

    local hintLabel = wm:CreateControl("RPCompanionNetworkHint", networkBg, CT_LABEL)
    hintLabel:SetFont("ZoFontGameSmall")
    hintLabel:SetDimensions(820, 40)
    hintLabel:SetText("Le whisper est préparé automatiquement. Il faut ensuite appuyer sur Entrée pour l'envoyer.")
    hintLabel:SetAnchor(TOPLEFT, self.networkTargetEdit, BOTTOMLEFT, 0, 8)

    local compatiblesHeader = wm:CreateControl("RPCompanionCompatiblesHeader", networkBg, CT_LABEL)
    compatiblesHeader:SetFont("ZoFontGameBold")
    compatiblesHeader:SetText("Utilisateurs compatibles")
    compatiblesHeader:SetAnchor(TOPLEFT, hintLabel, BOTTOMLEFT, 0, 14)

    local _, compatibleContent = self:CreateScrollableList(networkBg, 840, 140, compatiblesHeader, "RPCompanionCompatibleScroll")
    self.compatibleListContent = compatibleContent

    local receivedHeader = wm:CreateControl("RPCompanionReceivedHeader", networkBg, CT_LABEL)
    receivedHeader:SetFont("ZoFontGameBold")
    receivedHeader:SetText("Fiches reçues")
    receivedHeader:SetAnchor(TOPLEFT, compatiblesHeader, BOTTOMLEFT, 0, 185)

    local _, receivedContent = self:CreateScrollableList(networkBg, 840, 180, receivedHeader, "RPCompanionReceivedScroll")
    self.receivedListContent = receivedContent

    local detailBg = wm:CreateControl("RPCompanionReceivedDetailBg", networkBg, CT_BACKDROP)
    detailBg:SetDimensions(840, 230)
    detailBg:SetAnchor(TOPLEFT, receivedHeader, BOTTOMLEFT, 0, 225)
    detailBg:SetCenterColor(0, 0, 0, 0.35)
    detailBg:SetEdgeColor(0.55, 0.45, 0.30, 1)
    detailBg:SetEdgeTexture(nil, 1, 1, 1, 0)

    self.receivedDetailLabel = wm:CreateControl("RPCompanionReceivedDetailLabel", detailBg, CT_LABEL)
    self.receivedDetailLabel:SetFont("ZoFontGame")
    self.receivedDetailLabel:SetDimensions(820, 210)
    self.receivedDetailLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    self.receivedDetailLabel:SetVerticalAlignment(TEXT_ALIGN_TOP)
    self.receivedDetailLabel:SetAnchor(TOPLEFT, detailBg, TOPLEFT, 10, 10)
    self.receivedDetailLabel:SetText("Sélectionne une fiche reçue pour voir les détails.")

    self.window = window
    self:ShowTab("fiche")
end

function RPCompanion:ToggleUI()
    if not self.window then return end

    local hidden = self.window:IsHidden()
    self.window:SetHidden(not hidden)

    if hidden then
        self:RefreshUI()
    end
end