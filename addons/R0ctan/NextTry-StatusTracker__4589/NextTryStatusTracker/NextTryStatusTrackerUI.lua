local NTST = NextTryStatusTracker
local wm = WINDOW_MANAGER

local function getFontPath(style)
    if style == "bold" then
        return "EsoUI/Common/Fonts/univers67.otf"
    end
    return "EsoUI/Common/Fonts/univers57.otf"
end

local function getStateKey(state)
    if state == "online" or state == "offline" then return state end
    return state and "online" or "offline"
end

function NTST:UpdateFontCache()
    self.fontCache = self.fontCache or {}
    self.blinkFontCache = self.blinkFontCache or {}
    for _, state in ipairs({ "online", "offline" }) do
        local s = self.sv.styles[state]
        local baseFont = string.format("%s|%d", getFontPath(s.fontStyle), s.fontSize)
        local shadow = state == "offline" and "|soft-shadow-thin" or ""
        self.fontCache[state] = baseFont .. shadow
        self.blinkFontCache[state] = baseFont
    end
end

function NTST:GetFontString(state)
    state = getStateKey(state)
    if not self.fontCache or not self.fontCache[state] then
        self:UpdateFontCache()
    end
    return self.fontCache[state]
end

function NTST:GetBlinkFontString(state)
    state = getStateKey(state)
    if not self.blinkFontCache or not self.blinkFontCache[state] then
        self:UpdateFontCache()
    end
    return self.blinkFontCache[state]
end

function NTST:GetStatusStyle(isOnline)
    return isOnline and self.sv.styles.online or self.sv.styles.offline
end

local function normalizeWindowAnchor(anchor)
    if anchor == "right" or anchor == "center" then return anchor end
    return "left"
end

local function getLeftFromSavedPosition(position, width)
    local anchor = normalizeWindowAnchor(position and position.anchor)
    local x = tonumber(position and position.x) or 0
    width = tonumber(width) or 0

    if anchor == "right" then
        return x - width
    elseif anchor == "center" then
        return x - (width / 2)
    end

    return x
end

local function getAnchorXFromLeft(left, width, anchor)
    anchor = normalizeWindowAnchor(anchor)
    width = tonumber(width) or 0

    if anchor == "right" then
        return left + width
    elseif anchor == "center" then
        return left + (width / 2)
    end

    return left
end

local function shouldEnableRowMouseInput()
    -- Keep row mouse input enabled for right-click context menus, unlocked dragging,
    -- and hover handler routing. Tooltip text itself is still gated by the settings.
    return true
end

function NTST:ResetPosition()
    self.sv.position = nil
    self:ApplyPosition()
end

function NTST:SavePosition()
    if not self.container or not self.sv then return end

    local left = self.container:GetLeft()
    local right = self.container:GetRight()
    local top = self.container:GetTop()
    if left == nil or right == nil or top == nil then return end

    local anchor = normalizeWindowAnchor(self.sv.windowAnchor)
    local width = right - left
    local x = getAnchorXFromLeft(left, width, anchor)

    self.sv.position = {
        x = zo_round(x),
        y = zo_round(top),
        anchor = anchor,
    }
end

function NTST:ApplyPosition()
    if not self.container then return end

    self.container:ClearAnchors()

    local position = self.sv and self.sv.position
    local anchor = normalizeWindowAnchor(self.sv and self.sv.windowAnchor)

    if type(position) == "table" then
        local width = self.container:GetWidth() or 0
        local storedAnchor = normalizeWindowAnchor(position.anchor)
        local left = getLeftFromSavedPosition(position, width)
        local x = getAnchorXFromLeft(left, width, anchor)

        if width > 0 and storedAnchor ~= anchor then
            position.x = zo_round(x)
            position.anchor = anchor
        end

        if anchor == "right" then
            self.container:SetAnchor(TOPRIGHT, GuiRoot, TOPLEFT, x, position.y)
        elseif anchor == "center" then
            self.container:SetAnchor(TOP, GuiRoot, TOPLEFT, x, position.y)
        else
            self.container:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, position.y)
        end
    else
        self.container:SetAnchor(CENTER, GuiRoot, CENTER, GuiRoot:GetWidth() * 0.25, 0)
    end
end

