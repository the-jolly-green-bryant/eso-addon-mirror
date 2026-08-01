local ADDON_TITLE = "Ranckors Leaderboard Tracker"
local ADDON_VERSION = "v1.0.3"
local ADDON_LINK = "https://illyriat.com"

RanckorsUI = {}

RanckorsUI.uiWindow      = nil
RanckorsUI.uiContentRoot = nil
RanckorsUI.uiContent     = nil
RanckorsUI.baseWidth     = 375
RanckorsUI.baseHeight    = 250

local function ApplyContentScale()
    if not (RanckorsUI.uiWindow and RanckorsUI.uiContentRoot) then return end
    local winW, winH = RanckorsUI.uiWindow:GetDimensions()
    local bw,  bh    = RanckorsUI.baseWidth, RanckorsUI.baseHeight
    if bw <= 0 or bh <= 0 then return end

    local scale = math.min(winW / bw, winH / bh)
    scale = math.max(0.5, math.min(3.0, scale))

    RanckorsUI.uiContentRoot:SetScale(scale)
    RanckorsUI.uiContentRoot:ClearAnchors()
    RanckorsUI.uiContentRoot:SetAnchor(TOPLEFT, RanckorsUI.uiWindow, TOPLEFT, 0, 0)
end

local function SaveWindowSize(savedVars)
    if not (RanckorsUI.uiWindow and savedVars and savedVars.window) then return end
    local w, h = RanckorsUI.uiWindow:GetDimensions()
    savedVars.window.w = math.floor(w + 0.5)
    savedVars.window.h = math.floor(h + 0.5)
end

function RanckorsUI.CreateUIWindow(savedVars)
    if RanckorsUI.uiWindow then
        d("UI window already exists.")
        return RanckorsUI.uiWindow, RanckorsUI.uiContent
    end

    d("Creating UI window...")

    local fixedWidth  = RanckorsUI.baseWidth
    local fixedHeight = RanckorsUI.baseHeight

    RanckorsUI.uiWindow = WINDOW_MANAGER:CreateTopLevelWindow("RanckorsUIWindow")
    RanckorsUI.uiWindow:SetDimensions(fixedWidth, fixedHeight)
    RanckorsUI.uiWindow:SetMovable(true)
    RanckorsUI.uiWindow:SetMouseEnabled(true)
    RanckorsUI.uiWindow:SetClampedToScreen(true)
    RanckorsUI.uiWindow:SetHidden(false)
    RanckorsUI.uiWindow:SetResizeHandleSize(12)

    -- Background
    local customBg = WINDOW_MANAGER:CreateControl("$(parent)CustomBackground", RanckorsUI.uiWindow, CT_TEXTURE)
    customBg:SetAnchorFill(RanckorsUI.uiWindow)
    customBg:SetTexture("EsoUI/Art/ChatWindow/chat_bg_center.dds")
    customBg:SetColor(0, 0, 0, 0.8)
    customBg:SetDrawLayer(DL_BACKGROUND)

    RanckorsUI.uiContentRoot = WINDOW_MANAGER:CreateControl("$(parent)ContentRoot", RanckorsUI.uiWindow, CT_CONTROL)
    RanckorsUI.uiContentRoot:SetDimensions(fixedWidth, fixedHeight)
    RanckorsUI.uiContentRoot:SetAnchor(TOPLEFT, RanckorsUI.uiWindow, TOPLEFT, 0, 0)

    local titleLabel = WINDOW_MANAGER:CreateControl("$(parent)Title", RanckorsUI.uiContentRoot, CT_LABEL)
    titleLabel:SetFont("ZoFontGameLargeBold")
    titleLabel:SetText(ADDON_TITLE)
    titleLabel:SetAnchor(TOPLEFT, RanckorsUI.uiContentRoot, TOPLEFT, 10, 8)
    titleLabel:SetDimensions(260, 25)
    titleLabel:SetColor(ZO_NORMAL_TEXT:UnpackRGBA())
    titleLabel:SetMouseEnabled(true)
    titleLabel:SetHandler("OnMouseUp", function()
        RequestOpenUnsafeURL(ADDON_LINK)
    end)

    local versionLabel = WINDOW_MANAGER:CreateControl("$(parent)Version", RanckorsUI.uiContentRoot, CT_LABEL)
    versionLabel:SetFont("ZoFontGameSmall")
    versionLabel:SetText(ADDON_VERSION)
    versionLabel:SetAnchor(TOPRIGHT, RanckorsUI.uiContentRoot, TOPRIGHT, -10, 12)
    versionLabel:SetDimensions(60, 15)
    versionLabel:SetColor(ZO_NORMAL_TEXT:UnpackRGBA())

    RanckorsUI.uiContent = WINDOW_MANAGER:CreateControl("$(parent)Content", RanckorsUI.uiContentRoot, CT_LABEL)
    RanckorsUI.uiContent:SetAnchor(TOPLEFT,  RanckorsUI.uiContentRoot, TOPLEFT, 5, 40)
    RanckorsUI.uiContent:SetAnchor(BOTTOMRIGHT, RanckorsUI.uiContentRoot, BOTTOMRIGHT, -5, -5)
    RanckorsUI.uiContent:SetWrapMode(TEXT_WRAP_MODE_NONE)
    RanckorsUI.uiContent:SetFont("ZoFontGameBold|14")

    RanckorsUI.uiWindow:SetHandler("OnSizeChanged", function()
        ApplyContentScale()
    end)
    RanckorsUI.uiWindow:SetHandler("OnResizeStop", function()
        SaveWindowSize(savedVars)
        ApplyContentScale()
    end)

    d("UI window created successfully.")
    return RanckorsUI.uiWindow, RanckorsUI.uiContent
end

function RanckorsUI.RestoreWindowPositionAndSize(savedVars)
    if not RanckorsUI.uiWindow then
        d("UI window is nil. Creating it now.")
        RanckorsUI.CreateUIWindow(savedVars)
    end

    zo_callLater(function()
        local w = (savedVars.window and savedVars.window.w) or RanckorsUI.baseWidth
        local h = (savedVars.window and savedVars.window.h) or RanckorsUI.baseHeight

        RanckorsUI.uiWindow:ClearAnchors()
        RanckorsUI.uiWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, savedVars.window.x or 100, savedVars.window.y or 100)
        RanckorsUI.uiWindow:SetDimensions(w, h)
        RanckorsUI.uiWindow:SetHidden(false)

        ApplyContentScale()
    end, 100)
end

local function OnSceneStateChange(oldState, newState)
    if newState == SCENE_SHOWING then
        RanckorsUI.uiWindow:SetHidden(false)
    elseif newState == SCENE_HIDDEN then
        RanckorsUI.uiWindow:SetHidden(true)
    end
end

function RanckorsUI.RegisterSceneManagement()
    SCENE_MANAGER:GetScene("hud"):RegisterCallback("StateChange", OnSceneStateChange)
    SCENE_MANAGER:GetScene("hudui"):RegisterCallback("StateChange", OnSceneStateChange)
end
