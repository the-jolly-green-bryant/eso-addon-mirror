local ADDON_NAME = "RewardPopupsReworked"

RewardPopupsReworked = {
    name = ADDON_NAME,
    displayName = "Reward Popups Reworked",
    version = "1.0.8",
    author = "SlickStyles",
    sourceOrder = {},
    sources = {},
    session = {},
    defaults = {
        general = {
            enabled = false,
            lockActionWidget = false,
            glowAnimation = true,
            pulseAnimation = false,
            tooltips = true,
            notificationMessages = true,
            showWelcome = true,
            debug = false,
        },
        widget = {
            x = 0,
            y = 0,
        },
        tamrielTomes = {
            replacePopup = false,
            autoClaimRewards = false,
        },
        goldenPursuits = {
            replacePopup = false,
            autoClaimSafeRewards = false,
            preventAutomaticActivityPinning = false,
            enableActionWidget = true,
        },
        veterancyRewards = {
            replaceNotification = false,
            autoClaimRewards = false,
        },
    },
}

local RPR = RewardPopupsReworked

function RPR:RegisterSource(source)
    if not source or not source.id then return end

    if not self.sources[source.id] then
        table.insert(self.sourceOrder, source)
    end

    self.sources[source.id] = source
end

function RPR:Notify(message, force)
    if not message or message == "" then return end

    local general = self.savedVars and self.savedVars.general
    if not force and general and general.notificationMessages == false then return end

    local formatted = string.format("|cC7E8FF%s|r %s", self.displayName, message)
    if CHAT_SYSTEM and CHAT_SYSTEM.AddMessage then
        CHAT_SYSTEM:AddMessage(formatted)
    elseif d then
        d(formatted)
    end
end

function RPR:Debug(message)
    if self.savedVars and self.savedVars.general and self.savedVars.general.debug then
        self:Notify("[debug] " .. tostring(message), true)
    end
end

function RPR:NotifyOnce(key, message, cooldownMs)
    if not key or not message then return end

    cooldownMs = cooldownMs or 8000
    self.session.noticeTimes = self.session.noticeTimes or {}

    local now = GetFrameTimeMilliseconds and GetFrameTimeMilliseconds() or 0
    local previous = self.session.noticeTimes[key] or 0
    if now - previous < cooldownMs then return end

    self.session.noticeTimes[key] = now
    self:Notify(message)
end

function RPR:DisableAllClaiming()
    self.savedVars.tamrielTomes.autoClaimRewards = false
    self.savedVars.goldenPursuits.autoClaimSafeRewards = false
    self.savedVars.veterancyRewards.autoClaimRewards = false
end

function RPR:EnableAllClaiming()
    self.savedVars.tamrielTomes.autoClaimRewards = true
    self.savedVars.goldenPursuits.autoClaimSafeRewards = true
    self.savedVars.veterancyRewards.autoClaimRewards = true
end

function RPR:EnableCoreFeatures(enableAutoClaim)
    self.savedVars.general.enabled = true
    self.savedVars.tamrielTomes.replacePopup = true
    self.savedVars.goldenPursuits.replacePopup = true
    self.savedVars.goldenPursuits.preventAutomaticActivityPinning = true
    self.savedVars.goldenPursuits.enableActionWidget = true
    self.savedVars.veterancyRewards.replaceNotification = true

    if enableAutoClaim == true then
        self:EnableAllClaiming()
    else
        self:DisableAllClaiming()
    end

    if self.RewardManager and self.RewardManager.RefreshLater then
        self.RewardManager:RefreshLater("features enabled", 250)
    end
end

function RPR:MigrateSavedVariables()
    self.savedVars.general = self.savedVars.general or {}
    self.savedVars.tamrielTomes = self.savedVars.tamrielTomes or {}
    self.savedVars.goldenPursuits = self.savedVars.goldenPursuits or {}
    self.savedVars.veterancyRewards = self.savedVars.veterancyRewards or {}
    self.savedVars.migrations = self.savedVars.migrations or {}
    self.savedVars.general.showWelcome = self.savedVars.general.showWelcome ~= false

    self.savedVars.general.debug = self.savedVars.general.debug == true

    if not self.savedVars.migrations.disableDefaultClaiming then
        self:DisableAllClaiming()
        self.savedVars.migrations.disableDefaultClaiming = true
    end
end

function RPR:Initialize()
    self.savedVars = ZO_SavedVars:NewAccountWide("RewardPopupsReworkedSavedVariables",1,nil,self.defaults,GetWorldName())
    self:MigrateSavedVariables()
    self.session = {
        widgetHidden = false,
        widgetPreview = false,
        manualSignature = "",
        noticeTimes = {},
    }

    if self.PopupSuppressor and self.PopupSuppressor.Initialize then
        self.PopupSuppressor:Initialize()
    end

    if self.ActionWidget and self.ActionWidget.Initialize then
        self.ActionWidget:Initialize()
    end

    if self.WelcomeDialog and self.WelcomeDialog.Initialize then
        self.WelcomeDialog:Initialize()
    end

    if self.Settings and self.Settings.Initialize then
        self.Settings:Initialize()
    end

    if self.RewardManager and self.RewardManager.Initialize then
        self.RewardManager:Initialize()
    end
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= ADDON_NAME then return end

    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
    RPR:Initialize()
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
