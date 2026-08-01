-- Create namespace
DsRGuildAchievTracker = {}
local DsRGuildAchievTracker = DsRGuildAchievTracker or {}

DsRGuildAchievTracker.name = "DsRGuildAchievTracker"
local DsRGuildFavorites    = "DsRGuildFavorites"

local em    = GetEventManager()
local LMP   = LibMapPins

local DsRIcon = DsRglobals:HolidayIconLoad()

DsRGuildAchievTracker.ACCdefaults = {
    positionoffsetX  = 100,
    positionoffsetY  = 100,
    fontSizename     = 16,
    fontSizedesc     = 14,
    sizeX            = 100,
    sizeY            = 200,
    locked           = false,
    showIcons        = true,
    showDesc         = false,
    hideOldZoneAchievements = true,
    maxTracked       = 0,
    hidden           = false,
    AchievTrackOnOff = false,
}
DsRGuildAchievTracker.CHARdefaults = {
    tracked     = {},
	Zonetracked = {},
	-- showDetails = {},
}

DsRGuildAchievTracker.config               = nil
DsRGuildAchievTracker.configCHAR           = nil
DsRGuildAchievTracker.lastZone             = nil
DsRGuildAchievTracker.hiddenShortly        = false
DsRGuildAchievTracker.heightPerLine        = 50

local AutoTrackZone = {}

local function comma_value(amount)
  local formatted = amount
  while true do
    formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
    if (k==0) then
      break
    end
  end
  return formatted
end

