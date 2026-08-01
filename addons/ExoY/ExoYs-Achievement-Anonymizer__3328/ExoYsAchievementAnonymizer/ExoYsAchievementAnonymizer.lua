local LibExoY = LibExoYsUtilities
local LAM = LibAddonMenu2
local EM = GetEventManager()


local function OnAddonLoaded(_, addonName)

  if addonName == "ExoYsAchievementAnonymizer" then
    EM:UnregisterForEvent("ExoYsAchievementAnonymizer", EVENT_ADD_ON_LOADED)

    local defaults = {
      useCustom = false,
      string = "Custom Text",
      color = {1,1,1,1},
    }

    local store = ZO_SavedVars:NewAccountWide("ExoYsAchievementAnonymizerSV", 2, nil, defaults)

    local function Update()
      local string = ""
      if store.useCustom then
        string = LibExoY.ColorString(store.string, store.color)
      end

      SafeAddString(SI_ACHIEVEMENT_EARNED_FORMATTER, string, 2)

    end

    local optionsData = {
      {
        type = "description",
        text = "This addon hides the > |cFF8800Earned by|r < tooltip part of completed achievements.",
        width = "full",
      },
      {
        type = "divider",
        width = "full",
      },
      {
        type = "description",
        text = "Alternatively, the tooltip part can be replaced by a generic text:",
        width = "full",
      },
      {
        type = "checkbox",
        name = "Enable",
        getFunc = function() return store.useCustom end,
        setFunc = function( value )
          store.useCustom = value
          Update()
        end,
        width = "full",
      },
      {
        type = "editbox",
        tooltip = "custom tooltip text.",
        disabled = function() return not store.useCustom end,
        name = "",
        getFunc = function() return store.string end,
        setFunc = function( text )
            store.string = text
            Update()
         end,
        isMultiline = false,
        width = "half",
      },
      {
        type = "colorpicker",
        tooltip = "define color of custom text",
        disabled = function() return not store.useCustom end,
        name = "",
        disabled = function() return not store.useCustom end,
        getFunc = function() return unpack( store.color ) end,
        setFunc = function(r,g,b)
          store.color = {r,g,b,1}
          Update()
        end,
        width = "half",
      },
    }

    SettingsMenuParameter = {
      name = "ExoYsAchievementAnonymizer",
      displayName = "|c00FF00ExoY|rs Achievement Anonymizer",
      version = "2.1",
      esoui = "info3328-ExoYsAchievementAnonymizer.html",
      profiles = nil, 
      controls = optionsData,
  } 
  LibExoY.CreateSettingsMenu( SettingsMenuParameter ) 

    Update()
    ZO_PreHook(Achievement, "RefreshTooltip", function()
      return true
    end)

  end
  
end

EM:RegisterForEvent("ExoYsAchievementAnonymizer", EVENT_ADD_ON_LOADED, OnAddonLoaded)
