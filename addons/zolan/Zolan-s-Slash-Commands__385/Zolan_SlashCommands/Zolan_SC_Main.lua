--------------------------------------------------------------------------------
--                   Zolan's Auto Repair (Main)                               --
--------------------------------------------------------------------------------
if Zolan_SC == nil then Zolan_SC = {} end

local ZSC = Zolan_SC

if ZSC.AddonMenu == nil then ZSC.AddonMenu = {} end
if ZSC.Handler   == nil then ZSC.Handler   = {} end
if ZSC.Slashes   == nil then ZSC.Slashes   = {} end
if ZSC.Util      == nil then ZSC.Util      = {} end
if ZSC.Vars      == nil then ZSC.Vars      = {} end

-- ZO
local d     = d
-- Lua
local pairs = pairs

function ZSC.loadVariables()
    ---------------------------------------------------
    ---------------------------------------------------
    ----  APP VERSION DO NOT FORGET TO CHANGE!!!!!!! --
    ---------------------------------------------------
    ---------------------------------------------------
    ZSC.appVersion = '2.9'
    ZSC.addonName  = 'Zolan_SlashCommands'

    ZSC.Vars.savedVariablesName = 'Zolan_SC_SavedVariables'
    ZSC.Vars.configVersion      = 1
    ZSC.Vars.configNamespace    = 'SC'

    ZSC.Vars.headerColor        = "|c88DDFF" -- Light Blue
    ZSC.Vars.defaultColor       = "|cFFFFFF" -- White
    ZSC.Vars.currencyColor      = "|cFFD700" -- Gold

    ZSC.Vars.outputHeader       = ZSC.Vars.headerColor .. "Zolan's Slash Commands:"

    ZSC.Vars.configDefaults = {
        ["configVersion"]      = ZSC.Vars.configVersion,
        ["enabled"]            = true,
        ["debug"]              = false
    }

    local profile = nil
    ZSC.savedVars = ZO_SavedVars:New(
        ZSC.Vars.savedVariablesName,
        ZSC.Vars.configVersion,
        ZSC.Vars.configNamespace,
        ZSC.Vars.configDefaults,
        profile
    )

    ZSC.migrateSettings()
    ZSC.defaultMissingSettings()
    ZSC.removeVestigialSettings()

    ZSC.loaded = true
end

function ZSC.migrateSettings()
    -- Nothing for now.
end

function ZSC.defaultMissingSettings()
    for key, value in pairs(ZSC.Vars.configDefaults) do
        if ZSC.savedVars[key] == nil then
            ZSC.savedVars[key] = value
        end
    end
end

function ZSC.removeVestigialSettings()
    for key, value in pairs(ZSC.savedVars) do
        if ZSC.Vars.configDefaults[key] == nil then
            ZSC.savedVars[key] = nil
        end
    end
end

function ZSC.debug(message, isRaw)
    if ZSC.savedVars.debug then
        if isRaw then
            d(message)
        else
            d("ZSC: " .. message)
        end
    end
end
