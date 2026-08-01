GoldenLightGuildHall = GoldenLightGuildHall or {}
GoldenLightGuildHall.name = "GoldenLightGuildHall"

GoldenLightGuildHall.savedVars = {
    firstLoad = true,
    accountWide = true,
}

local function Keybinds()
	d("GoldenHall: " .. GetString(SI_BINDING_NAME_GoldenHall))
	d("Keybinding Layer: " .. GetString(SI_KEYBINDINGS_LAYER_GENERAL))
end


function
GoldenHall()
	JumpToHouse("@beaglesinbluejeans")
	end
	
SLASH_COMMANDS["/glhall"] = GoldenHall


function GoldenLightGuildHall_Initialize(eventCode, addOnName)

	if (addOnName ~= "GoldenLightGuildHall") then return end
	
	local GoldenHall = WINDOW_MANAGER:CreateTopLevelWindow()
	GoldenHall =  WINDOW_MANAGER:CreateControl("GoldenLightGuildHall", ZO_ChatWindow, CT_BUTTON)
    GoldenHall:SetDimensions(26, 26)
    GoldenHall:SetAnchor(TOPLEFT, ZO_ChatOptionsSectionLabel, TOPLEFT, 190, 8)
	GoldenHall:SetHandler("OnMouseEnter", function(control) InitializeTooltip(InformationTooltip, control) SetTooltipText(InformationTooltip, "|cede664Golden Light Guild Hall|r") end)
	GoldenHall:SetHandler("OnMouseExit", function(control) ClearTooltip(InformationTooltip) end)
	GoldenHall:SetNormalTexture("GoldenLightGuildHall/imgs/goldhouse.dds")
    GoldenHall:SetPressedTexture("GoldenLightGuildHall/imgs/goldhouse.dds")
    GoldenHall:SetMouseOverTexture("GoldenLightGuildHall/imgs/goldhouse.dds")
	

		
	GoldenHall:SetHandler("OnClicked", function(...)
		JumpToHouse("@beaglesinbluejeans")
	end)
	
	
	ZO_CreateStringId("SI_BINDING_NAME_GoldenHall", "|c6a5acdGoldenHall|r")
	end
	
	function GoldenLightGuildHall.OnAddOnLoaded(event, addonName)
	if addonName ~= GoldenLightGuildHall.name then return end
    EVENT_MANAGER:UnregisterForEvent(GoldenLightGuildHall.name, EVENT_ADD_ON_LOADED)

    GoldenLightGuildHall.characterSavedVars = ZO_SavedVars:New("GoldenLightGuildHallSavedVariables", 1, nil, GoldenLightGuildHall.savedVars)
    GoldenLightGuildHall.accountSavedVars = ZO_SavedVars:NewAccountWide("GoldenLightGuildHallSavedVariables", 1, nil, GoldenLightGuildHall.savedVars)

    if not GoldenLightGuildHall.characterSavedVars.accountWide then
        GoldenLightGuildHall.savedVars = GoldenLightGuildHall.characterSavedVars
    else
        GoldenLightGuildHall.savedVars = GoldenLightGuildHall.accountSavedVars
    end
end
		

EVENT_MANAGER:RegisterForEvent("GoldenLightGuildHallLoaded", EVENT_ADD_ON_LOADED, function(...) 	GoldenLightGuildHall_Initialize(...) 	end)