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
        if e.data and e.data.name==PBWT.L("px_menu") then parent=e end
        if e.data and e.data.scene=="gamepad_options_root" then index=i end
    end
    local icon="EsoUI/Art/HUD/Gamepad/gp_radialIcon_duel_down.dds"
    if not parent then
        if not index then return end
        parent=entry({name=PBWT.L("px_menu"),icon=icon,customTemplate="ZO_GamepadMenuEntryTemplateWithArrow",subMenu={}},"PBsPX")
        parent.subMenu={}; table.insert(ZO_MENU_ENTRIES,index,parent)
    end
    parent.subMenu=parent.subMenu or {}; parent.data.subMenu=parent.data.subMenu or {}
    -- The gamepad main menu renders exactly two levels (category and sub list), so the
    -- modes live one step further in, on the add-on's own mode screen.
    for _,e in ipairs(parent.subMenu) do if e.id=="PBsWarTable" or e.data.name==PBWT.Config.Title() then return end end
    -- Giving it a scene rather than a callback is what the menu does for Options and the rest:
    -- selecting it pushes that scene over the sub-menu, and Back returns here.
    local data={name=PBWT.Config.Title(),icon=icon,customTemplate="ZO_GamepadMenuEntryTemplateWithArrow",scene=PBWT.ModeMenu.SCENE}
    table.insert(parent.data.subMenu,data); table.insert(parent.subMenu,entry(data,"PBsWarTable"))
end
-- Called again once the world is up: PLAYER_TO_PLAYER may not exist yet when the add-on
-- loads, and a wheel without our entry is the only way a player finds duels.
function PBWT.HookMenu()
    PBWT.EnsureMenu()
    if MAIN_MENU_GAMEPAD and ZO_PreHook and not PBWT.mainMenuHooked then
        PBWT.mainMenuHooked=true
        ZO_PreHook(MAIN_MENU_GAMEPAD,"RefreshMainList",PBWT.EnsureMenu)
    end
    if PLAYER_TO_PLAYER and ZO_PreHook and not PBWT.interactHooked then
        PBWT.interactHooked=true
        -- The wheel's own icons, gamepad and keyboard, as the other PX games use them.
        local gamepadIcon="EsoUI/Art/HUD/Gamepad/gp_radialIcon_duel_down.dds"
        local icons={
            gamepad={enabledNormal=gamepadIcon,enabledSelected=gamepadIcon,
                disabledNormal="EsoUI/Art/HUD/Gamepad/gp_radialIcon_duel_disabled.dds",
                disabledSelected="EsoUI/Art/HUD/Gamepad/gp_radialIcon_duel_disabled.dds"},
            keyboard={enabledNormal="EsoUI/Art/HUD/radialIcon_duel_up.dds",
                enabledSelected="EsoUI/Art/HUD/radialIcon_duel_over.dds",
                disabledNormal="EsoUI/Art/HUD/radialIcon_duel_disabled.dds",
                disabledSelected="EsoUI/Art/HUD/radialIcon_duel_disabled.dds"},
        }
        -- Inject immediately before the built-in Cancel entry, before RadialMenu:Show.
        -- Do not replace ShowPlayerInteractMenu or append after the wheel is laid out.
        ZO_PreHook(PLAYER_TO_PLAYER,"AddMenuEntry",function(menu,label)
            if label~=GetString(SI_RADIAL_MENU_CANCEL_BUTTON) then return end
            local peer=menu.currentTargetDisplayName
            if not peer or peer=="" or peer==GetDisplayName() or IsIgnored(peer) then return end
            if not CanCommunicateWith(menu.currentTargetCharacterNameRaw) then return end
            -- The entry stays visible even when the duel cannot start yet (not grouped, in
            -- combat, library missing): PBWT.Challenge says which of those it is, and a
            -- missing entry would leave no way to find out.
            local set=(IsInGamepadPreferredMode and IsInGamepadPreferredMode()) and icons.gamepad or icons.keyboard
            menu:AddMenuEntry(PBWT.L("menu_invite"),set,true,function()
                -- Let the existing wheel finish handling its selection first.
                zo_callLater(function() PBWT.Challenge(peer) end,0)
            end)
        end)
    end
end
