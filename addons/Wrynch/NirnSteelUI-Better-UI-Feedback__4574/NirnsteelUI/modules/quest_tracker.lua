local NAME = "NirnsteelUI_QuestTracker"
Nirnsteel_UI = Nirnsteel_UI or {}
local Tracker = {}
Nirnsteel_UI.QuestTracker = Tracker
local function Settings() return Nirnsteel_UI.Settings:GetQuestTracker() end

function Tracker:HasCustomPosition()
    local position = Settings().position
    return type(position) == "table" and type(position.x) == "number" and type(position.y) == "number"
end

function Tracker:ApplyPosition()
    local panel = self.panel
    if not panel or self.applyingPosition then return end
    self.applyingPosition = true
    if self:HasCustomPosition() then
        local position = Settings().position
        panel:ClearAnchors()
        panel:SetAnchor(TOPLEFT,GuiRoot,TOPLEFT,position.x,position.y)
    end
    self.applyingPosition = false
end

function Tracker:RefreshMover()
    local panel = ZO_FocusedQuestTrackerPanel
    if not panel then return end
    if not self.panel then
        self.panel = panel
        -- Native HUD/platform layout updates must retain a user-selected position.
        ZO_PostHook(panel,"SetAnchor",function() self:ApplyPosition() end)
    end
    self:ApplyPosition()
    if not self.mover and Settings().unlocked then
        local mover = WINDOW_MANAGER:CreateTopLevelWindow(NAME .. "Mover")
        mover:SetClampedToScreen(true)
        mover:SetMouseEnabled(true)
        mover:SetMovable(true)
        mover:SetDrawTier(DT_HIGH)
        mover:SetDimensions(300,32)
        local backdrop = WINDOW_MANAGER:CreateControl(nil,mover,CT_BACKDROP)
        backdrop:SetAnchorFill(mover)
        backdrop:SetMouseEnabled(false)
        backdrop:SetCenterColor(0.02,0.02,0.02,0.75)
        backdrop:SetEdgeColor(0.48,0.68,0.80,0.92)
        backdrop:SetEdgeTexture("",1,1,2)
        local label = WINDOW_MANAGER:CreateControl(nil,mover,CT_LABEL)
        label:SetAnchor(CENTER,mover,CENTER,0,0)
        label:SetFont("ZoFontGameBold")
        label:SetText("Quest Log - Drag to Move")
        label:SetMouseEnabled(false)
        mover:SetHandler("OnMoveStop",function(control)
            Settings().position = {x=control:GetLeft(),y=control:GetTop()}
            self:ApplyPosition()
        end)
        self.mover = mover
    end
    if self.mover then
        self.mover:SetHidden(not Settings().unlocked)
        self.mover:ClearAnchors()
        self.mover:SetAnchor(TOPLEFT,GuiRoot,TOPLEFT,panel:GetLeft(),panel:GetTop())
    end
end

local function Diamond(parent,size,x,y)
    local shape = WINDOW_MANAGER:CreateControl(nil,parent,CT_POLYGON)
    shape:SetDimensions(size,size)
    shape:SetAnchor(TOPLEFT,parent,TOPLEFT,x,y)
    shape:SetMouseEnabled(false)
    shape:SetDrawLayer(DL_BACKGROUND)
    shape:SetPointLayout(POLYGON_POINT_LAYOUT_CLOCKWISE)
    shape:SetSmoothingEnabled(false)
    for _,p in ipairs({{0.5,0},{1,0.5},{0.5,1},{0,0.5}}) do shape:AddPoint(p[1],p[2]) end
    shape:SetCenterColor(0.58,0.66,0.72,0.9)
    return shape
end

