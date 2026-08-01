-- Create namespace
DsRGuildPvP = {}
local DsRGuildPvP = DsRGuildPvP  or {}

DsRGuildPvP.name = "DsRGuildPvP"

local DsRlogger = ZO_Object:Subclass()
function DsRlogger:Info(...)end

DsRGuildPvP.queuedCampaignID = nil
DsRGuildPvP.queueState 		 = nil
DsRGuildPvP.queuePosition 	 = nil

local dsrPeriodic    = ZO_CallbackObject:Subclass()
DsRGuildPvP_Periodic = dsrPeriodic

DsRGuildPvP.queuePeriodic = DsRGuildPvP_Periodic:New()

DsRPlayerDBData_SV.playerDB = DsRPlayerDBData_SV.playerDB or {}
DsRPlayerDBData_SV          = DsRPlayerDBData_SV or nil

-------------------------------------------------------------------------------------------------------------------------------------------------
-- AP update
-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvP.OnAPUpdated(eventCode, alliancePoints, playSound, difference, reason, locationId)
	if reason == CURRENCY_CHANGE_REASON_PLAYER_INIT then return end
	
	local maxLevel = GetMaxLevel()
	local currentAvARank
	local rankProgAvA, rankMaxAvA
	local levelProgress
	local rankIcon

	local params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT)

	currentAvARank = GetUnitAvARank("player")
	local function GetCurrentRankProgress()
		local rankPoints = GetUnitAvARankPoints("player")
		local _, _, rankStartsAt, nextRankAt = GetAvARankProgress(rankPoints)
		if rankPoints >= nextRankAt then
			local lastRankPoints = GetNumPointsNeededForAvARank(currentAvARank - 1)
			local maxRankPoints = GetNumPointsNeededForAvARank(currentAvARank)
			local fullRankPoints = maxRankPoints - lastRankPoints

			return fullRankPoints, fullRankPoints
		else
			return rankPoints - rankStartsAt, nextRankAt - rankStartsAt
		end
	end
	rankProgAvA, rankMaxAvA = GetCurrentRankProgress()

	local APicon   = zo_iconTextFormat("/esoui/art/currency/alliancepoints_64.dds", 18, 18, " ")
	local DsRicon  = zo_iconTextFormat("/DsRGuildHall/misc/DsR_AP.dds", 20, 20, " ")
	local DsRiconS = zo_iconTextFormat("/DsRGuildHall/misc/DsR_AP.dds", 30, 30, " ")

	rankIcon = GetAvARankIcon(GetUnitAvARank("player"))
	local lgIconText = zo_iconTextFormat(rankIcon, 18, 18, " ")

	local levelProgress = tostring(math.floor(100*(rankProgAvA/rankMaxAvA))).."%"
	local actualRP      = GetUnitAvARankPoints("player")

	if tonumber(difference) >= 0 then
		DsRGuildPvP.pvp.sessionStats.alliancePoints = DsRGuildPvP.pvp.sessionStats.alliancePoints + tonumber( difference )
		local ProgressPoint = tostring(math.floor(100*(rankProgAvA/rankMaxAvA)))
		DsRGuildPvPscore.ScoreWindow_Update(ProgressPoint)
	end

	if not DsRGuildPvP.pvp.PvPAP then return end
	if tonumber(difference) < tonumber(DsRGuildPvP.pvp.PvPAPvalue) then return end

	local WHITEcolor      = "|cFFFFFF"
	local GREYcolor	      = "|c808080"
	local GREENcolor	  = "|c35fc38"
	local darkGREENcolor  = "|c095e0a"

	if not IsBankOpen() then
		if reason ~= CURRENCY_CHANGE_REASON_BANK_WITHDRAWAL and reason ~= CURRENCY_CHANGE_REASON_VENDOR then
			local LocationORI = zo_strformat("<<1>>", GetKeepName(locationId))
			local Location    = LocationORI:gsub("der ", ""):gsub("die ", ""):gsub("das ", "")

			if reason == CURRENCY_CHANGE_REASON_KEEP_REPAIR and DsRGuildPvP.pvp.PvPAPrep == true then -- 40
				d(DsRicon .. GREENcolor .. GetString(DsRGuildPvP_ap_repairtxt) .. APicon .. WHITEcolor .. "+" .. ZO_CommaDelimitNumber( difference ):gsub("%,","%.") .. GREENcolor .. " AP "  .. darkGREENcolor .. "[" .. Location .. "]    " .. lgIconText .. WHITEcolor .. currentAvARank .. GREYcolor .. " -> " .. ZO_CommaDelimitNumber( rankProgAvA ):gsub("%,","%.") .. "/" .. ZO_CommaDelimitNumber( rankMaxAvA ):gsub("%,","%.") .. " ( " .. levelProgress .. " ) ")
				return
			elseif reason == CURRENCY_CHANGE_REASON_KILL and DsRGuildPvP.pvp.PvPAPdeath == true then -- 13
				d(DsRicon .. GREENcolor .. GetString(DsRGuildPvP_ap_killstxt) .. APicon .. WHITEcolor .. "+" .. ZO_CommaDelimitNumber( difference ):gsub("%,","%.") .. GREENcolor .. " AP " .. lgIconText .. WHITEcolor .. currentAvARank .. GREYcolor .. " -> " .. ZO_CommaDelimitNumber( rankProgAvA ):gsub("%,","%.") .. "/" .. ZO_CommaDelimitNumber( rankMaxAvA ):gsub("%,","%.") .. " ( " .. levelProgress .. " ) ")
				return
			elseif reason == CURRENCY_CHANGE_REASON_OFFENSIVE_KEEP_REWARD then -- 74	
				if DsRGuildPvP.pvp.PvPAPoffenschat == true then
					d(DsRicon .. GREENcolor .. GetString(DsRGuildPvP_ap_offensetxt) .. APicon .. WHITEcolor .. "+" .. ZO_CommaDelimitNumber( difference ):gsub("%,","%.") .. GREENcolor .. " AP "  .. darkGREENcolor .. "[" .. Location .. "]    " .. lgIconText .. WHITEcolor .. currentAvARank .. GREYcolor .. " -> " ..  ZO_CommaDelimitNumber( rankProgAvA ):gsub("%,","%.") .. "/" .. ZO_CommaDelimitNumber( rankMaxAvA ):gsub("%,","%.") .. " ( " .. levelProgress .. " ) ")
				end
				if DsRGuildPvP.pvp.PvPAPoffensscreen == true then
					params:SetText(DsRiconS .. GREENcolor .. GetString(DsRGuildPvP_ap_offensetxt) .. APicon .. WHITEcolor .. "+" .. ZO_CommaDelimitNumber( difference ):gsub("%,","%.") .. GREENcolor .. " AP "  .. darkGREENcolor .. "[" .. Location .. "]")
					CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(params)
				end
				return
			elseif reason == CURRENCY_CHANGE_REASON_DEFENSIVE_KEEP_REWARD then -- 75
				if DsRGuildPvP.pvp.PvPAPdeffenschat == true then
					d(DsRicon .. GREENcolor .. GetString(DsRGuildPvP_ap_defensetxt) .. APicon .. WHITEcolor .. "+" .. ZO_CommaDelimitNumber( difference ):gsub("%,","%.") .. GREENcolor .. " AP "  .. darkGREENcolor .. "[" .. Location .. "]    " .. lgIconText .. WHITEcolor .. currentAvARank .. GREYcolor .. " -> " ..  ZO_CommaDelimitNumber( rankProgAvA ):gsub("%,","%.") .. "/" .. ZO_CommaDelimitNumber( rankMaxAvA ):gsub("%,","%.") .. " ( " .. levelProgress .. " ) ")
				end
				if DsRGuildPvP.pvp.PvPAPdeffensscreen == true then
					params:SetText(DsRiconS .. GREENcolor .. GetString(DsRGuildPvP_ap_defensetxt) .. APicon .. WHITEcolor .. "+" .. ZO_CommaDelimitNumber( difference ):gsub("%,","%.") .. GREENcolor .. " AP "  .. darkGREENcolor .. "[" .. Location .. "]")
					CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(params)
				end
				return
			elseif reason == CURRENCY_CHANGE_REASON_PVP_RESURRECT and DsRGuildPvP.pvp.PvPAPressurect == true then -- 41
				d(DsRicon .. GREENcolor .. GetString(DsRGuildPvP_ap_revivaltxt) .. APicon .. WHITEcolor .. "+" .. ZO_CommaDelimitNumber( difference ):gsub("%,","%.") .. GREENcolor .. " AP " .. lgIconText .. WHITEcolor .. currentAvARank .. GREYcolor .. " -> " .. ZO_CommaDelimitNumber( rankProgAvA ):gsub("%,","%.") .. "/" .. ZO_CommaDelimitNumber( rankMaxAvA ):gsub("%,","%.") .. " ( " .. levelProgress .. " ) ")
				return
			elseif reason == CURRENCY_CHANGE_REASON_MEDAL and DsRGuildPvP.pvp.PvPAPmedal == true then -- 21
				d(DsRicon .. GREENcolor .. GetString(DsRGuildPvP_ap_awardstxt) .. APicon .. WHITEcolor .. "+" .. ZO_CommaDelimitNumber( difference ):gsub("%,","%.") .. GREENcolor .. " AP " .. lgIconText .. WHITEcolor .. currentAvARank .. GREYcolor .. " -> " .. ZO_CommaDelimitNumber( rankProgAvA ):gsub("%,","%.") .. "/" .. ZO_CommaDelimitNumber( rankMaxAvA ):gsub("%,","%.") .. " ( " .. levelProgress .. " ) ")
				return
			elseif reason == CURRENCY_CHANGE_REASON_BATTLEGROUND and DsRGuildPvP.pvp.PvPAPmatch == true then -- 12
				d(DsRicon .. GREENcolor .. GetString(DsRGuildPvP_ap_battlegroundtxt) .. APicon .. WHITEcolor .. "+" .. ZO_CommaDelimitNumber( difference ):gsub("%,","%.") .. GREENcolor .. " AP " .. lgIconText .. WHITEcolor .. currentAvARank .. GREYcolor .. " -> " .. ZO_CommaDelimitNumber( rankProgAvA ):gsub("%,","%.") .. "/" .. ZO_CommaDelimitNumber( rankMaxAvA ):gsub("%,","%.") .. " ( " .. levelProgress .. " ) ")
				return
			elseif ( reason == CURRENCY_CHANGE_REASON_TRADE or reason == CURRENCY_CHANGE_REASON_QUESTREWARD ) and DsRGuildPvP.pvp.PvPAPquest == true then -- 3 / 4
				d(DsRicon .. GREENcolor .. GetString(DsRGuildPvP_ap_questtxt) .. APicon .. WHITEcolor .. "+" .. ZO_CommaDelimitNumber( difference ):gsub("%,","%.") .. GREENcolor .. " AP " .. lgIconText .. WHITEcolor .. currentAvARank .. GREYcolor .. " -> " .. ZO_CommaDelimitNumber( rankProgAvA ):gsub("%,","%.") .. "/" .. ZO_CommaDelimitNumber( rankMaxAvA ):gsub("%,","%.") .. " ( " .. levelProgress .. " ) ")
				return
			end
		end
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- TelVar update & saver
-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvP.StartChatTelVarPort()
	if IsInImperialCity() then
    	CHAT_SYSTEM:Maximize()
    	CHAT_SYSTEM.textEntry:InsertLink( "/p DsR_TELVAR_SAVER_PORT" )
    	CHAT_SYSTEM.textEntry:Open()
    	CHAT_SYSTEM.textEntry:FadeIn()
	else
		d("|cb81414Port-Function only in ImperialCity|r")
	end
