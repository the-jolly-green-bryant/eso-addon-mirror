-- ESO Adventurer Suite
-- Golden Pursuits HUD.
-- v0.25.05: one Suite-owned, movable/resizable tracker replaces the duplicate
-- native + companion-panel presentation.

local EPC = ESOProgressionCoach
EPC.GoldenPursuits = EPC.GoldenPursuits or {}
local G = EPC.GoldenPursuits
local wm = WINDOW_MANAGER

local DEFAULT_WIDTH = 420
local DEFAULT_HEIGHT = 136
local MIN_WIDTH = 180
local MIN_HEIGHT = 90
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
    if EPC.saved and EPC.saved.goldenPursuitsCompactHeightVersion ~= 2871 then
        local oldHeight = tonumber(EPC.saved.goldenPursuitsHeight) or 0
        if oldHeight < MIN_HEIGHT then
            EPC.saved.goldenPursuitsHeight = DEFAULT_HEIGHT
        end
        EPC.saved.goldenPursuitsCompactHeightVersion = 2871
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
        EPC.saved.goldenPursuitsManualSize2875 = true
        if self.ApplyCompactLayout2875 then self:ApplyCompactLayout2875() end
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

function G:SetSelectedPursuitQuest2504(pursuitName, questName, campaignKey, activityIndex)
    self.selectedPursuitName2504 = tostring(pursuitName or "")
    self.selectedQuestName2504 = tostring(questName or "")
    self.selectedCampaignKey2871 = campaignKey
    self.selectedActivityIndex2871 = tonumber(activityIndex)
    if EPC.saved then
        EPC.saved.goldenPursuitName = self.selectedPursuitName2504
        EPC.saved.goldenPursuitQuestName = self.selectedQuestName2504
        local keyType = type(campaignKey)
        EPC.saved.goldenPursuitCampaignKey2871 = (keyType == "number" or keyType == "string") and campaignKey or nil
        EPC.saved.goldenPursuitActivityIndex2871 = tonumber(activityIndex)
    end
    self:RefreshSelectedQuestPanel2504()
end

function G:ClearSelectedPursuitQuest2504()
    self.selectedPursuitName2504 = ""
    self.selectedQuestName2504 = ""
    self.selectedCampaignKey2871 = nil
    self.selectedActivityIndex2871 = nil
    if EPC.saved then
        EPC.saved.goldenPursuitName = ""
        EPC.saved.goldenPursuitQuestName = ""
        EPC.saved.goldenPursuitCampaignKey2871 = nil
        EPC.saved.goldenPursuitActivityIndex2871 = nil
    end
    self:RefreshSelectedQuestPanel2504()
end

local function easLower2871(value)
    local text = tostring(value or "")
    if type(zo_strlower) == "function" then return zo_strlower(text) end
    return string.lower(text)
end

local function easSameKey2871(a, b)
    if a == nil or b == nil then return false end
    if tostring(a) == tostring(b) then return true end
    local an, bn = tonumber(a), tonumber(b)
    return an ~= nil and bn ~= nil and an == bn
end

function G:FindSelectedPursuitRow2871()
    local pursuitName = tostring(self.selectedPursuitName2504 or "")
    if pursuitName == "" then return nil end
    local journal = EPC.Journal
    if not journal or type(journal.BuildGoldenPursuitsView2494) ~= "function" then return nil end

    local ok, view = pcall(journal.BuildGoldenPursuitsView2494, journal)
    if not ok or type(view) ~= "table" then return nil end
    local rows = view.allRows or view.rows or {}
    local wantedKey = self.selectedCampaignKey2871
    if wantedKey == nil and EPC.saved then wantedKey = EPC.saved.goldenPursuitCampaignKey2871 end
    local wantedActivity = tonumber(self.selectedActivityIndex2871)
    if not wantedActivity and EPC.saved then wantedActivity = tonumber(EPC.saved.goldenPursuitActivityIndex2871) end

    local nameMatch = nil
    local wantedName = easLower2871(pursuitName)
    for _, row in ipairs(rows) do
        local activityIndex = tonumber(row.activityIndex)
        if wantedActivity and activityIndex == wantedActivity then
            if wantedKey == nil or easSameKey2871(row.campaignKey, wantedKey) then
                return row
            end
        end
        if not nameMatch and easLower2871(row.name) == wantedName then
            nameMatch = row
        end
    end
    return nameMatch
end

