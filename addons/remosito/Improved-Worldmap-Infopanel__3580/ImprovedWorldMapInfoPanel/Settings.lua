IWMIP = {}
IWMIP.LAM2 = LibAddonMenu2


IWMIP.unLocked = false

function IWMIP.CreateMenu()
    local panelData = {
        type = "panel",
        name = "Improved WorldMap InfoPanel",
        displayName = "Improved WorldMap InfoPanel",
        author = "remosito",
        version = IWMIP.Version,
        registerForRefresh = true,
    }

    IWMIP.SettingsPanel = IWMIP.LAM2:RegisterAddonPanel("Improved WorldMap InfoPanel", panelData)

    local optionsData = {
        {
            type = "header",
            name = "Position"
        },	
		{
            type = "description",
            text = [[Position of the Worldmap Infopanel 
 - Distance between right edge of panel and the right edge of the screen
   0 is touching right side of screen. -100 is shifted by 100 pixel to the left\n\n
- Vertical distance between top of panel and top of map section -ish\n
   negative is up, postitive is down]]
        },
		{
            type = "slider",
            name = "Horizontal",
			tooltip = "Distance of the right edge of panel from the right edge of the screen",
			min = -800,
			max = 0,
			step = 10,
            getFunc = function() return IWMIP.savedVars.anchorX end,
            setFunc = function(var) IWMIP.savedVars.anchorX = var end,
			width = "half",
        },
		{
            type = "slider",
            name = "Vertical",
			tooltip = "Vertical Position of the Infopanel",
			min = -300,
			max = 300,
			step = 10,
            getFunc = function() return IWMIP.savedVars.anchorY end,
            setFunc = function(var) IWMIP.savedVars.anchorY = var end,
 			width = "half",
        },
        {
            type = "header",
            name = "Size"
        },	
		{
            type = "description",
            text = [[Size of the Worldmap Infopanel

NOTE: Scrollbars disappeared without showing the whole list. Try /reloadui]]
        },
		{
            type = "slider",
            name = "Height",
			tooltip = "Height of the Infopanel",
			min = 600,
			max = 2000,
			step = 10,
            getFunc = function() return IWMIP.savedVars.height end,
            setFunc = function(var) IWMIP.savedVars.height = var end,
  			width = "half",
       },
		{
            type = "slider",
            name = "Infopanel width",
			tooltip = "Width",
			min = 300,
			max = 1000,
			step = 10,
            getFunc = function() return IWMIP.savedVars.width end,
            setFunc = function(var) IWMIP.savedVars.width = var end,
  			width = "half",
        },
        {
            type = "header",
            name = "Density/Row heights"
        },	
		{
            type = "description",
            text = [[Height of each row in the locations and houses lists

Other panels/lists are constructed differently. 
So can't adjust rowheight for those...]]
        },
		{
            type = "slider",
            name = "Locations",
			tooltip = "Height of each locations rows.\n Note: Will not change the font!",
			min = 16,
			max = 32,
			step = 1,
            getFunc = function() return IWMIP.savedVars.locrowheight end,
            setFunc = function(var) IWMIP.savedVars.locrowheight = var end,
   			width = "half",
       },
		{
            type = "slider",
            name = "Houses",
			tooltip = "Height of each houses rows.\n Note: Will not change the font!",
			min = 36,
			max = 84,
			step = 2,
            getFunc = function() return IWMIP.savedVars.houserowheight end,
            setFunc = function(var) IWMIP.savedVars.houserowheight = var end,
   			width = "half",
       },
	}
    IWMIP.LAM2:RegisterOptionControls("Improved WorldMap InfoPanel", optionsData)
end