AdvancedAutoLootConfig                               = ZO_Object:Subclass()
AdvancedAutoLootConfig.db                            = nil
AdvancedAutoLootConfig.EVENT_TOGGLE_AUTOLOOT         = 'ADVANCEDAUTOLOOT_TOGGLE_AUTOLOOT'


local CBM = CALLBACK_MANAGER
local LAM = LibStub( 'LibAddonMenu-2.0' )
if ( not LAM ) then return end

function AdvancedAutoLootConfig:New( ... )
    local result = ZO_Object.New( self )
    result:Initialize( ... )
    return result
end

function AdvancedAutoLootConfig:Initialize( db )
    self.db = db
    	
	local panelData = {
		type = "panel",
		name = "Advanced Autoloot Renewed",
		author = "|c666666Mandrakia|r, |c666666TheChessurCat|r, |c00FF00SilverWF|r",
		version = "1.9.8", 
		registerForRefresh = true,
		registerForDefaults = true,   
		website = "http://www.esoui.com/downloads/info1020-AdvancedAutoLootRenewed.html", 
		slashCommand = "/aalset", 
		}

	LAM:RegisterAddonPanel("AdvancedAutoLootOptions", panelData)

	local optionsData = {
		{
			type = "description",
			text = "Addon allows you filter your loot in the fast and simple way. Also, it allows you to automatically send mails with items, separated by type.",
		},
-- General settings
		{
			type = "header",
			name = "General settings",
		},       
		{
			type = "checkbox",
			name = "Activate Loot filtering",
			tooltip = "Enables loot sorting by filters in the Autojunk settings tab.",
			getFunc = function() return self.db.autoLootActivated end,
			setFunc = function() self:ToggleAutoLoot() end,
		},  
		{
			type = "checkbox",
			name = "Account wide settings",
			tooltip = "This action requires UI to reload!\nWhen set to ON, settings from current characters would be copied to the account wide settings, that will be used for every character at your account",
			getFunc = function() return AdvancedAutoLoot_Db.Default[GetDisplayName()]['$AccountWide']["accountWide"] end,
			setFunc = function(value)    
				if value then
					AdvancedAutoLoot_Db.Default[GetDisplayName()]['$AccountWide'] = AdvancedAutoLoot_Db.Default[GetDisplayName()][GetUnitName("player")]
				end
				AdvancedAutoLoot_Db.Default[GetDisplayName()]['$AccountWide']["accountWide"] = value
			end,
		}, 
		{
			type = "button",
			name = "Reload UI",
			func = function() ReloadUI() end
		},
		{
			type = "checkbox",
			name = "Autosell junk items",
			tooltip = "Should we sell all junk items at the every store open\nStolen items can't be sold to the Merchants!",
			getFunc = function() return self.db.autoJunkSell end,
			setFunc = function() self.db.autoJunkSell = not self.db.autoJunkSell end,
		},
		{
			type = "checkbox",
			name = "Chat announce on junk",
			tooltip = "Would post a various messages to chat: on junk, on deletion, on some savings",
			getFunc = function() return self.db.announceJunk end,
			setFunc = function() self.db.announceJunk = not self.db.announceJunk end,
		},    
		-- {
			-- type = "checkbox",
			-- name = "Enable Mail bouncer",
			-- tooltip = "Would automatically return mails to the sender if subject starts from RETURN or BOUNCE\nAddon would check your mails automatically and return if needed everytime when you'll open your mailbox",
			-- getFunc = function() return self.db.autoBouncer end,
			-- setFunc = function() self.db.autoBouncer = not self.db.autoBouncer end,
		-- },
		{
			type = "checkbox",
			name = "Disable mail delete confirm",
			tooltip = "Would autosuppress delete confirmation dialogue\nOnly for mails without attachments\nUse it on your own risk!",
			getFunc = function() return self.db.deleteDialogSuppress end,
			setFunc = function() self.db.deleteDialogSuppress = not self.db.deleteDialogSuppress end,
		},
		{
			type = "checkbox",
			name = "Disable mail return confirm",
			tooltip = "Would autosuppress return confirmation dialogue\nUse it on your own risk!",
			getFunc = function() return self.db.returnDialogSuppress end,
			setFunc = function() self.db.returnDialogSuppress = not self.db.returnDialogSuppress end,
		},
		{
			type = "slider",
			name = "Mailing delay",
			tooltip = "Delay in milliseconds between mails.\nDo not set it too low or you can be kicked from server!",
			min = 2000, 
			max = 5000, 
			step = 100,
			getFunc = function() return self.db.delay end,
			setFunc = function( delay ) self.db.delay = delay end,
		},
-- Junk sorting options
	   {
			type = "submenu",
			name = "Autojunk settings",
			tooltip = "",
			controls = {
            {
					type = "checkbox",
					name = "Allow stolen sorting",
					tooltip = "Would implement all rules below to the stolen items. If set to OFF then all stolen items would be kept in main bag.",
					getFunc = function() return self.db.allowStolenSort end,
					setFunc = function(value) self.db.allowStolenSort = value end,
				}, 
       {
					type = "slider",
					name = "Autodestroy stolen lower than",
          tooltip = "Would autodestroy stolen items if quality is EQUAL or lower than:\n0 - turn it OFF, 1 - white, 2 - green, 3 - blue, 4 - purple\nFor item types Treasure and Trash only!",
					min = 0, 
					max = 4, 
					getFunc = function() return self.db.minSdestroy end,
					setFunc = function( minSdestroy ) self.db.minSdestroy = minSdestroy end,
          disabled = function() return not self.db.allowStolenSort end,
				},  
				{
					type = "texture",
					image="EsoUI/Art/Miscellaneous/horizontalDivider.dds",
					imageWidth=510,
					imageHeight=4,
				}, 
       {
					type = "slider",
					name = "Minimum quality to keep",
          tooltip = "Minimum quality of ANY items to always keep.\n1 - white, 2 - green, 3 - blue, 4 - purple,  5 - yellow\nIf an item has lower quality, then it would be checked by filters below.",
					min = 1, 
					max = 5, 
					getFunc = function() return self.db.minQuality end,
					setFunc = function( minQuality ) self.db.minQuality = minQuality end,
				},  
       {
					type = "checkbox",
					name = "Keep Set items",
					tooltip = "Armor, Weapon or Jewelry, that are parts of ANY sets, would be kept with any rarity.\nFor CP 160 items only!",
					getFunc = function() return self.db.keepSetItems end,
					setFunc = function() self.db.keepSetItems = not self.db.keepSetItems end,
				},        
       {
					type = "checkbox",
					name = "Keep Any Jewelry",
					tooltip = "Jewelry of any traits and quality would be kept.\nFor CP 160 and salvageable items only!",
					getFunc = function() return self.db.keepAnyJewelry end,
					setFunc = function() self.db.keepAnyJewelry = not self.db.keepAnyJewelry end,
				},  
       {
					type = "checkbox",
					name = "Keep Researchable traits",
					tooltip = "If an item trait can be researched by current character, then it would be kept",
					getFunc = function() return self.db.keepResearchable end,
					setFunc = function() self.db.keepResearchable = not self.db.keepResearchable end,
				}, 		
       {
					type = "checkbox",
					name = "CraftStore: only by selected crafters",
					tooltip = "Keep an item only if it's trait can be researched by selected to Track Traits characters in the CraftStore addon AND you didn't have this type and trait item yet, stored in your Bank or on corresponding character\nRequires CraftStore Fixed and Improved addon!",
					getFunc = function() return self.db.keepMainResearchable end,
					setFunc = function() self.db.keepMainResearchable = not self.db.keepMainResearchable end,
					disabled = function() if not CS or not self.db.keepResearchable then return true else return false end end,
				}, 					
       {
					type = "checkbox",
					name = "Keep Crafted items",
					tooltip = "Any crafted items would be kept",
					getFunc = function() return self.db.keepCrafted end,
					setFunc = function() self.db.keepCrafted = not self.db.keepCrafted end,
				},    
        {
					type = "checkbox",
					name = "Item Savers check",
					tooltip = "Items Saver addons integration:\n* Item Saver - would keep any marked items\n* FCO Item Saver - would keep items, protected from being Junked or Sold\nYou need at least one of this addons installed and enabled to use this function!",
					getFunc = function() return self.db.keepISa end,
					setFunc = function() self.db.keepISa = not self.db.keepISa end,
					disabled = function() if (not ItemSaver and not FCOIS) then return true else return false end end,
				},  
      {
					type = "checkbox",
					name = "Begging the Gear check",
					tooltip = "Would keep gear, matching to filters in the BTG addon.\nYou need this addon installed and enabled to use this function!",
					getFunc = function() return self.db.keepBTG end,
					setFunc = function() self.db.keepBTG = not self.db.keepBTG end,
					disabled = function() if not BTG then return true else return false end end,
				}, 
        {
					type = "checkbox",
					name = "Keep Common style items",
					tooltip = "Common style gear (Dunmer, Bosmer, Khajit, Redguard, Nord, Orc, Altmer, Breton, Argonian, Imperial) would be kept\nOnly if item can be deconstructed\nWarning! If set it ON then it would keep most of looted gear!",
					getFunc = function() return self.db.keepCommonStyle end,
					setFunc = function() self.db.keepCommonStyle = not self.db.keepCommonStyle end,
				}, 
            {
					type = "checkbox",
					name = "Keep Rare style items",
					tooltip = "Rare style gear (Ancient Elf, Barbaric, Primal, Daedric, Mercenary, Glass, Xivkyn, Yokudan, Draugr, Ra Gada, Ashlander) would be kept\nOnly if item can be deconstructed",
					getFunc = function() return self.db.keepRareStyle end,
					setFunc = function() self.db.keepRareStyle = not self.db.keepRareStyle end,
				}, 
            {
					type = "checkbox",
					name = "Keep Exotic style items",
					tooltip = "Exotic style gear (Ancient Orc, alliances styles, Minotaur, Outlaw, etc - basically, any another styles) would be kept\nOnly if item can be deconstructed",
					getFunc = function() return self.db.keepExoticStyle end,
					setFunc = function() self.db.keepExoticStyle = not self.db.keepExoticStyle end,
				}, 
        {
					type = "checkbox",
					name = "Keep Intricate",
					tooltip = "Gear with the Intricate trait would be kept\nOnly if item can be deconstructed",
					getFunc = function() return self.db.keepIntricate end,
					setFunc = function() self.db.keepIntricate = not self.db.keepIntricate end,
				},
        {
					type = "slider",
					name = "Min CP level of gear items to keep",
					tooltip = "Gear (armor, weapon or jewelry) with CP lvl equal or above this filter, would be kept\nOnly if item can be deconstructed\n0 would turn this filter OFF\nWarning! This filter may save most of looted gear!",
					min = 0,
					max = 200,
					step = 10,
  				getFunc = function() return self.db.minItemCP end,
					setFunc = function (minItemCP) self.db.minItemCP = minItemCP end,
				},   
-------------------------
				{
					type = "checkbox",
					name = "Keep all recipes",
					tooltip = "Any craft type and lvl recipes would be kept",
					getFunc = function() return self.db.keepRecipes end,
					setFunc = function() self.db.keepRecipes = not self.db.keepRecipes end,
				},
				{
					type = "checkbox",
					name = "Keep Provisioning ingredients",
					tooltip = "Provisioning ingredients would be kept\nItems, looted directly to the Craft Bag (ESO+) would NOT be junked anyway!",
					getFunc = function() return self.db.keepProvisionning end,
					setFunc = function() self.db.keepProvisionning = not self.db.keepProvisionning end,
				},
				{
					type = "checkbox",
					name = "Keep Potions",
					tooltip = "Any potions would be kept",
					getFunc = function() return self.db.keepPotions end,
					setFunc = function() self.db.keepPotions = not self.db.keepPotions end,
				},        
            {
					type = "checkbox",
					name = "Keep Food / Drinks",
					tooltip = "Any Foods and Drinks would be kept",
					getFunc = function() return self.db.keepFood end,
					setFunc = function() self.db.keepFood = not self.db.keepFood end,
				},
            {
					type = "slider",
					name = "Min CP level of consumables to keep",
					tooltip = "Foods, Drinks and Potions below this CP level still would be junked\n0 would turn this filter OFF",
					min = 0,
					max = 200,
					step = 10,
  				getFunc = function() return self.db.keepFoodCP end,
					setFunc = function (keepFoodCP) self.db.keepFoodCP = keepFoodCP end,
          disabled = function() return not (self.db.keepFood or self.db.keepPotions) end,          
				},        
        {
					type = "checkbox",
					name = "Keep Fishing baits",
					tooltip = "Fishing baits would be kept\nItems, looted directly to the Craft Bag (ESO+) would NOT be junked anyway!",
					getFunc = function() return self.db.keepBaits end,
					setFunc = function() self.db.keepBaits = not self.db.keepBaits end,
				},
        {
					type = "checkbox",
					name = "Keep all Poisons",
					tooltip = "All poisons would be kept",
					getFunc = function() return self.db.keepPoison end,
					setFunc = function() self.db.keepPoison = not self.db.keepPoison end,
				},  
            {
					type = "slider",
					name = "Min CP level of Poisons to keep",
					tooltip = "Poisons below this CP level still would be junked\n0 would turn this filter OFF",
					min = 0,
					max = 200,
					step = 10,
  				getFunc = function() return self.db.keepPoisonCP end,
					setFunc = function (keepPoisonCP) self.db.keepPoisonCP = keepPoisonCP end,
          disabled = function() return not self.db.keepPoison end,
				},        
        {
					type = "checkbox",
					name = "Keep Glyphs",
					tooltip = "All glyphs would be kept",
					getFunc = function() return self.db.keepGlyph end,
					setFunc = function() self.db.keepGlyph = not self.db.keepGlyph end,
				},
            {
					type = "slider",
					name = "Min CP level of Glyphs to keep",
					tooltip = "Glyphs, below this CP level, still would be junked\n0 would turn CP filter OFF",
					min = 0,
					max = 200,
					step = 10,
  				getFunc = function() return self.db.keepGlyphCP end,
					setFunc = function (keepGlyphCP) self.db.keepGlyphCP = keepGlyphCP end,
          disabled = function() return not self.db.keepGlyph end,          
				},
            {
					type = "checkbox",
					name = "Keep Charged Soul Gems",
					tooltip = "Charged Soul Gems would be kept",
					getFunc = function() return self.db.keepSoulgemFull end,
					setFunc = function() self.db.keepSoulgemFull = not self.db.keepSoulgemFull end,
          width="half",
				},        
            {
					type = "checkbox",
					name = "Keep Empty Soul Gems",
					tooltip = "Empty Soul Gems would be kept",
					getFunc = function() return self.db.keepSoulgemEmpty end,
					setFunc = function() self.db.keepSoulgemEmpty = not self.db.keepSoulgemEmpty end,
          width="half",
				}, 
       {
					type = "slider",
					name = "Destroy junk with price lower",
          tooltip = "Would auto destroy junked items with sell cost, lower than set here, exclude unique items, like museum collectibles etc.\nSet 0 to turn this function off\nSet 1 to destroy junk with 0 sell price etc\nUse it on your own risk!",
					min = 0, 
					max = 100, 
          step = 1,          
					getFunc = function() return self.db.destroyJprice end,
					setFunc = function( destroyJprice ) self.db.destroyJprice = destroyJprice end,
				}, 				
       },   
      },  
-- Mail settings	  
		{
			type = "header",
			name = "Mail settings",
		},       
	   {
			type = "description",
			text = "Please, remember, that you can't send mails to yourself! To get your mails back, your recipient must use Mail bouncer feature or return mails to you manually.\nLocked and bound items can't be sent via mail! Also, Auto-mailer would ignore junked items.",
		    },	  
	-- Mail Glyphs settings
		{
			type = "submenu",
			name = "Glyphs settings",
			tooltip = "",	--(optional)
			controls = {
			
				{
					type = "checkbox",
					name = "Enable enchanting sending",
					tooltip = "Enable Glyph icon in the Mailbox",
					getFunc = function() return self.db.mailSettings.Glyph.Send end,
					setFunc = function() self.db.mailSettings.Glyph.Send = not self.db.mailSettings.Glyph.Send end,
				},
				{
					type = "editbox", 
					name = "Mail recipient",
					tooltip = "Recipient of enchanting mails\nRequired field",
					getFunc = function() return self.db.mailSettings.Glyph.To end,
					setFunc = function(value) self.db.mailSettings.Glyph.To = value end,
					disabled = function() return not self.db.mailSettings.Glyph.Send end,          
				},
				{
					type = "editbox", 
					name = "Glyph Subject",
					tooltip = "Subject of the mail\nRequired field",
					default = "RETURN glyphs",
					getFunc = function() return self.db.mailSettings.Glyph.Subject end,
					setFunc = function(value) self.db.mailSettings.Glyph.Subject = value end,
					disabled = function() return not self.db.mailSettings.Glyph.Send end,          
				},
				{
					type = "checkbox",
					name = "Send Essence",
					tooltip = "Would send essence runestones",
					getFunc = function() return self.db.mailSettings.Glyph.SendRaw end,
					setFunc = function() self.db.mailSettings.Glyph.SendRaw = not self.db.mailSettings.Glyph.SendRaw end,
					disabled = function() return not self.db.mailSettings.Glyph.Send end,          
				},				
				{
					type = "checkbox",
					name = "Send Potency",
					tooltip = "Would send potency runestones",
					getFunc = function() return self.db.mailSettings.Glyph.SendMaterials end,
					setFunc = function() self.db.mailSettings.Glyph.SendMaterials = not self.db.mailSettings.Glyph.SendMaterials end,
					disabled = function() return not self.db.mailSettings.Glyph.Send end,          
				},
				{
					type = "checkbox",
					name = "Send Aspect",
					tooltip = "Would send aspect runestones",
					getFunc = function() return self.db.mailSettings.Glyph.SendBoosters end,
					setFunc = function() self.db.mailSettings.Glyph.SendBoosters = not self.db.mailSettings.Glyph.SendBoosters end,
					disabled = function() return not self.db.mailSettings.Glyph.Send end,          
				},
				{
					type = "checkbox",
					name = "Send Glyphs",
					tooltip = "Would send any glyphs",
					getFunc = function() return self.db.mailSettings.Glyph.SendEquipment end,
					setFunc = function() self.db.mailSettings.Glyph.SendEquipment = not self.db.mailSettings.Glyph.SendEquipment end,
					disabled = function() return not self.db.mailSettings.Glyph.Send end,          
				},				
				{
					type = "slider",
					name = "Min amount of items",
					tooltip = "Min amount of items in one mail",
					min = 1, 
					max = 6, 
					getFunc = function() return self.db.mailSettings.Glyph.MinNumber end,
					setFunc = function( mini ) self.db.mailSettings.Glyph.MinNumber = mini end,
          disabled = function() return not self.db.mailSettings.Glyph.Send end,          
				},
			
			}, -- controls end
			
		}, -- glyphs submenu end
	-- 	Mail Wood settings
		{
			type = "submenu",
			name = "Wood settings",
			tooltip = "",	--(optional)
			controls = {
			
				{
					type = "checkbox",
					name = "Enable woodworking sending",
					tooltip = "Enable Wood icon in the Mailbox",
					getFunc = function() return self.db.mailSettings.Wood.Send end,
					setFunc = function() self.db.mailSettings.Wood.Send = not self.db.mailSettings.Wood.Send end,
				},
				{
					type = "checkbox",
					name = "Don't send Item savers",
					tooltip = "Wouldn't send items, protected by item savers:\nItem Saver - any marked items\nFCO Item Saver - items, protected from mailing",
					getFunc = function() return self.db.mailSettings.Wood.KeepISa end,
					setFunc = function() self.db.mailSettings.Wood.KeepISa = not self.db.mailSettings.Wood.KeepISa end,
					disabled = function() return not self.db.mailSettings.Wood.Send end,
				},					
				{
					type = "editbox", 
					name = "Mail recipient",
					tooltip = "Person to send the wood to\nRequired field",
					getFunc = function() return self.db.mailSettings.Wood.To end,
					setFunc = function(value) self.db.mailSettings.Wood.To = value end,
          disabled = function() return not self.db.mailSettings.Wood.Send end,          
				},
				{
					type = "editbox", 
					name = "Mail subject",
					tooltip = "Subject of the mail\nRequired field",
					default = "RETURN wood",
					getFunc = function() return self.db.mailSettings.Wood.Subject end,
					setFunc = function(value) self.db.mailSettings.Wood.Subject = value end,
          disabled = function() return not self.db.mailSettings.Wood.Send end,          
				},
				{
					type = "checkbox",
					name = "Send raw materials",
					tooltip = "Would send raw materials for woodworking",
					getFunc = function() return self.db.mailSettings.Wood.SendRaw end,
					setFunc = function() self.db.mailSettings.Wood.SendRaw = not self.db.mailSettings.Wood.SendRaw end,
          disabled = function() return not self.db.mailSettings.Wood.Send end,          
				},
				{
					type = "checkbox",
					name = "Send refined materials",
					tooltip = "Would send refined materials for woodworking",
					getFunc = function() return self.db.mailSettings.Wood.SendMaterials end,
					setFunc = function() self.db.mailSettings.Wood.SendMaterials = not self.db.mailSettings.Wood.SendMaterials end,
          disabled = function() return not self.db.mailSettings.Wood.Send end,          
				},
				{
					type = "checkbox",
					name = "Send resins",
					tooltip = "Would send resins: Pitch, Turpen etc",
					getFunc = function() return self.db.mailSettings.Wood.SendBoosters end,
					setFunc = function() self.db.mailSettings.Wood.SendBoosters = not self.db.mailSettings.Wood.SendBoosters end,
          disabled = function() return not self.db.mailSettings.Wood.Send end,          
				},
				{
					type = "checkbox",
					name = "Send ornate items",
					tooltip = "Would send gear with the Ornate trait",
					getFunc = function() return self.db.mailSettings.Wood.SendOrnate end,
					setFunc = function() self.db.mailSettings.Wood.SendOrnate = not self.db.mailSettings.Wood.SendOrnate end,
          disabled = function() return not self.db.mailSettings.Wood.Send end,          
				},
				{
					type = "checkbox",
					name = "Send equipment items",
					tooltip = "Would send equipment: staves, bows and shields",
					getFunc = function() return self.db.mailSettings.Wood.SendEquipment end,
					setFunc = function() self.db.mailSettings.Wood.SendOrnate = not self.db.mailSettings.Wood.SendEquipment end,
          disabled = function() return not self.db.mailSettings.Wood.Send end,          
				},
				
				{
					type = "slider",
					name = "Minimum quality to send",
					tooltip = "Minimum quality of equipment to send\n(1 - white, 2 - green, 3 - blue, 4 - purple, 5 - gold)",
					min = 1, 
					max = 5, 
					getFunc = function() return self.db.mailSettings.Wood.MinEquipment end,
					setFunc = function( mini ) self.db.mailSettings.Wood.MinEquipment = mini end,
          disabled = function() return not self.db.mailSettings.Wood.Send end,          
				},
				
				{
					type = "slider",
					name = "Maximum quality to send",
					tooltip = "Maximum quality of equipment to send\n(1 - white, 2 - green, 3 - blue, 4 - purple, 5 - gold)",
					min = 1, 
					max = 5, 
					getFunc = function() return self.db.mailSettings.Wood.MaxEquipment end,
					setFunc = function( mini ) self.db.mailSettings.Wood.MaxEquipment = mini end,
          disabled = function() return not self.db.mailSettings.Wood.Send end,          
				},
				
				{
					type = "slider",
					name = "Min amount of items",
					tooltip = "Min amount of items in one mail",
					min = 1, 
					max = 6, 
					getFunc = function() return self.db.mailSettings.Wood.MinNumber end,
					setFunc = function( mini ) self.db.mailSettings.Wood.MinNumber = mini end,
          disabled = function() return not self.db.mailSettings.Wood.Send end,          
				},

			}, 
			
		}, -- wood submenu end
	-- Mail Cloth settings	
		{
			type = "submenu",
			name = "Cloth/Leather settings",
			tooltip = "",	--(optional)
			controls = {
			
				{
					type = "checkbox",
					name = "Enable Cloth/Leather send",
					tooltip = "Enable Cloth icon in the Mailbox",
					getFunc = function() return self.db.mailSettings.Cloth.Send end,
					setFunc = function() self.db.mailSettings.Cloth.Send = not self.db.mailSettings.Cloth.Send end,
				},
				{
					type = "checkbox",
					name = "Don't send Item savers",
					tooltip = "Wouldn't send items, protected by item savers:\nItem Saver - any marked items\nFCO Item Saver - items, protected from mailing",
					getFunc = function() return self.db.mailSettings.Cloth.KeepISa end,
					setFunc = function() self.db.mailSettings.Cloth.KeepISa = not self.db.mailSettings.Cloth.KeepISa end,
					disabled = function() return not self.db.mailSettings.Cloth.Send end,
				},		
				{
					type = "editbox", 
					name = "Mail recipient",
					tooltip = "Recipient of the cloth/leather mails\nRequired field",
					getFunc = function() return self.db.mailSettings.Cloth.To end,
					setFunc = function(value) self.db.mailSettings.Cloth.To = value end,
          disabled = function() return not self.db.mailSettings.Cloth.Send end,          
				},
				{
					type = "editbox", 
					name = "Mail subject",
					tooltip = "Subject of the mail\nRequired field",
					default = "RETURN cloth",
					getFunc = function() return self.db.mailSettings.Cloth.Subject end,
					setFunc = function(value) self.db.mailSettings.Cloth.Subject = value end,
          disabled = function() return not self.db.mailSettings.Cloth.Send end,          
				},
				{
					type = "checkbox",
					name = "Send raw materials",
					tooltip = "Would send raw materials",
					getFunc = function() return self.db.mailSettings.Cloth.SendRaw end,
					setFunc = function() self.db.mailSettings.Cloth.SendRaw = not self.db.mailSettings.Cloth.SendRaw end,
          disabled = function() return not self.db.mailSettings.Cloth.Send end,
				},	
				
				{
					type = "checkbox",
					name = "Send refined materials",
					tooltip = "Would send refined materials",
					getFunc = function() return self.db.mailSettings.Cloth.SendMaterials end,
					setFunc = function() self.db.mailSettings.Cloth.SendMaterials = not self.db.mailSettings.Cloth.SendMaterials end,
          disabled = function() return not self.db.mailSettings.Cloth.Send end,
				},
				{
					type = "checkbox",
					name = "Send tannins",
					tooltip = "Would send tannins: Hemming, Embroidery etc",
					getFunc = function() return self.db.mailSettings.Cloth.SendBoosters end,
					setFunc = function() self.db.mailSettings.Cloth.SendBoosters = not self.db.mailSettings.Cloth.SendBoosters end,
          disabled = function() return not self.db.mailSettings.Cloth.Send end,
				},
				{
					type = "checkbox",
					name = "Send ornate items",
					tooltip = "Would send gear with the Ornate trait",
					getFunc = function() return self.db.mailSettings.Cloth.SendOrnate end,
					setFunc = function() self.db.mailSettings.Cloth.SendOrnate = not self.db.mailSettings.Cloth.SendOrnate end,
          disabled = function() return not self.db.mailSettings.Cloth.Send end,
				},
				{
					type = "checkbox",
					name = "Send equipment",
					tooltip = "Would send light or medium armor",
					getFunc = function() return self.db.mailSettings.Cloth.SendEquipment end,
					setFunc = function() self.db.mailSettings.Cloth.SendOrnate = not self.db.mailSettings.Cloth.SendEquipment end,
          disabled = function() return not self.db.mailSettings.Cloth.Send end,
				},
				
				{
					type = "slider",
					name = "Minimum quality of items to send",
					tooltip = "Minimum quality of equipment items to send\n(1 - white, 2 - green, 3 - blue, 4 - purple, 5 - gold)",
					min = 1, 
					max = 5, 
					getFunc = function() return self.db.mailSettings.Cloth.MinEquipment end,
					setFunc = function( mini ) self.db.mailSettings.Cloth.MinEquipment = mini end,
          disabled = function() return not self.db.mailSettings.Cloth.Send end,
				},
				
				{
					type = "slider",
					name = "Maxiumum quality of items to send",
					tooltip = "Maximum quality of equipment items to send\n(1 - white, 2 - green, 3 - blue, 4 - purple, 5 - gold)",
					min = 1, 
					max = 5, 
					getFunc = function() return self.db.mailSettings.Cloth.MaxEquipment end,
					setFunc = function( mini ) self.db.mailSettings.Cloth.MaxEquipment = mini end,
          disabled = function() return not self.db.mailSettings.Cloth.Send end,
				},
				
				{
					type = "slider",
					name = "Min amount of items",
					tooltip = "Min amount of items in one mail",
					min = 1, 
					max = 6, 
					getFunc = function() return self.db.mailSettings.Cloth.MinNumber end,
					setFunc = function( mini ) self.db.mailSettings.Cloth.MinNumber = mini end,
          disabled = function() return not self.db.mailSettings.Cloth.Send end,
				},

			}, 
			
		}, -- cloth submenu end
	-- Mail Metal settings	
		{
			type = "submenu",
			name = "Metal settings",
			tooltip = "",	--(optional)
			controls = {
			
				{
					type = "checkbox",
					name = "Enable Blacksmithing send",
					tooltip = "Enable Metal icon in the Mailbox",
					getFunc = function() return self.db.mailSettings.Metal.Send end,
					setFunc = function() self.db.mailSettings.Metal.Send = not self.db.mailSettings.Metal.Send end,
				},
				{
					type = "checkbox",
					name = "Don't send Item savers",
					tooltip = "Wouldn't send items, protected by item savers:\nItem Saver - any marked items\nFCO Item Saver - items, protected from mailing",
					getFunc = function() return self.db.mailSettings.Metal.KeepISa end,
					setFunc = function() self.db.mailSettings.Metal.KeepISa = not self.db.mailSettings.Metal.KeepISa end,
					disabled = function() return not self.db.mailSettings.Metal.Send end,
				},					
				{
					type = "editbox", 
					name = "Mail recipient",
					tooltip = "Recipient of the blacksmithing mails\nRequired field",
					getFunc = function() return self.db.mailSettings.Metal.To end,
					setFunc = function(value) self.db.mailSettings.Metal.To = value end,
          disabled = function() return not self.db.mailSettings.Metal.Send end,
				},
				{
					type = "editbox", 
					name = "Mail subject",
					tooltip = "Subject of the mail\nRequired field",
					default = "RETURN metal",
					getFunc = function() return self.db.mailSettings.Metal.Subject end,
					setFunc = function(value) self.db.mailSettings.Metal.Subject = value end,
          disabled = function() return not self.db.mailSettings.Metal.Send end,
				},
				{
					type = "checkbox",
					name = "Send raw materials",
					tooltip = "Would send raw materials",
					getFunc = function() return self.db.mailSettings.Metal.SendRaw end,
					setFunc = function() self.db.mailSettings.Metal.SendRaw = not self.db.mailSettings.Metal.SendRaw end,
          disabled = function() return not self.db.mailSettings.Metal.Send end,
				},	
				
				{
					type = "checkbox",
					name = "Send refined materials",
					tooltip = "Would send refined materials",
					getFunc = function() return self.db.mailSettings.Metal.SendMaterials end,
					setFunc = function() self.db.mailSettings.Metal.SendMaterials = not self.db.mailSettings.Metal.SendMaterials end,
          disabled = function() return not self.db.mailSettings.Metal.Send end,
				},
				{
					type = "checkbox",
					name = "Send tempers",
					tooltip = "Would send tempers: Honing Stone, Dwarven Oil etc",
					getFunc = function() return self.db.mailSettings.Metal.SendBoosters end,
					setFunc = function() self.db.mailSettings.Metal.SendBoosters = not self.db.mailSettings.Metal.SendBoosters end,
          disabled = function() return not self.db.mailSettings.Metal.Send end,
				},
				{
					type = "checkbox",
					name = "Send ornate items",
					tooltip = "Would send gear with the Ornate trait",
					getFunc = function() return self.db.mailSettings.Metal.SendOrnate end,
					setFunc = function() self.db.mailSettings.Metal.SendOrnate = not self.db.mailSettings.Metal.SendOrnate end,
          disabled = function() return not self.db.mailSettings.Metal.Send end,
				},
				{
					type = "checkbox",
					name = "Send equipment items",
					tooltip = "Would send gear: heavy armor and metallic weapon",
					getFunc = function() return self.db.mailSettings.Metal.SendEquipment end,
					setFunc = function() self.db.mailSettings.Metal.SendOrnate = not self.db.mailSettings.Metal.SendEquipment end,
          disabled = function() return not self.db.mailSettings.Metal.Send end,
				},
				
				{
					type = "slider",
					name = "Minimum quality of items to send",
					tooltip = "Minimum quality of equipment items to send\n(1 - white, 2 - green, 3 - blue, 4 - purple, 5 - gold)",
					min = 1, 
					max = 5, 
					getFunc = function() return self.db.mailSettings.Metal.MinEquipment end,
					setFunc = function( mini ) self.db.mailSettings.Metal.MinEquipment = mini end,
          disabled = function() return not self.db.mailSettings.Metal.Send end,
				},
				{
					type = "slider",
					name = "Maximum quality of items to send",
					tooltip = "Maximum quality of equipment items to send\n(1 - white, 2 - green, 3 - blue, 4 - purple, 5 - gold)",
					min = 1, 
					max = 5, 
					getFunc = function() return self.db.mailSettings.Metal.MaxEquipment end,
					setFunc = function( mini ) self.db.mailSettings.Metal.MaxEquipment = mini end,
          disabled = function() return not self.db.mailSettings.Metal.Send end,
				},
				
				{
					type = "slider",
					name = "Min amount of items",
					tooltip = "Min amount of items in one mail",
					min = 1, 
					max = 6, 
					getFunc = function() return self.db.mailSettings.Metal.MinNumber end,
					setFunc = function( mini ) self.db.mailSettings.Metal.MinNumber = mini end,
          disabled = function() return not self.db.mailSettings.Metal.Send end,
				},

			}, 
			
		}, -- Metal submenu end
	-- Mail Food settings	
		{
			type = "submenu",
			name = "Provisioning settings",
			tooltip = "",	--(optional)
			controls = {
				{
					type = "checkbox",
					name = "Enable Food sending",
					tooltip = "Enable Food send icon in the Mailbox",
					getFunc = function() return self.db.mailSettings.Food.Send end,
					setFunc = function() self.db.mailSettings.Food.Send = not self.db.mailSettings.Food.Send end,
				},
				{
					type = "checkbox",
					name = "Don't send Item savers",
					tooltip = "Wouldn't send items, protected by item savers:\nItem Saver - any marked items\nFCO Item Saver - items, protected from mailing",
					getFunc = function() return self.db.mailSettings.Food.KeepISa end,
					setFunc = function() self.db.mailSettings.Food.KeepISa = not self.db.mailSettings.Food.KeepISa end,
					disabled = function() return not self.db.mailSettings.Food.Send end,
				},				
				{
					type = "editbox", 
					name = "Mail recipient",
					tooltip = "Recipient of provisioning mails\nRequired field",
					getFunc = function() return self.db.mailSettings.Food.To end,
					setFunc = function(value) self.db.mailSettings.Food.To = value end,
					disabled = function() return not self.db.mailSettings.Food.Send end,
				}, 
				{
					type = "editbox", 
					name = "Mail subject",
					tooltip = "Subject of the mail\nRequired field",
					default = "RETURN my food pls",
					getFunc = function() return self.db.mailSettings.Food.Subject end,
					setFunc = function(value) self.db.mailSettings.Food.Subject = value end,
					disabled = function() return not self.db.mailSettings.Food.Send end,
				},
				{
					type = "checkbox",
					name = "Send Ingredients",
					tooltip = "Would send provisioning ingredients",
					getFunc = function() return self.db.mailSettings.Food.SendMaterials end,
					setFunc = function() self.db.mailSettings.Food.SendMaterials = not self.db.mailSettings.Food.SendMaterials end,
					disabled = function() return not self.db.mailSettings.Food.Send end,
				},
				{
					type = "checkbox",
					name = "Send Flavorings",
					tooltip = "Would send provisioning flavorings",
					getFunc = function() return self.db.mailSettings.Food.SendBoosters end,
					setFunc = function() self.db.mailSettings.Food.SendBoosters = not self.db.mailSettings.Food.SendBoosters end,
					disabled = function() return not self.db.mailSettings.Food.Send end,
				},				
				{
					type = "slider",
					name = "Min amount of items",
					tooltip = "Min amount of items in one mail",
					min = 1, 
					max = 6, 
					getFunc = function() return self.db.mailSettings.Food.MinNumber end,
					setFunc = function( mini ) self.db.mailSettings.Food.MinNumber = mini end,
					disabled = function() return not self.db.mailSettings.Food.Send end,
				},

			}, 
			
		}, -- Food submenu end
	-- Mail Alchemy settings	
		{
			type = "submenu",
			name = "Alchemy settings",
			
			controls = {
			
				{
					type = "checkbox",
					name = "Enable Alchemy send",
					tooltip = "Enable Alchemy icon in the Mailbox",
					getFunc = function() return self.db.mailSettings.Alchemy.Send end,
					setFunc = function() self.db.mailSettings.Alchemy.Send = not self.db.mailSettings.Alchemy.Send end,
				},
				{
					type = "editbox", 
					name = "Mail recipient",
					tooltip = "Recipient of the alchemy mails\nRequired field",
					getFunc = function() return self.db.mailSettings.Alchemy.To end,
					setFunc = function(value) self.db.mailSettings.Alchemy.To = value end,
					disabled = function() return not self.db.mailSettings.Alchemy.Send end,
				},
				{
					type = "editbox", 
					name = "Mail subject",
					tooltip = "Subject of the mail\nRequired field",
					default = "RETURN alchemy",
					getFunc = function() return self.db.mailSettings.Alchemy.Subject end,
					setFunc = function(value) self.db.mailSettings.Alchemy.Subject = value end,
					disabled = function() return not self.db.mailSettings.Alchemy.Send end,
				},		
		
				{
					type = "slider",
					name = "Min amount of items",
					tooltip = "Min amount of items in one mail",
					min = 1, 
					max = 6, 
					getFunc = function() return self.db.mailSettings.Alchemy.MinNumber end,
					setFunc = function( mini ) self.db.mailSettings.Alchemy.MinNumber = mini end,
					disabled = function() return not self.db.mailSettings.Alchemy.Send end,
				},

			}, 
			
		}, -- Alchemy submenu end
	-- Mail Jewelry settings	
    {
			type = "submenu",
			name = "Jewelry settings",
			tooltip = "",
			controls = {
			
				{
					type = "checkbox",
					name = "Enable jewelry send",
					tooltip = "Enable Jewelry icon in the Mailbox",
					getFunc = function() return self.db.mailSettings.Jwlr.Send end,
					setFunc = function() self.db.mailSettings.Jwlr.Send = not self.db.mailSettings.Jwlr.Send end,
				},
				{
					type = "checkbox",
					name = "Don't send Item savers",
					tooltip = "Wouldn't send items, protected by item savers:\nItem Saver - any marked items\nFCO Item Saver - items, protected from mailing",
					getFunc = function() return self.db.mailSettings.Jwlr.KeepISa end,
					setFunc = function() self.db.mailSettings.Jwlr.KeepISa = not self.db.mailSettings.Jwlr.KeepISa end,
					disabled = function() return not self.db.mailSettings.Jwlr.Send end,
				},					
				{
					type = "editbox", 
					name = "Mail recipient",
					tooltip = "Recipient of the jewelrycrafting mails\nRequired field",
					getFunc = function() return self.db.mailSettings.Jwlr.To end,
					setFunc = function(value) self.db.mailSettings.Jwlr.To = value end,
          disabled = function() return not self.db.mailSettings.Jwlr.Send end,
				}, 
				{
					type = "editbox", 
					name = "Mail subject",
					tooltip = "Subject of the mail\nRequired field",
					default = "Praise the Telvanni",
					getFunc = function() return self.db.mailSettings.Jwlr.Subject end,
					setFunc = function(value) self.db.mailSettings.Jwlr.Subject = value end,
          disabled = function() return not self.db.mailSettings.Jwlr.Send end,
				},
				{
					type = "checkbox",
					name = "Send raw materials",
					tooltip = "Would send raw materials",
					getFunc = function() return self.db.mailSettings.Jwlr.SendRaw end,
					setFunc = function() self.db.mailSettings.Jwlr.SendRaw = not self.db.mailSettings.Jwlr.SendRaw end,
          disabled = function() return not self.db.mailSettings.Jwlr.Send end,
				},	
				{
					type = "checkbox",
					name = "Send refined materials",
					tooltip = "Would send refined materials",
					getFunc = function() return self.db.mailSettings.Jwlr.SendMaterials end,
					setFunc = function() self.db.mailSettings.Jwlr.SendMaterials = not self.db.mailSettings.Jwlr.SendMaterials end,
          disabled = function() return not self.db.mailSettings.Jwlr.Send end,
				},
				{
					type = "checkbox",
					name = "Send platings",
					tooltip = "Would send platings: Terne, Iridium etc",
					getFunc = function() return self.db.mailSettings.Jwlr.SendBoosters end,
					setFunc = function() self.db.mailSettings.Jwlr.SendBoosters = not self.db.mailSettings.Jwlr.SendBoosters end,
          disabled = function() return not self.db.mailSettings.Jwlr.Send end,
				},
				{
					type = "checkbox",
					name = "Send ornate items",
					tooltip = "Would send jewelry with the Ornate trait",
					getFunc = function() return self.db.mailSettings.Jwlr.SendOrnate end,
					setFunc = function() self.db.mailSettings.Jwlr.SendOrnate = not self.db.mailSettings.Jwlr.SendOrnate end,
          disabled = function() return not self.db.mailSettings.Jwlr.Send end,
				},
				{
					type = "checkbox",
					name = "Send equipment",
					tooltip = "Would send jewelry equipment",
					getFunc = function() return self.db.mailSettings.Jwlr.SendEquipment end,
					setFunc = function() self.db.mailSettings.Jwlr.SendOrnate = not self.db.mailSettings.Jwlr.SendEquipment end,
          disabled = function() return not self.db.mailSettings.Jwlr.Send end,
				},
				
				{
					type = "slider",
					name = "Minimum quality of items to send",
					tooltip = "Minimum quality of equipment items to send\n(1 - white, 2 - green, 3 - blue, 4 - purple, 5 - gold)",
					min = 1, 
					max = 5, 
					getFunc = function() return self.db.mailSettings.Jwlr.MinEquipment end,
					setFunc = function( mini ) self.db.mailSettings.Jwlr.MinEquipment = mini end,
          disabled = function() return not self.db.mailSettings.Jwlr.Send end,
				},
				{
					type = "slider",
					name = "Maximum quality of items to send",
					tooltip = "Maximum quality of equipment items to send\n(1 - white, 2 - green, 3 - blue, 4 - purple, 5 - gold)",
					min = 1, 
					max = 5, 
					getFunc = function() return self.db.mailSettings.Jwlr.MaxEquipment end,
					setFunc = function( mini ) self.db.mailSettings.Jwlr.MaxEquipment = mini end,
          disabled = function() return not self.db.mailSettings.Jwlr.Send end,
				},
				
				{
					type = "slider",
					name = "Min amount of items",
					tooltip = "Min amount of items in one mail",
					min = 1, 
					max = 6, 
					getFunc = function() return self.db.mailSettings.Jwlr.MinNumber end,
					setFunc = function( mini ) self.db.mailSettings.Jwlr.MinNumber = mini end,
          disabled = function() return not self.db.mailSettings.Jwlr.Send end,
				},

			}, 
			
		}, -- Jewelry submenu end

---------- Say thanks here    
		{
			type = "texture",
			image="EsoUI/Art/Miscellaneous/horizontalDivider.dds",
			imageWidth=510,
			imageHeight=4,
		}, 
		{
			type = "submenu",
			name = "If you wish to say Thanks",
			tooltip = "",
			controls = {
				{
					type = "description",
					text = "Thanks for using this addon, boys and girls! I'm just a usual player, as most of you.\nIf you want to say thanks to me and you are playing at the PC EU server, then you can just send me some gold.\nThis is not a must, but it will stimulate me to keep updates up :)",
				},
				{
					type = "button",
					name = "Send 1000 gold",
					func = function()
						QueueMoneyAttachment(1000)
						SendMail("@SilverWF", "Thanks for AAL addon", "This is my thanks for Advanced Autoloot Renewed addon!")
					end,
					width = "half",
					disabled = function() return end,
				},
				{
					type = "button",
					name = "Send custom mail",
					func = function()
						SCENE_MANAGER:Show('mailSend')
						ZO_MailSendToField:SetText('@SilverWF')
						ZO_MailSendSubjectField:SetText('Thanks for AAL addon')
						ZO_MailSendBodyField:SetText('This is my thanks for Advanced Autoloot Renewed addon')
						QueueMoneyAttachment(1000)
						MAIL_SEND:UpdateMoneyAttachment() -- If no update, then money would be attached, but wouldn't showed - 'Send gold' field will be at 0.
						ZO_MailSendBodyField:TakeFocus()
					end,
					width = "half",
					disabled = function() return end,
				}, 
				{
					type = "description",
					text = "TOP DONATORS\nClawzter\nAiMPlAyEr\nDev1Spec\nSephirothC\nThnaks to everyone for your support of this addon!\nYou are awesome, boys and girls!",
				},
			},   
		},

	
	} -- optionsData end
	
	 LAM:RegisterOptionControls("AdvancedAutoLootOptions", optionsData)
			

end        

function AdvancedAutoLootConfig:ToggleAutoLoot()
    self.db.autoLootActivated = not self.db.autoLootActivated
    CBM:FireCallbacks( self.EVENT_TOGGLE_AUTOLOOT )
end