end

function DsRGuildPvP.ShowTelVarPortButton()
    if not DsR_PvPTelVarSaverPort then
        -- Fenster erzeugen
        local wnd = WINDOW_MANAGER:CreateTopLevelWindow("DsR_PvPTelVarSaverPort")
        wnd:SetDimensions(350, 120)
        wnd:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
        wnd:SetMovable(true)
        wnd:SetMouseEnabled(true)
        wnd:SetHidden(false)

        -- Hintergrund
        local bg = WINDOW_MANAGER:CreateControl(nil, wnd, CT_BACKDROP)
        bg:SetAnchorFill()
        bg:SetCenterColor(0, 0, 0, 0)
        bg:SetEdgeColor(0, 0, 0, 0)

        -- Button
        local btn = CreateControlFromVirtual("DsR_PvPTelVarSaverPortButton", wnd, "ZO_DefaultButton")
        btn:SetDimensions(300, 50)
        btn:SetAnchor(CENTER, wnd, CENTER, 0, 0)
        btn:SetText("|cb81414Port to Mainbase|r")
        btn:SetHidden(false)

        btn:SetHandler("OnClicked", function()
            DsRGuildPvP.TelVarSaver()
            DsR_PvPTelVarSaverPort:SetHidden(true)
            SCENE_MANAGER:SetInUIMode(false)
        end)

        -- Abbrechen-Button
        local btnCancel = CreateControlFromVirtual("DDsR_PvPTelVarSaverPortButtonCancel", wnd, "ZO_DefaultButton")
        btnCancel:SetDimensions(300, 40)
        btnCancel:SetAnchor(TOP, btn, BOTTOM, 0, 10)
        btnCancel:SetText("Cancel")

        btnCancel:SetHandler("OnClicked", function()
            DsR_PvPTelVarSaverPort:SetHidden(true)
            SCENE_MANAGER:SetInUIMode(false)
        end)
    else
        -- Fenster anzeigen
        DsR_PvPTelVarSaverPort:SetHidden(false)
    end

    -- Maus aktivieren
    SCENE_MANAGER:SetInUIMode(true)
