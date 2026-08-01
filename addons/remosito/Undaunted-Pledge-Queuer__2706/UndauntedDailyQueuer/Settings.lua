function UDQ.CreateMenu()
    local panelData = {
        type = "panel",
        name = "Undaunted Daily Queuer",
        displayName = "Undaunted Daily Queuer",
        author = "remosito",
        version = UDQ.Version,
        registerForRefresh = true,
    }

    UDQ.LAM2:RegisterAddonPanel("Undaunted Daily Queuer", panelData)

    local optionsData = {
        {
            type = "header",
            name = "General Options"
        },	
		{
            type = "description",
            text = "General Options to automatically add/hide certain sets of dungeons"
        },
		{
            type = "checkbox",
            name = "Hide Locked Dungeons",
			tooltip = "Hides not owned DLC dungeons",
            getFunc = function() return UDQ.savedVars.hideLocked end,
            setFunc = function(var) UDQ.savedVars.hideLocked = var UDQ.updateDungeonList() end,
        },		{
            type = "checkbox",
            name = "Add Undaunted Daily Dungeons",
			tooltip = "Adds todays undaunted daily dungeons",
            getFunc = function() return UDQ.savedVars.undauntedDaily end,
            setFunc = function(var) UDQ.savedVars.undauntedDaily = var UDQ.updateDungeonList() end,
        },
		{
            type = "checkbox",
            name = "Add Dungeons with missing Skillpoints",
			tooltip = "Adds Dungeons where current character hasn't done the skillpoing quest yet",
            getFunc = function() return UDQ.savedVars.missingSkillPoints end,
            setFunc = function(var) UDQ.savedVars.missingSkillPoints = var UDQ.updateDungeonList() end,
        },
		{
            type = "checkbox",
            name = "Add incomplete Stickerbook",
			tooltip = "Not implemented yet... :-/",
            getFunc = function() return UDQ.savedVars.incompleteStickerbook end,
            setFunc = function(var) UDQ.savedVars.incompleteStickerbook = var UDQ.updateDungeonList() end,
			disabled = true
        },
		{
            type = "checkbox",
            name = "Add all Dungeons",
			tooltip = "Adds all dungeons",
            getFunc = function() return UDQ.savedVars.allDungeons end,
            setFunc = function(var) UDQ.savedVars.allDungeons = var UDQ.updateDungeonList() end,
        },
        {
            type = "header",
            name = "Additional Dungeons"
        },
        {
            type = "description",
            text = "Select which additional Dungeons to be included"
        },
    }
	for key, dungeon in orderedPairs(UndauntedDaily.DUNGEONS) do
		if UDQ.savedVars.additionalDungeons[dungeon:GetNormalId()] == nil then 
			UDQ.savedVars.additionalDungeons[dungeon:GetNormalId()] = false
		end
		local option = {
            type = "checkbox",
            name = dungeon:GetName(),
            getFunc = function() return UDQ.savedVars.additionalDungeons[dungeon:GetNormalId()] end,
            setFunc = function(var) UDQ.savedVars.additionalDungeons[dungeon:GetNormalId()] = var UDQ.updateDungeonList() end,
        }
		table.insert(optionsData, option)
	end
    UDQ.LAM2:RegisterOptionControls("Undaunted Daily Queuer", optionsData)
end