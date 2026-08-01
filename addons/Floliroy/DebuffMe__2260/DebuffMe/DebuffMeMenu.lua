DebuffMe = DebuffMe or {}
local DebuffMe = DebuffMe

local LAM2 = LibAddonMenu2

local DebuffToAdd = {
    name = "",
    abbreviation = "",
}
local DebuffSelected = ""

local function GetFormattedAbilityNameWithID(id)	--Fix to LUI extended conflict thank you Solinur and Wheels
	local name = DebuffMe.CustomAbilityNameWithID[id] or zo_strformat(SI_ABILITY_NAME, GetAbilityName(id))
	return name
end 

function DebuffMe.SearchForIdWithName(name)
    if name ~= "" then
        if tonumber(name) then
            if GetFormattedAbilityNameWithID(name) and GetFormattedAbilityNameWithID(name) ~= "" then
                DebuffToAdd.name = GetFormattedAbilityNameWithID(name)
                return name --actualy name is already the ID
            end
        else
            local upperName = string.upper(name)
            for i = 1, 130000 do
                if upperName == string.upper(GetFormattedAbilityNameWithID(i)) then
                    return i
                end
            end
        end

        d("|cffffffDebuff|r|cec3c00Me:\n|r|cffffffThe debuff|r |cec3c00" .. name .. "|r |cffffffdoes not exist, or can't be found.|r")
    else
        d("|cffffffDebuff|r|cec3c00Me:\n|r|cffffffYou need to type a debuff to add.|r")
    end

    return -1
end

