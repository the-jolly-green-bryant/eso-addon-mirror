PBT=PBT or {}
local icon='EsoUI/Art/HUD/Gamepad/gp_radialIcon_duel_down.dds'
local function entry(data,id)
 local e=ZO_GamepadEntryData:New(data.name,data.icon);e.data=data;e.id=id;e:SetIconTintOnSelection(true);e:SetIconDisabledTintOnSelection(true);e:SetEnabled(true);return e
end
function PBT.EnsureMenu(app)
 if not ZO_MENU_ENTRIES then return end
 local parent,index
 for i,e in ipairs(ZO_MENU_ENTRIES) do
  if e.data.name=='ゲームセンターPX' then parent=e end
  if e.data.scene=='gamepad_options_root' then index=i end
 end
 if not parent then
  if not index then return end
  parent=entry({name='ゲームセンターPX',icon=icon,customTemplate='ZO_GamepadMenuEntryTemplateWithArrow',subMenu={}},'PBsPX')
  -- Inserted at the options entry rather than after it, which puts it between help and
  -- options: those two are adjacent and in that order in the client's own menu table.
  parent.subMenu={};table.insert(ZO_MENU_ENTRIES,index,parent)
 end
 parent.subMenu=parent.subMenu or {};parent.data.subMenu=parent.data.subMenu or {}
 for _,e in ipairs(parent.subMenu) do if e.id=='PBsTetris' or e.data.name==PBT.ModeMenu.TITLE then return end end
 -- One entry under Game Centre PX. Giving it a scene rather than a callback is what the menu
 -- itself does for Options and the rest: selecting it pushes that scene over the sub-menu.
 local data={name=PBT.ModeMenu.TITLE,icon=icon,customTemplate='ZO_GamepadMenuEntryTemplateWithArrow',scene=PBT.ModeMenu.SCENE}
 table.insert(parent.data.subMenu,data);table.insert(parent.subMenu,entry(data,'PBsTetris'))
end
function PBT.HookMenus(app)
 if not PBT.modeMenu and PBsTetrisModeMenu then PBT.modeMenu=PBT.ModeMenu:New(PBsTetrisModeMenu,app) end
 PBT.EnsureMenu(app)
 ZO_PreHook(MAIN_MENU_GAMEPAD,'RefreshMainList',function() PBT.EnsureMenu(app) end)
 ZO_PreHook(PLAYER_TO_PLAYER,'AddMenuEntry',function(menu,label)
  if label~=GetString(SI_RADIAL_MENU_CANCEL_BUTTON) then return end
  local peer=menu.currentTargetDisplayName
  if not peer or peer=='' or peer==GetDisplayName() or IsIgnored(peer) then return end
  if not CanCommunicateWith(menu.currentTargetCharacterNameRaw) then return end
  menu:AddMenuEntry('タムリエル de テトリス',{enabledNormal=icon,enabledSelected=icon,disabledNormal=icon,disabledSelected=icon},true,function()
   zo_callLater(function() app:Challenge(peer) end,0)
  end)
 end)
end
