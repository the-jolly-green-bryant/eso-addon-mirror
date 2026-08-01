-------------------------------------------------------------------------------
-- SALTI (Save ALT Info) - Currency Totals
-------------------------------------------------------------------------------
--[[
-- Copyright (c) 2017-2025 James A. Keene (Phinix) All rights reserved.
--
-- Permission is hereby granted, free of charge, to any person obtaining
-- a copy of this software and associated documentation (the "Software"),
-- to operate the Software for personal use only. Permission is NOT granted
-- to modify, merge, publish, distribute, sublicense, re-upload, and/or sell
-- copies of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
-- EXPRESS OR IMPLIED. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
-- HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
-- WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
-- FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
-- OTHER DEALINGS IN THE SOFTWARE.
--
-------------------------------------------------------------------------------
--
-- DISCLAIMER:
--
-- This Add-on is not created by, affiliated with or sponsored by ZeniMax
-- Media Inc. or its affiliates. The Elder Scrolls® and related logos are
-- registered trademarks or trademarks of ZeniMax Media Inc. in the United
-- States and/or other countries. All rights reserved.
--
-- You can read the full terms at:
-- https://account.elderscrollsonline.com/add-on-terms
--]]

local SALTI = _G['SALTI']
local L = SALTI.Strings
local version = "1.47"

-- Global functions:
local pTC	= SALTI.TColor
local pGK	= SALTI.GetKey
local pCC	= SALTI.CountKeys
local pC	= SALTI.Contains

-- session variables
local worldName						-- (STRING)		Megaserver name for current login session (NA, EU, PTS)
local accountName					-- (STRING)		Account @name for current login session
local currentID						-- (STRING)		Unique ID of the current logged in character
local GBRBuffer = 0					-- (INT)		buffer for guild bank ready spam control
local eBuffer = 0					-- (INT)		buffer for currency update event spam

-- variable tables
local CHeader = {}					-- (TABLE)		currency display header controls
local CSummary = {}					-- (TABLE)		currency display totals summary controls
local CDiv = {}						-- (TABLE)		currency display divider controls
local CChars = {}					-- (TABLE)		currency display character controls
local CGuilds = {}					-- (TABLE)		currency display guild total controls
local CControls = {}				-- (TABLE)		currency display main column controls
local nameList = {}					-- (TABLE)		sorted list of tracked characters
local charIDName = {}				-- (TABLE)		table of all characters on current logged in account indexed by unique ID
local charNamesOPT = {}				-- (TABLE)		table of characters the addon knows about and are set to track

