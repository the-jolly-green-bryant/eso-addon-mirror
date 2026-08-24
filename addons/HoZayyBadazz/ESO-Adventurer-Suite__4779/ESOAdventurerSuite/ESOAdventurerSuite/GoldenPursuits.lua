-- ESO Adventurer Suite
-- Golden Pursuits HUD.
-- v0.25.05: one Suite-owned, movable/resizable tracker replaces the duplicate
-- native + companion-panel presentation.

local EPC = ESOProgressionCoach
EPC.GoldenPursuits = EPC.GoldenPursuits or {}
local G = EPC.GoldenPursuits
local wm = WINDOW_MANAGER

local DEFAULT_WIDTH = 420
local DEFAULT_HEIGHT = 80
local MIN_WIDTH = 300
local MIN_HEIGHT = 72
local MAX_WIDTH = 900
local MAX_HEIGHT = 420

local function getNativeTrackerControl()
    if PROMOTIONAL_EVENT_TRACKER and PROMOTIONAL_EVENT_TRACKER.control then
        return PROMOTIONAL_EVENT_TRACKER.control
    end
    return ZO_PromotionalEventTracker_TL
end

local function savedNumber(key, fallback)
    local value = EPC.saved and tonumber(EPC.saved[key])
    if value ~= nil then return value end
    return fallback
end

function G:SuppressNativeTracker2505()
    local native = getNativeTrackerControl()
    if not native then return end
    if native.SetAlpha then native:SetAlpha(0) end
    if native.SetMouseEnabled then native:SetMouseEnabled(false) end
end

function G:IsSuiteMenuOpen2496()
    local journal = EPC.Journal
    local window = journal and journal.window
    if window and type(window.IsHidden) == "function" then
        local ok, hidden = pcall(window.IsHidden, window)
        if ok and hidden == false then return true end
    end
    return false
end

