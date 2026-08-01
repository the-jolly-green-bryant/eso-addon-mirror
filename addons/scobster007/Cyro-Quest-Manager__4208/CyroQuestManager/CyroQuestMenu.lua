local wm = GetWindowManager()

CyroQuestManager = CyroQuestManager or {}
local CQM = CyroQuestManager

CQM.ConquestQuestList = {
	"capture all 3 towns",
	"kill 150 enemy players",
	"capture any nine resources",
	"capture any three keeps"
}

function CQM.displayQuest(questLabel, questName, finished)
	if CQM.svChar.bShowQuestMenu then
		questLabel:SetText("- [" .. questName .. "]")
		if finished then
			questLabel:SetColor(0.1, 0.9, 0.1, 1)
		else
			questLabel:SetColor(0.9, 0.1, 0.1, 1)
		end
	end
end

function CQM.setQuestToDefault(questLabel)
	questLabel:SetText("- [None]")
	questLabel:SetColor(0.8, 0.8, 0.8, 1)
end

function CQM.setAllQuestsToDefault()
	if CQM.svChar.bShowQuestMenu then
		CQM.setQuestToDefault(cqmw.scrollQuest)
		CQM.setQuestToDefault(cqmw.ScoutQuest)
		CQM.setQuestToDefault(cqmw.BattleQuest)
		CQM.setQuestToDefault(cqmw.WarfrontQuest)
		CQM.setQuestToDefault(cqmw.conquestQuest)
		CQM.setQuestToDefault(cqmw.BountyQuest)
	end
end

function CQM.zoneChange()
	if CQM.svChar.bShowQuestMenu then
		if CQM.isInCyrodiil() then
			CQM.questWindow:SetHidden(false)
		else
			CQM.questWindow:SetHidden(true)
			CQM.checkQuests()
		end
	end
end

function CQM.dropQuest(questIndex)
	CHAT_SYSTEM:AddMessage(string.format("Dropping Quest: |c0af50a [%s]|", GetJournalQuestName(questIndex)))
	AbandonQuest(questIndex)
end

function CQM.checkCurrentQuest(questIndex)
	local questName = string.lower(GetJournalQuestName(questIndex))

	if questName == "kill 150 enemy players" and CQM.svChar.bAutoDrop150 then
		CQM.dropQuest(questIndex)
		return
	end

	if questName == "capture all 3 towns" and CQM.svChar.bAutoDropTowns then
		CQM.dropQuest(questIndex)
		return
	end

	if string.find(questName, "kill enemy") and CQM.svChar.bAutoDropClasses and not string.find(questName, "players") then
		CQM.dropQuest(questIndex)
		return
	end

	if CQM.svChar.bShowQuestMenu then

		for i=1, 4 do
			if CQM.ConquestQuestList[i] == questName then
				CQM.displayQuest(cqmw.conquestQuest, GetJournalQuestName(questIndex), GetJournalQuestIsComplete(questIndex))
				return
			end
		end

		if string.find(questName, "kill") then
			CQM.displayQuest(cqmw.BountyQuest, GetJournalQuestName(questIndex), GetJournalQuestIsComplete(questIndex))
			return
		end

		--Check If Scroll Quest
		if string.find(questName, "elder scroll") then
			CQM.displayQuest(cqmw.scrollQuest, GetJournalQuestName(questIndex), GetJournalQuestIsComplete(questIndex))
			return
		end

		if string.find(questName, "scout") then
			CQM.displayQuest(cqmw.ScoutQuest, GetJournalQuestName(questIndex), GetJournalQuestIsComplete(questIndex))
			return
		end

		if string.find(questName, "capture") then
			if string.find(questName, "farm") or string.find(questName, "mine") or string.find(questName, "lumbermill") then
				CQM.displayQuest(cqmw.BattleQuest, GetJournalQuestName(questIndex), GetJournalQuestIsComplete(questIndex))
				return
			else
				CQM.displayQuest(cqmw.WarfrontQuest, GetJournalQuestName(questIndex), GetJournalQuestIsComplete(questIndex))
				return
			end
		end
	end
