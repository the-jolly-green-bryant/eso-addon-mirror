local GS = GetString

local cspsPost = CSPS.post

function CSPS.attrBtnPlusMinus(i, x, ctrl,alt,shift)
	local myShiftKey = CSPS.savedVariables.settings.jumpShiftKey or 7
	myShiftKey = myShiftKey == 7 and shift or myShiftKey == 4 and ctrl or myShiftKey == 5 and alt or false
	if myShiftKey then x = x * 10 end
	CSPS.attrPoints[i] = CSPS.attrPoints[i] + x
	if CSPS.attrPoints[i] < 0 then CSPS.attrPoints[i] = 0 end
	local diff = CSPS.attrPoints[1] + CSPS.attrPoints[2] + CSPS.attrPoints[3] - CSPS.attrSum()
	if diff > 0 then CSPS.attrPoints[i] = CSPS.attrPoints[i] - diff end
	 CSPS.refreshTree()
	CSPS.showElement("save", true)
	CSPS.unsavedChanges = true
end

function CSPS.showAttrMenu(index)
	ClearMenu() 
	AddCustomMenuItem(GS(SI_GAMEPAD_CRAFTING_QUANTITY_MAX), function() 	
		for i=1,3 do
			CSPS.attrPoints[i] = i == index and CSPS.attrSum() or 0 
		end
		CSPS.refreshTree()
		CSPS.showElement("save", true)
		CSPS.unsavedChanges = true
	end)
	AddCustomMenuItem(GS(SI_GAMEPAD_CRAFTING_QUANTITY_MIN), function() 	
		CSPS.attrPoints[index] = 0 
		CSPS.refreshTree()
		CSPS.showElement("save", true)
		CSPS.unsavedChanges = true
	end)
	ShowMenu()
end		
function CSPS.populateAttributes()
	-- Read current attribute points
	for i=1, 3 do
		CSPS.attrPoints[i] = GetAttributeSpentPoints(i) 
	end
end

function CSPS.attrCompress(attrPoints)
	local attrComp = table.concat(attrPoints, ";")
	return attrComp
end

function CSPS.attrSum()
	return GetAttributeSpentPoints(1) + GetAttributeSpentPoints(2) + GetAttributeSpentPoints(3) + GetAttributeUnspentPoints()
end

