local T = BetterBars
T.ChatHUD = T.ChatHUD or {}
local CH = T.ChatHUD
local WM = WINDOW_MANAGER

local function Saved()
    return T.saved and T.saved.chatHUD
end

function CH:ResolveControl()
    if self.control then return self.control end
    -- Build a dense candidate list. A literal table containing an early nil
    -- would make ipairs stop before reaching the console-specific controls.
    local candidates = {}
    local function AddCandidate(control)
        if control then candidates[#candidates + 1] = control end
    end
    AddCandidate(ZO_ChatWindow)
    AddCandidate(ZO_ChatWindowContainer)
    AddCandidate(CHAT_SYSTEM and CHAT_SYSTEM.control)
    AddCandidate(CHAT_SYSTEM and CHAT_SYSTEM.primaryContainer and CHAT_SYSTEM.primaryContainer.control)
    AddCandidate(GAMEPAD_CHAT_SYSTEM and GAMEPAD_CHAT_SYSTEM.control)
    AddCandidate(GAMEPAD_CHAT_SYSTEM and GAMEPAD_CHAT_SYSTEM.primaryContainer and GAMEPAD_CHAT_SYSTEM.primaryContainer.control)
    for _, control in ipairs(candidates) do
        if control and control.ClearAnchors and control.SetDimensions then
            self.control = control
            break
        end
    end
    return self.control
end

function CH:CaptureNativeLayout()
    local control = self:ResolveControl()
    if not control or self.nativeLayout then return end
    -- ESO returns: isValid, point, relativeTo, relativePoint, offsetX, offsetY.
    -- The leading boolean must never be passed back as the anchor point.
    local isValid, point, relativeTo, relativePoint, offsetX, offsetY = control:GetAnchor(0)
    if not isValid or type(point) ~= "number" then return end
    if type(relativePoint) ~= "number" then relativePoint = point end
    self.nativeLayout = {
        point = point, relativeTo = relativeTo, relativePoint = relativePoint,
        offsetX = offsetX, offsetY = offsetY,
        width = control:GetWidth(), height = control:GetHeight(), scale = control:GetScale(),
    }
end

function CH:Apply()
    local control = self:ResolveControl()
    local saved = Saved()
    if not control or not saved then return false end
    self:CaptureNativeLayout()
    if saved.enabled == true then
        control:ClearAnchors()
        control:SetAnchor(CENTER, GuiRoot, CENTER, saved.offsetX or -520, saved.offsetY or 250)
        control:SetDimensions(zo_clamp(saved.width or 620, 300, 1000), zo_clamp(saved.height or 320, 160, 700))
        control:SetScale(zo_clamp(saved.scale or 1, 0.60, 1.40))
    elseif self.nativeLayout then
        local n = self.nativeLayout
        if type(n.point) ~= "number" then return false end
        control:ClearAnchors()
        control:SetAnchor(n.point or BOTTOMLEFT, n.relativeTo or GuiRoot, n.relativePoint or BOTTOMLEFT, n.offsetX or 0, n.offsetY or 0)
        control:SetDimensions(n.width, n.height)
        control:SetScale(n.scale or 1)
    end
    self:RefreshPreview()
    return true
end

function CH:SetOption(option, value)
    local saved = Saved()
    if not saved then return end
    saved[option] = value
    self:Apply()
    self:ShowPreview()
end

function CH:Nudge(dx, dy)
    local saved = Saved()
    if not saved then return end
    saved.offsetX = zo_clamp((saved.offsetX or 0) + dx, -1600, 1600)
    saved.offsetY = zo_clamp((saved.offsetY or 0) + dy, -900, 900)
    self:Apply()
    self:ShowPreview()
end

function CH:Reset()
    local saved = Saved()
    if not saved then return end
    saved.offsetX, saved.offsetY = -520, 250
    saved.width, saved.height, saved.scale = 620, 320, 1.0
    self:Apply()
    self:ShowPreview()
end

function CH:ApplyPreset(width, height, scale)
    local saved = Saved()
    if not saved then return end
    saved.width, saved.height, saved.scale = width, height, scale
    self:Apply()
    self:ShowPreview()
end

function CH:CreatePreview()
    if self.preview then return end
    local preview = WM:CreateTopLevelWindow("BetterBarsChatHUDPreview")
    preview:SetMouseEnabled(false)
    preview:SetDrawTier(DT_HIGH)
    preview:SetDrawLayer(DL_OVERLAY)
    local backdrop = WM:CreateControl(nil, preview, CT_BACKDROP)
    backdrop:SetAnchorFill()
    backdrop:SetCenterColor(0.05, 0.10, 0.16, 0.16)
    backdrop:SetEdgeColor(1.00, 0.83, 0.28, 0.95)
    backdrop:SetEdgeTexture("EsoUI/Art/Tooltips/UI-SliderBackdrop.dds", 2, 2, 2)
    local label = WM:CreateControl(nil, preview, CT_LABEL)
    label:SetAnchor(TOP, preview, TOP, 0, 8)
    label:SetFont("$(BOLD_FONT)|18|thick-outline")
    label:SetText("CHAT HUD")
    label:SetColor(1.00, 0.83, 0.28, 1)
    preview:SetHidden(true)
    self.preview = preview
end

function CH:RefreshPreview()
    if not self.preview or self.preview:IsHidden() then return end
    local control = self:ResolveControl()
    if not control then return end
    self.preview:ClearAnchors()
    self.preview:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)
    self.preview:SetDimensions(control:GetWidth(), control:GetHeight())
    self.preview:SetScale(control:GetScale())