DsRGuildAchievTracker.Place = {
    ["Imperial City"] = {
        [1] = "Kaiserstadt",
        [2] = "Imperial City",
        [3] = "Kanalisation der Kaiserstadt",
        [4] = "Imperial sewers"
    },
    ["Orsinium"] = {
        [1] = "Wrothgar",
        [2] = "Orsinium",
        [3] = "Morkul-Festung",
        [4] = "Morkul Stronghold",
    },
    ["Thieves Guild"] = {
        [1] = "Hews Fluch",
        [2] = "Hew`s Bane",
        [3] = "Abahs Landung",
        [4] = "Abah`s Landing",
    },
    ["Dark Brotherhood"] = {
        [1] = "Goldküste",
        [2] = "Gold Coast",
        [3] = "Anwil",
        [4] = "Kvatch",
    },
    ["Morrowind"] = {
        [1] = "Vvardenfell",
        [2] = "Morrowind",
        [3] = "Vivec",
        [4] = "Balmora",
        [5] = "Sadrith Mora",
    },
    ["Clockwork City"] = {
        [1] = "Stadt der Uhrwerke",
        [2] = "Clockwork City",
        [3] = "Messingfeste",
        [4] = "Brass Fortress",
    },
    ["Summerset"] = {
        [1] = "Sommersend",
        [2] = "Summerset",
        [3] = "Schimmerheim",
        [4] = "Shimmerene",
        [5] = "Alinor",
        [6] = "Artaeum",
    },
    ["Murkmire"] = {
        [1] = "Trübmoor",
        [2] = "Murkmire",
        [3] = "Lilmoth",
        [4] = "Wurzelflüsterdorf",
        [5] = "Root-Whisper Village",
        [6] = "Totwasserdorf",
        [7] = "Dead-Water Village",
    },
    ["Elsweyr"] = {
        [1] = "nördliche Elsweyr",
        [2] = "Northern Elsweyr",
        [3] = "Elsweyr",
        [4] = "Krempen",
        [5] = "Rimmen",
    },
    ["Dragonhold"] = {
        [1] = "südliche Elsweyr",
        [2] = "Southern Elsweyr",
        [3] = "Dragonhold",
        [4] = "Senchal",
        [5] = "Gezeiteninsel",
        [6] = "Tideholm",
        [7] = "südlichen Elsweyr",
        [8] = "Elsweyr",
    },
    ["Greymoor"] = {
        [1] = "Himmelsrand",
        [2] = "Western Skyrim",
        [3] = "Schwarzweite: Graumoorkavernen",
        [4] = "Blackreach: Greymoor Caverns",
        [5] = 'Greymoor',
        [6] = "Einsamkeit",
        [7] = "Solitude",
        [8] = "Skyrim",
    },
    ["Markarth"] = {
        [1] = "Reik",
        [2] = "Raech",
        [3] = "Schwarzweite: Arkthzand-Kaverne",
        [4] = "Blackreach: Arkthzand Cavern",
        [5] = "Markarth",
    },
    ["Blackwood"] = {
        [1] = "Dunkelforst",
        [2] = "Blackwood",
        [3] = "Leyawiin",
        [4] = "Gideon",
    },
    ["Deadlands"] = {
        [1] = "Totenländer",
        [2] = "The Deadlands",
        [3] = "Deadlands",
        [4] = "Ferngrab",
        [5] = "Fargarve",
        [6] = "Stadtkern von Ferngrab",
        [7] = "Fargrave City District",
        [8] = "Bruchgassen",
        [9] = "The Shambles"
    },
    ["High Isle"] = {
        [1] = "Hochinsel",
        [2] = "Amenos",
        [3] = "High Isle",
        [4] = "Gonfalon",
    },
    ["Firesong"] = {
        [1] = "Galen",
        [2] = "Y'ffelon",
        [3] = "Firesong",
        [4] = "Vastyr",
    },
    ["Necrom"] = {
        [1] = "Telvanni-Halbinsel",
        [2] = "Telvanni Peninsula",
        [3] = "Nekrom",
        [4] = "Necrom",
        [5] = "Apocrypha",
        [6] = "Telvanni",
    },
    ["Gold Road"] = {
        [1] = "Westauen",
        [2] = "West Weald",
        [3] = "Gold Road",
        [4] = "Skingrad",
    },
}

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildAchievTracker:GetLabel(name, parent, isBold)
  	local label = parent:GetNamedChild(name) or WINDOW_MANAGER:CreateControl(parent:GetName() .. name, parent, CT_LABEL)
  	label:SetHidden(false)
  	label:SetDimensions(250, 25)
  	label:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)

  	local fontFile = nil
  	local fontSize = DsRGuildAchievTracker.config.fontSizedesc
  	local fontDecoration = "soft-shadow-thin"
  	if isBold then
    	fontSize = DsRGuildAchievTracker.config.fontSizename
    	fontFile = ZoFontGameBold:GetFontInfo()
  	else
    	fontFile = ZoFontGame:GetFontInfo()
  	end

  	label:SetFont(string.format("%s|%d|%s", fontFile, fontSize, fontDecoration))
  	return label
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildAchievTracker:GetIcon(name, parent, texture)
  	local ico = parent:GetNamedChild(name) or WINDOW_MANAGER:CreateControl(parent:GetName() .. name, parent, CT_TEXTURE)
  	ico:SetHidden(false)
  	ico:SetDimensions(25, 25)
  	ico:SetTexture(texture)
  	return ico
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildAchievTracker:AutoTrackZoneAchievements()
	if DsRGuildAchievTracker.config == nil then return end
	if DsRGuildAchievTracker.config.hideOldZoneAchievements == false then
		for id in pairs(DsRGuildAchievTracker.tracked) do
			DsRGuildAchievTracker.configCHAR.Zonetracked[id] = true
		end
		return 
	end

	-- ---------------------------
	-- iCat				= iCatIndex
	-- ---------------------------
	-- Character 		= 1
	-- Player VS Player = 2
	-- Handwerk 		= 3
	-- Verlies 			= 4
	-- Veteranverliese 	= 5
	-- Erkunden 		= 6
	-- Quests 			= 7
	-- Endloses Archiv	= 8
	-- Wohnen 			= 9
	-- Fest und Feiern 	= 10
	-- Prologe 			= 11
	-- ---------------------------

	local ZoneId    = GetZoneId(GetUnitZoneIndex("player"))
    local ZoneIndex = GetZoneIndex(ZoneId)
    local ZoneName  = GetZoneNameByIndex(ZoneIndex):gsub("%^.+", "")
    local ZoneDesc  = GetZoneDescription(ZoneIndex)
    
    local MainZone, subzone = LMP:GetZoneAndSubzone()
    
    for id in pairs(DsRGuildAchievTracker.tracked) do
		local iCat 		 = GetAchievementCategoryInfo(GetCategoryInfoFromAchievementId(id))
		local iCatIndex  = select(1, GetCategoryInfoFromAchievementId(id))

        -- 3991 = Tintenscheffler

        if tonumber(iCatIndex) <= 11 or tonumber(id) == 3991 then
			DsRGuildAchievTracker.configCHAR.Zonetracked[id] = true
		else
            DsRGuildAchievTracker.configCHAR.Zonetracked[id] = false
            for k, v in pairs ( DsRGuildAchievTracker.Place ) do
                if iCat == k then
                    local DLC = string.format("%s", k)
                    for k, v in pairs ( DsRGuildAchievTracker.Place[DLC] ) do
                        local SearchStringA = zo_strupper(ZoneDesc):find(zo_strupper(v))
                        local SearchStringB = zo_strupper(MainZone):find(zo_strupper(v))
                        if SearchStringA or SearchStringB or ZoneName == v then
                            DsRGuildAchievTracker.configCHAR.Zonetracked[id] = true
                        end
                    end
                end
            end
		end
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildAchievTracker:CreateWindow()
  	DsRGuildAchievTracker.frame = WINDOW_MANAGER:CreateTopLevelWindow("DsRGuildAchievTrackerWindow")

  	DsRGuildAchievTracker.frame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, DsRGuildAchievTracker.config.positionoffsetX, DsRGuildAchievTracker.config.positionoffsetY)
  	DsRGuildAchievTracker.frame:SetHidden(false)
  	DsRGuildAchievTracker.frame:SetMovable(not DsRGuildAchievTracker.config.locked)
  	DsRGuildAchievTracker.frame:SetMouseEnabled(true)
  	DsRGuildAchievTracker.frame:SetResizeToFitDescendents(true)

  	DsRGuildAchievTracker.frame:SetResizeHandleSize(MOUSE_CURSOR_RESIZE_NS)
  	DsRGuildAchievTracker.frame:SetHandler("OnMouseUp", function()
    	local sizeX = DsRGuildAchievTracker.frame:GetWidth()
    	local sizeY = DsRGuildAchievTracker.frame:GetHeight()
    	DsRGuildAchievTracker.frame:SetDimensions(sizeX, sizeY)
    	DsRGuildAchievTracker.config.positionoffsetX = DsRGuildAchievTracker.frame:GetLeft()
    	DsRGuildAchievTracker.config.positionoffsetY = DsRGuildAchievTracker.frame:GetTop()
  	end)
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildAchievTracker:LoadTrackedAchievements(self, updatedId)
  	if DsRGuildAchievTracker.config.locked then
    	DsRGuildAchievTracker.frame:SetMovable(false)
  	else
    	DsRGuildAchievTracker.frame:SetMovable(true)
  	end

  	if DsRGuildAchievTracker.config.hideOldZoneAchievements then
        DsRGuildAchievTracker:AutoTrackZoneAchievements()
		AutoTrackZone = DsRGuildAchievTracker.configCHAR.Zonetracked
	else
		AutoTrackZone = DsRGuildAchievTracker.configCHAR.tracked
  	end

  	if DsRGuildAchievTracker.hiddenShortly or DsRGuildAchievTracker.config.hidden then
    	DsRGuildAchievTracker.frame:SetHidden(true)
  	else
    	DsRGuildAchievTracker.frame:SetHidden(false)
  	end
    -- hide children and adjust size of the frame
    local numChildren = DsRGuildAchievTracker.frame:GetNumChildren()
    for i = 1, numChildren do
        local child = DsRGuildAchievTracker.frame:GetChild(i)
        if child then
            local height = child:GetHeight()
            child:SetHidden(true)
            child:SetDimensions(0, 0)
            DsRGuildAchievTracker.frame:SetHeight(DsRGuildAchievTracker.frame:GetHeight() - height)
        end
    end

    -- no need to do all the stuff below if frame is hidden
    if DsRGuildAchievTracker.frame:IsHidden() then return end

    local i = 1
    local lastTotalHeight = 0;

    -- traverse tracked achievs and display them
    for id, isTracked in pairs(AutoTrackZone) do
        local name, desc, _, icon, done = GetAchievementInfo(id)
        local cName = zo_strformat(SI_TOOLTIP_ITEM_NAME, name)
        local cDesc = zo_strformat(SI_TOOLTIP_ITEM_NAME, desc)

		-- check if done
        local continue = true
        if done then
            continue = false
            DsRGuildAchievTracker.configCHAR.tracked[id]     = nil
            -- DsRGuildAchievTracker.configCHAR.showDetails[id] = nil
        end

        local max = DsRGuildAchievTracker.config.maxTracked
        if DsRGuildAchievTracker.config.maxTracked == 0 then max = 9999 end

        if i > max then return end

        if isTracked and continue then
            local offsetY = 5
            if lastTotalHeight > 0 then offsetY = lastTotalHeight end

            -- icon
            local achievIcon = DsRGuildAchievTracker:GetIcon("Icon" .. i, DsRGuildAchievTracker.frame, icon)
            achievIcon:SetAnchor(TOPLEFT, DsRGuildAchievTracker.frame, TOPLEFT, 5, offsetY)
            achievIcon:SetHidden(not DsRGuildAchievTracker.config.showIcons)

            -- name
            local achievName = DsRGuildAchievTracker:GetLabel("Label" .. i, DsRGuildAchievTracker.frame, true)
            local xPos = 5
            if achievIcon:IsHidden() then xPos = -15 end
            achievName:SetHeight(15)
            achievName:SetAnchor(TOPLEFT, achievIcon, TOPRIGHT, xPos, 0)
            achievName:SetText(cName)
            achievName:SetMouseEnabled(true)
            if done then
                achievName:SetColor(0, 1, 0, 1)
            else
                achievName:SetColor(1, 1, 1, 1)
            end

            achievName:SetHandler("OnMouseEnter", function(self)
                achievName:SetColor(1, 0.86, 0, 1)
            end)
            achievName:SetHandler("OnMouseExit", function(self)
                if done then
                    achievName:SetColor(0, 1, 0, 1)
                else
                    achievName:SetColor(1, 1, 1, 1)
                end
            end)
            achievName:SetHandler("OnMouseUp", function(_, button)
                if button == 1 then
                    local categoryIndex, subCategoryIndex, achievementIndex = GetCategoryInfoFromAchievementId(id)
                    SCENE_MANAGER:Show("achievements")
                    ACHIEVEMENTS:OpenCategory(categoryIndex, subCategoryIndex)
                -- elseif button == 2 then
                    -- DsRGuildAchievTracker.configCHAR.showDetails[id] = not DsRGuildAchievTracker.configCHAR.showDetails[id]
                    -- return DsRGuildAchievTracker:LoadTrackedAchievements()
                end
            end)

            -- criteria
            local achievCriteria = DsRGuildAchievTracker:GetLabel("Criteria" .. i, DsRGuildAchievTracker.frame)
            achievCriteria:SetAnchor(TOPLEFT, achievName, TOPLEFT, 0, achievName:GetTextHeight())
            if done then
                achievCriteria:SetColor(0, 1, 0, 1)
            else
                achievCriteria:SetColor(0.8, 0.8, 0.8, 1)
            end

            local numCriteria = GetAchievementNumCriteria(id)
            local totalCompleted = 0
            local totalRequired = 0

            if DsRGuildAchievTracker.config.showDesc then
            -- if DsRGuildAchievTracker.configCHAR.showDetails[id] then
                local text = ""
                local critDisplayed = 0
                for criteria = 1, numCriteria do
                    local critDesc, critCompleted, critRequired = GetAchievementCriterion(id, criteria)

                    if (critCompleted ~= critRequired) then
                        critDisplayed = critDisplayed + 1
                        if critDisplayed > 1 then
                            text = text .. "\n"
                        end
                        
                        if critCompleted ~= critRequired then
                            if critRequired == 1 then
                                text = text .. "|cFFEC8B - " .. cDesc
                            else
                                local critRequiredNum  = FormatIntegerWithDigitGrouping(critRequired, ".", 3)
                                local critCompletedNum = FormatIntegerWithDigitGrouping(critCompleted, ".", 3)
                                text = text .. "|cFFEC8B - " .. cDesc .. "\n   |cFF0000- |c0BDA51" .. critCompletedNum .. "|r/|ce6e600" .. critRequiredNum .. "|r"
                            end
                        else
                            text = text .. "|cFFEC8B - " .. cDesc .. "|r"
                        end
                    end
                end
                achievCriteria:SetText(text)
                achievCriteria:SetHeight(100)
                DsRGuildAchievTracker.frame:SetHeight(achievCriteria:GetTextHeight() * numCriteria)
            else
                for criteria = 1, numCriteria do
                    local critDesc, critCompleted, critRequired = GetAchievementCriterion(id, criteria)
                    totalCompleted = totalCompleted + critCompleted
                    totalRequired = totalRequired + critRequired
                end
                if totalCompleted > 1 then
                    totalCompleted  = FormatIntegerWithDigitGrouping(totalCompleted, ".", 3)
                end
                if totalRequired > 1 then
                    totalRequired = FormatIntegerWithDigitGrouping(totalRequired, ".", 3)
                    achievCriteria:SetText(" |cFF0000- |c0BDA51" .. totalCompleted .. "|r/|ce6e600" .. totalRequired  .. "|r")
                else
                    achievCriteria:SetText("")
                end
            end
            lastTotalHeight = lastTotalHeight + achievName:GetTextHeight() + achievCriteria:GetTextHeight() + 10
            i = i + 1
            DsRGuildAchievTracker.frame:SetHeight(lastTotalHeight)
        end
    end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildAchievTracker:SetHiddenShortly(hidden)
    local oldStatus = DsRGuildAchievTracker.hiddenShortly
    DsRGuildAchievTracker.hiddenShortly = hidden
    if DsRGuildAchievTracker.hiddenShortly ~= oldStatus then DsRGuildAchievTracker:LoadTrackedAchievements() end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildAchievTracker:Reset()
    for id, isTracked in pairs(DsRGuildAchievTracker.configCHAR.tracked) do
        DsRGuildAchievTracker.configCHAR.tracked[id] 		= nil
        DsRGuildAchievTracker.configCHAR.Zonetracked[id] 	= nil
        -- DsRGuildAchievTracker.configCHAR.showDetails[id] 	= nil
    end
    DsRGuildAchievTracker:LoadTrackedAchievements()
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildAchievTracker.achieveSceneChange(oldState, newState)
    if newState == SCENE_SHOWN then
        if DsRGuildAchievTracker.oldAchievementSetupFunction==nil then
            DsRGuildAchievTracker.oldAchievementSetupFunction=ACHIEVEMENTS.categoryTree.templateInfo.ZO_TreeLabelSubCategory.setupFunction
            ACHIEVEMENTS.categoryTree.templateInfo.ZO_TreeLabelSubCategory.setupFunction = DsRGuildAchievTracker.AchievementSetupFunction
            ACHIEVEMENTS.refreshGroups:RefreshAll("FullUpdate")
        end
    end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildAchievTracker.AchievementSetupFunction(node, control, data, open, userRequested, enabled)
    DsRGuildAchievTracker.oldAchievementSetupFunction(node,control,data,open,userRequested,enabled)
    local numAch, subEarned, subTotal
    local parentData = data.parentData
    if not data.isFakedSubcategory and parentData then
        numAch,subEarned,subTotal = select(2,GetAchievementSubCategoryInfo(parentData.categoryIndex, data.categoryIndex))
    else
        local numSubCat,numAchie,earnedPnt,totalPnt,hidesP = select(2,GetAchievementCategoryInfo(data.categoryIndex))
        if parentData then
            for subCatIndex = 1, numSubCat do
                local subCatEarned,subCatTotal = select(3,GetAchievementSubCategoryInfo(parentData.categoryIndex, subCatIndex))
                earnedPnt = earnedPnt - subCatEarned
                totalPnt = totalPnt - subCatTotal
            end
        end
        subEarned = earnedPnt
        subTotal = totalPnt
    end
    local col = (subEarned == subTotal) and DsRGuildAchievTracker.col_grn or DsRGuildAchievTracker.col_red
    ZO_SelectableLabel_SetNormalColor(control, col)
    if control.GetTextColor ~= DsRGuildAchievTracker.GetTextColor then control.GetTextColor = DsRGuildAchievTracker.GetTextColor end
    control:RefreshTextColor()
    local subMiss = subTotal - subEarned
    if subMiss > 0 then
        local oldTxt = control:GetText()
        control:SetFont(string.format("%s|%d|%s", ZoFontGameBold:GetFontInfo(), 18, "soft-shadow-thin"))
        control:SetText(string.format("%s (%s)", tostring(oldTxt), tostring(subMiss)))
    end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildAchievTracker:GetTextColor()
    local b,c,d,e=self.normalColor:UnpackRGBA()
    if self.selected then return b,c,d,0.4 elseif self.mouseover then return b,c,d,0.7 end;
    return b,c,d,e 
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Favorits list and context menu
-- Code based on Addon "VotansAchievementsOvw" 
-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildAchievTracker:CreateFavorites()
	local Achievements = getmetatable(ACHIEVEMENTS).__index
	local SUMMARY_ICONS = {
		DsRIcon,
		"/DsRGuildHall/misc/DsR_normal_activ.dds",
		DsRIcon
	}
	local orgAddTopLevelCategory = Achievements.AddTopLevelCategory
	function Achievements.AddTopLevelCategory(...)
		local self, name = ...
		if name then
			return orgAddTopLevelCategory(...)
		end

		local result = orgAddTopLevelCategory(...)
		local lookup, tree, numSubCategories, hidesUnearned = self.nodeLookupData, self.categoryTree, 0, false

		local normalIcon, pressedIcon, mouseoverIcon = unpack(SUMMARY_ICONS)

		local parentNode = self:AddCategory(lookup, tree, "ZO_IconChildlessHeader", nil, DsRGuildFavorites, GetString(DsRGuildAchievTrackerFav_Fav), hidesUnearned, normalIcon, pressedIcon, mouseoverIcon, true, true)
		local row = parentNode:GetData()
		row.isFavorits = true
		return result
	end
	if ACHIEVEMENTS.refreshGroups then
		ACHIEVEMENTS.refreshGroups:RefreshAll("FullUpdate")
	end

	local orgOnCategorySelected = Achievements.OnCategorySelected
	function Achievements.OnCategorySelected(...)
		local ACHIEVEMENTS, data, saveExpanded = ...
		if data.categoryIndex == DsRGuildFavorites then
			ACHIEVEMENTS:HideSummary()
			ACHIEVEMENTS.UpdateCategoryLabels(...)
		else
			return orgOnCategorySelected(...)
		end
	end

	local orgGetCategoryInfoFromData = Achievements.GetCategoryInfoFromData
	function Achievements.GetCategoryInfoFromData(...)
		local ACHIEVEMENTS, data, parentData = ...
		if data.categoryIndex == DsRGuildFavorites then
			local numAchievements, earnedPoints, totalPoints = 0, 0, 0
			local favorites, GetAchievementInfo = DsRGuildAchievTracker.tracked, GetAchievementInfo
			local id, points, _, completed
			for id in pairs(favorites) do
				numAchievements = numAchievements + 1
				points, _, completed = select(3, GetAchievementInfo(id))
				totalPoints = totalPoints + points
				if completed then
					earnedPoints = earnedPoints + points
				end
			end
			local hidesPoints = totalPoints == 0
			return numAchievements, earnedPoints, totalPoints, hidesPoints
		else
			return orgGetCategoryInfoFromData(...)
		end
	end

	local orgOnAchievementUpdated = Achievements.OnAchievementUpdated
	function Achievements.OnAchievementUpdated(...)
		local ACHIEVEMENTS, id = ...
		local data = ACHIEVEMENTS.categoryTree:GetSelectedData()

		if data and data.categoryIndex == DsRGuildFavorites then
			if DsRGuildAchievTracker.tracked[id] and ZO_ShouldShowAchievement(ACHIEVEMENTS.categoryFilter.filterType, id) then
				ACHIEVEMENTS:UpdateCategoryLabels(data, true, false)
			end
		else
			return orgOnAchievementUpdated(...)
		end
	end

	local gender = GetUnitGender("player")
	local orgZO_GetAchievementIds = ZO_GetAchievementIds
	local idToName = {}
	local function addName(id)
		local name = GetAchievementInfo(id)
		name = zo_strformat(name, gender)
		idToName[id] = name
		return name
	end
	local function sortByName(a, b)
		return (idToName[a] or addName(a)) < (idToName[b] or addName(b))
	end
	function ZO_GetAchievementIds(...)
		local categoryIndex, subcategoryIndex, numAchievements, considerSearchResults = ...
		if categoryIndex == DsRGuildFavorites then
			local result = {}

			local searchResults = considerSearchResults and ACHIEVEMENTS_MANAGER:GetSearchResults()
			if searchResults then
				local GetCategoryInfoFromAchievementId = GetCategoryInfoFromAchievementId
				local categoryIndex, subcategoryIndex, achievementIndex, searchResult
				for id in pairs(DsRGuildAchievTracker.tracked) do
					categoryIndex, subcategoryIndex, achievementIndex = GetCategoryInfoFromAchievementId(id)
					searchResult = searchResults[categoryIndex]
					if searchResult then
						searchResult = searchResult[subcategoryIndex or ZO_ACHIEVEMENTS_ROOT_SUBCATEGORY]
						if searchResult and searchResult[achievementIndex] then
							result[#result + 1] = id
						end
					end
				end
			else
				for id in pairs(DsRGuildAchievTracker.tracked) do
					result[#result + 1] = id
				end
			end
			table.sort(result, sortByName)
			return result
		else
			return orgZO_GetAchievementIds(...)
		end
	end
	local function RemoveAllOfThem(favorites, achievementId)
		while achievementId ~= 0 do
			favorites[achievementId] = nil
			achievementId = GetNextAchievementInLine(achievementId)
		end
	end

	local function GoToAchievement(achievementId)
		local achievements = SYSTEMS:GetObject("achievements")
	
		local categoryIndex, subCategoryIndex = GetCategoryInfoFromAchievementId(achievementId)
		if not achievements:OpenCategory(categoryIndex, subCategoryIndex) then
			if achievements.contentSearchEditBox:GetText() ~= "" then
				achievements.contentSearchEditBox:SetText("")
				local REFRESH_IMMEDIATELY = true
				ACHIEVEMENTS_MANAGER:ClearSearch(REFRESH_IMMEDIATELY)
			end
		end
		if achievements:OpenCategory(categoryIndex, subCategoryIndex) then
			if not achievements.achievementsById then
				return
			end
			local parentAchievementIndex = achievements:GetBaseAchievementId(achievementId)
			if not achievements.achievementsById[parentAchievementIndex] then
				achievements:ResetFilters()
			end
			if not achievements.achievementsById[parentAchievementIndex] then
				for id, row in pairs(achievements.achievementsById) do
					if row.achievementId == achievementId then
						parentAchievementIndex = id
						break
					end
				end
			end
			if achievements.achievementsById[parentAchievementIndex] then
				achievements.achievementsById[parentAchievementIndex]:Expand()
				local identifier = "DsRGuildAchievTrackerFavGoToIdentifier"
	
				local function DelayGoto()
					em:UnregisterForUpdate(identifier)
					if achievements.achievementsById and achievements.achievementsById[parentAchievementIndex] then
						ZO_Scroll_ScrollControlIntoCentralView(achievements.contentList, achievements.achievementsById[parentAchievementIndex]:GetControl())
					end
				end
				em:UnregisterForUpdate(identifier)
				em:RegisterForUpdate(identifier, 250, DelayGoto)
			end
		end
	end

	function DsRGuildAchievTracker:AddToContextMenu(achievement)
		local id    	 = GetAchievementIdFromLink(GetAchievementLink(achievement:GetId()))
		local isFav 	 = DsRGuildAchievTracker.tracked[id] or DsRGuildAchievTracker.tracked[achievement:GetId()]

		if isFav then
			AddCustomMenuItem(
				GetString(DsRGuildAchievTrackerFav_FavGoTo),
				function()
					GoToAchievement(id)
				end
			)
			AddCustomMenuItem("-", function() end)
			AddCustomMenuItem(
				GetString(DsRGuildAchievTrackerFav_FavREM),
				function()
					RemoveAllOfThem(DsRGuildAchievTracker.tracked, id)

                    DsRGuildAchievTracker.configCHAR.tracked[id] 		= nil
                    DsRGuildAchievTracker.configCHAR.Zonetracked[id] 	= nil
                    -- DsRGuildAchievTracker.configCHAR.showDetails[id] 	= nil
                    DsRGuildAchievTracker:LoadTrackedAchievements()

                    ACHIEVEMENTS:RefreshVisibleCategoryFilter()
                end
			)
		else
			AddCustomMenuItem("-", function() end)
			AddCustomMenuItem(
				GetString(DsRGuildAchievTrackerFav_FavADD),
				function()
					DsRGuildAchievTracker.tracked[id] = true
                    DsRGuildAchievTracker.configCHAR.tracked[id]     = true
                    -- if DsRGuildAchievTracker.config.showDesc then
					    -- DsRGuildAchievTracker.configCHAR.showDetails[id] = true
                    -- else
					    -- DsRGuildAchievTracker.configCHAR.showDetails[id] = false
                    -- end
                    DsRGuildAchievTracker:LoadTrackedAchievements()
				end
			)
		end
	end

	local function HookShowMenu(achievement)
		local orgShowMenu = ShowMenu
		function ShowMenu(...)
			ShowMenu = orgShowMenu
			if not ACHIEVEMENTS.control:IsHidden() then
				DsRGuildAchievTracker:AddToContextMenu(achievement)
			end
			return ShowMenu(...)
		end
	end

	local Achievement

	local function HookAchievement()
		local orgOnClicked = Achievement.OnClicked
		function Achievement:OnClicked(...)
			local button = ...
			if button == MOUSE_BUTTON_INDEX_LEFT then
				return orgOnClicked(self, ...)
			elseif button == MOUSE_BUTTON_INDEX_RIGHT and IsChatSystemAvailableForCurrentPlatform() then
				HookShowMenu(self)
				return orgOnClicked(self, ...)
			end
		end
	end
	-- Get Achievement class
	local orgFactory = ACHIEVEMENTS.achievementPool.m_Factory
	ACHIEVEMENTS.achievementPool.m_Factory = function(...)
		local achievement = orgFactory(...)
		if not Achievement and achievement then
			Achievement = getmetatable(achievement).__index
			HookAchievement()
		end
		return achievement
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- ON ADDON LAODED
-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildAchievTracker.OnAddonLoaded(event, name)
    
    DsRGuildAchievTracker.config     	 = ZO_SavedVars:NewAccountWide("DsRGuildAchievTrackerSettings", 1, nil, DsRGuildAchievTracker.ACCdefaults)
    DsRGuildAchievTracker.configCHAR 	 = ZO_SavedVars:New("DsRGuildAchievTrackerSettings", 1, nil, DsRGuildAchievTracker.CHARdefaults)
    
    DsRGuildAchievTracker.tracked 	  = DsRGuildAchievTracker.configCHAR.tracked

    if DsRGuildAchievTracker.config.AchievTrackOnOff == true then return end
    
    DsRGuildAchievTracker:CreateFavorites()

    DsRGuildAchievTracker:CreateWindow()

    DsRGuildAchievTracker.col_grn = ZO_ColorDef:New("66ff66")
	DsRGuildAchievTracker.col_red = ZO_ColorDef:New("ff6666")
    
    SCENE_MANAGER:GetScene("achievements"):RegisterCallback("StateChange", DsRGuildAchievTracker.achieveSceneChange)
    
    -- hide listeners
    ZO_PreHookHandler(ZO_MainMenuCategoryBar, "OnShow", function()
        DsRGuildAchievTracker:SetHiddenShortly(true)
    end)
    ZO_PreHookHandler(ZO_InteractWindow, "OnShow", function()
        DsRGuildAchievTracker:SetHiddenShortly(true)
    end)
    ZO_PreHookHandler(ZO_GameMenu_InGame, "OnShow", function()
        DsRGuildAchievTracker:SetHiddenShortly(true)
    end)
    ZO_PreHookHandler(ZO_KeybindStripControl, "OnShow", function()
        DsRGuildAchievTracker:SetHiddenShortly(true)
    end)

    -- show listeners
    ZO_PreHookHandler(ZO_MainMenuCategoryBar, "OnHide", function()
        DsRGuildAchievTracker:SetHiddenShortly(false)
    end)
    ZO_PreHookHandler(ZO_InteractWindow, "OnHide", function()
        DsRGuildAchievTracker:SetHiddenShortly(false)
    end)
    ZO_PreHookHandler(ZO_GameMenu_InGame, "OnHide", function()
        DsRGuildAchievTracker:SetHiddenShortly(false)
    end)
    ZO_PreHookHandler(ZO_KeybindStripControl, "OnHide", function()
        DsRGuildAchievTracker:SetHiddenShortly(false)
    end)

    -- event hooks
    DsRGuildAchievTrackerWindow:RegisterForEvent(EVENT_ZONE_CHANGED, 		function() DsRGuildAchievTracker:LoadTrackedAchievements() end)
    DsRGuildAchievTrackerWindow:RegisterForEvent(EVENT_PLAYER_ACTIVATED, 	function() DsRGuildAchievTracker:LoadTrackedAchievements() end)
    DsRGuildAchievTrackerWindow:RegisterForEvent(EVENT_ACHIEVEMENT_UPDATED, function() DsRGuildAchievTracker:LoadTrackedAchievements() end)
    
    EVENT_MANAGER:UnregisterForEvent ("DsRGuildAchievTracker", EVENT_ADD_ON_LOADED )
    
    DsRGuildAchievTracker:LoadTrackedAchievements()
end


