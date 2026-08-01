if OCDCollector == nil then OCDCollector = {} end
OCDCollector.name = "OCDCollector"

function OCDCollectorScan()
	OCDCollector.SUM = {}
	local TotalmaxCollectibles = 0
	local OwnedCollectibles = 0

	local CollectibleiconPack = {
	{Icon1="esoui/art/treeicons/store_indexicon_dlc_up.dds", Icon2="esoui/art/treeicons/store_indexicon_dlc_over.dds", Icon3="esoui/art/treeicons/store_indexicon_dlc_down.dds"},-- 1 Stories
	{Icon1="esoui/art/treeicons/store_indexicon_dlc_up.dds", Icon2="esoui/art/treeicons/store_indexicon_dlc_over.dds", Icon3="esoui/art/treeicons/store_indexicon_dlc_down.dds"},-- 2 Upgrade
	{Icon1="esoui/art/tutorial/store_indexicon_costumes_up.dds", Icon2="", Icon3=""},-- 3 Appearance
	{Icon1="esoui/art/guild/tabicon_home_up.dds", Icon2="esoui/art/guild/tabicon_home_over.dds", Icon3="esoui/art/guild/tabicon_home_down.dds"},-- 4 Housing
	{Icon1="esoui/art/treeicons/collection_indexicon_furnishings_up.dds", Icon2="esoui/art/treeicons/collection_indexicon_furnishings_over.dds", Icon3="esoui/art/treeicons/collection_indexicon_furnishings_down.dds"},-- 5 Furnishings
	{Icon1="esoui/art/treeicons/collection_indexicon_assistants_up.dds", Icon2="esoui/art/treeicons/collection_indexicon_assistants_over.dds", Icon3="esoui/art/treeicons/collection_indexicon_assistants_down.dds"},-- 6 Assistants
	{Icon1="esoui/art/treeicons/store_indexicon_trophy_up.dds", Icon2="esoui/art/treeicons/store_indexicon_trophy_over.dds", Icon3="esoui/art/treeicons/store_indexicon_trophy_down.dds"},-- 7 Mementos
	{Icon1="esoui/art/treeicons/store_indexicon_mounts_up.dds", Icon2="esoui/art/treeicons/store_indexicon_mounts_over.dds", Icon3="esoui/art/treeicons/store_indexicon_mounts_down.dds"},-- 8 Mounts
	{Icon1="/esoui/art/treeicons/store_indexicon_vanitypets_up.dds", Icon2="/esoui/art/treeicons/store_indexicon_vanitypets_over.dds", Icon3="/esoui/art/treeicons/store_indexicon_vanitypets_down.dds"},-- 9 Non-Combat Pets
	{Icon1="esoui/art/tutorial/tutorial_idexicon_emotes_up.dds", Icon2="esoui/art/tutorial/tutorial_idexicon_emotes_over.dds", Icon3="esoui/art/tutorial/tutorial_idexicon_emotes_down.dds"},-- 10 Emotes
	{Icon1="esoui/art/treeicons/collection_indexicon_abilityskins_up.dds", Icon2="esoui/art/treeicons/collection_indexicon_abilityskins_over.dds", Icon3="esoui/art/treeicons/collection_indexicon_abilityskins_down.dds"},-- 11 Special
	{Icon1="esoui/art/tutorial/progression_indexicon_armor_up.dds", Icon2="esoui/art/tutorial/progression_indexicon_armor_over.dds", Icon3="esoui/art/tutorial/progression_indexicon_armor_down.dds"},-- 12 Armor Styles
	{Icon1="esoui/art/progression/progression_indexicon_weapons_up.dds", Icon2="esoui/art/progression/progression_indexicon_weapons_over.dds", Icon3="esoui/art/progression/progression_indexicon_weapons_down.dds"}-- 13 Weapon Styles
}
	for categoryIndex = 1,GetNumCollectibleCategories(),1 do
			local name, numSubCatgories, numCollectibles, unlockedCollectibles, totalCollectibles = GetCollectibleCategoryInfo(categoryIndex)
			--Returns: string name, number numSubCatgories, number numCollectibles, number unlockedCollectibles, number totalCollectibles, boolean hidesLocked
			local mainCatN = 0
			local mainCatMax = 0
			--d("|cFF1010#"..categoryIndex.." ".. name.." - owned ".. numCollectibles.."/".. unlockedCollectibles.." / ".. totalCollectibles.."|r")
			--d(zo_strformat("<<Z:1>>", "i have 10, blue colored item"))

			--d("|cFF1010#"..categoryIndex.." ".. zo_strformat("<<Z:1>>", name).."|r")
			
			if numSubCatgories == 0 then
				for NoSubCatIndex=1, totalCollectibles,1 do
					Name, _, _, _, unlocked, _, _, categoryType = GetCollectibleInfo(GetCollectibleId(categoryIndex, nil, NoSubCatIndex))
					if unlocked then
						mainCatN = mainCatN + 1
					end
					--TotalmaxCollectibles = TotalmaxCollectibles + totalCollectibles
					-- if categoryIndex==6 then
					-- 	d("#".. NoSubCatIndex .." "..Name.." / "..tostring(unlocked))
					-- end
					--
				end
			else
				for subCategoryIndex=1, numSubCatgories do
					local subCategoryName, subCategoryNumCollectibles, subCategoryUnlockedCollectibles = GetCollectibleSubCategoryInfo(categoryIndex, subCategoryIndex)
					mainCatMax = mainCatMax + subCategoryNumCollectibles
					unlockedN = 0 -- unlocked N i subcategory
					unlockedMax = 0 -- Max N in subcategory
					for collectibleIndex=1, subCategoryNumCollectibles do
						local collectibleId = GetCollectibleId(categoryIndex, subCategoryIndex, collectibleIndex)
						local collectibleName, collectibleDesc, icon1, icon2, unlocked, _, _, categoryType = GetCollectibleInfo(collectibleId)
						if unlocked then
							unlockedN = unlockedN + 1
							mainCatN = mainCatN + 1 --band name, should be removed
						end
				 	end --end for iteration of collectibles
				 	--d("    $".. subCategoryIndex..": "..subCategoryName.." "..unlockedN.."/".. subCategoryNumCollectibles)
				 		--d(unlockedN)
				end --end for iteration of subcategory
			end
			TotalmaxCollectibles = TotalmaxCollectibles + math.max(mainCatMax, totalCollectibles)

			OwnedCollectibles = OwnedCollectibles + mainCatN
			--table.insert(OCDCollector.SUM, {Name = "", Icon1 = "", Icon2 = "", Icon3 = "", Val = "", Max = "" })

			--d(OCDCollector["SUM"])

			table.insert(OCDCollector.SUM, {Name = name, Icon1 = CollectibleiconPack[categoryIndex]["Icon1"], Icon2 = CollectibleiconPack[categoryIndex]["Icon2"], Icon3 = CollectibleiconPack[categoryIndex]["Icon3"], Val = mainCatN, Max = math.max(mainCatMax, totalCollectibles) })
			--d("|c10FF10#"..categoryIndex.." ".. name.." - All: "..mainCatN .. "/" .. math.max(mainCatMax, totalCollectibles).."|r")

	end --end for iteration of categories
	table.insert(OCDCollector.SUM, {Name = "Collectibles", Icon1 = "esoui/art/collections/collections_tabicon_collectibles_up.dds", Icon2 = "esoui/art/collections/collections_tabicon_collectibles_over.dds", Icon3 = "esoui/art/collections/collections_tabicon_collectibles_down.dds", Val = OwnedCollectibles, Max = TotalmaxCollectibles })
	--d("Collectibles: ".. OwnedCollectibles.."/" ..TotalmaxCollectibles)
	--d("-- OFF Collections stuff:")


