UnDeadUI = {}
UnDeadUI.defaults = {}
UnDeadUI.defaults.filtered = {}

local LAM = LibAddonMenu2
local TLW = nil

function UnDeadUI.CreateUI()
	TLW = UHS_Builder.BuildTLW()
	UnDeadUI.CreateTitle()
	UnDeadUI.CreateDisableButton()
	UnDeadUI.CreateReloadButton()
	UnDeadUI.CreateOptionsButton()
end

function UnDeadUI.CreateTitle()
	local color = COLOR_WHITE
	local name = "UHS_Title_Label"
	local text = "|c03c03cHarvest Summary|r"
	local dimX = 190
	local dimY = 25
	local relative = TLW
	local anchorX = ANCHOR_TOP_LEFT
	local anchorY = ANCHOR_TOP_LEFT

	UHS_Builder.BuildLabel(name, text, color, TLW, relative, dimX, dimY, anchorX, anchorY)
end

function UnDeadUI.ButtonOnMouseExit(self)
	ZO_Tooltips_HideTextTooltip()
end

function UnDeadUI.CreateDisableButton()
	local name = "UHS_Disable_Button"
	local relative = GetControl("UHS_Title_Label")
	local Normal = "esoui/art/buttons/minus_up.dds"
	local Pressed = "esoui/art/buttons/minus_down.dds"
	local Over = "esoui/art/buttons/minus_over.dds"
	local Disabled = "esoui/art/buttons/minus_down.dds"

	local btn = UHS_Builder.BuildButton(name, TLW, relative, Normal, Pressed, Over, Disabled)

	btn:SetHandler("OnClicked", UnDeadUI.DisableButtonOnClicked)
	btn:SetHandler("OnMouseEnter", UnDeadUI.DisableButtonOnMouseEnter)
	btn:SetHandler("OnMouseExit", UnDeadUI.ButtonOnMouseExit)
end

function UnDeadUI.DisableButtonOnClicked(self)
	UnDeadHarvest:DisableAll()
end

function UnDeadUI.DisableButtonOnMouseEnter(self)
	ZO_Tooltips_ShowTextTooltip(self, BOTTOM, "Disable All Items")
end


function UnDeadUI.CreateReloadButton()
	local name = "UHS_Reload_Button"
	local relative = GetControl("UHS_Disable_Button")
	local Normal = "esoui/art/help/help_tabicon_feedback_up.dds"
	local Pressed = "esoui/art/help/help_tabicon_feedback_down.dds"
	local Over = "esoui/art/help/help_tabicon_feedback_over.dds"
	local Disabled = "esoui/art/help/help_tabicon_feedback_down.dds"

	local btn = UHS_Builder.BuildButton(name, TLW, relative, Normal, Pressed, Over, Disabled)

	btn:SetHandler("OnClicked", UnDeadUI.ReloadButtonOnClicked)
	btn:SetHandler("OnMouseEnter", UnDeadUI.ReloadButtonOnMouseEnter)
	btn:SetHandler("OnMouseExit", UnDeadUI.ButtonOnMouseExit)
end

function UnDeadUI.ReloadButtonOnClicked(self)
	UnDeadUI.ReloadUI()
end

function UnDeadUI.ReloadUI()
	ReloadUI()
end

function UnDeadUI.ReloadButtonOnMouseEnter(self)
	ZO_Tooltips_ShowTextTooltip(self, BOTTOM, "Reload UI")
end


function UnDeadUI.CreateOptionsButton()
	local name = "UHS_Options_Button"
	local relative = GetControl("UHS_Reload_Button")
	local Normal = "esoui/art/buttons/edit_save_up.dds"
	local Pressed = "esoui/art/buttons/edit_save_down.dds"
	local Over = "esoui/art/buttons/edit_save_over.dds"
	local Disabled = "esoui/art/buttons/edit_save_disabled.dds"

	local btn = UHS_Builder.BuildButton(name, TLW, relative, Normal, Pressed, Over, Disabled)

	btn:SetHandler("OnClicked", UnDeadUI.OptionsButtonOnClicked)
	btn:SetHandler("OnMouseEnter", UnDeadUI.OptionsButtonOnMouseEnter)
	btn:SetHandler("OnMouseExit", UnDeadUI.ButtonOnMouseExit)
end

function UnDeadUI.OptionsButtonOnClicked(self)
	UnDeadUI.ShowOptions()
end

function UnDeadUI.ShowOptions()
	LAM:OpenToPanel(UnDeadHarvestSettingsPanel)
end

function UnDeadUI.OptionsButtonOnMouseEnter(self)
	ZO_Tooltips_ShowTextTooltip(self, BOTTOM, "UHS Settings")
end


SLASH_COMMANDS["/uhsoptions"] = UnDeadUI.ShowOptions