function G:Create2505()
    if self.frame2505 then return self.frame2505 end
    if not wm then return nil end

    -- v0.25.09: migrate the older tall HUD once so existing SavedVariables
    -- do not keep the previous 140px height after the compact redesign.
    if EPC.saved and EPC.saved.goldenPursuitsCompactHeightVersion ~= 2509 then
        EPC.saved.goldenPursuitsHeight = DEFAULT_HEIGHT
        EPC.saved.goldenPursuitsCompactHeightVersion = 2509
    end

    local frame = wm:CreateTopLevelWindow("EAS_GoldenPursuitsHUD2505")
    local width = math.max(MIN_WIDTH, math.min(MAX_WIDTH, savedNumber("goldenPursuitsWidth", DEFAULT_WIDTH)))
    local height = math.max(MIN_HEIGHT, math.min(MAX_HEIGHT, savedNumber("goldenPursuitsHeight", DEFAULT_HEIGHT)))
    frame:SetDimensions(width, height)
    frame:SetDimensionConstraints(MIN_WIDTH, MIN_HEIGHT)
    frame:SetResizeHandleSize(18)
    frame:SetClampedToScreen(true)
    frame:SetMouseEnabled(false)
    frame:SetMovable(false)
    frame:SetHidden(true)
    if frame.SetDrawLayer then frame:SetDrawLayer(DL_OVERLAY) end
    if DT_HIGH ~= nil and frame.SetDrawTier then frame:SetDrawTier(DT_HIGH) end

    local left = savedNumber("goldenPursuitsLeft", -1)
    local top = savedNumber("goldenPursuitsTop", -1)
    if left >= 0 and top >= 0 then
        frame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
    else
        frame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 34, 360)
    end

    -- Inset the backdrop so all four border strokes remain visible at every size.
    local bg = wm:CreateControl("EAS_GoldenPursuitsHUDBG2505", frame, CT_BACKDROP)
    bg:SetAnchor(TOPLEFT, frame, TOPLEFT, 2, 2)
    bg:SetAnchor(BOTTOMRIGHT, frame, BOTTOMRIGHT, -2, -2)
    bg:SetCenterColor(0.025, 0.022, 0.018, 0.90)
    bg:SetEdgeTexture(nil, 1, 1, 2)
    bg:SetEdgeColor(0.92, 0.72, 0.25, 0.95)
    bg:SetMouseEnabled(false)

    local header = wm:CreateControl("EAS_GoldenPursuitsHUDHeader2505", frame, CT_LABEL)
    header:SetFont("ZoFontGameSmall")
    header:SetColor(0.96, 0.80, 0.36, 1)
    header:SetAnchor(TOPLEFT, frame, TOPLEFT, 12, 8)
    header:SetAnchor(TOPRIGHT, frame, TOPRIGHT, -12, 8)
    header:SetHeight(18)
    header:SetText("GOLDEN PURSUITS")

    local title = wm:CreateControl("EAS_GoldenPursuitsHUDTitle2505", frame, CT_LABEL)
    title:SetFont("ZoFontGameBold")
    title:SetColor(0.96, 0.80, 0.36, 1)
    title:SetAnchor(TOPLEFT, frame, TOPLEFT, 12, 28)
    title:SetAnchor(TOPRIGHT, frame, TOPRIGHT, -12, 28)
    title:SetHeight(38)
    title:SetVerticalAlignment(TEXT_ALIGN_TOP)
    title:SetHorizontalAlignment(TEXT_ALIGN_LEFT)

    local pursuit = wm:CreateControl("EAS_GoldenPursuitsHUDPursuit2505", frame, CT_LABEL)
    pursuit:SetFont("ZoFontGame")
    pursuit:SetColor(0.92, 0.94, 0.97, 1)
    pursuit:SetAnchor(TOPLEFT, frame, TOPLEFT, 12, 68)
    pursuit:SetAnchor(TOPRIGHT, frame, TOPRIGHT, -12, 68)
    pursuit:SetHeight(24)
    pursuit:SetVerticalAlignment(TEXT_ALIGN_TOP)
    pursuit:SetHorizontalAlignment(TEXT_ALIGN_LEFT)

    local status = wm:CreateControl("EAS_GoldenPursuitsHUDStatus2505", frame, CT_LABEL)
    status:SetFont("ZoFontGameSmall")
    status:SetColor(0.78, 0.80, 0.84, 1)
    status:SetAnchor(TOPLEFT, frame, TOPLEFT, 12, 94)
    status:SetAnchor(BOTTOMRIGHT, frame, BOTTOMRIGHT, -12, -8)
    status:SetVerticalAlignment(TEXT_ALIGN_TOP)
    status:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    if status.SetLineSpacing then status:SetLineSpacing(2) end

    local moveHint = wm:CreateControl("EAS_GoldenPursuitsHUDMoveHint2505", frame, CT_LABEL)
    moveHint:SetFont("ZoFontGameSmall")
    moveHint:SetColor(0.96, 0.80, 0.36, 1)
    moveHint:SetAnchor(TOPRIGHT, frame, TOPRIGHT, -12, 8)
    moveHint:SetDimensions(230, 18)
    moveHint:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    moveHint:SetText("DRAG TO MOVE - EDGES TO RESIZE")
    moveHint:SetHidden(true)

    local layoutGuide = wm:CreateControl("EAS_GoldenPursuitsHUDLayoutGuide2505", frame, CT_BACKDROP)
    layoutGuide:SetAnchor(TOPLEFT, frame, TOPLEFT, 4, 4)
    layoutGuide:SetAnchor(BOTTOMRIGHT, frame, BOTTOMRIGHT, -4, -4)
    layoutGuide:SetCenterColor(0, 0, 0, 0)
    layoutGuide:SetEdgeTexture(nil, 1, 1, 1)
    layoutGuide:SetEdgeColor(1, 0.84, 0.42, 0.65)
    layoutGuide:SetHidden(true)

    frame:SetHandler("OnMoveStop", function(control)
        if not EPC.saved then return end
        EPC.saved.goldenPursuitsLeft = math.max(0, tonumber(control:GetLeft()) or 0)
        EPC.saved.goldenPursuitsTop = math.max(0, tonumber(control:GetTop()) or 0)
    end)
    frame:SetHandler("OnResizeStop", function(control)
        if not EPC.saved then return end
        local w, h = control:GetDimensions()
        EPC.saved.goldenPursuitsWidth = math.floor((tonumber(w) or DEFAULT_WIDTH) + 0.5)
        EPC.saved.goldenPursuitsHeight = math.floor((tonumber(h) or DEFAULT_HEIGHT) + 0.5)
    end)

    self.frame2505 = frame
    self.selectedQuestPanel2504 = frame -- compatibility with the v0.25.04 name
    self.bg2505 = bg
    self.header2505 = header
    self.title2505 = title
    self.pursuit2505 = pursuit
    self.status2505 = status
    self.moveHint2505 = moveHint
    self.layoutGuide2505 = layoutGuide
    return frame
