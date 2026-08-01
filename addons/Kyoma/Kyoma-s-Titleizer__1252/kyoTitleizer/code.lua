local Addon = {}
Addon.Name = "kyoTitleizer"
Addon.DisplayName = "|cFF5FF5Kyoma's|r Titleizer"
Addon.Author = "|cFF5FF5Kyoma|r"
Addon.Version = "2.0"

local AVA_SORT_BY_RANK =
{
    ["name"] = {},
    ["rank"] = {tiebreaker = "name", isNumeric = true},
}

local function spairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys 
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

--These are actually their respective achievementIds
local AchievmentIds =
{
	["AvA"] = 
	{
		 92, --Volunteer
		 93, --Recruit
		 94, --Tyro
		 95, --Legionary
		 96, --Veteran
		 97, --Corporal
		 98, --Sergeant
		706, --First Sergeant
		 99, --Lieutenant
		100, --Captain
		101, --Major
		102, --Centurion
		103, --Colonel
		104, --Tribune
		105, --Brigadier
		106, --Prefect
		107, --Praetorian
		108, --Palatine
		109, --August Palatine
		110, --Legate
		111, --General
		112, --Warlord
		113, --Grand Warlord
		114, --Overlord
		705, --Grand Overlord
	},

	["BG"] = 
	{
		1918, -- [Paragon] Paragon
		1915, -- [Battleground Butcher] Battleground Butcher
		1913, -- [Grand Champion] Grand Champion
		1916, -- [Tactician] Tactician
		1919, -- [Triple Threat] Relic Runner
		1910, -- [Conquering Hero] Conquering Hero
		1895, -- [Pit Hero] Bloodletter
		1901, -- [Grand Relic Guardian] Relic Guardian
		1898, -- [Grand Relic Hunter] Relic Hunter
		1904, -- [Grand Standard-Bearer] Standard-Bearer
		1907, -- [Grand Standard-Guardian] Standard-Guardian
		1921, -- [Quadruple Kill] The Merciless
	},

}
local AvATitles 
local AvATitlesF
local TitleCats = {} -- short for categories!! (and because I like cats)

local AchievementToTitle = {}
local TitleToAchievement = {}

local GetNumAchievementCategories        = GetNumAchievementCategories
local GetAchievementCategoryInfo         = GetAchievementCategoryInfo
local GetFirstAchievementInLine          = GetFirstAchievementInLine
local GetAchievementRewardTitle          = GetAchievementRewardTitle
local GetNextAchievementInLine           = GetNextAchievementInLine
local GetAchievementSubCategoryInfo      = GetAchievementSubCategoryInfo
local GetAchievementId                   = GetAchievementId

local GetTitle                           = GetTitle -- I want original titles

local function InitializeTitles()

	local function CheckAchievementsInLine(id)
		local firstId = GetFirstAchievementInLine(id)
		id = firstId > 0 and firstId or id
		while id > 0 do
			local hasTitle, title = GetAchievementRewardTitle(id)
			if hasTitle then
				AchievementToTitle[id] = title
				TitleToAchievement[title] = id
			end
			id = GetNextAchievementInLine(id)
		end
	end

	for i=1,GetNumAchievementCategories() do
		local s,n,a = GetAchievementCategoryInfo(i)
		for j=1,a do
			CheckAchievementsInLine(GetAchievementId(i,nil,j))
		end

		for j=1,n do
			local s,a = GetAchievementSubCategoryInfo(i,j) 
			for k=1,a do
				CheckAchievementsInLine(GetAchievementId(i,j,k))
			end
		end
	end


	AvATitles = {}
	--grab AvA titles from achievements
	for i, id in ipairs(AchievmentIds["AvA"]) do
		local _, titleName = GetAchievementRewardTitle(id)
		AvATitles[titleName] = i
	end
	
	AvATitlesF = {}
	for titleName, rank in pairs(AvATitles) do
		AvATitlesF[titleName] = "|t28:28:"..GetAvARankIcon(rank*2).."|t " .. titleName
	end

	local header
	for desc, section in pairs(AchievmentIds) do
		for _, id in ipairs(section) do
			if not header then
				header = GetAchievementSubCategoryInfo(GetCategoryInfoFromAchievementId(id))
			end
			local _, titleName = GetAchievementRewardTitle(id)
			TitleCats[titleName] = header
		end
		header = nil
	end
