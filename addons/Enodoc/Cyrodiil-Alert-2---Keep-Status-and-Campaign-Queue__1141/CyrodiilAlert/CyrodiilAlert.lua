-- Cyrodiil Alert
-- Original Author: @Tanthul, Dark Moon Guild (Scourge EU)
-- Updated by: @Enodoc, UESP
--
-- Localization version 2.1
-- Japanese localization and string definitions by Lionas
-- German localization by Scootworks

CA = {}

CA.name = "CyrodiilAlert"
CA.version = "3.0.7"
CA.initialised = false
CA.language = "en"

-- Default settings.
CA.defaults = {
	notifOutput			= true,
	notifyDelay			= 5,
	chatOutput			= true,
	sound				= true,
	showInit			= true,
	showInitUIKeeps		= true,
	allianceColors		= true,
	
	showQueue			= true,
	queueReady			= "Major",
	queueAccept			= false,
	queueDelay			= 10,
	
	showAttack			= true,
	siegesAttDef		= true,
	siegesByAlliance	= true,
	showAttackEnd		= true,
	showOwnerChanged	= true,
	showFlags			= true,
	showFlagsNeutral	= true,
	onlyMyAlliance		= false,
	
	showEmperors		= true,
	showEmperorsOutside	= false,
	showGates			= true,
	showGatesOutside	= false,
	showScrolls			= true,
	showScrollsOutside	= false,
	showScore			= true,
	showUnderpop		= true,
	showClaim			= true,
	
	showKeeps			= true,
	showOutposts		= true,
	showResources		= true,
	showTowns			= true,	
	showDistricts		= true,
	
	showBridges			= true,
	
	showFlagsKeeps		= true,
	showFlagsOutposts	= true,
	showFlagsResources	= false,
	showFlagsDistricts	= false,
	showFlagsTowns		= true,
	
	showTelvar			= true,
	showResourceUpdates	= true,
	showDaedric			= true,
	
	keepCapture			= "Major",
	resourceCapture		= "Major",
	outpostCapture		= "Major",
	townCapture			= "Major",
	districtCapture		= "Major",
	
	keepAttack			= "Major",
	resourceAttack		= "Major",
	outpostAttack		= "Major",
	townAttack			= "Major",
	districtAttack		= "Major",
	
	bridgePassable		= "Major",
	bridgeAttack		= "Major",
	
	dumpAttack			= true,
}

function CA.Initialise(eventCode, addOnName)

	-- Initialize self only.
	if (CA.name ~= addOnName) then return end

	-- Load saved variables.
	CA.vars = ZO_SavedVars:NewAccountWide("CA_SavedVariables", 1, nil, CA.defaults)
	RegisterForAssignedCampaignData()

    -- Event registration.    
	EVENT_MANAGER:RegisterForEvent("CA", EVENT_KEEP_UNDER_ATTACK_CHANGED, CA.OnKeepUnderAttackChanged)
	EVENT_MANAGER:RegisterForEvent("CA", EVENT_KEEP_ALLIANCE_OWNER_CHANGED, CA.OnAllianceOwnerChanged)
	EVENT_MANAGER:RegisterForEvent("CA", EVENT_KEEP_GATE_STATE_CHANGED, CA.OnGateChanged)
	EVENT_MANAGER:RegisterForEvent("CA", EVENT_DEPOSE_EMPEROR_NOTIFICATION, CA.OnDeposeEmperor)
	EVENT_MANAGER:RegisterForEvent("CA", EVENT_CORONATE_EMPEROR_NOTIFICATION, CA.OnCoronateEmperor)
	EVENT_MANAGER:RegisterForEvent("CA", EVENT_ARTIFACT_CONTROL_STATE, CA.OnArtifactControlState)
	EVENT_MANAGER:RegisterForEvent("CA", EVENT_OBJECTIVE_CONTROL_STATE, CA.OnObjectiveControlState)
	EVENT_MANAGER:RegisterForEvent("CA", EVENT_GUILD_CLAIM_KEEP_CAMPAIGN_NOTIFICATION, CA.OnClaimKeep)
	EVENT_MANAGER:RegisterForEvent("CA", EVENT_CAMPAIGN_QUEUE_POSITION_CHANGED, CA.CampaignQueue)
	EVENT_MANAGER:RegisterForEvent("CA", EVENT_CAMPAIGN_QUEUE_STATE_CHANGED, CA.CampaignQueueState)
	EVENT_MANAGER:RegisterForEvent("CA", EVENT_ZONE_CHANGED, CA.OnNewZone)
	EVENT_MANAGER:RegisterForEvent("CA", EVENT_PLAYER_ACTIVATED, CA.OnUILoad)
	EVENT_MANAGER:RegisterForEvent("CA", EVENT_CAMPAIGN_UNDERPOP_BONUS_CHANGE_NOTIFICATION, CA.OnUnderpopChange)
	EVENT_MANAGER:RegisterForEvent("CA", EVENT_CAMPAIGN_SCORE_DATA_CHANGED, CA.OnScoreEvaluation)
	EVENT_MANAGER:RegisterForEvent("CA", EVENT_KEEP_IS_PASSABLE_CHANGED, CA.OnPassableChanged)
	EVENT_MANAGER:RegisterForEvent("CA", EVENT_KEEP_PIECE_DIRECTIONAL_ACCESS_CHANGED, CA.OnDirectionalAccessChanged)
	EVENT_MANAGER:RegisterForEvent("CA", EVENT_ACTIVE_DAEDRIC_ARTIFACT_CHANGED, CA.OnDaedricArtifactChanged)
	EVENT_MANAGER:RegisterForEvent("CA", EVENT_DAEDRIC_ARTIFACT_OBJECTIVE_STATE_CHANGED, CA.OnDaedricArtifactStateChanged)

	-- Empty variables
	CA.campaignId = nil
	CA.currentId = nil
	CA.campaignName = nil
	CA.myAlliance = nil
	CA.keepsReady = false
	CA.ICUnlocked = IsCollectibleUnlocked(GetImperialCityCollectibleId())

        -- Objective owner storage
        CA.objOwner = {}

	-- colour setup
	CA.colAld = GetAllianceColor(ALLIANCE_ALDMERI_DOMINION)
	CA.colDag = GetAllianceColor(ALLIANCE_DAGGERFALL_COVENANT)
	CA.colEbo = GetAllianceColor(ALLIANCE_EBONHEART_PACT)
	CA.colGrn = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_KEEP_TOOLTIP,KEEP_TOOLTIP_COLOR_ACCESSIBLE))
	CA.colRed = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_KEEP_TOOLTIP,KEEP_TOOLTIP_COLOR_NOT_ACCESSIBLE))
	CA.colWht = ZO_ColorDef:New(0.9,0.9,0.9,1)
	CA.colGry = ZO_ColorDef:New(0.525,0.525,0.525,1)
	CA.colOng = ZO_ColorDef:New(0.84,0.4,0.05,1)
	CA.colBlu = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_KEEP_TOOLTIP,KEEP_TOOLTIP_COLOR_OWNER))
	CA.colTel = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_CURRENCY,CURRENCY_COLOR_TELVAR_STONES))


    -- Configuration Menu setup.
    CA.CreateConfigMenu()
    CA.initialised = true   
--	d("CA Debug: Ran Through Init") 

	CA.language = GetString(SI_CYRODIIL_ALERT_LANG)
end


EVENT_MANAGER:RegisterForEvent("CA", EVENT_ADD_ON_LOADED, CA.Initialise)


function CA.OnNewZone(eventCode, unitTag, subZoneName, newSubzone)
--	d("CA Debug: New Zone")
	zo_callLater(CA.OnNewZoneCont,1000)
end

function CA.OnUILoad(eventCode)
--	d("CA Debug: UI Loaded, Player Activated")
	zo_callLater(CA.OnNewZoneCont,1000)
end

function CA.OnNewZoneCont()
	if (IsInCampaign()) then
		if (CA.currentId ~= GetCurrentCampaignId()) then
--			d("CA Debug: In AvA, New Zone, New Campaign ID")
			CA.currentId = GetCurrentCampaignId()
			CA.campaignId = GetCurrentCampaignId()
			CA.campaignName = GetCampaignName(CA.campaignId)
			CA.myAlliance = GetUnitAlliance("player")
			zo_callLater(CA.InitKeeps, 1000)
		elseif (CA.currentId == GetCurrentCampaignId()) then
--			d("CA Debug: In AvA, New Zone, Same Campaign ID")
		end
	elseif (not IsInCampaign()) then
		if (CA.currentId ~= GetCurrentCampaignId()) then
--			d("CA Debug: Not AvA, New Zone, New Campaign ID")
			CA.currentId = GetCurrentCampaignId()
			CA.campaignId = GetAssignedCampaignId()
			CA.campaignName = GetCampaignName(CA.campaignId)
			CA.myAlliance = GetUnitAlliance("player")
			zo_callLater(CA.InitKeeps, 1000)
		elseif (CA.currentId == GetCurrentCampaignId()) then
--			d("CA Debug: Not AvA, New Zone, Same Campaign ID")
		end
	end
end

function CA.InitKeeps()

	local initText = zo_strformat(CA.colOng:Colorize(GetString(SI_CYRODIIL_ALERT_INIT_TEXT)))
	local campWelcome = zo_strformat(GetString(SI_CYRODIIL_ALERT_CAMP_WELCOME), CA.colGrn:Colorize(CA.campaignName))
	local campHome = zo_strformat(GetString(SI_CYRODIIL_ALERT_CAMP_HOME), CA.colGrn:Colorize(CA.campaignName))
	local icEntryStatus
	local chatOn = zo_strformat(CA.colWht:Colorize(GetString(SI_CYRODIIL_ALERT_CHAT_OUTPUT_ON)))
	local chatOff = zo_strformat(CA.colGry:Colorize(GetString(SI_CYRODIIL_ALERT_CHAT_OUTPUT_OFF)))
	local notiOn = zo_strformat(CA.colWht:Colorize(GetString(SI_CYRODIIL_ALERT_NOTIFICATION_ON)))
	local notiOff = zo_strformat(CA.colWht:Colorize(GetString(SI_CYRODIIL_ALERT_NOTIFICATION_OFF)))

	if (IsInCampaign()) then
		if (CA.vars.showInit) then
			CA.ChatMessage(initText)
			CA.ChatMessage(campWelcome)
			CA.NotifyInitMessage(initText,CSA_CATEGORY_LARGE_TEXT,"Display_Announcement",campWelcome,icEntryStatus)
		end

		if (CA.vars.showInit) then
			if (CA.vars.showDistricts) and (IsInImperialCity()) then
				CA.dumpDistricts()
			end
			if not IsInImperialCity() then
				CA.vars.dumpAttack = true CA.dumpChat()
			end
		end
	end
	
	if ((IsInCampaign()) and (CA.vars.showInit)) then
		if (CA.vars.chatOutput) then
			CA.ChatMessage(chatOn)
		elseif (not CA.vars.chatOutput) then
			CA.ChatMessage(chatOff)
		end
		
		if (CA.vars.notifOutput) then
			CA.NotifyMessage(notiOn,CSA_CATEGORY_SMALL_TEXT,nil)
		else
			CA.NotifyMessage(notiOff,CSA_CATEGORY_SMALL_TEXT,nil)
		end
	end
	
	CA.ADscore = GetCampaignAllianceScore(CA.currentId, ALLIANCE_ALDMERI_DOMINION)
	CA.DCscore = GetCampaignAllianceScore(CA.currentId, ALLIANCE_DAGGERFALL_COVENANT)
	CA.EPscore = GetCampaignAllianceScore(CA.currentId, ALLIANCE_EBONHEART_PACT)

	CA.keepsReady = true
end