end

function G:SetSelectedPursuitQuest2504(pursuitName, questName)
    self.selectedPursuitName2504 = tostring(pursuitName or "")
    self.selectedQuestName2504 = tostring(questName or "")
    if EPC.saved then
        EPC.saved.goldenPursuitName = self.selectedPursuitName2504
        EPC.saved.goldenPursuitQuestName = self.selectedQuestName2504
    end
    self:RefreshSelectedQuestPanel2504()
end

function G:ClearSelectedPursuitQuest2504()
    self.selectedPursuitName2504 = ""
    self.selectedQuestName2504 = ""
    if EPC.saved then
        EPC.saved.goldenPursuitName = ""
        EPC.saved.goldenPursuitQuestName = ""
    end
    self:RefreshSelectedQuestPanel2504()
end

function G:RefreshSelectedQuestPanel2504()
    local frame = self:Create2505()
    if not frame then return end

    local pursuitName = tostring(self.selectedPursuitName2504 or "")
    local questName = tostring(self.selectedQuestName2504 or "")
    local hasSelection = pursuitName ~= "" or questName ~= ""

    -- Keep this HUD intentionally minimal: GOLDEN PURSUITS header + active quest only.
    if self.layoutMode and not hasSelection then
        self.title2505:SetText("Active quest preview")
    elseif questName ~= "" then
        self.title2505:SetText(questName)
    else
        self.title2505:SetText(pursuitName)
    end

    self.pursuit2505:SetText("")
    self.status2505:SetText("")
    self.pursuit2505:SetHidden(true)
    self.status2505:SetHidden(true)

    self:RefreshVisibility2496()
end

function G:RefreshVisibility2496()
    self:SuppressNativeTracker2505()
    local frame = self:Create2505()
    if not frame then return end

    local pursuitName = tostring(self.selectedPursuitName2504 or "")
    local questName = tostring(self.selectedQuestName2504 or "")
    local hasSelection = pursuitName ~= "" or questName ~= ""
    local show = hasSelection or self.layoutMode

    if show and not self.layoutMode then
        if self:IsSuiteMenuOpen2496() then
            show = false
        elseif EPC.IsGameplayHudSuppressed and EPC:IsGameplayHudSuppressed() then
            show = false
        end
    end

    frame:SetHidden(not show)
    if frame.SetAlpha then frame:SetAlpha(show and 1 or 0) end
end

function G:SetLayoutMode(active)
    self.layoutMode = active == true
    local frame = self:Create2505()
    if not frame then return end
    frame:SetMouseEnabled(self.layoutMode)
    frame:SetMovable(self.layoutMode)
    if self.moveHint2505 then self.moveHint2505:SetHidden(not self.layoutMode) end
    if self.layoutGuide2505 then self.layoutGuide2505:SetHidden(not self.layoutMode) end
    self:RefreshSelectedQuestPanel2504()
