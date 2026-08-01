local SavedVars 

local function ChatSetupInitialize(eventCode, addOnName)
    if(addOnName == "ChatSetup") then
        SavedVars = ZO_SavedVars:NewAccountWide("ChatSetup_SavedVariables", 1, nil, {ChatSetup={}})
    end
end

local function GetChatCategoryColors()

    local categoryColor = {}

    local c = { GetChatCategoryColor(CHAT_CATEGORY_SAY) }
    categoryColor[ CHAT_CATEGORY_SAY ] = { R=c[1], G=c[2], B=c[3] }

    c = { GetChatCategoryColor(CHAT_CATEGORY_YELL) }
    categoryColor[ CHAT_CATEGORY_YELL ] = { R=c[1], G=c[2], B=c[3] }
    c = { GetChatCategoryColor(CHAT_CATEGORY_WHISPER_INCOMING) }
    categoryColor[ CHAT_CATEGORY_WHISPER_INCOMING ] = { R=c[1], G=c[2], B=c[3] }
    c = { GetChatCategoryColor(CHAT_CATEGORY_WHISPER_OUTGOING) }
    categoryColor[ CHAT_CATEGORY_WHISPER_OUTGOING ] = { R=c[1], G=c[2], B=c[3] }
    c = { GetChatCategoryColor(CHAT_CATEGORY_PARTY) }
    categoryColor[ CHAT_CATEGORY_PARTY ] = { R=c[1], G=c[2], B=c[3] }
    c = { GetChatCategoryColor(CHAT_CATEGORY_ZONE) }
    categoryColor[ CHAT_CATEGORY_ZONE ] = { R=c[1], G=c[2], B=c[3] }
    c = { GetChatCategoryColor(CHAT_CATEGORY_ZONE_ENGLISH) }
    categoryColor[ CHAT_CATEGORY_ZONE_ENGLISH ] = { R=c[1], G=c[2], B=c[3] }
    c = { GetChatCategoryColor(CHAT_CATEGORY_ZONE_FRENCH) }
    categoryColor[ CHAT_CATEGORY_ZONE_FRENCH ] = { R=c[1], G=c[2], B=c[3] }
    c = { GetChatCategoryColor(CHAT_CATEGORY_ZONE_GERMAN) }
    categoryColor[ CHAT_CATEGORY_ZONE_GERMAN ] = { R=c[1], G=c[2], B=c[3] }

    c = { GetChatCategoryColor(CHAT_CATEGORY_MONSTER_EMOTE) }
    categoryColor[ CHAT_CATEGORY_MONSTER_EMOTE ] = { R=c[1], G=c[2], B=c[3] }
    c = { GetChatCategoryColor(CHAT_CATEGORY_MONSTER_SAY) }
    categoryColor[ CHAT_CATEGORY_MONSTER_SAY ] = { R=c[1], G=c[2], B=c[3] }
    c = { GetChatCategoryColor(CHAT_CATEGORY_MONSTER_WHISPER) }
    categoryColor[ CHAT_CATEGORY_MONSTER_WHISPER ] = { R=c[1], G=c[2], B=c[3] }
    c = { GetChatCategoryColor(CHAT_CATEGORY_MONSTER_YELL) }
    categoryColor[ CHAT_CATEGORY_MONSTER_YELL ] = { R=c[1], G=c[2], B=c[3] }
    
    c = { GetChatCategoryColor(CHAT_CATEGORY_EMOTE) }
    categoryColor[ CHAT_CATEGORY_EMOTE ] = { R=c[1], G=c[2], B=c[3] }
    c = { GetChatCategoryColor(CHAT_CATEGORY_SYSTEM) }
    categoryColor[ CHAT_CATEGORY_SYSTEM ] = { R=c[1], G=c[2], B=c[3] }
    
    c = { GetChatCategoryColor(CHAT_CATEGORY_GUILD_1) }
    categoryColor[ CHAT_CATEGORY_GUILD_1 ] = { R=c[1], G=c[2], B=c[3] }
    c = { GetChatCategoryColor(CHAT_CATEGORY_OFFICER_1) }
    categoryColor[ CHAT_CATEGORY_OFFICER_1 ] = { R=c[1], G=c[2], B=c[3] }
    c = { GetChatCategoryColor(CHAT_CATEGORY_GUILD_2) }
    categoryColor[ CHAT_CATEGORY_GUILD_2 ] = { R=c[1], G=c[2], B=c[3] }
    c = { GetChatCategoryColor(CHAT_CATEGORY_OFFICER_2) }
    categoryColor[ CHAT_CATEGORY_OFFICER_2 ] = { R=c[1], G=c[2], B=c[3] }
    c = { GetChatCategoryColor(CHAT_CATEGORY_GUILD_3) }
    categoryColor[ CHAT_CATEGORY_GUILD_3 ] = { R=c[1], G=c[2], B=c[3] }
    c = { GetChatCategoryColor(CHAT_CATEGORY_OFFICER_3) }
    categoryColor[ CHAT_CATEGORY_OFFICER_3 ] = { R=c[1], G=c[2], B=c[3] }
    c = { GetChatCategoryColor(CHAT_CATEGORY_GUILD_4) }
    categoryColor[ CHAT_CATEGORY_GUILD_4 ] = { R=c[1], G=c[2], B=c[3] }
    c = { GetChatCategoryColor(CHAT_CATEGORY_OFFICER_4) }
    categoryColor[ CHAT_CATEGORY_OFFICER_4 ] = { R=c[1], G=c[2], B=c[3] }
    c = { GetChatCategoryColor(CHAT_CATEGORY_GUILD_5) }
    categoryColor[ CHAT_CATEGORY_GUILD_5 ] = { R=c[1], G=c[2], B=c[3] }
    c = { GetChatCategoryColor(CHAT_CATEGORY_OFFICER_5) }
    categoryColor[ CHAT_CATEGORY_OFFICER_5 ] = { R=c[1], G=c[2], B=c[3] }

    return categoryColor