end

function DsRGuildPvP.TelVarSaver()
	if not IsInImperialCity() and not IsInCyrodiil() then
		d(string.format(GetString(DsRGuildPvP_ap_telvarSaverPortBreak)))
		return
	end
	if IsActiveWorldBattleground() then
		return
	end
	if IsInImperialCity() then
	    local bagpackCache = SHARED_INVENTORY:GenerateFullSlotData(nil, BAG_BACKPACK)
	    for bagSlot, data in pairs(bagpackCache) do
	        local itemId    = GetItemId(BAG_BACKPACK, data.slotIndex)

	        if itemId == 68347 then -- Kaiserlicher Rückzugsstein
	            if IsProtectedFunction("UseItem") then 
	                CallSecureProtected("UseItem", INVENTORY_BACKPACK, data.slotIndex)
	            else
	                UseItem(INVENTORY_BACKPACK, data.slotIndex) 
	            end

				d(GetString(DsRGuildPvP_ap_telvarSaverPort))

				local params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT)
				params:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_BATTLEGROUND_OBJECTIVE)
				params:SetText(GetString(DsRGuildPvP_ap_telvarSaverPort))
				CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(params)

				return
	        end
	    end
		local itemLink = "|H0:item:68347:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
		d(string.format(GetString(DsRGuildPvP_telVarSaverNoStoneINV), itemLink))
		local params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT)
		params:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_BATTLEGROUND_OBJECTIVE)
		params:SetText(string.format(GetString(DsRGuildPvP_telVarSaverNoStoneINV), itemLink))
		CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(params)
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvP.OnTVUpdate(eventId, newTelvarStones, oldTelvarStones, reason, reasonSupplementaryInfo )
	local gain  = newTelvarStones - oldTelvarStones

	if (reason == CURRENCY_CHANGE_REASON_PLAYER_INIT) then return end
	
	DsRGuildPvPscore.ScoreWindow_Update()

	if not DsRGuildPvP.pvp.PvPTelVar then return end

	local bankedTelVarStones = GetBankedCurrencyAmount(CURT_TELVAR_STONES)
	local BagPackIcon        = [[esoui/art/inventory/inventory_tabicon_craftbag_up.dds]]

	local maxTV = newTelvarStones + bankedTelVarStones

	if (gain == 0) then return end

	local TVicon = zo_iconTextFormat("/esoui/art/hud/telvar_meter_currency.dds", 20, 20, "")

	local WHITEcolor      = "|cFFFFFF"
	local GREYcolor	      = "|c808080"
	local GREENcolor	  = "|c35fc38"
	local REDcolor	      = "|cFF0000"
	local BLUEcolor	      = "|c5C6BFF"

	if not IsBankOpen() then
		if gain < 0 then
			d(TVicon .. REDcolor .. ZO_CommaDelimitNumber( gain ):gsub("%,","%.") .. BLUEcolor .. " " .. GetString(DsRGuildPvP_ap_telvarmsg) .. WHITEcolor .. " -> " .. ZO_CommaDelimitNumber( newTelvarStones ):gsub("%,","%.") .. GREYcolor .. " ( " .. ZO_CommaDelimitNumber( maxTV ):gsub("%,","%.") .. " )")
		elseif gain > tonumber(DsRGuildPvP.pvp.PvPTelVartxt) then
			d(TVicon .. GREENcolor .. " +" .. ZO_CommaDelimitNumber( gain ):gsub("%,","%.") .. BLUEcolor .. " " .. GetString(DsRGuildPvP_ap_telvarmsg) .. WHITEcolor .. " -> " .. ZO_CommaDelimitNumber( newTelvarStones ):gsub("%,","%.") .. GREYcolor .. " ( " .. ZO_CommaDelimitNumber( maxTV ):gsub("%,","%.") .. " )")
		end
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Kill Animation / notification / Counter
-------------------------------------------------------------------------------------------------------------------------------------------------
function  DsRGuildPvP.EventPlayerDead(eventCode)
	if (IsInCampaign() or IsActiveWorldBattleground()) then
		DsRGuildPvP.pvp.sessionStats.deaths = DsRGuildPvP.pvp.sessionStats.deaths + 1
		DsRGuildPvPscore.ScoreWindow_Update()
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvP.OnKillingAssist(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
	if (IsPlayerInAvAWorld() or IsActiveWorldBattleground()) then
        if (isError) then return end

		if result == ACTION_RESULT_KILLING_BLOW and sourceType == COMBAT_UNIT_TYPE_PLAYER and GetUnitName("player") == zo_strformat("<<1>>", sourceName) then
			if (sourceName == targetName) then return end

			local victim        = targetName:gsub("%^.+", "")
			local ICON_SIZE     = 24
			local allianceColor = "|cFFFFFF"
			
			if abilityName == "" then
    			local entry            = DsRPlayerDBData_SV.playerDB[victim]
    			local alliance         = entry and entry.alliance     or 0
    			local allianceRank     = entry and entry.allianceRank or 0
    			local displayName      = entry and entry.displayName  or ""
				local allianceRankIcon = ZO_GetColoredAvARankIconMarkup(allianceRank, alliance, ICON_SIZE) or ""

				if alliance == 1 then 			-- ALLIANCE_ALDMERI_DOMINION
    			    allianceColor = "|cFFD700"
    			elseif alliance == 2 then 		-- ALLIANCE_EBONHEART_PACT
    			    allianceColor = "|cB22222"
    			elseif alliance == 3 then		-- ALLIANCE_DAGGERFALL_COVENANT
    			    allianceColor = "|c4169E1"
    			end

				DsRGuildPvP.pvp.sessionStats.kills = DsRGuildPvP.pvp.sessionStats.kills + 1
				DsRGuildPvPscore.ScoreWindow_Update()
				if DsRGuildPvP.pvp.PvPKillChat then
					PlaySound(SOUNDS.SKILL_XP_DARK_ANCHOR_CLOSED)
					if IsActiveWorldBattleground() then
							d("|c97FFFF" .. GetString(DsRGuildPvP_KillingChat) .. "|r" .. victim)
					else
						if displayName ~= "" then
							d("|c97FFFF" .. GetString(DsRGuildPvP_KillingChat) .. "|r" .. allianceRankIcon .. allianceColor .. victim .. " (" .. displayName .. ")")
						else
							d("|c97FFFF" .. GetString(DsRGuildPvP_KillingChat) .. "|r" .. victim)
						end
					end
				end
			end
        end
    end
end

victimPlayerCharacterNamePREV = ""

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvP.OnKillingBow(eventId, killLocation, killerPlayerDisplayName, killerPlayerCharacterName, killerPlayerAlliance, killerPlayerRank, victimPlayerDisplayName, victimPlayerCharacterName, victimPlayerAlliance, victimPlayerRank, isKillLocation)
	if (IsInCampaign() or IsActiveWorldBattleground()) then
		local yourDisplayname = GetUnitDisplayName("player")

		if yourDisplayname ~= killerPlayerDisplayName then return end

		if victimPlayerCharacterName == victimPlayerCharacterNamePREV then
			victimPlayerCharacterNamePREV = ""
			return
		end

		local ICON_SIZE 	  = 24
		local victimIsEmperor = false
		local isBattleground  = IsActiveWorldBattleground()

 		local emperorIcon 	  = "/esoui/art/campaign/overview_indexicon_emperor_up.dds"

		local _,_, emperorDisplayName = GetCampaignEmperorInfo(GetCurrentCampaignId()) or ""
	
		if emperorDisplayName == victimPlayerDisplayName and not isBattleground then 
			victimIsEmperor = true
	 	end
 
		local victimAllianceColor
		if isBattleground then
		 	victimAllianceColor = GetBattlegroundAllianceColor(victimPlayerAlliance):GetBright()
		else
		 	victimAllianceColor = GetAllianceColor(victimPlayerAlliance):GetBright()
		end
		 
    	local victimIcon
    	if isBattleground then
    	    victimIcon = ZO_GetBattlegroundIconMarkup(victimPlayerAlliance, ICON_SIZE)
    	else
			if victimIsEmperor then 
			     victimIcon = zo_iconTextFormatNoSpace(emperorIcon,ICON_SIZE,ICON_SIZE,"")
			else
			     victimIcon = ZO_GetColoredAvARankIconMarkup(victimPlayerRank, victimPlayerAlliance, ICON_SIZE)
			end
    	end

		local victim = victimIcon .. victimAllianceColor:Colorize(victimPlayerCharacterName:gsub("%^.+", "") .. " (" .. victimPlayerDisplayName .. ")")
			
		local Greencolor  = "|c35fc38"
		local REDcolor	  = "|cFF0000"
		local YELLOWcolor = "|cFFFF00"

		-- ---------------------------------
		-- CHECK ALLIANCE
		-- local youralliance = GetUnitAlliance("player")
		-- ---------------------------------
		-- 1 = ALLIANCE_ALDMERI_DOMINION
		-- 2 = ALLIANCE_EBONHEART_PACT
		-- 3 = ALLIANCE_DAGGERFALL_COVENANT
		-- ---------------------------------


        if DsRGuildPvP.pvp.PvPKillenableFrame then 
			DSR_KillingBlowScreenFrame.animation:PlayFromStart()
			PlaySound(SOUNDS.BATTLEGROUND_CAPTURE_AREA_CAPTURED_OWN_TEAM)
		end
		if DsRGuildPvP.pvp.PvPKillBlowChat then
			d("|cFF0000" .. GetString(DsRGuildPvP_KillingBlowmsgA) .. "|r" .. victim)
		end
		if DsRGuildPvP.pvp.PvPKillBlowScreen then
			if victimIsEmperor and not isBattleground then
				local params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT)
				params:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_BATTLEGROUND_OBJECTIVE)
				params:SetText(zo_strformat(GetString(DsRGuildPvP_VictimEmperor), victim))
				CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(params)
			else
				local params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT)
				params:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_BATTLEGROUND_OBJECTIVE)
				params:SetText("|cFF0000" .. GetString(DsRGuildPvP_KillingBlowmsgA) .. "|r" .. victim)
				CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(params)
			end
		end

		DsRGuildPvP.pvp.sessionStats.killingBlows = DsRGuildPvP.pvp.sessionStats.killingBlows + 1
		
		if victimPlayerAlliance == 1 then
			DsRGuildPvP.pvp.sessionStats.killingBlowsAD = DsRGuildPvP.pvp.sessionStats.killingBlowsAD + 1
		elseif victimPlayerAlliance == 2 then
			DsRGuildPvP.pvp.sessionStats.killingBlowsEP = DsRGuildPvP.pvp.sessionStats.killingBlowsEP + 1
		elseif victimPlayerAlliance == 3 then
			DsRGuildPvP.pvp.sessionStats.killingBlowsDC = DsRGuildPvP.pvp.sessionStats.killingBlowsDC + 1
		end
		DsRGuildPvPscore.ScoreWindow_Update()
    end
	victimPlayerCharacterNamePREV = victimPlayerCharacterName
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Warteschlange
-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvP_Periodic:New(inPeriodicFunc, inPeriodSecs)
    	
    local dsrPeriodicObj = ZO_Object.New(self)
    dsrPeriodicObj.periodicFunc = inPeriodicFunc
    dsrPeriodicObj.periodInSecs = inPeriodSecs or 60
    dsrPeriodicObj.isRegistered = false

    local bigRandom 		  = math.random(11111111, 99999999)
    local bigRandomStr 		  = string.format("%d",bigRandom)
    dsrPeriodicObj.identifier = "TBOP"..bigRandomStr
    return dsrPeriodicObj
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvP_Periodic:Start(inPeriodicFunc, inPeriodSecs)

    if self.isRegistered == true then DsRGuildPvP_Periodic:Stop() end	

    self.periodicFunc = inPeriodicFunc or self.periodicFunc
    assert(self.periodicFunc ~= nil, "DsRGuildPvP_Periodic:New(): The 'periodicFunc' of the DsRGuildPvP_Periodic cannot be nil!")

    self.periodInSecs = inPeriodSecs or self.periodInSecs
    assert(self.periodInSecs > 0, "DsRGuildPvP_Periodic:Start(): The 'inPeriodSecs' parameter must be a positive integer!")

    self.periodicFunc()

    local updateMillisecs = self.periodInSecs * 1000
	EVENT_MANAGER:RegisterForUpdate(self.identifier, updateMillisecs, self.periodicFunc)
	self.isRegistered = true
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvP_Periodic:Stop()
	if self.isRegistered == false then return end
	EVENT_MANAGER:UnregisterForUpdate(self.identifier)
	self.isRegistered = false
