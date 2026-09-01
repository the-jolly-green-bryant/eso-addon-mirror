MARK = MARK or { }

-- PERFORMANCE: Localize globals for UI and update loops
local EM = EVENT_MANAGER
local t_insert = table.insert
local t_sort = table.sort
local t_remove = table.remove
local t_tostring = tostring
local t_tonumber = tonumber
local m_sqrt = math.sqrt
local getPlayerPos = GetUnitRawWorldPosition

function MARK.OnUIMove()
	MARK.savedVars.left = MarkerUI:GetLeft()
	MARK.savedVars.top = MarkerUI:GetTop()
	MARK.savedVars.width = MarkerUI:GetWidth()
	MARK.savedVars.height = MarkerUI:GetHeight()
	MARK.RefreshList()
end

function MARK.LeftMenuChangeView()
	MARK.AdjustRightMenuVisibility(false)
	MARK.hideall()
	EM:UnregisterForUpdate(MARK.name .. "UpdateView")
    
	if MARK.UI.ShownMenu ~= 1 or MARK.loadedProfile == nil then
		MARK.UI.ShownMenu = 1
		MarkerUIBodyLeftSwitchLabel:SetText("Profiles (1/2)")
		RightProfileView:SetHidden(false)
		RightMarkerView:SetHidden(true)
		MarkerUIBodyLeftDistanceSettingOff:SetHidden(true)
		MarkerUIBodyLeftDistanceSettingOn:SetHidden(true)
		MARK.RefreshList()
		if MARK.loadedProfile == nil then
			MARK.notify("No profile selected.")
		end
	else
		MARK.UI.ShownMenu = 0
		MarkerUIBodyLeftSwitchLabel:SetText("Markers (2/2)")
		RightProfileView:SetHidden(true)
		RightMarkerView:SetHidden(false)
		if MARK.UI.FilterCloseOnly == 1 then
			MarkerUIBodyLeftDistanceSettingOff:SetHidden(true)
			MarkerUIBodyLeftDistanceSettingOn:SetHidden(false)
		else
			MarkerUIBodyLeftDistanceSettingOff:SetHidden(false)
			MarkerUIBodyLeftDistanceSettingOn:SetHidden(true)
		end
		MARK.RefreshList()
		EM:RegisterForUpdate(MARK.name .. "UpdateView", 250, MARK.RefreshList)
	end
end

function MARK.LeftMenuFilter()
	MARK.AdjustRightMenuVisibility(false)
	if MARK.UI.FilterCloseOnly == 0 then
		MARK.UI.FilterCloseOnly = 1
		MarkerUIBodyLeftDistanceSettingOff:SetHidden(true)
		MarkerUIBodyLeftDistanceSettingOn:SetHidden(false)
	else
		MARK.UI.FilterCloseOnly = 0
		MarkerUIBodyLeftDistanceSettingOff:SetHidden(false)
		MarkerUIBodyLeftDistanceSettingOn:SetHidden(true)
	end
	MARK.RefreshList()
end

function MARK.ItemClick(id)
	MARK.AdjustRightMenuVisibility(false)
	if MARK.UI.ShownMenu == 1 then
		if ((MARK.loadedProfile or {}).data or {}).id == id then
			MARK.unloadProfile(true)
		else
			MARK.loadProfile(id)
		end
	else
		local profile = MARK.loadedProfile
		if profile == nil then MARK.notify("err") return end
		profile:getMarkerObject(id):toggle()
	end
	MARK.RefreshList()
end

function MARK.ItemClickEdit(id)
	MARK.hideall()
	if MARK.UI.ShownMenu == 1 then
		MARKEditProfile:new(id)
	else
		MARKEditMarker:new(id)
	end
	MARK.AdjustRightMenuVisibility(true)
	MARK.RefreshList()
end

function MARK.ShowAlert(callback)
	if MARK.savedVars.alertDismissed == true then return false end
	MARK.alertCallback = callback
	MarkerUIAlert:SetHidden(false)
	return true
end

function MARK.ItemClickShare(id)
	if MARK.ShowAlert(function() MARK.ItemClickShare(id) end) then return end
	if MARK.UI.ShownMenu == 1 then
		MARK.shareprofilemessages = MARK.ShareProfileInChat(id)
		MARK.shareprofilemessagesindex = 1
		EM:UnregisterForEvent("MarkerChatMessageEvent", EVENT_CHAT_MESSAGE_CHANNEL)
		MARK.SetChatAndCallbackWhenSent()
		EM:RegisterForEvent("MarkerChatMessageEvent", EVENT_CHAT_MESSAGE_CHANNEL, function(eid, channel, from, message)
			if message:find(MARK.messagePrefixProfile, 1, true) ~= nil then
				MARK.SetChatAndCallbackWhenSent()
			end
		end)
	else
		MARK.AdjustRightMenuVisibility(false)
		local profile = MARK.loadedProfile
		if profile == nil then return end
		local marker = profile:getMarkerObject(id)
		if marker == nil then return end
		LibAkaUtils.setChat("/p " .. marker:toString(profile.data.zone))
	end
	MARK.RefreshList()
