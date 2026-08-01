local CT = ControllerTweaks

local Settings = {}

function Settings:LoadSavedSettings()
    CT.Settings = ZO_SavedVars:NewAccountWide(CT.AddonName .. "SavedVariables", 5, nil, CT.Settings)
end

CT.Settings = Settings