end

-------------------------------------------------------------------------------------------------------------------------------------------------
local function QueueTimeUpdate() 
	if DsRGuildPvP.queuedCampaignID == nil then return end
	local queueTime = GetSecondsInCampaignQueue(DsRGuildPvP.queuedCampaignID, DsRGuildPvP.queuedAsGroup or false)
	if not queueTime or queueTime == 0 then return end
	DsRGuildPvP.queueTimeInSecs = queueTime
	DsRGuildPvPscore.ScoreWindow_Update()
end

-------------------------------------------------------------------------------------------------------------------------------------------------
local function updateQueueInfo()
	local qSize 		= GetNumCampaignQueueEntries()
	local campID 		= nil
	local queuedAsGroup = nil

	if qSize > 0 then campID, queuedAsGroup = GetCampaignQueueEntry(qSize) end

	if campID then
		DsRGuildPvP.queuedCampaignID = campID
		DsRGuildPvP.queuedAsGroup 	 = queuedAsGroup
		DsRGuildPvP.queueState 		 = GetCampaignQueueState(campID, queuedAsGroup)
		DsRGuildPvP.queuePosition 	 = GetCampaignQueuePosition(campID, queuedAsGroup)
		DsRGuildPvP.queueTimeInSecs  = nil
		if DsRGuildPvP.queueState == CAMPAIGN_QUEUE_REQUEST_STATE_WAITING then 
			DsRGuildPvP.queueTimeInSecs = GetSecondsInCampaignQueue(campID, queuedAsGroup)
			DsRGuildPvP.queuePeriodic:Start(QueueTimeUpdate, 1)
		end
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvP.EVENT_CAMPAIGN_QUEUE_JOINED(eventCode, campaignId, isGroupMember, willLockToAlliance)
	DsRGuildPvP.queuedCampaignID = campaignId 
	DsRGuildPvP.queuedAsGroup    = isGroupMember
	DsRGuildPvP.queueState       = GetCampaignQueueState(campaignId, isGroupMember)
	DsRGuildPvP.queuePosition    = GetCampaignQueuePosition(campaignId, isGroupMember)
	DsRGuildPvP.queueTimeInSecs  = GetSecondsInCampaignQueue(campaignId, isGroupMember)

	DsRGuildPvPscore.ScoreWindow_Update()
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvP.EVENT_CAMPAIGN_QUEUE_LEFT(eventCode, campaignId, isGroup)
	DsRGuildPvP.queuedCampaignID = nil
	DsRGuildPvP.queuePosition 	 = nil
	DsRGuildPvP.queueState 		 = nil

	DsRGuildPvP.queuePeriodic:Stop()
	DsRGuildPvP.queueTimeInSecs = nil

	updateQueueInfo()

	DsRGuildPvPscore.ScoreWindow_Update()
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvP.EVENT_CAMPAIGN_QUEUE_STATE_CHANGED(eventCode, campaignId, isGroup, state)
	DsRGuildPvP.queuedCampaignID = campaignId
	DsRGuildPvP.queueState 		 = state
	if DsRGuildPvP.queueState == CAMPAIGN_QUEUE_REQUEST_STATE_WAITING then 
		DsRGuildPvP.queuePeriodic:Start(QueueTimeUpdate, 1)
	else 
		DsRGuildPvP.queuePeriodic:Stop() 
		DsRGuildPvP.queueTimeInSecs = nil
	end

	DsRGuildPvPscore.ScoreWindow_Update()

	if state == CAMPAIGN_QUEUE_REQUEST_STATE_CONFIRMING then
        ConfirmCampaignEntry(campaignId, isGroup, true)
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvP.EVENT_CAMPAIGN_QUEUE_POSITION_CHANGED(eventCode, campaignId, isGroup, position)
	DsRGuildPvP.queuedCampaignID = campaignId
	DsRGuildPvP.queuePosition 	 = position
	DsRGuildPvPscore.ScoreWindow_Update()