end


local function GetCurrentSetup()
    local numContainers = GetNumChatContainers()
    
    local containers = {}
    
    for container = 1, numContainers do
        local numTabs = GetNumChatContainerTabs(container)
        
        local red, green, blue, minAlpha, maxAlpha = GetChatContainerColors(container)
        
        local chatWindow = CHAT_SYSTEM.containers[container].control
        
        -- Override the chat container colors from the API with the 
        -- actual min/max Alpha values on the main chat window which 
        -- is determined from settings.  
        -- (The system doesn't apply the chat alpha min/max settings to 
        -- chat containers other than the main one.)
        minAlpha = chatWindow.container.minAlpha
        maxAlpha = chatWindow.container.maxAlpha
        
        local height = chatWindow:GetHeight()
        local width = chatWindow:GetWidth()
        
        local positionX = chatWindow:GetLeft()
        local positionY = chatWindow:GetTop()
        
        local tabs = {}
        
        for tab = 1, numTabs do
            local tabName, tabIsLocked, tabIsInteractive, tabIsCombatLog, tabTimestampsEnabled = 
                GetChatContainerTabInfo(container, tab)
            
            local tabCategoryEnabled = {}
            
            for category = CHAT_CATEGORY_SAY, CHAT_CATEGORY_ZONE_GERMAN do
                
                tabCategoryEnabled[ category ] = 
                    IsChatContainerTabCategoryEnabled(container, tab, category)
                    
            end
            
            for category = CHAT_CATEGORY_MONSTER_SAY, CHAT_CATEGORY_MONSTER_EMOTE do
                
                tabCategoryEnabled[ category ] = 
                    IsChatContainerTabCategoryEnabled(container, tab, category)
                    
            end

            tabs[tab] = {Name=tabName, IsLocked=tabIsLocked, IsInteractive=tabIsInteractive, 
                         IsCombatLog=tabIsCombatLog, TimestampsEnabled=tabTimestampsEnabled, 
                         CategoryEnabled=tabCategoryEnabled}
        end


        containers[ container ] = {R=red, G=green, B=blue, MinAlpha=minAlpha, MaxAlpha=maxAlpha, 
                                   X=positionX, Y=positionY, Height=height, Width=width, Tabs=tabs} 
    end
    
    local categoryColors = GetChatCategoryColors()
    
    local fontSize = GetChatFontSize()
   
    return containers, categoryColors, fontSize
