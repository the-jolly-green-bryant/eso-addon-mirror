
local PinTypeLocalization = {}
LibNodeDetection:RegisterModule("pinTypeLocalization", PinTypeLocalization)

local PinTypes = LibNodeDetection.pinTypes

local interactableName2PinTypeId = {

	["Piedra rúnica"] = PinTypes.ENCHANTING, --18938
	
	["Cardo bendito"] = PinTypes.FLOWER, -- 80335
	["Ajenjo"] = PinTypes.FLOWER,
	["Cardamina"] = PinTypes.FLOWER,
	["Lengua de buey"] = PinTypes.FLOWER,
	["Espina de dragón"] = PinTypes.FLOWER,
	["Flor de Montaña"] = PinTypes.FLOWER,
	["Aguileña"] = PinTypes.FLOWER,
	["Aciano"] = PinTypes.FLOWER,
	["Raíz de nirn"] = PinTypes.WATERPLANT,
	["Jacinto de agua"] = PinTypes.WATERPLANT,
	["Falacea"] = PinTypes.MUSHROOM,
	["Entoloma azul"] = PinTypes.MUSHROOM,
	["Rúsula emética"] = PinTypes.MUSHROOM,
	["Coprinus violeta"] = PinTypes.MUSHROOM,
	["Putrefacción de Namira"] = PinTypes.MUSHROOM,
	["Hongo blanco"] = PinTypes.MUSHROOM,
	["Rúsula luminosa"] = PinTypes.MUSHROOM,
	["Seta de diablillo"] = PinTypes.MUSHROOM,
	
	["Belladama"] = PinTypes.FLOWER, -- 89419
	
	--["Columbine"] = PinTypes.FLOWER, -- 88394
	["Tejo"] = PinTypes.WOODWORKING,
	["hilo de ébano"] = PinTypes.CLOTHING,
	["mineral de ébano"] = PinTypes.BLACKSMITH,
	
	["arce"] = PinTypes.WOODWORKING, -- 88405
	--["Stinkhorn"] = PinTypes.MUSHROOM,
	["roble"] = PinTypes.WOODWORKING,
	--["Bugloss"] = PinTypes.FLOWER,
	["haya"] = PinTypes.WOODWORKING,
	["nogal"] = PinTypes.WOODWORKING,
	["mineral de hierro"] = PinTypes.BLACKSMITH,
	["mineral de hierro superior"] = PinTypes.BLACKSMITH,
	["mineral de oricalco"] = PinTypes.BLACKSMITH,
	["mineral enano"] = PinTypes.BLACKSMITH,
	["yute"] = PinTypes.CLOTHING,
	["lino"] = PinTypes.CLOTHING,
	["seda de araña"] = PinTypes.CLOTHING,
	["algodón"] = PinTypes.CLOTHING,
	
	["agua pura"] = PinTypes.WATER, -- 88434
	
	["flor del vacío"] = PinTypes.CLOTHING, -- 89112
	["fibra de kresh"] = PinTypes.CLOTHING,
	["tallo plateado"] = PinTypes.CLOTHING,
	["tallo férreo"] = PinTypes.CLOTHING,
	["mineral de calcinio"] = PinTypes.BLACKSMITH,
	["mineral de galatita"] = PinTypes.BLACKSMITH,
	["mineral de azogue"] = PinTypes.BLACKSMITH,
	["mineral de piedra vacua"] = PinTypes.BLACKSMITH,
	["madera nocturna"] = PinTypes.WOODWORKING,
	["cenizas"] = PinTypes.WOODWORKING,
	["abedul"] = PinTypes.WOODWORKING,
	["caoba"] = PinTypes.WOODWORKING,
	
	["odre"] = PinTypes.WATER, --89494, 89537
	
	["fresno rubí"] = PinTypes.WOODWORKING, -- 89513
	["seda ancestral"] = PinTypes.CLOTHING,
	["mineral de rubedita"] = PinTypes.BLACKSMITH,
	
	--["Rubedite Ore"] = PinTypes.BLACKSMITH, -- 89734,89735,90023
	--["Water Skin"] = PinTypes.WATER, -- 89736,89737
	["bolsa de herborista"] = PinTypes.HERBALIST, -- 89419
	["tela rasgada"] = PinTypes.CLOTHING,
	["restos de madera"] = PinTypes.WOODWORKING,
	["líquidos potables"] = PinTypes.WATER, -- 89738,89739
	
	-- jewelry nodes
	["veta de peltre"] = PinTypes.BLACKSMITH, -- 89936
	["veta de platino"] = PinTypes.BLACKSMITH,
	["veta de cobre"] = PinTypes.BLACKSMITH,
	["veta de plata"] = PinTypes.BLACKSMITH,
	["veta de electro"] = PinTypes.BLACKSMITH,
	
	["Raíz de nirn carmesí"] = PinTypes.CRIMSON,
}

function PinTypeLocalization:Initialize()
	PinTypes.interactableName2PinTypeId = PinTypes.interactableName2PinTypeId or {}
	for name, pinTypeId in pairs(interactableName2PinTypeId) do
		PinTypes.interactableName2PinTypeId[zo_strlower(name)] = pinTypeId
	end
end
