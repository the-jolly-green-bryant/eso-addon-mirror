--- @class Srendarr
local Srendarr = _G['Srendarr'] -- grab addon table from global
local L = Srendarr:GetLocale()
local LMP = LibMediaProvider
--- @class Srendarr_CastBar
local Cast = _G['Srendarr_CastBar']

-- UPVALUES --
local strformat = string.format
local GetGameTimeMillis = GetGameTimeMilliseconds
local GetLatency = GetLatency
local IsSlotToggled = IsSlotToggled
local AddControl = Srendarr.AddControl

local exhaustingFatecarver = Srendarr.exhaustingFatecarver
local crystalFragments = Srendarr.crystalFragments         -- used for crystal frags procs (no cast if proc'd)
local crystalFragmentsProc = Srendarr.crystalFragmentsProc -- used for crystal frags procs (no cast if proc'd)
local castBarDelayAuras = Srendarr.castBarDelayAuras

local slotData = Srendarr.slotData
local cruxId = Srendarr.cruxId
local tTenths = L.Time_Tenths
local isCastingOrChannelling = false
local currentTime, data
local settings


-- ------------------------
-- CAST BAR UPDATE HANDLER
do ------------------------
    local RATE = Srendarr.CAST_UPDATE_RATE
    local nextUpdate = 0
    local timeRemaining

    local function OnUpdate(self, updateTime)
        if (updateTime >= nextUpdate) then
            if self.castFinish ~= nil then
                timeRemaining = self.castFinish - updateTime
            else
                timeRemaining = 0
            end

            if (timeRemaining <= 0) then -- cast complete, stop cast
                Srendarr.IsCasting = false
                self:OnCastStop()
            else
                if (self.isChannel) then
                    Cast.bar:SetValue(1 - ((updateTime - self.castStart) / (self.castFinish - self.castStart)))
                else
                    Cast.bar:SetValue((updateTime - self.castStart) / (self.castFinish - self.castStart))
                end

                Cast.timer:SetText(strformat(tTenths, timeRemaining))
            end

            nextUpdate = updateTime + RATE
        end
    end

    Cast:SetHidden(true)
    Cast:SetHandler('OnUpdate', OnUpdate)
end


-- ------------------------
-- CAST CONTROL
-- ------------------------
function Cast:OnCastStart(isChannel, castName, start, finish, castIcon, abilityID)
    self.isChannel = isChannel
    self.castStart = start
    self.castFinish = finish
    self.abilityID = abilityID

    self.name:SetText(zo_strformat(SI_ABILITY_TOOLTIP_NAME, castName))
    self.icon:SetTexture(castIcon)

    currentTime = GetGameTimeMillis() / 1000

    if (isChannel) then
        self.bar:SetValue((currentTime - start) / (finish - start))
    else
        self.bar:SetValue(1 - ((currentTime - start) / (finish - start)))
    end

    self.timer:SetText(strformat(tTenths, finish - currentTime))

    isCastingOrChannelling = true

    self:SetHidden(false)
end

function Cast:OnCastStop()
    isCastingOrChannelling = false

    self:SetHidden(true)
end

--[[ UNUSED FOR NOW
local function OnActionUpdateCooldowns()
	if (isCastingOrChannelling) then
		if (GetSlotCooldownInfo(Cast.slotID) > 0) then -- on cooldown, cast must be complete, cancel active
			d(string.format('%.3f OnActionUpdateCooldowns - Cancelled Cast', GetFrameTimeSeconds())
			Cast:OnCastStop()
		end
	end
end]]

local function OnActionSlotAbilityUsed(evt, slot, cPass)
    if (slot < 3 or slot > 8) then return end

    data = slotData[slot]

    if data.abilityID and castBarDelayAuras[data.abilityID] and not cPass then return end -- do not duplicate bar casts for combat event proxy auras (Phinix)

    if (not data.isDelayed) and not cPass then return end                                 -- this ability is instant cast

    if (IsSlotToggled(slot)) and not cPass then return end                                -- ability is toggled on, so no cast time to cancel

    if (isCastingOrChannelling and (data.abilityID == Cast.abilityID)) then return end    -- already casting this ability, bail out

    if (data.abilityName == crystalFragments and crystalFragmentsProc) then return end    -- no cast bar if ability is frags and the proc is active (instant)

    currentTime = GetGameTimeMillis() / 1000

    local duration = data.castTime / 1000            -- gold coast removes channeled cast separation from duration and uses only one return value for both with GetAbilityCastInfo (Phinix)

    if data.abilityName == exhaustingFatecarver then -- add crux multiplier to Exhausting Fatecarver duration (Phinix)
        duration = duration + (0.3 * Srendarr.cruxCurrent)
    end

    Cast:OnCastStart(
        data.isChannel,
        data.abilityName,
        currentTime,
        currentTime + duration + (GetLatency() / 1000),
        data.abilityIcon,
        data.abilityID
    )
end

function Cast:ProxyCastBar(slot, abilityId)
    OnActionSlotAbilityUsed(nil, slot, abilityId)
end

-- ------------------------
-- CONFIGURATION
-- ------------------------
function Srendarr:ConfigureCastBar()
    settings = self.db.castBar
    if (not settings.enabled) then
        EVENT_MANAGER:UnregisterForEvent(self.name .. 'Cast', EVENT_ACTION_SLOT_ABILITY_USED)
        Cast:SetHidden(true)
        Cast.icon:SetHidden(true)
        Cast.bar:SetHidden(true)
        Cast.name:SetHidden(true)
        Cast.timer:SetHidden(true)
        Cast.bar.borderL:SetHidden(true)
        Cast.bar.backdropL:SetHidden(true)
        return
    end

    Cast:SetHidden(false)
    Cast.icon:SetHidden(false)
    Cast.bar:SetHidden(false)
    Cast.bar.borderL:SetHidden(false)
    Cast.name:SetHidden(false)
    Cast.bar.backdropL:SetHidden(false)
    Cast:SetDimensions(settings.barWidth + 26, 23)

    Cast.icon:ClearAnchors()
    Cast.bar:ClearAnchors()
    Cast.bar:SetDimensions(settings.barWidth, 23)
    Cast.bar:SetGradientColors(settings.barColor.r1, settings.barColor.g1, settings.barColor.b1, 1, settings.barColor.r2, settings.barColor.g2, settings.barColor.b2, 1)
    Cast.bar.gloss:SetDimensions(settings.barWidth, 23)
    Cast.bar.gloss:SetHidden(not settings.barGloss)
    Cast.bar.borderM:SetDimensions(settings.barWidth - 17, 23)
    Cast.bar.backdropM:SetDimensions(settings.barWidth - 17, 23)

    Cast.name:ClearAnchors()
    Cast.name:SetFont(strformat('%s|%d|%s', LMP:Fetch('font', settings.nameFont), settings.nameSize, settings.nameStyle))
    Cast.name:SetColor(settings.nameColor[1], settings.nameColor[2], settings.nameColor[3], settings.nameColor[4])
    Cast.name:SetHidden(not settings.nameShow)

    Cast.timer:ClearAnchors()
    Cast.timer:SetFont(strformat('%s|%d|%s', LMP:Fetch('font', settings.timerFont), settings.timerSize, settings.timerStyle))
    Cast.timer:SetColor(settings.timerColor[1], settings.timerColor[2], settings.timerColor[3], settings.timerColor[4])
    Cast.timer:SetHidden(not settings.timerShow)

    if (settings.barReverse) then
        Cast.icon:SetAnchor(RIGHT, Cast, RIGHT, 0, 0)
        Cast.bar:SetAnchor(RIGHT, Cast.icon, LEFT, -3, 0)
        Cast.bar:SetBarAlignment(BAR_ALIGNMENT_REVERSE)
        Cast.bar.gloss:SetBarAlignment(BAR_ALIGNMENT_REVERSE)
        Cast.bar.borderL:SetDimensions(13, 23)
        Cast.bar.borderL:SetTextureCoords(0.3671874, 0.46875, 0.328125, 0.6875)
        Cast.bar.borderR:SetDimensions(4, 23)
        Cast.bar.borderR:SetTextureCoords(0.5859375, 0.6171875, 0.328125, 0.6875)
        Cast.bar.backdropL:SetDimensions(13, 23)
        Cast.bar.backdropL:SetTextureCoords(0.3671874, 0.46875, 0.328125, 0.6875)
        Cast.bar.backdropR:SetDimensions(4, 23)
        Cast.bar.backdropR:SetTextureCoords(0.5859375, 0.6171875, 0.328125, 0.6875)
        Cast.name:SetAnchor(RIGHT, Cast.bar, RIGHT, -5, 0)
        Cast.timer:SetAnchor(LEFT, Cast.bar, LEFT, 15, 0)
    else
        Cast.icon:SetAnchor(LEFT, Cast, LEFT, 0, 0)
        Cast.bar:SetAnchor(LEFT, Cast.icon, RIGHT, 3, 0)
        Cast.bar:SetBarAlignment(BAR_ALIGNMENT_NORMAL)
        Cast.bar.gloss:SetBarAlignment(BAR_ALIGNMENT_NORMAL)
        Cast.bar.borderL:SetDimensions(4, 23)
        Cast.bar.borderL:SetTextureCoords(0.6171875, 0.5859375, 0.328125, 0.6875)
        Cast.bar.borderR:SetDimensions(13, 23)
        Cast.bar.borderR:SetTextureCoords(0.46875, 0.3671874, 0.328125, 0.6875)
        Cast.bar.backdropL:SetDimensions(4, 23)
        Cast.bar.backdropL:SetTextureCoords(0.6171875, 0.5859375, 0.328125, 0.6875)
        Cast.bar.backdropR:SetDimensions(13, 23)
        Cast.bar.backdropR:SetTextureCoords(0.46875, 0.3671874, 0.328125, 0.6875)
        Cast.name:SetAnchor(LEFT, Cast.bar, LEFT, 5, 0)
        Cast.timer:SetAnchor(RIGHT, Cast.bar, RIGHT, -15, 0)
    end

    EVENT_MANAGER:RegisterForEvent(self.name .. 'Cast', EVENT_ACTION_SLOT_ABILITY_USED, OnActionSlotAbilityUsed)
end

-- ------------------------
-- DRAG OVERLAY
-- ------------------------
function Cast:EnableDragOverlay()
    self:SetMouseEnabled(true)
    self:SetMovable(true)

    currentTime = GetGameTimeMillis() / 1000

    Cast:OnCastStart(
        true,
        strformat('%s - %s', L.Srendarr_Basic, L.CastBar),
        currentTime,
        currentTime + 600,
        [[esoui/art/icons/ability_mageguild_001.dds]],
        Srendarr.castBarID
    )

    self:SetHidden(false)
end

function Cast:DisableDragOverlay()
    self:SetMouseEnabled(false)
    self:SetMovable(false)

    Cast:OnCastStop()

    self:SetHidden(true)
end

-- ------------------------
-- INITIALIZATION
-- ------------------------
function Srendarr:InitializeCastBar()
    settings = self.db.castBar

    Cast:SetKeyboardEnabled(false)
    Cast:SetMouseEnabled(false)
    Cast:SetMovable(false)
    Cast:SetDimensions(settings.barWidth + 26, 23)
    Cast:SetAnchor(settings.base.point, GuiRoot, settings.base.point, settings.base.x, settings.base.y)
    Cast:SetAlpha(settings.base.alpha) -- both values, if configured after load, are done directly)
    Cast:SetScale(settings.base.scale) -- both values, if configured after load, are done directly)

    Cast:SetHandler('OnReceiveDrag', function (f)
        f:StartMoving()
    end)
    Cast:SetHandler('OnMouseUp', function (f)
        f:StopMovingOrResizing()
        local point, x, y = Srendarr:GetEdgeRelativePosition(f)
        settings.base.point = point
        settings.base.x = x
        settings.base.y = y
    end)

    -- ICON
    Cast.icon = AddControl(Cast, CT_TEXTURE, 0)
    Cast.icon:SetDimensions(23, 23)
    Cast.iconBorder = AddControl(Cast.icon, CT_TEXTURE, 1)
    Cast.iconBorder:SetDimensions(23, 23)
    Cast.iconBorder:SetTexture([[/esoui/art/actionbar/abilityframe64_up.dds]])
    Cast.iconBorder:SetAnchor(CENTER)
    -- LABELS
    Cast.name = AddControl(Cast, CT_LABEL, 4)
    Cast.name:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    Cast.name:SetInheritScale(false)
    Cast.timer = AddControl(Cast, CT_LABEL, 4)
    Cast.timer:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    Cast.timer:SetInheritScale(false)
    -- BAR
    Cast.bar = AddControl(Cast, CT_STATUSBAR, 2)
    Cast.bar:SetTexture([[/esoui/art/unitattributevisualizer/attributebar_dynamic_fill.dds]])
    Cast.bar:SetTextureCoords(0, 1, 0, 0.53125)
    Cast.bar:SetLeadingEdge([[/esoui/art/unitattributevisualizer/attributebar_dynamic_leadingedge.dds]], 11, 17)
    Cast.bar:SetLeadingEdgeTextureCoords(0, 0.6875, 0, 0.53125)
    Cast.bar:EnableLeadingEdge(true)
    Cast.bar:SetHandler('OnValueChanged', function (bar, value) bar.gloss:SetValue(value) end) -- change gloss value as main bar changes
    -- BAR GLOSS
    Cast.bar.gloss = AddControl(Cast.bar, CT_STATUSBAR, 3)
    Cast.bar.gloss:SetAnchor(TOPLEFT)
    Cast.bar.gloss:SetTexture([[/esoui/art/unitattributevisualizer/attributebar_dynamic_fill_gloss.dds]])
    Cast.bar.gloss:SetTextureCoords(0, 1, 0, 0.53125)
    Cast.bar.gloss:SetLeadingEdge([[/esoui/art/unitattributevisualizer/attributebar_dynamic_leadingedge_gloss.dds]], 11, 17)
    Cast.bar.gloss:SetLeadingEdgeTextureCoords(0, 0.6875, 0, 0.53125)
    Cast.bar.gloss:EnableLeadingEdge(true)
    -- BAR FRAME
    Cast.bar.borderL = AddControl(Cast.bar, CT_TEXTURE, 4)
    Cast.bar.borderL:SetAnchor(TOPLEFT)
    Cast.bar.borderL:SetTexture([[/esoui/art/unitattributevisualizer/attributebar_dynamic_frame.dds]])
    Cast.bar.borderR = AddControl(Cast.bar, CT_TEXTURE, 4)
    Cast.bar.borderR:SetAnchor(TOPRIGHT)
    Cast.bar.borderR:SetTexture([[/esoui/art/unitattributevisualizer/attributebar_dynamic_frame.dds]])
    Cast.bar.borderM = AddControl(Cast.bar, CT_TEXTURE, 4)
    Cast.bar.borderM:SetAnchor(TOPLEFT, Cast.bar.borderL, TOPRIGHT, 0, 0)
    Cast.bar.borderM:SetTexture([[/esoui/art/unitattributevisualizer/attributebar_dynamic_frame.dds]])
    Cast.bar.borderM:SetTextureCoords(0.4921875, 0.5546875, 0.328125, 0.6875)
    -- BAR BACKDROP
    Cast.bar.backdropL = AddControl(Cast.bar, CT_TEXTURE, 1)
    Cast.bar.backdropL:SetAnchor(TOPLEFT)
    Cast.bar.backdropL:SetTexture([[/esoui/art/unitattributevisualizer/attributebar_dynamic_bg.dds]])
    Cast.bar.backdropR = AddControl(Cast.bar, CT_TEXTURE, 1)
    Cast.bar.backdropR:SetAnchor(TOPRIGHT)
    Cast.bar.backdropR:SetTexture([[/esoui/art/unitattributevisualizer/attributebar_dynamic_bg.dds]])
    Cast.bar.backdropM = AddControl(Cast.bar, CT_TEXTURE, 1)
    Cast.bar.backdropM:SetAnchor(TOPLEFT, Cast.bar.backdropL, TOPRIGHT, 0, 0)
    Cast.bar.backdropM:SetTexture([[/esoui/art/unitattributevisualizer/attributebar_dynamic_bg.dds]])
    Cast.bar.backdropM:SetTextureCoords(0.4921875, 0.5546875, 0.328125, 0.6875)

    self:ConfigureCastBar()
end

Srendarr.Cast = Cast