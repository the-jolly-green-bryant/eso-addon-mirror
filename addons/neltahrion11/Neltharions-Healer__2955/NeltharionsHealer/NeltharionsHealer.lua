--neltharionsHealer = {}
local NeltharionsHealer = NeltharionsHealer




NeltharionsHealer.enableAddon = true
NeltharionsHealer.replacable = false


NeltharionsHealer.unitTags = {}
NeltharionsHealer.inCombat = false
NeltharionsHealer.playerName = ""
NeltharionsHealer.LOW_HEALTH = 0.65
NeltharionsHealer.ignoreCompanion = false
NeltharionsHealer.ignorePlayersOutOfRange = false
NeltharionsHealer.unitTemp = ""
NeltharionsHealer.unitTempText = ""
NeltharionsHealer.warnsound = ""
NeltharionsHealer.warnsoundRange = ""
NeltharionsHealer.soundVolumen = 100
NeltharionsHealer.globalSoundVolume = 100
NeltharionsHealer.warnsoundenable = true

NeltharionsHealer.warnTColor = ZO_ColorDef:New(255,0,0,255)
NeltharionsHealer.warnTRColor = ZO_ColorDef:New(255,255,0,255)

NeltharionsHealer.overlayColerW = ZO_ColorDef:New(255,0,0,128)
NeltharionsHealer.overlayColerOR = ZO_ColorDef:New(255,255,0,128)
NeltharionsHealer.overlayPreview = false
NeltharionsHealer.overlayORPreview = false


NeltharionsHealer.overlayEnable = false
NeltharionsHealer.overlayOREnable = false
NeltharionsHealer.randomText = false

NeltharionsHealer.SoundEventIdentifier = "NeltharionsHealerAsyncSoundEvent"

NeltharionsHealer.cYellow = "|cffff22"
NeltharionsHealer.cYellow2 = "|cf2ff00"
NeltharionsHealer.cCyan = "|c22ffed"
NeltharionsHealer.cRed = "|cf21000"
NeltharionsHealer.cBlue = "|c0004ff"
NeltharionsHealer.cGreen = "|c0cf236"
NeltharionsHealer.cDGreen = "|c239c13"
NeltharionsHealer.cWhite = "|cffffff"


local NbusyPlaySound = false

 -- Initialize our addon
function NeltharionsHealer.OnAddOnLoaded(_, addOnName)
  --d("|ceeeeeeNeltharionHealer by |c006600Neltharion |ceeeeee v"..NeltharionsHealer.version.."|r")
  --d("|ceeeeeeNeltharionHealer by |c006600Neltharion |ceeeeee v"..NeltharionsHealer.version.."|r")
  if(addOnName == NeltharionsHealer.addOnName) then

    NeltharionsHealer:Initialize()
    NeltharionsHealer:CreateSettingsMenu()
  end
end

local function OnPluginLoaded(event, addon)

end


function NeltharionsHealer.OnPowerUpdate(eventCode, unitTag, powerIndex,powerType, powerValue, powerMax, powerEffectiveMax)
	NeltharionsHealer.UpdateVolatileUnitInfo(unitTag)
end

function NeltharionsHealer:Initialize()
  self.inCombat = IsUnitInCombat("player")
  self.playerName = GetUnitName("player")
  EVENT_MANAGER:RegisterForEvent(self.addOnName, EVENT_PLAYER_COMBAT_STATE, self.OnPlayerCombatState)
  EVENT_MANAGER:RegisterForEvent(self.addOnName, EVENT_POWER_UPDATE, NeltharionsHealer.OnPowerUpdate)

  self.savedVariables = LibSavedVars
    :NewAccountWide("NeltharionsHealer_Account", self.DEFAULTS)
    :AddCharacterSettingsToggle("NeltharionsHealer_Character")

  self:RestorePosition()
  self.CheckLOW_HEALTH(true)
  self:SetIgoreOption(true)
  self.enableAddon = self.savedVariables.enableAddon
  self.ignoreCompanion = self.savedVariables.ignoreCompanion
  self.warnsound = self.savedVariables.warnsound
  self.warnsoundRange = self.savedVariables.warnsoundoutR
  self.warnsoundenable = self.savedVariables.warnsoundenable
  self.soundVolumen = self.savedVariables.soundVolumen
  self.globalSoundVolume = math.floor(GetSetting(SETTING_TYPE_AUDIO,AUDIO_SETTING_UI_VOLUME))
  self.warnTColor = ZO_ColorDef:New(self.savedVariables.warnTColor)
  self.warnTRColor = ZO_ColorDef:New(self.savedVariables.warnTRColor)
  self.overlayEnable = self.savedVariables.overlayEnable
  self.overlayOREnable = self.savedVariables.overlayOREnable
  self.randomText = self.savedVariables.randomText
  NeltharionsHealer.AddonIsEnabled()




  neltharionsHealerIndicatorBG:SetAlpha(0)
  neltharionsHealerIndicator:SetWidth(600)
  neltharionsHealerIndicator:SetHeight(50)

  neltharionsHealerIndicatorT:ClearAnchors()
  neltharionsHealerIndicatorT:SetAnchor(CENTER, neltharionsHealerIndicator, CENTER, 0, 0)

  neltharionsHealerIndicatorT:SetWidth(600)
  neltharionsHealerIndicatorT:SetHeight(50)
  neltharionsHealerIndicatorT:SetHorizontalAlignment(1)

  neltharionsHealerAlertBorder:SetHidden(true)

  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_GAME_CAMERA_UI_MODE_CHANGED, NeltharionsHealer.UIModeChanged)
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_ACTIVATED, NeltharionsHealer.LateInitialize)
  EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_ADD_ON_LOADED)
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_RETICLE_HIDDEN_UPDATE, NeltharionsHealer.ReticleStateChanced)



  zo_callLater(NeltharionsHealer.InitializeReady, 1000)

end

function NeltharionsHealer.LateInitialize(eventCode, addOnName)
  --d("Neltharions Healer loaded...")
  EVENT_MANAGER:UnregisterForEvent(NeltharionsHealer.addOnName, EVENT_PLAYER_ACTIVATED)
end

function NeltharionsHealer.InitializeReady()
  d(NeltharionsHealer.cGreen.."NeltharionsHealer "..NeltharionsHealer.cDGreen.."v"..NeltharionsHealer.version..NeltharionsHealer.cWhite.." by "..NeltharionsHealer.cRed.."Neltharion |r")
  --d("|ceeeeeeNeltharionsHealer by |c006600Neltharion |ceeeeee v"..NeltharionsHealer.version.."|r")
end

function NeltharionsHealer.OnPlayerCombatState(event, inCombat)
  -- The ~= operator is "not equal to" in Lua.
  if inCombat ~= NeltharionsHealer.inCombat then
    NeltharionsHealer.inCombat = inCombat
    if inCombat then
      -- entering combat - clear unitTags
      NeltharionsHealer.unitTags = {}
      --d("Enter Fight!")
    else
      -- exiting combat - clear indicator
      neltharionsHealerIndicatorT:SetColor(255,255,255,255)
      neltharionsHealerIndicatorT:SetText("")
      NeltharionsHealer.unitTemp = ""
      NeltharionsHealer.unitTempText = ""
      NeltharionsHealer.displayOverlay(false)
      --d("Exit Fight")
    end
  end
end


function NeltharionsHealer.UpdateIndicator()
  local priorityUnit = nil;
  if NeltharionsHealer.inCombat then
    for i, unit in pairs(NeltharionsHealer.unitTags) do
      if unit.Online and (not unit.Dead) and unit.LowHealth and (unit.InSupportRange or not NeltharionsHealer.ignorePlayersOutOfRange) then
        if NeltharionsHealer.ignoreCompanion then
          if not unit.isCompanion then
            if not priorityUnit then
              priorityUnit = unit
            else
              if unit.HealthPercent < priorityUnit.HealthPercent then
                priorityUnit = unit
              end
            end
          end
        else
          if not priorityUnit then
            priorityUnit = unit
          else
            if unit.HealthPercent < priorityUnit.HealthPercent then
              priorityUnit = unit
            end
          end
        end
      end
    end

    if priorityUnit then
      if priorityUnit.InSupportRange then
        --neltharionsHealerIndicatorT:SetColor(255,0,0,255)
        neltharionsHealerIndicatorT:SetColor(NeltharionsHealer.warnTColor:UnpackRGBA())
        if NeltharionsHealer.playerName == priorityUnit.Name then
          --neltharionsHealerIndicatorT:SetText(GetString(LOCALES_HEAL_YOURSELF))
          NeltharionsHealer.setAlertText(true, priorityUnit.Name, true)
        else
          --neltharionsHealerIndicatorT:SetText(GetString(LOCALES_HEAL).." "..priorityUnit.Name.."!")
          NeltharionsHealer.setAlertText(false, priorityUnit.Name, true)
        end
        NeltharionsHealer.Soundalert(priorityUnit.Name, false)
        NeltharionsHealer.displayOverlay(true, false)
      else
        if not NeltharionsHealer.ignorePlayersOutOfRange then
          neltharionsHealerIndicatorT:SetColor(NeltharionsHealer.warnTRColor:UnpackRGBA())
          --neltharionsHealerIndicatorT:SetText(priorityUnit.Name.." "..GetString(LOCALES_OUT_OF_RANGE))
          NeltharionsHealer.setAlertText(false, priorityUnit.Name, false)
          NeltharionsHealer.Soundalert(priorityUnit.Name, true)
          NeltharionsHealer.displayOverlay(true, true)
        else
          neltharionsHealerIndicatorT:SetText("")
          NeltharionsHealer.displayOverlay(false, true)
        end
      end
    else
      neltharionsHealerIndicatorT:SetText("")
      NeltharionsHealer.unitTemp = ""
      NeltharionsHealer.unitTempText = ""
      NeltharionsHealer.displayOverlay(false, false)
    end
  end
