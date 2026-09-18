-- Share the existing PX menu without replacing other add-ons' entries.
local function entry(data,id)
    local e=ZO_GamepadEntryData:New(data.name,data.icon)
    e.data,e.id=data,id; e:SetIconTintOnSelection(true); e:SetEnabled(true)
    return e
end
function PBWT.EnsureMenu()
    if not ZO_MENU_ENTRIES or not ZO_GamepadEntryData then return end
    local parent,index
    for i,e in ipairs(ZO_MENU_ENTRIES) do
        if e.data and e.data.name=="ゲームセンターPX" then parent=e end
        if e.data and e.data.scene=="gamepad_options_root" then index=i end
    end
    local icon="EsoUI/Art/HUD/Gamepad/gp_radialIcon_duel_down.dds"
    if not parent then
        if not index then return end
        parent=entry({name="ゲームセンターPX",icon=icon,customTemplate="ZO_GamepadMenuEntryTemplateWithArrow",subMenu={}},"PBsPX")
        parent.subMenu={}; table.insert(ZO_MENU_ENTRIES,index,parent)
    end
    parent.subMenu=parent.subMenu or {}; parent.data.subMenu=parent.data.subMenu or {}
    for _,mode in ipairs({{id="PBsWarTableSolo",mode="beginner",label="COM初級"},
        {id="PBsWarTableIntermediate",mode="intermediate",label="COM中級"},
        {id="PBsWarTableAdvanced",mode="advanced",label="COM上級"},
        {id="PBsWarTableLocal",mode="local",label="ローカル検証"},
        {id="PBsWarTableTutorial",mode="tutorial",label="チュートリアル"}}) do
        local found=false
        for _,e in ipairs(parent.subMenu) do if e.id==mode.id then found=true; break end end
        if not found then
            local chosen=mode.mode
            local data={name=PBWT.Config.TITLE.."（"..mode.label.."）",icon=icon,activatedCallback=function() PBWT.Open(chosen) end}
            table.insert(parent.data.subMenu,data); table.insert(parent.subMenu,entry(data,mode.id))
        end
    end
end
function PBWT.HookMenu()
    PBWT.EnsureMenu()
    if MAIN_MENU_GAMEPAD and ZO_PreHook then ZO_PreHook(MAIN_MENU_GAMEPAD,"RefreshMainList",PBWT.EnsureMenu) end
    if PLAYER_TO_PLAYER and ZO_PreHook then
        local icon="EsoUI/Art/HUD/Gamepad/gp_radialIcon_duel_down.dds"
        ZO_PreHook(PLAYER_TO_PLAYER,"AddMenuEntry",function(menu,label)
            if label~=GetString(SI_RADIAL_MENU_CANCEL_BUTTON) then return end
            local peer=menu.currentTargetDisplayName
            if not PBWT.transport or not PBWT.transport:Check(peer,true) then return end
            menu:AddMenuEntry(PBWT.Config.TITLE,{enabledNormal=icon,enabledSelected=icon,disabledNormal=icon,disabledSelected=icon},true,function()
                zo_callLater(function() PBWT.Challenge(peer) end,0)
            end)
        end)
    end
end
