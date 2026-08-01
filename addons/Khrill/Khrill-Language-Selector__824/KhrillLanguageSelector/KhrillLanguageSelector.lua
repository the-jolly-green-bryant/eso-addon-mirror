------------------------------------------
--           Language Selector          --
--               by Khrill              --
--                                      --
--                v 1.6.0               --
------------------------------------------

local KLS = {}
KLS.name  = "KhrillLanguageSelector"
KLS.version = "1.6.0"

KLS.defaults = {
	Enable	= true,
	anchor	= {BOTTOMLEFT, BOTTOMLEFT, 20, 0},
	Flags = {
		["en"]	= true,
		["fr"]	= true,
		["de"]	= true,
		["br"]	= false,
		["es"]	= false,
		["it"]	= false,
		["ru"]	= false,
		["tr"]	= false,
	}
}
KLS.settings = KLS.defaults
KLS.langString = nil
KLS.positionning = false

KLS.Flags = { "en", "fr", "de", "br", "es", "it", "ru", "tr" }

local COLOR_KHRILLSELECT = "FF6A00" -- orange ^^

-- // **********
-- //  Events
-- // **********
function KLS_Change(lang)
	-- onclick on flag icon
	local msg = "|c"..COLOR_KHRILLSELECT..KLS.name.."|r : change to  "..zo_iconFormat("KhrillLanguageSelector/art/"..lang..".dds", 24, 24)
	d(msg)
	zo_callLater(function()
		SetCVar("language.2", lang)
		ReloadUI()
	end, 500)
end

-- // **********
-- //  UI PANEL
-- // **********
function KLS:RefreshUI()
	-- Init UI (flags from table KLS.Flags)
	local flagControl
	local count = 0
	local flagTexture
	for _, flagCode in pairs(KLS.Flags) do
		flagTexture = "KhrillLanguageSelector/art/"..flagCode..".dds"
		flagControl = GetControl("KLS_FlagControl_"..tostring(flagCode))
		if flagControl == nil then
			flagControl = CreateControlFromVirtual("KLS_FlagControl_", KLSUI, "KLS_FlagControl", tostring(flagCode))
			if flagControl:GetHandler("OnMouseDown") == nil then flagControl:SetHandler("OnMouseDown", function() KLS_Change(flagCode) end) end
			GetControl("KLS_FlagControl_"..flagCode.."Texture"):SetTexture(flagTexture)	
		end
		if KLS.settings.Flags[flagCode] then
			flagControl:ClearAnchors()
			flagControl:SetAnchor(LEFT, KLSUI, LEFT, 14 +count*34, 0)
			count = count +1
		end
		flagControl:SetMouseEnabled(true)
		flagControl:SetHidden(not KLS.settings.Flags[flagCode])
	end
	KLSUI:SetDimensions(25 +count*34, 50)
	KLSUI:SetMouseEnabled(true)
end

-- // **********
-- //  Init
-- // **********
function KLS_SaveAnchor()
	-- Save the new position of windows
--d("--SaveAnchor")
	local isValidAnchor, point, relativeTo, relativePoint, offsetX, offsetY = KLSUI:GetAnchor()
	if isValidAnchor then
		KLS.settings.anchor = { point, relativePoint, offsetX, offsetY }
	end
end

function KLS:GetLanguage()
	local lang = GetCVar("language.2")
--	lang = "en" --for testing
	
	--supported languages
	if(lang == "fr") then return lang end
	if(lang == "de") then return lang end
	if(lang == "es") then return lang end
	if(lang == "it") then return lang end
	if(lang == "br") then return lang end
	if(lang == "ru") then return lang end
	if(lang == "tr") then return lang end

	--return english if not supported
	return "en"
end
function KLS:OnInit(eventCode, addOnName)
    if ( addOnName ~= KLS.name) then return end
	
	--language
	KLS.langString = KLS_Lang[KLS:GetLanguage()]
	KLS.settings = ZO_SavedVars:New(KLS.name .. "_settings", 1, nil, KLS.defaults)
--	KLS.settings = KLS.defaults --reinit for test
	--bindings
	for _, flagCode in pairs(KLS.Flags) do
		ZO_CreateStringId("SI_BINDING_NAME_"..string.upper(flagCode), string.upper(flagCode))
	end
	--settings
	KLS:CommandOptionPanel()

	-- Init UI
	KLS:RefreshUI()
	-- position
	KLSUI:ClearAnchors()
	KLSUI:SetAnchor(KLS.settings.anchor[1], GuiRoot, KLS.settings.anchor[2], KLS.settings.anchor[3], KLS.settings.anchor[4])

	KLS:registerEvents(true)
	
	EVENT_MANAGER:UnregisterForEvent(KLS.name, EVENT_ADD_ON_LOADED)
