function Esosets.TextSearch(term)
    local results ={}
    --for key, value in pairs( Esosets.ALL_SETS) do
    for key, value in pairs( Esosets.ALL_SETS2) do
        if value ~= nill then
            --bonuses           table of strings
            --weights           table of strings
            --dungeons          table of strings
            --type              string
            --dlc               string
            --zone              string
            --displayText       string
            --shouldersChest    string
            --name              string

            -- match bonuses
            if(value.bonuses ~= nil) then
                if(Esosets.ContainsString(value.bonuses, term)) then
                    if(Esosets.Contains(results, value)) then
                        -- results already has this value
                    else
                        table.insert(results,value)
                    end
                end
            end


            -- match weights
            if(value.weights ~= nil )then
                if(Esosets.ContainsString(value.weights, term)) then
                    if(Esosets.Contains(results, value)) then
                        -- results already has this value
                    else
                        table.insert(results,value)
                    end
                end

            end


            -- match dungeons
            if(value.dungeons ~= nil)then
                if(Esosets.ContainsString(value.dungeons, term)) then
                    if(Esosets.Contains(results, value)) then
                        -- results already has this value
                    else
                        table.insert(results,value)
                    end
                end
            end



            -- match Content Type
            if(value.bestUsedIn ~= nil)then
                if(Esosets.ContainsString(value.bestUsedIn, term)) then
                    if(Esosets.Contains(results, value)) then
                        -- results already has this value
                    else
                        table.insert(results,value)
                    end
                end
            end


            -- match type
            if(value.type ~= nil)then
                if(Esosets.HasSubString(value.type, term)) then
                    if(Esosets.Contains(results, value)) then
                        -- results already has this value
                    else
                        table.insert(results,value)
                    end
                end
            end


            -- match zone
            if(value.zone ~= nil) then
                if(Esosets.HasSubString(value.zone, term)) then
                    if(Esosets.Contains(results, value)) then
                        -- results already has this value
                    else
                        table.insert(results,value)
                    end
                end
            end



            -- match displayText
            if(value.displayText ~= nil) then
                if(Esosets.HasSubString(value.displayText, term)) then
                    if(Esosets.Contains(results, value)) then
                        -- results already has this value
                    else
                        table.insert(results,value)
                    end
                end
            end



            -- match shouldersChest
            if(value.shouldersChest ~= nil)then
                if(Esosets.HasSubString(value.shouldersChest, term)) then
                    if(Esosets.Contains(results, value)) then
                        -- results already has this value
                    else
                        table.insert(results,value)
                    end
                end
            end


            -- match name
            if(value.name ~= nil)then
                if(Esosets.HasSubString(value.name, term)) then
                    if(Esosets.Contains(results, value)) then
                        -- results already has this value
                    else
                        table.insert(results,value)
                    end
                end
            end



            -- match dlc
            if(value.dlc ~= nil)then
                if(Esosets.HasSubString(value.dlc, term)) then
                    if(Esosets.Contains(results, value)) then
                        -- results already has this value
                    else
                        table.insert(results,value)
                    end
                end
            end
        end
    end

    local function compare(a,b)
        return a["name"] < b["name"]
    end

    table.sort(results, compare)






    return results
end -- end TextSearch



function Esosets.FilteredSearch()
    --[[Esosets.SearchFilters ={
        bonus1 = Esosets.ANY,
        bonus2 = Esosets.ANY,
        update = Esosets.ANY,
        type = Esosets.ANY,
        dungeon = Esosets.ANY,
        zone = Esosets.ANY,
        weight = Esosets.ANY,
        monsterChest = Esosets.ANY
    }
    --]]
    local filters = Esosets.SearchFilters

    local results ={}
    for i, set in pairs(Esosets.ALL_SETS2) do
        -- set up checks to pass
        local meetsBonus1 = false
        local meetsBonus2 = false
        local meetsWeight = false
        local meetsUpdate = false
        local meetsType = false
        local meetsZone = false
        local meetsMonsterChest = false
        local meetsDungeon = false
        local meetsContentType = false

        if(filters.bonus1 == Esosets.ANY) then
            meetsBonus1 = true
        else
           meetsBonus1 = Esosets.ContainsString(set.bonuses, filters.bonus1)
        end



        if(filters.bonus2 == Esosets.ANY) then
            meetsBonus2 = true
        else
            meetsBonus2 = Esosets.ContainsString(set.bonuses, filters.bonus2)
        end

        if(filters.weight == Esosets.ANY) then
            meetsWeight = true
        else
            meetsWeight = Esosets.ContainsString(set.weights, filters.weight)
        end

        if(filters.update == Esosets.ANY) then
            meetsUpdate = true
        else
            if(set.dlc)then
                if(set.dlc == filters.update) then meetsUpdate = true end
            end
        end

        if(filters.type == Esosets.ANY) then
            meetsType = true
        else
            if(set.type)then
                if(set.type == filters.type) then meetsType = true end
            end
        end

        if(filters.zone == Esosets.ANY) then
            meetsZone = true
        else
            if(set.zone)then
                if(set.zone == filters.zone)then meetsZone = true end
            end
        end

        if(filters.monsterChest == Esosets.ANY) then
            meetsMonsterChest = true
        else
            if(set.shouldersChest) then
                if(set.shouldersChest == filters.monsterChest) then meetsMonsterChest = true end
            end
        end

        if(filters.dungeon == Esosets.ANY) then
            meetsDungeon = true
        else
            if(set.dungeons) then
                meetsDungeon = Esosets.ContainsString(set.dungeons, filters.dungeon)
            end
        end

        if(filters.contentType == Esosets.ANY) then
            meetsContentType = true
        else
            if(set.bestUsedIn)then
                meetsContentType = Esosets.ContainsString(set.bestUsedIn, filters.contentType)
            else
                meetsContentType = true
                d("missing content type for "..set.name)
            end

        end



        if(meetsBonus1 and meetsBonus2 and meetsDungeon and meetsMonsterChest and meetsType and meetsUpdate and meetsWeight and meetsZone and meetsContentType) then
            table.insert(results, set)
        end
    end -- end for each set



    local function compare(a,b)
        return a["name"] < b["name"]
    end

    table.sort(results, compare)


    return results
end-- end filtered search













