local T,C=PBTrade,PBTrade.Config
function T.Open()
    if not T.ui then return end
    if IsUnitInCombat("player") then ZO_Alert(UI_ALERT_CATEGORY_ALERT,nil,"戦闘終了後に交易台帳を開いてください"); return end
    SCENE_MANAGER:Show(C.scene)
end
EVENT_MANAGER:RegisterForEvent(C.addonId,EVENT_ADD_ON_LOADED,function(_,name)
    if name~=C.addonId then return end
    EVENT_MANAGER:UnregisterForEvent(C.addonId,EVENT_ADD_ON_LOADED)
    local defaults={state=nil,tutorialComplete=false}
    if ZO_SavedVars and ZO_SavedVars.NewAccountWide then
        T.saved=ZO_SavedVars:NewAccountWide(C.savedVariables,1,nil,defaults)
    else T.saved=defaults end
    -- Texture path: always the add-on-relative one at load (as PBsTetris). A choice made in the
    -- ledger lasts only for the session, so a path that fails can never stick across launches.
    T.saved.assetRoot=nil
    T.Assets.Initialize(1)
    -- Keep load light: the 1,302-property session is created when the scene first opens.
    T.ui=T.UI.New(function() T.app=T.app or T.Controller.New(nil,T.saved); return T.app end); T.HookMenu()
    -- Visits are observed from login onward. Before the ledger's first open they are kept as
    -- small pending records; afterwards they unlock properties immediately.
    local lastVisitKey
    function T.ObserveVisit()
        local L=T.LiveCatalog; if not L then return end
        local record=L.Observe(); if not record then return end
        local key=(record.zoneId or "?").."|"..record.name
        -- Same place as the last poll: nothing new to record.
        if key==lastVisitKey then return end
        lastVisitKey=key
        if not T.app then L.RecordPending(T.saved,record); return end
        local property,newlyVisited=L.Apply(T.app.state,record)
        if property and newlyVisited then
            T.app.notice=property.name.."を現地確認しました。買収交渉が解放されました"
            T.app:Flash("discovery",property.name.."を現地確認！",2.8); T.app:Save()
        end
    end
    function T.ReportHere()
        local text=T.LiveCatalog and T.LiveCatalog.Describe(T.app and T.app.state) or "現在地を取得できません"
        if CHAT_ROUTER and CHAT_ROUTER.AddSystemMessage then
            for line in text:gmatch("[^\n]+") do CHAT_ROUTER:AddSystemMessage("[交易戦] "..line) end
        elseif d then d(text) end
        return text
    end
    local function chat(text)
        if CHAT_ROUTER and CHAT_ROUTER.AddSystemMessage then
            for line in text:gmatch("[^\n]+") do CHAT_ROUTER:AddSystemMessage("[交易戦] "..line) end
        elseif d then d(text) end
        return text
    end
    SLASH_COMMANDS["/pbtrade"]=function(arg)
        arg=type(arg)=="string" and arg:lower() or ""
        if arg:find("here",1,true) then T.ReportHere()
        elseif arg=="display" then chat(T.ui:DescribeDisplay())
        elseif arg:find("assets",1,true) then chat(T.Assets.Describe())
        else T.Open() end
    end
    local previous=GetFrameTimeSeconds(); local locationCheck=0
    EVENT_MANAGER:RegisterForUpdate(C.addonId,C.ui.updateMs,function()
        local now=GetFrameTimeSeconds(); local dt=math.max(0,now-previous); previous=now; T.ui:Tick(dt)
        locationCheck=locationCheck+dt
        if locationCheck>=2 then
            locationCheck=0
            T.ObserveVisit()
        end
    end)
    local function hide() if T.app then T.app:FlushSave() end; SCENE_MANAGER:Hide(C.scene) end
    EVENT_MANAGER:RegisterForEvent(C.addonId,EVENT_PLAYER_COMBAT_STATE,function(_,inCombat) if inCombat then hide() end end)
    EVENT_MANAGER:RegisterForEvent(C.addonId,EVENT_CONTROLLER_DISCONNECTED,hide)
    EVENT_MANAGER:RegisterForEvent(C.addonId,EVENT_PLAYER_DEACTIVATED,hide)
    EVENT_MANAGER:RegisterForEvent(C.addonId,EVENT_PLAYER_ACTIVATED,function()
        T.HookMenu(); T.ObserveVisit()
    end)
    if EVENT_ZONE_CHANGED then
        EVENT_MANAGER:RegisterForEvent(C.addonId.."LiveCatalog",EVENT_ZONE_CHANGED,function()
            T.ObserveVisit()
        end)
    end
end)