end

local function RemoveContainers()
    local numContainers = GetNumChatContainers()
    
    if numContainers == 1 then return end
    
    for container = numContainers, 2, -1 do
        RemoveChatContainer( container ) 
    end

end

local function RemoveTabs()
    local numTabs = GetNumChatContainerTabs(1)
    
    if numTabs == 1 then return end
    
    for i = numTabs, 2, -1 do
        d("Removing tab "..i)
        RemoveChatContainerTab(1, i)
    end

end

local function SaveChatSetup(setupName)
    local containers, categoryColors, fontSize = GetCurrentSetup()
    SavedVars.ChatSetup[string.lower(setupName)] = 
        { Containers=containers, CategoryColors=categoryColors, FontSize=fontSize }
   
    d("SaveChatSetup "..tostring(categoryColors == nil))

    d(string.format("Chat window setup saved as %s.", setupName))
end

local function ApplySetup(containers, categoryColors, fontSize)

    local minAlpha = 0
    local maxAlpha = 1

    for c = 1, #containers do 
        local container = containers[c]
        
        if c > 1 then
            d("Creating container "..c)
            --AddChatContainer() -- This API method does not immediately create the new chat window.
                                 -- So use the method from the CHAT_SYSTEM object instead.
            CHAT_SYSTEM:CreateChatContainer()
        end

        local chatSystemContainer = CHAT_SYSTEM.containers[c]
        local chatWindow = chatSystemContainer.control

        -- None of these methods below worked to make the new window immediately
        -- useable without a ReloadUI().  Any window I create raises an error 
        -- when you interact with it until ReloadUI() is executed.
        -- 
        --chatSystemContainer:Initialize()
        --chatSystemContainer:LoadSettings()
        --chatSystemContainer:LoadWindowSettings()
        --chatSystemContainer:PerformLayout()
        
        -- Always use alpha values from container 1 as these are determined from 
        -- Settings.  Containers are otherwise always 0 min and 1 max which means
        -- they ignore what the user specified in Settings.
        if c == 1 then
            minAlpha = container.MinAlpha
            maxAlpha = container.MaxAlpha
        end
        
        d("Alpha "..minAlpha.." "..maxAlpha)
        SetChatContainerColors(c, container.R, container.G, container.B, minAlpha, maxAlpha)

        -- Window positioning doesn't work but I'm leaving the code here anyway.
        chatWindow:SetSimpleAnchorParent(container.X, container.Y)
        chatWindow:SetDimensions(container.Width, container.Height)
        
        -- None of these methods below worked to get the window 
        -- positioning to work.
        -- 
        -- chatSystemContainer:OnMoveStop()
        -- chatSystemContainer:SaveSettings()
        -- chatSystemContainer:SaveWindowSettings()
        -- chatSystemContainer:ForceWindowIntoView()
        
        for t = 1, #container.Tabs do

            tab = container.Tabs[t]
            
            -- New containers (c > 1) always need tabs created
            -- Container #1 never has its last tab removed, so no need to create tab #1 for it
            if t > 1 or c > 1 then
                d("Creating tab "..t.." for container "..c)
                AddChatContainerTab(c, tab.Name, tab.IsCombatLog)
            end

            d("Setting up tab "..tab.Name)

            SetChatContainerTabInfo(c, t, tab.Name, tab.IsLocked, tab.IsInteractive, tab.TimestampsEnabled)
            
            for category = CHAT_CATEGORY_SAY, CHAT_CATEGORY_ZONE_GERMAN do
                SetChatContainerTabCategoryEnabled(c, t, category, tab.CategoryEnabled[ category ])
            end
            for category = CHAT_CATEGORY_MONSTER_SAY, CHAT_CATEGORY_MONSTER_EMOTE do
                SetChatContainerTabCategoryEnabled(c, t, category, tab.CategoryEnabled[ category ])
            end

        end
        
        d(string.format("Chat %s created at (%s, %s) with size %shx%sw", c, container.X, container.Y, container.Height, container.Width))

    end
    
    for category,color in pairs(categoryColors) do
        SetChatCategoryColor(category, color.R, color.G, color.B)
    end
    
    SetChatFontSize(fontSize)

    d(string.format("Colors and font configured."))

 end

