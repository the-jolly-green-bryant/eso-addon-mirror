local UMB = UnstuffMyBags or {}

function UMB.CreateSettingsMenu(savedVars, defaults)
   local LAM2 = LibStub("LibAddonMenu-2.0")
   local panelData = {
      type = "panel",
      name = "Unstuff My Bags",
      displayName = name,
      author = "manavortex",
      registerForRefresh = true,
      slashCommand = "/umb",
   }
   LAM2:RegisterAddonPanel("UMB_OptionsPanel", panelData)

   local optionsData = {
     
		-- Here be checkboxes
		-- todo: find a more elegant solution to initialize these, these
		-- threefold method calls that are repeated everytime look shabby.
		{	-- Destroy style items?
			type = "checkbox",
			name = "Destroy style items?",
			tooltip = "Destroy common style items for player race styles? \n The AddOn will try to stuff things into your crafting bag before destroying anything, if you have one.",
			getFunc = function() return savedVars.styleitems end,
			setFunc = function(value) savedVars.styleitems = value end,
		},

		{	-- Destroy white pickup apparel?
			type = "checkbox",
			name = "Destroy white pickup apparel?",
			tooltip = "Destroy white weapons and armours with a value of 0 gold? \nThis will not touch anything with an equipType of 0. If you want to check if an item is affected, enter /script d(GetItemLinkEquipType(\"[ItemLink]\")) into your chat.",
			getFunc = function() return savedVars.white end,
			setFunc = function(value) savedVars.white = value end,
		},
		
		{	-- Destroy all junk with a value of 0?
			type = "checkbox",
			name = "Destroy all junk with a value of 0?",
			tooltip = "Whatever your other junk handlers consider junk\n Will exclude anything above white quality, to avoid accidentally trashing valuables.",
			getFunc = function() return savedVars.white end,
			setFunc = function(value) savedVars.junk = value end,
		},
				
		{	-- exclude furniture blueprints
			type = "checkbox",
			name = "exclude furniture blueprints",
			tooltip = "AddOn will ignore furnishing blueprints",
			getFunc = function() return savedVars.keepFurnitureBlueprints end,
			setFunc = function(value) savedVars.keepFurnitureBlueprints = value end,
		},	
		
		{	-- trash after pickup
			type = "checkbox",
			name = "trash after pickup?",
			tooltip = "Use at own risk \n This will consider everything you configure below.",
			getFunc = function() return savedVars.trashOnPickup end,
			setFunc = function(value) savedVars.trashOnPickup = value end,
			warning = "Use at own risk",
		},	


			
		
		{ -- stolen
			type = "header",
			name = "Stolen Stuff subsettings",
		},
		{	-- activate
			type = "checkbox",
			name = "activate (filter below)...",
			tooltip = "",
			getFunc = function() return UMB.GetStolenActive() end,
			setFunc = function(value) UMB.SetStolenActive(value) end,
		},		

		{	-- exclude vanity clothing
			type = "checkbox",
			name = "exclude vanity clothing",
			tooltip = "keep vanity clothing. If you are (or know) a roleplayer, you should check this box.",
			getFunc = function() return savedVars.keepVanityClothing end,
			setFunc = function(value) UMB.SetKeepVanityClothing(value) end,
			disabled = UMB.GetStolenActive(),
		},

		{ -- Stolen item value
			type = "slider",
			name = "Stolen item value is <=",
			tooltip = "",
			default = defaults.stolenMaxValue,
			min = 0,
			max = 1500,
			step = 50,
			getFunc = function() return savedVars.stolenMaxValue end,
			setFunc = function(value) savedVars.stolenMaxValue = value end,
			disabled = UMB.GetStolenActive(),
		},
		{ -- Stolen item quality
			type = "slider",
			name = "Stolen item quality is <=",
			tooltip = "1 => white \n2 => green \n3 => blue \n4 => purple \n5 => epic",
			default = defaults.stolenKeepQuality,
			min = 1,
			max = 5,
			getFunc = function() return savedVars.stolenKeepQuality end,
			setFunc = function(value) savedVars.stolenKeepQuality = value end,
			disabled = UMB.GetStolenActive(),
		},

		{	-- geahandle recipes separatelyr
			type = "checkbox",
			name = "handle recipes separately",
			tooltip = "",
			getFunc = function() return savedVars.trashRecipes end,
			setFunc = function(value) savedVars.trashRecipes = value end,
			disabled = UMB.GetStolenActive(),
		},

		{ -- recipe quality
			type = "slider",
			name = "Destroy recipes with a quality under",
			tooltip = "2 => green \n3 => blue \n4 => purple \n5 => epic",
			default = defaults.stolenKeepRecipeQuality,
			min = 2,
			max = 5,
			getFunc = function() return savedVars.stolenKeepRecipeQuality end,
			setFunc = function(value) savedVars.stolenKeepRecipeQuality = value end,
			disabled = UMB.GetStolenActive(),
		},
				

			
		 {	-- But I want to keep my...
			 type = "submenu",
			 name = "But I want to keep my...",
			 -- here are more checkboxes
			 controls = {
				{	-- Altmer
					type = "checkbox",
					name = "Altmer Adamantite",
					tooltip = "Wearing Altmer clothes will not make them like you, you know.",
					getFunc = function() return savedVars.keepStyles[ITEMSTYLE_RACIAL_HIGH_ELF] end,
					setFunc = function(value) savedVars.keepStyles[ITEMSTYLE_RACIAL_HIGH_ELF] = value end,
				},
				{	-- Bosmer
					type = "checkbox",
					name = "Bosmer Bone",
					tooltip = "Bosmer eat their dead. Are you sure you want to keep these?",
					getFunc = function() return savedVars.keepStyles[ITEMSTYLE_RACIAL_WOOD_ELF] end,
					setFunc = function(value) 	savedVars.keepStyles[ITEMSTYLE_RACIAL_WOOD_ELF] = value end,
				},
				{	-- Dunmer
					type = "checkbox",
					name = "Dunmer Obsidian",
					tooltip = "A decent choice.",
					getFunc = function() return savedVars.keepStyles[ITEMSTYLE_RACIAL_DARK_ELF] end,
					setFunc = function(value) savedVars.keepStyles[ITEMSTYLE_RACIAL_DARK_ELF] = value end,
				},
				{	-- Nord
					type = "checkbox",
					name = "Nord Corundum",
					tooltip = "Well, if you want to look like you have turned your latest kill inside out and put it on your head...",
					getFunc = function() return savedVars.keepStyles[ITEMSTYLE_RACIAL_NORD] end,
					setFunc = function(value) savedVars.keepStyles[ITEMSTYLE_RACIAL_NORD] = value end,
				   
				},
				{	-- Breton
					type = "checkbox",
					name = "Breton Molybdenum",
					tooltip = "As far as heavy armour goes, these are okay, but have you ever considered Dunmer?",
					getFunc = function() return savedVars.keepStyles[ITEMSTYLE_RACIAL_BRETON] end,
					setFunc = function(value) savedVars.keepStyles[ITEMSTYLE_RACIAL_BRETON] = value end,
					  
				},
				{	-- Redguard
					type = "checkbox",
					name = "Redguard Starmetal",
					tooltip = "If you say Tu'whacca, I will roast you on a stick",
					getFunc = function() return savedVars.keepStyles[ITEMSTYLE_RACIAL_REDGUARD] end,
					setFunc = function(value) savedVars.keepStyles[ITEMSTYLE_RACIAL_REDGUARD] = value end,
				},
				{	-- Orc
					type = "checkbox",
					name = "Orc Manganese",
					tooltip = "They are savages, but their heavy armour cleavage is really appealing.",
					getFunc = function() return savedVars.keepStyles[ITEMSTYLE_RACIAL_ORC] end,
					setFunc = function(value) savedVars.keepStyles[ITEMSTYLE_RACIAL_ORC] = value end,
				},
				{	-- Khajiit
					type = "checkbox",
					name = "Khajit Moonstone",
					tooltip = "Why do Khajit lick their butts? To get the taste of Khajit cooking out of their mouths.",
					getFunc = function() return savedVars.keepStyles[ITEMSTYLE_RACIAL_KHAJIIT] end,
					setFunc = function(value) savedVars.keepStyles[ITEMSTYLE_RACIAL_KHAJIIT] = value end,
				},
				{	-- Argonian
					type = "checkbox",
					name = "Argonian Flint",
					tooltip = "Stay moist!",
					getFunc = function() return savedVars.keepStyles[ITEMSTYLE_RACIAL_ARGONIAN] end,
					setFunc = function(value) savedVars.keepStyles[ITEMSTYLE_RACIAL_ARGONIAN] = value end,
				   
				},
				{
					type = "checkbox",
					name = "Imperial Nickel",
					tooltip = "You seem to have too much money, or be an Imperial invader. In any case, you are entitled to mail a lot of gold to @manavortex (EU)! Congratulations!",
					getFunc = function() return savedVars.keepStyles[ITEMSTYLE_RACIAL_IMPERIAL] end,
					setFunc = function(value) savedVars.keepStyles[ITEMSTYLE_RACIAL_IMPERIAL] = value end,
				},
			 },
		  },

		  
	   }
	   
   LAM2:RegisterOptionControls("UMB_OptionsPanel", optionsData)
end



