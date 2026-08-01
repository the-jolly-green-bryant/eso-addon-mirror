function ChatHotKeys.CreateChatConfigMenu()

    local panelData = {
        type = "panel",
        name = "ChatHotKeys",
        displayName = "|c8080FFChat HotKeys|r",
        author = "Gitright",
        version = tostring(ChatHotKeys.version),
    }

    local optionsData = {
        {
            type = "header",
            name = "Chat Text Settings (i.e. /g hello.../z Join My Guild)",
        },
		{
			type = "editbox",
			name = "Chat Text 1",
			getFunc = function() return ChatHotKeys.settings.chattxt[1] end,
			setFunc = function(value) ChatHotKeys.settings.chattxt[1] = value end		
		},
		{
			type = "editbox",
			name = "Chat Text 2",
			getFunc = function() return ChatHotKeys.settings.chattxt[2] end,
			setFunc = function(value) ChatHotKeys.settings.chattxt[2] = value end		
		},
		{
			type = "editbox",
			name = "Chat Text 3",
			getFunc = function() return ChatHotKeys.settings.chattxt[3] end,
			setFunc = function(value) ChatHotKeys.settings.chattxt[3] = value end		
		},
		{
			type = "editbox",
			name = "Chat Text 4",
			getFunc = function() return ChatHotKeys.settings.chattxt[4] end,
			setFunc = function(value) ChatHotKeys.settings.chattxt[4] = value end		
		},
		{
			type = "editbox",
			name = "Chat Text 5",
			getFunc = function() return ChatHotKeys.settings.chattxt[5] end,
			setFunc = function(value) ChatHotKeys.settings.chattxt[5] = value end		
		},
		{
			type = "editbox",
			name = "Chat Text 6",
			getFunc = function() return ChatHotKeys.settings.chattxt[6] end,
			setFunc = function(value) ChatHotKeys.settings.chattxt[6] = value end		
		},
		{
			type = "editbox",
			name = "Chat Text 7",
			getFunc = function() return ChatHotKeys.settings.chattxt[7] end,
			setFunc = function(value) ChatHotKeys.settings.chattxt[7] = value end		
		},
		{
			type = "editbox",
			name = "Chat Text 8",
			getFunc = function() return ChatHotKeys.settings.chattxt[8] end,
			setFunc = function(value) ChatHotKeys.settings.chattxt[8] = value end		
		},
		{
			type = "editbox",
			name = "Chat Text 9",
			getFunc = function() return ChatHotKeys.settings.chattxt[9] end,
			setFunc = function(value) ChatHotKeys.settings.chattxt[9] = value end		
		},
		{
			type = "editbox",
			name = "Chat Text 10",
			getFunc = function() return ChatHotKeys.settings.chattxt[10] end,
			setFunc = function(value) ChatHotKeys.settings.chattxt[10] = value end		
		},		
    }

    local LAM2 = LibStub("LibAddonMenu-2.0")
    LAM2:RegisterAddonPanel(ChatHotKeys.name.."Config", panelData)
    LAM2:RegisterOptionControls(ChatHotKeys.name.."Config", optionsData)	
end