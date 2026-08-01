Sauhaufen.eventHouses = {}
Sauhaufen.eventHousesPattern = "Event"
Sauhaufen.activeEvent = false

function Sauhaufen.LoadEventHouses()
    Sauhaufen.eventHouses = {}
    Sauhaufen.activeEvent = false
    local totalGuildMemberCount = GetNumGuildMembers(Sauhaufen.guildId)
    for idx = 1, totalGuildMemberCount do
        local name, note, _, _, _ = GetGuildMemberInfo(Sauhaufen.guildId, idx)
        local tagT = Sauhaufen.GetTagsFromString(note, Sauhaufen.eventHousesPattern)
        if tagT ~= nil then 
            for i = 1, table.getn(tagT) do
                local eventT = Sauhaufen.TagToTable(tagT[i])
                if tonumber(eventT[3]) == 1 then
                    e = {name = eventT[1], id = eventT[2], username = name}
                    table.insert(Sauhaufen.eventHouses, e)
                    Sauhaufen.activeEvent = true
                end
            end
        end
    end     
end

function Sauhaufen.PrintEvents()
    if table.getn(Sauhaufen.eventHouses) == 0 then
        CHAT_ROUTER:AddSystemMessage("Momentan sind keine Events aktiv")
        return
    else
        CHAT_ROUTER:AddSystemMessage("Events: ")
    end

    for i = 1, table.getn(Sauhaufen.eventHouses) do
        CHAT_ROUTER:AddSystemMessage(i .. ": " .. Sauhaufen.eventHouses[i].name)
    end
end