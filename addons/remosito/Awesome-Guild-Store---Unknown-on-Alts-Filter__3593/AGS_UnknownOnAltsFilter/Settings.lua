function AGS_UOAF.CreateMenu()

   local panelData = {
        type = "panel",
        name = "AGS_UnknownOnAltsFilter",
        displayName = "AGS_UnknownOnAltsFilter",
        author = "remosito",
        version = AGS_UOAF.Version,
		registerForRefresh = true,
	  }
    AGS_UOAF.LAM2:RegisterAddonPanel("AGS_UnknownOnAltsFilter", panelData)
	
	AGS_UOAF.charnames = {}
	AGS_UOAF.charids = {}
	AGS_UOAF.charid2charnames = {}
	local charlist = LibCharacterKnowledge.GetCharacterList()
	for i = 1,#charlist do
		AGS_UOAF.charnames[i] = charlist[i].name
		AGS_UOAF.charids[i] = charlist[i].id
		AGS_UOAF.charid2charnames[charlist[i].id] = charlist[i].name
		AGS_UOAF.characterorder[charlist[i].id] = i
	end
    local optionsData = {
        {
            type = "header",
            name = "Select Characters to be tracked"
        },	
		{
            type = "description",
            text = [[Select which characters you want to be options in the Awesome Guild Store
			
 List and order of Characters is determined by LCK (LibCharacterknowledge)
 
 Double check settings in CharacterKnowledge_Data if characterlist seems off 
   - Additional Accounts or specific Characters can be in/ex- cluded in LCK
   - The order of characters is determined by Grouping[A-Z] in LCK
   - Your selected characters having lower LCK Groups increases performance
   
   ]]
        },
		{
			type = "dropdown",
			multiSelect = true, 
			name = "Select Characters", 
			tooltip = "This dropdown is multi-select!", 
			multiSelectType = "normal", 
			choices = AGS_UOAF.charnames,
			choicesValues = AGS_UOAF.charids,
			getFunc = function() return AGS_UOAF.savedVars.crafters end,
			setFunc = function(var) AGS_UOAF.savedVars.crafters = var end,
			requiresReload = true,
		},	
	}
    AGS_UOAF.LAM2:RegisterOptionControls("AGS_UnknownOnAltsFilter", optionsData)
end