local ItalianScrollsOnline = {}
ItalianScrollsOnline.name  = "Italian Scrolls Online"
ItalianScrollsOnline.version = "1"
ItalianScrollsOnline.savedVariables = ItalianScrollsOnline.Default
ItalianScrollsOnline.Flags = { "en", "it"}
ItalianScrollsOnline.variableVersion = 1
ItalianScrollsOnline.Default = { Enable	= true, position = BOTTOMLEFT, offsetX = 20, offsetY = 0, Flags = {["en"] = true,["it"] = true,}}

local confirmDialog = {
    title = { text = zo_iconFormat("ItalianScrollsOnline/images/".."it.dds", 24, 24).." Italian Scrolls Online "..zo_iconFormat("ItalianScrollsOnline/images/".."it.dds", 24, 24)},
    mainText = { text = "Grazie per aver scelto il nostro Add-on, visita il sito http:/italianscrollsonline.com e seguici sulla nostra pagina Facebook \"Elder Scrolls Online - Traduzione Italiana\"." },
    buttons = {
        { text = SI_DIALOG_ACCEPT, callback = functionToCall},
    }
}
ZO_Dialogs_RegisterCustomDialog("ADDON_DIALOG", confirmDialog )

if GetCVar("IgnorePatcherLanguageSetting") == "0" then
	ZO_Dialogs_ShowDialog("ADDON_DIALOG")
end

function ItalianScrollsOnline_ChangeLanguage(lang)
	if lang ~= GetCVar("language.2") then SetCVar("IgnorePatcherLanguageSetting", 1) SetCVar("language.2", lang) end
end

function ItalianScrollsOnline_SavePosition()
    ItalianScrollsOnline.savedVariables.offsetX = ItalianScrollsOnlineUI:GetLeft()
    ItalianScrollsOnline.savedVariables.offsetY = ItalianScrollsOnlineUI:GetTop()
	ItalianScrollsOnline.savedVariables.position = TOPLEFT
end

function ItalianScrollsOnline:RefreshUI()
	local flagControl
	local count = 0
	local flagTexture
	for _, flagCode in pairs(ItalianScrollsOnline.Flags) do
		flagTexture = "ItalianScrollsOnline/images/"..flagCode..".dds"
		flagControl = GetControl("ItalianScrollsOnline_FlagControl_"..tostring(flagCode))
		if flagControl == nil then
			flagControl = CreateControlFromVirtual("ItalianScrollsOnline_FlagControl_", ItalianScrollsOnlineUI, "ItalianScrollsOnline_FlagControl", tostring(flagCode))
			if flagControl:GetHandler("OnMouseDown") == nil then flagControl:SetHandler("OnMouseDown", function() ItalianScrollsOnline_ChangeLanguage(flagCode) end) end
			GetControl("ItalianScrollsOnline_FlagControl_"..flagCode.."Texture"):SetTexture(flagTexture)	
		end
		if ItalianScrollsOnline.savedVariables.Flags[flagCode] then
			flagControl:ClearAnchors()
			flagControl:SetAnchor(LEFT, ItalianScrollsOnlineUI, LEFT, 14 +count*34, 0)
			count = count +1
		end
		flagControl:SetMouseEnabled(true)
		flagControl:SetHidden(not ItalianScrollsOnline.savedVariables.Flags[flagCode])
	end
	ItalianScrollsOnlineUI:SetDimensions(25 +count*34, 50)
	ItalianScrollsOnlineUI:SetMouseEnabled(true)
end

function ItalianScrollsOnline:Initialize(eventCode, addOnName)
	ItalianScrollsOnline.savedVariables = ZO_SavedVars:NewCharacterIdSettings("ItalianScrollsOnlineVars", ItalianScrollsOnline.variableVersion, nil, ItalianScrollsOnline.Default)
	for _, flagCode in pairs(ItalianScrollsOnline.Flags) do
		ZO_CreateStringId("SI_BINDING_NAME_"..string.upper(flagCode), string.upper(flagCode))
	end
	ItalianScrollsOnline:RefreshUI()
	ItalianScrollsOnlineUI:ClearAnchors()
	ItalianScrollsOnlineUI:SetAnchor(ItalianScrollsOnline.savedVariables.position, GuiRoot, ItalianScrollsOnline.savedVariables.position, ItalianScrollsOnline.savedVariables.offsetX, ItalianScrollsOnline.savedVariables.offsetY)
	ItalianScrollsOnline:registerEvents(true)
	EVENT_MANAGER:UnregisterForEvent(ItalianScrollsOnline.name, EVENT_ADD_ON_LOADED)
end

function ItalianScrollsOnline:registerEvents(state)
	if state then
		EVENT_MANAGER:RegisterForEvent(ItalianScrollsOnline.name, EVENT_RETICLE_HIDDEN_UPDATE, function(eventCode, hidden) if ItalianScrollsOnline.savedVariables.Enable then ItalianScrollsOnlineUI:SetHidden(not hidden) end end)
	else
		EVENT_MANAGER:UnregisterForEvent(ItalianScrollsOnline.name, EVENT_RETICLE_HIDDEN_UPDATE)
	end
end

EVENT_MANAGER:RegisterForEvent(ItalianScrollsOnline.name, EVENT_ADD_ON_LOADED , function(_event, _name) ItalianScrollsOnline:Initialize(_event, _name) end)