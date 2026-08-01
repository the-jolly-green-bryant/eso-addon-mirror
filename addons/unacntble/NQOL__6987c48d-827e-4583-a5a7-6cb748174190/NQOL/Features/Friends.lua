NQOL = NQOL or {}
NQOL.Features = NQOL.Features or {}

local Friends = {}

local EVENT_NAMESPACE = "NQOL_Friends"
local DEFAULT_WIDTH = 460
local WIDTH_MIN = 220
local WIDTH_MAX = 900
local DEFAULT_FONT_SIZE = 28
local FONT_SIZE_MIN = 14
local FONT_SIZE_MAX = 44
local DEFAULT_MAX_ROWS = 8
local MAX_ROWS_MIN = 1
local MAX_ROWS_MAX = 25
local BACKGROUND_OPACITY_MIN = 0
local BACKGROUND_OPACITY_MAX = 100
local BORDER_SIZE_MIN = 0
local BORDER_SIZE_MAX = 6
local BORDER_TEXTURE_SIZE = 8
local DEFAULT_HEADER_COLOR = { 0.42, 0.88, 1, 1 }
local DEFAULT_TEXT_COLOR = { 1, 1, 1, 0.95 }
local DRAW_LEVEL = 30
local PADDING = 12
local ROW_GAP_BASELINE = 3
local ROW_GAP_FONT_SCALE = 0.2
local TITLE_GAP = 6
local DIVIDER_GAP = 8
local DIVIDER_HEIGHT = 1
local DETAIL_GAP_BASELINE = 2
local DETAIL_GAP_FONT_SCALE = 0.2
local ICON_SIZE = 22
local STATUS_ICON_OFFSET_Y = 4
local TEXTURE_WHITE = "EsoUI/Art/Miscellaneous/white.dds"
local GAMEPLAY_SCENES = {
    hud = true,
    siegeBar = true,
}

local defaults = {
    friends = {
        enabled = false,
        showInSettings = true,
        horizontalPosition = 100,
        verticalPosition = 18,
        width = DEFAULT_WIDTH,
        maxRows = DEFAULT_MAX_ROWS,
        font = NQOL.Util.GetDefaultFont(),
        fontSize = DEFAULT_FONT_SIZE,
        backgroundOpacity = 90,
        borderSize = 0,
        headerColor = { 0.42, 0.88, 1, 1 },
        textColor = { 1, 1, 1, 0.95 },
        showCharacterName = true,
        showZone = true,
        showStatusIcon = true,
    },
}

local savedVariables
local initialized = false
local settingsPanelVisible = false
local eventsRegistered = false
local sceneCallbackInstalled = false
local refreshQueued = false
local control
local background
local header
local counter
local divider
local emptyLabel
local rowControls = {}
local fontStringCache = {}
local friendCharacterCache = {}

local Clamp = NQOL.Util.Clamp
local Round = NQOL.Util.Round

local function CopyColor(color)
    return { color[1], color[2], color[3], color[4] }
end

local function NormalizeColor(value, defaultColor)
    if type(value) ~= "table" then
        return CopyColor(defaultColor)
    end

    return {
        Clamp(tonumber(value[1]) or defaultColor[1], 0, 1),
        Clamp(tonumber(value[2]) or defaultColor[2], 0, 1),
        Clamp(tonumber(value[3]) or defaultColor[3], 0, 1),
        Clamp(tonumber(value[4]) or defaultColor[4], 0, 1),
    }
end

local function MoveControlAbove(target, drawLevel)
    if not target then
        return
    end

    if target.SetDrawLayer and DL_OVERLAY then
        target:SetDrawLayer(DL_OVERLAY)
    end
    if target.SetDrawTier and DT_HIGH then
        target:SetDrawTier(DT_HIGH)
    end
    if target.SetDrawLevel then
        target:SetDrawLevel(drawLevel or DRAW_LEVEL)
    end
end

local function GetSettings()
    local settings = NQOL.Settings.GetSection(savedVariables, defaults, "friends")

    NQOL.Settings.Boolean(settings, defaults.friends, "enabled")
    NQOL.Settings.Boolean(settings, defaults.friends, "showInSettings")
    NQOL.Settings.Boolean(settings, defaults.friends, "showCharacterName")
    NQOL.Settings.Boolean(settings, defaults.friends, "showZone")
    NQOL.Settings.Boolean(settings, defaults.friends, "showStatusIcon")
    NQOL.Settings.ClampedNumber(settings, defaults.friends, "horizontalPosition", 0, 100)
    NQOL.Settings.ClampedNumber(settings, defaults.friends, "verticalPosition", 0, 100)
    NQOL.Settings.ClampedNumber(settings, defaults.friends, "width", WIDTH_MIN, WIDTH_MAX, true)
    NQOL.Settings.ClampedNumber(settings, defaults.friends, "maxRows", MAX_ROWS_MIN, MAX_ROWS_MAX, true)
    NQOL.Settings.ClampedNumber(settings, defaults.friends, "fontSize", FONT_SIZE_MIN, FONT_SIZE_MAX, true)
    NQOL.Settings.ClampedNumber(settings, defaults.friends, "backgroundOpacity", BACKGROUND_OPACITY_MIN, BACKGROUND_OPACITY_MAX, true)
    NQOL.Settings.ClampedNumber(settings, defaults.friends, "borderSize", BORDER_SIZE_MIN, BORDER_SIZE_MAX, true)
    if not NQOL.Util.IsFontChoice(settings.font) then
        settings.font = defaults.friends.font
    end
    settings.headerColor = NormalizeColor(settings.headerColor, DEFAULT_HEADER_COLOR)
    settings.textColor = NormalizeColor(settings.textColor, DEFAULT_TEXT_COLOR)

    return settings
