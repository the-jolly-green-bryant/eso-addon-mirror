-- Flamechasers Dungeon Codex UI
-- Compact branded layout with native ESO scroll containers and per-boss notes.

local DMC = DungeonMechsCodex
local wm = WINDOW_MANAGER

local UI = {
    selectedDungeonId = nil,
    selectedBossId = nil,
    selectedChatLine = nil,
    searchText = "",
    roleFilter = "all",
    mode = "hm",
    activityType = "dungeon",
    dungeonButtons = {},
    bossButtons = {},
    dungeonPasteButtons = {},
    bossPasteButtons = {},
    notePasteButtons = {},
    mechanicRows = {},
    noteOriginal = "",
    noteLoading = false,
    noteLoadedDungeonId = nil,
    noteLoadedBossId = nil,
    noteLoadedMode = nil,
}
DMC.ui = UI

local C = {
    bg = {0.005, 0.009, 0.014, 1},
    header = {0.014, 0.062, 0.094, 1},
    panel = {0.010, 0.018, 0.026, 1},
    panel2 = {0.014, 0.024, 0.034, 1},
    section = {0.022, 0.052, 0.070, 1},
    sectionAlt = {0.019, 0.042, 0.057, 1},
    row = {0.024, 0.039, 0.052, 1},
    rowHover = {0.038, 0.073, 0.096, 1},
    rowSelected = {0.032, 0.104, 0.143, 1},
    pill = {0.034, 0.078, 0.100, 1},
    pillHover = {0.052, 0.122, 0.154, 1},
    pillPressed = {0.030, 0.106, 0.142, 1},
    pillSelected = {0.044, 0.158, 0.206, 1},
    pillPrimaryHover = {0.060, 0.196, 0.248, 1},
    pillDisabled = {0.018, 0.034, 0.044, 1},
    segment = {0.017, 0.037, 0.049, 1},
    segmentHover = {0.030, 0.075, 0.096, 1},
    segmentPressed = {0.027, 0.094, 0.122, 1},
    segmentSelected = {0.030, 0.112, 0.146, 1},
    pillEdge = {0.18, 0.50, 0.61, 0.94},
    pillHoverEdge = {0.31, 0.73, 0.87, 1},
    pillSelectedEdge = {0.39, 0.87, 1.00, 1},
    pillDisabledEdge = {0.11, 0.28, 0.34, 0.74},
    buttonText = {0.84, 0.88, 0.91, 1},
    buttonDisabledText = {0.43, 0.48, 0.52, 1},
    bodyText = {0.82, 0.85, 0.88, 1},
    bodyTextSoft = {0.76, 0.80, 0.83, 1},
    iconPill = {0.018, 0.043, 0.056, 0.82},
    iconPillHover = {0.035, 0.092, 0.116, 0.94},
    iconPillEdge = {0.14, 0.39, 0.48, 0.82},
    mechanic = {0.024, 0.048, 0.063, 1},
    mechanicAlt = {0.014, 0.029, 0.041, 1},
    mechanicHeader = {0.030, 0.064, 0.082, 1},
    mechanicAction = {0.010, 0.023, 0.032, 0.96},
    structuralRule = {0.12, 0.36, 0.45, 0.56},
    passiveRule = {0.10, 0.29, 0.36, 0.42},
    fieldEdge = {0.16, 0.45, 0.55, 0.88},
    fieldFocus = {0.32, 0.76, 0.90, 1},
    edge = {0.25, 0.72, 1.00, 0.92},
    edgeDim = {0.13, 0.38, 0.48, 0.96},
    title = {0.48, 0.90, 1.00, 1},
    text = {0.92, 0.93, 0.94, 1},
    muted = {0.52, 0.62, 0.70, 1},
    quiet = {0.38, 0.46, 0.54, 1},
    gold = {0.96, 0.75, 0.30, 1},
    ok = {0.45, 0.94, 0.62, 1},
    warning = {0.95, 0.72, 0.32, 1},
}

local WINDOW_WIDTH = 1260
local WINDOW_HEIGHT = 860
local WINDOW_INSET = 7
local LEFT_X = 18
local CONTENT_Y = 68
local LEFT_WIDTH = 276
local CONTENT_HEIGHT = 774
local RIGHT_X = 306
local RIGHT_WIDTH = 936
local DUNGEON_ROW_HEIGHT = 30
local DUNGEON_CONTENT_WIDTH = 232
local DUNGEON_TITLE_X = 52
local MECHANIC_CONTENT_WIDTH = 874
local FONT_BODY = "$(MEDIUM_FONT)|15|soft-shadow-thin"
local FONT_META = "$(MEDIUM_FONT)|13|soft-shadow-thin"
local FONT_META_BOLD = "$(BOLD_FONT)|13|soft-shadow-thin"
local FONT_BOSS_ROW = "$(BOLD_FONT)|14|soft-shadow-thin"
local FONT_SECTION = "$(BOLD_FONT)|16|soft-shadow-thin"
local FONT_SECTION_SMALL = "$(BOLD_FONT)|15|soft-shadow-thin"

-- Activity Finder already ships artwork for supported instances. Resolve it
-- at runtime so the Codex gains activity identity without bundling duplicate
-- assets or relying on brittle hard-coded texture paths.
local activityArtworkCatalog
local activityArtworkCache = {}

-- Activity Finder uses shared category artwork for Trials and Arenas. Point
-- those activities at their own Veteran loading screens instead, all of which
-- are shipped by the ESO client. Keeping this keyed by our stable activity ID
-- also makes the result independent of client language and queue categories.
local VETERAN_INSTANCE_LOADSCREENS = {
    aetherian_archive = "/esoui/art/loadingscreens/loadscreen_aetherianarchive_veteran_01.dds",
    hel_ra_citadel = "/esoui/art/loadingscreens/loadscreen_helracitadel_veteran_01.dds",
    sanctum_ophidia = "/esoui/art/loadingscreens/loadscreen_serpenttrial_veteran_01.dds",
    maw_of_lorkhaj = "/esoui/art/loadingscreens/loadscreen_maw_of_lorkaj_veteran_01.dds",
    halls_of_fabrication = "/esoui/art/loadingscreens/loadscreen_hallsoffabrication_veteran_01.dds",
    asylum_sanctorium = "/esoui/art/loadingscreens/loadscreen_asylumsanctorium_veteran_01.dds",
    cloudrest = "/esoui/art/loadingscreens/loadscreen_cloudrest_veteran_01.dds",
    sunspire = "/esoui/art/loadingscreens/loadscreen_sunspire_veteran_01.dds",
    kynes_aegis = "/esoui/art/loadingscreens/loadscreen_kynesaegis_veteran_01.dds",
    rockgrove = "/esoui/art/loadingscreens/loadscreen_rockgrove_veteran_01.dds",
    dreadsail_reef = "/esoui/art/loadingscreens/loadscreen_dreadsail_reef_trial_veteran_01.dds",
    sanitys_edge = "/esoui/art/loadingscreens/loadscreen_sanitysedge_veteran_01.dds",
    lucent_citadel = "/esoui/art/loadingscreens/loadscreen_lucentcitadel_veteran_01.dds",
    ossein_cage = "/esoui/art/loadingscreens/loadscreen_ossein_cage_veteran_01.dds",
    dragonstar_arena = "/esoui/art/loadingscreens/loadscreen_dragonstararena_veteran_01.dds",
    blackrose_prison_arena = "/esoui/art/loadingscreens/loadscreen_blackrose_prison_veteran_01.dds",
    maelstrom_arena = "/esoui/art/loadingscreens/loadscreen_maelstromarena_veteran_01.dds",
    vateshran_hollows = "/esoui/art/loadingscreens/loadscreen_vateshranhollows_veteran_01.dds",
}

local function validTexture(texture)
    return type(texture) == "string" and texture ~= ""
end

local function getFinderArtwork(activityId)
    local smallTexture, largeTexture
    if type(GetActivityKeyboardDescriptionTextures) == "function" then
        smallTexture, largeTexture = GetActivityKeyboardDescriptionTextures(activityId)
    end
    if validTexture(smallTexture) then return smallTexture end
    if validTexture(largeTexture) then return largeTexture end
    if type(GetActivityGamepadDescriptionTexture) == "function" then
        local gamepadTexture = GetActivityGamepadDescriptionTexture(activityId)
        if validTexture(gamepadTexture) then return gamepadTexture end
    end
    return nil
end

local function buildActivityArtworkCatalog()
    if activityArtworkCatalog then return activityArtworkCatalog end
    activityArtworkCatalog = {byName = {}, byZone = {}}

    if type(GetNumActivitiesByType) ~= "function"
        or type(GetActivityIdByTypeAndIndex) ~= "function" then
        return activityArtworkCatalog
    end

    local activityTypes, seenTypes = {}, {}
    local function addType(activityType)
        if activityType ~= nil and not seenTypes[activityType] then
            seenTypes[activityType] = true
            activityTypes[#activityTypes + 1] = activityType
        end
    end

    -- Match ESO's own Activity Finder manager: walk the complete live enum
    -- range. Trials and arenas are not guaranteed to live in only the four
    -- queue categories used by the dungeon finder on every API revision.
    local firstType = _G.LFG_ACTIVITY_ITERATION_BEGIN
    local lastType = _G.LFG_ACTIVITY_ITERATION_END
    if type(firstType) == "number" and type(lastType) == "number"
        and lastType >= firstType and lastType - firstType < 100 then
        for activityType = firstType, lastType do addType(activityType) end
    end

    -- Retain explicit fallbacks for older API/test environments that do not
    -- publish the iteration boundary constants.
    addType(_G.LFG_ACTIVITY_DUNGEON)
    addType(_G.LFG_ACTIVITY_MASTER_DUNGEON)
    addType(_G.LFG_ACTIVITY_TRIAL)
    addType(_G.LFG_ACTIVITY_ARENA)
    addType(_G.LFG_ACTIVITY_ADVENTURE_ZONE)

    for _, activityType in ipairs(activityTypes) do
        local count = GetNumActivitiesByType(activityType) or 0
        for index = 1, count do
            local activityId = GetActivityIdByTypeAndIndex(activityType, index)
            if activityId then
                local name = ""
                if type(GetActivityName) == "function" then
                    name = GetActivityName(activityId) or ""
                end
                if name == "" and type(GetActivityInfo) == "function" then
                    name = GetActivityInfo(activityId)
                end
                local texture = getFinderArtwork(activityId)
                if texture then
                    local nameKey = DMC.NormalizeText(name or "")
                    if nameKey ~= "" and not activityArtworkCatalog.byName[nameKey] then
                        activityArtworkCatalog.byName[nameKey] = texture
                    end
                    if type(GetActivityZoneId) == "function" then
                        local zoneId = GetActivityZoneId(activityId)
                        if zoneId and zoneId > 0 and not activityArtworkCatalog.byZone[zoneId] then
                            activityArtworkCatalog.byZone[zoneId] = texture
                        end
                    end
                end
            end
        end
    end
    return activityArtworkCatalog
end

local function getZoneStoryArtwork(activity)
    if type(GetZoneStoryKeyboardBackground) ~= "function"
        and type(GetZoneStoryGamepadBackground) ~= "function" then
        return nil
    end

    local tested = {}
    local function tryZone(zoneId)
        if not zoneId or zoneId <= 0 or tested[zoneId] then return nil end
        tested[zoneId] = true
        if type(GetZoneStoryKeyboardBackground) == "function" then
            local texture = GetZoneStoryKeyboardBackground(zoneId)
            if validTexture(texture) then return texture end
        end
        if type(GetZoneStoryGamepadBackground) == "function" then
            local texture = GetZoneStoryGamepadBackground(zoneId)
            if validTexture(texture) then return texture end
        end
        return nil
    end

    for _, zoneId in ipairs(activity.zoneIds or {}) do
        local texture = tryZone(zoneId)
        if texture then return texture end
        if type(GetZoneStoryZoneIdForZoneId) == "function" then
            texture = tryZone(GetZoneStoryZoneIdForZoneId(zoneId))
            if texture then return texture end
        end
    end
    return nil
end

local function getActivityArtwork(activity)
    if not activity then return nil end
    local cached = activityArtworkCache[activity.id]
    if cached ~= nil then
        if cached == false then return nil end
        return cached.texture, cached.isLoadscreen
    end

    local instanceLoadscreen = VETERAN_INSTANCE_LOADSCREENS[activity.id]
    if instanceLoadscreen then
        activityArtworkCache[activity.id] = {texture = instanceLoadscreen, isLoadscreen = true}
        return instanceLoadscreen, true
    end

    -- Do not accept Activity Finder or Zone Story fallbacks for a Trial/Arena:
    -- both APIs return shared chapter/category art rather than the selected
    -- instance's splash image. A missing future mapping should stay blank until
    -- its real client texture is added, never silently show the wrong picture.
    if DMC.GetActivityKind(activity) ~= "dungeon" then
        activityArtworkCache[activity.id] = false
        return nil
    end

    local catalog = buildActivityArtworkCatalog()
    local texture
    for _, zoneId in ipairs(activity.zoneIds or {}) do
        texture = catalog.byZone[zoneId]
        if texture then break end
    end
    if not texture then
        texture = catalog.byName[DMC.NormalizeText(activity.name or "")]
    end
    if not texture then
        for _, alias in ipairs(activity.aliases or {}) do
            texture = catalog.byName[DMC.NormalizeText(alias)]
            if texture then break end
        end
    end
    if not texture then texture = getZoneStoryArtwork(activity) end
    activityArtworkCache[activity.id] = texture and {texture = texture, isLoadscreen = false} or false
    return texture
end

local function getSessionState()
    DMC.sessionState = DMC.sessionState or {}
    if not DMC.sessionState.roleFilter then DMC.sessionState.roleFilter = "all" end
    if DMC.sessionState.activityType ~= "trial" and DMC.sessionState.activityType ~= "arena" then
        DMC.sessionState.activityType = "dungeon"
    end
    return DMC.sessionState
end

local function isValidRoleFilter(role)
    return role == "all" or role == "quick" or role == "tank" or role == "healer" or role == "dps"
end

local ROLE_ORDER = {"all", "quick", "tank", "healer", "dps"}

local function hideCompactHint()
    if UI.compactHint then UI.compactHint:SetHidden(true) end
end

local function showCompactHint(control, text)
    if not UI.compactHint or not UI.compactHintLabel then return end
    UI.compactHintLabel:SetText(text or "")
    local width = math.max(46, math.min(132, math.ceil(UI.compactHintLabel:GetTextWidth() + 16)))
    UI.compactHint:SetDimensions(width, 20)
    UI.compactHint:ClearAnchors()
    UI.compactHint:SetAnchor(BOTTOM, control, TOP, 0, -4)
    UI.compactHint:SetHidden(false)
end

local function anchorFill(control, parent, inset)
    inset = inset or 0
    control:SetAnchor(TOPLEFT, parent, TOPLEFT, inset, inset)
    control:SetAnchor(BOTTOMRIGHT, parent, BOTTOMRIGHT, -inset, -inset)
end

local function makeBackdrop(parent, name, centerColor, edgeColor, inset)
    local backdrop = wm:CreateControl(name, parent, CT_BACKDROP)
    anchorFill(backdrop, parent, inset or 0)
    backdrop:SetCenterTexture("EsoUI/Art/Tooltips/UI-TooltipCenter.dds")
    backdrop:SetEdgeTexture("EsoUI/Art/Tooltips/UI-Tooltip-Border.dds", 128, 16)
    backdrop:SetInsets(7, 7, -7, -7)
    backdrop:SetCenterColor(unpack(centerColor or C.panel))
    backdrop:SetEdgeColor(unpack(edgeColor or C.edgeDim))
    backdrop:SetMouseEnabled(false)
    backdrop:SetDrawLayer(DL_BACKGROUND)
    return backdrop
end

local function makeWindowStroke(parent, name, thickness, inset, color)
    local frame = wm:CreateControl(name, parent, CT_CONTROL)
    frame:SetAnchor(TOPLEFT, parent, TOPLEFT, inset, inset)
    frame:SetAnchor(BOTTOMRIGHT, parent, BOTTOMRIGHT, -inset, -inset)
    frame:SetMouseEnabled(false)
    frame.lines = {}

    local function horizontal(suffix, top)
        local line = wm:CreateControl(name .. suffix, frame, CT_TEXTURE)
        line:SetHeight(thickness)
        line:SetAnchor(top and TOPLEFT or BOTTOMLEFT, frame, top and TOPLEFT or BOTTOMLEFT, 0, 0)
        line:SetAnchor(top and TOPRIGHT or BOTTOMRIGHT, frame, top and TOPRIGHT or BOTTOMRIGHT, 0, 0)
        line:SetColor(unpack(color))
        line:SetDrawLayer(DL_OVERLAY)
        line:SetDrawLevel(250)
        table.insert(frame.lines, line)
    end

    local function vertical(suffix, left)
        local line = wm:CreateControl(name .. suffix, frame, CT_TEXTURE)
        line:SetWidth(thickness)
        line:SetAnchor(left and TOPLEFT or TOPRIGHT, frame, left and TOPLEFT or TOPRIGHT, 0, 0)
        line:SetAnchor(left and BOTTOMLEFT or BOTTOMRIGHT, frame, left and BOTTOMLEFT or BOTTOMRIGHT, 0, 0)
        line:SetColor(unpack(color))
        line:SetDrawLayer(DL_OVERLAY)
        line:SetDrawLevel(250)
        table.insert(frame.lines, line)
    end

    horizontal("Top", true)
    horizontal("Bottom", false)
    vertical("Left", true)
    vertical("Right", false)
    return frame
end

local function setStrokeColor(frame, color)
    if not frame or not frame.lines then return end
    for _, line in ipairs(frame.lines) do line:SetColor(unpack(color)) end
end

local function makePanel(parent, name, x, y, width, height, centerColor)
    local panel = wm:CreateControl(name, parent, CT_CONTROL)
    panel:SetAnchor(TOPLEFT, parent, TOPLEFT, x, y)
    panel:SetDimensions(width, height)
    panel.bg = makeBackdrop(panel, name .. "Backdrop", centerColor or C.panel, {0, 0, 0, 0}, 0)
    panel.bg:SetEdgeColor(0, 0, 0, 0)
    return panel
end

local function makeSectionBand(parent, name, height, x, width, color)
    local band = wm:CreateControl(name, parent, CT_BACKDROP)
    x = x or 1
    band:SetAnchor(TOPLEFT, parent, TOPLEFT, x, 1)
    if width then
        band:SetDimensions(width, height)
    else
        band:SetAnchor(TOPRIGHT, parent, TOPRIGHT, -1, 1)
        band:SetHeight(height)
    end
    band:SetCenterColor(unpack(color or C.section))
    band:SetEdgeColor(0, 0, 0, 0)
    band:SetMouseEnabled(false)
    band:SetDrawLayer(DL_BACKGROUND)
    band:SetDrawLevel(2)

    local rule = wm:CreateControl(name .. "Rule", band, CT_TEXTURE)
    rule:SetAnchor(BOTTOMLEFT, band, BOTTOMLEFT, 0, 0)
    rule:SetAnchor(BOTTOMRIGHT, band, BOTTOMRIGHT, 0, 0)
    rule:SetHeight(1)
    rule:SetColor(unpack(C.structuralRule))
    return band
end

local function makeLabel(parent, name, text, font, color, oneLine)
    local label = wm:CreateControl(name, parent, CT_LABEL)
    label:SetFont(font or "ZoFontGame")
    label:SetText(text or "")
    label:SetColor(unpack(color or C.text))
    if oneLine then label:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS) end
    return label
