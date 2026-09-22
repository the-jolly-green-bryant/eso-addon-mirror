------------------------------------------------------------
-- RYTIC RAID LEAD v0.2 - local-reference optimization
-- Ready Check + Pull Timer buttons for RyticTankTools.
------------------------------------------------------------
RyticTank = RyticTank or {}
local RyticTank=RyticTank
RyticTank.RaidLead = RyticTank.RaidLead or {}
local R=RyticTank.RaidLead
local EM,WM=EVENT_MANAGER,WINDOW_MANAGER

-- Cache API/standard-library references used by ready-check and pull-timer paths.
local GetFrameTimeSeconds=GetFrameTimeSeconds
local IsUnitGrouped=IsUnitGrouped
local IsUnitGroupLeader=IsUnitGroupLeader
local GetGroupSize=GetGroupSize
local BeginGroupElection=BeginGroupElection
local PlaySound=PlaySound
local tonumber=tonumber
local tostring=tostring
local math_max=math.max
local math_min=math.min
local math_floor=math.floor
local PULL_EVENT="RyticRaidLeadPull"

local function defaults()
    RyticTank.saved=RyticTank.saved or {}
    RyticTank.saved.raidLead=RyticTank.saved.raidLead or {
        enabled=true,x=248,y=-58,pullSeconds=5,announce=true,scale=1.0,unlocked=false
    }
    return RyticTank.saved.raidLead
end

local function canLead()
    return IsUnitGrouped("player") and (IsUnitGroupLeader("player") or GetGroupSize()==1)
end

local externalPullCommand=nil

local function playCountdownSound(remain)
    if remain==3 or remain==2 or remain==1 then
        PlaySound(SOUNDS.DUEL_START)
    elseif remain==0 then
        PlaySound(SOUNDS.DUEL_WON)
    end
end

function R.ReadyCheck()
    if not IsUnitGrouped("player") then d("|cFFAA00Rytic: You are not grouped.|r"); return end
    if not IsUnitGroupLeader("player") then d("|cFFAA00Rytic: Ready Check button is for the group leader.|r"); return end

    -- Prefer ESO's own ready-check helper so Rytic follows the same native
    -- election path used by the base UI and by addons observing ready checks.
    if ZO_SendReadyCheck then
        ZO_SendReadyCheck()
    else
        -- Compatibility fallback for API revisions where the helper is unavailable.
        BeginGroupElection(2,"Ready Check")
    end
end

function R.CancelPull()
    EM:UnregisterForUpdate(PULL_EVENT)
    R.pullEnd=nil
    if R.pullText then R.pullText:SetText("") end
end

function R.StartPull(seconds, skipExternal)
    seconds=tonumber(seconds) or defaults().pullSeconds or 5
    seconds=math_max(3,math_min(60,math_floor(seconds)))

    if not IsUnitGrouped("player") or not IsUnitGroupLeader("player") then
        d("|cFFAA00Rytic: Pull Timer requires group lead.|r"); return
    end

    -- If Hodor Reflexes (or another addon) already owns /pull, use its
    -- countdown first. Hodor's pull module provides the synchronized
    -- visual/audio notification for compatible group members.
    if not skipExternal and externalPullCommand then
        externalPullCommand(tostring(seconds))
        return
    end

    -- Standalone fallback: local Rytic visual/audio countdown.
    R.CancelPull()
    R.pullEnd=GetFrameTimeSeconds()+seconds
    R.lastAnnounced=nil

    EM:RegisterForUpdate(PULL_EVENT,100,function()
        if not R.pullEnd then return end
        local remain=math_max(0,math.ceil(R.pullEnd-GetFrameTimeSeconds()))

        if R.pullText then
            R.pullText:SetText(remain>0 and ("|c49BFFF"..remain.."|r") or "|c55FF55PULL!|r")
        end

        if remain~=R.lastAnnounced then
            R.lastAnnounced=remain
            if remain<=3 then playCountdownSound(remain) end
            if remain==0 then
                zo_callLater(function()
                    if R.pullText then R.pullText:SetText("") end
                end,1200)
                EM:UnregisterForUpdate(PULL_EVENT)
                R.pullEnd=nil
            end
        end
    end)
end

local function button(parent,text,x,fn)
    local b=WM:CreateControl(nil,parent,CT_BUTTON)
    b:SetDimensions(145,38); b:SetAnchor(TOPLEFT,parent,TOPLEFT,x,0)
    b:SetFont("ZoFontGameBold"); b:SetText(text)
    b:SetNormalFontColor(1,1,1,1); b:SetMouseOverFontColor(1,1,1,1)
    b:SetHandler("OnClicked",fn)
    local bg=WM:CreateControl(nil,b,CT_BACKDROP); bg:SetAnchorFill()
    bg:SetCenterColor(.035,.34,.62,.96); bg:SetEdgeColor(1,1,1,1)
    bg:SetDrawLayer(DL_BACKGROUND)
    return b
end