end

function CQM.checkQuests()
	CQM.setAllQuestsToDefault()
	for questIndex = 1, MAX_JOURNAL_QUESTS do
		if GetJournalQuestType(questIndex) == QUEST_TYPE_AVA then
			CQM.checkCurrentQuest(questIndex)
		end
	end
end

function CQM.makeQuestMenu()
	CQM.questWindow = wm:CreateTopLevelWindow("CyroQuestMenu")
	cqmw = CQM.questWindow
	cqmw:SetHidden(false)
	cqmw:SetMovable(true)
	cqmw:SetMouseEnabled(true)
	cqmw:SetClampedToScreen(true)
	cqmw:SetClampedToScreenInsets(16, 0, -16, 0)
	cqmw:SetDimensions(300,350)
	cqmw:SetResizeToFitDescendents(false)

	local function GetPosition()
		return cqmw:GetLeft(), cqmw:GetTop(), cqmw:GetRight(), cqmw:GetBottom()
	end

	local function SetPosition(x, y, r, b)
		local cx, cy = GuiRoot:GetCenter()
		local isLeft, isTop = x < cx, y < cy
		cqmw:ClearAnchors()
		if isLeft and isTop then
			cqmw:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
		elseif isLeft then
			cqmw:SetAnchor(BOTTOMLEFT, GuiRoot, BOTTOMLEFT, x, b - GuiRoot:GetHeight())
		elseif isTop then
			cqmw:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, r - GuiRoot:GetWidth(), y)
		else
			cqmw:SetAnchor(BOTTOMRIGHT, GuiRoot, BOTTOMRIGHT, r - GuiRoot:GetWidth(), b - GuiRoot:GetHeight())
		end
	end

	local function OnMoveStop()
		CQM.svChar.x, CQM.svChar.y, CQM.svChar.r, CQM.svChar.b = GetPosition()
	end

	cqmw:SetHandler("OnMoveStop", OnMoveStop)
	cqmw:SetDrawLayer(DL_CONTROLS)
	--cqmw:SetDrawLevel(3)

	SetPosition(CQM.svChar.x, CQM.svChar.y, CQM.svChar.r, CQM.svChar.b)

	CQM.Yellow = ZO_ColorDef:New(0.8, 0.8, 0.3, 1)
	CQM.Grey = ZO_ColorDef:New(0.8,0.8,0.8,1)

	--Create Background
	cqmw.bg = wm:CreateControl("CQMBackground", cqmw, CT_BACKDROP)
	cqmw.bg:SetDrawLayer(DL_BACKGROUND)
	cqmw.bg:SetAnchorFill(cqmw)
	cqmw.bg:SetCenterColor(0,0,0,0.5)
	cqmw.bg:SetEdgeColor(0,0,0,0.5)

	--Header
	cqmw.title = wm:CreateControl("CQMTitle", cqmw, CT_LABEL)
	cqmw.title:SetAnchor(TOPLEFT, cqmw, TOPLEFT, 10, 10)
	cqmw.title:SetStyleColor(0, 0, 0 ,1)
	cqmw.title:SetText("Cyrodiil Quests")
	cqmw.title:SetHidden(false)
	cqmw.title:SetFont("ZoFontWinT1")

	--Scroll Title
	cqmw.scroll = wm:CreateControl("CQMScroll", cqmw.title, CT_LABEL)
	cqmw.scroll:SetAnchor(TOPLEFT, cqmw.title, BOTTOMLEFT, 10, 5)
	cqmw.scroll:SetStyleColor(0, 0, 0, 1)
	cqmw.scroll:SetColor(0.8, 0.8, 0.3, 1)
	cqmw.scroll:SetText("Scroll Quest:")
	cqmw.scroll:SetHidden(false)
	cqmw.scroll:SetFont("ZoFontWinT2")

	--Scroll Quests
	cqmw.scrollQuest = wm:CreateControl("CQMScrollQuest", cqmw.scroll, CT_LABEL)
	cqmw.scrollQuest:SetAnchor(TOPLEFT, cqmw.scroll, BOTTOMLEFT, 20, 5)
	cqmw.scrollQuest:SetStyleColor(0, 0, 0, 1)
	cqmw.scrollQuest:SetColor(0.8, 0.8, 0.8, 1)
	cqmw.scrollQuest:SetText("- [None]")
	cqmw.scrollQuest:SetHidden(false)
	cqmw.scrollQuest:SetFont("ZoFontWinT2")

	--Conquest Title
	cqmw.conquestTitle = wm:CreateControl("CQMConquestTitle", cqmw.scrollQuest, CT_LABEL)
	cqmw.conquestTitle:SetAnchor(TOPLEFT, cqmw.scrollQuest, BOTTOMLEFT, -20, 5)
	cqmw.conquestTitle:SetStyleColor(0,0,0,1)
	cqmw.conquestTitle:SetColor(0.8, 0.8, 0.3, 1)
	cqmw.conquestTitle:SetText("Conquest Mission Board: ")
	cqmw.conquestTitle:SetHidden(false)
	cqmw.conquestTitle:SetFont("ZoFontWinT2")

	--Conquest Quest
	cqmw.conquestQuest = wm:CreateControl("CQMConquestQuest", cqmw.conquestTitle, CT_LABEL)
	cqmw.conquestQuest:SetAnchor(TOPLEFT, cqmw.conquestTitle, BOTTOMLEFT, 20, 5)
	cqmw.conquestQuest:SetStyleColor(0,0,0,1)
	cqmw.conquestQuest:SetColor(0.8,0.8,0.8,1)
	cqmw.conquestQuest:SetText("- [None]")
	cqmw.conquestQuest:SetHidden(false)
	cqmw.conquestQuest:SetFont("ZoFontWinT2")

	--Scout Title
	cqmw.ScoutTitle = wm:CreateControl("CQMScoutTitle", cqmw.conquestQuest, CT_LABEL)
	cqmw.ScoutTitle:SetAnchor(TOPLEFT, cqmw.conquestQuest, BOTTOMLEFT, -20, 5)
	cqmw.ScoutTitle:SetStyleColor(0,0,0,1)
	cqmw.ScoutTitle:SetColor(0.8, 0.8, 0.3, 1)
	cqmw.ScoutTitle:SetText("Scouting Mission Board: ")
	cqmw.ScoutTitle:SetHidden(false)
	cqmw.ScoutTitle:SetFont("ZoFontWinT2")

	--Scout Quest
	cqmw.ScoutQuest = wm:CreateControl("CQMScoutQuest", cqmw.ScoutTitle, CT_LABEL)
	cqmw.ScoutQuest:SetAnchor(TOPLEFT, cqmw.ScoutTitle, BOTTOMLEFT, 20, 5)
	cqmw.ScoutQuest:SetStyleColor(0,0,0,1)
	cqmw.ScoutQuest:SetColor(0.8,0.8,0.8,1)
	cqmw.ScoutQuest:SetText("- [None]")
	cqmw.ScoutQuest:SetHidden(false)
	cqmw.ScoutQuest:SetFont("ZoFontWinT2")

	--Bounty Title
	cqmw.BountyTitle = wm:CreateControl("CQMBountyTitle", cqmw.ScoutQuest, CT_LABEL)
	cqmw.BountyTitle:SetAnchor(TOPLEFT, cqmw.ScoutQuest, BOTTOMLEFT, -20, 5)
	cqmw.BountyTitle:SetStyleColor(0,0,0,1)
	cqmw.BountyTitle:SetColor(0.8, 0.8, 0.3, 1)
	cqmw.BountyTitle:SetText("Bounty Mission Board:")
	cqmw.BountyTitle:SetHidden(false)
	cqmw.BountyTitle:SetFont("ZoFontWinT2")

	--Bounty Quest
	cqmw.BountyQuest = wm:CreateControl("CQMBountyQuest", cqmw.BountyTitle, CT_LABEL)
	cqmw.BountyQuest:SetAnchor(TOPLEFT, cqmw.BountyTitle, BOTTOMLEFT, 20, 5)
	cqmw.BountyQuest:SetStyleColor(0,0,0,1)
	cqmw.BountyQuest:SetColor(0.8,0.8,0.8,1)
	cqmw.BountyQuest:SetText("- [None]")
	cqmw.BountyQuest:SetHidden(false)
	cqmw.BountyQuest:SetFont("ZoFontWinT2")

	--Battle Mission Title
	cqmw.BattleTitle = wm:CreateControl("CQMBattleTitle", cqmw.BountyQuest, CT_LABEL)
	cqmw.BattleTitle:SetAnchor(TOPLEFT, cqmw.BountyQuest, BOTTOMLEFT, -20, 5)
	cqmw.BattleTitle:SetStyleColor(0,0,0,1)
	cqmw.BattleTitle:SetColor(0.8, 0.8, 0.3, 1)
	cqmw.BattleTitle:SetText("Battle Mission Board:")
	cqmw.BattleTitle:SetHidden(false)
	cqmw.BattleTitle:SetFont("ZoFontWinT2")

	--Battle Mission Quest
	cqmw.BattleQuest = wm:CreateControl("CQMBattleQuest", cqmw.BattleTitle, CT_LABEL)
	cqmw.BattleQuest:SetAnchor(TOPLEFT, cqmw.BattleTitle, BOTTOMLEFT, 20, 5)
	cqmw.BattleQuest:SetStyleColor(0,0,0,1)
	cqmw.BattleQuest:SetColor(0.8,0.8,0.8,1)
	cqmw.BattleQuest:SetText("- [None]")
	cqmw.BattleQuest:SetHidden(false)
	cqmw.BattleQuest:SetFont("ZoFontWinT2")

	--Warfront Title
	cqmw.WarfrontTitle = wm:CreateControl("CQMWarfrontTitle", cqmw.BattleQuest, CT_LABEL)
	cqmw.WarfrontTitle:SetAnchor(TOPLEFT, cqmw.BattleQuest, BOTTOMLEFT, -20, 5)
	cqmw.WarfrontTitle:SetStyleColor(0,0,0,1)
	cqmw.WarfrontTitle:SetColor(0.8, 0.8, 0.3, 1)
	cqmw.WarfrontTitle:SetText("Warfront Mission Board:")
	cqmw.WarfrontTitle:SetHidden(false)
	cqmw.WarfrontTitle:SetFont("ZoFontWinT2")

	--Warfront Quest
	cqmw.WarfrontQuest = wm:CreateControl("CQMWarfrontQuest", cqmw.WarfrontTitle, CT_LABEL)
	cqmw.WarfrontQuest:SetAnchor(TOPLEFT, cqmw.WarfrontTitle, BOTTOMLEFT, 20, 5)
	cqmw.WarfrontQuest:SetStyleColor(0,0,0,1)
	cqmw.WarfrontQuest:SetColor(0.8,0.8,0.8,1)
	cqmw.WarfrontQuest:SetText("- [None]")
	cqmw.WarfrontQuest:SetHidden(false)
	cqmw.WarfrontQuest:SetFont("ZoFontWinT2")

	CYRO_QUEST_FRAGMENT = ZO_HUDFadeSceneFragment:New(cqmw, 500, 0)
	CYRO_QUEST_FRAGMENT:SetConditional(
		function()
			return CQM.isInCyrodiil()
		end
	)

	HUD_SCENE:AddFragment(CYRO_QUEST_FRAGMENT)
	HUD_UI_SCENE:AddFragment(CYRO_QUEST_FRAGMENT)
	LOOT_SCENE:AddFragment(CYRO_QUEST_FRAGMENT)

	--cqmw.MakeOrders()

	CQM.checkQuests()
end