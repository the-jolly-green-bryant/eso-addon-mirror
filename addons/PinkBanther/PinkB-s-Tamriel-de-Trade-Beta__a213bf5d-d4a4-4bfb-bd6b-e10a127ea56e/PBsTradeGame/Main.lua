local T,C=PBTrade,PBTrade.Config
function T.Open()
    if not T.ui then return end
    if IsUnitInCombat("player") then ZO_Alert(UI_ALERT_CATEGORY_ALERT,nil,"戦闘終了後に交易台帳を開いてください"); return end
    SCENE_MANAGER:Show(C.scene)
end
EVENT_MANAGER:RegisterForEvent(C.addonId,EVENT_ADD_ON_LOADED,function(_,name)
    if name~=C.addonId then return end
    EVENT_MANAGER:UnregisterForEvent(C.addonId,EVENT_ADD_ON_LOADED)
    T.Assets.Initialize()
    local defaults={state=nil,tutorialComplete=false}
    if ZO_SavedVars and ZO_SavedVars.NewAccountWide then
        T.saved=ZO_SavedVars:NewAccountWide(C.savedVariables,1,nil,defaults)
    else T.saved=defaults end
    -- Keep load light: the 1,302-property session is created when the scene first opens.
    T.ui=T.UI.New(function() T.app=T.app or T.Controller.New(nil,T.saved); return T.app end); T.HookMenu()
    SLASH_COMMANDS["/pbtrade"]=T.Open
    local previous=GetFrameTimeSeconds(); local locationCheck=0
    EVENT_MANAGER:RegisterForUpdate(C.addonId,C.ui.updateMs,function()
        local now=GetFrameTimeSeconds(); local dt=math.max(0,now-previous); previous=now; T.ui:Tick(dt)
        locationCheck=locationCheck+dt
        if locationCheck>=2 then
            locationCheck=0
            if T.app and T.LiveCatalog then
                local property,newlyVisited=T.LiveCatalog.CaptureCurrent(T.app.state)
                if property and newlyVisited then
                    T.app.notice=property.name.."を現地確認しました。買収交渉が解放されました"
                    T.app:Flash("discovery",property.name.."を現地確認！",2.8); T.app:Save()
                end
            end
        end
    end)
    local function hide() if T.app then T.app:Save() end; SCENE_MANAGER:Hide(C.scene) end
    EVENT_MANAGER:RegisterForEvent(C.addonId,EVENT_PLAYER_COMBAT_STATE,function(_,inCombat) if inCombat then hide() end end)
    EVENT_MANAGER:RegisterForEvent(C.addonId,EVENT_CONTROLLER_DISCONNECTED,hide)
    EVENT_MANAGER:RegisterForEvent(C.addonId,EVENT_PLAYER_DEACTIVATED,hide)
    EVENT_MANAGER:RegisterForEvent(C.addonId,EVENT_PLAYER_ACTIVATED,function()
        T.HookMenu(); if T.app and T.LiveCatalog then T.LiveCatalog.CaptureCurrent(T.app.state); T.app:Save() end
    end)
    if EVENT_ZONE_CHANGED then
        EVENT_MANAGER:RegisterForEvent(C.addonId.."LiveCatalog",EVENT_ZONE_CHANGED,function()
            if T.app and T.LiveCatalog then T.LiveCatalog.CaptureCurrent(T.app.state); T.app:Save() end
        end)
    end
end)