function CA.dumpChat()

	local bgContext
		if IsInCampaign() and not IsInImperialCity() then
			bgContext = BGQUERY_LOCAL
		else
			bgContext = BGQUERY_ASSIGNED_CAMPAIGN
			CA.ChatMessage(CA.colGry:Colorize(GetString(SI_CYRODIIL_ALERT_NOT_IN_CY)))
			do return end
		end

	local statusText = zo_strformat(CA.colGry:Colorize(GetString(SI_CYRODIIL_ALERT_STATUS_TEXT)))
	local uaText = zo_strformat(CA.colRed:Colorize(GetString(SI_CYRODIIL_ALERT_UNDER_ATTACK)))
	local uaText2
	local noAttacks = zo_strformat(CA.colWht:Colorize(GetString(SI_CYRODIIL_ALERT_NO_ATTACK)))

	local attTot = 0
	CA.ChatMessage(statusText)

	for i = 1,200 do
		local allianceCol
		local keepAlliance = GetKeepAlliance(i, bgContext)
		local keepType = GetKeepType(i)
		local keepName = GetKeepName(i)
		if (keepAlliance == ALLIANCE_ALDMERI_DOMINION) then
			allianceCol = CA.colAld
		elseif (keepAlliance == ALLIANCE_DAGGERFALL_COVENANT) then
			allianceCol = CA.colDag
		elseif (keepAlliance == ALLIANCE_EBONHEART_PACT) then
			allianceCol = CA.colEbo
		else
			allianceCol = CA.colOng
		end
		if ((keepType == KEEPTYPE_KEEP) or (keepType == KEEPTYPE_OUTPOST) or (keepType == KEEPTYPE_RESOURCE) or (keepType == KEEPTYPE_TOWN)) and (GetKeepAlliance(i, bgContext) ~= ALLIANCE_NONE) then
			uaText2 = zo_strformat(GetString(SI_CYRODIIL_ALERT_IS_UNDER_ATTACK), allianceCol:Colorize(keepName))
			if (GetKeepUnderAttack(i, bgContext)) then
				attTot = attTot + 1
				if CA.vars.dumpAttack then
					CA.ChatMessage(uaText2)
				else
					CA.ChatMessage(allianceCol:Colorize(keepName) .. " - " .. uaText)
				end
				local defendSiege = GetNumSieges(i, bgContext, keepAlliance)
				local allSiege = GetNumSieges(i, bgContext, ALLIANCE_ALDMERI_DOMINION)
				allSiege = allSiege + GetNumSieges(i, bgContext, ALLIANCE_DAGGERFALL_COVENANT)
				allSiege = allSiege + GetNumSieges(i, bgContext, ALLIANCE_EBONHEART_PACT)
				local adSiege = GetNumSieges(i, bgContext, ALLIANCE_ALDMERI_DOMINION)
				local dcSiege = GetNumSieges(i, bgContext, ALLIANCE_DAGGERFALL_COVENANT)
				local epSiege = GetNumSieges(i, bgContext, ALLIANCE_EBONHEART_PACT)
				local mySiege = GetNumSieges(i, bgContext, CA.myAlliance)
				local attackSiege = allSiege - defendSiege

				local siegesTextAll = CA.colWht:Colorize(GetString(SI_CYRODIIL_ALERT_SIEGES_A)) .. CA.colRed:Colorize(attackSiege) .. CA.colWht:Colorize(GetString(SI_CYRODIIL_ALERT_SLASH_D)) .. CA.colGrn:Colorize(defendSiege) .. CA.colWht:Colorize("  (") .. CA.colAld:Colorize(adSiege) .. CA.colWht:Colorize(", ") .. CA.colDag:Colorize(dcSiege) .. CA.colWht:Colorize(", ") .. CA.colEbo:Colorize(epSiege) .. CA.colWht:Colorize(")")
				local siegesTextAttDef = CA.colWht:Colorize(GetString(SI_CYRODIIL_ALERT_SIEGES_ATT)) .. CA.colRed:Colorize(attackSiege) .. CA.colWht:Colorize(GetString(SI_CYRODIIL_ALERT_SLASH_DEF)) .. CA.colGrn:Colorize(defendSiege)
				local siegesTextAlliance = CA.colWht:Colorize(GetString(SI_CYRODIIL_ALERT_SIEGES_AD)) .. CA.colAld:Colorize(adSiege) .. CA.colWht:Colorize(GetString(SI_CYRODIIL_ALERT_DC)) .. CA.colDag:Colorize(dcSiege) .. CA.colWht:Colorize(GetString(SI_CYRODIIL_ALERT_EP)) .. CA.colEbo:Colorize(epSiege) .. CA.colWht:Colorize(")")
				local siegesTextNone = CA.colWht:Colorize(GetString(SI_CYRODIIL_ALERT_SIEGES_NONE))

				if (allSiege ~= 0) and (keepType ~= KEEPTYPE_TOWN) then
					if (CA.vars.siegesAttDef) and (CA.vars.siegesByAlliance) then
						CA.ChatMessage(siegesTextAll)
						if (CA.vars.showInitUIKeeps) then
							CA.NotifyMessage(uaText2 .. siegesTextAll,CSA_CATEGORY_SMALL_TEXT,nil)
						end
					elseif (CA.vars.siegesAttDef) and (not CA.vars.siegesByAlliance) then
						CA.ChatMessage(siegesTextAttDef)
						if (CA.vars.showInitUIKeeps) then
							CA.NotifyMessage(uaText2 .. siegesTextAttDef,CSA_CATEGORY_SMALL_TEXT,nil)
						end
					elseif (not CA.vars.siegesAttDef) and (CA.vars.siegesByAlliance) then
						CA.ChatMessage(siegesTextAlliance)
						if (CA.vars.showInitUIKeeps) then
							CA.NotifyMessage(uaText2 .. siegesTextAttDef,CSA_CATEGORY_SMALL_TEXT,nil)
						end
					end
				elseif (allSiege == 0) and (keepType ~= KEEPTYPE_TOWN) and ((CA.vars.siegesAttDef) or (CA.vars.siegesByAlliance)) then
					CA.ChatMessage(siegesTextNone)
					if (CA.vars.showInitUIKeeps) then
						CA.NotifyMessage(uaText2 .. siegesTextNone,CSA_CATEGORY_SMALL_TEXT,nil)
					end
				elseif (keepType == KEEPTYPE_TOWN) then
					if (CA.vars.showInitUIKeeps) then
						CA.NotifyMessage(uaText2,CSA_CATEGORY_SMALL_TEXT,nil)
					end
				end
			elseif (not GetKeepUnderAttack(i, bgContext)) and (not CA.vars.dumpAttack) then
				CA.ChatMessage(allianceCol:Colorize(keepName))
			end
		end
	end		

	if (attTot == 0) then
		CA.ChatMessage(noAttacks)
		if (CA.vars.showInitUIKeeps) then
			CA.NotifyMessage(noAttacks,CSA_CATEGORY_SMALL_TEXT,nil)
		end
	end
end

function CA.dumpDistricts()
	if not IsInImperialCity() then
		CA.ChatMessage(CA.colGry:Colorize(GetString(SI_CYRODIIL_ALERT_NOT_IN_IC)))
		do return end
	end

	local bgContext
		if IsInCampaign() then
			bgContext = BGQUERY_LOCAL
		else
			bgContext = BGQUERY_ASSIGNED_CAMPAIGN
		end

	local attTot = 0
	local aldTot = 0
	local dagTot = 0
	local eboTot = 0
	local aldNum = 0
	local dagNum = 0
	local eboNum = 0
	local ADcol = CA.colGry
	local DCcol = CA.colGry
	local EPcol = CA.colGry
	local uaText = zo_strformat(CA.colRed:Colorize(GetString(SI_CYRODIIL_ALERT_UNDER_ATTACK)))
	local uaText2
	local noAttacks = zo_strformat(CA.colWht:Colorize(GetString(SI_CYRODIIL_ALERT_NO_DISTRICT_UNDER_ATTACK)))	
	if CA.myAlliance == ALLIANCE_ALDMERI_DOMINION then
		ADcol = CA.colGrn
	elseif CA.myAlliance == ALLIANCE_DAGGERFALL_COVENANT then
		DCcol = CA.colGrn
	elseif CA.myAlliance == ALLIANCE_EBONHEART_PACT then
		EPcol = CA.colGrn
	end
	if IsInImperialCity() then
		CA.ChatMessage(CA.colGry:Colorize(GetString(SI_CYRODIIL_ALERT_IMPERIAL_DISTRICTS)))
		for i = 1,200 do
			local allianceCol
			local keepAlliance = GetKeepAlliance(i, bgContext)
			local keepType = GetKeepType(i)
			local keepName = GetKeepName(i)
			if (keepType == KEEPTYPE_IMPERIAL_CITY_DISTRICT) and (GetKeepAlliance(i, bgContext) ~= ALLIANCE_NONE) then
				if (keepAlliance == ALLIANCE_ALDMERI_DOMINION) then
					allianceCol = CA.colAld
					aldTot = aldTot + GetDistrictOwnershipTelVarBonusPercent(i, bgContext)
					aldNum = aldNum + 1
				elseif (keepAlliance == ALLIANCE_DAGGERFALL_COVENANT) then
					allianceCol = CA.colDag
					dagTot = dagTot + GetDistrictOwnershipTelVarBonusPercent(i, bgContext)
					dagNum = dagNum + 1
				elseif (keepAlliance == ALLIANCE_EBONHEART_PACT) then
					allianceCol = CA.colEbo
					eboTot = eboTot + GetDistrictOwnershipTelVarBonusPercent(i, bgContext)
					eboNum = eboNum + 1
				else
					allianceCol = CA.colOng
				end
				uaText2 = zo_strformat(GetString(SI_CYRODIIL_ALERT_IS_UNDER_ATTACK), allianceCol:Colorize(keepName))
				if (GetKeepUnderAttack(i, bgContext)) then
					attTot = attTot + 1
					if CA.vars.dumpAttack then
						CA.ChatMessage(uaText2)
					else
						CA.ChatMessage(allianceCol:Colorize(keepName) .. " - " .. uaText)
					end
					if (CA.vars.showInitUIKeeps) then
						CA.NotifyMessage(uaText2,CSA_CATEGORY_SMALL_TEXT,nil)
					end
				elseif (not GetKeepUnderAttack(i, bgContext)) and (not CA.vars.dumpAttack) then
					CA.ChatMessage(allianceCol:Colorize(keepName))
				end
			end
		end
		if (attTot == 0) then
			CA.ChatMessage(noAttacks)
			if (CA.vars.showInitUIKeeps) then
				CA.NotifyMessage(noAttacks,CSA_CATEGORY_SMALL_TEXT,nil)
			end
		end
		local adDistricts = CA.colAld:Colorize(GetString(SI_CYRODIIL_ALERT_AD_NAME)) .. CA.colWht:Colorize(GetString(SI_CYRODIIL_ALERT_DISTRICTS)) .. CA.colOng:Colorize(aldNum) .. CA.colWht:Colorize(", ") .. CA.colTel:Colorize(GetString(SI_CYRODIIL_ALERT_TEL_VAR_BONUS)) .. CA.colWht:Colorize(": ") .. ADcol:Colorize("+"..aldTot.."%").. zo_strformat(" |t16:16:<<X:1>>|t", "EsoUI/Art/Currency/currency_telvar.dds")
		local dcDistricts = CA.colEbo:Colorize(GetString(SI_CYRODIIL_ALERT_EP_NAME)) .. CA.colWht:Colorize(GetString(SI_CYRODIIL_ALERT_DISTRICTS)) .. CA.colOng:Colorize(eboNum) .. CA.colWht:Colorize(", ") .. CA.colTel:Colorize(GetString(SI_CYRODIIL_ALERT_TEL_VAR_BONUS)) .. CA.colWht:Colorize(": ") .. EPcol:Colorize("+"..eboTot.."%").. zo_strformat(" |t16:16:<<X:1>>|t", "EsoUI/Art/Currency/currency_telvar.dds")
		local epDistricts = CA.colDag:Colorize(GetString(SI_CYRODIIL_ALERT_DC_NAME)) .. CA.colWht:Colorize(GetString(SI_CYRODIIL_ALERT_DISTRICTS)) .. CA.colOng:Colorize(dagNum) .. CA.colWht:Colorize(", ") .. CA.colTel:Colorize(GetString(SI_CYRODIIL_ALERT_TEL_VAR_BONUS)) .. CA.colWht:Colorize(": ") .. DCcol:Colorize("+"..dagTot.."%").. zo_strformat(" |t16:16:<<X:1>>|t", "EsoUI/Art/Currency/currency_telvar.dds")
		local adDistricts2 = CA.colAld:Colorize(GetString(SI_CYRODIIL_ALERT_AD_NAME)) .. CA.colWht:Colorize(GetString(SI_CYRODIIL_ALERT_DISTRICTS)) .. CA.colOng:Colorize(aldNum) .. CA.colWht:Colorize(", ") .. CA.colTel:Colorize(GetString(SI_CYRODIIL_ALERT_TEL_VAR_BONUS)) .. CA.colWht:Colorize(": ") .. ADcol:Colorize("+"..aldTot.."%").. zo_strformat(" |t30:30:<<X:1>>|t", "EsoUI/Art/Currency/currency_telvar_32.dds")
		local dcDistricts2 = CA.colEbo:Colorize(GetString(SI_CYRODIIL_ALERT_EP_NAME)) .. CA.colWht:Colorize(GetString(SI_CYRODIIL_ALERT_DISTRICTS)) .. CA.colOng:Colorize(eboNum) .. CA.colWht:Colorize(", ") .. CA.colTel:Colorize(GetString(SI_CYRODIIL_ALERT_TEL_VAR_BONUS)) .. CA.colWht:Colorize(": ") .. EPcol:Colorize("+"..eboTot.."%").. zo_strformat(" |t30:30:<<X:1>>|t", "EsoUI/Art/Currency/currency_telvar_32.dds")
		local epDistricts2 = CA.colDag:Colorize(GetString(SI_CYRODIIL_ALERT_DC_NAME)) .. CA.colWht:Colorize(GetString(SI_CYRODIIL_ALERT_DISTRICTS)) .. CA.colOng:Colorize(dagNum) .. CA.colWht:Colorize(", ") .. CA.colTel:Colorize(GetString(SI_CYRODIIL_ALERT_TEL_VAR_BONUS)) .. CA.colWht:Colorize(": ") .. DCcol:Colorize("+"..dagTot.."%").. zo_strformat(" |t30:30:<<X:1>>|t", "EsoUI/Art/Currency/currency_telvar_32.dds")
		CA.ChatMessage(adDistricts)
		CA.ChatMessage(dcDistricts)
		CA.ChatMessage(epDistricts)
		if (CA.vars.showInitUIKeeps) then
			CA.NotifyMessage(adDistricts2,CSA_CATEGORY_SMALL_TEXT,nil)
			CA.NotifyMessage(dcDistricts2,CSA_CATEGORY_SMALL_TEXT,nil)
			CA.NotifyMessage(epDistricts2,CSA_CATEGORY_SMALL_TEXT,nil)
		end
	end
