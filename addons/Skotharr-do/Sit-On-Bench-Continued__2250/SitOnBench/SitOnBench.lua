SIT_ON_BENCH = "SitOnBench"

local function RefreshCharacter()
  local HelmetStatus = GetSetting(SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_HIDE_POLYMORPH_HELM)
  SetSetting(SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_HIDE_POLYMORPH_HELM, 1 - HelmetStatus)
  SetSetting(SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_HIDE_POLYMORPH_HELM, HelmetStatus)
end

local function SitOnBench()
  DoCommand('/sitchair')
  zo_callLater( RefreshCharacter, 500 )
  zo_callLater( RefreshCharacter, 700 )
  zo_callLater( RefreshCharacter, 900 )
  zo_callLater( RefreshCharacter, 1100 )
  zo_callLater( RefreshCharacter, 1300 )
  zo_callLater( RefreshCharacter, 1500 )
end

local function OnAddOnLoaded(event, addonName)
	if addonName ~= SIT_ON_BENCH then
		return
	end
	EVENT_MANAGER:UnregisterForEvent(SIT_ON_BENCH, EVENT_ADD_ON_LOADED)
	
	SLASH_COMMANDS['/sitbench'] = SitOnBench
end

EVENT_MANAGER:RegisterForEvent(SIT_ON_BENCH, EVENT_ADD_ON_LOADED, OnAddOnLoaded)