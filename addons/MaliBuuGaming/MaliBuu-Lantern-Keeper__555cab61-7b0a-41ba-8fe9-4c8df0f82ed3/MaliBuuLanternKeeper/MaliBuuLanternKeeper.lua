-- MaliBuu LanternKeeper v1.0 (effect-watcher)
local ADDON_NAME="MaliBuuLanternKeeper"; local EM=GetEventManager()
local SV; local ACTIVE=false
local COLLECTIBLE_ID,ABILITY_ID=341,26829
local DEFAULTS={enabled=true,tickMs=2000}

local function ready()
  local remain=select(1,GetCollectibleCooldownAndDuration(COLLECTIBLE_ID))
  return (remain or 0)==0
end

local function say(msg)
  if ZO_Alert then ZO_Alert(UI_ALERT_CATEGORY_ALERT,SOUNDS.BOOK_ACQUIRED,msg)
  elseif CENTER_SCREEN_ANNOUNCE then CENTER_SCREEN_ANNOUNCE:AddMessage("MBLK",CSA_EVENT_SMALL_TEXT,SOUNDS.BOOK_ACQUIRED,msg)
  else PlaySound(SOUNDS.BOOK_ACQUIRED) end
end

local function fire()
  if not (SV and SV.enabled) then return end
  if IsUnitInCombat("player") then return end
  if not IsCollectibleUnlocked(COLLECTIBLE_ID) or not ready() then return end
  UseCollectible(COLLECTIBLE_ID)
end

local function onFX(_,change,_,_,unit,_,_,_,_,_,_,_,_,_,_,ability)
  if unit~="player" or ability~=ABILITY_ID then return end
  if change==EFFECT_RESULT_FADED then ACTIVE=false; fire() else ACTIVE=true end
end

EM:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, function(_,name)
  if name~=ADDON_NAME then return end
  SV=ZO_SavedVars:NewAccountWide("MaliBuuLanternKeeper_SV",1,nil,DEFAULTS,GetWorldName())
  -- no login toast in 1.0; keep it quiet
  EM:RegisterForEvent(ADDON_NAME, EVENT_EFFECT_CHANGED, onFX)
  EM:AddFilterForEvent(ADDON_NAME, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")
  EM:AddFilterForEvent(ADDON_NAME, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, ABILITY_ID)
  EM:RegisterForUpdate(ADDON_NAME.."_tick", SV.tickMs, function() if not ACTIVE then fire() end end)
  zo_callLater(function() if not ACTIVE then fire() end end,1500)
  if type(SLASH_COMMANDS)=="table" then
    SLASH_COMMANDS["/lantern"]=function(arg)
      arg=string.lower(zo_strtrim(arg or ""))
      if arg=="on" then SV.enabled=true; fire()
      elseif arg=="off" then SV.enabled=false
      else if d then d("Usage: /lantern on|off") end end
    end
  end
end)
