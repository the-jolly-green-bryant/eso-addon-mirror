if AutoMessage == nil then AutoMessage = {} end
local AM = AutoMessage

function AM.MakeMenu()	

	local panelData = {
    		type = "panel",
    		name = "Auto Message",
    		displayName = "Auto Message",
    		author = "|c6C00FF@peniku8|r",
        version = AM.version,
        website = "https://www.esoui.com/downloads/info2859-AutoMessage.html",
        slashCommand = "/automessage",
        registerForDefaults = true,
	}
	

  local optionsTable = {
  	
	      {
      			type = "description",
      			text = "Note: The message previews require you to reload the UI to update.\n",
        },
        
        {
            type = "checkbox",
            name = "Display Chat Notifications",
            getFunc = function() return AM.settings.chatMessages end,
            setFunc = function(value) AM.settings.chatMessages = value end,
            width = "full",
            default = true,
        },
        
        {
            type = "checkbox",
            name = "Note immunity",
            tooltip = "Ignore members with a note",
            getFunc = function() return AM.settings.note end,
            setFunc = function(value) AM.settings.note = value end,
            width = "full",
            default = false,
        },
        
        {
      			type = "description",
      			text = "You can add dynamic values to the message:\n#GUILD - inserts the name of the guild the recipient is in",
        },
  
        {
      			type = "description",
      			text = "Note: The message previews require you to reload the UI to update.",
        },
        
        {
            type = "editbox",
            name = "Subject",
            tooltip = AM.settings.mail1,
            getFunc = function() return AM.settings.mail1 end,
            setFunc = function(value) AM.settings.mail1 = value end,
            isMultiline = false,
            default = "",
        },
  
        {
            type = "editbox",
            name = "Message text",
            tooltip = AM.settings.mail2,
            getFunc = function() return AM.settings.mail2 end,
            setFunc = function(value) AM.settings.mail2 = value end,
            isMultiline = true,
            default = "",
        },
        
				{
					type = "button",
					name = "Send Mails",
					func = function() AM.process() end,
          width = "full",
				},
  }
  
  
  
  function AM.makeRecipientsMenu()
  	local options = {}
  	
  	table.insert(options,
	    {
          type = "editbox",
          name = "Recipients",
          tooltip = "Valid separators are new line, a comma or nothing at all",
          getFunc = function() return AM.settings.list end,
          setFunc = function(value) AM.settings.list = value end,
          isMultiline = true,
          width = "full",
          default = "",
      }
    )
    
    for i=1, GetNumGuilds() do
    	
    	local guild = i
    	local guildID = GetGuildId(guild)
    	local guildname = GetGuildName(guildID)
    	local ranksMenu = {}
    	
    	table.insert(options,
    	    {
              type = "checkbox",
              name = guildname,
              tooltip = "Enable a guild to send a message to all its members.\nAuto Message will only send one mail to every player, even if they are member of multiple guilds.",
              getFunc = function() return AM.settings.guild[guild] end,
              setFunc = function(value) AM.settings.guild[guild] = value end,
              width = "full",
              default = false,
          }
    	)
    	
    	for i=1, GetNumGuildRanks(guildID) do
    		local rank=i
      	table.insert(ranksMenu,
      	    {
                type = "checkbox",
                name = GetFinalGuildRankName(guildID, rank),
                tooltip = "Disable to prevent players of this rank to recieve the mail",
                getFunc = function() return AM.settings.rank[guild][rank] end,
                setFunc = function(value) AM.settings.rank[guild][rank] = value end,
                width = "full",
                default = true,
            }
      	)    		
    	end
    	
      table.insert(options,
          {
              type = "submenu",
              name = guildname .. " Ranks",
              controls = ranksMenu
          }
      )
    	
    end
    
    return options
  end
  
  
  table.insert(optionsTable,
    {
        type = "submenu",
        name = "Recipients",
        controls = AM.makeRecipientsMenu()
    }
  )
  
  
  local menu = LibAddonMenu2
  menu:RegisterAddonPanel("Auto_Message", panelData)
	menu:RegisterOptionControls("Auto_Message", optionsTable)
	
end