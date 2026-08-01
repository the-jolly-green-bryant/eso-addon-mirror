--------------------------------------------------------------------------------
-- HUH Meter
--------------------------------------------------------------------------------

local STATE_DISABLED	= 0
local STATE_ENABLED		= 1
local STATE_EXTRA		= 2

local function setInfamyStyle(self, state, style)
	ApplyTemplateToControl(self.control, style.template)
	self.currencyOptions = style.currencyOptions
end

local function setTelVarStyle(self, state, style)
	self.gamepadStyle = style
	
	if state > STATE_DISABLED then
	end
		self:UpdatePlatformStyle(self.gamepadStyle)
end

local function setDaedricEnergyMeterStyle(self, state, style)
	if self.gamepadStyle ~= style then
		self.gamepadStyle = style
		self.platformStyle.gamepadStyle = style
	end
	
	self.platformStyle:Apply()
end

--------------------------------------------------------------------------------
-- Preview
--------------------------------------------------------------------------------

local previewUpdateTick = 2000
local UPDATE_TYPE_TICK = 0
local UPDATE_TYPE_EVENT = 1

local function updateInfamy(self, infamy, bounty, isKOS, isTrespassing)

	self:OnInfamyUpdated(UPDATE_TYPE_EVENT)
	self:UpdateInfamyMeterState(infamy, bounty, isKOS, isTrespassing)
--	self:OnInfamyUpdated(UPDATE_TYPE_EVENT)

	ZO_CurrencyControl_SetSimpleCurrency(self.bountyLabel, CURT_MONEY, bounty, self.currencyOptions, CURRENCY_SHOW_ALL, true)

	self:UpdateBar(self.infamyBar, self.infamyMeterState.infamy, UPDATE_TYPE_EVENT)
	self:UpdateBar(self.bountyBar, self.infamyMeterState.bounty, UPDATE_TYPE_EVENT)
end

local function previewInfamyMeter(self, show)
	if show then
		local infamy = GetInfamy()
		infamy = infamy > 0 and infamy or 100
		local bounty = GetBounty()
		bounty = bounty > 0 and bounty or 1000
		
		local isKOS = true
		local isTrespassing = false

		updateInfamy(self, infamy, bounty, isKOS, isTrespassing)
	else
		self:UpdateInfamyMeterState()
	end
end

local function previewTelVarMeter(self, show)
	if show then
		self:SetHiddenForReason("disabledInZone", false)
		local event = 0
		local newTelvarStones = 1500
		local oldTelvarStones = 500
		local reason = 0
		self:AnimateMeter(45)
		self:OnTelvarStonesUpdated(event, newTelvarStones, oldTelvarStones, reason)
		
        self:UpdateMeterBar()
        self:UpdateMultiplier()
	else
		self:AnimateMeter(0)
		self:OnTelvarStonesUpdated()
        self:UpdateMeterBar()
        self:UpdateMultiplier()
		self:SetHiddenForReason("disabledInZone", true)
	end
end

local function previewDaedricEnergyMeter(self, show)
	if show then
		local SHOULD_FADE_OUT = true
		self:SetHiddenForReason("daedricArtifactInactive", false, SHOULD_FADE_OUT)
		self.activeWeapon:Hide()
		self.activeWeapon = self.animationsForArtifactVisualType[DAEDRIC_ARTIFACT_VISUAL_TYPE_VOLENDRUNG]

		local not_instant = false
		self:UpdateEnergyValues(1000, 1000, not_instant)
		self.activeWeapon:Show()
	else
        local visualType = GetDaedricArtifactVisualType(GetLocalPlayerDaedricArtifactId())
		self.activeWeapon = self.animationsForArtifactVisualType[visualType]
		self.activeWeapon:Hide()
		self:UpdateVisibility()
	end
end

local function showPreview(Self, showFN, hideFN)
	showFN(Self, true)
	local name = tostring(Self)
	EVENT_MANAGER:UnregisterForUpdate(name)
    EVENT_MANAGER:RegisterForUpdate(name, previewUpdateTick, function()
		EVENT_MANAGER:UnregisterForUpdate(name)
		hideFN(Self, true)
	end)
end

local function onShow(callback, self)
	self:RequestHidden(false)
	callback(self, true)
end

local function onHide(callback, self)
	callback(self)
	self:RequestHidden(true)
end

local function onShowHiddenForReason(callback, self)
	self:SetHiddenForReason("hudScene", false)
	callback(self, true)
end

local function onHideHiddenForReason(callback, self)
	callback(self)
	self:SetHiddenForReason("hudScene", true)
end

