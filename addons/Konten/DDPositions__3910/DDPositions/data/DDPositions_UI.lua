-- DDPositions_UI.lua
DDPositions = DDPositions or {}
local DDP = DDPositions

DDP.UI = DDP.UI or {}
local UI = DDP.UI
DDP.UI.freeAssignmentsVisible = false

UI.buttons = {}

function DDP.ClearChatEntry()
    local cs = CHAT_SYSTEM
    local edit = _G.ZO_ChatWindowTextEntryEditBox
                or (cs and cs.textEntry and cs.textEntry.editControl)

    if edit and edit.SetText then
        edit:SetText("")
        if edit.LoseFocus then edit:LoseFocus() end
    end
    if cs and cs.CloseEditBox then
        cs:CloseEditBox()
    end
end

local function showPlayerContextMenu(playerName, currentZoneId, mechKey, positionIndex, anchorControl, positionLabel)
    if not playerName then return end
    ClearMenu()

    if IsUnitGroupLeader("player") then
        AddMenuItem("Kick " .. playerName .. " From Group", function()
            local unitTag = DDP.GetUnitTagByName(playerName)
            if not unitTag then DDP.msg("Player not found in group.") return end
            GroupKick(unitTag)
        end)
        AddMenuItem(" ", function() end)
    end

    local zoneData = DDP.positions[currentZoneId]
    local mechPositions = zoneData and zoneData.mechanics[mechKey] or {}

    local overrideSub = {}
    for i, pos in ipairs(mechPositions) do
        table.insert(overrideSub, {
            label = string.format("Assign to [%s]", pos),
            callback = function()
                DDP.OverrideAssignment(currentZoneId, mechKey, i, playerName, true)
            end
        })
    end

    local playerSub = {}
    for i = 1, GetGroupSize() do
        local unitTag = GetGroupUnitTagByIndex(i)
        if DoesUnitExist(unitTag) and DDP.IsUnitDPS(unitTag) then
            local name = zo_strformat("<<1>>", GetUnitDisplayName(unitTag))
            if name ~= playerName then
                table.insert(playerSub, {
                    label = string.format("Replace with %s", name),
                    callback = function()
                        DDP.OverrideAssignment(currentZoneId, mechKey, positionIndex, name, true)
                    end
                })
            end
        end
    end

    if AddCustomSubMenuItem then
        AddCustomSubMenuItem("-- Change assignment --", overrideSub)
        AddCustomSubMenuItem("-- Change player --", playerSub)
    else
        AddMenuItem("-- Change assignment --", function() end)
        for _, item in ipairs(overrideSub) do
            AddMenuItem(item.label, item.callback)
        end
		AddMenuItem(" ", function() end)
        AddMenuItem("-- Change player --", function() end)
        for _, item in ipairs(playerSub) do
            AddMenuItem(item.label, item.callback)
        end
    end

    AddMenuItem(" ", function() end)
    AddMenuItem("-- Whisper assignment --", function()
        StartChatInput(string.format("/w %s Your assignment is: ::[%s -> %s]::",
            playerName, playerName, positionLabel))
    end)

    ShowMenu(anchorControl or GuiRoot)
end