local function LoadChatSetup(setupName)
    local setup = SavedVars.ChatSetup[string.lower(setupName)]
    
    if setup == nil then
        d(string.format("No chat window setup called %s could be found.", setupName))
        return
    end
    
    RemoveContainers()
    
    RemoveTabs()
    
    ApplySetup(setup.Containers, setup.CategoryColors, setup.FontSize)
    
    ReloadUI()
    
    d(string.format("Chat window setup for %s was loaded.", setupName))
end


local function UsageVerbose()
    d("ChatSetup commands:")
    d("/chatsetup save <name>", "- saves the current chat window setup with the given name.")
    d("/chatsetup load <name>", "- loads the chat window setup with the given name.",
      "- WARNING: This will overwrite current chat window setup immediately.")
    d("/chatsetup list", "- lists the chat window setups you have saved.")
    d("/chatsetup remove <name>", "- removes the chat window setup with the given name.")
    d("/chatsetup clear", "- removes all chat window setups you have saved.")
    
end

local function Usage()
    d("ChatSetup commands:")
    d("/chatsetup save <name>")
    d("/chatsetup load <name>")
    d("/chatsetup list")
    d("/chatsetup remove <name>")
    d("/chatsetup clear")
    
end

local function ClearChatSetup()
    SavedVars.ChatSetup = {}
    
    d("All saved chat window setups are now deleted.")
end

local function ListChatSetup()

    local count = ChatSetupUtil.TableLength(SavedVars.ChatSetup)

    if count < 1 then
        d("There are no chat window setups saved.")
        return
    end

    d("Saved Chat Window Setups:")
    for name, setup in pairs(SavedVars.ChatSetup) do 
        d(name)
    end

end

local function RemoveChatSetup(name)

    if SavedVars.ChatSetup[name] ~= nil then
        SavedVars.ChatSetup[name] = nil
        d(string.format("%s was removed from saved setups.", name))
    else
        d(string.format("%s was not present in the list of saved setups.", name))
    end

end

local function ChatSetupCommand(options)

	local command, setupName = ChatSetupUtil.Behead(options)

	if command == "save" then
        if setupName == nil or setupName == "" then
            d("Please specify the name for the setup being saved")
            d("/chatsetup save <name>")
        else
            SaveChatSetup(setupName)
        end
    elseif command == "load" then
        if setupName == nil or setupName == "" then
            d("Please specify the name for the setup being loaded")
            d("/chatsetup load <name>")
        else
            LoadChatSetup(setupName)
        end
    elseif command == "list" then
        ListChatSetup()
    elseif command == "remove" then
        if setupName == nil or setupName == "" then
            d("Please specify the name for the setup being removed")
            d("/chatsetup remove <name>")
        else
            RemoveChatSetup(setupName)
        end
    elseif command == "clear" then
        ClearChatSetup()
    else
        Usage()
    end

end



EVENT_MANAGER:RegisterForEvent("ChatSetup", EVENT_ADD_ON_LOADED, ChatSetupInitialize)

SLASH_COMMANDS["/chatsetup"] = ChatSetupCommand





