local GlossFreeAttribute = {}

function GlossFreeAttribute:Load(eventCode, addOnName)
	EVENT_MANAGER:UnregisterForEvent("GlossFreeAttribute_OnAddOnLoaded", EVENT_ADD_ON_LOADED)

	GlossFreeAttribute:TextureSwap()
end

function GlossFreeAttribute:TextureSwap()
	RedirectTexture("esoui/art/unitattributevisualizer/attributebar_dynamic_fill_gloss.dds", "GlossFreeAttribute/blank.dds")
	RedirectTexture("esoui/art/unitattributevisualizer/attributebar_dynamic_leadingedge_gloss.dds", "GlossFreeAttribute/blank.dds")
	RedirectTexture("esoui/art/unitattributevisualizer/attributebar_small_fill_center_gloss.dds", "GlossFreeAttribute/blank.dds")
	RedirectTexture("esoui/art/unitattributevisualizer/attributebar_small_fill_leadingedge_gloss.dds", "GlossFreeAttribute/blank.dds")
	RedirectTexture("esoui/art/unitattributevisualizer/targetbar_dynamic_fill_gloss.dds", "GlossFreeAttribute/blank.dds")
	RedirectTexture("esoui/art/unitattributevisualizer/targetbar_dynamic_leadingedge_gloss.dds", "GlossFreeAttribute/blank.dds")
end
	
EVENT_MANAGER:RegisterForEvent("GlossFreeAttribute_OnAddOnLoaded", EVENT_ADD_ON_LOADED, function(_event, _name) GlossFreeAttribute:Load(_event, _name) end)
EVENT_MANAGER:RegisterForEvent("GlossFreeAttribute_OnPlayerActivated", EVENT_PLAYER_ACTIVATED, function(...) GlossFreeAttribute:TextureSwap() end)