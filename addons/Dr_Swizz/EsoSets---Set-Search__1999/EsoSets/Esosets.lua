--[[
     v.1.1 Added esc and "b" buttons to close
           Added "Suggested Content" Filter
]]--

Esosets = {
	name = "Esosets",
    version ="1.6",
    updatedTo = "Dragonhold",
    IS_OPEN = false,
    colors ={
        gold = "eec929",
        headingBlue = "a8c2ed",
        blue ="5c5cf6",
        red ="f74a4a",
        green ="008000",
        purple ="a778e8",
        windowsGreen = "80FFFF"
    },
    Defaults = {
        searches = {

        },
        sets ={

        }
    }

}


local function OnWeightSelected(comboBox, itemName, item, selectionChanged)
    --itemName = the weight

    local results = {}
    for key, value in pairs( Esosets.ALL_SETS) do
        if value ~= nill then
            if(Esosets.Contains(value.weights,itemName))then
                table.insert(results,value)
            else

            end
        end
    end

    Esosets.Results:Update(results)
end

local function TableContains (table, needle)
    for index, value in pairs(table) do

        if value == needle then
            return true
        end
    end

    return false
end

local function IndexOfItemInTable(table, needle)
    for index, value in pairs(table) do
        if value == needle then
            return index
        end
    end
    return 0
end

local function TableContinsString(table, needle)
    if(table == nil)then d("nil table sent to TableContainsString") return end
    needle = string.lower(needle)
    for index, value in pairs(table) do
        if(Esosets.HasSubString(value,needle)) then
            return true
        end
    end

    return false
end

local function StringContainsSubString(haystack, needle)
    haystack = string.lower(haystack)
    needle = string.lower(needle)

    if string.match(haystack, needle) then
        return true
    end

    return false
end

local function WrapStringInColor(color, string)

    return zo_strformat("|c<<1>><<2>>|r",color,string)
end


local function ConvertArrayOfStringsToListTable(list, key)
    local returnTable = {}


    if(key == nil) then key = "name" end

    for i, value in pairs(list) do
        table.insert(returnTable,{name = value})
    end
    return returnTable
    end

local function Blacklist()
    local name = GetUnitDisplayName("player")
    if(Esosets.HasSubString(name,"alcast"))then return true end
    if(Esosets.HasSubString(name,"woeler"))then return true end

    return false
end



