end

function CA.CampaignQueueState(eventCode, campaignId, isGroup, state)
--	local states = {[0]="Pending Join","Waiting","Confirming","Finished","Pending Leave","Pending Accept"}
--	d("CA Debug: Queue State " .. state .. " - " .. states[state])

	local queueType

	if (CA.vars.queueReady == "Off") then
		do return end
	end

	local campaignName = GetCampaignName(campaignId)
	if (isGroup) then
		queueType = GetString(SI_CYRODIIL_ALERT_IS_GROUP)
	elseif (not isGroup) then
		queueType = GetString(SI_CYRODIIL_ALERT_IS_SOLO)
	else
	end

	if state == CAMPAIGN_QUEUE_REQUEST_STATE_CONFIRMING then
		local CSAcat
		if CA.vars.queueReady == "Major" then
			CSAcat = CSA_CATEGORY_LARGE_TEXT
		else
			CSAcat = CSA_CATEGORY_SMALL_TEXT
		end
		
		local queueReady = zo_strformat(GetString(SI_CYRODIIL_ALERT_QUEUE_READY), CA.colGrn:Colorize(campaignName), queueType)
		
		if (CA.vars.chatOutput) then
			CA.ChatMessage(queueReady)
		end
		if (CA.vars.notifOutput) then	
			CA.NotifyQueueMessage(queueReady,CSAcat,"ElderScroll_Captured_Aldmeri")
		end
		if (CA.vars.queueAccept) then
			zo_callLater(function() ConfirmCampaignEntry(campaignId,isGroup,true) end, CA.vars.queueDelay*1000)
		end
	end

end

function CA.CampaignQueue(eventCode, campaignId, isGroup, position)
--	d("CA Debug: Queue Position - " .. position)

	local queueType

	if (not CA.vars.showQueue) then
		do return end
	end

	local campaignName = GetCampaignName(campaignId)
	if (isGroup) then
		queueType = GetString(SI_CYRODIIL_ALERT_IS_GROUP)
	elseif (not isGroup) then
		queueType = GetString(SI_CYRODIIL_ALERT_IS_SOLO)
	else
	end

	local queueText = zo_strformat(GetString(SI_CYRODIIL_ALERT_QUEUE_POSITION), CA.colGrn:Colorize(campaignName), position, queueType)
	
	if (CA.vars.chatOutput) then
		CA.ChatMessage(queueText)
	end
	
	if (CA.vars.notifOutput) then
		CA.NotifyMessage(queueText,CSA_CATEGORY_SMALL_TEXT,"Quest_ObjectivesIncrement")
	end
end
	

function CA.OnAllianceOwnerChanged(eventCode, keepId, battlegroundContext, owningAlliance, oldAlliance)
--	d("CA Debug: Owner Changed, BGContext " .. battlegroundContext)
	if (not CA.keepsReady) then
		do return end
	end

	local keepType = GetKeepType(keepId)

	if  not IsInCampaign() then
		do return end
	end

	if ((IsInImperialCity()) and (keepType ~= KEEPTYPE_IMPERIAL_CITY_DISTRICT)) then
		do return end
	end
	
	if (CA.vars.showOwnerChanged == false) then
		do return end
	end

	if (CA.vars.showKeeps == false) and (keepType == KEEPTYPE_KEEP) then
		do return end
	end

	if (CA.vars.showResources == false) and (keepType == KEEPTYPE_RESOURCE) then
		do return end
	end

	if (CA.vars.showOutposts == false) and (keepType == KEEPTYPE_OUTPOST) then
		do return end
	end

	if (CA.vars.showTowns == false) and (keepType == KEEPTYPE_TOWN) then
		do return end
	end

	if ((CA.vars.showDistricts == false) or (not IsInImperialCity())) and (keepType == KEEPTYPE_IMPERIAL_CITY_DISTRICT) then
		do return end
	end

	local keepName = GetKeepName(keepId)
	local allianceName = GetAllianceName(owningAlliance)
	if ((owningAlliance == ALLIANCE_DAGGERFALL_COVENANT) and (CA.vars.allianceColors)) then
		allianceCol = CA.colDag
	elseif ((owningAlliance == ALLIANCE_ALDMERI_DOMINION) and (CA.vars.allianceColors)) then
		allianceCol = CA.colAld
	elseif ((owningAlliance == ALLIANCE_EBONHEART_PACT) and (CA.vars.allianceColors)) then
		allianceCol = CA.colEbo
	else
		allianceCol = CA.colOng
	end
	if ((oldAlliance == ALLIANCE_DAGGERFALL_COVENANT) and (CA.vars.allianceColors)) then
		oldCol = CA.colDag
	elseif ((oldAlliance == ALLIANCE_ALDMERI_DOMINION) and (CA.vars.allianceColors)) then
		oldCol = CA.colAld
	elseif ((oldAlliance == ALLIANCE_EBONHEART_PACT) and (CA.vars.allianceColors)) then
		oldCol = CA.colEbo
	else
		oldCol = CA.colOng
	end

	local TVbonus
	local ownTot
	local oldTot

	if keepType == KEEPTYPE_IMPERIAL_CITY_DISTRICT then
		TVbonus = GetDistrictOwnershipTelVarBonusPercent(keepId, battlegroundContext)
		ownTot = 0
		oldTot = 0
		for i = 1,200 do
			local keepType2 = GetKeepType(i)
			local keepAlliance2 = GetKeepAlliance(i, battlegroundContext)
			if (keepType2 == KEEPTYPE_IMPERIAL_CITY_DISTRICT) and (keepAlliance2 ~= ALLIANCE_NONE) then
--				d("CA Debug: District Ownership Tel Var is District")
				if (keepAlliance2 == owningAlliance) then
					ownTot = ownTot + GetDistrictOwnershipTelVarBonusPercent(i, battlegroundContext)
--					d("CA Debug: District Ownership Tel Var Total for New Owner: " .. ownTot)
				elseif (keepAlliance2 == oldAlliance) then
					oldTot = oldTot + GetDistrictOwnershipTelVarBonusPercent(i, battlegroundContext)
--					d("CA Debug: District Ownership Tel Var Total for Old Owner: " .. oldTot)
				end
			end
		end
	end

	if (CA.vars.onlyMyAlliance and (CA.myAlliance ~= owningAlliance and CA.myAlliance ~= oldAlliance)) then
		do return end
	end

	local captureText = zo_strformat(GetString(SI_CYRODIIL_ALERT_HAS_CAPTURED), oldCol:Colorize(keepName), allianceCol:Colorize(allianceName))

	local newTelvar
	local oldTelvar
	local newTelvar2
	local oldTelvar2
	if keepType == KEEPTYPE_IMPERIAL_CITY_DISTRICT then
		newTelvar = zo_strformat(GetString(SI_CYRODIIL_ALERT_IN_DISTRICTS_TOTAL), allianceCol:Colorize(allianceName), CA.colGrn:Colorize(" +"..TVbonus.."% "), "EsoUI/Art/Currency/currency_telvar.dds", CA.colTel:Colorize("+"..ownTot.."%"))
		oldTelvar = zo_strformat(GetString(SI_CYRODIIL_ALERT_IN_DISTRICTS_TOTAL), oldCol:Colorize(GetAllianceName(oldAlliance)), CA.colRed:Colorize(" -"..TVbonus.."% "), "EsoUI/Art/Currency/currency_telvar.dds", CA.colTel:Colorize("+"..oldTot.."%"))
		newTelvar2 = zo_strformat(GetString(SI_CYRODIIL_ALERT_IN_DISTRICTS_TOTAL2), allianceCol:Colorize(allianceName), CA.colGrn:Colorize(" +"..TVbonus.."% "), "EsoUI/Art/Currency/currency_telvar_32.dds", CA.colTel:Colorize("+"..ownTot.."%"))
		oldTelvar2 = zo_strformat(GetString(SI_CYRODIIL_ALERT_IN_DISTRICTS_TOTAL2), oldCol:Colorize(GetAllianceName(oldAlliance)), CA.colRed:Colorize(" -"..TVbonus.."% "), "EsoUI/Art/Currency/currency_telvar_32.dds", CA.colTel:Colorize("+"..oldTot.."%"))
	end

	if (CA.vars.chatOutput) then
		CA.ChatMessage(captureText)
		if (CA.vars.showTelvar) and keepType == KEEPTYPE_IMPERIAL_CITY_DISTRICT then
			CA.ChatMessage(newTelvar)
			CA.ChatMessage(oldTelvar)
		end
	end

	local CSAcat
	local CSAsnd
	if (CA.vars.keepCapture == "Major" and keepType == KEEPTYPE_KEEP) or (CA.vars.resourceCapture == "Major" and keepType == KEEPTYPE_RESOURCE) or (CA.vars.outpostCapture == "Major" and keepType == KEEPTYPE_OUTPOST) or (CA.vars.townCapture == "Major" and keepType == KEEPTYPE_TOWN) or (CA.vars.districtCapture == "Major" and keepType == KEEPTYPE_IMPERIAL_CITY_DISTRICT) then
		CSAcat = CSA_CATEGORY_LARGE_TEXT
		CSAsnd = "ElderScroll_Captured_Aldmeri"
	else
		CSAcat = CSA_CATEGORY_SMALL_TEXT
		CSAsnd = "AvA_Gate_Closed"
	end
	
	if (CA.vars.notifOutput) then
		CA.NotifyTakenMessage(captureText,CSAcat,CSAsnd)

		if (CA.vars.showTelvar) and keepType == KEEPTYPE_IMPERIAL_CITY_DISTRICT then
			CA.NotifyExtraMessage(newTelvar2 .. "\n" .. oldTelvar2,CSA_CATEGORY_SMALL_TEXT,"Telvar_MultiplierUp")
		end
	end