end

function DsRGuildPvP.ZoneChanged(eventCode, zoneName, subZoneName, newSubzone, zoneId, subZoneId)
	if IsPlayerInAvAWorld() == false or IsActiveWorldBattleground() == false then
		DsRGuildPvPscore.ScoreWindow_Update()
	end

	if IsInCyrodiil() then
		if  DsRGuildPvP.pvp.PvPkillFeedCyro then
			SetSetting(SETTING_TYPE_UI, UI_SETTING_SHOW_PVP_KILL_FEED_NOTIFICATIONS, "true")
		else	
			SetSetting(SETTING_TYPE_UI, UI_SETTING_SHOW_PVP_KILL_FEED_NOTIFICATIONS, "false")
		end
	elseif IsInImperialCity() then
		if DsRGuildPvP.pvp.PvPkillFeedImp then
			SetSetting(SETTING_TYPE_UI, UI_SETTING_SHOW_PVP_KILL_FEED_NOTIFICATIONS, "true")
		else
			SetSetting(SETTING_TYPE_UI, UI_SETTING_SHOW_PVP_KILL_FEED_NOTIFICATIONS, "false")
		end
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvP.GroupInviteZone()

	local size     = GetGroupSize()
    local free     = math.floor(12 - tonumber(size))
	local Imperial = IsInImperialCity()
    local Cyrodiil = IsInCyrodiil()
	local TEXT     = ""

	if tonumber(free) == 12 then
		free = 11 
	end

	if Cyrodiil == true then
    	TEXT = "|H1:guild:155508|hDsR|h Type -> RABE <- for group invite / für Gruppeneinladung (Free places: " .. free .. ")"
	elseif Imperial == true then
		TEXT = "|H1:guild:155508|hDsR|h Type -> RABE <- for MolagBal-group / für MolagBal-Gruppe (Free places: " .. free .. ")"
	else
		return
	end

	local channel    = string.format("%s", "/zone")
	local outputtext = string.format("%s", TEXT)
	CHAT_SYSTEM:Maximize()
    CHAT_SYSTEM.textEntry:InsertLink( channel )
    CHAT_SYSTEM.textEntry:InsertLink( " " .. outputtext )
	CHAT_SYSTEM.textEntry:Open() CHAT_SYSTEM.textEntry:FadeIn()
