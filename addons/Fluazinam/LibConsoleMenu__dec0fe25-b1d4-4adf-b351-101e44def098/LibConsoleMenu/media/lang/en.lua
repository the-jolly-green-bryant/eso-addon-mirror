-- English defaults. May load twice when client language is en (en.lua + $(language).lua).
local function Define(id, text)
	if _G[id] == nil then
		ZO_CreateStringId(id, text)
	else
		SafeAddString(_G[id], text, 1)
	end
end

Define("SI_LCM_SLIDER_LARGE_DECREASE", "Large Decrease")
Define("SI_LCM_SLIDER_LARGE_INCREASE", "Large Increase")
Define("SI_LCM_TOGGLE_SHOW", "Show")
Define("SI_LCM_TOGGLE_HIDE", "Hide")
