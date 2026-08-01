Sol_Guild_Hall = {}
Sol_Guild_Hall.name = "Sol_Guild_Hall"

local savedVariables


local function ShowButton(but)
    --button2:SetHidden(false)
    --Sol_Guild_Hall_house_Sol:SetHidden(false)
    --savedVariables.visible = true
    if(but == "home") then 
        Sol_Guild_Hall_house:SetHidden(false)
        savedVariables.HouseVisible = true
    elseif(but == "sol") then 
        Sol_Guild_Hall_house_Sol:SetHidden(false)
        savedVariables.SolVisible = true
    elseif(but == "reload") then 
        Sol_Guild_Hall_ReloadUI:SetHidden(false)
        savedVariables.ReloadUIVisible = true
    end
 end
 
 local function HideButton(but)
    --Sol_Guild_Hall_house_Sol:SetHidden(true)
    --savedVariables.visible = false
    if(but == "home") then 
        Sol_Guild_Hall_house:SetHidden(true)
        savedVariables.HouseVisible = false
    elseif(but == "sol") then 
        Sol_Guild_Hall_house_Sol:SetHidden(true)
        savedVariables.SolVisible = false
    elseif(but == "reload") then 
        Sol_Guild_Hall_ReloadUI:SetHidden(true)
        savedVariables.ReloadUIVisible = false
    end
 end


 local function setVisibility(v, tp)
    if(v == true) then
        if(tp == "home") then ShowButton("home")
        elseif(tp == "sol") then ShowButton("sol")
        elseif(tp == "reload") then ShowButton("reload")
        end        
    else
        if(tp == "home") then HideButton("home")
        elseif(tp == "sol") then HideButton("sol")
        elseif(tp == "reload") then HideButton("reload")
        end   
    end
 end
 
 local function getVisibility(str)
    --return savedVariables.visible
    if(str == "home") then return savedVariables.HouseVisible
    elseif(str == "sol") then return savedVariables.SolVisible
    elseif(str == "reload") then return savedVariables.ReloadUIVisible
    end 
 end
 

local function initializeSolGuildHallAddon()

    setVisibility(savedVariables.HouseVisible, "home")
    setVisibility(savedVariables.SolVisible, "sol")
    setVisibility(savedVariables.ReloadUIVisible, "reload")

    local LAM = LibAddonMenu2
    local panelName = "SolGuildHallOptions"

    local panelData = {
        type = "panel",
        name = "Sol Guild Hall",
        author = "@Marvell0usChester",
     }

     local optionsData = {
        [1] = {
            type = "checkbox",
            name = "Телепорт в дом",
            tooltip = "Показывать кнопку телепорта в свой выбранный дом",
            getFunc = function() return getVisibility("home") end,
            setFunc = function(value) setVisibility(value, "home") end
            },
      --  [2] = {
      --      type = "dropdown",
      --      name = "Название дома",
      --      choices = {
      --      "дом 1",
      --      "дом 2",
      --      "дом 3"
      --      },
      --      getFunc = function() return end,
      --      setFunc = function(value) end,
      --      },
        [2] = {
            type = "checkbox",
            name = "Телепорт в гх @Sol.Phoenix",
            tooltip = "Показывать кнопку телепорта в дом к @Sol.Phoenix",
            getFunc = function() return getVisibility("sol") end,
            setFunc = function(value) setVisibility(value, "sol") end
            },
        [3] = {
            type = "checkbox",
            name = "Кнопка ReloadUI",
            tooltip = "Показывать кнопку ReloadUI",
            getFunc = function() return getVisibility("reload") end,
            setFunc = function(value) setVisibility(value, "reload") end
            }
     }
     local panel = LAM:RegisterAddonPanel(panelName, panelData)
     LAM:RegisterOptionControls(panelName, optionsData)


end

function Sol_Guild_Hall.OnAddOnLoaded(eventCode, addOnName)

	if (addOnName ~= "Sol_Guild_Hall") then return end
    EVENT_MANAGER:UnregisterForEvent("Sol_Guild_Hall", EVENT_ADD_ON_LOADED)

    local id_player = GetDisplayName()

    local label1 = WINDOW_MANAGER:CreateControl("label", ZO_ChatWindow, CT_LABEL)
    label1:SetAnchor(CENTER, ZO_ChatWindowNotifications, CENTER, 40 )

    --кнопка 1 тп в свой дом
    Sol_Guild_Hall_house:SetParent(ZO_ChatWindow)
    Sol_Guild_Hall_house:SetAnchor(RIGHT, label1, RIGHT, 25)
    --кнопка 2 тп к @Sol.Phoenix
    Sol_Guild_Hall_house_Sol:SetParent(ZO_ChatWindow)
    Sol_Guild_Hall_house_Sol:SetAnchor(CENTER, label1, CENTER, 40)
    --кнопка 3 ReloadUI
    Sol_Guild_Hall_ReloadUI:SetParent(ZO_ChatWindow)
    Sol_Guild_Hall_ReloadUI:SetAnchor(LEFT, label1, LEFT, 55)

    --кнопка 1 тп в свой дом
