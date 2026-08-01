local TITW = ThisIsTheWayshrine

local LAM = LibHarvensAddonSettings

if not LibHarvensAddonSettings then
    return
end

function TITW:BuildMenu()

  self.panel = LAM:AddAddon(TITW.Name, {
    allowDefaults = false,  -- Show "Reset to Defaults" button
    allowRefresh = true    -- Enable automatic control updates
  })

  self.panel:AddSetting {
    type = LAM.ST_CHECKBOX,
    label = TITW.Lang.ENABLE_JUMPING,
    getFunction = function()
      return TITW.SV.enableJumping
    end,
    setFunction = function(var)
      TITW.SV.enableJumping = var
      if var then
        TITW.checkGuildMembersCurrentZoneAndJump()
      end
    end,
    default = TITW.SV.enableJumping
  }

  self.panel:AddSetting {
    type = LAM.ST_CHECKBOX,
    label = TITW.Lang.ANNOUNCE,
    getFunction = function()
      return TITW.SV.announce
    end,
    setFunction = function(var)
      TITW.SV.announce = var
    end,
    default = TITW.SV.announce
  }

  self.panel:AddSetting {
    type = LAM.ST_LABEL,
    label = TITW.Lang.GUILD_ENABLE_HEADER
  }

  for iDex = 1, GetNumGuilds() do
    local guildId = GetGuildId(iDex)
    self.panel:AddSetting {
      type = LAM.ST_CHECKBOX,
      label = GetGuildName(guildId),
      getFunction = function()
        if not TITW.AV.enableOverrideGuilds[guildId].initial then
          return TITW.AV.enableOverrideGuilds[guildId].enabled
        end
        return true
      end,
      setFunction = function(var)
        if guildId ~= nil then
          if TITW.AV.enableOverrideGuilds[guildId].initial then
            TITW.AV.enableOverrideGuilds[guildId] = { enabled = var }
          end
          TITW.AV.enableOverrideGuilds[guildId].enabled = var
        end
      end,
      default = true
    }
  end

  self.panel:AddSetting {
    type = LAM.ST_LABEL,
    label = TITW.Lang.TOGGLE_ZONE_DISCOVERY,
  }

  self.panel:AddSetting {
    type = LAM.ST_CHECKBOX,
    label = TITW.Lang.TOGGLE_ALL_ZONES,
    getFunction = function()
      return TITW.SV.selectAll
    end,
    setFunction = function(var)
      TITW.toggleAvailableZones(var)
      TITW.SV.selectAll = var
    end,
    default = TITW.SV.selectAll
  }

  for i, data in pairs(GAMEPAD_WORLD_MAP_LOCATIONS.data.mapData) do
    local locationName = data.locationName
    local zoneId = TITW:GetZoneIdFromZoneName(locationName)
    self.panel:AddSetting {
      type = LAM.ST_CHECKBOX,
      label = data.locationName,
      getFunction = function()
        if TITW.SV.enabledZones[zoneId] ~= nil then
          return TITW.SV.enabledZones[zoneId].enabled
        end
        return TITW.SV.selectAll
      end,
      setFunction = function(var)
        if zoneId ~= nil then
          if TITW.SV.enabledZones[zoneId] == nil then
            TITW.SV.enabledZones[zoneId] = TITW:enumerateWayshrines(nil, zoneId)
          end
          TITW.SV.enabledZones[zoneId].enabled = var
        end
      end,
      default = TITW.SV.selectAll,
      disable = function()
        return not ZONE_STORIES_GAMEPAD.IsZoneCollectibleUnlocked(zoneId) and not TITW:GetZoneFullyDiscovered(zoneId)
      end
    }
  end
end
