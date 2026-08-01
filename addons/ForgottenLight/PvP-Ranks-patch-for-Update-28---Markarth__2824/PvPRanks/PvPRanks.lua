
local LAM2 = LibAddonMenu2

--===================================--
-- Create Tables used in the addon --
--===================================--
local PvPRanks 		= ZO_Object:New()
local ADDON_NAME 	= "PvPRanks"
local CODE_VERSION 	= 2.4
local ROW_HEIGHT 	= 30
local ESO_STATS_LOADED = false

local ASSAULT_SKILL_LINE_INDEX	 = 1
local SUPPORT_SKILL_LINE_INDEX	 = 2
local MAX_SKILL_LINE_RANK		 = 10

--=====================================================--
--======= DEBUG =========--
--=====================================================--
local DEBUG_MODE = false

local function debugMsg(msg, tableItem)
	if not DEBUG_MODE then return end
	if not PVP_RANKS_DEBUG_TABLE then PVP_RANKS_DEBUG_TABLE = {} end
	
	if msg and msg ~= "" then
		d(msg)
		table.insert(PVP_RANKS_DEBUG_TABLE, msg)
	end
	
	-- Used to save object references for later examination:
	if tableItem then
		table.insert(PVP_RANKS_DEBUG_TABLE, tableItem)
	end
end
--=====================================================--
--=====================================================--
function PvPRanks:New()
	local obj = ZO_Object.New(self)
	local mt = getmetatable(obj)
	mt.__index = self
	obj.name 	= ADDON_NAME
	obj.version = CODE_VERSION
	--=================================--
	--=================================--
	obj.savedVarVersion = 1.8 -- saved var version do not touch
	--=================================--
	--=================================--
	obj.rankInfo = {}
	obj.skillUnlocksByRank = {}
	obj.sv = {}
	obj.colors = {
		red			= "|cFF0000",
		darkOrange 	= "|cFFA500",
		yellow 		= "|cFFFF00",
	}
	
	return obj
end

function PvPRanks:Initialize()
	self.playerRank 			= GetUnitAvARank("player")
	self.playerGender 			= GetUnitGender("player")
	
	local defaultSavedVars = {
		["RANK_HIGHLIGHT_COLOR"] = {1, 0, 0, 1}
	}
	self.sv = ZO_SavedVars:New("PvPRanksSavedVars", self.version, nil, defaultSavedVars)
	
	self.scrollList = self:CreateScrollList()
	
	self:InitializeRankInfo()
	self:InitializeSkillUnlocksByRank()
	self:UpdateRankInfoWithSkillUnlocks()
	self:UpdateScrollList()
end

--=====================================================--
--======= Initialize RankInfo & Skill Unlocks =========--
--=====================================================--
-- Initialize basic rank information: rank, starting/ending AP, rank name, rank icon
function PvPRanks:InitializeRankInfo()
	local MAX_AVA_RANK 			= 50
	local currentRankPoints 	= 0
	self.rankInfo 				= {}
	
	--local startsAt, nextRankXp = GetSkillLineRankXPExtents(SKILL_TYPE_AVA, 1, 1) 
	
	-- Gather AVA Rank unlock information
	for rank=0, MAX_AVA_RANK do
		-- GetNumPointsNeededForAvARank(rank)
		local subRankStartsAt, nextSubRankAt, rankStartsAt, nextRankAt  = GetAvARankProgress(currentRankPoints)
		local rankEndsAt = rankStartsAt ~= nextRankAt and nextRankAt - 1 or nil
		
		currentRankPoints = nextRankAt+1
		
		local rankName 	= zo_strformat(SI_STAT_RANK_NAME_FORMAT, GetAvARankName(self.playerGender, rank))
		local rankIcon 	= GetAvARankIcon(rank) 
		local data 		= {["rank"] = rank, ["startsAt"] = rankStartsAt, ["endsAt"] = rankEndsAt, ["rankName"] = rankName, ["rankIcon"] = rankIcon}
		
		table.insert(self.rankInfo, data)
	end
end