function R.Create()
    if R.root then return end
    local sv=defaults()
    local root=WM:CreateTopLevelWindow("RyticRaidLeadRoot"); R.root=root
    -- ESOUI HUD fragment: automatically hide this HUD when menus open.
    local hudFragment=ZO_HUDFadeSceneFragment:New(root,nil,0)
    HUD_SCENE:AddFragment(hudFragment)
    HUD_UI_SCENE:AddFragment(hudFragment)
    R.hudFragment=hudFragment
    root:SetDimensions(310,82); root:SetAnchor(BOTTOMLEFT,GuiRoot,BOTTOMLEFT,sv.x,sv.y)
    root:SetScale(sv.scale or 1.0)
    root:SetMovable(true); root:SetMouseEnabled(true); root:SetClampedToScreen(true)
    root:SetHandler("OnMouseDown",function(self,button)
        if button==MOUSE_BUTTON_INDEX_LEFT and defaults().unlocked==true then
            self:StartMoving()
        end
    end)
    root:SetHandler("OnMouseUp",function(self,button)
        if button==MOUSE_BUTTON_INDEX_LEFT and defaults().unlocked==true then
            self:StopMovingOrResizing()
            local _,_,_,x,y=self:GetAnchor(0)
            sv.x=x or 248; sv.y=y or -58
        end
    end)
    root:SetHandler("OnMoveStop",function(self)
        local _,_,_,x,y=self:GetAnchor(0); sv.x=x or 248; sv.y=y or -58
    end)

    R.ready=button(root,"READY CHECK",0,R.ReadyCheck)
    R.pull=button(root,"PULL "..tostring(sv.pullSeconds or 5).."s",155,function() R.StartPull() end)

    local function dragStart(control,button)
        if button==MOUSE_BUTTON_INDEX_LEFT and defaults().unlocked==true then
            root:StartMoving()
        end
    end
    local function dragStop(control,button,upInside)
        if button==MOUSE_BUTTON_INDEX_LEFT and defaults().unlocked==true then
            root:StopMovingOrResizing()
            local _,_,_,x,y=root:GetAnchor(0)
            sv.x=x or 248; sv.y=y or -58
            return
        end
        -- Only activate buttons while locked. This prevents accidentally firing
        -- Ready Check / Pull while positioning the panel.
        if defaults().unlocked~=true and upInside then
            if control==R.ready then R.ReadyCheck()
            elseif control==R.pull then R.StartPull() end
        end
    end
    -- Replace the helper's click handlers with drag-aware handlers.
    R.ready:SetHandler("OnClicked",nil)
    R.pull:SetHandler("OnClicked",nil)
    R.ready:SetHandler("OnMouseDown",dragStart)
    R.pull:SetHandler("OnMouseDown",dragStart)
    R.ready:SetHandler("OnMouseUp",dragStop)
    R.pull:SetHandler("OnMouseUp",dragStop)
    R.pullText=WM:CreateControl(nil,root,CT_LABEL); R.pullText:SetFont("ZoFontWinH1")
    R.pullText:SetAnchor(TOP,root,BOTTOM,0,6); R.pullText:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    R.pullText:SetDimensions(300,55)

    root:SetHidden(not sv.enabled)
end

function R.SetUnlocked(unlocked)
    local sv=defaults(); sv.unlocked=unlocked and true or false
    if R.root then R.root:SetMovable(true) end
    if R.ready then R.ready:SetText(sv.unlocked and "READY CHECK  [MOVE]" or "READY CHECK") end
end

function R.SetScale(scale)
    local sv=defaults(); sv.scale=tonumber(scale) or 1.0
    if R.root then R.root:SetScale(sv.scale) end
end

function R.SetEnabled(enabled)
    local sv=defaults(); sv.enabled=enabled and true or false
    if R.root then R.root:SetHidden(not sv.enabled) end
end

function R.Toggle()
    local sv=defaults(); R.SetEnabled(not sv.enabled)
end

function R.PullSlash(arg)
    if arg=="cancel" or arg=="stop" then
        R.CancelPull()
        return
    end

    local seconds=tonumber(arg) or defaults().pullSeconds or 5
    seconds=math_max(3,math_min(60,math_floor(seconds)))

    if externalPullCommand then
        externalPullCommand(tostring(seconds))
    else
        R.StartPull(seconds,true)
    end
end

function R.Initialize()
    -- Preserve an existing /pull handler (for example Hodor Reflexes)
    -- before Rytic registers its own wrapper.
    local existing=SLASH_COMMANDS["/pull"]
    if existing and existing~=R.PullSlash then
        externalPullCommand=existing
    end

    R.Create()
    SLASH_COMMANDS["/ryticready"]=R.ReadyCheck
    SLASH_COMMANDS["/pull"]=R.PullSlash
    SLASH_COMMANDS["/ryticraid"]=R.Toggle
end


EM:RegisterForEvent("RyticRaidLeadBootstrap",EVENT_ADD_ON_LOADED,function(_,addonName)
    if addonName~="RyticTankTools" then return end
    EM:UnregisterForEvent("RyticRaidLeadBootstrap",EVENT_ADD_ON_LOADED)
    R.Initialize()
end)
