local ADDON = NameLanguageNinja
local LMN = LibMultilingualName
local LAM = LibAddonMenu2

--------
-- in this file local use, private
--------

local function getPanelInfo()
	return {
		type = "panel",
		name = ADDON.NAME,
		displayName = ADDON.DISPLAY_NAME,
		author = ADDON.AUTHOR,
		version = ADDON.VERSION,
		registerForRefresh = true
	}
end

local function getLanguageColorOption(base, langCode, title)
	local defaultSaveData = ADDON.GetDefaultSaveData()

	local defaultValue
	if base then
		defaultValue = defaultSaveData[base].LanguageColors[langCode]
	else
		defaultValue = defaultSaveData.LanguageColors[langCode]
	end

	--[[colorpickerData = {
    type = "colorpicker",
    name = "My Color Picker", -- or string id or function returning a string
    getFunc = function() return db.r, db.g, db.b, db.a end, -- (alpha is optional)
    setFunc = function(r,g,b,a) db.r=r, db.g=g, db.b=b, db.a=a end, -- (alpha is optional)
    tooltip = "Color Picker's tooltip text.", -- or string id or function returning a string (optional)
    width = "full", -- or "half" (optional)
    disabled = function() return db.someBooleanSetting end, -- or boolean (optional)
    warning = "May cause permanent awesomeness.", -- or string id or function returning a string (optional)
    requiresReload = false, -- boolean, if set to true, the warning text will contain a notice that changes are only applied after an UI reload and any change to the value will make the "Apply Settings" button appear on the panel which will reload the UI when pressed (optional)
    default = {r = defaults.r, g = defaults.g, b = defaults.b, a = defaults.a}, -- (optional) table of default color values (or default = defaultColor, where defaultColor is a table with keys of r, g, b[, a]) or a function that returns the color
    helpUrl = "https://www.esoui.com/portal.php?id=218&a=faq", -- a string URL or a function that returns the string URL (optional)
    reference = "MyAddonColorpicker" -- unique global reference to control (optional)
	} ]]
	return {
		type = "colorpicker",
		name = title,
		width = "half",
		warning = false,
		default = defaultValue,
		getFunc = function()
			local color
			if base then
				color = ADDON.SaveData[base].LanguageColors[langCode]
			else
				color = ADDON.SaveData.LanguageColors[langCode]
			end
			return color.r, color.g, color.b
		end,
		setFunc = function(r, g, b)
			local color
			if base then
				color = ADDON.SaveData[base].LanguageColors[langCode]
			else
				color = ADDON.SaveData.LanguageColors[langCode]
			end
			color.r = r
			color.g = g
			color.b = b
		end
	}
end

local function getLangCodeOption(base, langCode, title)
	local defaultSaveData = ADDON.GetDefaultSaveData()

	local defaultValue
	if base then
		defaultValue = defaultSaveData[base].Languages[langCode]
	else
		defaultValue = defaultSaveData.Languages[langCode]
	end
	return {
		type = "checkbox",
		name = title,
		tooltip = "",
		width = "half",
		getFunc = function()
			if base then
				return ADDON.SaveData[base].Languages[langCode]
			else
				return ADDON.SaveData.Languages[langCode]
			end
		end,
		setFunc = function(state)
			if base then
				ADDON.SaveData[base].Languages[langCode] = state
			else
				ADDON.SaveData.Languages[langCode] = state
			end
		end,
		warning = false,
		default = defaultValue
	}
end