--  Off Collection Stuff to get:
--**  Achievements
	table.insert(OCDCollector.SUM, {Name = "Achievements", Icon1 = "esoui/art/journal/journal_tabicon_achievements_up.dds", Icon2 = "esoui/art/journal/journal_tabicon_achievements_over.dds", Icon3 = "", Val = GetEarnedAchievementPoints(), Max = GetTotalAchievementPoints() })

	--d("Achievements: "..GetEarnedAchievementPoints().." / "..GetTotalAchievementPoints())
--** Recipes
	-- /script local c = 0 for i=1,GetNumRecipeLists() ,1 do local a,b = GetRecipeListInfo(i) c=c+b d(a.."-"..b)end d(c)
	-- difference of 60 due to mrl

	-- GetRecipeListInfo(number recipeListIndex)
	-- Returns: string name, number numRecipes, textureName upIcon, textureName downIcon, textureName overIcon, textureName disabledIcon, string createSound 

	-- GetRecipeInfo(number recipeListIndex, number recipeIndex)
	-- Returns: boolean known, string name, number numIngredients, number provisionerLevelReq, number qualityReq, number ProvisionerSpecialIngredientType specialIngredientType, number TradeskillType requiredCraftingStationType 

	local MaxRecipes = 0
	local KnownRecipes = 0
	for i=1,GetNumRecipeLists() ,1 do
		local a,b = GetRecipeListInfo(i)
		MaxRecipes=MaxRecipes+b
		--d("#"..i.." "..a.."-"..b)
		for j=1,b do
			local x, y = GetRecipeInfo(i,j)
			--d("#"..y.." "..tostring(x))
			if x then
				KnownRecipes = KnownRecipes + 1
			end
		end
	end
	table.insert(OCDCollector.SUM, {Name = "Recipes", Icon1 = "esoui/art/journal/journal_tabicon_cadwell_up.dds", Icon2 = "esoui/art/journal/journal_tabicon_cadwell_over.dds", Icon3 = "esoui/art/journal/journal_tabicon_cadwell_down.dds", Val = KnownRecipes, Max = MaxRecipes })
	--d("Recipes: "..KnownRecipes.." / "..MaxRecipes)