end

local function IsGameplaySceneShowing()
    if not SCENE_MANAGER or not SCENE_MANAGER.GetCurrentScene then
        return true
    end

    local scene = SCENE_MANAGER:GetCurrentScene()
    if not scene or not scene.GetName then
        return true
    end

    return GAMEPLAY_SCENES[scene:GetName()] == true
end

local function ShouldShow()
    local settings = GetSettings()
    if settingsPanelVisible and settings.showInSettings == true then
        return true
    end

    return settings.enabled == true and IsGameplaySceneShowing()
end

local function GetFontSize(sizeOffset)
    return Clamp(GetSettings().fontSize + (sizeOffset or 0), FONT_SIZE_MIN, FONT_SIZE_MAX + 6)
end

local function GetFont(sizeOffset)
    local settings = GetSettings()
    local fontSize = GetFontSize(sizeOffset)
    local key = tostring(settings.font) .. ":" .. tostring(fontSize)
    if not fontStringCache[key] then
        fontStringCache[key] = NQOL.Util.CreateFontString(settings.font, fontSize, "ZoFontGamepad22")
    end

    return fontStringCache[key]
end

local function GetScaledGap(baseline, fontScale)
    return baseline + Round(GetSettings().fontSize * fontScale)
end

local function GetRowGap()
    return GetScaledGap(ROW_GAP_BASELINE, ROW_GAP_FONT_SCALE)
end

local function GetDetailGap()
    return GetScaledGap(DETAIL_GAP_BASELINE, DETAIL_GAP_FONT_SCALE)
end

local function GetRowHeight()
    return Clamp(GetFontSize(0) + GetFontSize(-6) + GetDetailGap(), 24, 96)
end

local function GetNameOnlyRowHeight()
    return Clamp(GetSettings().fontSize + 2, ICON_SIZE, 48)
end

local function ApplyBorder()
    if not background then
        return
    end

    local borderSize = GetSettings().borderSize
    if borderSize <= 0 then
        background:SetEdgeColor(1, 1, 1, 0)
        background:SetEdgeTexture("", 1, 1, 1)
        return
    end

    background:SetEdgeColor(1, 1, 1, 0.18)
    background:SetEdgeTexture("", BORDER_TEXTURE_SIZE, BORDER_TEXTURE_SIZE, borderSize)
end

local function EnsureControls()
    if control or not WINDOW_MANAGER or not GuiRoot then
        return
    end

    control = WINDOW_MANAGER:CreateTopLevelWindow("NQOLFriends")
    control:SetHidden(true)
    MoveControlAbove(control, DRAW_LEVEL)

    background = WINDOW_MANAGER:CreateControl(nil, control, CT_BACKDROP)
    background:SetAnchorFill(control)
    background:SetEdgeTexture("", 1, 1, 1)
    MoveControlAbove(background, DRAW_LEVEL)

    header = WINDOW_MANAGER:CreateControl(nil, control, CT_LABEL)
    header:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    header:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    MoveControlAbove(header, DRAW_LEVEL + 1)

    counter = WINDOW_MANAGER:CreateControl(nil, control, CT_LABEL)
    counter:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    counter:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    MoveControlAbove(counter, DRAW_LEVEL + 1)

    divider = WINDOW_MANAGER:CreateControl(nil, control, CT_TEXTURE)
    MoveControlAbove(divider, DRAW_LEVEL + 1)

    emptyLabel = WINDOW_MANAGER:CreateControl(nil, control, CT_LABEL)
    emptyLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    emptyLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    MoveControlAbove(emptyLabel, DRAW_LEVEL + 1)

end

local function GetRowControl(index)
    local row = rowControls[index]
    if row then
        return row
    end

    row = WINDOW_MANAGER:CreateControl(nil, control, CT_CONTROL)
    row.icon = WINDOW_MANAGER:CreateControl(nil, row, CT_TEXTURE)
    row.icon:SetDimensions(ICON_SIZE, ICON_SIZE)
    MoveControlAbove(row.icon, DRAW_LEVEL + 2)

    row.name = WINDOW_MANAGER:CreateControl(nil, row, CT_LABEL)
    row.name:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    row.name:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    if row.name.SetWrapMode and TEXT_WRAP_MODE_ELLIPSIS then
        row.name:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    end
    MoveControlAbove(row.name, DRAW_LEVEL + 1)

    row.detail = WINDOW_MANAGER:CreateControl(nil, row, CT_LABEL)
    row.detail:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    row.detail:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    if row.detail.SetWrapMode and TEXT_WRAP_MODE_ELLIPSIS then
        row.detail:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    end
    MoveControlAbove(row.detail, DRAW_LEVEL + 1)

    rowControls[index] = row
    return row
end

local function GetScreenDimensions()
    local width = GuiRoot and GuiRoot.GetWidth and GuiRoot:GetWidth() or 1920
    local height = GuiRoot and GuiRoot.GetHeight and GuiRoot:GetHeight() or 1080
    return width, height
end

