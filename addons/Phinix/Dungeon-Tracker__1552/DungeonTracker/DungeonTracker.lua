-------------------------------------------------------------------------------
-- Dungeon Tracker
-------------------------------------------------------------------------------
--[[
-- Copyright (c) 2015-2025 James A. Keene (Phinix) All rights reserved.
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

local DTAddon = _G['DTAddon']
local L = DTAddon.Strings
local version = '1.48'
local labelShown
local DB

-- quest queue variables
local DTQuests = true
local DTQuestNC = {}
local DTQLabel
local DTQToggle
local DTQButton

-- variable tables
local cOpts = {} -- text strings for dungeon quest completion character list format
local mOpts = {} -- text strings for dungeon quest completion display mode setting

local function TColor(color, text) -- Wraps the color tags with the passed color around the given text.
	local cText = "|c"..tostring(color)..tostring(text).."|r"
	return cText
end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Adds completion information to dungeon, trial, and delve tooltips
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function ModeIcons(mNode)
	local tH = (DTAddon.aOpts.sDungeonHM == true and DB.dungeons[mNode] ~= nil and DB.dungeons[mNode].hMode == true) and "|t16:16:/DungeonTracker/bin/a-hard.dds|t" or ""
	local tT = (DTAddon.aOpts.sDungeonTT == true and DB.dungeons[mNode] ~= nil and DB.dungeons[mNode].tMode == true) and "|t16:16:/DungeonTracker/bin/a-time.dds|t" or ""
	local tD = (DTAddon.aOpts.sDungeonND == true and DB.dungeons[mNode] ~= nil and DB.dungeons[mNode].nDeath == true) and "|t16:16:/DungeonTracker/bin/a-nodeath.dds|t" or ""
	return tH, tT, tD
end

local function GetColorSortedNames(qt)
	local cID = GetCurrentCharacterId()
	local cHighlight = DTAddon.ASV.highlightCC
	local kSformat = DTAddon.ASV.kSformat
	local aNames = {}
	local tNames = {}
	local vNames = {}

	for i = 1, GetNumCharacters() do
		local charName, _, _, _, _, _, charID = GetCharacterInfo(i)
		local fName = zo_strformat(SI_UNIT_NAME, charName)
		local tagName

		if DTAddon.ASV.charEnabled[charID] == nil or DTAddon.ASV.charEnabled[charID] == true then
			if kSformat == 1 then
				if qt[charID] ~= nil then
					if qt[charID] == true then
						tagName = tostring(fName) .. "1"
					elseif qt[charID] == false then
						tagName = tostring(fName) .. "2"
					end
				else
					tagName = tostring(fName) .. "2"
				end
				table.insert(aNames, #aNames + 1, tagName) 
				vNames[tagName] = (charID == cID) and true or false
			elseif kSformat == 2 then
				if qt[charID] ~= nil then
					if qt[charID] == true then
						tagName = tostring(fName) .. "1"
						table.insert(aNames, #aNames + 1, tagName) 
						vNames[tagName] = (charID == cID) and true or false
					end
				end
			elseif kSformat == 3 then
				if qt[charID] ~= nil then
					if qt[charID] == false then
						tagName = tostring(fName) .. "2"
						table.insert(aNames, #aNames + 1, tagName) 
						vNames[tagName] = (charID == cID) and true or false
					end
				else
					tagName = tostring(fName) .. "2"
					table.insert(aNames, #aNames + 1, tagName) 
					vNames[tagName] = (charID == cID) and true or false
				end
			end
		end
	end
	if DTAddon.ASV.sortAlpha then table.sort(aNames) end

	for k, n in ipairs(aNames) do
		local colorName = ""
		if string.find(n, "1") then
			colorName = TColor(DTAddon.ASV.cColorS,tostring(n):gsub("1",''))
			if (vNames[n]) and (cHighlight) then
				colorName = TColor(DTAddon.ASV.vColorS,"*"..tostring(n):gsub("1",''))
			end
			tNames[#tNames + 1] = colorName
		elseif string.find(n, "2") then
			colorName = TColor(DTAddon.ASV.iColorS,tostring(n):gsub("2",''))
			if (vNames[n]) and (cHighlight) then
				colorName = TColor(DTAddon.ASV.iColorS,"*"..tostring(n):gsub("2",''))
			end
			tNames[#tNames + 1] = colorName
		end
	end
	return tNames
end

local function CreateLabelControl(tier, ID, parent)
	tier[ID].control = WINDOW_MANAGER:CreateControl(tostring(ID) .. 'DTLabelControl', parent, CT_LABEL)
	tier[ID].control:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
	tier[ID].control:SetFont("ZoFontWinH5")
	tier[ID].control:SetDrawTier(DT_HIGH)
end

local function ModifyDungeonTooltip(pin, pType, pNode, pIndex)

	if pType == 1 then -- Add group dungeon tooltip info.
		local vII = DTAddon.DungeonIndex[pNode].vII
		local mode1 = (vII == 0) and 0 or (vII < pNode) and vII or pNode
		local mode2 = (vII == 0) and 0 or (vII > pNode) and vII or pNode
		local countshown = 0

		if (DTAddon.ASV.sDungeonNMap) or (DTAddon.ASV.sDungeonVMap) or (DTAddon.ASV.sDungeonFC) then
			InformationTooltip:AddLine(DTAddon.DungeonIndex[pNode].icon, "ZoFontGameOutline")
			ZO_Tooltip_AddDivider(InformationTooltip)
		end

		if DTAddon.ASV.sDungeonNMap == true then
			if vII ~= 0 then
				if DB.dungeons[mode1] and DB.dungeons[mode1].nComplete == true then
					InformationTooltip:AddLine(TColor("ffffff",L.DTAddon_CNormI)..TColor(DTAddon.ASV.cColorS,L.DTAddon_True), "ZoFontGameOutline")
					countshown = countshown + 1
				elseif DB.dungeons[mode1] and DB.dungeons[mode1].nComplete == false then
					InformationTooltip:AddLine(TColor("ffffff",L.DTAddon_CNormI)..TColor(DTAddon.ASV.iColorS,L.DTAddon_False), "ZoFontGameOutline")
					countshown = countshown + 1
				end
				if DB.dungeons[mode2] and DB.dungeons[mode2].nComplete == true then
					InformationTooltip:AddLine(TColor("ffffff",L.DTAddon_CNormII)..TColor(DTAddon.ASV.cColorS,L.DTAddon_True), "ZoFontGameOutline")
					countshown = countshown + 1
				elseif DB.dungeons[mode2] and DB.dungeons[mode2].nComplete == false then
					InformationTooltip:AddLine(TColor("ffffff",L.DTAddon_CNormII)..TColor(DTAddon.ASV.iColorS,L.DTAddon_False), "ZoFontGameOutline")
					countshown = countshown + 1
				end
			else
				if DB.dungeons[pNode] and DB.dungeons[pNode].nComplete == true then
					InformationTooltip:AddLine(TColor("ffffff",L.DTAddon_CNorm)..TColor(DTAddon.ASV.cColorS,L.DTAddon_True), "ZoFontGameOutline")
					countshown = countshown + 1
				else
					InformationTooltip:AddLine(TColor("ffffff",L.DTAddon_CNorm)..TColor(DTAddon.ASV.iColorS,L.DTAddon_False), "ZoFontGameOutline")
					countshown = countshown + 1
				end
			end
		end
		if DTAddon.ASV.sDungeonVMap == true then
			local hMode, tMode, nDeath
			if vII ~= 0 then
				if DB.dungeons[mode1] and DB.dungeons[mode1].vComplete == true then
					hMode, tMode, nDeath = ModeIcons(mode1)
					InformationTooltip:AddLine(TColor("ffffff",L.DTAddon_CVetI)..TColor(DTAddon.ASV.cColorS,L.DTAddon_True)..hMode..tMode..nDeath, "ZoFontGameOutline")
					countshown = countshown + 1
				else
					InformationTooltip:AddLine(TColor("ffffff",L.DTAddon_CVetI)..TColor(DTAddon.ASV.iColorS,L.DTAddon_False), "ZoFontGameOutline")
					countshown = countshown + 1
				end
				if DB.dungeons[mode2] and DB.dungeons[mode2].vComplete == true then
					hMode, tMode, nDeath = ModeIcons(mode2)
					InformationTooltip:AddLine(TColor("ffffff",L.DTAddon_CVetII)..TColor(DTAddon.ASV.cColorS,L.DTAddon_True)..hMode..tMode..nDeath, "ZoFontGameOutline")
					countshown = countshown + 1
				else
					InformationTooltip:AddLine(TColor("ffffff",L.DTAddon_CVetII)..TColor(DTAddon.ASV.iColorS,L.DTAddon_False), "ZoFontGameOutline")
					countshown = countshown + 1
				end
			else
				if DB.dungeons[pNode] and DB.dungeons[pNode].vComplete == true then
					hMode, tMode, nDeath = ModeIcons(pNode)
					InformationTooltip:AddLine(TColor("ffffff",L.DTAddon_CVet)..TColor(DTAddon.ASV.cColorS,L.DTAddon_True)..hMode..tMode..nDeath, "ZoFontGameOutline")
					countshown = countshown + 1
				else
					InformationTooltip:AddLine(TColor("ffffff",L.DTAddon_CVet)..TColor(DTAddon.ASV.iColorS,L.DTAddon_False), "ZoFontGameOutline")
					countshown = countshown + 1
				end
			end
		end
		if DTAddon.ASV.kQuestMap == 1 then
			local nString = ""
			if vII ~= 0 then
				if DB.dungeons[mode1] and DTAddon.DungeonIndex[mode1].questID ~= 0 then
					local sTable = GetColorSortedNames(DB.dungeons[mode1].questC)
					nString = ""
					if #sTable < 1 then
						nString = TColor(DTAddon.ASV.iColorS,L.DTAddon_None)
					else
						for k, v in ipairs(sTable) do
							local nSep = (k ~= #sTable) and ", " or ""
							nString = nString .. v .. nSep
						end
					end
					InformationTooltip:AddLine(TColor("ffffff",L.DTAddon_QCompI)..nString, "ZoFontGameOutline")
					countshown = countshown + 1
				end
				if DB.dungeons[mode2] and DTAddon.DungeonIndex[mode2].questID ~= 0 then
					local sTable = GetColorSortedNames(DB.dungeons[mode2].questC)
					nString = ""
					if #sTable < 1 then
						nString = TColor(DTAddon.ASV.iColorS,L.DTAddon_None)
					else
						for k, v in ipairs(sTable) do
							local nSep = (k ~= #sTable) and ", " or ""
							nString = nString .. v .. nSep
						end
					end
					InformationTooltip:AddLine(TColor("ffffff",L.DTAddon_QCompII)..nString, "ZoFontGameOutline")
					countshown = countshown + 1
				end
			else
				if DB.dungeons[pNode] and DTAddon.DungeonIndex[pNode].questID ~= 0 then
					local sTable = GetColorSortedNames(DB.dungeons[pNode].questC)
					nString = ""
					if #sTable < 1 then
						nString = TColor(DTAddon.ASV.iColorS,L.DTAddon_None)
					else
						for k, v in ipairs(sTable) do
							local nSep = (k ~= #sTable) and ", " or ""
							nString = nString .. v .. nSep
						end
					end
					InformationTooltip:AddLine(TColor("ffffff",L.DTAddon_QComp)..nString, "ZoFontGameOutline")
					countshown = countshown + 1
				end
			end
		elseif DTAddon.ASV.kQuestMap == 2 then
			if vII ~= 0 then
				if DB.dungeons[mode1] and DTAddon.DungeonIndex[mode1].questID ~= 0 then
					local questName, questType = GetCompletedQuestInfo(DTAddon.DungeonIndex[mode1].questID)
					if questName ~= "" then
						InformationTooltip:AddLine("|t16:16:/DungeonTracker/bin/cachievement.dds|t "..TColor("00ffff",L.DTAddon_QCompI)..TColor(DTAddon.ASV.cColorS,L.DTAddon_True), "ZoFontGameOutline")
						countshown = countshown + 1
					else
						InformationTooltip:AddLine("|t16:16:/DungeonTracker/bin/cachievement.dds|t "..TColor("00ffff",L.DTAddon_QCompI)..TColor(DTAddon.ASV.iColorS,L.DTAddon_False), "ZoFontGameOutline")
						countshown = countshown + 1
					end
				end
				if DB.dungeons[mode2] and DTAddon.DungeonIndex[mode2].questID ~= 0 then
					local questName, questType = GetCompletedQuestInfo(DTAddon.DungeonIndex[mode2].questID)
					if questName ~= "" then
						InformationTooltip:AddLine("|t16:16:/DungeonTracker/bin/cachievement.dds|t "..TColor("00ffff",L.DTAddon_QCompII)..TColor(DTAddon.ASV.cColorS,L.DTAddon_True), "ZoFontGameOutline")
						countshown = countshown + 1
					else
						InformationTooltip:AddLine("|t16:16:/DungeonTracker/bin/cachievement.dds|t "..TColor("00ffff",L.DTAddon_QCompII)..TColor(DTAddon.ASV.iColorS,L.DTAddon_False), "ZoFontGameOutline")
						countshown = countshown + 1
					end
				end
			else
				if DB.dungeons[pNode] and DTAddon.DungeonIndex[pNode].questID ~= 0 then
					local questName, questType = GetCompletedQuestInfo(DTAddon.DungeonIndex[pNode].questID)
					if questName ~= "" then
						InformationTooltip:AddLine("|t16:16:/DungeonTracker/bin/cachievement.dds|t "..TColor("00ffff",L.DTAddon_QComp)..TColor(DTAddon.ASV.cColorS,L.DTAddon_True), "ZoFontGameOutline")
						countshown = countshown + 1
					else
						InformationTooltip:AddLine("|t16:16:/DungeonTracker/bin/cachievement.dds|t "..TColor("00ffff",L.DTAddon_QComp)..TColor(DTAddon.ASV.iColorS,L.DTAddon_False), "ZoFontGameOutline")
						countshown = countshown + 1
					end
				end
			end
		end
		if DTAddon.ASV.sDungeonFC == true then
			local fP = DTAddon.DungeonIndex[pNode].fP
			if fP ~= 0 then
				local label = tostring(GetAchievementInfo(fP))
				label = zo_strformat("<<t:1>>",label)
				label = label .. ": "
				local numCriteria = GetAchievementNumCriteria(fP)
				local completed = 0
				for i = 1, numCriteria do
					local _, numCompleted, _ = GetAchievementCriterion(fP, i)
					if numCompleted == 1 then 
						completed = completed + 1
					end
				end
				-- Colorize achievement title by faction.
				if fP == 1073 then label = TColor("e05a4c",label)
				elseif fP == 1075 then label = TColor("fff578",label)
				elseif fP == 1074 then label = TColor("6a91b6",label) end
			--	label = DTAddon.DungeonIndex[pNode].icon .. label .. tostring(completed) .. "/" .. tostring(numCriteria)
				label = label .. tostring(completed) .. "/" .. tostring(numCriteria)
				InformationTooltip:AddLine(label, "ZoFontGameOutline")
				countshown = countshown + 1
			end
		end
		if countshown > 0 then
			ZO_Tooltip_AddDivider(InformationTooltip)
		end
	elseif pType == 2 then -- Add group delve tooltip info.
		local poiName = zo_strformat("<<t:1>>",GetPOIInfo(pNode, pIndex))
		local poiKey = tostring(pNode).."-"..tostring(pIndex)
		local DI = DTAddon.DelveIndex

		InformationTooltip:AddLine(poiName, "ZoFontGameOutline")
		ZO_Tooltip_AddDivider(InformationTooltip)

		if DTAddon.ASV.sDelveGC == true then
			local cDone = false
			local gA = {GetAchievementInfo(DI[poiKey].gA)}
			if gA[5] == true then
				cDone = true
			end
			if (cDone) then
				InformationTooltip:AddLine("|t16:16:/DungeonTracker/bin/cachievement.dds|t "..TColor("00ffff",L.DTAddon_CGChal)..TColor("ffffff",": ")..TColor(DTAddon.ASV.cColorS,L.DTAddon_True), "ZoFontGameOutline")
			else
				InformationTooltip:AddLine("|t16:16:/DungeonTracker/bin/cachievement.dds|t "..TColor("00ffff",L.DTAddon_CGChal)..TColor("ffffff",": ")..TColor(DTAddon.ASV.iColorS,L.DTAddon_False), "ZoFontGameOutline")
			end
		end
		if DTAddon.ASV.sDelveBC == true then
			local cDone = false
			local bA = {GetAchievementInfo(DI[poiKey].bA)}
			if bA[5] == true then
				cDone = true
			end
			if (cDone) then
				InformationTooltip:AddLine(TColor("ffffff",L.DTAddon_CDBoss)..TColor(DTAddon.ASV.cColorS,L.DTAddon_True), "ZoFontGameOutline")
			else
				InformationTooltip:AddLine(TColor("ffffff",L.DTAddon_CDBoss)..TColor(DTAddon.ASV.iColorS,L.DTAddon_False), "ZoFontGameOutline")
			end
		end
		if DTAddon.ASV.sDelveFC == true then
			local fP = DI[poiKey].fP
			if fP ~= 0 then
				local label = tostring(GetAchievementInfo(fP))
				label = zo_strformat("<<t:1>>",label)
				label = label .. ": "
				local numCriteria = GetAchievementNumCriteria(fP)
				local completed = 0
				for i = 1, numCriteria do
					local _, numCompleted, _ = GetAchievementCriterion(fP, i)
					if numCompleted == 1 then 
						completed = completed + 1
					end
				end
				-- Colorize achievement title by faction.
				if fP == 1068 then label = TColor("e05a4c",label)
				elseif fP == 1069 then label = TColor("fff578",label)
				elseif fP == 1070 then label = TColor("6a91b6",label) end
				label = DI[poiKey].icon..label .. tostring(completed) .. "/" .. tostring(numCriteria)
				InformationTooltip:AddLine(label, "ZoFontGameOutline")
			end
		end
	end
end

local function ToggleActivityTooltip(control, op)
	if op == 1 then

		local tooltip = ZO_ActivityFinderTemplateTooltip_Keyboard
		local data = control.node.data
		local desc = data.description
		local lfgIndex = data.id

		--Un-comment to debug new dungeon activity ID
	--	d(lfgIndex)

		local levelMin = data.levelMin
		local iTable = (levelMin < GetMaxLevel()) and DTAddon.FinderNormalIndex or DTAddon.FinderVeteranIndex

		if iTable[lfgIndex] == nil then return end

		local sVar = iTable[lfgIndex].svI
		local fP = DTAddon.DungeonIndex[sVar].fP
		local vII = DTAddon.DungeonIndex[sVar].vII
		local mode1 = (vII == 0) and 0 or (vII < sVar) and vII or sVar
		local mode2 = (vII == 0) and 0 or (vII > sVar) and vII or sVar

		InitializeTooltip(InformationTooltip, tooltip, TOPRIGHT, -4, -3, TOPLEFT)
		if labelShown then labelShown:SetHidden(true) labelShown = nil end

		local tooltipContents = tooltip:GetNamedChild("Contents")
		local nameLabel = tooltipContents:GetNamedChild("NameLabel")
		local artTexture = tooltip:GetNamedChild("ArtTexture")
		local lWidth = artTexture:GetWidth() - 20

		if DTAddon.ASV.sLFGdesc == true then
			if iTable[lfgIndex].control == nil then CreateLabelControl(iTable, lfgIndex, nameLabel) end
			labelShown = iTable[lfgIndex].control
			labelShown:SetWidth(lWidth)
			labelShown:SetText(desc)
			labelShown:ClearAnchors()
			labelShown:SetAnchor(TOPLEFT, nameLabel, BOTTOMLEFT, 0, 12)
			labelShown:SetHidden(false)
		end

		if DTAddon.ASV.sLFGcomp == true then
			if levelMin < GetMaxLevel() then
				if DB.dungeons[sVar] and DB.dungeons[sVar].nComplete == true then
					InformationTooltip:AddLine(TColor("ffffff",L.DTAddon_CNorm)..TColor(DTAddon.ASV.cColorS,L.DTAddon_True), "ZoFontGameOutline")
				else
					InformationTooltip:AddLine(TColor("ffffff",L.DTAddon_CNorm)..TColor(DTAddon.ASV.iColorS,L.DTAddon_False), "ZoFontGameOutline")
				end
			else
				local hMode, tMode, nDeath
				if DB.dungeons[sVar] and DB.dungeons[sVar].vComplete == true then
					hMode, tMode, nDeath = ModeIcons(sVar)
					InformationTooltip:AddLine(TColor("ffffff",L.DTAddon_CVet)..TColor(DTAddon.ASV.cColorS,L.DTAddon_True)..hMode..tMode..nDeath, "ZoFontGameOutline")
				else
					InformationTooltip:AddLine(TColor("ffffff",L.DTAddon_CVet)..TColor(DTAddon.ASV.iColorS,L.DTAddon_False), "ZoFontGameOutline")
				end
			end
		end

		if DTAddon.ASV.kQuestMap == 1 then
			local nString = ""
			if DB.dungeons[sVar] then
				local sTable = GetColorSortedNames(DB.dungeons[sVar].questC)
				if #sTable < 1 then
					nString = TColor(DTAddon.ASV.iColorS,L.DTAddon_None)
				else
					for k, v in ipairs(sTable) do
						local nSep = (k ~= #sTable) and ", " or ""
						nString = nString .. v .. nSep
					end
				end
				InformationTooltip:AddLine(TColor("ffffff",L.DTAddon_QComp)..nString, "ZoFontGameOutline")
			end
		elseif DTAddon.ASV.kQuestMap == 2 then
			if DB.dungeons[sVar] then
				local questName, questType = GetCompletedQuestInfo(DTAddon.DungeonIndex[sVar].questID)
				if questName ~= "" then
					InformationTooltip:AddLine("|t16:16:/DungeonTracker/bin/cachievement.dds|t "..TColor("00ffff",L.DTAddon_QComp)..TColor(DTAddon.ASV.cColorS,L.DTAddon_True), "ZoFontGameOutline")
				else
					InformationTooltip:AddLine("|t16:16:/DungeonTracker/bin/cachievement.dds|t "..TColor("00ffff",L.DTAddon_QComp)..TColor(DTAddon.ASV.iColorS,L.DTAddon_False), "ZoFontGameOutline")
				end
			end
		end

		-- Add dungeon unlock level to the LFG tooltip.
		InformationTooltip:AddLine(TColor("ffffff",L.DTAddon_Unlock..levelMin), "ZoFontGameOutline")

		if fP ~= 0 then -- Show faction achievement progress.
			if DTAddon.ASV.sDungeonFC == true then
				ZO_Tooltip_AddDivider(InformationTooltip)
				local label = tostring(GetAchievementInfo(fP))
				label = zo_strformat("<<t:1>>",label)
				label = label .. ": "
				local numCriteria = GetAchievementNumCriteria(fP)
				local completed = 0
				for i = 1, numCriteria do
					local _, numCompleted, _ = GetAchievementCriterion(fP, i)
					if numCompleted == 1 then 
						completed = completed + 1
					end
				end
				-- Colorize achievement title by faction.
				if fP == 1073 then label = TColor("e05a4c",label)
				elseif fP == 1075 then label = TColor("fff578",label)
				elseif fP == 1074 then label = TColor("6a91b6",label) end
				label = DTAddon.DungeonIndex[sVar].icon .. label .. tostring(completed) .. "/" .. tostring(numCriteria)
				InformationTooltip:AddLine(label, "ZoFontGameOutline")
			end
		end
	elseif op == 2 then
		if labelShown then labelShown:SetHidden(true) labelShown = nil end
		ClearTooltip(InformationTooltip)
	end
end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Update achievement progress
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function CheckAchievements()
	local nA
	local vA
	local hM
	local tT
	local nD
	for k, v in pairs(DTAddon.DungeonIndex) do
		nA = {GetAchievementInfo(v.nA)}
		vA = {GetAchievementInfo(v.vA)}
		hM = {GetAchievementInfo(v.hM)}
		tT = {GetAchievementInfo(v.tT)}
		nD = {GetAchievementInfo(v.nD)}
		if nA[5] == true then
			DB.dungeons[k].nComplete = true
		end
		if vA[5] == true then
			DB.dungeons[k].vComplete = true
		end
		if hM[5] == true then
			DB.dungeons[k].hMode = true
		end
		if tT[5] == true then
			DB.dungeons[k].tMode = true
		end
		if nD[5] == true then
			DB.dungeons[k].nDeath = true
		end
	end
end

local function AchievementCompleted(eventCode, name, points, id, link)
	for k, v in pairs(DTAddon.DungeonIndex) do
		if v.nA == id or v.vA == id or v.hM == id or v.tT == id or v.nD == id then
			CheckAchievements()
			break
		end
	end
end

local function QuestCompleted(eventCode, questName, level, pExperience, cExperience, cPoints, qType, iType)
	for k, v in pairs(DTAddon.DungeonIndex) do -- update db of characters who have completed dungeon quests
		local eName, eType = GetCompletedQuestInfo(v.questID)
		if eName ~= "" and zo_strformat("<<t:1>>",eName) == zo_strformat("<<t:1>>",questName) then
			DB.dungeons[k].questC[GetCurrentCharacterId()] = true
		end
	end
end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Init functions
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function InitValues()
	cOpts[1] = L.DTAddon_CTOPT1
	cOpts[2] = L.DTAddon_CTOPT2
	cOpts[3] = L.DTAddon_CTOPT3
	mOpts[1] = L.DTAddon_MQOPT1
	mOpts[2] = L.DTAddon_MQOPT2
	mOpts[3] = L.DTAddon_MQOPT3

	DB = DTAddon.ASV.achievementDB
	if not DB.dungeons then DB.dungeons = {} end
	if not DB.delves then DB.delves = {} end
	for k, v in pairs(DTAddon.DungeonIndex) do
		if not DB.dungeons[k] then DB.dungeons[k] = {nComplete = false, vComplete = false, hMode = false, tMode = false, nDeath = false} end
	end
	for i, d in pairs(DB.dungeons) do
		if not DB.dungeons[i].questC then 
			DB.dungeons[i].questC = {}
		end
	end
end

local function HookDungeonTooltips()
	ZO_MapPin.TOOLTIP_CREATORS[MAP_PIN_TYPE_POI_SEEN].tooltip = ZO_MAP_TOOLTIP_MODE.INFORMATION
	ZO_MapPin.TOOLTIP_CREATORS[MAP_PIN_TYPE_POI_COMPLETE].tooltip = ZO_MAP_TOOLTIP_MODE.INFORMATION

-- Group Dungeons (act as wayshrines)
	local TooltipCreatorFastTravel = ZO_MapPin.TOOLTIP_CREATORS[MAP_PIN_TYPE_FAST_TRAVEL_WAYSHRINE].creator
	ZO_MapPin.TOOLTIP_CREATORS[MAP_PIN_TYPE_FAST_TRAVEL_WAYSHRINE].creator = function(pin)
		TooltipCreatorFastTravel(pin)
		local nIndex = pin:GetFastTravelNodeIndex()
		--Un-comment for new dungeon node ID debug
	--	d("nIndex: "..nIndex)

		if DTAddon.DungeonIndex[nIndex] then -- Add group dungeon tooltip info.
			local vII = DTAddon.DungeonIndex[nIndex].vII
			local mode1 = (vII == 0) and 0 or (vII < nIndex) and vII or nIndex
			local mode2 = (vII == 0) and 0 or (vII > nIndex) and vII or nIndex
			if vII == 0 or (vII ~= 0 and nIndex == mode1) then
				ModifyDungeonTooltip(pin, 1, nIndex)
			end
		end
	end

-- Delves (POI tooltips)
	local TooltipCreatorPOISeen = ZO_MapPin.TOOLTIP_CREATORS[MAP_PIN_TYPE_POI_SEEN].creator
	ZO_MapPin.TOOLTIP_CREATORS[MAP_PIN_TYPE_POI_SEEN].creator = function(pin)
		TooltipCreatorPOISeen(pin)
		local zoneIndex = pin:GetPOIZoneIndex()
		local poiIndex = pin:GetPOIIndex()
		local poiName = zo_strformat("<<t:1>>",GetPOIInfo(zoneIndex, poiIndex))
		local poiKey = tostring(zoneIndex).."-"..tostring(poiIndex)
		--Un-comment to debug when zone index changes due to expansions/DLC additions
		--d(tostring(zoneIndex).." - "..tostring(poiIndex))

		if DTAddon.DelveIndex[poiKey] and ((DTAddon.ASV.sDelveGC) or (DTAddon.ASV.sDelveBC) or (DTAddon.ASV.sDelveFC)) then -- Add group delve tooltip info.
			ModifyDungeonTooltip(pin, 2, zoneIndex, poiIndex)
		else
			InformationTooltip:AddLine(poiName, "ZoFontGame")
		end
	end

-- Activity Finder tooltips
	local DTAddonShowActivityTooltip = ZO_ActivityFinderTemplate_Keyboard.ShowActivityTooltip
	ZO_ActivityFinderTemplate_Keyboard.ShowActivityTooltip = function(self, control)
		DTAddonShowActivityTooltip(self, control)
		ToggleActivityTooltip(self, 1)
	end
	local DTAddonHideActivityTooltip = ZO_ActivityFinderTemplate_Keyboard.HideActivityTooltip
	ZO_ActivityFinderTemplate_Keyboard.HideActivityTooltip = function(self)
		DTAddonHideActivityTooltip(self)
		ToggleActivityTooltip(self, 2)
	end
end

local function SetupCharacters()
	local currentChar = GetCurrentCharacterId()
	if DTAddon.ASV.charEnabled[currentChar] == nil then
		DTAddon.ASV.charEnabled[currentChar] = true
	end

	for k, v in pairs(DTAddon.DungeonIndex) do -- update db of characters who have completed dungeon quests
		if DTAddon.ASV.charEnabled[currentChar] == nil or DTAddon.ASV.charEnabled[currentChar] == true then
			local questName, questType = GetCompletedQuestInfo(v.questID)
			if questName ~= "" then
				DB.dungeons[k].questC[currentChar] = true
			end
		else
			DB.dungeons[k].questC[currentChar] = nil
		end
	end
end

local function DTCheckQuests()
	DTQuests = true
	DTQuestNC = {}
	for k, v in pairs(DTAddon.FinderNormalIndex) do
		local qVal = DTAddon.DungeonIndex[v.svI].questID
		if GetCompletedQuestInfo(qVal) == "" then
			DTQuestNC[v.svI] = true
		end
	end
	local next = next 
	if next(DTQuestNC) == nil then DTQuests = false end
end

local function sceneChange(oldState, newState)
    if newState ~= SCENE_SHOWN then
		if DTQButton then DTQButton:SetHidden(true) end
		if DTQToggle then DTQToggle:SetHidden(true) end
		if DTQLabel then DTQLabel:SetHidden(true) end
    else
		if ZO_DungeonFinder_KeyboardListSectionScrollChildZO_ActivityFinderTemplateNavigationHeader_Keyboard1 and not ZO_DungeonFinder_KeyboardListSectionScrollChildZO_ActivityFinderTemplateNavigationHeader_Keyboard1:IsHidden() then
			if DUNGEON_FINDER_KEYBOARD.filterComboBox.m_selectedItemData and not DUNGEON_FINDER_KEYBOARD.filterComboBox.m_selectedItemData.data.singular then
				DTCheckQuests()
				DTQButton:SetHidden(false)
				DTQToggle:SetHidden(false)
				DTQLabel:SetHidden(false)
				DTQButton:SetEnabled(not ZO_ACTIVITY_FINDER_ROOT_MANAGER:GetIsCurrentlyInQueue() and DTQuests == true)
			end
		end
	end
end

local function fragmentChange(oldState, newState)
	if newState == SCENE_FRAGMENT_SHOWN then
		if DTQButton then DTQButton:SetHidden(true) end
		if DTQToggle then DTQToggle:SetHidden(true) end
		if DTQLabel then DTQLabel:SetHidden(true) end
	end
end

local function DTQueueSelection()
	if IsUnitGrouped("player") and not IsUnitGroupLeader("player") then return end
	--reset selection
	ZO_ACTIVITY_FINDER_ROOT_MANAGER:ClearAndUpdate()
	--select missing
	local mode
	local dtable
	if DTQToggle:GetState() ~= 1 then
		mode = _G["ZO_DungeonFinder_KeyboardListSectionScrollChildContainer2"]
		dtable = DTAddon.FinderNormalIndex
	else
		mode = _G["ZO_DungeonFinder_KeyboardListSectionScrollChildContainer3"]
		dtable = DTAddon.FinderVeteranIndex
	end

	if mode then
		for i = 1, mode:GetNumChildren() do
			local obj = mode:GetChild(i)
			if obj then
				local id = obj.node.data.id
				if dtable[id] then
					local qVal = DTAddon.DungeonIndex[dtable[id].svI].questID
					if GetCompletedQuestInfo(qVal) == "" then
						if obj.check:GetState() == 0 then
							obj.check:SetState(BSTATE_PRESSED, true)
							ZO_ACTIVITY_FINDER_ROOT_MANAGER:ToggleLocationSelected(obj.node.data)
						end
					end
				end
			end
		end
	end
end

local function DTVetToggleFunction(opt)
	if opt == 1 then
		InitializeTooltip(InformationTooltip, DTQButton, TOPRIGHT, -8, 0, TOPLEFT)
		SetTooltipText(InformationTooltip, L.DTAddon_QMQVTip)
	elseif opt == 2 then
		ClearTooltip(InformationTooltip)
	elseif opt == 3 then
		if DTQToggle:GetState() == 0 then
			DTQToggle:SetState(1, true)
		else
			DTQToggle:SetState(0, false)
		end
	end
end

local function DTQueueQuestTooltip(opt)
	if opt == 1 then
		InitializeTooltip(InformationTooltip, DTQButton, TOPRIGHT, -8, 0, TOPLEFT)
		SetTooltipText(InformationTooltip, L.DTAddon_QMQTip)
	elseif opt == 2 then
		ClearTooltip(InformationTooltip)
	end
end

local function DTCreateQueueControls()
	DTQLabel = WINDOW_MANAGER:CreateControl('DTQuestVetLabel', ZO_SearchingForGroup, CT_LABEL)
	DTQLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
	DTQLabel:SetFont("ZoFontGame")
	DTQLabel:SetText("Veteran Mode:")
	DTQLabel:SetAnchor(BOTTOM, ZO_SearchingForGroupStatus, TOP, 0, -40)
	DTQLabel:SetHidden(true)

	DTQToggle = WINDOW_MANAGER:CreateControlFromVirtual('DTQuestVetCheck', ZO_SearchingForGroup, 'ZO_CheckButton')
	DTQToggle:SetHandler("OnMouseEnter", function() DTVetToggleFunction(1) end)
	DTQToggle:SetHandler("OnMouseExit", function() DTVetToggleFunction(2) end)
	DTQToggle:SetHandler("OnClicked", function() DTVetToggleFunction(3) end)
	DTQToggle:SetAnchor(LEFT, DTQLabel, RIGHT, 6, 0)
	DTQToggle:SetState(0)
	DTQToggle:SetHidden(true)

	DTQButton = WINDOW_MANAGER:CreateControlFromVirtual("DTQuestQueueButton", ZO_SearchingForGroup, "ZO_DefaultButton")
	DTQButton:SetDimensions(206, 28)
	DTQButton:SetAnchor(BOTTOM, DTQLabel, TOP, 0, -8)
	DTQButton:SetFont("ZoFontGameBold")
	DTQButton:SetText(L.DTAddon_QMQ)
	DTQButton:SetClickSound("Click")
	DTQButton:SetVerticalAlignment(TEXT_ALIGN_CENTER)
	DTQButton:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
	DTQButton:SetHandler("OnMouseEnter", function() DTQueueQuestTooltip(1) end)
	DTQButton:SetHandler("OnMouseExit", function() DTQueueQuestTooltip(2) end)
	DTQButton:SetHandler("OnClicked", DTQueueSelection)
	DTQButton:SetHidden(true)

	ZO_PreHook(ZO_ActivityFinderTemplate_Keyboard, "OnFilterChanged", function(comboBox, entryText, entry)
		if DUNGEON_FINDER_KEYBOARD.filterComboBox.m_selectedItemData and not DUNGEON_FINDER_KEYBOARD.filterComboBox.m_selectedItemData.data.singular then
			DTQButton:SetHidden(false)
			DTQToggle:SetHidden(false)
			DTQLabel:SetHidden(false)
		else
			DTQButton:SetHidden(true)
			DTQToggle:SetHidden(true)
			DTQLabel:SetHidden(true)
		end
	end)
	ZO_PreHook(ZO_ActivityFinderTemplate_Keyboard, "RefreshJoinQueueButton", function()
		if ZO_DungeonFinder_KeyboardListSectionScrollChildZO_ActivityFinderTemplateNavigationHeader_Keyboard1 and not ZO_DungeonFinder_KeyboardListSectionScrollChildZO_ActivityFinderTemplateNavigationHeader_Keyboard1:IsHidden() then
			DTQButton:SetHidden(false)
			DTQToggle:SetHidden(false)
			DTQLabel:SetHidden(false)
			DTQButton:SetEnabled(not ZO_ACTIVITY_FINDER_ROOT_MANAGER:GetIsCurrentlyInQueue() and DTQuests == true)
		else
			DTQButton:SetHidden(true)
			DTQToggle:SetHidden(true)
			DTQLabel:SetHidden(true)
		end
	end)
	ZO_PreHook(ZO_Tree, "SelectNode", function(self,treeNode,...) -- when changing left-side navigation category
		local tName = treeNode:GetControl():GetName()
		if tName == "ZO_GroupMenu_KeyboardCategoriesScrollChildZO_GroupMenuKeyboard_StatusIconChildlessHeader3" then
			if DUNGEON_FINDER_KEYBOARD.filterComboBox.m_selectedItemData and not DUNGEON_FINDER_KEYBOARD.filterComboBox.m_selectedItemData.data.singular then
				DTQButton:SetHidden(false)
				DTQToggle:SetHidden(false)
				DTQLabel:SetHidden(false)
			end
		end
	end)
end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Set up the Addon Settings options panel.
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function CreateSettingsWindow()
	local LAM = LibAddonMenu2

	local panelData = {
		type					= "panel",
		name					= L.DTAddon_Title,
		displayName				= ZO_HIGHLIGHT_TEXT:Colorize(L.DTAddon_Title),
		author					= TColor("66ccff", "Phinix"),
		version					= version,
		registerForRefresh		= true,
		registerForDefaults		= true,
	}

	local function num2hex(ntable) -- Convert decimal r,g,b,a table to hex string
		local cstring = ""
		for i = 1, 3, 1 do
			local colornum = ntable[i] * 255
			local hexstr = "0123456789abcdef"
			local s = ""
			while colornum > 0 do
				local mod = math.fmod(colornum, 16)
				s = string.sub(hexstr, mod+1, mod+1) .. s
				colornum = math.floor(colornum / 16)
			end
			if #s == 1 then s = "0" .. s end
			if s == "" then s = "00" end
			cstring = cstring .. s
		end
		return cstring
	end

	local optionsData = {
	{
			type			= "checkbox",
			name			= L.DTAddon_SHMComp..' '..'|t24:24:/DungeonTracker/bin/a-hard.dds|t',
			tooltip			= L.DTAddon_SHMCompD..L.DTAddon_AWide,
			getFunc			= function() return DTAddon.ASV.sDungeonHM end,
			setFunc			= function(value) DTAddon.ASV.sDungeonHM = value end,
			width			= "full",
			default			= DTAddon.aOpts.sDungeonHM,
	},
	{
			type			= "checkbox",
			name			= L.DTAddon_STTComp..' '..'|t24:24:/DungeonTracker/bin/a-time.dds|t',
			tooltip			= L.DTAddon_STTCompD..L.DTAddon_AWide,
			getFunc			= function() return DTAddon.ASV.sDungeonTT end,
			setFunc			= function(value) DTAddon.ASV.sDungeonTT = value end,
			width			= "full",
			default			= DTAddon.aOpts.sDungeonTT,
	},
	{
			type			= "checkbox",
			name			= L.DTAddon_SNDComp..' '..'|t24:24:/DungeonTracker/bin/a-nodeath.dds|t',
			tooltip			= L.DTAddon_SNDCompD..L.DTAddon_AWide,
			getFunc			= function() return DTAddon.ASV.sDungeonND end,
			setFunc			= function(value) DTAddon.ASV.sDungeonND = value end,
			width			= "full",
			default			= DTAddon.aOpts.sDungeonND,
	},
	{
			type			= "checkbox",
			name			= L.DTAddon_SGFComp,
			tooltip			= L.DTAddon_SGFCompD..L.DTAddon_AWide,
			getFunc			= function() return DTAddon.ASV.sDungeonFC end,
			setFunc			= function(value) DTAddon.ASV.sDungeonFC = value end,
			width			= "full",
			default			= DTAddon.aOpts.sDungeonFC,
	},
	{
			type			= "checkbox",
			name			= L.DTAddon_SLFGt,
			tooltip			= L.DTAddon_SLFGtD..L.DTAddon_AWide,
			getFunc			= function() return DTAddon.ASV.sLFGcomp end,
			setFunc			= function(value) DTAddon.ASV.sLFGcomp = value end,
			width			= "full",
			default			= DTAddon.aOpts.sLFGcomp,
	},
	{
			type			= "checkbox",
			name			= L.DTAddon_SLFGd,
			tooltip			= L.DTAddon_SLFGdD..L.DTAddon_AWide,
			getFunc			= function() return DTAddon.ASV.sLFGdesc end,
			setFunc			= function(value) DTAddon.ASV.sLFGdesc = value end,
			width			= "full",
			default			= DTAddon.aOpts.sLFGdesc,
	},
	{
			type			= "checkbox",
			name			= L.DTAddon_SNComp,
			tooltip			= L.DTAddon_SNCompD..L.DTAddon_AWide,
			getFunc			= function() return DTAddon.ASV.sDungeonNMap end,
			setFunc			= function(value) DTAddon.ASV.sDungeonNMap = value end,
			width			= "full",
			default			= DTAddon.aOpts.sDungeonNMap,
	},
	{
			type			= "checkbox",
			name			= L.DTAddon_SVComp,
			tooltip			= L.DTAddon_SVCompD..L.DTAddon_AWide,
			getFunc			= function() return DTAddon.ASV.sDungeonVMap end,
			setFunc			= function(value) DTAddon.ASV.sDungeonVMap = value end,
			width			= "full",
			default			= DTAddon.aOpts.sDungeonVMap,
	},
	{
			type			= "checkbox",
			name			= L.DTAddon_SGCCompM..TColor("00ffff",L.DTAddon_SGCComp)..'  '..'|t20:20:/DungeonTracker/bin/cachievement.dds|t',
			tooltip			= L.DTAddon_SGCCompD,
			getFunc			= function() return DTAddon.ASV.sDelveGC end,
			setFunc			= function(value) DTAddon.ASV.sDelveGC = value end,
			width			= "full",
			default			= DTAddon.aOpts.sDelveGC,
	},
	{
			type			= "checkbox",
			name			= L.DTAddon_SDBComp,
			tooltip			= L.DTAddon_SDBCompD..L.DTAddon_AWide,
			getFunc			= function() return DTAddon.ASV.sDelveBC end,
			setFunc			= function(value) DTAddon.ASV.sDelveBC = value end,
			width			= "full",
			default			= DTAddon.aOpts.sDelveBC,
	},
	{
			type			= "checkbox",
			name			= L.DTAddon_SDFComp,
			tooltip			= L.DTAddon_SDFCompD..L.DTAddon_AWide,
			getFunc			= function() return DTAddon.ASV.sDelveFC end,
			setFunc			= function(value) DTAddon.ASV.sDelveFC = value end,
			width			= "full",
			default			= DTAddon.aOpts.sDelveFC,
	},
	{
			type			= "colorpicker",
			name			= L.DTAddon_CNColor,
			tooltip			= L.DTAddon_CNColorD,
			getFunc			= function() return unpack(DTAddon.ASV.cColorT) end,
			setFunc			= function(r, g, b, a)
								DTAddon.ASV.cColorT = { r, g, b, a }
								DTAddon.ASV.cColorS = num2hex(DTAddon.ASV.cColorT)
							end,
			width			= "full",
			default			= {r=DTAddon.aOpts.cColorT[1], g=DTAddon.aOpts.cColorT[2], b=DTAddon.aOpts.cColorT[3]},
	},
	{
			type			= "colorpicker",
			name			= L.DTAddon_NNColor,
			tooltip			= L.DTAddon_NNColorD,
			getFunc			= function() return unpack(DTAddon.ASV.iColorT) end,
			setFunc			= function(r, g, b, a)
								DTAddon.ASV.iColorT = { r, g, b, a }
								DTAddon.ASV.iColorS = num2hex(DTAddon.ASV.iColorT)
							end,
			width			= "full",
			default			= {r=DTAddon.aOpts.iColorT[1], g=DTAddon.aOpts.iColorT[2], b=DTAddon.aOpts.iColorT[3]},
	},
	{
		type			= 'submenu',
		name			= L.DTAddon_QCompHead,
		controls		= {
			[1] = {
					type			= 'dropdown',
					name			= L.DTAddon_QCompS,
					tooltip			= L.DTAddon_QCompSD,
					choices			= mOpts,
					getFunc			= function() return mOpts[DTAddon.ASV.kQuestMap] end,
					setFunc			= function(selected)
										for k,v in ipairs(mOpts) do
											if v == selected then
												DTAddon.ASV.kQuestMap = k
												break
											end
										end
									end,
					default			= mOpts[DTAddon.aOpts.kQuestMap],
			},
			[2] = {
					type			= 'dropdown',
					name			= L.DTAddon_CTDROPDOWN,
					tooltip			= L.DTAddon_CTDROPDOWND,
					choices			= cOpts,
					getFunc			= function() return cOpts[DTAddon.ASV.kSformat] end,
					setFunc			= function(selected)
										for k,v in ipairs(cOpts) do
											if v == selected then
												DTAddon.ASV.kSformat = k
												break
											end
										end
									end,
					default			= cOpts[DTAddon.aOpts.kSformat],
			},
			[3] = {
					type			= "checkbox",
					name			= L.DTAddon_ALPHAN,
					tooltip			= L.DTAddon_ALPHAND,
					getFunc			= function() return DTAddon.ASV.sortAlpha end,
					setFunc			= function(value)
										DTAddon.ASV.sortAlpha = value
										SetupCharacters()
									end,
					width			= "full",
					default			= DTAddon.aOpts.sortAlpha,
			},
			[4] = {
					type			= "checkbox",
					name			= L.DTAddon_CHighlight,
					tooltip			= L.DTAddon_CHighlightD,
					getFunc			= function() return DTAddon.ASV.highlightCC end,
					setFunc			= function(value) DTAddon.ASV.highlightCC = value end,
					width			= "full",
					default			= DTAddon.aOpts.highlightCC,
			},
			[5] = {
					type			= "colorpicker",
					name			= L.DTAddon_HColor,
					tooltip			= L.DTAddon_HColorD,
					getFunc			= function() return unpack(DTAddon.ASV.vColorT) end,
					setFunc			= function(r, g, b, a)
										DTAddon.ASV.vColorT = { r, g, b, a }
										DTAddon.ASV.vColorS = num2hex(DTAddon.ASV.vColorT)
									end,
					width			= "full",
					default			= {r=DTAddon.aOpts.vColorT[1], g=DTAddon.aOpts.vColorT[2], b=DTAddon.aOpts.vColorT[3]},
			},
			[6] = {
					type = "header",
					name = L.DTAddon_CharTracking,
			},
			[7] = {
					type			= "checkbox",
					name			= L.DTAddon_TrackChar,
					tooltip			= L.DTAddon_TrackCharD,
					getFunc			= function() return (DTAddon.ASV.charEnabled[GetCurrentCharacterId()] ~= nil and DTAddon.ASV.charEnabled[GetCurrentCharacterId()] == true) end,
					setFunc			= function(value)
										DTAddon.ASV.charEnabled[GetCurrentCharacterId()] = value
										SetupCharacters()
										ReloadUI()
									end,
					width			= "full",
					default			= true,
			},
			[8] = {
				type = 'description',
				text = L.DTAddon_TrackWarn,
			},
		},
	},
	}

	LAM:RegisterAddonPanel("DTAddon_Panel", panelData)
	LAM:RegisterOptionControls("DTAddon_Panel", optionsData)
end

local function OnAddonLoaded(event, addonName)
	if addonName ~= 'DungeonTracker' then return end
	EVENT_MANAGER:UnregisterForEvent('DungeonTracker', EVENT_ADD_ON_LOADED)
	DTAddon.ASV = ZO_SavedVars:NewAccountWide('DungeonTracker', 1.37, nil, DTAddon.aOpts, GetWorldName())

	-- dungeon finder missing quest selection init
	EVENT_MANAGER:RegisterForEvent('DungeonTracker', EVENT_SKILL_POINTS_CHANGED, function() DTCheckQuests() end)
	SCENE_MANAGER:GetScene("groupMenuKeyboard"):RegisterCallback("StateChange", sceneChange)
	GROUP_LIST_FRAGMENT:RegisterCallback("StateChange", fragmentChange)
	TIMED_ACTIVITIES_FRAGMENT:RegisterCallback("StateChange", fragmentChange)
	ZONE_STORIES_FRAGMENT:RegisterCallback("StateChange", fragmentChange)
	DTCheckQuests()
	DTCreateQueueControls()

	-- init other values
	InitValues()
	CheckAchievements()
	HookDungeonTooltips()
	SetupCharacters()
	CreateSettingsWindow()
end

EVENT_MANAGER:RegisterForEvent('DungeonTracker', EVENT_ADD_ON_LOADED, OnAddonLoaded)
EVENT_MANAGER:RegisterForEvent('DungeonTracker', EVENT_ACHIEVEMENT_AWARDED, AchievementCompleted)
EVENT_MANAGER:RegisterForEvent('DungeonTracker', EVENT_QUEST_COMPLETE, QuestCompleted)