function NTST:AttachDragHandlers(control)
    if not control or control.nextTryTrackerDragAttached then return end
    control.nextTryTrackerDragAttached = true
    control:SetHandler("OnMouseDown", function(_, button)
        if self.sv.uiUnlocked and button == MOUSE_BUTTON_INDEX_LEFT and self.container then
            self.container:StartMoving()
        end
    end)
    control:SetHandler("OnMouseUp", function(owner, button)
        if button == MOUSE_BUTTON_INDEX_RIGHT then
            local row = owner and owner.nextTryTrackerContextRow
            if self:ShowPlayerContextMenu(owner, row) then return end
        end
        if self.sv.uiUnlocked and self.container then
            self.container:StopMovingOrResizing()
            self:SavePosition()
        end
    end)
end

function NTST:GetPlayerTooltipText(entry)
    if not (self.sv and self.sv.showHoverTooltip and entry) then return nil end

    local lines = {}
    local accountName = self.CleanPlayerText(entry.playerName)
    local isOnline = entry.isOnline == true
    local characterName = isOnline and entry.playerData and self.CleanPlayerText(entry.playerData.characterName)
    local zoneName = isOnline and entry.playerData and self.CleanPlayerText(entry.playerData.zoneName)
    local note
    local profile = entry.profile or self:GetPlayerProfile(entry.playerName)
    local classId = entry.playerData and tonumber(entry.playerData.classId) or profile and profile.lastKnownClassId
    local alliance = entry.playerData and tonumber(entry.playerData.alliance) or profile and profile.lastKnownAlliance
    local classText = isOnline and self:GetClassDisplayText(classId)
    local allianceText = isOnline and self:GetAllianceDisplayText(alliance)
    local characterIconSize = 32
    local lastSeenIconSize = 32
    local classIcon = self.Icon(self:BuildClassIconMap()[classId], characterIconSize)
    local allianceIcon = self.Icon(self.allianceIconPaths[alliance], characterIconSize)
    if entry.playerData then
        note = self.CleanPlayerText(entry.playerData.friendNote) or self.CleanPlayerText(entry.playerData.guildNote) or self.CleanPlayerText(entry.playerData.note)
    end

    if accountName then lines[#lines + 1] = accountName end
    if characterName then
        local characterLine = string.format(self.L("tooltipCharacter"), characterName)
        local characterIcons = {}
        if classIcon ~= "" then characterIcons[#characterIcons + 1] = classIcon end
        if allianceIcon ~= "" then characterIcons[#characterIcons + 1] = allianceIcon end
        if #characterIcons > 0 then
            characterLine = string.format("%s %s", characterLine, table.concat(characterIcons, " "))
        end
        lines[#lines + 1] = characterLine
    end
    if classText and classIcon == "" then lines[#lines + 1] = string.format(self.L("tooltipClass"), classText) end
    if allianceText and allianceIcon == "" then lines[#lines + 1] = string.format(self.L("tooltipAlliance"), allianceText) end
    if zoneName then lines[#lines + 1] = string.format(self.L("tooltipZone"), zoneName) end

    if self.sv.showNotesTooltip and note and note ~= "" then
        lines[#lines + 1] = ""
        lines[#lines + 1] = self.L("tooltipNoteHeader")
        lines[#lines + 1] = note
    end

    if profile then
        if profile.customNote ~= "" then
            lines[#lines + 1] = ""
            lines[#lines + 1] = self.L("tooltipTrackerNoteHeader")
            lines[#lines + 1] = profile.customNote
        end

        if not isOnline then
            local lastSeen = self:FormatLastSeen(profile.lastSeenAt)
            local lastCharacter = self.CleanPlayerText(profile.lastKnownCharacterName)
            local lastZone = self.CleanPlayerText(profile.lastKnownZone)
            if lastCharacter then
                local lastSeenClassIcon = self.Icon(self:BuildClassIconMap()[profile.lastKnownClassId], lastSeenIconSize)
                local lastSeenAllianceIcon = self.Icon(self.allianceIconPaths[profile.lastKnownAlliance], lastSeenIconSize)
                local lastSeenIcons = {}
                if lastSeenClassIcon ~= "" then lastSeenIcons[#lastSeenIcons + 1] = lastSeenClassIcon end
                if lastSeenAllianceIcon ~= "" then lastSeenIcons[#lastSeenIcons + 1] = lastSeenAllianceIcon end
                if #lastSeenIcons > 0 then
                    lastCharacter = string.format("%s %s", lastCharacter, table.concat(lastSeenIcons, " "))
                end
            end
            if type(profile.lastSeenAt) == "number" then
                if lastZone and lastCharacter then
                    lastSeen = string.format(self.L("lastSeenZoneCharacter"), lastSeen, lastZone, lastCharacter)
                elseif lastZone then
                    lastSeen = string.format(self.L("lastSeenZone"), lastSeen, lastZone)
                elseif lastCharacter then
                    lastSeen = string.format(self.L("lastSeenCharacter"), lastSeen, lastCharacter)
                end
            end
            lines[#lines + 1] = ""
            lines[#lines + 1] = string.format(self.L("tooltipLastSeen"), lastSeen)
        end

        local detailLines = {}
        local roles = {}
        for _, key in ipairs(self.roleKeys) do
            if profile.roles[key] then
                roles[#roles + 1] = self.roleIcons[key] or self.roleFallbacks[key]
            end
        end
        if #roles > 0 then detailLines[#detailLines + 1] = string.format(self.L("tooltipRoles"), table.concat(roles, " ")) end

        local tags = {}
        for _, definition in ipairs(self:GetSortedTagDefinitions()) do
            if profile.tags[definition.key] then tags[#tags + 1] = definition.name end
        end
        if #tags > 0 then detailLines[#detailLines + 1] = string.format(self.L("tooltipTags"), table.concat(tags, ", ")) end
        if #detailLines > 0 then
            lines[#lines + 1] = ""
            for _, detailLine in ipairs(detailLines) do lines[#lines + 1] = detailLine end
        end
    end

    if #lines == 0 then return nil end
    return table.concat(lines, "\n")
end

function NTST:RegisterTrackerNoteDialog()
    if self.trackerNoteDialogRegistered or not ZO_Dialogs_RegisterCustomDialog then return end
    self.trackerNoteDialogRegistered = true
    ZO_Dialogs_RegisterCustomDialog("NEXTTRY_STATUS_TRACKER_NOTE", {
        title = { text = self.L("trackerNoteDialogTitle") },
        mainText = { text = self.L("trackerNoteDialogText") },
        editBox = { defaultText = "", maxInputCharacters = 500 },
        setup = function(dialog, data)
            local editBox = dialog and dialog:GetNamedChild("EditBox")
            if editBox then editBox:SetText(data and data.note or "") end
        end,
        buttons = {
            {
                text = SI_DIALOG_ACCEPT,
                callback = function(dialog)
                    local data = dialog and dialog.data
                    if data and data.playerName then
                        self:SetPlayerCustomNote(data.playerName, ZO_Dialogs_GetEditBoxText and ZO_Dialogs_GetEditBoxText(dialog) or "")
                        self:Refresh(true)
                    end
                end,
            },
            { text = SI_DIALOG_CANCEL },
        },
    })
end

function NTST:ShowTrackerNoteDialog(playerName)
    if not ZO_Dialogs_ShowDialog then return end
    self:RegisterTrackerNoteDialog()
    local profile = self:GetPlayerProfile(playerName)
    ZO_Dialogs_ShowDialog("NEXTTRY_STATUS_TRACKER_NOTE", { playerName = playerName, note = profile and profile.customNote or "" })
end

function NTST:ShowPlayerTooltip(control, row)
    if not row or not row.tooltipText or row.tooltipText == "" or not InformationTooltip then return end
    InitializeTooltip(InformationTooltip, control, RIGHT, 6, 0, LEFT)
    SetTooltipText(InformationTooltip, row.tooltipText)
end

function NTST:HidePlayerTooltip()
    if InformationTooltip then ClearTooltip(InformationTooltip) end
end

local function getMenuText(stringId, fallback)
    if stringId and GetString then
        local text = GetString(stringId)
        if text and text ~= "" then return text end
    end
    return fallback
end

function NTST:ShowPlayerContextMenu(control, row)
    if not row or not row.entry or not ClearMenu or not AddMenuItem or not ShowMenu then return false end

    local accountName = self.CleanPlayerText(row.entry.playerName)
    if not accountName then return false end

    local playerData = row.entry.playerData or {}
    local source = playerData.source
    local characterName = self.CleanPlayerText(playerData.characterName)
    local isFriend = source == "friend" or (IsFriend and IsFriend(accountName))
    local canUseGuildTravel = source == "guild" and playerData.guildId ~= nil

    ClearMenu()

    if StartChatInput and CHAT_CHANNEL_WHISPER then
        AddMenuItem(getMenuText(SI_SOCIAL_LIST_SEND_MESSAGE, self.L("contextWhisper")), function()
            StartChatInput("", CHAT_CHANNEL_WHISPER, accountName)
        end)
    end

    local inviteName = characterName or accountName
    if TryGroupInviteByName and IsGroupModificationAvailable and IsGroupModificationAvailable() then
        AddMenuItem(getMenuText(SI_SOCIAL_MENU_INVITE, self.L("contextInviteGroup")), function()
            local NOT_SENT_FROM_CHAT = false
            local DISPLAY_INVITED_MESSAGE = true
            TryGroupInviteByName(inviteName, NOT_SENT_FROM_CHAT, DISPLAY_INVITED_MESSAGE)
        end)
    elseif GroupInviteByName then
        AddMenuItem(getMenuText(SI_SOCIAL_MENU_INVITE, self.L("contextInviteGroup")), function()
            GroupInviteByName(inviteName)
        end)
    end

    if isFriend and JumpToFriend then
        AddMenuItem(getMenuText(SI_SOCIAL_MENU_JUMP_TO_PLAYER, self.L("contextTravelToPlayer")), function()
            JumpToFriend(accountName)
        end)
    elseif canUseGuildTravel and JumpToGuildMember then
        AddMenuItem(getMenuText(SI_SOCIAL_MENU_JUMP_TO_PLAYER, self.L("contextTravelToPlayer")), function()
            JumpToGuildMember(accountName)
        end)
    end

    if MAIL_SEND and MAIL_SEND.ComposeMailTo then
        AddMenuItem(getMenuText(SI_SOCIAL_MENU_SEND_MAIL, self.L("contextSendMail")), function()
            if IsUnitDead and IsUnitDead("player") then
                if ZO_AlertEvent and EVENT_UI_ERROR and SI_CANNOT_DO_THAT_WHILE_DEAD then
                    ZO_AlertEvent(EVENT_UI_ERROR, SI_CANNOT_DO_THAT_WHILE_DEAD)
                end
                return
            end
            MAIL_SEND:ComposeMailTo(accountName)
        end)
    end

    if isFriend and ZO_Dialogs_ShowDialog and FRIENDS_LIST_MANAGER and FRIENDS_LIST_MANAGER.GetNoteEditedFunction then
        AddMenuItem(getMenuText(SI_SOCIAL_MENU_EDIT_NOTE, self.L("contextEditNote")), function()
            local note = self.CleanPlayerText(playerData.friendNote) or (source == "friend" and self.CleanPlayerText(playerData.note)) or ""
            local dialogParams = {
                displayName = accountName,
                note = note,
                changedCallback = FRIENDS_LIST_MANAGER:GetNoteEditedFunction(),
            }
            ZO_Dialogs_ShowDialog("EDIT_NOTE", dialogParams)
        end)
    end

    AddMenuItem(self.L("contextEditTrackerNote"), function()
        self:ShowTrackerNoteDialog(accountName)
    end)

    local profile = self:GetPlayerProfile(accountName)
    local notificationKey = profile and profile.notificationEnabled and "contextDisableNotifications" or "contextEnableNotifications"
    AddMenuItem(self.L(notificationKey), function()
        self:SetPlayerNotificationEnabled(accountName, not (profile and profile.notificationEnabled))
    end)

    AddMenuItem("-", function() end)
    AddMenuItem(self.L("contextRemoveFromTracker"), function()
        self:RemovePlayer(accountName)
    end)

    ShowMenu(control)
    return true
end


function NTST:AttachTooltipHandlers(control, row)
    if not control or control.nextTryTrackerTooltipAttached then return end
    control.nextTryTrackerTooltipAttached = true
    control:SetHandler("OnMouseEnter", function(owner) self:ShowPlayerTooltip(owner, row) end)
    control:SetHandler("OnMouseExit", function() self:HidePlayerTooltip() end)
end

function NTST:ApplyMouseStateToRows()
    if not self.rows then return end
    local enabled = shouldEnableRowMouseInput()
    for _, row in ipairs(self.rows) do
        row:SetMouseEnabled(enabled)
        if row.bg then row.bg:SetMouseEnabled(enabled) end
        if row.roleLabel then row.roleLabel:SetMouseEnabled(enabled) end
        if row.label then row.label:SetMouseEnabled(enabled) end
    end
end

function NTST:ApplyWindowVisual()
    if not self.containerBg then return end
    local display = self.sv.display
    local bg = display.backgroundColor
    local border = self.sv.uiUnlocked and display.unlockedBorderColor or display.borderColor
    local borderAlpha = self.sv.uiUnlocked and (border.a or 0.45) or (border.a or 0)
    local edgeSize = (self.sv.uiUnlocked or borderAlpha > 0) and 2 or 0

    self.containerBg:SetCenterColor(bg.r, bg.g, bg.b, bg.a)
    self.containerBg:SetEdgeColor(border.r, border.g, border.b, edgeSize > 0 and borderAlpha or 0)
    self.containerBg:SetEdgeTexture("", 8, 8, edgeSize)
end

function NTST:CreateSceneFragment()
    self.fragment = nil
end

function NTST:ShouldShowWindow()
    if NextTryShared and NextTryShared.WindowVisibility and NextTryShared.WindowVisibility.ShouldShowWindow then
        return NextTryShared.WindowVisibility.ShouldShowWindow(self)
    end
    return self.sv and self.sv.visible ~= false
end

function NTST:ApplyVisibility()
    if NextTryShared and NextTryShared.WindowVisibility and NextTryShared.WindowVisibility.ApplyVisibility then
        NextTryShared.WindowVisibility.ApplyVisibility(self)
    end
end

function NTST:RegisterSceneVisibilityCallbacks()
    if NextTryShared and NextTryShared.WindowVisibility and NextTryShared.WindowVisibility.RegisterSceneCallbacks then
        NextTryShared.WindowVisibility.RegisterSceneCallbacks(self)
    end
end

function NTST:SetSettingsPreview(active)
    self.settingsPreviewActive = active and true or false
    self:ApplyVisibility()
    if self:ShouldShowWindow() then
        self:Refresh(true)
    end
end

function NTST:SetUnlocked(unlocked)
    self.sv.uiUnlocked = unlocked and true or false
    if not self.container then return end
    self.container:SetMovable(self.sv.uiUnlocked)
    self.container:SetMouseEnabled(self.sv.uiUnlocked)
    self.container:SetClampedToScreen(true)
    if self.containerBg then self.containerBg:SetMouseEnabled(self.sv.uiUnlocked) end
    self:ApplyMouseStateToRows()
    self:ApplyWindowVisual()
end

function NTST:CreateUI()
    if self.container then return end

    local c = wm:CreateTopLevelWindow("NextTryStatusTrackerWindow")
    c:SetResizeToFitDescendents(false)
    c:SetClampedToScreen(true)
    c:SetDrawTier(DT_MEDIUM)
    c:SetDrawLayer(DL_CONTROLS)
    c:SetMouseEnabled(self.sv.uiUnlocked)
    c:SetMovable(self.sv.uiUnlocked)
    self:AttachDragHandlers(c)
    c:SetHandler("OnMoveStop", function() self:SavePosition() end)

    c.bg = wm:CreateControl("NextTryStatusTrackerWindowBg", c, CT_BACKDROP)
    c.bg:SetAnchorFill(c)
    c.bg:SetInsets(0, 0, 0, 0)
    c.bg:SetMouseEnabled(self.sv.uiUnlocked)
    self:AttachDragHandlers(c.bg)

    self.container = c
    self.window = c
    self.containerBg = c.bg
    self.rows = {}
    self.lastOnline = {}

    self:CreateSceneFragment()
    self:UpdateFontCache()
    self:ApplyVisibility()
    self:ApplyWindowVisual()
    self:ApplyPosition()
end

function NTST:ApplyRowVisual(row, isOnline)
    if not (row and row.label and row.bg) then return end
    local state = isOnline and "online" or "offline"
    local s = self:GetStatusStyle(isOnline)

    row.label:SetFont(self:GetFontString(state))
    row.label:SetColor(s.fontColor.r, s.fontColor.g, s.fontColor.b, s.fontColor.a)
    if row.roleLabel then
        row.roleLabel:SetFont(self:GetFontString(state))
        row.roleLabel:SetColor(s.fontColor.r, s.fontColor.g, s.fontColor.b, s.fontColor.a)
    end
    row.bg:SetCenterColor(s.backgroundColor.r, s.backgroundColor.g, s.backgroundColor.b, s.backgroundColor.a)
    row.bg:SetEdgeColor(s.backgroundColor.r, s.backgroundColor.g, s.backgroundColor.b, s.backgroundColor.a)
    if row.blinkBg then row.blinkBg:SetAlpha(0) end
end

function NTST:CreateRow(index)
    local row = wm:CreateControl("NextTryStatusTrackerRow" .. index, self.container, CT_CONTROL)
    row.nextTryTrackerContextRow = row
    row:SetDimensions(10, 10)
    local mouseEnabled = shouldEnableRowMouseInput()
    row:SetMouseEnabled(mouseEnabled)
    self:AttachDragHandlers(row)
    self:AttachTooltipHandlers(row, row)

    row.bg = wm:CreateControl("NextTryStatusTrackerRowBg" .. index, row, CT_BACKDROP)
    row.bg.nextTryTrackerContextRow = row
    row.bg:SetAnchorFill(row)
    row.bg:SetEdgeTexture("", 1, 1, 0)
    row.bg:SetInsets(0, 0, 0, 0)
    row.bg:SetMouseEnabled(mouseEnabled)
    self:AttachDragHandlers(row.bg)
    self:AttachTooltipHandlers(row.bg, row)

    row.blinkBg = wm:CreateControl("NextTryStatusTrackerRowBlinkBg" .. index, row, CT_BACKDROP)
    row.blinkBg:SetAnchorFill(row)
    row.blinkBg:SetEdgeTexture("", 1, 1, 0)
    row.blinkBg:SetInsets(0, 0, 0, 0)
    row.blinkBg:SetAlpha(0)

    row.roleLabel = wm:CreateControl("NextTryStatusTrackerRowRoleLabel" .. index, row, CT_LABEL)
    row.roleLabel.nextTryTrackerContextRow = row
    row.roleLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    row.roleLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    row.roleLabel:SetMouseEnabled(mouseEnabled)
    self:AttachDragHandlers(row.roleLabel)
    self:AttachTooltipHandlers(row.roleLabel, row)

    row.label = wm:CreateControl("NextTryStatusTrackerRowLabel" .. index, row, CT_LABEL)
    row.label.nextTryTrackerContextRow = row
    row.label:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    row.label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    row.label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    row.label:SetMouseEnabled(mouseEnabled)
    self:AttachDragHandlers(row.label)
    self:AttachTooltipHandlers(row.label, row)

    return row
end

function NTST:HasVisibleRoleMarkers(entries)
    if not (self.sv and self.sv.showDisplayRoleMarker) then return false end
    for _, entry in ipairs(entries or {}) do
        if entry.roleMarker and entry.roleMarker ~= "" then return true end
    end
    return false
end

function NTST:GetRoleColumnWidth(entries, roleColumnActive)
    if not roleColumnActive then return 0 end
    local width = 0
    for _, entry in ipairs(entries or {}) do
        local state = entry.isOnline and "online" or "offline"
        width = math.max(width, self:GetRoleMarkerIconSize(state) + 6)
    end
    return width
end

function NTST:GetEstimatedRowSize(row, isOnline, roleColumnWidth)
    local state = isOnline and "online" or "offline"
    local style = self.sv.styles[state]
    local fontSize = style.fontSize or 16
    local labelPadding = 8
    local verticalPadding = 5
    local roleColumnRightBalance = roleColumnWidth > 0 and roleColumnWidth or 0

    row.label:SetFont(self:GetFontString(state))
    row.label:SetWidth(2000)

    local measuredWidth = row.label:GetTextWidth() or 0
    local measuredHeight = row.label:GetTextHeight() or 0
    local roleIconSize = self:GetRoleMarkerIconSize(state)
    local width = math.max(1, zo_ceil(measuredWidth + (labelPadding * 2) + roleColumnWidth + roleColumnRightBalance))
    local height = math.max(fontSize + (verticalPadding * 2), measuredHeight + (verticalPadding * 2), roleIconSize + 4, 24)

    return width, height, labelPadding, roleColumnWidth, roleColumnRightBalance, roleIconSize
end

function NTST:LayoutRows(entries)
    local previous
    local maxWidth = 1
    local totalHeight = 0
    local totalWidth = 0
    local display = self.sv.display
    local padding = 0
    local rowGap = zo_clamp(zo_floor(display.rowGap or 0), 0, 50)
    local groupGap = zo_clamp(zo_floor(display.groupGap or 0), 0, 100)
    local roleColumnActive = self:HasVisibleRoleMarkers(entries)
    local roleColumnWidth = self:GetRoleColumnWidth(entries, roleColumnActive)

    for i, row in ipairs(self.rows) do
        row:ClearAnchors()
        row:SetHidden(i > #entries)
        if i <= #entries then
            local entry = entries[i]
            local width, height, labelPadding, rowRoleColumnWidth, roleColumnRightBalance = self:GetEstimatedRowSize(row, entry.isOnline, roleColumnWidth)
            local gap = previous and rowGap or 0
            if entry.groupBreakBefore then gap = gap + groupGap end

            row:SetDimensions(width, height)
            row.label:ClearAnchors()
            row.label:SetAnchor(LEFT, row, LEFT, labelPadding + rowRoleColumnWidth, 0)
            row.label:SetDimensions(math.max(width - (labelPadding * 2) - rowRoleColumnWidth - roleColumnRightBalance, 1), height)
            row.roleLabel:ClearAnchors()
            row.roleLabel:SetAnchor(LEFT, row, LEFT, labelPadding, 0)
            row.roleLabel:SetDimensions(rowRoleColumnWidth, height)
            row.roleLabel:SetHidden(rowRoleColumnWidth == 0)

            if self.sv.layout == "horizontal" then
                if previous then
                    row:SetAnchor(LEFT, previous, RIGHT, gap, 0)
                else
                    row:SetAnchor(TOPLEFT, self.container, TOPLEFT, padding, padding)
                end
                totalWidth = totalWidth + width + gap
                totalHeight = math.max(totalHeight, height)
            else
                if previous then
                    row:SetAnchor(TOPLEFT, previous, BOTTOMLEFT, 0, gap)
                else
                    row:SetAnchor(TOPLEFT, self.container, TOPLEFT, padding, padding)
                end
                maxWidth = math.max(maxWidth, width)
                totalHeight = totalHeight + height + gap
            end
            previous = row
        end
    end

    if self.sv.layout ~= "horizontal" then
        for i, row in ipairs(self.rows) do
            if i <= #entries then
                row:SetWidth(maxWidth)
                local roleColumnRightBalance = roleColumnWidth > 0 and roleColumnWidth or 0
                row.label:SetWidth(math.max(maxWidth - 16 - roleColumnWidth - roleColumnRightBalance, 1))
            end
        end
        totalWidth = maxWidth
    end

    local newWidth = math.max(totalWidth + (padding * 2), 1)
    local newHeight = math.max(totalHeight + (padding * 2), 1)
    self.container:SetDimensions(newWidth, newHeight)
    self:ApplyPosition()
    self:ApplyWindowVisual()
end

local function copyPlayerData(data)
    if type(data) ~= "table" then return data end
    local copy = {}
    for key, value in pairs(data) do
        copy[key] = value
    end
    return copy
end

local function copyEntry(entry)
    if type(entry) ~= "table" then return nil end
    return {
        playerName = entry.playerName,
        playerData = copyPlayerData(entry.playerData),
        isOnline = entry.isOnline,
        displayName = entry.displayName,
        filteredOut = entry.filteredOut,
        temporaryVisibleForBlink = entry.temporaryVisibleForBlink,
        groupBreakBefore = entry.groupBreakBefore,
        profile = entry.profile,
        roleMarker = entry.roleMarker,
    }
end

function NTST:BuildEntriesForStableBlink(allEntries, statusTransitions, blinkEnabled)
    local finalByName = {}
    local finalVisible = {}
    local hasBlinkTransition = false

    for _, entry in ipairs(allEntries) do
        local transition = statusTransitions[entry.playerName]
        local keepForOfflineBlink = transition and transition.blink and blinkEnabled and entry.filteredOut and transition.oldOnline == true and entry.isOnline == false
        if keepForOfflineBlink then
            transition.hideAfterBlink = true
        end

        if not entry.filteredOut or keepForOfflineBlink then
            entry.temporaryVisibleForBlink = keepForOfflineBlink
            finalByName[entry.playerName] = entry
            finalVisible[#finalVisible + 1] = entry
        end

        if transition and transition.blink then
            hasBlinkTransition = true
        end
    end

    if not hasBlinkTransition or not self.lastVisibleEntries then
        return finalVisible, false
    end

    local entries = {}
    local used = {}

    for _, oldEntry in ipairs(self.lastVisibleEntries) do
        local entry = finalByName[oldEntry.playerName]
        local transition = statusTransitions[oldEntry.playerName]
        if entry then
            local stableEntry
            if transition and transition.blink then
                stableEntry = copyEntry(oldEntry) or copyEntry(entry) or entry
                stableEntry.filteredOut = false
                stableEntry.temporaryVisibleForBlink = entry.temporaryVisibleForBlink
            else
                stableEntry = entry
            end
            stableEntry.groupBreakBefore = oldEntry.groupBreakBefore
            entries[#entries + 1] = stableEntry
            used[entry.playerName] = true
        end
    end

    for _, entry in ipairs(finalVisible) do
        if not used[entry.playerName] then
            entries[#entries + 1] = entry
            used[entry.playerName] = true
        end
    end

    return entries, true
end

function NTST:Refresh(initial)
    if self.blinkInProgress then
        self.refreshAfterBlink = true
        self.pendingInitialAfterBlink = self.pendingInitialAfterBlink or initial == true
        return
    end

    if not self.container then return end
    self:ApplyVisibility()

    local allEntries = self:GetDisplayEntries(true)
    local statusTransitions = {}
    local shouldPlaySound = false
    local blinkEnabled = self.sv.statusBlinkEnabled ~= false

    for _, entry in ipairs(allEntries) do
        local previousStatus = self.lastOnline[entry.playerName]
        self.lastOnline[entry.playerName] = entry.isOnline

        local statusChanged = previousStatus ~= nil and previousStatus ~= entry.isOnline and not initial
        if statusChanged then
            local notificationEnabled = not entry.profile or entry.profile.notificationEnabled ~= false
            statusTransitions[entry.playerName] = {
                oldOnline = previousStatus,
                newOnline = entry.isOnline,
                blink = blinkEnabled and notificationEnabled,
                hideAfterBlink = false,
            }
            if notificationEnabled then shouldPlaySound = true end
        end
    end

    local entries, stableBlinkLayout = self:BuildEntriesForStableBlink(allEntries, statusTransitions, blinkEnabled)

    if self.sv.groupByStatus and not stableBlinkLayout then
        local previousStatus
        for i, entry in ipairs(entries) do
            entry.groupBreakBefore = i > 1 and previousStatus ~= entry.isOnline
            previousStatus = entry.isOnline
        end
    end

    local transitions = {}
    local blinkTransitionCount = 0

    for i, entry in ipairs(entries) do
        local row = self.rows[i]
        if not row then
            row = self:CreateRow(i)
            self.rows[i] = row
        end

        if row.playerName ~= entry.playerName then
            row.blinkToken = (row.blinkToken or 0) + 1
        end

        row.playerName = entry.playerName
        row.entry = entry
        row.tooltipText = self:GetPlayerTooltipText(entry)
        row.label:SetText(entry.displayName)
        local roleState = entry.isOnline and "online" or "offline"
        row.roleLabel:SetText(self:GetDisplayRoleMarker(entry.playerName, self:GetRoleMarkerIconSize(roleState)) or "")
        row:SetHidden(false)

        local statusTransition = statusTransitions[entry.playerName]
        local transition = {
            row = row,
            oldOnline = statusTransition and statusTransition.oldOnline or entry.isOnline,
            newOnline = statusTransition and statusTransition.newOnline or entry.isOnline,
            blink = statusTransition and statusTransition.blink or false,
            hideAfterBlink = statusTransition and statusTransition.hideAfterBlink or false,
        }

        if transition.blink then
            blinkTransitionCount = blinkTransitionCount + 1
        end

        transitions[i] = transition
    end

    for i = #entries + 1, #self.rows do
        local row = self.rows[i]
        row.blinkToken = (row.blinkToken or 0) + 1
        row.playerName = nil
        row.entry = nil
        row.tooltipText = nil
        row:SetHidden(true)
    end

    self:LayoutRows(entries)

    if shouldPlaySound then
        self:PlayStatusSound()
    end

    local pendingBlinkTransitions = blinkTransitionCount

    local function completeBlinkSequence()
        local pendingInitial = self.pendingInitialAfterBlink == true
        self.blinkInProgress = false
        self.refreshAfterBlink = false
        self.pendingInitialAfterBlink = false
        self:Refresh(pendingInitial)
    end

    local function finishBlink(row, hideAfterBlink)
        if hideAfterBlink and row then
            row:SetHidden(true)
        end

        pendingBlinkTransitions = pendingBlinkTransitions - 1
        if pendingBlinkTransitions <= 0 then
            completeBlinkSequence()
        end
    end

    if blinkTransitionCount > 0 then
        self.blinkInProgress = true
        self.refreshAfterBlink = false
        self.pendingInitialAfterBlink = false
    end

    for _, transition in ipairs(transitions) do
        if transition.blink then
            self:BlinkThenApply(transition.row, transition.oldOnline, transition.newOnline, function(row)
                finishBlink(row, transition.hideAfterBlink)
            end)
        else
            self:ApplyRowVisual(transition.row, transition.newOnline)
            if transition.hideAfterBlink then
                transition.row:SetHidden(true)
            end
        end
    end

    if blinkTransitionCount == 0 then
        self.lastVisibleEntries = {}
        for i, entry in ipairs(entries) do
            self.lastVisibleEntries[i] = copyEntry(entry)
        end
    end
end