local function ApplyPosition()
    if not control then
        return
    end

    local settings = GetSettings()
    local screenWidth, screenHeight = GetScreenDimensions()
    local width = settings.width
    local height = control:GetHeight()
    local x = (screenWidth - width) * (settings.horizontalPosition / 100)
    local y = (screenHeight - height) * (settings.verticalPosition / 100)

    control:ClearAnchors()
    control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
end

local function GetPlayerStatusIcon(status)
    if ZO_GetGamepadPlayerStatusIcon then
        return ZO_GetGamepadPlayerStatusIcon(status)
    end
    if ZO_GetPlayerStatusIcon then
        return ZO_GetPlayerStatusIcon(status)
    end

    return TEXTURE_WHITE
end

local function FormatDisplayName(displayName)
    if ZO_FormatUserFacingDisplayName then
        return ZO_FormatUserFacingDisplayName(displayName)
    end

    return displayName or ""
end

local function FormatCharacterName(characterName)
    if not characterName or characterName == "" then
        return ""
    end
    if ZO_CachedStrFormat and SI_UNIT_NAME then
        return ZO_CachedStrFormat(SI_UNIT_NAME, characterName)
    end
    if zo_strformat then
        return zo_strformat("<<1>>", characterName)
    end

    return characterName
end

local function FormatZoneName(zoneName)
    if not zoneName or zoneName == "" then
        return ""
    end
    if ZO_CachedStrFormat and SI_ZONE_NAME then
        return ZO_CachedStrFormat(SI_ZONE_NAME, zoneName)
    end
    if zo_strformat then
        return zo_strformat("<<1>>", zoneName)
    end

    return zoneName
end

local function HasText(value)
    return type(value) == "string" and value ~= ""
end

local function NormalizeDisplayName(displayName)
    if not HasText(displayName) then
        return ""
    end

    local normalized = displayName
    if UndecorateDisplayName then
        normalized = UndecorateDisplayName(normalized)
    end
    if zo_strlower then
        return zo_strlower(normalized)
    end

    return string.lower(normalized)
end

local function DisplayNamesMatch(left, right)
    return NormalizeDisplayName(left) == NormalizeDisplayName(right)
end

local function CharacterNamesMatch(left, right)
    if not HasText(left) or not HasText(right) then
        return false
    end

    local formattedLeft = FormatCharacterName(left)
    local formattedRight = FormatCharacterName(right)
    if zo_strlower then
        return zo_strlower(formattedLeft) == zo_strlower(formattedRight)
    end

    return string.lower(formattedLeft) == string.lower(formattedRight)
end

local function CacheFriendCharacter(displayName, characterName, zoneName)
    if not HasText(displayName) or (not HasText(characterName) and not HasText(zoneName)) then
        return
    end

    for cachedDisplayName in pairs(friendCharacterCache) do
        if cachedDisplayName ~= displayName and DisplayNamesMatch(cachedDisplayName, displayName) then
            friendCharacterCache[cachedDisplayName] = nil
        end
    end

    friendCharacterCache[displayName] = {
        characterName = characterName or "",
        zoneName = zoneName or "",
    }
end

local function ClearFriendCharacter(displayName)
    if not HasText(displayName) then
        return
    end

    friendCharacterCache[displayName] = nil
    for cachedDisplayName in pairs(friendCharacterCache) do
        if DisplayNamesMatch(cachedDisplayName, displayName) then
            friendCharacterCache[cachedDisplayName] = nil
        end
    end
end

local function GetCachedFriendCharacter(displayName)
    local cached = friendCharacterCache[displayName]
    if cached then
        return cached
    end

    for cachedDisplayName, cachedDetails in pairs(friendCharacterCache) do
        if DisplayNamesMatch(cachedDisplayName, displayName) then
            return cachedDetails
        end
    end

    return nil
end

local function MergeFriendDetails(characterName, zoneName, candidateCharacterName, candidateZoneName)
    local candidateHasCharacter = HasText(candidateCharacterName)
    local candidateHasZone = HasText(candidateZoneName)
    if not candidateHasCharacter and not candidateHasZone then
        return characterName, zoneName
    end

    if not HasText(characterName) then
        characterName = candidateCharacterName or ""
        if not HasText(zoneName) then
            zoneName = candidateZoneName or ""
        end
    elseif not candidateHasCharacter or CharacterNamesMatch(characterName, candidateCharacterName) then
        if not HasText(zoneName) then
            zoneName = candidateZoneName or ""
        end
    end

    return characterName, zoneName
end

local function GetDirectFriendDetails(friendIndex)
    if not GetFriendCharacterInfo then
        return "", ""
    end

    local hasCharacter, characterName, zoneName = GetFriendCharacterInfo(friendIndex)
    if hasCharacter then
        return characterName or "", zoneName or ""
    end

    return "", ""
end

local function GetGroupFriendDetails(displayName)
    if not GetGroupSize or not GetGroupUnitTagByIndex or not GetUnitDisplayName then
        return "", ""
    end

    for groupIndex = 1, GetGroupSize() do
        local unitTag = GetGroupUnitTagByIndex(groupIndex)
        if unitTag and DisplayNamesMatch(GetUnitDisplayName(unitTag), displayName) then
            if not IsUnitOnline or IsUnitOnline(unitTag) then
                local characterName = GetUnitName and GetUnitName(unitTag) or ""
                local zoneName = GetUnitZone and GetUnitZone(unitTag) or ""
                return characterName or "", zoneName or ""
            end
        end
    end

    return "", ""
