local Addon = {}
Addon.Name = "kyoAchievenizer"
Addon.DisplayName = "|cFF5FF5Kyoma's|r Global Achievements"
Addon.Author = "|cFF5FF5Kyoma|r"
Addon.Version = "2.4.0"

local CURRENT_PROFILE_VERSION = 4

local currentProfile = nil
local globalProfile = nil
local profileCombobox = nil

local function GetAchievementName(id)
	return (GetAchievementInfo(id))
end

-- some quick functions for collected achievement data
local function IsAchievementDataCompleted(data)
	return data.timestamp ~= "0" --data.completed -- TODO: change this to data.timestamp ~= "0"
end



local raw_GetEarnedAchievementPoints = GetEarnedAchievementPoints
local new_GetEarnedAchievementPoints = function()
	if not currentProfile then return raw_GetEarnedAchievementPoints() end
	return currentProfile.earnedPoints or 0
end 
local raw_GetTotalAchievementPoints = GetTotalAchievementPoints
local new_GetTotalAchievementPoints = function()
	if not currentProfile then return raw_GetTotalAchievementPoints() end
	return currentProfile.totalPoints or 0
end 


local raw_IsAchievementComplete = IsAchievementComplete
local new_IsAchievementComplete = function(id)
	if not currentProfile then return raw_IsAchievementComplete(id) end
	
	local achievement = currentProfile.achievements[id]
	if not achievement then return raw_IsAchievementComplete(id) end 
	
	return IsAchievementDataCompleted(achievement)
end
local raw_GetAchievementInfo = GetAchievementInfo
local new_GetAchievementInfo = function(id)
	if not currentProfile then return raw_GetAchievementInfo(id) end
	
	local achievement = currentProfile.achievements[id]
	if not achievement then return raw_GetAchievementInfo(id) end 

	local name, desc, points, icon = raw_GetAchievementInfo(id)
	return name, desc, points, icon, IsAchievementDataCompleted(achievement), FormatAchievementLinkTimestamp(achievement.timestamp) --achievement.date, achievement.time
end


--local raw_GetAchievementNumCriteria = GetAchievementNumCriteria
--local new_GetAchievementNumCriteria = function(id)
--	if not currentProfile then return raw_GetAchievementNumCriteria(id) end
--	
--	local achievement = currentProfile.achievements[id]
--	if not achievement then return raw_GetAchievementNumCriteria(id) end 
--	
--	return achievement.numCriteria or 0
--end
local raw_GetAchievementCriterion = GetAchievementCriterion
local new_GetAchievementCriterion = function(id, index)
	if not currentProfile then return raw_GetAchievementCriterion(id, index) end

	local achievement = currentProfile.achievements[id]
	if not achievement then return raw_GetAchievementCriterion(id, index) end 
	
	--local criteria = achievement.criteria[index]
	local desc, _, numRequired = raw_GetAchievementCriterion(id, index)
	local numCompleted = select(index, GetAchievementProgressFromLinkData(id, achievement.progress))
	return desc, numCompleted, numRequired
end

--[[ Not needed since this remains the same regardless of completion or progress
local raw_GetFirstAchievementInLine     = GetFirstAchievementInLine
local new_GetFirstAchievementInLine = function(id)
	if not currentProfile then return raw_GetFirstAchievementInLine(id) end

	local achievement = currentProfile.achievements[id]
	if not achievement then return raw_GetFirstAchievementInLine(id) end 
	
	return achievement.firstId or 0
end
local raw_GetNextAchievementInLine      = GetNextAchievementInLine
local new_GetNextAchievementInLine = function(id)
	if not currentProfile then return raw_GetNextAchievementInLine(id) end

	local achievement = currentProfile.achievements[id]
	if not achievement then return raw_GetNextAchievementInLine(id) end 
	
	return achievement.nextId or 0
end
local raw_GetPreviousAchievementInLine  = GetPreviousAchievementInLine
local new_GetPreviousAchievementInLine = function(id)
	if not currentProfile then return raw_GetPreviousAchievementInLine(id) end

	local achievement = currentProfile.achievements[id]
	if not achievement then return raw_GetPreviousAchievementInLine(id) end 
	
	return achievement.prevId or 0
end
--]]
-- Instead we need this to fix it not returning the previous-in-line if neither was completed yet
local raw_GetPreviousAchievementInLine = GetPreviousAchievementInLine
GetPreviousAchievementInLine = function(id)
	local prev = raw_GetPreviousAchievementInLine(id)
	if prev == 0 then
		local cur = GetFirstAchievementInLine(id)
		while cur > 0 and cur ~= id do
			local next = GetNextAchievementInLine(cur)
			if next == id then
				return cur
			end
			cur = next
		end
	end
	return prev
