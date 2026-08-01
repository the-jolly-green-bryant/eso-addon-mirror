------------------------------------------
--     Khrill Helm Control FOV addin    --
--        Light Armour FOV Package	--
--              by REVENANTSP1      	--
--                                      --
--                v 1.0.0               --
------------------------------------------


local PACKAGE_NAME = "RS1Light"

local KHCADDIN_NAME = "KhrillHelmControlFOVaddin"..PACKAGE_NAME

local addinList = {}
--	addinList = {
--		[ITEMSTYLE_RACIAL_ARGONIAN] = {"texture1.dds", "texture2.dds" , ...}
--		[ItemStyle] = {filename, ...}
--	}
--[[ItemStyle:
* ITEMSTYLE_NONE				0
* ITEMSTYLE_RACIAL_ARGONIAN		6
* ITEMSTYLE_RACIAL_BRETON		1
* ITEMSTYLE_RACIAL_DARK_ELF		4
* ITEMSTYLE_RACIAL_HIGH_ELF		7
* ITEMSTYLE_RACIAL_IMPERIAL		34
* ITEMSTYLE_RACIAL_KHAJIIT		9
* ITEMSTYLE_RACIAL_NORD			5
* ITEMSTYLE_RACIAL_ORC			3
* ITEMSTYLE_RACIAL_REDGUARD		2
* ITEMSTYLE_RACIAL_WOOD_ELF		8
* ITEMSTYLE_AREA_DWEMER			14
* ITEMSTYLE_AREA_ANCIENT_ELF	15
* ITEMSTYLE_AREA_REACH			17
* ITEMSTYLE_ENEMY_PRIMITIVE		19
* ITEMSTYLE_ENEMY_DAEDRIC		20
]]

addinList[ITEMSTYLE_RACIAL_HIGH_ELF] = {
	"Altmer_All.dds",
}
addinList[ITEMSTYLE_AREA_ANCIENT_ELF] = {
	"Altmer_All.dds",
}
addinList[ITEMSTYLE_RACIAL_ARGONIAN] = {
	"Argonian_Low.dds",
	"Argonian_Mid.dds",
}
addinList[ITEMSTYLE_AREA_REACH] = {
	"Barbaric_All.dds",
}
addinList[ITEMSTYLE_RACIAL_WOOD_ELF] = {
	"Bosmer_Low.dds",
	"Bosmer_Mid.dds",
}
addinList[ITEMSTYLE_RACIAL_BRETON] = {
	"Breton_Low.dds",
	"Breton_Mid.dds",
}
addinList[ITEMSTYLE_RACIAL_DARK_ELF] = {
	"Dunmer_Low.dds",
	"Dunmer_Mid.dds",
	"Dunmer_High.dds",
}
addinList[ITEMSTYLE_ENEMY_DAEDRIC] = {
	"Daedric_All.dds",
}
addinList[ITEMSTYLE_RACIAL_DARK_ELF] = {
	"Dunmer_Low.dds",
	"Dunmer_Mid.dds",
	"Dunmer_High.dds",
}
addinList[ITEMSTYLE_AREA_DWEMER] = {
	"Dwemer_All.dds",
	"Dwemer_Alt.dds",
}
addinList[ITEMSTYLE_RACIAL_IMPERIAL] = {
	"Imperial_Low.dds",
	"Imperial_Mid.dds",
	"Imperial_High.dds",
}
addinList[ITEMSTYLE_RACIAL_KHAJIIT] = {
	"Khajiit_All.dds",
}
addinList[ITEMSTYLE_RACIAL_NORD] = {
	"Nord_Low.dds",
	"Nord_Mid.dds",
	"Nord_High.dds",
}
addinList[ITEMSTYLE_RACIAL_ORC] = {
	"Orsimer_Low.dds",
	"Orsimer_Mid.dds",
	"Orsimer_High.dds",
}
addinList[ITEMSTYLE_ENEMY_PRIMITIVE] = {
	"Primal_All.dds",
}
addinList[ITEMSTYLE_RACIAL_REDGUARD] = {
	"Redguard_Low.dds",
	"Redguard_Mid.dds",
	"Redguard_High.dds",
}

-- REGISTER --
local function OnActivate()
	if KHCFOV ~= nil then KHCFOV:AddPackage(PACKAGE_NAME, addinList) end
	
	EVENT_MANAGER:UnregisterForEvent(KHCADDIN_NAME, EVENT_PLAYER_ACTIVATED)
end

EVENT_MANAGER:RegisterForEvent(KHCADDIN_NAME, EVENT_PLAYER_ACTIVATED, OnActivate)
--EVENT_MANAGER:RegisterForEvent(KHCADDIN_NAME, EVENT_ADD_ON_LOADED, function(_event, _name) OnInit(_event, _name) end)
