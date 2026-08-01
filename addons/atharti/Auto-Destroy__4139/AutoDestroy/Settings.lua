AD = AutoDestroy

local LAM = LibAddonMenu2

function AD.GetChoices()
    local choices = {}
    local values = {}

    for itemId, itemLink in pairs(AD.Settings.itemsList) do
        local name = GetItemLinkName(itemLink)
        table.insert(choices, name)
        table.insert(values, itemId)
    end

    return choices, values
end

function AD.RefreshDropdown()
    AD_CONTROL_NAME:UpdateChoices(AD.GetChoices())
    AD_CONTROL_NAME:UpdateValue()
end

function AD.ShowEnableSettingsDialogOne()
    local dialogParams = {
        callback = function()
            AD.Settings.autoDestroyEnabled = true
            AD.ScanAndDestroy()
        end,
        mainText = "Enabling this feature will instantly |cFF0000DESTROY|r items that you marked for Auto Destroy. And also will |cFF0000DESTROY|r these items as soon as they appear in your bag. Are you sure?",
		finishingCallback = function()
			MAIN_DESTROY_MODULE:UpdateValue(false)
		end
    }

    ZO_Dialogs_ShowDialog('AUTO_DESTROY_CONFIRMATION_DIALOG', dialogParams)
end

function AD.ShowEnableSettingsDialogTwo()
    local dialogParams = {
        callback = function()
            AD.Settings.destroyMaps = true
            AD.ScanAndDestroy()
        end,
        mainText = "Enabling this feature will auto-open all treasure map envelopes and |cFF0000DESTROY|r all treasure maps that you got, and will get except: |c008000Blackwood|r, |c008000Deadlands|r, |c008000High Isle|r, |c008000Telvanni Peninsula|r, |c008000Apocrypha|r, |c008000West Weald|r and |c008000Solstice|r zones. Are you sure?",
		finishingCallback = function()
			RAPE_TRASHURE:UpdateValue(false)
		end
    }

    ZO_Dialogs_ShowDialog('AUTO_DESTROY_CONFIRMATION_DIALOG', dialogParams)
end

function AD.SetupSettings()
    local panelData = {
        type = "panel",
        name = "AutoDestroy",
        displayName = "|cFFD700AutoDestroy|r",
        author = "|cFFD700@Atharti|r",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local optionsData = {
        {
            type = "checkbox",
            name = "Enable Auto Destroy",
            tooltip = "Toggle automatic destruction of specified items on inventory update.",
            getFunc = function() return AD.Settings.autoDestroyEnabled end,
            setFunc = function(value)
			    if value then
					AD.ShowEnableSettingsDialogOne()
				else
                	AD.Settings.autoDestroyEnabled = value
				end
            end,
            default = false,
			reference = "MAIN_DESTROY_MODULE"
        },
		{
            type = "checkbox",
            name = "Auto-Open Unknown And Destroy Base Game And Cheap DLC Treasure Maps",
            tooltip = "This feature will intantly |cFF0000DESTROY|r all treasure maps except: Blackwood, Deadlands, High Isle, Telvanni Peninsula, Apocrypha, West Weald and Solstice zones.",
            getFunc = function() return AD.Settings.destroyMaps end,
            setFunc = function(value)
				if value then
					AD.ShowEnableSettingsDialogTwo()
				else
					AD.Settings.destroyMaps = value
				end
            end,
            default = false,
			reference = "RAPE_TRASHURE"
        },
    }

    local selectedItemId

    local choices, values = AD.GetChoices()

    -- Create dropdown control for selecting an item to remove
    local destroyItemsDropdown = {
        type = "dropdown",
        name = "List Of Items To Destroy:",
        tooltip = "Select an item ID to remove from the AutoDestroy list.",
        choices = choices, 
        choicesValues = values,
        getFunc = function() return end,
        setFunc = function(value)
            selectedItemId = value
        end,
        width = "full",
		reference = "AD_CONTROL_NAME"
    }

    -- Create button to remove selected item from list
    local removeButton = {
        type = "button",
        name = "Remove from AutoDestroy list",
        tooltip = "Removes the selected item ID from the list.",
        width = "half",
        func = function()
            if selectedItemId and AD.Settings.itemsList[selectedItemId] then
                AD.Settings.itemsList[selectedItemId] = nil
                AD.RefreshDropdown()
            else
                d("|cFF0000[AutoDestroy]|r No item selected or item does not exist.")
            end
        end,
    }

    table.insert(optionsData, destroyItemsDropdown)
    table.insert(optionsData, removeButton)

    local panel = LAM:RegisterAddonPanel("AutoDestroyOptions", panelData)
    LAM:RegisterOptionControls("AutoDestroyOptions", optionsData)

    return panel
end