AbilityIDToolkit = AbilityIDToolkit or {}
local AIT = AbilityIDToolkit

function AIT:ReturnToGameplayForCapture()
    zo_callLater(function()
        if SCENE_MANAGER and SCENE_MANAGER.SetInUIMode then
            SCENE_MANAGER:SetInUIMode(false)
        elseif SCENE_MANAGER and SCENE_MANAGER.ShowBaseScene then
            SCENE_MANAGER:ShowBaseScene()
        end
    end, 1)
end

function AIT:RefreshSettingsPanel(rebuild)
    local panel = self.settingsPanel
    if not panel then return end

    -- LibHarvensAddonSettings console pages calculate their scroll/focus geometry
    -- when the addon page is selected.  Dynamic labels can change height/content
    -- after that calculation, so use Votan's native page-reselect pattern when
    -- the visible result set changes.
    if rebuild and panel.selected and panel.Select then
        panel.selected = false
        panel:Select()
        return
    end

    if panel.UpdateControls then
        panel:UpdateControls()
    elseif panel.RefreshSettings then
        panel:RefreshSettings()
    end
end

function AIT:InitializeSettings()
    if not LibHarvensAddonSettings then return end

    local panel = LibHarvensAddonSettings:AddAddon("Ability ID Toolkit")
    self.settingsPanel = panel
    local H = LibHarvensAddonSettings

    local function add(def)
        if panel and panel.AddSetting then panel:AddSetting(def) end
    end

    add({ type=H.ST_LABEL, label="|cE6C34BABILITY ID TOOLKIT|r\n|cE6C34BA BMG Addon|r\nCreated and maintained by @BMGXSANCHO" })

    add({ type=H.ST_SECTION, label="Capture" })
    add({
        type=H.ST_BUTTON,
        label="Start 12-Second Capture",
        tooltip="Starts capture and returns to normal gameplay. Proc the set or ability during the 12-second window, then reopen Ability ID Toolkit to review the results below.",
        buttonText="START",
        clickHandler=function()
            self:StartCapture()
            self:ReturnToGameplayForCapture()
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, "Ability ID capture started - proc the set or ability now.")
        end,
    })
    add({ type=H.ST_CHECKBOX, label="Capture Effect Events", tooltip="Records EVENT_EFFECT_CHANGED ability IDs while capture is active.", getFunction=function() return self.sv.captureEffectEvents end, setFunction=function(v) self.sv.captureEffectEvents=v end, default=true })
    add({ type=H.ST_CHECKBOX, label="Capture Combat Events", tooltip="Records EVENT_COMBAT_EVENT ability IDs while capture is active.", getFunction=function() return self.sv.captureCombatEvents end, setFunction=function(v) self.sv.captureCombatEvents=v end, default=true })
    add({ type=H.ST_CHECKBOX, label="Local Player Source Only", tooltip="When enabled, ignores combat events clearly sourced from other players. Leave off when diagnosing recipient cooldowns or target effects.", getFunction=function() return self.sv.localPlayerOnly end, setFunction=function(v) self.sv.localPlayerOnly=v end, default=false })

    add({ type=H.ST_SECTION, label="Last Capture Results" })
    add({ type=H.ST_LABEL, label=function() return tostring(self:GetCaptureSummary() or "") end, canSelect=true })
    for i=1,80 do
        local resultIndex = i
        add({
            type=H.ST_LABEL,
            label=function() return tostring(self:GetCaptureResultText(resultIndex) or "") end,
            canSelect=true,
            disable=function() return self:GetCaptureResultText(resultIndex) == "" end,
        })
    end

    add({ type=H.ST_SECTION, label="Ability Lookup" })
    add({ type=H.ST_EDIT, label="Search Ability ID or Name", tooltip="Enter an exact numeric Ability ID or part of a known name.", getFunction=function() return self.sv.lookupQuery or "" end, setFunction=function(v) self.sv.lookupQuery=tostring(v or "") end, default="" })
    add({
        type=H.ST_BUTTON,
        label="Run Ability Search",
        buttonText="SEARCH",
        clickHandler=function()
            self:RunLookup(self.sv.lookupQuery or "")
        end,
    })
    add({
        type=H.ST_BUTTON,
        label="Show All Known IDs",
        buttonText="SHOW ALL",
        clickHandler=function()
            self.sv.lookupQuery = ""
            self:RunLookup("")
        end,
    })
    add({ type=H.ST_LABEL, label=function() return tostring(self:GetLookupSummary() or "") end, canSelect=true })
    for i=1,12 do
        local resultIndex = i
        add({
            type=H.ST_LABEL,
            label=function() return tostring(self:GetLookupResultText(resultIndex) or "") end,
            canSelect=true,
            disable=function() return self:GetLookupResultText(resultIndex) == "" end,
        })
    end

    add({ type=H.ST_SECTION, label="Database" })
    add({ type=H.ST_BUTTON, label="Clear Current Capture", buttonText="CLEAR", clickHandler=function() self:ClearLog(); self:RefreshSettingsPanel(true) end })
    add({ type=H.ST_BUTTON, label="Clear Saved Discoveries", buttonText="CLEAR", clickHandler=function() self.sv.known={}; self.sv.sessions={}; self.lookupResults={}; self:RefreshSettingsPanel(true) end })

    add({ type=H.ST_SECTION, label="Navigation" })
    add({ type=H.ST_LABEL, label="All results use ESO's normal Addon Settings controls. D-pad Up/Down scrolls the menu and Circle returns normally. No separate popup or custom input layer is used." })
end