end


local raw_GetAchievementCategoryInfo   = GetAchievementCategoryInfo
local new_GetAchievementCategoryInfo = function(categoryIndex)
	if not currentProfile then return raw_GetAchievementCategoryInfo(categoryIndex) end

	local name, numSubs, numAch, earnedPoints, totalPoints, hidesPoints = raw_GetAchievementCategoryInfo(categoryIndex)
	local category = currentProfile.categories[name]
	if category then
		earnedPoints = category.earnedPoints
		totalPoints  = category.totalPoints
		numAch = #category.achievements
	end
	return name, numSubs, numAch, earnedPoints, totalPoints, hidesPoints
end
local raw_GetAchievementSubCategoryInfo   = GetAchievementSubCategoryInfo
local new_GetAchievementSubCategoryInfo = function(categoryIndex, subCategoryIndex)
	if not currentProfile then return raw_GetAchievementSubCategoryInfo(categoryIndex, subCategoryIndex) end
	
	local parentName = raw_GetAchievementCategoryInfo(categoryIndex)
	local name, numAch, earnedPoints, totalPoints, hidesPoints = raw_GetAchievementSubCategoryInfo(categoryIndex, subCategoryIndex)
	local category = currentProfile.categories[parentName]
	if category then
		local subcategory = category[name]
		if subcategory then
			earnedPoints = subcategory.earnedPoints
			totalPoints  = subcategory.totalPoints
			numAch = #subcategory.achievements
		end
	end
	return name, numAch, earnedPoints, totalPoints, hidesPoints
end

--|H1:achievement:2027:4095:1511549485|h|h
local ACHIEVEMENT_LINK_FORMAT = "|H%d:achievement:%d:%s:%s|h|h"
local raw_GetAchievementLink   = GetAchievementLink
local new_GetAchievementLink = function(id, linkType)
	if not currentProfile then return raw_GetAchievementLink(id, linkType) end
	
	local achievement = currentProfile.achievements[id]
	if not achievement then return raw_GetAchievementLink(id, linkType) end 
	
	return ACHIEVEMENT_LINK_FORMAT:format(linkType, id, achievement.progress, achievement.timestamp)
end


local raw_GetAchievementId = GetAchievementId
local new_GetAchievementId = function(categoryIndex, subCategoryIndex, achievementIndex)
	if not currentProfile then return raw_GetAchievementId(categoryIndex, subCategoryIndex, achievementIndex) end

	local parentName = raw_GetAchievementCategoryInfo(categoryIndex)
	local category = currentProfile.categories[parentName]
	if category then
		local achievementList = category.achievements
		if subCategoryIndex then
			local name = raw_GetAchievementSubCategoryInfo(categoryIndex, subCategoryIndex)
			local subcategory = category[name]
			if subcategory then
				achievementList = subcategory.achievements
			end
		end
		return achievementList[achievementIndex]
	end
	return 0
end


local MAX_RECENTLY_COMPLETED_ACHIEVEMENTS = 10
local raw_GetRecentlyCompletedAchievements = GetRecentlyCompletedAchievements
local new_GetRecentlyCompletedAchievements = function(numAchievementsToGet)
	if not currentProfile then return raw_GetRecentlyCompletedAchievements(numAchievementsToGet) end

	local result = {}
	for i=1, numAchievementsToGet do
		result[i] = currentProfile.recentlyCompleted[i]
	end
	return unpack(result)
end


