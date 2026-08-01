local synergyWasHooked = false
local BetterSynergy = {}

local function LoadSavedVariables()
    BetterSynergy.savedVariables = ZO_SavedVars:NewAccountWide("BetterSynergySavedVars", 1, nil, {
        synergyScale = 1.0,
        hideText = true,
        hideIcon = false,
        hideKey = false,
        uiUnlocked = false,
        uiX = nil,
        uiY = nil
    })
end


local function InitializePreviewFrame()
    if not BetterSynergyUI then
        InitializeBetterSynergyUI()
    end
    
    BetterSynergy.previewFrame = WINDOW_MANAGER:CreateControl("BetterSynergyPreviewFrame", BetterSynergyUI, CT_BACKDROP)
    BetterSynergy.previewFrame:SetAnchorFill(BetterSynergyUI)
    BetterSynergy.previewFrame:SetCenterColor(0, 0, 1, 1)  -- Full solid blue
    BetterSynergy.previewFrame:SetEdgeColor(1, 1, 1, 1) -- White border
    BetterSynergy.previewFrame:SetDrawLayer(DT_TOP)
    BetterSynergy.previewFrame:SetDrawLevel(99999)
    BetterSynergy.previewFrame:SetHidden(true)
end

local function ShowPreviewFrame()
    if not BetterSynergy.previewFrame then
        InitializePreviewFrame()
    end
    BetterSynergyUI:SetHidden(false)
    BetterSynergy.previewFrame:SetHidden(false)
end

local function HidePreviewFrame()
    if BetterSynergy.previewFrame then
        BetterSynergy.previewFrame:SetHidden(true)
    end
end

local function SaveFramePosition()
    BetterSynergy.savedVariables.uiX = BetterSynergyUI:GetLeft()
    BetterSynergy.savedVariables.uiY = BetterSynergyUI:GetTop()
end

local function ApplySynergySettings()
    if not SYNERGY then return end
    
    if BetterSynergy.savedVariables.hideText and SYNERGY.action then
        SYNERGY.action:SetHidden(true)
    else
        SYNERGY.action:SetHidden(false)
    end

    if BetterSynergy.savedVariables.hideIcon and SYNERGY.icon then
        SYNERGY.icon:SetHidden(true)
    else
        SYNERGY.icon:SetHidden(false)
    end

    if BetterSynergy.savedVariables.hideKey and SYNERGY.key then
        SYNERGY.key:SetHidden(true)
    else
        SYNERGY.key:SetHidden(false)
    end

    local scale = BetterSynergy.savedVariables.synergyScale or 1.0
    SYNERGY.container:SetScale(scale)

    if BetterSynergy.savedVariables.uiX and BetterSynergy.savedVariables.uiY then
        SYNERGY.container:ClearAnchors()
        SYNERGY.container:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, BetterSynergy.savedVariables.uiX, BetterSynergy.savedVariables.uiY)
    end
	
    BetterSynergyUI:SetMovable(BetterSynergy.savedVariables.uiUnlocked)
    BetterSynergyUI:SetMouseEnabled(BetterSynergy.savedVariables.uiUnlocked)
    
    if BetterSynergy.savedVariables.uiUnlocked then
        ShowPreviewFrame()
    else
        HidePreviewFrame()
    end
end


local function InitializeBetterSynergyUI()
    BetterSynergyUI = WINDOW_MANAGER:CreateTopLevelWindow("BetterSynergyUI")
    BetterSynergyUI:SetDimensions(300, 50)
    BetterSynergyUI:SetMovable(BetterSynergy.savedVariables.uiUnlocked)
    BetterSynergyUI:SetMouseEnabled(BetterSynergy.savedVariables.uiUnlocked)
    BetterSynergyUI:SetDrawLayer(DT_TOP)
    BetterSynergyUI:SetDrawLevel(99999)
    BetterSynergyUI:SetHidden(false)

		zo_callLater(function()
    -- Ensure saved variables are properly loaded before proceeding
    if BetterSynergy.savedVariables == nil then
        LoadSavedVariables()
    end

    if BetterSynergy.savedVariables.uiX ~= nil and BetterSynergy.savedVariables.uiY ~= nil then

		BetterSynergyUI:ClearAnchors()
		BetterSynergyUI:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, BetterSynergy.savedVariables.uiX, BetterSynergy.savedVariables.uiY)
	elseif SYNERGY and SYNERGY.container then
		local left, top = SYNERGY.container:GetLeft(), SYNERGY.container:GetTop()
		if left and top then
			BetterSynergy.savedVariables.uiX = left
			BetterSynergy.savedVariables.uiY = top
			BetterSynergyUI:ClearAnchors()
			BetterSynergyUI:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
		else
			BetterSynergyUI:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 800, 800)
		end
	else
		BetterSynergyUI:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 800, 800)
	end