-------------------------
---- Settings Window ----
-------------------------
function DebuffMe.CreateSettingsWindow()
	local panelData = {
		type = "panel",
		name = "DebuffMe",
		displayName = "Debuff|cec3c00Me|r",
		author = "Floliroy",
		version = DebuffMe.version,
		slashCommand = "/debuffme",
		registerForRefresh = true,
		registerForDefaults = true,
	}
	
	local cntrlOptionsPanel = LAM2:RegisterAddonPanel("DebuffMe_Settings", panelData)

	local optionsData = {
		{
			type = "header",
			name = "DebuffMe Settings",
		},
		{
			type = "description",
			text = "Choose here which debuff you want to show.",
		},
		{
			type = "dropdown",
			name = "Main Debuff (Middle White)",
			tooltip = "No number after the decimal point, neither abbreviation if debuff at 0.",
			choices = DebuffMe.DebuffList,
			default = DebuffMe.DebuffList[2],
			getFunc = function() return DebuffMe.DebuffList[DebuffMe.savedVariables.Debuff_Show[1]] end,
			setFunc = function(selected)
				for index, name in ipairs(DebuffMe.DebuffList) do
					if name == selected then
						DebuffMe.savedVariables.Debuff_Show[1] = index
						DebuffMe.Debuff_Show[1] = index
						break
					end
				end
			end,
            scrollable = true,
            sort = "name-up",
            reference = "MainDebuff_dropdown",
		},
        {
			type = "dropdown",
			name = "Secondary Debuff (Left Blue)",
			tooltip = "One number after the decimal point, and abbreviation if debuff at 0.",
			choices = DebuffMe.DebuffList,
			default = DebuffMe.DebuffList[4],
			getFunc = function() return DebuffMe.DebuffList[DebuffMe.savedVariables.Debuff_Show[2]] end,
			setFunc = function(selected)
				for index, name in ipairs(DebuffMe.DebuffList) do
					if name == selected then
						DebuffMe.savedVariables.Debuff_Show[2] = index
						DebuffMe.Debuff_Show[2] = index
						break
					end
				end
			end,
            scrollable = true,
            sort = "name-up",
            reference = "LeftDebuff_dropdown",
		},
        {
			type = "dropdown",
			name = "Secondary Debuff (Top Green)",
			tooltip = "One number after the decimal point, and abbreviation if debuff at 0.",
			choices = DebuffMe.DebuffList,
			default = DebuffMe.DebuffList[3],
			getFunc = function() return DebuffMe.DebuffList[DebuffMe.savedVariables.Debuff_Show[3]] end,
			setFunc = function(selected)
				for index, name in ipairs(DebuffMe.DebuffList) do
					if name == selected then
						DebuffMe.savedVariables.Debuff_Show[3] = index
						DebuffMe.Debuff_Show[3] = index
						break
					end
				end
			end,
            scrollable = true,
            sort = "name-up",
            reference = "TopDebuff_dropdown",
		},
        {
			type = "dropdown",
			name = "Secondary Debuff (Right Red)",
			tooltip = "One number after the decimal point, and abbreviation if debuff at 0.",
			choices = DebuffMe.DebuffList,
			default = DebuffMe.DebuffList[5],
			getFunc = function() return DebuffMe.DebuffList[DebuffMe.savedVariables.Debuff_Show[4]] end,
			setFunc = function(selected)
				for index, name in ipairs(DebuffMe.DebuffList) do
					if name == selected then
						DebuffMe.savedVariables.Debuff_Show[4] = index
						DebuffMe.Debuff_Show[4] = index
						break
					end
				end
			end,
            scrollable = true,
            sort = "name-up",
            reference = "RightDebuff_dropdown",
		},
		{
			type = "slider",
			name = "HP Threshold",
			tooltip = "The minimum target's max Health in Million for the tracker to be enabled.\nPut it to 0 if you always want it enabled.",
			min = 0,
			max = 30,
			step = 1,
			default = 1,
			getFunc = function() return DebuffMe.savedVariables.thresholdHP end,
			setFunc = function(newValue)
				DebuffMe.savedVariables.thresholdHP = newValue
				DebuffMe.thresholdHP = newValue
				end,
		},
        {
			type = "header",
			name = "DebuffMe Graphics",
		},
		{
			type = "description",
			text = "More coming soon !",
		},
		{
			type = "button",
			name = "Reset Position",
			tooltip = "Reset the position of the timers at their initial position: center of your screen.",
			func = function()
				DebuffMe.savedVariables.OffsetX = 0
				DebuffMe.savedVariables.OffsetY = 0
				DebuffMeAlert:SetAnchor(CENTER, GuiRoot, CENTER, DebuffMe.savedVariables.OffsetX, DebuffMe.savedVariables.OffsetY)
			end,
			width = "half",
		},
        {
			type = "checkbox",
			name = "Unlock",
			tooltip = "Use it to move the timers.",
			default = false,
			getFunc = function() return DebuffMe.savedVariables.AlwaysShowAlert end,
			setFunc = function(newValue) 
				DebuffMe.savedVariables.AlwaysShowAlert = newValue
				DebuffMeAlert:SetHidden(not newValue)  
			end,
		},
		{
            type = "slider",
            name = "Font Size",
            tooltip = "Choose here the size of the text, the middle debuff will be a bit smaller.",
            getFunc = function() return DebuffMe.savedVariables.FontSize end,
            setFunc = function(newValue) 
				DebuffMe.savedVariables.FontSize = newValue 
				DebuffMe.SetFontSize(DebuffMeAlertMiddle, (newValue * 0.9))
				DebuffMe.SetFontSize(DebuffMeAlertLeft, newValue)
				DebuffMe.SetFontSize(DebuffMeAlertTop, newValue)
				DebuffMe.SetFontSize(DebuffMeAlertRight, newValue)
			end,
            min = 20,
            max = 72,
            step = 2,
            default = 36,
            width = "full",
		},
		{
            type = "slider",
            name = "Spacing",
            tooltip = "Choose here the spacing between the different timers.",
            getFunc = function() return DebuffMe.savedVariables.Spacing end,
            setFunc = function(newValue) 
				DebuffMe.savedVariables.Spacing = newValue 
				DebuffMeAlertLeft:SetAnchor(CENTER, DebuffMeAlertMiddle, CENTER, -8*DebuffMe.savedVariables.Spacing, DebuffMe.savedVariables.Spacing)
				DebuffMeAlertTop:SetAnchor(CENTER, DebuffMeAlertMiddle, CENTER, 0, -6*DebuffMe.savedVariables.Spacing)
				DebuffMeAlertRight:SetAnchor(CENTER, DebuffMeAlertMiddle, CENTER, 8*DebuffMe.savedVariables.Spacing, DebuffMe.savedVariables.Spacing)
			end,
            min = 3,
            max = 30,
            step = 1,
            default = 10,
            width = "full",
		},
		{
			type = "checkbox",
			name = "Slow Mode",
			tooltip = "The addon will take less performance on your computer, but timers will not have any numbers after decimal points.",
			default = false,
			getFunc = function() return DebuffMe.savedVariables.SlowMode end,
			setFunc = function(newValue) 
				DebuffMe.savedVariables.SlowMode = newValue
				DebuffMe.SlowMode = newValue
				DebuffMe.EventRegister()
			end,
        },
        {
			type = "header",
			name = "Custom Debuffs",
		},
        {
            type = "editbox",
            name = "Debuff To Add",
            tooltip = "Type here the ID of the debuff or his name.",
            getFunc = function() return DebuffToAdd.name end,
            setFunc = function(newValue) 
                DebuffToAdd.name = newValue
                end,
        },
        {
            type = "editbox",
            name = "Abbreviation for this Debuff",
            tooltip = "Type here the abbreviation for this debuff that you want DebuffMe to show if the debuff is at 0.",
            getFunc = function() return DebuffToAdd.abbreviation end,
            setFunc = function(newValue) 
                DebuffToAdd.abbreviation = newValue
                end,
        },
        {
            type = "button",
            name = "Add This Debuff",
            tooltip = "Add the debuff choosed with the abbreviation typed to the list.",
            func = function()
                local id = DebuffMe.SearchForIdWithName(DebuffToAdd.name)
                if id ~= -1 then
                    table.insert(DebuffMe.CustomDataList.name, zo_strformat(SI_ABILITY_NAME, GetAbilityName(id)))
                    table.insert(DebuffMe.CustomDataList.id, id)
                    table.insert(DebuffMe.CustomDataList.abbreviation, DebuffToAdd.abbreviation)
                    DebuffMe.savedVariables.CustomDataList = DebuffMe.CustomDataList

                    d("|cffffffDebuff|r|cec3c00Me:\n|r|cffffffThe debuff|r |cec3c00" .. zo_strformat(SI_ABILITY_NAME, GetAbilityName(id)) .. " (" .. id .. ")|r |cffffffhas been added.|r")
                    DebuffMe.AddCustomDataList()
                end
            end,
            width = "half",
        },
        {
            type = "description",
            text = " ", -- just a separator
        },
        {
            type = "dropdown",
            name = "Select a Custom Debuff to Remove",
            tooltip = "One number after the decimal point, and abbreviation if debuff at 0.",
            choices = DebuffMe.CustomDataList.name,
            getFunc = function() return DebuffSelected end,
            setFunc = function(selected)
                for index, name in ipairs(DebuffMe.CustomDataList.name) do
                    if name == selected then
                        DebuffSelected = index
                        break
                    end
                end
            end,
            scrollable = true,
            width = "half",
            reference = "RemoveDebuff_dropdown",
        },
        {
            type = "button",
            name = "Remove",
            tooltip = "Remove the debuff selected in the previous dropdown.",
            func = function()
                if DebuffSelected ~= "" then                    
                    --Message in chat
                    d("|cffffffDebuff|r|cec3c00Me:\n|r|cffffffThe debuff|r |cec3c00" .. DebuffMe.CustomDataList.name[DebuffSelected] .. " (" 
                        .. DebuffMe.CustomDataList.id[DebuffSelected] .. ")|r |cffffffhas been removed.|r")

                    --remove from custom table
                    table.remove(DebuffMe.CustomDataList.name, DebuffSelected)
                    table.remove(DebuffMe.CustomDataList.id, DebuffSelected)
                    table.remove(DebuffMe.CustomDataList.abbreviation, DebuffSelected)

                    --rebuild
                    DebuffMe.AddCustomDataList()
                    DebuffSelected = ""
                end
            end,
            width = "half",
        },
	}
	
	LAM2:RegisterOptionControls("DebuffMe_Settings", optionsData)
end