end

function NeltharionsHealer.UpdateVolatileUnitInfo(unitTag)
  if not unitTag then
    return
  end

  local currentHp, maxHp, effectiveMaxHp
  local unit = {}

  if NeltharionsHealer.inCombat and (string.sub(unitTag,1,string.len("group"))=="group" or string.sub(unitTag,1,string.len("player"))=="player") then
		currentHp, maxHp, effectiveMaxHp = GetUnitPower(unitTag, POWERTYPE_HEALTH)

    unit.Name = GetUnitName(unitTag)
		unit.Dead = IsUnitDead(unitTag)
		unit.Online = IsUnitOnline(unitTag)
		unit.HealthPercent = currentHp / maxHp
		unit.LowHealth = unit.HealthPercent <= NeltharionsHealer.LOW_HEALTH
		unit.InSupportRange = IsUnitInGroupSupportRange(unitTag)
		unit.UnitTag = unitTag
    unit.isCompanion = IsGroupCompanionUnitTag(unitTag)


		NeltharionsHealer.unitTags[unitTag] = unit
		NeltharionsHealer.UpdateIndicator()
	end
end

function NeltharionsHealer:CheckLOW_HEALTH(isSelf)
	local userValue = 0;

	if isSelf then
		userValue = self.savedVariables.userLOW_HEALTH
	else
		userValue = NeltharionsHealer.savedVariables.userLOW_HEALTH
	end

	if (userValue and userValue > 5) then
		if isSelf then
			self.LOW_HEALTH = (userValue/100)
		else
			NeltharionsHealer.LOW_HEALTH = (userValue/100)
		end
	end
end

function NeltharionsHealer:SetIgoreOption(isSelf)
	if isSelf then
		self.ignorePlayersOutOfRange = self.savedVariables.ignorePlayersOutOfRange
	else
		NeltharionsHealer.ignorePlayersOutOfRange = NeltharionsHealer.savedVariables.ignorePlayersOutOfRange
	end
end

function NeltharionsHealer.OnIndicatorMoveStop()
	NeltharionsHealer.savedVariables.left = neltharionsHealerIndicator:GetLeft()
	NeltharionsHealer.savedVariables.top = neltharionsHealerIndicator:GetTop()
end

function NeltharionsHealer:RestorePosition()
	local left = self.savedVariables.left
	local top = self.savedVariables.top

	neltharionsHealerIndicator:ClearAnchors()
	neltharionsHealerIndicator:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end

function NeltharionsHealer.UIModeChanged()
	if (IsReticleHidden()) then
		neltharionsHealerIndicatorBG:SetAlpha(100)
		neltharionsHealerIndicatorT:SetText(GetString(LOCALES_LABLE_NAME))
	else
		neltharionsHealerIndicatorBG:SetAlpha(0)
		neltharionsHealerIndicatorT:SetText("")
	end
end

function NeltharionsHealer.ReticleStateChanced(eventCode,hidden)
	if (hidden and NeltharionsHealer.savedVariables.userVISIBLE ~= true) then
	   neltharionsHealerIndicator:SetHidden(true)
   else
	   neltharionsHealerIndicator:SetHidden(false)
   end
end


function NeltharionsHealer.Soundalert(unit, brange)
  if (NeltharionsHealer.warnsoundenable == true) then
    if (NeltharionsHealer.unitTemp ~= unit) then
      NeltharionsHealer.unitTemp = unit
      if (brange == true) then
        --PlaySound(NeltharionsHealer.warnsoundoutR)
        NeltharionsHealer.playSounds(NeltharionsHealer.warnsoundRange)
      else
        --PlaySound(NeltharionsHealer.warnsound)
        NeltharionsHealer.playSounds(NeltharionsHealer.warnsound)
      end
    end
  end
