--------------------------
-- Initialize Variables --
--------------------------

PermanentExperienceBar = {}
PermanentExperienceBar.name = "PermanentExperienceBar"
PermanentExperienceBar.configVersion = 1
PermanentExperienceBar.saveData = {}
PermanentExperienceBar.defaults = {
    enabled = true
}

---------------------
--  OnAddOnLoaded  --
---------------------

function OnAddOnLoaded(event, addonName)
    if addonName ~= PermanentExperienceBar.name then
        return
    end
    PermanentExperienceBar:Initialize()
end

--------------------------
--  Initialize Function --
--------------------------

function PermanentExperienceBar:Initialize()
    -- Handle Save Data
    self.saveData = ZO_SavedVars:New(self.name .. "Data", self.configVersion, nil, self.defaults)
    self:RepairSaveData()

    -- Handle Startup
    if self.saveData.enabled == true then
        self:Enable()
    end

    -- Listen for Changes
    --ZO_PreHookHandler(ZO_PlayerProgressBar, "OnUpdate", PermanentExperienceBar.AlphaCommand)

    -- Dismiss Initializer
    EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_ADD_ON_LOADED)
end

--------------------
-- Internal Tools --
--------------------

-- allow debugging based on changes
PermanentExperienceBar.debugLog = {}
function PermanentExperienceBar:Debug(key, output)
    if output ~= self.debugLog[key] then
        self.debugLog[key] = output
        d(self.name .. "." .. key .. ":", output)
    end
end

function PermanentExperienceBar:RepairSaveData()
    for key, value in pairs(self.defaults) do
        if (self.saveData[key] == nil) then
            self.saveData[key] = value
        end
    end
end

function PermanentExperienceBar:Arguments(args)
    local arguments = {}
    local searchResult = { string.match(args,"^(%S*)%s*(.-)$") }
    for i,v in pairs(searchResult) do
        if (v ~= nil and v ~= "") then
            arguments[i] = string.lower(v)
        end
    end
    return arguments
end

------------------------
-- Core Functionality --
------------------------

function PermanentExperienceBar:CreateHUD()
	SCENE_MANAGER:GetScene("hud"):AddFragment(PLAYER_PROGRESS_BAR_FRAGMENT)
	SCENE_MANAGER:GetScene("hud"):AddFragment(PLAYER_PROGRESS_BAR_CURRENT_FRAGMENT)
end

function PermanentExperienceBar:CreateHUDUI()
	SCENE_MANAGER:GetScene("hudui"):AddFragment(PLAYER_PROGRESS_BAR_FRAGMENT)
	SCENE_MANAGER:GetScene("hudui"):AddFragment(PLAYER_PROGRESS_BAR_CURRENT_FRAGMENT)
end

function PermanentExperienceBar:CreateInteract()
    SCENE_MANAGER:GetScene("interact"):AddFragment(PLAYER_PROGRESS_BAR_FRAGMENT)
	SCENE_MANAGER:GetScene("interact"):AddFragment(PLAYER_PROGRESS_BAR_CURRENT_FRAGMENT)
end

function PermanentExperienceBar:Disable()
    -- Store settings for next run
    self.saveData.enabled = false

    -- Reload the UI to wipe the old fragments
    ReloadUI("ingame")
end

function PermanentExperienceBar:Enable()
    -- Store settings for next run
    self.saveData.enabled = true

    -- Add the experience bar to the two hud displays so it always shows up
    self:CreateHUD()
    self:CreateHUDUI()
end

function PermanentExperienceBar:Show()
    ZO_PlayerProgressBar:SetAlpha(1)
end

----------------------
--  Register Events --
----------------------

EVENT_MANAGER:RegisterForEvent(PermanentExperienceBar.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

------------------------
--  Register Commands --
------------------------

SLASH_COMMANDS["/expbar"] = function (args)
  local arguments = PermanentExperienceBar:Arguments(args)
  if next(arguments) == nil or arguments[1] == "help" then
      d("--------------------------------------------------")
      d("Permanent Experience Bar Commands")
      d("--------------------------------------------------")
      d("help - This information")
      d("disable - Disable the permanent experience bar")
      d("enable - Enable the experience bar")
      d("hud - Add experience bar to HUD*")
      d("hudui - Add experience bar to HUD UI*")
      d("interactive - Add experience bar to Interactive Scenes")
      d("show - Set opacity to highly visible")
      d("--------------------------------------------------")
      d("*These functions run automatically on startup")
      d("--------------------------------------------------")
  elseif arguments[1] == "disable" then
      d("Removing Experience Bar...")
      PermanentExperienceBar:Disable()
  elseif arguments[1] == "enable" then
      PermanentExperienceBar:Enable()
      d("Enabled Experience Bar")
  elseif arguments[1] == "hud" then
      PermanentExperienceBar:CreateHUD()
      d("HUD added")
  elseif arguments[1] == "hudui" then
      PermanentExperienceBar:CreateHUDUI()
      d("HUD UI added")
  elseif arguments[1] == "interactive" then
      PermanentExperienceBar:CreateInteract()
      d("Interactive Scene added")
  elseif arguments[1] == "show" then
      PermanentExperienceBar:Show()
      d("Experience Bar shown")
  else
      d("Command not known: " .. arguments[1])
  end
end
