
function PUIAddon.CraftingMaterialLevelDisplay()

----------------------------------------------------------------------------------------------------------------
-- Initialize Saved Variable Database Reference
----------------------------------------------------------------------------------------------------------------
	local db = CMLD_SavedVariables[GetWorldName()][GetDisplayName()][tostring(GetCurrentCharacterId())]
	local aw = CMLD_SavedVariables_Account[GetWorldName()]["AllAccounts"]["$AccountWide"]
	
----------------------------------------------------------------------------------------------------------------
-- Configure Addon Settings
----------------------------------------------------------------------------------------------------------------
	aw.saveMode = 1

	db.itemTypeLabels = {
		[0] = false,
		[1] = true,
		[2] = true,
		[3] = false,
		[4] = true,
		[5] = false,
		[6] = false,
		[7] = true,
		[8] = false,
		[9] = true,
		[10] = true,
		[11] = true,
		[12] = true,
		[13] = false,
		[14] = false,
		[15] = false,
		[16] = false,
		[17] = true,
		[18] = true,
		[19] = true,
		[20] = false,
		[21] = false,
		[22] = false,
		[23] = true,
		[24] = true,
		[25] = true,
		[26] = false,
		[27] = false,
		[28] = true,
		[29] = true,
		[30] = true,
		[31] = true,
		[32] = false,
		[33] = true,
		[34] = false,
		[35] = true,
		[36] = true,
		[37] = true,
		[38] = true,
		[39] = true,
		[40] = true,
		[41] = true,
		[42] = true,
		[43] = true,
		[44] = false,
		[45] = true,
		[46] = true,
		[47] = false,
		[48] = false,
		[49] = false,
		[50] = false,
		[51] = true,
		[52] = true,
		[53] = true,
		[54] = false,
		[55] = false,
		[56] = false,
		[57] = false,
		[58] = true,
		[59] = false,
		[60] = false,
		[61] = true,
		[62] = true,
		[63] = false,
		[64] = false,
		[65] = false,
		[66] = false,
		[67] = false,
		[68] = false,
		[69] = false,
		[70] = false,
		[71] = false,
	}
	db.font = {
		color = {
			a = 1,
			r = 1,
			b = 1,
			g = 1,
		},
		size = 14,
		style = "none",
		family = "Univers 55",
	}
	db.showLevelsInCraftingInventoryLists = false
	db.levelSortHeader = true
	db.jewelryCrafting = true
	db.inventoryOffset = -100
	db.blacksmithingInventoryList = true
	db.normalCraftingInventoryList = false
	db.clothingInventoryList = true
	db.showLevelsInInventoryLists = false
	db.normalInventoryList = false
	db.enchanting = true
	db.alchemy = true
	db.woodworkingInventoryList = true
	db.levelHeaderOffsetX = 50
	db.enchantingInventoryList = true
	db.lootOffset = -20
	db.jewelryCraftingInventoryList = true

end