-- Try to initialize the skillUnlocksByRank table. It holds all of the starting/ending xp information for
-- AVA skill ranks and what skills are unlocked at each rank.
--[[ Since API Fails at gathering skill unlock information when the player does not have an assigned campaign we must attempt to gather this unlock information on startup (if possible) and also try to gather it when the event EVENT_ASSIGNED_CAMPAIGN_CHANGED is fired. This way a new player who does not have a campaignId, but then is assigned a campaign will get this data populated when the event is fired since it can not be gathered when the addon is loaded due to API limitations.
--]]
function PvPRanks:InitializeSkillUnlocksByRank()
	-- API fails if the player does not have a campaign assigned.
	-- Will have to also run this on the EVENT_ASSIGNED_CAMPAIGN_CHANGED event.
	if GetAssignedCampaignId() == 0 then return end
	
	--self.skillUnlocksByRank = {}
	local skillUnlocksByRank = self.skillUnlocksByRank
	
	-- Changing campaigns does not change the xp requirements or skill unlock info
	-- so theres no need to run this again once the skillUnlocksByRank table has been created
	if next(skillUnlocksByRank) ~= nil then return end
	
	-- Gather information about xp needed for skill unlocks
	-- Assualt & support have the same starting/ending rank xp
	for skillLineRank = 1, MAX_SKILL_LINE_RANK do
		local startsAt, nextRankStartsAt, endsAt
		
		if skillLineRank == 10 then
			local _, nextRankStartsAt = GetSkillLineRankXPExtents(SKILL_TYPE_AVA, skillIndex, skillLineRank-1)
			startsAt = nextRankStartsAt
			--nextRankStartsAt = nill
		else
			startsAt, nextRankStartsAt = GetSkillLineRankXPExtents(SKILL_TYPE_AVA, skillIndex, skillLineRank)
			if nextRankStartsAt ~= nil then
				endsAt = nextRankStartsAt - 1
			else 
				return
			end
		end

		skillUnlocksByRank[skillLineRank] = {rankUnlocked = skillLineRank,	startsAt=startsAt, endsAt=endsAt, 
			skillsUnlocked = {
				-- looks like this:
				--[ASSAULT_SKILL_LINE_INDEX] = {},
				--[SUPPORT_SKILL_LINE_INDEX] = {},
			},
		}
	end
	
	-- Find out what skills are unlocked with those ranks:
	for skillLineIndex = 1, 2 do
		local numAbilities = GetNumSkillAbilities(SKILL_TYPE_AVA, skillLineIndex)
		for abilityIndex = 1, numAbilities do
			local name, icon, skillLineRank, isPassive = GetSkillAbilityInfo(SKILL_TYPE_AVA, skillLineIndex, abilityIndex)
			
			local skillInfo = {
				skillName 		= name,
				iconPath 		= icon,
				earnedAtRank	= skillLineRank,
				isPassive		= isPassive,
			}
			if not skillUnlocksByRank[skillLineRank].skillsUnlocked[skillLineIndex] then
				skillUnlocksByRank[skillLineRank].skillsUnlocked[skillLineIndex] = {}
			end
			table.insert(skillUnlocksByRank[skillLineRank].skillsUnlocked[skillLineIndex], skillInfo)
		end
	end
end

--[[ Since API Fails at gathering skill unlock information when the player does not have an assigned campaign we must attempt insert the unlock information into the rankInfo table on startup (if possible) and also try to insert the information when the event EVENT_ASSIGNED_CAMPAIGN_CHANGED is fired. This way a new player who does not have a campaignId, but then is assigned a campaign will get this data populated when the event is fired since it can not be populated when the addon is loaded due to API limitations.
--]]
function PvPRanks:UpdateRankInfoWithSkillUnlocks()
	local rankInfo 				= self.rankInfo
	local skillUnlocksByRank 	= self.skillUnlocksByRank
	
	-- For new chars that haven't unlocked campaigns yet, this table will not exist
	-- because the API does not allow access to that information.
	if next(skillUnlocksByRank) == nil then return end
	
	-- Used to determine if a skill rank is unlocked for some ava ap range since the
	-- skill ranks no longer unlock at the same time ava ranks level up.
	local function GetSkillRankUnlocked(startAp, endAp)
		for skillLineRank = 1, MAX_SKILL_LINE_RANK do
			local skillLineStartsAt = skillUnlocksByRank[skillLineRank].startsAt
			if skillLineStartsAt >= startAp and (not endAp or skillLineStartsAt <= endAp) then
				return skillLineRank
			end
		end
	end
	
	for rank, rankData in ipairs(rankInfo) do
		local unlockedSkillRank = GetSkillRankUnlocked(rankData.startsAt, rankData.endsAt)
		
		rankData.unlocks = skillUnlocksByRank[unlockedSkillRank]
	end
