SmarterAutoLootSettings                               = ZO_Object:Subclass()
SmarterAutoLootSettings.db                            = nil
SmarterAutoLootSettings.EVENT_TOGGLE_AUTOLOOT         = 'SMARTERAUTOLOOT_TOGGLE_AUTOLOOT'


local CBM = CALLBACK_MANAGER
local LAM2 = LibAddonMenu2
if ( not LAM2 ) then return end

function SmarterAutoLootSettings:New( ... )
    local result = ZO_Object.New( self )
    result:Initialize( ... )
    return result
end

function SmarterAutoLootSettings:Initialize( db )
    self.db = db
	local panelData = 
	{
		type = "panel",
		name = "Smarter AutoLoot",
	}
	local optionsData = 
	{
		[1] = {
			type = "submenu",
			name = "General Settings",
			controls = {
				[1] = {
					type = "checkbox",
					name = "Enable SmarterAutoLoot",
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
					tooltip = "Should SmarterAutoLoot be allowed to auto destroy left over items?",
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
					name = "Crafting Materials",
					choices = {"always loot", "never loot", "only stolen", "only legal", "per quality threshold", "per value threshold", "per quality OR value", "per quality AND value"},
					getFunc = function() return self.db.filters.craftingMaterials end,
					setFunc = function(value) self.db.filters.craftingMaterials = value end,
					default = "always loot",
				},
				[2] = {
					type = "dropdown",
					name = "Trait & Style Materials",
					choices = {"always loot", "never loot", "only stolen", "only legal", "per quality threshold", "per value threshold", "per quality OR value", "per quality AND value"},
					getFunc = function() return self.db.filters.styleMaterials end,
					setFunc = function(value) self.db.filters.styleMaterials = value end,
					default = "always loot",
				},
				[3] = {
					type = "dropdown",
					name = "Cooking Ingredients",
					choices = {"always loot", "never loot", "only stolen", "only legal", "per quality threshold", "per value threshold", "per quality OR value", "per quality AND value"},
					getFunc = function() return self.db.filters.ingredients end,
					setFunc = function(value) self.db.filters.ingredients = value end,
					default = "always loot",
				},
				[4] = {
					type = "dropdown",
					name = "Cooking Recipes",
					choices = {"always loot", "never loot", "only stolen", "only legal", "per quality threshold", "per value threshold", "per quality OR value", "per quality AND value"},
					getFunc = function() return self.db.filters.recipes end,
					setFunc = function(value) self.db.filters.recipes = value end,
					default = "always loot",
				},
				[5] = {
					type = "dropdown",
					name = "Food & Drink",
					choices = {"always loot", "never loot", "only stolen", "only legal", "per quality threshold", "per value threshold", "per quality OR value", "per quality AND value"},
					getFunc = function() return self.db.filters.foodAndDrink end,
					setFunc = function(value) self.db.filters.foodAndDrink = value end,
					default = "always loot",
				},
				[6] = {
					type = "dropdown",
					name = "Fishing Bait",
					choices = {"always loot", "never loot", "only stolen", "only legal", "per quality threshold", "per value threshold", "per quality OR value", "per quality AND value"},
					getFunc = function() return self.db.filters.fishingBait end,
					setFunc = function(value) self.db.filters.fishingBait = value end,
					default = "always loot",
				},
				[7] = {
					type = "dropdown",
					name = "Soul Gems",
					choices = {"always loot", "never loot", "only stolen", "only legal", "per quality threshold", "per value threshold", "per quality OR value", "per quality AND value"},
					getFunc = function() return self.db.filters.soulGems end,
					setFunc = function(value) self.db.filters.soulGems = value end,
					default = "always loot",
				},
				[8] = {
					type = "dropdown",
					name = "Lockpicks & Tools",
					choices = {"always loot", "never loot", "only stolen", "only legal", "per quality threshold", "per value threshold", "per quality OR value", "per quality AND value"},
					getFunc = function() return self.db.filters.tools end,
					setFunc = function(value) self.db.filters.tools = value end,
					default = "always loot",
				},
				[9] = {
					type = "dropdown",
					name = "Weapons",
					choices = {"always loot", "never loot", "only stolen", "only legal", "per quality threshold", "per value threshold", "per quality OR value", "per quality AND value"},
					getFunc = function() return self.db.filters.weapons end,
					setFunc = function(value) self.db.filters.weapons = value end,
					default = "always loot",
				},
				[10] = {
					type = "dropdown",
					name = "Armor",
					choices = {"always loot", "never loot", "only stolen", "only legal", "per quality threshold", "per value threshold", "per quality OR value", "per quality AND value"},
					getFunc = function() return self.db.filters.armor end,
					setFunc = function(value) self.db.filters.armor = value end,
					default = "always loot",
				},
				[11] = {
					type = "dropdown",
					name = "Collectibles",
					choices = {"always loot", "never loot", "only stolen", "only legal", "per quality threshold", "per value threshold", "per quality OR value", "per quality AND value"},
					getFunc = function() return self.db.filters.collectibles end,
					setFunc = function(value) self.db.filters.collectibles = value end,
					default = "always loot",
				},
				[12] = {
					type = "dropdown",
					name = "Costumes & Disguises",
					choices = {"always loot", "never loot", "only stolen", "only legal", "per quality threshold", "per value threshold", "per quality OR value", "per quality AND value"},
					getFunc = function() return self.db.filters.costumes end,
					setFunc = function(value) self.db.filters.costumes = value end,
					default = "always loot",
				},
				[13] = {
					type = "dropdown",
					name = "Glyphs",
					choices = {"always loot", "never loot", "only stolen", "only legal", "per quality threshold", "per value threshold", "per quality OR value", "per quality AND value"},
					getFunc = function() return self.db.filters.glyphs end,
					setFunc = function(value) self.db.filters.glyphs = value end,
					default = "always loot",
				},
				[14] = {
					type = "dropdown",
					name = "Potions",
					choices = {"always loot", "never loot", "only stolen", "only legal", "per quality threshold", "per value threshold", "per quality OR value", "per quality AND value"},
					getFunc = function() return self.db.filters.potions end,
					setFunc = function(value) self.db.filters.potions = value end,
					default = "always loot",
				},
				[15] = {
					type = "dropdown",
					name = "Poisons",
					choices = {"always loot", "never loot", "only stolen", "only legal", "per quality threshold", "per value threshold", "per quality OR value", "per quality AND value"},
					getFunc = function() return self.db.filters.poisons end,
					setFunc = function(value) self.db.filters.poisons = value end,
					default = "always loot",
				},
				[16] = {
					type = "dropdown",
					name = "Intricate Items",
					choices = {"always loot", "never loot", "only stolen", "only legal", "per quality threshold", "per value threshold", "per quality OR value", "per quality AND value"},
					getFunc = function() return self.db.filters.intricate end,
					setFunc = function(value) self.db.filters.intricate = value end,
					default = "always loot",
				},
				[17] = {
					type = "dropdown",
					name = "Ornate Items",
					choices = {"always loot", "never loot", "only stolen", "only legal", "per quality threshold", "per value threshold", "per quality OR value", "per quality AND value"},
					getFunc = function() return self.db.filters.ornate end,
					setFunc = function(value) self.db.filters.ornate = value end,
					default = "always loot",
				},
				[18] = {
					type = "dropdown",
					name = "Furniture Crafting Materials",
					choices = {"always loot", "never loot", "only stolen", "only legal", "per quality threshold", "per value threshold", "per quality OR value", "per quality AND value"},
					getFunc = function() return self.db.filters.furnitureCraftingMaterials end,
					setFunc = function(value) self.db.filters.furnitureCraftingMaterials = value end,
					default = "always loot",
				},
				-- [18] = {
				-- 	type = "dropdown",
				-- 	name = "Needed Research",
				-- 	choices = {"always loot", "never loot", "only stolen", "only legal", "per quality threshold", "per value threshold", "per quality OR value", "per quality AND value"},
				-- 	getFunc = function() return self.db.filters.neededResearch end,
				-- 	setFunc = function(value) self.db.filters.neededResearch = value end,
				-- 	default = "always loot",
				-- },

			}
		}
	}
	LAM2:RegisterAddonPanel("SmarterAutoLootOptions", panelData)
	LAM2:RegisterOptionControls("SmarterAutoLootOptions", optionsData)
end

function SmarterAutoLootSettings:ToggleAutoLoot()
    self.db.enabled = not self.db.enabled
    CBM:FireCallbacks( self.EVENT_TOGGLE_AUTOLOOT )
end
