
function AdvancedGroupRoster.InitializePlayerArray(playerName)
	if AdvancedGroupRoster.SV.raidAttendance == false then
		return
	end

	local playerName = zo_strformat("<<1>>", playerName)

	if string.len(playerName) <= 0 or playerName == 'Offline' then
		return
	end

	if AdvancedGroupRoster.currentSession.players[playerName] == nil then
		local defaultPlayerArray = {}

		defaultPlayerArray.atName = 'Unknown'
		defaultPlayerArray.startTime = os.time()
		defaultPlayerArray.timeInGroup = 0

		AdvancedGroupRoster.currentSession.players[playerName] = defaultPlayerArray
	end
end

function AdvancedGroupRoster.UpdateTimeInGroup(playerName)
	if AdvancedGroupRoster.SV.raidAttendance == false then
		return
	end

	if AdvancedGroupRoster.currentSession.players[playerName] ~= nil then
		if AdvancedGroupRoster.currentSession.players[playerName].startTime ~= 0 then
			local totalTime = AdvancedGroupRoster.GetTotalTime(AdvancedGroupRoster.currentSession.players[playerName].startTime, AdvancedGroupRoster.currentSession.players[playerName].timeInGroup)

			AdvancedGroupRoster.currentSession.players[playerName].timeInGroup = totalTime
		end

		if IsPlayerInGroup(playerName) == false then
			AdvancedGroupRoster.currentSession.players[playerName].startTime = 0
		else
			AdvancedGroupRoster.currentSession.players[playerName].startTime = os.time()
		end
	end
end

function AdvancedGroupRoster.GetTotalTime(startTime, currentTotalTime)
	return currentTotalTime + -(os.difftime(startTime, os.time()))
end

function AdvancedGroupRoster.SecondsToClock(seconds)
	local seconds = tonumber(seconds)

	if seconds <= 0 then
		return "00:00:00";
	else
		hours = string.format("%02.f", math.floor(seconds/3600));
		mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)));
		secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60));
		return hours..":"..mins..":"..secs
	end
end

function AdvancedGroupRoster.UpdateGroupTime()
	if AdvancedGroupRoster.SV.raidAttendance == false then
		return
	end

	for playerName, playerInfo in pairs(AdvancedGroupRoster.currentSession.players) do
		AdvancedGroupRoster.UpdateTimeInGroup(playerName)
	end
end

function AdvancedGroupRoster.ClearRaidAttendance()
	AdvancedGroupRoster.currentSession = {
		players = {}
	}

	AdvancedGroupRoster.SV.dump = {}
end

function AdvancedGroupRoster.UpdateAttendance()
	if AdvancedGroupRoster.SV.raidAttendance == false then
		return
	end

	AdvancedGroupRoster.ExportRaidAttendance(true)
end

function AdvancedGroupRoster.ImportRaidAttendance()
	AdvancedGroupRoster.currentSession = {
		players = {}
	}

	local currentSection = ''
	local playerIndexes = {}
	local index = 0

	for _, text in pairs(AdvancedGroupRoster.SV.dump) do
		if text == 'Characters' or text == 'UserID' or text == 'Time' or text == '' then
			currentSection = text
			index = -1
		else
			if currentSection == 'Characters' then
				local defaultPlayerArray = {}

				defaultPlayerArray.atName = 'Unknown'

				if IsPlayerInGroup(text) == false then
					defaultPlayerArray.startTime = 0
				else
					defaultPlayerArray.startTime = os.time()
				end

				defaultPlayerArray.timeInGroup = 0

				AdvancedGroupRoster.currentSession.players[text] = defaultPlayerArray

				playerIndexes[index] = text
			elseif currentSection == 'UserID' or currentSection == 'Time' then
				local playerName = playerIndexes[index]

				if currentSection == 'UserID' then
					AdvancedGroupRoster.currentSession.players[playerName].atName = text
				elseif currentSection == 'Time' then
					AdvancedGroupRoster.currentSession.players[playerName].timeInGroup = AdvancedGroupRoster.ClockToSeconds(text)
				end
			end
		end
		
		index = index + 1
	end

	AdvancedGroupRoster.UpdateGroupTime()
