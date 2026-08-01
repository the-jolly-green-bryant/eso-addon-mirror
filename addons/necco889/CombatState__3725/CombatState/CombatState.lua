CombatState = {
    name = 'CombatState',
    author = '@necco889',
    variableVersion = 2,

    -- Settings
    defaults = {
        left = 400,
        top = 300,
        accountwide = true,
        uiunlocked = true,
        chat = false,
        fontsize = 24,
        incombat =
        {
            color = {1, 0, 0, 1},
            text = "In combat",
            hide = false,
            hideDelay = 3,
        },
        outcombat =
        {
            color = {0, 1, 0, 1},
            text = "Out of combat",
            hide = false,
            hideDelay = 3,
        },
    },

}

local self=CombatState

function CombatState.PrintMessage(message, ...)
    local msg = message:format(...)
    df("[|c66a7f5Combat|r|c0fcc0fState|r]: %s", msg)
end

local function updateFont()
    self.lbl:SetFont(string.format("$(MEDIUM_FONT)|$(KB_%d)|soft-shadow-thick", CombatState.SV.fontsize))
end

function CombatState.OnMoveStop()
    self.SV.left = CombatStateFrame:GetLeft();
    self.SV.top = CombatStateFrame:GetTop();
end

function CombatState.UnlockUI(unlock)
    self.SV.uiunlocked = unlock
    CombatStateFrame:SetMovable(unlock)
    CombatStateFrame:SetMouseEnabled(unlock)
    if unlock then
        self.lbl:SetText("-- combat state --")
        self.lbl:SetHidden(false)
    end
    self.fragment:Refresh()
end

function CombatState.Update(inCombat)
    inCombat = inCombat or IsUnitInCombat("player")
    local data = inCombat and self.SV.incombat or self.SV.outcombat
    if self.SV.chat then
        CombatState.PrintMessage(data.text)
    end
    self.lbl:SetHidden(false)
    self.lbl:SetColor(unpack(data.color))
    self.lbl:SetText(data.text)
    if data.hide then
        zo_callLater( function()
            self.lbl:SetHidden(true)
        end, data.hideDelay * 1000 + 10 )
    end
end

local function onCombatStateEvt(_, inCombat)
    CombatState.Update(inCombat)
end

function CombatState.Initialize()
    EVENT_MANAGER:RegisterForEvent("CombatStateOnCombatState", EVENT_PLAYER_COMBAT_STATE, onCombatStateEvt)
end

local function onPlayerActivated(eventCode)
    EVENT_MANAGER:UnregisterForEvent(CombatState.name, eventCode)
    CombatState.Initialize()

    SCENE_MANAGER:GetScene("hud"):AddFragment(self.fragment);
    SCENE_MANAGER:GetScene("hudui"):AddFragment(self.fragment);
end

function CombatState.OnAddOnLoaded(event, addOnName)
    if addOnName ~= CombatState.name then return end
    EVENT_MANAGER:UnregisterForEvent(CombatState.name, EVENT_ADD_ON_LOADED);

    -- CombatState.SV = ZO_SavedVars:NewAccountWide("CombatStateSavedVars", CombatState.variableVersion, nil, CombatState.defaults)

    CombatState.SV = ZO_SavedVars:NewAccountWide("CombatStateSavedVars", CombatState.variableVersion, nil, CombatState.defaults)
	if not CombatState.SV.accountwide then CombatState.SV  = ZO_SavedVars:NewCharacterIdSettings("CombatStateSavedVars", CombatState.variableVersion, nil, CombatState.defaults) end

    CombatStateFrame:ClearAnchors();
    CombatStateFrame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, CombatState.SV.left, CombatState.SV.top);

    self.fragment = ZO_HUDFadeSceneFragment:New(CombatStateFrame);
    self.frame = CombatStateFrame
    self.lbl = self.frame:GetNamedChild("Label")
    CombatState.UnlockUI(self.SV.uiunlocked)
    CombatState.Update()

    EVENT_MANAGER:RegisterForEvent(CombatState.name, EVENT_PLAYER_ACTIVATED, onPlayerActivated)
    CombatState.AddonMenu()
end