function Tracker:StyleLabel(control,kind)
    local enabled = Settings().enabled
    if not control.nirnsteelQuestArt and enabled then
        local art = {}
        control.nirnsteelQuestArt = art
        if kind == "header" then
            -- A small floating ornament, with no panel or enclosing border.
            art.rule = WINDOW_MANAGER:CreateControl(nil,control,CT_TEXTURE)
            art.rule:SetDimensions(48,1)
            art.rule:SetAnchor(TOPLEFT,control,BOTTOMLEFT,11,7)
            art.rule:SetColor(0.66,0.73,0.78,0.85)
            art.rule:SetMouseEnabled(false)
            art.rule:SetDrawLayer(DL_BACKGROUND)
            art.tail = WINDOW_MANAGER:CreateControl(nil,control,CT_TEXTURE)
            art.tail:SetDimensions(28,1)
            art.tail:SetAnchor(TOPLEFT,control,BOTTOMLEFT,59,7)
            art.tail:SetColor(0.66,0.73,0.78,0.3)
            art.tail:SetMouseEnabled(false)
            art.tail:SetDrawLayer(DL_BACKGROUND)
            art.seal = Diamond(control,5,0,0)
            art.seal:ClearAnchors()
            art.seal:SetAnchor(TOPLEFT,control,BOTTOMLEFT,1,5)
        elseif kind == "condition" then
            art.marker = Diamond(control,5,-10,8)
            art.thread = WINDOW_MANAGER:CreateControl(nil,control,CT_TEXTURE)
            art.thread:SetWidth(1)
            art.thread:SetAnchor(TOPLEFT,control,TOPLEFT,-8,16)
            art.thread:SetAnchor(BOTTOMLEFT,control,BOTTOMLEFT,-8,2)
            art.thread:SetColor(0.52,0.61,0.68,0.28)
            art.thread:SetMouseEnabled(false)
            art.thread:SetDrawLayer(DL_BACKGROUND)
        end
    end
    for _,part in pairs(control.nirnsteelQuestArt or {}) do part:SetHidden(not enabled) end
    local color = {control:GetColor()}
    local previous = control.nirnsteelQuestColor
    if not previous or color[1] ~= previous[1] or color[2] ~= previous[2] or color[3] ~= previous[3] then
        control.nirnsteelNativeColor = color
    end
    if not enabled then
        if control.nirnsteelNativeColor then control:SetColor(unpack(control.nirnsteelNativeColor)) end
        control.nirnsteelQuestColor = nil
        return
    end
    local palette = kind == "header" and {0.86,0.90,0.93,1}
        or kind == "progress" and {0.64,0.73,0.79,1} or {0.88,0.85,0.77,1}
    control.nirnsteelQuestColor = palette
    control:SetColor(unpack(palette))
    local size = kind == "header" and Settings().titleSize or Settings().textSize
    if IsInGamepadPreferredMode() then size = size + 3 end
    control:SetFont((kind == "header" and "$(ANTIQUE_FONT)" or "$(MEDIUM_FONT)") .. "|" .. size .. "|soft-shadow-thick")
    -- Leave native widths, icons, bindings and mouse handlers intact.
    if control.m_TreeNode then control.m_TreeNode:SetOffsetY(kind == "header" and 24 or Settings().spacing + 9) end
end