end

function CA.OnKeepUnderAttackChanged(eventCode, keepId, battlegroundContext, underAttack)
--	d("CA Debug: Attack Status Changed, BGContext " .. battlegroundContext)
	if (not CA.keepsReady) then
		do return end
	end

	local keepType = GetKeepType(keepId)

	local keepAlliance = GetKeepAlliance(keepId, battlegroundContext)

	if not IsInCampaign() then
		do return end
	end
	
	if ((IsInImperialCity()) and (keepType ~= KEEPTYPE_IMPERIAL_CITY_DISTRICT)) then
		do return end
	end

	if (CA.vars.showKeeps == false) and (keepType == KEEPTYPE_KEEP) then
		do return end
	end

	if (CA.vars.showResources == false) and (keepType == KEEPTYPE_RESOURCE) then
		do return end
	end

	if (CA.vars.showOutposts == false) and (keepType == KEEPTYPE_OUTPOST) then
		do return end
	end

	if (CA.vars.showTowns == false) and (keepType == KEEPTYPE_TOWN) then
		do return end
	end

	if ((CA.vars.showDistricts == false) or (not IsInImperialCity())) and (keepType == KEEPTYPE_IMPERIAL_CITY_DISTRICT) then
		do return end
	end
	
	if (CA.vars.showBridges == false) and ((keepType == KEEPTYPE_MILEGATE) or (keepType == KEEPTYPE_BRIDGE)) then
		do return end
	end


	local keepName = GetKeepName(keepId)

	
	local defendSiege = GetNumSieges(keepId, battlegroundContext, keepAlliance)
	local allSiege = GetNumSieges(keepId, battlegroundContext, ALLIANCE_ALDMERI_DOMINION)
	allSiege = allSiege + GetNumSieges(keepId, battlegroundContext, ALLIANCE_DAGGERFALL_COVENANT)
	allSiege = allSiege + GetNumSieges(keepId, battlegroundContext, ALLIANCE_EBONHEART_PACT)
	local adSiege = GetNumSieges(keepId, battlegroundContext, ALLIANCE_ALDMERI_DOMINION)
	local dcSiege = GetNumSieges(keepId, battlegroundContext, ALLIANCE_DAGGERFALL_COVENANT)
	local epSiege = GetNumSieges(keepId, battlegroundContext, ALLIANCE_EBONHEART_PACT)
	local mySiege = GetNumSieges(keepId, battlegroundContext, CA.myAlliance)
	local attackSiege = allSiege - defendSiege


	local allianceName = GetAllianceName(keepAlliance)
	if ((keepAlliance == ALLIANCE_DAGGERFALL_COVENANT) and (CA.vars.allianceColors)) then
		allianceCol = CA.colDag
	elseif ((keepAlliance == ALLIANCE_ALDMERI_DOMINION) and (CA.vars.allianceColors)) then
		allianceCol = CA.colAld
	elseif ((keepAlliance == ALLIANCE_EBONHEART_PACT) and (CA.vars.allianceColors)) then
		allianceCol = CA.colEbo
	else
		allianceCol = CA.colOng
	end

	if (CA.vars.onlyMyAlliance and (CA.myAlliance ~= keepAlliance and mySiege == 0)) then
		do return end
	end

	local uaText = zo_strformat(GetString(SI_CYRODIIL_ALERT_IS_UNDER_ATTACK), allianceCol:Colorize(keepName))
	local notuaText = zo_strformat(GetString(SI_CYRODIIL_ALERT_IS_NO_LONGER_UNDER_ATTACK),allianceCol:Colorize(keepName))
	local siegesTextAll = CA.colWht:Colorize(GetString(SI_CYRODIIL_ALERT_SIEGES_A)) .. CA.colRed:Colorize(attackSiege) .. CA.colWht:Colorize(GetString(SI_CYRODIIL_ALERT_SLASH_D)) .. CA.colGrn:Colorize(defendSiege) .. CA.colWht:Colorize("  (") .. CA.colAld:Colorize(adSiege) .. CA.colWht:Colorize(", ") .. CA.colDag:Colorize(dcSiege) .. CA.colWht:Colorize(", ") .. CA.colEbo:Colorize(epSiege) .. CA.colWht:Colorize(")")
	local siegesTextAttDef = CA.colWht:Colorize(GetString(SI_CYRODIIL_ALERT_SIEGES_ATT)) .. CA.colRed:Colorize(attackSiege) .. CA.colWht:Colorize(GetString(SI_CYRODIIL_ALERT_SLASH_DEF)) .. CA.colGrn:Colorize(defendSiege)
	local siegesTextAlliance = CA.colWht:Colorize(GetString(SI_CYRODIIL_ALERT_SIEGES_AD)) .. CA.colAld:Colorize(adSiege) .. CA.colWht:Colorize(GetString(SI_CYRODIIL_ALERT_DC)) .. CA.colDag:Colorize(dcSiege) .. CA.colWht:Colorize(GetString(SI_CYRODIIL_ALERT_EP)) .. CA.colEbo:Colorize(epSiege) .. CA.colWht:Colorize(")")
	local siegesTextNone = CA.colWht:Colorize(GetString(SI_CYRODIIL_ALERT_SIEGES_NONE))
	
	local CSAcat
	local CSAsnd
	if (CA.vars.keepAttack == "Major" and keepType == KEEPTYPE_KEEP) or (CA.vars.resourceAttack == "Major" and keepType == KEEPTYPE_RESOURCE) or (CA.vars.outpostAttack == "Major" and keepType == KEEPTYPE_OUTPOST) or (CA.vars.townAttack == "Major" and keepType == KEEPTYPE_TOWN) or (CA.vars.districtAttack == "Major" and keepType == KEEPTYPE_IMPERIAL_CITY_DISTRICT) or (CA.vars.bridgeAttack == "Major" and (keepType == KEEPTYPE_MILEGATE or keepType == KEEPTYPE_BRIDGE)) then
		CSAcat = CSA_CATEGORY_LARGE_TEXT
		CSAsnd = "Emperor_Coronated_Aldmeri"
	else
		CSAcat = CSA_CATEGORY_SMALL_TEXT
		CSAsnd = "AvA_Gate_Opened"
	end

	if (underAttack) and (CA.vars.showAttack) then
		if (CA.vars.chatOutput) then
		CA.ChatMessage(uaText)
			if (allSiege ~= 0) and (keepType ~= KEEPTYPE_IMPERIAL_CITY_DISTRICT and keepType ~= KEEPTYPE_TOWN and keepType ~= KEEPTYPE_MILEGATE and keepType ~= KEEPTYPE_BRIDGE) then
				if (CA.vars.siegesAttDef) and (CA.vars.siegesByAlliance) then
					CA.ChatMessage(siegesTextAll)
				elseif (CA.vars.siegesAttDef) and (not CA.vars.siegesByAlliance) then
					CA.ChatMessage(siegesTextAttDef)
				elseif (not CA.vars.siegesAttDef) and (CA.vars.siegesByAlliance) then
					CA.ChatMessage(siegesTextAlliance)
				end
			elseif (allSiege == 0) and (keepType ~= KEEPTYPE_IMPERIAL_CITY_DISTRICT and keepType ~= KEEPTYPE_TOWN and keepType ~= KEEPTYPE_MILEGATE and keepType ~= KEEPTYPE_BRIDGE) and ((CA.vars.siegesAttDef) or (CA.vars.siegesByAlliance)) then
				CA.ChatMessage(siegesTextNone)
			end
		end
		
		if (CA.vars.notifOutput) then
			if (not CA.vars.siegesAttDef) and (not CA.vars.siegesByAlliance) then
				CA.NotifyAttackMessage(uaText,"",CSAcat,CSAsnd)
			else
				if (allSiege ~= 0) and (keepType ~= KEEPTYPE_IMPERIAL_CITY_DISTRICT and keepType ~= KEEPTYPE_TOWN and keepType ~= KEEPTYPE_MILEGATE and keepType ~= KEEPTYPE_BRIDGE) then
					if (CA.vars.siegesAttDef) and (CA.vars.siegesByAlliance) then
						CA.NotifyAttackMessage(uaText,siegesTextAll,CSAcat,CSAsnd)
					elseif (CA.vars.siegesAttDef) and (not CA.vars.siegesByAlliance) then
						CA.NotifyAttackMessage(uaText,siegesTextAttDef,CSAcat,CSAsnd)
					elseif (not CA.vars.siegesAttDef) and (CA.vars.siegesByAlliance) then
						CA.NotifyAttackMessage(uaText,siegesTextAlliance,CSAcat,CSAsnd)
					else
						CA.NotifyAttackMessage(uaText,"",CSAcat,CSAsnd)
					end
				elseif (allSiege == 0) and (keepType ~= KEEPTYPE_IMPERIAL_CITY_DISTRICT and keepType ~= KEEPTYPE_TOWN and keepType ~= KEEPTYPE_MILEGATE and keepType ~= KEEPTYPE_BRIDGE) then
					if (CA.vars.siegesAttDef) or (CA.vars.siegesByAlliance) then
						CA.NotifyAttackMessage(uaText,siegesTextNone,CSAcat,CSAsnd)
					else
						CA.NotifyAttackMessage(uaText,"",CSAcat,CSAsnd)
					end
				else
						CA.NotifyAttackMessage(uaText,"",CSAcat,CSAsnd)
				end
			end
		end
	elseif (not underAttack) and (CA.vars.showAttackEnd) then
		if (CA.vars.chatOutput) then
			CA.ChatMessage(notuaText)
		end
		
		if (CA.vars.notifOutput) then
			CA.NotifyMessage(notuaText,CSA_CATEGORY_SMALL_TEXT,"AvA_Gate_Closed")
		end
	end
end



function CA.OnGateChanged(eventCode, keepId, open)
	local bgContext
	local campaignId
		if IsInCampaign() then
			bgContext = BGQUERY_LOCAL
			campaignId = GetCurrentCampaignId()
		else
			bgContext = BGQUERY_ASSIGNED_CAMPAIGN
			campaignId = GetAssignedCampaignId()
		end

	if (not CA.keepsReady) then
		do return end
	end

	if (not IsInCampaign()) and (not CA.vars.showGatesOutside) then
		do return end
	end
	
	if (IsInImperialCity()) and (not CA.vars.showGatesOutside) then
		do return end
	end
	
	local keepName = GetKeepName(keepId)
	local keepAlliance = GetKeepAlliance(keepId, bgContext)
	if ((keepAlliance == ALLIANCE_DAGGERFALL_COVENANT) and (CA.vars.allianceColors)) then
		allianceCol = CA.colDag
	elseif ((keepAlliance == ALLIANCE_ALDMERI_DOMINION) and (CA.vars.allianceColors)) then
		allianceCol = CA.colAld
	elseif ((keepAlliance == ALLIANCE_EBONHEART_PACT) and (CA.vars.allianceColors)) then
		allianceCol = CA.colEbo
	else
		allianceCol = CA.colOng
	end
	
	if (not CA.vars.showGates) then
		do return end
	end

	homeCamp = GetCampaignName(campaignId)

	local openText = zo_strformat(GetString(SI_CYRODIIL_ALERT_IS_OPEN), homeCamp, allianceCol:Colorize(keepName))
	local closedText = zo_strformat(GetString(SI_CYRODIIL_ALERT_IS_CLOSED), homeCamp, allianceCol:Colorize(keepName))

	if (open) then
		if (CA.vars.chatOutput) then
			CA.ChatMessage(openText)
		end
		
		if (CA.vars.notifOutput) then
			CA.NotifyExtraMessage(openText,CSA_CATEGORY_MAJOR_TEXT,"AvA_Gate_Opened")
		end
	else
		if (CA.vars.chatOutput) then
			CA.ChatMessage(closedText)
		end
		
		if (CA.vars.notifOutput) then
			CA.NotifyExtraMessage(closedText,CSA_CATEGORY_MAJOR_TEXT,"AvA_Gate_Closed")
		end
	end