end

function NeltharionsHealer.playSounds(sound)
  if(NbusyPlaySound == false) then
    NbusyPlaySound = true
    NeltharionsHealer.globalSoundVolume = math.floor(GetSetting(SETTING_TYPE_AUDIO,AUDIO_SETTING_UI_VOLUME))
  end
  SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_UI_VOLUME, NeltharionsHealer.soundVolumen)
  PlaySound(sound)
  EVENT_MANAGER:RegisterForUpdate(NeltharionsHealer.SoundEventIdentifier, 5000, NeltharionsHealer.resetVolumenAsync)
end

function NeltharionsHealer.resetVolumenAsync()
  EVENT_MANAGER:UnregisterForUpdate(NeltharionsHealer.SoundEventIdentifier)
  SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_UI_VOLUME, NeltharionsHealer.globalSoundVolume)
  NbusyPlaySound = false
--  d("ResetVol")
end



function NeltharionsHealer.AddonIsEnabled()
  if(NeltharionsHealer.enableAddon == true) then
    EVENT_MANAGER:RegisterForEvent(NeltharionsHealer.addOnName, EVENT_PLAYER_COMBAT_STATE, NeltharionsHealer.OnPlayerCombatState)
    EVENT_MANAGER:RegisterForEvent(NeltharionsHealer.addOnName, EVENT_POWER_UPDATE, NeltharionsHealer.OnPowerUpdate)
    --d("Addon an")
  else
    EVENT_MANAGER:UnregisterForEvent(NeltharionsHealer.addOnName, EVENT_PLAYER_COMBAT_STATE, NeltharionsHealer.OnPlayerCombatState)
    EVENT_MANAGER:UnregisterForEvent(NeltharionsHealer.addOnName, EVENT_POWER_UPDATE, NeltharionsHealer.OnPowerUpdate)
    --d("Addon aus")
  end
end

function NeltharionsHealer.displayOverlay(enable, range)
  if(range == true and NeltharionsHealer.overlayOREnable == true)then
    neltharionsHealerAlertBorderOverlay:SetEdgeColor(NeltharionsHealer.overlayColerOR:UnpackRGBA())
    neltharionsHealerAlertBorder:SetHidden(not enable)
  elseif (range == false and NeltharionsHealer.overlayEnable == true)then
     neltharionsHealerAlertBorderOverlay:SetEdgeColor(NeltharionsHealer.overlayColerW:UnpackRGBA())
     neltharionsHealerAlertBorder:SetHidden(not enable)
  else
     neltharionsHealerAlertBorder:SetHidden(true)
  end
end


function NeltharionsHealer.setAlertText(BisPlayer, SunitName, BinRange)
  if(NeltharionsHealer.randomText == false) then
    if(BisPlayer == true) then
      neltharionsHealerIndicatorT:SetText(GetString(LOCALES_HEAL_YOURSELF))
    else
      if(BinRange == true) then
        neltharionsHealerIndicatorT:SetText(GetString(LOCALES_HEAL).." "..SunitName.."!")
      else
        neltharionsHealerIndicatorT:SetText(SunitName.." "..GetString(LOCALES_OUT_OF_RANGE))
      end
    end
  else
    if (NeltharionsHealer.unitTempText ~= SunitName) then
      NeltharionsHealer.unitTempText = SunitName
      local rand = math.random(1, 3)
      if(BisPlayer == true) then
        if(rand == 1) then
          neltharionsHealerIndicatorT:SetText(GetString(LOCALES_HEAL_YOURSELF))
        elseif(rand==2) then
          neltharionsHealerIndicatorT:SetText(GetString(LOCALES_HEAL_YOURSELF_2))
        elseif(rand == 3)then
          neltharionsHealerIndicatorT:SetText(GetString(LOCALES_HEAL_YOURSELF_3))
        else
          neltharionsHealerIndicatorT:SetText(GetString(LOCALES_HEAL_YOURSELF))
        end
      else
        if(BinRange == true) then
          if(rand ==1)then
            neltharionsHealerIndicatorT:SetText(GetString(LOCALES_HEAL).." "..SunitName.."!")
          elseif(rand==2) then
            neltharionsHealerIndicatorT:SetText(GetString(LOCALES_HEAL_2).." "..SunitName.."!")
          elseif(rand==3)then
            neltharionsHealerIndicatorT:SetText(SunitName.." "..GetString(LOCALES_HEAL_3))
          else
            neltharionsHealerIndicatorT:SetText(GetString(LOCALES_HEAL).." "..SunitName.."!")
          end
        else
          if(rand == 1) then
            neltharionsHealerIndicatorT:SetText(SunitName.." "..GetString(LOCALES_OUT_OF_RANGE))
          elseif(rand == 2)then
            neltharionsHealerIndicatorT:SetText(SunitName.." "..GetString(LOCALES_OUT_OF_RANGE_2))
          elseif(rand == 3)then
            neltharionsHealerIndicatorT:SetText(SunitName.." "..GetString(LOCALES_OUT_OF_RANGE_3))
          else
            neltharionsHealerIndicatorT:SetText(SunitName.." "..GetString(LOCALES_OUT_OF_RANGE))
          end
        end 
      end
    end
  end