end


--=====================================================--
--======= ScrollList Functions =========--
--=====================================================--
function PvPRanks:UpdateScrollList()
	local rankInfo 		= self.rankInfo
	local scrollList	= self.scrollList
	
	ZO_ScrollList_Clear(scrollList)
	
	local entryList = ZO_ScrollList_GetDataList(scrollList)
	
	for rank=1, #rankInfo do
		local entry = ZO_ScrollList_CreateDataEntry(1, rankInfo[rank])
		table.insert(entryList, entry)
	end
	
	ZO_ScrollList_Commit(scrollList)
end

function PvPRanks:CreateScrollList()
	local tlw = WINDOW_MANAGER:CreateTopLevelWindow("PvPRanks") 
	tlw:SetDimensions(275, 500)
	tlw:SetHidden(true)
	tlw:SetMouseEnabled(true)
	tlw:SetMovable(false)
	-- Exception for positioning if esoStats is loaded.
	if ESO_STATS_LOADED then
		local esoStatsBtn = GetControl("EsoStatsToggleButton")
		tlw:ClearAnchors()
		tlw:SetAnchor(TOPLEFT, esoStatsBtn, BOTTOMLEFT, -5, 0)
		tlw:SetDimensions(275, 400)
	else
		tlw:SetAnchor(TOPLEFT, ZO_CampaignOverviewCategoriesContainer1, BOTTOMLEFT, 15, 0)
	end
	
	tlw:SetHandler("OnShow", function()
		self.playerRank = GetUnitAvARank("player")
		local scrollList = PVP_RANKS.scrollList
		local scrollBar = scrollList.scrollbar
		local minValue, maxValue = scrollBar:GetMinMax()
		local centerValue = self.playerRank * ROW_HEIGHT-(scrollList:GetHeight()/2)
		scrollBar:SetValue(centerValue)
	end)
	
	local list = WINDOW_MANAGER:CreateControlFromVirtual("PvPRanksScrollList", tlw, "ZO_ScrollList") 
	self.scrollList = list
	list:SetAnchor(TOPLEFT, tlw, TOPLEFT, 10, 30)
	list:SetAnchor(BOTTOMRIGHT, tlw, BOTTOMRIGHT, -10, -10)
	list:SetAlpha(1)
	
	self.FRAGMENT_WINDOW = ZO_FadeSceneFragment:New(tlw)
	
	CAMPAIGN_OVERVIEW_SCENE:AddFragment(self.FRAGMENT_WINDOW)
	
	self.c_tlw = tlw
	self.c_tlwbg = bg
	self.c_scrollList = list
	
	local function AddTooltipLine(tooltip, line, padUp)
		if padUp then
			tooltip:AddVerticalPadding(-10) 
		end
		tooltip:AddLine(line, "ZoFontGame", 1, 1, 1, TOPLEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT, true)
	end

    local function ShowTooltip(rowControl, data)
		local AP_ICON = zo_iconFormat("EsoUI/Art/currency/alliancePoints.dds", 14, 14)
	   InitializeTooltip(InformationTooltip, rowControl, TOPRIGHT, -50, 0, TOPLEFT)
	   
		local rankNameHeading = zo_iconTextFormat(data.rankIcon, 35, 35, data.rankName)
		InformationTooltip:AddLine(rankNameHeading, "ZoFontGame", 1, 1,1, TOPLEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true) 
		
		ZO_Tooltip_AddDivider(InformationTooltip)
		
		local currentRankString	= zo_strformat("<<1>><<2>>|r <<3>>", self.colors.yellow, GetString(SI_STAT_TRADESKILL_RANK), data.rank)
		local startsAtString 	= zo_strformat("<<1>><<2>>|r <<3>> <<4>>", self.colors.yellow, "Starts at:", ZO_CommaDelimitNumber(data.startsAt), AP_ICON)
		
		AddTooltipLine(InformationTooltip, currentRankString, false)
		AddTooltipLine(InformationTooltip, startsAtString, true)
		
		-- exception for AVA Rank 50, has no end xp
		if data.endsAt then
			local EndsAtString		= zo_strformat("<<1>><<2>>|r <<3>> <<4>>", self.colors.yellow, "Ends at:", ZO_CommaDelimitNumber(data.endsAt), AP_ICON)
			AddTooltipLine(InformationTooltip, EndsAtString, true)
		end
		
		local unlocks = data.unlocks
		
		if unlocks then
			ZO_Tooltip_AddDivider(InformationTooltip)
			
			local skillType = SKILL_TYPE_AVA
			local skillAssaultName = GetSkillLineInfo(SKILL_TYPE_AVA, 1) 
			local skillSupportName = GetSkillLineInfo(SKILL_TYPE_AVA, 2)
			
			skillAssaultName = zo_strformat(SI_SKILLS_TREE_NAME_FORMAT, skillAssaultName)
			skillSupportName = zo_strformat(SI_SKILLS_TREE_NAME_FORMAT, skillSupportName)
			
			local unlocksHeading	= zo_strformat("<<1>> <<2>> <<3>> <<4>>", GetString(SI_GUILDHISTORYGENERALSUBCATEGORIES3), "at", ZO_CommaDelimitNumber(unlocks.startsAt), AP_ICON)
			InformationTooltip:AddLine(unlocksHeading, "ZoFontGame", 1, .5,0, TOPLEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true) 
			
			ZO_Tooltip_AddDivider(InformationTooltip)
			
			local rank			 = GetString(SI_GUILD_TOOLTIP_RANK)
			local assaultUnlocks = unlocks.skillsUnlocked[ASSAULT_SKILL_LINE_INDEX]
			local supportUnlocks = unlocks.skillsUnlocked[SUPPORT_SKILL_LINE_INDEX]
			
			local function AddUnlockedSkills(skillTable)
				for i=1, #skillTable do
					local unlockedSkill	= zo_iconTextFormat(skillTable[i].iconPath, 35, 35, skillTable[i].skillName)
					InformationTooltip:AddLine(unlockedSkill, "ZoFontGame", 1, .5,0, TOPLEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
				end
			end

			local assaultRankUnlocked	= zo_strformat("<<1>> <<2>> <<3>>", skillAssaultName, rank, unlocks.rankUnlocked)
			InformationTooltip:AddLine(assaultRankUnlocked, "ZoFontGame", 1, .5,0, TOPLEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT, true) 
			
			if assaultUnlocks then
				AddUnlockedSkills(assaultUnlocks)
			end
			
			local supportRankUnlocked	= zo_strformat("<<1>> <<2>> <<3>>", skillSupportName, rank, unlocks.rankUnlocked)
			InformationTooltip:AddLine(supportRankUnlocked, "ZoFontGame", 1, .5,0, TOPLEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT, true) 
			
			if supportUnlocks then
				AddUnlockedSkills(supportUnlocks)
			end
		end
    end
    
    local function HideTooltip(self)   
	   ClearTooltip(InformationTooltip)
    end
    
	local function listRow_Setup(rowControl, data, list)
		rowControl:SetHeight(ROW_HEIGHT)
		rowControl:SetFont("ZoFontWinH4")
		rowControl:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
		rowControl:SetVerticalAlignment(TEXT_ALIGN_CENTER)
		rowControl:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
		
		rowControl:SetHandler("OnMouseEnter", function(rowControl) ShowTooltip(rowControl, data) end)
		rowControl:SetHandler("OnMouseExit", HideTooltip)
		
		local rankInfo = data.dataEntry.data
		if rankInfo.rank == self.playerRank then
			local color = self.sv["RANK_HIGHLIGHT_COLOR"]
			rowControl:SetColor(unpack(color))
		else
			--rowControl:SetColor(1,.784,.588,1)
			rowControl:SetColor(.772549,.760784,.61960,1)
		end
		
		local formattedRankIcon = zo_iconFormat(data.dataEntry.data.rankIcon, 35, 35)
		local formattedRowString = zo_strformat("<<1>>)<<2>><<3>>", rankInfo.rank, formattedRankIcon, data.rankName)
		
		rowControl:SetText(formattedRowString) 
	end 
	
	ZO_ScrollList_AddDataType(list, 1, "ZO_SelectableLabel", ROW_HEIGHT, listRow_Setup) 
	
	return list
end

	
--=====================================================--
--======= Utility Functions =========--
--=====================================================--
local function UpdateRankHighlightColor()
	local color = PVP_RANKS.sv["RANK_HIGHLIGHT_COLOR"]
	local activeControls = PVP_RANKS.scrollList.activeControls
	local playerRank = GetUnitAvARank("player")
	
	for k,rowControl in pairs(activeControls) do
		local rankInfo = rowControl.dataEntry.data
		
		if rankInfo.rank == playerRank then
			rowControl:SetColor(unpack(color))
		else
			rowControl:SetColor(.772549,.760784,.61960,1)
		end
	end
end


--=====================================================--
--======= Event Functions =========--
--=====================================================--
local function OnPlayerActivated()
	-- unregistering here to catch if eso_stats is loaded
	EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
	EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED)