local function hideAll()
	for k, name in pairs({tostring(HUD_INFAMY_METER), tostring(HUD_TELVAR_METER), tostring(HUD_DAEDRIC_ENERGY_METER)}) do
		if name then
			EVENT_MANAGER:UnregisterForUpdate(name)
		end
	end

	if not HUD_INFAMY_METER.control:IsHidden() then
		HUD_INFAMY_METER:RequestHidden(true)
	end

	if not HUD_TELVAR_METER.control:IsHidden() then
		previewTelVarMeter(HUD_TELVAR_METER)
		HUD_TELVAR_METER:SetHiddenForReason("hudScene", true)
	end

	if not HUD_DAEDRIC_ENERGY_METER.control:IsHidden() then
		previewDaedricEnergyMeter(HUD_DAEDRIC_ENERGY_METER)
		HUD_DAEDRIC_ENERGY_METER:SetHiddenForReason("hudScene", true)
	end
end

--------------------------------------------------------------------------------
-- 
--------------------------------------------------------------------------------

local HudMeters = ZO_InitializingObject:Subclass()

function HudMeters:Initialize(state)
	self.infamyMeter = {
		[STATE_DISABLED] = {
			['template'] = HUD_INFAMY_METER.isInGamepadMode and "ZO_HUDInfamyMeter_GamepadTemplate" or "ZO_HUDInfamyMeter_KeyboardTemplate",
			['currencyOptions'] = {
				showTooltips = true,
				customTooltip = SI_STATS_BOUNTY_LABEL,
				font = HUD_INFAMY_METER.isInGamepadMode and "ZoFontGamepadHeaderDataValue" or "ZoFontGameLargeBold",
				overrideTexture = HUD_INFAMY_METER.isInGamepadMode and ZO_Currency_GetGamepadCurrencyIcon(CURT_MONEY) or nil,
				iconSide = RIGHT,
				isGamepad = HUD_INFAMY_METER.isInGamepadMode
			}
		},
		[STATE_ENABLED] = {
			['template'] = 'ZO_HUDInfamyMeter_KeyboardTemplate',
			['currencyOptions'] = {
				showTooltips = true,
				customTooltip = SI_STATS_BOUNTY_LABEL,
				font = "ZoFontGameLargeBold",
			    overrideTexture = nil,
				iconSide = RIGHT,
				isGamepad = HUD_INFAMY_METER.isInGamepadMode
			},
			
		},
	}

--	local hud_telvar_meter_gamepadStyle = HUD_TELVAR_METER.gamepadStyle
	self.telVarStyle = {
	--	[STATE_DISABLED] = hud_telvar_meter_gamepadStyle,
		[STATE_DISABLED] = HUD_TELVAR_METER.gamepadStyle,
		[STATE_ENABLED] = HUD_TELVAR_METER.keyboardStyle,
	}
	
--	local hud_daedric_energy_meter_gamepadstyle = HUD_DAEDRIC_ENERGY_METER.gamepadStyle
	self.daedricEnergyMeter = {
	--	[STATE_DISABLED] = hud_daedric_energy_meter_gamepadstyle,
		[STATE_DISABLED] = HUD_DAEDRIC_ENERGY_METER.gamepadStyle,
		[STATE_ENABLED] = HUD_DAEDRIC_ENERGY_METER.keyboardStyle,
	}

	SCENE_MANAGER:GetScene("gameMenuInGame"):RegisterCallback("StateChange", function(oldState, newState)
		if newState == SCENE_SHOWN then
		elseif newState == SCENE_HIDDEN then
			hideAll()
		end
	end)
end

function HudMeters:SetState(state)
	if self.state ~= state then
		self.state = state

		if self.telVarStyle then
			setTelVarStyle(HUD_TELVAR_METER, state, self.telVarStyle[self.state])
		end
		if self.telVarStyle then
			setInfamyStyle(HUD_INFAMY_METER, state, self.infamyMeter[self.state])
		end
		if self.telVarStyle then
			setDaedricEnergyMeterStyle(HUD_DAEDRIC_ENERGY_METER, state, self.daedricEnergyMeter[self.state])
		end
	end
end

function HudMeters:ShowPreview(show)
	-- Stop queued previews from firing
	hideAll()
	
	if show then
		showPreview(HUD_INFAMY_METER, function(...)
			onShow(previewInfamyMeter, ...)
		end, function(...)
			onHide(previewInfamyMeter, ...)
			showPreview(HUD_TELVAR_METER, function(...)
				onShowHiddenForReason(previewTelVarMeter, ...)
			end, function(...)
				onHideHiddenForReason(previewTelVarMeter, ...)
				showPreview(HUD_DAEDRIC_ENERGY_METER, function(...)
					onShowHiddenForReason(previewDaedricEnergyMeter, ...)
				end, function(...)
					onHideHiddenForReason(previewDaedricEnergyMeter, ...)
				end)
			end)
		end)

	end
end

--------------------------------------------------------------------------------
-- 
--------------------------------------------------------------------------------

function IJA_GamepadUIVisibility_MoveHudMeters_Initialize()
	return HudMeters:New()
end