end

local function FindGuildMemberIndex(guildId, displayName)
    if not GetGuildMemberIndexFromDisplayName then
        return nil
    end

    local memberIndex = GetGuildMemberIndexFromDisplayName(guildId, displayName)
    if memberIndex then
        return memberIndex
    end

    if UndecorateDisplayName then
        local undecoratedName = UndecorateDisplayName(displayName)
        if undecoratedName ~= displayName then
            memberIndex = GetGuildMemberIndexFromDisplayName(guildId, undecoratedName)
            if memberIndex then
                return memberIndex
            end
        end
    end

    if DecorateDisplayName then
        local decoratedName = DecorateDisplayName(displayName)
        if decoratedName ~= displayName then
            return GetGuildMemberIndexFromDisplayName(guildId, decoratedName)
        end
    end

    return nil
end

local function GetGuildFriendDetails(displayName)
    if not GetNumGuilds or not GetGuildId or not GetGuildMemberCharacterInfo then
        return "", ""
    end

    for guildIndex = 1, GetNumGuilds() do
        local guildId = GetGuildId(guildIndex)
        local memberIndex = guildId and FindGuildMemberIndex(guildId, displayName)
        if memberIndex then
            local hasCharacter, characterName, zoneName = GetGuildMemberCharacterInfo(guildId, memberIndex)
            if hasCharacter then
                return characterName or "", zoneName or ""
            end
        end
    end

    return "", ""
end

local function GetManagedFriendDetails(displayName)
    if not FRIENDS_LIST_MANAGER or not FRIENDS_LIST_MANAGER.FindDataByDisplayName then
        return "", ""
    end

    local data = FRIENDS_LIST_MANAGER:FindDataByDisplayName(displayName)
    if not data or data.online == false then
        return "", ""
    end

    local zoneName = data.formattedZone
    if not HasText(zoneName) then
        zoneName = data.zone
    end

    return data.characterName or "", zoneName or ""
end

local function HasRequestedDetails(characterName, zoneName, needsCharacter, needsZone)
    return (not needsCharacter or HasText(characterName)) and (not needsZone or HasText(zoneName))
end

local function ResolveFriendDetails(friendIndex, displayName, needsCharacter, needsZone)
    local characterName, zoneName = GetDirectFriendDetails(friendIndex)
    if not HasRequestedDetails(characterName, zoneName, needsCharacter, needsZone) then
        characterName, zoneName = MergeFriendDetails(characterName, zoneName, GetGroupFriendDetails(displayName))
    end

    local cached = GetCachedFriendCharacter(displayName)
    if cached and not HasRequestedDetails(characterName, zoneName, needsCharacter, needsZone) then
        characterName, zoneName = MergeFriendDetails(characterName, zoneName, cached.characterName, cached.zoneName)
    end

    if not HasRequestedDetails(characterName, zoneName, needsCharacter, needsZone) then
        characterName, zoneName = MergeFriendDetails(characterName, zoneName, GetGuildFriendDetails(displayName))
    end
    if not HasRequestedDetails(characterName, zoneName, needsCharacter, needsZone) then
        characterName, zoneName = MergeFriendDetails(characterName, zoneName, GetManagedFriendDetails(displayName))
    end

    CacheFriendCharacter(displayName, characterName, zoneName)
    return characterName, zoneName
end

local function BuildFriendRows()
    local rows = {}
    if not GetNumFriends or not GetFriendInfo then
        return rows
    end

    local settings = GetSettings()
    local detailsEnabled = settings.showCharacterName == true or settings.showZone == true
    for friendIndex = 1, GetNumFriends() do
        local displayName, _, status = GetFriendInfo(friendIndex)
        if status and status ~= PLAYER_STATUS_OFFLINE then
            local characterName, zoneName = "", ""
            if detailsEnabled then
                characterName, zoneName = ResolveFriendDetails(
                    friendIndex,
                    displayName,
                    settings.showCharacterName == true,
                    settings.showZone == true
                )
            end

            rows[#rows + 1] = {
                displayName = FormatDisplayName(displayName),
                characterName = FormatCharacterName(characterName),
                zoneName = FormatZoneName(zoneName),
                status = status,
            }
        end
    end

    table.sort(rows, function(left, right)
        return (left.displayName or "") < (right.displayName or "")
    end)

    return rows
end