end


function CA.OnDeposeEmperor(eventCode, campaignId, emperorName, emperorAlliance, abdication)
	if not IsInCampaign() and (not CA.vars.showEmperorsOutside) then
		do return end
	end
	
	if IsInImperialCity() and (not CA.vars.showEmperorsOutside) then
		do return end
	end
	
	if (not CA.vars.showEmperors) then
		do return end
	end

	local allianceName = GetAllianceName(emperorAlliance)
	if ((emperorAlliance == ALLIANCE_DAGGERFALL_COVENANT) and (CA.vars.allianceColors)) then
		allianceCol = CA.colDag
	elseif ((emperorAlliance == ALLIANCE_ALDMERI_DOMINION) and (CA.vars.allianceColors)) then
		allianceCol = CA.colAld
	elseif ((emperorAlliance == ALLIANCE_EBONHEART_PACT) and (CA.vars.allianceColors)) then
		allianceCol = CA.colEbo
	else
		allianceCol = CA.colOng
	end
	
	homeCamp = GetCampaignName(campaignId)

	local abdicateText = zo_strformat(GetString(SI_CYRODIIL_ALERT_ABDICATED), homeCamp, allianceCol:Colorize(allianceName), CA.colGrn:Colorize(emperorName));
	local deposeText = zo_strformat(GetString(SI_CYRODIIL_ALERT_DEPOSED), homeCamp, allianceCol:Colorize(allianceName), CA.colGrn:Colorize(emperorName));

	if (CA.vars.chatOutput) then
		if (abdication) then
			CA.ChatMessage(abdicateText)
		else
			CA.ChatMessage(deposeText)
		end
	end
	
	if (CA.vars.notifOutput) then
		if (abdication) then
			CA.NotifyExtraMessage(abdicateText,CSA_CATEGORY_MAJOR_TEXT,"Emperor_Abdicated")
		else
			CA.NotifyExtraMessage(deposeText,CSA_CATEGORY_MAJOR_TEXT,"Emperor_Abdicated")
		end
	end

end

function CA.OnCoronateEmperor(eventCode, campaignId, emperorName, emperorAlliance)
	if (not IsInCampaign()) and (not CA.vars.showEmperorsOutside) then
		do return end
	end
	
	if (IsInImperialCity()) and (not CA.vars.showEmperorsOutside) then
		do return end
	end
	
	if (not CA.vars.showEmperors) then
		do return end
	end

	local allianceName = GetAllianceName(emperorAlliance)
	if ((emperorAlliance == ALLIANCE_DAGGERFALL_COVENANT) and (CA.vars.allianceColors)) then
		allianceCol = CA.colDag
	elseif ((emperorAlliance == ALLIANCE_ALDMERI_DOMINION) and (CA.vars.allianceColors)) then
		allianceCol = CA.colAld
	elseif ((emperorAlliance == ALLIANCE_EBONHEART_PACT) and (CA.vars.allianceColors)) then
		allianceCol = CA.colEbo
	else
		allianceCol = CA.colOng
	end

	homeCamp = GetCampaignName(campaignId)

	local coronateText = zo_strformat(GetString(SI_CYRODIIL_ALERT_CROWNED_EMPEROR), homeCamp, allianceCol:Colorize(allianceName), CA.colGrn:Colorize(emperorName));

	if (CA.vars.chatOutput) then
		CA.ChatMessage(coronateText)
	end
	
	if (CA.vars.notifOutput) then
		CA.NotifyExtraMessage(coronateText,CSA_CATEGORY_MAJOR_TEXT,"Emperor_Coronated_Aldmeri")
	end

end

function CA.OnArtifactControlState(eventCode, artifactName, keepId, playerName, playerAlliance, controlEvent, controlState, campaignId)
--	d("CA Debug: Artifact Control State, " .. artifactName .. ", Keep ID:" .. keepId .. ", Player: " .. playerName .. " of " .. playerAlliance)
--	local ctrlEvent = {[0]="Under Attack","Lost","Captured","Recaptured","Assaulted","Fully Held","Area Neutral","Flag Taken","Flag Returned","Flag Dropped","Flag Returned by Timer","Area Influence Changed","None","Flag Spawned","Deactivated","Deactivate Pending","(16)"}
--	local ctrlState = {[0]="Flag at Base","Flag Dropped","Flag Held","Flag at Enemy Base","Area No Control","Area Below Control Threshold","Area Above Control Threshold","Area Max Control","Point Transitioning","Point Controlled","Unknown","Area Inactive"}
--	d("Control Event: " .. ctrlEvent[controlEvent])
--	d("Control State: " .. ctrlState[controlState])

	local bgContext
		if IsInCampaign() then
			bgContext = BGQUERY_LOCAL
		else
			bgContext = BGQUERY_ASSIGNED_CAMPAIGN
		end

	local keepType = GetKeepType(keepId)

	if (not IsInCampaign()) and (not CA.vars.showScrollsOutside) then
		do return end
	end
	
	if (IsInImperialCity()) and (not CA.vars.showScrollsOutside) then
		do return end
	end
	
	if (CA.vars.showScrolls == false) then
		do return end
	end

	local allianceName = GetAllianceName(playerAlliance)
	if ((playerAlliance == ALLIANCE_DAGGERFALL_COVENANT) and (CA.vars.allianceColors)) then
		allianceCol = CA.colDag
	elseif ((playerAlliance == ALLIANCE_ALDMERI_DOMINION) and (CA.vars.allianceColors)) then
		allianceCol = CA.colAld
	elseif ((playerAlliance == ALLIANCE_EBONHEART_PACT) and (CA.vars.allianceColors)) then
		allianceCol = CA.colEbo
	else
		allianceCol = CA.colOng
	end

	local keepName = GetKeepName(keepId)
	if keepId == 0 then
		keepName = "(N/A)"
	end
	local keepAlliance = GetKeepAlliance(keepId, bgContext)

	if ((keepAlliance == ALLIANCE_DAGGERFALL_COVENANT) and (CA.vars.allianceColors)) then
		keepCol = CA.colDag
	elseif ((keepAlliance == ALLIANCE_ALDMERI_DOMINION) and (CA.vars.allianceColors)) then
		keepCol = CA.colAld
	elseif ((keepAlliance == ALLIANCE_EBONHEART_PACT) and (CA.vars.allianceColors)) then
		keepCol = CA.colEbo
	else
		keepCol = CA.colOng
	end

	homeCamp = GetCampaignName(campaignId)

	local pickupText = zo_strformat(GetString(SI_CYRODIIL_ALERT_PICKED_UP), homeCamp, allianceCol:Colorize(allianceName), CA.colGrn:Colorize(playerName), CA.colOng:Colorize(artifactName))
	local takenText = zo_strformat(GetString(SI_CYRODIIL_ALERT_HAS_TAKEN), homeCamp, allianceCol:Colorize(allianceName), CA.colGrn:Colorize(playerName), keepCol:Colorize(keepName), CA.colOng:Colorize(artifactName))
	local droppedText = zo_strformat(GetString(SI_CYRODIIL_ALERT_HAS_DROPPED), homeCamp, allianceCol:Colorize(allianceName), CA.colGrn:Colorize(playerName), CA.colOng:Colorize(artifactName))
	local capturedText = zo_strformat(GetString(SI_CYRODIIL_ALERT_HAS_SECURED), homeCamp, allianceCol:Colorize(allianceName), CA.colGrn:Colorize(playerName), keepCol:Colorize(keepName), CA.colOng:Colorize(artifactName))
	local returnedText = zo_strformat(GetString(SI_CYRODIIL_ALERT_HAS_RETURNED), homeCamp, allianceCol:Colorize(allianceName), CA.colGrn:Colorize(playerName), CA.colOng:Colorize(artifactName), keepCol:Colorize(keepName))
	local timedoutText = zo_strformat(GetString(SI_CYRODIIL_ALERT_TIMEOUT), homeCamp, CA.colOng:Colorize(artifactName), keepCol:Colorize(keepName))
	
	if (controlEvent == OBJECTIVE_CONTROL_EVENT_FLAG_TAKEN) then	
		if (keepId == 0) then
			if (CA.vars.chatOutput) then
				CA.ChatMessage(pickupText)
			end
				
			if (CA.vars.notifOutput) then
				CA.NotifyExtraMessage(pickupText,CSA_CATEGORY_MAJOR_TEXT,"ElderScroll_Captured_Aldmeri")
			end
		else
			if (CA.vars.chatOutput) then
				CA.ChatMessage(takenText)
			end
				
			if (CA.vars.notifOutput) then
				CA.NotifyExtraMessage(takenText,CSA_CATEGORY_MAJOR_TEXT,"ElderScroll_Captured_Aldmeri")
			end
		end
			
	elseif (controlEvent == OBJECTIVE_CONTROL_EVENT_FLAG_DROPPED) then
		if (CA.vars.chatOutput) then
			CA.ChatMessage(droppedText)
		end
	
		if (CA.vars.notifOutput) then
			CA.NotifyExtraMessage(droppedText,CSA_CATEGORY_MAJOR_TEXT,"ElderScroll_Captured_Aldmeri")
		end

	elseif (controlEvent == OBJECTIVE_CONTROL_EVENT_CAPTURED) then
		if (CA.vars.chatOutput) then
			CA.ChatMessage(capturedText)
		end
	
		if (CA.vars.notifOutput) then
			CA.NotifyExtraMessage(capturedText,CSA_CATEGORY_MAJOR_TEXT,"ElderScroll_Captured_Aldmeri")
		end

	elseif (controlEvent == OBJECTIVE_CONTROL_EVENT_FLAG_RETURNED) then
		if (CA.vars.chatOutput) then
			CA.ChatMessage(returnedText)
		end
	
		if (CA.vars.notifOutput) then
			CA.NotifyExtraMessage(returnedText,CSA_CATEGORY_MAJOR_TEXT,"ElderScroll_Captured_Aldmeri")
		end

	elseif (controlEvent == OBJECTIVE_CONTROL_EVENT_FLAG_RETURNED_BY_TIMER) then
		if (CA.vars.chatOutput) then
			CA.ChatMessage(timedoutText)
		end
	
		if (CA.vars.notifOutput) then
			CA.NotifyExtraMessage(timedoutText,CSA_CATEGORY_MAJOR_TEXT,"ElderScroll_Captured_Aldmeri")
		end
	end
end

function CA.OnObjectiveControlState(eventCode, keepId, objectiveId, battlegroundContext, objectiveName, objectiveType, controlEvent, controlState, param1, param2)
--	d("CA Debug: Objective Control State, ID " .. objectiveId .. ": " .. objectiveName .. ", Param 1: " .. param1 .. ", Param 2: " .. param2)
--	local objType = {[0]="Default","Flag Capture","(2)","Capture Point","Capture Area","Assault","Return","Ball","Artifact Offensive","Artifact Defensive","Artifact Return","Daedric Artifact"}
--	local ctrlEvent = {[0]="Under Attack","Lost","Captured","Recaptured","Assaulted","Fully Held","Area Neutral","Flag Taken","Flag Returned","Flag Dropped","Flag Returned by Timer","Area Influence Changed","None","Flag Spawned","Deactivated","Deactivate Pending","(16)"}
--	local ctrlState = {[0]="Flag at Base","Flag Dropped","Flag Held","Flag at Enemy Base","Area No Control","Area Below Control Threshold","Area Above Control Threshold","Area Max Control","Point Transitioning","Point Controlled","Unknown","Area Inactive"}
--	d("Objective Type: " .. objType[objectiveType])
--	d("Control Event: " .. ctrlEvent[controlEvent])
--	d("Control State: " .. ctrlState[controlState])
	if (not CA.keepsReady) then
		do return end
	end

        if ((controlEvent == OBJECTIVE_CONTROL_EVENT_ASSAULTED) or (controlEvent == OBJECTIVE_CONTROL_EVENT_LOST)) then
            CA.objOwner[objectiveId] = param2
        end
        if (controlEvent == OBJECTIVE_CONTROL_EVENT_AREA_NEUTRAL) then
			param1 = CA.objOwner[objectiveId]
            CA.objOwner[objectiveId] = nil
        end

	local keepType = GetKeepType(keepId)

	if not IsInCampaign() then
		do return end
	end
	
	if (IsInImperialCity()) and (keepType ~= KEEPTYPE_IMPERIAL_CITY_DISTRICT) then
		do return end
	end

	if (CA.vars.showKeeps == false) and (keepType == KEEPTYPE_KEEP) then
		do return end
	end

	if (CA.vars.showResources == false) and (keepType == KEEPTYPE_RESOURCE) then
		do return end
	end

	if (CA.vars.showOutposts == false) and (keepType == KEEPTYPE_OUTPOST) then
		do return end
	end

	if (CA.vars.showTowns == false) and (keepType == KEEPTYPE_TOWN) then
		do return end
	end
	
	if ((CA.vars.showDistricts == false) or (not IsInImperialCity())) and (keepType == KEEPTYPE_IMPERIAL_CITY_DISTRICT) then
		do return end
	end

	if (CA.vars.showFlags == false) then
		do return end
	end

	if (CA.vars.showFlagsKeeps == false) and (keepType == KEEPTYPE_KEEP) then
