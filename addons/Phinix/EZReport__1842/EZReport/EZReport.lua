-------------------------------------------------------------------------------
-- EZReport
-------------------------------------------------------------------------------
--[[
-- Copyright (c) 2015-2024 James A. Keene (Phinix) All rights reserved.
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

local EZReport = _G['EZReport']
local L = EZReport:GetLanguage()
local lastTarget = EZReport.GetTargetInfo(nil, nil)

-- Global functions:
local pR2 = EZReport.RGB2Hex
local pTC = EZReport.TColor

------------------------------------------------------------------------------------------------------------------------------------
-- Main functions
------------------------------------------------------------------------------------------------------------------------------------
local function OnTargetChanged() -- called when reticle target changes
	if not IsUnitPlayer("reticleover") then EZReport_Reported:SetHidden(true) return end -- ignore if target isn't a player

	local tName = GetUnitName("reticleover") -- if target is valid player and different than last, update report info
	if tName and tName ~= "" then
		if tName ~= lastTarget.rName then
			lastTarget = EZReport.GetTargetInfo(tName)
		end
	else
		EZReport_Reported:SetHidden(true)
		return -- end if no valid target
	end

	local unitTag = 'reticleover'
	local tAccount = lastTarget.rAccount
	if EZReport.ASV.accountDB[tAccount] == nil and EZReport.ASV.characterDB[tName] == nil then EZReport_Reported:SetHidden(true) return end -- skip adding marks if not in database
	if (EZReport.ASV.sVars.targetIcon) then -- handles adding the reported mark and optional timestamp to target frames
		local reason

		if EZReport.ASV.characterDB[tName] ~= nil then -- set icon based on last reported reason
			-- check the last time this account/character was reported
			local lastIndex = EZReport.LastTimeIndex(EZReport.ASV.characterDB[tName])
			reason = EZReport.ASV.characterDB[tName][lastIndex].rReason
			EZReport.SetReportedTexture(reason,EZReport.ASV.characterDB[tName][lastIndex].rDT,false)
		elseif EZReport.ASV.accountDB[tAccount].names[tName] ~= nil then
			-- check the last time this account/character was reported
			local lastIndex = EZReport.LastTimeIndex(EZReport.ASV.accountDB[tAccount].names[tName])
			reason = EZReport.ASV.accountDB[tAccount].names[tName][lastIndex].rReason
			EZReport.SetReportedTexture(reason,EZReport.ASV.accountDB[tAccount].names[tName][lastIndex].rDT,false)
		elseif EZReport.ASV.accountDB[tAccount].lastReason ~= nil then
			reason = EZReport.ASV.accountDB[tAccount].lastReason
			EZReport.SetReportedTexture(0,EZReport.ASV.accountDB[tAccount].lastReport,true)
		end

		if (EZReport.ASV.sVars.targetDS) then -- colorize timestamp text by last report reason
			EZReport_Reported_Label:SetHidden(false)
		else
			EZReport_Reported_Label:SetHidden(true)
		end

		EZReport_Reported:SetWidth(EZReport_Reported_Mark:GetWidth() + ((EZReport.ASV.sVars.targetDS) and EZReport_Reported_Label:GetWidth() or 0) + 4)
		EZReport_Reported:ClearAnchors()
		EZReport_Reported:SetAnchor(TOP, ZO_TargetUnitFramereticleoverCaption, BOTTOM, 0, 4)
		EZReport_Reported:SetHidden(false)
	else
		EZReport_Reported:SetHidden(true)
	end
end

local function ShowHistory(cSearch) -- print report history of @account or character name to chat using keybind or /ezreport option
	if cSearch == nil or cSearch == "" then
		EZReport.ShowMain()
	else
		local _, count = cSearch:gsub('@','')
		local match = 0
		if count ~= 0 then
			for tAccount, _ in pairs(EZReport.ASV.accountDB) do
				if tAccount == cSearch then
					for name, _ in pairs(EZReport.ASV.accountDB[tAccount].names) do
						for dtIndex, _ in pairs(EZReport.ASV.accountDB[tAccount].names[name]) do
							local rDT = string.sub(EZReport.ASV.accountDB[tAccount].names[name][dtIndex].rDT, 1, 10)
							local rReason = EZReport.ASV.accountDB[tAccount].names[name][dtIndex].rReason
							local rAccount = EZReport.ASV.accountDB[tAccount].names[name][dtIndex].account
							local rText = EZReport.rReasons[rReason]
							local rColor = pR2(EZReport.ASV.rColor[rReason].color)
							d(rDT.." - "..L.EZReport_RepT.." "..pTC("ffffff",rAccount).." \("..L.EZReport_Now.." "..pTC("ffffff",tAccount).."\) "..L.EZReport_Char.." "..pTC("ffffff",name).." "..L.EZReport_For.." "..pTC(rColor,rText))
							match = match + 1
						end
					end
				end
			end
		else
			for tAccount, _ in pairs(EZReport.ASV.accountDB) do
				for name, _ in pairs(EZReport.ASV.accountDB[tAccount].names) do
					if name == cSearch then
						for dtIndex, _ in pairs(EZReport.ASV.accountDB[tAccount].names[name]) do
							local rDT = string.sub(EZReport.ASV.accountDB[tAccount].names[name][dtIndex].rDT, 1, 10)
							local rReason = EZReport.ASV.accountDB[tAccount].names[name][dtIndex].rReason
							local rAccount = EZReport.ASV.accountDB[tAccount].names[name][dtIndex].account
							local rText = EZReport.rReasons[rReason]
							local rColor = pR2(EZReport.ASV.rColor[rReason].color)
							d(rDT.." - "..L.EZReport_RepT.." "..pTC("ffffff",rAccount).." \("..L.EZReport_Now.." "..pTC("ffffff",tAccount).."\) "..L.EZReport_Char.." "..pTC("ffffff",name).." "..L.EZReport_For.." "..pTC(rColor,rText))
							match = match + 1
						end
					end
				end
			end
			for name, _ in pairs(EZReport.ASV.characterDB) do
				if name == cSearch then
					for dtIndex, _ in pairs(EZReport.ASV.accountDB[tAccount].names[name]) do
						local rDT = string.sub(EZReport.ASV.accountDB[tAccount].names[name][dtIndex].rDT, 1, 10)
						local rReason = EZReport.ASV.accountDB[tAccount].names[name][dtIndex].rReason
						local rAccount = EZReport.ASV.accountDB[tAccount].names[name][dtIndex].account
						local rText = EZReport.rReasons[rReason]
						local rColor = pR2(EZReport.ASV.rColor[rReason].color)
						d(rDT.." - "..L.EZReport_RepC.." "..pTC("ffffff",name).." \("..L.EZReport_Unkn.."\) "..L.EZReport_For.." "..pTC(rColor,rText))
						match = match + 1
					end
				end
			end
		end
		if match == 0 then d(L.EZReport_NoMatch) end
	end
end

function EZReport.TargetHistory() -- keybind target report history
	if lastTarget.rName ~= "" then
		ShowHistory(lastTarget.rName)
	end
end

function EZReport.ReportTarget() -- called using the bindable EZReport hotkey
	-- these set the category and subcategory for the reporting window and may need changing with game updates.
		HELP_CUSTOMER_SERVICE_ASK_FOR_HELP_KEYBOARD:SelectImpact(2)
		HELP_CUSTOMER_SERVICE_ASK_FOR_HELP_KEYBOARD:SelectCategory(3)
		HELP_CUSTOMER_SERVICE_ASK_FOR_HELP_KEYBOARD.helpSubcategoryComboBox:SetSelected(4)

	--	HELP_CUSTOMER_SERVICE_ASK_FOR_HELP_KEYBOARD:SelectSubcategory(EZReport.ASV.sVars.dCategory) -- can set default subcategory in addon settings
	--	EZReport.GetReason(EZReport.ASV.sVars.dCategory)
		EZReport.GetReason(3)

	if lastTarget.rName ~= "" then -- pull info for last targeted player
		-- can set default reporting reason in addon settings
		local text = string.gsub(EZReport.Template, "({([^}]+)})", function(whole,i) return lastTarget[i] or whole end)
		local formatNames = ZO_GetPrimaryPlayerNameWithSecondary(lastTarget.rAccount, lastTarget.rName)

		local hText = text -- option to show previous reports in report summary
		local rReports = {}
		local tsort = {}
		local rsort = {}
		local ttext = ""
		if (EZReport.ASV.sVars.pReports) then
			local count = 0
			for aName, _ in pairs(EZReport.ASV.accountDB) do
				if aName == lastTarget.rAccount then
					for name, _ in pairs(EZReport.ASV.accountDB[aName].names) do
						for dt, _ in pairs(EZReport.ASV.accountDB[aName].names[name]) do
							local tstring = EZReport.ASV.accountDB[aName].names[name][dt].rDT.." - "..name.." \("..EZReport.ASV.accountDB[aName].names[name][dt].account.."\)"
							local rDT = EZReport.ASV.accountDB[aName].names[name][dt].rDT
							local monString = string.sub(rDT, 1, 2)
							local dString = string.sub(rDT, 4, 5)
							local yString = string.sub(rDT, 7, 10)
							local dtString = yString..monString..dString
							rReports[tonumber(dtString)] = tstring
							count = count + 1
						end
					end
				end
			end
			for name, _ in pairs(EZReport.ASV.characterDB) do
				if name == lastTarget.rName then
					for dt, _ in pairs(EZReport.ASV.characterDB[name]) do
						local tstring = EZReport.ASV.characterDB[name].rDT.." - "..name.." \("..L.EZReport_AccUnavail.."\)"
						local rDT = EZReport.ASV.characterDB[name].rDT
						local monString = string.sub(rDT, 1, 2)
						local dString = string.sub(rDT, 4, 5)
						local yString = string.sub(rDT, 7, 10)
						local dtString = yString..monString..dString
						rReports[tonumber(dtString)] = tstring
						count = count + 1
					end
				end
			end
			for k, _ in pairs(rReports) do table.insert(tsort, k) end
			table.sort(tsort)
			for _, rt in ipairs(tsort) do
				table.insert(rsort, 1, rt)
			end
			if count > 0 then
				for _, nt in ipairs(rsort) do
					ttext = ttext.."\n"..rReports[nt]
				end
				hText = hText..L.EZReport_Previous
			end
			local tFormat = (count > 0) and "\n\n" or ""
			ttext = ttext..tFormat..L.EZReport_Generated
		else
			ttext = ttext..L.EZReport_Generated
		end
		hText = hText..ttext

		-- these populate the character name and description text fields in the reporting window
		ZO_Help_Ask_For_Help_Keyboard_ControlDetailsTextLineField:SetText(formatNames)
		ZO_Help_Ask_For_Help_Keyboard_ControlDescriptionBodyField:SetText(hText)

		local account = lastTarget.rAccount -- this section builds the list of reported alts at the reporting window
		local altString = ''
		if EZReport.ASV.accountDB[account] then
			local tsort = {}
			for k, v in pairs(EZReport.ASV.accountDB[account].names) do table.insert(tsort, k) end
			table.sort(tsort) -- sort all previously reported alts alphabetically

			for _, k in ipairs(tsort) do
				if k and k ~= "" then
					local datestring -- add the date they were reported to the reporting window

					-- check the last time this account/character was reported
					local lastIndex = EZReport.LastTimeIndex(EZReport.ASV.accountDB[account].names[k])
					local timestamp = EZReport.GetDateTime()
					local monString = string.sub(timestamp, 1, 2)
					local dString = string.sub(timestamp, 4, 5)
					local yString = string.sub(timestamp, 7, 10)
					local dtString = yString..monString..dString
					local sStamp = string.sub(lastIndex, 1, 8)

					if sStamp == dtString then
						datestring = " \("..L.EZReport_Today.."\)"
					else
						local lastY = string.sub(sStamp, 1, 4)
						local lastM = string.sub(sStamp, 5, 6)
						local lastD = string.sub(sStamp, 7, 8)
						datestring = " \("..lastM.."\/"..lastD.."\/"..lastY.."\)"
					end
					altString = altString..k..datestring.."\n"
				end
			end
		end

		if (EZReport.ASV.sVars.rCDown) then -- reporting cooldown check if option is enabled
			local timestamp = EZReport.GetDateTime()
			local monString = string.sub(timestamp, 1, 2)
			local dString = string.sub(timestamp, 4, 5)
			local yString = string.sub(timestamp, 7, 10)
			local dtString = yString..monString..dString

			if EZReport.ASV.accountDB[account] ~= nil then
				if EZReport.ASV.accountDB[account].names[lastTarget.rName] ~= nil then
					-- check the last time this account/character was reported
					local lastIndex = EZReport.LastTimeIndex(EZReport.ASV.accountDB[account].names[lastTarget.rName])
					local sStamp = string.sub(lastIndex, 1, 8)
					
					if (string.find(dtString,sStamp) ~= nil) then
					--if sStamp == dtString then
						if (EZReport.ASV.sVars.outputChat) then d(L.EZReport_RCooldownM) end
						return
					end
				end
			end
			if EZReport.ASV.characterDB[lastTarget.rName] ~= nil then
				local lastIndex = EZReport.ASV.characterDB[lastTarget.rName]
				local sStamp = string.sub(lastIndex, 1, 8)
				
				if (string.find(dtString,sStamp) ~= nil) then
				--if sStamp == dtString then
					if (EZReport.ASV.sVars.outputChat) then d(L.EZReport_RCooldownM) end
					return
				end
			end
		end

		-- updates text for the current selected reporting character and reported alts at the reporting window
		EZReport_Window_RAcctV:SetText(lastTarget.rAccount.." \("..lastTarget.rName.."\)")
		EZReport_Window_RAltsV:SetText(altString)

		if altString == '' then -- hide the alts display if nothing to show
			EZReport_Window_RAltsT:SetHidden(true)
			EZReport_Window_RAltsV:SetHidden(true)
		else
			EZReport_Window_RAltsT:SetHidden(false)
			EZReport_Window_RAltsV:SetHidden(false)
		end

		EZReport_Window:SetHidden(false)
		EZReport_CButton:SetHidden(false)
	else
		ZO_Help_Ask_For_Help_Keyboard_ControlDetailsTextLineField:SetText("")
		ZO_Help_Ask_For_Help_Keyboard_ControlDescriptionBodyField:SetText("")
	end
	
	-- after everything is setup this opens the reporting window with all modifications and pre-configurations
	HELP_CUSTOMER_SUPPORT_KEYBOARD:OpenScreen(HELP_CUSTOMER_SERVICE_ASK_FOR_HELP_KEYBOARD_FRAGMENT)
end

------------------------------------------------------------------------------------------------------------------------------------
-- Addon initialization
------------------------------------------------------------------------------------------------------------------------------------
local function OnAddonLoaded(event, addonName)
	if addonName ~= 'EZReport' then return end
	EVENT_MANAGER:UnregisterForEvent('EZReport', EVENT_ADD_ON_LOADED)
	SCENE_MANAGER:RegisterTopLevel(EZReport_MainFrame, false)
	EZReport.ASV = ZO_SavedVars:NewAccountWide('EZReport_Vars', 1.0, 'AccountSettings', EZReport.Defaults)
	ZO_CreateStringId('SI_BINDING_NAME_EZREPORT_OPEN', L.EZReport_ROpen)
	ZO_CreateStringId('SI_BINDING_NAME_EZREPORT_TARGET', L.EZReport_RLast)
	ZO_CreateStringId('SI_BINDING_NAME_EZREPORT_TARGET_HISTORY', L.EZReport_RHistory)
	EZReport.DBMaintenance()
	EZReport.InitializeHooks()
	EZReport.SetupCharacterDropbox()
	EZReport.CreateSettingsWindow()
end

SLASH_COMMANDS['/ezreport'] = function(option) ShowHistory(option) end
EVENT_MANAGER:RegisterForEvent('EZReport', EVENT_ADD_ON_LOADED, OnAddonLoaded)
EVENT_MANAGER:RegisterForEvent('EZReport', EVENT_RETICLE_TARGET_CHANGED, OnTargetChanged)