local function Initialize(event, addon)
    if addon ~= Esosets.name then return end
	GetEventManager():UnregisterForEvent(Esosets.name, EVENT_ADD_ON_LOADED)

    Esosets.WrapInColor = WrapStringInColor
    Esosets.HasSubString = StringContainsSubString
    Esosets.Contains = TableContains
    Esosets.ContainsString = TableContinsString
    Esosets.ConvertArrayOfStringsToListTable = ConvertArrayOfStringsToListTable
    Esosets.IndexOf = IndexOfItemInTable


    -- found in constants.lua
    Esosets.InitConstants()


    -- found in sets.lua
    Esosets.InitSets()

    Esosets.saved = ZO_SavedVars:New("EsosetsSavedVariables", 1, nil, Esosets.Defaults)

    -- CAN CLEAR OUT THE VARS LIKE THIS
    --Esosets.saved.searches ={}

    -- update version and dlc
    local updateString = zo_strformat("|c<<1>>V <<2>> Updated to|r |c<<3>> '<<4>>' |r",Esosets.colors.headingBlue,Esosets.version, Esosets.colors.windowsGreen, Esosets.updatedTo)
    Esosets_Version:SetText(updateString)


    Esosets.SearchFilters ={
        bonus1 = Esosets.ANY,
        bonus2 = Esosets.ANY,
        update = Esosets.ANY,
        type = Esosets.ANY,
        dungeon = Esosets.ANY,
        zone = Esosets.ANY,
        weight = Esosets.ANY,
        monsterChest = Esosets.ANY,
        contentType = Esosets.ANY
    }

    Esosets.ActiveDropdown =nil

    Esosets.TableOfFilterSelected ={}

    Esosets.SetSearchFilter = function(itemName, value)
        if(itemName == "Bonus 1") then Esosets.SearchFilters.bonus1 = value end
        if(itemName == "Bonus 2") then Esosets.SearchFilters.bonus2 = value end
        if(itemName == "Weight") then Esosets.SearchFilters.weight = value end
        if(itemName == "Type") then Esosets.SearchFilters.type = value end
        if(itemName == "Zone") then Esosets.SearchFilters.zone = value end
        if(itemName == "Dungeons") then Esosets.SearchFilters.dungeon = value end
        if(itemName == "Update") then Esosets.SearchFilters.update = value end
        if(itemName == "Monster Chest") then Esosets.SearchFilters.monsterChest = value end
        if(itemName == "Suggested Content Type") then Esosets.SearchFilters.contentType = value end
    end

    Esosets.GetSearchFilter = function(itemName)
        if(itemName == "Bonus 1") then return Esosets.SearchFilters.bonus1 end
        if(itemName == "Bonus 2") then return Esosets.SearchFilters.bonus2  end
        if(itemName == "Weight") then return Esosets.SearchFilters.weight  end
        if(itemName == "Type") then return Esosets.SearchFilters.type  end
        if(itemName == "Zone") then return Esosets.SearchFilters.zone end
        if(itemName == "Dungeons") then return Esosets.SearchFilters.dungeon end
        if(itemName == "Update") then return Esosets.SearchFilters.update  end
        if(itemName == "Monster Chest") then return Esosets.SearchFilters.monsterChest end
        if(itemName == "Suggested Content Type") then return Esosets.SearchFilters.contentType end
    end




    local container = EsosetsWrapper
    local basicSerachWrapper = EsoBasicSearch
    local advancedSearchWrapper = EsoAdvancedSearch
    local searchWrapper = EsoSearchOptions
    local searchResultsLabel = EsosetsResultsLabel


    searchResultsLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

    --container:SetHandler("OnKeyUp", function(self, key) Esosets.OnKeyPressed(container, key) end)




    local libScroll = LibStub:GetLibrary("LibScroll")


    -- MAIN RESULTS SCROLL LIST
    local scrollData = {
        name    = "EsosetsResultsScroll",
        parent  = EsosetsResults,
        width   = 600,
        height  = 675,

        rowHeight       = 400,
        rowTemplate     = "EsosetsCardLayout",
        setupCallback   = Esosets.OnDisplaySetData, --(rowControl, data, scrollList)
        --sortFunction    = SortScrollList,
        selectTemplate  = "Fuck",
        --selectCallback  = OnRowSelection, OnRowSelect(previouslySelectedData, selectedData, reselectingDuringRebuild)

        --dataTypeSelectSound = SOUNDS.BOOK_CLOSE,
        --hideCallback    = OnRowHide,
        --resetCallback   = OnRowReset,

        --categories  = {1, 2},
    }

    local scrollList = libScroll:CreateScrollList(scrollData)

    scrollList:Update(Esosets.ALL_SETS)
    scrollList:ClearAnchors()
    --scrollList:SetAnchor(TOPLEFT,searchWrapper,BOTTOMLEFT,0,50)
    scrollList:SetAnchor(TOP,searchResultsLabel,BOTTOM,0,20)
    Esosets.Results = scrollList



    local ALL_FILTERS ={
        [1] ={
            ["name"] = "Suggested Content Type",
            ["data_table"] = Esosets.ALL_BEST_USED_FOR
        },
        [2] = {
            ["name"] = "Bonus 1",
            ["data_table"] = Esosets.ALL_BONUSES
        },
        [3] = {
            ["name"] = "Bonus 2",
            ["data_table"] = Esosets.ALL_BONUSES
        },
        [4] = {
            ["name"] = "Weight",
            ["data_table"] = Esosets.ALL_WEIGHTS
        },
        [5] = {
            ["name"] = "Type",
            ["data_table"] = Esosets.ALL_SETS_BY_TYPE
        },
        [6] = {
            ["name"] = "Zone",
            ["data_table"] = Esosets.ALL_ZONES
        },
        [7] = {
            ["name"] = "Dungeons",
            ["data_table"] = Esosets.ALL_DUNGEONS
        },
        [8] = {
            ["name"] = "Update",
            ["data_table"] = Esosets.ALL_DLC
        },
        [9] = {
            ["name"] = "Monster Chest",
            ["data_table"] = Esosets.ALL_MONSTER_SHOULDER_VENDORS
        }

    }





    local function SetupDropdown(rowControl, data, scrollList)

        local name = rowControl:GetNamedChild("Name")
        name:SetText(data.name)
        name:SetFont("ZoFontGameSmall")
        name:SetVerticalAlignment(TEXT_ALIGN_CENTER)

        rowControl:SetMouseEnabled(true)
        rowControl:SetHandler("OnMouseUp", function()
            ZO_ScrollList_MouseClick(scrollList, rowControl)
            return true
        end)

        local highlight = rowControl:GetNamedChild("Highlight")
        rowControl:SetHandler("OnMouseEnter", function() highlight:SetHidden(false) end)
        rowControl:SetHandler("OnMouseExit", function() highlight:SetHidden(true) end)

    end






    for i, value in pairs(ALL_FILTERS) do
        local control = WINDOW_MANAGER:CreateControlFromVirtual(value.name, EsosetsFiltersBG, "DropdownTemplate")
        local header = control:GetNamedChild("Name")
        header:SetVerticalAlignment(TEXT_ALIGN_CENTER)

        local selected = control:GetNamedChild("Selected")
        selected:SetVerticalAlignment(TEXT_ALIGN_CENTER)

        local expandButton = control:GetNamedChild("Expand")
        local scrollAnchor = control:GetNamedChild("ScrollAnchor")

        -- add this to gloabal so we can reset them when user clears
        table.insert(Esosets.TableOfFilterSelected,selected)


        control:ClearAnchors()
        control:SetAnchor(TOPLEF,EsosetsFiltersBG,TOPLEFT, 10,i *80)

        local function DisableAllMouseOverBut(theActiveSelect)
            for i, value in pairs(Esosets.TableOfFilterSelected) do
                if(value == theActiveSelect) then
                    value:SetMouseEnabled(true)
                else
                    value:SetMouseEnabled(false)
                end
            end

        end

        local function EnableAll()
            for i, value in pairs(Esosets.TableOfFilterSelected) do
                value:SetMouseEnabled(true)
            end
        end

        local function HandleToggle()
            if(Esosets.ActiveDropdown == nil)then
                scrollAnchor:SetHidden(not scrollAnchor:IsHidden())
                Esosets.ActiveDropdown = scrollAnchor
                DisableAllMouseOverBut(selected)
            elseif(Esosets.ActiveDropdown == scrollAnchor)then
                if(scrollAnchor:IsHidden())then
                    -- open the scroll
                    scrollAnchor:SetHidden(false)
                    DisableAllMouseOverBut(selected)
                else
                    -- close the scroll and set to nil
                    scrollAnchor:SetHidden(true)
                    Esosets.ActiveDropdown = nil
                    EnableAll()
                end
            end
        end




        expandButton:SetHandler("OnMouseUp", function()
            --scrollAnchor:SetHidden(not scrollAnchor:IsHidden())
            HandleToggle()
        end)

        selected:SetMouseEnabled(true)
        selected:SetHandler("OnMouseUp", function()
            --scrollAnchor:SetHidden(not scrollAnchor:IsHidden())
            HandleToggle()
        end)



        header:SetText(value.name)
        selected:SetText(Esosets.GetSearchFilter(value.name))



        local function OnSelected(previouslySelectedData, selectedData, reselectingDuringRebuild)
            if not selectedData then return end
            if(previouslySelectedData == selectedData)then return end
            selected:SetText(selectedData.name)
            Esosets.SetSearchFilter(value.name,selectedData.name)
            --scrollAnchor:SetHidden(true)
            HandleToggle()
            -- triggers the search and updates the results list
            Esosets.OnFilterChanged()
        end





        -- Scroll template for each filter drop down

        local scrollData2 = {
            name    = "$(parent)Scroll",
            parent  = scrollAnchor,
            width   = 200,
            height  = 300,

            rowHeight       = 25,
            rowTemplate     = "DropdownRow",
            setupCallback   = SetupDropdown, --(rowControl, data, scrollList)
            --sortFunction    = SortScrollList,
            --selectTemplate  = "Fuck",
            selectCallback  = OnSelected, --OnRowSelect(previouslySelectedData, selectedData, reselectingDuringRebuild)

            --dataTypeSelectSound = SOUNDS.BOOK_CLOSE,
            --hideCallback    = OnRowHide,
            --resetCallback   = OnRowReset,

            --categories  = {1, 2},
        }



        local libScroll2 = LibStub:GetLibrary("LibScroll")

        local new_scrollList = libScroll2:CreateScrollList(scrollData2)



        new_scrollList:SetHidden(false)
        new_scrollList:Update(ConvertArrayOfStringsToListTable(value.data_table))
        new_scrollList:ClearAnchors()
        new_scrollList:SetAnchor(TOPRIGHT,expandButton,BOTTOMLEFT,0,0)


        new_scrollList:SetMouseEnabled(true)
        new_scrollList:SetHandler("OnMouseExit", function() HandleToggle()  end)







    end -- end each filter drop down creation


    local function SetupSavedSearchRow(rowControl, data, scrollList)
        if(data == nil)then return end
        local name = rowControl:GetNamedChild("Name")
        name:SetText(data.name)
        name:SetFont("ZoFontGameSmall")
        name:SetVerticalAlignment(TEXT_ALIGN_CENTER)

        rowControl:SetMouseEnabled(true)
        rowControl:SetHandler("OnMouseUp", function()
            ZO_ScrollList_MouseClick(scrollList, rowControl)
            return true
        end)

        local highlight = rowControl:GetNamedChild("Highlight")
        rowControl:SetHandler("OnMouseEnter", function() highlight:SetHidden(false) end)
        rowControl:SetHandler("OnMouseExit", function() highlight:SetHidden(true) end)

    end

    local function OnSavedSearchSelected(previouslySelectedData, selectedData, reselectingDuringRebuild)
        if not selectedData then return end
        if(previouslySelectedData == selectedData)then return end
        EsoTextInput:SetText(selectedData.name)
    end

    --SCROLL FOR SAVED SEARCHES
    local scrollData = {
        name    = "$(parent)Scroll",
        parent  = SAVED_SEARCH_SCROLL_ANCHOR,
        width   = 250,
        height  = 300,

        rowHeight       = 30,
        rowTemplate     = "DropdownRow",
        setupCallback   = SetupSavedSearchRow, --(rowControl, data, scrollList)
        --sortFunction    = SortScrollList,
        --selectTemplate  = "Fuck",
        selectCallback  = OnSavedSearchSelected

        --dataTypeSelectSound = SOUNDS.BOOK_CLOSE,
        --hideCallback    = OnRowHide,
        --resetCallback   = OnRowReset,

        --categories  = {1, 2},
    }

    local savedSearches = libScroll:CreateScrollList(scrollData)

    savedSearches:ClearAnchors()

    savedSearches:SetAnchor(TOP,SAVED_SEARCH_SCROLL_ANCHOR,TOP,8,0)

    Esosets.SavedSearchesScrollList = savedSearches
    local converted = ConvertArrayOfStringsToListTable(Esosets.saved.searches)
    Esosets.SavedSearchesScrollList:Update(converted)






    --SCROLL FOR SAVED SETS
    local scrollData = {
        name    = "$(parent)Scroll",
        parent  = SAVED_SETS_SCROLL_ANCHOR,
        width   = 250,
        height  = 300,

        rowHeight       = 30,
        rowTemplate     = "DropdownRow",
        setupCallback   = SetupSavedSearchRow, --(rowControl, data, scrollList)
        --sortFunction    = SortScrollList,
        --selectTemplate  = "Fuck",
        selectCallback  = OnSavedSearchSelected

        --dataTypeSelectSound = SOUNDS.BOOK_CLOSE,
        --hideCallback    = OnRowHide,
        --resetCallback   = OnRowReset,

        --categories  = {1, 2},
    }

    local savedSets = libScroll:CreateScrollList(scrollData)

    savedSets:ClearAnchors()

    savedSets:SetAnchor(TOP,SAVED_SETS_SCROLL_ANCHOR,TOP,8,0)

    Esosets.SavedSetsScrollList = savedSets
    local converted = ConvertArrayOfStringsToListTable(Esosets.saved.sets)
    Esosets.SavedSetsScrollList:Update(converted)







    local textInput = EsoTextInput
    textInput:SetHandler("OnTextChanged", function() Esosets.OnTextInput() end)



    Esosets.ResetFilters = function()
        Esosets.SearchFilters ={
            bonus1 = Esosets.ANY,
            bonus2 = Esosets.ANY,
            update = Esosets.ANY,
            type = Esosets.ANY,
            dungeon = Esosets.ANY,
            zone = Esosets.ANY,
            weight = Esosets.ANY,
            monsterChest = Esosets.ANY,
            contentType = Esosets.ANY
        }

        for i, label in pairs(Esosets.TableOfFilterSelected) do
            label:SetText(Esosets.ANY)
        end
    end


    local fragment = ZO_SimpleSceneFragment:New(container)
    --HUD_UI_SCENE:AddFragment(fragment)

    local scene = ZO_Scene:New("Esosets", SCENE_MANAGER)
    scene:AddFragment(fragment)


    Esosets.TOGGLE = function()

        if  not SCENE_MANAGER:IsShowing("Esosets") then
            if(Blacklist())then d("User name does not have access, please try adding a hypen")return end

            -- show window and set input to take focus
            SCENE_MANAGER:Toggle("Esosets")
            EsoTextInput:TakeFocus()
            SCENE_MANAGER:SetInUIMode(true)
            container:SetHidden(false)
        else
            SCENE_MANAGER:Toggle("Esosets")
            container:SetHidden(true)
        end



        --SCENE_MANAGER:Toggle("Esosets")
    end


    Esosets.COMMAND_SEARCH = function(extra)

        Esosets.TOGGLE()
        EsoTextInput:SetText(extra)
    end

    Esosets.TOGGLE_FILTERS = function()
        EsosetsFiltersBG:SetHidden(not EsosetsFiltersBG:IsHidden())
    end



    SLASH_COMMANDS["/esosets"] = Esosets.TOGGLE

    SLASH_COMMANDS["/setsearch"] = Esosets.COMMAND_SEARCH


    --create the string to show in the controls window for user keybinds
    ZO_CreateStringId("SI_BINDING_NAME_TOGGLE_WINDOW", "Show/Hide Esosets")


end -- end Initialize

GetEventManager():RegisterForEvent(Esosets.name, EVENT_ADD_ON_LOADED, Initialize)