--** CPs
	local _, _, lvl= GetCharacterInfo()
	table.insert(OCDCollector.SUM, {Name = "Level", Icon1 = "esoui/art/charactercreate/charactercreate_faceicon_up.dds", Icon2 = "", Icon3 = "", Val = lvl, Max = 50 })
	table.insert(OCDCollector.SUM, {Name = "CP", Icon1 = "esoui/art/treeicons/achievements_indexicon_champion_up.dds", Icon2 = "esoui/art/treeicons/achievements_indexicon_champion_up.dds", Icon3 = "", Val = GetPlayerChampionPointsEarned(), Max = 3600 })

--** Lorebooks
	--1 - shalidor
	--2- crafting
	--3 - Eidetic
	local TotalKnownLore = 0
	local TotalLore = 0
	for i=1,3,1 do
		local name, CatNum, categoryId = GetLoreCategoryInfo(i)
		--d(name.." - "..CatNum.."/"..categoryId)
		for j=1,CatNum,1 do
			local LoreName,desc, LoreKnown, LoreTotal= GetLoreCollectionInfo(i,j)
			TotalKnownLore = TotalKnownLore + LoreKnown
			TotalLore = TotalLore + LoreTotal
		end
	end
	table.insert(OCDCollector.SUM, {Name = "Lorebooks", Icon1 = "esoui/art/journal/journal_tabicon_lorelibrary_up.dds", Icon2 = "esoui/art/journal/journal_tabicon_lorelibrary_down.dds", Icon3 = "", Val = TotalKnownLore, Max = TotalLore })
	--d("Lorebooks: "..TotalKnownLore.." / "..TotalLore)

	-- GetLoreCategoryInfo(number categoryIndex)
	-- Returns: string name, number numCollections, number categoryId 

	-- GetLoreCollectionInfo(number categoryIndex, number collectionIndex)
	-- Returns: string name, string description, number numKnownBooks, number totalBooks, boolean hidden, textureName gamepadIcon, number collectionId 

--** MountTraining
     --Returns: number inventoryBonus, number maxInventoryBonus, number staminaBonus, number maxStaminaBonus, number speedBonus, number maxSpeedBonus 
	local a,b,c,dd,e,f = GetRidingStats()
	local MountStats = a + c + e
	local MountStatsMax = b + dd + f
	--d("MountTraining: ".. MountStats .. " / " .. MountStatsMax)
	table.insert(OCDCollector.SUM, {Name = "Mount Training", Icon1 = "esoui/art/treeicons/store_indexicon_mounts_up.dds", Icon2 = "", Icon3 = "", Val = MountStats, Max = MountStatsMax })


--Skills to Max

-- Research