local function getPanelControlsForLangCode(name)
	local data = {}
	for _index, _language_name in pairs(LMN.ALL_LANGUAGE_NAMES) do
		local _langCode = LMN.ALL_LANG_CODES[_index]
		data[#data + 1] = getLangCodeOption(name, _langCode, _language_name)
	end

	return data
end

local function getPanelControlsForLanguageColorOption(name)
	local data = {}
	for _index, _language_name in pairs(LMN.ALL_LANGUAGE_NAMES) do
		local _langCode = LMN.ALL_LANG_CODES[_index]
		data[#data + 1] = getLanguageColorOption(name, _langCode, _language_name)
	end

	return data
end

local function getOptionTable()
	local defaultSaveData = ADDON.GetDefaultSaveData()
	local panels = {
		{
			type = "header",
			name = "Global"
		},
		{
			type = "checkbox",
			name = "Accountwide",
			tooltip = "",
			width = "half",
			getFunc = function()
				return ADDON.SaveDataGlobal.AcrossAccounts
			end,
			setFunc = function(state)
				ADDON.SaveDataGlobal.AcrossAccounts = state
				ADDON.LoadSavedVariables()
			end,
			warning = false,
			default = defaultSaveData.AcrossAccounts
		},
		{
			type = "checkbox",
			name = "ShowMessageOnInit",
			tooltip = "To show this addon's name at chat window when player are activated.\n" ..
				"If you have been installed so many addons, I think the setting will help you.",
			width = "half",
			getFunc = function()
				return ADDON.SaveDataGlobal.ShowMessageOnInit
			end,
			setFunc = function(state)
				ADDON.SaveDataGlobal.ShowMessageOnInit = state
			end,
			warning = false,
			default = defaultSaveData.ShowMessageOnInit
		},
		{
			type = "header",
			name = "Output"
		},
		--[[ TODO
		{
			type = "checkbox",
			name = "Item's Tooltip's Title",
			tooltip = "[NOTICE] Beta ver. " .. "\nnow using tooltip instead of actual title.",
			width = "half",
			getFunc = function()
				return ADDON.SaveData.To.Item.Tooltip.Title
			end,
			setFunc = function(state)
				ADDON.SaveData.To.Item.Tooltip.Title = state
			end,
			warning = false,
			default = defaultSaveData.To.Item.Tooltip.Title
		},
		]]
		{
			type = "checkbox",
			name = "Item's Tooltip's Body",
			tooltip = "",
			width = "half",
			getFunc = function()
				return ADDON.SaveData.To.Item.Tooltip.Body
			end,
			setFunc = function(state)
				ADDON.SaveData.To.Item.Tooltip.Body = state
			end,
			warning = false,
			default = defaultSaveData.To.Item.Tooltip.Body
		},
		--[[ TODO
		{
			type = "checkbox",
			name = "Skill's Tooltip's Title",
			tooltip = "",
			getFunc = function() return ADDON.SaveData.To.Skill.Tooltip.Title end,
			setFunc = function(state)
				ADDON.SaveData.To.Skill.Tooltip.Title = state
			end,
			warning = false,
			default = defaultSaveData.To.Skill.Tooltip.Title,
		},
		]]
		{
			type = "checkbox",
			name = "Skill's Tooltip's Body",
			tooltip = "",
			width = "half",
			getFunc = function()
				return ADDON.SaveData.To.Skill.Tooltip.Body
			end,
			setFunc = function(state)
				ADDON.SaveData.To.Skill.Tooltip.Body = state
			end,
			warning = false,
			default = defaultSaveData.To.Skill.Tooltip.Body
		},
		{
			type = "header",
			name = "Behaviour"
		},
		{
			type = "checkbox",
			name = "Don't show current language",
			tooltip = "Don't show translation written in ESO Client's current language code.\n" ..
				"translation of 'Link In Chat' ignore this setting.",
			width = "half",
			getFunc = function()
				return ADDON.SaveData.DontShowClientLanguage
			end,
			setFunc = function(state)
				ADDON.SaveData.DontShowClientLanguage = state
			end,
			warning = false,
			default = defaultSaveData.DontShowClientLanguage
		},
		{
			type = "checkbox",
			name = "Don't show dividers",
			tooltip = "",
			width = "half",
			getFunc = function()
				return ADDON.SaveData.DontShowDivider
			end,
			setFunc = function(state)
				ADDON.SaveData.DontShowDivider = state
			end,
			warning = false,
			default = defaultSaveData.DontShowDivider
		},
		{
			type = "checkbox",
			name = "ItemBrowser Integration",
			tooltip = "Add translations to Item Set Browser's tooltip." ..
				"\n" .. "Item Set Browser: https://www.esoui.com/downloads/info1480-ItemSetBrowser.html",
			width = "half",
			getFunc = function()
				return ADDON.SaveData.ItemBrowserIntegration
			end,
			setFunc = function(state)
				ADDON.SaveData.ItemBrowserIntegration = state
			end,
			warning = false,
			default = defaultSaveData.ItemBrowserIntegration
		},
		{
			type = "header",
			name = "Name"
		},
		{
			type = "checkbox",
			name = "Show Set Item Name",
			tooltip = "",
			width = "half",
			getFunc = function()
				return ADDON.SaveData.OutputSetItemName
			end,
			setFunc = function(state)
				ADDON.SaveData.OutputSetItemName = state
			end,
			warning = false,
			default = defaultSaveData.OutputSetItemName
		},
		{
			type = "checkbox",
			name = "Show Item's ID",
			tooltip = "",
			width = "half",
			getFunc = function()
				return ADDON.SaveData.OutputItemId
			end,
			setFunc = function(state)
				ADDON.SaveData.OutputItemId = state
			end,
			warning = false,
			default = defaultSaveData.OutputItemId
		},
		{
			type = "submenu",
			name = "Languages",
			tooltip = "",
			controls = getPanelControlsForLangCode(nil)
		},
		{
			type = "submenu",
			name = "Font Colors",
			tooltip = "",
			controls = getPanelControlsForLanguageColorOption(nil)
		},
		{
			type = "header",
			name = "Description"
		},
		{
			type = "checkbox",
			name = "Show Set Bonus Description",
			tooltip = "Show Set Bonus description. Set bonus means the bonus ability described as last '(N items)'." ..
				"\nIf suspicious bonus description are detected, alert mark |cff0000[!]|r will be added." ..
					"\n!!! This function is still BETA version.",
			width = "half",
			getFunc = function()
				return ADDON.SaveData.Description.OutputSetBonus
			end,
			setFunc = function(state)
				ADDON.SaveData.Description.OutputSetBonus = state
			end,
			warning = false,
			default = defaultSaveData.Description.OutputSetBonus
		},
		{
			type = "checkbox",
			name = "Show Skill Description",
			tooltip = "",
			width = "half",
			getFunc = function()
				return ADDON.SaveData.Description.OutputSkill
			end,
			setFunc = function(state)
				ADDON.SaveData.Description.OutputSkill = state
			end,
			warning = false,
			default = defaultSaveData.Description.OutputSkill
		},
		{
			type = "submenu",
			name = "Languages",
			tooltip = "",
			controls = getPanelControlsForLangCode("Description")
		},
		{
			type = "header",
			name = "Link In Chat"
		},
		{
			type = "checkbox",
			name = "Replace Link In Chat's Title",
			tooltip = "",
			width = "half",
			getFunc = function()
				return ADDON.SaveData.LinkInChat.Replace
			end,
			setFunc = function(state)
				ADDON.SaveData.LinkInChat.Replace = state
			end,
			warning = false,
			default = defaultSaveData.LinkInChat.Replace
		},
		{
			type = "checkbox",
			name = "Include Own Title Modified By That Link In Chat",
			tooltip = "Even if a Link In Chat already has own title(e.g outputted by another addon), the setting replace these Links In Chat.",
			width = "half",
			getFunc = function()
				return ADDON.SaveData.LinkInChat.IncludeDesignatedTitle
			end,
			setFunc = function(state)
				ADDON.SaveData.LinkInChat.IncludeDesignatedTitle = state
			end,
			warning = false,
			default = defaultSaveData.LinkInChat.IncludeDesignatedTitle
		},
		{
			type = "slider",
			name = "Not Replace If Length Greater Than",
			tooltip = "If the length of the new message is greater than the value, replacer will echo original message. (0 means always replace)",
			min = 0,
			max = 1500,
			step = 1,
			getFunc = function()
				return tonumber(ADDON.SaveData.LinkInChat.NotReplaceIfLengthGreaterThan)
			end,
			setFunc = function(state)
				ADDON.SaveData.LinkInChat.NotReplaceIfLengthGreaterThan = state
			end,
			width = "full",
			default = tonumber(defaultSaveData.LinkInChat.NotReplaceIfLengthGreaterThan)
		},
		{
			type = "editbox",
			name = "LinkTitle",
			tooltip = "Link In Chat's title is replaced by the value. " ..
				"\n\n!!! strongly recommended to use only 'A-Za-z0-9'. Or whole message'll die.",
			getFunc = function()
				return ADDON.SaveData.LinkInChat.LinkTitle
			end,
			setFunc = function(state)
				ADDON.SaveData.LinkInChat.LinkTitle = state
			end,
			width = "full",
			default = defaultSaveData.LinkInChat.LinkTitle
		},
		{
			type = "submenu",
			name = "Languages",
			tooltip = "",
			controls = getPanelControlsForLangCode("LinkInChat")
		},
		{
			type = "submenu",
			name = "ShortenMode",
			tooltip = "",
			controls = {
				{
					type = "dropdown",
					name = "ShortenMode NumOf LIC",
					tooltip = "ShortenMode If the number of LinkInChat is greater equal than this value.",
					width = "half",
					choices = {"Never", "Always", "2", "3", "4", "5"},
					choicesValues = {999, 0, 1, 2, 3, 4},
					getFunc = function()
						return ADDON.SaveData.LinkInChat.ShortenMode.IfNumOfLinkInChatGreaterThan
					end,
					setFunc = function(state)
						ADDON.SaveData.LinkInChat.ShortenMode.IfNumOfLinkInChatGreaterThan = state
					end,
					default = defaultSaveData.LinkInChat.ShortenMode.IfNumOfLinkInChatGreaterThan
				},
				{
					type = "dropdown",
					name = "ShortenMode Language",
					tooltip = "ShortenMode Language",
					width = "half",
					choices = ADDON.SHORTEN_MODE_LANGUAGES,
					choicesValues = ADDON.SHORTEN_MODE_LANGUAGE_VALUES,
					getFunc = function()
						return ADDON.SaveData.LinkInChat.ShortenMode.Language
					end,
					setFunc = function(state)
						ADDON.SaveData.LinkInChat.ShortenMode.Language = state
					end,
					default = defaultSaveData.LinkInChat.ShortenMode.Language
				},
				{
					type = "checkbox",
					name = "Use set name",
					tooltip = "Use set name and icon instead of the gear's own name." ..
						"\nIf weapon type is staff, the icon will have one capital char for distinct among Flame, Ice, Thunder, and Heal staffs.",
					width = "half",
					getFunc = function()
						return ADDON.SaveData.LinkInChat.ShortenMode.UseSetName
					end,
					setFunc = function(state)
						ADDON.SaveData.LinkInChat.ShortenMode.UseSetName = state
					end,
					warning = false,
					default = defaultSaveData.LinkInChat.ShortenMode.UseSetName
				},
				{
					type = "slider",
					name = "Icon size",
					tooltip = "",
					min = 15,
					max = 45,
					step = 1,
					getFunc = function()
						return tonumber(ADDON.SaveData.LinkInChat.ShortenMode.IconSize)
					end,
					setFunc = function(state)
						ADDON.SaveData.LinkInChat.ShortenMode.IconSize = state
					end,
					width = "half",
					default = tonumber(defaultSaveData.LinkInChat.ShortenMode.IconSize)
				},
				{
					type = "checkbox",
					name = "Delete Specific Heads",
					tooltip = "Delete some spedcific prefix words and use icon instead." .. "\ne.g) Recipe, Style Page, Crafting Motif",
					width = "half",
					getFunc = function()
						return ADDON.SaveData.LinkInChat.ShortenMode.OmitItemPrefix
					end,
					setFunc = function(state)
						ADDON.SaveData.LinkInChat.ShortenMode.OmitItemPrefix = state
					end,
					warning = false,
					default = defaultSaveData.LinkInChat.ShortenMode.OmitItemPrefix
				},
				{
					type = "checkbox",
					name = "Icon to Right",
					tooltip = "Put icon on left side or right side of that Link In Chat.",
					width = "half",
					getFunc = function()
						return ADDON.SaveData.LinkInChat.ShortenMode.IconPositionRight
					end,
					setFunc = function(state)
						ADDON.SaveData.LinkInChat.ShortenMode.IconPositionRight = state
					end,
					warning = false,
					default = defaultSaveData.LinkInChat.ShortenMode.IconPositionRight
				},
				{
					type = "slider",
					name = "Omit Name If",
					tooltip = "Omit Name If name length is greater than the value." ..
						"\nZero means 'Never'." ..
							"\nI DON'T check length as UTF8 string. I recommend to set multiple of 3, not to show garbled characters.",
					min = 0,
					max = 60,
					step = 1,
					getFunc = function()
						return tonumber(ADDON.SaveData.LinkInChat.ShortenMode.OmitNameIfLengthGreaterThan)
					end,
					setFunc = function(state)
						ADDON.SaveData.LinkInChat.ShortenMode.OmitNameIfLengthGreaterThan = state
					end,
					width = "half",
					default = tonumber(defaultSaveData.LinkInChat.ShortenMode.OmitNameIfLengthGreaterThan)
				}
			}
		},
		{
			type = "header",
			name = "Command"
		},
		{
			type = "button",
			name = "Reset Settings",
			width = "half",
			tooltip = "",
			func = function()
				ADDON.d("Reset Settings.")
				local defaultSaveData = ADDON.GetDefaultSaveData()
				ADDON.SaveData = defaultSaveData
			end
		}
	}

	panels[#panels + 1] = {
		type = "checkbox",
		name = "DebugMode",
		tooltip = "",
		width = "half",
		getFunc = function()
			return ADDON.SaveDataGlobal.DebugMode
		end,
		setFunc = function(state)
			ADDON.SaveDataGlobal.DebugMode = state
			ADDON.LoadSavedVariables()
		end,
		warning = false,
		default = defaultSaveData.DebugMode
	}
	if ADDON.IS_DEBUG() then
		panels[#panels + 1] = {
			type = "button",
			name = "[DEBUG]",
			width = "half",
			tooltip = "",
			func = function()
				-- TODO
			end
		}
	end

	return panels
end

--------
-- in this ADDON use, protected
--------

ADDON.RegisterPanel = function()
	ADDON.develop("RegisterPanel")
	LAM:RegisterAddonPanel(ADDON.NAME, getPanelInfo())
	LAM:RegisterOptionControls(ADDON.NAME, getOptionTable())
end

local tmpData1, tmpData2
tmpData1 = {}
tmpData2 = {}
for _index, _language_name in ipairs(LMN.ALL_LANGUAGE_NAMES) do
	local _langCode = LMN.ALL_LANG_CODES[_index]
	tmpData1[#tmpData1 + 1] = _langCode
	tmpData2[#tmpData2 + 1] = #tmpData2 + 1
end
ADDON.SHORTEN_MODE_LANGUAGES = tmpData1
ADDON.SHORTEN_MODE_LANGUAGE_VALUES = tmpData2


ADDON.GetLangCodeForShortenMode = function()
	if ADDON.SHORTEN_MODE_LANGUAGES[ADDON.SaveData.LinkInChat.ShortenMode.Language] then
		return ADDON.SHORTEN_MODE_LANGUAGES[ADDON.SaveData.LinkInChat.ShortenMode.Language]
	end
	return LMN.CODE_ENGLISH
end
