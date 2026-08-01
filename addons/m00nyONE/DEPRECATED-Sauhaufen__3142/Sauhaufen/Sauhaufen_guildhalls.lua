Sauhaufen.guildHalls = {}
Sauhaufen.guildhallPattern = "GH"

function Sauhaufen.LoadGuildHalls()
    Sauhaufen.guildHalls = {}
    local totalGuildMemberCount = GetNumGuildMembers(Sauhaufen.guildId)
    for idx = 1, totalGuildMemberCount do
        local name, note, _, _, _ = GetGuildMemberInfo(Sauhaufen.guildId, idx)
        local tagT = Sauhaufen.GetTagsFromString(note, Sauhaufen.guildhallPattern)
        if tagT ~= nil then
            for i = 1, table.getn(tagT) do
                local guildhallT = Sauhaufen.TagToTable(tagT[i])
                if tonumber(guildhallT[4]) == 1 then
                    g = {name = guildhallT[2], id = guildhallT[3], username = name, order = guildhallT[1]}
                    Sauhaufen.guildHalls[tonumber(guildhallT[1])] = g
                    -- table.insert(Sauhaufen.guildHalls, g)
                end
            end
        end
    end     
end

-- Print /sh gh
function Sauhaufen.PrintGuildhalls()
    if table.getn(Sauhaufen.guildHalls) == 0 then
        CHAT_ROUTER:AddSystemMessage("Momentan sind keine Gildenhäuser betretbar")
        return
    else
        CHAT_ROUTER:AddSystemMessage("Gildenhäuser: ")
    end

    for i = 1, table.getn(Sauhaufen.guildHalls) do
        CHAT_ROUTER:AddSystemMessage(i .. ": " .. Sauhaufen.guildHalls[i].username)
    end

    if table.getn(Sauhaufen.guildHalls) >= 1 then
        CHAT_ROUTER:AddSystemMessage("Du kannst mit |cFFFFFF/sh gh#|r zu den einzelnen Häusern porten")
        return
    end
end