end

function MARK.AdjustRightMenuVisibility(visible)
	if MARK.UI.ShownMenu == 1 then
		MARK.AdjustRightMenuProfileVisibility(visible)
		MARK.AdjustRightMenuMarkerVisibility(false)
	else
		MARK.AdjustRightMenuMarkerVisibility(visible)
		MARK.AdjustRightMenuProfileVisibility(false)
	end
	MARK.RefreshList()
end

function MARK.AdjustRightMenuProfileVisibility(visible)
	if visible == true then
		local profile = MARK.UI.Edit.Profile
		if profile == nil then return end
		RightProfileViewInput1:SetText(profile.name)
		RightProfileViewInput1:SetEditEnabled(true)
		RightProfileViewBackdrop1:SetAlpha(1)
		RightProfileViewImport:SetEnabled(true)
		RightProfileViewExport:SetEnabled(true)
		RightProfileViewImport:SetAlpha(1)
		RightProfileViewExport:SetAlpha(1)
		RightProfileViewOnLoad:SetEnabled(true)
		RightProfileViewOnUnload:SetEnabled(true)
		RightProfileViewOnLoad:SetAlpha(1)
		RightProfileViewOnUnload:SetAlpha(1)
		RightProfileViewSave:SetHidden(false)
	else
		RightProfileViewInput1:SetText("")
		RightProfileViewInput1:SetEditEnabled(false)
		RightProfileViewBackdrop1:SetAlpha(0.3)
		RightProfileViewImport:SetEnabled(false)
		RightProfileViewExport:SetEnabled(false)
		RightProfileViewImport:SetAlpha(0.3)
		RightProfileViewExport:SetAlpha(0.3)
		RightProfileViewOnLoad:SetEnabled(false)
		RightProfileViewOnUnload:SetEnabled(false)
		RightProfileViewOnLoad:SetAlpha(0.3)
		RightProfileViewOnUnload:SetAlpha(0.3)
		RightProfileViewSave:SetHidden(true)
	end
	MARK.RefreshList()
end

function MARK.AdjustRightMenuMarkerVisibility(visible)
	if visible == true then
		local marker = MARK.UI.Edit.Marker
		if marker == nil then return end
		MARK.UI.SelectedTexture = marker.texture
		RightMarkerViewInput1:SetText(marker.x)
		RightMarkerViewInput2:SetText(marker.y)
		RightMarkerViewInput3:SetText(marker.z)
		RightMarkerViewInput4:SetText(marker.size)
		RightMarkerViewTextureEdit:SetNormalTexture(LibEmote.GetEmoteByIndex(marker.texture).textures[1])
		RightMarkerViewInput1:SetEditEnabled(true)
		RightMarkerViewInput2:SetEditEnabled(true)
		RightMarkerViewInput3:SetEditEnabled(true)
		RightMarkerViewInput4:SetEditEnabled(true)
		RightMarkerViewBackdrop1:SetAlpha(1)
		RightMarkerViewBackdrop2:SetAlpha(1)
		RightMarkerViewBackdrop3:SetAlpha(1)
		RightMarkerViewBackdrop4:SetAlpha(1)
		RightMarkerViewBackdrop5:SetAlpha(1)
		RightMarkerViewFunction:SetEnabled(true)
		RightMarkerViewFunction:SetAlpha(1)
		RightMarkerViewSave:SetHidden(false)
	else
		RightMarkerViewInput1:SetText("")
		RightMarkerViewInput2:SetText("")
		RightMarkerViewInput3:SetText("")
		RightMarkerViewInput4:SetText("")
		RightMarkerViewInput1:SetEditEnabled(false)
		RightMarkerViewInput2:SetEditEnabled(false)
		RightMarkerViewInput3:SetEditEnabled(false)
		RightMarkerViewInput4:SetEditEnabled(false)
		RightMarkerViewBackdrop1:SetAlpha(0.3)
		RightMarkerViewBackdrop2:SetAlpha(0.3)
		RightMarkerViewBackdrop3:SetAlpha(0.3)
		RightMarkerViewBackdrop4:SetAlpha(0.3)
		RightMarkerViewBackdrop5:SetAlpha(0.3)
		RightMarkerViewFunction:SetEnabled(false)
		RightMarkerViewFunction:SetAlpha(0.3)
		RightMarkerViewSave:SetHidden(true)
	end
	MARK.RefreshList()
