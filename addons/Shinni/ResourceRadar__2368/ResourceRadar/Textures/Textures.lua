
local Textures = {}
ResourceRadar:RegisterModule("textures", Textures)

function Textures:Initialize()
	
	self.emptyTexture = "ResourceRadar/Textures/emptyTexture.dds"
	
	self.worldPinTextures = {
		"esoui/art/icons/poi/poi_crafting_complete.dds",
		"esoui/art/ava/ava_rankicon64_augustpalatine.dds",
		"esoui/art/ava/ava_rankicon64_centurion.dds",
		"esoui/art/ava/ava_rankicon64_citizen.dds",
		"esoui/art/currency/gamepad/gp_inspiration_64.dds",
		"esoui/art/ava/ava_rankicon64_augustpalatine.dds",
		"esoui/art/treeicons/gamepad/achievement_categoryicon_crafting.dds",
	}
	
	local PinTypes = LibNodeDetection.pinTypes
	self.pinTypeTextures = {
		[PinTypes.BLACKSMITH] = {
			"esoui/art/icons/mapkey/mapkey_mine.dds",
			"esoui/art/charactercreate/gamepad/charactercreate_orcicon_down.dds",
			--"esoui/art/icons/servicetooltipicons/gamepad/gp_servicetooltipicon_weaponsmith.dds",
			--"esoui/art/icons/servicetooltipicons/gamepad/gp_servicetooltipicon_jewelrycrafting.dds",
			"esoui/art/icons/servicemappins/servicepin_armory.dds",
			"esoui/art/icons/servicemappins/servicepin_jewelrycrafting.dds",
			"esoui/art/icons/servicemappins/servicepin_smithy.dds",
			"esoui/art/crafting/smithing_tabicon_refine_down.dds",
		},
		[PinTypes.CLOTHING] = {
			--"esoui/art/icons/servicetooltipicons/gamepad/gp_servicetooltipicon_armorsmithingstation.dds",
			--"esoui/art/icons/servicetooltipicons/gamepad/gp_servicetooltipicon_lightarmor.dds",
			"esoui/art/icons/servicemappins/servicepin_clothier.dds",
		},
		[PinTypes.ENCHANTING] = {
			--"esoui/art/icons/servicetooltipicons/gamepad/gp_servicetooltipicon_enchanter.dds",
			"esoui/art/crafting/enchantment_tabicon_essence_down.dds",
			"esoui/art/icons/servicemappins/servicepin_enchanting.dds",
		},
		[PinTypes.MUSHROOM] = {
			--"esoui/art/icons/servicetooltipicons/gamepad/gp_servicetooltipicon_alchemist.dds",
			--"esoui/art/icons/servicetooltipicons/gamepad/gp_servicetooltipicon_dyestation.dds",
			"esoui/art/icons/servicemappins/servicepin_alchemy.dds",
			"esoui/art/icons/servicemappins/servicepin_dyestation.dds",
			"esoui/art/crafting/alchemy_tabicon_reagent_down.dds",
		},
		[PinTypes.FLOWER] = {
			--"esoui/art/icons/servicetooltipicons/gamepad/gp_servicetooltipicon_alchemist.dds",
			--"esoui/art/icons/servicetooltipicons/gamepad/gp_servicetooltipicon_dyestation.dds",
			"esoui/art/icons/servicemappins/servicepin_alchemy.dds",
			"esoui/art/icons/servicemappins/servicepin_dyestation.dds",
			"esoui/art/crafting/alchemy_tabicon_reagent_down.dds",
		},
		[PinTypes.WATERPLANT]  = {
			"ResourceRadar/Textures/waterplant.dds",
			--"esoui/art/icons/servicetooltipicons/gamepad/gp_servicetooltipicon_alchemist.dds",
			--"esoui/art/icons/servicetooltipicons/gamepad/gp_servicetooltipicon_dyestation.dds",
			"esoui/art/icons/servicemappins/servicepin_alchemy.dds",
			"esoui/art/icons/servicemappins/servicepin_dyestation.dds",
			"esoui/art/crafting/alchemy_tabicon_reagent_down.dds",
		},
		[PinTypes.CRIMSON]  = {
			"ResourceRadar/Textures/waterplant.dds",
			--"esoui/art/icons/servicetooltipicons/gamepad/gp_servicetooltipicon_alchemist.dds",
			--"esoui/art/icons/servicetooltipicons/gamepad/gp_servicetooltipicon_dyestation.dds",
			"esoui/art/icons/servicemappins/servicepin_alchemy.dds",
			"esoui/art/icons/servicemappins/servicepin_dyestation.dds",
			"esoui/art/crafting/alchemy_tabicon_reagent_down.dds",
		},
		[PinTypes.WOODWORKING] = {
			"esoui/art/icons/mapkey/mapkey_lumbermill.dds",
			--"esoui/art/icons/servicetooltipicons/gamepad/gp_servicepin_woodworker.dds",
			--"esoui/art/icons/servicetooltipicons/gamepad/gp_servicepin_woodworker_new.dds",
			"esoui/art/icons/servicemappins/servicepin_woodworking.dds",
		},
		[PinTypes.WATER] = {
			"esoui/art/treeicons/gamepad/progression_levelup_choiceofpotion.dds",
			"esoui/art/treeicons/store_indexicon_consumables_down.dds",
			"esoui/art/crafting/alchemy_tabicon_solvent_down.dds",
			--"esoui/art/icons/servicetooltipicons/gamepad/gp_servicetooltipicon_alchemist.dds",
			--"esoui/art/icons/servicetooltipicons/gamepad/gp_servicetooltipicon_dyestation.dds",
			"esoui/art/icons/servicemappins/servicepin_alchemy.dds",
			"esoui/art/icons/servicemappins/servicepin_dyestation.dds",
			"esoui/art/icons/servicemappins/servicepin_inn.dds",
		},
		[PinTypes.HERBALIST] = {
			"esoui/art/icons/servicemappins/servicepin_dyestation.dds",
			"ResourceRadar/Textures/waterplant.dds",
			"esoui/art/icons/servicemappins/servicepin_alchemy.dds",
			"esoui/art/crafting/alchemy_tabicon_reagent_down.dds",
		},
		[PinTypes.UNKNOWN] = {
			"esoui/art/icons/poi/poi_crafting_complete.dds",
			"esoui/art/ava/ava_rankicon64_augustpalatine.dds",
			"esoui/art/ava/ava_rankicon64_centurion.dds",
			"esoui/art/ava/ava_rankicon64_citizen.dds",
			"esoui/art/currency/gamepad/gp_inspiration_64.dds",
			"esoui/art/ava/ava_rankicon64_augustpalatine.dds",
			"esoui/art/treeicons/gamepad/achievement_categoryicon_crafting.dds",
		},
	}
	
end
