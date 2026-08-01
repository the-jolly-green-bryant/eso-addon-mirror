local errorTemplateText = "[AF_FCOItemSaverFilters] ERROR --- ABORTING due to no FCOIS %s found!"

--As the gear set values etc. are rebuild at EVENT_PLAYER_ACTIVATED within FCOItemSaver addon we need to
--rebuild some avriables here accordingly. See function FCOIS.rebuildGearSetBaseVars() in file FCOItemSaver/FCOIS_Functions.lua
local function AF_FCOItemSaverFiltersPlugin_PlayerActivated(event)
    --FCOItemSaver is loaded?
    if AdvancedFilters == nil or FCOIS == nil then return end
    --Delay a bit to give the FCOIS event_player_activated tasks time to run and end properly
    zo_callLater(function()
        --Variables needed
        local util = AdvancedFilters.util
        --Settings of FCOIS
        local numVars = FCOIS.numVars
        local mappingVars = FCOIS.mappingVars
        if numVars == nil then
            d(string.format(errorTemplateText, "numVars"))
            return false
        end
        if mappingVars == nil then
            d(string.format(errorTemplateText, "mappingVars"))
            return false
        end
        --Gear sets
        local numGearSets       = numVars.gFCONumGearSets
        local numGearSetsStatic = numVars.gFCONumGearSetsStatic
        local gearToIcon        = mappingVars.gearToIcon
        --Dynamic icons & dynamic icons flagged as gear
        local numDynamicIcons   = numVars.gFCONumDynamicIcons
        local iconIdToDynIcon   = mappingVars.dynamicToIcon
        local iconToDynamic     = mappingVars.iconToDynamic
        --Get the settings and the needed variables
        local settings          = FCOIS.settingsVars.settings
        local isGearIcon        = settings.iconIsGear
        local isIconEnabled     = settings.isIconEnabled
        --Abort the AF plugin addon here if the needed FCOItemSaver settings could not be loaded
        if settings == nil or isGearIcon == nil then
            d(string.format(errorTemplateText, "settings"))
            return false
        end
        --Get the selected language
        local langu = GetCVar("language.2")
        if langu == nil then
            langu = "en"
        end

        --[[
            This function handles the actual filtering. Use whatever parameters for "GetFilterCallback..."
            and whatever logic you need to in "function( slot )".
          ]]
        local function GetFilterCallbackForFCOMarked(FCOFilterId, FCOIconId)
            return function( slot , slotIndex)
                if util.prepareSlot ~= nil then
                    if slotIndex ~= nil and type(slot) ~= "table" then
                        slot = util.prepareSlot(slot, slotIndex)
                    end
                end
                --local locItemInstanceId = GetItemInstanceId(slot.bagId, slot.slotIndex)
                local bag, slot = slot.bagId, slot.slotIndex
                if bag == nil or slot == nil then return false end

                --Get the settings and the needed variables
                local locSettings          = FCOIS.settingsVars.settings
                local locIsGearIcon        = locSettings.iconIsGear

                --Function to check if icons are in the check table
                local function checkIfIconsToCheck(iconsCheckTable)
                    if iconsCheckTable == nil then return false end
                    for _,_ in pairs(iconsCheckTable) do
                        return true --any entry found -> Icon is in the table
                    end
                    return false
                end

                --Add entries to the icons check table used in function FCOIS.IsMarked
                local function addToIconsChecktable(type, iconsCheckTable)
                    if iconsCheckTable == nil then return false end
                    if type == nil or type == "" then return false end

                    --All dynmic icons
                    if type == "dynamic" or type == "dynamicAndGear" then
                        --Add the dynamic icons
                        for dynIconNr = 1, numDynamicIcons, 1 do
                            local addDynIcon = true
                            --Is the dynamic icon a gear icon?
                            if type ~= "dynamicAndGear" then
                                --Do not add dynamic gear icons!
                                local dynIconId = iconIdToDynIcon[dynIconNr]
                                if locIsGearIcon[dynIconId] then
                                    addDynIcon = false
                                end
                            end
                            if addDynIcon then
                                iconsCheckTable["dynamic" .. tostring(dynIconNr)] = _G["FCOIS_CON_ICON_DYNAMIC_" .. tostring(dynIconNr)]
                            end
                        end

                        --All gear sets
                    elseif type == "gear" then
                        --Add the static gear set icons
                        for gearNr = 1, numGearSetsStatic, 1 do
                            iconsCheckTable["gear" .. tostring(gearNr)] = _G["FCOIS_CON_ICON_GEAR_" .. tostring(gearNr)]
                        end
                        --Now add dynmic icons which are flagged as gear too
                        for dynIconNr = 1, numDynamicIcons, 1 do
                            local dynIconId = iconIdToDynIcon[dynIconNr]
                            --Is the dynamic icon a gear icon?
                            if locIsGearIcon[dynIconId] then
                                iconsCheckTable["dynamic" .. tostring(dynIconNr)] = _G["FCOIS_CON_ICON_DYNAMIC_" .. tostring(dynIconNr)]
                            end
                        end
                    end
                end

                --Check the filters, or the icon?
                --Check the icons here:
                if (FCOFilterId == nil and (FCOIconId ~= nil and FCOIconId ~= -1 and type(FCOIconId)=="number")) then
                    --Check if the given item is marked with one of the iconIds
                    return FCOIS.IsMarked(bag, slot, FCOIconId)

                    --Check the special filters here:
                elseif (FCOFilterId ~= nil and type(FCOFilterId) == "string") then
                    --Table with the icons to check. Key can be any value. Value msut be the iconId or -1 for all icons.
                    local iconsToCheck = {}
                    --Add the icons to the check table now according to the filterId's "type"
                    addToIconsChecktable(FCOFilterId, iconsToCheck)
                    --Check if icons are inside the table
                    if checkIfIconsToCheck(iconsToCheck) then
                        --Check if the given item is marked with one of the iconIds
                        return FCOIS.IsMarked(bag, slot, iconsToCheck)
                    else
                        return false
                    end

                    --Check the filters here:
                elseif (FCOFilterId ~= nil and (FCOFilterId == -1 or type(FCOFilterId) == "number")) then
                    --Show all that are not marked with any FCO ItemSaver icon
                    if FCOFilterId == 0 then
                        return not FCOIS.IsMarked(bag, slot, -1)

                        --Icons 1 (locked) & 13, 14, 15 and 16 belong together to the lock & dynamic icons
                        --If any of the icons will be checked, ALL of the icons must be checked
                    elseif FCOFilterId == FCOIS_CON_FILTER_BUTTON_LOCKDYN then
                        --Table with the icons to check. Key can be any value. Value msut be the iconId or -1 for all icons.
                        local iconsToCheck = {}
                        iconsToCheck["locked"] 	 = FCOIS_CON_ICON_LOCK
                        --Add the icons to the check table now according to the filterId's "type"
                        addToIconsChecktable("dynamic", iconsToCheck)
                        --Check if icons are inside the table
                        if checkIfIconsToCheck(iconsToCheck) then
                            --Check if the given item is marked with one of the iconIds
                            return FCOIS.IsMarked(bag, slot, iconsToCheck)
                        else
                            return false
                        end

                        --Icons 2, 4, 6, 7 and 8 belong together to the gear sets
                        --If any of the icons will be checked, ALL of the icons must be checked
                    elseif FCOFilterId == FCOIS_CON_FILTER_BUTTON_GEARSETS then
                        --Table with the icons to check. Key can be any value. Value msut be the iconId or -1 for all icons.
                        local iconsToCheck = {}
                        --Add the icons to the check table now according to the filterId's "type"
                        addToIconsChecktable("gear", iconsToCheck)
                        --Check if icons are inside the table
                        if checkIfIconsToCheck(iconsToCheck) then
                            --Check if the given item is marked with one of the iconIds
                            return FCOIS.IsMarked(bag, slot, iconsToCheck)
                        else
                            return false
                        end

                        --Icons 3, 9 and 10 belong together to the research/deconstruction/improvement filter
                        --If any of the icons will be checked, ALL of the icons must be checked
                    elseif FCOFilterId == FCOIS_CON_FILTER_BUTTON_RESDECIMP then
                        --Table with the icons to check. Key can be any value. Value msut be the iconId or -1 for all icons.
                        local iconsToCheck = {}
                        iconsToCheck["research"] 	   = FCOIS_CON_ICON_RESEARCH
                        iconsToCheck["deconstruction"] = FCOIS_CON_ICON_DECONSTRUCTION
                        iconsToCheck["improvement"]    = FCOIS_CON_ICON_IMPROVEMENT
                        --Check if the given item is marked with one of the iconIds
                        return FCOIS.IsMarked(bag, slot, iconsToCheck)

                        --Icons 5, 11 and 12 belong together to the sell/sell at guild store/intricate filter
                        --If any of the icons will be checked, ALL of the icons must be checked
                    elseif FCOFilterId == FCOIS_CON_FILTER_BUTTON_SELLGUILDINT then
                        --Table with the icons to check. Key can be any value. Value msut be the iconId or -1 for all icons.
                        local iconsToCheck = {}
                        iconsToCheck["sell"] 	            = FCOIS_CON_ICON_SELL
                        iconsToCheck["sellToGuildStore"]    = FCOIS_CON_ICON_SELL_AT_GUILDSTORE
                        iconsToCheck["intricate"]           = FCOIS_CON_ICON_INTRICATE
                        --Check if the given item is marked with one of the iconIds
                        return FCOIS.IsMarked(bag, slot, iconsToCheck)

                    else
                        return FCOIS.IsMarked(bag, slot, FCOFilterId)
                    end
                else
                    --Parameters are wrong, return true to show the item (don't filter it)
                    return true
                end
            end
        end

        --Function to check if icon is enabled and add it to the dropdown callback table
        local function addToDropdownCallbackTable(dropdownCallbackTable, iconId, entryData)
            if iconId == nil or iconId == 0 or iconId == -1 or isIconEnabled[iconId] then
                table.insert(dropdownCallbackTable, entryData)
            end
        end

        --[[
            This table is processed within Advanced Filters and it's contents are added to Advanced Filter's
            callback table. The string value for name is the relevant key for the language table.
          ]]
        local FCOItemSaverDropdownCallback = {}
        addToDropdownCallbackTable(FCOItemSaverDropdownCallback, -1, { name = "FCOMarkedAll",       filterCallback = GetFilterCallbackForFCOMarked(-1, nil)})
        addToDropdownCallbackTable(FCOItemSaverDropdownCallback, 0, { name = "FCOMarkedNone",       filterCallback = GetFilterCallbackForFCOMarked(0, nil)})
        addToDropdownCallbackTable(FCOItemSaverDropdownCallback, nil, { name = "FCOMarkedFilter1",  filterCallback = GetFilterCallbackForFCOMarked(FCOIS_CON_FILTER_BUTTON_LOCKDYN, nil)}) -- Lock & dynamic
        addToDropdownCallbackTable(FCOItemSaverDropdownCallback, -1, { name = "FCOMarkedLocked",    filterCallback = GetFilterCallbackForFCOMarked(nil, FCOIS_CON_ICON_LOCK)})
        addToDropdownCallbackTable(FCOItemSaverDropdownCallback, nil, { name = "FCOMarkedDynamic",  filterCallback = GetFilterCallbackForFCOMarked("dynamic", nil)})
        addToDropdownCallbackTable(FCOItemSaverDropdownCallback, nil, { name = "FCOMarkedFilter2",  filterCallback = GetFilterCallbackForFCOMarked(FCOIS_CON_FILTER_BUTTON_GEARSETS, nil)}) -- Gear sets
        addToDropdownCallbackTable(FCOItemSaverDropdownCallback, nil, { name = "FCOMarkedFilter3",  filterCallback = GetFilterCallbackForFCOMarked(FCOIS_CON_FILTER_BUTTON_RESDECIMP, nil)}) -- Res, dec, imp
        addToDropdownCallbackTable(FCOItemSaverDropdownCallback, -1, { name = "FCOMarkedRes",       filterCallback = GetFilterCallbackForFCOMarked(nil, FCOIS_CON_ICON_RESEARCH)})
        addToDropdownCallbackTable(FCOItemSaverDropdownCallback, -1, { name = "FCOMarkedDec",       filterCallback = GetFilterCallbackForFCOMarked(nil, FCOIS_CON_ICON_DECONSTRUCTION)})
        addToDropdownCallbackTable(FCOItemSaverDropdownCallback, -1, { name = "FCOMarkedImp",       filterCallback = GetFilterCallbackForFCOMarked(nil, FCOIS_CON_ICON_IMPROVEMENT)})
        addToDropdownCallbackTable(FCOItemSaverDropdownCallback, nil, { name = "FCOMarkedFilter4",  filterCallback = GetFilterCallbackForFCOMarked(FCOIS_CON_FILTER_BUTTON_SELLGUILDINT, nil)}) -- Sell, guild, int
        addToDropdownCallbackTable(FCOItemSaverDropdownCallback, -1, { name = "FCOMarkedSell",      filterCallback = GetFilterCallbackForFCOMarked(nil, FCOIS_CON_ICON_SELL)})
        addToDropdownCallbackTable(FCOItemSaverDropdownCallback, -1, { name = "FCOMarkedSellGuild", filterCallback = GetFilterCallbackForFCOMarked(nil, FCOIS_CON_ICON_SELL_AT_GUILDSTORE)})
        addToDropdownCallbackTable(FCOItemSaverDropdownCallback, -1, { name = "FCOMarkedInt",       filterCallback = GetFilterCallbackForFCOMarked(nil, FCOIS_CON_ICON_INTRICATE)})

        local FCOItemSaverDynamicDropdownCallback = {}
        --Add the "all dynmic icons" entry
        table.insert(FCOItemSaverDynamicDropdownCallback, { name = "FCOMarkedDynamicAll", filterCallback = GetFilterCallbackForFCOMarked("dynamicAndGear", nil)})
        table.insert(FCOItemSaverDynamicDropdownCallback, { name = "FCOMarkedDynamicWithoutGearAll", filterCallback = GetFilterCallbackForFCOMarked("dynamic", nil)})
        --Add the dynamic icons
        for dynIconNr = 1, numDynamicIcons, 1 do
            local dynIconId = _G["FCOIS_CON_ICON_DYNAMIC_" .. tostring(dynIconNr)]
            addToDropdownCallbackTable(FCOItemSaverDynamicDropdownCallback, dynIconId, { name = "FCOMarkedDynamic" ..tostring(dynIconNr), filterCallback = GetFilterCallbackForFCOMarked(nil, dynIconId)})
        end
        local FCOItemSaverGearDropdownCallback = {}
        --Add the "all gear icons" entry
        table.insert(FCOItemSaverGearDropdownCallback, { name = "FCOMarkedGearAll", filterCallback = GetFilterCallbackForFCOMarked("gear", nil)})
        --Add the normal gear icons
        for gearIconNr = 1, numGearSetsStatic, 1 do
            local gearIconId = _G["FCOIS_CON_ICON_GEAR_" .. tostring(gearIconNr)]
            addToDropdownCallbackTable(FCOItemSaverGearDropdownCallback, gearIconId, { name = "FCOMarkedGear" ..tostring(gearIconNr), filterCallback = GetFilterCallbackForFCOMarked(nil, gearIconId)})
        end
        --Add the dynamic gear icons
        local gearSetNr = numGearSetsStatic
        for dynIconNr = 1, numDynamicIcons, 1 do
            local dynMarkerIcon = _G["FCOIS_CON_ICON_DYNAMIC_" .. tostring(dynIconNr)]
            local isDynGearIcon = isGearIcon[dynMarkerIcon] or false
            if isDynGearIcon then
                gearSetNr = gearSetNr + 1
                addToDropdownCallbackTable(FCOItemSaverGearDropdownCallback, dynMarkerIcon, { name = "FCOMarkedGear" ..tostring(gearSetNr), filterCallback = GetFilterCallbackForFCOMarked(nil, dynMarkerIcon)})
            end
        end

        --The deafult gear set texts
        local defaultGearSetTexts = {}
        defaultGearSetTexts["en"] = {}
        defaultGearSetTexts["de"] = {}
        defaultGearSetTexts["fr"] = {}
        defaultGearSetTexts["ru"] = {}
        defaultGearSetTexts["es"] = {}
        defaultGearSetTexts["jp"] = {}
        for i=1, numGearSets, 1 do
            --english
            defaultGearSetTexts["en"][i] = "Gear set " .. tostring(i)
            --german
            defaultGearSetTexts["de"][i] = "Gear Set " .. tostring(i)
            --french
            defaultGearSetTexts["fr"][i] = "Set " .. tostring(i)
            --russian
            defaultGearSetTexts["ru"][i] = "комплекты передач " .. tostring(i)
            --spanish
            defaultGearSetTexts["es"][i] = "Equipamiento " .. tostring(i)
            --japanese
            defaultGearSetTexts["jp"][i] = "ギア " .. tostring(i)
        end

        --The deafult dynamic icons texts
        local defaultDynamicIconTexts = {}
        defaultDynamicIconTexts["en"] = {}
        defaultDynamicIconTexts["de"] = {}
        defaultDynamicIconTexts["fr"] = {}
        defaultDynamicIconTexts["ru"] = {}
        defaultDynamicIconTexts["es"] = {}
        defaultDynamicIconTexts["jp"] = {}
        local dynamicTexts = {}
        dynamicTexts[langu] = {}
        for dynIconNr = 1, numDynamicIcons, 1 do
            --english
            defaultDynamicIconTexts["en"][dynIconNr] = "Dynamic " .. tostring(dynIconNr)
            --german
            defaultDynamicIconTexts["de"][1] = "Dynamisch " .. tostring(dynIconNr)
            --french
            defaultDynamicIconTexts["fr"][1] = "Dynamique " .. tostring(dynIconNr)
            --russian
            defaultDynamicIconTexts["ru"][1] =  tostring(dynIconNr) .. "-й динамический"
            --spanish
            defaultDynamicIconTexts["es"][1] = "Dinámico " .. tostring(dynIconNr)
            --japanese
            defaultDynamicIconTexts["jp"][1] = "ダイナミック " .. tostring(dynIconNr)
            if FCOIS.GetIconText ~= nil then
                dynamicTexts[langu]["dynamic" ..tostring(dynIconNr)] = FCOIS.GetIconText(_G["FCOIS_CON_ICON_DYNAMIC_" .. tostring(dynIconNr)])
            end
            --Dynamic icons
            if dynamicTexts[langu]["dynamic" .. tostring(dynIconNr)] == nil or dynamicTexts[langu]["dynamic" .. tostring(dynIconNr)] == "" then
                dynamicTexts[langu]["dynamic" .. tostring(dynIconNr)] = defaultDynamicIconTexts[langu][dynIconNr]
            end
        end
        --Get the gear set & dyanmic texts
        local gearSetTexts = {}
        gearSetTexts[langu] = {}
        for gearIconNr = 1, numGearSets, 1 do
            local gearIconConstant = ""
            --Static gear set icons
            if gearIconNr <= numGearSetsStatic then
                gearIconConstant = _G["FCOIS_CON_ICON_GEAR_" .. tostring(gearIconNr)]
            else
                --Dynamic icons marked as gear
                --Get the dynamic icon for the current gear number
                local dynIconId = gearToIcon[gearIconNr]
                --Check if the icon is dynamic and marked as gear
                if isGearIcon[dynIconId] then
                    --Get the dynamic icon Nr for the icon Id
                    local dynIconNr = iconToDynamic[dynIconId]
                    gearIconConstant = _G["FCOIS_CON_ICON_DYNAMIC_" .. tostring(dynIconNr)]
                end
            end
            if FCOIS.GetIconText ~= nil then
                local gearNameText = FCOIS.GetIconText(gearIconConstant)
                gearSetTexts[langu]["gear" ..tostring(gearIconNr)] = gearNameText
            end
            --Gear set icons
            local currentGearNrText = gearSetTexts[langu]["gear" .. tostring(gearIconNr)]
            if currentGearNrText == nil or currentGearNrText == "" then
                gearSetTexts[langu]["gear" .. tostring(gearIconNr)] = defaultGearSetTexts[langu][gearIconNr]
            end
        end

        --[[
            There are four potential tables for this section - enStrings (English), deStrings (German),
            frStrings (French), ruStrings (Russian). Only enStrings is required. If other language tables are
            not included, the english table will automatically be used for those languages. If other languages
            are included, all language must share common keys.
          ]]
        local enFCOStrings = {
            ["FCOItemSaverSubMenu"] = "FCO ItemSaver",
            ["FCOMarkedAll"] 	 = "[FCOIS] All",
            ["FCOMarkedNone"] 	 = "Non marked",
            ["FCOMarkedFilter1"] = "Lock & dynamic",
            ["FCOMarkedLocked"]  = "Locked",
            ["FCOMarkedDynamic"] = "Dynamic",
            ["FCOMarkedFilter2"] = "Gear sets",
            ["FCOMarkedFilter3"] = "Research, decon. & improve",
            ["FCOMarkedRes"] 	 = "Research",
            ["FCOMarkedDec"] 	 = "Deconstruction",
            ["FCOMarkedImp"] 	 = "Improvement",
            ["FCOMarkedFilter4"] = "Sell, sell guild & intricate",
            ["FCOMarkedSell"] 	 = "Sell",
            ["FCOMarkedSellGuild"] 	 = "Sell at guild store",
            ["FCOMarkedInt"] 	 = "Intricate",
        }
        local deFCOStrings = {
            ["FCOItemSaverSubMenu"] = "FCO ItemSaver",
            ["FCOMarkedAll"] 	 = "[FCOIS] Alle",
            ["FCOMarkedNone"] 	 = "Nicht markierte",
            ["FCOMarkedFilter1"] = "Sperre & dynamisch",
            ["FCOMarkedLocked"]  = "Gesperrt",
            ["FCOMarkedDynamic"] = "Dynamisch",
            ["FCOMarkedFilter2"] = "Gear Sets",
            ["FCOMarkedFilter3"] = "Analyse, Ver- & Aufwerten",
            ["FCOMarkedRes"] 	 = "Analyse",
            ["FCOMarkedDec"] 	 = "Verwerten",
            ["FCOMarkedImp"] 	 = "Aufwerten",
            ["FCOMarkedFilter4"] = "Verkauf + Gildenshop & Aufwendig",
            ["FCOMarkedSell"] 	 = "Verkauf",
            ["FCOMarkedSellGuild"] 	 = "Verkauf im Gildenshop",
            ["FCOMarkedInt"] 	 = "Aufwendig",
        }
        local frFCOStrings = {
            ["FCOItemSaverSubMenu"] = "FCO ItemSaver",
            ["FCOMarkedAll"]     = "[FCOIS] Tous",
            ["FCOMarkedNone"]    = "Non marqués",
            ["FCOMarkedFilter1"] = "Bloqués & dynamique",
            ["FCOMarkedLocked"]  = "Bloqués",
            ["FCOMarkedDynamic"] = "Dynamique",
            ["FCOMarkedFilter2"] = "Sets",
            ["FCOMarkedFilter3"] = "Recherche, démontage & amélio.",
            ["FCOMarkedRes"]     = "Analyse",
            ["FCOMarkedDec"]     = "Démontage",
            ["FCOMarkedImp"]     = "Amélioration",
            ["FCOMarkedFilter4"] = "Vendre + magasin de guilde & complexe",
            ["FCOMarkedSell"] 	 = "Vendre",
            ["FCOMarkedSellGuild"] 	 = "Vendez au magasin de guilde",
            ["FCOMarkedInt"] 	 = "Complexe",
        }
        local ruFCOStrings = {
            ["FCOItemSaverSubMenu"] = "FCO ItemSaver",
            ["FCOMarkedAll"] 	 = "[FCOIS] Все",
            ["FCOMarkedNone"] 	 = "Не отмечено",
            ["FCOMarkedFilter1"] = "Замок & динамический",
            ["FCOMarkedLocked"]  = "запертый",
            ["FCOMarkedDynamic"] = "динамические",
            ["FCOMarkedFilter2"] = "комплекты передач",
            ["FCOMarkedFilter3"] = "Исследование, деконструкция и улучшение",
            ["FCOMarkedRes"] 	 = "Исследование",
            ["FCOMarkedDec"] 	 = "деконструкция",
            ["FCOMarkedImp"] 	 = "улучшение",
            ["FCOMarkedFilter4"] = "Продать + магазин гильдии и замысловатый",
            ["FCOMarkedSell"] 	 = "Продать",
            ["FCOMarkedSellGuild"] 	 = "Продать в магазине гильдии",
            ["FCOMarkedInt"] 	 = "запутанный",
        }
        local esFCOStrings = {
            ["FCOItemSaverSubMenu"] = "FCO ItemSaver",
            ["FCOMarkedAll"] 	 = "[FCOIS] Todos",
            ["FCOMarkedNone"] 	 = "No marcar",
            ["FCOMarkedFilter1"] = "Bloquear & dinámico",
            ["FCOMarkedLocked"]  = "Bloquear",
            ["FCOMarkedDynamic"] = "Dinámico",
            ["FCOMarkedFilter2"] = "Equipamientos",
            ["FCOMarkedFilter3"] = "Investig., descon. & mejorar",
            ["FCOMarkedRes"] 	 = "Investigacion",
            ["FCOMarkedDec"] 	 = "Desconstruccion",
            ["FCOMarkedImp"] 	 = "Mejora",
            ["FCOMarkedFilter4"] = "Vender + corp. estore & compleja",
            ["FCOMarkedSell"] 	 = "Vender",
            ["FCOMarkedSellGuild"] 	 = "Vender a estore de copr.",
            ["FCOMarkedInt"] 	 = "Compleja",
        }
        local jpFCOStrings = {
            ["FCOItemSaverSubMenu"] = "FCO ItemSaver",
            ["FCOMarkedAll"]         = "[FCOIS] 全て",
            ["FCOMarkedNone"]        = "マーク無し",
            ["FCOMarkedFilter1"] = "ロック & ダイナミック",
            ["FCOMarkedLocked"]  = "ロック済み",
            ["FCOMarkedDynamic"] = "ダイナミック",
            ["FCOMarkedFilter2"] = "ギアセット",
            ["FCOMarkedFilter3"] = "研究, 破壊 & 改良",
            ["FCOMarkedRes"]     = "研究",
            ["FCOMarkedDec"]     = "破壊",
            ["FCOMarkedImp"]     = "改良",
            ["FCOMarkedFilter4"] = "売却 + ギルドストア & 複雑",
            ["FCOMarkedSell"]    = "売却",
            ["FCOMarkedSellGuild"] = "ギルドストアで売却",
            ["FCOMarkedInt"]     = "複雑",
        }

        ------------------------------------------------------------------------------------------------------------------------
        -- Normal icons
        ------------------------------------------------------------------------------------------------------------------------
        --[[----------------------------------------------------------------------------
            This section packages the data for Advanced Filters to use.
            All keys are required except for deStrings, frStrings, ruStrings, and
                esStrings as they correspond to optional languages. All language keys
                are assigned the same table here only to demonstrate the key names. You
                do not need to do this.
            The filterType key expects an ITEMFILTERTYPE constant provided by the game.
            The values for key/value pairs in the "subfilters" table can be any of the
                string keys from the "masterSubfilterData" table in
                AdvancedFiltersData.lua such as "All", "OneHanded", "Body", or
                "Blacksmithing".
            If your filterType is ITEMFILTERTYPE_ALL then the "subfilters" table must
                only contain the value "All".
            If the field "submenuName" is defined, your filters will be placed into a
                submenu in the dropdown list rather then in the root dropdown list
                itself. "submenuName" takes a string which matches a key in your strings
                table(s).
        --]]----------------------------------------------------------------------------
        local filterInformation = {
            submenuName = "FCOItemSaverSubMenu",
            callbackTable = FCOItemSaverDropdownCallback,
            filterType = ITEMFILTERTYPE_ALL,
            subfilters = {"All",},
            enStrings = enFCOStrings,
            deStrings = deFCOStrings,
            frStrings = frFCOStrings,
            ruStrings = ruFCOStrings,
            esStrings = esFCOStrings,
            jpStrings = jpFCOStrings,
        }
        --Register the filter
        AdvancedFilters_RegisterFilter(filterInformation)

        ------------------------------------------------------------------------------------------------------------------------
        -- GEAR icons
        ------------------------------------------------------------------------------------------------------------------------
        local enFCOStrings = {}
        local deFCOStrings = {}
        local frFCOStrings = {}
        local ruFCOStrings = {}
        local esFCOStrings = {}
        local jpFCOStrings = {}
        enFCOStrings["FCOItemSaverGearSubMenu"] = "FCO ItemSaver - Gear"
        deFCOStrings["FCOItemSaverGearSubMenu"] = "FCO ItemSaver - Gear"
        frFCOStrings["FCOItemSaverGearSubMenu"] = "FCO ItemSaver - Sets"
        ruFCOStrings["FCOItemSaverGearSubMenu"] = "FCO ItemSaver - комплекты передач"
        esFCOStrings["FCOItemSaverGearSubMenu"] = "FCO ItemSaver - Equipamientos"
        jpFCOStrings["FCOItemSaverGearSubMenu"] = "FCO ItemSaver - ギアセット"
        enFCOStrings["FCOMarkedGearAll"] = "All gear"
        deFCOStrings["FCOMarkedGearAll"] = "Alle Gears"
        frFCOStrings["FCOMarkedGearAll"] = "Tous les sets"
        ruFCOStrings["FCOMarkedGearAll"] = "Все наборы"
        esFCOStrings["FCOMarkedGearAll"] = "Todos los equipamientos"
        jpFCOStrings["FCOMarkedGearAll"] = "すべてのギアセット"
        for gearIconNr = 1, numGearSets, 1 do
            enFCOStrings["FCOMarkedGear" ..tostring(gearIconNr)]   = "" .. gearSetTexts[langu]["gear" ..tostring(gearIconNr)]
            deFCOStrings["FCOMarkedGear" ..tostring(gearIconNr)]   = "" .. gearSetTexts[langu]["gear" ..tostring(gearIconNr)]
            frFCOStrings["FCOMarkedGear" ..tostring(gearIconNr)]   = "" .. gearSetTexts[langu]["gear" ..tostring(gearIconNr)]
            ruFCOStrings["FCOMarkedGear" ..tostring(gearIconNr)]   = "" .. gearSetTexts[langu]["gear" ..tostring(gearIconNr)]
            esFCOStrings["FCOMarkedGear" ..tostring(gearIconNr)]   = "" .. gearSetTexts[langu]["gear" ..tostring(gearIconNr)]
            jpFCOStrings["FCOMarkedGear" ..tostring(gearIconNr)]   = "" .. gearSetTexts[langu]["gear" ..tostring(gearIconNr)]
        end

        local filterInformation = {
            submenuName = "FCOItemSaverGearSubMenu",
            callbackTable = FCOItemSaverGearDropdownCallback,
            filterType = ITEMFILTERTYPE_ALL,
            subfilters = {"All",},
            enStrings = enFCOStrings,
            deStrings = deFCOStrings,
            frStrings = frFCOStrings,
            ruStrings = ruFCOStrings,
            esStrings = esFCOStrings,
            jpStrings = jpFCOStrings,
        }
        --Register the gear filter
        AdvancedFilters_RegisterFilter(filterInformation)

        ------------------------------------------------------------------------------------------------------------------------
        -- Dynamic icons
        ------------------------------------------------------------------------------------------------------------------------
        enFCOStrings = {}
        deFCOStrings = {}
        frFCOStrings = {}
        ruFCOStrings = {}
        esFCOStrings = {}
        jpFCOStrings = {}
        enFCOStrings["FCOItemSaverDynamicSubMenu"] = "FCO ItemSaver - Dynamic"
        deFCOStrings["FCOItemSaverDynamicSubMenu"] = "FCO ItemSaver - Dynamisch"
        frFCOStrings["FCOItemSaverDynamicSubMenu"] = "FCO ItemSaver - Dynamique"
        ruFCOStrings["FCOItemSaverDynamicSubMenu"] = "FCO ItemSaver - динамические"
        esFCOStrings["FCOItemSaverDynamicSubMenu"] = "FCO ItemSaver - Dinámico"
        jpFCOStrings["FCOItemSaverDynamicSubMenu"] = "FCO ItemSaver - ダイナミック"
        enFCOStrings["FCOMarkedDynamicAll"] = "All dynamics"
        deFCOStrings["FCOMarkedDynamicAll"] = "Alle dynamischen"
        frFCOStrings["FCOMarkedDynamicAll"] = "Tous les dynamiques"
        ruFCOStrings["FCOMarkedDynamicAll"] = "Все динамические"
        esFCOStrings["FCOMarkedDynamicAll"] = "Todos los dinámicos"
        jpFCOStrings["FCOMarkedDynamicAll"] = "すべてのダイナミック"
        enFCOStrings["FCOMarkedDynamicWithoutGearAll"] = "All dynamics w/o gear"
        deFCOStrings["FCOMarkedDynamicWithoutGearAll"] = "Alle dynamischen ohne Gear"
        frFCOStrings["FCOMarkedDynamicWithoutGearAll"] = "Tous les dynamiques sans sets"
        ruFCOStrings["FCOMarkedDynamicWithoutGearAll"] = "Все динамические Без комплектов передач"
        esFCOStrings["FCOMarkedDynamicWithoutGearAll"] = "Todos los dinámicos sin equipamientos"
        jpFCOStrings["FCOMarkedDynamicWithoutGearAll"] = "すべてのダイナミック ギアセットなし"
        for dynIconNr = 1, numDynamicIcons, 1 do
            enFCOStrings["FCOMarkedDynamic" .. tostring(dynIconNr)]  = "" .. dynamicTexts[langu]["dynamic" .. tostring(dynIconNr)]
            deFCOStrings["FCOMarkedDynamic" .. tostring(dynIconNr)]  = "" .. dynamicTexts[langu]["dynamic" .. tostring(dynIconNr)]
            frFCOStrings["FCOMarkedDynamic" .. tostring(dynIconNr)]  = "" .. dynamicTexts[langu]["dynamic" .. tostring(dynIconNr)]
            ruFCOStrings["FCOMarkedDynamic" .. tostring(dynIconNr)]  = "" .. dynamicTexts[langu]["dynamic" .. tostring(dynIconNr)]
            esFCOStrings["FCOMarkedDynamic" .. tostring(dynIconNr)]  = "" .. dynamicTexts[langu]["dynamic" .. tostring(dynIconNr)]
            jpFCOStrings["FCOMarkedDynamic" .. tostring(dynIconNr)]  = "" .. dynamicTexts[langu]["dynamic" .. tostring(dynIconNr)]
        end
        filterInformation = {}
        filterInformation = {
            submenuName = "FCOItemSaverDynamicSubMenu",
            callbackTable = FCOItemSaverDynamicDropdownCallback,
            filterType = ITEMFILTERTYPE_ALL,
            subfilters = {"All",},
            enStrings = enFCOStrings,
            deStrings = deFCOStrings,
            frStrings = frFCOStrings,
            ruStrings = ruFCOStrings,
            esStrings = esFCOStrings,
            jpStrings = jpFCOStrings,
        }
        --Register the dynamic filter
        AdvancedFilters_RegisterFilter(filterInformation)
    end, 250)
end

--The callback function for the Advancedfilters FCOItemSaver marker icons plugin.
--Needs to be used so the dependecnies to FCOIS are used and the settings are loaded properly!
local function AF_FCOItemSaverFiltersPlugin_Loaded(event, addonName)
    if addonName ~= "AF_FCOItemSaverFilters" then return false end
    --Register the callback function for the player activated
    EVENT_MANAGER:RegisterForEvent("AF_FCOItemSaverFilterPluginPlayerActivated", EVENT_PLAYER_ACTIVATED, AF_FCOItemSaverFiltersPlugin_PlayerActivated)
    --Unregister this event again so it isn't fired again after this addon has beend recognized
    EVENT_MANAGER:UnregisterForEvent(AF_FCOItemSaverFilterPluginLoaded, EVENT_ADD_ON_LOADED)
end

--Register the addon's loaded callback function
EVENT_MANAGER:RegisterForEvent("AF_FCOItemSaverFilterPluginLoaded", EVENT_ADD_ON_LOADED, AF_FCOItemSaverFiltersPlugin_Loaded)
