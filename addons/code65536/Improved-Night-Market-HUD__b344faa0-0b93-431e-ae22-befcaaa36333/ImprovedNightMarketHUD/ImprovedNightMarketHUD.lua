local NAME = "ImprovedNightMarketHUD"
local TITLE = "Improved Night Market HUD"

EVENT_MANAGER:RegisterForEvent(NAME, EVENT_ADD_ON_LOADED, function( _, addonName )
	if (addonName ~= NAME) then return end
	EVENT_MANAGER:UnregisterForEvent(NAME, EVENT_ADD_ON_LOADED)

	if (not ADVENTURE_ZONE_HUD_TRACKER) then return end

	local MODE_DEFAULT = 1
	local MODE_SKIRMISH = 2
	local MODE_HIDDEN = 3

	local STATUS_LABELS = {
		[ADVENTURE_ZONE_WORLD_EVENT_LOCATION_STATE_INACTIVE] = { default = "Inactive", de = "Inaktiv", es = "Inactivo", fr = "Inactif", jp = "無効", ru = "Неактивно", zh = "未激活" },
		[ADVENTURE_ZONE_WORLD_EVENT_LOCATION_STATE_ACTIVE] = { default = "Active", de = "Aktiv", es = "Activo", fr = "Actif", jp = "有効", ru = "Активно", zh = "已激活" },
	}

	local MODE_LABELS = {
		[MODE_DEFAULT] = { default = "Show Scores" },
		[MODE_SKIRMISH] = { default = "Show Skirmishes" },
		[MODE_HIDDEN] = { default = "Hide" },
	}

	local W, H = 512, 256
	local ICON_REGIONS = {
		{ 144/W, 208/W, 24/H,  88/H }, -- /esoui/art/lfg/pc_nightmarket_skirmishgroupevent_skitteringprecinct_1x1.dds
		{ 192/W, 288/W, 36/H, 132/H }, -- /esoui/art/lfg/pc_nightmarket_skirmishgroupevent_theparch_1x1.dds
		{  64/W, 160/W, 32/H, 128/H }, -- /esoui/art/lfg/pc_nightmarket_skirmishgroupevent_sorrowsfriend_1x1.dds
		default = { 0, 1, 0, 1 },
	}

	local LANG = GetCVar("Language.2")
	local SV = { mode = MODE_SKIRMISH }

	-- Load SV only if it exists, since we're lazily creating SV only if settings are changed
	if (ImprovedNightMarketHUDSavedVariables and ImprovedNightMarketHUDSavedVariables.mode) then
		SV = ImprovedNightMarketHUDSavedVariables
	end

	function ADVENTURE_ZONE_HUD_TRACKER:INMHUD_Initialize( )
		self.INMHUD_Skirmishes = { }
		self.INMHUD_SkirmishChangesActive = false
		self.INMHUD_RefreshInfoCallback = function() self:INMHUD_RefreshInfo() end
		self.INMHUD_RefreshSkirmishStatusCallback = function() self:INMHUD_RefreshSkirmishStatus() end

		self.control:UnregisterForEvent(EVENT_PLAYER_ACTIVATED)
		self.control:RegisterForEvent(EVENT_PLAYER_ACTIVATED, ZO_GetEventForwardingFunction(self, self.INMHUD_Update))
		EVENT_MANAGER:UnregisterForEvent("AdventureZoneHUDTracker", EVENT_ADVENTURE_ZONE_FACTION_STANDING_UPDATE_RECEIVED)
		EVENT_MANAGER:RegisterForEvent(NAME, EVENT_ADVENTURE_ZONE_FACTION_STANDING_UPDATE_RECEIVED, self.INMHUD_RefreshInfoCallback)
		EVENT_MANAGER:RegisterForEvent(NAME, EVENT_ADVENTURE_ZONE_WORLD_EVENT_INIT, self.INMHUD_RefreshSkirmishStatusCallback)
		EVENT_MANAGER:RegisterForEvent(NAME, EVENT_ADVENTURE_ZONE_WORLD_EVENT_STARTS_SOON, self.INMHUD_RefreshSkirmishStatusCallback)
	end

	function ADVENTURE_ZONE_HUD_TRACKER:INMHUD_Update( )
		if (SV.mode == MODE_HIDDEN or (SV.mode == MODE_SKIRMISH and GetZoneId(GetUnitZoneIndex("player")) ~= 1559)) then
			self:GetFragment():SetHiddenForReason("NotInAdventureZone", true)
			return true
		else
			self:INMHUD_RefreshSkirmishStatus()
			return self:Update()
		end
	end

	function ADVENTURE_ZONE_HUD_TRACKER:INMHUD_RefreshFactionArrow( )
		self.playerFactionIndicator:SetHidden(SV.mode == MODE_SKIRMISH or GetUnitAdventureZoneFaction("player") == ADVENTURE_ZONE_FACTION_NONE)
	end

	function ADVENTURE_ZONE_HUD_TRACKER:INMHUD_RefreshSkirmishStatus( suppressInfoRefresh )
		local requestInfoRefresh = false
		if (SV.mode == MODE_SKIRMISH) then
			for index, factionControl in pairs(self.factionScoreControls) do
				self.INMHUD_Skirmishes[index] = { state = GetAdventureZoneEventLocationState(index), time = GetAdventureZoneEventLocationStartTimestampMs(index) }
				if (not self.INMHUD_SkirmishChangesActive) then
					factionControl.icon:SetTexture(GetAdventureZoneEventLocationBackgroundFileIndex(index))
					factionControl.icon:SetTextureCoords(unpack(ICON_REGIONS[index] or ICON_REGIONS.default))
					factionControl.score:SetIsCommaDelimited(false)
				end
			end
			if (not self.INMHUD_SkirmishChangesActive) then
				self.INMHUD_SkirmishChangesActive = true
				self:INMHUD_RefreshFactionArrow()
				EVENT_MANAGER:RegisterForUpdate(NAME, 1000, self.INMHUD_RefreshInfoCallback)
				requestInfoRefresh = true
			end
		elseif (self.INMHUD_SkirmishChangesActive) then
			self.INMHUD_SkirmishChangesActive = false
			self:INMHUD_RefreshFactionArrow()
			for faction, factionControl in pairs(self.factionScoreControls) do
				factionControl.icon:SetTexture(ZO_ADVENTURE_ZONE_FACTION_ICONS[faction])
				factionControl.icon:SetTextureCoords(unpack(ICON_REGIONS.default))
				factionControl.score:SetIsCommaDelimited(true)
			end
			EVENT_MANAGER:UnregisterForUpdate(NAME)
			requestInfoRefresh = true
		end

		if (requestInfoRefresh and not suppressInfoRefresh) then
			self:INMHUD_RefreshInfo()
		end
	end

	function ADVENTURE_ZONE_HUD_TRACKER:INMHUD_RefreshInfo( )
		if (SV.mode == MODE_DEFAULT) then
			return self:RefreshScores()
		elseif (SV.mode == MODE_SKIRMISH and self.INMHUD_SkirmishChangesActive) then
			local requestSkirmishRefresh = false
			for index, factionControl in pairs(self.factionScoreControls) do
				local text
				if (self.INMHUD_Skirmishes[index].state == ADVENTURE_ZONE_WORLD_EVENT_LOCATION_STATE_STARTS_SOON) then
					local remaining = (self.INMHUD_Skirmishes[index].time / ZO_ONE_SECOND_IN_MILLISECONDS) - GetTimeStamp()
					if (remaining < 0) then
						remaining = 0
						requestSkirmishRefresh = true
					end
					text = ZO_FormatTime(remaining, TIME_FORMAT_STYLE_SHOW_LARGEST_TWO_UNITS, TIME_FORMAT_PRECISION_SECONDS)
				else
					local strings = STATUS_LABELS[self.INMHUD_Skirmishes[index].state] or { }
					text = strings[LANG] or strings.default
				end
				factionControl.transitionManager:SetValueImmediately(text or "")
			end
			if (requestSkirmishRefresh) then
				self:INMHUD_RefreshSkirmishStatus(true)
			end
		end
	end

	SecurePostHook(ADVENTURE_ZONE_HUD_TRACKER, "OnShown", function( self )
		if (SV.mode == MODE_SKIRMISH) then
			self:INMHUD_RefreshInfo()
		end
	end)

	SecurePostHook(ADVENTURE_ZONE_HUD_TRACKER, "RefreshAnchors", function( self )
		self:INMHUD_RefreshFactionArrow()
	end)

	ADVENTURE_ZONE_HUD_TRACKER:INMHUD_Initialize()

	EVENT_MANAGER:RegisterForEvent(NAME, EVENT_PLAYER_ACTIVATED, function( )
		local LAM = LibAddonMenu2

		if (LAM) then
			local panelId = NAME

			local settingsPanel = LAM:RegisterAddonPanel(panelId, {
				type = "panel",
				name = TITLE,
				author = "@code65536",
			})

			local modes = { }
			local labels = { }
			for i = 1, 3 do
				table.insert(modes, i)
				table.insert(labels, MODE_LABELS[i][LANG] or MODE_LABELS[i].default)
			end

			LAM:RegisterOptionControls(panelId, {
				{
					type = "dropdown",
					name = SI_CHAT_CONFIG_OPTIONS,
					choices = labels,
					choicesValues = modes,
					getFunc = function() return SV.mode end,
					setFunc = function( mode )
						SV.mode = mode
						ImprovedNightMarketHUDSavedVariables = SV
						ADVENTURE_ZONE_HUD_TRACKER:INMHUD_Update()
					end,
				},
			})
		end
	end, true)
end)
