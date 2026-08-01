local synergyWasHooked = false
local BetterSynergy = {}

BetterSynergy.savedVariables = ZO_SavedVars:NewAccountWide("BetterSynergySavedVars", 1, nil, {
    synergyScale = 1.0,
    hideText = true,
    hideIcon = false,
    hideKey = false,
    uiUnlocked = false,
    uiX = nil,
    uiY = nil,
	playSoundOnSynergy = true
})

local function InitializeDefaultPosition()
    zo_callLater(function()
        if BetterSynergy.savedVariables.uiX == nil or BetterSynergy.savedVariables.uiY == nil then
            if SYNERGY and SYNERGY.container then
                local left, top = SYNERGY.container:GetLeft(), SYNERGY.container:GetTop()
                if left and top then
                    BetterSynergy.savedVariables.uiX = left
                    BetterSynergy.savedVariables.uiY = top
                    d("Setting initial position from SYNERGY container: ", left, top)
                else
                    d("SYNERGY position not found. Keeping uiX and uiY as nil.")
                end
            else
                d("SYNERGY not available at init. Keeping uiX and uiY nil.")
            end
        else
            d("Skipping InitializeDefaultPosition, using saved values: ", BetterSynergy.savedVariables.uiX, BetterSynergy.savedVariables.uiY)
        end
    end, 500) -- Delay by 500ms to ensure saved variables are loaded
end


local function HandleSynergySound()
    if BetterSynergy.savedVariables.playSoundOnSynergy then
        PlaySound(SOUNDS.QUEST_OBJECTIVE_STARTED) -- Custom sound, can be changed
    else
        SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_SYNERGY, 0) -- Suppress game’s synergy sound
    end
end

local function InitializeBetterSynergyUI()
    InitializeDefaultPosition()
    BetterSynergyUI = WINDOW_MANAGER:CreateTopLevelWindow("BetterSynergyUI")
    BetterSynergyUI:SetDimensions(300, 50)
    BetterSynergyUI:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, BetterSynergy.savedVariables.uiX, BetterSynergy.savedVariables.uiY)
    BetterSynergyUI:SetMovable(BetterSynergy.savedVariables.uiUnlocked)
    BetterSynergyUI:SetMouseEnabled(BetterSynergy.savedVariables.uiUnlocked)
    BetterSynergyUI:SetDrawLayer(DT_TOP)
    BetterSynergyUI:SetDrawLevel(99999)
    BetterSynergyUI:SetHidden(false)

    BetterSynergyUI:SetHandler("OnMoveStop", function()
        if BetterSynergy.savedVariables.uiUnlocked then
            BetterSynergy.savedVariables.uiX = BetterSynergyUI:GetLeft()
            BetterSynergy.savedVariables.uiY = BetterSynergyUI:GetTop()
            d("Saved new position (OnMoveStop): ", BetterSynergy.savedVariables.uiX, BetterSynergy.savedVariables.uiY)
        end
    end)

    -- 🔹 Initialize the Preview Frame Inside UI Setup
    BetterSynergy.previewFrame = WINDOW_MANAGER:CreateControl("BetterSynergyPreviewFrame", BetterSynergyUI, CT_BACKDROP)
    BetterSynergy.previewFrame:SetAnchorFill(BetterSynergyUI)
    BetterSynergy.previewFrame:SetCenterColor(0, 0, 1, 0.6)  -- Semi-transparent blue
    BetterSynergy.previewFrame:SetEdgeColor(1, 1, 1, 1) -- White border
    BetterSynergy.previewFrame:SetDrawLayer(DT_TOP)
    BetterSynergy.previewFrame:SetDrawLevel(99999)
    BetterSynergy.previewFrame:SetHidden(true)

    d("Preview frame initialized and anchored to BetterSynergyUI")
end



local function ShowPreviewFrame()
    if BetterSynergy.previewFrame then
        BetterSynergyUI:SetHidden(false)
        BetterSynergy.previewFrame:SetHidden(false)
        d("Preview frame is now visible.") -- Debugging
    else
        d("Warning: Preview frame not found!")
    end
end

local function HidePreviewFrame()
    if BetterSynergy.previewFrame then
        BetterSynergy.previewFrame:SetHidden(true)
    end
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
    
        if BetterSynergy.savedVariables.uiUnlocked then
        ShowPreviewFrame()
        
        -- Ensure the preview frame matches the updated synergy frame position
        if BetterSynergy.savedVariables.uiX and BetterSynergy.savedVariables.uiY then
            BetterSynergy.previewFrame:ClearAnchors()
            BetterSynergy.previewFrame:SetAnchor(TOPLEFT, BetterSynergyUI, TOPLEFT, BetterSynergy.savedVariables.uiX, BetterSynergy.savedVariables.uiY)
            d("Updated preview frame position to:", BetterSynergy.savedVariables.uiX, BetterSynergy.savedVariables.uiY)
        end
    else
        HidePreviewFrame()
    end


    
    HandleSynergySound()
end


local function RestoreDefaults()
    BetterSynergy.savedVariables.synergyScale = 1.0
    BetterSynergy.savedVariables.hideText = false
    BetterSynergy.savedVariables.hideIcon = false
    BetterSynergy.savedVariables.hideKey = false
    BetterSynergy.savedVariables.uiUnlocked = false
	BetterSynergy.savedVariables.uiX = nil
    BetterSynergy.savedVariables.uiY = nil
	BetterSynergy.savedVariables.playSoundOnSynergy = false
    InitializeDefaultPosition()
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
            name = "Play Synergy Sound",
            tooltip = "Toggle playing a sound when synergy is available.",
            getFunc = function() return BetterSynergy.savedVariables.playSoundOnSynergy end,
            setFunc = function(value) BetterSynergy.savedVariables.playSoundOnSynergy = value ApplySynergySettings() end,
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
	InitializeDefaultPosition()
    InitializeBetterSynergyUI()
    CreateSettingsMenu()
    HookSynergyFunction()
    EVENT_MANAGER:RegisterForEvent("BetterSynergy", EVENT_PLAYER_ACTIVATED, ApplySynergySettings)
end

EVENT_MANAGER:RegisterForEvent("BetterSynergy", EVENT_ADD_ON_LOADED, OnAddOnLoaded)
