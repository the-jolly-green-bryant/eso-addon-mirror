if StowIt == nil then StowIt = {} end
local SI = StowIt

function SI.BuildAddonMenu()
    local settings = SI.settingsVars.settings
    if not settings or not SI.LAM then return false end
    local defaults = SI.settingsVars.defaultsValues
    local addonVars = SI.addonVars

    local panelData = {
        type 				= 'panel',
        name 				= addonVars.addonName,
        displayName 		= addonVars.addonName,
        author 				= addonVars.addonAuthor,
        version 			= tostring(addonVars.addonVersion),
        registerForRefresh 	= true,
        registerForDefaults = true,
        slashCommand        = "/fcoms",
        website             = addonVars.addonWebsite
    }

    local savedVariablesOptions = {
        [1] = GetString(STOWIT_SAVEMODE1),
        [2] = GetString(STOWIT_SAVEMODE2)
    }

    SI.LAMSettingsPanel = SI.LAM:RegisterAddonPanel(SI.addonVars.addonName .. "_LAM", panelData)

--[[
    --LAM 2.0 callback function if the panel was created
    local LAMPanelCreated = function(panel)
        if panel == SI.LAMSettingsPanel then
            CALLBACK_MANAGER:UnregisterCallback("LAM-PanelControlsCreated")
        end
    end
    CALLBACK_MANAGER:RegisterCallback("LAM-PanelControlsCreated", FCOMLAMPanelCreated)
]]
    local optionsTable =
    {	-- BEGIN OF OPTIONS TABLE

        {
            type = 'description',
            text = GetString(STOWIT_TITEL),
        },
        {
            type = 'dropdown',
            name = GetString(STOWIT_SAVEMODE),
            tooltip = GetString(STOWIT_SAVEMODE_TT),
            choices = savedVariablesOptions,
            getFunc = function() return savedVariablesOptions[SI.settingsVars.defaultSettings.saveMode] end,
            setFunc = function(value)
                for i,v in pairs(savedVariablesOptions) do
                    if v == value then
                        SI.settingsVars.defaultSettings.saveMode = i
                        break
                    end
                end
            end,
            requiresReload = true,
        },
        --==============================================================================
        {
            type = 'header',
            name = 'Hide weapon',
        },
        {
            type = "checkbox",
            name = GetString(STOWIT_STOWAFTERWEAPONSWAP),
            tooltip = GetString(STOWIT_STOWAFTERWEAPONSWAP_TT),
            getFunc = function() return settings.stowAfterWeaponSwap end,
            setFunc = function(value) settings.stowAfterWeaponSwap = value
            end,
            default = defaults.stowAfterWeaponSwap,
            width="full",
        },
    } -- optionsTable
    -- END OF OPTIONS TABLE
    SI.LAM:RegisterOptionControls(SI.addonVars.addonName .. "_LAM", optionsTable)
end