------------------------------------------------------------------------------------------------------------------------------------
-- Utility functions
------------------------------------------------------------------------------------------------------------------------------------
local function GetSorted(vTable, char)
	local tNames = {}
	if char then
		for k in pairs(vTable) do
			tNames[#tNames + 1] = charIDName[k]
		end
	else
		for k in pairs(vTable) do
			tNames[#tNames + 1] = k
		end
	end
	table.sort(tNames)
	return tNames
end

local function GetSortedNames(ct, sorted)
	local tNames = {}
	local sNames = {}
	for k, c in ipairs(ct) do
		table.insert(tNames, c)
	end
	if sorted then table.sort(tNames) end
	for k, n in ipairs(tNames) do
		sNames[#sNames + 1] = n
	end
	return sNames
end

local function GetAccountCharacters()
	local tempChars = {}
	local tempIDs = {}
	local trackedNames = {}		-- this is the name list for the actual currency display. current character included here where appropriate.
	charNamesOPT = {}			-- this table of names is for the addon settings dropdown to delete characters. current is excluded.

	for i = 1, GetNumCharacters() do -- populate table of all character names on the current account indexed by unique ID
		local charName, _, _, _, _, _, charID = GetCharacterInfo(i)
		tempIDs[#tempIDs + 1] = {name = zo_strformat(SI_UNIT_NAME, charName), ID = charID}
		charIDName[charID] = zo_strformat(SI_UNIT_NAME, charName)
	end

	for characterID, _ in pairs(SALTIVars[worldName][accountName]) do -- remove character from account variables if not a valid existing character on the account
		if characterID ~= "$AccountWide" then
			if charIDName[characterID] == nil then
				SALTIVars[worldName][accountName][characterID] = nil
			end
		end
	end

	for k, v in ipairs(tempIDs) do -- build list of valid account characters the addon knows about and are set to track
		if SALTIVars[worldName][accountName][v.ID] ~= nil then
			if SALTIVars[worldName][accountName][v.ID].CharacterSettings.trackChar == true then
				trackedNames[#trackedNames + 1] = v.name
				if v.ID ~= currentID then
					charNamesOPT[#charNamesOPT + 1] = v.name
				end
			end
		end
	end

	nameList = (SALTI.ASV.sortAlpha) and GetSortedNames(trackedNames, true) or GetSortedNames(trackedNames, false) -- sort character database alphabetically or as account order

	for cNum = 1, #nameList do -- build final addon character display info based on above sorted result
		local nameCon = GetControl('SALTI_Gold'..'_CG'..cNum..'Name')
		local apCon = GetControl('SALTI_Gold'..'_CG'..cNum..'AP')
		local tvCon = GetControl('SALTI_Gold'..'_CG'..cNum..'TV')
		local wvCon = GetControl('SALTI_Gold'..'_CG'..cNum..'WV')
		local goldCon = GetControl('SALTI_Gold'..'_CG'..cNum..'Gold')
		local iconCon = GetControl('SALTI_Gold'..'_CG'..cNum..'Icon')
		tempChars[cNum] = {
			name = (not nameCon) and WINDOW_MANAGER:CreateControl(SALTI_Gold:GetName()..'_CG'..cNum..'Name', SALTI_Gold, CT_LABEL) or nameCon,
			ap = (not apCon) and WINDOW_MANAGER:CreateControl(SALTI_Gold:GetName()..'_CG'..cNum..'AP', SALTI_Gold, CT_LABEL) or apCon,
			tv = (not tvCon) and WINDOW_MANAGER:CreateControl(SALTI_Gold:GetName()..'_CG'..cNum..'TV', SALTI_Gold, CT_LABEL) or tvCon,
			wv = (not wvCon) and WINDOW_MANAGER:CreateControl(SALTI_Gold:GetName()..'_CG'..cNum..'WV', SALTI_Gold, CT_LABEL) or wvCon,
			gold = (not goldCon) and WINDOW_MANAGER:CreateControl(SALTI_Gold:GetName()..'_CG'..cNum..'Gold', SALTI_Gold, CT_LABEL) or goldCon,
			icon = (not iconCon) and WINDOW_MANAGER:CreateControl(SALTI_Gold:GetName()..'_CG'..cNum..'Icon', SALTI_Gold, CT_TEXTURE) or iconCon,
		}
	end

	for i = 1, #tempChars do
		tempChars[i].name:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
		tempChars[i].name:SetFont("ZoFontGame")
		tempChars[i].name:SetHidden(true)
		tempChars[i].ap:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
		tempChars[i].ap:SetFont("ZoFontGame")
		tempChars[i].ap:SetHidden(true)
		tempChars[i].tv:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
		tempChars[i].tv:SetFont("ZoFontGame")
		tempChars[i].tv:SetHidden(true)
		tempChars[i].wv:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
		tempChars[i].wv:SetFont("ZoFontGame")
		tempChars[i].wv:SetHidden(true)
		tempChars[i].gold:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
		tempChars[i].gold:SetFont("ZoFontGame")
		tempChars[i].gold:SetHidden(true)
		tempChars[i].icon:SetWidth(24)
		tempChars[i].icon:SetHeight(24)
		tempChars[i].icon:SetHidden(true)
		-- Add to controls DB
		CControls[#CControls + 1] = tempChars[i].name
		CControls[#CControls + 1] = tempChars[i].ap
		CControls[#CControls + 1] = tempChars[i].tv
		CControls[#CControls + 1] = tempChars[i].wv
		CControls[#CControls + 1] = tempChars[i].gold
		CControls[#CControls + 1] = tempChars[i].icon
	end

	return tempChars
end

local function EventBufferReset()
	eBuffer = 0
end

------------------------------------------------------------------------------------------------------------------------------------
-- Main functions
------------------------------------------------------------------------------------------------------------------------------------
local function CIcon(aid, cid) -- Sets the class/alliance icons (if enabled)
	local alliance = {
		[1] = {icon = {[1] = '/SALTI/bin/ADD.dds',[2] = '/SALTI/bin/ADS.dds',[3] = '/SALTI/bin/ADN.dds',[4] = '/SALTI/bin/ADW.dds',[5] = '/SALTI/bin/ADNM.dds',[6] = '/SALTI/bin/ADT.dds',[117] = '/SALTI/bin/ADA.dds'}},
		[2] = {icon = {[1] = '/SALTI/bin/EPD.dds',[2] = '/SALTI/bin/EPS.dds',[3] = '/SALTI/bin/EPN.dds',[4] = '/SALTI/bin/EPW.dds',[5] = '/SALTI/bin/EPNM.dds',[6] = '/SALTI/bin/EPT.dds',[117] = '/SALTI/bin/EPA.dds'}},
		[3] = {icon = {[1] = '/SALTI/bin/DCD.dds',[2] = '/SALTI/bin/DCS.dds',[3] = '/SALTI/bin/DCN.dds',[4] = '/SALTI/bin/DCW.dds',[5] = '/SALTI/bin/DCNM.dds',[6] = '/SALTI/bin/DCT.dds',[117] = '/SALTI/bin/DCA.dds'}}
	}
	return alliance[aid].icon[cid]
end

local function MoneyUpdate(eventCode, currencyType, currencyLocation, newAmount, oldAmount, reason) -- Update character, bank, and account-wide money totals
	if eBuffer == 0 then
		-- prevent multiple calls processing back to back when depositing in bank, etc.
		eBuffer = 1

	-- Debug
	--	if currencyType == CURT_MONEY then
	--		d("Gold")
	--	elseif currencyType == CURT_ALLIANCE_POINTS then
	--		d("Alliance Points")
	--	elseif currencyType == CURT_TELVAR_STONES then
	--		d("Telvar Stones")
	--	elseif currencyType == CURT_WRIT_VOUCHERS then
	--		d("Writ Vouchers")
	--	elseif currencyType == CURT_CHAOTIC_CREATIA then
	--		d("Transmute Crystals")
	--	elseif currencyType == CURT_EVENT_TICKETS then
	--		d("Event Tickets")
	--	elseif currencyType == CURT_STYLE_STONES then
	--		d("Outfit Tokens")
	--	elseif currencyType == CURT_UNDAUNTED_KEYS then
	--		d("Undaunted Keys")
	--	elseif currencyType == CURT_ARCHIVAL_FORTUNES then
	--		d("Archival Fortunes")
	--	elseif currencyType == CURT_IMPERIAL_FRAGMENT then
	--		d("Imperial Fragments")
	--	elseif currencyType == CURT_CROWN_GEMS then
	--		d("Crown Gems")
	--	elseif currencyType == CURT_CROWNS then
	--		d("Crowns")
	--	elseif currencyType == CURT_ENDEAVOR_SEALS then
	--		d("Seals of Endeavor")
	--	end

		-- Check current bank totals
		local tgBank = GetBankedCurrencyAmount(CURT_MONEY)
		local ttvBank = GetBankedCurrencyAmount(CURT_TELVAR_STONES)
		local tapBank = GetBankedCurrencyAmount(CURT_ALLIANCE_POINTS)
		local twvBank = GetBankedCurrencyAmount(CURT_WRIT_VOUCHERS)

		-- Temp vars for account-wide tally
		local tTotalGold = 0
		local tTotalTelvar = 0
		local tTotalAP = 0
		local tTotalWV = 0

		-- For each saved character, check current totals, update vars as needed, and add to temp account-wide tally
		for k,v in ipairs(nameList) do
			local cID = pGK(charIDName, v)
			local vars = SALTIVars[worldName][accountName][cID].CharacterSettings.cVals
			if cID == currentID then
				SALTI.SV.cVals.money = GetCarriedCurrencyAmount(CURT_MONEY)
				SALTI.SV.cVals.telvar = GetCarriedCurrencyAmount(CURT_TELVAR_STONES)
				SALTI.SV.cVals.ap = GetCarriedCurrencyAmount(CURT_ALLIANCE_POINTS)
				SALTI.SV.cVals.wvouchers = GetCarriedCurrencyAmount(CURT_WRIT_VOUCHERS)
			end

			local ctmoney = (vars.money ~= nil) and vars.money or 0
			if vars.money == nil then vars.money = ctmoney end
			local cttv = (vars.telvar ~= nil) and vars.telvar or 0
			if vars.telvar == nil then vars.telvar = cttv end
			local ctap = (vars.ap ~= nil) and vars.ap or 0
			if vars.ap == nil then vars.ap = ctap end
			local ctwv = (vars.wvouchers ~= nil) and vars.wvouchers or 0
			if vars.wvouchers == nil then vars.wvouchers = ctwv end

			tTotalGold = tTotalGold + ctmoney
			tTotalTelvar = tTotalTelvar + cttv
			tTotalAP = tTotalAP + ctap
			tTotalWV = tTotalWV + ctwv
		end

		-- Add all character totals and banked totals
		tTotalGold = tTotalGold + tgBank
		tTotalTelvar = tTotalTelvar + ttvBank
		tTotalAP = tTotalAP + tapBank
		tTotalWV = tTotalWV + twvBank
	
		-- Update bank saved var totals
		SALTI.ASV.gBank = tgBank
		SALTI.ASV.tvBank = ttvBank
		SALTI.ASV.apBank = tapBank
		SALTI.ASV.wvBank = twvBank

		-- Update combined currency totals
		SALTI.ASV.gAccount = tTotalGold
		SALTI.ASV.tvAccount = tTotalTelvar
		SALTI.ASV.apAccount = tTotalAP
		SALTI.ASV.wvAccount = tTotalWV

		-- Update account-wide totals
		SALTI.ASV.sEndeavor = GetCurrencyAmount(CURT_ENDEAVOR_SEALS, CURRENCY_LOCATION_ACCOUNT)		-- Seals of Endeavor
		SALTI.ASV.aTCrystals = GetCurrencyAmount(CURT_CHAOTIC_CREATIA, CURRENCY_LOCATION_ACCOUNT)	-- Transmute Crystals
		SALTI.ASV.aETickets = GetCurrencyAmount(CURT_EVENT_TICKETS, CURRENCY_LOCATION_ACCOUNT)		-- Event Tickets
		SALTI.ASV.aOutfit = GetCurrencyAmount(CURT_STYLE_STONES, CURRENCY_LOCATION_ACCOUNT)			-- Outfit Tokens
		SALTI.ASV.aUKeys = GetCurrencyAmount(CURT_UNDAUNTED_KEYS, CURRENCY_LOCATION_ACCOUNT)		-- Undaunted Keys
		SALTI.ASV.aFortunes = GetCurrencyAmount(CURT_ARCHIVAL_FORTUNES, CURRENCY_LOCATION_ACCOUNT)	-- Archival Fortunes
		SALTI.ASV.impFrags = GetCurrencyAmount(CURT_IMPERIAL_FRAGMENTS, CURRENCY_LOCATION_ACCOUNT)	-- Imperial Fragments
		SALTI.ASV.aCGems = GetCurrencyAmount(CURT_CROWN_GEMS, CURRENCY_LOCATION_ACCOUNT)			-- Crown Gems
		SALTI.ASV.aCrowns = GetCurrencyAmount(CURT_CROWNS, CURRENCY_LOCATION_ACCOUNT)				-- Crowns

		-- New API function to save variables to file immediately
	--	RequestAddOnSavedVariablesPrioritySave('SALTI')

		zo_callLater(EventBufferReset, 100)
	end
end

local function ACIcons() -- Resize display to fit class icons (if enabled)
	if SALTI.ASV.iACShow then
		return 596, 26, -27
	else
		return 576, 7, -10
	end
end

local function RestoreGoldPosition() -- Restores independent movable window location
	local left = SALTI.ASV.xpos
	local top = SALTI.ASV.ypos
	SALTI_Gold:ClearAnchors()
	SALTI_Gold:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end

local function MoneyTooltip(control, opt) -- Modifies the money tooltip; controls defined in /bin/setup.lua
	if opt == 1 then
		MoneyUpdate()
		local numTrackedChars = #nameList
		local numTrackedGuilds = pCC(SALTI.ASV.gVals)
		local gWidth, sAlign, dAlign = ACIcons()
		local gHeight = 106
		ClearTooltip(InformationTooltip)
		SALTI_Gold:SetWidth(gWidth)
		SALTI_Gold:SetHeight(gHeight)

		CSummary.TS:ClearAnchors()
		CSummary.TG:ClearAnchors()
		CSummary.TT:ClearAnchors()
		CSummary.TA:ClearAnchors()
		CSummary.TW:ClearAnchors()
		CSummary.BS:ClearAnchors()
		CSummary.BG:ClearAnchors()
		CSummary.BT:ClearAnchors()
		CSummary.BA:ClearAnchors()
		CSummary.BW:ClearAnchors()

		CHeader.HS:ClearAnchors()
		CHeader.HS:SetText(L.SALTI_SOURCE)
		CHeader.HS:SetAnchor(TOPLEFT, SALTI_Gold, TOPLEFT, sAlign, 5)
		CHeader.HW:ClearAnchors()
		CHeader.HW:SetText(L.SALTI_WV)
		CHeader.HW:SetAnchor(TOPRIGHT, SALTI_Gold, TOPRIGHT, -7, 5)
		CHeader.HA:ClearAnchors()
		CHeader.HA:SetText(L.SALTI_AP)
		CHeader.HA:SetAnchor(TOPRIGHT, CHeader.HW, TOPLEFT, -68, 0)
		CHeader.HT:ClearAnchors()
		CHeader.HT:SetText(L.SALTI_TV)
		CHeader.HT:SetAnchor(TOPRIGHT, CHeader.HA, TOPLEFT, -68, 0)
		CHeader.HG:ClearAnchors()
		CHeader.HG:SetText(L.SALTI_GOLD)
		CHeader.HG:SetAnchor(TOPRIGHT, CHeader.HT, TOPLEFT, -60, 0)

		CDiv.DIV1:ClearAnchors()
		CDiv.DIV1:SetAnchor(TOPLEFT, CHeader.HS, BOTTOMLEFT, dAlign, 10)
		CDiv.DIV1:SetAnchor(TOPRIGHT, CHeader.HW, BOTTOMRIGHT, 0, 10)
		CDiv.DIV1:SetHidden(false)
		
		if numTrackedChars > 0 then
			for i = 1, numTrackedChars do
				local cID = pGK(charIDName, nameList[i])
				local vars = SALTIVars[worldName][accountName][cID].CharacterSettings.cVals
				local CIcon = CIcon(vars.alliance, vars.class)

				CChars[i].name:ClearAnchors()
				CChars[i].ap:ClearAnchors()
				CChars[i].tv:ClearAnchors()
				CChars[i].wv:ClearAnchors()
				CChars[i].gold:ClearAnchors()
				CChars[i].icon:ClearAnchors()
				CChars[i].icon:SetTexture(CIcon)
				CChars[i].name:SetText(nameList[i])

				if vars.ap == 0 then CChars[i].ap:SetText(pTC("2be023", "--")) else CChars[i].ap:SetText(pTC("2be023", ZO_CurrencyControl_FormatCurrency(vars.ap, false))) end
				if vars.telvar == 0 then CChars[i].tv:SetText(pTC("60a7ff", "--")) else CChars[i].tv:SetText(pTC("60a7ff", ZO_CurrencyControl_FormatCurrency(vars.telvar, false))) end
				if vars.wvouchers == 0 then CChars[i].wv:SetText(pTC("ffff00", "--")) else CChars[i].wv:SetText(pTC("ffff00", ZO_CurrencyControl_FormatCurrency(vars.wvouchers, false))) end
				if vars.money == 0 then CChars[i].gold:SetText("--") else CChars[i].gold:SetText(ZO_CurrencyControl_FormatCurrency(vars.money, false)) end
				if i == 1 then
					CChars[i].name:SetAnchor(TOPLEFT, CHeader.HS, BOTTOMLEFT, 0, 20)
					CChars[i].icon:SetAnchor(RIGHT, CChars[i].name, LEFT, -1, 0)
					CChars[i].ap:SetAnchor(TOPRIGHT, CHeader.HA, BOTTOMRIGHT, 0, 20)
					CChars[i].tv:SetAnchor(TOPRIGHT, CHeader.HT, BOTTOMRIGHT, 0, 20)
					CChars[i].wv:SetAnchor(TOPRIGHT, CHeader.HW, BOTTOMRIGHT, 0, 20)
					CChars[i].gold:SetAnchor(TOPRIGHT, CHeader.HG, BOTTOMRIGHT, 0, 20)
				else
					CChars[i].name:SetAnchor(TOPLEFT, CChars[i-1].name, BOTTOMLEFT, 0, 2)
					CChars[i].icon:SetAnchor(RIGHT, CChars[i].name, LEFT, -1, 0)
					CChars[i].ap:SetAnchor(TOPRIGHT, CChars[i-1].ap, BOTTOMRIGHT, 0, 2)
					CChars[i].tv:SetAnchor(TOPRIGHT, CChars[i-1].tv, BOTTOMRIGHT, 0, 2)
					CChars[i].wv:SetAnchor(TOPRIGHT, CChars[i-1].wv, BOTTOMRIGHT, 0, 2)
					CChars[i].gold:SetAnchor(TOPRIGHT, CChars[i-1].gold, BOTTOMRIGHT, 0, 2)
				end
				if SALTI.ASV.iACShow then CChars[i].icon:SetHidden(false) end
				CChars[i].name:SetHidden(false)
				CChars[i].ap:SetHidden(false)
				CChars[i].tv:SetHidden(false)
				CChars[i].wv:SetHidden(false)
				CChars[i].gold:SetHidden(false)
			end
			CDiv.DIV2:ClearAnchors()
			CDiv.DIV2:SetAnchor(TOPLEFT, CChars[numTrackedChars].name, BOTTOMLEFT, dAlign, 10)
			CDiv.DIV2:SetAnchor(TOPRIGHT, CChars[numTrackedChars].wv, BOTTOMRIGHT, 0, 10)
			CDiv.DIV2:SetHidden(false)
			CSummary.BS:SetText(L.SALTI_BTotal)
			CSummary.BS:SetAnchor(TOPLEFT, CChars[numTrackedChars].name, BOTTOMLEFT, 0, 20)
			if SALTI.ASV.wvBank == 0 then CSummary.BW:SetText(pTC("ffff00", "--")) else CSummary.BW:SetText(pTC("ffff00", ZO_CurrencyControl_FormatCurrency(SALTI.ASV.wvBank, false))) end
			CSummary.BW:SetAnchor(TOPRIGHT, CChars[numTrackedChars].wv, BOTTOMRIGHT, 0, 20)
			if SALTI.ASV.apBank == 0 then CSummary.BA:SetText(pTC("2be023", "--")) else CSummary.BA:SetText(pTC("2be023", ZO_CurrencyControl_FormatCurrency(SALTI.ASV.apBank, false))) end
			CSummary.BA:SetAnchor(TOPRIGHT, CChars[numTrackedChars].ap, BOTTOMRIGHT, 0, 20)
			if SALTI.ASV.tvBank == 0 then CSummary.BT:SetText(pTC("60a7ff", "--")) else CSummary.BT:SetText(pTC("60a7ff", ZO_CurrencyControl_FormatCurrency(SALTI.ASV.tvBank, false))) end
			CSummary.BT:SetAnchor(TOPRIGHT, CChars[numTrackedChars].tv, BOTTOMRIGHT, 0, 20)
			if SALTI.ASV.gBank == 0 then CSummary.BG:SetText("--") else CSummary.BG:SetText(ZO_CurrencyControl_FormatCurrency(SALTI.ASV.gBank, false)) end
			CSummary.BG:SetAnchor(TOPRIGHT, CChars[numTrackedChars].gold, BOTTOMRIGHT, 0, 20)
			CSummary.TS:SetText(L.SALTI_ATotal)
			CSummary.TS:SetAnchor(TOPLEFT, CSummary.BS, BOTTOMLEFT, 0, 2)
			if SALTI.ASV.wvAccount == 0 then CSummary.TW:SetText(pTC("ffff00", "--")) else CSummary.TW:SetText(pTC("ffff00", ZO_CurrencyControl_FormatCurrency(SALTI.ASV.wvAccount, false))) end
			CSummary.TW:SetAnchor(TOPRIGHT, CSummary.BW, BOTTOMRIGHT, 0, 2)
			if SALTI.ASV.apAccount == 0 then CSummary.TA:SetText(pTC("2be023", "--")) else CSummary.TA:SetText(pTC("2be023", ZO_CurrencyControl_FormatCurrency(SALTI.ASV.apAccount, false))) end
			CSummary.TA:SetAnchor(TOPRIGHT, CSummary.BA, BOTTOMRIGHT, 0, 2)
			if SALTI.ASV.tvAccount == 0 then CSummary.TT:SetText(pTC("60a7ff", "--")) else CSummary.TT:SetText(pTC("60a7ff", ZO_CurrencyControl_FormatCurrency(SALTI.ASV.tvAccount, false))) end
			CSummary.TT:SetAnchor(TOPRIGHT, CSummary.BT, BOTTOMRIGHT, 0, 2)
			if SALTI.ASV.gAccount == 0 then CSummary.TG:SetText("--") else CSummary.TG:SetText(ZO_CurrencyControl_FormatCurrency(SALTI.ASV.gAccount, false)) end
			CSummary.TG:SetAnchor(TOPRIGHT, CSummary.BG, BOTTOMRIGHT, 0, 2)
			gHeight = SALTI_Gold:GetHeight() + (26 * numTrackedChars) + 17
		else
			CSummary.BS:SetText(L.SALTI_BTotal)
			CSummary.BS:SetAnchor(TOPLEFT, CHeader.HS, BOTTOMLEFT, 0, 20)
			if SALTI.ASV.wvBank == 0 then CSummary.BW:SetText(pTC("ffff00", "--")) else CSummary.BW:SetText(pTC("ffff00", ZO_CurrencyControl_FormatCurrency(SALTI.ASV.wvBank, false))) end
			CSummary.BW:SetAnchor(TOPRIGHT, CHeader.HW, BOTTOMRIGHT, 0, 20)
			if SALTI.ASV.apBank == 0 then CSummary.BA:SetText(pTC("2be023", "--")) else CSummary.BA:SetText(pTC("2be023", ZO_CurrencyControl_FormatCurrency(SALTI.ASV.apBank, false))) end
			CSummary.BA:SetAnchor(TOPRIGHT, CHeader.HA, BOTTOMRIGHT, 0, 20)
			if SALTI.ASV.tvBank == 0 then CSummary.BT:SetText(pTC("60a7ff", "--")) else CSummary.BT:SetText(pTC("60a7ff", ZO_CurrencyControl_FormatCurrency(SALTI.ASV.tvBank, false))) end
			CSummary.BT:SetAnchor(TOPRIGHT, CHeader.HT, BOTTOMRIGHT, 0, 20)
			CSummary.BG:SetText(ZO_CurrencyControl_FormatCurrency(SALTI.ASV.gBank, false))
			CSummary.BG:SetAnchor(TOPRIGHT, CHeader.HG, BOTTOMRIGHT, 0, 20)
			CSummary.TS:SetText(L.SALTI_ATotal)
			CSummary.TS:SetAnchor(TOPLEFT, CSummary.BS, BOTTOMLEFT, 0, 2)
			if SALTI.ASV.wvAccount == 0 then CSummary.TW:SetText(pTC("ffff00", "--")) else CSummary.TW:SetText(pTC("ffff00", ZO_CurrencyControl_FormatCurrency(SALTI.ASV.wvAccount, false))) end
			CSummary.TW:SetAnchor(TOPRIGHT, CSummary.BW, BOTTOMRIGHT, 0, 2)
			if SALTI.ASV.apAccount == 0 then CSummary.TA:SetText(pTC("2be023", "--")) else CSummary.TA:SetText(pTC("2be023", ZO_CurrencyControl_FormatCurrency(SALTI.ASV.apAccount, false))) end
			CSummary.TA:SetAnchor(TOPRIGHT, CSummary.BA, BOTTOMRIGHT, 0, 2)
			if SALTI.ASV.tvAccount == 0 then CSummary.TT:SetText(pTC("60a7ff", "--")) else CSummary.TT:SetText(pTC("60a7ff", ZO_CurrencyControl_FormatCurrency(SALTI.ASV.tvAccount, false))) end
			CSummary.TT:SetAnchor(TOPRIGHT, CSummary.BT, BOTTOMRIGHT, 0, 2)
			if SALTI.ASV.gAccount == 0 then CSummary.TG:SetText("--") else CSummary.TG:SetText(ZO_CurrencyControl_FormatCurrency(SALTI.ASV.gAccount, false)) end
			CSummary.TG:SetAnchor(TOPRIGHT, CSummary.BG, BOTTOMRIGHT, 0, 2)
		end

		SALTI_Gold:SetHeight(gHeight)

		CSummary.AS:SetHidden(true)
		CSummary.TC:SetHidden(true)
		CSummary.ET:SetHidden(true)
		CSummary.OT:SetHidden(true)
		CSummary.CU:SetHidden(true)
		CSummary.CG:SetHidden(true)
		CSummary.CR:SetHidden(true)
		CSummary.AF:SetHidden(true)
		CSummary.IF:SetHidden(true)

		if SALTI.ASV.aCShow then -- Show the global currency summary.
			gHeight = gHeight + 54
			SALTI_Gold:SetHeight(gHeight)

			CDiv.DIV3:ClearAnchors()
			CDiv.DIV3:SetAnchor(TOPLEFT, CSummary.TS, BOTTOMLEFT, dAlign, 10)
			CDiv.DIV3:SetAnchor(TOPRIGHT, CSummary.TW, BOTTOMRIGHT, 0, 10)
			CDiv.DIV3:SetHidden(false)

			CSummary.AS:ClearAnchors()
			CSummary.TC:ClearAnchors()
			CSummary.ET:ClearAnchors()
			CSummary.OT:ClearAnchors()
			CSummary.CU:ClearAnchors()
			CSummary.CG:ClearAnchors()
			CSummary.CR:ClearAnchors()
			CSummary.AF:ClearAnchors()
			CSummary.IF:ClearAnchors()

			local gPadding = SALTI.ASV.gPadding * -1
		-- Configure "Account Totals" label
			CSummary.AS:SetText(L.SALTI_CGlobal)
			CSummary.AS:SetAnchor(TOPLEFT, CSummary.TS, BOTTOMLEFT, 0, 20)

		-- Configure Crown Gems
			CSummary.CG:SetText(ZO_CurrencyControl_FormatCurrency(SALTI.ASV.aCGems, false) .. ' '  .. L.SALTI_CGEMS)
			CSummary.CG:SetAnchor(TOPRIGHT, CSummary.TW, BOTTOMRIGHT, 0, 20)
		-- Configure Seals of Endeavor
			CSummary.SE:SetText(ZO_CurrencyControl_FormatCurrency(SALTI.ASV.sEndeavor, false) .. ' '  .. L.SALTI_ESEALS)
			CSummary.SE:SetAnchor(RIGHT, CSummary.CG, LEFT, gPadding, 0)
		-- Configure Crowns
			CSummary.CR:SetText(ZO_CurrencyControl_FormatCurrency(SALTI.ASV.aCrowns, false) .. ' '  .. L.SALTI_CROWNS)
			CSummary.CR:SetAnchor(RIGHT, CSummary.SE, LEFT, gPadding, 0)

		-- Configure Transmute Crystals
			CSummary.TC:SetText(ZO_CurrencyControl_FormatCurrency(SALTI.ASV.aTCrystals, false) .. '/' .. tostring(GetMaxPossibleCurrency(CURT_CHAOTIC_CREATIA, CURRENCY_LOCATION_ACCOUNT)) .. ' ' .. L.SALTI_TGEMS)
			CSummary.TC:SetAnchor(TOPRIGHT, CSummary.TW, BOTTOMRIGHT, 0, 46)
		-- Configure Event Tickets
			CSummary.ET:SetText(ZO_CurrencyControl_FormatCurrency(SALTI.ASV.aETickets, false) .. '/' .. tostring(GetMaxPossibleCurrency(CURT_EVENT_TICKETS, CURRENCY_LOCATION_ACCOUNT)) .. ' ' .. L.SALTI_ETICKETS)
			CSummary.ET:SetAnchor(RIGHT, CSummary.TC, LEFT, gPadding, 0)
		-- Configure Outfit Tokens
			CSummary.OT:SetText(ZO_CurrencyControl_FormatCurrency(SALTI.ASV.aOutfit, false) .. ' '  .. L.SALTI_OUTFIT)
			CSummary.OT:SetAnchor(RIGHT, CSummary.ET, LEFT, gPadding, 0)
		-- Configure Undaunted Keys
			CSummary.CU:SetText(ZO_CurrencyControl_FormatCurrency(SALTI.ASV.aUKeys, false) .. ' '  .. L.SALTI_UKEYS)
			CSummary.CU:SetAnchor(RIGHT, CSummary.OT, LEFT, gPadding, 0)
		-- Configure Imperial Fragments
			CSummary.IF:SetText(ZO_CurrencyControl_FormatCurrency(SALTI.ASV.impFrags, false) .. ' '  .. L.SALTI_IFRAGMENTS)
			CSummary.IF:SetAnchor(RIGHT, CSummary.CU, LEFT, gPadding, 0)
		-- Configure Archival Fortunes
			CSummary.AF:SetText(ZO_CurrencyControl_FormatCurrency(SALTI.ASV.aFortunes, false) .. ' '  .. L.SALTI_AFORTUNES)
			CSummary.AF:SetAnchor(RIGHT, CSummary.IF, LEFT, gPadding, 0)

			CSummary.AS:SetHidden(false)
			CSummary.TC:SetHidden(false)
			CSummary.ET:SetHidden(false)
			CSummary.OT:SetHidden(false)
			CSummary.CU:SetHidden(false)
			CSummary.CG:SetHidden(false)
			CSummary.CR:SetHidden(false)
			CSummary.AF:SetHidden(false)
			CSummary.IF:SetHidden(false)
		end

		if SALTI.ASV.gGBShow then -- Show the guild bank currency summary.
			local gAnchor = (SALTI.ASV.aCShow == true) and 40 or 0
			if numTrackedGuilds > 0 then
				local tGuilds = GetSorted(SALTI.ASV.gVals)
				CDiv.DIV4:ClearAnchors()
				CDiv.DIV4:SetAnchor(TOPLEFT, CSummary.TS, BOTTOMLEFT, dAlign, 10 + gAnchor)
				CDiv.DIV4:SetAnchor(TOPRIGHT, CSummary.TW, BOTTOMRIGHT, 0, 10 + gAnchor)
				CDiv.DIV4:SetHidden(false)

				for i = 1, numTrackedGuilds do
					CGuilds[i].name:ClearAnchors()
					CGuilds[i].wv:ClearAnchors()
					CGuilds[i].ap:ClearAnchors()
					CGuilds[i].tv:ClearAnchors()
					CGuilds[i].gold:ClearAnchors()
					CGuilds[i].name:SetText(tGuilds[i])
					CGuilds[i].ap:SetText("|c2be023--|r")
					CGuilds[i].tv:SetText("|c60a7ff--|r")
					CGuilds[i].wv:SetText("|cffff00--|r")

					if SALTI.ASV.gVals[tGuilds[i]].money == 0 then CGuilds[i].gold:SetText("--") else CGuilds[i].gold:SetText(ZO_CurrencyControl_FormatCurrency(SALTI.ASV.gVals[tGuilds[i]].money, false)) end
					if i == 1 then
						CGuilds[i].name:SetAnchor(TOPLEFT, CSummary.TS, BOTTOMLEFT, 0, 20 + gAnchor)
						CGuilds[i].wv:SetAnchor(TOPRIGHT, CSummary.TW, BOTTOMRIGHT, 0, 20 + gAnchor)
						CGuilds[i].ap:SetAnchor(TOPRIGHT, CSummary.TA, BOTTOMRIGHT, 0, 20 + gAnchor)
						CGuilds[i].tv:SetAnchor(TOPRIGHT, CSummary.TT, BOTTOMRIGHT, 0, 20 + gAnchor)
						CGuilds[i].gold:SetAnchor(TOPRIGHT, CSummary.TG, BOTTOMRIGHT, 0, 20 + gAnchor)
					else
						CGuilds[i].name:SetAnchor(TOPLEFT, CGuilds[i-1].name, BOTTOMLEFT, 0, 2)
						CGuilds[i].wv:SetAnchor(TOPRIGHT, CGuilds[i-1].wv, BOTTOMRIGHT, 0, 2)
						CGuilds[i].ap:SetAnchor(TOPRIGHT, CGuilds[i-1].ap, BOTTOMRIGHT, 0, 2)
						CGuilds[i].tv:SetAnchor(TOPRIGHT, CGuilds[i-1].tv, BOTTOMRIGHT, 0, 2)
						CGuilds[i].gold:SetAnchor(TOPRIGHT, CGuilds[i-1].gold, BOTTOMRIGHT, 0, 2)
					end
					CGuilds[i].name:SetHidden(false)
					CGuilds[i].wv:SetHidden(false)
					CGuilds[i].ap:SetHidden(false)
					CGuilds[i].tv:SetHidden(false)
					CGuilds[i].gold:SetHidden(false)
				end

				gHeight = gHeight + (26 * numTrackedGuilds) + 17
				SALTI_Gold:SetHeight(gHeight)
			end
		end

		if control ~= nil then
			SALTI_Gold:ClearAnchors()
			SALTI_Gold:SetAnchor(BOTTOMRIGHT, control, TOPRIGHT, -3, -10)
		else
			RestoreGoldPosition()
		end
		SALTI_Gold:SetHidden(false)
	elseif opt == 2 then
		SALTI_Gold:SetHidden(true)
		for i = 1, #CControls do
			CControls[i]:SetHidden(true)
		end
	end
end

------------------------------------------------------------------------------------------------------------------------------------
-- Maintenance functions
------------------------------------------------------------------------------------------------------------------------------------
local function ResetGBRBuffer()
	GBRBuffer = 0
end

local function GBMoneyChanged(eventCode, newBankedMoney, oldBankedMoney) -- Update guild bank gold totals when event occurs
	local gName = GetGuildName(GetSelectedGuildBankId())
	if not SALTI.ASV.gVals[gName] then
		local tVal = {money = newBankedMoney}
		SALTI.ASV.gVals[gName] = tVal
	else
		SALTI.ASV.gVals[gName].money = newBankedMoney
	end
end

local function OnGuildBankReady() -- Update guild bank gold totals when event occurs
	if GBRBuffer == 0 then
		local gName = GetGuildName(GetSelectedGuildBankId())
		if not SALTI.ASV.gVals[gName] then
			local tVal = {money = GetGuildBankedCurrencyAmount(CURT_MONEY)}
			SALTI.ASV.gVals[gName] = tVal
		else
			SALTI.ASV.gVals[gName].money = GetGuildBankedCurrencyAmount(CURT_MONEY)
		end
		GBRBuffer = 1
		zo_callLater(ResetGBRBuffer, 500)
	end
end

local function OnLeftGuild(eventCode, guildId, guildName) -- Delete guild data when leaving
	SALTI.ASV.gVals[guildName] = nil
end

local function OnMoveStop() -- Saves independent movable window location
	SALTI.ASV.xpos = SALTI_Gold:GetLeft()
	SALTI.ASV.ypos = SALTI_Gold:GetTop()
end

local function ShowGold() -- Show/hide the independent movable window
	local control = GetControl('SALTI_Gold')
	if ( control:IsHidden() ) then
		--SCENE_MANAGER:ToggleTopLevel(SALTI_Gold)
		MoneyTooltip(nil, 1)
	else
		--SCENE_MANAGER:ToggleTopLevel(SALTI_Gold)
		MoneyTooltip(nil, 2)
	end
end

function SALTI:CheckTracking(opt) -- Updates character and guild totals on demand
	if opt == 1 then
		local tSGuilds = GetSorted(SALTI.ASV.gVals)
		local trackChar = SALTI.SV.trackChar
		local tCGuilds = {}

		if trackChar and trackChar == true then
			local pclassID = GetUnitClassId("player")
			local pallianceID = GetUnitAlliance("player")
			SALTI.SV.cVals.class = pclassID
			SALTI.SV.cVals.alliance = pallianceID
		end
		MoneyUpdate()

		for i = 1, MAX_GUILDS do
			local gName = GetGuildName(GetGuildId(i))
			if gName ~= "" then
				tCGuilds[#tCGuilds + 1] = gName
			end
		end
		for i = 1, #tSGuilds do
			if not pC(tCGuilds, tSGuilds[i]) then
				SALTI.ASV.gVals[tSGuilds[i]] = nil
			end
		end
	elseif opt == 10 then
		ShowGold()
	elseif opt == 11 then
		OnMoveStop()
	end
end

------------------------------------------------------------------------------------------------------------------------------------
-- Set up the options panel in Addon Settings
------------------------------------------------------------------------------------------------------------------------------------
local function CreateSettingsWindow()
	local sChar
	local LAM = LibAddonMenu2

	local panelData = {
		type					= "panel",
		name					= L.SALTI_Title,
		displayName				= ZO_HIGHLIGHT_TEXT:Colorize(L.SALTI_PTitle),
		author					= pTC("66ccff", "Phinix"),
		version					= version,
		registerForRefresh		= true,
		registerForDefaults		= true,
	}

	local optionsData = {

	{
		type = "header",
		name = L.SALTI_GOpts,
	},
	{
			type			= "checkbox",
			name			= L.SALTI_SACIcon,
			tooltip			= L.SALTI_SACIconD,
			getFunc			= function() return SALTI.ASV.iACShow end,
			setFunc			= function(value) SALTI.ASV.iACShow = value end,
			width			= "full",
			default			= SALTI.aOpts.iACShow,
	},
	{
			type			= "checkbox",
			name			= L.SALTI_ALPHAN,
			tooltip			= L.SALTI_ALPHAND,
			getFunc			= function() return SALTI.ASV.sortAlpha end,
			setFunc			= function(value) SALTI.ASV.sortAlpha = value CChars = GetAccountCharacters() end,
			width			= "full",
			default			= SALTI.aOpts.sortAlpha,
	},
	{
			type			= "checkbox",
			name			= L.SALTI_SGC,
			tooltip			= L.SALTI_SGCD,
			getFunc			= function() return SALTI.ASV.aCShow end,
			setFunc			= function(value) SALTI.ASV.aCShow = value end,
			width			= "full",
			default			= SALTI.aOpts.aCShow,
	},
	{
			type			= "slider",
			name			= L.SALTI_GCS,
			tooltip			= L.SALTI_GCSD,
			min				= 8,
			max				= 28,
			step			= 4,
			
			getFunc			= function() return SALTI.ASV.gPadding end,
			setFunc			= function(value) SALTI.ASV.gPadding = value end,
			width			= "full",
			default			= SALTI.aOpts.gPadding,
			disabled		= function() return not SALTI.ASV.aCShow end,
	},
	{
			type			= "checkbox",
			name			= L.SALTI_SGBGold,
			tooltip			= L.SALTI_SGBGoldD,
			getFunc			= function() return SALTI.ASV.gGBShow end,
			setFunc			= function(value) SALTI.ASV.gGBShow = value end,
			width			= "full",
			default			= SALTI.aOpts.gGBShow,
	},
	{
			type			= "checkbox",
			name			= L.SALTI_IWPos,
			tooltip			= L.SALTI_IWPosD,
			getFunc			= function() return SALTI.ASV.tIWPos end,
			setFunc			= function(value) SALTI.ASV.tIWPos = value end,
			width			= "full",
			default			= SALTI.aOpts.tIWPos,
	},

	{
		type = "header",
		name = L.SALTI_COpts,
	},
	{
			type			= "checkbox",
			name			= L.SALTI_CCTrack,
			tooltip			= L.SALTI_CCTrackD,
			getFunc			= function() return SALTI.SV.trackChar end,
			setFunc			= function(value)
								SALTI.SV.trackChar = value
								CChars = GetAccountCharacters()
							end,
			default			= SALTI.cOpts.trackChar,
	},
	{
			type			= 'dropdown',
			name			= L.SALTI_DCChar,
			tooltip			= '',
			choices			= charNamesOPT,
	--		sort			= "name-up",
			getFunc			= function()
								if #charNamesOPT > 0 then
									sChar = charNamesOPT[1]
									return sChar
								end
							end,
			setFunc			= function(selected)
								sChar = selected
							end,
			default			= "",
			disabled		= function() return #charNamesOPT < 1 end,
			reference		= "SALTICharsDropdown",
	},
	{
			type			= "button",
			name			= L.SALTI_DELETE,
			tooltip			= L.SALTI_CDELD,
			width			= "full",
			func			= function()
								if sChar ~= nil then
									local sID = pGK(charIDName, sChar)
									if SALTIVars[worldName][accountName][sID] then
										SALTIVars[worldName][accountName][sID].CharacterSettings.trackChar = false
									end
									CChars = GetAccountCharacters()
									SALTICharsDropdown:UpdateChoices(charNamesOPT)
									LAM.util.RequestRefreshIfNeeded(SALTICharsDropdown)
								end

							end,
	--		disabled		= function() return sChar == nil end,
	},
	}

	LAM:RegisterAddonPanel("SALTI_Panel", panelData)
	LAM:RegisterOptionControls("SALTI_Panel", optionsData)
end

------------------------------------------------------------------------------------------------------------------------------------
-- Init functions
------------------------------------------------------------------------------------------------------------------------------------
local function HookMoney() -- Hooks and replaces the default currency tooltip
	local tNames = {
		["ZO_PlayerInventoryInfoBarMoney"] = true,
		["ZO_PlayerInventoryInfoBarAltMoney"] = true,
		["ZO_PlayerBankInfoBarMoney"] = true,
		["ZO_PlayerBankInfoBarAltMoney"] = true,
		["ZO_GuildBankInfoBarMoney"] = true,
		["ZO_TradingHouseSearchControlsMoney"] = true,
		["ZO_InventoryWalletInfoBarMoney"] = true,
	}

	ZO_PreHook("ZO_CurrencyTemplate_OnMouseEnter", function(control)
		local tName = control:GetName()

	--	d(control:GetTextForLines())

		if not tNames[tName] then
		--	d(tName)
		--	Zgoo.CommandHandler(control)
		else
			if SALTI.ASV.tIWPos then
				ShowGold()
			else
				MoneyTooltip(control, 1)
			end
			return true
		end
	end)
	SecurePostHook("ZO_CurrencyTemplate_OnMouseExit", function(control)
		MoneyTooltip(nil, 2)
	end)
end

local function OnAddonLoaded(eventCode, addonName)
	if addonName ~= 'SALTI' then return end
	EVENT_MANAGER:UnregisterForEvent('SALTI', EVENT_ADD_ON_LOADED)
--	SCENE_MANAGER:RegisterTopLevel(SALTI_Gold, false)

	worldName = GetWorldName()
	accountName = GetDisplayName()
	currentID = tostring(GetCurrentCharacterId())

	if SALTIVars ~= nil then
		if SALTIVars.Default ~= nil then -- remove the old non-Megaserver specific variables table
			d("****************************************************")
			d(L.SALTI_DBUpdate)
			d("****************************************************")
			SALTIVars.Default = nil
		end
	end
	SALTI.SV = ZO_SavedVars:NewCharacterIdSettings('SALTIVars', 1.2, 'CharacterSettings', SALTI.cOpts, worldName)
	SALTI.ASV = ZO_SavedVars:NewAccountWide('SALTIVars', 1.2, 'AccountSettings', SALTI.aOpts, worldName)

	ZO_CreateStringId('SI_BINDING_NAME_TOGGLE_SALTI_GOLD', 'Toggle Currency Summary')

	-- build the list of controls based on current account status
	CHeader, CSummary, CDiv, CGuilds, CControls = SALTI:CurrencyControls()
	CChars = GetAccountCharacters()

	CreateSettingsWindow()
	SALTI:CheckTracking(1)
	HookMoney()
end

SLASH_COMMANDS['/salti'] = ShowGold
EVENT_MANAGER:RegisterForEvent('SALTI', EVENT_ADD_ON_LOADED, OnAddonLoaded)
EVENT_MANAGER:RegisterForEvent('SALTI', EVENT_GUILD_BANK_ITEMS_READY, OnGuildBankReady)
EVENT_MANAGER:RegisterForEvent('SALTI', EVENT_GUILD_SELF_LEFT_GUILD, OnLeftGuild)
EVENT_MANAGER:RegisterForEvent('SALTI', EVENT_GUILD_BANKED_MONEY_UPDATE, GBMoneyChanged)
EVENT_MANAGER:RegisterForEvent('SALTI', EVENT_CURRENCY_UPDATE, MoneyUpdate)
EVENT_MANAGER:RegisterForEvent('SALTI', EVENT_MAIL_TAKE_ATTACHED_ITEM_SUCCESS, MoneyUpdate)
