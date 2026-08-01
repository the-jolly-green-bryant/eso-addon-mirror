--------------------------------------------------------------------------------
--                   Zolan's Auto Repair (Main)                               --
--------------------------------------------------------------------------------
if Zolan_AR == nil then Zolan_AR = {} end

local ZAR = Zolan_AR

if ZAR.AddonMenu == nil then ZAR.AddonMenu = {} end
if ZAR.Handler   == nil then ZAR.Handler   = {} end
if ZAR.Repairer  == nil then ZAR.Repairer  = {} end
if ZAR.Util      == nil then ZAR.Util      = {} end
if ZAR.Vars      == nil then ZAR.Vars      = {} end

-- ZO
local d     = d
-- Lua
local pairs = pairs

function ZAR.loadVariables()
    ---------------------------------------------------
    ---------------------------------------------------
    ----  APP VERSION DO NOT FORGET TO CHANGE!!!!!!! --
    ---------------------------------------------------
    ---------------------------------------------------
    ZAR.appVersion = '3.1'
    ZAR.addonName  = 'Zolan_AutoRepair'

    ZAR.Vars.savedVariablesName = 'Zolan_AR_SavedVariables'
    ZAR.Vars.configVersion      = 1
    ZAR.Vars.configNamespace    = 'AR'

    ZAR.Vars.headerColor        = "|c88DDFF" -- Light Blue
    ZAR.Vars.defaultColor       = "|cFFFFFF" -- White
    ZAR.Vars.currencyColor      = "|cFFD700" -- Gold

    ZAR.Vars.outputHeader       = ZAR.Vars.headerColor .. "Zolan's Auto Repair:"

    ZAR.Vars.configDefaults = {
        ["configVersion"]      = ZAR.Vars.configVersion,
        ["enabled"]            = true,
        ["debug"]              = false,
        ["repairEquippedOnly"] = true,
        ["repairNotify"]       = true,
        ["showItemized"]       = true,
        ["showSummary"]        = true,
        ["useKits"]            = true
    }

    local profile = nil
    ZAR.savedVars = ZO_SavedVars:New(
        ZAR.Vars.savedVariablesName,
        ZAR.Vars.configVersion,
        ZAR.Vars.configNamespace,
        ZAR.Vars.configDefaults,
        profile
    )

    ZAR.migrateSettings()
    ZAR.defaultMissingSettings()
    ZAR.removeVestigialSettings()

    ZAR.loaded             = true
end

function ZAR.migrateSettings()
    -- Nothing for now.
end

function ZAR.defaultMissingSettings()
    for key, value in pairs(ZAR.Vars.configDefaults) do
        if ZAR.savedVars[key] == nil then
            ZAR.savedVars[key] = value
        end
    end
end

function ZAR.removeVestigialSettings()
    for key, value in pairs(ZAR.savedVars) do
        if ZAR.Vars.configDefaults[key] == nil then
            ZAR.savedVars[key] = nil
        end
    end
end

function ZAR.debug(message, isRaw)
    if ZAR.savedVars.debug then
        if isRaw then
            d(message)
        else
            d("ZAR: " .. message)
        end
    end
end
