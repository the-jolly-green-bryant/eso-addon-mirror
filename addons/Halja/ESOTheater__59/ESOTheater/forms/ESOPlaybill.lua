ESOTheater.ESOPlaybill = {}
local IsConfigurationMode = false
local ET = ESOTheater

function ET.SetEmoteListItem(control,data)
	control:SetWidth(ET.TweaksUI.EmoteConfigWindow.ButtonSize)
	local listitemtext = control:GetNamedChild( "Name" )
	listitemtext:SetText( data.EmoteName )
	listitemtext:SetColor(0.77,0.76,0.62,1)
	listitemtext:SetWidth(ET.TweaksUI.EmoteConfigWindow.ButtonSize - 10)
end

function ET.ESOPlaybill:FillScrollList()
	local control = GetControl("PlaybillFrameList")
	ZO_ScrollList_Clear(control)
	
	local tblCategory = ET.EmoteData.CategoryTable
	for k  in pairs (tblCategory) do
		--ZO_ScrollList_AddCategory(control, tblCategory[k])
		ZO_ScrollList_AddCategory(control, k)
	end
	
    local datalist = ZO_ScrollList_GetDataList(control)
	local tblemote = ET.EmoteData.EmoteTable
	local listsize = ET.TableSize( tblemote )
	
	for i = 1, listsize do
		local emotecatid = ET.CategoryIdByName(tblemote[i].Category)
		datalist[i] = ZO_ScrollList_CreateDataEntry( 1, 
		{
			EmoteName = tblemote[i].EmoteName,
			ID = tblemote[i].ID,			
		},
		emotecatid
		--tblemote[i].Category
		)
	end
	
	ZO_ScrollList_Commit(control, datalist)
	--control:RefreshData()
end


function ET.ESOPlaybill:Initialize()
	local control = GetControl("PlaybillFrameList")
	control:SetHeight(300)
	control:SetWidth(125)
	ZO_ScrollList_AddDataType(control, 1 , "PlaybillListItemTemplate", 20,  ET.SetEmoteListItem)
	ET.ESOPlaybill:FillScrollList()
end

function ET.ESOPlaybill:ToggleWindow()
	local control = GetControl("PlaybillFrame")
    if ( control:IsHidden() ) then
		ET.ESOPlaybill:Show()
	else
		control:SetHidden( true )
    end
end

function ET.ESOPlaybill:PlaybillFrameOnSave()
	local lastEmote = ET.GetLastEmote()
	if (lastEmote.ID > 0) then
		local control = GetControl("PlaybillFrame")
		local statuspaneltxt = control:GetNamedChild("StatusLabel")
		local btntochange = statuspaneltxt:GetText()
		if ET.IsVerbose() then
			ET.PrintSystemChat( string.format("Going to change %s to emote id %d ( %s )" , btntochange, lastEmote.ID, lastEmote.Name))
		end
		ET.ESOStage:FavoriteButtonOnChange(btntochange, lastEmote.ID)
	end
	ET.ESOPlaybill:Hide()
end


