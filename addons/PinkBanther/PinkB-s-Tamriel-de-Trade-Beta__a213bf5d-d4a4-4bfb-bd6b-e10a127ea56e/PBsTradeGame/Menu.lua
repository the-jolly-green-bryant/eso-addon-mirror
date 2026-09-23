-- Integrates with the same PX category as the user's other game add-ons.
local T=PBTrade
function T.EnsureMenu()
    if not ZO_MENU_ENTRIES or not ZO_GamepadEntryData then return end
    local function entry(data,id)
        local e=ZO_GamepadEntryData:New(data.name,data.icon)
        e.data,e.id=data,id; e:SetIconTintOnSelection(true); e:SetEnabled(true); return e
    end
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
    for _,e in ipairs(parent.subMenu) do
        if e.id==T.Config.addonId or (e.data and e.data.name==T.Config.displayTitle) then return end
    end
    local data={name=T.Config.displayTitle,icon=icon,customTemplate="ZO_GamepadMenuEntryTemplateWithArrow",scene=T.Config.scene}
    table.insert(parent.data.subMenu,data); table.insert(parent.subMenu,entry(data,T.Config.addonId))
end
function T.HookMenu()
    T.EnsureMenu()
    if MAIN_MENU_GAMEPAD and ZO_PreHook and not T.mainMenuHooked then
        T.mainMenuHooked=true
        ZO_PreHook(MAIN_MENU_GAMEPAD,"RefreshMainList",T.EnsureMenu)
    end
end