function G:GetSelectedProgress2871()
    local row = self:FindSelectedPursuitRow2871()
    if not row then return nil end
    local progress = math.max(0, tonumber(row.progress) or 0)
    local goal = math.max(0, tonumber(row.goal) or 0)
    local complete = row.complete == true
    local percent = nil
    if goal > 0 then
        percent = math.max(0, math.min(100, math.floor((progress / goal) * 100 + 0.5)))
    end
    return {
        row = row,
        name = tostring(row.name or self.selectedPursuitName2504 or "Golden Pursuit"),
        progress = progress,
        goal = goal,
        percent = percent,
        complete = complete,
        campaignCompleted = math.max(0, tonumber(row.campaignCompleted) or 0),
        campaignThreshold = math.max(0, tonumber(row.campaignThreshold) or 0),
    }
end

function G:RefreshSelectedQuestPanel2504()
    local frame = self:Create2505()
    if not frame then return end

    local pursuitName = tostring(self.selectedPursuitName2504 or "")
    local questName = tostring(self.selectedQuestName2504 or "")
    local hasSelection = pursuitName ~= "" or questName ~= ""
    local progressInfo = hasSelection and self:GetSelectedProgress2871() or nil

    if self.layoutMode and not hasSelection then
        self.title2505:SetText("Linked quest preview")
        self.pursuit2505:SetText("Golden Pursuit task preview")
        self.status2505:SetText("• PROGRESS: 3 / 10 (30%)\n• CAMPAIGN: 6 / 20")
        self.status2505:SetColor(1, 1, 1, 1)
    else
        local displayTitle = questName ~= "" and questName or pursuitName
        self.title2505:SetText(displayTitle)

        local taskName = progressInfo and progressInfo.name or pursuitName
        if taskName ~= "" and easLower2871(taskName) ~= easLower2871(displayTitle) then
            self.pursuit2505:SetText(taskName)
        else
            self.pursuit2505:SetText("")
        end

        if progressInfo then
            local progressText
            if progressInfo.complete then
                if progressInfo.goal > 0 then
                    progressText = string.format("• PROGRESS: %d / %d (COMPLETE)", progressInfo.progress, progressInfo.goal)
                else
                    progressText = "• PROGRESS: COMPLETE"
                end
                self.status2505:SetColor(1, 1, 1, 1)
            elseif progressInfo.goal > 0 then
                progressText = string.format("• PROGRESS: %d / %d (%d%%)", progressInfo.progress, progressInfo.goal, progressInfo.percent or 0)
                self.status2505:SetColor(1, 1, 1, 1)
            else
                progressText = string.format("• PROGRESS: %d", progressInfo.progress)
                self.status2505:SetColor(1, 1, 1, 1)
            end
            if progressInfo.campaignThreshold > 0 then
                progressText = progressText .. string.format("\n• CAMPAIGN: %d / %d", progressInfo.campaignCompleted, progressInfo.campaignThreshold)
            end
            self.status2505:SetText(progressText)
        elseif hasSelection then
            self.status2505:SetText("• PROGRESS: Syncing with Golden Pursuits...")
            self.status2505:SetColor(0.78, 0.80, 0.84, 1)
        else
            self.status2505:SetText("")
        end
    end

    local hasPursuitLine = self.pursuit2505:GetText() ~= ""
    self.pursuit2505:SetHidden(not hasPursuitLine)

    -- v0.28.75: reflow all rows into the user's current viewport instead of
    -- reserving a tall fixed layout that prevents compact sizing.
    self:ApplyCompactLayout2875()
    self:RefreshVisibility2496()
end