end, 600)


	BetterSynergyUI:SetHandler("OnMoveStop", function()
		if BetterSynergy.savedVariables == nil then
			LoadSavedVariables()
		end

		BetterSynergy.savedVariables.uiX = BetterSynergyUI:GetLeft()
		BetterSynergy.savedVariables.uiY = BetterSynergyUI:GetTop()

		-- Force UI to refresh and apply the new saved position
		ApplySynergySettings()
end)




end




local function RestoreDefaults()
    BetterSynergy.savedVariables.synergyScale = 1.0
    BetterSynergy.savedVariables.hideText = true
    BetterSynergy.savedVariables.hideIcon = false
    BetterSynergy.savedVariables.hideKey = false
    BetterSynergy.savedVariables.uiUnlocked = false
    BetterSynergy.savedVariables.uiX = nil
    BetterSynergy.savedVariables.uiY = nil
    ApplySynergySettings()
end

local function HookSynergyFunction()
    if synergyWasHooked or not SYNERGY then return end

    SecurePostHook(SYNERGY, "OnSynergyAbilityChanged", function(self, ...)
        ApplySynergySettings()
    end)
    synergyWasHooked = true
end

local function CreateSettingsMenu()
    local LAM = LibAddonMenu2
    local panelData = {
        type = "panel",
        name = "BetterSynergy",
        displayName = "Better Synergy",
        author = "SkullElf",
        version = "1.0",
        registerForRefresh = true,
        registerForDefaults = true,
    }
    
    local optionsData = {
        {
            type = "slider",
            name = "Synergy Frame Size",
            tooltip = "Adjust the size of the synergy prompt.",
            min = 0.5,
            max = 2.0,
            step = 0.1,
            getFunc = function() return BetterSynergy.savedVariables.synergyScale end,
            setFunc = function(value) BetterSynergy.savedVariables.synergyScale = value ApplySynergySettings() end,
        },
        {
            type = "checkbox",
            name = "Hide Synergy Text",
            tooltip = "Toggle hiding the synergy activation text.",
            getFunc = function() return BetterSynergy.savedVariables.hideText end,
            setFunc = function(value) BetterSynergy.savedVariables.hideText = value ApplySynergySettings() end,
        },
        {
            type = "checkbox",
            name = "Hide Synergy Icon",
            tooltip = "Toggle hiding the synergy activation icon.",
            getFunc = function() return BetterSynergy.savedVariables.hideIcon end,
            setFunc = function(value) BetterSynergy.savedVariables.hideIcon = value ApplySynergySettings() end,
        },
        {
            type = "checkbox",
            name = "Hide Synergy Keybind",
            tooltip = "Toggle hiding the synergy keybind.",
            getFunc = function() return BetterSynergy.savedVariables.hideKey end,
            setFunc = function(value) BetterSynergy.savedVariables.hideKey = value ApplySynergySettings() end,
        },
        {
            type = "checkbox",
            name = "Unlock Synergy Frame",
            tooltip = "Allows you to move the synergy frame.",
            getFunc = function() return BetterSynergy.savedVariables.uiUnlocked end,
            setFunc = function(value)
                BetterSynergy.savedVariables.uiUnlocked = value
                BetterSynergyUI:SetMovable(value)
                BetterSynergyUI:SetMouseEnabled(value)
                ApplySynergySettings()
            end,
        },
        {
            type = "button",
            name = "Show Preview Frame",
            tooltip = "Displays a preview of the synergy frame.",
            func = function()
                ShowPreviewFrame()
            end,
        },
        {
            type = "button",
            name = "Hide Preview Frame",
            tooltip = "Hides the preview of the synergy frame.",
            func = function()
                HidePreviewFrame()
            end,
        },
        {
            type = "button",
            name = "Restore Defaults",
            tooltip = "Reset all settings to default values.",
            func = RestoreDefaults,
        }
    }

    
    LAM:RegisterAddonPanel("BetterSynergyOptions", panelData)
    LAM:RegisterOptionControls("BetterSynergyOptions", optionsData)
end

local function OnAddOnLoaded(event, addonName)
    if addonName ~= "BetterSynergy" then return end
    EVENT_MANAGER:UnregisterForEvent("BetterSynergy", EVENT_ADD_ON_LOADED)
	LoadSavedVariables()
    InitializeBetterSynergyUI()
    InitializePreviewFrame()
    CreateSettingsMenu()
    HookSynergyFunction()
    EVENT_MANAGER:RegisterForEvent("BetterSynergy", EVENT_PLAYER_ACTIVATED, ApplySynergySettings)
end

EVENT_MANAGER:RegisterForEvent("BetterSynergy", EVENT_ADD_ON_LOADED, OnAddOnLoaded)