end

function G:SetSize(width, height)
    local frame = self:Create2505()
    if not frame or not EPC.saved then return end
    width = math.max(MIN_WIDTH, math.min(MAX_WIDTH, tonumber(width) or frame:GetWidth()))
    height = math.max(MIN_HEIGHT, math.min(MAX_HEIGHT, tonumber(height) or frame:GetHeight()))
    frame:SetDimensions(width, height)
    EPC.saved.goldenPursuitsWidth = math.floor(width + 0.5)
    EPC.saved.goldenPursuitsHeight = math.floor(height + 0.5)
end

function G:ResetSize()
    local frame = self:Create2505()
    if not frame or not EPC.saved then return end
    EPC.saved.goldenPursuitsWidth = DEFAULT_WIDTH
    EPC.saved.goldenPursuitsHeight = DEFAULT_HEIGHT
    frame:SetDimensions(DEFAULT_WIDTH, DEFAULT_HEIGHT)
end

function G:ResetPosition()
    local frame = self:Create2505()
    if not frame or not EPC.saved then return end
    EPC.saved.goldenPursuitsLeft = -1
    EPC.saved.goldenPursuitsTop = -1
    frame:ClearAnchors()
    frame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 34, 360)
end

function G:Initialize()
    self.layoutMode = false
    self.selectedPursuitName2504 = tostring(EPC.saved and EPC.saved.goldenPursuitName or "")
    self.selectedQuestName2504 = tostring(EPC.saved and EPC.saved.goldenPursuitQuestName or "")
    self:SuppressNativeTracker2505()
    self:Create2505()
    self:RefreshSelectedQuestPanel2504()

    local prefix = EPC.name .. "_GoldenPursuits2505"
    if SCENE_MANAGER and type(SCENE_MANAGER.RegisterCallback) == "function" then
        SCENE_MANAGER:RegisterCallback("SceneStateChanged", function()
            self:RefreshVisibility2496()
        end)
    end
    if EVENT_GAME_CAMERA_UI_MODE_CHANGED then
        EVENT_MANAGER:RegisterForEvent(prefix .. "_UIMode", EVENT_GAME_CAMERA_UI_MODE_CHANGED, function()
            self:RefreshVisibility2496()
        end)
    end
    if EVENT_PLAYER_ACTIVATED then
        EVENT_MANAGER:RegisterForEvent(prefix .. "_Activated", EVENT_PLAYER_ACTIVATED, function()
            self:SuppressNativeTracker2505()
            self:RefreshVisibility2496()
        end)
    end
    if EVENT_PROMOTIONAL_EVENTS_ACTIVITY_TRACKING_UPDATED then
        EVENT_MANAGER:RegisterForEvent(prefix .. "_Tracking", EVENT_PROMOTIONAL_EVENTS_ACTIVITY_TRACKING_UPDATED, function()
            self:RefreshSelectedQuestPanel2504()
        end)
    end
    EVENT_MANAGER:RegisterForUpdate(prefix .. "_Visibility", 200, function()
        self:SuppressNativeTracker2505()
        self:RefreshVisibility2496()
    end)
end

-- v0.25.13: only show this tracker when Golden Pursuits is the selected
-- quest-tracking source. HUD Layout Mode still exposes it for positioning.
local easLegacyRefreshVisibility_2513 = G.RefreshVisibility2496
function G:RefreshVisibility2496()
    easLegacyRefreshVisibility_2513(self)
    if self.layoutMode then return end
    local source = tostring(EPC.saved and EPC.saved.questTrackingSource or "ACTIVE_QUEST")
    if source ~= "GOLDEN_PURSUITS" then
        local frame = self:Create2505()
        if frame then
            frame:SetHidden(true)
            if frame.SetAlpha then frame:SetAlpha(0) end
        end
    end
end
