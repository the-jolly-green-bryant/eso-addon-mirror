if AdBlock == nil then AdBlock = {} end
local AB = AdBlock


function AB.MakeMenu()
  
	local panelData = {
    		type = "panel",
    		name = "AdBlock",
    		displayName = "AdBlock",
    		author = "|c6C00FF@peniku8|r",
        version = AB.version,
        slashCommand = "/adblock",
        registerForRefresh = true,
        registerForDefaults = true,
        website = "https://www.esoui.com/downloads/info2862-AdBlock.html",
	}
  
  
  
  local optionsTable = {
				
        {
            type = "checkbox",
            name = "Lootrun ads",
            tooltip = "Hides text similar to 'Wts lootruns...'",
            getFunc = function() return AB.settings.loot end,
            setFunc = function(value) AB.settings.loot = value end,
            width = "full",
            default = AB.defaults.loot,
        },
				
        {
            type = "checkbox",
            name = "Guild ads",
            tooltip = "Hides all guild ads with a guild linking",
            getFunc = function() return AB.settings.guild end,
            setFunc = function(value) AB.settings.guild = value end,
            width = "full",
            default = AB.defaults.guild,
        },
				
        {
            type = "checkbox",
            name = "Crown traders",
            tooltip = "Hides 'wts/wtb crowns' messages",
            getFunc = function() return AB.settings.crown end,
            setFunc = function(value) AB.settings.crown = value end,
            width = "full",
            default = AB.defaults.crown,
        },
        
        {
            type = "checkbox",
            name = "Item traders",
            tooltip = "Hides 'wts/wtb item xy' messages",
            getFunc = function() return AB.settings.items end,
            setFunc = function(value) AB.settings.items = value end,
            width = "full",
            default = AB.defaults.items,
        },
        
        {
            type = "checkbox",
            name = "Normal Trial searches",
            tooltip = "Hides lfg/lfm messages for normal trials",
            getFunc = function() return AB.settings.nTrial end,
            setFunc = function(value) AB.settings.nTrial = value end,
            width = "full",
            default = AB.defaults.nTrial,
        },
        
        {
            type = "checkbox",
            name = "Veteran Trial searches",
            tooltip = "Hides lfg/lfm messages for veteran trials",
            getFunc = function() return AB.settings.vTrial end,
            setFunc = function(value) AB.settings.vTrial = value end,
            width = "full",
            default = AB.defaults.vTrial,
        },
        
        {
            type = "checkbox",
            name = "Hyperlinks",
            tooltip = "Hides weblinks",
            getFunc = function() return AB.settings.web end,
            setFunc = function(value) AB.settings.web = value end,
            width = "full",
            default = AB.defaults.web,
        },
        
        {type = "custom"},
        
        {
            type = "checkbox",
            name = "Ignore own messages",
            tooltip = "When enabled you will be able to see your own messages, regardless of what you post",
            getFunc = function() return AB.settings.self end,
            setFunc = function(value) AB.settings.self = value end,
            width = "full",
            default = AB.defaults.self,
        },
  }
  
  
  
  local menu = LibAddonMenu2
  menu:RegisterAddonPanel("AdBlock", panelData)
	menu:RegisterOptionControls("AdBlock", optionsTable)
	
end