local function HookAchievements()
	GetEarnedAchievementPoints             = new_GetEarnedAchievementPoints
	GetTotalAchievementPoints              = new_GetTotalAchievementPoints
	IsAchievementComplete                  = new_IsAchievementComplete
	GetAchievementInfo                     = new_GetAchievementInfo
	GetAchievementCriterion                = new_GetAchievementCriterion
	GetAchievementCategoryInfo             = new_GetAchievementCategoryInfo
	GetAchievementSubCategoryInfo          = new_GetAchievementSubCategoryInfo
	GetAchievementLink                     = new_GetAchievementLink
	GetAchievementId                       = new_GetAchievementId
	GetRecentlyCompletedAchievements       = new_GetRecentlyCompletedAchievements
end

local function UnhookAchievements()
	GetEarnedAchievementPoints             = raw_GetEarnedAchievementPoints
	GetTotalAchievementPoints              = raw_GetTotalAchievementPoints
	IsAchievementComplete                  = raw_IsAchievementComplete
	GetAchievementInfo                     = raw_GetAchievementInfo
	GetAchievementCriterion                = raw_GetAchievementCriterion
	GetAchievementCategoryInfo             = raw_GetAchievementCategoryInfo
	GetAchievementSubCategoryInfo          = raw_GetAchievementSubCategoryInfo
	GetAchievementLink                     = raw_GetAchievementLink
	GetAchievementId                       = raw_GetAchievementId
	GetRecentlyCompletedAchievements       = raw_GetRecentlyCompletedAchievements
end


local function CollectAchievementProfile()
	local profile = {}

	profile.name = GetUnitName("player")
	profile.version = CURRENT_PROFILE_VERSION
	profile.earnedPoints = raw_GetEarnedAchievementPoints()
	profile.totalPoints = raw_GetTotalAchievementPoints()
	profile.achievements = {} -- contains ALL achievements' data
	profile.recentlyCompleted = {raw_GetRecentlyCompletedAchievements(MAX_RECENTLY_COMPLETED_ACHIEVEMENTS)}

	local function CollectAchievement(id)
		local achievement = {}
		-- store it in advance
		profile.achievements[id] = achievement
		local _, _, _, _, completed, date, time = raw_GetAchievementInfo(id)
		-- base info
		--achievement.id = id
		--achievement.completed = completed -- might remove this later on and just check timestamp ~= "0" -- yep, time to remove it
		achievement.progress, achievement.timestamp = select(5, ZO_LinkHandler_ParseLink(raw_GetAchievementLink(id, LINK_STYLE_BRACKETS)))

		return achievement
	end

	-- returns the first in-progress achievement in the line
	local function CollectAchievementsInLine(id)
		local firstId = GetFirstAchievementInLine(id)
		id = firstId > 0 and firstId or id
		local result = ZO_GetNextInProgressAchievementInLine(id)
		while id > 0 do
			CollectAchievement(id)
			id = GetNextAchievementInLine(id)
		end
		return result
	end

	profile.categories = {}
	for i=1,GetNumAchievementCategories() do
		local name, numSub, numAch, earnedPoints, totalPoints = raw_GetAchievementCategoryInfo(i)
		local category = 
		{
			earnedPoints = earnedPoints,
			totalPoints  = totalPoints,
			achievements = {}, -- contains just achievement ids
		}
		for j=1,numAch do
			category.achievements[j] = CollectAchievementsInLine(raw_GetAchievementId(i,nil,j))
		end
		profile.categories[name] = category

		for j=1,numSub do
			name, numAch, earnedPoints, totalPoints = raw_GetAchievementSubCategoryInfo(i,j) 
			local subcategory = 
			{
				earnedPoints = earnedPoints,
				totalPoints  = totalPoints,
				achievements = {}, -- contains just achievement ids
			}
			for k=1,numAch do
				subcategory.achievements[k] = CollectAchievementsInLine(raw_GetAchievementId(i,j,k))
			end
			category[name] = subcategory
		end
	end

	return profile
end

local function CollectCurrentProfile()
	Addon.Settings.profiles[GetUnitName("player")] = CollectAchievementProfile()
end