function Tracker:StyleTomes()
    local tomes = self.tomes
    if not tomes or self.stylingTomes then return end
    self.stylingTomes = true
    self:StyleLabel(tomes.headerLabel,"header")
    self:StyleLabel(tomes.subLabel,"condition")
    self:StyleLabel(tomes.progressLabel,"progress")
    if Settings().enabled then
        -- Keep the native container anchors so other HUD trackers still stack.
        tomes.subLabel:ClearAnchors()
        tomes.subLabel:SetAnchor(TOPLEFT,tomes.headerLabel,BOTTOMLEFT,10,18)
        tomes.subLabel:SetAnchor(TOPRIGHT,tomes.headerLabel,BOTTOMRIGHT,0,18)
        if not self.tomeProgress then
            local bar = WINDOW_MANAGER:CreateControl(nil,tomes.progressLabel,CT_STATUSBAR)
            bar:SetHeight(2)
            bar:SetAnchor(TOPLEFT,tomes.progressLabel,BOTTOMLEFT,0,5)
            bar:SetAnchor(TOPRIGHT,tomes.progressLabel,BOTTOMRIGHT,0,5)
            bar:SetColor(0.57,0.69,0.76,0.95)
            bar:SetMouseEnabled(false)
            self.tomeProgress = bar
        end
        local data
        if not IsPromotionalEventSystemLocked() then
            local key,index = GetTrackedPromotionalEventActivityInfo()
            local campaign = PROMOTIONAL_EVENT_MANAGER:GetCampaignDataByKey(key)
            if campaign and campaign:ShouldCampaignBeVisible() then data = campaign:GetActivityData(index) end
        end
        local maximum
        if data then maximum = data:GetCompletionThreshold()
        elseif IsTimedActivitySystemAvailable() then
            local index = GetTrackedTimedActivityInfo()
            data = index and TIMED_ACTIVITIES_MANAGER:GetActivityDataByIndex(index)
            maximum = data and data:GetMaxProgress()
        end
        self.tomeProgress:SetHidden(not data or not maximum or maximum <= 0)
        if data and maximum and maximum > 0 then
            self.tomeProgress:SetMinMax(0,maximum)
            self.tomeProgress:SetValue(math.min(maximum,math.max(0,data:GetProgress())))
        end
    elseif self.tomeProgress then self.tomeProgress:SetHidden(true) end
    self.stylingTomes = false
end

function Tracker:InitializeTomes()
    if self.tomes or not PROMOTIONAL_EVENT_TRACKER then return end
    self.tomes = PROMOTIONAL_EVENT_TRACKER
    for _,method in ipairs({"Update","ApplyPlatformStyle","RefreshAnchors"}) do
        ZO_PostHook(self.tomes,method,function() self:StyleTomes() end)
    end
end

function Tracker:Apply()
    for _,entry in ipairs({{self.native.headerPool,"header"},{self.native.conditionPool,"condition"},
        {self.native.stepDescriptionPool,"step"}}) do
        for _,control in pairs(entry[1]:GetActiveObjects()) do self:StyleLabel(control,entry[2]) end
    end
end

function Tracker:Initialize()
    if self.native then return true end
    local native = FOCUSED_QUEST_TRACKER
    if not native or not native.headerPool or not native.conditionPool or not native.stepDescriptionPool then return false end
    self.native = native
    -- Style before tree layout so wrapped text uses the correct font dimensions.
    ZO_PreHook(native,"UpdateTreeView",function() self:Apply(); return false end)
    for _,pool in ipairs({native.headerPool,native.conditionPool,native.stepDescriptionPool}) do
        local targetPool = pool
        ZO_PreHook(targetPool,"ReleaseObject",function(_,key)
            local control = targetPool:GetActiveObjects()[key]
            if control then
                for _,part in pairs(control.nirnsteelQuestArt or {}) do part:SetHidden(true) end
            end
            return false
        end)
    end
    return true
end

function Tracker:RefreshSettings()
    self:InitializeTomes()
    if not self:Initialize() then return end
    -- Restores native fonts/spacing when disabled; the hook reapplies when on.
    self.native:ApplyPlatformStyle()
    if self.tomes and self.tomes.currentStyle then self.tomes:ApplyPlatformStyle(self.tomes.currentStyle) end
    self:RefreshMover()
end

EVENT_MANAGER:RegisterForEvent(NAME,EVENT_ADD_ON_LOADED,function(_,addon)
    if addon ~= "NirnsteelUI" then return end
    EVENT_MANAGER:UnregisterForEvent(NAME,EVENT_ADD_ON_LOADED)
    Tracker:RefreshSettings()
end)
EVENT_MANAGER:RegisterForEvent(NAME .. "_Activated",EVENT_PLAYER_ACTIVATED,function() Tracker:RefreshSettings() end)