end

local function OnRankPointUpdate(eventCode, unitTag, rankPoints, difference)
	if unitTag ~= "player" then return end
	
	PVP_RANKS.playerRank = GetUnitAvARank("player")
	UpdateRankHighlightColor()
end

local function OnAssignedCampaignChanged(eventCode, newAssignedCampaignId) 
	-- could this even happen? Can they completely remove the assigned campaign?
	-- Just in case its possible:
	if newAssignedCampaignId == 0 then return end
	
	PVP_RANKS:InitializeSkillUnlocksByRank()
	PVP_RANKS:UpdateRankInfoWithSkillUnlocks()
	PVP_RANKS:UpdateScrollList()
end

--****************************************************************--
--****************************************************************--
--------------------------------------------------------------------
--  OnAddOnLoaded  --
--------------------------------------------------------------------
--****************************************************************--
--****************************************************************--
local function OnAddOnLoaded(_event, _sAddonName)
	if _sAddonName == "EsoStats" then
		ESO_STATS_LOADED = true
		if PVP_RANKS then
			local pvpRanks = GetControl("PvPRanks")
			local esoStatsBtn = GetControl("EsoStatsToggleButton")
			PvPRanks:ClearAnchors()
			PvPRanks:SetAnchor(TOPLEFT, esoStatsBtn, BOTTOMLEFT, -5, 0)
			PvPRanks:SetDimensions(275, 400)
		end
	end
	if _sAddonName == ADDON_NAME then
		PVP_RANKS = PvPRanks:New()
		PVP_RANKS:Initialize()
		PVP_RANKS:CreateSettingsMenu()
		
	
		EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
		EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_RANK_POINT_UPDATE, OnRankPointUpdate)
		EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ASSIGNED_CAMPAIGN_CHANGED, OnAssignedCampaignChanged)
	end
