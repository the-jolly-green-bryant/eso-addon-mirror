local NAME = "NirnsteelUI_WerewolfRage"
Nirnsteel_UI = Nirnsteel_UI or {}
local Rage = {}
Nirnsteel_UI.WerewolfRage = Rage
local function Settings() return Nirnsteel_UI.Settings:GetWerewolfRage() end
local function Clamp(n, low, high) return math.max(low, math.min(high, tonumber(n) or low)) end

function Rage:CreateView()
    if self.root then return end
    local root = WINDOW_MANAGER:CreateTopLevelWindow(NAME)
    self.root = root
    root:SetDimensions(320, 218)
    root:SetDrawTier(DT_HIGH)
    root:SetClampedToScreen(true)
    root:SetMouseEnabled(false)
    root:SetHidden(true)
    root:SetHandler("OnMouseDown",function(control,button)
        if button == MOUSE_BUTTON_INDEX_LEFT and Settings().unlocked then
            control:SetMovable(true)
            control:StartMoving()
        end
    end)
    root:SetHandler("OnMouseUp",function(control,button)
        if button == MOUSE_BUTTON_INDEX_LEFT then control:StopMovingOrResizing() end
    end)
    root:SetHandler("OnMoveStop",function(control)
        control:SetMovable(false)
        local x,y = control:GetCenter()
        local rootX,rootY = GuiRoot:GetCenter()
        Settings().x,Settings().y = x-rootX,y-rootY
    end)
    local art = Nirnsteel_UI:GetAssetPath("ui/werewolf/")
    local function Texture(file, w, h, x, y, level)
        local c = WINDOW_MANAGER:CreateControl(nil, root, CT_TEXTURE)
        c:SetDimensions(w,h)
        c:SetAnchor(TOPLEFT,root,TOPLEFT,x,y)
        c:SetTexture(art .. file .. "_dxt5.dds")
        c:SetDrawLayer(DL_ARTWORK)
        c:SetDrawLevel(level)
        return c
    end
    self.glow = Texture("claws_glow",320,160,0,0,1)
    self.glow:SetBlendMode(TEX_BLEND_MODE_ADD)
    self.frame = Texture("claws_base",320,160,0,0,2)
    self.fill = Texture("claws_fill",320,160,0,0,3)
    self.title = WINDOW_MANAGER:CreateControl(nil,root,CT_LABEL)
    self.title:SetAnchor(TOP,root,TOP,0,164)
    self.title:SetFont("$(ANTIQUE_FONT)|23|soft-shadow-thick")
    self.title:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    self.title:SetWidth(320)
    self.value = WINDOW_MANAGER:CreateControl(nil,root,CT_LABEL)
    self.value:SetAnchor(TOP,root,TOP,0,194)
    self.value:SetFont("$(MEDIUM_FONT)|16|soft-shadow-thick")
    self.value:SetColor(0.75,0.79,0.82,1)
end

function Rage:ReadState()
    local current, maximum = GetUnitPower("player", COMBAT_MECHANIC_FLAGS_WEREWOLF)
    current, maximum = tonumber(current) or 0, tonumber(maximum) or 0
    local slot = ACTION_BAR_ULTIMATE_SLOT_INDEX + 1
    local category = GetActiveHotbarCategory()
    local cost = GetSlotAbilityCost(slot, COMBAT_MECHANIC_FLAGS_WEREWOLF, category)
    local threshold = cost and cost > 0 and cost or maximum
    local ready = maximum > 0 and current >= threshold and category == HOTBAR_CATEGORY_WEREWOLF
        and IsSlotUsable(slot, category)
    return current, maximum, ready
end

function Rage:SetPulsing(active)
    if active then
        if not self.pulseStart then
            self.pulseStart = GetFrameTimeMilliseconds()
            self.root:SetHandler("OnUpdate",function() self:UpdatePulse() end)
        end
        self:UpdatePulse()
    elseif self.pulseStart then
        self.pulseStart = nil
        self.root:SetHandler("OnUpdate",nil)
        self.glow:SetAlpha(1)
        self.fill:SetAlpha(1)
    end
end

function Rage:UpdatePulse()
    if not self.pulseStart then return end
    -- A two-second breath, with no scale/anchor changes or abrupt flashes.
    local elapsed = GetFrameTimeMilliseconds()-self.pulseStart
    local light = (1 + math.cos(elapsed / 2000 * 2 * math.pi)) * 0.5
    self.glow:SetAlpha(0.45 + 0.55 * light)
    self.fill:SetAlpha(0.82 + 0.18 * light)
end

