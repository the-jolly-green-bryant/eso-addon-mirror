UHS_Data = {}
UHS_Data.Saved = {}
UHS_Data.Saved.Items = {}

UHS_Data.Active = {}
UHS_Data.OldList = {}
UHS_Data.OldItems = {}

local function DoesNotContain(set, key)
    if key == "version" or key == "IDLog" then
        return false
    end
    if key == "Left" or key == "Top" or key == "default" then
        return false
    end
    if key == "GetInterfaceForCharacter" or key == "ResetToDefaults" then
        return false
    end
    return true
end

function UHS_Data.AddOldItems()
    UHS_Data.OldList = ZO_SavedVars:New("UnDeadHarvestAddedVariables", 2, nil, UHS_Data.OldList)
    UHS_Data.NOfV = ZO_SavedVars:New("UnDeadHarvestNumberOfVariables", 2, nil, UHS_Data.OldItems)
    local V_Count = UHS_Data.NOfV.Count

	if V_Count ~= nil then
		for i = 1, V_Count do
			local customName = UHS_Data.OldList[i][ITEM_NAME]
			local customCode = UHS_Data.OldList[i][ITEM_CODE]
			local customCategory = UHS_Data.OldList[i][ITEM_CATEGORY]
			local customBool = UHS_Data.OldList[i][ITEM_ACTIVE]
			UHS_Data.Saved.Items[customName] = {customName, tonumber(customCode), 0, customCategory, customBool}
            UHS_Data.OldList[i] = nil
		end
        UHS_Data.OldItems = ZO_SavedVars:New("UnDeadHarvestSavedVariables", 5, nil, UHS_Data.OldItems)
        if UHS_Data.OldItems ~= nil then
            for k,v in pairs(UHS_Data.Saved.Items) do
                if UHS_Data.OldItems[k][ITEM_ACTIVE] ~= nil then
                    UHS_Data.Saved.Items[k][ITEM_ACTIVE] = UHS_Data.OldItems[k][ITEM_ACTIVE]
                    UHS_Data.OldItems[k] = nil
                end
            end
        end
        UHS_Data.Saved.Left = UHS_Data.OldItems.Left
        UHS_Data.Saved.Top = UHS_Data.OldItems.Top
        UHS_Data.OldItems.Left = nil
        UHS_Data.OldItems.Top = nil
        UHS_Data.OldItems.IDLog = nil
	end

    UHS_Data.Saved.HasImported = true
end

UHS_Data.Defaults = {}
UHS_Data.Defaults.IDLog = false
UHS_Data.Defaults.HasImported = false
UHS_Data.Defaults.Items = {
    Gold = {"|cffff00Gold|r", "Gold", 0, CATEGORY_CURRENCY, false},
    AP = {"|c00cc99Alliance Points|r", "AP", 0, CATEGORY_CURRENCY, false},
    TelVar = {"|c2a52beTel Var Stones|r", "TelVar", 0, CATEGORY_CURRENCY, false},
    Fish = {"|c1dacd6Fish|r", "Fish", 0, CATEGORY_BAIT, false},
    InsectParts = {"Insect Parts", 42872, 0, CATEGORY_BAIT, true},
    Crawlers = {"Crawlers", 42871, 0, CATEGORY_BAIT, false},
    Worms = {"Worms", 42869, 0, CATEGORY_BAIT, false},
    Guts = {"Guts", 42870, 0, CATEGORY_BAIT, false},
    RubediteOre = {"Rubedite Ore", 71198, 0, CATEGORY_RAW, true},
	AncestorSilk = {"Ancestor Silk", 71200, 0, CATEGORY_RAW, true},
	RubedoScraps = {"Rubedo Scraps", 71239, 0, CATEGORY_RAW, true},
	RubyAsh = {"Ruby Ash", 71199, 0, CATEGORY_RAW, true},
	PlatinumDust = {"Platinum Dust", 135145, 0, CATEGORY_RAW, true},
	LorkhanTears = {"Lorkhan's Tears", 64501, 0, CATEGORY_ALCHEMY, false},
	Kuta = {"|cffff00Kuta|r", 45854, 0, CATEGORY_ENCHANTING, true},
	Rekuta = {"|c9400d3Rekuta|r", 45853, 0, CATEGORY_ENCHANTING, false},
	Itade = {"Itade", 68340, 0, CATEGORY_ENCHANTING, false},
	Repora = {"Repora", 68341, 0, CATEGORY_ENCHANTING, false},
	Haoko = {"Haoko", 45841, 0, CATEGORY_ENCHANTING, false},
	Makko = {"Makko", 45832, 0, CATEGORY_ENCHANTING, false},
	Deni = {"Deni", 45833, 0, CATEGORY_ENCHANTING, false},
	Bugloss = {"Bugloss", 30160, 0, CATEGORY_ALCHEMY, false},
	MountainFlower = {"Mountain Flower", 30163, 0, CATEGORY_ALCHEMY, false},
	LadySmock = {"Lady's Smock", 30158, 0, CATEGORY_ALCHEMY, false},
	CornFlower = {"Corn Flower", 30161, 0, CATEGORY_ALCHEMY, false},
	Columbine = {"Columbine", 30164, 0, CATEGORY_ALCHEMY, false},
	ClamGall = {"Clam Gall", 139020, 0, CATEGORY_ALCHEMY, false},
	MotherOfPearl = {"Mother of Pearl", 139019, 0, CATEGORY_ALCHEMY, false},
	Game = {"Game", 28609, 0, CATEGORY_MISC, false},
	DaedraHeart = {"Daedra Heart", 46151, 0, CATEGORY_MISC, false}
}
