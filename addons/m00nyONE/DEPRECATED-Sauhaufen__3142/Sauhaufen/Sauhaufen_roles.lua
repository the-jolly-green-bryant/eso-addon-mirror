Sauhaufen.RoleT = {}
Sauhaufen.RoleH = {}
Sauhaufen.RoleDD = {}
Sauhaufen.RoleMasterCrafter = {}
Sauhaufen.RoleVampire = {}
Sauhaufen.RoleWerewolf = {}
Sauhaufen.rolePattern = "Role"

function Sauhaufen.LoadRoles()
    Sauhaufen.RoleT = {}
    Sauhaufen.RoleH = {}
    Sauhaufen.RoleDD = {}
    Sauhaufen.RoleMasterCrafter = {}
    Sauhaufen.RoleVampire = {}
    Sauhaufen.RoleWerewolf = {}
    local totalGuildMemberCount = GetNumGuildMembers(Sauhaufen.guildId)
    for idx = 1, totalGuildMemberCount do
        local name, note, _, _, logoff = GetGuildMemberInfo(Sauhaufen.guildId, idx)
        --if logoff == 0 then

            local roles = Sauhaufen.GetTagsFromString(note, Sauhaufen.rolePattern)
            if roles ~= nil then 
                for i = 1, table.getn(roles) do

                    local rolesT = Sauhaufen.TagToTable(roles[i])
                    if rolesT ~= nil then
                        for j = 1, table.getn(rolesT) do 
                            if logoff == 0 and name ~= GetUnitDisplayName("player") then
                                if rolesT[j] == "T" or rolesT[j] == "Tank" then
                                    r = {username = name}
                                    table.insert(Sauhaufen.RoleT, r)
                                elseif rolesT[j] == "H" or rolesT[j] == "Healer" then
                                    r = {username = name}
                                    table.insert(Sauhaufen.RoleH, r)
                                elseif rolesT[j] == "DD" then
                                    r = {username = name}
                                    table.insert(Sauhaufen.RoleDD, r)
                                end
                            end

                            local isOnline = false
                            if logoff == 0 then
                                isOnline = true
                            end

                            if rolesT[j] == "M" or rolesT[j] == "Meisterhandwerker" then
                                r = {username = name, isOnline = isOnline}
                                table.insert(Sauhaufen.RoleMasterCrafter, r)
                            end
                            if rolesT[j] == "V" or rolesT[j] == "Vampire" then
                                r = {username = name, isOnline = isOnline}
                                table.insert(Sauhaufen.RoleVampire, r)
                            end
                            if rolesT[j] == "W" or rolesT[j] == "Werewolf" then
                                r = {username = name, isOnline = isOnline}
                                table.insert(Sauhaufen.RoleWerewolf, r)
                            end
                        end
                    end
                end
            end
        --end
    end     
end