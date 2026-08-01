local LMP = LibMediaProvider
TurkishScrollsOnline = {}
TurkishScrollsOnline.name  = "Turkish Scrolls Online"
TurkishScrollsOnline.addonName  = "TurkishScrollsOnline"
TurkishScrollsOnline.version = "1.23"
TurkishScrollsOnline.settings = TurkishScrollsOnline.defaults
TurkishScrollsOnline.langString = nil
TurkishScrollsOnline.positionning = false
TurkishScrollsOnline.Flags = { "en", "tr" }

TurkishScrollsOnline.defaults = {
	Enable	= true,
	anchor	= {BOTTOMRIGHT, BOTTOMRIGHT, 0, 7},
	Flags = {
		["tr"]	= true,
		["en"]	= true,
	}
}

local confirmDialog = {
    title = { text = zo_iconFormat("TurkishScrollsOnline/images/".."tr.dds", 24, 24).." Turkish Scrolls Online "..zo_iconFormat("TurkishScrollsOnline/images/".."tr.dds", 24, 24)},
		mainText = { text = "Merhaba. ESC'ye bastıktan sonra sağ alt bölümde, ortada bulunan Türk bayrağına tıklayarak eklentimizi kullanmaya başlayabilirsiniz. Hata ve önerileri bildirmek için lütfen Discord yoluyla bize ulaşın.\nBalgamov & Sharlikran" },
    buttons = {
        { text = SI_DIALOG_ACCEPT, callback = functionToCall},
    }
}
ZO_Dialogs_RegisterCustomDialog("ADDON_DIALOG", confirmDialog )

function TurkishScrollsOnline:TestDialog()
  ZO_Dialogs_ShowDialog("ADDON_DIALOG")
end

if GetCVar("IgnorePatcherLanguageSetting") == "0" then
	ZO_Dialogs_ShowDialog("ADDON_DIALOG")
end

function TurkishScrollsOnline_ChangeLanguage(lang)
	if lang ~= GetCVar("language.2") then
    if lang == "en" then
      SetCVar("IgnorePatcherLanguageSetting", 0)
    else
      SetCVar("IgnorePatcherLanguageSetting", 1)
    end
    TurkishScrollsOnline.langString = lang
    SetCVar("language.2", lang)
  end
end

function TurkishScrollsOnline:RefreshUI()
	local flagControl
	local count = 0
	local flagTexture
	for _, flagCode in pairs(TurkishScrollsOnline.Flags) do
		flagTexture = "TurkishScrollsOnline/images/"..flagCode..".dds"
		flagControl = GetControl("TurkishScrollsOnline_FlagControl_"..tostring(flagCode))
		if flagControl == nil then
			flagControl = CreateControlFromVirtual("TurkishScrollsOnline_FlagControl_", TurkishScrollsOnlineUI, "TurkishScrollsOnline_FlagControl", tostring(flagCode))
			if flagControl:GetHandler("OnMouseDown") == nil then flagControl:SetHandler("OnMouseDown", function() TurkishScrollsOnline_ChangeLanguage(flagCode) end) end
			GetControl("TurkishScrollsOnline_FlagControl_"..flagCode.."Texture"):SetTexture(flagTexture)
		end
		if TurkishScrollsOnline.langString ~= flagCode then
      flagControl:SetAlpha(0.3)
		end
		if TurkishScrollsOnline.settings.Flags[flagCode] then
			flagControl:ClearAnchors()
			flagControl:SetAnchor(LEFT, TurkishScrollsOnlineUI, LEFT, 14 +count*34, 0)
			count = count +1
		end
		flagControl:SetMouseEnabled(true)
		flagControl:SetHidden(not TurkishScrollsOnline.settings.Flags[flagCode])
	end
	TurkishScrollsOnlineUI:SetDimensions(25 +count*34, 50)
	TurkishScrollsOnlineUI:SetMouseEnabled(true)
end

function TurkishScrollsOnline_Selected()
	local isValidAnchor, point, relativeTo, relativePoint, offsetX, offsetY = TurkishScrollsOnlineUI:GetSelected()
	if isValidAnchor then
		TurkishScrollsOnline.settings.anchor = { point, relativePoint, offsetX, offsetY }
	end
end

function TurkishScrollsOnline:OnInit(eventCode, addOnName)
  if (TurkishScrollsOnline.addonName ~= addOnName) then return end

  LMP:Register("font", "Century Gothic", "$(ESOTR_CENTURY_GOTHIC_FONT)")
  LMP:Register("font", "Crimson Regular", "$(ESOTR_CRIMSON_REGULAR_FONT)")
  LMP:Register("font", "Gentium", "$(ESOTR_GENTIUM_FONT)")
  LMP:Register("font", "Metamorphous Regular", "$(ESOTR_METAMORPHOUS_REGULAR_FONT)")
  LMP:Register("font", "Patrick Hand SC", "$(ESOTR_PATRICK_HAND_SC_FONT)")
  LMP:Register("font", "ProseAntique", "$(ESOTR_PROSEANTIQUE_FONT)")

	TurkishScrollsOnline.langString = GetCVar("language.2")
	TurkishScrollsOnline.settings = ZO_SavedVars:New(TurkishScrollsOnline.name .. "_settings", 1, nil, TurkishScrollsOnline.defaults)

	for _, flagCode in pairs(TurkishScrollsOnline.Flags) do
		ZO_CreateStringId("SI_BINDING_NAME_"..string.upper(flagCode), string.upper(flagCode))
	end

	TurkishScrollsOnline:RefreshUI()
	TurkishScrollsOnlineUI:ClearAnchors()
	TurkishScrollsOnlineUI:SetAnchor(TurkishScrollsOnline.settings.anchor[1], GuiRoot, TurkishScrollsOnline.settings.anchor[2], TurkishScrollsOnline.settings.anchor[3], TurkishScrollsOnline.settings.anchor[4])
	TurkishScrollsOnline:registerEvents(true)

	EVENT_MANAGER:UnregisterForEvent(TurkishScrollsOnline.name, EVENT_ADD_ON_LOADED)
end

function TurkishScrollsOnline:registerEvents(state)
	if state then
		EVENT_MANAGER:RegisterForEvent(TurkishScrollsOnline.name, EVENT_RETICLE_HIDDEN_UPDATE, function(eventCode, hidden) if TurkishScrollsOnline.settings.Enable then TurkishScrollsOnlineUI:SetHidden(not hidden) end end)
	else
		EVENT_MANAGER:UnregisterForEvent(TurkishScrollsOnline.name, EVENT_RETICLE_HIDDEN_UPDATE)
	end
end

EVENT_MANAGER:RegisterForEvent(TurkishScrollsOnline.name, EVENT_ADD_ON_LOADED , function(_event, _name) TurkishScrollsOnline:OnInit(_event, _name) end)