local function BuildDetailText(friend)
    local settings = GetSettings()
    local parts = {}

    if settings.showCharacterName == true and settings.showZone == true then
        local characterName = friend.characterName ~= "" and friend.characterName or NQOL.L("features.friends.character_unavailable")
        local zoneName = friend.zoneName ~= "" and friend.zoneName or NQOL.L("features.friends.zone_unavailable")

        if friend.characterName == "" and friend.zoneName == "" then
            return NQOL.L("features.friends.details_unavailable")
        end

        return characterName .. " - " .. zoneName
    end

    if settings.showCharacterName == true then
        parts[#parts + 1] = friend.characterName ~= "" and friend.characterName or NQOL.L("features.friends.character_unavailable")
    end
    if settings.showZone == true then
        parts[#parts + 1] = friend.zoneName ~= "" and friend.zoneName or NQOL.L("features.friends.zone_unavailable")
    end

    return table.concat(parts, " - ")
end

local function HideUnusedRows(startIndex)
    for index = startIndex, #rowControls do
        rowControls[index]:SetHidden(true)
    end
end

local function Render()
    EnsureControls()
    if not control then
        return
    end

    if not ShouldShow() then
        control:SetHidden(true)
        return
    end

    local settings = GetSettings()
    local rows = BuildFriendRows()
    local rowHeight = GetRowHeight()
    local nameOnlyRowHeight = GetNameOnlyRowHeight()
    local rowGap = GetRowGap()
    local detailGap = GetDetailGap()
    local visibleRows = math.min(#rows, settings.maxRows)
    local headerHeight = rowHeight + 4
    local contentRows = math.max(visibleRows, 1)
    local hasDetailsEnabled = settings.showCharacterName == true or settings.showZone == true
    local contentRowHeight = hasDetailsEnabled and rowHeight or nameOnlyRowHeight
    local contentTop = PADDING + headerHeight + TITLE_GAP + DIVIDER_HEIGHT + DIVIDER_GAP
    local height = contentTop + (contentRows * contentRowHeight) + ((contentRows - 1) * rowGap) + PADDING

    control:SetDimensions(settings.width, height)
    background:SetCenterColor(0, 0, 0, settings.backgroundOpacity / 100)
    ApplyBorder()

    header:SetFont(GetFont(2))
    header:SetText(NQOL.L("features.friends.friends_c11d5e1"))
    header:SetColor(settings.headerColor[1], settings.headerColor[2], settings.headerColor[3], settings.headerColor[4])
    header:ClearAnchors()
    header:SetAnchor(TOPLEFT, control, TOPLEFT, PADDING, PADDING)
    header:SetDimensions(settings.width - (PADDING * 2), headerHeight)

    counter:SetFont(GetFont(-3))
    counter:SetText(NQOL.L("features.friends.online_count", #rows))
    counter:SetColor(settings.headerColor[1], settings.headerColor[2], settings.headerColor[3], settings.headerColor[4])
    counter:ClearAnchors()
    counter:SetAnchor(TOPRIGHT, control, TOPRIGHT, -PADDING, PADDING)
    counter:SetDimensions(settings.width - (PADDING * 2), headerHeight)

    divider:SetColor(settings.headerColor[1], settings.headerColor[2], settings.headerColor[3], settings.headerColor[4] * 0.28)
    divider:SetDimensions(settings.width - (PADDING * 2), DIVIDER_HEIGHT)
    divider:ClearAnchors()
    divider:SetAnchor(TOPLEFT, control, TOPLEFT, PADDING, PADDING + headerHeight + TITLE_GAP)

    if visibleRows == 0 then
        emptyLabel:SetFont(GetFont(-3))
        emptyLabel:SetText(NQOL.L("features.friends.no_friends_online_ed23789"))
        emptyLabel:SetColor(settings.textColor[1], settings.textColor[2], settings.textColor[3], settings.textColor[4] * 0.72)
        emptyLabel:ClearAnchors()
        emptyLabel:SetAnchor(TOPLEFT, control, TOPLEFT, PADDING, contentTop)
        emptyLabel:SetDimensions(settings.width - (PADDING * 2), contentRowHeight)
        emptyLabel:SetHidden(false)
        HideUnusedRows(1)
    else
        emptyLabel:SetHidden(true)
        for index = 1, visibleRows do
            local row = GetRowControl(index)
            local friend = rows[index]
            local detailText = BuildDetailText(friend)
            local activeRowHeight = detailText == "" and nameOnlyRowHeight or rowHeight
            local y = contentTop + ((index - 1) * (contentRowHeight + rowGap))
            local nameWidth = settings.width - (PADDING * 2)
            local nameLeft = 0

            row:ClearAnchors()
            row:SetAnchor(TOPLEFT, control, TOPLEFT, PADDING, y)
            row:SetDimensions(settings.width - (PADDING * 2), activeRowHeight)

            row.icon:SetHidden(settings.showStatusIcon ~= true)
            if settings.showStatusIcon == true then
                row.icon:SetTexture(GetPlayerStatusIcon(friend.status))
                row.icon:SetColor(settings.headerColor[1], settings.headerColor[2], settings.headerColor[3], settings.headerColor[4])
                row.icon:ClearAnchors()
                row.icon:SetAnchor(RIGHT, row.name, LEFT, -8, STATUS_ICON_OFFSET_Y)
                nameLeft = ICON_SIZE + 8
                nameWidth = nameWidth - nameLeft
            end

            row.name:SetFont(GetFont(0))
            row.name:SetText(friend.displayName)
            row.name:SetColor(settings.textColor[1], settings.textColor[2], settings.textColor[3], settings.textColor[4])
            row.name:ClearAnchors()
            row.name:SetAnchor(TOPLEFT, row, TOPLEFT, nameLeft, 0)
            row.name:SetDimensions(nameWidth, detailText == "" and activeRowHeight or GetFontSize(0))

            row.detail:SetFont(GetFont(-6))
            row.detail:SetText(detailText)
            row.detail:SetColor(settings.textColor[1], settings.textColor[2], settings.textColor[3], settings.textColor[4] * 0.72)
            row.detail:ClearAnchors()
            row.detail:SetAnchor(BOTTOMLEFT, row, BOTTOMLEFT, nameLeft, 0)
            row.detail:SetDimensions(nameWidth, math.max(GetFontSize(-6), activeRowHeight - GetFontSize(0) - detailGap))
            row.detail:SetHidden(detailText == "")

            row:SetHidden(false)
        end
        HideUnusedRows(visibleRows + 1)
    end

    ApplyPosition()
    control:SetHidden(false)
end

local function QueueRender()
    if refreshQueued then
        return
    end

    refreshQueued = true
    if zo_callLater then
        zo_callLater(function()
            refreshQueued = false
            Render()
        end, 0)
    else
        refreshQueued = false
        Render()
    end
end

local function OnFriendRemoved(_, displayName)
    ClearFriendCharacter(displayName)
    QueueRender()
end

local function OnFriendPlayerStatusChanged(_, displayName, characterName, oldStatus, newStatus)
    if newStatus == PLAYER_STATUS_OFFLINE then
        ClearFriendCharacter(displayName)
    elseif HasText(characterName) then
        local cached = GetCachedFriendCharacter(displayName)
        if oldStatus == PLAYER_STATUS_OFFLINE or not cached or not CharacterNamesMatch(cached.characterName, characterName) then
            CacheFriendCharacter(displayName, characterName, "")
        end
    end

    QueueRender()
end

local function OnFriendCharacterUpdated(_, displayName)
    ClearFriendCharacter(displayName)
    QueueRender()
end

local function OnFriendCharacterZoneChanged(_, displayName, characterName, zoneName)
    CacheFriendCharacter(displayName, characterName, zoneName)
    QueueRender()
end

local function OnFriendDisplayNameChanged(_, oldDisplayName, newDisplayName)
    local cached = GetCachedFriendCharacter(oldDisplayName)
    ClearFriendCharacter(oldDisplayName)
    if cached and HasText(newDisplayName) then
        friendCharacterCache[newDisplayName] = cached
    end
    QueueRender()
end

local function IsOnlineFriend(displayName)
    if not HasText(displayName) or not GetNumFriends or not GetFriendInfo then
        return false
    end

    for friendIndex = 1, GetNumFriends() do
        local friendDisplayName, _, status = GetFriendInfo(friendIndex)
        if status ~= PLAYER_STATUS_OFFLINE and DisplayNamesMatch(friendDisplayName, displayName) then
            return true
        end
    end

    return false
end

local function OnGuildFriendDataChanged(_, guildId, displayName)
    if IsOnlineFriend(displayName) then
        ClearFriendCharacter(displayName)
        QueueRender()
    end
end

local function OnGroupMemberJoined(_, characterName, displayName)
    ClearFriendCharacter(displayName)
    QueueRender()
end

local function OnGroupMemberLeft(_, characterName, reason, isLocalPlayer, isLeader, displayName)
    ClearFriendCharacter(displayName)
    QueueRender()
end

local function OnGroupMemberStatusChanged(_, unitTag)
    if GetUnitDisplayName then
        ClearFriendCharacter(GetUnitDisplayName(unitTag))
    end
    QueueRender()
end

local function OnGroupMemberAccountChanged(_, unitTag, displayName)
    ClearFriendCharacter(displayName)
    QueueRender()
end

local function OnGroupZoneUpdated(_, unitTag)
    local isGroupUnit = ZO_Group_IsGroupUnitTag and ZO_Group_IsGroupUnitTag(unitTag)
    if not isGroupUnit and type(unitTag) == "string" then
        isGroupUnit = string.sub(unitTag, 1, 5) == "group"
    end

    if isGroupUnit then
        QueueRender()
    end
end

local function RegisterEvents()
    if eventsRegistered or not EVENT_MANAGER then
        return
    end

    eventsRegistered = true
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE .. "_SocialLoaded", EVENT_SOCIAL_DATA_LOADED, QueueRender)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE .. "_FriendAdded", EVENT_FRIEND_ADDED, OnFriendCharacterUpdated)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE .. "_FriendRemoved", EVENT_FRIEND_REMOVED, OnFriendRemoved)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE .. "_FriendStatus", EVENT_FRIEND_PLAYER_STATUS_CHANGED, OnFriendPlayerStatusChanged)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE .. "_FriendCharacter", EVENT_FRIEND_CHARACTER_UPDATED, OnFriendCharacterUpdated)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE .. "_FriendZone", EVENT_FRIEND_CHARACTER_ZONE_CHANGED, OnFriendCharacterZoneChanged)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE .. "_FriendName", EVENT_FRIEND_DISPLAY_NAME_CHANGED, OnFriendDisplayNameChanged)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE .. "_GuildCharacter", EVENT_GUILD_MEMBER_CHARACTER_UPDATED, OnGuildFriendDataChanged)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE .. "_GuildZone", EVENT_GUILD_MEMBER_CHARACTER_ZONE_CHANGED, OnGuildFriendDataChanged)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE .. "_GuildStatus", EVENT_GUILD_MEMBER_PLAYER_STATUS_CHANGED, OnGuildFriendDataChanged)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE .. "_GroupJoined", EVENT_GROUP_MEMBER_JOINED, OnGroupMemberJoined)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE .. "_GroupLeft", EVENT_GROUP_MEMBER_LEFT, OnGroupMemberLeft)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE .. "_GroupStatus", EVENT_GROUP_MEMBER_CONNECTED_STATUS, OnGroupMemberStatusChanged)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE .. "_GroupAccount", EVENT_GROUP_MEMBER_ACCOUNT_NAME_UPDATED, OnGroupMemberAccountChanged)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE .. "_GroupZone", EVENT_ZONE_UPDATE, OnGroupZoneUpdated)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE .. "_Activated", EVENT_PLAYER_ACTIVATED, QueueRender)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE .. "_ScreenResized", EVENT_SCREEN_RESIZED, Render)
end