end
-------------------------------------------------------------------------------------------------------------------------------------------------
-- On addon loaded
-------------------------------------------------------------------------------------------------------------------------------------------------
local function LogoutOrQuit()
	DsRGuildPvP.pvp.sessionStats.kills 			= 0
	DsRGuildPvP.pvp.sessionStats.killingBlows	= 0
	DsRGuildPvP.pvp.sessionStats.killingBlowsAD	= 0
	DsRGuildPvP.pvp.sessionStats.killingBlowsEP	= 0
	DsRGuildPvP.pvp.sessionStats.killingBlowsDC	= 0
	DsRGuildPvP.pvp.sessionStats.deaths 		= 0
	DsRGuildPvP.pvp.sessionStats.alliancePoints = 0
end

local function OnGroupMessage(eventCode, messageType, fromName, text, isCustomerService, fromDisplayName)
    if text == "DsR_TELVAR_SAVER_PORT" then
        DsRGuildPvP.ShowTelVarPortButton()
    end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvP.OnAddonLoaded(event, name)
	if DsRGuildPvP.pvp.PvPAP then
		EVENT_MANAGER:RegisterForEvent(DsRGuildPvP.name, EVENT_ALLIANCE_POINT_UPDATE, DsRGuildPvP.OnAPUpdated )
	else
		EVENT_MANAGER:UnregisterForEvent(DsRGuildPvP.name, EVENT_ALLIANCE_POINT_UPDATE )
	end
	if DsRGuildPvP.pvp.PvPTelVar then
		EVENT_MANAGER:RegisterForEvent(DsRGuildPvP.name, EVENT_TELVAR_STONE_UPDATE, DsRGuildPvP.OnTVUpdate )
	else
		EVENT_MANAGER:UnregisterForEvent(DsRGuildPvP.name, EVENT_TELVAR_STONE_UPDATE )
	end

	DSR_KillingBlowScreenFrameOverlay:SetEdgeColor(ZO_ColorDef:New(unpack(DsRGuildPvP.pvp.PvPKillframeColor)):UnpackRGBA())
	DSR_KillingBlowScreenFrame.animation = ANIMATION_MANAGER:CreateTimelineFromVirtual('DSR_KillingBlowScreenFrameAnimation', DSR_KillingBlowScreenFrame)
	
	EVENT_MANAGER:RegisterForEvent(DsRGuildPvP.name, EVENT_PVP_KILL_FEED_DEATH, DsRGuildPvP.OnKillingBow)
	EVENT_MANAGER:RegisterForEvent(DsRGuildPvP.name, EVENT_COMBAT_EVENT, 		DsRGuildPvP.OnKillingAssist)
	EVENT_MANAGER:RegisterForEvent(DsRGuildPvP.name, EVENT_PLAYER_DEAD, 		DsRGuildPvP.EventPlayerDead)

	EVENT_MANAGER:RegisterForEvent(DsRGuildPvP.name, EVENT_ZONE_CHANGED, function() DsRGuildPvP.ZoneChanged() end)

	if DsRGuildPvP.pvp.enableQueueBar then
		EVENT_MANAGER:RegisterForEvent(DsRGuildPvP.name, EVENT_CAMPAIGN_QUEUE_JOINED, 			DsRGuildPvP.EVENT_CAMPAIGN_QUEUE_JOINED)
		EVENT_MANAGER:RegisterForEvent(DsRGuildPvP.name, EVENT_CAMPAIGN_QUEUE_LEFT, 			DsRGuildPvP.EVENT_CAMPAIGN_QUEUE_LEFT)
		EVENT_MANAGER:RegisterForEvent(DsRGuildPvP.name, EVENT_CAMPAIGN_QUEUE_STATE_CHANGED, 	DsRGuildPvP.EVENT_CAMPAIGN_QUEUE_STATE_CHANGED)
		EVENT_MANAGER:RegisterForEvent(DsRGuildPvP.name, EVENT_CAMPAIGN_QUEUE_POSITION_CHANGED, DsRGuildPvP.EVENT_CAMPAIGN_QUEUE_POSITION_CHANGED)
	end

	EVENT_MANAGER:RegisterForEvent("DsRPvPTelVarSaveCommandWatch", EVENT_CHAT_MESSAGE_CHANNEL, OnGroupMessage)

	ZO_PreHook("Logout", function() LogoutOrQuit() end)
	ZO_PreHook("Quit", function() LogoutOrQuit() end)
end
