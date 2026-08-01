local NP = NamePlater or {}

NP.name = "NamePlater"
NP.version = "0.15"

function NP:SetupEvents(toggle)
  --EVENT_ZONE_CHANGED
  if toggle then
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_ACTIVATED,  function(...) self:SetFont(self.SV.font, self.SV.style, self.SV.size) end)
  else
    EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_PLAYER_ACTIVATED)
  end
end

function NP:SetFont(font, style, size)
  local fp, fs

  if IsInGamepadPreferredMode() then
    fp, fs = GetNameplateGamepadFont()

    if fp ~= font or fs ~= style then
      SetNameplateGamepadFont(font .. "|" .. size .. "|", style)
    end

  else
    fp, fs = GetNameplateKeyboardFont()

    if fp ~= font or fs ~= style then
      SetNameplateKeyboardFont(font .. "|" .. size .. "|", style)
    end
  end
end

function NP:Initialise()
  -- find addon version (not version)
  local manager = GetAddOnManager()

  for i = 1, manager:GetNumAddOns() do
    local name, _, _, _, _, state = manager:GetAddOnInfo(i)
    if name == self.name then
      self.version = manager:GetAddOnVersion(i)
    end
  end

  self.SV = ZO_SavedVars:NewAccountWide("NamePlaterSettings", self.version, "Settings", self.defaults)

  self:SetFont(self.SV.font, self.SV.style, self.SV.size)
  self:SetupEvents(true)
end

function NP.OnLoad(event, addonName)
  if addonName ~= NP.name then return end
  EVENT_MANAGER:UnregisterForEvent(NP.name, EVENT_ADD_ON_LOADED, NP.OnLoad)
  NP:InitialiseAddonMenu()
  NP:Initialise()
end

EVENT_MANAGER:RegisterForEvent(NP.name, EVENT_ADD_ON_LOADED, NP.OnLoad)