local function UnregisterEvents()
    if not eventsRegistered or not EVENT_MANAGER then
        return
    end

    eventsRegistered = false
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE .. "_SocialLoaded", EVENT_SOCIAL_DATA_LOADED)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE .. "_FriendAdded", EVENT_FRIEND_ADDED)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE .. "_FriendRemoved", EVENT_FRIEND_REMOVED)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE .. "_FriendStatus", EVENT_FRIEND_PLAYER_STATUS_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE .. "_FriendCharacter", EVENT_FRIEND_CHARACTER_UPDATED)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE .. "_FriendZone", EVENT_FRIEND_CHARACTER_ZONE_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE .. "_FriendName", EVENT_FRIEND_DISPLAY_NAME_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE .. "_GuildCharacter", EVENT_GUILD_MEMBER_CHARACTER_UPDATED)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE .. "_GuildZone", EVENT_GUILD_MEMBER_CHARACTER_ZONE_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE .. "_GuildStatus", EVENT_GUILD_MEMBER_PLAYER_STATUS_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE .. "_GroupJoined", EVENT_GROUP_MEMBER_JOINED)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE .. "_GroupLeft", EVENT_GROUP_MEMBER_LEFT)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE .. "_GroupStatus", EVENT_GROUP_MEMBER_CONNECTED_STATUS)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE .. "_GroupAccount", EVENT_GROUP_MEMBER_ACCOUNT_NAME_UPDATED)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE .. "_GroupZone", EVENT_ZONE_UPDATE)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE .. "_Activated", EVENT_PLAYER_ACTIVATED)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE .. "_ScreenResized", EVENT_SCREEN_RESIZED)
    friendCharacterCache = {}