--++--++--++--++--++--++--
-- Partial Helpers:
-- Dungeons
-- dungeons Skills
-- original fishes / Fishing zones done
-- Cyro Ranks
-- skyshards  GetNumSkyShards()


	OCDShortBG:SetEdgeColor(0.4,0.2,0.2, 0)
	OCDShortBG:SetCenterColor(0.1,0.1,0.1)
	OCDShortBG:SetAlpha(0.8)
	OCDShortBG:SetDrawLayer(0)
	OCDShortBG:SetResizeToFitDescendents(true)
	OCDShortBG:SetMovable(true)

	OCDShort:SetResizeToFitDescendents(true)
	OCDShort:SetMovable(true)

	local last = OCDShortBG
	local OCDShortWidth = 10
	local i = 1
	local ShortShowOrder = OCDShortPrepareArray()
	-- {Name = "", Icon1 = "", Icon2 = "", Icon3 = "", Val = "", Max = "" }
	for k,v in pairs(ShortShowOrder) do

		local line = WINDOW_MANAGER:CreateControlFromVirtual("ShortDIVNode", OCDShortBG, "ShortDIV", i)
		line.icon   = line:GetNamedChild("Icon")
		line.texture = line.icon:GetNamedChild("Texture")
		--d(line.icon)
		line.text   = line:GetNamedChild("TXT")
		line.tooltip   = line:GetNamedChild("TOOLTIP")

		line.text:SetText(v.Val.."/"..v.Max.." ")--use margin instead
		line.icon:SetNormalTexture(v.Icon1)

		if v.Icon2 ~= nil then
			line.icon:SetMouseOverTexture(v.Icon2)
		end
		if v.Icon2 ~= nil then
			line.icon:SetPressedTexture(v.Icon3)
		end
		line.tooltip:SetText(v.Name)

		OCDShortWidth = OCDShortWidth + line.icon:GetWidth()
		OCDShortWidth = OCDShortWidth + line.text:GetWidth()
					
		if i==1 then
			line.icon:SetAnchor(TOPLEFT, OCDShortBG, TOPLEFT, 0,0)
			line.text:SetAnchor(LEFT, line.icon, RIGHT, 0,0)
		else
			line.icon:SetAnchor(LEFT, last, RIGHT, 0,0)
			line.text:SetAnchor(LEFT, line.icon, RIGHT, 0,0)
		end
		last = line.text
		i = i+1
	end
	OCDShortBG:SetDimensionConstraints(OCDShortWidth, 40, 2000, 2000)
	OCDShort:SetDimensionConstraints(OCDShortWidth, 40, 2000, 2000)
	OCDShortSUMMARY:SetText(string.format("%.2f", OCDShortCalculatePercent()).."%")

end

function OCDShortPrepareArray()

	local tmp = {}

	local ShortOrder = OCDCollector.savedVariables.ShortShow
	for k,v in pairs(ShortOrder) do
		--d(tostring(v).." "..OCDCollector["SUM"][v]["Name"])
		table.insert(tmp, OCDCollector["SUM"][v])
	end
	return tmp
end

function OCDShortCalculatePercent()
--mode standard
	local i = 0
	local PartialPercent = 0
	for k,v in pairs(OCDCollector["SUM"]) do
		PartialPercent = PartialPercent + v.Val / v.Max
		i = i + 1
	end
	PartialPercent = PartialPercent / i*100
	return PartialPercent
end
--TODO Weighted arithmetic mean based on Settings

function OCDTooltipShow(id)
	id:GetParent():GetNamedChild("TOOLTIP"):SetHidden(false)
end

function OCDTooltipHide(id)
	id:GetParent():GetNamedChild("TOOLTIP"):SetHidden(true)
end
function OCDCollectorSpanCat()
	local last = OCDDashLeft
	
	for i,j in pairs(OCDCollector.SUM) do
		local line = WINDOW_MANAGER:CreateControlFromVirtual("DashCat", OCDDashLeft, "LeftCat", i)
		line.label = line:GetNamedChild("Label")
		line.label:SetText(j.Name)
		line.icon  = line:GetNamedChild("Icon")
		line.icon:SetNormalTexture(j.Icon1)

		if j.Icon2 ~= nil then
			line.icon:SetMouseOverTexture(j.Icon2)
		end
		if j.Icon2 ~= nil then
			line.icon:SetPressedTexture(j.Icon3)
		end

		if i==1 then
			line.icon:SetAnchor(TOPLEFT, last, TOPLEFT, 0,0)
			line.label:SetAnchor(LEFT, line.icon, RIGHT, 0,0)
		else
			line.icon:SetAnchor(TOPLEFT, last.icon, BOTTOMLEFT, 0,0)
			line.label:SetAnchor(LEFT, line.icon, RIGHT, 0,0)
		end
		last = line
	end
end

function OCDCollectorBuildAddonSettingsMenu()
local LAM2 = LibStub("LibAddonMenu-2.0")

function SetShortIcons(str)
	local tmp = {}

	for i in string.gmatch(str, "%S+") do
		if tonumber(i) ~= nil then
			table.insert(tmp, tonumber(i))
		end
	end
	return tmp
end

local panelData = {
         type = "panel",
         name = "OCD Collector",
    }

