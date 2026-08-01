-- Print /sh info
function Sauhaufen.PrintInfo()
    CHAT_ROUTER:AddSystemMessage(Sauhaufen.ColorString("Sauhaufen Info:"))
    CHAT_ROUTER:AddSystemMessage(Sauhaufen.ColorString(zo_strformat("<<1[Keine Sau ist/%d Schwein ist/%d Schweine sind]>> gerade online!", Sauhaufen.GetOnlineCount())))
end

-- Print /sh motd
function Sauhaufen.PrintMotD()
    motd = Sauhaufen.SplitString(Sauhaufen.motd, "\n")
    
    CHAT_ROUTER:AddSystemMessage(Sauhaufen.ColorString("Sauhaufen MotD:", "89CFF0"))
    for index, value in ipairs(motd) do
        CHAT_ROUTER:AddSystemMessage(Sauhaufen.ColorString(value, "89CFF0"))
    end
end

-- Print /sh guilded
function Sauhaufen.PrintGuilded()
    CHAT_ROUTER:AddSystemMessage(zo_strformat("guilded: <<1>>", Sauhaufen.guildedLink))
end

-- Post guilded Link in chat
function Sauhaufen.PostGuildedLink()
    StartChatInput(Sauhaufen.guildedLink)
end

function Sauhaufen.Recruit()
    StartChatInput(Sauhaufen.recruitmentText)
end

-- Print /sh help
function Sauhaufen.PrintHelp()
    CHAT_ROUTER:AddSystemMessage("Sauhaufen Addon - Befehle /sh <str>")
    CHAT_ROUTER:AddSystemMessage("/sh open - |cFFFFFFöffnet das Sauhaufen GUI|r")
    CHAT_ROUTER:AddSystemMessage("/sh motd - |cFFFFFFNachricht des Tages|r")
    CHAT_ROUTER:AddSystemMessage("/sh info - |cFFFFFFAnzahl der eingeloggten Mitglieder|r")
    for i = 1, table.getn(Sauhaufen.guildHalls) do 
        CHAT_ROUTER:AddSystemMessage("/sh gh" .. i .. " - |cFFFFFFPorte zum Gildenhaus von " .. Sauhaufen.guildHalls[i].username .. "|r")
    end

    for i = 1, table.getn(Sauhaufen.eventHouses) do
        CHAT_ROUTER:AddSystemMessage("/sh ev" .. i .. " - |cFFFFFFPorte zum Event \"" .. Sauhaufen.eventHouses[i].name .. "\" bei " .. Sauhaufen.eventHouses[i].username .. "|r")
    end

    CHAT_ROUTER:AddSystemMessage("/sh games - |cFFFFFFListe aller verfügbaren Sauhaufen Spiele|r")
    CHAT_ROUTER:AddSystemMessage("/sh housing - |cFFFFFFListe der Häuser von und für Housingverrückte|r")
    CHAT_ROUTER:AddSystemMessage("/sh guilded - |cFFFFFFGuilded Link|r")
    CHAT_ROUTER:AddSystemMessage("/sh postguilded - |cFFFFFFPoste Guilded Link in den Chat|r")
    CHAT_ROUTER:AddSystemMessage("/sh recruit - |cFFFFFFPoste Gildenwerbung in den Chat|r")
end

function Sauhaufen.JumpToHouse(playerName, id)
    if playerName ~= nil and playerName ~= "" then
        if id ~= nil or id ~= 0 then
            if playerName == GetDisplayName() or playerName == nil then
                RequestJumpToHouse(id)
            else
                JumpToSpecificHouse(playerName, id)
            end
        else
            JumpToHouse(playerName)
        end 
        CHAT_ROUTER:AddSystemMessage("Porte in |cFFFFFF" .. playerName .. "|r's Haus")
    end

    if Sauhaufen.GUI.MainMenuVisible then
        Sauhaufen.GUIToggleMain()
    end
end

-- register slash commands
function Sauhaufen.SlashCommands(str)
    if not str or str == "" or str == "help" then
        Sauhaufen.PrintHelp()
    elseif str == "reload" then
        Sauhaufen.LoadGuildHalls()
        Sauhaufen.LoadEventHouses()
        Sauhaufen.LoadHouses()
        Sauhaufen.LoadGames()
        Sauhaufen.LoadMotD()
    elseif str == "open" then
        Sauhaufen.GUIToggleMain()
    elseif str == "motd" then
        Sauhaufen.PrintMotD()
    elseif str == "guilded" or str == "dc" then
        Sauhaufen.PrintGuilded()
    elseif str == "postguilded" or str == "pd" then
        Sauhaufen.PostGuildedLink()
    elseif str == "gh" or str == "gildenhaus" then
        Sauhaufen.PrintGuildhalls()
    elseif str == "ev" or str == "e" or str == "event" or str == "events" then
        Sauhaufen.PrintEvents()
    elseif str == "info" then
        Sauhaufen.PrintInfo()
    elseif str == "housing" or str == "h" then
        Sauhaufen.LoadHouses()
        Sauhaufen.PrintHouses()
    elseif str == "game" or str =="games" or str == "g" then
        Sauhaufen.LoadGames()
        Sauhaufen.PrintGames()
    elseif str == "houseid" then
        CHAT_ROUTER:AddSystemMessage(GetCurrentZoneHouseId())
        CHAT_ROUTER:AddSystemMessage(Sauhaufen.GetHouseNameById(GetCurrentZoneHouseId()))
    elseif str == "donate" then
        Sauhaufen.Donate(0)
    elseif str == "recruit" then
        Sauhaufen.Recruit()
    end

    for i = 1, table.getn(Sauhaufen.guildHalls) do
        if str == "gh" .. i or str == "gildenhaus" .. i then
            Sauhaufen.JumpToHouse(Sauhaufen.guildHalls[i].username, Sauhaufen.guildHalls[i].id)
        end
    end

    for i = 1, table.getn(Sauhaufen.eventHouses) do
        if str == "ev" .. i or str == "event" .. i then
            Sauhaufen.JumpToHouse(Sauhaufen.eventHouses[i].username, Sauhaufen.eventHouses[i].id)
        end
    end

    for i = 1, table.getn(Sauhaufen.houses) do
        if str == "h" .. i or str == "housing" .. i then
            Sauhaufen.JumpToHouse(Sauhaufen.houses[i].username, Sauhaufen.houses[i].id)
        end
    end

    for i = 1, table.getn(Sauhaufen.games) do
        if str == "g" .. i or str == "game" .. i then
            Sauhaufen.JumpToHouse(Sauhaufen.games[i].username, Sauhaufen.games[i].id)
        end
    end
end

SLASH_COMMANDS["/sauhaufen"] = function(str)
    Sauhaufen.SlashCommands(string.lower(str))
end
SLASH_COMMANDS[Sauhaufen.slashCmd] = function(str)
    Sauhaufen.SlashCommands(string.lower(str))
end