end

local function createHeaderIcon(parent, name, kind, color)
    local icon = wm:CreateControl(name, parent, CT_CONTROL)
    icon:SetDimensions(14, 14)
    icon:SetMouseEnabled(false)
    icon.parts = {}

    local function part(suffix, x, y, w, h, alpha)
        local p = wm:CreateControl(name .. suffix, icon, CT_TEXTURE)
        p:SetAnchor(TOPLEFT, icon, TOPLEFT, x, y)
        p:SetDimensions(w, h)
        local c = color or C.title
        p:SetColor(c[1], c[2], c[3], alpha or c[4] or 1)
        p:SetDrawLayer(DL_OVERLAY)
        p:SetDrawLevel(25)
        table.insert(icon.parts, p)
    end

    if kind == "list" then
        part("Dot1", 0, 2, 2, 2, 0.95)
        part("Line1", 4, 2, 9, 2, 0.90)
        part("Dot2", 0, 6, 2, 2, 0.82)
        part("Line2", 4, 6, 9, 2, 0.78)
        part("Dot3", 0, 10, 2, 2, 0.72)
        part("Line3", 4, 10, 9, 2, 0.68)
    elseif kind == "notes" then
        part("Top", 1, 0, 10, 1, 0.90)
        part("Left", 1, 0, 1, 12, 0.90)
        part("Right", 10, 0, 1, 12, 0.90)
        part("Bottom", 1, 11, 10, 1, 0.90)
        part("Clip", 4, 0, 4, 2, 0.95)
        part("Line1", 3, 4, 6, 1, 0.75)
        part("Line2", 3, 7, 6, 1, 0.60)
    elseif kind == "mechanics" then
        part("Bar", 6, 1, 2, 8, 0.92)
        part("Dot", 6, 11, 2, 2, 0.82)
        part("Accent", 3, 1, 2, 2, 0.62)
        part("Accent2", 9, 1, 2, 2, 0.62)
    elseif kind == "bosses" then
        part("Top", 1, 1, 8, 1, 0.92)
        part("Left", 1, 1, 1, 8, 0.92)
        part("Right", 8, 1, 1, 8, 0.92)
        part("Bottom", 1, 8, 8, 1, 0.92)
        part("Center", 4, 4, 2, 2, 0.95)
        part("Side", 11, 4, 2, 2, 0.68)
    end
    return icon
end

local function makeButton(parent, name, text, callback, font)
    local button = wm:CreateControl(name, parent, CT_BUTTON)
    button:SetFont(font or "ZoFontGame")
    button:SetText(text or "")
    button:SetNormalFontColor(0.84, 0.88, 0.91, 1)
    button:SetMouseOverFontColor(1, 1, 1, 1)
    button:SetPressedFontColor(0.48, 0.91, 1, 1)
    if callback then button:SetHandler("OnClicked", callback) end
    return button
end

local function setPillText(button, text)
    if not button then return end
    text = text or ""
    button:SetText(text)
    if button.caption then button.caption:SetText(text) end
end

local function applyPillVisual(button)
    if not button or not button.bg then return end
    local fill, edge, textColor
    if button.isEnabled == false then
        fill, edge, textColor = C.pillDisabled, C.pillDisabledEdge, C.buttonDisabledText
    elseif button.isPressed then
        fill, edge, textColor = C.pillPressed, C.pillSelectedEdge, C.title
    elseif button.isSelected then
        fill, edge, textColor = C.pillSelected, C.pillSelectedEdge, C.title
    elseif button.iconStyle and button.isHovered then
        fill, edge, textColor = C.iconPillHover, C.pillHoverEdge, C.text
    elseif button.iconStyle then
        fill, edge, textColor = C.iconPill, C.iconPillEdge, C.buttonText
    elseif button.variant == "primary" and button.isHovered then
        fill, edge, textColor = C.pillPrimaryHover, C.pillSelectedEdge, C.text
    elseif button.variant == "primary" then
        fill, edge, textColor = C.pillSelected, C.pillSelectedEdge, C.title
    elseif button.isHovered then
        fill, edge, textColor = C.pillHover, C.pillHoverEdge, C.text
    else
        fill, edge, textColor = C.pill, C.pillEdge, C.buttonText
    end
    button.bg:SetCenterColor(unpack(fill))
    button.bg:SetEdgeColor(unpack(edge))
    setStrokeColor(button.frame, edge)
    if button.caption then button.caption:SetColor(unpack(textColor)) end
    if button.icon then button.icon:SetColor(unpack(textColor)) end
end

local function makePill(parent, name, text, callback, font)
    local button = makeButton(parent, name, text, callback, font or "ZoFontGameSmall")
    button.bg = wm:CreateControl(name .. "Bg", button, CT_BACKDROP)
    button.bg:SetAnchorFill(button)
    button.bg:SetCenterColor(unpack(C.pill))
    button.bg:SetEdgeColor(0, 0, 0, 0)
    button.bg:SetMouseEnabled(false)
    button.bg:SetDrawLayer(DL_BACKGROUND)
    button.bg:SetDrawLevel(10)
    button.frame = makeWindowStroke(button, name .. "Frame", 1, 0, C.pillEdge)
    button.caption = makeLabel(button, name .. "Label", text or "", font or "ZoFontGameSmall", C.buttonText, true)
    button.caption:SetAnchor(TOPLEFT, button, TOPLEFT, 2, 0)
    button.caption:SetAnchor(BOTTOMRIGHT, button, BOTTOMRIGHT, -2, 0)
    button.caption:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    button.caption:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    button.caption:SetMouseEnabled(false)
    button.caption:SetDrawLayer(DL_OVERLAY)
    button.caption:SetDrawLevel(20)
    button:SetNormalFontColor(0, 0, 0, 0)
    button:SetMouseOverFontColor(0, 0, 0, 0)
    button:SetPressedFontColor(0, 0, 0, 0)
    button:SetDisabledFontColor(0, 0, 0, 0)
    button.isEnabled = true
    button:SetHandler("OnMouseEnter", function(control)
        control.isHovered = true
        applyPillVisual(control)
    end)
    button:SetHandler("OnMouseExit", function(control)
        control.isHovered = false
        control.isPressed = false
        applyPillVisual(control)
    end)
    button:SetHandler("OnMouseDown", function(control)
        control.isPressed = true
        applyPillVisual(control)
    end)
    button:SetHandler("OnMouseUp", function(control)
        control.isPressed = false
        applyPillVisual(control)
    end)
    applyPillVisual(button)
    return button
end

local function layoutPasteIcon(button, partNumber)
    if not button or not button.icon then return end
    button.pastePart = partNumber
    button.icon:ClearAnchors()
    button.caption:ClearAnchors()
    if partNumber then
        button.icon:SetAnchor(LEFT, button, LEFT, 6, 0)
        button.icon:SetDimensions(15, 15)
        button.caption:SetAnchor(TOPLEFT, button, TOPLEFT, 22, 0)
        button.caption:SetAnchor(BOTTOMRIGHT, button, BOTTOMRIGHT, -4, 0)
        button.caption:SetText(tostring(partNumber))
        button.caption:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    else
        button.icon:SetAnchor(CENTER, button, CENTER, 0, 0)
        button.icon:SetDimensions(16, 16)
        button.caption:SetText("")
        button.caption:SetAnchorFill(button)
    end
    button.caption:SetVerticalAlignment(TEXT_ALIGN_CENTER)
end

local function makePasteIconButton(parent, name, callback)
    local button = makePill(parent, name, "", callback, FONT_META_BOLD)
    button.iconStyle = true
    button.icon = wm:CreateControl(name .. "Icon", button, CT_TEXTURE)
    button.icon:SetTexture("DungeonMechsCodex/paste_icon.dds")
    button.icon:SetMouseEnabled(false)
    button.icon:SetDrawLayer(DL_OVERLAY)
    button.icon:SetDrawLevel(22)
    layoutPasteIcon(button, nil)
    ZO_PostHookHandler(button, "OnMouseEnter", function(control)
        local text = control.pastePart and ("Paste part " .. tostring(control.pastePart)) or "Paste"
        showCompactHint(control, text)
    end)
    ZO_PostHookHandler(button, "OnMouseExit", hideCompactHint)
    applyPillVisual(button)
    return button
end

local function applySegmentVisual(button)
    if not button or not button.bg then return end
    local fill, textColor
    if button.isEnabled == false then
        fill, textColor = C.pillDisabled, C.buttonDisabledText
    elseif button.isPressed then
        fill, textColor = C.segmentPressed, C.title
    elseif button.isSelected then
        fill, textColor = C.segmentSelected, C.title
    elseif button.isHovered then
        fill, textColor = C.segmentHover, C.text
    else
        fill, textColor = C.segment, C.buttonText
    end
    button.bg:SetCenterColor(unpack(fill))
    if button.caption then button.caption:SetColor(unpack(textColor)) end
    if button.activeBar then button.activeBar:SetHidden(not button.isSelected) end