end



--===================================--
--  Register Events --
--===================================--
EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)







--===================================--
--=====   Settings Menu   ===========--
--===================================--
function PvPRanks:CreateSettingsMenu()
	local colorYellow = "|cFFFF00" 	-- yellow 
	
	local panelData = {
		type = "panel",
		name = "PvPRanks",
		displayName = "|cFF0000 Circonians |c00FFFF PvPRanks",
		author = "Circonian",
		version = self.version,
		slashCommand = "/pvpranks",
		registerForRefresh = true,
		registerForDefaults = true,
	}
	local cntrlOptionsPanel = LAM2:RegisterAddonPanel("Circonians_PvPRanks_Options", panelData)
	
	local optionsData = {
		[1] = {
			type = "colorpicker",
			name = "Rank Highlight Color",
			tooltip = "Changes the highlight color for your current rank.",
			default = {1,0,0,1},
			getFunc = function() return unpack(self.sv["RANK_HIGHLIGHT_COLOR"]) end,
			setFunc = function(r,g,b,a) self.sv["RANK_HIGHLIGHT_COLOR"] = {r,g,b,a} 
				UpdateRankHighlightColor()
			end,
		},
	}
	LAM2:RegisterOptionControls("Circonians_PvPRanks_Options", optionsData)
end



