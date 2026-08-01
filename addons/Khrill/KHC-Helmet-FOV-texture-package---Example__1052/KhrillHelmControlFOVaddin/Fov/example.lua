------------------------------------------
--     Khrill Helm Control FOV addin    --
--        example TEXTURE PACKAGE       --
--               by Khrill              --
--                                      --
--                v 1.0.1               --
------------------------------------------


local PACKAGE_NAME = "example"

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

addinList[ITEMSTYLE_RACIAL_DARK_ELF] = {
	"Dun_High.dds",
}
addinList[ITEMSTYLE_RACIAL_HIGH_ELF] = {
	"heavyhelmet.dds",
}


-- REGISTER --
local function OnActivate()
	if KHCFOV ~= nil then KHCFOV:AddPackage(PACKAGE_NAME, addinList) end
	
	EVENT_MANAGER:UnregisterForEvent(KHCADDIN_NAME, EVENT_PLAYER_ACTIVATED)
end

EVENT_MANAGER:RegisterForEvent(KHCADDIN_NAME, EVENT_PLAYER_ACTIVATED, OnActivate)
