local AR_COLOR_GREEN = "2DC50E"
local AR_COLOR_BLUE = "3A92FF"
local AR_COLOR_PURPLE = "A02EF7"
local AR_COLOR_GOLD = "E9C629"
local AR_COLOR_WHITE = "FFFFFF"

AutoRefine.traits = 
{
	{ link = "|H0:item:23221:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"}, -- Almandine
	{ link = "|H0:item:23173:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"}, -- Sapphire
	{ link = "|H0:item:30221:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"}, -- Sardonyx
	{ link = "|H0:item:23149:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"}, -- FireOpal
	{ link = "|H0:item:23204:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"}, -- Amethyst
	{ link = "|H0:item:810:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"}, -- Jade
	{ link = "|H0:item:30219:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"}, -- Bloodstone	
	{ link = "|H0:item:813:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"}, -- Turquoise
	{ link = "|H0:item:23165:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"}, -- Carnelian
	{ link = "|H0:item:4456:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"}, -- Quartz
	{ link = "|H0:item:4486:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"}, -- Ruby
	{ link = "|H0:item:4442:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"}, -- Emerald
	{ link = "|H0:item:23171:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"}, -- Garnet
	{ link = "|H0:item:23219:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"}, -- Diamond
	{ link = "|H0:item:16291:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"}, -- Citrine
	{ link = "|H0:item:23203:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"} -- Chysolite
}

AutoRefine.jewelrycraftingTraits = 
{
	{link = "|H0:item:135158:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"}, -- trait1
	{link = "|H0:item:135159:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"}, -- trait2
	{link = "|H0:item:135160:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"} -- trait3	
}   

AutoRefine.clothier = 
{
	itemType = ITEMTYPE_CLOTHIER_RAW_MATERIAL,
	matCp160RawLight = "|H0:item:71200:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
	matCp160RawMedium = "|H0:item:71239:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
	matCp160Light = "|H0:item:64504:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
	matCp160Medium = "|H0:item:64506:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
	
	levelMats =
	{
		{ raw = "|H0:item:71200:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", refined = "|H0:item:64504:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h" }, -- Cp160Light
		{ raw = "|H0:item:71239:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", refined = "|H0:item:64506:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h" }, -- Cp160Medium
	},
	
	mats = 
	{
		{link = "|H0:item:54177:34:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", color = AR_COLOR_GOLD },
		{link = "|H0:item:54176:33:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", color = AR_COLOR_PURPLE },
		{link = "|H0:item:54175:32:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", color = AR_COLOR_BLUE },		
		{link = "|H0:item:54174:31:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", color = AR_COLOR_GREEN },
	},
	
	traits = AutoRefine.traits,
	
	defaultMatCost = 4
}
AutoRefine.blacksmithing = 
{
	itemType = ITEMTYPE_BLACKSMITHING_RAW_MATERIAL,
	matCp160Raw = "|H0:item:71198:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
	matCp160 = "|H0:item:64489:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
	
	levelMats =
	{
		{ raw = "|H0:item:71198:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", refined = "|H0:item:64489:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h" }, -- Cp160
	},
	
	mats = 
	{
		{link = "|H0:item:54173:34:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", color = AR_COLOR_GOLD },
		{link = "|H0:item:54172:33:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", color = AR_COLOR_PURPLE },
		{link = "|H0:item:54171:32:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", color = AR_COLOR_BLUE },		
		{link = "|H0:item:54170:31:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", color = AR_COLOR_GREEN }
	},
	
	traits = AutoRefine.traits,
	
	defaultMatCost = 4
}
AutoRefine.woodworking = 
{	
	itemType = ITEMTYPE_WOODWORKING_RAW_MATERIAL,
	matCp160Raw = "|H0:item:71199:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
	matCp160 = "|H0:item:64502:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
	
	levelMats =
	{
		{ raw = "|H0:item:71199:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", refined = "|H0:item:64502:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h" }, -- Cp160
	},
	
	mats = 
	{
		{link = "|H0:item:54181:34:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", color = AR_COLOR_GOLD },
		{link = "|H0:item:54180:33:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", color = AR_COLOR_PURPLE },
		{link = "|H0:item:54179:32:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", color = AR_COLOR_BLUE },		
		{link = "|H0:item:54178:31:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", color = AR_COLOR_GREEN }
	},
	
	traits = AutoRefine.traits,
	
	defaultMatCost = 4
}

AutoRefine.jewelrycrafting = 
{	
	itemType = ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL,
	extraItemTypes = { ITEMTYPE_JEWELRY_RAW_TRAIT, ITEMTYPE_JEWELRYCRAFTING_RAW_BOOSTER }, 
	matCp160Raw = "|H0:item:135145:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
	matCp160 = "|H0:item:135146:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
	
	levelMats =
	{
		{ raw = "|H0:item:135137:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", refined = "|H0:item:135138:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h" }, 
		{ raw = "|H0:item:135139:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", refined = "|H0:item:135140:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h" }, 
		{ raw = "|H0:item:135141:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", refined = "|H0:item:135142:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h" }, 
		{ raw = "|H0:item:135143:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", refined = "|H0:item:135144:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h" }, 
		{ raw = "|H0:item:135145:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", refined = "|H0:item:135146:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h" }, 
	},
	
	mats = 
	{
		{link = "|H0:item:135154:34:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", color = AR_COLOR_GOLD },
		{link = "|H0:item:135153:33:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", color = AR_COLOR_PURPLE },
		{link = "|H0:item:135152:32:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", color = AR_COLOR_BLUE },		
		{link = "|H0:item:135151:31:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", color = AR_COLOR_GREEN }
	},
	
	traits = AutoRefine.jewelrycraftingTraits,
		
	defaultMatCost = 4
}