end

function AdvancedGroupRoster.ExportRaidAttendance(automatic)
	local dump = AdvancedGroupRoster.SV.dump

	-- clear out old export, in case this one is smaller then last one, so they don't combine
	dump = {}

	AdvancedGroupRoster.UpdateGroupTime()

	dump[1] = "Characters"

	local i = 2

	if AdvancedGroupRoster.currentSession.players ~= nil then
		for playerName, playerInfo in pairs(AdvancedGroupRoster.currentSession.players) do
			dump[i] = playerName
			i = i + 1
		end
	end

	dump[i] = ""
	i = i + 1
	dump[i] = "UserID"
	i = i + 1

	if AdvancedGroupRoster.currentSession.players ~= nil then
		for playerName, playerInfo in pairs(AdvancedGroupRoster.currentSession.players) do
			dump[i] = playerInfo.atName
			i = i + 1
		end
	end

	dump[i] = ""
	i = i + 1
	dump[i] = "Time"
	i = i + 1

	if AdvancedGroupRoster.currentSession.players ~= nil then
		for playerName, playerInfo in pairs(AdvancedGroupRoster.currentSession.players) do
			dump[i] = AdvancedGroupRoster.SecondsToClock(playerInfo.timeInGroup)
			i = i + 1
		end
	end

	if automatic == false then
		d("Raid Attendance dump complete. Reload your UI (command /reloadui) and then review the file SavedVariables file following directions found in the addon's settings or description.")
	end
end

function AdvancedGroupRoster.ToggleReport()
	if AdvancedGroupRosterReport._isHidden == true then
		AdvancedGroupRoster.OpenReport()
	elseif AdvancedGroupRosterReport._isHidden == false then
		AdvancedGroupRoster.CloseReport()
	else
		AdvancedGroupRoster.OpenReport()
	end
end

function AdvancedGroupRoster.CloseReport()
    AdvancedGroupRosterReport:SetHidden(true)
	AdvancedGroupRosterReport._isHidden = true;
end

function AdvancedGroupRoster.OpenReport()
	AdvancedGroupRoster.UpdateGroupTime()

    AdvancedGroupRosterReport:SetHidden(false)
	AdvancedGroupRosterReport._isHidden = false;

	AdvancedGroupRoster.UpdateTables()
end

function AdvancedGroupRoster.PopupOnMoveStop()
	AdvancedGroupRoster.SV.popupLeft = HealCounterReport:GetLeft();
	AdvancedGroupRoster.SV.popupTop = HealCounterReport:GetTop();
end

function AdvancedGroupRoster.UpdateTables()
	if AdvancedGroupRoster.players_table ~= nil then
		local tkw = AdvancedGroupRoster.players_table

		tkw.DataLines = {}

		if AdvancedGroupRoster.currentSession.players ~= nil then
			for playerName, playerInfo in pairs(AdvancedGroupRoster.currentSession.players) do
				local data = {["name"] = playerName, ["timeInGroup"] = AdvancedGroupRoster.SecondsToClock(playerInfo.timeInGroup), ["atName"] = playerInfo.atName}
				table.insert(tkw.DataLines, data)
			end
		end
	end

	AdvancedGroupRoster.UpdateSessionPlayersTable()
end

function AdvancedGroupRoster.UpdateSessionPlayersTable(...)
    if AdvancedGroupRoster.players_table == nil then
		return
	end

    local tlw = AdvancedGroupRoster.players_table

    tlw.DataOffset = tlw.DataOffset or 0

    if tlw.DataOffset < 0 then
		tlw.DataOffset = 0
	end

    if AdvancedGroupRoster.tablelength(tlw.DataLines) == 0 then 
		return
	end

    tlw.Slider:SetMinMax(0, AdvancedGroupRoster.tablelength(tlw.DataLines) - tlw.MaxLines)

	local pk = tlw.DataOffset

    for i = 2,tlw.MaxLines do
        if pk + (i-1) > #tlw.DataLines then
			break
		end

        local curLine = tlw.Lines[i]
        local curData = tlw.DataLines[pk + i -1]

        curLine.Columns[1]:SetText(curData.name)
		curLine.Columns[2]:SetText(curData.atName)
		curLine.Columns[3]:SetText(curData.timeInGroup)
    end 