function ET.ESOPlaybill:Show(aname)
	local width
	local height
	local control = GetControl("PlaybillFrame")
	if (control:IsHidden()) then
		ET.SetLastEmote("",0)
		control:SetHidden( false )
		local emotelabel = GetControl("PlaybillFrameBottomPanelStatusEmote")
		emotelabel:SetText("")

		local WindowTitle =GetControl("PlaybillFrameHeaderPanelTitle")
		local btnSave = control:GetNamedChild("ButtonSave")
		local btnCancel = control:GetNamedChild("ButtonCancel")
		
		local tblemote = ET.EmoteData.EmoteTable
		
		btnSave:SetText(ET.AddOnStrings.EN_SAVE)
		btnCancel:SetText(ET.AddOnStrings.EN_CANCEL)
		
		if (aname ~= nil) then
			IsConfigurationMode = true
			width = ET.TweaksUI.EmoteConfigWindow.WindowMaxWidth
			height = ET.TweaksUI.EmoteConfigWindow.WindowMaxHeight
			ET.ESOStage:MinimizeWindowToggle()
			local statuspaneltxt = control:GetNamedChild("StatusLabel")
			statuspaneltxt:SetText(string.sub(aname,13))
			if ET.IsVerbose() then
				statuspaneltxt:SetHidden( false )
			else
				statuspaneltxt:SetHidden( true )
			end
			local apanel =  control:GetNamedChild("List")
			apanel:SetHeight( height - 120 )
			apanel:SetWidth( ET.TweaksUI.EmoteConfigWindow.ButtonSize )
			
			local apanel =  control:GetNamedChild("BottomPanel")
			apanel:SetWidth( width - 5 )
			apanel:SetHeight( 45 )
			local child =  apanel:GetNamedChild("StatusEmote")
			child:ClearAnchors()
			child:SetAnchor( CENTER, apanel, TOP, 0, 2)
			btnSave:SetHidden( false )
			btnCancel:SetHidden( false )
		else
			IsConfigurationMode = false
			width = ET.TweaksUI.EmoteConfigWindow.WindowMinWidth
			height = ET.TweaksUI.EmoteConfigWindow.WindowMinHeight
			local apanel =  control:GetNamedChild("List")
			apanel:SetHeight( height - 110 )
			apanel:SetWidth( ET.TweaksUI.EmoteConfigWindow.ButtonSize )
			
			local apanel =  control:GetNamedChild("BottomPanel")
			apanel:SetWidth( width - 5 )
			apanel:SetHeight( 35 )
			local child =  apanel:GetNamedChild("StatusEmote")
			child:ClearAnchors()
			child:SetAnchor( CENTER, apanel, CENTER, nil, nil)
			btnSave:SetHidden( true )
			btnCancel:SetHidden( true )
		end
		control:SetWidth(width)
		control:SetHeight(height)
		local apanel =  control:GetNamedChild("HeaderPanel")
		apanel:SetWidth( width - 5 )
		local apanel =  control:GetNamedChild("CenterPanel")
		apanel:SetWidth( width - 5 )
		apanel:SetHeight( height- 5 )
		
	else
		if (aname ~= nil) then
			ET.ESOPlaybill:Hide()	
			ET.ESOPlaybill:Show(aname)
		end
	end	
end

function ET.ESOPlaybill:Hide()
	local control = GetControl("PlaybillFrame")
	control:SetHidden( true )
	if (IsConfigurationMode == true) then
		ET.ESOStage:MinimizeWindowToggle()
	end
end

function ET.ESOPlaybill:MoveWindow( x, y )
		local mainframe = GetControl("PlaybillFrame")
		mainframe:ClearAnchors()
		mainframe:SetAnchor( TOPLEFT, GetControl("GuiRoot"), TOPLEFT, x, y)
end

function ET.ESOPlaybill:SaveWindowPosition()
	local mainframe = GetControl("PlaybillFrame")
	local x =mainframe:GetLeft()
	local y = mainframe:GetTop()
	if ET.IsVerbose() then
		ET.PrintSystemChat( string.format("Top and Left inside GuiRoot= %d : %d",x ,y ))
	end
	ET.CurrentSVars.UserSettings.PlaybillLocation.Xoffset = x
	ET.CurrentSVars.UserSettings.PlaybillLocation.Yoffset = y
end

function ET.ESOPlaybill:LoadCategoryFilters()
	local comboBox = ZO_ComboBox_ObjectFromContainer(PlaybillFrameComboBox01)
	comboBox:SetSortsItems(false)
	comboBox:SetSpacing(4)
	
	local function OnFilterChanged(comboBox, entryText, entry)
		if ET.IsVerbose() then
			ET.PrintSystemChat( string.format("%s", entryText ))
		end
		local emotecatid = ET.CategoryIdByName(entryText)
		local control = GetControl("PlaybillFrameList")
		ZO_ScrollList_HideAllCategories(control)
		if (emotecatid > 1) then
			ZO_ScrollList_ShowCategory(control, emotecatid)
		else
			for k  in ipairs (ET.EmoteData.CategoryTable) do
				ZO_ScrollList_ShowCategory(control, k)
			end
		end
	end
		
	local tblCategory = ET.EmoteData.CategoryTable
	
	for k  in ipairs (tblCategory) do
		local entry = comboBox:CreateItemEntry(tblCategory[k], OnFilterChanged)
		comboBox:AddItem(entry)
	end
	
	comboBox:SetSelectedItem("ALL")	
end
