LO = LO or {}
LO.name = "LeadOverview"
LO.version = "1.1.1"

LO.maxEntriesPerPage = 18

LO.pageIndex = 1
LO.entries = 0

LO.sortAlgo = "DIFFICULTYDESC"
LO.sortOrder = "DESC"

LO.COLORS = {
	[ANTIQUITY_DIFFICULTY_TRIVIAL] = "|cFFFFFF",		--white
	[ANTIQUITY_DIFFICULTY_SIMPLE] = "|c2DC50E",			--green
	[ANTIQUITY_DIFFICULTY_INTERMEDIATE] = "|c3A92FF", 	--blue
	[ANTIQUITY_DIFFICULTY_ADVANCED] = "|cA02EF7",		--purple
	[ANTIQUITY_DIFFICULTY_MASTER] = "|cCCAA1A",			--gold
	[ANTIQUITY_DIFFICULTY_ULTIMATE] = "|cE58B27",		--orange
}

LO.SORT = {
	["DIFFICULTYASC"] = function(a, b) return a.difficulty < b.difficulty end,
	["DIFFICULTYDESC"] = function(a, b) return a.difficulty > b.difficulty end,
	["ZONEASC"] = function(a, b) return a.zone < b.zone end,
	["ZONEDESC"] = function(a, b) return a.zone > b.zone end,
	["REWARDASC"] = function(a, b) return a.reward.name < b.reward.name end,
	["REWARDDESC"] = function(a, b) return a.reward.name > b.reward.name end,
}

LO.BUTTONS = {
	["ASC"] = {
		normal = "esoui/art/progression/progression_crafting_delevel_up.dds",
		pressed = "esoui/art/progression/progression_crafting_delevel_down.dds",
		mouseOver = "esoui/art/progression/progression_crafting_delevel_over.dds",
	},
	["DESC"] = {
		normal = "esoui/art/progression/progression_crafting_unlocked_up.dds",
		pressed = "esoui/art/progression/progression_crafting_unlocked_down.dds",
		mouseOver = "esoui/art/progression/progression_crafting_unlocked_over.dds",
	},
}

function LO.AddDummyValues(leads)
	for i = 1, 45 do
		leads[#leads+1] = {
			name = "Dummy Item " .. i,
			difficulty = math.random(1, 4),
			zone = "Auridon",
			reward = {
				name = "Dummy Reward",
				quality = 0,
			},
		}
	end
end

function LO.Open()
	if LeadList:IsHidden() == true then
		LeadList:SetHidden(false)
	else
		LeadList:SetHidden(true)
	end
end

function LO.Sort(algo)

	if LO.sortOrder == "ASC" then
		LO.sortOrder = "DESC"
	elseif LO.sortOrder == "DESC" then
		LO.sortOrder = "ASC"
	end

	if algo == "DIFFICULTY" then
		LeadListSortDifficulty:SetNormalTexture(LO.BUTTONS[LO.sortOrder].normal)
		LeadListSortDifficulty:SetPressedTexture(LO.BUTTONS[LO.sortOrder].pressed)
		LeadListSortDifficulty:SetMouseOverTexture(LO.BUTTONS[LO.sortOrder].mouseOver)
	elseif algo == "ZONE" then
		LeadListSortZone:SetNormalTexture(LO.BUTTONS[LO.sortOrder].normal)
		LeadListSortZone:SetPressedTexture(LO.BUTTONS[LO.sortOrder].pressed)
		LeadListSortZone:SetMouseOverTexture(LO.BUTTONS[LO.sortOrder].mouseOver)
	elseif algo == "REWARD" then
		LeadListSortReward:SetNormalTexture(LO.BUTTONS[LO.sortOrder].normal)
		LeadListSortReward:SetPressedTexture(LO.BUTTONS[LO.sortOrder].pressed)
		LeadListSortReward:SetMouseOverTexture(LO.BUTTONS[LO.sortOrder].mouseOver)
	end
	
	LO.sortAlgo = algo .. LO.sortOrder
	LO.BuildTable()
end

--this needs to be refactored in the near future
function LO.TurnPage(direction)
	
	local maxPage = LO.entries / LO.maxEntriesPerPage
	local maxPageNoDecimals = (LO.entries - LO.entries % LO.maxEntriesPerPage) / LO.maxEntriesPerPage
	if (maxPage - maxPageNoDecimals) > 0 then maxPage = maxPageNoDecimals + 1 end
	
	local rightEnabled = (LO.pageIndex < maxPage) and true or false
	LeadListPageRight:SetEnabled(rightEnabled)

	local leftEnabled = (LO.pageIndex > 1) and true or false
	LeadListPageLeft:SetEnabled(leftEnabled)

	if direction > 0 and rightEnabled == true then
		LO.pageIndex = LO.pageIndex + 1
		LO.BuildTable(LO.pageIndex)
	elseif direction < 0 and leftEnabled == true then
		LO.pageIndex = LO.pageIndex - 1
		LO.BuildTable(LO.pageIndex)
	end
	
	LeadListPageIndex:SetText(LO.pageIndex .. " / " .. maxPage)
	
	rightEnabled = (LO.pageIndex < maxPage) and true or false
	LeadListPageRight:SetEnabled(rightEnabled)

	leftEnabled = (LO.pageIndex > 1) and true or false
	LeadListPageLeft:SetEnabled(leftEnabled)
