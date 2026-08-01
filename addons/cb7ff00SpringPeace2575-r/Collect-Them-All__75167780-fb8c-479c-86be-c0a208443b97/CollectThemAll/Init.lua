CollectThemAll = CollectThemAll or {}
local CTA = CollectThemAll

EVENT_MANAGER:RegisterForEvent(CTA.name, EVENT_ADD_ON_LOADED, CTA.OnAddOnLoaded)
