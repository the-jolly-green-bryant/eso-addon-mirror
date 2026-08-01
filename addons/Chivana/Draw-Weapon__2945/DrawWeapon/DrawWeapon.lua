
if DrawWeapon == nil then DrawWeapon = {
  addon = "DrawWeapon",
  name = "Draw Weapon", 
  author = "Chivana",
  version = "1.4.1",
} end

local DW = DrawWeapon
local EM = GetEventManager()

local function isRollDodge()
  local i = GetNumBuffs("player")
  while i > 0 do
    local buffName, _, _, _, _, _, _, _, _, _, abilityId = GetUnitBuffInfo("player", i)
    if DW.savedVars.debug then d(zo_strformat("<<1>>. [<<2>>] <<C:3>>", i, abilityId, ZO_SELECTED_TEXT:Colorize(buffName))) end
    if abilityId == 69143 then -- Dodge Fatigue
    	if DW.droll == false then
			  DW.droll = true
			  return true
      end
      return false 
    end  
    i = i - 1
  end 
  DW.droll = false
  return false
end

local function isSprinting()
  local sprint = false
  if DW.savedVars.shift > 0 then 
    local _, x, _, y = GetUnitRawWorldPosition('player')
   	if DW.x ~= nil and DW.y ~= nil then
      local xd = x - DW.x
      local yd = y - DW.y
	    local speed = math.sqrt(xd * xd + yd * yd) / DW.loop * 1000
      if DW.savedVars.debug then d(speed) end
      if speed > DW.savedVars.shift then
        sprint = true
        if DW.savedVars.debug then d("Sprint detected.") end
      end
    end  
		DW.x = x
		DW.y = y
  else
    sprint = IsShiftKeyDown()
  end
  return sprint
end

local function OnAddonUpdate()
  if not DW.savedVars.enabled then
    DW.count = 0
    return
  end
  if IsUnitInCombat("player") or IsUnitSwimming("player") or IsMounted() or not IsPlayerMoving() then 
    DW.count = 0
  else
    local sprint = isSprinting()
    if ArePlayerWeaponsSheathed() then
      if DW.savedVars.draw then
        if sprint and not DW.savedVars.sprint then
          DW.count = 0
          if DW.savedVars.debug then d("Sprinting.") end
        elseif not sprint and not DW.savedVars.sprint and not DW.savedVars.dodge and not DW.savedVars.stealth and DW.count == DW.skip 
        or DW.savedVars.sprint and sprint 
        or DW.savedVars.dodge and isRollDodge() 
        or DW.savedVars.stealth and GetUnitStealthState("player") ~= 0 then
          TogglePlayerWield()
          if DW.savedVars.debug then d("Draw weapon!") end
        elseif DW.count < DW.skip then
          DW.count = DW.count + 1
          if DW.savedVars.debug then d("Movement ignored.") end
        end  
      end  
   	else 
      if DW.savedVars.sheath then
        if sprint and not (DW.savedVars.draw and DW.savedVars.sprint) then
          TogglePlayerWield()
          if DW.savedVars.debug then d("Sheath weapon!") end
        end
      end 
    end  	
  end  
end

local function OnAddonLoaded(_,addonName)
  if addonName ~= DW.addon then return end
  EM:UnregisterForEvent(DW.addon,EVENT_ADD_ON_LOADED)

  local defaultVars = {
    debug = false,
    enabled = true,
    draw = true,
    sheath = true,
    sprint = false,
    dodge = false,
    stealth = false,
    shift = 0,
  }
  DW.savedVars = ZO_SavedVars:NewCharacterIdSettings("DrawWeaponSavedVars", 1, nil, defaultVars)
  DW.loop = 499
  DW.skip = 1
  DW.count = 0
  DW.droll = false
  DW.x = nil
  DW.y = nil
  
  local LAM2 = LibAddonMenu2
  LAM2:RegisterAddonPanel("DrawWeaponSettings", { 
    type = "panel", 
    name = DW.name, 
    author = DW.author,
    version = DW.version,
    registerForRefresh = true,
  })
  LAM2:RegisterOptionControls("DrawWeaponSettings", {
  	{
    	type = "header",
  	  name = "Settings",
  	},
    {
      type = "checkbox",
      name = "Auto-draw weapon",
      tooltip = "Draw weapon when out of combat moving (and not mounted or swimming).",
      getFunc = function() return DW.savedVars.draw end,
      setFunc = function(value) DW.savedVars.draw = value end,
    },
    {
      type = "checkbox",
      name = "     on Roll Dodge",
      tooltip = "Draw weapon after using Roll Dodge (Hasty Retreat with Bow equipped).",
      getFunc = function() return DW.savedVars.dodge end,
      setFunc = function(value) DW.savedVars.dodge = value end,
      disabled = function() return not DW.savedVars.draw end,
    },
    {
      type = "checkbox",
      name = "     when crouching",
      tooltip = "Draw weapon when crouching (Stealth).",
      getFunc = function() return DW.savedVars.stealth end,
      setFunc = function(value) DW.savedVars.stealth = value end,
      disabled = function() return not DW.savedVars.draw end,
    },
    {
      type = "checkbox",
      name = "     when sprinting",
      tooltip = "Draw weapon when sprinting (Shift key or Sprint detection).",
      getFunc = function() return DW.savedVars.sprint end,
      setFunc = function(value) DW.savedVars.sprint = value end,
      disabled = function() return not DW.savedVars.draw end,
    },
    {
      type = "checkbox",
      name = "Auto-sheath weapon",
      tooltip = "Sheath weapon when out of combat sprinting (Shift key or Sprint detection).",
      getFunc = function() return DW.savedVars.sheath end,
      setFunc = function(value) DW.savedVars.sheath = value end,
      disabled = function() return DW.savedVars.draw and DW.savedVars.sprint end,
    },
    {
      type = "slider",
      name = "Sprint detection",
      tooltip = "Movement speed threshold (Set to 0 if using Shift key).",
      min = 0,
      max = 2000,
      step = 1,
      getFunc = function() return DW.savedVars.shift end,
      setFunc = function(value) DW.savedVars.shift = value end,
    },
    {
      type = "divider",
    },
    {
      type = "checkbox",
      name = "Debug",
      tooltip = "Display debug info in chat (incl. current speed).",
      getFunc = function() return DW.savedVars.debug end,
      setFunc = function(value) DW.savedVars.debug = value end,
    },
  })

  EM:RegisterForUpdate(DW.addon.."OnAddonUpdate",DW.loop,OnAddonUpdate)
end
 
EM:RegisterForEvent(DW.addon,EVENT_ADD_ON_LOADED,OnAddonLoaded)

ZO_CreateStringId("SI_BINDING_NAME_DRAWWEAPON_TOGGLE_ENABLED", "Enable/disable")
function DrawWeapon.ToggleEnabled()
  if DW.savedVars.enabled then
    DW.savedVars.enabled = false
    d("Draw Weapon disabled.")
  else
    DW.savedVars.enabled = true
    d("Draw Weapon enabled.")
  end  
end