end

function LO.GetLeadTable()

	local leads = {}
	
	local antiquityId = GetNextAntiquityId()
    while antiquityId do
		local haveLead = DoesAntiquityHaveLead(antiquityId)
		if haveLead then
		
			local setId = GetAntiquitySetId(antiquityId)
			local rewardName = GetAntiquitySetName(setId)
			local rewardQuality = GetAntiquitySetQuality(setId)
			local rewardId = GetAntiquityRewardId(antiquityId)
			
			if rewardName == "" then
				rewardName = REWARDS_MANAGER:GetRewardContextualTypeString(rewardId)
				rewardQuality = GetAntiquityQuality(antiquityId)
			end
			
			local antiquityDifficulty = GetAntiquityDifficulty(antiquityId)
			if rewardQuality < ANTIQUITY_DIFFICULTY_ADVANCED then
				antiquityDifficulty = rewardQuality
			end
			
			leads[#leads+1] = {
				name = zo_strformat("<<C:1>>", GetAntiquityName(antiquityId)),
				difficulty = antiquityDifficulty,
				zone = zo_strformat("<<C:1>>", GetZoneNameById(GetAntiquityZoneId(antiquityId))),
				reward = {
					name = zo_strformat("<<C:1>>", rewardName),
					quality = rewardQuality,
				},
			}
		end
        antiquityId = GetNextAntiquityId(antiquityId)
    end
		
	if LO.sortAlgo ~= nil and LO.sortAlgo ~= "" then
		table.sort(leads, LO.SORT[LO.sortAlgo])
	end
	
	LO.entries = #leads

	return leads
end

function LO.BuildTable()
	
	local names = "|cCFDCBDName|r\n"
	local zones = "|cCFDCBDZone|r\n"
	local rewards = "|cCFDCBDReward|r\n"
	
	local antiquities = LO.GetLeadTable()

	local startValue = LO.maxEntriesPerPage * (LO.pageIndex - 1) + 1
	local endValue = startValue + LO.maxEntriesPerPage - 1

	for i = startValue, endValue do
		if antiquities[i] ~= nil then
			local name = antiquities[i].name
			local difficulty = antiquities[i].difficulty
			local zone = antiquities[i].zone
			local reward = antiquities[i].reward
		
			names = string.format("%s%s%s%s", names, LO.COLORS[difficulty], name, "|r\n")
			zones = string.format("%s%s%s", zones, zone, "\n")
			rewards = string.format("%s%s%s%s", rewards, LO.COLORS[reward.quality], reward.name, "|r\n")
		end
	end
	
	LeadListNames:SetText(names)
	LeadListZones:SetText(zones)
	LeadListRewards:SetText(rewards)
end

--hopefully fixes empty lead list at game start
function LO.OnFirstWindowOpen()
	ANTIQUITY_JOURNAL_KEYBOARD_SCENE:UnregisterCallback("StateChange", LO.OnFirstWindowOpen)
	LO.BuildTable()
	LO.TurnPage(0)
end

function LO.OnWindowMove()
	LO.savedVariables.windowTop = LeadList:GetTop()
	LO.savedVariables.windowLeft = LeadList:GetLeft()
end

function LO.RestoreWindowPosition()
	LeadList:ClearAnchors()
	LeadList:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, LO.savedVariables.windowLeft, LO.savedVariables.windowTop)
end

function LO.InitSavedVariables()
	local defaults = {
		windowTop = 190,
		windowLeft = 110,
	}
	LO.savedVariables = ZO_SavedVars:NewAccountWide("LOSV", 1, nil, defaults)
end

function LO.OnAddOnLoaded(_, addonName)
	if addonName ~= LO.name then return end
	
	LO.fragment = ZO_HUDFadeSceneFragment:New(LeadList)
	ANTIQUITY_JOURNAL_KEYBOARD_SCENE:AddFragment(LO.fragment)
	
	ZO_CreateStringId("SI_BINDING_NAME_LEADOVERVIEW_OPENMENU", "Toggle Window")
	SLASH_COMMANDS["/leads"] = LO.Open
	
	LO.InitSavedVariables()
	LO.RestoreWindowPosition()
	
	ANTIQUITY_JOURNAL_KEYBOARD_SCENE:RegisterCallback("StateChange", LO.OnFirstWindowOpen)
	
	EVENT_MANAGER:RegisterForEvent(LO.name, EVENT_ANTIQUITY_LEAD_ACQUIRED, LO.BuildTable)
	EVENT_MANAGER:RegisterForEvent(LO.name, EVENT_ANTIQUITY_DIGGING_EXIT_RESPONSE, LO.BuildTable)
end

EVENT_MANAGER:RegisterForEvent(LO.name, EVENT_ADD_ON_LOADED, LO.OnAddOnLoaded)