end

local function makeSegmentButton(parent, name, text, callback, font)
    local button = makeButton(parent, name, text, callback, font or "ZoFontGameSmall")
    button.bg = wm:CreateControl(name .. "Bg", button, CT_BACKDROP)
    button.bg:SetAnchorFill(button)
    button.bg:SetCenterColor(unpack(C.segment))
    button.bg:SetEdgeColor(0, 0, 0, 0)
    button.bg:SetMouseEnabled(false)
    button.bg:SetDrawLayer(DL_BACKGROUND)
    button.bg:SetDrawLevel(10)

    button.caption = makeLabel(button, name .. "Label", text or "", font or "ZoFontGameSmall", C.buttonText, true)
    button.caption:SetAnchor(TOPLEFT, button, TOPLEFT, 2, 0)
    button.caption:SetAnchor(BOTTOMRIGHT, button, BOTTOMRIGHT, -2, 0)
    button.caption:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    button.caption:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    button.caption:SetMouseEnabled(false)
    button.caption:SetDrawLayer(DL_OVERLAY)
    button.caption:SetDrawLevel(20)

    button.activeBar = wm:CreateControl(name .. "ActiveBar", button, CT_TEXTURE)
    button.activeBar:SetAnchor(BOTTOMLEFT, button, BOTTOMLEFT, 7, 0)
    button.activeBar:SetAnchor(BOTTOMRIGHT, button, BOTTOMRIGHT, -7, 0)
    button.activeBar:SetHeight(2)
    button.activeBar:SetColor(unpack(C.edge))
    button.activeBar:SetDrawLayer(DL_OVERLAY)
    button.activeBar:SetDrawLevel(25)
    button.activeBar:SetHidden(true)

    button:SetNormalFontColor(0, 0, 0, 0)
    button:SetMouseOverFontColor(0, 0, 0, 0)
    button:SetPressedFontColor(0, 0, 0, 0)
    button:SetDisabledFontColor(0, 0, 0, 0)
    button.isEnabled = true
    button.isSegment = true
    button:SetHandler("OnMouseEnter", function(control)
        control.isHovered = true
        applySegmentVisual(control)
    end)
    button:SetHandler("OnMouseExit", function(control)
        control.isHovered = false
        control.isPressed = false
        applySegmentVisual(control)
    end)
    button:SetHandler("OnMouseDown", function(control)
        control.isPressed = true
        applySegmentVisual(control)
    end)
    button:SetHandler("OnMouseUp", function(control)
        control.isPressed = false
        applySegmentVisual(control)
    end)
    applySegmentVisual(button)
    return button
end

local function setSelectedButton(button, selected)
    if not button then return end
    button.isSelected = selected
    if button.isSegment then applySegmentVisual(button) else applyPillVisual(button) end
end

local function setButtonEnabled(button, enabled)
    if not button then return end
    button.isEnabled = enabled
    button:SetEnabled(enabled)
    button:SetAlpha(1)
    if button.caption then
        if button.isSegment then applySegmentVisual(button) else applyPillVisual(button) end
    else
        button:SetAlpha(enabled and 1 or 0.55)
    end
end

local function shortFlags(boss)
    if not boss or not boss.flags then return "" end
    local out, seen = {}, {}
    local function add(label)
        if not seen[label] then
            seen[label] = true
            table.insert(out, label)
        end
    end
    for _, flag in ipairs(boss.flags) do
        local normalized = DMC.NormalizeText(flag)
        if normalized == "secret" then add("Secret")
        elseif normalized == "super secret" then add("Secret+")
        elseif normalized == "final" then add("Final")
        elseif normalized == "main" then add("Main")
        end
    end
    return #out > 0 and ("  |c46545D" .. table.concat(out, " ") .. "|r") or ""
end

local function plainFlags(boss)
    if not boss or not boss.flags then return "" end
    local out, seen = {}, {}
    local function add(label)
        if not seen[label] then seen[label] = true table.insert(out, label) end
    end
    for _, flag in ipairs(boss.flags) do
        local normalized = DMC.NormalizeText(flag)
        if normalized == "secret" then add("Secret")
        elseif normalized == "super secret" then add("Secret+")
        elseif normalized == "final" then add("Final")
        elseif normalized == "main" then add("Main") end
    end
    return table.concat(out, " ")
end

local function getDungeonSummaryText(dungeon)
    if not dungeon or not dungeon.summary then return "" end
    return DMC.GetModeText(dungeon.summary, {"ui", "full"}, UI.mode)
end

local function getBossSummaryText(boss)
    if not boss then return "" end
    return DMC.GetModeText(boss, {"ui", "summary"}, UI.mode)
end

local function stripForUI(text)
    return DMC.StripChatFormatting(text or "")
end

local function setPasteButton(button, chatText, label)
    if not button then return end
    button.chatText = chatText
    button:SetHidden(not chatText or chatText == "")
    if chatText then
        if button.iconStyle then
            local partNumber = label and tostring(label):match("(%d+)$") or nil
            layoutPasteIcon(button, partNumber)
        else
            setPillText(button, label or "PASTE")
        end
    end
end

