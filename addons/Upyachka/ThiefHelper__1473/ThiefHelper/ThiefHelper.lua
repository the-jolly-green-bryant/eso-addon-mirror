--- Local imports:
local ProvidersController = LibStub:GetLibrary("Up_ProvidersController")
local SettingsController = LibStub:GetLibrary("Up_SettingsController")
local UiFactory = LibStub:GetLibrary("Up_UiFactory")
local UiController = LibStub:GetLibrary("Up_UiController")
local FloatingWindowPresenter = LibStub:GetLibrary("Up_FloatingWindowPresenter")
local AddonConfigurator = LibStub:GetLibrary("Up_AddonConfigurator")
local SettingsMenu = LibStub:GetLibrary("Up_WindowSettingsMenu")

local self = ThiefHelper

-- Other addons can add their custom providers.
self.ProvidersController = ProvidersController:new()

local function getColorizedTextDependsDifficulty(text, difficulty)
    if not difficulty or difficulty < 3 then
       return text
    end
    if difficulty == 2 then
        return string.format("|cADD8E6%s|r", text)
    elseif difficulty == 3 then
        return string.format("|c4169E1%s|r", text)
    elseif difficulty > 4 then
        return string.format("|c800080%s|r", text)
    end
end

-- function callback to initialize addon on first loading. Required by Up_AddonConfigurator
function self.onLoaded(event)
    SettingsController.loadSettings(self)
    self.UiController = UiController:new(self.Settings, self)
    self.UiController:initializeUI()
    SettingsMenu.createMenu(self, GetString(THIEF_HELPER_ADDON_NAME))

    local presenter = FloatingWindowPresenter:new(self, self.UI.Window, UiFactory, "general", self.Settings)
    self.ProvidersController:registerProvider("FenceDataProvider", FenceDataProvider:new())
    self.ProvidersController:registerProvider("ThiefBagDataProvider", ThiefBagDataProvider:new())
    self.ProvidersController:registerProvider("RecallCooldownDataProvider", RecallCooldownDataProvider:new())
    presenter:start()

    local difficultyHistory = self.Settings.DifficultyHistory or {}
    self.Settings.DifficultyHistory = difficultyHistory

    local function OnReticleTargetChanged()
        local action, interactableName, interactionBlocked, isOwned, additionalInteractInfo, context, contextLink, isCriminalInteract = GetGameCameraInteractableActionInfo()
        if not interactableName then return end
        local text = RETICLE.interactContext:GetText()
        local rawName = GetRawUnitName("reticleover")
        if additionalInteractInfo == ADDITIONAL_INTERACT_INFO_PICKPOCKET_CHANCE then
            local inBonus, isHostile, percentChance, difficulty, isEmpty, prospectiveResult, monsterClassString = GetGameCameraPickpocketingBonusInfo()
            text = getColorizedTextDependsDifficulty(text, difficulty)
            if difficulty > 2 then
                difficultyHistory[interactableName] = difficulty
                --d("Raw: " .. (rawName or "NoRaw") .. " Name: " .. (interactableName or "NoInteractableName") .. " " .. difficulty)
            end
        end
        RETICLE.interactContext:SetText(text)
    end

    local native = RETICLE.UpdateInteractText
    RETICLE.UpdateInteractText = function() native(RETICLE) OnReticleTargetChanged() end

    local native = GetUnitName
    GetUnitName = function(unitTag)
        local name = native(unitTag)
        return getColorizedTextDependsDifficulty(name, difficultyHistory[name])
    end
end

-- Invocation of Up_AddonConfigurator to bind onLoaded as callback for first time of addon loading.
AddonConfigurator.configureOnLoadedCallback(self)
