
Banker.LAM = LibStub("LibAddonMenu-2.0")

Banker.Settings = {
	
	panel = {
		type = "panel",
		name = SI.get(SI.BANKER_NAME),
		author="Nils-Börge Margotti",
		version="1.5",
		slashCommand="/banker",
		registerForRefresh=true,
		registerForDefaults=true
	},
	
	settings = {
		
		[1] = {
			type="header",
			name=SI.get(SI.HEADER_SETTINGS),
		},
		[2] = {
			type="description",
			name=SI.get(SI.DESC_MAIN_TITLE),
			text=SI.get(SI.DESC_MAIN),
		}
	},
	
	init = function()
		
		local s = Banker.Settings
		
		Banker.LAM:RegisterAddonPanel("BankerOptions", s.panel);
	end,
	
	add = function(option)
		
		local s = Banker.Settings
		
		local n = table.getn(s.settings) + 1
		s.settings[n] = option
		
		s.refresh()
	end,
	
	clear = function()
		
		local s = Banker.Settings
		
		s.settings = {
			
			[1] = {
				type="header",
				name=SI.get("HEADER_SETTINGS")
			}
		}
		
		s.refresh()
	end,
	
	refresh = function()
		
		local s = Banker.Settings
		
		Banker.LAM:RegisterOptionControls("BankerOptions", s.settings)
	end
}