-- v0.28.75: keep Golden Pursuits usable at compact manual sizes. Rows are
-- stacked from the top and the status label becomes a clipped viewport instead
-- of imposing the old 300x126 minimum footprint.
function G:ApplyCompactLayout2875()
    local frame = self.frame2505 or self:Create2505()
    if not frame or not self.header2505 or not self.title2505 or not self.pursuit2505 or not self.status2505 then return end

    local frameWidth = tonumber(frame:GetWidth()) or DEFAULT_WIDTH
    local frameHeight = math.max(MIN_HEIGHT, tonumber(frame:GetHeight()) or DEFAULT_HEIGHT)
    local pad = frameWidth < 240 and 8 or 12
    local headerTop, headerHeight = 6, 18

    self.header2505:ClearAnchors()
    self.header2505:SetAnchor(TOPLEFT, frame, TOPLEFT, pad, headerTop)
    self.header2505:SetAnchor(TOPRIGHT, frame, TOPRIGHT, -pad, headerTop)
    self.header2505:SetHeight(headerHeight)

    local titleTop = headerTop + headerHeight + 2
    local titleDesired = 38
    if type(self.title2505.GetTextHeight) == "function" then
        local ok, value = pcall(self.title2505.GetTextHeight, self.title2505)
        if ok and tonumber(value) then titleDesired = math.max(18, math.ceil(tonumber(value)) + 2) end
    end
    local titleHeight = math.max(18, math.min(38, titleDesired))
    self.title2505:ClearAnchors()
    self.title2505:SetAnchor(TOPLEFT, frame, TOPLEFT, pad, titleTop)
    self.title2505:SetAnchor(TOPRIGHT, frame, TOPRIGHT, -pad, titleTop)
    self.title2505:SetHeight(titleHeight)

    local cursorY = titleTop + titleHeight + 2
    local hasPursuitLine = not self.pursuit2505:IsHidden() and tostring(self.pursuit2505:GetText() or "") ~= ""
    if hasPursuitLine then
        local pursuitHeight = 20
        self.pursuit2505:ClearAnchors()
        self.pursuit2505:SetAnchor(TOPLEFT, frame, TOPLEFT, pad, cursorY)
        self.pursuit2505:SetAnchor(TOPRIGHT, frame, TOPRIGHT, -pad, cursorY)
        self.pursuit2505:SetHeight(pursuitHeight)
        cursorY = cursorY + pursuitHeight + 2
    end

    self.status2505:ClearAnchors()
    self.status2505:SetAnchor(TOPLEFT, frame, TOPLEFT, pad, cursorY)
    self.status2505:SetAnchor(TOPRIGHT, frame, TOPRIGHT, -pad, cursorY)
    local statusHeight = math.max(0, frameHeight - cursorY - 6)
    self.status2505:SetHeight(statusHeight)
    self.status2505:SetHidden(tostring(self.status2505:GetText() or "") == "" or statusHeight < 6)
end

function G:RefreshVisibility2496()
    self:SuppressNativeTracker2505()
    local frame = self:Create2505()
    if not frame then return end

    local pursuitName = tostring(self.selectedPursuitName2504 or "")
    local questName = tostring(self.selectedQuestName2504 or "")
    local hasSelection = pursuitName ~= "" or questName ~= ""
    local enabled = not EPC.saved or EPC.saved.showGoldenPursuitsOverlay ~= false
    local show = (enabled and hasSelection) or self.layoutMode

    if show and not self.layoutMode and EPC.OverlayModeAllows then
        show = EPC:OverlayModeAllows("goldenPursuitsVisibility")
    end

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
    EPC.saved.goldenPursuitsManualSize2875 = true
    self:ApplyCompactLayout2875()
end

function G:ResetSize()
    local frame = self:Create2505()
    if not frame or not EPC.saved then return end
    EPC.saved.goldenPursuitsWidth = DEFAULT_WIDTH
    EPC.saved.goldenPursuitsHeight = DEFAULT_HEIGHT
    EPC.saved.goldenPursuitsManualSize2875 = false
    frame:SetDimensions(DEFAULT_WIDTH, DEFAULT_HEIGHT)
    self:ApplyCompactLayout2875()
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
    self.selectedCampaignKey2871 = EPC.saved and EPC.saved.goldenPursuitCampaignKey2871 or nil
    self.selectedActivityIndex2871 = EPC.saved and tonumber(EPC.saved.goldenPursuitActivityIndex2871) or nil
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
    if PROMOTIONAL_EVENT_MANAGER and type(PROMOTIONAL_EVENT_MANAGER.RegisterCallback) == "function" then
        pcall(PROMOTIONAL_EVENT_MANAGER.RegisterCallback, PROMOTIONAL_EVENT_MANAGER, "ActivityProgressUpdated", function()
            self:RefreshSelectedQuestPanel2504()
        end)
        pcall(PROMOTIONAL_EVENT_MANAGER.RegisterCallback, PROMOTIONAL_EVENT_MANAGER, "RewardsClaimed", function()
            self:RefreshSelectedQuestPanel2504()
        end)
    end
    EVENT_MANAGER:RegisterForUpdate(prefix .. "_Visibility", 200, function()
        self:SuppressNativeTracker2505()
        self:RefreshVisibility2496()
    end)
    EVENT_MANAGER:RegisterForUpdate(prefix .. "_Progress2871", 750, function()
        if self.selectedPursuitName2504 ~= "" then
            self:RefreshSelectedQuestPanel2504()
        end
    end)
end

-- v0.28.72: the Golden Pursuits HUD is independently toggleable. The
-- authoritative quest-tracking source still controls ESO assisted tracking and
-- compass behavior, but no longer suppresses this dedicated overlay.
local easLegacyRefreshVisibility_2513 = G.RefreshVisibility2496
function G:RefreshVisibility2496()
    return easLegacyRefreshVisibility_2513(self)
end


-- v0.28.74: Golden Pursuits progress/campaign text uses white and the status
-- row collapses upward whenever there is no separate pursuit-task line.

-- v0.28.74: Golden Pursuits progress and campaign values render as separate
-- white bullet rows to match the Active Quest objective presentation.
