local A = PBS_CLOCK
local S = PBS_CLOCK_STRINGS
local PATH = "PBsClock/assets/"

local function Label(name, parent)
    local c = WINDOW_MANAGER:CreateControl(name, parent, CT_LABEL)
    c:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    c:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    c:SetColor(0.91, 0.85, 0.70, 1)
    c:SetMouseEnabled(false)
    return c
end

local function Texture(name, parent, file, level)
    local c = WINDOW_MANAGER:CreateControl(name, parent, CT_TEXTURE)
    c:SetTexture(PATH .. file .. ".dds")
    c:SetAnchor(CENTER, parent, CENTER, 0, 0)
    c:SetDrawLayer(DL_CONTROLS)
    c:SetDrawLevel(level)
    c:SetMouseEnabled(false)
    return c
end

function A:CreateUI()
    self.cards = {}
    for _, kind in ipairs({"real", "game"}) do
        local base = "PBsClock" .. kind
        local c = {root=WINDOW_MANAGER:CreateTopLevelWindow(base)}
        c.root:SetHidden(true)
        c.root:SetMouseEnabled(false)
        c.root:SetMovable(false)
        c.text = Label(base .. "Text", c.root)
        c.text:SetDrawLayer(DL_TEXT)
        c.dial = WINDOW_MANAGER:CreateControl(base .. "Dial", c.root, CT_CONTROL)
        c.face = Texture(base .. "Face", c.dial, "dial", 0)
        c.hour = Texture(base .. "Hour", c.dial, "hour", 1)
        c.minute = Texture(base .. "Minute", c.dial, "minute", 2)
        c.second = Texture(base .. "Second", c.dial, "second", 3)
        c.hub = Texture(base .. "Hub", c.dial, "hub", 4)
        self.cards[kind] = c
    end
end

function A:IsPreviewing()
    return self.panelOpen and self.sv.preview and self.active
end

function A:ApplyLayout()
    if not self.cards then return end
    local preview=self:IsPreviewing()
    self.renderStyle=preview and (self.previewStyle or self.sv.style) or self.sv.style
    local analog=self.renderStyle=="analog"
    local kinds=self:VisibleKinds()
    if preview and self.previewKind and self.sv.display~= "both" and self.sv.display~=self.previewKind then
        kinds[#kinds+1]=self.previewKind
    end
    self.activeKinds=kinds
    local sw,sh=math.max(1,GuiRoot:GetWidth()),math.max(1,GuiRoot:GetHeight())
    for _,kind in ipairs({"real","game"}) do
        local c=self.cards[kind]
        local layout=self:Layout(self.renderStyle,kind)
        local fontSize=layout.fontSize
        local showText=not analog or layout.showText
        local width,height,dialSize,textHeight,scale=self:LayoutMetrics(self.renderStyle,layout)
        c.root:SetScale(scale)
        c.root:SetDimensions(width,height)
        c.root:ClearAnchors()
        c.root:SetAnchor(TOPLEFT,GuiRoot,TOPLEFT,
            math.min(math.max(0,sw-width*scale),layout.x)/scale,
            math.min(math.max(0,sh-height*scale),layout.y)/scale)
        c.root:SetAlpha(self.sv.opacity/100)
        -- Root tier orders the complete clock, preserving face/hand/text ordering.
        local tier=({back=DT_LOW,normal=DT_MEDIUM,front=DT_HIGH})[layout.layer]
        c.root:SetDrawTier(preview and DT_HIGH or tier)
        c.root:SetDrawLayer(preview and DL_OVERLAY or DL_CONTROLS)
        c.root:SetDrawLevel(preview and 100 or 0)
        c.text:SetHidden(not showText)
        c.text:SetFont(string.format("$(BOLD_FONT)|%d|soft-shadow-thick",fontSize))
        c.text:SetHorizontalAlignment(({left=TEXT_ALIGN_LEFT,center=TEXT_ALIGN_CENTER,right=TEXT_ALIGN_RIGHT})[layout.align])
        c.text:SetColor(layout.color[1],layout.color[2],layout.color[3],1)
        c.text:ClearAnchors()
        -- A fixed-width label keeps the same position for every alignment. Anchor
        -- the content-sized label itself so alignment also changes its placement,
        -- independently of the renderer's internal paragraph alignment/layout cache.
        local textAnchor=({left=TOPLEFT,center=TOP,right=TOPRIGHT})[layout.align]
        c.text:SetDimensionConstraints(0,0,width,textHeight)
        c.text:SetDimensions(0,textHeight)
        c.text:SetAnchor(textAnchor,c.root,textAnchor,0,analog and dialSize or 0)
        c.dial:SetHidden(not analog)
        c.dial:ClearAnchors()
        c.dial:SetAnchor(TOP,c.root,TOP,0,0)
        c.dial:SetDimensions(dialSize,dialSize)
        for _,part in ipairs({c.face,c.hour,c.minute,c.second,c.hub}) do
            part:SetDimensions(dialSize,dialSize)
        end
    end
    self:Update()
end

function A:Update()
    for _, kind in ipairs(self.activeKinds or {}) do
        local c, time = self.cards[kind], self:ReadTime(kind)
        local analog = self.renderStyle == "analog"
        local text = S[kind] .. (analog and "\n" or "  ") .. self:FormatTime(time)
        if not time then text = S[kind] .. (analog and "\n" or "  ") .. S.unavailable end
        if c.lastText ~= text then c.text:SetText(text); c.lastText = text end
        if analog then
            c.hour:SetHidden(time == nil)
            c.minute:SetHidden(time == nil)
            c.second:SetHidden(time == nil or not self.sv.seconds)
            if time then
                local h, m, s = self:Angles(time)
                -- Texture rotation rotates sampling coordinates; negative is clockwise.
                c.hour:SetTextureRotation(-h, 0.5, 0.5)
                c.minute:SetTextureRotation(-m, 0.5, 0.5)
                c.second:SetTextureRotation(-s, 0.5, 0.5)
            end
        end
    end
end

function A:RefreshVisibility()
    if not self.cards then return end
    local visible=self.active and (self:IsPreviewing() or (self.sv.enabled and
        (HUD_SCENE:IsShowing() or HUD_UI_SCENE:IsShowing())))
    local wanted={}
    for _,kind in ipairs(self.activeKinds or {}) do wanted[kind]=true end
    for kind,c in pairs(self.cards) do c.root:SetHidden(not (visible and wanted[kind])) end
    EVENT_MANAGER:UnregisterForUpdate(self.name .. "Tick")
    if visible then
        self:Update()
        EVENT_MANAGER:RegisterForUpdate(self.name .. "Tick",250,function() self:Update() end)
    end
end