function UI:Create()
    local wm = WINDOW_MANAGER
    if self.window then return end

    self.window = wm:CreateTopLevelWindow("DDPositionsPanel")
    self.window:SetDimensions(150, 220)
    self.window:SetHidden(true)
    self.window:SetMovable(true)
    self.window:SetMouseEnabled(true)
    self.window:SetClampedToScreen(true)

    local pos = (DDP.SV and DDP.SV.panelPosition) or { x = 500, y = 300 }
    self.window:ClearAnchors()
    self.window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, pos.x, pos.y)

    self.window:SetHandler("OnMoveStop", function()
        local x, y = self.window:GetLeft(), self.window:GetTop()
        DDP.SV.panelPosition = { x = x, y = y }
    end)

    local bg = wm:CreateControl("DDPositionsPanel_BG", self.window, CT_BACKDROP)
    bg:SetAnchorFill(self.window)
    bg:SetCenterColor(0, 0, 0, 0.6)
    bg:SetEdgeColor(1, 1, 1, 0.3)
    self.bg = bg

    self.title = wm:CreateControl("DDPositionsPanel_Title", self.window, CT_LABEL)
    self.title:SetFont("ZoFontWinH5")
    self.title:SetAnchor(TOP, self.window, TOP, 0, 10)
    self.title:SetText("::[DDPositions]::")
    self.title:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    self.title:SetColor(0.6, 0.6, 0.6, 0.5)

    local titleButton = wm:CreateControl("DDPositionsPanel_TitleButton", self.window, CT_BUTTON)
    titleButton:SetDimensions(220, 28)
    titleButton:SetAnchor(CENTER, self.title, CENTER, 0, 0)
    titleButton:SetMouseEnabled(true)
    titleButton:SetClickSound("Click")

    titleButton:SetHandler("OnMouseEnter", function()
        self.title:SetColor(0.4, 0.4, 0.4, 0.4)
        InitializeTooltip(InformationTooltip, titleButton, TOP, 0, 20)
        SetTooltipText(InformationTooltip, "Click to send a mechanic assignment notice to group chat.")
    end)
    titleButton:SetHandler("OnMouseExit", function()
        self.title:SetColor(0.6, 0.6, 0.6, 0.5)
        ClearTooltip(InformationTooltip)
    end)
    titleButton:SetHandler("OnClicked", function()
        StartChatInput("::[DDPositions]:: Mechanics will be automatically assigned. Type '+' if you're comfortable handling any mechanic.", CHAT_CHANNEL_PARTY)
    end)

    self.container = wm:CreateControl("DDPositionsPanel_Container", self.window, CT_CONTROL)
    self.container:SetAnchor(TOP, self.title, BOTTOM, 0, 10)
    self.container:SetDimensions(200, 180)
end

function UI:ClearButtons()
    for _, btn in ipairs(self.buttons) do
        if btn then btn:SetHidden(true) end
    end
    ZO_ClearNumericallyIndexedTable(self.buttons)
end