local function layoutDungeonPasteButtons(lineCount)
    local count = math.min(lineCount or 0, #UI.dungeonPasteButtons)
    local buttonWidth, gap = 42, 5
    local rightInset = 16
    local rightEdge = RIGHT_WIDTH - rightInset
    local topY = 7
    local totalWidth = count > 0 and (count * buttonWidth + math.max(0, count - 1) * gap) or 0
    local startX = rightEdge - totalWidth

    for index, button in ipairs(UI.dungeonPasteButtons) do
        if index <= count then
            button:ClearAnchors()
            button:SetAnchor(TOPLEFT, UI.dungeonPanel, TOPLEFT, startX + (index - 1) * (buttonWidth + gap), topY)
            button:SetDimensions(buttonWidth, 25)
        end
    end

    local pasteLabelWidth = 38
    local pasteLabelLeft = count > 0 and (startX - pasteLabelWidth - 7) or rightEdge
    if UI.dungeonPasteLabel then
        UI.dungeonPasteLabel:ClearAnchors()
        UI.dungeonPasteLabel:SetAnchor(TOPLEFT, UI.dungeonPanel, TOPLEFT, pasteLabelLeft, topY + 2)
        UI.dungeonPasteLabel:SetHidden(count == 0)
    end

    local modeWidth = UI.modeGroup and not UI.modeGroup:IsHidden() and 92 or 0
    local modeRight = count > 0 and (pasteLabelLeft - 10) or rightEdge
    local modeLeft = modeRight - modeWidth
    if UI.modeGroup and modeWidth > 0 then
        UI.modeGroup:ClearAnchors()
        UI.modeGroup:SetAnchor(TOPLEFT, UI.dungeonPanel, TOPLEFT, modeLeft, topY)
    end
    local titleRight = modeLeft - (modeWidth > 0 and 12 or 0)
    if UI.statusLabel and not UI.statusLabel:IsHidden() then
        UI.statusLabel:ClearAnchors()
        UI.statusLabel:SetAnchor(TOPRIGHT, UI.dungeonPanel, TOPRIGHT, -(RIGHT_WIDTH - startX + 10), 12)
        UI.statusLabel:SetDimensions(116, 20)
        titleRight = startX - 136
    end
    UI.dungeonTitleAvailableWidth = math.min(600, math.max(300, titleRight - DUNGEON_TITLE_X))
end

local function applyActivityCapabilities(activity)
    if not activity then return end
    local capabilities = DMC.GetActivityCapabilities(activity)
    local preferredMode = DMC.GetDifficultyMode(DMC.sv and DMC.sv.mode or UI.mode)
    UI.mode = DMC.ActivitySupports(activity, "difficulties", preferredMode)
        and preferredMode or (capabilities.difficulties[1] or "vet")

    local preferredRole = getSessionState().roleFilter
    UI.roleFilter = DMC.ActivitySupports(activity, "roles", preferredRole)
        and preferredRole or (capabilities.roles[1] or "all")

    local supportedRoles = {}
    for _, role in ipairs(ROLE_ORDER) do
        if DMC.ActivitySupports(activity, "roles", role) then
            supportedRoles[#supportedRoles + 1] = role
        end
    end
    local segmentWidth = 65
    UI.roleGroup:SetDimensions(math.max(segmentWidth, #supportedRoles * segmentWidth), 30)
    local visibleIndex = 0
    for _, role in ipairs(ROLE_ORDER) do
        local button = UI.roleButtons and UI.roleButtons[role]
        local supported = DMC.ActivitySupports(activity, "roles", role)
        if button then
            button:SetHidden(not supported)
            if supported then
                button:ClearAnchors()
                button:SetAnchor(TOPLEFT, UI.roleGroup, TOPLEFT, visibleIndex * segmentWidth, 0)
                button:SetDimensions(segmentWidth, 30)
                visibleIndex = visibleIndex + 1
            end
        end
        local separator = UI.roleSeparators and UI.roleSeparators[role]
        if separator then
            separator:SetHidden(not supported or visibleIndex <= 1)
            if supported and visibleIndex > 1 then
                separator:ClearAnchors()
                separator:SetAnchor(TOPLEFT, UI.roleGroup, TOPLEFT, (visibleIndex - 1) * segmentWidth, 5)
                separator:SetAnchor(BOTTOMLEFT, UI.roleGroup, BOTTOMLEFT, (visibleIndex - 1) * segmentWidth, -5)
            end
        end
    end

    UI.modeGroup:SetHidden(#(capabilities.difficulties or {}) < 2)
    setSelectedButton(UI.modeVet, UI.mode == "vet")
    setSelectedButton(UI.modeHm, UI.mode == "hm")
    for _, role in ipairs(ROLE_ORDER) do
        setSelectedButton(UI.roleButtons and UI.roleButtons[role], UI.roleFilter == role)
    end
end

local function layoutDungeonTitle(dungeon)
    if not UI.dungeonTitle or not UI.dungeonDlc then return end
    local titleMax = UI.dungeonTitleAvailableWidth or 500
    local dlcText = tostring(dungeon and dungeon.dlc or "")
    local hasDlc = dlcText ~= ""
    local dungeonNameMax = math.max(180, titleMax - (hasDlc and 124 or 0))

    UI.dungeonTitle:SetText(dungeon and dungeon.name or "Select an activity")
    UI.dungeonTitle:SetDimensions(dungeonNameMax, 30)
    local dungeonNameWidth = math.min(dungeonNameMax, math.ceil(UI.dungeonTitle:GetTextWidth() + 2))
    UI.dungeonTitle:SetDimensions(dungeonNameWidth, 30)

    UI.dungeonDlc:ClearAnchors()
    UI.dungeonDlc:SetAnchor(LEFT, UI.dungeonTitle, RIGHT, 10, 1)
    UI.dungeonDlc:SetText(dlcText)
    UI.dungeonDlc:SetHidden(not hasDlc)
    local dlcMax = math.max(0, titleMax - dungeonNameWidth - 14)
    UI.dungeonDlc:SetDimensions(math.min(190, dlcMax), 20)
end

local function layoutBossPasteButtons(lineCount)
    local count = math.min(lineCount or 0, #UI.bossPasteButtons)
    local buttonWidth, gap = 42, 4
    local rightX = 520
    local totalWidth = count * buttonWidth + math.max(0, count - 1) * gap
    local startX = rightX - totalWidth

    for index, button in ipairs(UI.bossPasteButtons) do
        if index <= count then
            button:ClearAnchors()
            button:SetAnchor(TOPLEFT, UI.bossPanel, TOPLEFT, startX + (index - 1) * (buttonWidth + gap), 7)
            button:SetDimensions(buttonWidth, 25)
        end
    end
    UI.bossTitleAvailableWidth = count > 0 and math.max(170, startX - 24) or 504
end

local function layoutSelectedBossTitle(boss)
    if not UI.bossTitle or not UI.bossMeta then return end
    local available = UI.bossTitleAvailableWidth or 504
    local meta = plainFlags(boss)
    UI.bossMeta:SetText(meta)
    local metaWidth = meta ~= "" and math.min(90, math.max(54, math.ceil(UI.bossMeta:GetTextWidth() + 12))) or 0
    local nameMax = math.max(150, available - (metaWidth > 0 and (metaWidth + 8) or 0))
    UI.bossTitle:SetDimensions(nameMax, 28)
    UI.bossTitle:SetText(boss and boss.name or "")
    local nameWidth = math.min(nameMax, math.ceil(UI.bossTitle:GetTextWidth() + 2))
    UI.bossTitle:SetDimensions(nameWidth, 28)
    UI.bossMeta:ClearAnchors()
    UI.bossMeta:SetAnchor(LEFT, UI.bossTitle, RIGHT, 7, 1)
    UI.bossMeta:SetDimensions(metaWidth, 20)
    UI.bossMeta:SetHidden(meta == "")
end

local function measureBossRowWidth(text)
    if not UI.bossMeasureLabel then return 260 end
    UI.bossMeasureLabel:SetText(text or "")
    return math.ceil(UI.bossMeasureLabel:GetTextWidth() + 30)
end

local function layoutBossListTable(bossCount)
    bossCount = bossCount or 0
    local rowsPerColumn = math.max(1, math.ceil(bossCount / 2))
    local leftCount = math.min(rowsPerColumn, bossCount)
    local rightCount = math.max(0, bossCount - leftCount)
    local rightStart = leftCount + 1
    local topY = 39
    local rowHeight = rowsPerColumn > 4 and 16 or 20
    local leftX, totalWidth, gap = 16, 908, 20
    local leftMin, rightMin, leftMax = 250, 280, 520

    local leftNeed = leftMin
    for index = 1, leftCount do
        local button = UI.bossButtons[index]
        if button and button.bossId then
            leftNeed = math.max(leftNeed, measureBossRowWidth(button.measureText))
        end
    end

    local rightNeed = rightMin
    for index = rightStart, rightStart + rightCount - 1 do
        local button = UI.bossButtons[index]
        if button and button.bossId then
            rightNeed = math.max(rightNeed, measureBossRowWidth(button.measureText))
        end
    end

    local usable = totalWidth - (rightCount > 0 and gap or 0)
    local leftWidth
    if rightCount == 0 then
        leftWidth = zo_clamp(leftNeed, leftMin, math.min(leftMax, usable))
    elseif leftNeed + rightNeed <= usable then
        leftWidth = zo_clamp(leftNeed, leftMin, math.min(leftMax, usable - rightMin))
    else
        local combined = math.max(1, leftNeed + rightNeed)
        local proportional = math.floor(usable * (leftNeed / combined) + 0.5)
        leftWidth = zo_clamp(proportional, leftMin, math.min(leftMax, usable - rightMin))
    end

    local rightX = leftX + leftWidth + gap
    local rightWidth = math.max(rightMin, totalWidth - leftWidth - gap)

    for index, button in ipairs(UI.bossButtons) do
        if button.bossId then
            local column = index <= leftCount and 0 or 1
            local row = column == 0 and (index - 1) or (index - rightStart)
            button:ClearAnchors()
            if column == 0 then
                button:SetAnchor(TOPLEFT, UI.bossListPanel, TOPLEFT, leftX, topY + row * rowHeight)
                button:SetDimensions(leftWidth, rowHeight - 1)
            else
                button:SetAnchor(TOPLEFT, UI.bossListPanel, TOPLEFT, rightX, topY + row * rowHeight)
                button:SetDimensions(rightWidth, rowHeight - 1)
            end
        end
    end
end

local function makeNativeScroll(parent, name, x, y, width, height)
    local scroll = wm:CreateControlFromVirtual(name, parent, "ZO_ScrollContainer")
    scroll:SetAnchor(TOPLEFT, parent, TOPLEFT, x, y)
    scroll:SetDimensions(width, height)
    local child = scroll:GetNamedChild("ScrollChild")
    child:SetResizeToFitDescendents(false)
    ZO_Scroll_SetUseFadeGradient(scroll, false)
    return scroll, child
end

local function updateNativeScroll(scroll, child, contentWidth, contentHeight, reset)
    if not scroll or not child then return end
    child:SetDimensions(contentWidth, math.max(1, contentHeight))
    local function update()
        if reset then ZO_Scroll_ResetToTop(scroll) end
        ZO_Scroll_UpdateScrollBar(scroll, true)
    end
    update()
    zo_callLater(update, 0)
end

local function makeScrollableText(parent, name, x, y, width, height, font, color)
    local scroll, child = makeNativeScroll(parent, name .. "Scroll", x, y, width, height)
    local contentWidth = width - 24
    local label = makeLabel(child, name .. "Label", "", font or "ZoFontGameSmall", color or C.text, false)
    label:SetAnchor(TOPLEFT, child, TOPLEFT, 0, 0)
    label:SetDimensions(contentWidth, height)
    return {
        scroll = scroll,
        child = child,
        label = label,
        contentWidth = contentWidth,
        viewHeight = height,
    }
end

local function setScrollableText(view, text, reset)
    if not view then return end
    view.label:SetText(text or "")
    view.label:SetDimensions(view.contentWidth, 1000)
    local contentHeight = math.max(view.viewHeight, math.ceil(view.label:GetTextHeight() + 6))
    view.label:SetDimensions(view.contentWidth, contentHeight)
    updateNativeScroll(view.scroll, view.child, view.contentWidth, contentHeight, reset ~= false)
end

local function forwardWheel(scroll)
    return function(_, delta)
        ZO_Scroll_OnMouseWheel(scroll, delta)
    end
end

local function findCurrentDungeon()
    return DMC.GetCurrentDungeon()
end

local function getCurrentBoss()
    local dungeon = DMC.GetDungeonById(UI.selectedDungeonId)
    return dungeon, DMC.GetBossById(dungeon, UI.selectedBossId)
end

local function refreshNoteControls()
    if not UI.noteEdit then return end
    local dungeon, boss = getCurrentBoss()
    local hasBoss = dungeon ~= nil and boss ~= nil
    local text = UI.noteEdit:GetText() or ""
    local dirty = hasBoss and text ~= (UI.noteOriginal or "")
    local count = ZoUTF8StringLength(text)

    UI.noteCounter:SetText(string.format("%d / %d", count, DMC.personalNoteMaxChars or 900))
    if not hasBoss then
        UI.noteStatus:SetText("SELECT A BOSS")
        UI.noteStatus:SetColor(unpack(C.quiet))
    elseif dirty then
        UI.noteStatus:SetText("UNSAVED")
        UI.noteStatus:SetColor(unpack(C.warning))
    else
        UI.noteStatus:SetText(text ~= "" and "SAVED" or "")
        UI.noteStatus:SetColor(unpack(C.ok))
    end

    setButtonEnabled(UI.noteSave, dirty)
    setButtonEnabled(UI.noteRevert, dirty)
    local chatLines = hasBoss and DMC.BuildBossNoteChatLines(text) or {}
    if UI.notePasteLabel then UI.notePasteLabel:SetHidden(#chatLines == 0) end
    for index, button in ipairs(UI.notePasteButtons) do
        local line = chatLines[index]
        setPasteButton(button, line, tostring(index))
        setButtonEnabled(button, line ~= nil)
    end
    UI.noteEdit:SetEditEnabled(hasBoss)
end

local function loadCurrentBossNote()
    if not UI.noteEdit then return end
    local dungeon, boss = getCurrentBoss()
    local mode = DMC.GetDifficultyMode(UI.mode)
    local text = boss and DMC.GetBossNote(dungeon.id, boss.id, mode) or ""
    UI.noteLoading = true
    UI.noteEdit:SetText(text)
    UI.noteLoading = false
    UI.noteOriginal = text
    UI.noteLoadedDungeonId = dungeon and dungeon.id or nil
    UI.noteLoadedBossId = boss and boss.id or nil
    UI.noteLoadedMode = boss and mode or nil
    if UI.noteTitle then
        UI.noteTitle:SetText(mode == "vet" and "PERSONAL NOTES · VET" or "PERSONAL NOTES · HM")
    end
    refreshNoteControls()
end

function DMC.SavePersonalBossNote(showStatus)
    if not UI.noteEdit then return end
    local dungeon, boss = getCurrentBoss()
    local dungeonId = UI.noteLoadedDungeonId or (dungeon and dungeon.id)
    local bossId = UI.noteLoadedBossId or (boss and boss.id)
    local mode = UI.noteLoadedMode or UI.mode
    if not dungeonId or not bossId then return end

    local saved = DMC.SetBossNote(dungeonId, bossId, UI.noteEdit:GetText(), mode)
    if UI.noteEdit:GetText() ~= saved then
        UI.noteLoading = true
        UI.noteEdit:SetText(saved)
        UI.noteLoading = false
    end
    UI.noteOriginal = saved
    refreshNoteControls()
    if showStatus ~= false then
        UI.noteStatus:SetText(saved ~= "" and "SAVED" or "CLEARED")
        UI.noteStatus:SetColor(unpack(C.ok))
    end
end

local function saveCurrentNoteIfDirty()
    if UI.noteEdit and not UI.noteLoading and UI.noteLoadedBossId then
        if (UI.noteEdit:GetText() or "") ~= (UI.noteOriginal or "") then
            DMC.SavePersonalBossNote(false)
        end
    end
end

local function revertPersonalBossNote()
    if not UI.noteEdit then return end
    UI.noteLoading = true
    UI.noteEdit:SetText(UI.noteOriginal or "")
    UI.noteLoading = false
    refreshNoteControls()
    UI.noteStatus:SetText("REVERTED")
    UI.noteStatus:SetColor(unpack(C.muted))
end

local function pastePersonalBossNoteChunk(control)
    local chatText = control and control.chatText
    if not UI.noteEdit or not chatText then return end
    DMC.SavePersonalBossNote(false)
    DMC.PasteBossNoteToChat(chatText)
end

local function setDungeonButtonState(button, selected, current)
    if not button then return end
    button.isSelected = selected
    button.isCurrent = current

    -- Auto-detection is indicated purely by typography now: green + bold.
    -- Keep that treatment even when the detected dungeon is also selected.
    if current then
        button:SetFont("ZoFontGameBold")
        button:SetNormalFontColor(0.48, 0.95, 0.65, 1)
    else
        button:SetFont("ZoFontGame")
        if selected then
            button:SetNormalFontColor(0.52, 0.93, 1, 1)
        else
            button:SetNormalFontColor(0.76, 0.82, 0.86, 1)
        end
    end

    if selected then
        button.bg:SetCenterColor(unpack(C.rowSelected))
        button.accent:SetColor(unpack(C.edge))
        button.accent:SetHidden(false)
    elseif current then
        button.bg:SetCenterColor(0.028, 0.068, 0.060, 0.97)
        button.accent:SetColor(unpack(C.ok))
        button.accent:SetHidden(false)
    else
        button.bg:SetCenterColor(unpack(C.row))
        button.accent:SetHidden(true)
    end
end

local function ensureDungeonButton(index)
    if UI.dungeonButtons[index] then return UI.dungeonButtons[index] end
    local button = makeButton(UI.dungeonListChild, "DMC_DungeonButton" .. index, "", function(control)
        if control.dungeonId then DMC.SelectDungeon(control.dungeonId) end
    end, "ZoFontGame")
    button:SetDimensions(DUNGEON_CONTENT_WIDTH, 29)
    button:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    button:SetHandler("OnMouseWheel", forwardWheel(UI.dungeonListScroll))

    button.bg = wm:CreateControl("DMC_DungeonButton" .. index .. "Bg", button, CT_BACKDROP)
    button.bg:SetAnchorFill(button)
    button.bg:SetCenterColor(unpack(C.row))
    button.bg:SetEdgeColor(0, 0, 0, 0)
    button.bg:SetMouseEnabled(false)
    button.bg:SetDrawLayer(DL_BACKGROUND)

    button.accent = wm:CreateControl("DMC_DungeonButton" .. index .. "Accent", button, CT_TEXTURE)
    button.accent:SetAnchor(TOPLEFT, button, TOPLEFT, 2, 3)
    button.accent:SetAnchor(BOTTOMLEFT, button, BOTTOMLEFT, 2, -3)
    button.accent:SetWidth(3)
    button.accent:SetHidden(true)

    button:SetHandler("OnMouseEnter", function(control)
        if not control.isSelected and not control.isCurrent then
            control.bg:SetCenterColor(unpack(C.rowHover))
        end
    end)
    button:SetHandler("OnMouseExit", function(control)
        setDungeonButtonState(control, control.isSelected, control.isCurrent)
    end)

    UI.dungeonButtons[index] = button
    return button
end

local function updateBossButtonText(button, activeChevron)
    if not button or not button.bossName then return end
    local chevron = activeChevron and "|c75E6FF›|r  " or "|c5B6D78›|r  "
    button:SetText(chevron .. button.bossName .. (button.bossFlagsMarkup or ""))
end

local function setBossButtonState(button, selected)
    if not button then return end
    button.isSelected = selected
    if selected then
        button:SetNormalFontColor(0.52, 0.93, 1, 1)
        button.bg:SetCenterColor(unpack(C.rowSelected))
        button.accent:SetHidden(false)
    else
        button:SetNormalFontColor(0.78, 0.82, 0.85, 1)
        button.bg:SetCenterColor(0.018, 0.032, 0.042, 0.72)
        button.accent:SetHidden(true)
    end
    updateBossButtonText(button, selected or button.isHovered)
end

local function ensureMechanicRow(index)
    if UI.mechanicRows[index] then return UI.mechanicRows[index] end
    local row = wm:CreateControl("DMC_MechanicRow" .. index, UI.mechanicsChild, CT_CONTROL)
    row:SetDimensions(MECHANIC_CONTENT_WIDTH, 104)
    row:SetMouseEnabled(true)
    row:SetHandler("OnMouseWheel", forwardWheel(UI.mechanicsScroll))
    local rowColor = index % 2 == 1 and C.mechanic or C.mechanicAlt
    row.bg = makeBackdrop(row, "DMC_MechanicRow" .. index .. "Bg", rowColor, {0, 0, 0, 0}, 0)
    row.bg:SetEdgeColor(0, 0, 0, 0)

    row.header = wm:CreateControl("DMC_MechanicHeader" .. index, row, CT_BACKDROP)
    row.header:SetAnchor(TOPLEFT, row, TOPLEFT, 1, 1)
    row.header:SetAnchor(TOPRIGHT, row, TOPRIGHT, -1, 1)
    row.header:SetHeight(34)
    row.header:SetCenterColor(unpack(C.mechanicHeader))
    row.header:SetEdgeColor(0, 0, 0, 0)
    row.header:SetMouseEnabled(false)
    row.header:SetDrawLayer(DL_BACKGROUND)
    row.header:SetDrawLevel(2)

    row.headerRule = wm:CreateControl("DMC_MechanicHeaderRule" .. index, row.header, CT_TEXTURE)
    row.headerRule:SetAnchor(BOTTOMLEFT, row.header, BOTTOMLEFT, 0, 0)
    row.headerRule:SetAnchor(BOTTOMRIGHT, row.header, BOTTOMRIGHT, 0, 0)
    row.headerRule:SetHeight(1)
    row.headerRule:SetColor(0.72, 0.51, 0.16, 0.48)

    row.bottomRule = wm:CreateControl("DMC_MechanicBottomRule" .. index, row, CT_TEXTURE)
    row.bottomRule:SetAnchor(BOTTOMLEFT, row, BOTTOMLEFT, 3, 0)
    row.bottomRule:SetAnchor(BOTTOMRIGHT, row, BOTTOMRIGHT, 0, 0)
    row.bottomRule:SetHeight(1)
    row.bottomRule:SetColor(0.08, 0.22, 0.28, 0.24)
    row.bottomRule:SetDrawLayer(DL_OVERLAY)
    row.bottomRule:SetDrawLevel(20)

    row.actionSurface = wm:CreateControl("DMC_MechanicActionSurface" .. index, row, CT_BACKDROP)
    row.actionSurface:SetAnchor(TOPRIGHT, row, TOPRIGHT, -1, 35)
    row.actionSurface:SetAnchor(BOTTOMRIGHT, row, BOTTOMRIGHT, -1, -1)
    row.actionSurface:SetWidth(94)
    row.actionSurface:SetCenterColor(unpack(C.mechanicAction))
    row.actionSurface:SetEdgeColor(0, 0, 0, 0)
    row.actionSurface:SetMouseEnabled(false)
    row.actionSurface:SetDrawLayer(DL_BACKGROUND)
    row.actionSurface:SetDrawLevel(3)

    row.actionDivider = wm:CreateControl("DMC_MechanicActionDivider" .. index, row.actionSurface, CT_TEXTURE)
    row.actionDivider:SetAnchor(TOPLEFT, row.actionSurface, TOPLEFT, 0, 0)
    row.actionDivider:SetAnchor(BOTTOMLEFT, row.actionSurface, BOTTOMLEFT, 0, 0)
    row.actionDivider:SetWidth(1)
    row.actionDivider:SetColor(unpack(C.passiveRule))
    row.actionDivider:SetDrawLayer(DL_OVERLAY)
    row.actionDivider:SetDrawLevel(20)

    row.accent = wm:CreateControl("DMC_MechanicAccent" .. index, row, CT_TEXTURE)
    row.accent:SetAnchor(TOPLEFT, row, TOPLEFT, 1, 1)
    row.accent:SetAnchor(BOTTOMLEFT, row, BOTTOMLEFT, 1, -1)
    row.accent:SetWidth(3)
    row.accent:SetColor(1.00, 0.72, 0.24, 0.82)
    row.accent:SetDrawLayer(DL_OVERLAY)
    row.accent:SetDrawLevel(240)

    row.title = makeLabel(row, "DMC_MechanicTitle" .. index, "", "ZoFontGameBold", C.gold, true)
    row.title:SetAnchor(TOPLEFT, row, TOPLEFT, 14, 7)
    row.title:SetDimensions(MECHANIC_CONTENT_WIDTH - 128, 24)

    row.number = makeLabel(row, "DMC_MechanicNumber" .. index, "", "ZoFontGameBold", C.quiet, true)
    row.number:SetAnchor(TOPRIGHT, row, TOPRIGHT, -14, 9)
    row.number:SetDimensions(44, 20)
    row.number:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)

    row.lines = {}
    row.pasteButtons = {}
    for lineIndex = 1, 3 do
        local label = makeLabel(row, "DMC_MechanicLine" .. index .. "_" .. lineIndex, "", FONT_BODY, C.bodyText, false)
        row.lines[lineIndex] = label
        local paste = makePasteIconButton(row, "DMC_MechanicPaste" .. index .. "_" .. lineIndex, function(control)
            if control.chatText then
                UI.selectedChatLine = control.chatText
                DMC.PasteToChatInput(control.chatText)
            end
        end)
        paste:SetDimensions(42, 26)
        paste:SetHandler("OnMouseWheel", forwardWheel(UI.mechanicsScroll))
        row.pasteButtons[lineIndex] = paste
    end

    UI.mechanicRows[index] = row
    return row
end

local function layoutMechanicRow(row, chatLines)
    local bodyWidth = MECHANIC_CONTENT_WIDTH - 122
    local y = 41
    local visible = math.min(#chatLines, 3)
    if visible == 0 then
        visible = 1
        chatLines = {"No written mechanic text matches this view."}
    end

    for lineIndex = 1, 3 do
        local label = row.lines[lineIndex]
        local paste = row.pasteButtons[lineIndex]
        local line = chatLines[lineIndex]
        if line then
            label:ClearAnchors()
            label:SetAnchor(TOPLEFT, row, TOPLEFT, 15, y)
            label:SetText(stripForUI(line))
            label:SetDimensions(bodyWidth, 160)
            local textHeight = math.max(22, math.ceil(label:GetTextHeight()))
            label:SetDimensions(bodyWidth, textHeight)
            label:SetHidden(false)

            paste:ClearAnchors()
            paste:SetAnchor(TOPRIGHT, row, TOPRIGHT, -26, y)
            setPasteButton(paste, line, visible > 1 and ("PASTE " .. tostring(lineIndex)) or "PASTE")
            y = y + math.max(textHeight, 26) + 8
        else
            label:SetText("")
            label:SetHidden(true)
            setPasteButton(paste, nil)
        end
    end

    local rowHeight = math.max(96, y + 9)
    row:SetDimensions(MECHANIC_CONTENT_WIDTH, rowHeight)
    return rowHeight
end

function DMC.InitializeUI()
    local session = getSessionState()
    UI.roleFilter = isValidRoleFilter(session.roleFilter) and session.roleFilter or "all"
    UI.mode = DMC.GetDifficultyMode(DMC.sv and DMC.sv.mode or "hm")
    UI.activityType = (session.activityType == "trial" or session.activityType == "arena")
        and session.activityType or "dungeon"
    UI.selectedDungeonId = session.selectedDungeonId
    UI.selectedBossId = session.selectedBossId

    local window = wm:CreateTopLevelWindow("DMC_MainWindow")
    UI.window = window
    window:SetDimensions(WINDOW_WIDTH, WINDOW_HEIGHT)
    local savedWindow = DMC.sv and DMC.sv.window or nil
    if savedWindow and savedWindow.x and savedWindow.y and (savedWindow.x ~= 0 or savedWindow.y ~= 0) then
        window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, savedWindow.x, savedWindow.y)
    else
        window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    end
    window:SetMouseEnabled(true)
    window:SetMovable(true)
    window:SetClampedToScreen(true)
    window:SetHidden(true)
    window:SetDrawLayer(DL_OVERLAY)
    window:SetDrawTier(DT_HIGH)
    window:SetDrawLevel(100)
    window:SetHandler("OnMoveStop", function()
        if DMC.sv and DMC.sv.window then
            DMC.sv.window.x = window:GetLeft()
            DMC.sv.window.y = window:GetTop()
        end
    end)

    makeBackdrop(window, "DMC_MainWindowBackdrop", C.bg, {0, 0, 0, 0}, WINDOW_INSET)

    -- Paste and difficulty hints belong to the Codex window itself. This keeps
    -- them above the addon's high draw tier without invoking ESO's shared tooltip.
    UI.compactHint = wm:CreateControl("DMC_CompactHint", window, CT_BACKDROP)
    UI.compactHint:SetDimensions(54, 20)
    UI.compactHint:SetCenterTexture("EsoUI/Art/Tooltips/UI-TooltipCenter.dds")
    UI.compactHint:SetEdgeTexture("EsoUI/Art/Tooltips/UI-Tooltip-Border.dds", 128, 16)
    UI.compactHint:SetInsets(5, 5, -5, -5)
    UI.compactHint:SetCenterColor(0.008, 0.019, 0.026, 0.98)
    UI.compactHint:SetEdgeColor(0.14, 0.38, 0.46, 0.88)
    UI.compactHint:SetMouseEnabled(false)
    UI.compactHint:SetDrawLayer(DL_OVERLAY)
    UI.compactHint:SetDrawLevel(480)
    UI.compactHint:SetHidden(true)
    UI.compactHintLabel = makeLabel(UI.compactHint, "DMC_CompactHintLabel", "", "$(MEDIUM_FONT)|11|soft-shadow-thin", C.muted, true)
    UI.compactHintLabel:SetAnchorFill(UI.compactHint)
    UI.compactHintLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    UI.compactHintLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    UI.compactHintLabel:SetDrawLayer(DL_OVERLAY)
    UI.compactHintLabel:SetDrawLevel(490)

    -- The tooltip-center texture used by the outer backdrop is translucent.
    -- This inset surface keeps the visible body aligned with the header and
    -- signature frame instead of exposing uneven strips of the game world.
    UI.bodySurface = wm:CreateControl("DMC_MainBodySurface", window, CT_BACKDROP)
    UI.bodySurface:SetAnchor(TOPLEFT, window, TOPLEFT, WINDOW_INSET, WINDOW_INSET + 52)
    UI.bodySurface:SetAnchor(BOTTOMRIGHT, window, BOTTOMRIGHT, -WINDOW_INSET, -WINDOW_INSET)
    UI.bodySurface:SetCenterColor(0.003, 0.007, 0.011, 0.94)
    UI.bodySurface:SetEdgeColor(0, 0, 0, 0)
    UI.bodySurface:SetMouseEnabled(false)
    UI.bodySurface:SetDrawLayer(DL_BACKGROUND)
    UI.bodySurface:SetDrawLevel(1)
    makeWindowStroke(window, "DMC_MainWindowStroke", 2, WINDOW_INSET, C.edge)

    local header = wm:CreateControl("DMC_MainHeader", window, CT_BACKDROP)
    UI.header = header
    header:SetAnchor(TOPLEFT, window, TOPLEFT, WINDOW_INSET, WINDOW_INSET)
    header:SetAnchor(TOPRIGHT, window, TOPRIGHT, -WINDOW_INSET, WINDOW_INSET)
    header:SetHeight(52)
    header:SetCenterColor(unpack(C.header))
    header:SetEdgeColor(0, 0, 0, 0)
    header:SetDrawLayer(DL_BACKGROUND)
    header:SetDrawLevel(0)
    local headerGlow = wm:CreateControl("DMC_HeaderGlow", header, CT_TEXTURE)
    headerGlow:SetAnchor(BOTTOMLEFT, header, BOTTOMLEFT, 0, 0)
    headerGlow:SetAnchor(BOTTOMRIGHT, header, BOTTOMRIGHT, 0, 0)
    headerGlow:SetHeight(2)
    headerGlow:SetColor(unpack(C.edge))

    UI.brand = makeLabel(window, "DMC_Brand", "FLAMECHASERS", "ZoFontGameSmall", C.title, true)
    UI.brand:SetAnchor(TOPLEFT, window, TOPLEFT, 20, 11)
    UI.brand:SetDimensions(170, 17)
    UI.title = makeLabel(window, "DMC_Title", "DUNGEON, TRIAL & ARENA CODEX", "ZoFontGameBold", C.text, true)
    UI.title:SetAnchor(TOPLEFT, window, TOPLEFT, 20, 27)
    UI.title:SetDimensions(350, 22)
    UI.tagline = makeLabel(window, "DMC_Tagline", "Boss mechanics. Role-ready. Paste-ready.", "ZoFontGameSmall", C.muted, true)
    UI.tagline:SetAnchor(LEFT, UI.title, RIGHT, 14, 0)
    UI.tagline:SetDimensions(330, 22)

    UI.close = makeButton(window, "DMC_Close", "", function() DMC.HideWindow() end)
    UI.close:SetAnchor(TOPRIGHT, window, TOPRIGHT, -16, 17)
    UI.close:SetDimensions(32, 32)
    UI.close:SetDrawLayer(DL_OVERLAY)
    UI.close:SetDrawLevel(200)
    UI.closeIcon = wm:CreateControl("DMC_CloseIcon", UI.close, CT_TEXTURE)
    UI.closeIcon:SetAnchor(CENTER, UI.close, CENTER, 0, 0)
    UI.closeIcon:SetDimensions(20, 20)
    UI.closeIcon:SetTexture("DungeonMechsCodex/close_icon.dds")
    UI.closeIcon:SetColor(0.90, 0.94, 1, 1)
    UI.closeIcon:SetDrawLayer(DL_OVERLAY)
    UI.closeIcon:SetDrawLevel(210)
    UI.close:SetHandler("OnMouseEnter", function() UI.closeIcon:SetColor(0.48, 0.91, 1, 1) end)
    UI.close:SetHandler("OnMouseExit", function() UI.closeIcon:SetColor(0.90, 0.94, 1, 1) end)

    UI.leftPanel = makePanel(window, "DMC_LeftPanel", LEFT_X, CONTENT_Y, LEFT_WIDTH, CONTENT_HEIGHT, C.panel)
    UI.sidebarDivider = wm:CreateControl("DMC_SidebarDivider", UI.leftPanel, CT_TEXTURE)
    UI.sidebarDivider:SetAnchor(TOPRIGHT, UI.leftPanel, TOPRIGHT, 0, 0)
    UI.sidebarDivider:SetAnchor(BOTTOMRIGHT, UI.leftPanel, BOTTOMRIGHT, 0, 0)
    UI.sidebarDivider:SetWidth(1)
    UI.sidebarDivider:SetColor(unpack(C.structuralRule))
    UI.sidebarDivider:SetDrawLayer(DL_OVERLAY)
    UI.sidebarDivider:SetDrawLevel(20)
    makeSectionBand(UI.leftPanel, "DMC_LeftPanelHeader", 34)
    UI.dungeonSectionTitle = makeLabel(UI.leftPanel, "DMC_DungeonSectionTitle", "ACTIVITIES", FONT_SECTION, C.title, true)
    UI.dungeonSectionIcon = createHeaderIcon(UI.leftPanel, "DMC_DungeonSectionIcon", "list", C.title)
    UI.dungeonSectionIcon:SetAnchor(TOPLEFT, UI.leftPanel, TOPLEFT, 14, 11)
    UI.dungeonSectionTitle:SetAnchor(LEFT, UI.dungeonSectionIcon, RIGHT, 7, 0)
    UI.dungeonSectionTitle:SetDimensions(140, 22)
    UI.dungeonCount = makeLabel(UI.leftPanel, "DMC_DungeonCount", "", FONT_META, C.quiet, true)
    UI.dungeonCount:SetAnchor(TOPRIGHT, UI.leftPanel, TOPRIGHT, -14, 13)
    UI.dungeonCount:SetDimensions(96, 20)
    UI.dungeonCount:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)

    UI.searchBg = wm:CreateControlFromVirtual("DMC_SearchBackdrop", UI.leftPanel, "ZO_SingleLineEditBackdrop_Keyboard")
    UI.searchBg:SetAnchor(TOPLEFT, UI.leftPanel, TOPLEFT, 14, 37)
    UI.searchBg:SetDimensions(248, 34)
    UI.searchBg:SetCenterColor(0.008, 0.017, 0.024, 1)
    UI.searchBg:SetEdgeColor(unpack(C.fieldEdge))
    UI.search = wm:CreateControlFromVirtual("DMC_SearchBox", UI.searchBg, "ZO_DefaultEditForBackdrop")
    UI.search:SetAnchor(TOPLEFT, UI.searchBg, TOPLEFT, 22, 0)
    UI.search:SetAnchor(BOTTOMRIGHT, UI.searchBg, BOTTOMRIGHT, 0, 0)
    UI.search:SetColor(0.88, 0.92, 0.95, 1)
    UI.search:SetMaxInputChars(50)
    UI.search:SetDefaultText("Search name, DLC, chapter...")
    UI.searchIcon = wm:CreateControl("DMC_SearchIcon", UI.searchBg, CT_TEXTURE)
    UI.searchIcon:SetAnchor(LEFT, UI.searchBg, LEFT, 6, 0)
    UI.searchIcon:SetDimensions(14, 14)
    UI.searchIcon:SetTexture("EsoUI/Art/TradingHouse/tradinghouse_searchicon_up.dds")
    UI.searchIcon:SetColor(0.42, 0.52, 0.60, 0.82)
    UI.searchIcon:SetMouseEnabled(false)
    UI.searchIcon:SetDrawLayer(DL_OVERLAY)
    UI.searchIcon:SetDrawLevel(22)
    UI.search:SetHandler("OnTextChanged", function(edit)
        UI.searchText = edit:GetText() or ""
        DMC.RefreshDungeonList(true)
    end)
    UI.searchFocused = false
    ZO_PostHookHandler(UI.search, "OnMouseEnter", function()
        if not UI.searchFocused then UI.searchBg:SetCenterColor(0.012, 0.026, 0.036, 1) end
    end)
    ZO_PostHookHandler(UI.search, "OnMouseExit", function()
        if not UI.searchFocused then UI.searchBg:SetCenterColor(0.008, 0.017, 0.024, 1) end
    end)
    ZO_PostHookHandler(UI.search, "OnFocusGained", function()
        UI.searchFocused = true
        UI.searchBg:SetCenterColor(0.014, 0.032, 0.044, 1)
        UI.searchBg:SetEdgeColor(unpack(C.fieldFocus))
    end)
    ZO_PostHookHandler(UI.search, "OnFocusLost", function()
        UI.searchFocused = false
        UI.searchBg:SetCenterColor(0.008, 0.017, 0.024, 1)
        UI.searchBg:SetEdgeColor(unpack(C.fieldEdge))
    end)

    UI.activityGroup = wm:CreateControl("DMC_ActivityGroup", UI.leftPanel, CT_CONTROL)
    UI.activityGroup:SetAnchor(TOPLEFT, UI.leftPanel, TOPLEFT, 14, 77)
    UI.activityGroup:SetDimensions(248, 25)
    UI.activityGroupBg = wm:CreateControl("DMC_ActivityGroupBg", UI.activityGroup, CT_BACKDROP)
    UI.activityGroupBg:SetAnchorFill(UI.activityGroup)
    UI.activityGroupBg:SetCenterColor(0.007, 0.016, 0.022, 1)
    UI.activityGroupBg:SetEdgeColor(unpack(C.pillEdge))
    UI.activityDungeon = makeSegmentButton(UI.activityGroup, "DMC_ActivityDungeon", "DUNGEONS", function()
        DMC.SetActivityType("dungeon")
    end, FONT_META_BOLD)
    UI.activityDungeon:SetAnchor(TOPLEFT, UI.activityGroup, TOPLEFT, 0, 0)
    UI.activityDungeon:SetDimensions(83, 25)
    UI.activityTrial = makeSegmentButton(UI.activityGroup, "DMC_ActivityTrial", "TRIALS", function()
        DMC.SetActivityType("trial")
    end, FONT_META_BOLD)
    UI.activityTrial:SetAnchor(TOPLEFT, UI.activityGroup, TOPLEFT, 83, 0)
    UI.activityTrial:SetDimensions(82, 25)
    UI.activityArena = makeSegmentButton(UI.activityGroup, "DMC_ActivityArena", "ARENAS", function()
        DMC.SetActivityType("arena")
    end, FONT_META_BOLD)
    UI.activityArena:SetAnchor(TOPLEFT, UI.activityGroup, TOPLEFT, 165, 0)
    UI.activityArena:SetDimensions(83, 25)
    for index, x in ipairs({83, 165}) do
        local divider = wm:CreateControl("DMC_ActivityDivider" .. index, UI.activityGroup, CT_TEXTURE)
        divider:SetAnchor(TOPLEFT, UI.activityGroup, TOPLEFT, x, 4)
        divider:SetAnchor(BOTTOMLEFT, UI.activityGroup, BOTTOMLEFT, x, -4)
        divider:SetWidth(1)
        divider:SetColor(unpack(C.passiveRule))
        divider:SetDrawLayer(DL_OVERLAY)
    end
    setSelectedButton(UI.activityDungeon, UI.activityType == "dungeon")
    setSelectedButton(UI.activityTrial, UI.activityType == "trial")
    setSelectedButton(UI.activityArena, UI.activityType == "arena")

    UI.dungeonListScroll, UI.dungeonListChild = makeNativeScroll(UI.leftPanel, "DMC_DungeonList", 14, 109, 248, 647)
    UI.noDungeons = makeLabel(UI.dungeonListChild, "DMC_NoDungeons", "No matching activities.", "ZoFontGameSmall", C.muted, true)
    UI.noDungeons:SetAnchor(TOPLEFT, UI.dungeonListChild, TOPLEFT, 8, 8)
    UI.noDungeons:SetDimensions(DUNGEON_CONTENT_WIDTH - 16, 24)
    UI.noDungeons:SetHidden(true)

    UI.dungeonPanel = makePanel(window, "DMC_DungeonPanel", RIGHT_X, CONTENT_Y, RIGHT_WIDTH, 112, C.panel2)
    makeSectionBand(UI.dungeonPanel, "DMC_DungeonPanelHeader", 38)
    UI.dungeonArt = wm:CreateControl("DMC_DungeonArt", UI.dungeonPanel, CT_TEXTURE)
    UI.dungeonArt:SetAnchor(TOPLEFT, UI.dungeonPanel, TOPLEFT, 1, 1)
    UI.dungeonArt:SetAnchor(BOTTOMRIGHT, UI.dungeonPanel, BOTTOMRIGHT, -1, -1)
    UI.dungeonArt:SetResizeToFitFile(false)
    UI.dungeonArt:SetTextureCoords(0, 0.6836, 0.41, 0.575)
    UI.dungeonArt:SetGradientColors(ORIENTATION_HORIZONTAL,
        0.15, 0.27, 0.31, 0.07,
        0.34, 0.54, 0.61, 0.17)
    UI.dungeonArt:SetMouseEnabled(false)
    UI.dungeonArt:SetDrawLayer(DL_BACKGROUND)
    UI.dungeonArt:SetDrawLevel(3)
    UI.dungeonArt:SetHidden(true)
    UI.dungeonIcon = wm:CreateControl("DMC_DungeonIcon", UI.dungeonPanel, CT_TEXTURE)
    UI.dungeonIcon:SetAnchor(TOPLEFT, UI.dungeonPanel, TOPLEFT, 16, 6)
    UI.dungeonIcon:SetDimensions(28, 28)
    UI.dungeonIcon:SetTexture(ZO_GetZoneDisplayTypeIcon(ZONE_DISPLAY_TYPE_DUNGEON))
    UI.dungeonIcon:SetColor(unpack(C.title))
    UI.dungeonIcon:SetMouseEnabled(false)
    UI.dungeonIcon:SetDrawLayer(DL_OVERLAY)
    UI.dungeonIcon:SetDrawLevel(24)
    UI.dungeonIcon:SetHidden(true)
    UI.dungeonTitle = makeLabel(UI.dungeonPanel, "DMC_DungeonTitle", "Select an activity", "ZoFontWinH2", C.title, true)
    UI.dungeonTitle:SetAnchor(TOPLEFT, UI.dungeonPanel, TOPLEFT, DUNGEON_TITLE_X, 10)
    UI.dungeonTitle:SetDimensions(500, 30)
    UI.dungeonDlc = makeLabel(UI.dungeonPanel, "DMC_DungeonDlc", "", FONT_META_BOLD, C.quiet, true)
    UI.dungeonDlc:SetAnchor(LEFT, UI.dungeonTitle, RIGHT, 10, 1)
    UI.dungeonDlc:SetDimensions(190, 20)
    UI.statusLabel = makeLabel(UI.dungeonPanel, "DMC_StatusLabel", "HARD MODE", FONT_META_BOLD, C.ok, true)
    UI.statusLabel:SetAnchor(TOPRIGHT, UI.dungeonPanel, TOPRIGHT, -14, 12)
    UI.statusLabel:SetDimensions(210, 20)
    UI.statusLabel:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    UI.statusLabel:SetHidden(true)
    UI.dungeonSummaryView = makeScrollableText(UI.dungeonPanel, "DMC_DungeonSummary", 16, 43, 904, 55, FONT_BODY, C.bodyText)

    UI.modeGroup = wm:CreateControl("DMC_ModeGroup", UI.dungeonPanel, CT_CONTROL)
    UI.modeGroup:SetDimensions(92, 25)
    UI.modeGroup:SetHidden(true)
    UI.modeGroupBg = wm:CreateControl("DMC_ModeGroupBg", UI.modeGroup, CT_BACKDROP)
    UI.modeGroupBg:SetAnchorFill(UI.modeGroup)
    UI.modeGroupBg:SetCenterColor(unpack(C.segment))
    UI.modeGroupBg:SetEdgeColor(0, 0, 0, 0)
    UI.modeGroupBg:SetMouseEnabled(false)
    UI.modeGroupBg:SetDrawLayer(DL_BACKGROUND)
    UI.modeGroupBg:SetDrawLevel(5)
    UI.modeGroupFrame = makeWindowStroke(UI.modeGroup, "DMC_ModeGroupFrame", 1, 0, C.pillEdge)

    UI.modeVet = makeSegmentButton(UI.modeGroup, "DMC_ModeVet", "VET", function()
        DMC.SetDifficultyMode("vet")
    end, FONT_META_BOLD)
    UI.modeVet:SetAnchor(TOPLEFT, UI.modeGroup, TOPLEFT, 0, 0)
    UI.modeVet:SetDimensions(46, 25)
    UI.modeHm = makeSegmentButton(UI.modeGroup, "DMC_ModeHm", "HM", function()
        DMC.SetDifficultyMode("hm")
    end, FONT_META_BOLD)
    UI.modeHm:SetAnchor(TOPLEFT, UI.modeGroup, TOPLEFT, 46, 0)
    UI.modeHm:SetDimensions(46, 25)
    UI.modeSeparator = wm:CreateControl("DMC_ModeSeparator", UI.modeGroup, CT_TEXTURE)
    UI.modeSeparator:SetAnchor(TOPLEFT, UI.modeGroup, TOPLEFT, 46, 4)
    UI.modeSeparator:SetAnchor(BOTTOMLEFT, UI.modeGroup, BOTTOMLEFT, 46, -4)
    UI.modeSeparator:SetWidth(1)
    UI.modeSeparator:SetColor(unpack(C.passiveRule))
    UI.modeSeparator:SetDrawLayer(DL_OVERLAY)
    UI.modeSeparator:SetDrawLevel(28)
    ZO_PostHookHandler(UI.modeVet, "OnMouseEnter", function(control)
        showCompactHint(control, "Veteran")
    end)
    ZO_PostHookHandler(UI.modeVet, "OnMouseExit", hideCompactHint)
    ZO_PostHookHandler(UI.modeHm, "OnMouseEnter", function(control)
        showCompactHint(control, "Hard Mode")
    end)
    ZO_PostHookHandler(UI.modeHm, "OnMouseExit", hideCompactHint)

    for index = 1, 4 do
        local paste = makePasteIconButton(UI.dungeonPanel, "DMC_DungeonPaste" .. index, function(control)
            if control.chatText then DMC.PasteToChatInput(control.chatText) end
        end)
        paste:SetAnchor(TOPLEFT, UI.dungeonPanel, TOPLEFT, 878, 7)
        paste:SetDimensions(42, 25)
        UI.dungeonPasteButtons[index] = paste
    end
    UI.dungeonPasteLabel = makeLabel(UI.dungeonPanel, "DMC_DungeonPasteLabel", "PASTE", FONT_META, C.quiet, true)
    UI.dungeonPasteLabel:SetDimensions(38, 21)
    UI.dungeonPasteLabel:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    UI.dungeonPasteLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    UI.dungeonPasteLabel:SetHidden(true)

    UI.bossListPanel = makePanel(window, "DMC_BossListPanel", RIGHT_X, CONTENT_Y + 122, RIGHT_WIDTH, 120, C.panel2)
    makeSectionBand(UI.bossListPanel, "DMC_BossListPanelHeader", 35)
    UI.bossListTitle = makeLabel(UI.bossListPanel, "DMC_BossListTitle", "BOSSES", FONT_SECTION_SMALL, C.title, true)
    UI.bossListIcon = createHeaderIcon(UI.bossListPanel, "DMC_BossListIcon", "bosses", C.title)
    UI.bossListIcon:SetAnchor(TOPLEFT, UI.bossListPanel, TOPLEFT, 16, 11)
    UI.bossListTitle:SetAnchor(LEFT, UI.bossListIcon, RIGHT, 7, 0)
    UI.bossListTitle:SetDimensions(120, 22)
    UI.bossMeasureLabel = makeLabel(UI.bossListPanel, "DMC_BossMeasureLabel", "", FONT_BOSS_ROW, C.text, true)
    UI.bossMeasureLabel:SetDimensions(900, 20)
    UI.bossMeasureLabel:SetHidden(true)
    UI.roleGroup = wm:CreateControl("DMC_RoleGroup", UI.bossListPanel, CT_CONTROL)
    UI.roleGroup:SetAnchor(TOPRIGHT, UI.bossListPanel, TOPRIGHT, -16, 6)
    UI.roleGroup:SetDimensions(325, 30)
    UI.roleGroupBg = wm:CreateControl("DMC_RoleGroupBg", UI.roleGroup, CT_BACKDROP)
    UI.roleGroupBg:SetAnchorFill(UI.roleGroup)
    UI.roleGroupBg:SetCenterColor(unpack(C.segment))
    UI.roleGroupBg:SetEdgeColor(0, 0, 0, 0)
    UI.roleGroupBg:SetMouseEnabled(false)
    UI.roleGroupBg:SetDrawLayer(DL_BACKGROUND)
    UI.roleGroupBg:SetDrawLevel(5)
    UI.roleGroupFrame = makeWindowStroke(UI.roleGroup, "DMC_RoleGroupFrame", 1, 0, C.pillEdge)

    UI.roleLabel = makeLabel(UI.bossListPanel, "DMC_RoleLabel", "VIEW", FONT_META, C.quiet, true)
    UI.roleLabel:SetAnchor(RIGHT, UI.roleGroup, LEFT, -10, 0)
    UI.roleLabel:SetDimensions(44, 22)
    UI.roleLabel:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    UI.roleLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    local roleDefs = {
        {key = "all", label = "FULL", width = 65},
        {key = "quick", label = "QUICK", width = 65},
        {key = "tank", label = "TANK", width = 65},
        {key = "healer", label = "HEALER", width = 65},
        {key = "dps", label = "DPS", width = 65},
    }
    UI.roleButtons = {}
    UI.roleSeparators = {}
    local x = 0
    for index, def in ipairs(roleDefs) do
        local roleKey = def.key
        local button = makeSegmentButton(UI.roleGroup, "DMC_Role" .. def.key, def.label, function()
            DMC.SetRoleFilter(roleKey)
        end)
        button:SetAnchor(TOPLEFT, UI.roleGroup, TOPLEFT, x, 0)
        button:SetDimensions(def.width, 30)
        if index > 1 then
            local separator = wm:CreateControl("DMC_RoleSeparator" .. index, UI.roleGroup, CT_TEXTURE)
            separator:SetAnchor(TOPLEFT, UI.roleGroup, TOPLEFT, x, 5)
            separator:SetAnchor(BOTTOMLEFT, UI.roleGroup, BOTTOMLEFT, x, -5)
            separator:SetWidth(1)
            separator:SetColor(unpack(C.passiveRule))
            separator:SetDrawLayer(DL_OVERLAY)
            separator:SetDrawLevel(28)
            UI.roleSeparators[def.key] = separator
        end
        UI["role" .. def.key] = button
        UI.roleButtons[def.key] = button
        x = x + def.width
    end

    for index = 1, 12 do
        local button = makeButton(UI.bossListPanel, "DMC_BossButton" .. index, "", function(control)
            if control.bossId then DMC.SelectBoss(control.bossId) end
        end, FONT_BOSS_ROW)
        local column = index <= 4 and 0 or 1
        local row = (index - 1) % 4
        button:SetAnchor(TOPLEFT, UI.bossListPanel, TOPLEFT, 16 + column * 452, 39 + row * 20)
        button:SetDimensions(440, 19)
        button:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        button.bg = wm:CreateControl("DMC_BossButton" .. index .. "Bg", button, CT_BACKDROP)
        button.bg:SetAnchorFill(button)
        button.bg:SetCenterColor(0.018, 0.032, 0.042, 0.78)
        button.bg:SetEdgeColor(0, 0, 0, 0)
        button.bg:SetMouseEnabled(false)
        button.bg:SetDrawLayer(DL_BACKGROUND)
        button.accent = wm:CreateControl("DMC_BossButton" .. index .. "Accent", button, CT_TEXTURE)
        button.accent:SetAnchor(TOPLEFT, button, TOPLEFT, 0, 1)
        button.accent:SetAnchor(BOTTOMLEFT, button, BOTTOMLEFT, 0, -1)
        button.accent:SetWidth(2)
        button.accent:SetColor(unpack(C.edge))
        button.accent:SetHidden(true)

        button:SetHandler("OnMouseEnter", function(control)
            control.isHovered = true
            if not control.isSelected then
                control.bg:SetCenterColor(0.043, 0.079, 0.104, 0.96)
                control:SetNormalFontColor(0.93, 0.95, 0.96, 1)
            end
            updateBossButtonText(control, true)
        end)
        button:SetHandler("OnMouseExit", function(control)
            control.isHovered = false
            setBossButtonState(control, control.isSelected)
        end)
        UI.bossButtons[index] = button
    end

    UI.bossPanel = makePanel(window, "DMC_BossPanel", RIGHT_X, CONTENT_Y + 252, RIGHT_WIDTH, 188, C.panel2)
    makeSectionBand(UI.bossPanel, "DMC_BossSummaryHeader", 39, 1, 535, C.section)
    makeSectionBand(UI.bossPanel, "DMC_NoteHeader", 39, 537, 398, C.sectionAlt)
    local bossDivider = wm:CreateControl("DMC_BossPanelDivider", UI.bossPanel, CT_TEXTURE)
    bossDivider:SetAnchor(TOPLEFT, UI.bossPanel, TOPLEFT, 536, 1)
    bossDivider:SetAnchor(BOTTOMLEFT, UI.bossPanel, BOTTOMLEFT, 536, -1)
    bossDivider:SetWidth(1)
    bossDivider:SetColor(unpack(C.passiveRule))
    bossDivider:SetDrawLayer(DL_OVERLAY)
    bossDivider:SetDrawLevel(20)

    UI.bossTitle = makeLabel(UI.bossPanel, "DMC_BossTitle", "", "ZoFontWinH3", C.title, true)
    UI.bossTitle:SetAnchor(TOPLEFT, UI.bossPanel, TOPLEFT, 16, 10)
    UI.bossTitle:SetDimensions(420, 28)
    UI.bossMeta = makeLabel(UI.bossPanel, "DMC_BossMeta", "", FONT_META_BOLD, C.quiet, true)
    UI.bossMeta:SetDimensions(80, 20)
    for index = 1, 4 do
        local paste = makePasteIconButton(UI.bossPanel, "DMC_BossPaste" .. index, function(control)
            if control.chatText then DMC.PasteToChatInput(control.chatText) end
        end)
        paste:SetDimensions(42, 25)
        UI.bossPasteButtons[index] = paste
    end
    UI.bossSummaryView = makeScrollableText(UI.bossPanel, "DMC_BossSummary", 16, 45, 504, 127, FONT_BODY, C.bodyText)

    UI.noteTitle = makeLabel(UI.bossPanel, "DMC_NoteTitle", "PERSONAL NOTES", FONT_SECTION_SMALL, C.title, true)
    UI.noteIcon = createHeaderIcon(UI.bossPanel, "DMC_NoteIcon", "notes", C.title)
    UI.noteIcon:SetAnchor(TOPLEFT, UI.bossPanel, TOPLEFT, 554, 13)
    UI.noteTitle:SetAnchor(LEFT, UI.noteIcon, RIGHT, 7, -1)
    UI.noteTitle:SetDimensions(164, 22)
    UI.noteStatus = makeLabel(UI.bossPanel, "DMC_NoteStatus", "SELECT A BOSS", FONT_META, C.quiet, true)
    UI.noteStatus:SetAnchor(TOPLEFT, UI.bossPanel, TOPLEFT, 722, 13)
    UI.noteStatus:SetDimensions(98, 20)
    UI.noteStatus:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    UI.noteCounter = makeLabel(UI.bossPanel, "DMC_NoteCounter", "0 / 900", FONT_META, C.quiet, true)
    UI.noteCounter:SetAnchor(TOPRIGHT, UI.bossPanel, TOPRIGHT, -16, 13)
    UI.noteCounter:SetDimensions(96, 20)
    UI.noteCounter:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)

    UI.noteBackdrop = wm:CreateControlFromVirtual("DMC_NoteBackdrop", UI.bossPanel, "ZO_MultiLineEditBackdrop_Keyboard")
    UI.noteBackdrop:SetAnchor(TOPLEFT, UI.bossPanel, TOPLEFT, 554, 43)
    UI.noteBackdrop:SetDimensions(366, 91)
    UI.noteBackdrop:SetCenterColor(0.012, 0.024, 0.032, 1)
    UI.noteBackdrop:SetEdgeColor(unpack(C.fieldEdge))
    UI.noteEdit = wm:CreateControlFromVirtual("DMC_NoteEdit", UI.noteBackdrop, "ZO_DefaultEditMultiLineForBackdrop")
    UI.noteEdit:SetMaxInputChars(DMC.personalNoteMaxChars or 900)
    UI.noteEdit:SetColor(unpack(C.bodyTextSoft))
    UI.noteEdit:SetFont(FONT_BODY)
    UI.noteEdit:SetDefaultText("Write a boss note to keep and paste later...")
    UI.noteEdit:SetHandler("OnTextChanged", function()
        if not UI.noteLoading then refreshNoteControls() end
    end)
    ZO_PostHookHandler(UI.noteEdit, "OnFocusGained", function() UI.noteBackdrop:SetEdgeColor(unpack(C.fieldFocus)) end)
    ZO_PostHookHandler(UI.noteEdit, "OnFocusLost", function() UI.noteBackdrop:SetEdgeColor(unpack(C.fieldEdge)) end)

    UI.noteRevert = makePill(UI.bossPanel, "DMC_NoteRevert", "REVERT", revertPersonalBossNote)
    UI.noteRevert:SetAnchor(TOPLEFT, UI.bossPanel, TOPLEFT, 554, 145)
    UI.noteRevert:SetDimensions(70, 26)
    UI.noteSave = makePill(UI.bossPanel, "DMC_NoteSave", "SAVE", function() DMC.SavePersonalBossNote(true) end)
    UI.noteSave:SetAnchor(LEFT, UI.noteRevert, RIGHT, 6, 0)
    UI.noteSave:SetDimensions(70, 26)
    UI.noteSave.variant = "primary"
    applyPillVisual(UI.noteSave)

    UI.notePasteLabel = makeLabel(UI.bossPanel, "DMC_NotePasteLabel", "", FONT_META, C.quiet, true)
    UI.notePasteLabel:SetAnchor(TOPLEFT, UI.bossPanel, TOPLEFT, 734, 145)
    UI.notePasteLabel:SetDimensions(44, 26)
    UI.notePasteLabel:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    UI.notePasteLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    UI.notePasteLabel:SetHidden(true)

    for index = 1, 4 do
        local paste = makePasteIconButton(UI.bossPanel, "DMC_NotePaste" .. index, pastePersonalBossNoteChunk)
        if index == 1 then
            paste:SetAnchor(TOPLEFT, UI.bossPanel, TOPLEFT, 748, 145)
        else
            paste:SetAnchor(LEFT, UI.notePasteButtons[index - 1], RIGHT, 4, 0)
        end
        paste:SetDimensions(40, 26)
        UI.notePasteButtons[index] = paste
    end

    UI.mechanicsPanel = makePanel(window, "DMC_MechanicsPanel", RIGHT_X, CONTENT_Y + 446, RIGHT_WIDTH, 328, C.panel2)
    makeSectionBand(UI.mechanicsPanel, "DMC_MechanicsPanelHeader", 37)
    UI.mechanicsTitle = makeLabel(UI.mechanicsPanel, "DMC_MechanicsTitle", "MECHANICS", FONT_SECTION_SMALL, C.title, true)
    UI.mechanicsIcon = createHeaderIcon(UI.mechanicsPanel, "DMC_MechanicsIcon", "mechanics", C.title)
    UI.mechanicsIcon:SetAnchor(TOPLEFT, UI.mechanicsPanel, TOPLEFT, 16, 11)
    UI.mechanicsTitle:SetAnchor(LEFT, UI.mechanicsIcon, RIGHT, 7, 0)
    UI.mechanicsTitle:SetDimensions(180, 22)
    UI.mechanicsCount = makeLabel(UI.mechanicsPanel, "DMC_MechanicsCount", "", FONT_META, C.quiet, true)
    UI.mechanicsCount:SetAnchor(TOPRIGHT, UI.mechanicsPanel, TOPRIGHT, -18, 12)
    UI.mechanicsCount:SetDimensions(130, 20)
    UI.mechanicsCount:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    UI.mechanicsScroll, UI.mechanicsChild = makeNativeScroll(UI.mechanicsPanel, "DMC_MechanicsList", 14, 42, 908, 267)

    setSelectedButton(UI.roleall, UI.roleFilter == "all")
    setSelectedButton(UI.rolequick, UI.roleFilter == "quick")
    setSelectedButton(UI.roletank, UI.roleFilter == "tank")
    setSelectedButton(UI.rolehealer, UI.roleFilter == "healer")
    setSelectedButton(UI.roledps, UI.roleFilter == "dps")
    DMC.RefreshDungeonList(true)
    loadCurrentBossNote()
end

local function enterCursorModeForCodex()
    UI.cursorModeWasActiveOnOpen = IsGameCameraUIModeActive()
    UI.cursorModeActivatedByCodex = not UI.cursorModeWasActiveOnOpen
    SetGameCameraUIMode(true)
    zo_callLater(function()
        if UI.window and not UI.window:IsHidden() then SetGameCameraUIMode(true) end
    end, 50)
end

local function restoreCursorModeForCodex()
    local shouldRestore = UI.cursorModeActivatedByCodex
    UI.cursorModeActivatedByCodex = false
    UI.cursorModeWasActiveOnOpen = nil
    if not shouldRestore then return end
    zo_callLater(function()
        if UI.window and UI.window:IsHidden() then SetGameCameraUIMode(false) end
    end, 50)
end

function DMC.ShowWindow()
    if not UI.window then return end
    if UI.window:IsHidden() then UI.window:SetHidden(false) end

    local session = getSessionState()
    if isValidRoleFilter(session.roleFilter) then UI.roleFilter = session.roleFilter end
    local current = findCurrentDungeon()
    if current then
        if UI.search and UI.search:GetText() ~= "" then
            UI.search:SetText("")
            UI.searchText = ""
        end
        DMC.SelectDungeon(current.id)
    elseif session.selectedDungeonId and DMC.GetDungeonById(session.selectedDungeonId) then
        DMC.SelectDungeon(session.selectedDungeonId, session.selectedBossId)
    else
        local dungeons = DMC.GetDungeonsSorted(UI.searchText, false, UI.activityType)
        if dungeons[1] then DMC.SelectDungeon(dungeons[1].id) end
    end
    DMC.RefreshDungeonList(current ~= nil)
    enterCursorModeForCodex()
end

function DMC.HideWindow()
    if not UI.window then return end
    saveCurrentNoteIfDirty()
    if UI.noteEdit then UI.noteEdit:LoseFocus() end
    hideCompactHint()
    UI.window:SetHidden(true)
    restoreCursorModeForCodex()
end

function DMC.ToggleWindow()
    if not UI.window then return end
    if UI.window:IsHidden() then DMC.ShowWindow() else DMC.HideWindow() end
end

function DMC.HandlePlayerActivated()
    if not UI.window or UI.window:IsHidden() then return end
    local current = findCurrentDungeon()
    if current and current.id ~= UI.selectedDungeonId then
        if UI.search and UI.search:GetText() ~= "" then
            UI.search:SetText("")
            UI.searchText = ""
        end
        DMC.SelectDungeon(current.id)
    else
        DMC.RefreshDungeonList(current ~= nil)
    end
end

function DMC.SetRoleFilter(role)
    local activity = DMC.GetDungeonById(UI.selectedDungeonId)
    if activity and not DMC.ActivitySupports(activity, "roles", role) then return end
    UI.roleFilter = isValidRoleFilter(role) and role or "all"
    getSessionState().roleFilter = UI.roleFilter
    UI.selectedChatLine = nil
    setSelectedButton(UI.roleall, UI.roleFilter == "all")
    setSelectedButton(UI.rolequick, UI.roleFilter == "quick")
    setSelectedButton(UI.roletank, UI.roleFilter == "tank")
    setSelectedButton(UI.rolehealer, UI.roleFilter == "healer")
    setSelectedButton(UI.roledps, UI.roleFilter == "dps")
    DMC.RefreshBossDetails()
end

function DMC.SetDifficultyMode(mode)
    mode = DMC.NormalizeDifficultyMode(mode)
    local activity = DMC.GetDungeonById(UI.selectedDungeonId)
    if activity and not DMC.ActivitySupports(activity, "difficulties", mode) then return end
    if UI.mode == mode then return end
    saveCurrentNoteIfDirty()
    UI.mode = mode
    if DMC.sv then DMC.sv.mode = mode end
    UI.selectedChatLine = nil
    setSelectedButton(UI.modeVet, mode == "vet")
    setSelectedButton(UI.modeHm, mode == "hm")
    if UI.selectedDungeonId then
        DMC.SelectDungeon(UI.selectedDungeonId, UI.selectedBossId)
    end
end

function DMC.SetActivityType(activityType)
    activityType = (activityType == "trial" or activityType == "arena") and activityType or "dungeon"
    if UI.activityType == activityType then return end
    saveCurrentNoteIfDirty()
    UI.activityType = activityType
    local session = getSessionState()
    session.activityType = activityType
    UI.selectedChatLine = nil
    setSelectedButton(UI.activityDungeon, activityType == "dungeon")
    setSelectedButton(UI.activityTrial, activityType == "trial")
    setSelectedButton(UI.activityArena, activityType == "arena")

    local selected = DMC.GetDungeonById(UI.selectedDungeonId)
    if not selected or DMC.GetActivityKind(selected) ~= activityType then
        local current = findCurrentDungeon()
        local target = current and DMC.GetActivityKind(current) == activityType and current or nil
        if not target then
            local activities = DMC.GetDungeonsSorted(UI.searchText, false, activityType)
            -- A search from the previous collection should not leave its old
            -- activity selected behind an empty new tab. Clear only when the
            -- same query has no result in the collection being opened.
            if not activities[1] and UI.searchText ~= "" then
                UI.searchText = ""
                UI.search:SetText("")
                activities = DMC.GetDungeonsSorted("", false, activityType)
            end
            target = activities[1]
        end
        if target then DMC.SelectDungeon(target.id) end
    end
    DMC.RefreshDungeonList(true)
end

function DMC.RefreshDungeonList(resetScroll)
    if not UI.dungeonListChild then return end
    local current = findCurrentDungeon()
    local currentDungeonId = current and current.id or false
    local dungeons = DMC.GetDungeonsSorted(UI.searchText, currentDungeonId, UI.activityType)
    local hasSearch = DMC.NormalizeText(UI.searchText or "") ~= ""
    if hasSearch then
        UI.dungeonCount:SetText(string.format("%d RESULTS", #dungeons))
    else
        local collectionLabel = UI.activityType == "trial" and "TRIALS"
            or (UI.activityType == "arena" and "ARENAS" or "DUNGEONS")
        UI.dungeonCount:SetText(string.format("%d %s", #dungeons, collectionLabel))
    end
    for index, dungeon in ipairs(dungeons) do
        local button = ensureDungeonButton(index)
        button:ClearAnchors()
        button:SetAnchor(TOPLEFT, UI.dungeonListChild, TOPLEFT, 0, (index - 1) * DUNGEON_ROW_HEIGHT)
        local isCurrent = dungeon.id == currentDungeonId
        local status = dungeon.status == "complete" and "" or " |c68727A(stub)|r"
        button:SetText("   " .. dungeon.name .. status)
        button.dungeonId = dungeon.id
        button:SetHidden(false)
        setDungeonButtonState(button, dungeon.id == UI.selectedDungeonId, isCurrent)
    end
    for index = #dungeons + 1, #UI.dungeonButtons do
        UI.dungeonButtons[index]:SetHidden(true)
        UI.dungeonButtons[index].dungeonId = nil
    end

    UI.noDungeons:SetHidden(#dungeons > 0)
    local contentHeight = #dungeons > 0 and (#dungeons * DUNGEON_ROW_HEIGHT) or 40
    updateNativeScroll(UI.dungeonListScroll, UI.dungeonListChild, DUNGEON_CONTENT_WIDTH, contentHeight, resetScroll == true)
end

function DMC.SelectDungeon(dungeonId, preferredBossId)
    local dungeon = DMC.GetDungeonById(dungeonId)
    if not dungeon then return end
    local previousDungeonId = UI.selectedDungeonId
    local previousBossId = UI.selectedBossId
    local session = getSessionState()
    local activityType = DMC.GetActivityKind(dungeon)
    UI.activityType = activityType
    session.activityType = activityType
    setSelectedButton(UI.activityDungeon, activityType == "dungeon")
    setSelectedButton(UI.activityTrial, activityType == "trial")
    setSelectedButton(UI.activityArena, activityType == "arena")
    local rememberedBossId = session.selectedDungeonId == dungeonId and session.selectedBossId or nil

    saveCurrentNoteIfDirty()
    UI.selectedDungeonId = dungeonId
    session.selectedDungeonId = dungeonId
    UI.selectedChatLine = nil

    applyActivityCapabilities(dungeon)

    local isStub = dungeon.status ~= "complete"
    UI.statusLabel:SetText(isStub and "DATASET STUB" or "")
    UI.statusLabel:SetColor(unpack(C.muted))
    UI.statusLabel:SetHidden(not isStub)
    local statusText = isStub and " Dataset stub: mechanics not written yet." or ""
    setScrollableText(UI.dungeonSummaryView, getDungeonSummaryText(dungeon) .. statusText, true)

    local dungeonLines = DMC.BuildDungeonChatLines(dungeon, UI.mode)
    for index, button in ipairs(UI.dungeonPasteButtons) do
        local line = dungeonLines[index]
        setPasteButton(button, line, #dungeonLines > 1 and ("PASTE " .. tostring(index)) or "PASTE")
    end
    layoutDungeonPasteButtons(#dungeonLines)

    local zoneDisplayType = ZONE_DISPLAY_TYPE_DUNGEON
    if activityType == "trial" then
        zoneDisplayType = ZONE_DISPLAY_TYPE_RAID
    elseif activityType == "arena" then
        zoneDisplayType = _G.ZONE_DISPLAY_TYPE_GROUP_ARENA
            or _G.ZONE_DISPLAY_TYPE_SOLO_ARENA
            or _G.ZONE_DISPLAY_TYPE_DUNGEON
    end
    UI.dungeonIcon:SetTexture(ZO_GetZoneDisplayTypeIcon(zoneDisplayType))
    UI.dungeonIcon:SetHidden(false)
    local artwork, isLoadscreen = getActivityArtwork(dungeon)
    if isLoadscreen then
        -- Loading screens are 16:9; crop a centered horizontal banner that
        -- fills the 936x112 summary panel without stretching the artwork.
        UI.dungeonArt:SetTextureCoords(0, 1, 0.394, 0.606)
    else
        -- Activity Finder keyboard artwork uses a larger atlas region.
        UI.dungeonArt:SetTextureCoords(0, 0.6836, 0.41, 0.575)
    end
    if artwork then UI.dungeonArt:SetTexture(artwork) end
    UI.dungeonArt:SetHidden(not artwork)
    layoutDungeonTitle(dungeon)

    local visibleBossCount = 0
    for index, button in ipairs(UI.bossButtons) do
        local boss = dungeon.bosses and dungeon.bosses[index]
        if boss then
            button.bossId = boss.id
            button.bossName = boss.name
            button.bossFlagsMarkup = shortFlags(boss)
            local flags = plainFlags(boss)
            button.measureText = boss.name .. (flags ~= "" and ("  " .. flags) or "")
            button:SetHidden(false)
            button.isHovered = false
            updateBossButtonText(button, false)
            visibleBossCount = visibleBossCount + 1
        else
            button:SetText("")
            button.bossId = nil
            button.bossName = nil
            button.bossFlagsMarkup = nil
            button.measureText = nil
            button:SetHidden(true)
        end
    end
    layoutBossListTable(visibleBossCount)

    if dungeon.bosses and dungeon.bosses[1] then
        local targetBossId = preferredBossId
        if not targetBossId and previousDungeonId == dungeonId then targetBossId = previousBossId end
        if not targetBossId then targetBossId = rememberedBossId end
        if not targetBossId or not DMC.GetBossById(dungeon, targetBossId) then
            targetBossId = dungeon.bosses[1].id
        end
        DMC.SelectBoss(targetBossId, true)
    else
        UI.selectedBossId = nil
        session.selectedBossId = nil
        loadCurrentBossNote()
        DMC.RefreshBossDetails()
    end
    DMC.RefreshDungeonList(false)
end

function DMC.SelectBoss(bossId, skipSave)
    if not skipSave and bossId ~= UI.selectedBossId then saveCurrentNoteIfDirty() end
    UI.selectedBossId = bossId
    getSessionState().selectedBossId = bossId
    UI.selectedChatLine = nil
    loadCurrentBossNote()
    DMC.RefreshBossDetails()
end

function DMC.RefreshBossDetails()
    for _, button in ipairs(UI.bossButtons) do
        setBossButtonState(button, button.bossId and button.bossId == UI.selectedBossId)
    end
    setSelectedButton(UI.roleall, UI.roleFilter == "all")
    setSelectedButton(UI.rolequick, UI.roleFilter == "quick")
    setSelectedButton(UI.roletank, UI.roleFilter == "tank")
    setSelectedButton(UI.rolehealer, UI.roleFilter == "healer")
    setSelectedButton(UI.roledps, UI.roleFilter == "dps")

    local dungeon, boss = getCurrentBoss()
    if not boss then
        UI.bossTitle:SetText("No boss selected")
        UI.bossTitle:SetDimensions(504, 28)
        if UI.bossMeta then UI.bossMeta:SetHidden(true) end
        setScrollableText(UI.bossSummaryView, "Select a boss to view its overview and mechanics.", true)
        for _, button in ipairs(UI.bossPasteButtons) do setPasteButton(button, nil) end
        layoutBossPasteButtons(0)
        UI.mechanicsCount:SetText("")
        for _, row in ipairs(UI.mechanicRows) do row:SetHidden(true) end
        updateNativeScroll(UI.mechanicsScroll, UI.mechanicsChild, MECHANIC_CONTENT_WIDTH, 1, true)
        refreshNoteControls()
        return
    end

    setScrollableText(UI.bossSummaryView, getBossSummaryText(boss), true)
    local bossLines = DMC.BuildBossChatLines(dungeon, boss, UI.mode)
    for index, button in ipairs(UI.bossPasteButtons) do
        local line = bossLines[index]
        setPasteButton(button, line, #bossLines > 1 and ("PASTE " .. tostring(index)) or "PASTE")
    end
    layoutBossPasteButtons(#bossLines)
    layoutSelectedBossTitle(boss)

    local matching = {}
    for _, mechanic in ipairs(boss.mechanics or {}) do
        if DMC.MechanicMatchesRole(mechanic, UI.roleFilter, UI.mode) then table.insert(matching, mechanic) end
    end
    UI.mechanicsCount:SetText(string.format("%d %s", #matching, #matching == 1 and "ENTRY" or "ENTRIES"))

    local y = 0
    if #matching == 0 then
        local row = ensureMechanicRow(1)
        row:ClearAnchors()
        row:SetAnchor(TOPLEFT, UI.mechanicsChild, TOPLEFT, 0, 0)
        row.title:SetText(UI.roleFilter == "quick" and "No Quick callouts" or "No mechanics")
        row.number:SetText("")
        row.number:SetHidden(true)
        local message = UI.roleFilter == "quick"
            and "No Quick callouts are written for this boss yet. Use Full for the complete mechanic explanations."
            or "No mechanics match this view."
        y = layoutMechanicRow(row, {message})
        for _, button in ipairs(row.pasteButtons) do setPasteButton(button, nil) end
        row:SetHidden(false)
        for index = 2, #UI.mechanicRows do UI.mechanicRows[index]:SetHidden(true) end
    else
        for index, mechanic in ipairs(matching) do
            local row = ensureMechanicRow(index)
            row:ClearAnchors()
            row:SetAnchor(TOPLEFT, UI.mechanicsChild, TOPLEFT, 0, y)
            row.title:SetText(DMC.GetMechanicLabel(mechanic, UI.mode))
            row.number:SetText(string.format("%02d", index))
            row.number:SetHidden(false)
            local lines = DMC.BuildMechanicChatLines(dungeon, boss, mechanic, UI.roleFilter, UI.mode)
            local rowHeight = layoutMechanicRow(row, lines)
            row:SetHidden(false)
            y = y + rowHeight + 14
        end
        for index = #matching + 1, #UI.mechanicRows do UI.mechanicRows[index]:SetHidden(true) end
    end

    updateNativeScroll(UI.mechanicsScroll, UI.mechanicsChild, MECHANIC_CONTENT_WIDTH, math.max(1, y), true)
    refreshNoteControls()
end

function DMC.PasteSelectedChatLine()
    if UI.selectedChatLine then
        DMC.PasteToChatInput(UI.selectedChatLine)
        return
    end
    local dungeon, boss = getCurrentBoss()
    local lines = DMC.BuildBossChatLines(dungeon, boss, UI.mode)
    if lines[1] then DMC.PasteToChatInput(lines[1])
    else DMC.Print("No selected mechanic chat line yet.") end
end
