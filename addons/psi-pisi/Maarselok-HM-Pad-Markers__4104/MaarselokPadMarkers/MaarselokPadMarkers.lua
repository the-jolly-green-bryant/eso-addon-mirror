MPM = {
  name = "MaarselokPadMarkers",
  version = "1.0.0",
  author = "psi-pisi"
};

local iconData = {
  -- Pad 1 [OSI] x=134418 y=69003 z=137996 zone=1123
  -- Pad 2 [OSI] x=136796 y=69026 z=140548 zone=1123
  -- Pad 3 [OSI] x=133322 y=68990 z=141543 zone=1123
  {x = 134418, y = 69003 + 750, z = 137996, texture = "odysupporticons/icons/squares/squaretwo_red_one.dds"},
  {x = 136796, y = 69026 + 750, z = 140548, texture = "odysupporticons/icons/squares/squaretwo_red_two.dds"},
  {x = 133322, y = 68990 + 750, z = 141543, texture = "odysupporticons/icons/squares/squaretwo_red_three.dds"},
}

local function OnAddOnLoaded(addOnName)
  if (addOnName ~= MPM.name) then
    MPM.Initialize()
  end
end

function MPM.Initialize()
  --Unregister Loaded Callback
  EVENT_MANAGER:UnregisterForEvent(MPM.name, EVENT_ADD_ON_LOADED);
end

function MPM.OnAreaChange()
  if GetZoneId(GetUnitZoneIndex("player")) ~= 1123 then
    return
  else
    for index, value in pairs(iconData) do
      OSI.CreatePositionIcon(value.x, value.y, value.z, value.texture, OSI.GetIconSize() * 3.5, {1, 1, 1})
    end
  end
end

EVENT_MANAGER:RegisterForEvent(MPM.name..'OnPlayerActivated', EVENT_PLAYER_ACTIVATED, MPM.OnAreaChange)

--Register Loaded Callback
EVENT_MANAGER:RegisterForEvent(MPM.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded);