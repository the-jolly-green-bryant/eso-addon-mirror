AdvancedSmartAutoLootSettings                               = ZO_Object:Subclass()
AdvancedSmartAutoLootSettings.db                            = nil
AdvancedSmartAutoLootSettings.EVENT_TOGGLE_AUTOLOOT         = 'ADVANCEDSMARTAUTOLOOT_TOGGLE_AUTOLOOT'
AdvancedSmartAutoLootSettings.originalAuthor = "Agathorn"
AdvancedSmartAutoLootSettings.maintainer = "Archshot"
AdvancedSmartAutoLootSettings.version = "1.0.2"

local CBM = CALLBACK_MANAGER
local LAM2 = LibStub( 'LibAddonMenu-2.0' )
if ( not LAM2 ) then return end

function AdvancedSmartAutoLootSettings:New( ... )
    local result = ZO_Object.New( self )
    result:Initialize( ... )
    return result
end

function AdvancedSmartAutoLootSettings:Initialize( db )
    self.db = db
    local dropdownChoicesFilter = 
    {
    	[1] = "Always loot",
    	[2] = "Never loot",
    	[3] = "Only legal",
    	[4] = "Only stolen",
    	[5] = "Per quality threshold",
    	[6] = "Per value threshold",
    	[7] = "Per quality or value",
    	[8] = "Per quality and value"
    }
    local dropdownChoicesSimple =
    {
    	[1] = "Always loot",
    	[2] = "Never loot",
    	[3] = "Only legal",
    	[4] = "Only stolen",
    }
	local panelData = 
	{
		type = "panel",
		name = "Advanced Smart Auto Loot",
		author = self.maintainer,
    	version = self.version,
		registerForDefaults = true,
	}
	local optionsData = 
	{
		[1] = {
			type = "submenu",
			name = "General Settings",
			controls = {
				[1] = {
					type = "checkbox",
					name = "Enable Advanced Smart AutoLoot",
					getFunc = function() return self.db.enabled end,
					setFunc = function(value) self:ToggleAutoLoot() end,
					default = true,
				},
				[2] = {
					type = "checkbox",
					name = "Show Item Links",
					tooltip = "If enabled, item links for each item looted will be displayed in the chat window for reference.  They will not be sent to chat, only displayed for you.",
					getFunc = function() return self.db.printItems end,
					setFunc = function(value) self.db.printItems = value end,
					default = false,
				},
				[3] = {
					type = "checkbox",
					name = "Close Loot Window",
					tooltip = "If any items are NOT autolooted due to filters, should the loot window be closed with the items still in the container?",
					getFunc = function() return self.db.closeLootWindow end,
					setFunc = function(value) self.db.closeLootWindow = value end,
					default = false,
				},
				[4] = {
					type = "slider",
					name = "Quality Threshold",
					min = 1,
					max = 5,
					step = 1,
					getFunc = function() return self.db.minimumQuality end,
					setFunc = function(value) self.db.minimumQuality = value end,
					default = 1,
				},
				[5] = {
					type = "slider",
					name = "Value Threshold",
					min = 0,
					max = 10000,
					getFunc = function() return self.db.minimumValue end,
					setFunc = function(value) self.db.minimumValue = value end,
					default = 0,
				},
				[6] = {
					type = "checkbox",
					name = "Allow Item Destruction",
					tooltip = "Should AdvancedSmartAutoLoot be allowed to auto destroy left over items?",
					getFunc = function() return self.db.allowDestroy end,
					setFunc = function(value) self.db.allowDestroy = value; ReloadUI() end,
					default = false,
					warning = "Require Reload of UI"
				},
				[7] = {
					type = "checkbox",
					name = "Loot Stolen Items",
					tooltip = "By default items marked as stolen will not be looted, even if they match your filters.  Enable this to allow stolen items that match the filters to be auto looted.",
					getFunc = function() return self.db.lootStolen end,
					setFunc = function(value) self.db.lootStolen = value end,
					default = false
				},
			}
		},
		[2] = {
			type = "submenu",
			name = "Loot Filters",
			controls = {
				[1] = {
					type = "dropdown",
					name = "Armor",
					choices = dropdownChoicesFilter,
					getFunc = function() return self.db.filters.armor end,
					setFunc = function(value) self.db.filters.armor = value end,
				},
				[2] = {
					type = "dropdown",
					name = "Collectibles",
					choices = dropdownChoicesFilter,
					getFunc = function() return self.db.filters.collectibles end,
					setFunc = function(value) self.db.filters.collectibles = value end,
				},
				[3] = {
					type = "dropdown",
					name = "Cooking Ingredients",
					choices = dropdownChoicesFilter,
					getFunc = function() return self.db.filters.ingredients end,
					setFunc = function(value) self.db.filters.ingredients = value end,
				},
				[4] = {
					type = "dropdown",
					name = "Cooking Recipes",
					choices = dropdownChoicesFilter,
					getFunc = function() return self.db.filters.recipes end,
					setFunc = function(value) self.db.filters.recipes = value end,
				},
				[5] = {
					type = "dropdown",
					name = "Costumes & Disguises",
					choices = dropdownChoicesSimple,
					getFunc = function() return self.db.filters.costumes end,
					setFunc = function(value) self.db.filters.costumes = value end,
				},
				[6] = {
					type = "dropdown",
					name = "Crafting Materials",
					choices = dropdownChoicesFilter,
					getFunc = function() return self.db.filters.craftingMaterials end,
					setFunc = function(value) self.db.filters.craftingMaterials = value end,
				},
				[7] = {
					type = "dropdown",
					name = "Fishing Bait",
					choices = dropdownChoicesSimple,
					getFunc = function() return self.db.filters.fishingBait end,
					setFunc = function(value) self.db.filters.fishingBait = value end,
				},
				[8] = {
					type = "dropdown",
					name = "Food & Drink",
					choices = dropdownChoicesFilter,
					getFunc = function() return self.db.filters.foodAndDrink end,
					setFunc = function(value) self.db.filters.foodAndDrink = value end,
				},
				[9] = {
					type = "dropdown",
					name = "Furniture Crafting Materials",
					choices = dropdownChoicesFilter,
					getFunc = function() return self.db.filters.furnitureCraftingMaterials end,
					setFunc = function(value) self.db.filters.furnitureCraftingMaterials = value end,
				},
				[10] = {
					type = "dropdown",
					name = "Glyphs",
					choices = dropdownChoicesFilter,
					getFunc = function() return self.db.filters.glyphs end,
					setFunc = function(value) self.db.filters.glyphs = value end,
				},
				[11] = {
					type = "dropdown",
					name = "Intricate Items",
					choices = dropdownChoicesSimple,
					getFunc = function() return self.db.filters.intricate end,
					setFunc = function(value) self.db.filters.intricate = value end,
				},
				[12] = {
					type = "dropdown",
					name = "Lockpicks & Tools",
					choices = dropdownChoicesSimple,
					getFunc = function() return self.db.filters.tools end,
					setFunc = function(value) self.db.filters.tools = value end,
				},
				[13] = {
					type = "dropdown",
					name = "Ornate Items",
					choices = dropdownChoicesFilter,
					getFunc = function() return self.db.filters.ornate end,
					setFunc = function(value) self.db.filters.ornate = value end,
				},
				[14] = {
					type = "dropdown",
					name = "Poisons",
					choices = dropdownChoicesFilter,
					getFunc = function() return self.db.filters.poisons end,
					setFunc = function(value) self.db.filters.poisons = value end,
				},
				[15] = {
					type = "dropdown",
					name = "Potions",
					choices = dropdownChoicesFilter,
					getFunc = function() return self.db.filters.potions end,
					setFunc = function(value) self.db.filters.potions = value end,
				},
				[16] = {
					type = "dropdown",
					name = "Soul Gems",
					choices = dropdownChoicesSimple,
					getFunc = function() return self.db.filters.soulGems end,
					setFunc = function(value) self.db.filters.soulGems = value end,
				},
				[17] = {
					type = "dropdown",
					name = "Trait & Style Materials",
					choices = dropdownChoicesSimple,
					getFunc = function() return self.db.filters.styleMaterials end,
					setFunc = function(value) self.db.filters.styleMaterials = value end,
				},
				[18] = {
				 	type = "dropdown",
				 	name = "Trash",
					choices = dropdownChoicesFilter,
				 	getFunc = function() return self.db.filters.itemTrash end,
				 	setFunc = function(value) self.db.filters.itemTrash = value end,
				},
				[19] = {
				 	type = "dropdown",
				 	name = "Treasures",
					choices = dropdownChoicesFilter,
				 	getFunc = function() return self.db.filters.itemTreasure end,
				 	setFunc = function(value) self.db.filters.itemTreasure = value end,
				},
				[20] = {
					type = "dropdown",
					name = "Weapons",
					choices = dropdownChoicesFilter,
					getFunc = function() return self.db.filters.weapons end,
					setFunc = function(value) self.db.filters.weapons = value end,
				},
			}
		}
	}
	LAM2:RegisterAddonPanel("AdvancedSmartAutoLootOptions", panelData)
	LAM2:RegisterOptionControls("AdvancedSmartAutoLootOptions", optionsData)
end

function AdvancedSmartAutoLootSettings:ToggleAutoLoot()
    self.db.enabled = not self.db.enabled
    CBM:FireCallbacks( self.EVENT_TOGGLE_AUTOLOOT )
end