end

function AdvancedGroupRoster:SetupPlayerTable()
	local tkw = AdvancedGroupRosterReportPlayersTable
	tkw:ClearAnchors()
    tkw.DataOffset = 0
    tkw.MaxLines = 20
    tkw.MaxColumns = 3
    tkw.DataLines = {}
    tkw.Lines = {}
    tkw:SetHeight(565)
    tkw:SetWidth(570)
    tkw:SetAnchor(TOPLEFT,AdvancedGroupRosterReport,TOPLEFT,10,50)
    tkw:SetDrawLayer(DL_BACKGROUND)
    tkw:SetMouseEnabled(true)
	tkw:SetHandler("OnMouseWheel",function(self,delta)
        if AdvancedGroupRoster.players_table == nil then
			return
		end

        local tlw = AdvancedGroupRoster.players_table
        local value = tlw.DataOffset - delta

        if value < 0 then 
            value = 0
        elseif value > AdvancedGroupRoster.tablelength(tlw.DataLines) - tlw.MaxLines then 
            value = AdvancedGroupRoster.tablelength(tlw.DataLines) - tlw.MaxLines 
        end

        tlw.DataOffset = value
        tlw.Slider:SetValue(tlw.DataOffset)
        AdvancedGroupRoster.UpdateSessionPlayersTable()
    end)

	tkw.BackGround = WINDOW_MANAGER:CreateControl(nil,tkw,CT_BACKDROP)
    tkw.BackGround:SetAnchorFill(tkw)
    tkw.BackGround:SetCenterColor(0.0, 0.0, 0.0, 0.5)   
    tkw.BackGround:SetEdgeColor(1, 1, 1, 0.5)
    tkw.BackGround:SetEdgeTexture(nil, 2, 2, 2.0, 2.0)  

    local tex = "/esoui/art/miscellaneous/scrollbox_elevator.dds"
    tkw.Slider = WINDOW_MANAGER:CreateControl("AdvancedGroupRosterPlayersScrollBar",tkw,CT_SLIDER)

    tkw.Slider:SetDimensions(13,tkw:GetHeight())
    tkw.Slider:SetMouseEnabled(true)
    tkw.Slider:SetThumbTexture(tex,tex,tex,13,35,0,0,1,1)
    tkw.Slider:SetValue(0)
    tkw.Slider:SetValueStep(1)
    tkw.Slider:SetAnchorFill()
    tkw.Slider:SetMinMax(0,50)
    tkw.Slider:ClearAnchors()
    tkw.Slider:SetAnchor(TOPLEFT,tkw,TOPLEFT,tkw:GetWidth() - 15,5)
    tkw.Slider:SetHandler("OnValueChanged",function(self,value,eventReason)
        if AdvancedGroupRoster.players_table == nil then
			return
		end

        local tlw = AdvancedGroupRoster.players_table
        tlw.DataOffset = math.min(value,AdvancedGroupRoster.tablelength(tlw.DataLines) - tlw.MaxLines)
        AdvancedGroupRoster.UpdateSessionPlayersTable()
    end)

	for i=1,tkw.MaxLines do
        tkw.Lines[i] = WINDOW_MANAGER:CreateControlFromVirtual("AdvancedGroupRosterPlayerTableLine_" .. i, tkw, "AdvancedGroupRosterTableLine")
        tkw.Lines[i]:SetDimensions(tkw:GetWidth()-10,25)

        if i == 1 then
            tkw.Lines[i]:SetAnchor(TOPLEFT,tkw,TOPLEFT,0,5)
        else
            tkw.Lines[i]:SetAnchor(TOPLEFT,tkw.Lines[i-1],BOTTOMLEFT,0,3)
        end

        local index = i
        tkw.Lines[i].Columns = {}

        for j=1,tkw.MaxColumns do 
            tkw.Lines[i].Columns[j] = WINDOW_MANAGER:CreateControl(nil,tkw.Lines[i],CT_LABEL)
            local oy = 0

            if i == 1 then
                tkw.Lines[i].Columns[j]:SetFont("ZoFontGameBold")
            else
                tkw.Lines[i].Columns[j]:SetFont("ZoFontGameSmall")
                 oy = 3
            end

            tkw.Lines[i].Columns[j]:SetDimensions(tkw.Lines[i]:GetWidth()/6,25)

            if i==1 then
                local sw, wh = tkw.Lines[i].Columns[j]:GetTextDimensions()

                tkw.Lines[i].Columns[j]:SetDimensions(sw,25)

                if j == 1 then
                     tkw.Lines[i].Columns[j]:SetAnchor(TOPLEFT,tkw.Lines[i],TOPLEFT,18,0)
                else
                    local sw, wh = tkw.Lines[i].Columns[j-1]:GetTextDimensions()
                    local ox = (tkw.Lines[i]:GetWidth()/tkw.MaxColumns) - sw

                    if j == 2 then
                        ox = ox + 20
                    end

					if j == 3 then
                        ox = ox + 30
                    end

					tkw.Lines[i].Columns[j]:SetAnchor(TOPLEFT,tkw.Lines[i].Columns[j-1],TOPRIGHT, ox,oy)
                end
            else
                local w, h = tkw.Lines[1].Columns[j]:GetTextDimensions()
                local offx = 0

                if j ~= 1 and i == 2 then
                    offx = (w/2) - tkw.Lines[i].Columns[j]:GetTextDimensions()
                end

                if j ~= 1 and i == 2 then
                    offx = offx + 18
                end

				if j == 2 and i == 2 then
					offx = offx - 45
				end

				if j == 3 and i == 2 then
					offx = offx - 35
				end

                tkw.Lines[i].Columns[j]:SetAnchor(TOPLEFT,tkw.Lines[i-1].Columns[j],BOTTOMLEFT,offx,oy)
            end

            if i == 1 then
                if j == 1 then 
                    tkw.Lines[i].Columns[j]:SetText("Name")
                    tkw.Lines[i].Columns[j].SortButton = WINDOW_MANAGER:CreateControl(nil,tkw.Lines[i].Columns[j],CT_BUTTON)
                    tkw.Lines[i].Columns[j].SortButton:SetWidth(tkw.Lines[i].Columns[j]:GetWidth())
                    tkw.Lines[i].Columns[j].SortButton:SetHeight(tkw.Lines[i].Columns[j]:GetHeight())
                    tkw.Lines[i].Columns[j].SortButton:SetAnchor(TOPLEFT,tkw.Lines[i].Columns[j],TOPLEFT,0,0)
                    tkw.Lines[i].Columns[j].SortButton.Desc = false
                    tkw.Lines[i].Columns[j].SortButton:SetHandler("OnClicked",function(self,delta)
                            tkw.Lines[i].Columns[j].SortButton.Desc = not tkw.Lines[i].Columns[j].SortButton.Desc
                            local dl = {}

                            if tkw.Lines[i].Columns[j].SortButton.Desc then
                                for k,v in AdvancedGroupRoster.spairs(AdvancedGroupRoster.players_table.DataLines, function(t,a,b) return t[b].name < t[a].name end) do
                                    table.insert(dl, v)
                                end
                            else
                                for k,v in AdvancedGroupRoster.spairs(AdvancedGroupRoster.players_table.DataLines, function(t,a,b) return t[b].name > t[a].name end) do
                                    table.insert(dl, v)
                                end
                            end

                            AdvancedGroupRoster.players_table.DataLines = dl
                            AdvancedGroupRoster.UpdateSessionPlayersTable()
                    end)

                    tkw.Lines[i].Columns[j].SortButton:SetHidden(false)
                end

				if j == 2 then 
                    tkw.Lines[i].Columns[j]:SetText("UserID")
                    tkw.Lines[i].Columns[j].SortButton = WINDOW_MANAGER:CreateControl(nil,tkw.Lines[i].Columns[j],CT_BUTTON)
                    tkw.Lines[i].Columns[j].SortButton:SetWidth(tkw.Lines[i].Columns[j]:GetWidth())
                    tkw.Lines[i].Columns[j].SortButton:SetHeight(tkw.Lines[i].Columns[j]:GetHeight())
                    tkw.Lines[i].Columns[j].SortButton:SetAnchor(TOPLEFT,tkw.Lines[i].Columns[j],TOPLEFT,0,0)
                    tkw.Lines[i].Columns[j].SortButton.Desc = false
                    tkw.Lines[i].Columns[j].SortButton:SetHandler("OnClicked",function(self,delta)
                            tkw.Lines[i].Columns[j].SortButton.Desc = not tkw.Lines[i].Columns[j].SortButton.Desc
                            local dl = {}

                            if tkw.Lines[i].Columns[j].SortButton.Desc then
                                for k,v in AdvancedGroupRoster.spairs(AdvancedGroupRoster.players_table.DataLines, function(t,a,b) return t[b].atName < t[a].atName end) do
                                    table.insert(dl, v)
                                end
                            else
                                for k,v in AdvancedGroupRoster.spairs(AdvancedGroupRoster.players_table.DataLines, function(t,a,b) return t[b].atName > t[a].atName end) do
                                    table.insert(dl, v)
                                end
                            end

                            AdvancedGroupRoster.players_table.DataLines = dl
                            AdvancedGroupRoster.UpdateSessionPlayersTable()
                    end)

                    tkw.Lines[i].Columns[j].SortButton:SetHidden(false)
                end

				if j == 3 then 
                    tkw.Lines[i].Columns[j]:SetText("Time")
                    tkw.Lines[i].Columns[j].SortButton = WINDOW_MANAGER:CreateControl(nil,tkw.Lines[i].Columns[j],CT_BUTTON)
                    tkw.Lines[i].Columns[j].SortButton:SetWidth(tkw.Lines[i].Columns[j]:GetWidth())
                    tkw.Lines[i].Columns[j].SortButton:SetHeight(tkw.Lines[i].Columns[j]:GetHeight())
                    tkw.Lines[i].Columns[j].SortButton:SetAnchor(TOPLEFT,tkw.Lines[i].Columns[j],TOPLEFT,0,0)
                    tkw.Lines[i].Columns[j].SortButton.Desc = false
                    tkw.Lines[i].Columns[j].SortButton:SetHandler("OnClicked",function(self,delta)
                            tkw.Lines[i].Columns[j].SortButton.Desc = not tkw.Lines[i].Columns[j].SortButton.Desc
                            local dl = {}

                            if tkw.Lines[i].Columns[j].SortButton.Desc then
                                for k,v in AdvancedGroupRoster.spairs(AdvancedGroupRoster.players_table.DataLines, function(t,a,b) return t[b].timeInGroup < t[a].timeInGroup end) do
                                    table.insert(dl, v)
                                end
                            else
                                for k,v in AdvancedGroupRoster.spairs(AdvancedGroupRoster.players_table.DataLines, function(t,a,b) return t[b].timeInGroup > t[a].timeInGroup end) do
                                    table.insert(dl, v)
                                end
                            end

                            AdvancedGroupRoster.players_table.DataLines = dl
                            AdvancedGroupRoster.UpdateSessionPlayersTable()
                    end)

                    tkw.Lines[i].Columns[j].SortButton:SetHidden(false)
                end
            end

            tkw.Lines[i].Columns[j]:SetHidden(false)
        end
    end

    AdvancedGroupRoster.players_table = tkw
end