local function BuildGlobalProfile()

	local interProfile = CollectAchievementProfile() -- use current character as base
	interProfile.earnedPoints = 0 -- reset this as we calculate it after merging
	interProfile.totalPoints  = 0 -- reset this as we calculate it after merging
	interProfile.categories = {} -- we don't need this since we completely rebuild it after
	--df("CompileGlobalProfile for: %s", interProfile.name)

	local function CompareAchievements(cur, cmp)
		if not cur then return cmp end -- in case an achievement is missing, should not happen tho
		if IsAchievementDataCompleted(cur) then 
			return cur -- always take local achievement even if another char had it earlier
		elseif IsAchievementDataCompleted(cmp) then
			return cmp
		else
			-- neither was completed so we take the local one, comparing the 'progress' is rather messy and pointless often
			return cur
		end
	end

	for name,profile in pairs(Addon.Settings.profiles) do
		if name ~= interProfile.name then
			--df("Processing...%s", name)
			-- iterate over achievements and integrate completed as we find them 
			for id, achievement in pairs(profile.achievements) do
				-- compare and store the 'most completed', ignore timestamp for now
				interProfile.achievements[id] = CompareAchievements(interProfile.achievements[id], achievement)
			end
		end
	end
	
	local categories = {} -- temp, using indices instead of names
	
	local function GetNextInProgressAchievementInLine(achievementId)
		local nextAchievementId = achievementId
		while nextAchievementId ~= 0 do
			achievementId = nextAchievementId

			--if not IsAchievementComplete(achievementId) then
			if not IsAchievementDataCompleted(interProfile.achievements[achievementId]) then
				return achievementId
			end

			nextAchievementId = GetNextAchievementInLine(achievementId)
		end

		return achievementId
	end
    
    --[[
    local whitelist =
    {
        [1896] = true,
        [1897] = true,
        [1898] = true,
        [1687] = true,
        [1688] = true,
        [1689] = true,
        [12] = true,
        [13] = true,
        [14] = true,
        [15] = true,
        [16] = true,

    }
    local function dbg(id, ...)
        if whitelist[id] then
            df(...)
        end
    end
    --]]

	-- returns the proper achievement for the list, aka, the first in progress 
	local function CheckCategoryInfoFromAchievementId(id)
        local firstId, prevId, nextId = GetFirstAchievementInLine(id), GetPreviousAchievementInLine(id), GetNextAchievementInLine(id)
        local nextInProgressId = GetNextInProgressAchievementInLine(firstId)

        local hidden = false
        local index, subIndex = GetCategoryInfoFromAchievementId(id)
        if index == nil then
            index, subIndex = GetCategoryInfoFromAchievementId(GetNextInProgressAchievementInLine(GetFirstAchievementInLine(id)))
        end
        
        -- since the status of an achievement line may differ from the current character we need to replicate the behaviour of ZOS' internal code 
        -- We hide it if:
        --    * It is completed and not last in the line
        --    * It is not completed, neither is the previous and it is not the first in the line
        if IsAchievementDataCompleted(interProfile.achievements[id]) then
            hidden = nextId ~= 0
        elseif prevId > 0 and not IsAchievementDataCompleted(interProfile.achievements[prevId]) then
            hidden = true
        end

        return hidden, index, subIndex
	end
	
	-- time to calculate points
	for id,achievement in pairs(interProfile.achievements) do
		local pts = select(3, GetAchievementInfo(id)) -- maybe use "raw_" here for speed?
		local earnedPts = IsAchievementDataCompleted(achievement) and pts or 0
		interProfile.totalPoints = interProfile.totalPoints + pts
		interProfile.earnedPoints = interProfile.earnedPoints + earnedPts

		local hidden, index, subIndex = CheckCategoryInfoFromAchievementId(id, achievement)
		if not categories[index] then
			categories[index] = 
			{
				earnedPoints = 0,
				totalPoints  = 0,
				achievements = {},
			}
		end
		local parent = categories[index]
		parent.totalPoints = parent.totalPoints + pts
		parent.earnedPoints = parent.earnedPoints + earnedPts
		if subIndex then
			if not parent[subIndex] then
				parent[subIndex] = 
				{
					earnedPoints = 0,
					totalPoints  = 0,
					achievements = {},
				}
			end
			parent = parent[subIndex]
			parent.totalPoints = parent.totalPoints + pts
			parent.earnedPoints = parent.earnedPoints + earnedPts
		end
		if parent and not hidden then -- see above
			table.insert(parent.achievements, id)
		end
	end
	
	local function SortAchievements(aId, bId)
		local aData = interProfile.achievements[aId]
		local prev = GetPreviousAchievementInLine(aId)
		
		while not IsAchievementDataCompleted(aData) do
			if prev == 0 then
				break
			end
			aData = interProfile.achievements[prev]
			prev = GetPreviousAchievementInLine(prev)
		end

		local bData = interProfile.achievements[bId]
		prev = GetPreviousAchievementInLine(bId)
		while not IsAchievementDataCompleted(bData) do
			if prev == 0 then
				break
			end
			bData = interProfile.achievements[prev]
			prev = GetPreviousAchievementInLine(prev)
		end
		if aData.timestamp == bData.timestamp then
			return GetAchievementName(aData.id) < GetAchievementName(bData.id)
		else
			return aData.timestamp > bData.timestamp
		end
		
	end

	interProfile.categories = {}
	for index=1,GetNumAchievementCategories() do
		local category = 
		{
			earnedPoints = categories[index].earnedPoints,
			totalPoints  = categories[index].totalPoints,
			achievements = categories[index].achievements,
		}
		table.sort(category.achievements, SortAchievements)
		local name, numSubs, numAch = GetAchievementCategoryInfo(index)
		--df("-- Category: %s, points: %d/%d, achievements: %d", name, category.earnedPoints, category.totalPoints, #category.achievements)
		interProfile.categories[name] = category
		if numAch ~= #category.achievements then
			--df("--- Error! Mismatching amount of achievements: %d vs %d", numAch, #category.achievements)
		end
		for subIndex=1,numSubs do
			local subcategory = 
			{
				earnedPoints = categories[index][subIndex].earnedPoints,
				totalPoints  = categories[index][subIndex].totalPoints,
				achievements = categories[index][subIndex].achievements,
			}
			table.sort(subcategory.achievements, SortAchievements)
			name, numAch = GetAchievementSubCategoryInfo(index, subIndex)
			--df("---- SubCategory: %s, points: %d/%d, achievements: %d", name, subcategory.earnedPoints, subcategory.totalPoints, #subcategory.achievements)
			if numAch ~= #subcategory.achievements then
				--df("----- Error! Mismatching amount of achievements: %d vs %d", numAch, #subcategory.achievements)
			end
			category[name] = subcategory
			subIndex = subIndex + 1
		end
		index = index + 1
	end

	--df("Total points: %d", interProfile.totalPoints)
	--df("Earned points: %d", interProfile.earnedPoints)
	
	return interProfile
end


local function SetCurrentProfile(profileName)
	if profileName == "-Global-" then
		currentProfile = BuildGlobalProfile()
	elseif profileName == GetUnitName("player") then
		currentProfile = nil -- just use our actual data
	else
		currentProfile = Addon.Settings.profiles[profileName]
		if currentProfile.version ~= CURRENT_PROFILE_VERSION then
			--d("PROFILE VERSION DOES NOT MATCH, CANCELLING THE PROFILE CHANGE")
		end
	end
	ACHIEVEMENTS:UpdatePointDisplay()
	ACHIEVEMENTS:RefreshVisibleCategoryFilter()

end


local myControl = WINDOW_MANAGER:CreateControl(nil, GuiRoot, CT_LABEL)
myControl:SetHidden(true)

local myControl2 = WINDOW_MANAGER:CreateControl(nil, GuiRoot, CT_LABEL)
myControl2:SetHidden(true)

local ANCHOR_POINTS = 
{
	[0]            = "INVALID",
	[TOP]          = "TOP",
	[TOPLEFT]      = "TOPLEFT",
	[TOPRIGHT]     = "TOPRIGHT",
	[LEFT]         = "LEFT",
	[RIGHT]        = "RIGHT",
	[CENTER]       = "CENTER",
	[BOTTOM]       = "BOTTOM",
	[BOTTOMLEFT]   = "BOTTOMLEFT",
	[BOTTOMRIGHT]  = "BOTTOMRIGHT",
}

local function ReanchorLines(tooltip, numLines, dynamic)
	--add control to tooltip, so we can parse its lines

	tooltip:AddControl(myControl)
	local nextLine = myControl:GetParent()
	nextLine = select(3, nextLine:GetAnchor(0))
	--df("%s", tostring(nextLine))

	local anchorList = {} --lists lines from bottom-to-top
	while nextLine and nextLine ~= tooltip do
		table.insert(anchorList, {nextLine, nextLine:GetAnchor(0)})
		nextLine = select(3, nextLine:GetAnchor(0))
	end

	--df("Total Lines: %d", #anchorList)
	for i,anchor in ipairs(anchorList) do
		--df("#%d -> %s, %s, %s, %s, %s", i, ANCHOR_POINTS[anchor[3]], tostring(anchor[4]), ANCHOR_POINTS[anchor[5]], anchor[6], anchor[7])
	end
	
	local function AdjustLines(index, offset)
		-- the lower the index the lower the line in the tooltip
		
		-- anchor anchorList[index-1] to anchorList[index+1] using values from anchorList[index]
		local curLine, _, point, relativeTo, relativePoint, offsetX, offsetY, restr = unpack(anchorList[index])

		if index > 1 then 
			local prevLine = index < #anchorList and anchorList[index+1][1] or tooltip
			local nextLine = anchorList[index-1][1]
			nextLine:ClearAnchors()
			nextLine:SetAnchor(point, prevLine, relativePoint, offsetX, offsetY, restr)
		end
		--df("Hiding %s", tostring(curLine))
		curLine:SetHidden(true)
	end
	
	if dynamic then 
		local index = #anchorList
		local prev
		while index > 0 do
			local curLine, _, point, relativeTo, relativePoint, offsetX, offsetY, restr = unpack(anchorList[index])
			if offsetX == 0 and offsetY == 0 then
				numLines = index 
				break
			end
			index = index - 1
		end
	end
	if numLines then 
		if numLines < 0 then 
			numLines = #anchorList + numLines + 1
		end
		AdjustLines(numLines)
	end
    --
	----reanchor new bonus lines
	--newFirstLine:ClearAnchors()
	--newFirstLine:SetAnchor(TOP, nextLine, TOP, 0, 0)
end

--function kyoTT(arg)
--
--	ReanchorLines(ItemTooltip, arg)
--end


local raw_SetAchievement = AchievementTooltip.SetAchievement
AchievementTooltip.SetAchievement = function(tooltip, achievementId)
	if not currentProfile then return raw_SetAchievement(tooltip, achievementId) end

	-- now for some magic to replace the headers
	tooltip:SetMinHeaderRows(2)
	raw_SetAchievement(tooltip, achievementId)
	
	local completed, date, time = select(5, GetAchievementInfo(achievementId)) -- the hook for this will take care of getting the correct values
	if completed then
		tooltip:AddHeaderLine(GetString(SI_ACHIEVEMENTS_TOOLTIP_COMPLETE), "ZoFontWinT2", 1, TOOLTIP_HEADER_SIDE_LEFT, ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB())
		tooltip:AddHeaderLine(date, "ZoFontWinT2", 1, TOOLTIP_HEADER_SIDE_RIGHT, ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB())
	else
		tooltip:AddHeaderLine(GetString(SI_ACHIEVEMENTS_TOOLTIP_PROGRESS), "ZoFontWinT2", 1, TOOLTIP_HEADER_SIDE_LEFT, ZO_ERROR_COLOR:UnpackRGB())
	end
	ReanchorLines(tooltip, -1)
end


--[[
    GetCategoryInfoFromAchievementId(number achievementId)
        Returns: number:nilable topLevelIndex, number:nilable categoryIndex, number:nilable achievementIndex, number offsetFromParent 
--]]

local Defaults = 
{
	profiles = {},
}

local function CreateControls()
    
	local profileFilter = WINDOW_MANAGER:CreateControlFromVirtual("$(parent)ProfileFilter", ACHIEVEMENTS.contents, "ZO_ComboBox")
    profileFilter:SetHidden(true)

    local function SetParentContainer(parent)
        profileFilter:SetParent(parent)
        profileFilter:ClearAnchors()
        profileFilter:SetAnchorFill(parent)
        profileFilter:SetHidden(false)
    end 
    
    local function SetupParentContainer(parent, dimensions, anchor)
        local container = WINDOW_MANAGER:CreateControl("$(parent)ProfileContainer", parent, CT_CONTROL)
        container:SetDimensions(unpack(dimensions))
        container:SetAnchor(unpack(anchor))
        container:SetHandler("OnEffectivelyShown", SetParentContainer)
    end

    SetupParentContainer(ACHIEVEMENTS.categoryFilter, {ACHIEVEMENTS.categoryFilter:GetDimensions()}, {BOTTOMLEFT, parent, TOPLEFT, 0})
    SetupParentContainer(ACHIEVEMENTS.pointsDisplay, {222, 32}, {TOPLEFT, parent, BOTTOMLEFT, 0})

	profileCombobox = ZO_ComboBox_ObjectFromContainer(profileFilter)

    profileCombobox:SetSortsItems(false)
    profileCombobox:SetFont("ZoFontWinT1")
    profileCombobox:SetSpacing(4)
    
    local function OnFilterChanged(comboBox, entryText, entry)
		SetCurrentProfile(entryText)
    end

	profileCombobox:ClearItems()
	profileCombobox:AddItem(profileCombobox:CreateItemEntry("-Global-", OnFilterChanged))
	for name,profile in pairs(Addon.Settings.profiles) do
		local entry = profileCombobox:CreateItemEntry(name, OnFilterChanged)
		profileCombobox:AddItem(entry)
	end
	profileCombobox:SetSelectedItemText(GetUnitName("player")) -- just set text since we don't actually use the local profile
end

local function HookAchievementLineThumbs()

	local originalFactory
	local function NewFactoryBehavior(control)
		originalFactory(control)
		control:SetHandler("OnMouseUp", function(control, button, upInside)
			if upInside and button == MOUSE_BUTTON_INDEX_RIGHT then
				ClearMenu()
				AddCustomMenuItem(GetString(SI_ITEM_ACTION_LINK_TO_CHAT), function() ZO_LinkHandler_InsertLink(ZO_LinkHandler_CreateChatLink(GetAchievementLink, control.achievementId)) end)
				--AddCustomMenuItem("First", function() df("First: %d", GetFirstAchievementInLine(control.achievementId)) end)
				--AddCustomMenuItem("Previous", function() df("Previous: %d", GetPreviousAchievementInLine(control.achievementId)) end)
				--AddCustomMenuItem("Next", function() df("Next: %d", GetNextAchievementInLine(control.achievementId)) end)
				ShowMenu(control)
			end
		end)
	end

	local tmp = ACHIEVEMENTS.achievementPool:AcquireObject()
	originalFactory = tmp.lineThumbPool.customFactoryBehavior
	tmp.lineThumbPool:SetCustomFactoryBehavior(NewFactoryBehavior)
	ACHIEVEMENTS.achievementPool:ReleaseObject(tmp.key)
end

local function OnLoad(eventCode, name)
	if name ~= Addon.Name then return end

	Addon.Settings = ZO_SavedVars:NewAccountWide("kyoAchievenizerGlobal", CURRENT_PROFILE_VERSION, GetWorldName(), Defaults)

	HookAchievementLineThumbs()

	local achievementsScene = SYSTEMS:GetRootScene("achievements")
	achievementsScene:RegisterCallback("StateChange", function(oldState, newState)
		if newState == SCENE_SHOWING then
			HookAchievements()
		elseif newState == SCENE_HIDING then
			UnhookAchievements()
		end
	end)

	CollectCurrentProfile()
	CreateControls()
	EVENT_MANAGER:RegisterForEvent(Addon.Name, EVENT_PLAYER_DEACTIVATED, CollectCurrentProfile) 

	EVENT_MANAGER:UnregisterForEvent(Addon.Name, EVENT_ADD_ON_LOADED)
end
EVENT_MANAGER:RegisterForEvent(Addon.Name, EVENT_ADD_ON_LOADED, OnLoad)

KYO_ACHIEVE = Addon