end

function KLS:registerEvents(state)
	if state then
		EVENT_MANAGER:RegisterForEvent(KLS.name, EVENT_RETICLE_HIDDEN_UPDATE, function(eventCode, hidden) if KLS.settings.Enable then KLSUI:SetHidden(not hidden) end end)
	else
		EVENT_MANAGER:UnregisterForEvent(KLS.name, EVENT_RETICLE_HIDDEN_UPDATE)
	end
end

EVENT_MANAGER:RegisterForEvent(KLS.name, EVENT_ADD_ON_LOADED , function(_event, _name) KLS:OnInit(_event, _name) end)

-- // **********
-- //  Settings
-- // **********
function KLS:ToggleEnable(value)
	KLS.settings.Enable = value
	KLS:registerEvents(KLS.settings.Enable)	
	KLSUI:SetHidden(not KLS.settings.Enable)
end
function KLS:TogglePositionning(value)
	KLS.positionning = value
	KLSUI:SetHidden(not KLS.positionning)
end

function KLS:ToggleFlag(flagCode, value)
	KLS.settings.Flags[flagCode] = value
	KLS:RefreshUI()
end

function KLS:CommandOptionPanel()
	--// Settings panel LAM2
	local LAM2 = LibStub("LibAddonMenu-2.0")
	if ( not LAM2 ) then return end
	
	local ADDON_NAME="Language Selector"
	local ADDON_VERSION="v"..KLS.version
	local panelData = {
			type = "panel",
			name = ADDON_NAME,
			displayName = "|c"..COLOR_KHRILLSELECT.. ADDON_NAME .."|r (" .. KLS.langString.LOCALE .. ")",
			author = "|c"..COLOR_KHRILLSELECT.."Khrill|r",
			version = ADDON_VERSION,
			slashCommand = "/kls",
			registerForRefresh = true,
			registerForDefaults = true,
	}
	local settingsPanel = LAM2:RegisterAddonPanel(ADDON_NAME, panelData)

	local optionsTable = {
		------------SETTINGS--------------
		{	-- enable
			type = "checkbox",
			name = KLS.langString.Settings_enable,
			tooltip = KLS.langString.Settings_enable,
			getFunc = function() return KLS.settings.Enable end,
			setFunc = function(value) KLS:ToggleEnable(value) end,
			width = "full",
			default = KLS.defaults.Enable,
		},
		{
			type = "description",
			text = KLS.langString.Settings_keybindText,
			width = "full",
		},
		{
			type = "header",
			name = "|c"..COLOR_KHRILLSELECT..KLS.langString.Settings_control.."|r",
			width = "full",
		},
		
	}
	------------FLAGS--------------
	local index = #optionsTable
	for _, flagCode in pairs(KLS.Flags) do
		index = index + 1
		optionsTable[index] = {
			type = "checkbox",
			name = KLS.langString.Settings_printFlag.." "..GetString(_G["SI_BINDING_NAME_KLS_"..string.upper(flagCode)]),
			tooltip = KLS.langString.Settings_enable,
			getFunc = function() return KLS.settings.Flags[flagCode] end,
			setFunc = function(value) KLS:ToggleFlag(flagCode, value) end,
			width = "full",
			default = KLS.defaults.Flags[flagCode],
		}
	end

			------------POSITIONNING--------------
	index = index + 1
	optionsTable[index] = {
			type = "header",
			name = "|c"..COLOR_KHRILLSELECT..KLS.langString.Settings_positionning.."|r",
			width = "full",
		}
	index = index + 1
	optionsTable[index] = {
			type = "description",
			text = KLS.langString.Settings_positionningText,
			width = "full",
		}
	index = index + 1
	optionsTable[index] = {
			type = "checkbox",
			name = KLS.langString.Settings_enable,
			tooltip = KLS.langString.Settings_enable,
			getFunc = function() return true end,
			setFunc = function(value) KLS:TogglePositionning(value) end,
			width = "full",
			default = true,
		}

	LAM2:RegisterOptionControls(ADDON_NAME, optionsTable)
end

