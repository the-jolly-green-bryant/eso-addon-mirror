local ov = GlByGrhmForOverview

local win = "champion"
ov.ctrl.subHeader[win] = {}
ov.ctrl.control[win] = {}

local ctrl = {}
ctrl.discipline = {}
ctrl.skillName = {}
ctrl.skillText =  {}
local di = 0
local si = 0
local dSort = { [1] = 3, [2] = 1, [3] = 2}
for i = 1, 3 do
	ctrl.skillName[i] = {}
	ctrl.skillText[i] = {}
end
local dHeight = 0

function ov.createChampion()
	
	local dAnchor = 0
	local dSpacerX = 0
	
	local dColor = "endurance"

	for di = 1, 3 do
		
		ov.backdrop(di, win, 270, 100, 0 + dSpacerX, 30)
	
		ctrl.discipline[di] = ov.ctrl.wm:CreateControl(string.format("OverviewChampionDiscipline%d-%s", di, win), ov.ctrl.tlw[win], CT_LABEL)
		ctrl.discipline[di]:SetAnchor(TOP, ov.ctrl.control[win][di], TOP, 5, 5)
		ctrl.discipline[di]:SetDimensions(190, 25)
		ctrl.discipline[di]:SetFont(ov.font.big)
		ctrl.discipline[di]:SetColor(ov.getColor(dColor))
		ctrl.discipline[di]:SetWrapMode(ELLIPSIS)
		ctrl.discipline[di]:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
		ctrl.discipline[di]:SetText(zo_strformat("<<Z:1>>", GetChampionDisciplineName(dSort[di])))
		
		dAnchor = ctrl.discipline[di]
		
		for si = 1, 4 do
			ctrl.skillName[di][si] = ov.ctrl.wm:CreateControl(string.format("OverviewChampionSkillText%d-%d-%s", di, si, win), ov.ctrl.tlw[win], CT_LABEL)
			ctrl.skillName[di][si]:SetAnchor(TOP, dAnchor, BOTTOM, 0, 10)
			ctrl.skillName[di][si]:SetDimensions(264, nil)
			ctrl.skillName[di][si]:SetFont(ov.font.element)
			ctrl.skillName[di][si]:SetColor(ov.getColor(dColor))
			ctrl.skillName[di][si]:SetWrapMode(ELLIPSIS)
			ctrl.skillName[di][si]:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
			
			ctrl.skillText[di][si] = ov.ctrl.wm:CreateControl(string.format("OverviewChampionValueText%d-%d-%s", di, si, win), ov.ctrl.tlw[win], CT_LABEL)
			ctrl.skillText[di][si]:SetAnchor(TOP, ctrl.skillName[di][si], BOTTOM, -1, 0)
			ctrl.skillText[di][si]:SetDimensions(264, nil)
			ctrl.skillText[di][si]:SetColor(ov.getColor("gold"))
			ctrl.skillText[di][si]:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
			ctrl.skillText[di][si]:SetFont(ov.font.subElement)
			ctrl.skillText[di][si]:SetWrapMode(ELLIPSIS)
			
			dAnchor = ctrl.skillText[di][si]
		end
		
		if di == 1 then 
			dSpacerX  = 275
			dColor = "magicka"
		end
		
		if di == 2 then 
			dSpacerX  = 550
			dColor = "life"
		end
	end
end

function ov.championFill()

	local dHeight = 0
	
	local cpAdd = ""
	if not DoesCurrentCampaignRulesetAllowChampionPoints() and ov.isInPvPArea() then
		cpAdd = zo_strformat(" |cFF0000<<z:1>>|r", GetString(SI_MARKET_SUBSCRIPTION_PAGE_SUBSCRIPTION_STATUS_NOT_ACTIVE))
	end
	ov.ctrl.header[win]:SetText(zo_strformat("<<1>><<2>>", ov.text.champion, cpAdd))
	
	local bonus = ""
	local bonusTxt = ""
	local skillId = 0
	local id = 1
	
	for di = 1, 3 do
		
		dHeight = 0
		for si = 1, 4 do
			skillId = GetSlotBoundId(id, HOTBAR_CATEGORY_CHAMPION)
			bonus = GetChampionSkillCurrentBonusText(skillId, GetNumPointsSpentOnChampionSkill(skillId))
			
			if bonus ~= "" then 
				bonusTxt = zo_strformat("\n<<Z:1>>: <<C:2>>", GetString(SI_GAMEPAD_LFG_QUEUE_ACTUAL), bonus)
			else 
				bonusTxt = ""
			end
			
			ctrl.skillName[di][si]:SetText(zo_strformat("<<C:1>>", GetChampionSkillName(skillId)))
			ctrl.skillText[di][si]:SetText(zo_strformat("<<C:1>><<C:2>>", GetChampionSkillDescription(skillId), bonusTxt))
			
			id = id + 1
			dHeight = dHeight + 20 + ctrl.skillText[di][si]:GetHeight() + ctrl.skillName[di][si]:GetHeight()
		end
		ov.ctrl.control[win][di]:SetHeight(dHeight)
	end
end