if Automate == nil then Automate = {} end
local AM = Automate

function AM.MakeMenu()
	
	local guilds = {}
	
	for i = 1, GetNumGuilds() do
		table.insert(guilds, GetGuildName(GetGuildId(i)))
	end
	
  
	local panelData = {
    		type = "panel",
    		name = "Automate",
    		displayName = "Automate",
    		author = "|c6C00FF@peniku8|r",
        version = AM.version,
        slashCommand = "/automate",
        registerForRefresh = true,
        registerForDefaults = true,
        website = "",
	}
	
  
  local optionsTable = {
		
				{
					type = "button",
					name = "Start Automate",
					tooltip = "Check if your sales data is completely updated first!",
					func = function() AM.start() end,
          width = "half",
				},
				
				{
					type = "button",
					name = "Stop Automate",
					func = function() AM.stop() end,
          width = "half",
				},
				
        {
            type = "slider",
            name = "Scan frequency",
            tooltip = "Set an interval in minutes to process your guilds",
            min = 2,
            max = 60,
            step = 1,
            getFunc = function() return AM.settings.interval end,
            setFunc = function(value) AM.settings.interval = value end,
            width = "full",
            default = 5,
        },
        				
  }
  
  
  
  function AM.makeExtraMenu(guild)
  	local extraMenu = {}
  	local altGuilds = {}
  	
  	for i = 1, GetNumGuilds() do
  		if GetGuildName(GetGuildId(i)) ~= GetGuildName(GetGuildId(guild)) then
  		  table.insert(altGuilds, GetGuildName(GetGuildId(i)))
  	  end
  	end
  	
  	  table.insert(extraMenu,
          {
        			type = "description",
        			text = "Note: The message previews require you to reload the UI to update.\n",
          }
      )
      
 	    table.insert(extraMenu,
          {
              type = "checkbox",
              name = "Welcome Mail",
              tooltip = "Send a PM when accepting an application",
              getFunc = function() return AM.settings.welcomeText[guild] end,
              setFunc = function(value) AM.settings.welcomeText[guild] = value end,
              width = "full",
              default = false,
          }
      )
      
      table.insert(extraMenu,
            {
                type = "editbox",
                name = "Subject",
                tooltip = AM.settings.welcomeText1[guild],
                getFunc = function() return AM.settings.welcomeText1[guild] end,
                setFunc = function(value) AM.settings.welcomeText1[guild] = value end,
                isMultiline = false,
                width = "full",
                default = "",
            }
      )
      
      table.insert(extraMenu,
            {
                type = "editbox",
                name = "Message text",
                tooltip = AM.settings.welcomeText2[guild],
                getFunc = function() return AM.settings.welcomeText2[guild] end,
                setFunc = function(value) AM.settings.welcomeText2[guild] = value end,
                isMultiline = true,
                width = "full",
                default = "",
            }
      )
      
 	    table.insert(extraMenu,
          {
              type = "checkbox",
              name = "Guild alternative",
              tooltip = "Invite somebody to a different guild after declining an app.\nAutomate settings (CP requirement) for the other guild will then apply.",
              getFunc = function() return AM.settings.altInvite[guild] end,
              setFunc = function(value) AM.settings.altInvite[guild] = value end,
              width = "full",
              default = false,
          }
      )
      
 	    table.insert(extraMenu,
          {
              type = "dropdown",
              name = "Guild alternative",
              choices = altGuilds,
              getFunc = function() return AM.settings.altGuild[guild] end,
              setFunc = function(value) AM.settings.altGuild[guild] = value end,
              width = "full",
              default = "",
         }
      ) 
      
 	    table.insert(extraMenu,
          {
              type = "checkbox",
              name = "Alternative mail",
              tooltip = "Send a PM when inviting the applicant to a different guild",
              getFunc = function() return AM.settings.altText[guild] end,
              setFunc = function(value) AM.settings.altText[guild] = value end,
              width = "full",
              default = false,
          }
      )
      
      table.insert(extraMenu,
            {
                type = "editbox",
                name = "Subject",
                tooltip = AM.settings.altText1[guild],
                getFunc = function() return AM.settings.altText1[guild] end,
                setFunc = function(value) AM.settings.altText1[guild] = value end,
                isMultiline = false,
                width = "full",
                default = "",
            }
      )
      
      table.insert(extraMenu,
            {
                type = "editbox",
                name = "Message text",
                tooltip = AM.settings.altText2[guild],
                getFunc = function() return AM.settings.altText2[guild] end,
                setFunc = function(value) AM.settings.altText2[guild] = value end,
                isMultiline = true,
                width = "full",
                default = "",
            }
      )
      
      return extraMenu
  	  
  end
  
  
  
  function AM.makeGuildMenu(guild)
  	
    local extraMenu = AM.makeExtraMenu(guild)
    local guildMenu = {}
    
    if AutoRanks then
 	    table.insert(guildMenu,
          {
              type = "checkbox",
              name = "Handle guild ranks",
              tooltip = "Will also process the ranks in this guild, even if it's not enabled in AutoRanks",
              getFunc = function() return AM.settings.ranks[guild] end,
              setFunc = function(value) AM.settings.ranks[guild] = value end,
              width = "full",
              default = false,
          }
      )
    end
    
    if AutoKick then
 	    table.insert(guildMenu,
          {
              type = "checkbox",
              name = "Handle kicking",
              tooltip = "This will not ask twice. Specify options below",
              getFunc = function() return AM.settings.kick[guild] end,
              setFunc = function(value) AM.settings.kick[guild] = value end,
              width = "full",
              default = false,
          }
      )
      
      table.insert(guildMenu,
          {
              type = "slider",
              name = "Kick threshold",
              tooltip = "Only kick when the guild has a certain amount of members",
              min = 450,
              max = 500,
              step = 1,
              getFunc = function() return AM.settings.kickThreshold[guild] end,
              setFunc = function(value) AM.settings.kickThreshold[guild] = value end,
              width = "full",
              default = 499,
          }
      )
      
      table.insert(guildMenu,
          {
              type = "slider",
              name = "Kick amount",
              tooltip = "Set an amount of members to remove whenever the threshold is exceeded",
              min = 1,
              max = 25,
              step = 1,
              getFunc = function() return AM.settings.kickAmount[guild] end,
              setFunc = function(value) AM.settings.kickAmount[guild] = value end,
              width = "full",
              default = 5,
          }
      )
    end
      
 	    table.insert(guildMenu,
          {
              type = "checkbox",
              name = "Handle applicants",
              tooltip = "Automate will stop processing applicants, once there are less than 5 free spots left",
              getFunc = function() return AM.settings.apps[guild] end,
              setFunc = function(value) AM.settings.apps[guild] = value end,
              width = "full",
              default = false,
          }
      )
      
      table.insert(guildMenu,
          {
              type = "slider",
              name = "CP requirement",
              tooltip = "'0' will also accept low-level players",
              min = 0,
              max = 810,
              step = 10,
              getFunc = function() return AM.settings.minCP[guild] end,
              setFunc = function(value) AM.settings.minCP[guild] = value end,
              width = "full",
              default = 0,
          }
      )
      
 	    table.insert(guildMenu,
          {
              type = "checkbox",
              name = "Prefer written",
              tooltip = "Enable this to accept all apps with a written text regardless",
              getFunc = function() return AM.settings.appText[guild] end,
              setFunc = function(value) AM.settings.appText[guild] = value end,
              width = "full",
              default = false,
          }
      )
      
      table.insert(guildMenu,
            {
                type = "editbox",
                name = "Decline Reason",
                tooltip = function() if string.len(AM.settings.declineReason[guild])>0 then return "200 characters max:\n\n" .. AM.settings.declineReason[guild] end end,
                getFunc = function() return AM.settings.declineReason[guild] end,
                setFunc = function(value) AM.settings.declineReason[guild] = value end,
                isMultiline = true,
                default = "",
            }
      )
      
      table.insert(guildMenu,
            {
              type = "submenu",
              name = "Additional Settings",
              controls = extraMenu,
            }
      )
      
    return guildMenu
    
  end
  
  
  
	for i = 1, GetNumGuilds() do
		
		local guildMenu = AM.makeGuildMenu(i)
		
      table.insert(optionsTable,
         		{
        			  type = "header",
        			  name = "|c3a92ff" .. guilds[i],
                width = "full",
            }
      )
      
      table.insert(optionsTable,
            {
                type = "checkbox",
                name = "Process guild",
                tooltip = "Activate Automate for " .. guilds[i],
                getFunc = function() return AM.settings.process[i] end,
                setFunc = function(value) AM.settings.process[i] = value end,
                width = "full",
                default = false,
            }
      )
      
  		table.insert(optionsTable,
            {
              type = "submenu",
              name = "Guild Settings",
              controls = guildMenu,
            }
      )
      
      table.insert(optionsTable, {type = "custom"})
      
  end
  
  
  
  local menu = LibAddonMenu2
  menu:RegisterAddonPanel("Automate", panelData)
	menu:RegisterOptionControls("Automate", optionsTable)
	
end