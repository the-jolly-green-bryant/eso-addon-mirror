local sf = string.format
local zo_cachedstr = ZO_CachedStrFormat

TB_Settings = ZO_Object:Subclass()
local TB_CONFIRM_DELETE = "TB_CONFIRM_DELETE"

function TB_Settings:New(...)
    local object = ZO_Object.New(self)
    object:Initialize(...)
    return object
end

function TB_Settings:Initialize()
end

function TB_Settings:CreatePanel()
	--Settings menu
	if not LibAddonMenu2 then return end
	local defaults = TraitBuddy:DefaultSettings()
	local OptionsName = "TBOptions"
	local panelData = {
		type = "panel",
		name = TraitBuddy.ADDON_NAME,
		displayName = sf("|cff8800%s|r", TraitBuddy.ADDON_NAME),
		author = "Weolo & WolfStar07",
		version = TraitBuddy.ADDON_VERSION,
		registerForRefresh = true,
		registerForDefaults = true,
		slashCommand = "/traitbuddyoptions",
		website = "http://www.esoui.com/downloads/info1058-TraitBuddy.html",
		feedback = "http://www.esoui.com/downloads/info1058-TraitBuddy.html#comments"
	}
	self.panel = LibAddonMenu2:RegisterAddonPanel(OptionsName, panelData)

	local optionsData = {
		{
			type = "header",
			name = sf("|c3f7fff%s|r", GetString(TB_OP_HEADING1))
		},
		{
			type = "checkbox",
			name = TB_OP_BAG,
			tooltip = TB_OP_BAG_TT,
			getFunc = function() return TraitBuddy.settings.tooltip.show.bag end,
			setFunc = function(value) TraitBuddy.settings.tooltip.show.bag = value end,
			default = defaults.tooltip.show.bag,
			warning = TB_OP_RELOAD
		},
		{
			type = "checkbox",
			name = TB_OP_LOOT,
			tooltip = TB_OP_LOOT_TT,
			getFunc = function() return TraitBuddy.settings.tooltip.show.loot end,
			setFunc = function(value) TraitBuddy.settings.tooltip.show.loot = value end,
			default = defaults.tooltip.show.loot,
			warning = TB_OP_RELOAD
		},
		{
			type = "checkbox",
			name = TB_OP_MAIL,
			tooltip = TB_OP_MAIL_TT,
			getFunc = function() return TraitBuddy.settings.tooltip.show.mail end,
			setFunc = function(value) TraitBuddy.settings.tooltip.show.mail = value end,
			default = defaults.tooltip.show.mail,
			warning = TB_OP_RELOAD
		},
		{
			type = "checkbox",
			name = SI_ITEMFILTERTYPE8,
			tooltip = TB_OP_BUYBACK_TT,
			getFunc = function() return TraitBuddy.settings.tooltip.show.buyback end,
			setFunc = function(value) TraitBuddy.settings.tooltip.show.buyback = value end,
			default = defaults.tooltip.show.buyback,
			warning = TB_OP_RELOAD
		},
		{
			type = "checkbox",
			name = TB_OP_TRADE,
			tooltip = TB_OP_TRADE_TT,
			getFunc = function() return TraitBuddy.settings.tooltip.show.trade end,
			setFunc = function(value) TraitBuddy.settings.tooltip.show.trade = value end,
			default = defaults.tooltip.show.trade,
			warning = TB_OP_RELOAD
		},
		{
			type = "checkbox",
			name = TB_OP_TRADINGHOUSE,
			tooltip = TB_OP_TRADINGHOUSE_TT,
			getFunc = function() return TraitBuddy.settings.tooltip.show.tradingHouse end,
			setFunc = function(value) TraitBuddy.settings.tooltip.show.tradingHouse = value end,
			default = defaults.tooltip.show.tradingHouse,
			warning = TB_OP_RELOAD
		},
		{
			type = "checkbox",
			name = TB_OP_CHAT,
			tooltip = TB_OP_CHAT_TT,
			getFunc = function() return TraitBuddy.settings.tooltip.show.chat end,
			setFunc = function(value) TraitBuddy.settings.tooltip.show.chat = value end,
			default = defaults.tooltip.show.chat,
			warning = TB_OP_RELOAD
		},
		{
			type = "checkbox",
			name = TB_OP_QUEST,
			tooltip = TB_OP_QUEST_TT,
			getFunc = function() return TraitBuddy.settings.tooltip.show.quest end,
			setFunc = function(value) TraitBuddy.settings.tooltip.show.quest = value end,
			default = defaults.tooltip.show.quest,
			warning = TB_OP_RELOAD
		},
		{
			type = "checkbox",
			name = SI_QUESTTYPE4,
			tooltip = TB_OP_CRAFTING_TT,
			getFunc = function() return TraitBuddy.settings.tooltip.show.crafting end,
			setFunc = function(value) TraitBuddy.settings.tooltip.show.crafting = value end,
			default = defaults.tooltip.show.crafting,
			warning = TB_OP_RELOAD
		},
		{
			type = "checkbox",
			name = SI_ITEM_FORMAT_STR_EQUIPPED,
			tooltip = TB_OP_WORN_TT,
			getFunc = function() return TraitBuddy.settings.tooltip.show.worn end,
			setFunc = function(value) TraitBuddy.settings.tooltip.show.worn = value end,
			default = defaults.tooltip.show.worn,
			warning = TB_OP_RELOAD
		},
		{
			type = "header",
			name = sf("|c3f7fff%s|r", GetString(TB_OP_HEADING2))
		},
		{
			type = "checkbox",
			name = TB_OP_TITLE,
			tooltip = TB_OP_TITLE_TT,
			getFunc = function() return TraitBuddy.settings.tooltip.show.title end,
			setFunc = function(value) TraitBuddy.settings.tooltip.show.title = value end,
			default = defaults.tooltip.show.title
		},
		{
			type = "checkbox",
			name = TB_OP_KNOWN,
			tooltip = TB_OP_KNOWN_TT,
			getFunc = function() return TraitBuddy.settings.tooltip.show.knowSection end,
			setFunc = function(value) TraitBuddy.settings.tooltip.show.knowSection = value end,
			default = defaults.tooltip.show.knowSection
		},
		{
			type = "colorpicker",
			name = TB_OP_KNOWN_COLOUR,
			tooltip = TB_OP_KNOWN_COLOUR_TT,
			getFunc = function()
				return TraitBuddy.settings.tooltip.colours.know_title.r, TraitBuddy.settings.tooltip.colours.know_title.g, TraitBuddy.settings.tooltip.colours.know_title.b
			end,
			setFunc = function(r,g,b,a) TraitBuddy.settings.tooltip.colours.know_title = {r=r,g=g,b=b} end,
			default = defaults.tooltip.colours.know_title
		},
		{
			type = "checkbox",
			name = TB_OP_RESEARCHING,
			tooltip = TB_OP_RESEARCHING_TT,
			getFunc = function() return TraitBuddy.settings.tooltip.show.researchingSection end,
			setFunc = function(value) TraitBuddy.settings.tooltip.show.researchingSection = value end,
			default = defaults.tooltip.show.researchingSection
		},
		{
			type = "colorpicker",
			name = TB_OP_RESEARCHING_COLOUR,
			tooltip = TB_OP_RESEARCHING_COLOUR_TT,
			getFunc = function()
				return TraitBuddy.settings.tooltip.colours.researching_title.r, TraitBuddy.settings.tooltip.colours.researching_title.g, TraitBuddy.settings.tooltip.colours.researching_title.b
			end,
			setFunc = function(r,g,b,a) TraitBuddy.settings.tooltip.colours.researching_title = {r=r,g=g,b=b} end,
			default = defaults.tooltip.colours.researching_title
		},
		{
			type = "checkbox",
			name = TB_OP_CANRESEARCH,
			tooltip = TB_OP_CANRESEARCH_TT,
			getFunc = function() return TraitBuddy.settings.tooltip.show.canResearchSection end,
			setFunc = function(value) TraitBuddy.settings.tooltip.show.canResearchSection = value end,
			default = defaults.tooltip.show.canResearchSection
		},
		{
			type = "colorpicker",
			name = TB_OP_CANRESEARCH_COLOUR,
			tooltip = TB_OP_CANRESEARCH_COLOUR_TT,
			getFunc = function()
				return TraitBuddy.settings.tooltip.colours.canResearch_title.r, TraitBuddy.settings.tooltip.colours.canResearch_title.g, TraitBuddy.settings.tooltip.colours.canResearch_title.b
			end,
			setFunc = function(r,g,b,a) TraitBuddy.settings.tooltip.colours.canResearch_title = {r=r,g=g,b=b} end,
			default = defaults.tooltip.colours.canResearch_title
		},
		{
			type = "checkbox",
			name = TB_OP_YOUKNOW,
			tooltip = TB_OP_YOUKNOW_TT,
			getFunc = function() return TraitBuddy.settings.tooltip.show.youKnowSection end,
			setFunc = function(value) TraitBuddy.settings.tooltip.show.youKnowSection = value end,
			default = defaults.tooltip.show.youKnowSection
		},
		{
			type = "checkbox",
			name = TB_OP_ADDON1,
			tooltip = TB_OP_ADDON1_TT,
			getFunc = function() return TraitBuddy.settings.tooltip.show.inventoryInsight end,
			setFunc = function(value) TraitBuddy.settings.tooltip.show.inventoryInsight = value end,
			default = defaults.tooltip.show.inventoryInsight
		},
		{
			type = "checkbox",
			name = TB_OP_MOTIFLOC,
			tooltip = TB_OP_MOTIFLOC_TT,
			getFunc = function() return TraitBuddy.settings.tooltip.show.motifLocation end,
			setFunc = function(value) TraitBuddy.settings.tooltip.show.motifLocation = value end,
			default = defaults.tooltip.show.motifLocation
		},
		{
			type = "header",
			name = sf("|c3f7fff%s|r", GetString(SI_EQUIPTYPE11))
		},
		{
			type = "colorpicker",
			name = TB_OP_UI_KNOW_COLOUR,
			tooltip = TB_OP_UI_KNOW_COLOUR_TT,
			getFunc = function()
				return TraitBuddy.settings.colours.know.r, TraitBuddy.settings.colours.know.g, TraitBuddy.settings.colours.know.b
			end,
			setFunc = function(r,g,b,a)
				TraitBuddy.settings.colours.know = {r=r,g=g,b=b}
				TraitBuddy.ui:UpdateUI(CRAFTING_TYPE_BLACKSMITHING)
				TraitBuddy.ui:UpdateUI(CRAFTING_TYPE_CLOTHIER)
				TraitBuddy.ui:UpdateUI(CRAFTING_TYPE_WOODWORKING)
				TraitBuddy.ui.motifs:UpdateUI()
			end,
			default = defaults.colours.know
		},
		{
			type = "colorpicker",
			name = TB_OP_UI_RESEARCHING_COLOUR,
			tooltip = TB_OP_UI_RESEARCHING_COLOUR_TT,
			getFunc = function()
				return TraitBuddy.settings.colours.researching.r, TraitBuddy.settings.colours.researching.g, TraitBuddy.settings.colours.researching.b
			end,
			setFunc = function(r,g,b,a)
				TraitBuddy.settings.colours.researching = {r=r,g=g,b=b}
				TraitBuddy.ui:UpdateUI(CRAFTING_TYPE_BLACKSMITHING)
				TraitBuddy.ui:UpdateUI(CRAFTING_TYPE_CLOTHIER)
				TraitBuddy.ui:UpdateUI(CRAFTING_TYPE_WOODWORKING)
			end,
			default = defaults.colours.researching
		},
		{
			type = "colorpicker",
			name = TB_OP_UI_OTHERS_KNOW_COLOUR,
			tooltip = TB_OP_UI_OTHERS_KNOW_COLOUR_TT,
			getFunc = function()
				return TraitBuddy.settings.colours.others_know.r, TraitBuddy.settings.colours.others_know.g, TraitBuddy.settings.colours.others_know.b
			end,
			setFunc = function(r,g,b,a)
				TraitBuddy.settings.colours.others_know = {r=r,g=g,b=b}
				TraitBuddy.ui:UpdateUI(CRAFTING_TYPE_BLACKSMITHING)
				TraitBuddy.ui:UpdateUI(CRAFTING_TYPE_CLOTHIER)
				TraitBuddy.ui:UpdateUI(CRAFTING_TYPE_WOODWORKING)
				TraitBuddy.ui.motifs:UpdateUI()
			end,
			default = defaults.colours.others_know
		},
		{
			type = "colorpicker",
			name = TB_OP_UI_OTHERS_RES_COLOUR,
			tooltip = TB_OP_UI_OTHERS_RES_COLOUR_TT,
			getFunc = function()
				return TraitBuddy.settings.colours.others_researching.r, TraitBuddy.settings.colours.others_researching.g, TraitBuddy.settings.colours.others_researching.b
			end,
			setFunc = function(r,g,b,a)
				TraitBuddy.settings.colours.others_researching = {r=r,g=g,b=b}
				TraitBuddy.ui:UpdateUI(CRAFTING_TYPE_BLACKSMITHING)
				TraitBuddy.ui:UpdateUI(CRAFTING_TYPE_CLOTHIER)
				TraitBuddy.ui:UpdateUI(CRAFTING_TYPE_WOODWORKING)
			end,
			default = defaults.colours.others_researching
		},
		{
			type = "colorpicker",
			name = TB_OP_UI_NOTKNOWN_COLOUR,
			tooltip = TB_OP_UI_NOTKNOWN_COLOUR_TT,
			getFunc = function()
				return TraitBuddy.settings.colours.not_known.r, TraitBuddy.settings.colours.not_known.g, TraitBuddy.settings.colours.not_known.b
			end,
			setFunc = function(r,g,b,a)
				TraitBuddy.settings.colours.not_known = {r=r,g=g,b=b}
				TraitBuddy.ui:UpdateUI(CRAFTING_TYPE_BLACKSMITHING)
				TraitBuddy.ui:UpdateUI(CRAFTING_TYPE_CLOTHIER)
				TraitBuddy.ui:UpdateUI(CRAFTING_TYPE_WOODWORKING)
				TraitBuddy.ui.motifs:UpdateUI()
			end,
			default = defaults.colours.not_known
		},
		{
			type = "colorpicker",
			name = TB_OP_UI_MARK_COLOUR,
			tooltip = TB_OP_UI_MARK_COLOUR_TT,
			getFunc = function()
				return TraitBuddy.settings.colours.mark.r, TraitBuddy.settings.colours.mark.g, TraitBuddy.settings.colours.mark.b
			end,
			setFunc = function(r,g,b,a)
				TraitBuddy.settings.colours.mark = {r=r,g=g,b=b}
				TraitBuddy.ui:UpdateUI(CRAFTING_TYPE_BLACKSMITHING)
				TraitBuddy.ui:UpdateUI(CRAFTING_TYPE_CLOTHIER)
				TraitBuddy.ui:UpdateUI(CRAFTING_TYPE_WOODWORKING)
				TraitBuddy.ui.motifs:UpdateUI()
			end,
			default = defaults.colours.mark
		},
		{
			type = "checkbox",
			name = TB_OP_LAUNCH1,
			tooltip = TB_OP_LAUNCH1,
			getFunc = function() return TraitBuddy.settings.showLaunch1 end,
			setFunc = function(value)
				TraitBuddy.settings.showLaunch1 = value
				TraitBuddy.ui.launchers.smithing:SetHidden(not value)
			end,
			default = defaults.showLaunch1
		},
		{
			type = "checkbox",
			name = TB_OP_LAUNCH2,
			tooltip = TB_OP_LAUNCH2,
			getFunc = function() return TraitBuddy.settings.showLaunch2 end,
			setFunc = function(value)
				TraitBuddy.settings.showLaunch2 = value
				TraitBuddy.ui.launchers.skills:SetHidden(not value)
			end,
			default = defaults.showLaunch2
		},
		{
			type = "checkbox",
			name = TB_OP_LAUNCH3,
			tooltip = TB_OP_LAUNCH3,
			getFunc = function() return TraitBuddy.settings.showLaunch3 end,
			setFunc = function(value)
				TraitBuddy.settings.showLaunch3 = value
				TraitBuddy.ui.launchers.guildstore:SetHidden(not value)
			end,
			default = defaults.showLaunch3
		},
		{
			type = "header",
			name = sf("|c3f7fff%s|r", GetString(TB_OP_HEADING6))
		},
		{
			type = "checkbox",
			name = TB_OP_BAG,
			tooltip = TB_OP_INV_BAG_TT,
			getFunc = function() return TraitBuddy.settings.inventory.show.bag end,
			setFunc = function(value) TraitBuddy.settings.inventory.show.bag = value end,
			default = defaults.inventory.show.bag
		},
		{
			type = "checkbox",
			name = SI_INTERACT_OPTION_BANK,
			tooltip = TB_OP_INV_BANK_TT,
			getFunc = function() return TraitBuddy.settings.inventory.show.bank end,
			setFunc = function(value) TraitBuddy.settings.inventory.show.bank = value end,
			default = defaults.inventory.show.bank
		},
		{
			type = "checkbox",
			name = SI_INTERACT_OPTION_GUILDBANK,
			tooltip = TB_OP_INV_BANK_TT,
			getFunc = function() return TraitBuddy.settings.inventory.show.guild end,
			setFunc = function(value) TraitBuddy.settings.inventory.show.guild = value end,
			default = defaults.inventory.show.guild
		},
		{
			type = "checkbox",
			name = SI_QUESTTYPE4,
			getFunc = function() return TraitBuddy.settings.inventory.show.crafting end,
			setFunc = function(value) TraitBuddy.settings.inventory.show.crafting = value end,
			default = defaults.inventory.show.crafting
		},
		{
			type = "colorpicker",
			name = TB_OP_INV_OTHER,
			tooltip = TB_OP_INV_OTHER_TT,
			getFunc = function()
				return TraitBuddy.settings.inventory.colours.othersCan.r, TraitBuddy.settings.inventory.colours.othersCan.g, TraitBuddy.settings.inventory.colours.othersCan.b
			end,
			setFunc = function(r,g,b,a)
				TraitBuddy.settings.inventory.colours.othersCan = {r=r,g=g,b=b}
			end,
			default = defaults.inventory.colours.othersCan
		},
		{
			type = "checkbox",
			name = TB_OP_GAME_ICON,
			tooltip = TB_OP_GAME_ICON_TT,
			getFunc = function() return TraitBuddy.settings.inventory.gameIcon end,
			setFunc = function(value) TraitBuddy.settings.inventory.gameIcon = value end,
			default = defaults.inventory.gameIcon
		},
		{
			type = "checkbox",
			name = TB_OP_IGV_ONTOP,
			tooltip = TB_OP_IGV_ONTOP_TT,
			getFunc = function() return TraitBuddy.settings.inventory.IGVOnTop end,
			setFunc = function(value) TraitBuddy.settings.inventory.IGVOnTop = value end,
			default = defaults.inventory.IGVOnTop
		},
		{
			type = "header",
			name = sf("|c3f7fff%s|r", GetString(SI_FURNITURETHEMETYPE1))
		},
		{
			type = "checkbox",
			name = TB_OP_SELECTION,
			tooltip = TB_OP_SELECTION_TT,
			getFunc = function() return TraitBuddy.settings.alternativeSelection end,
			setFunc = function(value)
				TraitBuddy.settings.alternativeSelection = value
				TraitBuddy.ui.selector:Show()
			end,
			default = defaults.alternativeSelection
		},
		{
			type = "checkbox",
			name = TB_OP_ESOPLUS,
			tooltip = TB_OP_ESOPLUS_TT,
			getFunc = function() return TraitBuddy.settings.esoplusCheck end,
			setFunc = function(value)
				TraitBuddy.settings.esoplusCheck = value
			end,
			default = defaults.esoplusCheck
		},
		{
			type = "checkbox",
			name = TB_OP_COMPLETE,
			tooltip = TB_OP_COMPLETE_TT,
			getFunc = function() return TraitBuddy.settings.messageComplete end,
			setFunc = function(value)
				TraitBuddy.settings.messageComplete = value
			end,
			default = defaults.messageComplete
		},
		{
			type = "button",
			name = SI_INTERFACE_OPTIONS_FRAMERATE_LATENCY_POSITION_RESET,
			func = function()
				TraitBuddy.ui:SetWindowPosition(defaults.x, defaults.y)
			end
		},
		{
			type = "header",
			name = sf("|c3f7fff%s|r", GetString(TB_OP_HEADING4))
		},
		{
			type = "description",
			text = TB_OP_INCLUSION
		},
		{
			type = "checkbox",
			name = TB_OP_TIDY,
			tooltip = TB_OP_TIDY_TT,
			getFunc = function() return TraitBuddy.settings.tidy end,
			setFunc = function(value)
				TraitBuddy.settings.tidy = value
				TraitBuddy:TidyCharacters()
			end,
			default = defaults.tidy
		},
		{
			type = "custom",
			reference = sf("%sCharacters", OptionsName)
		}
	}
	LibAddonMenu2:RegisterOptionControls(OptionsName, optionsData)