function UI:PopulateMechanicList()
    if not self.window or not self.container then self:Create() end
    self:ClearButtons()

    local currentZoneId = GetZoneId(GetUnitZoneIndex("player"))
    local zoneData = DDP.positions[currentZoneId]
    if not zoneData then return end
    local zoneName = zo_strformat("<<C:1>>", GetZoneNameById(currentZoneId))
    local wm = WINDOW_MANAGER
    local offsetY = 0

    local sepTop = wm:CreateControl(nil, self.container, CT_TEXTURE)
    sepTop:SetDimensions(180, 2)
    sepTop:SetColor(1, 1, 1, 0.4)
    sepTop:SetAnchor(TOP, self.container, TOP, 0, offsetY)
    sepTop:SetTexture("EsoUI/Art/Miscellaneous/horizontalDivider.dds")
    table.insert(self.buttons, sepTop)
    offsetY = offsetY + 10

    local vetLabel = wm:CreateControl(nil, self.container, CT_LABEL)
    vetLabel:SetFont("ZoFontGameSmall")
    vetLabel:SetText("Vet assignments")
    vetLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    vetLabel:SetAnchor(TOPLEFT, self.container, TOPLEFT, 0, offsetY)
    vetLabel:SetColor(0.6, 0.6, 0.6, 0.5)
    table.insert(self.buttons, vetLabel)
    offsetY = offsetY + 18
	
	local clearVet = wm:CreateControl(nil, self.container, CT_BUTTON)
	clearVet:SetDimensions(50, 20)
	clearVet:SetAnchor(TOPRIGHT, self.container, TOPRIGHT, -85, offsetY - 18)
	clearVet:SetMouseEnabled(true)
	clearVet:SetClickSound("Click")

	local clearVetLabel = wm:CreateControl(nil, clearVet, CT_LABEL)
	clearVetLabel:SetFont("ZoFontGameSmall")
	clearVetLabel:SetText("clear all")
	clearVetLabel:SetColor(1, 0.33, 0.33, 1)
	clearVetLabel:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
	clearVetLabel:SetAnchorFill(clearVet)
	
	clearVet:SetHandler("OnMouseEnter", function()
		clearVetLabel:SetColor(1, 0.4, 0.4, 1)
	end)
	clearVet:SetHandler("OnMouseExit", function()
		clearVetLabel:SetColor(1, 0.33, 0.33, 1)
	end)
	clearVet:SetHandler("OnMouseDown", function()
		clearVetLabel:SetColor(0.8, 0.2, 0.2, 1)
	end)
	clearVet:SetHandler("OnMouseUp", function()
		clearVetLabel:SetColor(1, 0.4, 0.4, 1)
	end)

	clearVet:SetHandler("OnClicked", function()
		PlaySound(SOUNDS.DIALOG_ACCEPT)
		DDP.savedAssignments = {}
		if DDP.SV then DDP.SV.savedAssignments = {} end
		DDP.lastMechanicShown = nil

		local wasVisible = DDP.UI.freeAssignmentsVisible
		DDP.UI:PopulateMechanicList()
		if wasVisible then
			local zid = GetZoneId(GetUnitZoneIndex("player"))
			if zid then
				DDP.UI.freeAssignmentsVisible = true
				DDP.UI:PopulateFreeAssignments(zid)
			end
		end
		DDP.ClearChatEntry()
		DDP.msg("|cFF5555All Vet assignments cleared.|r")
	end)

	table.insert(self.buttons, clearVet)

    local mechOrder = zoneData.mechOrder or {}
    local savedZone = (DDP.savedAssignments and DDP.savedAssignments[currentZoneId]) or {}

    for index, mechName in ipairs(mechOrder) do
        local btn = wm:CreateControl(nil, self.container, CT_BUTTON)
        btn:SetDimensions(180, 24)
        btn:SetAnchor(TOP, self.container, TOP, 0, offsetY)
        btn.mechName = mechName
        btn:SetMouseEnabled(true)
        btn:SetClickSound("Click")

        local label = wm:CreateControl(nil, btn, CT_LABEL)
        label:SetFont("ZoFontGameBold")
        label:SetAnchorFill(btn)
        label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        label:SetAnchor(TOPLEFT, self.container, TOPLEFT, 15, offsetY)
        label:SetText("• " .. mechName)
        btn.label = label

        if DDP.lastMechanicShown == mechName then
            label:SetColor(0.6, 1.0, 0.6, 1)
        else
            label:SetColor(1, 1, 1, 1)
        end

        btn:SetHandler("OnMouseEnter", function(selfBtn)
            selfBtn.label:SetColor(1, 0.85, 0.3, 1)
        end)
        btn:SetHandler("OnMouseExit", function(selfBtn)
            if DDP.lastMechanicShown == selfBtn.mechName then
                selfBtn.label:SetColor(0.6, 1.0, 0.6, 1)
            else
                selfBtn.label:SetColor(1, 1, 1, 1)
            end
        end)
        btn:SetHandler("OnClicked", function(selfBtn)
            DDP.AssignSpecificMechanic(currentZoneId, selfBtn.mechName)
        end)
        btn:SetHandler("OnMouseUp", function(control, button, upInside)
            if button == MOUSE_BUTTON_INDEX_RIGHT and upInside then
                ClearMenu()
                AddMenuItem("*Shuffle all*", function()
                    local mechPositions = zoneData.mechanics[mechName]
                    local msg = DDP.ShuffleAllAssignments(currentZoneId, mechName, mechPositions, true)
                    DDP.lastMechanicShown = mechName
                    DDP.UI:PopulateMechanicList()
                    StartChatInput(msg, CHAT_CHANNEL_PARTY)
                end)
                AddMenuItem("|cAAAAAAShuffle (ignore overrides)|r", function()
                    local mechPositions = zoneData.mechanics[mechName]
                    local msg = DDP.ShuffleAllAssignments(currentZoneId, mechName, mechPositions, false)
                    DDP.lastMechanicShown = mechName
                    DDP.UI:PopulateMechanicList()
                    StartChatInput(msg, CHAT_CHANNEL_PARTY)
                end)
                ShowMenu(control)
            end
        end)

        table.insert(self.buttons, btn)
        offsetY = offsetY + 24

        local showMechanic = false
        if savedZone[mechName] and #savedZone[mechName] > 0 then
            for _, entry in ipairs(savedZone[mechName]) do
                if entry.name ~= "@Missing" then
                    showMechanic = true
                    break
                end
            end
        end

        if showMechanic and (DDP.lastMechanicShown == nil or DDP.lastMechanicShown == mechName) then
            for i, entry in ipairs(savedZone[mechName]) do
                local playerName = entry.name
                local myName = zo_strformat("<<1>>", GetUnitDisplayName("player"))
                local pos = entry.position

                local isOffline = false
                local unitTag = DDP.GetUnitTagByName(playerName)
                if unitTag and not IsUnitOnline(unitTag) then
                    isOffline = true
                end

                local displayName = string.format("%s -> %s", playerName, pos)
                if isOffline then displayName = displayName .. " (offline)" end
                if entry.override then displayName = displayName .. " |c88FF88(locked)|r" end

                local playerLabel = wm:CreateControl(nil, self.container, CT_LABEL)
                playerLabel:SetFont("ZoFontGameSmall")
                playerLabel:SetText(displayName)
                playerLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
                playerLabel:SetAnchor(TOPLEFT, self.container, TOPLEFT, 25, offsetY)

                local baseColor
                if playerName == "@Missing" then
                    baseColor = {1.0, 0.3, 0.3, 1}
                else
                    baseColor = isOffline and {1.0, 0.267, 0.267, 1} or {0.7, 0.7, 0.7, 1}
                end
                playerLabel:SetColor(unpack(baseColor))

                playerLabel:SetMouseEnabled(playerName ~= "@Missing")

                playerLabel:SetHandler("OnMouseUp", function(control, button, upInside)
                    if not upInside or playerName == "@Missing" then return end
                    if button == MOUSE_BUTTON_INDEX_RIGHT then
                        showPlayerContextMenu(playerName, currentZoneId, mechName, i, control, pos)
                    elseif button == MOUSE_BUTTON_INDEX_LEFT and playerName ~= myName then
                        local unitTag = DDP.GetUnitTagByName(playerName)
                        if unitTag then
                            StartChatInput(string.format("/w %s Your assignment is: ::[%s -> %s]::", playerName, playerName, pos))
                        else
                            DDP.msg(string.format("Cannot whisper %s — player is not in your group.", playerName))
                        end
                    end
                end)

                playerLabel:SetHandler("OnMouseEnter", function(control)
                    control:SetColor(1, 0.85, 0.3, 1)
                end)
                playerLabel:SetHandler("OnMouseExit", function(control)
                    control:SetColor(unpack(baseColor))
                end)

                table.insert(self.buttons, playerLabel)
                offsetY = offsetY + 18
            end
            offsetY = offsetY + 5
			
			local currentZoneId = GetZoneId(GetUnitZoneIndex("player"))
			local mechKey = (currentZoneId == 1548) and "Portal" or "Tombs"

			if (currentZoneId == 1548 and mechName == "Portal") or (currentZoneId == 1121 and mechName == "Tombs") then

				local healers = DDP.GetHealersInGroup()
				if #healers > 0 then
					offsetY = offsetY + 5

					local zoneData = DDP.positions[currentZoneId]
					local mechObjects = DDP.savedAssignments
						and DDP.savedAssignments[currentZoneId]
						and DDP.savedAssignments[currentZoneId][mechKey]

					local nextAvailableIndex = 1

					for _, healerName in ipairs(healers) do
						local hLabel = wm:CreateControl(nil, self.container, CT_LABEL)
						hLabel:SetFont("ZoFontGameSmall")
						hLabel:SetText(string.format("%s -> %s", healerName, mechKey))
						hLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
						hLabel:SetAnchor(TOPLEFT, self.container, TOPLEFT, 25, offsetY)
						hLabel:SetColor(0.8, 0.8, 0.8, 1)
						table.insert(self.buttons, hLabel)

						hLabel:SetMouseEnabled(true)
						hLabel:SetHandler("OnMouseUp", function(_, button, upInside)
							if button == MOUSE_BUTTON_INDEX_LEFT and upInside then
								if mechObjects then
									local validSlots = {}
									if currentZoneId == 1548 then
										for i, obj in ipairs(mechObjects) do
											if obj.position == "+P" then
												table.insert(validSlots, i)
											end
										end
									elseif currentZoneId == 1121 then
										for i, obj in ipairs(mechObjects) do
											if string.sub(obj.position, 1, 1) == "T" then
												table.insert(validSlots, i)
											end
										end
									end

									if #validSlots > 0 then
										local assigned = false
										for _, idx in ipairs(validSlots) do
											if mechObjects[idx].name == "@Missing" or not mechObjects[idx].override then
												mechObjects[idx].name = healerName
												mechObjects[idx].override = true
												assigned = true
												break
											end
										end
										if not assigned then
											mechObjects[validSlots[1]].name = healerName
											mechObjects[validSlots[1]].override = true
										end
										DDP.savedAssignments[currentZoneId][mechKey] = mechObjects
										if DDP.SV then DDP.SV.savedAssignments = DDP.savedAssignments end
										DDP.UI:PopulateMechanicList()
										DDP.PrintCurrentAssignments(currentZoneId, mechKey)
									end
								end
							end
						end)

						hLabel:SetHandler("OnMouseEnter", function(control)
							control:SetColor(1, 0.85, 0.3, 1)
						end)
						hLabel:SetHandler("OnMouseExit", function(control)
							control:SetColor(0.8, 0.8, 0.8, 1)
						end)

						offsetY = offsetY + 16
					end

					offsetY = offsetY + 10
				end
			end

        end
    end
	
	local freeBtn = wm:CreateControl(nil, self.container, CT_BUTTON)
	freeBtn:SetDimensions(180, 20)
	freeBtn:SetAnchor(TOPLEFT, self.container, TOPLEFT, 0, offsetY + 10)
	freeBtn:SetMouseEnabled(true)
	freeBtn:SetClickSound("Click")
	local freeLabel = wm:CreateControl(nil, freeBtn, CT_LABEL)
	freeLabel:SetFont("ZoFontGameSmall")
	freeLabel:SetText("Free assignments")
	freeLabel:SetAnchorFill(freeBtn)
	freeLabel:SetColor(0.6, 0.6, 0.6, 0.5)
	freeBtn:SetHandler("OnMouseEnter", function()
		freeLabel:SetColor(0.4, 0.4, 0.4, 0.4)
	end)
	freeBtn:SetHandler("OnMouseExit", function()
		freeLabel:SetColor(0.6, 0.6, 0.6, 0.5)
	end)
	freeBtn:SetHandler("OnMouseDown", function()
		freeLabel:SetColor(0.3, 0.3, 0.3, 0.3)
	end)
	freeBtn:SetHandler("OnMouseUp", function()
		freeLabel:SetColor(0.4, 0.4, 0.4, 0.4)
	end)
	
	local clearFree = wm:CreateControl(nil, self.container, CT_BUTTON)
	clearFree:SetDimensions(50, 20)
	clearFree:SetAnchor(RIGHT, freeBtn, RIGHT, -25, 0)
	clearFree:SetMouseEnabled(true)
	clearFree:SetClickSound("Click")
	local clearFreeLabel = wm:CreateControl(nil, clearFree, CT_LABEL)
	clearFreeLabel:SetFont("ZoFontGameSmall")
	clearFreeLabel:SetText("clear all")
	clearFreeLabel:SetColor(1, 0.33, 0.33, 1)
	clearFreeLabel:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
	clearFreeLabel:SetAnchorFill(clearFree)
	clearFree:SetHandler("OnMouseEnter", function()
		clearFreeLabel:SetColor(1, 0.4, 0.4, 1)
	end)
	clearFree:SetHandler("OnMouseExit", function()
		clearFreeLabel:SetColor(1, 0.33, 0.33, 1)
	end)
	clearFree:SetHandler("OnMouseDown", function()
		clearFreeLabel:SetColor(0.8, 0.2, 0.2, 1)
	end)
	clearFree:SetHandler("OnMouseUp", function()
		clearFreeLabel:SetColor(1, 0.4, 0.4, 1)
	end)

	clearFree:SetHandler("OnClicked", function()
		PlaySound(SOUNDS.DIALOG_ACCEPT)
		local zid = GetZoneId(GetUnitZoneIndex("player"))
		if zid and DDP.freeAssignments and DDP.freeAssignments[zid] then
			DDP.freeAssignments[zid] = {}
		end
		DDP.ClearChatEntry()
		DDP.msg("|cFF5555All Free assignments cleared.|r")

		if self.freeAssignmentsVisible then
			self.freeAssignmentsVisible = false
			if self.freeLabels then
				for _, label in ipairs(self.freeLabels) do
					label:SetHidden(true)
				end
			end
			self.container:SetDimensions(240, offsetY + 40)
			self.window:SetDimensions(260, offsetY + 80)
		end

		DDP.UI:PopulateMechanicList()
	end)


	table.insert(self.buttons, clearFree)
	table.insert(self.buttons, freeBtn)
	offsetY = offsetY + 24

	self.freeAssignmentsY = offsetY

	freeBtn:SetHandler("OnClicked", function()
		local zid = GetZoneId(GetUnitZoneIndex("player"))
		if not zid then return end
		self.freeAssignmentsVisible = not self.freeAssignmentsVisible

		if self.freeAssignmentsVisible then
			DDP.UI:PopulateFreeAssignments(zid)
		else
			if self.freeLabels then
				for _, label in ipairs(self.freeLabels) do
					label:SetHidden(true)
				end
			end
			self.container:SetDimensions(240, offsetY + 40)
			self.window:SetDimensions(260, offsetY + 80)
		end
	end)

    local sepBottom = wm:CreateControl(nil, self.container, CT_TEXTURE)
    sepBottom:SetDimensions(180, 2)
    sepBottom:SetColor(1, 1, 1, 0.4)
    sepBottom:SetAnchor(BOTTOM, self.container, BOTTOM, 0, -24)
    sepBottom:SetTexture("EsoUI/Art/Miscellaneous/horizontalDivider.dds")
    table.insert(self.buttons, sepBottom)

    local trialLabel = wm:CreateControl(nil, self.container, CT_LABEL)
    trialLabel:SetFont("ZoFontWinH5")
    trialLabel:SetText(zoneName)
    trialLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    trialLabel:SetAnchor(TOP, sepBottom, BOTTOM, 0, 0)
    trialLabel:SetColor(0.6, 0.6, 0.6, 0.5)
    table.insert(self.buttons, trialLabel)
	
	local helpBtn = wm:CreateControl(nil, self.container, CT_BUTTON)
	helpBtn:SetDimensions(20, 20)
	helpBtn:ClearAnchors()
	helpBtn:SetAnchor(BOTTOMLEFT, self.window, BOTTOMLEFT, 10, -5)
	-- helpBtn:SetAnchor(BOTTOMRIGHT, self.window, BOTTOMRIGHT, -10, -5)
	helpBtn:SetMouseEnabled(true)
	helpBtn:SetClickSound("Click")

	local helpIcon = wm:CreateControl(nil, helpBtn, CT_TEXTURE)
	helpIcon:SetAnchorFill(helpBtn)
	helpIcon:SetTexture("EsoUI/Art/Miscellaneous/help_icon.dds")
	helpIcon:SetTextureCoords(0, 1, 0, 1)
	helpIcon:SetColor(1, 1, 1, 0.4)

	helpBtn:SetHandler("OnMouseEnter", function()
		helpIcon:SetColor(1, 1, 1, 1)
		InitializeTooltip(InformationTooltip, helpBtn, TOP, 0, 20)
		SetTooltipText(InformationTooltip, "whisper @autor:")
	end)
	helpBtn:SetHandler("OnMouseExit", function()
		helpIcon:SetColor(1, 1, 1, 0.4)
		ClearTooltip(InformationTooltip)
	end)
	helpBtn:SetHandler("OnClicked", function()
		if DDP.autor then DDP.UnignorePlayer(DDP.autor) end
		StartChatInput("/w "..DDP.autor.." ")
	end)

	table.insert(self.buttons, helpBtn)
	
    self.container:SetDimensions(240, offsetY + 40)
    self.window:SetDimensions(260, offsetY + 80)
	if self.freeAssignmentsVisible then
		local zid = GetZoneId(GetUnitZoneIndex("player"))
		if zid then
			DDP.UI:PopulateFreeAssignments(zid)
		end
	end