-- 	local button1 =  WINDOW_MANAGER:CreateControl("Sol_Guild_Hall1", ZO_ChatWindow, CT_BUTTON)
--    button1:SetDimensions(20, 20)
    --button1:SetAnchor(TOPLEFT, ZO_ChatWindowNotifications, TOPRIGHT, 50, 5)
    --button1:SetAnchor(RIGHT, ZO_ChatWindowNotifications, RIGHT, 0, 0)
--    button1:SetAnchor(RIGHT, label1, RIGHT)
    -- Ниже тултипы
--    button1:SetHandler("OnMouseEnter", function(control) InitializeTooltip(InformationTooltip, control) SetTooltipText(InformationTooltip, "Sol_Guild_Hall") end)
--    button1:SetHandler("OnMouseExit", function(control) ClearTooltip(InformationTooltip) end)
    -- Конец тултипов
-- 	button1:SetNormalTexture("Sol_Guild_Hall/imgs/covOver.dds")

    --кнопка 2 тп к @Sol.Phoenix
--    local button2 =  WINDOW_MANAGER:CreateControl("Sol_Guild_Hall2", ZO_ChatWindow, CT_BUTTON)
--    button2:SetDimensions(20, 20)
    --button2:SetAnchor(TOPLEFT, ZO_ChatWindowNotifications, TOPRIGHT, 85, 5)
--    button2:SetAnchor(CENTER, label1, CENTER, 10)
    -- Ниже тултипы
--    button2:SetHandler("OnMouseEnter", function(control) InitializeTooltip(InformationTooltip, control) SetTooltipText(InformationTooltip, "Sol_Guild_Hall") end)
--    button2:SetHandler("OnMouseExit", function(control) ClearTooltip(InformationTooltip) end)
    -- Конец тултипов
--	button2:SetNormalTexture("Sol_Guild_Hall/imgs/SolPhoenix.dds")
	
    --кнопка 3 ReloadUI
--    local button3 =  WINDOW_MANAGER:CreateControl("Sol_Guild_Hall3", ZO_ChatWindow, CT_BUTTON)
--    button3:SetDimensions(20, 20)
    --button3:SetAnchor(TOPLEFT, ZO_ChatWindowNotifications, TOPRIGHT, 105, 5)
--    button3:SetAnchor(LEFT, label1, LEFT, 20)
    -- Ниже тултипы
--    button3:SetHandler("OnMouseEnter", function(control) InitializeTooltip(InformationTooltip, control) SetTooltipText(InformationTooltip, "Reload UI") end)
--    button3:SetHandler("OnMouseExit", function(control) ClearTooltip(InformationTooltip) end)
    -- Конец тултипов
--    button3:SetNormalTexture("Sol_Guild_Hall/imgs/reload.dds")


--обработчики событий 

--	button1:SetHandler("OnClicked", function(...)
--		RequestJumpToHouse(39)
--	end)
Sol_Guild_Hall_house:SetHandler("OnMouseEnter", function(control) 
    InitializeTooltip(InformationTooltip, control) 
    SetTooltipText(InformationTooltip, "House") 
end)
Sol_Guild_Hall_house:SetHandler("OnMouseExit", function(control) 
    ClearTooltip(InformationTooltip)
end)
Sol_Guild_Hall_house:SetHandler("OnClicked", function(...)
    RequestJumpToHouse(GetHousingPrimaryHouse())
end)
--    button2:SetHandler("OnClicked", function(...)
		--JumpToHouse("@Sol.Phoenix", 40)
--        JumpToHouse("@Sol.Phoenix")
--	end)
Sol_Guild_Hall_house_Sol:SetHandler("OnMouseEnter", function(control) 
    InitializeTooltip(InformationTooltip, control) 
    SetTooltipText(InformationTooltip, "@Sol.Phoenix") 
end)
Sol_Guild_Hall_house_Sol:SetHandler("OnMouseExit", function(control) 
    ClearTooltip(InformationTooltip)
end)
Sol_Guild_Hall_house_Sol:SetHandler("OnClicked", function(...)
    if(id_player == "@Sol.Phoenix") then
        RequestJumpToHouse(GetHousingPrimaryHouse())
    else
        JumpToHouse("@Sol.Phoenix")
    end   
end)
--    button3:SetHandler("OnClicked", function(...)
--		ReloadUI("ingame")
--    end)
Sol_Guild_Hall_ReloadUI:SetHandler("OnMouseEnter", function(control) 
    InitializeTooltip(InformationTooltip, control) 
    SetTooltipText(InformationTooltip, "Reload UI") 
end)
Sol_Guild_Hall_ReloadUI:SetHandler("OnMouseExit", function(control) 
    ClearTooltip(InformationTooltip)
end)
Sol_Guild_Hall_ReloadUI:SetHandler("OnClicked", function(...)
    ReloadUI("ingame")
end)

    local defaults = {
        HouseVisible  = true,
        SolVisible  = true,
        ReloadUIVisible  = true,
    }

    savedVariables = ZO_SavedVars:NewAccountWide('SolGuildHallVars', 3, nil, defaults)
    
    initializeSolGuildHallAddon()

    SLASH_COMMANDS["/rl"] = function(...) ReloadUI("ingame") end
	
end

EVENT_MANAGER:RegisterForEvent(Sol_Guild_Hall.name, EVENT_ADD_ON_LOADED, Sol_Guild_Hall.OnAddOnLoaded)