end

function MARK.ItemClickRemove(id)
	MARK.AdjustRightMenuVisibility(false)
	if MARK.UI.ShownMenu == 1 then
		local profile = MARK.getProfile(id)
		if profile == nil then MARK.notify("err") return end
		profile:remove()
	else
		local profile = MARK.loadedProfile
		if profile == nil then MARK.notify("err") return end
		profile:removeMarker(id)
	end
	MARK.RefreshList()
end

function MARK.SetupUnitRow(control, data)
	control.data = data
	
    -- PERFORMANCE FIX: Cache UI control lookups to prevent searching the UI tree every frame
	control.label = control.label or GetControl(control, "Label")
	control.share = control.share or GetControl(control, "Share")

	if MARK.UI.ShownMenu == 1 then
		if ((MARK.loadedProfile or {}).data or {}).id == data.id then
			control.label:SetColor(0, 1, 0, 1)
		else
			control.label:SetColor(1, 1, 1, 1)
		end
		control.label:SetText(data.name .. " (" .. data.size .. " Marker)")
		control.share:SetHidden(false)
	else
		if data.marked == true then
			control.label:SetColor(0, 1, 0, 1)
		else
			control.label:SetColor(1, 1, 1, 1)
		end
        
        -- PERFORMANCE FIX: Use the pre-cached texture message and localized math.sqrt
		local text = data.texMsg .. " - " .. LibAkaUtils.formatDistance(m_sqrt(data.distance))
		control.label:SetText(text)
		control.share:SetHidden(false)
	end
end

function MARK.InitList()
	ZO_ScrollList_AddDataType(MarkerList, 1, "MarkerUIUnitRow", 40, MARK.SetupUnitRow)
end

function MARK.TriggerHistorySet()
	t_insert(MARK.UI.SelectedTextureHistory, 1, t_tostring(MARK.UI.SelectedTexture))
	if #MARK.UI.SelectedTextureHistory > 2 then
		t_remove(MARK.UI.SelectedTextureHistory, 3)
	end
	RightMarkerViewTextureHistory1:SetNormalTexture(LibEmote.GetEmoteByIndex(MARK.UI.SelectedTextureHistory[1]).textures[1])
	RightMarkerViewTextureHistory2:SetNormalTexture(LibEmote.GetEmoteByIndex(MARK.UI.SelectedTextureHistory[2]).textures[1])
	MARK.RefreshList()
end

function MARK.LoadHistory(index)
	local hist = t_tostring(MARK.UI.SelectedTextureHistory[index] or "")
	MARK.TriggerHistorySet()
	MARK.UI.SelectedTexture = hist
	RightMarkerViewTextureEdit:SetNormalTexture(LibEmote.GetEmoteByIndex(MARK.UI.SelectedTexture).textures[1])
	MARK.saveData()
	MARK.RefreshList()
end

-- PERFORMANCE FIX: Create a persistent cache table to prevent massive GC spikes 
-- from creating a new table every 250ms.
MARK._listDataCache = MARK._listDataCache or {}

