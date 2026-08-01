local LCCC = LibCodesCommonCode
local LUP = LibUndauntedPledges
local LQS = LibQuestStatus
local RCR = Raidificator


--------------------------------------------------------------------------------
-- RaidificatorPledges
--------------------------------------------------------------------------------

local RaidificatorPledges = ZO_Object:Subclass()

local QuestHandler

function RaidificatorPledges:New( )
	local obj = ZO_Object.New(self)
	local window = RaidificatorPledgesTopLevel
	obj.window = window

	local PADDING = 12
	local HEADER = 94
	local LINE = 2
	local WIDTH = 880
	local HEIGHT = 24

	local divider = window:GetNamedChild("DividerH")
	divider:SetEdgeColor(0, 0, 0, 0)
	divider:SetCenterColor(LCCC.Int32ToRGBA(RCR.COLOR_DIVIDER))

	local header = window:GetNamedChild("Header")
	header:GetNamedChild("Base1"):SetText(LUP.GetPledgeGiverName(LUP.BASE1))
	header:GetNamedChild("Base2"):SetText(LUP.GetPledgeGiverName(LUP.BASE2))
	header:GetNamedChild("Dlc1"):SetText(LUP.GetPledgeGiverName(LUP.DLC1))

	obj.rowCount = LUP.GetPledgeCount(LUP.DLC1)
	obj.rows = { [0] = window:GetNamedChild("Header") }
	for i = 1, obj.rowCount do
		local row = WINDOW_MANAGER:CreateControlFromVirtual("$(parent)Row" .. i, window, "RaidificatorPledgesEntry")
		row:SetAnchor(TOPLEFT, obj.rows[i - 1], BOTTOMLEFT)
		row:GetNamedChild("BG"):SetHidden(i % 2 == 0)
		obj.rows[i] = row
		if (QuestHandler) then
			QuestHandler.EnableMouse(row, "Base1")
			QuestHandler.EnableMouse(row, "Base2")
			QuestHandler.EnableMouse(row, "Dlc1")
		end
	end

	window:SetDimensions(
		WIDTH + PADDING * 2 + 4,
		HEIGHT * obj.rowCount + PADDING * 2 + HEADER
	)
	window:ClearAnchors()
	window:SetAnchor(CENTER, GuiRoot, CENTER)
	window:SetHandler("OnShow", function( )
		if (SCENE_MANAGER:IsInUIMode()) then
			obj.restoreMovement = nil
		else
			obj.restoreMovement = true
			SCENE_MANAGER:SetInUIMode(true)
		end
	end)
	window:SetHandler("OnHide", function( )
		if (obj.restoreMovement) then
			obj.restoreMovement = nil
			SCENE_MANAGER:SetInUIMode(false)
		end
	end)

	return obj
end

function RaidificatorPledges:Toggle( offset )
	offset = tonumber(offset) or 0

	if (self.window:IsHidden() or self.prevOffset ~= offset) then
		self.prevOffset = offset

		local SetCell = function( control, name, text, color, zoneId )
			local cell = control:GetNamedChild(name)
			cell:SetText(text)
			cell:SetColor(color:UnpackRGB())
			cell.zoneId = zoneId
		end

		for i = 1, self.rowCount do
			local pledge = LUP.GetPledges(i - 1 + offset)
			local row = self.rows[i]
			local color = (pledge.date.wday == 7 or pledge.date.wday == 1) and ZO_HIGHLIGHT_TEXT or ZO_DEFAULT_TEXT
			SetCell(row, "Date", string.format("%04d-%02d-%02d – %s", pledge.date.year, pledge.date.month, pledge.date.day, pledge.date.wdayShort), color)
			SetCell(row, "Base1", pledge[LUP.BASE1].name, color, pledge[LUP.BASE1].zoneId)
			SetCell(row, "Base2", pledge[LUP.BASE2].name, color, pledge[LUP.BASE2].zoneId)
			SetCell(row, "Dlc1", pledge[LUP.DLC1].name, color, pledge[LUP.DLC1].zoneId)
		end

		self.window:SetHidden(false)
	else
		self.window:SetHidden(true)
	end
end


--------------------------------------------------------------------------------
-- Quests
--------------------------------------------------------------------------------

