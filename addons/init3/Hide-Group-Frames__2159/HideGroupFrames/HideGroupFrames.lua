HideGroupFrames = HideGroupFrames or {}
local HideGroupFrames = HideGroupFrames

HideGroupFrames.name = "HideGroupFrames"
HideGroupFrames.author = "init3"
HideGroupFrames.version = "1.0"
HideGroupFrames.variableVersion = 1


HideGroupFrames.defaults = {
     hideGroupFrames = true,
}

function HideGroupFrames.OnAddOnLoaded(event, addonName)
     if HideGroupFrames.name ~= addonName then return end
     HideGroupFrames.savedVars = ZO_SavedVars:NewCharacterIdSettings("HGFVars", HideGroupFrames.variableVersion, HideGroupFrames.defaults)
     HideGroupFrames.sv = HGFVars["Default"][GetDisplayName()][GetCurrentCharacterId()]
     ZO_UnitFramesGroups:SetHidden(HideGroupFrames.sv.hideGroupFrames)
     HideGroupFrames.CreateSettingsWindow()
end

EVENT_MANAGER:RegisterForEvent(HideGroupFrames.name, EVENT_ADD_ON_LOADED, HideGroupFrames.OnAddOnLoaded)