--		d("CA Debug: Objective Control State, ID " .. objectiveId .. ": " .. objectiveName .. ", identified as Keep")
		do return end
	end
	if (CA.vars.showFlagsOutposts == false) and (keepType == KEEPTYPE_OUTPOST) then
--		d("CA Debug: Objective Control State, ID " .. objectiveId .. ": " .. objectiveName .. ", identified as Outpost")
		do return end
	end
	if (CA.vars.showFlagsResources == false) and (keepType == KEEPTYPE_RESOURCE) then
--		d("CA Debug: Objective Control State, ID " .. objectiveId .. ": " .. objectiveName .. ", identified as Resource")
		do return end
	end
	if (CA.vars.showFlagsTowns == false) and (keepType == KEEPTYPE_TOWN) then
--		d("CA Debug: Objective Control State, ID " .. objectiveId .. ": " .. objectiveName .. ", identified as Town")
		do return end
	end
	if (CA.vars.showFlagsDistricts == false) and (keepType == KEEPTYPE_IMPERIAL_CITY_DISTRICT) then
--		d("CA Debug: Objective Control State, ID " .. objectiveId .. ": " .. objectiveName .. ", identified as District")
		do return end
	end
	if (objectiveType == OBJECTIVE_DAEDRIC_WEAPON) then
--		d("CA Debug: Objective Control State, ID " .. objectiveId .. ": " .. objectiveName .. ", identified as Daedric Weapon")
		do return end
	end

	
	local keepName = GetKeepName(keepId)
	local keepAlliance = GetKeepAlliance(keepId, battlegroundContext)
	local allianceName = GetAllianceName(param1)
	local allianceName2 = GetAllianceName(param2)
	local keepOwner = GetAllianceName(keepAlliance)
	if (((param1 == ALLIANCE_DAGGERFALL_COVENANT) or (param2 == ALLIANCE_DAGGERFALL_COVENANT)) and (CA.vars.allianceColors)) then
		allianceCol = CA.colDag
	elseif (((param1 == ALLIANCE_ALDMERI_DOMINION) or (param2 == ALLIANCE_ALDMERI_DOMINION)) and (CA.vars.allianceColors)) then
		allianceCol = CA.colAld
	elseif (((param1 == ALLIANCE_EBONHEART_PACT) or (param2 == ALLIANCE_EBONHEART_PACT)) and (CA.vars.allianceColors)) then
		allianceCol = CA.colEbo
	else
		allianceCol = CA.colOng
		allianceName = GetString(SI_CYRODIIL_ALERT_UNKNOWN)
	end
	if ((keepAlliance == ALLIANCE_DAGGERFALL_COVENANT) and (CA.vars.allianceColors)) then
		keepCol = CA.colDag
	elseif ((keepAlliance == ALLIANCE_ALDMERI_DOMINION) and (CA.vars.allianceColors)) then
		keepCol = CA.colAld
	elseif ((keepAlliance == ALLIANCE_EBONHEART_PACT) and (CA.vars.allianceColors)) then
		keepCol = CA.colEbo
	else
		keepCol = CA.colOng
		keepOwner = GetString(SI_CYRODIIL_ALERT_UNKNOWN)
	end

	if (CA.vars.onlyMyAlliance and (CA.myAlliance ~= keepAlliance and CA.myAlliance ~= param1)) then
		do return end
	end

	local capturedText = zo_strformat(GetString(SI_CYRODIIL_ALERT_HAS_CAPTURED),CA.colOng:Colorize(objectiveName), allianceCol:Colorize(allianceName))
	local recapturedText = zo_strformat(GetString(SI_CYRODIIL_ALERT_HAS_RECAPTURED), allianceCol:Colorize(allianceName), CA.colOng:Colorize(objectiveName))
	local neutralText = zo_strformat(GetString(SI_CYRODIIL_ALERT_HAS_FALLEN),CA.colOng:Colorize(objectiveName),CA.colGrn:Colorize(GetString(SI_CYRODIIL_ALERT_NO_CONTROL)),allianceCol:Colorize(allianceName))

	if (CA.language == "jp") then
		capturedText = zo_strformat(GetString(SI_CYRODIIL_ALERT_HAS_CAPTURED2), allianceCol:Colorize(allianceName), CA.colOng:Colorize(objectiveName))
		neutralText = zo_strformat(GetString(SI_CYRODIIL_ALERT_NEUTRAL), CA.colOng:Colorize(objectiveName))
	end

	if (objectiveType == OBJECTIVE_CAPTURE_AREA) then

		if (controlEvent == OBJECTIVE_CONTROL_EVENT_CAPTURED) then
	
			if (CA.vars.chatOutput) then
				CA.ChatMessage(capturedText)
			end
			
			if (CA.vars.notifOutput) then
				CA.NotifyExtraMessage(capturedText,CSA_CATEGORY_SMALL_TEXT,"Quest_ObjectivesIncrement")
			end
	
		elseif (controlEvent == OBJECTIVE_CONTROL_EVENT_RECAPTURED) then
	
			if (CA.vars.chatOutput) then
				CA.ChatMessage(recapturedText)
			end
			
			if (CA.vars.notifOutput) then
				CA.NotifyExtraMessage(recapturedText,CSA_CATEGORY_SMALL_TEXT,"Quest_ObjectivesIncrement")
			end

		elseif (controlEvent == OBJECTIVE_CONTROL_EVENT_AREA_NEUTRAL and CA.vars.showFlagsNeutral == true) then
	
			if (CA.vars.chatOutput) then
				CA.ChatMessage(neutralText)
			end
			
			if (CA.vars.notifOutput) then
				CA.NotifyExtraMessage(neutralText,CSA_CATEGORY_SMALL_TEXT,"Quest_ObjectivesIncrement")
			end

		end
		
	end

end

function CA.OnClaimKeep(eventCode, campaignId, keepId, guildName, playerName)
	if (not CA.keepsReady) then
		do return end
	end

	local bgContext
		if IsInCampaign() then
			bgContext = BGQUERY_LOCAL
		else
			bgContext = BGQUERY_ASSIGNED_CAMPAIGN
		end

	local keepType = GetKeepType(keepId)

	if (not IsInCampaign()) then
		do return end
	end
	
	if (IsInImperialCity()) and (keepType ~= KEEPTYPE_IMPERIAL_CITY_DISTRICT) then
		do return end
	end
	
	if (not CA.vars.showClaim) then
		do return end
	end

	local keepName = GetKeepName(keepId)
	local keepAlliance = GetKeepAlliance(keepId, bgContext)
	local allianceName = GetAllianceName(keepAlliance)
	if ((keepAlliance == ALLIANCE_DAGGERFALL_COVENANT) and (CA.vars.allianceColors)) then
		allianceCol = CA.colDag
	elseif ((keepAlliance == ALLIANCE_ALDMERI_DOMINION) and (CA.vars.allianceColors)) then
		allianceCol = CA.colAld
	elseif ((keepAlliance == ALLIANCE_EBONHEART_PACT) and (CA.vars.allianceColors)) then
		allianceCol = CA.colEbo
	else
		allianceCol = CA.colOng
	end

	if (CA.vars.onlyMyAlliance and CA.myAlliance ~= keepAlliance) then
		do return end
	end
		
	homeCamp = GetCampaignName(campaignId)

	local claimText = zo_strformat(GetString(SI_CYRODIIL_ALERT_HAS_CLAIMED), homeCamp, CA.colGrn:Colorize(playerName), CA.colBlu:Colorize(guildName), allianceCol:Colorize(keepName))

	if (CA.vars.chatOutput) then
		CA.ChatMessage(claimText)
	end
	
	if (CA.vars.notifOutput) then
		CA.NotifyExtraMessage(claimText,CSA_CATEGORY_SMALL_TEXT,"Quest_Complete")
	end

end

function CA.OnUnderpopChange(eventCode, campaignId)
	if (not IsInCampaign()) then
		do return end
	end
	
	if (not CA.vars.showUnderpop) then
		do return end
	end

	local underpopAD = IsUnderpopBonusEnabled(campaignId,ALLIANCE_ALDMERI_DOMINION)
	local underpopDC = IsUnderpopBonusEnabled(campaignId,ALLIANCE_DAGGERFALL_COVENANT)
	local underpopEP = IsUnderpopBonusEnabled(campaignId,ALLIANCE_EBONHEART_PACT)

	local underpopText
	local underpopTitle = zo_strformat(CA.colWht:Colorize(GetString(SI_CYRODIIL_ALERT_UNDERPOP_TITLE)))
	if ((underpopAD) and (underpopDC) and (underpopEP)) then
		underpopText = zo_strformat(GetString(SI_CYRODIIL_ALERT_UNDERPOP_THREE),CA.colGrn:Colorize(GetString(SI_CYRODIIL_ALERT_UNDERPOP_ALL)))
	elseif ((underpopAD) and (underpopDC) and (not underpopEP)) then
		underpopText = zo_strformat(GetString(SI_CYRODIIL_ALERT_UNDERPOP_TWO),CA.colAld:Colorize(GetAllianceName(ALLIANCE_ALDMERI_DOMINION)),CA.colDag:Colorize(GetAllianceName(ALLIANCE_DAGGERFALL_COVENANT)))
	elseif ((underpopAD) and (not underpopDC) and (underpopEP)) then
		underpopText = zo_strformat(GetString(SI_CYRODIIL_ALERT_UNDERPOP_TWO),CA.colAld:Colorize(GetAllianceName(ALLIANCE_ALDMERI_DOMINION)),CA.colEbo:Colorize(GetAllianceName(ALLIANCE_EBONHEART_PACT)))
	elseif ((not underpopAD) and (underpopDC) and (underpopEP)) then
		underpopText = zo_strformat(GetString(SI_CYRODIIL_ALERT_UNDERPOP_TWO),CA.colDag:Colorize(GetAllianceName(ALLIANCE_DAGGERFALL_COVENANT)),CA.colEbo:Colorize(GetAllianceName(ALLIANCE_EBONHEART_PACT)))
	elseif ((underpopAD) and (not underpopDC) and (not underpopEP)) then
		underpopText = zo_strformat(GetString(SI_CYRODIIL_ALERT_UNDERPOP_ONE),CA.colAld:Colorize(GetAllianceName(ALLIANCE_ALDMERI_DOMINION)))
	elseif ((not underpopAD) and (underpopDC) and (not underpopEP)) then
		underpopText = zo_strformat(GetString(SI_CYRODIIL_ALERT_UNDERPOP_ONE),CA.colDag:Colorize(GetAllianceName(ALLIANCE_DAGGERFALL_COVENANT)))
	elseif ((not underpopAD) and (not underpopDC) and (underpopEP)) then
		underpopText = zo_strformat(GetString(SI_CYRODIIL_ALERT_UNDERPOP_ONE),CA.colEbo:Colorize(GetAllianceName(ALLIANCE_EBONHEART_PACT)))
	elseif ((not underpopAD) and (not underpopDC) and (not underpopEP)) then
		underpopText = zo_strformat(GetString(SI_CYRODIIL_ALERT_UNDERPOP_ONE),CA.colOng:Colorize(GetString(SI_CYRODIIL_ALERT_UNDERPOP_NONE)))
	end

	if (CA.vars.chatOutput) then
		CA.ChatMessage(underpopTitle)
		CA.ChatMessage(underpopText)
	end
	
	if (CA.vars.notifOutput) then
		CA.NotifyScoreMessage(underpopTitle,CSA_CATEGORY_LARGE_TEXT,"Display_Announcement",underpopText)
	end