end

function TB_Settings:AddCharacters()
	if TBOptionsCharactersSection then return end
	local control = CreateControlFromVirtual("$(parent)", TBOptionsCharacters, "TB_SettingsCharacters", "Section")
	self.container = control:GetNamedChild("Container")
	local last
	for k,id in ipairs(TraitBuddy:GetCharacters(true)) do
		last = self:AddCharacter(id, last)
	end
end

function TB_Settings_OnMouseEnter(control, craftingSkillType)
	InitializeTooltip(InformationTooltip, control, BOTTOMLEFT, 0, -2, TOPLEFT)
	SetTooltipText(InformationTooltip, zo_cachedstr(SI_ABILITY_NAME, ZO_GetCraftingSkillName(craftingSkillType)))
end

function TB_Settings_Motif_OnMouseEnter(control)
	InitializeTooltip(InformationTooltip, control, BOTTOMLEFT, 0, -2, TOPLEFT)
	SetTooltipText(InformationTooltip, GetString(SI_ITEMTYPE8))
end

local function GetConfirmDialog()
	if not ZO_Dialogs_IsDialogRegistered(TB_CONFIRM_DELETE) then
		local data = {
			title = {text = SI_NOTIFICATIONS_DELETE},
			mainText = {text = ""},
			buttons = {
				[1] = {
					text = SI_DIALOG_YES,
					callback = function(dialog) end,
					clickSound = SOUNDS.DIALOG_ACCEPT,
				},
				[2] = {
					text = SI_DIALOG_NO,
				}
			}
		}
		ZO_Dialogs_RegisterCustomDialog(TB_CONFIRM_DELETE, data)
	end
	return ESO_Dialogs[TB_CONFIRM_DELETE]
