local savedVars
local LAM2 = LibStub("LibAddonMenu-2.0")

function AutoProcessStolenItems.CreateSettingsMenu(defaults)	
	local panelData = {
		type 					= "panel",
		name 					= "AutoProcessStolenItems",
		displayName 			= name,
		author 					= "manavortex",
		registerForRefresh 		= true,
		registerForDefaults  	= true,
		slashCommand 			= "/autoprocessstolenitems",
	}
	LAM2:RegisterAddonPanel("AutoProcessStolenItems_OptionsPanel", panelData)
	savedVars = AutoProcessStolenItems.savedVars
	
	local optionsData = {
		{	-- output single
			type = "checkbox",
			name = "itemized output",
			getFunc = function() return savedVars.debugSingle end,
			setFunc = function(value) 
				savedVars.debugSingle 	= value 
				if value then 
					savedVars.debugAll 		= false
				end
			end,
		}, 
		{	-- output list
			type = "checkbox",
			name = "summary output",
			getFunc = function() return savedVars.debugAll end,
			setFunc = function(value) 
				savedVars.debugAll 		= value 
				if value then 
					savedVars.debugSingle 	= false
				end
				
			end,
		},	
		{ 	type = "header", -- auto-launder
			name = "Automatically launder...",
		},				
		{	type = "checkbox",	-- Water
			name = "locked items",
			tooltip = "will automatically launder anything you locked",
			getFunc = function() return savedVars.handleLocked 			end,
			setFunc = function(value) 	savedVars.handleLocked = value	end,
		}, 		
		{	type = "checkbox",	-- Water
			name = "Alchemy solvents",
			getFunc = function() return savedVars[ITEMTYPE_POTION_BASE] end,
			setFunc = function(value) 	
				savedVars[ITEMTYPE_POTION_BASE] = value 				
				savedVars[ITEMTYPE_POISON_BASE] = value 				
			end,
		}, 	
		{	type = "checkbox",	-- Water
			name = "Treasure maps",
			getFunc = function() return savedVars[ITEMTYPE_TROPHY][SPECIALIZED_ITEMTYPE_TROPHY_TREASURE_MAP] 			end,
			setFunc = function(value)	savedVars[ITEMTYPE_TROPHY][SPECIALIZED_ITEMTYPE_TROPHY_TREASURE_MAP] = value 	end,
		}, 
		{	type = "checkbox",	-- Water
			name = "Leniency Edicts",
			getFunc = function() return savedVars[ITEMTYPE_TROPHY][SPECIALIZED_ITEMTYPE_TROPHY_SCROLL]			end,
			setFunc = function(value)	savedVars[ITEMTYPE_TROPHY][SPECIALIZED_ITEMTYPE_TROPHY_SCROLL] = value 	end,
		}, 
		-- {	type = "checkbox", -- Motif books
			-- name = "crow daily treasures?",
			-- tooltip = "Only works on English clients right now and is highly experimental.",
			-- getFunc = function() return	savedVars[ITEMTYPE_TREASURE][SPECIALIZED_ITEMTYPE_TREASURE]				end,
			-- setFunc = function(value) 	savedVars[ITEMTYPE_TREASURE][SPECIALIZED_ITEMTYPE_TREASURE] = value 	end,
		-- },
		
		{	type = "checkbox",	-- Vanity clothing
			name = "vanity clothing",
			getFunc = function() return	savedVars[ITEMTYPE_ARMOR][ITEMTYPE_NONE]				end,
			setFunc = function(value) 	savedVars[ITEMTYPE_ARMOR][ITEMTYPE_NONE] = value 		end,
		},
		
		{	type = "submenu",	-- Style material
			name = "Style material",
			 
			controls = {						
				
				{	type = "checkbox", -- style material
					name = "Style material",
					getFunc = function() return savedVars[ITEMTYPE_STYLE_MATERIAL] 					end,
					setFunc = function(value) 	savedVars[ITEMTYPE_STYLE_MATERIAL] 		= value 	end,
				},  
				{	type = "checkbox", -- refineable style material
					name = "refineable style material",
					getFunc = function() return savedVars[ITEMTYPE_RAW_MATERIAL] 					end,
					setFunc = function(value) 	savedVars[ITEMTYPE_RAW_MATERIAL] 		= value 	end,
				},
			},
		},
		
		{	type = "submenu",	-- Motifs
			name = "Motifs",
			 
			controls = {
				
				{	type = "checkbox", -- Motif books
					name = "Motif books",
					getFunc = function() return	savedVars[ITEMTYPE_RACIAL_STYLE_MOTIF][SPECIALIZED_ITEMTYPE_RACIAL_STYLE_MOTIF_BOOK]						end,
					setFunc = function(value) 	savedVars[ITEMTYPE_RACIAL_STYLE_MOTIF][SPECIALIZED_ITEMTYPE_RACIAL_STYLE_MOTIF_BOOK] = value 		end,
				},		
				{	type = "checkbox", -- Motif chapters
					name = "Motif chapters",
					getFunc = function() return savedVars[ITEMTYPE_RACIAL_STYLE_MOTIF][SPECIALIZED_ITEMTYPE_RACIAL_STYLE_MOTIF_CHAPTER]					end,
					setFunc = function(value) 	savedVars[ITEMTYPE_RACIAL_STYLE_MOTIF][SPECIALIZED_ITEMTYPE_RACIAL_STYLE_MOTIF_CHAPTER] = value 	end,
				},
				{ 	type = "slider", -- Motif book quality
					name = "Motif book quality is >=",
					tooltip = "1 => white \n2 => green \n3 => blue \n4 => purple \n5 => epic",
					default = defaults.stolenKeepQuality,
					min = 3,
					max = 5,
					getFunc = function() return savedVars.quality[ITEMTYPE_RACIAL_STYLE_MOTIF][SPECIALIZED_ITEMTYPE_RACIAL_STYLE_MOTIF_BOOK] 		end,
					setFunc = function(value) 	savedVars.quality[ITEMTYPE_RACIAL_STYLE_MOTIF][SPECIALIZED_ITEMTYPE_RACIAL_STYLE_MOTIF_BOOK] = value end,
				},
			},
		},
		
		{	type = "submenu",	-- Furnishing
			name = "Furnishing",
			 
			controls = {
				{	type = "checkbox", -- Furniture items
					name = "Furniture items",
					getFunc = function() return savedVars[ITEMTYPE_FURNISHING]						end,
					setFunc = function(value) 	savedVars[ITEMTYPE_FURNISHING] = value 				end,
				}, 		
				{	type = "checkbox", -- Furniture material
					name = "Furniture material",
					getFunc = function() return savedVars[ITEMTYPE_FURNISHING_MATERIAL]				end,
					setFunc = function(value) 	savedVars[ITEMTYPE_FURNISHING_MATERIAL] = value 	end,
				}, 		
				{	type = "checkbox", -- Furniture blueprints
					name = "Furniture blueprints",
					getFunc = function() return savedVars[ITEMTYPE_RECIPE][SPECIALIZED_ITEMTYPE_RECIPE_ALCHEMY_FORMULA_FURNISHING]	end,
					setFunc = function(value) 
						savedVars[ITEMTYPE_RECIPE][SPECIALIZED_ITEMTYPE_RECIPE_ALCHEMY_FORMULA_FURNISHING] 			= value 
						savedVars[ITEMTYPE_RECIPE][SPECIALIZED_ITEMTYPE_RECIPE_BLACKSMITHING_DIAGRAM_FURNISHING] 	= value 
						savedVars[ITEMTYPE_RECIPE][SPECIALIZED_ITEMTYPE_RECIPE_CLOTHIER_PATTERN_FURNISHING] 		= value 
						savedVars[ITEMTYPE_RECIPE][SPECIALIZED_ITEMTYPE_RECIPE_ENCHANTING_SCHEMATIC_FURNISHING] 	= value 
						savedVars[ITEMTYPE_RECIPE][SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_DESIGN_FURNISHING] 		= value 
						savedVars[ITEMTYPE_RECIPE][SPECIALIZED_ITEMTYPE_RECIPE_WOODWORKING_BLUEPRINT_FURNISHING] 	= value 				
					end,
				},
				 { 	type = "slider", -- Recipe quality
					name = "Recipe quality is >=",
					tooltip = "1 => white \n2 => green \n3 => blue \n4 => purple \n5 => epic",
					default = 2,
					min = 1,
					max = 5,
					getFunc = function() return savedVars.quality[ITEMTYPE_RECIPE][SPECIALIZED_ITEMTYPE_RECIPE_ALCHEMY_FORMULA_FURNISHING] 		end,
					setFunc = function(value) 	
						savedVars.quality[ITEMTYPE_RECIPE][SPECIALIZED_ITEMTYPE_RECIPE_ALCHEMY_FORMULA_FURNISHING] 			= value 
						savedVars.quality[ITEMTYPE_RECIPE][SPECIALIZED_ITEMTYPE_RECIPE_BLACKSMITHING_DIAGRAM_FURNISHING] 	= value 
						savedVars.quality[ITEMTYPE_RECIPE][SPECIALIZED_ITEMTYPE_RECIPE_CLOTHIER_PATTERN_FURNISHING] 		= value 
						savedVars.quality[ITEMTYPE_RECIPE][SPECIALIZED_ITEMTYPE_RECIPE_ENCHANTING_SCHEMATIC_FURNISHING] 	= value 
						savedVars.quality[ITEMTYPE_RECIPE][SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_DESIGN_FURNISHING] 		= value 
						savedVars.quality[ITEMTYPE_RECIPE][SPECIALIZED_ITEMTYPE_RECIPE_WOODWORKING_BLUEPRINT_FURNISHING] 	= value
					end,
				}, 						
			},
		},
		
		{	type = "submenu",	-- Provisioning
			name = "Provisioning",
			 
			controls = {	
			 
				{	type = "checkbox", -- Provisioning ingredients
					name = "Provisioning ingredients",
					getFunc = function() return savedVars[ITEMTYPE_INGREDIENT]							end,
					setFunc = function(value) 	savedVars[ITEMTYPE_INGREDIENT] = value 				end,
				}, 	
				
				{	type = "checkbox",	-- Provisioning recipes
					name = "Provisioning recipes",
					getFunc = function() return savedVars[ITEMTYPE_RECIPE][SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_DRINK]	end,
					setFunc = function(value) 
						savedVars[ITEMTYPE_RECIPE][SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_DRINK] 				= value 
						savedVars[ITEMTYPE_RECIPE][SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_FOOD] 					= value 				
					end,
				},
				  
				{ 	type = "slider", -- Recipe quality
					name = "Provisioning recipe quality is >=",
					tooltip = "1 => white \n2 => green \n3 => blue \n4 => purple \n5 => epic",
					default = 2,
					min = 1,
					max = 5,
					getFunc = function() return savedVars.quality[ITEMTYPE_RECIPE][SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_DRINK] 		end,
					setFunc = function(value) 	
						savedVars.quality[ITEMTYPE_RECIPE][SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_DRINK] = value 
						savedVars.quality[ITEMTYPE_RECIPE][SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_FOOD] = value 
					end,
				},
			},
		},				
	
		{ 	type = "header", -- auto-sell
			name = "Automatically sell...",
		},
		{	type = "checkbox", -- activate
			name = "sell treasures",
			getFunc = function() return savedVars.sell[ITEMTYPE_TREASURE]					end,
			setFunc = function(value) 	savedVars.sell[ITEMTYPE_TREASURE]		= value 	end,
		},  
		{ -- recipe quality
			type = "slider",
			name = "Treasure quality >=",
			tooltip = "1 => white\n2 => green \n3 => blue \n4 => purple \n5 => epic",
			default = defaults.stolenKeepRecipeQuality,
			min = 1,
			max = 5,
			getFunc = function() return savedVars.sell.quality 			end,
			setFunc = function(value) 	savedVars.sell.quality = value 	end,
		},
		
		{ 	type = "header", -- auto-destroy
			name = "Automatically destroy...",
		},			
		{	type = "checkbox",	-- Water
			name = "Activate this feature",
			getFunc = function() return savedVars.destroy.active 			end,
			setFunc = function(value) 	
				savedVars.destroy.active = value 	
				AutoProcessStolenItems.registerForTrashing(active)	
			end,
		},			
		{	type = "checkbox",	-- Water
			name = "destroy quietly",
			tooltip = "Will not tell you when any item you picked up is getting trashed. Use at own risk.",
			getFunc = function() return savedVars.destroy.shutit 			end,
			setFunc = function(value) 	savedVars.destroy.shutit = value 	end,
		},	
		
		{	type = "description",	-- Explanation
			text = ("This will examine every stolen item that you pick up and mercilessly junk it if it meets the conditions below.\n" ..
				"There is no way to un-destroy it. Use at own risk!\n\n" ..
				"Obviously, this will also override any settings for auto-laundering items."
			)
		},
		

		
		{	type = "checkbox",	-- Water
			name = "Alchemy solvents",
			getFunc = function() return savedVars.destroy[ITEMTYPE_POTION_BASE] end,
			setFunc = function(value) 	
				savedVars.destroy[ITEMTYPE_POTION_BASE] = value 				
				savedVars.destroy[ITEMTYPE_POISON_BASE] = value 				
			end,
		},
		{	type = "checkbox",	-- Lockpicks
			name = "Lockpicks",
			getFunc = function() return savedVars.destroy[ITEMTYPE_TOOL][SPECIALIZED_ITEMTYPE_LOCKPICK] 			end,
			setFunc = function(value)   savedVars.destroy[ITEMTYPE_TOOL][SPECIALIZED_ITEMTYPE_LOCKPICK]  = value 	end,
		},
		{	type = "submenu",	-- Equippables
			name = "Consumables",			 
			controls = {			
				{	type = "checkbox",	-- Vanity clothing
					name = "Food",
					getFunc = function() return	savedVars.destroy[ITEMTYPE_FOOD]									end,
					setFunc = function(value) 	savedVars.destroy[ITEMTYPE_FOOD] = value 							end,
				},			
				{	type = "checkbox",	-- Vanity clothing
					name = "Drink",
					getFunc = function() return	savedVars.destroy[ITEMTYPE_DRINK]									end,
					setFunc = function(value) 	savedVars.destroy[ITEMTYPE_DRINK] = value 							end,
				},			
				{	type = "checkbox",	-- Vanity clothing
					name = "Potion",
					getFunc = function() return	savedVars.destroy[ITEMTYPE_POTION]									end,
					setFunc = function(value) 	savedVars.destroy[ITEMTYPE_POTION] = value 							end,
				},			
				{	type = "checkbox",	-- Vanity clothing
					name = "Poison",
					getFunc = function() return	savedVars.destroy[ITEMTYPE_POISON]									end,
					setFunc = function(value) 	savedVars.destroy[ITEMTYPE_POISON] = value 							end,
				},		
			},		
		},		
		{	type = "submenu",	-- Equippables
			name = "Equippables",			 
			controls = {			
				{	type = "checkbox",	-- Vanity clothing
					name = "vanity clothing",
					getFunc = function() return	savedVars.destroy[ITEMTYPE_ARMOR][ITEMTYPE_NONE]							end,
					setFunc = function(value) 	
						savedVars.destroy[ITEMTYPE_ARMOR][ITEMTYPE_NONE] = value 					
						savedVars.destroy[ITEMTYPE_ARMOR][EQUIP_TYPE_MIN_VALUE] = value
					end,
				},			
				{	type = "checkbox",	-- Vanity clothing
					name = "armor",
					getFunc = function() return	savedVars.destroy[ITEMTYPE_ARMOR][SPECIALIZED_ITEMTYPE_ARMOR]				end,
					setFunc = function(value) 	savedVars.destroy[ITEMTYPE_ARMOR][SPECIALIZED_ITEMTYPE_ARMOR] = value 		end,
				},			
				{	type = "checkbox",	-- Vanity clothing
					name = "weapons",
					getFunc = function() return	savedVars.destroy[ITEMTYPE_WEAPON]											end,
					setFunc = function(value) 	savedVars.destroy[ITEMTYPE_WEAPON] = value 									end,
				},	
				{	type = "checkbox",	-- jewellery
					name = "jewellery",
					getFunc = function() return	savedVars.destroy[ITEMTYPE_ARMOR][EQUIP_TYPE_RING]							end,
					setFunc = function(value) 	
						savedVars.destroy[ITEMTYPE_ARMOR][EQUIP_TYPE_RING] = value 			
						savedVars.destroy[ITEMTYPE_ARMOR][EQUIP_TYPE_NECK] = value 			
					end,
				
				},		
			},		
		},		
		{	type = "submenu",	-- Style material
			name = "Style material",			 
			controls = {						
				
				{	type = "checkbox", -- style material
					name = "Style material",
					getFunc = function() return savedVars.destroy[ITEMTYPE_STYLE_MATERIAL] 					end,
					setFunc = function(value) 	savedVars.destroy[ITEMTYPE_STYLE_MATERIAL] 		= value 	end,
				},  
				{	type = "checkbox", -- refineable style material
					name = "refineable style material",
					getFunc = function() return savedVars.destroy[ITEMTYPE_RAW_MATERIAL] 					end,
					setFunc = function(value) 	savedVars.destroy[ITEMTYPE_RAW_MATERIAL] 		= value 	end,
				},
			},
		},
		
		{	type = "submenu",	-- Motifs
			name = "Motifs",
			 
			controls = {
				
				{	type = "checkbox", -- Motif books
					name = "Motif books",
					getFunc = function() return	savedVars.destroy[ITEMTYPE_RACIAL_STYLE_MOTIF][SPECIALIZED_ITEMTYPE_RACIAL_STYLE_MOTIF_BOOK]						end,
					setFunc = function(value) 	savedVars.destroy[ITEMTYPE_RACIAL_STYLE_MOTIF][SPECIALIZED_ITEMTYPE_RACIAL_STYLE_MOTIF_BOOK] = value 		end,
				},		
				{	type = "checkbox", -- Motif chapters
					name = "Motif chapters",
					getFunc = function() return savedVars.destroy[ITEMTYPE_RACIAL_STYLE_MOTIF][SPECIALIZED_ITEMTYPE_RACIAL_STYLE_MOTIF_CHAPTER]					end,
					setFunc = function(value) 	savedVars.destroy[ITEMTYPE_RACIAL_STYLE_MOTIF][SPECIALIZED_ITEMTYPE_RACIAL_STYLE_MOTIF_CHAPTER] = value 	end,
				},
				{ 	type = "slider", -- Motif book quality
					name = "Motif book quality is >=",
					tooltip = "1 => white \n2 => green \n3 => blue \n4 => purple \n5 => epic",
					default = defaults.stolenKeepQuality,
					min = 3,
					max = 5,
					getFunc = function() return savedVars.quality[ITEMTYPE_RACIAL_STYLE_MOTIF][SPECIALIZED_ITEMTYPE_RACIAL_STYLE_MOTIF_BOOK] 		end,
					setFunc = function(value) 	savedVars.quality[ITEMTYPE_RACIAL_STYLE_MOTIF][SPECIALIZED_ITEMTYPE_RACIAL_STYLE_MOTIF_BOOK] = value end,
				},
			},
		},
		
		{	type = "submenu",	-- Motifs
			name = "Treasure",
			 
			controls = {
				
			
				{	type = "checkbox", -- Motif books
					name = "destroy treasure",
					getFunc = function() return	savedVars.destroy[ITEMTYPE_TREASURE]				end,
					setFunc = function(value) 	savedVars.destroy[ITEMTYPE_TREASURE]["a"] = value 	end,
				},	
				{	type = "checkbox", -- Motif books
					name = "keep for crow daily?",
					getFunc = function() return	not savedVars.destroy[ITEMTYPE_TREASURE][SPECIALIZED_ITEMTYPE_TREASURE]				end,
					setFunc = function(value) 	savedVars.destroy[ITEMTYPE_TREASURE][SPECIALIZED_ITEMTYPE_TREASURE] = not value 	end,
				},	
				{ 	type = "slider", -- treasure quality 
					name = "treasure quality is <=",
					tooltip = "1 => white \n2 => green \n3 => blue \n4 => purple \n5 => epic",
					getFunc = function() return savedVars.destroy.quality[ITEMTYPE_TREASURE] 		 end,
					setFunc = function(value) 	savedVars.destroy.quality[ITEMTYPE_TREASURE] = value end,
					min = 1,					
					max = 5,
				},
			},
		},
		
		{	type = "submenu",	-- Furnishing
			name = "Furnishing",
			 
			controls = {
				{	type = "checkbox", -- Furniture items
					name = "Furniture items",
					getFunc = function() return savedVars.destroy[ITEMTYPE_FURNISHING]						end,
					setFunc = function(value) 	savedVars.destroy[ITEMTYPE_FURNISHING] = value 				end,
				}, 		
				{	type = "checkbox", -- Furniture material
					name = "Furniture material",
					getFunc = function() return savedVars.destroy[ITEMTYPE_FURNISHING_MATERIAL]				end,
					setFunc = function(value) 	savedVars.destroy[ITEMTYPE_FURNISHING_MATERIAL] = value 	end,
				}, 		
				{	type = "checkbox", -- Furniture blueprints
					name = "Furniture blueprints",
					getFunc = function() return savedVars.destroy[ITEMTYPE_RECIPE][SPECIALIZED_ITEMTYPE_RECIPE_ALCHEMY_FORMULA_FURNISHING]	end,
					setFunc = function(value) 
						savedVars.destroy[ITEMTYPE_RECIPE][SPECIALIZED_ITEMTYPE_RECIPE_ALCHEMY_FORMULA_FURNISHING] 			= value 
						savedVars.destroy[ITEMTYPE_RECIPE][SPECIALIZED_ITEMTYPE_RECIPE_BLACKSMITHING_DIAGRAM_FURNISHING] 	= value 
						savedVars.destroy[ITEMTYPE_RECIPE][SPECIALIZED_ITEMTYPE_RECIPE_CLOTHIER_PATTERN_FURNISHING] 		= value 
						savedVars.destroy[ITEMTYPE_RECIPE][SPECIALIZED_ITEMTYPE_RECIPE_ENCHANTING_SCHEMATIC_FURNISHING] 	= value 
						savedVars.destroy[ITEMTYPE_RECIPE][SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_DESIGN_FURNISHING] 		= value 
						savedVars.destroy[ITEMTYPE_RECIPE][SPECIALIZED_ITEMTYPE_RECIPE_WOODWORKING_BLUEPRINT_FURNISHING] 	= value 				
					end,
				},
				 { 	type = "slider", -- Recipe quality
					name = "Recipe quality is >=",
					tooltip = "1 => white \n2 => green \n3 => blue \n4 => purple \n5 => epic",
					default = 2,
					min = 1,
					max = 5,
					getFunc = function() return savedVars.quality[ITEMTYPE_RECIPE][SPECIALIZED_ITEMTYPE_RECIPE_ALCHEMY_FORMULA_FURNISHING] 		end,
					setFunc = function(value) 	
						savedVars.destroy.quality[ITEMTYPE_RECIPE][SPECIALIZED_ITEMTYPE_RECIPE_ALCHEMY_FORMULA_FURNISHING] 			= value 
						savedVars.destroy.quality[ITEMTYPE_RECIPE][SPECIALIZED_ITEMTYPE_RECIPE_BLACKSMITHING_DIAGRAM_FURNISHING] 	= value 
						savedVars.destroy.quality[ITEMTYPE_RECIPE][SPECIALIZED_ITEMTYPE_RECIPE_CLOTHIER_PATTERN_FURNISHING] 		= value 
						savedVars.destroy.quality[ITEMTYPE_RECIPE][SPECIALIZED_ITEMTYPE_RECIPE_ENCHANTING_SCHEMATIC_FURNISHING] 	= value 
						savedVars.destroy.quality[ITEMTYPE_RECIPE][SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_DESIGN_FURNISHING] 		= value 
						savedVars.destroy.quality[ITEMTYPE_RECIPE][SPECIALIZED_ITEMTYPE_RECIPE_WOODWORKING_BLUEPRINT_FURNISHING] 	= value
					end,
				}, 						
			},
		},
		
		{	type = "submenu",	-- Provisioning
			name = "Provisioning",
			 
			controls = {	
			 
				{	type = "checkbox", -- Provisioning ingredients
					name = "Provisioning ingredients",
					getFunc = function() return savedVars.destroy[ITEMTYPE_INGREDIENT]							end,
					setFunc = function(value) 	savedVars.destroy[ITEMTYPE_INGREDIENT] = value 				end,
				}, 	
				
				{	type = "checkbox",	-- Provisioning recipes
					name = "Provisioning recipes",
					getFunc = function() return savedVars.destroy[ITEMTYPE_RECIPE][SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_DRINK]	end,
					setFunc = function(value) 
						savedVars.destroy[ITEMTYPE_RECIPE][SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_DRINK] 				= value 
						savedVars.destroy[ITEMTYPE_RECIPE][SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_FOOD] 					= value 				
					end,
				},
				  
				{ 	type = "slider", -- Recipe quality
					name = "Provisioning recipe quality is >=",
					tooltip = "1 => white \n2 => green \n3 => blue \n4 => purple \n5 => epic",
					default = 2,
					min = 1,
					max = 5,
					getFunc = function() return savedVars.quality[ITEMTYPE_RECIPE][SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_DRINK] 		end,
					setFunc = function(value) 	
						savedVars.destroy.quality[ITEMTYPE_RECIPE][SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_DRINK] = value 
						savedVars.destroy.quality[ITEMTYPE_RECIPE][SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_FOOD] = value 
					end,
				},
			},
		},
			
	}
			
	
	LAM2:RegisterOptionControls("AutoProcessStolenItems_OptionsPanel", optionsData)
	
end