end

function CA.OnScoreEvaluation(eventCode,manualCall)
	local bgContext
	local campaignId
		if IsInCampaign() then
			bgContext = BGQUERY_LOCAL
			campaignId = GetCurrentCampaignId()
		else
			bgContext = BGQUERY_ASSIGNED_CAMPAIGN
			campaignId = GetAssignedCampaignId()
		end

	if (not IsInCampaign()) then
		do return end
	end
	
	if (not CA.vars.showScore) then
		do return end
	end
	
	if ((GetCampaignAllianceScore(campaignId, ALLIANCE_ALDMERI_DOMINION) == CA.ADscore) and (GetCampaignAllianceScore(campaignId, ALLIANCE_DAGGERFALL_COVENANT) == CA.DCscore) and (GetCampaignAllianceScore(campaignId, ALLIANCE_EBONHEART_PACT) == CA.EPscore) and not manualCall) then
		do return end
	end

	CA.ADscore = GetCampaignAllianceScore(campaignId, ALLIANCE_ALDMERI_DOMINION)
	CA.DCscore = GetCampaignAllianceScore(campaignId, ALLIANCE_DAGGERFALL_COVENANT)
	CA.EPscore = GetCampaignAllianceScore(campaignId, ALLIANCE_EBONHEART_PACT)
	local ADscore = CA.ADscore
	local DCscore = CA.DCscore
	local EPscore = CA.EPscore
	local ADname = GetAllianceName(ALLIANCE_ALDMERI_DOMINION)
	local DCname = GetAllianceName(ALLIANCE_DAGGERFALL_COVENANT)
	local EPname = GetAllianceName(ALLIANCE_EBONHEART_PACT)
	local leaderScore
	local leaderName
	local leaderCol
	local loserScore
	local loserName
	local loserCol
	local runnerScore
	local runnerName
	local runnerCol
	if ((ADscore >= DCscore) and (ADscore >= EPscore)) then
		leaderScore = ADscore
		leaderName = ADname
		leaderCol = CA.colAld
		if (DCscore >= EPscore) then
			runnerScore = DCscore
			runnerName = DCname
			runnerCol = CA.colDag
			loserScore = EPscore
			loserName = EPname
			loserCol = CA.colEbo
		else
			runnerScore = EPscore
			runnerName = EPname
			runnerCol = CA.colEbo
			loserScore = DCscore
			loserName = DCname
			loserCol = CA.colDag
		end
	elseif ((DCscore >= ADscore) and (DCscore >= EPscore)) then
		leaderScore = DCscore
		leaderName = DCname
		leaderCol = CA.colDag
		if (ADscore >= EPscore) then
			runnerScore = ADscore
			runnerName = ADname
			runnerCol = CA.colAld
			loserScore = EPscore
			loserName = EPname
			loserCol = CA.colEbo
		else
			runnerScore = EPscore
			runnerName = EPname
			runnerCol = CA.colEbo
			loserScore = ADscore
			loserName = ADname
			loserCol = CA.colAld
		end
	elseif ((EPscore >= DCscore) and (EPscore >= ADscore)) then
		leaderScore = EPscore
		leaderName = EPname
		leaderCol = CA.colEbo
		if (DCscore >= ADscore) then
			runnerScore = DCscore
			runnerName = DCname
			runnerCol = CA.colDag
			loserScore = ADscore
			loserName = ADname
			loserCol = CA.colAld
		else
			runnerScore = ADscore
			runnerName = ADname
			runnerCol = CA.colAld
			loserScore = DCscore
			loserName = DCname
			loserCol = CA.colDag
		end
	end

	local scoreTitle = zo_strformat(GetString(SI_CYRODIIL_ALERT_SCORE_EVALUATION),CA.colGrn:Colorize(GetCampaignName(campaignId)))
	local scoreText = zo_strformat(GetString(SI_CYRODIIL_ALERT_SCORE_DETAILS),leaderCol:Colorize(leaderName),leaderScore,runnerCol:Colorize(runnerName),runnerScore,loserCol:Colorize(loserName),loserScore)

	if (CA.vars.chatOutput) then
		CA.ChatMessage(scoreTitle)
		CA.ChatMessage(scoreText)
	end
	
	if (CA.vars.notifOutput) then
		CA.NotifyScoreMessage(scoreTitle,CSA_CATEGORY_LARGE_TEXT,"Display_Announcement",scoreText)
	end	

end

function CA.OnDaedricArtifactChanged(eventCode, artifactId)
--	d("CA Debug: Active Daedric Artifact Changed, ID " .. artifactId)
end

function CA.OnDaedricArtifactStateChanged(eventCode, objectiveKeepId, objectiveObjectiveId, battlegroundContext, controlEvent, controlState, holderAlliance, lastHolderAlliance, holderRawCharacterName, holderDisplayName, lastHolderRawCharacterName, lastHolderDisplayName, pinType, artifactId)
--	d("CA Debug: Active Daedric Artifact Objective State Changed, ID " .. artifactId .. ", Keep ID: " .. objectiveKeepId .. ", Objective ID: " .. objectiveObjectiveId .. ", Alliance: " .. holderAlliance .. ", Last Alliance: " .. lastHolderAlliance)
--	d("Holder: " .. holderRawCharacterName .. "(" .. holderDisplayName .. "), Last Holder: " .. lastHolderRawCharacterName .. "(" .. lastHolderDisplayName .. ")")
--	local ctrlEvent = {[0]="Under Attack","Lost","Captured","Recaptured","Assaulted","Fully Held","Area Neutral","Flag Taken","Flag Returned","Flag Dropped","Flag Returned by Timer","Area Influence Changed","None","Flag Spawned","Deactivated","Deactivate Pending","(16)"}
--	local ctrlState = {[0]="Flag at Base","Flag Dropped","Flag Held","Flag at Enemy Base","Area No Control","Area Below Control Threshold","Area Above Control Threshold","Area Max Control","Point Transitioning","Point Controlled","Unknown","Area Inactive"}
--	d("Control Event: " .. ctrlEvent[controlEvent])
--	d("Control State: " .. ctrlState[controlState])
	if (not CA.keepsReady) then
		do return end
	end

	if not IsInCampaign() then
		do return end
	end

	if (CA.vars.showDaedric == false) then
		do return end
	end

	local objectiveName = GetObjectiveInfo(objectiveKeepId, objectiveObjectiveId, battlegroundContext)
	local allianceName
	if holderAlliance == 0 then
		allianceName = GetAllianceName(lastHolderAlliance)
	else
		allianceName = GetAllianceName(holderAlliance)
	end

	if (((holderAlliance == ALLIANCE_DAGGERFALL_COVENANT) or (lastHolderAlliance == ALLIANCE_DAGGERFALL_COVENANT)) and (CA.vars.allianceColors)) then
		allianceCol = CA.colDag
	elseif (((holderAlliance == ALLIANCE_ALDMERI_DOMINION) or (lastHolderAlliance == ALLIANCE_ALDMERI_DOMINION)) and (CA.vars.allianceColors)) then
		allianceCol = CA.colAld
	elseif (((holderAlliance == ALLIANCE_EBONHEART_PACT) or (lastHolderAlliance == ALLIANCE_EBONHEART_PACT)) and (CA.vars.allianceColors)) then
		allianceCol = CA.colEbo
	else
		allianceCol = CA.colOng
		allianceName = GetString(SI_CYRODIIL_ALERT_UNKNOWN)
	end

	if (CA.vars.onlyMyAlliance and (CA.myAlliance ~= keepAlliance and CA.myAlliance ~= holderAlliance and CA.myAlliance ~= lastHolderAlliance)) then
		do return end
	end

	local playerName
	if (holderRawCharacterName == "") then
		if (lastHolderRawCharacterName == "") then
			playerName = "[unknown]"
		else
			playerName = lastHolderRawCharacterName
		end
	else
		playerName = holderRawCharacterName
	end

	local daedricSpawnText = zo_strformat(GetString(SI_CYRODIIL_ALERT_DAEDRIC_SPAWNED),CA.colOng:Colorize(objectiveName))
	local daedricTakenText = zo_strformat(GetString(SI_CYRODIIL_ALERT_DAEDRIC_TAKEN),allianceCol:Colorize(allianceName),CA.colOng:Colorize(objectiveName),CA.colGrn:Colorize("Player" .. playerName))
	local daedricDroppedText = zo_strformat(GetString(SI_CYRODIIL_ALERT_DAEDRIC_DROPPED),allianceCol:Colorize(allianceName),CA.colOng:Colorize(objectiveName),CA.colGrn:Colorize("Player" .. playerName))
	local daedricDespawnText = zo_strformat(GetString(SI_CYRODIIL_ALERT_DAEDRIC_DESPAWNED),CA.colOng:Colorize(objectiveName))
	
	if (controlEvent == OBJECTIVE_CONTROL_EVENT_FLAG_SPAWNED) then
	
		if (CA.vars.chatOutput) then
			CA.ChatMessage(daedricSpawnText)
		end
		
		if (CA.vars.notifOutput) then
			CA.NotifyExtraMessage(daedricSpawnText,CSA_CATEGORY_SMALL_TEXT,"BG_CA_AreaCaptured_Spawned")
		end
		
	elseif (controlEvent == OBJECTIVE_CONTROL_EVENT_FLAG_TAKEN) then
	
		if (CA.vars.chatOutput) then
			CA.ChatMessage(daedricTakenText)
		end
		
		if (CA.vars.notifOutput) then
			CA.NotifyExtraMessage(daedricTakenText,CSA_CATEGORY_SMALL_TEXT,"BG_MB_BallTaken_OtherTeam")
		end

	elseif (controlEvent == OBJECTIVE_CONTROL_EVENT_FLAG_DROPPED) then

		if (CA.vars.chatOutput) then
			CA.ChatMessage(daedricDroppedText)
		end
			
		if (CA.vars.notifOutput) then
			CA.NotifyExtraMessage(daedricDroppedText,CSA_CATEGORY_SMALL_TEXT,"BG_MB_BallDropped_OtherTeam")
		end
			
	elseif (controlEvent == 16) then
			
		if (CA.vars.chatOutput) then
			CA.ChatMessage(daedricDespawnText)
		end
			
		if (CA.vars.notifOutput) then
			CA.NotifyExtraMessage(daedricDespawnText,CSA_CATEGORY_SMALL_TEXT,"BG_CA_AreaCaptured_Moved")
		end

	end

end