function Rage:Render(current, maximum, ready)
    local fraction = maximum > 0 and Clamp(current / maximum,0,1) or 0
    self.fill:SetHidden(fraction == 0)
    self.fill:SetWidth(math.max(1,320*fraction))
    self.fill:SetTextureCoords(0,fraction,0,1)
    -- Three wounds charge from left to right; full Rage breathes with light.
    if ready then
        self.fill:SetColor(1,0.68,0.36,1)
        self.glow:SetColor(1,0.12,0.025,0.85)
        self.title:SetColor(1,0.85,0.58,1)
        self.title:SetText("RAMPAGE READY")
    else
        self.fill:SetColor(0.48+fraction*0.52,0.035+fraction*fraction*0.30,0.025+fraction*0.035,1)
        self.glow:SetColor(0.9,0.015,0.03,fraction*0.30)
        self.title:SetColor(0.75+fraction*0.25,0.64-fraction*0.22,0.59-fraction*0.30,1)
        self.title:SetText("")
    end
    local showTitle = ready and Settings().showReady ~= false
    self.title:SetHidden(not showTitle)
    self.value:ClearAnchors()
    self.value:SetAnchor(TOP,self.root,TOP,0,showTitle and 194 or 164)
    self.value:SetText(string.format("%d / %d",current,maximum))
    self.value:SetHidden(not Settings().showValue)
    self:SetPulsing(fraction >= 1 and not self.root:IsHidden())
end

function Rage:SyncNative(hide)
    local native = ZO_PlayerAttributeWerewolf
    if not native then return end
    if self.native ~= native then
        self.native = native
        self.nativeWantedHidden = native:IsHidden()
        ZO_PreHook(native,"SetHidden",function(_,hidden)
            if self.settingNative then return false end
            self.nativeWantedHidden = hidden
            return self.nativeSuppressed and not hidden
        end)
    end
    if hide ~= self.nativeSuppressed then
        self.nativeSuppressed = hide
        self.settingNative = true
        native:SetHidden(hide or self.nativeWantedHidden)
        self.settingNative = false
    end
end

function Rage:Update()
    local settings = Settings()
    local wolf = IsPlayerInWerewolfForm()
    local preview = self.previewStart and GetFrameTimeMilliseconds()-self.previewStart < 12000
    if not preview then self.previewStart = nil end
    local unlocked = settings.enabled and settings.unlocked
    local active = settings.enabled and (wolf or preview or unlocked)
    self:SyncNative(settings.enabled and wolf)
    self.root:SetHidden(not active or (not preview and not unlocked and not SCENE_MANAGER:IsShowing("hud") and not SCENE_MANAGER:IsShowing("hudui")))
    if active then
        if preview then
            local elapsed = GetFrameTimeMilliseconds()-self.previewStart
            local amount = math.min(100,math.floor(elapsed/70))
            self:Render(amount,100,amount == 100)
        elseif unlocked and not wolf then self:Render(100,100,true)
        else self:Render(self:ReadState()) end
        if not self.updating then
            self.updating = true
            EVENT_MANAGER:RegisterForUpdate(NAME,100,function() self:Update() end)
        end
    else
        self:SetPulsing(false)
        EVENT_MANAGER:UnregisterForUpdate(NAME)
        self.updating = false
    end
end

function Rage:RefreshSettings()
    self:CreateView()
    local settings = Settings()
    self.root:ClearAnchors()
    self.root:SetAnchor(CENTER,GuiRoot,CENTER,Clamp(settings.x,-1600,1600),Clamp(settings.y,-900,900))
    self.root:SetScale(Clamp(settings.scale,60,160)/100)
    self.root:SetAlpha(Clamp(settings.opacity,20,100)/100)
    self.root:SetMouseEnabled(settings.enabled and settings.unlocked == true)
    if not settings.enabled then self.previewStart = nil end
    self:Update()
end

function Rage:Preview()
    if not Settings().enabled then return end
    self.previewStart = GetFrameTimeMilliseconds()
    self:RefreshSettings()
end

EVENT_MANAGER:RegisterForEvent(NAME,EVENT_ADD_ON_LOADED,function(_,addon)
    if addon ~= "NirnsteelUI" then return end
    EVENT_MANAGER:UnregisterForEvent(NAME,EVENT_ADD_ON_LOADED)
    Rage:RefreshSettings()
    EVENT_MANAGER:RegisterForEvent(NAME,EVENT_WEREWOLF_STATE_CHANGED,function() Rage:Update() end)
    EVENT_MANAGER:RegisterForEvent(NAME .. "_Activated",EVENT_PLAYER_ACTIVATED,function() Rage:RefreshSettings() end)
end)
