--------------------------------------------------------------------------------
-- LIBRARY IMPORTS
--------------------------------------------------------------------------------
local LAM = LibAddonMenu2
--------------------------------------------------------------------------------
-- FUNCTIONS FOR THE SETTINGS
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- CREATE SETTING MENU WITH LIBADDONMENU
--------------------------------------------------------------------------------

function DSDB.setupSettings()
	local settingName = "Descendants Display Bar"
	local settingData = {
		type = "panel",
		name = "|caeba00Descendants Display Bar|r",
		author = "|caeba00@Sven_re|r",
		-- feedback = "https://github.com/gentlemansr/DescendantsSupportSetTracker/issues",
		registerForDefaults = true,
		slashCommand = "/DSDB"
	}
	
	local menuData = {
		{
			type = "checkbox",
			name = "Lock Window",
			tooltip = "Locks the movement of the window",
			getFunc = function() return  DSDB.locked end,
			setFunc = function(value) 
				DSDB.locked =  value
				DSDB.savedVariables.locked = value
				DSDB.cMainWindow:SetMovable(not value)
				DSDB.cMainWindow:SetMouseEnabled(not value)	
			end,
		},
		{
            type = "button",
            name = "Reset Position",
            tooltip = "Resets the Position to the Center of the Screen",
            width = "half",
            func = function(value)   
				DSDB.cMainWindow:SetAnchor(TOPLEFT, GuiRoot, nil, 300 , 10)
				DSDB.OnIndicatorMoveStop()
			end,
        },
	}	


	DSDB.optionsPanel = LAM:RegisterAddonPanel(settingName, settingData)
	LAM:RegisterOptionControls(settingName, menuData)
end