function CSPS.attrExtract(attrComp, mySep)
	if attrComp ~= "" and attrComp ~= "-" then
		mySep = mySep or ";"
		CSPS.attrPoints = {SplitString(mySep, attrComp)}
		for i=1, math.max(#CSPS.attrPoints,3) do
			if i > 3 then 
				CSPS.attrPoints[i] = nil
			else
				CSPS.attrPoints[i] = tonumber(CSPS.attrPoints[i]) or 0
			end
		end
	end
end

function CSPS.applyAttr(skipDiag, callOnSuccess, callOnFail)
	callOnSuccess = callOnSuccess or function() end
	callOnFail = callOnFail or callOnSuccess
	if not CSPS.treeIsReady then callOnFail() return end
	local attrToSpend = {}
	local canRespecFromUI = CSPS.canRespecFromUI()
	local freePoints, pointsToSpend = 0, 0
	for i=1, 3 do
		attrToSpend[i] = CSPS.attrPoints[i] -  GetAttributeSpentPoints(i)
		if attrToSpend[i] < 0 then 
			if canRespecFromUI then
				freePoints = freePoints - attrToSpend[i] 
			else
				ZO_Dialogs_ShowDialog(CSPS.name.."_OkDiag", {returnFunc = callOnFail},  {mainTextParams = {GS(CSPS_MSG_ConfirmAttr2)}, titleParams = {GS(CSPS_MSG_ConfirmAttrTitle)}})
				return 
			end
		else 
			pointsToSpend = pointsToSpend + attrToSpend[i]
		end
	end
	if pointsToSpend == 0 then callOnSuccess() return end
	local unspentPoints = GetAttributeUnspentPoints()
	local shouldRespec = false
	if pointsToSpend > unspentPoints then
		if pointsToSpend > unspentPoints + freePoints then 
			local pointsToClear = pointsToSpend - unspentPoints - freePoints
			local pointsToClearSingle = math.floor(pointsToClear / 3)
			local maxIndex, maxValue = false, 0
			local attrIndex = 1
			while pointsToClear > 0 do
				if attrToSpend[attrIndex] > 0 then 
					attrToSpend[attrIndex] = attrToSpend[attrIndex] - 1 
					pointsToClear = pointsToClear - 1
				end
				attrIndex = attrIndex%3 + 1
			end
		end
		shouldRespec = freePoints > 0
			
	end
	local function applyAttrGo() 
		local function tryAgainOnCooldown(respecCooldown)	--getRespecCooldown is part of csps_skills.lua!
			cspsPost(string.format(GS(CSPS_RespecCooldown), math.floor(respecCooldown/100 + 0.5) / 10))
			ZO_Dialogs_ShowDialog("CSPS_RESPEC_COOLDOWN_DIAG", {}, {titleParams = {string.format(GS(CSPS_RespecCooldown), math.floor(respecCooldown/100 + 0.5) / 10)}})
			CSPS.cancelRespecOnCooldown = function()
				EVENT_MANAGER:UnregisterForUpdate(CSPS.name.."_AttrRespecTryAgain")
				callOnFail()
				CSPS.cancelRespecOnCooldown = function() end
			end
			EVENT_MANAGER:RegisterForUpdate(CSPS.name.."_AttrRespecTryAgain", respecCooldown + 60, function()
				EVENT_MANAGER:UnregisterForUpdate(CSPS.name.."_AttrRespecTryAgain")
				CSPS.cancelRespecOnCooldown = function() end
				ZO_Dialogs_ReleaseDialog("CSPS_RESPEC_COOLDOWN_DIAG")
				applyAttrGo()
			end)
		end
		EVENT_MANAGER:UnregisterForUpdate(CSPS.name.."_AttrRespecTryAgain")
		
		
		if shouldRespec then
			if GetInteractionType() == INTERACTION_ATTRIBUTE_RESPEC then
				STATS:SetAttributePointAllocationMode(ATTRIBUTE_POINT_ALLOCATION_MODE_PURCHASE_FULL)
				STATS:UpdateSpendablePoints()
				KEYBIND_STRIP:UpdateKeybindButtonGroup(STATS.keybindButtons)
			else
				EVENT_MANAGER:RegisterForUpdate(CSPS.name.."_AttrRespecStartFail", 1420, function()
					EVENT_MANAGER:UnregisterForEvent(CSPS.name.."_AttrRespecStart", EVENT_START_ATTRIBUTE_RESPEC)
					EVENT_MANAGER:UnregisterForUpdate(CSPS.name.."_AttrRespecStartFail")
					CSPS.cspsD("Attr Respec failed")
					callOnFail()
				end)
				EVENT_MANAGER:RegisterForEvent(CSPS.name.."_AttrRespecStart", EVENT_START_ATTRIBUTE_RESPEC, function(_, allocationMode)
					EVENT_MANAGER:UnregisterForEvent(CSPS.name.."_AttrRespecStart", EVENT_START_ATTRIBUTE_RESPEC)
					EVENT_MANAGER:UnregisterForUpdate(CSPS.name.."_AttrRespecStartFail")
					if allocationMode ~= ATTRIBUTE_POINT_ALLOCATION_MODE_FULL then return end
					CSPS.cspsD("Attr Respec started")
					applyAttrGo()
				end)
				SCENE_MANAGER:Show("stats")
				zo_callLater(function() StartAttributeRespecFromUI() end, 420)
				return
			end
			EVENT_MANAGER:RegisterForEvent(CSPS.name.."_AttrRespec", EVENT_ATTRIBUTE_RESPEC_RESULT, 
				function(_, respecResult)
					if respecResult == RESPEC_RESULT_ON_COOLDOWN_ATTRIBUTES then 
						local respecCooldown = CSPS.getRespecCooldown()
						respecCooldown = respecCooldown and respecCooldown > 2000 and respecCooldown or 2000
						CSPS.setRespecCooldown(respecCooldown)
						tryAgainOnCooldown(respecCooldown)
					elseif respecResult == RESPEC_RESULT_SUCCESS then
						callOnSuccess() 
					else
						callOnFail(respecResult) 
					end
		
					EVENT_MANAGER:UnregisterForEvent(CSPS.name.."_AttrRespec", EVENT_ATTRIBUTE_RESPEC_RESULT)
				end)
			--STATS.attributeControls[i].pointLimitedSpinner:SetAddedPointsByTotalPoints(10)
			for i, attributeControl in pairs(STATS.attributeControls) do
				attributeControl.pointLimitedSpinner.pointsSpinner:SetValue(0)
			end
			for i, attributeControl in pairs(STATS.attributeControls) do
				attributeControl.pointLimitedSpinner.pointsSpinner:SetValue(CSPS.attrPoints[i])
			end
			SendAttributePointAllocationRequest(RESPEC_PAYMENT_TYPE_GOLD, unpack(attrToSpend))
		else
			PurchaseAttributes(unpack(attrToSpend))
			callOnSuccess()
		end
	end
	if not skipDiag then
		local diagText = {zo_strformat(GS(CSPS_MSG_ConfirmAttr), pointsToSpend, freePoints > 0 and unspentPoints.." (+"..freePoints..")" or unspentPoints),
			"",
			CSPS.cpColors[3]:Colorize(string.format("%s: %s", GS(SI_ATTRIBUTES1), attrToSpend[1])),
			CSPS.cpColors[2]:Colorize(string.format("%s: %s", GS(SI_ATTRIBUTES2), attrToSpend[2])),
			CSPS.cpColors[1]:Colorize(string.format("%s: %s", GS(SI_ATTRIBUTES3), attrToSpend[3])),
			}
		diagText = table.concat(diagText, "\n")
		ZO_Dialogs_ShowDialog(CSPS.name.."_OkCancelDiag", 
			{returnFunc = function() 
				applyAttrGo()
			end,
			cancelFunc = callOnFail},  			
			{mainTextParams = {diagText}, titleParams = {GS(CSPS_MSG_ConfirmAttrTitle)}})
	else
		applyAttrGo()
	end
end