end

function CH:ShowPreview()
    self:CreatePreview()
    self.preview:SetHidden(false)
    self:RefreshPreview()
    EVENT_MANAGER:UnregisterForUpdate("BetterBarsChatHUDPreviewTimeout")
    EVENT_MANAGER:RegisterForUpdate("BetterBarsChatHUDPreviewTimeout", 5000, function()
        EVENT_MANAGER:UnregisterForUpdate("BetterBarsChatHUDPreviewTimeout")
        if CH.preview then CH.preview:SetHidden(true) end
    end)
end

function CH:AddSettings(panel)
    local LHAS = LibHarvensAddonSettings
    panel:AddSettings({
        {type=LHAS.ST_SECTION,label="Chat HUD"},
        {type=LHAS.ST_LABEL,label="Resize and reposition ESO's native Chat HUD. The gold preview outline closes automatically after five seconds."},
        {type=LHAS.ST_CHECKBOX,label="Customize Native Chat HUD",tooltip="OFF restores the native chat position, size, and scale captured when Better Bars loaded.",getFunction=function() return Saved().enabled==true end,setFunction=function(v) CH:SetOption("enabled",v==true) end},
        {type=LHAS.ST_SLIDER,label="Chat Width",min=300,max=1000,step=20,getFunction=function() return Saved().width or 620 end,setFunction=function(v) CH:SetOption("width",v) end},
        {type=LHAS.ST_SLIDER,label="Chat Height",min=160,max=700,step=20,getFunction=function() return Saved().height or 320 end,setFunction=function(v) CH:SetOption("height",v) end},
        {type=LHAS.ST_SLIDER,label="Chat Scale",min=60,max=140,step=5,unit="%",getFunction=function() return zo_round((Saved().scale or 1)*100) end,setFunction=function(v) CH:SetOption("scale",v/100) end},
        {type=LHAS.ST_SLIDER,label="Chat Horizontal Position",min=-1200,max=1200,step=20,getFunction=function() return Saved().offsetX or -520 end,setFunction=function(v) CH:SetOption("offsetX",v) end},
        {type=LHAS.ST_SLIDER,label="Chat Vertical Position",min=-700,max=700,step=20,getFunction=function() return Saved().offsetY or 250 end,setFunction=function(v) CH:SetOption("offsetY",v) end},
        {type=LHAS.ST_BUTTON,buttonText="Preview Chat HUD",clickHandler=function() CH:ShowPreview() end},
        {type=LHAS.ST_BUTTON,buttonText="Compact Chat Preset",clickHandler=function() CH:ApplyPreset(460,220,0.90) end},
        {type=LHAS.ST_BUTTON,buttonText="Wide Chat Preset",clickHandler=function() CH:ApplyPreset(800,360,1.00) end},
        {type=LHAS.ST_BUTTON,buttonText="Chat Up",clickHandler=function() CH:Nudge(0,-20) end},
        {type=LHAS.ST_BUTTON,buttonText="Chat Down",clickHandler=function() CH:Nudge(0,20) end},
        {type=LHAS.ST_BUTTON,buttonText="Chat Left",clickHandler=function() CH:Nudge(-20,0) end},
        {type=LHAS.ST_BUTTON,buttonText="Chat Right",clickHandler=function() CH:Nudge(20,0) end},
        {type=LHAS.ST_BUTTON,buttonText="Restore Chat HUD Position and Size",clickHandler=function() CH:Reset() end},
    })
end

function CH:Initialize()
    self:CreatePreview()
    self:Apply()
    EVENT_MANAGER:RegisterForEvent("BetterBarsChatHUDActivated", EVENT_PLAYER_ACTIVATED, function()
        if Saved() and Saved().enabled == true then CH:Apply() end
    end)
end