local optionsData = {
	{
		type ="divider",
		width = "full"
	},
	{
		type = "checkbox",
		name = "Show % of total progression",
		tooltip = "If ON it will show % of total progression",
		getFunc = function() return OCDCollector.savedVariables.ShowTotalProcent end,
		 
		setFunc = function(value) d(value) OCDCollector.savedVariables.ShowTotalProcent=value OCDShortBGBIG:SetHidden(not value) OCDShortSUMMARY:SetHidden(not value) end,
	},
	{
		type ="divider",
		width = "full"
	},
	{
		type = "header",
		name = "Show/Hide Progression Icon",
	}}

	for j,k in pairs(OCDCollector.SUM) do
		table.insert(optionsData, {
			type = "checkbox",
			name = "#"..j.." "..k.Name,
			tooltip = "If ON \""..k.Name.."\" category will be counted in calculating total progression",
			getFunc = function() return true end,
			setFunc = function(value) d(value) end,
		})

	end


optionsData2={
	{
	type = "editbox",
	name = "Order",
	tooltip = "Set the order on on-screen summary",
	getFunc = function() return table.concat(OCDCollector.savedVariables.ShortShow, " ") end,
	setFunc = function(text) SetShortIcons(text) end,
	isMultiline = false,
	width = "full",
	requiresReload = true,
	},
	{
		type ="divider",
		width = "full"
	},
	{
		type = "dropdown",
		name = "My Dropdown",
		tooltip = "Dropdown's tooltip text.",
		choices = {"table", "of", "choices"},
		getFunc = function() return "of" end,
		setFunc = function(var) print(var) end,
	},
	{
		type = "slider",
		name = "My Slider",
		tooltip = "Slider's tooltip text.",
		min = 0,
		max = 20,
		getFunc = function() return 3 end,
		setFunc = function(value) d(value) end,
	},
	{
		type ="divider",
		width = "full"
	},
	{
		type = "description",
		text = "My description text to display.",
		title = "My Title",
		width = "full",
	}
}
	--little hack for merginga tables
	for i in pairs(optionsData2) do
	table.insert(optionsData, optionsData2[i])
	end

LAM2:RegisterAddonPanel("OCDCollectorSettings", panelData)
LAM2:RegisterOptionControls("OCDCollectorSettings", optionsData)

end
function OCDCollector.ShowCollectibles()
	d("--Show Collectibes--")
	OCDDash:SetHidden(true)
	OCDCollectorSpanCat()
end

function OCDCollector.HideCollectibles()
	OCDDash:SetHidden(true)
end

function OCDCollector.SaveSettings()
	OCDCollector.savedVariables.Left = -1 * GuiRoot:GetRight() + OCDShort:GetRight()
	OCDCollector.savedVariables.Top = OCDShort:GetTop()
end

function OCDCollectorLoadSettings()
	OCDShort:ClearAnchors()
	OCDShort:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, OCDCollector.savedVariables.Left, OCDCollector.savedVariables.Top)
	OCDShortBGBIG:SetHidden(not ShowTotalProcent)
	OCDShortSUMMARY:SetHidden(not ShowTotalProcent)

end

function OCDCollector.OnAddOnLoaded(event, addonName)
	if (addonName ~= "OCDCollector") then return end
		d("OCD Collector started")

		OCDCollector.savedVariables = ZO_SavedVars:NewAccountWide("OCDCollector", 1, nil, 
			{
			Left = 0,
			Top = 0,
			ShowTotalProcent = true
			--ShortShow = {3,4,5,6,7,8,9,10,12,13,14,15,16,18,19} --idk why it doesnt work
			})
		if OCDCollector.savedVariables.ShortShow == nil then
			OCDCollector.savedVariables.ShortShow = {3,4,5,6,7,8,9,10,12,13,14,15,16,18,19}
		end
		
		OCDCollectorLoadSettings()
		OCDCollectorScan()
		OCDCollectorBuildAddonSettingsMenu()
		--OCDCollector.ShowCollectibles()
		d("OCD Collector finished")
end

EVENT_MANAGER:RegisterForEvent(OCDCollector.name, EVENT_PLAYER_DEACTIVATED , OCDCollector.SaveSettings)
EVENT_MANAGER:RegisterForEvent(OCDCollector.name, EVENT_ADD_ON_LOADED, OCDCollector.OnAddOnLoaded)
SLASH_COMMANDS["/ocd"] = OCDCollector.ShowCollectibles
SLASH_COMMANDS["/oscan"] = OCDCollectorScan