function MARK.RefreshList()
	if MarkerUI:IsHidden() == true then
		EM:UnregisterForUpdate(MARK.name .. "UpdateView")
		return
	end
    
	local scrollData = ZO_ScrollList_GetDataList(MarkerList)
	ZO_ScrollList_Clear(MarkerList)

	local profile = MARK.loadedProfile
    
    -- PERFORMANCE FIX: Reuse the cached table instead of `local data = {}`
	local data = MARK._listDataCache
    ZO_ClearNumericallyIndexedTable(data)

	if MARK.UI.ShownMenu == 1 then
		local zoneId = getPlayerPos("player")
		for _, v in pairs(MARK.getZoneProfilesData(zoneId) or {}) do
			local markerCount = 0
			for _ in pairs(v.marker) do
				markerCount = markerCount + 1
			end
			t_insert(data, {
				id = t_tostring(v.id),
				name = t_tostring(v.name),
				size = markerCount
			})
		end
		t_sort(data, function(a, b)
			return a.name < b.name
		end)
	else
		if profile ~= nil then 
            local radSq = MARK.savedVars.radius * MARK.savedVars.radius
            local filterClose = MARK.UI.FilterCloseOnly == 1
            
			for _, v in pairs(profile.markerObjects) do
                local dist = v.distance or 0
                
				if not filterClose or dist < radSq then
                    -- PERFORMANCE FIX: Cache the expensive TextureMessage string on the marker object
                    -- so it doesn't have to be recalculated every frame for every visible row.
                    if not v._cachedTexMsg then
                        local tex = LibEmote.GetEmoteByIndex(v.data.texture).textures[1]
                        v._cachedTexMsg = LibAkaUtils.TextureMessage(26, tex)
                    end
                    
					t_insert(data, {
						id = t_tostring(v.data.id),
						texture = t_tostring(v.data.texture),
						distance = t_tonumber(dist),
						marked = v:isMarked(),
                        texMsg = v._cachedTexMsg
					})
				end
			end
			t_sort(data, function(a, b)
				return a.distance < b.distance
			end)
		end
	end
    
	for i = 1, #data do
		scrollData[#scrollData + 1] = ZO_ScrollList_CreateDataEntry(1, data[i])
	end
	ZO_ScrollList_Commit(MarkerList)
end

function MARK.toDonate()
	SCENE_MANAGER:Show('mailSend')
	zo_callLater(function()
		ZO_MailSendToField:SetText(MARK.addonInfo.author)
		ZO_MailSendSubjectField:SetText(MARK.addonInfo.title.." - Donation")
		ZO_MailSendBodyField:SetText("")
		QueueMoneyAttachment(100000)
		ZO_MailSendBodyField:TakeFocus()
	end, 200)
end

function MARK.export()
	local prf = MARK.UI.Edit.Profile
	if prf == nil then return end
	MARK.hideall()
	MarkerUIGetConfigInput1:SetText("")
	MarkerUIGetConfigInput2:SetText("")
	MarkerUIGetConfigInput3:SetText("")
	local profile = MARK.getProfile(prf.id)
	if profile == nil then return end
	local elms = profile:getElmsConfig()
	local marker = profile:getConfig()
	local markerJson = profile:getJsonConfig()
	MarkerUIGetConfig:SetHidden(false)
	MarkerUIGetConfigInput1:SetText(elms)
	MarkerUIGetConfigInput2:SetText(marker)
	MarkerUIGetConfigInput3:SetText(markerJson)
end

function MARK.import()
	MARK.hideall()
	MarkerUISetConfig:SetHidden(false)
end

function MARK.saveImport()
	local profile = MARK.UI.Edit.Profile
	if profile == nil then return end
	if MarkerUISetConfigInput:GetText() ~= "" then 
		profile:setConfig(MarkerUISetConfigInput:GetText())
	end
	MarkerUISetConfigInput:SetText("")
	MarkerUISetConfig:SetHidden(true)
end

function MARK.hideall()
	MarkerUIImportSizeSelector:SetHidden(true)
	MarkerUIGetConfig:SetHidden(true)
	MarkerUISetCode:SetHidden(true)
	MarkerUISetConfig:SetHidden(true)
	if MARK._codeWindowElement == nil then
		MARK._codeWindowElement = LibLuaCodeWindow:new(MarkerUISetCodeBody)
	end
	MARK._codeWindowElement:hide()
end

function MARK.codeWindow(isProfile, isProfileOnLoad)
	MARK.hideall()
	MARK._codeWindowElement:show()
	if isProfile == true then
		local profile = MARK.UI.Edit.Profile
		if profile == nil then return end
		local text = ""
		if isProfileOnLoad == true then
			text = profile.onLoad or ""
		else
			text = profile.onUnload or ""
		end
		if t_tostring(text) == "nil" then text = "" end
		MarkerUISetCode:SetHidden(false)
		MARK._codeWindowElement:setText(text)
		MarkerUISetCodeSave:SetHandler("OnClicked", function()
			if MARK._codeWindowElement:getText() ~= "" then 
				if isProfileOnLoad == true then
					profile:setOnLoad(MARK._codeWindowElement:getText())
				else
					profile:setOnUnload(MARK._codeWindowElement:getText())
				end
			else
				if isProfileOnLoad == true then
					profile:setOnLoad(nil)
				else
					profile:setOnUnload(nil)
				end
			end
			MARK._codeWindowElement:setText("")
			MarkerUISetCode:SetHidden(true)
		end)
	else
		local marker = MARK.UI.Edit.Marker
		if marker == nil then return end
		local text = marker.requirement or ""
		if t_tostring(text) == "nil" then text = "" end
		MarkerUISetCode:SetHidden(false)
		MARK._codeWindowElement:setText(text)
		MarkerUISetCodeSave:SetHandler("OnClicked", function()
			if MARK._codeWindowElement:getText() ~= "" then 
				marker:setRequirement(MARK._codeWindowElement:getText())
			else
				marker:setRequirement(nil)
			end
			MARK._codeWindowElement:setText("")
			MarkerUISetCode:SetHidden(true)
		end)
	end
	MARK.RefreshList()
end