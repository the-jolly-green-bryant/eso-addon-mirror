--- @class GamepadMiniChatTabsSettingsManager : GamepadMiniChatTabsBaseModule
--- @field panel table? The LibHarvensAddonSettings panel
local GamepadMiniChatTabsSettingsManager = GamepadMiniChatTabsBaseModule:Subclass();

--- Creates a new settings manager instance
--- @param manager GamepadMiniChatTabs The main manager instance
--- @return GamepadMiniChatTabsSettingsManager
function GamepadMiniChatTabsSettingsManager:New(manager)
    local obj = GamepadMiniChatTabsBaseModule.New(self, manager);
    return obj;
end;

--- Initializes the settings manager
--- @param manager GamepadMiniChatTabs The main manager instance
function GamepadMiniChatTabsSettingsManager:Initialize(manager)
    GamepadMiniChatTabsBaseModule.Initialize(self, manager);
    self.panel = nil;
end;

function GamepadMiniChatTabsSettingsManager:OnInitialize()
    if not self:IsChatSystemAvailable() then
        return;
    end;

    self:CreateSettingsPanel();
end;

--- Creates the LibHarvensAddonSettings panel
function GamepadMiniChatTabsSettingsManager:CreateSettingsPanel()
    local manager = self;

    self.panel = LibHarvensAddonSettings:AddAddon("Gamepad Chat",
                                                  {
                                                      allowDefaults = true;
                                                      defaultsFunction = function ()
                                                          manager:ResetToDefaults();
                                                      end;
                                                      allowRefresh = true
                                                  });

    self:AddFontSettings();
    self:AddTabManagement();
    self:AddFadeSettings();
end;

--- Adds font and appearance settings
function GamepadMiniChatTabsSettingsManager:AddFontSettings()
    self.panel:AddSetting(
        {
            type = LibHarvensAddonSettings.ST_SECTION;
            label = "Font & Appearance"
        });

    self.panel:AddSetting(
        {
            type = LibHarvensAddonSettings.ST_DROPDOWN;
            label = "Font Size";
            tooltip = "Adjust chat text size.";
            items =
            {
                { name = "Small";  data = GAMEPAD_CHAT_TEXT_SIZE_SETTING_SMALL  };
                { name = "Medium"; data = GAMEPAD_CHAT_TEXT_SIZE_SETTING_MEDIUM };
                { name = "Large";  data = GAMEPAD_CHAT_TEXT_SIZE_SETTING_LARGE  }
            };
            getFunction = function ()
                local currentSize = GetGamepadChatFontSize();
                if currentSize == GAMEPAD_CHAT_TEXT_SIZE_SETTING_SMALL then
                    return "Small";
                elseif currentSize == GAMEPAD_CHAT_TEXT_SIZE_SETTING_LARGE then
                    return "Large";
                else
                    return "Medium";
                end;
            end;
            setFunction = function (control, itemName, itemData)
                local fontSize = itemData.data or itemData;
                SetGamepadChatFontSize(fontSize);
                local chatSystem = self:GetChatSystem();
                if chatSystem then
                    chatSystem:SetFontSize(fontSize);
                end;
            end;
            default = "Medium"
        });
end;

--- Adds tab management settings
function GamepadMiniChatTabsSettingsManager:AddTabManagement()
    self.panel:AddSetting(
        {
            type = LibHarvensAddonSettings.ST_SECTION;
            label = "Tab Management"
        });

    local container = self:GetContainer();
    if container and container.windows then
        for tabIndex, window in ipairs(container.windows) do
            self:AddTabNameEditor(tabIndex);
        end;
    end;

    self:AddCreateTabButton();
end;

