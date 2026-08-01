--------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ItemAlert.CreateSpecialThanksFooter(panel)

    local control = CreateControl("$(parent)SpecialThanksFooter", panel, CT_LABEL)

    control:SetAnchor(BOTTOMLEFT, panel, BOTTOMLEFT, 0, 70)
    control:SetText("|c00FEF1Special thanks to |cb062ff@Little_Insect|r|c00FEF1 and the ESO addon community!|r")
    control:SetFont("ZoFontGameBoldShadow")
    control:SetScale(4.5)

    return control

end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ItemAlert.InitializeLAM2Panel()

    local PanelData =
    {
        type = "panel",
        name = ItemAlert.FancyName,
        author = ItemAlert.Author.."|r",
        version = ItemAlert.GetFriendlyVersion(),
        slashCommand = "/iamenu",
        registerForRefresh 	= true,
        registerForDefaults = false,
    }

    ItemAlert.PanelData = ItemAlertLam2:RegisterAddonPanel(ItemAlert.PanelTitle.."LAM2Options", PanelData)

end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ItemAlert.InitializeLAM2OptionData()

    ItemAlertLam2:RegisterOptionControls(ItemAlert.PanelTitle.."LAM2Options", {})

    ItemAlert.OptionsData = {}

    table.insert(ItemAlert.OptionsData, {
        type = "description",
        name = "Play sound and display loot totals for special items such as Potent Nirncrux.",
        width = "full",
    })

    local generalSettings = {}

    table.insert(ItemAlert.OptionsData, {
        type = "submenu",
        name = "|c00e0ffGeneral Settings|r",
        controls = generalSettings,
    })

    table.insert(generalSettings, {
        type = "checkbox",
        name = "ItemAlert On/Off",
        tooltip = "Show Display Bar On/Off.",
        getFunc = function() return ItemAlert.GetAccountSetting("ShowDisplayBar") end,
        setFunc = function(value) ItemAlert.UpdateAccountSetting("ShowDisplayBar", value) ItemAlert.SaveAccountSettings() if ItemAlert.GetAccountSetting("ShowDisplayBar") == true then ItemAlert.ShowDisplayBar() else ItemAlert.HideDisplayBar() end end,
    })

    table.insert(generalSettings, {
        type = "checkbox",
        name = "Lock On/Off",
        tooltip = "Lock Information Bar Placement On/Off.",
        getFunc = function() ItemAlert.GetAccountSetting("Lock") end,
        setFunc = function(value) ItemAlert.UpdateAccountSetting("Lock", value) ItemAlert.SaveAccountSettings() ItemAlert.Lock() end,
    })

    table.insert(generalSettings, {
        type = "checkbox",
        name = "Show Alert Chat On/Off",
        tooltip = "Turn Item Alerts In Chat On/Off.",
        getFunc = function() return ItemAlert.GetAccountSetting("Chat") end,
        setFunc = function(value) ItemAlert.UpdateAccountSetting("Chat", value) ItemAlert.SaveAccountSettings() end,
    })

    table.insert(generalSettings, {
        type = "checkbox",
        name = "Turn Sounds On/Off",
        tooltip = "Turn Sounds On/Off.",
        getFunc = function() return ItemAlert.GetAccountSetting("Sound") end,
        setFunc = function(value) ItemAlert.UpdateAccountSetting("Sound", value) ItemAlert.SaveAccountSettings() end,
    })

    table.insert(generalSettings, {
        type = "button",
        name = "Reset Totals",
        func = function() ItemAlert.Reset() end,
        width = "full",
    })

    table.insert(generalSettings, {
        type = "divider",
        height = 15,
        alpha = 0.5,
        width = "full"
    })

    table.insert(generalSettings, {
        type = "editbox",
        name = "Settings - Use the box below to copy and paste settings across accounts.",
        tooltip = "Note: Use Crtl-A To Select All, Then CTRL-C To Copy To Clipboard. After, You Can Use CTRL-V To Paste It Into Another Account.",
        getFunc = function() return ItemAlert.GetSettings() end,
        setFunc = function(value) ItemAlert.SetSettings(value) end,
        isMultiline = true,
        isExtraWide = true,
        --requiresReload = true,
        warning = "Will need to reload the UI.",
        width = "full",
        default = "",
    })

    table.insert(generalSettings, {
        type = "button",
        name = "Reload UI",
        func = function() ReloadUI() end,
        width = "full",
    })

    local informationBarSettings = {}

    table.insert(ItemAlert.OptionsData, {
        type = "submenu",
        name = "|c00beffInformation Bar Settings|r",
        controls = informationBarSettings,
    })

    table.insert(informationBarSettings, {
        type = "checkbox",
        name = "Force Bar CenterX On/Off",
        tooltip = "Make The Information Bar Centered Horizontally On/Off.",
        getFunc = function() return ItemAlert.GetAccountSetting("ForceCenter") end,
        setFunc = function(value) ItemAlert.UpdateAccountSetting("ForceCenter", value) ItemAlert.SaveAccountSettings() ItemAlert.UpdateDisplayBar() end,
    })

    table.insert(informationBarSettings, {
        type = "checkbox",
        name = "Item Total On/Off",
        tooltip = "Show Information Bar Item Total On/Off.",
        getFunc = function() return ItemAlert.GetAccountSetting("DisplayItemTotal") end,
        setFunc = function(value) ItemAlert.UpdateAccountSetting("DisplayItemTotal", value) ItemAlert.SaveAccountSettings() ItemAlert.UpdateDisplayBar() end,
    })

    table.insert(informationBarSettings, {
        type = "checkbox",
        name = "Node Total On/Off",
        tooltip = "Show Information Bar Node Total On/Off.",
        getFunc = function() return ItemAlert.GetAccountSetting("DisplayNodeTotal") end,
        setFunc = function(value) ItemAlert.UpdateAccountSetting("DisplayNodeTotal", value) ItemAlert.SaveAccountSettings() ItemAlert.UpdateDisplayBar() end,
    })

    table.insert(informationBarSettings, {
        type = "checkbox",
        name = "Elapsed Time On/Off",
        tooltip = "Show Information Bar Elapsed Hours And Minutes On/Off.",
        getFunc = function() return ItemAlert.GetAccountSetting("DisplayMinutes") end,
        setFunc = function(value) ItemAlert.UpdateAccountSetting("DisplayMinutes", value) ItemAlert.SaveAccountSettings() ItemAlert.UpdateDisplayBar() end,
    })

    table.insert(informationBarSettings, {
        type = "checkbox",
        name = "Text On/Off",
        tooltip = "Show Information Bar Text On/Off.",
        getFunc = function() return ItemAlert.GetAccountSetting("DisplayText") end,
        setFunc = function(value) ItemAlert.UpdateAccountSetting("DisplayText", value) ItemAlert.SaveAccountSettings() ItemAlert.UpdateDisplayBar() end,
    })

    table.insert(informationBarSettings, {
        type = "colorpicker",
        name = "Text Color",
        tooltip = "Change The Information Bar Text Color.",
        getFunc = function() return ItemAlert.ConvertHexToRGBA(ItemAlert.GetAccountSetting("TextColor")) end,
        setFunc = function(r, g, b, a) ItemAlert.UpdateAccountSetting("TextColor", ItemAlert.ConvertRGBAToHex(r, g, b, a)) ItemAlert.SaveAccountSettings() ItemAlert.UpdateDisplayBar() end,
        width = "full",
    })

    table.insert(informationBarSettings, {
        type = "colorpicker",
        name = "Totals Color",
        tooltip = "Change The Information Bar Totals Color.",
        getFunc = function() return ItemAlert.ConvertHexToRGBA(ItemAlert.GetAccountSetting("TotalsColor"))  end,
        setFunc = function(r, g, b, a) ItemAlert.UpdateAccountSetting("TotalsColor", ItemAlert.ConvertRGBAToHex(r, g, b, a)) ItemAlert.SaveAccountSettings() ItemAlert.UpdateDisplayBar() end,
        width = "full",
    })

    table.insert(informationBarSettings, {
        type = "colorpicker",
        name = "Background Color",
        tooltip = "Change The Information Bar Background Color.",
        getFunc = function() return tonumber(ItemAlert.GetAccountSetting("BackgroundColorR")), tonumber(ItemAlert.GetAccountSetting("BackgroundColorG")), tonumber(ItemAlert.GetAccountSetting("BackgroundColorB")), tonumber(ItemAlert.GetAccountSetting("BackgroundColorA")) end,
        setFunc = function(r, g, b, a) ItemAlert.UpdateAccountSetting("BackgroundColorR", r) ItemAlert.UpdateAccountSetting("BackgroundColorG", g) ItemAlert.UpdateAccountSetting("BackgroundColorB", b) ItemAlert.UpdateAccountSetting("BackgroundColorA", a) ItemAlert.SaveAccountSettings() ItemAlert.UpdateDisplayBar() end,
        width = "full",
    })

    table.insert(informationBarSettings, {
        type = "dropdown",
        name = "Font Style",
        tooltip = "Select A Font Style.",
        scrollable = true,
        choices = ItemAlertLf.GetFontNameList(),
        getFunc = function() return ItemAlert.GetAccountSetting("FontStyle") end,
        setFunc = function(value) ItemAlert.UpdateAccountSetting("FontStyle", value) ItemAlert.SaveAccountSettings() ItemAlert.UpdateDisplayBar() end,
        width = "full",
    })

    table.insert(informationBarSettings, {
        type = "slider",
        name = "Font Size",
        tooltip = "Adjust The Font Size Of The Text Display.",
        min = 12,
        max = 48,
        step = 1,
        default = 18,
        getFunc = function() return ItemAlert.GetAccountSetting("FontSize") end,
        setFunc = function(value) ItemAlert.UpdateAccountSetting("FontSize", value) ItemAlert.SaveAccountSettings() ItemAlert.UpdateDisplayBar() end,
    })

    table.insert(informationBarSettings, {
        type = "dropdown",
        name = "Font Spacing",
        tooltip = "How Far Apart Should Each Item Be On The Text Display.",
        choices = { "Normal", "Compact" },
        getFunc = function() return ItemAlert.GetAccountSetting("FontSpacing") end,
        setFunc = function(value) ItemAlert.UpdateAccountSetting("FontSpacing", value) ItemAlert.SaveAccountSettings() ItemAlert.UpdateDisplayBar() end,
        width = "full",
    })

    table.insert(informationBarSettings, {
        type = "checkbox",
        name = "Punctuation On/Off",
        tooltip = "Replace Punctuation With Spaces?",
        getFunc = function() return ItemAlert.GetAccountSetting("Punctuation") end,
        setFunc = function(value) ItemAlert.UpdateAccountSetting("Punctuation", value) ItemAlert.SaveAccountSettings() ItemAlert.UpdateDisplayBar() end,
    })

    local displayItemSettings = {}

    table.insert(ItemAlert.OptionsData, {
        type = "submenu",
        name = "|c009cffItem Remove and Display Order Settings|r",
        controls = displayItemSettings,
    })

    table.insert(displayItemSettings, {
        type = "orderlistbox",
        name = "Tracked Item Display Order",
        tooltip = "Please Right-Click An Item In The Chat Window, Your Inventory, or Craft Bag To Add It",
        listEntries = ItemAlert.SortOrderEntries,
        disableDrag = true,
        disableButtons = false,
        showPosition = true,
        getFunc = function() return ItemAlert.SortOrderEntries end,
        minHeight = 150,
        setFunc = function(sortedSortListEntries) ItemAlert.SortOrderEntries = sortedSortListEntries ItemAlert.UpdateItemEntries(sortedSortListEntries) end,
        width="full",
        maxHeight = 150,
        disabled = function() return false end,
        reference = "ItemAlert_Settings_IconSortOrder_OrderListBox",
        default = ItemAlert.SortOrderEntries,
        addEntryDialog = {
            title="Add new item",
            text="Please Right-Click An Item In The Chat Window, Your Inventory, or Craft Bag To Add It. Items added here will not show up in the Tracked Item Settings until you reload UI or restart the game. The icon for the item will be updated the next time you loot it.",
            textType=TEXT_TYPE_ALL,
            validatesText = true,
            validator = function(text) return text ~= nil and text ~= "" end
        },
        -- (optional) function returning a boolean (true = added, false = not added) called as the entry get's added,
        --addEntryCallbackFunction = onAddEntryCallback,
        rowMaxLineCount = 1,
        rowSelectionTemplate = "ZO_ThinListHighlight",
        --An optional callback function when a row of the listEntries is selected.
        --rowSelectedCallback = function() ItemAlert.OnRowSelected(rowControl, previouslySelectedData, selectedData, reselectingDuringRebuild) end,
        showRemoveEntryButton = true,
        -- (optional) function returning a boolean (true = removed, false = not removed) called as the entry get's removed,
        --removeEntryCallbackFunction = function(orderListBox, selectedEntry, orderListBoxData) ItemAlert.Logger:Debug("Entry removed") return true end,
        askBeforeRemoveEntry = function() return true end,
    })

    local trackedItemSettings = {}

    table.insert(ItemAlert.OptionsData, {
        type = "submenu",
        name = "|c007bffTracked Item Settings|r",
        tooltip = "Important! Any Recently Added Items Will Not Show Up Here Until You Reload UI",
        controls = trackedItemSettings,
        reference = "TrackedItemSettingsSubmenu"
    })

    local sorted_items = {}

    for key, value in pairs(ItemAlert.GetAccountSpecialItems()) do

        table.insert(sorted_items, {key = key, value = value})

    end

    table.sort(sorted_items, function(a, b)

        return a.value < b.value

    end)

    for _, item in ipairs(sorted_items) do

        table.insert(trackedItemSettings, {
            type = "divider"
        })

        table.insert(trackedItemSettings, {
            type = "checkbox",
            name = "Display "..ItemAlert.ProperCase(item.key),
            default = true,
            getFunc = function() return ItemAlert.GetAccountSpecialItemDetail(item.key, "display") end,
            setFunc = function(value) ItemAlert.UpdateAccountSpecialItemDetail(item.key, "display", value) ItemAlert.SaveAccountSettings() ItemAlert.LoadAccountSettings() end,
            width = "full",
        })

        table.insert(trackedItemSettings, {
            type = "checkbox",
            name = "Animate Display",
            default = true,
            getFunc = function() return ItemAlert.GetAccountSpecialItemDetail(item.key, "animatedisplay") end,
            setFunc = function(value) ItemAlert.UpdateAccountSpecialItemDetail(item.key, "animatedisplay", value) ItemAlert.SaveAccountSettings() ItemAlert.LoadAccountSettings() end,
            width = "full",
        })

        table.insert(trackedItemSettings, {
            type = "checkbox",
            name = "Display Center Screen",
            default = true,
            getFunc = function() return ItemAlert.GetAccountSpecialItemDetail(item.key, "displayscreen") end,
            setFunc = function(value) ItemAlert.UpdateAccountSpecialItemDetail(item.key, "displayscreen", value) ItemAlert.SaveAccountSettings() ItemAlert.LoadAccountSettings() end,
            width = "full",
        })

        table.insert(trackedItemSettings, {
            type = "slider",
            name = "Display Alert Duration (Seconds)",
            tooltip = "How Many Seconds To Display An Alert Message.",
            min = 1, -- Minimum Duration in Seconds
            max = 10, -- Maximum Duration in Seconds
            step = 0.5,
            default = 3,
            getFunc = function() return ItemAlert.GetAccountSpecialItemDetail(item.key, "alertduration") end,
            setFunc = function(value) ItemAlert.UpdateAccountSpecialItemDetail(item.key, "alertduration", value) ItemAlert.SaveAccountSettings() ItemAlert.LoadAccountSettings() end,
        })

        table.insert(trackedItemSettings, {
            type = "editbox",
            name = "Display Name",
            getFunc = function() return ItemAlert.GetAccountSpecialItemDetail(item.key, "displayname") end,
            setFunc = function(value) ItemAlert.UpdateAccountSpecialItemDetail(item.key, "displayname", value) ItemAlert.SaveAccountSettings() ItemAlert.LoadAccountSettings() end,
        })

        table.insert(trackedItemSettings, {
            type = "slider",
            name = "Alert Sound",
            getFunc = function() return ItemAlert.GetIndexOfSound(ItemAlert.GetAccountSpecialItemDetail(item.key, "soundname")) end,
            setFunc = function(value)
                local soundName = ItemAlert.Sounds[value]
                local volume = ItemAlert.GetAccountSpecialItemDetail(item.key, "volume")
                ItemAlert.UpdateAccountSpecialItemDetail(item.key, "soundname", soundName)
                ItemAlert.SaveAccountSettings()
                ItemAlert.LoadAccountSettings()
                if value ~= 1 then
                    if soundName and SOUNDS and SOUNDS[soundName] then
                        for _ = 1, volume do
                            PlaySound(SOUNDS[soundName])
                        end
                    end
                end
                return
            end,
            min = 1,
            max = #ItemAlert.Sounds,
            step = 1,
            clampInput = true,
            clampFunction = function(value, min, max) return math.max(math.min(value, max), min) end,
            decimals = 0,
            autoSelect = true,
            inputLocation = "below",
            width = "full",
            default = 2,
        })

        table.insert(trackedItemSettings, {
            type = "slider",
            name = "Alert Volume",
            getFunc = function() return ItemAlert.GetAccountSpecialItemDetail(item.key, "volume") end,
            setFunc = function(value)
                local soundName = ItemAlert.GetAccountSpecialItemDetail(item.key, "soundname")
                local volume = value
                ItemAlert.UpdateAccountSpecialItemDetail(item.key, "volume", volume)
                ItemAlert.SaveAccountSettings()
                ItemAlert.LoadAccountSettings()
                for _ = 1, volume do
                    PlaySound(SOUNDS[soundName])
                end
                return
            end,
            min = 1,
            max = 25,
            step = 1,
            clampInput = true,
            clampFunction = function(value, min, max) return math.max(math.min(value, max), min) end,
            decimals = 0,
            autoSelect = true,
            inputLocation = "below",
            width = "full",
            default = 2,
        })

    end

    ItemAlert.OptionsPanel = ItemAlertLam2:RegisterOptionControls(ItemAlert.PanelTitle.."LAM2Options", ItemAlert.OptionsData)

end
