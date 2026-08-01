local DEG_ADDON = _G["DEG_CURRENT_ADDON"]

local function d(msg)
  _G[DEG_ADDON.PACKAGE_NAME].plugins[DEG_ADDON.ADDON_NAME_SHORT]:d(msg)
end

local function ts(...)
  return tostring(...)
end

local Addon = {}
Addon.initialized = false
Addon.debug = false--release:false
Addon.name = DEG_ADDON.ADDON_NAME
Addon.versionString = '1.022'
Addon.saveVariablesName = DEG_ADDON.SAVED_VARS_NAME
Addon.savedVariablesAccount = nil
Addon.savedVariablesCharacter = nil
Addon.saveVariablesVersion = 1
Addon.vars = {control = nil}
Addon.Settings = _G[DEG_ADDON.ADDON_NAME.."Settings"]

function Addon:Initialize()
  if (self.initialized) then return end

  local defaultsAccount = {frameAlpha = 50, frameColor={255/255,0,0}, frameSize=100}
  self.savedVariablesAccount = ZO_SavedVars:NewAccountWide(self.saveVariablesName, self.saveVariablesVersion, nil, defaultsAccount)
   
  local defaultsCharacter = {helperActivated = true}
  self.savedVariablesCharacter = ZO_SavedVars:New(self.saveVariablesName, self.saveVariablesVersion, nil, defaultsCharacter)   
  
  self.Settings:initialize()
  
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_ACTIVATED, function(...) self:onEVENT_PLAYER_ACTIVATED(...) end)
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_RETICLE_TARGET_CHANGED, function(...) self:onEVENT_RETICLE_TARGET_CHANGED(...) end)
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_EFFECT_CHANGED, function(...) self:onEVENT_EFFECT_CHANGED(...) end)
      
  local moreMotd = ""
  if self.debug then moreMotd =" ,"..ts(GetGameTimeMilliseconds()) end
  LibMOTD:setMessage(self.savedVariablesAccount, "|c3f95ffDryzler's|r |cEFEBBETaunt Helper|r: "..GetString(SI_DEG_TAUNT_MOTD)..moreMotd, 2)

  degLib("ad1")

  self.initialized = true
end

function Addon:showHelper()

  if not self.vars.control then
    self.vars.control = WINDOW_MANAGER:CreateControl("DEGTauntControl", ZO_ReticleContainer, CT_TEXTURE)
    --self.vars.control:SetTexture([[esoui/art/icons/housing_targetdummy_humanoid_01_empty.dds]])
    self.vars.control:SetTexture([[esoui/art/icons/placeholder/icon_offense_swordtarget_01.dds]])    
    --esoui/art/icons/housing_targetdummy_humanoid_01.dds
    self.vars.control:SetAnchor(CENTER, ZO_ReticleContainer, CENTER, 0, 0)
  end
  
  local scale = self.savedVariablesAccount.frameSize / 100
  local size = 40 * scale
  self.vars.control:SetWidth(size)
  self.vars.control:SetHeight(size)  
  local r,g,b = unpack(self.savedVariablesAccount.frameColor)    
  self.vars.control:SetColor(r, g, b, 1)
  self.vars.control:SetAlpha(self.savedVariablesAccount.frameAlpha / 100) --0,62745098039215686274509803921569
  
  self.vars.control:SetHidden(false)
end

function Addon:hideHelper()
  if not self.vars.control then return end
  self.vars.control:SetHidden(true)
end

function Addon:onEVENT_EFFECT_CHANGED()
  self:updateReticle()
end

function Addon:updateReticle()
  if not self.savedVariablesCharacter.helperActivated then
    return
  end
  
  local hasSpot = nil
  if self.debug or IsUnitInCombat('player') then
    if (DoesUnitExist('reticleover') and not IsUnitDead('reticleover')) then
      local reaction = GetUnitReaction('reticleover')
      if reaction == UNIT_REACTION_HOSTILE then
        hasSpot = false
        for i = 1,GetNumBuffs('reticleover') do
          local auraName, start, finish, buffSlot, stack, icon, buffType, effectType, abilityType, statusType, abilityId, canClickOff, castByPlayer = GetUnitBuffInfo('reticleover', i)
          
          if ABILITY_TYPE_SETTARGET == abilityType then        
            hasSpot = true
            i = GetNumBuffs('reticleover')
          end
        end
      end
    end
  end
  
  if hasSpot == false then
    self:showHelper()
  else
    self:hideHelper()
  end
end

function Addon:onEVENT_RETICLE_TARGET_CHANGED()
  --d("onEVENT_RETICLE_TARGET_CHANGED")
    
  self:updateReticle()
end

function Addon:onEVENT_PLAYER_ACTIVATED(intEventCode, bInitial)
  d("onEVENT_PLAYER_ACTIVATED: "..GetUnitName("player"))
end

--#################################################################################################

function Addon:d(m)
  if self.debug then
    _G.d(self.name.."> "..tostring(m))
  end
end

_G[DEG_ADDON.PACKAGE_NAME].plugins[DEG_ADDON.ADDON_NAME_SHORT] = Addon;

EVENT_MANAGER:RegisterForEvent(DEG_ADDON.ADDON_NAME, EVENT_ADD_ON_LOADED, 
  function(event, AddonName)
    if AddonName == _G[DEG_ADDON.PACKAGE_NAME].plugins[DEG_ADDON.ADDON_NAME_SHORT].name then
      _G[DEG_ADDON.PACKAGE_NAME].plugins[DEG_ADDON.ADDON_NAME_SHORT]:Initialize()
      EVENT_MANAGER:UnregisterForEvent(_G[DEG_ADDON.PACKAGE_NAME].plugins[DEG_ADDON.ADDON_NAME_SHORT].name, EVENT_ADD_ON_LOADED)
    end
  end
)