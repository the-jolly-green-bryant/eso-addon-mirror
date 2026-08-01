Sauhaufen.houses = {}
Sauhaufen.housingPattern = "Housing"

function Sauhaufen.LoadHouses()
    Sauhaufen.houses = {}
    local totalGuildMemberCount = GetNumGuildMembers(Sauhaufen.guildId)
    for idx = 1, totalGuildMemberCount do
        local name, note, _, _, _ = GetGuildMemberInfo(Sauhaufen.guildId, idx)
        local tagT = Sauhaufen.GetTagsFromString(note, Sauhaufen.housingPattern)
        if tagT ~= nil then 
            for i = 1, table.getn(tagT) do
                local houseT = Sauhaufen.TagToTable(tagT[i])
                if tonumber(houseT[3]) == 1 then
                    h = {name = houseT[1], id = houseT[2], username = name}
                    table.insert(Sauhaufen.houses, h)
                end
            end
        end
    end     
end

function Sauhaufen.PrintHouses()
    if table.getn(Sauhaufen.houses) == 0 then
        CHAT_ROUTER:AddSystemMessage("Momentan sind keine Häuser zum betrachten gelistet")
        return
    else
        CHAT_ROUTER:AddSystemMessage("Häuserliste: ")
    end

    local atLeastOne = false
    for i = 1, table.getn(Sauhaufen.houses) do
        CHAT_ROUTER:AddSystemMessage(i .. ": " .. Sauhaufen.houses[i].username .."'s |cFFFFFF\"" .. Sauhaufen.houses[i].name .. "\"|r" )
        atLeastOne = true
    end
    if atLeastOne then
        CHAT_ROUTER:AddSystemMessage("Du kannst mit |cFFFFFF/sh housing#|r zu den einzelnen Häusern porten")
    end
end