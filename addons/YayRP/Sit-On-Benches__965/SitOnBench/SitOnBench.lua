SOB = {}
SOB.Name = "SitOnBench"
SOB.Version = "1.01"

local function RefreshCharacter()
  local HelmetStatus = GetSetting(SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_HIDE_HELM)
  SetSetting(SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_HIDE_HELM, 1 - HelmetStatus)
  SetSetting(SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_HIDE_HELM, HelmetStatus)
end

local function SitOnBench()
  DoCommand("/sitchair")
  zo_callLater( RefreshCharacter, 500 )
  zo_callLater( RefreshCharacter, 700 )
  zo_callLater( RefreshCharacter, 900 )
  zo_callLater( RefreshCharacter, 1100 )
  zo_callLater( RefreshCharacter, 1300 )
  zo_callLater( RefreshCharacter, 1500 )
end

SLASH_COMMANDS["/sitbench"] = SitOnBench