end

function UI:PopulateFreeAssignments(currentZoneId)
    if self.freeLabels then
        for _, label in ipairs(self.freeLabels) do
            label:SetHidden(true)
        end
    end
    self.freeLabels = {}

    local wm = WINDOW_MANAGER
    local offsetY = self.freeAssignmentsY or 0

    local allDPS = {}
    for i = 1, GetGroupSize() do
        local unitTag = GetGroupUnitTagByIndex(i)
        if DoesUnitExist(unitTag) and DDP.IsUnitDPS(unitTag) then
            local name = zo_strformat("<<1>>", GetUnitDisplayName(unitTag))
            table.insert(allDPS, name)
        end
    end

    local zoneData = DDP.positions[currentZoneId]
    local savedZone = DDP.savedAssignments and DDP.savedAssignments[currentZoneId] or {}

    offsetY = offsetY + 18
    for _, playerName in ipairs(allDPS) do
        local assignedTo = nil

        for mechKey, entries in pairs(savedZone) do
            for _, obj in ipairs(entries) do
                if obj.name == playerName then
                    assignedTo = string.format("%s -> %s", mechKey, obj.position)
                    break
                end
            end
            if assignedTo then break end
        end

        local displayName = "• " .. playerName
        if assignedTo then
            displayName = string.format("%s -> %s", playerName, assignedTo:match("->%s*(.*)") or assignedTo)
        end

        local label = wm:CreateControl(nil, self.container, CT_LABEL)
        label:SetFont("ZoFontGameSmall")
        label:SetText(displayName)
        label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        label:SetAnchor(TOPLEFT, self.container, TOPLEFT, 15, offsetY)
        label:SetColor(0.8, 0.8, 0.8, 1)
        label:SetMouseEnabled(true)

		label:SetHandler("OnMouseUp", function(control, button, upInside)
			if not upInside or button ~= MOUSE_BUTTON_INDEX_RIGHT then return end
			ClearMenu()

			local zoneData = DDP.positions[currentZoneId]
			if not zoneData then return end

			local fa = DDP.freeAssignments and DDP.freeAssignments[currentZoneId] and DDP.freeAssignments[currentZoneId][playerName]
			if fa then
				AddMenuItem("|cFF8888Clear free assignment|r", function()
					DDP.ClearFreeAssignment(currentZoneId, playerName)
				end)
				AddMenuItem(" ", function() end)
			end

			local mechOrder = zoneData.mechOrder or {}
			for _, mechKey in ipairs(mechOrder) do
				local positions = zoneData.mechanics[mechKey]
				if positions then
					local subMenu = {}
					for i, pos in ipairs(positions) do
						table.insert(subMenu, {
							label = string.format("[%s -> %s]", mechKey, pos),
							callback = function()
								DDP.SetFreeAssignment(currentZoneId, playerName, mechKey, i)
							end
						})
					end
					if AddCustomSubMenuItem then
						AddCustomSubMenuItem(mechKey, subMenu)
					else
						AddMenuItem("-- " .. mechKey .. " --", function() end)
						for _, sub in ipairs(subMenu) do
							AddMenuItem(sub.label, sub.callback)
						end
					end
				end
			end
			ShowMenu(control)
		end)

		
		local fa = DDP.freeAssignments and DDP.freeAssignments[currentZoneId]
		local assigned = fa and fa[playerName] or nil

		local displayName = "• " .. playerName
		if assigned then
			displayName = string.format("• %s -> %s", playerName, assigned.position)
		end

		label:SetText(displayName)

        table.insert(self.freeLabels, label)
        offsetY = offsetY + 18
    end

    self.container:SetDimensions(240, offsetY + 40)
    self.window:SetDimensions(260, offsetY + 80)
end

function UI:Toggle()
    if self.window and not self.window:IsHidden() then
        self:ClearButtons()
        self.window:SetHidden(true)
        SCENE_MANAGER:SetInUIMode(false)
        return
    end

    local currentZoneId = GetZoneId(GetUnitZoneIndex("player"))
    if not DDP.positions[currentZoneId] then
        DDP.msg("Panel is only available inside a supported trial.")
        return
    end

    if not self.window then self:Create() end
    SCENE_MANAGER:SetInUIMode(true)
    self:PopulateMechanicList()
    self.window:SetHidden(false)
end

SLASH_COMMANDS["/DDPositions"] = function()
    if _G.DDPanel then
        _G.DDPanel:Toggle()
    end
end

_G.DDPanel = UI
