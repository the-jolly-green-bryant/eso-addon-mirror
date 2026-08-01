Sauhaufen.games = {}
Sauhaufen.gamePattern = "Game"

function Sauhaufen.LoadGames()
    Sauhaufen.games = {}
    local totalGuildMemberCount = GetNumGuildMembers(Sauhaufen.guildId)
    for idx = 1, totalGuildMemberCount do
        local name, note, _, _, _ = GetGuildMemberInfo(Sauhaufen.guildId, idx)
        local tagT = Sauhaufen.GetTagsFromString(note, Sauhaufen.gamePattern)
        if tagT ~= nil then 
            for i = 1, table.getn(tagT) do
                local gameT = Sauhaufen.TagToTable(tagT[i])
                if tonumber(gameT[3]) == 1 then
                    g = {name = gameT[1], id = gameT[2], username = name}
                    table.insert(Sauhaufen.games, g)
                end
            end
        end
    end     
end

function Sauhaufen.PrintGames()
    if table.getn(Sauhaufen.games) == 0 then
        CHAT_ROUTER:AddSystemMessage("Momentan sind keine Spielehäuser gelistet")
        return
    else
        CHAT_ROUTER:AddSystemMessage("Spieleliste: ")
    end

    for i = 1, table.getn(Sauhaufen.games) do
        CHAT_ROUTER:AddSystemMessage(i .. ": " .. Sauhaufen.games[i].username .."'s \"" .. Sauhaufen.games[i].name .. "\"" )
    end

    if table.getn(Sauhaufen.games) >= 1 then
        CHAT_ROUTER:AddSystemMessage("Du kannst mit |cFFFFFF/sh g#|r zu den einzelnen Häusern porten")
        return
    end
end