end

function TB_Settings:Character_Delete_OnClicked(control)
	local id = control:GetParent().data.id
	local dialog = GetConfirmDialog(control)
	local msg = sf(GetString(TB_OP_DELETE_TT), TraitBuddy.ADDON_NAME, TraitBuddy:GetCharacter(id).name)
    dialog.mainText.text = sf("%s?", msg)
    dialog.buttons[1].callback = function(dialog) TraitBuddy:DeleteCharacter(id) end
	ZO_Dialogs_ShowDialog(TB_CONFIRM_DELETE)
end

local function FormatLabel(c, control)
	local enable = (c.show.bs or c.show.cl or c.show.ww or c.show.motif or c.show.je)
	control.label:SetColor((enable and ZO_SELECTED_TEXT or ZO_DISABLED_TEXT):UnpackRGBA())
end

local function Toggle(checkbox, checked)
	local control = checkbox:GetParent()
	local id = control.data.id
	local c = TraitBuddy:GetCharacter(id)
	c.show[checkbox.data.show] = checked
	FormatLabel(c, control)
	local selectedId = TraitBuddy.ui.selector:GetSelectedID()
	TraitBuddy.ui.selector:Build(selectedId)
	TraitBuddy.ui.research:UpdateUI()
	TraitBuddy.ui.motifs:SelectCurrentFilter()
