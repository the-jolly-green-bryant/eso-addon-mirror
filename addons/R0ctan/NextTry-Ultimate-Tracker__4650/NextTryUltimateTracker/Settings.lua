local Addon = NextTryUltimateTracker
local PANEL_NAME = Addon.name .. "Options"

local function L(stringId)
    return GetString(stringId)
end

local function ColorOptions(getColor, refresh)
    return function()
        local color = getColor()
        return color[1], color[2], color[3]
    end,
    function(r, g, b)
        local color = getColor()
        color[1], color[2], color[3] = r, g, b
        refresh()
    end
end

function Addon:CreateSettings()
    local lam = LibAddonMenu2
    if not lam then
        self:Print("LibAddonMenu-2.0 is unavailable.")
        return
    end

    self.settingsPanel = lam:RegisterAddonPanel(PANEL_NAME, {
        type = "panel",
        name = self.displayName,
        displayName = self.displayName,
        author = "R0ctan",
        version = self.version,
        registerForRefresh = true,
        registerForDefaults = true,
    })

    local function Refresh()
        self:ApplyAppearance()
        self:UpdateUltimateState(true)
    end

    local boxGet, boxSet = ColorOptions(function() return self.sv.box.color end, Refresh)
    local blinkGet, blinkSet = ColorOptions(function() return self.sv.box.blinkColor end, Refresh)
    local textGet, textSet = ColorOptions(function() return self.sv.text.color end, Refresh)
    local textBgGet, textBgSet = ColorOptions(function() return self.sv.text.backgroundColor end, Refresh)
    local defaults = self.profileDefaults
    local soundChoices, soundValues = {}, {}
    for _, option in ipairs(self.soundOptions or {}) do
        table.insert(soundChoices, option.label)
        table.insert(soundValues, option.value)
    end
    local profileChoices = {}
    local profileChoiceValues = {}
    self.profileChoices = profileChoices
    self.profileChoiceValues = profileChoiceValues
    local function UpdateProfileChoices()
        for index = #profileChoices, 1, -1 do table.remove(profileChoices, index) end
        for index = #profileChoiceValues, 1, -1 do table.remove(profileChoiceValues, index) end
        for _, value in ipairs(self:GetProfileChoices()) do table.insert(profileChoices, value) end
        for _, value in ipairs(self:GetProfileChoiceValues()) do table.insert(profileChoiceValues, value) end
    end
    local function IsDefaultProfileActive()
        return self:GetActiveProfileId() == "global"
    end
    UpdateProfileChoices()
    self.RefreshProfileOptionChoices = UpdateProfileChoices
    self.profileDropdownReference = self.name .. "ProfileDropdown"
    self.profileNameEditboxReference = self.name .. "ProfileNameEditbox"
    self.profileDeleteButtonReference = self.name .. "ProfileDeleteButton"
    local function ZoneFilterUnavailable()
        return not self:IsLibZoneAvailable()
    end
    local function ZoneFilterOptionDisabled()
        return ZoneFilterUnavailable() or not self.sv.zoneFilter.enabled
    end

    local options = {
        {
            type = "header",
            name = L(NEXTTRYULTIMATETRACKER_GENERAL),
        },
        {
            type = "checkbox", name = L(NEXTTRYULTIMATETRACKER_ENABLED),
            tooltip = L(NEXTTRYULTIMATETRACKER_ENABLED_TOOLTIP),
            getFunc = function() return self.accountSv.enabled ~= false end,
            setFunc = function(value) self.accountSv.enabled = value; Refresh() end,
            default = self.globalDefaults.enabled,
        },
        {
            type = "dropdown", name = L(NEXTTRYULTIMATETRACKER_PROFILE_ACTIVE),
            tooltip = L(NEXTTRYULTIMATETRACKER_PROFILE_ACTIVE_TOOLTIP),
            choices = profileChoices,
            choicesValues = profileChoiceValues,
            reference = self.profileDropdownReference,
            getFunc = function() return self:GetActiveProfileId() end,
            setFunc = function(value)
                if self.settingsControlRefreshActive then return end
                if value == self:GetActiveProfileId() then return end
                if self:SetActiveProfile(value) then
                    self:RequestSettingsRefresh()
                    self:QueueSettingsRefresh()
                    self:Print(string.format(L(NEXTTRYULTIMATETRACKER_PROFILE_ACTIVE_SET), self:GetActiveProfileName()))
                else
                    self:RequestSettingsRefresh()
                    self:QueueSettingsRefresh()
                end
            end,
            default = "global",
        },
        {
            type = "description",
            text = L(NEXTTRYULTIMATETRACKER_PROFILE_HELP),
        },
        {
            type = "button", name = L(NEXTTRYULTIMATETRACKER_PROFILE_CREATE),
            tooltip = L(NEXTTRYULTIMATETRACKER_PROFILE_CREATE_TOOLTIP),
            func = function() self:CreateProfileFromDefaults() end,
        },
        {
            type = "editbox", name = L(NEXTTRYULTIMATETRACKER_PROFILE_NAME),
            tooltip = L(NEXTTRYULTIMATETRACKER_PROFILE_NAME_TOOLTIP),
            getFunc = function() return self:GetActiveProfileName() end,
            setFunc = function(value)
                if self.settingsControlRefreshActive then return end
                self:SetActiveProfileName(value)
            end,
            reference = self.profileNameEditboxReference,
            isMultiline = false,
            disabled = IsDefaultProfileActive,
        },
        {
            type = "button", name = L(NEXTTRYULTIMATETRACKER_PROFILE_DELETE),
            tooltip = L(NEXTTRYULTIMATETRACKER_PROFILE_DELETE_TOOLTIP),
            warning = L(NEXTTRYULTIMATETRACKER_PROFILE_DELETE_WARNING),
            reference = self.profileDeleteButtonReference,
            func = function() self:DeleteActiveProfile() end,
            disabled = IsDefaultProfileActive,
        },
        {
            type = "checkbox", name = L(NEXTTRYULTIMATETRACKER_ONLY_COMBAT),
            tooltip = L(NEXTTRYULTIMATETRACKER_ONLY_COMBAT_TOOLTIP),
            getFunc = function() return self.sv.onlyCombat end,
            setFunc = function(value) self.sv.onlyCombat = value; Refresh() end,
            default = defaults.onlyCombat,
        },
        {
            type = "checkbox", name = L(NEXTTRYULTIMATETRACKER_TEST_MODE),
            tooltip = L(NEXTTRYULTIMATETRACKER_TEST_MODE_TOOLTIP),
            getFunc = function() return self.sv.testMode end,
            setFunc = function(value) self.sv.testMode = value; Refresh() end,
            default = defaults.testMode,
        },

        {
            type = "submenu",
            name = L(NEXTTRYULTIMATETRACKER_ZONE_FILTER),
            controls = {
        {
            type = "description",
            text = L(NEXTTRYULTIMATETRACKER_ZONE_FILTER_LIBZONE_NOTE),
        },
        {
            type = "checkbox", name = L(NEXTTRYULTIMATETRACKER_ZONE_FILTER_ENABLED),
            tooltip = L(NEXTTRYULTIMATETRACKER_ZONE_FILTER_ENABLED_TOOLTIP),
            getFunc = function() return self.sv.zoneFilter.enabled end,
            setFunc = function(value) self.sv.zoneFilter.enabled = value; Refresh() end,
            default = defaults.zoneFilter.enabled,
            disabled = ZoneFilterUnavailable,
        },
        {
            type = "checkbox", name = L(NEXTTRYULTIMATETRACKER_ZONE_FILTER_OVERLAND),
            tooltip = L(NEXTTRYULTIMATETRACKER_ZONE_FILTER_OVERLAND_TOOLTIP),
            getFunc = function() return self.sv.zoneFilter.allowOverland end,
            setFunc = function(value) self.sv.zoneFilter.allowOverland = value; Refresh() end,
            default = defaults.zoneFilter.allowOverland,
            disabled = ZoneFilterOptionDisabled,
        },
        {
            type = "checkbox", name = L(NEXTTRYULTIMATETRACKER_ZONE_FILTER_DELVE_PUBLIC),
            tooltip = L(NEXTTRYULTIMATETRACKER_ZONE_FILTER_DELVE_PUBLIC_TOOLTIP),
            getFunc = function() return self.sv.zoneFilter.allowDelvePublic end,
            setFunc = function(value) self.sv.zoneFilter.allowDelvePublic = value; Refresh() end,
            default = defaults.zoneFilter.allowDelvePublic,
            disabled = ZoneFilterOptionDisabled,
        },
        {
            type = "checkbox", name = L(NEXTTRYULTIMATETRACKER_ZONE_FILTER_DUNGEON_TRIAL),
            tooltip = L(NEXTTRYULTIMATETRACKER_ZONE_FILTER_DUNGEON_TRIAL_TOOLTIP),
            getFunc = function() return self.sv.zoneFilter.allowDungeonTrial end,
            setFunc = function(value) self.sv.zoneFilter.allowDungeonTrial = value; Refresh() end,
            default = defaults.zoneFilter.allowDungeonTrial,
            disabled = ZoneFilterOptionDisabled,
        },
        {
            type = "checkbox", name = L(NEXTTRYULTIMATETRACKER_ZONE_FILTER_ARENA),
            tooltip = L(NEXTTRYULTIMATETRACKER_ZONE_FILTER_ARENA_TOOLTIP),
            getFunc = function() return self.sv.zoneFilter.allowArena end,
            setFunc = function(value) self.sv.zoneFilter.allowArena = value; Refresh() end,
            default = defaults.zoneFilter.allowArena,
            disabled = ZoneFilterOptionDisabled,
        },
        {
            type = "checkbox", name = L(NEXTTRYULTIMATETRACKER_ZONE_FILTER_ENDLESS_ARCHIVE),
            tooltip = L(NEXTTRYULTIMATETRACKER_ZONE_FILTER_ENDLESS_ARCHIVE_TOOLTIP),
            getFunc = function() return self.sv.zoneFilter.allowEndlessArchive end,
            setFunc = function(value) self.sv.zoneFilter.allowEndlessArchive = value; Refresh() end,
            default = defaults.zoneFilter.allowEndlessArchive,
            disabled = ZoneFilterOptionDisabled,
        },
        {
            type = "checkbox", name = L(NEXTTRYULTIMATETRACKER_ZONE_FILTER_PVP),
            tooltip = L(NEXTTRYULTIMATETRACKER_ZONE_FILTER_PVP_TOOLTIP),
            getFunc = function() return self.sv.zoneFilter.allowPvp end,
            setFunc = function(value) self.sv.zoneFilter.allowPvp = value; Refresh() end,
            default = defaults.zoneFilter.allowPvp,
            disabled = ZoneFilterOptionDisabled,
        },
        {
            type = "checkbox", name = L(NEXTTRYULTIMATETRACKER_ZONE_FILTER_HOUSING),
            tooltip = L(NEXTTRYULTIMATETRACKER_ZONE_FILTER_HOUSING_TOOLTIP),
            getFunc = function() return self.sv.zoneFilter.allowHousing end,
            setFunc = function(value) self.sv.zoneFilter.allowHousing = value; Refresh() end,
            default = defaults.zoneFilter.allowHousing,
            disabled = ZoneFilterOptionDisabled,
        },
            },
        },

        {
            type = "submenu",
            name = L(NEXTTRYULTIMATETRACKER_ALERT_TARGET),
            controls = {
        {
            type = "dropdown", name = L(NEXTTRYULTIMATETRACKER_TARGET_BARS),
            tooltip = L(NEXTTRYULTIMATETRACKER_TARGET_BARS_TOOLTIP),
            choices = {
                L(NEXTTRYULTIMATETRACKER_FRONTBAR),
                L(NEXTTRYULTIMATETRACKER_BACKBAR),
                L(NEXTTRYULTIMATETRACKER_BOTH),
                L(NEXTTRYULTIMATETRACKER_ACTIVE_BAR),
                L(NEXTTRYULTIMATETRACKER_INACTIVE_BAR),
            },
            choicesValues = { "primary", "backup", "bothFixed", "active", "inactive" },
            getFunc = function() return self.sv.targetBars end,
            setFunc = function(value) self.sv.targetBars = value; Refresh() end,
            default = defaults.targetBars,
        },
            },
        },

        {
            type = "submenu",
            name = L(NEXTTRYULTIMATETRACKER_BOX),
            controls = {
        {
            type = "checkbox", name = L(NEXTTRYULTIMATETRACKER_BOX_SHOW),
            tooltip = L(NEXTTRYULTIMATETRACKER_BOX_SHOW_TOOLTIP),
            getFunc = function() return self.sv.box.show end,
            setFunc = function(value) self.sv.box.show = value; Refresh() end,
            default = defaults.box.show,
        },
        {
            type = "checkbox", name = L(NEXTTRYULTIMATETRACKER_BOX_UNLOCK),
            tooltip = L(NEXTTRYULTIMATETRACKER_BOX_UNLOCK_TOOLTIP),
            getFunc = function() return self.sv.box.unlocked end,
            setFunc = function(value) self.sv.box.unlocked = value; Refresh() end,
            default = defaults.box.unlocked,
        },
        {
            type = "slider", name = L(NEXTTRYULTIMATETRACKER_BOX_WIDTH),
            min = 40, max = 1000, step = 5,
            getFunc = function() return self.sv.box.width end,
            setFunc = function(value) self.sv.box.width = value; Refresh() end,
            default = defaults.box.width,
        },
        {
            type = "slider", name = L(NEXTTRYULTIMATETRACKER_BOX_HEIGHT),
            min = 20, max = 1000, step = 5,
            getFunc = function() return self.sv.box.height end,
            setFunc = function(value) self.sv.box.height = value; Refresh() end,
            default = defaults.box.height,
        },
        {
            type = "colorpicker", name = L(NEXTTRYULTIMATETRACKER_BOX_COLOR),
            getFunc = boxGet, setFunc = boxSet,
            default = { r = defaults.box.color[1], g = defaults.box.color[2], b = defaults.box.color[3] },
        },
        {
            type = "slider", name = L(NEXTTRYULTIMATETRACKER_BOX_ALPHA),
            min = 0, max = 100, step = 1,
            getFunc = function() return self.sv.box.alpha * 100 end,
            setFunc = function(value) self.sv.box.alpha = value / 100; Refresh() end,
            default = defaults.box.alpha * 100,
        },
        {
            type = "colorpicker", name = L(NEXTTRYULTIMATETRACKER_BLINK_COLOR),
            getFunc = blinkGet, setFunc = blinkSet,
            default = { r = defaults.box.blinkColor[1], g = defaults.box.blinkColor[2], b = defaults.box.blinkColor[3] },
        },
        {
            type = "slider", name = L(NEXTTRYULTIMATETRACKER_BLINK_SPEED),
            tooltip = L(NEXTTRYULTIMATETRACKER_BLINK_SPEED_TOOLTIP),
            min = 150, max = 3000, step = 50,
            getFunc = function() return self.sv.box.blinkSpeed end,
            setFunc = function(value) self.sv.box.blinkSpeed = value; Refresh() end,
            default = defaults.box.blinkSpeed,
        },
        {
            type = "dropdown", name = L(NEXTTRYULTIMATETRACKER_DRAW_LAYER),
            tooltip = L(NEXTTRYULTIMATETRACKER_DRAW_LAYER_TOOLTIP),
            choices = { "Background", "Controls", "Overlay" },
            choicesValues = { DL_BACKGROUND, DL_CONTROLS, DL_OVERLAY },
            getFunc = function() return self.sv.box.drawLayer end,
            setFunc = function(value) self.sv.box.drawLayer = value; Refresh() end,
            default = defaults.box.drawLayer,
        },
        {
            type = "slider", name = L(NEXTTRYULTIMATETRACKER_DRAW_LEVEL),
            tooltip = L(NEXTTRYULTIMATETRACKER_DRAW_LEVEL_TOOLTIP),
            min = 0, max = 200, step = 1,
            getFunc = function() return self.sv.box.drawLevel end,
            setFunc = function(value) self.sv.box.drawLevel = value; Refresh() end,
            default = defaults.box.drawLevel,
        },
        {
            type = "dropdown", name = L(NEXTTRYULTIMATETRACKER_DRAW_TIER),
            tooltip = L(NEXTTRYULTIMATETRACKER_DRAW_TIER_TOOLTIP),
            choices = { "Low", "Medium", "High" },
            choicesValues = { DT_LOW, DT_MEDIUM, DT_HIGH },
            getFunc = function() return self.sv.box.drawTier end,
            setFunc = function(value) self.sv.box.drawTier = value; Refresh() end,
            default = defaults.box.drawTier,
        },
            },
        },

        {
            type = "submenu",
            name = L(NEXTTRYULTIMATETRACKER_SCREEN_TEXT),
            controls = {
        {
            type = "checkbox", name = L(NEXTTRYULTIMATETRACKER_TEXT_SHOW),
            tooltip = L(NEXTTRYULTIMATETRACKER_TEXT_SHOW_TOOLTIP),
            getFunc = function() return self.sv.text.show end,
            setFunc = function(value) self.sv.text.show = value; Refresh() end,
            default = defaults.text.show,
        },
        {
            type = "dropdown", name = L(NEXTTRYULTIMATETRACKER_TEXT_MODE),
            tooltip = L(NEXTTRYULTIMATETRACKER_TEXT_MODE_TOOLTIP),
            choices = {
                L(NEXTTRYULTIMATETRACKER_TEXT_MODE_COMPACT),
                L(NEXTTRYULTIMATETRACKER_TEXT_MODE_NAMES),
                L(NEXTTRYULTIMATETRACKER_TEXT_MODE_DETAILS),
            },
            choicesValues = { "compact", "names", "details" },
            getFunc = function() return self.sv.text.mode end,
            setFunc = function(value) self.sv.text.mode = value; Refresh() end,
            default = defaults.text.mode,
        },
        {
            type = "checkbox", name = L(NEXTTRYULTIMATETRACKER_TEXT_UNLOCK),
            tooltip = L(NEXTTRYULTIMATETRACKER_TEXT_UNLOCK_TOOLTIP),
            getFunc = function() return self.sv.text.unlocked end,
            setFunc = function(value) self.sv.text.unlocked = value; Refresh() end,
            default = defaults.text.unlocked,
        },
        {
            type = "slider", name = L(NEXTTRYULTIMATETRACKER_TEXT_SIZE),
            min = 12, max = 72, step = 1,
            getFunc = function() return self.sv.text.fontSize end,
            setFunc = function(value) self.sv.text.fontSize = value; Refresh() end,
            default = defaults.text.fontSize,
        },
        {
            type = "colorpicker", name = L(NEXTTRYULTIMATETRACKER_TEXT_COLOR),
            getFunc = textGet, setFunc = textSet,
            default = { r = defaults.text.color[1], g = defaults.text.color[2], b = defaults.text.color[3] },
        },
        {
            type = "colorpicker", name = L(NEXTTRYULTIMATETRACKER_TEXT_BG_COLOR),
            getFunc = textBgGet, setFunc = textBgSet,
            default = {
                r = defaults.text.backgroundColor[1],
                g = defaults.text.backgroundColor[2],
                b = defaults.text.backgroundColor[3],
            },
        },
        {
            type = "slider", name = L(NEXTTRYULTIMATETRACKER_TEXT_BG_ALPHA),
            tooltip = L(NEXTTRYULTIMATETRACKER_TEXT_BG_ALPHA_TOOLTIP),
            min = 0, max = 100, step = 1,
            getFunc = function() return self.sv.text.backgroundAlpha * 100 end,
            setFunc = function(value) self.sv.text.backgroundAlpha = value / 100; Refresh() end,
            default = defaults.text.backgroundAlpha * 100,
        },
            },
        },

        {
            type = "submenu",
            name = L(NEXTTRYULTIMATETRACKER_ULTIMATE_BLOCK),
            controls = {
        {
            type = "dropdown", name = L(NEXTTRYULTIMATETRACKER_ULTIMATE_BLOCK_MODE),
            tooltip = L(NEXTTRYULTIMATETRACKER_ULTIMATE_BLOCK_TOOLTIP),
            choices = {
                L(NEXTTRYULTIMATETRACKER_ULTIMATE_BLOCK_OFF),
                L(NEXTTRYULTIMATETRACKER_FRONTBAR),
                L(NEXTTRYULTIMATETRACKER_BACKBAR),
                L(NEXTTRYULTIMATETRACKER_BOTH),
            },
            choicesValues = { "off", "primary", "backup", "bothFixed" },
            getFunc = function() return self.sv.ultimateBlock.mode end,
            setFunc = function(value) self.sv.ultimateBlock.mode = value end,
            default = defaults.ultimateBlock.mode,
        },
        {
            type = "checkbox", name = L(NEXTTRYULTIMATETRACKER_ULTIMATE_BLOCK_MESSAGE),
            tooltip = L(NEXTTRYULTIMATETRACKER_ULTIMATE_BLOCK_MESSAGE_TOOLTIP),
            getFunc = function() return self.sv.ultimateBlock.showMessage ~= false end,
            setFunc = function(value) self.sv.ultimateBlock.showMessage = value end,
            default = defaults.ultimateBlock.showMessage,
        },
            },
        },

        {
            type = "submenu",
            name = L(NEXTTRYULTIMATETRACKER_WEREWOLF),
            controls = {
        {
            type = "checkbox", name = L(NEXTTRYULTIMATETRACKER_WEREWOLF_BLOCK_REVERT),
            tooltip = L(NEXTTRYULTIMATETRACKER_WEREWOLF_BLOCK_REVERT_TOOLTIP),
            getFunc = function() return self.sv.werewolf.blockRevertInCombat end,
            setFunc = function(value) self.sv.werewolf.blockRevertInCombat = value; Refresh() end,
            default = defaults.werewolf.blockRevertInCombat,
        },
        {
            type = "checkbox", name = L(NEXTTRYULTIMATETRACKER_WEREWOLF_BLOCK_MESSAGE),
            tooltip = L(NEXTTRYULTIMATETRACKER_WEREWOLF_BLOCK_MESSAGE_TOOLTIP),
            getFunc = function() return self.sv.werewolf.showBlockMessage end,
            setFunc = function(value) self.sv.werewolf.showBlockMessage = value end,
            default = defaults.werewolf.showBlockMessage,
        },
        {
            type = "checkbox", name = L(NEXTTRYULTIMATETRACKER_WEREWOLF_BLOCK_SOUND),
            tooltip = L(NEXTTRYULTIMATETRACKER_WEREWOLF_BLOCK_SOUND_TOOLTIP),
            getFunc = function() return self.sv.werewolf.playBlockSound end,
            setFunc = function(value) self.sv.werewolf.playBlockSound = value end,
            default = defaults.werewolf.playBlockSound,
        },
            },
        },

        {
            type = "submenu",
            name = L(NEXTTRYULTIMATETRACKER_SOUND_DEBUG),
            controls = {
        {
            type = "checkbox", name = L(NEXTTRYULTIMATETRACKER_SOUND_ENABLED),
            tooltip = L(NEXTTRYULTIMATETRACKER_SOUND_ENABLED_TOOLTIP),
            getFunc = function() return self.sv.soundEnabled end,
            setFunc = function(value) self.sv.soundEnabled = value end,
            default = defaults.soundEnabled,
        },
        {
            type = "dropdown", name = L(NEXTTRYULTIMATETRACKER_SOUND),
            tooltip = L(NEXTTRYULTIMATETRACKER_SOUND_TOOLTIP),
            choices = soundChoices,
            choicesValues = soundValues,
            getFunc = function() return self.sv.sound end,
            setFunc = function(value) self.sv.sound = value end,
            default = defaults.sound,
        },
        {
            type = "button", name = L(NEXTTRYULTIMATETRACKER_TEST_SOUND),
            tooltip = L(NEXTTRYULTIMATETRACKER_TEST_SOUND_TOOLTIP),
            func = function() self:PlayAlertSound() end,
        },
        {
            type = "checkbox", name = L(NEXTTRYULTIMATETRACKER_DEBUG),
            tooltip = L(NEXTTRYULTIMATETRACKER_DEBUG_TOOLTIP),
            getFunc = function() return self.sv.debug end,
            setFunc = function(value) self.sv.debug = value end,
            default = defaults.debug,
        },
            },
        },
    }

    lam:RegisterOptionControls(PANEL_NAME, options)

    if NextTryShared and NextTryShared.WindowVisibility then
        NextTryShared.WindowVisibility.RegisterLAMPreviewCallbacks(
            self,
            function(panel) return panel == self.settingsPanel end,
            function(active)
                self.settingsPreviewActive = active
                self:UpdateUltimateState(true)
            end
        )
    end
end
