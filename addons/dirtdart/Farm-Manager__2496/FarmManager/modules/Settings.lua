local fm = FarmManager
local classes = fm.classes
classes.Settings = ZO_Object:Subclass()

local LAM2 = LibStub("LibAddonMenu-2.0")

function classes.Settings:New(...)
    local controller = ZO_Object.New(self)
    controller:Init(...)
    return controller
end

function classes.Settings:ShouldInclude(itemLink)
	local itemType = GetItemLinkItemType(itemLink)
    local localItemType = self.db.itemFilter[itemType]
    return localItemType == nil or localItemType.include
end

function classes.Settings:GetGuildName()
	return self.guildNameToNumberList[self.db.guild]
end

function classes.Settings:Init()
    self.name = fm.name.."Settings"
    self.defaults = {
        useMM = true,
		running = false,
		useCraftBag = true,
        itemFilter = {
			[ITEMTYPE_ADDITIVE] = { include =  1 },
			[ITEMTYPE_ARMOR] = { include = 0},
			[ITEMTYPE_ARMOR_BOOSTER] = { include = 1},
			[ITEMTYPE_ARMOR_TRAIT] = {include = 1},
			[ITEMTYPE_AVA_REPAIR] = {include = 1},
			[ITEMTYPE_BLACKSMITHING_BOOSTER] = {include = 1},
			[ITEMTYPE_BLACKSMITHING_MATERIAL] = {include = 1},
			[ITEMTYPE_BLACKSMITHING_RAW_MATERIAL] = {include = 1},
			[ITEMTYPE_CLOTHIER_BOOSTER] = {include = 1},
			[ITEMTYPE_CLOTHIER_MATERIAL] = {include = 1},
			[ITEMTYPE_CLOTHIER_RAW_MATERIAL] = {include = 1},
			[ITEMTYPE_COLLECTIBLE] = {include = 1},
			[ITEMTYPE_CONTAINER] = {include = 1},
			[ITEMTYPE_COSTUME] = {include = 1},
			[ITEMTYPE_CROWN_ITEM] = {include = 1},
			[ITEMTYPE_CROWN_REPAIR] = {include = 1},
			[ITEMTYPE_DISGUISE] = {include = 1},
			[ITEMTYPE_DRINK] = {include = 0},
			[ITEMTYPE_DYE_STAMP] = {include = 1},
			[ITEMTYPE_ENCHANTING_RUNE_ASPECT] = {include = 1},
			[ITEMTYPE_ENCHANTING_RUNE_ESSENCE] = {include = 1},
			[ITEMTYPE_ENCHANTING_RUNE_POTENCY] = {include = 1},
			[ITEMTYPE_ENCHANTMENT_BOOSTER] = {include = 1},
			[ITEMTYPE_FISH] = {include = 1},
			[ITEMTYPE_FLAVORING] = {include = 1},
			[ITEMTYPE_FOOD] = {include=0},
			[ITEMTYPE_FURNISHING] = {include=1},
			[ITEMTYPE_FURNISHING_MATERIAL] = {include=1},
			[ITEMTYPE_GLYPH_ARMOR] = {include=0},
			[ITEMTYPE_GLYPH_JEWELRY] = {include=0},
			[ITEMTYPE_GLYPH_WEAPON] = {include=0},
			[ITEMTYPE_INGREDIENT] = {include=1},
			[ITEMTYPE_LOCKPICK] = {inclde=1},
			[ITEMTYPE_LURE] = {include=1},
			[ITEMTYPE_MASTER_WRIT] = {include=1},
			[ITEMTYPE_MOUNT] = {include=1},
			[ITEMTYPE_PLUG] = {include=1},
			[ITEMTYPE_POISON] = {include=1},
			[ITEMTYPE_POISON_BASE] = {include=1},
			[ITEMTYPE_POTION] = {include=0},
			[ITEMTYPE_POTION_BASE] = {include=1},
			[ITEMTYPE_RACIAL_STYLE_MOTIF] = {include=1},
			[ITEMTYPE_RAW_MATERIAL] = {include=1},
			[ITEMTYPE_REAGENT] = {include=1},
			[ITEMTYPE_RECIPE] = {include=1},
			[ITEMTYPE_SIEGE] = {include=0},
			[ITEMTYPE_SOUL_GEM] = {include=1},
			[ITEMTYPE_SPELLCRAFTING_TABLET] = {include=1},
			[ITEMTYPE_SPICE] = {include=1},
			[ITEMTYPE_STYLE_MATERIAL] = {include=1},
			[ITEMTYPE_TABARD] = {include=0},
			[ITEMTYPE_TOOL] = {include=0},
			[ITEMTYPE_TRASH] = {include=0},
			[ITEMTYPE_TREASURE] = {include=0},
			[ITEMTYPE_TROPHY] = {include=1},
			[ITEMTYPE_WEAPON] = {include=0},
			[ITEMTYPE_WEAPON_BOOSTER] = {include=1},
			[ITEMTYPE_WEAPON_TRAIT] = {include=1},
			[ITEMTYPE_WOODWORKING_BOOSTER] = {include=1},
			[ITEMTYPE_WOODWORKING_MATERIAL] = {include=1},
			[ITEMTYPE_WOODWORKING_RAW_MATERIAL] = {include=1},
			[ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL] = {include=1},
			[ITEMTYPE_JEWELRYCRAFTING_MATERIAL] = {include=1},
			[ITEMTYPE_JEWELRYCRAFTING_BOOSTER] = {include=1},
			[ITEMTYPE_JEWELRYCRAFTING_RAW_BOOSTER] = {include=1}
		}
    }

    self.db = ZO_SavedVars:NewAccountWide("FarmManagerSavedVars", fm.variableVersion, nil, self.defaults)

    local panelData = {
        type = "panel",
        name = "Farm Manager",
        displayName = "Farm Manager",
        author = "@dirtdart",
        version = FarmManager.version,
        registerForRefresh = true,
        registerForDefaults = true
    }

    local menuPanel = LAM2:RegisterAddonPanel(FarmManager.name.."MenuPanel", panelData)

    local optionsTable = {
        {
            type = "checkbox",
            name = "Use MM",
            tooltip = "Use Master Merchant (when off, use Arkadius' Trade Tools",
            getFunc = function() return self.db.useMM end,
            setFunc = function(value) self.db.useMM = value end,
            default = self.db.useMM
		},
		{
			type = "checkbox",
			name = "Use Craft Bag",
			tooltip = "Pull items from craft bag (when off use inventory)",
			getFunc = function() return self.db.useCraftBag end,
			setFunc = function(value) self.db.useCraftBag = value end,
			default = self.db.useCraftBag
		}
    }

    LAM2:RegisterOptionControls(FarmManager.name.."MenuPanel", optionsTable)
end