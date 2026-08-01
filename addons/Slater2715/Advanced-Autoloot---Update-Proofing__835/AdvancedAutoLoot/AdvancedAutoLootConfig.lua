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
		name = "Advanced Autoloot",
	}
	
	LAM:RegisterAddonPanel("AdvancedAutoLootOptions", panelData)
	
	local optionsData = {
	
	-- -- Glyphs	
		{
			type = "submenu",
			name = "Glyphs settings",
			tooltip = "",	--(optional)
			controls = {
			
				{
					type = "checkbox",
					name = "Mail glyphs",
					tooltip = "Should we send glyphs?",
					getFunc = function() return self.db.mailSettings.Glyph.Send end,
					setFunc = function() self.db.mailSettings.Glyph.Send = not self.db.mailSettings.Glyph.Send end,
				},
				{
					type = "editbox", 
					name = "Glyph recipient",
					tooltip = "Person to send the glyphs to",
					getFunc = function() return self.db.mailSettings.Glyph.To end,
					setFunc = function(value) self.db.mailSettings.Glyph.To = value end,
				}, -- todo: autocomplete?
				-- gRecipEdit.autoComplete = ZO_AutoComplete:New(gRecipEdit.edit, AUTO_COMPLETE_FLAG_ALL, AUTO_COMPLETION_ONLINE_OR_OFFLINE, MAX_AUTO_COMPLETION_RESULTS)
				{
					type = "editbox", 
					name = "Glyph topic",
					tooltip = "Subject of the mail",
					default = "Praise the Telvanni",
					getFunc = function() return self.db.mailSettings.Glyph.Subject end,
					setFunc = function(value) self.db.mailSettings.Glyph.Subject = value end,
				},
				{
					type = "checkbox",
					name = "Send runestones",
					tooltip = "Should we send aspect and essence runestones?",
					getFunc = function() return self.db.mailSettings.Glyph.SendMaterials end,
					setFunc = function() self.db.mailSettings.Glyph.SendMaterials = not self.db.mailSettings.Glyph.SendMaterials end,
				},
				{
					type = "checkbox",
					name = "Send potency runestones",
					tooltip = "Should we send potency runestones?",
					getFunc = function() return self.db.mailSettings.Glyph.SendBoosters end,
					setFunc = function() self.db.mailSettings.Glyph.SendBoosters = not self.db.mailSettings.Glyph.SendBoosters end,
				},
				{
					type = "slider",
					name = "Minimum mail items",
					min = 1, 
					max = 6, 
					getFunc = function() return self.db.mailSettings.Glyph.MinNumber end,
					setFunc = function( mini ) self.db.mailSettings.Glyph.MinNumber = mini end,
				},
			
			}, -- controls end
			
		}, -- glyphs submenu end
		
		{
			type = "submenu",
			name = "Wood settings",
			tooltip = "",	--(optional)
			controls = {
			
				{
					type = "checkbox",
					name = "Mail wood",
					tooltip = "Should we send wood?",
					getFunc = function() return self.db.mailSettings.Wood.Send end,
					setFunc = function() self.db.mailSettings.Wood.Send = not self.db.mailSettings.Wood.Send end,
				},
				{
					type = "editbox", 
					name = "Wood recipient",
					tooltip = "Person to send the wood to",
					getFunc = function() return self.db.mailSettings.Wood.To end,
					setFunc = function(value) self.db.mailSettings.Wood.To = value end,
				}, -- todo: autocomplete?
				-- gRecipEdit.autoComplete = ZO_AutoComplete:New(gRecipEdit.edit, AUTO_COMPLETE_FLAG_ALL, AUTO_COMPLETION_ONLINE_OR_OFFLINE, MAX_AUTO_COMPLETION_RESULTS)
				{
					type = "editbox", 
					name = "Wood topic",
					tooltip = "Subject of the mail",
					default = "Praise the Telvanni",
					getFunc = function() return self.db.mailSettings.Wood.Subject end,
					setFunc = function(value) self.db.mailSettings.Wood.Subject = value end,
				},
				{
					type = "checkbox",
					name = "Send raw wood",
					tooltip = "Should we send raw wood?",
					getFunc = function() return self.db.mailSettings.Wood.SendRaw end,
					setFunc = function() self.db.mailSettings.Wood.SendRaw = not self.db.mailSettings.Wood.SendRaw end,
				},
				{
					type = "checkbox",
					name = "Send materials",
					tooltip = "Should we send sanded wood?",
					getFunc = function() return self.db.mailSettings.Wood.SendMaterials end,
					setFunc = function() self.db.mailSettings.Wood.SendMaterials = not self.db.mailSettings.Wood.SendMaterials end,
				},
				{
					type = "checkbox",
					name = "Send tempers",
					tooltip = "Should we send Pitch, Turpen, Mastic..?",
					getFunc = function() return self.db.mailSettings.Wood.SendBoosters end,
					setFunc = function() self.db.mailSettings.Wood.SendBoosters = not self.db.mailSettings.Wood.SendBoosters end,
				},
				
				{
					type = "checkbox",
					name = "Send white items",
					tooltip = "Should we send white items?",
					getFunc = function() return self.db.mailSettings.Wood.SendWhite end,
					setFunc = function() self.db.mailSettings.Wood.SendWhite = not self.db.mailSettings.Wood.SendWhite end,
				},
				
				{
					type = "checkbox",
					name = "Send ornate items",
					tooltip = "Should we send ornate items?",
					getFunc = function() return self.db.mailSettings.Wood.SendOrnate end,
					setFunc = function() self.db.mailSettings.Wood.SendOrnate = not self.db.mailSettings.Wood.SendOrnate end,
				},
				{
					type = "checkbox",
					name = "Send equipment items",
					tooltip = "Should we send equipment items?",
					getFunc = function() return self.db.mailSettings.Wood.SendEquipment end,
					setFunc = function() self.db.mailSettings.Wood.SendOrnate = not self.db.mailSettings.Wood.SendEquipment end,
				},
				
				{
					type = "slider",
					name = "Minimum quality of items to send",
					tooltip = "Minimum quality of equipment items to send (1=white,5=legendary)",
					min = 1, 
					max = 5, 
					getFunc = function() return self.db.mailSettings.Wood.MinEquipment end,
					setFunc = function( mini ) self.db.mailSettings.Wood.MinEquipment = mini end,
				},
				
				{
					type = "slider",
					name = "Maxiumum quality of items to send",
					tooltip = "Maximum quality of equipment items to send (1=white,5=legendary)",
					min = 1, 
					max = 5, 
					getFunc = function() return self.db.mailSettings.Wood.MaxEquipment end,
					setFunc = function( mini ) self.db.mailSettings.Wood.MaxEquipment = mini end,
				},
				
				{
					type = "slider",
					name = "Minimum mail items",
					min = 1, 
					max = 6, 
					getFunc = function() return self.db.mailSettings.Wood.MinNumber end,
					setFunc = function( mini ) self.db.mailSettings.Wood.MinNumber = mini end,
				},

			}, 
			
		}, -- wood submenu end
		
		{
			type = "submenu",
			name = "Cloth/Leather settings",
			tooltip = "",	--(optional)
			controls = {
			
				{
					type = "checkbox",
					name = "Mail cloth/leather",
					tooltip = "Should we send cloth/leather?",
					getFunc = function() return self.db.mailSettings.Cloth.Send end,
					setFunc = function() self.db.mailSettings.Cloth.Send = not self.db.mailSettings.Cloth.Send end,
				},
				{
					type = "editbox", 
					name = "Cloth recipient",
					tooltip = "Person to send the cloth/leather to",
					getFunc = function() return self.db.mailSettings.Cloth.To end,
					setFunc = function(value) self.db.mailSettings.Cloth.To = value end,
				}, -- todo: autocomplete?
				-- gRecipEdit.autoComplete = ZO_AutoComplete:New(gRecipEdit.edit, AUTO_COMPLETE_FLAG_ALL, AUTO_COMPLETION_ONLINE_OR_OFFLINE, MAX_AUTO_COMPLETION_RESULTS)
				{
					type = "editbox", 
					name = "Cloth/Leather topic",
					tooltip = "Subject of the mail",
					default = "Praise the Telvanni",
					getFunc = function() return self.db.mailSettings.Cloth.Subject end,
					setFunc = function(value) self.db.mailSettings.Cloth.Subject = value end,
				},
				{
					type = "checkbox",
					name = "Send raw materials",
					tooltip = "Should we send unrefined cloth and leather scraps?",
					getFunc = function() return self.db.mailSettings.Cloth.SendRaw end,
					setFunc = function() self.db.mailSettings.Cloth.SendRaw = not self.db.mailSettings.Cloth.SendRaw end,
				},	
				
				{
					type = "checkbox",
					name = "Send materials",
					tooltip = "Should we send hide and refined cloth?",
					getFunc = function() return self.db.mailSettings.Cloth.SendMaterials end,
					setFunc = function() self.db.mailSettings.Cloth.SendMaterials = not self.db.mailSettings.Cloth.SendMaterials end,
				},
				{
					type = "checkbox",
					name = "Send tempers",
					tooltip = "Should we send Hemming, Embroidery, Elegant Lining..?",
					getFunc = function() return self.db.mailSettings.Cloth.SendBoosters end,
					setFunc = function() self.db.mailSettings.Cloth.SendBoosters = not self.db.mailSettings.Cloth.SendBoosters end,
				},
				
				{
					type = "checkbox",
					name = "Send white items",
					tooltip = "Should we send white items?",
					getFunc = function() return self.db.mailSettings.Cloth.SendWhite end,
					setFunc = function() self.db.mailSettings.Cloth.SendWhite = not self.db.mailSettings.Cloth.SendWhite end,
				},
				
				{
					type = "checkbox",
					name = "Send ornate items",
					tooltip = "Should we send ornate items?",
					getFunc = function() return self.db.mailSettings.Cloth.SendOrnate end,
					setFunc = function() self.db.mailSettings.Cloth.SendOrnate = not self.db.mailSettings.Cloth.SendOrnate end,
				},
				{
					type = "checkbox",
					name = "Send equipment items",
					tooltip = "Should we send equipment items?",
					getFunc = function() return self.db.mailSettings.Cloth.SendEquipment end,
					setFunc = function() self.db.mailSettings.Cloth.SendOrnate = not self.db.mailSettings.Cloth.SendEquipment end,
				},
				
				{
					type = "slider",
					name = "Minimum quality of items to send",
					tooltip = "Minimum quality of equipment items to send (1=white,5=legendary)",
					min = 1, 
					max = 5, 
					getFunc = function() return self.db.mailSettings.Cloth.MinEquipment end,
					setFunc = function( mini ) self.db.mailSettings.Cloth.MinEquipment = mini end,
				},
				
				{
					type = "slider",
					name = "Maxiumum quality of items to send",
					tooltip = "Maximum quality of equipment items to send (1=white,5=legendary)",
					min = 1, 
					max = 5, 
					getFunc = function() return self.db.mailSettings.Cloth.MaxEquipment end,
					setFunc = function( mini ) self.db.mailSettings.Cloth.MaxEquipment = mini end,
				},
				
				{
					type = "slider",
					name = "Minimum mail items",
					min = 1, 
					max = 6, 
					getFunc = function() return self.db.mailSettings.Cloth.MinNumber end,
					setFunc = function( mini ) self.db.mailSettings.Cloth.MinNumber = mini end,
				},

			}, 
			
		}, -- cloth submenu end
		
		{
			type = "submenu",
			name = "Metal settings",
			tooltip = "",	--(optional)
			controls = {
			
				{
					type = "checkbox",
					name = "Mail metal",
					tooltip = "Should we send metal?",
					getFunc = function() return self.db.mailSettings.Metal.Send end,
					setFunc = function() self.db.mailSettings.Metal.Send = not self.db.mailSettings.Metal.Send end,
				},
				{
					type = "editbox", 
					name = "Metal recipient",
					tooltip = "Person to send the metal to",
					getFunc = function() return self.db.mailSettings.Metal.To end,
					setFunc = function(value) self.db.mailSettings.Metal.To = value end,
				}, -- todo: autocomplete?
				-- gRecipEdit.autoComplete = ZO_AutoComplete:New(gRecipEdit.edit, AUTO_COMPLETE_FLAG_ALL, AUTO_COMPLETION_ONLINE_OR_OFFLINE, MAX_AUTO_COMPLETION_RESULTS)
				{
					type = "editbox", 
					name = "Metal topic",
					tooltip = "Subject of the mail",
					default = "Praise the Telvanni",
					getFunc = function() return self.db.mailSettings.Metal.Subject end,
					setFunc = function(value) self.db.mailSettings.Metal.Subject = value end,
				},
				{
					type = "checkbox",
					name = "Send raw materials",
					tooltip = "Should we send raw ore?",
					getFunc = function() return self.db.mailSettings.Metal.SendRaw end,
					setFunc = function() self.db.mailSettings.Metal.SendRaw = not self.db.mailSettings.Metal.SendRaw end,
				},	
				
				{
					type = "checkbox",
					name = "Send materials",
					tooltip = "Should we send ingots?",
					getFunc = function() return self.db.mailSettings.Metal.SendMaterials end,
					setFunc = function() self.db.mailSettings.Metal.SendMaterials = not self.db.mailSettings.Metal.SendMaterials end,
				},
				{
					type = "checkbox",
					name = "Send tempers",
					tooltip = "Should we send Honing Stone, Dwarven Oil, Grain Solvent..?",
					getFunc = function() return self.db.mailSettings.Metal.SendBoosters end,
					setFunc = function() self.db.mailSettings.Metal.SendBoosters = not self.db.mailSettings.Metal.SendBoosters end,
				},
				
				{
					type = "checkbox",
					name = "Send white items",
					tooltip = "Should we send white items?",
					getFunc = function() return self.db.mailSettings.Metal.SendWhite end,
					setFunc = function() self.db.mailSettings.Metal.SendWhite = not self.db.mailSettings.Metal.SendWhite end,
				},
				
				{
					type = "checkbox",
					name = "Send ornate items",
					tooltip = "Should we send ornate items?",
					getFunc = function() return self.db.mailSettings.Metal.SendOrnate end,
					setFunc = function() self.db.mailSettings.Metal.SendOrnate = not self.db.mailSettings.Metal.SendOrnate end,
				},
				{
					type = "checkbox",
					name = "Send equipment items",
					tooltip = "Should we send equipment items?",
					getFunc = function() return self.db.mailSettings.Metal.SendEquipment end,
					setFunc = function() self.db.mailSettings.Metal.SendOrnate = not self.db.mailSettings.Metal.SendEquipment end,
				},
				
				{
					type = "slider",
					name = "Minimum quality of items to send",
					tooltip = "Minimum quality of equipment items to send (1=white,5=legendary)",
					min = 1, 
					max = 5, 
					getFunc = function() return self.db.mailSettings.Metal.MinEquipment end,
					setFunc = function( mini ) self.db.mailSettings.Metal.MinEquipment = mini end,
				},
				{
					type = "slider",
					name = "Maxiumum quality of items to send",
					tooltip = "Maximum quality of equipment items to send (1=white,5=legendary)",
					min = 1, 
					max = 5, 
					getFunc = function() return self.db.mailSettings.Metal.MaxEquipment end,
					setFunc = function( mini ) self.db.mailSettings.Metal.MaxEquipment = mini end,
				},
				
				{
					type = "slider",
					name = "Minimum mail items",
					min = 1, 
					max = 6, 
					getFunc = function() return self.db.mailSettings.Metal.MinNumber end,
					setFunc = function( mini ) self.db.mailSettings.Metal.MinNumber = mini end,
				},

			}, 
			
		}, -- Metal submenu end
		
		
		{
			type = "submenu",
			name = "Provisioning settings",
			tooltip = "",	--(optional)
			controls = {
			
				{
					type = "checkbox",
					name = "Mail ingredients",
					tooltip = "Should we send provisioning ingredients?",
					getFunc = function() return self.db.mailSettings.Food.Send end,
					setFunc = function() self.db.mailSettings.Food.Send = not self.db.mailSettings.Food.Send end,
				},
				{
					type = "editbox", 
					name = "Ingredients recipient",
					tooltip = "Person to send the ingredients to",
					getFunc = function() return self.db.mailSettings.Food.To end,
					setFunc = function(value) self.db.mailSettings.Food.To = value end,
				}, -- todo: autocomplete?
				-- gRecipEdit.autoComplete = ZO_AutoComplete:New(gRecipEdit.edit, AUTO_COMPLETE_FLAG_ALL, AUTO_COMPLETION_ONLINE_OR_OFFLINE, MAX_AUTO_COMPLETION_RESULTS)
				{
					type = "editbox", 
					name = "Food topic",
					tooltip = "Subject of the mail",
					default = "Praise the Telvanni",
					getFunc = function() return self.db.mailSettings.Food.Subject end,
					setFunc = function(value) self.db.mailSettings.Food.Subject = value end,
				},
				{
					type = "checkbox",
					name = "Send recipes",
					tooltip = "Should we send provisioning recipes?",
					getFunc = function() return self.db.mailSettings.Food.SendRecipes end,
					setFunc = function() self.db.mailSettings.Food.SendRecipes = not self.db.mailSettings.Food.SendRecipes end,
				},	
				
		
				{
					type = "slider",
					name = "Minimum mail items",
					min = 1, 
					max = 6, 
					getFunc = function() return self.db.mailSettings.Food.MinNumber end,
					setFunc = function( mini ) self.db.mailSettings.Food.MinNumber = mini end,
				},

			}, 
			
		}, -- Food submenu end
		
		{
			type = "submenu",
			name = "Alchemy settings",
			
			controls = {
			
				{
					type = "checkbox",
					name = "Mail herbs",
					tooltip = "Should we send herbs?",
					getFunc = function() return self.db.mailSettings.Alchemy.Send end,
					setFunc = function() self.db.mailSettings.Alchemy.Send = not self.db.mailSettings.Alchemy.Send end,
				},
				{
					type = "editbox", 
					name = "Herbs recipient",
					tooltip = "Person to send the herbs to",
					getFunc = function() return self.db.mailSettings.Alchemy.To end,
					setFunc = function(value) self.db.mailSettings.Alchemy.To = value end,
				}, -- todo: autocomplete?
				-- gRecipEdit.autoComplete = ZO_AutoComplete:New(gRecipEdit.edit, AUTO_COMPLETE_FLAG_ALL, AUTO_COMPLETION_ONLINE_OR_OFFLINE, MAX_AUTO_COMPLETION_RESULTS)
				{
					type = "editbox", 
					name = "Herb topic",
					tooltip = "Subject of the mail",
					default = "Praise the Telvanni",
					getFunc = function() return self.db.mailSettings.Alchemy.Subject end,
					setFunc = function(value) self.db.mailSettings.Alchemy.Subject = value end,
				},		
		
				{
					type = "slider",
					name = "Minimum mail items",
					min = 1, 
					max = 6, 
					getFunc = function() return self.db.mailSettings.Alchemy.MinNumber end,
					setFunc = function( mini ) self.db.mailSettings.Alchemy.MinNumber = mini end,
				},

			}, 
			
		}, -- Metal submenu end
	
	} -- optionsData end
	
	 LAM:RegisterOptionControls("AdvancedAutoLootOptions", optionsData)
			

end

function AdvancedAutoLootConfig:ToggleAutoLoot()
    self.db.autoLootActivated = not self.db.autoLootActivated
    CBM:FireCallbacks( self.EVENT_TOGGLE_AUTOLOOT )
end