end

local function InstallSceneCallback()
    if sceneCallbackInstalled or not SCENE_MANAGER or not SCENE_MANAGER.RegisterCallback then
        return
    end

    sceneCallbackInstalled = true
    SCENE_MANAGER:RegisterCallback("SceneStateChanged", function()
        if ShouldShow() then
            RegisterEvents()
            QueueRender()
        else
            if control then
                control:SetHidden(true)
            end
        end
    end)
end

local function UpdateRuntime()
    InstallSceneCallback()
    if ShouldShow() then
        Friends.Initialize()
        RegisterEvents()
        QueueRender()
    else
        if GetSettings().enabled ~= true and not settingsPanelVisible then
            UnregisterEvents()
        end
        if control then
            control:SetHidden(true)
        end
    end
end

function Friends.InitializeSavedVariables()
    savedVariables = NQOL.Settings.NewAccountWide(defaults)
    GetSettings()
end

function Friends.Initialize()
    if initialized then
        return
    end

    local settings = GetSettings()
    if settings.enabled ~= true and not (settingsPanelVisible and settings.showInSettings == true) then
        return
    end

    initialized = true
    EnsureControls()
    InstallSceneCallback()
    RegisterEvents()
    QueueRender()
end

function Friends.GetEnabled() return GetSettings().enabled end
function Friends.GetEnabledDefault() return defaults.friends.enabled end
function Friends.SetEnabled(value) GetSettings().enabled = value == true; UpdateRuntime() end
function Friends.GetShowInSettings() return GetSettings().showInSettings end
function Friends.GetShowInSettingsDefault() return defaults.friends.showInSettings end
function Friends.SetShowInSettings(value) GetSettings().showInSettings = value == true; UpdateRuntime() end
function Friends.GetHorizontalPosition() return GetSettings().horizontalPosition end
function Friends.SetHorizontalPosition(value) GetSettings().horizontalPosition = Clamp(value, 0, 100); ApplyPosition() end
function Friends.GetVerticalPosition() return GetSettings().verticalPosition end
function Friends.SetVerticalPosition(value) GetSettings().verticalPosition = Clamp(value, 0, 100); ApplyPosition() end
function Friends.GetWidth() return GetSettings().width end
function Friends.SetWidth(value) GetSettings().width = Clamp(Round(value), WIDTH_MIN, WIDTH_MAX); Render() end
function Friends.GetMaxRows() return GetSettings().maxRows end
function Friends.SetMaxRows(value) GetSettings().maxRows = Clamp(Round(value), MAX_ROWS_MIN, MAX_ROWS_MAX); Render() end
function Friends.GetFont() return GetSettings().font end
function Friends.SetFont(value) if not NQOL.Util.IsFontChoice(value) then value = NQOL.Util.GetDefaultFont() end GetSettings().font = value; Render() end
function Friends.GetFontChoices() return NQOL.Util.GetFontChoices() end
function Friends.GetFontChoiceNames() return NQOL.Util.GetFontChoiceNames() end
function Friends.GetFontSize() return GetSettings().fontSize end
function Friends.SetFontSize(value) GetSettings().fontSize = Clamp(Round(value), FONT_SIZE_MIN, FONT_SIZE_MAX); Render() end
function Friends.GetBackgroundOpacity() return GetSettings().backgroundOpacity end
function Friends.SetBackgroundOpacity(value) GetSettings().backgroundOpacity = Clamp(Round(value), BACKGROUND_OPACITY_MIN, BACKGROUND_OPACITY_MAX); Render() end
function Friends.GetBorderSize() return GetSettings().borderSize end
function Friends.SetBorderSize(value) GetSettings().borderSize = Clamp(Round(value), BORDER_SIZE_MIN, BORDER_SIZE_MAX); Render() end
function Friends.GetHeaderColor() local color = GetSettings().headerColor return color[1], color[2], color[3], color[4] end
function Friends.SetHeaderColor(red, green, blue, alpha) GetSettings().headerColor = { red, green, blue, alpha or 1 }; Render() end
function Friends.GetTextColor() local color = GetSettings().textColor return color[1], color[2], color[3], color[4] end
function Friends.SetTextColor(red, green, blue, alpha) GetSettings().textColor = { red, green, blue, alpha or 1 }; Render() end
function Friends.GetShowCharacterName() return GetSettings().showCharacterName end
function Friends.SetShowCharacterName(value) GetSettings().showCharacterName = value == true; Render() end
function Friends.GetShowZone() return GetSettings().showZone end
function Friends.SetShowZone(value) GetSettings().showZone = value == true; Render() end
function Friends.GetShowStatusIcon() return GetSettings().showStatusIcon end
function Friends.SetShowStatusIcon(value) GetSettings().showStatusIcon = value == true; Render() end
function Friends.SetSettingsPanelVisible(value) settingsPanelVisible = value == true; UpdateRuntime() end