function CombatState.AddonMenu()
    local menuOptions = {
        type                = "panel",
        name                = "Combat State Indicator",
        displayName         = "Combat State Indicator",
        author              = CombatState.author,
        version             = CombatState.version,
        registerForRefresh  = true,
        registerForDefaults = true,
    }

    local dataTable = {
        {
			type = "checkbox",
			name = "Use account wide settings",
			default = CombatState.defaults.accountwide,
			getFunc = function() return CombatStateSavedVars.Default[GetDisplayName()]['$AccountWide']["accountwide"] end,
			setFunc = function(value) CombatStateSavedVars.Default[GetDisplayName()]['$AccountWide']["accountwide"] = value end,
			requiresReload = true,
            width = "full",
		},
        {
            type = "checkbox",
            name = "Unlock UI",
            getFunc = function() return CombatState.SV.uiunlocked end,
            setFunc = function(newValue) CombatState.UnlockUI(newValue) end,
            default = false,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Output to chat",
            getFunc = function() return CombatState.SV.chat end,
            setFunc = function(newValue) CombatState.SV.chat = newValue end,
            default = false,
            width = "full",
        },
        {
            type = "dropdown",
            name = "Font size",
            default = 24,
            choices = {8, 12, 14, 16, 20, 24, 28, 32, 36, 40, 48},
            getFunc = function() return CombatState.SV.fontsize end,
            setFunc = function(value) CombatState.SV.fontsize = value updateFont() end
        },
        {
            type = "divider",
        },
        {
            type = "colorpicker",
            name = "In combat color",
            getFunc = function() return unpack(CombatState.SV.incombat.color) end,
            setFunc = function(r, g, b, a) CombatState.SV.incombat.color = {r, g, b, a} CombatState.Update() end,
            width = "full",
       },
       {
            type = "editbox",
            name = "In combat text",
            getFunc = function() return CombatState.SV.incombat.text end,
            setFunc = function(value)
                CombatState.SV.incombat.text = value
                CombatState.Update()
            end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Hide in combat",
            tooltip = "Turning 'On' will dynamically display the text when you enter combat with the delay settings.  Turning 'Off' will permanenty display the text",
            getFunc = function() return CombatState.SV.incombat.hide end,
            setFunc = function(value) CombatState.SV.incombat.hide = value end,
            default = false,
            width = "full",
        },
        {
            type = "slider",
            name = "Hide in combat delay",
            getFunc = function() return CombatState.SV.incombat.hideDelay end,
            setFunc = function(value) CombatState.SV.incombat.hideDelay = value end,
            min = 1,
            max = 10,
            step = 1,
            default = 1,
            width = "full",
        },

        {
            type = "divider",
        },
        {
            type = "colorpicker",
            name = "Out of combat color",
            getFunc = function() return unpack(CombatState.SV.outcombat.color) end,
            setFunc = function(r, g, b, a) CombatState.SV.outcombat.color = {r, g, b, a} CombatState.Update() end,
            width = "full",
       },
       {
            type = "editbox",
            name = "Out of combat text",
            getFunc = function() return CombatState.SV.outcombat.text end,
            setFunc = function(value)
                CombatState.SV.outcombat.text = value
                CombatState.Update()
            end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Hide out of combat",
            tooltip = "Turning 'On' will dynamically display the text when you exit combat with the delay settings.  Turning 'Off' will permanenty display the text",
            getFunc = function() return CombatState.SV.outcombat.hide end,
            setFunc = function(value) CombatState.SV.outcombat.hide = value end,
            default = false,
            width = "full",
        },
        {
            type = "slider",
            name = "Hide out of combat delay",
            getFunc = function() return CombatState.SV.outcombat.hideDelay end,
            setFunc = function(value) CombatState.SV.outcombat.hideDelay = value end,
            min = 1,
            max = 10,
            step = 1,
            default = 1,
            width = "full",
        },
    }

    LAM = LibAddonMenu2
    LAM:RegisterAddonPanel(CombatState.name .. "Options", menuOptions )
    LAM:RegisterOptionControls(CombatState.name .. "Options", dataTable )
end


EVENT_MANAGER:RegisterForEvent(CombatState.name, EVENT_ADD_ON_LOADED, CombatState.OnAddOnLoaded)