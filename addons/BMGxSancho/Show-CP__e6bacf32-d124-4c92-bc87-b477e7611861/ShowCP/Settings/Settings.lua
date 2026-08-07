local SC = ShowCP
SC.Settings = SC.Settings or {}
local Settings = SC.Settings

local MOVE_STEP = 20
local MODULES = {
    { key = "blue", label = "BLUE CP", color = "4DB3FF" },
    { key = "red", label = "RED CP", color = "FF5750" },
    { key = "green", label = "GREEN CP", color = "5CEB75" },
}

local function AddModuleSettings(panel, module)
    local key = module.key

    panel:AddSetting({
        type = LibHarvensAddonSettings.ST_LABEL,
        label = "|c" .. module.color .. module.label .. "|r",
    })

    panel:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Show " .. module.label,
        getFunction = function() return SC.saved[key].enabled end,
        setFunction = function(value) SC:SetModuleEnabled(key, value) end,
        default = SC.defaults[key].enabled,
    })

    panel:AddSetting({
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = "Scale",
        min = 60,
        max = 160,
        step = 5,
        format = "%.0f",
        unit = "%",
        getFunction = function() return math.floor((SC.saved[key].scale or 1) * 100 + 0.5) end,
        setFunction = function(value) SC:SetModuleScale(key, value / 100) end,
        default = math.floor(SC.defaults[key].scale * 100),
    })

    panel:AddSetting({
        type = LibHarvensAddonSettings.ST_BUTTON,
        label = "Move Up",
        buttonText = "Move Up",
        clickHandler = function() SC:MoveModule(key, 0, -MOVE_STEP) end,
    })

    panel:AddSetting({
        type = LibHarvensAddonSettings.ST_BUTTON,
        label = "Move Down",
        buttonText = "Move Down",
        clickHandler = function() SC:MoveModule(key, 0, MOVE_STEP) end,
    })

    panel:AddSetting({
        type = LibHarvensAddonSettings.ST_BUTTON,
        label = "Move Left",
        buttonText = "Move Left",
        clickHandler = function() SC:MoveModule(key, -MOVE_STEP, 0) end,
    })

    panel:AddSetting({
        type = LibHarvensAddonSettings.ST_BUTTON,
        label = "Move Right",
        buttonText = "Move Right",
        clickHandler = function() SC:MoveModule(key, MOVE_STEP, 0) end,
    })

    panel:AddSetting({
        type = LibHarvensAddonSettings.ST_BUTTON,
        label = "Restore Default Position",
        buttonText = "Restore Default Position",
        clickHandler = function() SC:ResetModulePosition(key) end,
    })
end

function Settings:Initialize()
    if self.registered then return true end
    if not LibHarvensAddonSettings then return false end

    local panel = LibHarvensAddonSettings:AddAddon(SC.displayName, {
        allowDefaults = true,
        allowRefresh = true,
        defaultsFunction = function()
            SC.saved.enabled = SC.defaults.enabled
            for _, module in ipairs(MODULES) do
                local key = module.key
                SC.saved[key].enabled = SC.defaults[key].enabled
                SC.saved[key].x = SC.defaults[key].x
                SC.saved[key].y = SC.defaults[key].y
                SC.saved[key].scale = SC.defaults[key].scale
                SC.Display:ApplyPlacement(key)
            end
            SC.Display:RefreshVisibility()
            SC:QueueRefresh(0)
        end,
    })

    if not panel then return false end

    panel:AddSetting({
        type = LibHarvensAddonSettings.ST_LABEL,
        label = "|cF9D65CSHOW CP|r  |cFFFFFFv" .. SC.version .. "|r",
    })

    panel:AddSetting({
        type = LibHarvensAddonSettings.ST_LABEL,
        label = "Created by BMGxSancho",
    })

    panel:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Enable Show CP",
        tooltip = "Show or hide all Show CP modules without changing the individual Blue, Red, or Green settings.",
        getFunction = function() return SC.saved.enabled end,
        setFunction = function(value) SC:SetEnabled(value) end,
        default = SC.defaults.enabled,
    })

    for _, module in ipairs(MODULES) do
        AddModuleSettings(panel, module)
    end

    self.registered = true
    return true
end
