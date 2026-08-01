function Esosets.OnKeyPressed(self, key)
    --keycode 134 is the B button on xbox controller
    if key == KEY_ESCAPE or key == KEY_GAMEPAD_BUTTON_2 then Esosets.CLOSE() end


end



function Esosets.OnTextInput()
    local textInput =EsoTextInput
    local value = textInput:GetText()
    if (value ~= nil and value ~= '')then
        --d(zo_strformat("Searching For: <<1>>",value))
        local results = Esosets.TextSearch(value)
        Esosets.Results:Update(results)


        -- results count
        local count = 0
        for _ in pairs(results) do count = count + 1 end

        EsosetsResultsLabel:SetText(zo_strformat("<<1>> Results For: '<<2>>'",count,value))


        ZO_ScrollList_ScrollAbsolute(Esosets.Results, 0)




        -- timed delay to save search
        zo_callLater(function()
            --local textInput = EsoTextInput
            local currentTerm = textInput:GetText()
            if(value == currentTerm)then

                -- add in term to the front and remove anything over 10
                if(Esosets.ContainsString(Esosets.saved.searches, value)== false)then
                    table.insert(Esosets.saved.searches, 1, value)
                    if(#Esosets.saved.searches > 20)then
                        table.remove(Esosets.saved.searches,10)
                    end

                    -- convert a table of strings into some bullshit for the scroll list, then update it with the new values
                    local converted = Esosets.ConvertArrayOfStringsToListTable(Esosets.saved.searches)
                    Esosets.SavedSearchesScrollList:Update(converted)
                end



            end
        end, 3000)
    end
end


local function GetFiltersResultString()

    local filters = Esosets.SearchFilters
    local ret = ""

    if(filters.weight ~= Esosets.ANY) then
        ret = zo_strformat("<<1>> Armor",filters.weight)
    end

    if(filters.bonus1 ~= Esosets.ANY)then
        ret = zo_strformat("<<1>> With <<2>> ",ret,filters.bonus1)
    end

    if(filters.bonus2 ~= Esosets.ANY)then
        local filler = "And"
        if(filters.bonus1 == Esosets.ANY)then
            filler = "With"
        end
        ret = zo_strformat("<<1>> <<2>> <<3>> ",ret,filler,filters.bonus2)
    end

    if(filters.type ~= Esosets.ANY)then
        ret = zo_strformat("<<1>> That is a <<2>> ",ret,filters.type)
    end

    if(filters.zone ~= Esosets.ANY)then
        ret = zo_strformat("<<1>> In <<2>> ",ret,filters.zone)
    end

    if(filters.dungeon ~= Esosets.ANY)then
        ret = zo_strformat("<<1>> In <<2>> ",ret,filters.dungeon)
    end

    if(filters.update ~= Esosets.ANY)then
        ret = zo_strformat("<<1>> In <<2>> ",ret,filters.update)
    end

    if(filters.monsterChest ~= Esosets.ANY)then
        ret = zo_strformat("<<1>> In <<2>> ",ret,filters.monsterChest)
    end

    return ret
end



function Esosets.OnFilterChanged()
    local results = Esosets.FilteredSearch()
    Esosets.Results:Update(results)

    -- results count
    local count = 0
    for _ in pairs(results) do count = count + 1 end

    local resultsString = GetFiltersResultString()

    EsosetsResultsLabel:SetText(zo_strformat("<<1>> Results <<2>>",count,resultsString))
    ZO_ScrollList_ScrollAbsolute(Esosets.Results, 0)
end






function Esosets.OnDisplaySetData(rowControl, data, scrollList)
    -----------NAME

    local color = "FFFFFF"
    local firstWeight = data.weights[1]
    if firstWeight == Esosets.LIGHT then color = Esosets.colors.blue end
    if firstWeight == Esosets.MEDIUM then color = Esosets.colors.green end
    if firstWeight == Esosets.HEAVY then color = Esosets.colors.red end

    local coloredName = zo_strformat("|c<<1>><<2>>|r",color, data.name)

    local name_lable = rowControl:GetNamedChild("Name")
    name_lable:SetText(data.name)
    name_lable:SetFont("ZoFontWinH1")
    name_lable:SetMouseEnabled(true)


    local tooltip = rowControl:GetNamedChild("Tooltip")
    ClearTooltip(tooltip)
    tooltip:ClearLines()
    SetTooltipText(tooltip, "")


    -----------DLC
    local dlc_lable = rowControl:GetNamedChild("Dlc")
    dlc_lable:SetText(data.dlc)
    dlc_lable:SetFont("ZoFontGameSmall")

    -----------WEIGHTS
    local weights_label = rowControl:GetNamedChild("Weights")
    local weightsString =""
    for index, value in pairs(data.weights) do
        weightsString = zo_strformat("<<1>> <<2>> ",weightsString, value)

    end
    weightsString = zo_strformat("|c<<1>>Weights:|r <<2>>",Esosets.colors.headingBlue,weightsString)
    weights_label:SetText(weightsString)
    weights_label:SetFont("ZoFontWinH5")



    -----------TYPE , MONSTER CHEST , TRAITS IF CRAFTED

    local type_label = rowControl:GetNamedChild("SetType")

    local typeString =data.type

    if(data.traits ~= nil)then
        typeString = zo_strformat("<<1>>  |c<<2>>( <<3>> Traits ) |r ", typeString,Esosets.colors.headingBlue, data.traits)
    end


    if(data.shouldersChest ~= nil)then
        typeString = zo_strformat("<<1>> - <<2>>", typeString, data.shouldersChest)
    end

    typeString = zo_strformat("|c<<1>>Type:|r <<2>>", Esosets.colors.headingBlue,typeString)
    type_label:SetText(typeString)
    type_label:SetFont("ZoFontWinH5")
    type_label:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)




    -----------ZONE
    local zoneString = zo_strformat("|c<<1>>Zone:|r <<2>>",Esosets.colors.headingBlue,data.zone)


    if(data.obtained~= nil)then
        if(data.obtained.location ~= nil)then
            zoneString = zo_strformat("<<1>> - <<2>>",zoneString,data.obtained.location)
        end

        if(data.obtained.ad ~= nil)then
            local ad = zo_strformat("|c<<1>><<2>>|r",Esosets.colors.gold, data.obtained.ad)
            local dc = zo_strformat("|c<<1>><<2>>|r",Esosets.colors.blue, data.obtained.dc)
            local ep = zo_strformat("|c<<1>><<2>>|r",Esosets.colors.red, data.obtained.ep)
            local combined = zo_strformat("<<1>>;<<2>>;<<3>>",ad, dc, ep)
            combined = string.gsub(combined, ";","\n")

            zoneString = zo_strformat("<<1>>",combined)

            ClearTooltip(tooltip)
            tooltip:ClearLines()
            SetTooltipText(tooltip, zoneString)


        end
    end

    local zone_lable = rowControl:GetNamedChild("SetZone")
    zone_lable:SetText(zoneString)
    zone_lable:SetFont("ZoFontWinH5")

    zone_lable:SetHandler("OnMouseEnter", function()
        if(zone_lable:WasTruncated()) then tooltip:SetHidden(false) end
    end)
    zone_lable:SetHandler("OnMouseExit",function() tooltip:SetHidden(true) end)


    -----------Dungeons
    local dungeonsString = zo_strformat("|c<<1>>Dungeons:|r ", Esosets.colors.headingBlue)
    if(data.dungeons ~= nill)then
        zoneString = zo_strformat("<<1>> |c<<2>>Dungeons:|r ",zoneString,Esosets.colors.headingBlue)
        for index, value in pairs(data.dungeons) do
            dungeonsString = zo_strformat("<<1>> <<2>> ",dungeonsString, value)

        end
        local dungeons_lable = rowControl:GetNamedChild("SetDungeons")
        zone_lable:SetText(dungeonsString)
        zone_lable:SetFont("ZoFontWinH5")
    end



    -----------SET BONUSES
    local bonuses_control = rowControl:GetNamedChild("Bonuses")
    local bonuses_label = bonuses_control:GetNamedChild("SetBonuses")


    local displayText = string.gsub(data.displayText, ";", "\n")
    displayText = string.gsub(displayText,"%(","")
    displayText = string.gsub(displayText,"%)","")
    displayText = string.gsub(displayText,"%{","")
    displayText = string.gsub(displayText,"%}","")


    displayText = string.gsub(displayText,"(%d+)",Esosets.WrapInColor(Esosets.colors.gold,"%1"))


    displayText = string.gsub(displayText,"(Weapon Damage)",Esosets.WrapInColor(Esosets.colors.green,"%1"))
    displayText = string.gsub(displayText,"(Weapon Critical)",Esosets.WrapInColor(Esosets.colors.green,"%1"))
    displayText = string.gsub(displayText,"(Max Stamina)",Esosets.WrapInColor(Esosets.colors.green,"%1"))
    displayText = string.gsub(displayText,"(Stamina Recovery)",Esosets.WrapInColor(Esosets.colors.green,"%1"))
    --displayText = string.gsub(displayText,"(Stamina)",Esosets.WrapInColor(Esosets.colors.green,"%1"))


    displayText = string.gsub(displayText,"(Max Health)",Esosets.WrapInColor(Esosets.colors.red,"%1"))
    displayText = string.gsub(displayText,"(Health Recovery)",Esosets.WrapInColor(Esosets.colors.red,"%1"))
    displayText = string.gsub(displayText,"(Healing Done)",Esosets.WrapInColor(Esosets.colors.red,"%1"))
    displayText = string.gsub(displayText,"(Healing Taken)",Esosets.WrapInColor(Esosets.colors.red,"%1"))
    --displayText = string.gsub(displayText,"(Health)",Esosets.WrapInColor(Esosets.colors.red,"%1"))

    displayText = string.gsub(displayText,"(Max Magicka)",Esosets.WrapInColor(Esosets.colors.blue,"%1"))
    displayText = string.gsub(displayText,"(Magicka Recovery)",Esosets.WrapInColor(Esosets.colors.blue,"%1"))
    displayText = string.gsub(displayText,"(Spell Damage)",Esosets.WrapInColor(Esosets.colors.blue,"%1"))
    displayText = string.gsub(displayText,"(Spell Critical)",Esosets.WrapInColor(Esosets.colors.blue,"%1"))
    --displayText = string.gsub(displayText,"(Magicka)",Esosets.WrapInColor(Esosets.colors.blue,"%1"))



    --- purple    ultimate, major and minor buffs
    displayText = string.gsub(displayText,"(Ultimate)",Esosets.WrapInColor(Esosets.colors.purple,"%1"))
    displayText = string.gsub(displayText,"(Major%s%w*%s)",Esosets.WrapInColor(Esosets.colors.purple,"%1"))
    displayText = string.gsub(displayText,"(Minor%s%w*%s)",Esosets.WrapInColor(Esosets.colors.purple,"%1"))



    local tagsString =""
    for index, value in pairs(data.bonuses) do
        tagsString = zo_strformat("<<1>> '<<2>>'  ",tagsString, value)

    end

    if(data.bestUsedIn)then
        for index, value in pairs(data.bestUsedIn) do
            tagsString = zo_strformat("<<1>> '<<2>>'  ",tagsString, value)

        end
    end

    tagsString = zo_strformat("Tags: |c<<1>><<2>>|r",Esosets.colors.headingBlue,tagsString)

    displayText = zo_strformat("<<1>>;<<2>>",displayText,tagsString)
    displayText = string.gsub(displayText,";","\n\n")

    bonuses_label:SetText(displayText)
    bonuses_label:SetFont("ZoFontWinH5")



    --[[
    local tags_label = rowControl:GetNamedChild("Tags")
    local tagsString =""
    for index, value in pairs(data.bonuses) do
        tagsString = zo_strformat("<<1>> '<<2>>'  ",tagsString, value)

    end

    tagsString = zo_strformat("Tags: |c<<1>><<2>>|r",Esosets.colors.gold,tagsString)

    tags_label:SetText(tagsString)
    tags_label:SetFont("ZoFontGameSmall")

    ]]--


    local favoriteButton = rowControl:GetNamedChild("FavoriteButton")
    local icon = "esoui/art/characterwindow/equipmentbonusicon_full.dds"

    if(Esosets.ContainsString(Esosets.saved.sets, data.name))then
        icon = "esoui/art/characterwindow/equipmentbonusicon_full_gold.dds"
    end

    favoriteButton:SetNormalTexture(icon)



    favoriteButton:SetHandler("OnMouseUp", function()
        local icon
        if(Esosets.ContainsString(Esosets.saved.sets, data.name))then
            -- IS ALREADY A FAV
            icon = "esoui/art/characterwindow/equipmentbonusicon_full.dds"

            -- Remove from favs
            table.remove(Esosets.saved.sets,Esosets.IndexOf(Esosets.saved.sets,data.name))
        else

            -- IS NOT A FAVORITE YET
            icon = "esoui/art/characterwindow/equipmentbonusicon_full_gold.dds"

            -- Add to saved favorites
            table.insert(Esosets.saved.sets,1,data.name)
        end

        favoriteButton:SetNormalTexture(icon)

        local converted = Esosets.ConvertArrayOfStringsToListTable(Esosets.saved.sets)
        Esosets.SavedSetsScrollList:Update(converted)

    end)


    ------ SEND SET TO CHAT
    name_lable:SetHandler("OnMouseUp", function()
        local name = data.name
        local dlc = data.dlc
        if(dungeonsString == nil)then dungeonsString ="" end

        local toChat = zo_strformat("[Esosets.com];Name: <<1>>;DLC: <<2>>;<<3>>;<<4>>;<<5>>",name,dlc,weightsString,typeString,zoneString)
        toChat = zo_strformat("<<1>>;<<2>>;<<3>>",toChat,dungeonsString, displayText)
        toChat = string.gsub(toChat,";","\n")

        --d(toChat)
        --CHAT_SYSTEM:AddMessage(toChat)
        local ChatEditControl = CHAT_SYSTEM.textEntry.editControl
        if (not ChatEditControl:HasFocus()) then StartChatInput() end

        --ChatEditControl:InsertText(toChat)

        d(GetUnitDisplayName("player"))
    end)

end

