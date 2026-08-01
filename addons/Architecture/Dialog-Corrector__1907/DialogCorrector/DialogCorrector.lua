local DialogCorrector = ZO_Object:Subclass()

local LAM = LibStub:GetLibrary("LibAddonMenu-2.0")

function DialogCorrector:SetupOptions()
	local addonDisplayName = "Dialog Corrector"

	local panelData = {
		type = "panel",
		name = addonDisplayName,
		displayName = addonDisplayName,
		author = "|c0066FFArchitecture|r, SlippyCheeze",
                website = "http://www.esoui.com/downloads/info1907-DialogCorrector.html",
		version = "1.1.1",
		registerForRefresh = true,
		registerForDefaults = false,
	}

	local optionsTable = {
		{
			type = "header",
			name = "Dialog Interaction Enhancements",
			width = "full",
		},
                {
                        type = "description",
                        title = "Fix Spacing Inconsistencies",
                        text = [[Unfortunately, the typography in quest and NPC dialog has been quite inconsistent. In some places one space is used at the end of a sentence, in others two. Sometimes, this is even inside a single dialog!

This is rather frustrating if you notice that sort of thing, so this addon can correct the problem by enforcing either single or double spacing at the end of a sentence.

Select your preferred style below, and remember: nobody is wrong, we just like different things.
]],
                },
		{
			type = "checkbox",
			name = "Enable Typography Correction",
			tooltip = "Automatically normalize spaces at the end of sentences.",
			getFunc = function()
                           return self.sv.enabled
                        end,
			setFunc = function(value)
                           self.sv.enabled = value
                           if (value) then
                              self:HookDialogInteraction()
                           end
                        end,
			width = "full",
		},
                {
                        type = "checkbox",
                        name = "Use two spaces, not one, between sentences?",
                        tooltip = "Use two spaces between sentences, or only one?",
                        getFunc = function()
                           return self.sv.twoSpaces
                        end,
                        setFunc = function(value)
                           self.sv.twoSpaces = value
			   self:SetupSpaces()
                        end,
                        width = "full",
                },
	}

	LAM:RegisterAddonPanel(self.name, panelData)
	LAM:RegisterOptionControls(self.name, optionsTable)
end

function DialogCorrector:HookDialogInteraction()
	if (self.hasEnabled) then return end
	self.hasEnabled = true

	local addon = self
	local original = ZO_InteractWindowTargetAreaBodyText.SetText
	ZO_InteractWindowTargetAreaBodyText.SetText = function(control, text)
		if addon.sv.enabled and text and addon.spaces then
			text = text:gsub("([.?!])  ?", addon.spaces)
		end
	        return original(control, text)
	end
end

function DialogCorrector:SetupSpaces()
	if self.sv.twoSpaces then
		self.spaces = "%1  "
	else
		self.spaces = "%1 "
	end
end

function DialogCorrector:Initialize(addonName)
	self.hasEnabled = false
	self.name = addonName

	self.defaults = {
		enabled = true,
		twoSpaces = false,
	}

	self.sv = ZO_SavedVars:NewAccountWide(self.name.."_SavedVariables", 1, nil, self.defaults)

	self:SetupOptions(self.name)
	self:SetupSpaces()

	if (self.sv.enabled) then
		self:HookDialogInteraction()
	end

end

INTERACTION_DIALOG_CORRECTOR = DialogCorrector:New()

local function DialogCorrector_Init(_, addonName)
	if addonName ~= "DialogCorrector" then
		return
	end

	INTERACTION_DIALOG_CORRECTOR:Initialize(addonName)
end

EVENT_MANAGER:RegisterForEvent("DialogCorrectorInit", EVENT_ADD_ON_LOADED, DialogCorrector_Init)