function CA.OnPassableChanged(eventCode, keepId, battlegroundContext, isPassable)
	if (not CA.keepsReady) then
		do return end
	end
	
	local keepType = GetKeepType(keepId)
	if keepType ~= KEEPTYPE_BRIDGE then
		do return end
	end

	if (not IsInCampaign()) then
		do return end
	end
	
	if (IsInImperialCity()) then
		do return end
	end

	if (CA.vars.showBridges == false) then
		do return end
	end
	
	local keepName = GetKeepName(keepId)
		allianceCol = CA.colOng

	local passableText = zo_strformat(GetString(SI_CYRODIIL_ALERT_IS_PASSABLE), allianceCol:Colorize(keepName))
	local passableText2 = zo_strformat(GetString(SI_CYRODIIL_ALERT_IS_PASSABLE_2), allianceCol:Colorize(keepName))
	local blockedText = zo_strformat(GetString(SI_CYRODIIL_ALERT_IS_BLOCKED),allianceCol:Colorize(keepName))
	
	if CA.vars.bridgePassable == "Major" then
		CSAcat = CSA_CATEGORY_LARGE_TEXT
		CSAsnd = "Emperor_Abdicated"
	else
		CSAcat = CSA_CATEGORY_SMALL_TEXT
		CSAsnd = "AvA_Gate_Closed"
	end

	if (isPassable) then
		if (CA.vars.chatOutput) then
			CA.ChatMessage(passableText)
		end
		
		if (CA.vars.notifOutput) then
			CA.NotifyScoreMessage(passableText,CSAcat,CSAsnd,passableText2)
		end
	elseif (not isPassable) then
		if (CA.vars.chatOutput) then
			CA.ChatMessage(blockedText)
		end
		
		if (CA.vars.notifOutput) then
			CA.NotifyScoreMessage(blockedText,CSAcat,CSAsnd,"")
		end
	end
end

function CA.OnDirectionalAccessChanged(eventCode, keepId, battlegroundContext, directionalAccess)
	if (not CA.keepsReady) then
		do return end
	end

	local keepType = GetKeepType(keepId)
	if keepType ~= KEEPTYPE_MILEGATE then
		do return end
	end

	if (not IsInCampaign()) then
		do return end
	end
	
	if (IsInImperialCity()) then
		do return end
	end

	if (CA.vars.showBridges == false) then
		do return end
	end
	
	local keepName = GetKeepName(keepId)
		allianceCol = CA.colOng

	local trueAccess = GetKeepDirectionalAccess(keepId, battlegroundContext)
	local gatePassable = IsKeepPassable(keepId, battlegroundContext)
	
--	d("CA Debug: Directional Access")
--	d("    Key: Bidirectional " .. KEEP_PIECE_DIRECTIONAL_ACCESS_BIDIRECTIONAL .. "; Blocked " .. KEEP_PIECE_DIRECTIONAL_ACCESS_BLOCKED .. "; Ignore " .. KEEP_PIECE_DIRECTIONAL_ACCESS_IGNORE .. "; Unidirectional " .. KEEP_PIECE_DIRECTIONAL_ACCESS_UNIDIRECTIONAL)
--	d("    " .. keepName .. ", Event Directional Access " .. directionalAccess)
--	d("    " .. keepName .. ", True Directional Access " .. trueAccess)
--	d("    " .. keepName .. ", Passable: " .. tostring(gatePassable))

	local ignoreText = zo_strformat(GetString(SI_CYRODIIL_ALERT_ACCESS_IGNORE), allianceCol:Colorize(keepName))
	local bidirectionalText = zo_strformat(GetString(SI_CYRODIIL_ALERT_ACCESS_BIDIRECTIONAL),allianceCol:Colorize(keepName))
	local unidirectionalTextA = zo_strformat(GetString(SI_CYRODIIL_ALERT_ACCESS_UNIDIRECTIONAL_A),allianceCol:Colorize(keepName))
	local unidirectionalTextB = zo_strformat(GetString(SI_CYRODIIL_ALERT_ACCESS_UNIDIRECTIONAL_B),allianceCol:Colorize(keepName))
	local blockedText = zo_strformat(GetString(SI_CYRODIIL_ALERT_ACCESS_BLOCKED), allianceCol:Colorize(keepName))
	local bidirectionalText2 = zo_strformat(GetString(SI_CYRODIIL_ALERT_ACCESS_BIDIRECTIONAL_2))
	local unidirectionalText2 = zo_strformat(GetString(SI_CYRODIIL_ALERT_ACCESS_UNIDIRECTIONAL_2))
	local blockedText2 = ""
	
	if CA.vars.bridgePassable == "Major" then
		CSAcat = CSA_CATEGORY_LARGE_TEXT
		CSAsnd = "Emperor_Abdicated"
	else
		CSAcat = CSA_CATEGORY_SMALL_TEXT
		CSAsnd = "AvA_Gate_Closed"
	end

	if (directionalAccess == KEEP_PIECE_DIRECTIONAL_ACCESS_BLOCKED) and (trueAccess == KEEP_PIECE_DIRECTIONAL_ACCESS_BLOCKED) then
		if (CA.vars.chatOutput) then
			CA.ChatMessage(blockedText)
		end
		
		if (CA.vars.notifOutput) then
			CA.NotifyScoreMessage(blockedText,CSAcat,CSAsnd,blockedText2)
		end
	elseif (directionalAccess == KEEP_PIECE_DIRECTIONAL_ACCESS_BLOCKED) and (trueAccess == KEEP_PIECE_DIRECTIONAL_ACCESS_UNIDIRECTIONAL) then
		if (CA.vars.chatOutput) then
			CA.ChatMessage(unidirectionalTextA)
		end
		
		if (CA.vars.notifOutput) then
			CA.NotifyScoreMessage(unidirectionalTextA,CSAcat,CSAsnd,unidirectionalText2)
		end
	elseif (directionalAccess == KEEP_PIECE_DIRECTIONAL_ACCESS_UNIDIRECTIONAL) and (trueAccess == KEEP_PIECE_DIRECTIONAL_ACCESS_UNIDIRECTIONAL) then
		if (CA.vars.chatOutput) then
			CA.ChatMessage(unidirectionalTextB)
		end
		
		if (CA.vars.notifOutput) then
			CA.NotifyScoreMessage(unidirectionalTextB,CSAcat,CSAsnd,unidirectionalText2)
		end
	elseif (directionalAccess == KEEP_PIECE_DIRECTIONAL_ACCESS_BIDIRECTIONAL) then
		if (CA.vars.chatOutput) then
			CA.ChatMessage(bidirectionalText)
		end
		
		if (CA.vars.notifOutput) then
			CA.NotifyScoreMessage(bidirectionalText,CSAcat,CSAsnd,bidirectionalText2)
		end
	end
end


function CA.ChatMessage(message)
--	local sysR,sysG,sysB = GetChatCategoryColor(CHAT_CATEGORY_SYSTEM)
--	local chatColSys = ZO_ColorDef:New(sysR,sysG,sysB,1)
--	SetChatCategoryColor(CHAT_CATEGORY_SYSTEM, CA.colWht:UnpackRGB() )
	d(message)
--	SetChatCategoryColor(CHAT_CATEGORY_SYSTEM, chatColSys:UnpackRGB() )
end

function CA.NotifyMessage(message,category,sound)
	if not CA.vars.sound then sound = nil end
	local params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(category, sound)
	params:SetText(message)
	params:SetLifespanMS(CA.vars.notifyDelay*1000)
	params:SetPriority(0)
	CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(params)
end
function CA.NotifyTakenMessage(message,category,sound)
	if not CA.vars.sound then sound = nil end
	local params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(category, sound)
	params:SetText(message)
	params:SetLifespanMS(CA.vars.notifyDelay*1000)
	params:SetPriority(0)
	CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(params)
end
function CA.NotifyExtraMessage(message,category,sound)
	if not CA.vars.sound then sound = nil end
	local params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(category, sound)
	params:SetText(message)
	params:SetLifespanMS(CA.vars.notifyDelay*1000)
	params:SetPriority(0)
	CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(params)
end
function CA.NotifyQueueMessage(message,category,sound)
	if not CA.vars.sound then sound = nil end
	local params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, "Emperor_Coronated_Aldmeri")
	local params2 = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_MAJOR_TEXT, "AvA_Gate_Opened")
	local counter = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_COUNTDOWN_TEXT, "BG_Countdown_Finish")
	counter:SetIconData("esoui/art/campaign/gamepad/gp_campaign_menuicon_travel.dds")
	params:SetText(message)
	params2:SetText(zo_strformat(GetString(SI_CYRODIIL_ALERT_AUTO_QUEUE)))
	counter:SetLifespanMS(CA.vars.queueDelay*1000 - 3000 - CA.vars.notifyDelay*1000)
	params:SetLifespanMS(CA.vars.notifyDelay*1000)
	params2:SetLifespanMS(4000)
	counter:SetPriority(1)
	params:SetPriority(2)
	CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(params)
	if (CA.vars.queueAccept) then
		zo_callLater(function() CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(counter) end, CA.vars.notifyDelay*1000 + 3000)
		zo_callLater(function() CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(params2) end, CA.vars.notifyDelay*1000 - 2000)
	end
end
function CA.NotifyAttackMessage(message,siegmsg,category,sound)
	if not CA.vars.sound then sound = nil end
	if category == CSA_CATEGORY_LARGE_TEXT then
		local params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(category, sound)
		params:SetText(message, siegmsg)
		params:SetLifespanMS(CA.vars.notifyDelay*1000)
		params:SetPriority(1)
		CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(params)
	elseif category == CSA_CATEGORY_SMALL_TEXT then
		local params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(category, sound)
		params:SetText(message .. siegmsg)
		params:SetLifespanMS(CA.vars.notifyDelay*1000)
		params:SetPriority(1)
		CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(params)
	end
end
function CA.NotifyInitMessage(message,category,sound,msg2,msg3)
	if not CA.vars.sound then sound = nil end
	local params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_MAJOR_TEXT, "Duel_Boundary_Warning")
	params:SetText(LocaleAwareToUpper(message))
	params:SetLifespanMS(CA.vars.notifyDelay*1000)
	params:SetPriority(0)
	CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(params)
	local params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_MAJOR_TEXT, "Duel_InviteReceived")
	params:SetText(LocaleAwareToUpper(msg2))
	params:SetLifespanMS(CA.vars.notifyDelay*1000)
	params:SetPriority(0)
	zo_callLater(function() CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(params) end, CA.vars.notifyDelay*1000 + 2000)
	local params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT, "Justice_NowKOS")
	params:SetText(msg3)
	params:SetLifespanMS(CA.vars.notifyDelay*1000)
	params:SetPriority(0)
	CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(params2)
end
function CA.NotifyScoreMessage(message,category,sound,msg2)
	if not CA.vars.sound then sound = nil end
	local params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, sound)
	params:SetText(message, msg2)
	params:SetLifespanMS(CA.vars.notifyDelay*1000)
	params:SetPriority(0)
	CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(params)
end

-- SLASH COMMAND FUNCTIONALITY
function CAslash(text )
	if (text == "status") then
		CA.vars.dumpAttack = false return CA.dumpChat()
	end
	if (text == "attacks") then
		CA.vars.dumpAttack = true return CA.dumpChat()
	end
	if ((text == "imperial") or (text == "ic")) then
		CA.vars.dumpAttack = true CA.dumpDistricts()
	end
	if (text == "score") then
		return CA.OnScoreEvaluation(_,true)
	end
	if (text == "underpop") then
		return CA.OnUnderpopChange()
	end
	if (text == "init") then
		if (IsInCampaign()) then
			if (CA.currentId ~= GetCurrentCampaignId()) then
--				d("CA Debug: In AvA, Slash Init, New Campaign ID")
				CA.currentId = GetCurrentCampaignId()
				CA.campaignId = GetCurrentCampaignId()
				CA.campaignName = GetCampaignName(CA.campaignId)
				CA.myAlliance = GetUnitAlliance("player")
			elseif (CA.currentId == GetCurrentCampaignId()) then
--				d("CA Debug: In AvA, Slash Init, Same Campaign ID")
			end
		elseif (not IsInCampaign()) then
			if (CA.currentId ~= GetCurrentCampaignId()) then
--				d("CA Debug: Not AvA, Slash Init, New Campaign ID")
				CA.currentId = GetCurrentCampaignId()
				CA.campaignId = GetAssignedCampaignId()
				CA.campaignName = GetCampaignName(CA.campaignId)
				CA.myAlliance = GetUnitAlliance("player")
			elseif (CA.currentId == GetCurrentCampaignId()) then
--				d("CA Debug: Not AvA, Slash Init, Same Campaign ID")
			end
		end
		return CA.InitKeeps()
	end
	if (text == "help") then
		d(GetString(SI_CYRODIIL_ALERT_HELP))
	end
end -- CAslash
 
SLASH_COMMANDS["/ca"] = CAslash