local _n="DailyMail" local db local _busy=false
local function RMB()
    if not DailyMailIcon or not db or db.mailMinimized then return end
    if SCENE_MANAGER:IsShowing("mailInbox") or SCENE_MANAGER:IsShowing("mailManagerGamepad") then DailyMailIcon:SetHidden(true) return end
    local c=GetNumUnreadMail() or 0
    local t=db.mailThreshold or 20
    if c>=t then 
        DailyMailIcon:SetHidden(false)
        if DailyMailIconLabel then DailyMailIconLabel:SetText("UNREAD MAILS: "..c) end
        SCENE_MANAGER:SetInUIMode(true) 
    else 
        DailyMailIcon:SetHidden(true) 
    end
end

local function Valid(id)
    local _,_,s,c=GetMailFlags(id) return s==true and c==false
end

local function StartPMA()
    if _busy then return end
    local n=GetNumMailItems()
    if n==0 then _busy=false return end
    
    local foundTask = false
    _busy=true
    
    for i=1,n do
        local id=GetMailIdByIndex(i)
        if id and Valid(id) then
            foundTask = true
            local num,mon=GetMailAttachmentInfo(id)
            if num>0 or mon>0 then 
                ZO_MailInboxShared_TakeAll(id)
            else
                DeleteMail(id,false)
            end
            -- Zwiększone opóźnienie do 600ms dla stabilności UI
            zo_callLater(function() _busy=false StartPMA() end,600) 
            return
        end
    end
    
    -- Jeśli pętla przeszła i nic nie znalazła, kończymy, żeby nie spamować
    _busy=false
end

local function OnLoad(_,n)
    if n~=_n then return end
    db=ZO_SavedVars:NewAccountWide("DailyMail_Data",1,nil,{mailMinimized=false,mailThreshold=20})
    DailyMailIconBtn:SetHandler("OnClicked",function()
        SCENE_MANAGER:SetInUIMode(false) 
        SCENE_MANAGER:Toggle("mailInbox")
        zo_callLater(function() DailyMailIcon:SetHidden(true) end,200)
        zo_callLater(StartPMA,1500)
    end)
    DailyMailCancelBtn:SetHandler("OnClicked",function() 
        db.mailMinimized=true 
        DailyMailIcon:SetHidden(true) 
        SCENE_MANAGER:SetInUIMode(false) 
    end)
end

-- Rejestracja zdarzeń pozostaje bez zmian
EVENT_MANAGER:RegisterForEvent(_n,EVENT_MAIL_OPEN_MAILBOX,function() zo_callLater(StartPMA,2000) end)
SLASH_COMMANDS["/dmset"]=function(a) local v=tonumber(a) if v and db then db.mailThreshold=v RMB() end end
EVENT_MANAGER:RegisterForEvent(_n,EVENT_MAIL_NUM_UNREAD_CHANGED,RMB)
EVENT_MANAGER:RegisterForEvent(_n,EVENT_PLAYER_ACTIVATED,function() if db then db.mailMinimized=false end zo_callLater(RMB,4000) end)
EVENT_MANAGER:RegisterForEvent(_n,EVENT_ADD_ON_LOADED,OnLoad)