--indexes
--1 disabled
--2 all
local index=3
--bastian,mirri,isobel,ember,sharp,azandar,tanlorin,zerith-var
local companionIds={9245,9353,9912,9911,11113,11114,12172,12173}
--get ids
--/script for i=10000,15000 do local name,_,_,_,_,_,_,type=GetCollectibleInfo(i) if type==27 then d(name) d(i) end end
local companions={}
for i,val in pairs(companionIds) do  
  local name,description,icon,_,unlocked,_,isActive,_,hint=GetCollectibleInfo(val)
  if IsCollectibleBlocked(val) and GetCollectibleBlockReason(val)==COLLECTIBLE_USAGE_BLOCK_REASON_COMPANION_INTRO_QUEST then unlocked=false end
  companions["activeId"]=0
  table.insert(companions,{
    index=index,
    id=val,
    name=name,
    description=description,
    icon=icon,
    unlocked=unlocked,
    isActive=isActive,
    hint=hint,    
  })
  index=index+1
end

BCUI         = {
  name          ="BanditsCompanions",  
  Frames        ={},
  Player        ={},
  Vars          ={},
  Menu          ={},
  Panel         ={},
  Companions    ={},
  Binds         ={},
  CompanionInfo = companions,
  InSettingMenu =false,
  FramesLocked  =true,
  language      =GetCVar("language.2"),
  Localization  ={},
  Loc =function(var) return BCUI.Localization[BCUI.language] and BCUI.Localization[BCUI.language][var] or BCUI.Localization.en[var] or var end,
}

local function Initialize ()
    CALLBACK_MANAGER:UnregisterCallback("BUI_Ready", Initialize)

    BCUI.Vars.Initialize()
    BCUI.Frames.Initialize()  
    BCUI.Menu.Initialize()  
    BCUI.Binds.Initialize()
    BCUI.Panel.Initialize()
    BCUI.RegisterEvents()
end

local function preInit (eventCode, addOnName)
  if addOnName~=BCUI.name then return end
  
  EVENT_MANAGER:UnregisterForEvent("BCUI_Event", EVENT_ADD_ON_LOADED)  
end

--EVENT_MANAGER:RegisterForEvent("BCUI_Event", EVENT_ADD_ON_LOADED, preInit)
CALLBACK_MANAGER:RegisterCallback("BUI_Ready", Initialize)