if (LUP and LQS) then
	QuestHandler = { }

	local Tooltip = ExtendedJournalTextTooltip

	local function AddToList( list, server, account, name )
		list[server] = list[server] or { }
		list[server][account] = list[server][account] or { }
		table.insert(list[server][account], name)
	end

	local function AddRegularText( text )
		local r, g, b = ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB()
		Tooltip:AddLine(text, "LejFontSmall", r, g, b, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT, true)
	end

	local function AddTooltipSection( headerStringId, questId, serverOrder, accountOrder, list )
		Tooltip:AddLine(GetString(headerStringId), "ZoFontWinH3")
		Tooltip:AddLine(GetQuestName(questId), "ZoFontWinH5")

		if (next(list)) then
			for _, server in ipairs(serverOrder) do
				local serverPrefix = #serverOrder > 1 and zo_iconTextFormat(RCR.GetTexture(server), "100%", "100%", " ") or ""
				for _, account in ipairs(accountOrder) do
					local accountPrefix = #accountOrder > 1 and string.format("|c66CCFF|l1:1:1:2:2:66CCFF|l%s:|l|r ", account) or ""
					local names = list[server] and list[server][account]
					if (names) then
						AddRegularText(string.format("%s%s%s", serverPrefix, accountPrefix, table.concat(names, ", ")))
					end
				end
			end
		else
			AddRegularText(GetString(SI_HOUSE_TOURS_LISTING_TAGS_NONE))
		end

	end

	function QuestHandler.OnMouseEnter( control )
		local zoneId = control.zoneId

		if (zoneId) then
			local _, pledgeQuestId = LUP.LookupIds(zoneId, LUP.TYPE_ZONE)
			local storyQuestId = RCR.ZONES.D[zoneId] and RCR.ZONES.D[zoneId][5]

			if (pledgeQuestId ~= 0 and storyQuestId) then
				local active = { }
				local sp = { }

				local serverOrder = { }
				local accountOrder = { }
				local accountSeen = { }

				for _, data in ipairs(LQS.GetServerAndCharacterList(true)) do
					table.insert(serverOrder, data.server)
					for _, character in ipairs(data.characters) do
						if (not accountSeen[character.account]) then
							accountSeen[character.account] = true
							table.insert(accountOrder, character.account)
						end

						-- Pledges
						local activePledge = LQS.GetActiveQuestsForCharacter(data.server, character.charId)[pledgeQuestId]
						if (activePledge) then
							AddToList(active, data.server, character.account, (activePledge.completed or activePledge.conditionType == QUEST_CONDITION_TYPE_TALK_TO) and string.format("|cFFFF00%s|r", character.name) or character.name)
						elseif (LQS.IsRepeatableQuestOnCooldownForCharacter(pledgeQuestId, data.server, character.charId)) then
							AddToList(active, data.server, character.account, string.format("|c00FF00%s|r", character.name))
						end

						-- Skill Point
						if (not LQS.HasCompletedQuestOnCharacter(storyQuestId, data.server, character.charId)) then
							AddToList(sp, data.server, character.account, character.name)
						end
					end
				end

				InitializeTooltip(Tooltip, control, TOPRIGHT, 0, 0, TOPLEFT)
				AddTooltipSection(SI_RCR_PLEDGES_ACTIVE, pledgeQuestId, serverOrder, accountOrder, active)
				ZO_Tooltip_AddDivider(Tooltip)
				AddTooltipSection(SI_RCR_PLEDGES_AVAILABLE_SP, storyQuestId, serverOrder, accountOrder, sp)
			end
		end
	end

	function QuestHandler.OnMouseExit( control )
		ClearTooltip(Tooltip)
	end

	function QuestHandler.EnableMouse( row, cellName )
		local cell = row:GetNamedChild(cellName)
		cell:SetMouseEnabled(true)
		cell:SetHandler("OnMouseEnter", QuestHandler.OnMouseEnter)
		cell:SetHandler("OnMouseExit", QuestHandler.OnMouseExit)
	end

	LCCC.MonitorZoneChanges("RCR_PledgeWatcher", function( zoneId )
		if (GetUnitLevel("player") >= 45 and LUP.IsPledge(zoneId)) then
			local _, pledgeQuestId = LUP.LookupIds(zoneId, LUP.TYPE_ZONE)
			if (not HasQuest(pledgeQuestId) and not LQS.IsRepeatableQuestOnCooldownForCharacter(pledgeQuestId)) then
				local message = zo_strformat(SI_RCR_PLEDGES_AVAILABLE_PL, GetQuestName(pledgeQuestId))

				-- Chat
				RCR.Msg(message)

				-- CSA
				local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.OBJECTIVE_DISCOVERED)
				messageParams:SetText(message)
				CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
			end
		end
	end)
end


--------------------------------------------------------------------------------
-- Entry points
--------------------------------------------------------------------------------

function RCR.PledgesEnabled( )
	return type(LUP) == "table"
end

function RCR.InitializePledges( )
	if (RCR.PledgesEnabled()) then
		LCCC.RegisterString("SI_BINDING_NAME_RCR_PLEDGES", string.format("%s: %s", GetString(SI_RCR_TITLE), GetString(SI_RCR_PLEDGES)))
		LCCC.RegisterSlashCommands(RCR.Pledges, "/pledgecal")
	end
end

function RCR.GetPledgesButton( )
	return {
		name = GetString(SI_RCR_PLEDGES),
		keybind = "UI_SHORTCUT_QUATERNARY",
		callback = RCR.Pledges,
	}
end

local Pledges = nil

function RCR.Pledges( ... )
	if (RCR.PledgesEnabled()) then
		if (not Pledges) then
			Pledges = RaidificatorPledges:New()
		end
		Pledges:Toggle(...)
	end
end