--- Adds a tab name editor
--- @param tabIndex integer The tab index
function GamepadMiniChatTabsSettingsManager:AddTabNameEditor(tabIndex)
    local manager = self;
    local container = manager:GetContainer();
    if not container then return; end;
    local tabName = container:GetTabName(tabIndex);
    local isPrimaryTab = container:IsPrimary() and tabIndex == 1;

    -- Rename edit box
    self.panel:AddSetting(
        {
            type = LibHarvensAddonSettings.ST_EDIT;
            label = "Tab " .. tabIndex .. " Name";
            tooltip = "Enter new name for this tab";
            textType = TEXT_TYPE_ALL;
            maxChars = 50;
            getFunction = function ()
                local innerContainer = manager:GetContainer();
                if not innerContainer then return ""; end;
                return innerContainer:GetTabName(tabIndex);
            end;
            setFunction = function (value)
                if value and value ~= "" then
                    local innerContainer = manager:GetContainer();
                    if not innerContainer then return; end;
                    innerContainer:SetTabName(tabIndex, value);

                    local tabManager = manager.manager:GetModule("tabs");
                    if tabManager then
                        tabManager:RebuildTabs();
                    end;
                end;
            end;
            default = tabName
        });

    -- Remove button (except for primary tab 1)
    if not isPrimaryTab then
        self.panel:AddSetting(
            {
                type = LibHarvensAddonSettings.ST_BUTTON;
                label = "Tab " .. tabIndex .. " - Remove";
                buttonText = "Remove Tab";
                tooltip = "Delete this chat tab";
                clickHandler = function ()
                    local innerContainer = manager:GetContainer();
                    if not innerContainer then return; end;

                    ZO_Dialogs_ShowGamepadDialog("GAMEPAD_CHAT_REMOVE_TAB",
                                                 {
                                                     container = innerContainer;
                                                     tabIndex = tabIndex;
                                                     tabName = innerContainer:GetTabName(tabIndex);
                                                     refreshCallback = function ()
                                                         -- Properly refresh settings after removal
                                                         LibHarvensAddonSettings:RefreshAddonSettings();
                                                     end
                                                 });
                end
            });
    end;
end;

--- Adds create tab button
function GamepadMiniChatTabsSettingsManager:AddCreateTabButton()
    local manager = self;

    self.panel:AddSetting(
        {
            type = LibHarvensAddonSettings.ST_BUTTON;
            label = "Create New Tab";
            buttonText = "Create";
            tooltip = "Add a new chat tab";
            clickHandler = function ()
                local chatSystem = manager:GetChatSystem();
                local container = manager:GetContainer();
                if not chatSystem or not container then return; end;
                chatSystem:CreateNewChatTab(container);

                local tabManager = manager.manager:GetModule("tabs");
                if tabManager then
                    tabManager:RebuildTabs();
                end;

                LibHarvensAddonSettings:RefreshAddonSettings();
            end
        });
end;

--- Adds fade settings
function GamepadMiniChatTabsSettingsManager:AddFadeSettings()
    self.panel:AddSetting(
        {
            type = LibHarvensAddonSettings.ST_SECTION;
            label = "Text Fade"
        });

    local manager = self;
    self.panel:AddSetting(
        {
            type = LibHarvensAddonSettings.ST_CHECKBOX;
            label = "Disable Text Fade Out";
            tooltip = "Prevents chat text from fading out over time";
            getFunction = function ()
                return GAMEPAD_MINI_CHAT_TABS:GetDisableTextFade();
            end;
            setFunction = function (value)
                GAMEPAD_MINI_CHAT_TABS:SetDisableTextFade(value);
                local container = manager:GetContainer();
                if container and container.FadeOutLines then
                    container:FadeOutLines();
                end;
            end;
            default = false
        });
end;

--- Resets all settings to defaults
function GamepadMiniChatTabsSettingsManager:ResetToDefaults()
    local container = self:GetContainer();
    if container then
        container:ResetMinAlphaToDefault();
    end;
    SetGamepadChatFontSize(GAMEPAD_CHAT_TEXT_SIZE_SETTING_MEDIUM);
    local chatSystem = self:GetChatSystem();
    if chatSystem then
        chatSystem:SetFontSize(GAMEPAD_CHAT_TEXT_SIZE_SETTING_MEDIUM);
    end;
    GAMEPAD_MINI_CHAT_TABS:SetDisableTextFade(false);
end;

local settingsManager = GamepadMiniChatTabsSettingsManager:New(GAMEPAD_MINI_CHAT_TABS);
GAMEPAD_MINI_CHAT_TABS:RegisterModule("settings", settingsManager);