function Friends.GetWidthMin() return WIDTH_MIN end
function Friends.GetWidthMax() return WIDTH_MAX end
function Friends.GetMaxRowsMin() return MAX_ROWS_MIN end
function Friends.GetMaxRowsMax() return MAX_ROWS_MAX end
function Friends.GetFontSizeMin() return FONT_SIZE_MIN end
function Friends.GetFontSizeMax() return FONT_SIZE_MAX end
function Friends.GetBackgroundOpacityMin() return BACKGROUND_OPACITY_MIN end
function Friends.GetBackgroundOpacityMax() return BACKGROUND_OPACITY_MAX end
function Friends.GetBorderSizeMin() return BORDER_SIZE_MIN end
function Friends.GetBorderSizeMax() return BORDER_SIZE_MAX end

function Friends.GetEntryLabel() return NQOL.L("features.friends.entry_label") end
function Friends.GetEntryTooltip() return NQOL.L("features.friends.entry_tooltip") end
function Friends.GetEnabledLabel() return NQOL.L("features.friends.enabled_label") end
function Friends.GetEnabledTooltip() return NQOL.L("features.friends.enabled_tooltip") end
function Friends.GetShowInSettingsLabel() return NQOL.L("features.friends.show_in_settings_label") end
function Friends.GetShowInSettingsTooltip() return NQOL.L("features.friends.show_in_settings_tooltip") end
function Friends.GetHorizontalPositionLabel() return NQOL.L("features.friends.horizontal_position_label") end
function Friends.GetHorizontalPositionTooltip() return NQOL.L("features.friends.horizontal_position_tooltip") end
function Friends.GetVerticalPositionLabel() return NQOL.L("features.friends.vertical_position_label") end
function Friends.GetVerticalPositionTooltip() return NQOL.L("features.friends.vertical_position_tooltip") end
function Friends.GetWidthLabel() return NQOL.L("features.friends.width_label") end
function Friends.GetWidthTooltip() return NQOL.L("features.friends.width_tooltip") end
function Friends.GetMaxRowsLabel() return NQOL.L("features.friends.max_rows_label") end
function Friends.GetMaxRowsTooltip() return NQOL.L("features.friends.max_rows_tooltip") end
function Friends.GetFontLabel() return NQOL.L("features.friends.font_label") end
function Friends.GetFontTooltip() return NQOL.L("features.friends.font_tooltip") end
function Friends.GetFontSizeLabel() return NQOL.L("features.friends.font_size_label") end
function Friends.GetFontSizeTooltip() return NQOL.L("features.friends.font_size_tooltip") end
function Friends.GetBackgroundOpacityLabel() return NQOL.L("features.friends.background_opacity_label") end
function Friends.GetBackgroundOpacityTooltip() return NQOL.L("features.friends.background_opacity_tooltip") end
function Friends.GetBorderSizeLabel() return NQOL.L("features.friends.border_size_label") end
function Friends.GetBorderSizeTooltip() return NQOL.L("features.friends.border_size_tooltip") end
function Friends.GetHeaderColorLabel() return NQOL.L("features.friends.header_color_label") end
function Friends.GetHeaderColorTooltip() return NQOL.L("features.friends.header_color_tooltip") end
function Friends.GetTextColorLabel() return NQOL.L("features.friends.text_color_label") end
function Friends.GetTextColorTooltip() return NQOL.L("features.friends.text_color_tooltip") end
function Friends.GetShowCharacterNameLabel() return NQOL.L("features.friends.show_character_name_label") end
function Friends.GetShowCharacterNameTooltip() return NQOL.L("features.friends.show_character_name_tooltip") end
function Friends.GetShowZoneLabel() return NQOL.L("features.friends.show_zone_label") end
function Friends.GetShowZoneTooltip() return NQOL.L("features.friends.show_zone_tooltip") end
function Friends.GetShowStatusIconLabel() return NQOL.L("features.friends.show_status_icon_label") end
function Friends.GetShowStatusIconTooltip() return NQOL.L("features.friends.show_status_icon_tooltip") end

NQOL.Features.Friends = Friends
