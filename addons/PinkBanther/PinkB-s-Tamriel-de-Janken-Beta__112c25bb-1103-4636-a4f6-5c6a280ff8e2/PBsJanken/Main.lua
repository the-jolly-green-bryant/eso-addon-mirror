local App={name="PBsJanken"}
PBJ.App=App
local function random32()
    -- ESO's random source is not cryptographically secure; this is a casual game.
    return math.random(0,65535)*65536+math.random(0,65535)
end
function App:Alert(key) ZO_Alert(UI_ALERT_CATEGORY_ALERT,nil,PBJ.Text(key)) end
function App:Changed(game)
    if game~=self.game then return end
    if game.state=="result" and not game.counted then
        game.counted=true
        if not self.practice then self.saved[game.result]=self.saved[game.result]+1 end
    elseif game:IsActive() then game.counted=false end
    if self.ui then
        self.ui:Refresh()
        if game.state=="invited" then self.ui:Show() end
    end
end
function App:CreateOnlineGame()
    self.practice=false
    self.game=PBJ.Game.New({name=GetDisplayName(),now=GetFrameTimeSeconds,random=random32,
        allowed=function(peer) return self.transport:Allowed(peer) end,
        send=function(peer,packet) return self.transport:Send(peer,packet) end,
        changed=function(game) self:Changed(game) end})
end
function App:Challenge(peer)
    if self.game:IsActive() then self:Alert("busy"); self.ui:Show(); return end
    if self.transport.error then
        local message=self.transport:ErrorText()
        ZO_Alert(UI_ALERT_CATEGORY_ALERT,nil,PBJ.Text(self.transport.error))
        -- Original technical diagnostics are available only on explicit request.
        self.lastDiagnostic=message
        return
    end
    if not self.transport:Allowed(peer) then self:Alert("groupRequired"); return end
    if self.practice then self:CreateOnlineGame() end
    if self.game:Invite(peer) then self.ui:Show() end
end
function App:Practice()
    if self.game:IsActive() then self:Alert("busy"); return end
    self.practice=true
    local player,bot
    local function deliver(receiver,sender,packet)
        zo_callLater(function()
            if self.practice and self.game==player then receiver():Receive(sender,packet) end
        end,350)
        return true
    end
    player=PBJ.Game.New({name=GetDisplayName(),now=GetFrameTimeSeconds,random=random32,
        allowed=function() return true end,
        send=function(_,packet) return deliver(function() return bot end,GetDisplayName(),packet) end,
        changed=function(game) self:Changed(game) end})
    bot=PBJ.Game.New({name="Training partner",now=GetFrameTimeSeconds,random=random32,
        allowed=function() return true end,
        send=function(_,packet) return deliver(function() return player end,"Training partner",packet) end,
        changed=function(game)
            if game.state=="invited" then
                game:Accept()
                game:Choose(math.random(1,3))
            end
        end})
    self.game=player
    player:Invite("Training partner")
    self.ui:Show()
end
function App:Replay()
    if self.practice then self:Practice() else self:Challenge(self.game.peer) end
end
function App:HookInteraction()
    local gamepadIcons={
        enabledNormal="EsoUI/Art/HUD/Gamepad/gp_radialIcon_duel_down.dds",
        enabledSelected="EsoUI/Art/HUD/Gamepad/gp_radialIcon_duel_down.dds",
        disabledNormal="EsoUI/Art/HUD/Gamepad/gp_radialIcon_duel_disabled.dds",
        disabledSelected="EsoUI/Art/HUD/Gamepad/gp_radialIcon_duel_disabled.dds",
    }
    local keyboardIcons={
        enabledNormal="EsoUI/Art/HUD/radialIcon_duel_up.dds",
        enabledSelected="EsoUI/Art/HUD/radialIcon_duel_over.dds",
        disabledNormal="EsoUI/Art/HUD/radialIcon_duel_disabled.dds",
        disabledSelected="EsoUI/Art/HUD/radialIcon_duel_disabled.dds",
    }
    -- Inject immediately before the built-in Cancel entry, before RadialMenu:Show.
    -- Do not replace ShowPlayerInteractMenu or append after the wheel is laid out.
    ZO_PreHook(PLAYER_TO_PLAYER,"AddMenuEntry",function(menu,text)
        if text~=GetString(SI_RADIAL_MENU_CANCEL_BUTTON) then return end
        local peer=menu.currentTargetDisplayName
        if not peer or peer=="" or peer==GetDisplayName() or IsIgnored(peer) then return end
        if not CanCommunicateWith(menu.currentTargetCharacterNameRaw) then return end
        local icons=IsInGamepadPreferredMode() and gamepadIcons or keyboardIcons
        menu:AddMenuEntry(PBJ.Text("menu"),icons,true,function()
            -- Let the existing wheel finish handling its selection first.
            zo_callLater(function() self:Challenge(peer) end,0)
        end)
    end)
end
function App:Initialize()
    PBJ.Textures:Initialize()
    self.saved=ZO_SavedVars:NewAccountWide("PBsJyankenSavedVariables",1,nil,{win=0,lose=0,draw=0})
    self.transport=PBJ.Transport.New(function(sender,packet)
        if not self.practice then self.game:Receive(sender,packet) end
    end)
    self:CreateOnlineGame()
    self.ui=PBJ.UI.New(self)
    self:HookInteraction()
    SLASH_COMMANDS["/pbj"]=function(args)
        if args:match("^%s*practice%s*$") then self:Practice()
        elseif args:match("^%s*textures%s*$") then
            if self.game:IsActive() then self:Alert("busy") else self.ui:Show(true) end
        elseif args:match("^%s*debug%s*$") then
            if d then
                d(self.lastDiagnostic or PBJ.Text("noDiagnostic"))
                d("画像格納先（"..PBJ.Textures.rootSource.."）: "..PBJ.Textures.root)
                if self.ui.textureReport then d(self.ui.textureReport) end
            end
        else self.ui:Show() end
    end
    EVENT_MANAGER:RegisterForUpdate(self.name.."Tick",100,function()
        self.game:Tick()
        if self.ui.scene:IsShowing() then self.ui:RefreshTimer() end
    end)
    EVENT_MANAGER:RegisterForEvent(self.name,EVENT_PLAYER_DEACTIVATED,function()
        if self.game:IsActive() then self.game:Cancel("unavailable") end
        SCENE_MANAGER:Hide("pbjGame")
    end)
end
EVENT_MANAGER:RegisterForEvent(App.name,EVENT_ADD_ON_LOADED,function(_,name)
    if name~=App.name then return end
    EVENT_MANAGER:UnregisterForEvent(App.name,EVENT_ADD_ON_LOADED)
    App:Initialize()
end)