end

local function OnLoad(eventCode, name)
	if name ~= Addon.Name then return end
	
	InitializeTitles()
	
	local LSM = LibStub("LibScrollableMenu")

	local orgAddDropdownRow = STATS.AddDropdownRow
	STATS.AddDropdownRow = function(self, rowName)
		local control = orgAddDropdownRow(self, rowName)
		control.combobox = control:GetNamedChild("Dropdown")
		control.scrollHelper = LSM.ScrollableDropdownHelper:New(self.control, control, 16)
		-- handle scene fading
		--local function OnStateChange(oldState, newState)
		--	if newState == SCENE_HIDING then
		--		control.scrollHelper:DoHide()
		--	end
		--end
		STATS_SCENE:RegisterCallback("StateChange", OnStateChange)
		control.scrollHelper.OnShow = function() end --don't change parenting

		titlesRow = control
		return control
	end

	local function ComboBoxSortHelper(item1, item2, comboBoxObject, sortKey, sortType, sortOrder)
		return ZO_TableOrderingFunction(item1, item2, sortKey or "name", sortType or comboBoxObject.m_sortType, sortOrder or comboBoxObject.m_sortOrder)
	end
	
	local function UpdateTitleDropdownTitles(self, dropdown)
		--[[ original code
		dropdown:ClearItems()

		dropdown:AddItem(ZO_ComboBox:CreateItemEntry(GetString(SI_STATS_NO_TITLE), function() SelectTitle(nil) end), ZO_COMBOBOX_SUPRESS_UPDATE)
		for i=1, GetNumTitles() do
			dropdown:AddItem(ZO_ComboBox:CreateItemEntry(zo_strformat(GetTitle(i), GetRawUnitName("player")) , function() SelectTitle(i) end), ZO_COMBOBOX_SUPRESS_UPDATE)
		end

		dropdown:UpdateItems()

		self:UpdateTitleDropdownSelection(dropdown)
		--]]
		
		-- new code
		dropdown:ClearItems()
		dropdown:AddItem(ZO_ComboBox:CreateItemEntry(GetString(SI_STATS_NO_TITLE), function() SelectTitle(nil) end), ZO_COMBOBOX_SUPRESS_UPDATE)
        
		local function stripMarkup(str)
			return str:gsub("|[Cc]%x%x%x%x%x%x", ""):gsub("|[Rr]", "")
		end
		
		local ownedTitles = {}
		local doonce = false
		local hasSubmenus = false
        
		local mainItems = {}
		local subItems = {}
		for i=1, GetNumTitles() do
			local title = zo_strformat(GetTitle(i), GetRawUnitName("player"))
			title = stripMarkup(title)
			ownedTitles[title] = true
			local header = TitleCats[title]
			if header ~= nil then
				hasSubmenus = true
				subItems[header] = subItems[header] or {}
				table.insert(subItems[header], {name=AvATitlesF[title] or title, rank=AvATitles[title] or 0, callback=function() SelectTitle(i) end})
			else
				table.insert(mainItems, {name=title, callback=function() SelectTitle(i) end})
			end
		end
		table.sort(mainItems, function(item1, item2) return ComboBoxSortHelper(item1, item2, dropdown) end)

		--[[ insert unowned AvA titles
		for title, rank in pairs(AvATitles) do
			local header = TitleCats[title]
			if header ~= nil and not ownedTitles[title] then
				subItems[header] = subItems[header] or {}
				table.insert(subItems[header], {name=AvATitlesF[title] or title, rank=AvATitles[title] or 0, callback=function() end, disabled=true, tooltip = "Disabled Title"})
			end
		end
		--]]

		local i = 1
		for header, titles in spairs(subItems) do
			table.sort(titles, function(item1, item2) return ComboBoxSortHelper(item1, item2, dropdown, "rank", AVA_SORT_BY_RANK) end)
			table.insert(mainItems, i, {name=header, entries=titles})
			i = i + 1
		end
		-- add divider below "No Title" if there is more
		if #mainItems > 0 then
			table.insert(mainItems, 1, {name=LSM.DIVIDER})
			i = i + 1
		end
		-- add divider below last submenu if there is more
		if i <= #mainItems and hasSubmenus then 
			table.insert(mainItems, i, {name=LSM.DIVIDER})
		end
		dropdown:AddItems(mainItems)

		self:UpdateTitleDropdownSelection(dropdown)
	end

	if STATS and STATS.UpdateTitleDropdownTitles then
		STATS.UpdateTitleDropdownTitles = UpdateTitleDropdownTitles
	end

	--[[ test code
	local control = TMP42UI:GetNamedChild("Row")
	control.combobox = control:GetNamedChild("Dropdown")
	control.scrollHelper = LSM.ScrollableDropdownHelper:New(TMP42UI, control, 10) -- do not alter parent of dropdown
	control.scrollHelper.OnShow = function() end
	
	local dropdown = control.dropdown
	dropdown:SetSortsItems(false)
	
	local checks = {}
	local function SetChecked(checked, data)
		df("SetChecked >> %s -> %s", data.name, tostring(checked))
		checks[data.id] = checked
	end
	local function GetChecked(data)
		return checks[data.id]
	end
	
	local function DummyCallback() end
	
	local function OnSelected(dropdown, name, item, selectionChanged)
		df("Selected %s", name)
	end
	
	local function GetTooltip(data)
		--df("GetTooltip >> %s (%s)", data.name, control:GetName())
		if not control.scrollHelper then
			--d("NO HELPER")
		end
		return "Tooltip ".. data.id
	end
	
	local function GetEntries(data)
		--df("GetEntries >> %s (%s)", data.name, control:GetName())
		if not control.scrollHelper then

		end
		return data.content
	end
	
	local mainItems = {}
	local maxDepth = 4
	local index = 0
	local function CreateDummyContent(depth, checked)
		local content = {}
		for i=1, math.random(2, 13) do
			index = index + 1
			if checked then 
				table.insert(content, {name="Entry "..index, id=index, checked=GetChecked, callback=SetChecked})
			else
				table.insert(content, {name="Entry "..index, id=index, tooltip=GetTooltip, callback=OnSelected})
			end
		end
		if depth <= maxDepth then
			table.insert(content, 1, {name=LSM.DIVIDER})
			index = index + 1
			table.insert(content, 1, {name="Submenu "..index, id=index, entries=CreateDummyContent(depth+1)})
			index = index + 1
			table.insert(content, 1, {name="Submenu "..index, id=index, content=CreateDummyContent(99, true), entries=GetEntries}) --never add entries for this submenu
		end
		--table.insert(content, 1, {name="A really long entry for testing.", checked=true, callback=DummyCallback})
		return content
	end
	mainItems = CreateDummyContent(1)
	dropdown:ClearItems()
	dropdown:AddItems(mainItems)
	
	SLASH_COMMANDS["/kyo"] = function()
		index = 0
		local items = CreateDummyContent(1)
		titlesRow.dropdown:ClearItems()
		titlesRow.dropdown:AddItems(items)
	end
	
	--]]

	EVENT_MANAGER:UnregisterForEvent(Addon.Name, EVENT_ADD_ON_LOADED)
end
EVENT_MANAGER:RegisterForEvent(Addon.Name, EVENT_ADD_ON_LOADED, OnLoad)

KYO_TITLEIZER = Addon