end






SLASH_COMMANDS["/neltharionscmd"] = function(option)
  local options = {}
  if(option) then
    local searchResult = { string.match(option,"^(%S*)%s*(.-)$") }
    for i,v in pairs(searchResult) do
        if (v ~= nil and v ~= "") then
            options[i] = string.lower(v)
        end
    end
    if #options == 0 or options[1] == "help" then
       -- Display help
       d("|ceeeeeeNeltharionHealer by |c006600Neltharion |ceeeeee v"..NeltharionsHealer.version.."|r")
       d(GetString(LOCALES_SLCMD_HELP)..":")
       d(GetString(LOCALES_SLCMD_COMAND)..":")
       d("/neltharionscmd ignorerange [on/off]")
       d(GetString(LOCALES_SLCMD_IGNOREDES))
       d("/neltharionscmd ignorecomp [on/off]")
       d(GetString(LOCALES_SLCMD_IGNORECOMP))
       d("/neltharionscmd sound [on/off]")
       d(GetString(LOCALES_SLCMD_SOUNDDES))
       d("/neltharionscmd health [1 - 99]")
       d(GetString(LOCALES_SLCMD_HEALTHDES))
    elseif options[1] == "ignorerange" then
      if options[2] == "on" then
        NeltharionsHealer.savedVariables.ignorePlayersOutOfRange = true
        NeltharionsHealer.SetIgoreOption(false)
        d("Ignore On")
      elseif options[2] == "off" then
        NeltharionsHealer.savedVariables.ignorePlayersOutOfRange = false
        NeltharionsHealer.SetIgoreOption(false)
        d("Ignore Off")
      else
          d("/neltharioncmd ignorerange [on/off]")
          d(GetString(LOCALES_SLCMD_WRGOPT))
      end
    elseif options[1] == "ignorecomp" then
      if options[2] == "on" then
        NeltharionsHealer.savedVariables.ignoreCompanion = true
        NeltharionsHealer.ignoreCompanion = true
        d("Ignore Companion on")
      elseif options[2] == "off" then
        NeltharionsHealer.savedVariables.ignoreCompanion = false
        NeltharionsHealer.ignoreCompanion = false
        d("Ignore Companion off")
      else
        d("/neltharioncmd ignorecomp [on/off]")
        d(GetString(LOCALES_SLCMD_WRGOPT))
      end
    elseif options[1] == "sound" then
      if options[2] == "on" then
        NeltharionsHealer.savedVariables.warnsoundenable = true
        NeltharionsHealer.warnsoundenable = true
        d("Sound On")
      elseif options[2] == "off" then
        NeltharionsHealer.savedVariables.warnsoundenable = false
        NeltharionsHealer.warnsoundenable = false
        d("Sound Off")
      else
        d("/neltharionscmd sound [on/off]")
        d(GetString(LOCALES_SLCMD_WRGOPT))
      end
    elseif options[1] == "health" then
      if options[2] ~= 0 then
        local isNum = tonumber(options[2]) ~= nil
        if(isNum == true) then
          local num = tonumber(options[2])
          if num > 0 and num < 100 then
            NeltharionsHealer.savedVariables.userLOW_HEALTH = num
            NeltharionsHealer.CheckLOW_HEALTH(false)
            d(GetString(LOCALES_SLCMD_HEALTH)..num)
          else
              d(GetString(LOCALES_SLCMD_HEALTHNUM))
          end
        else
          d(GetString(LOCALES_SLCMD_HEALTHNUMT))
        end
      else
        d("/neltharionscmd health [1 - 99]")
        d(GetString(LOCALES_SLCMD_WRGOPT))
      end
    else
      d(GetString(LOCALES_SLCMD_WRGOPT))
    end
  end
end

EVENT_MANAGER:RegisterForEvent(NeltharionsHealer.addOnName, EVENT_ADD_ON_LOADED, NeltharionsHealer.OnAddOnLoaded);
