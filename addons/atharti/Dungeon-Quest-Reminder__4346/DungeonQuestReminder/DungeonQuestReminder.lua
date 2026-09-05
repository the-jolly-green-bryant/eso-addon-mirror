local DungeonQuestReminder = {}

local DQR = DungeonQuestReminder
local EM = EVENT_MANAGER

DQR.name = "DungeonQuestReminder"

-- =========================
-- DUNGEON DATA
-- =========================
local DUNGEON_ZONE_QUEST = {
	[11] = 4822,  -- VoM
	[22] = 4432,  -- VF
	[31] = 4733,  -- SW
	[38] = 4589,  -- BH
	[63] = 4145,  -- DC I
	[64] = 4469,  -- BC
	[126] = 4336,  -- EH I
	[130] = 4379,  -- CoH I
	[131] = 4538,  -- TI
	[144] = 4054,  -- SC I
	[146] = 4246,  -- WS I
	[148] = 4202,  -- AC
	[176] = 4778,  -- CoA I
	[283] = 3993,  -- FG I
	[380] = 4107,  -- BC I
	[449] = 4346,  -- DK
	[678] = 5136,  -- ICP
	[681] = 5120,  -- CoA II
	[688] = 5342,  -- WGT
	[843] = 5403,  -- RoM
	[848] = 5702,  -- COS
	[930] = 4641,  -- DC II
	[931] = 4675,  -- EH II
	[932] = 5113,  -- CoH II
	[933] = 4813,  -- WS II
	[934] = 4303,  -- FG II
	[935] = 4597,  -- BC II
	[936] = 4555,  -- SC II
	[973] = 5889,  -- BF
	[974] = 5891,  -- FH
	[1009] = 6064,	-- FL
	[1010] = 6065,	-- SCP
	[1052] = 6186,	-- MHK
	[1055] = 6188,	-- MoS
	[1080] = 6249,	-- FV
	[1081] = 6251,	-- DoM
	[1122] = 6349,	-- MGF
	[1123] = 6351,	-- LoM
	[1152] = 6414,	-- IR
	[1153] = 6416,	-- UG
	[1197] = 6505,	-- SG
	[1201] = 6507,	-- CT
	[1228] = 6576,	-- BDV
	[1229] = 6578,	-- CD
	[1267] = 6683,	-- RPB
	[1268] = 6685,	-- DC
	[1301] = 6740,	-- CA
	[1302] = 6742,	-- SR
	[1360] = 6835,	-- ERE
	[1361] = 6837,	-- GD
	[1389] = 6896,	-- BS
	[1390] = 7027,	-- SH
	[1470] = 7105,	-- OP
	[1471] = 7155,	-- BV
	[1496] = 7235,	-- ExR
	[1497] = 7237,	-- LS
	[1551] = 7320,	-- NC
	[1552] = 7323,	-- BGF
}

-- =========================
-- TRIAL DATA
-- =========================
local TRIALS_ZONE_QUEST = {
	[636] = 5087, -- HRC
	[638] = 5102, -- AA
	[639] = 5171, -- SO
	[725] = 5352, -- MoL
	[975] = 5894, -- HoF
	[1000] = 6090, -- AS
	[1051] = 6192, -- CR
	[1121] = 6353, -- SS
	[1196] = 6503, -- KA
	[1263] = 6654, -- RG
	[1344] = 6783, -- DSR
	[1427] = 7031, -- SE
	[1478] = 7212, -- LC
	[1548] = 7306, -- OC
}

-- =========================
-- HELPERS
-- =========================
function DQR.PlayerHasQuest(questId)
	for journalIndex = 1, GetNumJournalQuests() do
		if GetJournalQuestId(journalIndex) == questId then
			return true
		end
	end
end

function DQR.GetRelevantZoneQuest(zoneId)
	return DUNGEON_ZONE_QUEST[zoneId] or TRIALS_ZONE_QUEST[zoneId]
end

function DQR.ShouldShow()
	local zoneId = GetZoneId(GetUnitZoneIndex("player"))
	local questId = DQR.GetRelevantZoneQuest(zoneId)
	return questId and DQR.PlayerHasQuest(questId)
end

-- =========================
-- UI
-- =========================
function DQR.CreateUI()
	DQR.win = WINDOW_MANAGER:CreateTopLevelWindow("DQRWindow")
	DQR.win:SetDimensions(1000, 200)
	DQR.win:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
	DQR.win:SetHidden(true)
	DQR.win:SetMouseEnabled(true)

	local label = DQR.win:CreateControl(nil, CT_LABEL)
	label:SetFont("ZoFontGameLargeBold|72")
	label:SetAnchor(CENTER, DQR.win, CENTER, 0, 0)
	label:SetText("! quest !")
	label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
	label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
	DQR.label = label

	DQR.fragment = ZO_HUDFadeSceneFragment:New(DQR.win)
end

-- =========================
-- POPUP SHOW / HIDE
-- =========================
function DQR.ShowPopup()
	HUD_SCENE:AddFragment(DQR.fragment)
	HUD_UI_SCENE:AddFragment(DQR.fragment)

	DQR.win:SetHandler("OnUpdate", function(_, frameTimeSeconds)
		local t = frameTimeSeconds * 5
		local r = math.abs(math.sin(t))
		local g = math.abs(math.sin(t + 2))
		local b = math.abs(math.sin(t + 4))
		DQR.label:SetColor(r, g, b, 1)
		local xOffset = math.sin(t * 4) * 4
		local yOffset = math.cos(t * 4.5) * 4
		DQR.label:SetAnchor(CENTER, DQR.win, CENTER, xOffset, yOffset)
	end)

	EM:RegisterForUpdate(DQR.name, 1000, function()
		if not DQR.ShouldShow() then
			DQR.HidePopup()
		end
	end)
end

function DQR.HidePopup()
	HUD_SCENE:RemoveFragment(DQR.fragment)
	HUD_UI_SCENE:RemoveFragment(DQR.fragment)
	DQR.win:SetHandler("OnUpdate", nil)
	EM:UnregisterForUpdate(DQR.name)
end

-- =========================
-- EVENT HANDLERS
-- =========================
function DQR.OnContentComplete()
	if DQR.ShouldShow() then
		DQR.ShowPopup()
	end
end

-- =========================
-- INIT
-- =========================
local function OnAddonLoaded(event, addonName)
	if addonName ~= DQR.name then return end
	EM:UnregisterForEvent(DQR.name, EVENT_ADD_ON_LOADED)

	DQR.CreateUI()

	EM:RegisterForEvent(DQR.name, EVENT_ACTIVITY_FINDER_ACTIVITY_COMPLETE, DQR.OnContentComplete)
	EM:RegisterForEvent(DQR.name, EVENT_RAID_TRIAL_COMPLETE, DQR.OnContentComplete)
end

EM:RegisterForEvent(DQR.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)