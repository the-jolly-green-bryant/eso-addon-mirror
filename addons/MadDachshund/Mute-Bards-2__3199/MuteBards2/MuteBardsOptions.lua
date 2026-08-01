MuteBards = MuteBards or {};
local isInitialized = false;
function MuteBards:InitSettingsPanel(svZones, svChar)

  local function refreshCallback()
    self:Refresh();
  end

  local function getCurrentZoneName(sv)
    if (sv ~= nil and sv.currentSubZone ~= ni and sv.currentSubZone ~= "") then
      return sv.currentSubZone;
    end
    return "UNKNOWN"
  end

  local panelData = {
    type = "panel",
    name = "Mute Bards 2",
    displayName = "Mute Bards 2",
    author = "@MadDachshund",
    version = self.version,
    website = "https://www.esoui.com/downloads/info3199-MuteBards2.html",
    feedback = "https://www.esoui.com/downloads/info3199-MuteBards2.html#comments",
    slashCommand = "/mutebards", --(optional) will register a keybind to open to this panel
    registerForRefresh = true, --boolean (optional) (will refresh all options controls when a setting is changed and when the panel is shown)
    registerForDefaults = false, --boolean (optional) (will set all options controls back to default values)
  }

  local zoneToAdd, zoneToRemove

  local optionsTable = {
    {
      type = "header",
      name = "Zones",
      width = "full", --or "half" (optional)
    },
    {
      type = "description",
      --title = "My Title",	--(optional)
      text = "Add the exact subzone (usually town) name for the zone you wish to mute bards in.  For example, \"Solitude\" or \"Rimmen\" (without quotes)",
      width = "full", --or "half" (optional)
    },
    {
      type = "description",
      title = "Current Zone:",	--(optional)
      text = function() return "  " .. getCurrentZoneName(svChar) end,

      width = "half", --or "half" (optional)
    },
    {
      type = "button",
      name = "Add Current Zone",
      disabled = function()  return getCurrentZoneName(svChar) == "UNKNOWN" end,
      func = function()
        if (getCurrentZoneName(svChar) ~= "UNKNOWN") then
          self:AddZone(getCurrentZoneName(svChar), refreshCallback);
        end
      end,
      width = "half", --or "half" (optional)
    },
    {
      type = "editbox",
      name = "Add Zone:",
      tooltip = "Zone Name",
      getFunc = function()
        return zoneToAdd
      end,
      setFunc = function(text)
        zoneToAdd = text
      end,
      isMultiline = false, --boolean
      width = "half", --or "half" (optional)
      default = "", --(optional)
    },
    {
      type = "button",
      name = "Add",
      func = function()
        self:AddZone(zoneToAdd, refreshCallback);
        zoneToAdd = "";
      end,
      width = "half", --or "half" (optional)
    },
    {
      type = "description",
      title = "Currently Muted Zones:",
      text = function()
        return table.concat(svZones, ", ");
      end,
      width = "full",
      requiresReload = true,
    },
    {
      type = "editbox",
      name = "Remove Zone:",
      getFunc = function()
        return zoneToRemove
      end,
      setFunc = function(text)
        zoneToRemove = text
      end,
      isMultiline = false, --boolean
      width = "half", --or "full" (optional)
      default = "", --(optional)
    },
    {
      type = "button",
      name = "Remove",
      func = function()
        self:RemoveZone(zoneToRemove, refreshCallback);
        zoneToRemove = "";
      end,
      width = "half", --or "full" (optional)
    },
    {
      type = "button",
      name = "Force Refresh",
      func = refreshCallback,
      width = "full", --or "half" (optional)
    },
  }

  local LAM = LibAddonMenu2
  if (not isInitialized) then
    LAM:RegisterAddonPanel("MuteBards2", panelData);
  end
  LAM:RegisterOptionControls("MuteBards2", optionsTable);

  isInitialized = true;

end