end

function TB_Settings:AddCharacter(id, last)
	local c = TraitBuddy:GetCharacter(id)
	local control = CreateControlFromVirtual("$(parent)", self.container, "TB_SettingsCharacter", id)
	if last then
		control:SetAnchor(TOPLEFT, last, BOTTOMLEFT, 0, 0)
		control:SetAnchor(BOTTOMRIGHT, last, BOTTOMRIGHT, 0, 30)
	else
		control:SetAnchor(TOPLEFT, nil, TOPLEFT, 0, 0)
		control:SetAnchor(BOTTOMRIGHT, nil, TOPRIGHT, 0, 30)
	end
	control.data = control.data or {}
	control.data.id = id
	control.label = control:GetNamedChild("Name")
	control.label:SetText(c.name)
	FormatLabel(c, control)
	local names = {"BS", "CL", "WW", "MOTIF", "JE"}
	for k,name in pairs(names) do
		local checkbox = control:GetNamedChild(name)
		checkbox.data = checkbox.data or {}
		checkbox.data.show = name:lower()
		checkbox.data.tooltipText = nil
		ZO_CheckButton_SetCheckState(checkbox, c.show[checkbox.data.show])
		ZO_CheckButton_SetToggleFunction(checkbox, Toggle)
	end
	
	local delButton = control:GetNamedChild("Delete")
	delButton.data = control.data or {}
	delButton.data.tooltipText = sf(GetString(TB_OP_DELETE_TT), TraitBuddy.ADDON_NAME, c.name)
	return control
end

function TB_Settings:ClearCharacter(id)
	if self.container then
		local control = self.container:GetNamedChild(id)
		if control then
			control:SetHidden(true)
		end
	end
end

function TB_Settings:OnSettingsControlsCreated(panel)
	--Each time an options panel is created, once for each addon viewed
	if panel:GetName() == "TBOptions" then
		self:AddCharacters()
	end
end

function TB_Settings:IsCreated()
	if self.container then
		return true
	else
		return false
	end
end