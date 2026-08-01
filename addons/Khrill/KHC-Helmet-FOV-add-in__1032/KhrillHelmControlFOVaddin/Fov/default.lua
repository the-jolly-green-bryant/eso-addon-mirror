------------------------------------------
--     Khrill Helm Control FOV addin    --
--        default TEXTURE PACKAGE       --
--               by Khrill              --
--                                      --
--                v 1.0.5               --
------------------------------------------


local PACKAGE_NAME = "default"

local KHCADDIN_NAME = "KhrillHelmControlFOVaddin"..PACKAGE_NAME

local defaultZoom = {.15,.85,.20,1}

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

addinList[ITEMSTYLE_NONE] = {
	"fov_01_furmale.dds",
	"fov_02_furfemale.dds",
	"fov_03_thief.dds",	
	"fov_04_chainmale.dds",	
	"fov_05_chainfemale.dds",	
	"fov_06_mithril.dds",	
	"fov_07_elven.dds",	
	"fov_08_glass.dds",	
	"fov_09_townguard.dds",	
	"fov_10_iron.dds",	
	"fov_11_steel.dds",	
	"fov_12_blades.dds",	
	"fov_13_dwarven.dds",	
	"fov_14_orcish.dds",	
	"fov_15_ebonymale.dds",	
	"fov_16_ebonyfemale.dds",	
	"fov_17_daedric.dds",	
	"fov_18_legion.dds",	
	"fov_19_greyfox.dds",	
	"fov_20_bloodworm.dds",	
	"fov_21_oreyn.dds",	
	"fov_22_clavicus.dds",	
	"fov_23_leather.dds",	
	"fov_24_generichood.dds",	
	"fov_25_darkbrotherhood.dds",	
	"fov_26_crusader.dds",	
	"fov_27_amber.dds",	
	"fov_28_madness.dds",	
	"fov_29_darkseducer.dds",	
	"fov_30_goldensaint.dds",	
	"fov_31_order.dds",	
	"fov_32_zealot.dds",	
	"fov_33_thadon.dds",	
	"fov_34_mythic.dds",	
	"fov_35_lich.dds",	
	"fov_36_pegasus.dds",	
}


-- REGISTER --
local function OnActivate()
	if KHCFOV ~= nil then KHCFOV:AddPackage(PACKAGE_NAME, addinList, defaultZoom) end
	EVENT_MANAGER:UnregisterForEvent(KHCADDIN_NAME, EVENT_PLAYER_ACTIVATED)
end

EVENT_MANAGER:RegisterForEvent(KHCADDIN_NAME, EVENT_PLAYER_ACTIVATED, OnActivate)
