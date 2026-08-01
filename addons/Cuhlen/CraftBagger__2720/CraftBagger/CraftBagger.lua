CraftBagger = {}
CraftBagger.Name = "CraftBagger"
CraftBagger.Version = 1.073
CraftBagger.savedVariables = {}
CraftBagger.Defaults = {
    Items = {},
    AppendDateTime = 0,
    DateTimeFormatStr = "yyyyMMdd-HHmmss",
    EnableStartupMessage = true
}

function CraftBagger:ConfigureSettings()
    if not LibAddonMenu2 then
        return
    end

    CraftBagger.PanelName = "CraftBaggerSettingsPanel"

    CraftBagger.PanelData = {
        type = "panel",
        name = CraftBagger.Name,
        displayname = CraftBagger.Name,
        author = "Cuhlen (@Tooslow001) Version: " .. CraftBagger.Version,
        version = CraftBagger.Version,
		registerForDefaults = true,
		website = "https://www.esoui.com/downloads/info2720-CraftBagger.html"
    }
    
    CraftBagger.OptionsTable = {
        { 
            type = "checkbox", 
            name = "Enable the Startup Message", 
            tooltip = "This setting enables the CraftBagger startup message",
            getFunc = function() return CraftBagger.savedVariables.EnableStartupMessage end,
            setFunc = function(value) CraftBagger.savedVariables.EnableStartupMessage = value end,
            width = "full", 
            default = CraftBagger.Defaults.EnableStartupMessage, 
        },
		{
			type = "header",
			name = "CSV FILE"
		},
        {
            type = "checkbox",
            name = "Append DateTime stamp to CSV",
            tooltip = "Appends the export date & time to the resulting csv file instead of overwriting it",
            getFunc = function() return CraftBagger.savedVariables.AppendDateTime end,
            setFunc = function(value) CraftBagger.savedVariables.AppendDateTime = value end,
            default = CraftBagger.Defaults.AppendDateTime,
            warning = "Changing this value requires re-saving the craftbag (/savecraftbag)",
            width = "full", 
        },
        {
            type = "editbox",
            name = "Date Time Format String",
            tooltip = "Powershell compatible Date Time Format String (Only valid if 'Append DateTime stamp to CSV' is TRUE",
            getFunc = function() return CraftBagger.savedVariables.DateTimeFormatStr end,
            setFunc = function(value) CraftBagger.savedVariables.DateTimeFormatStr = value end,
            isMultiline = false,
            default = CraftBagger.Defaults.DateTimeFormatStr,
            warning = "Changing this value requires re-saving the craftbag (/savecraftbag)",
            width = "full", 
        },
    }
    
    LibAddonMenu2:RegisterAddonPanel(CraftBagger.PanelName, CraftBagger.PanelData)
    LibAddonMenu2:RegisterOptionControls(CraftBagger.PanelName, CraftBagger.OptionsTable)
end

function CraftBagger:Initialize()
    CraftBagger.savedVariables = ZO_SavedVars:NewAccountWide("CraftBaggerData", CraftBagger.Version, nil, CraftBagger.Defaults, nil)

    EVENT_MANAGER:UnregisterForEvent(CraftBagger.Name, EVENT_ADD_ON_LOADED)
end

function CraftBagger.OnAddOnLoaded(event, addonName)
    if addonName ~= CraftBagger.Name then
        return
    end

    CraftBagger:Initialize()
    CraftBagger:ConfigureSettings()
end

function CraftBagger:DoSerialize(option)
    d(CraftBagger:Tag() .. " Retrieving craftbag items...")

    CraftBagger.savedVariables.Items = CraftBagger.GetCraftbagItems()
    local itemCount = table.getn(CraftBagger.savedVariables.Items)

    d(CraftBagger:Tag() .. " Total unique items=" .. itemCount)
end

function CraftBagger.GetItemPrice(itemLink)
    if (LibPrice) then
        gold,source,fieldname = LibPrice.ItemLinkToPriceGold(itemLink, "ttc", "mm", "att")

        if (gold) then
            return gold
        end
    end

    return 0
end

function CraftBagger.OnPlayerActivated()
	if CraftBagger.savedVariables.EnableStartupMessage then
		d("|ceeeeeeCraftBagger v"..CraftBagger.Version.." by |c3D85C6Cuhlen (@TooSlow001)|r")
	end

	EVENT_MANAGER:UnregisterForEvent(CraftBagger.Name, EVENT_PLAYER_ACTIVATED)
end


function CraftBagger:GetCraftbagItems()
    local slotId = GetNextVirtualBagSlotId(nil)
    local itemData = {}
	
	while (slotId) do
		local itemLink = GetItemLink(BAG_VIRTUAL, slotId)
		
		if (itemLink ~= "") then
            local icon, qnt = GetItemInfo(BAG_VIRTUAL, slotId)
            local itemName = GetItemLinkName(itemLink)
            local suggestedPrice = CraftBagger.GetItemPrice(itemLink)

            local item = {
                name = LocalizeString("<<1>>", itemName),
                quantity = qnt,
                price = suggestedPrice
            }

            table.insert(itemData, item)
		end
		
		slotId = GetNextVirtualBagSlotId(slotId)
	end
	
	return itemData
end

function CraftBagger:Tag()
    return "[CRAFTBAGGER " .. tostring(CraftBagger.Version) .. "]"
end

EVENT_MANAGER:RegisterForEvent(CraftBagger.Name, EVENT_ADD_ON_LOADED, CraftBagger.OnAddOnLoaded)
EVENT_MANAGER:RegisterForEvent(CraftBagger.Name, EVENT_PLAYER_ACTIVATED, CraftBagger.OnPlayerActivated)

SLASH_COMMANDS['/savecraftbag'] = CraftBagger.DoSerialize

