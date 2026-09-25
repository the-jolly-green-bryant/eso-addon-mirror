------------------------------------------------------------
-- RYTIC RAID CONTROLS v3.0.0 - module-isolated lifecycle
------------------------------------------------------------
RyticTank=RyticTank or {}
local RyticTank=RyticTank
RyticTank.RaidLead=RyticTank.RaidLead or {}
local R=RyticTank.RaidLead
local EM,WM=EVENT_MANAGER,WINDOW_MANAGER
local GetFrameTimeSeconds=GetFrameTimeSeconds
local IsUnitGrouped=IsUnitGrouped
local IsUnitGroupLeader=IsUnitGroupLeader
local GetGroupSize=GetGroupSize
local BeginGroupElection=BeginGroupElection
local PlaySound=PlaySound
local tonumber,tostring=tonumber,tostring
local math_max,math_min,math_floor=math.max,math.min,math.floor
local PULL_EVENT="RyticRaidLeadPull"

local function defaults()
    RyticTank.saved=RyticTank.saved or {}
    RyticTank.saved.raidLead=RyticTank.saved.raidLead or {enabled=true,x=248,y=-58,pullSeconds=5,announce=true,scale=1,unlocked=false}
    return RyticTank.saved.raidLead
end
local function canLead()
    if not IsUnitGrouped("player") then return false end
    local G=RyticTank.GroupFrames
    return (G and G.CanManageAssignments and G.CanManageAssignments()) or IsUnitGroupLeader("player") or GetGroupSize()==1
end
local externalPullCommand=nil
local function playCountdownSound(remain)
    if remain==3 or remain==2 or remain==1 then PlaySound(SOUNDS.DUEL_START)
    elseif remain==0 then PlaySound(SOUNDS.DUEL_WON) end
end
function R.ReadyCheck()
    if defaults().enabled==false then return end
    if not IsUnitGrouped("player") then d("|cFFAA00Rytic: You are not grouped.|r"); return end
    -- ESO allows any grouped member to start a normal Ready Check.
    -- Do not apply Rytic leader/assistant permissions to this native group action.
    if ZO_SendReadyCheck then
        ZO_SendReadyCheck()
    elseif BeginGroupElection and ZO_GROUP_ELECTION_DESCRIPTORS and ZO_GROUP_ELECTION_DESCRIPTORS.READY_CHECK then
        BeginGroupElection(GROUP_ELECTION_TYPE_GENERIC_UNANIMOUS, ZO_GROUP_ELECTION_DESCRIPTORS.READY_CHECK)
    else
        d("|cFFAA00Rytic: Ready Check API is unavailable.|r")
    end
end
function R.CancelPull()
    EM:UnregisterForUpdate(PULL_EVENT); R.pullEnd=nil
    if R.pullText then R.pullText:SetText("") end
end
function R.StartPull(seconds,skipExternal)
    if defaults().enabled==false then return end
    seconds=math_max(3,math_min(60,math_floor(tonumber(seconds) or defaults().pullSeconds or 5)))
    if not canLead() then d("|cFFAA00Rytic: Pull Timer requires group lead or Rytic assistant authority.|r"); return end
    if not skipExternal and externalPullCommand then externalPullCommand(tostring(seconds)); return end
    R.CancelPull(); R.pullEnd=GetFrameTimeSeconds()+seconds; R.lastAnnounced=nil
    EM:RegisterForUpdate(PULL_EVENT,100,function()
        if not R.pullEnd then return end
        local remain=math_max(0,math.ceil(R.pullEnd-GetFrameTimeSeconds()))
        if R.pullText then R.pullText:SetText(remain>0 and ("|c49BFFF"..remain.."|r") or "|c55FF55PULL!|r") end
        if remain~=R.lastAnnounced then
            R.lastAnnounced=remain; if remain<=3 then playCountdownSound(remain) end
            if remain==0 then zo_callLater(function() if R.pullText then R.pullText:SetText("") end end,1200); R.CancelPull() end
        end
    end)
end

local function button(parent,text,x,y,w,fn)
    local b=WM:CreateControl(nil,parent,CT_BUTTON); b:SetDimensions(w or 145,34); b:SetAnchor(TOPLEFT,parent,TOPLEFT,x,y)
    b:SetFont("ZoFontGameBold"); b:SetText(text); b:SetNormalFontColor(1,1,1,1); b:SetMouseOverFontColor(1,1,1,1); b:SetHandler("OnClicked",fn)
    local bg=WM:CreateControl(nil,b,CT_BACKDROP); bg:SetAnchorFill(); bg:SetCenterColor(.035,.34,.62,.96); bg:SetEdgeColor(1,1,1,1); bg:SetDrawLayer(DL_BACKGROUND)
    return b
end

function R.GroupAutoBalance()
    if not canLead() then d("|cFFAA00Rytic: Group balancing requires group lead or Rytic assistant authority.|r"); return end
    if RyticTank.GroupFrames and RyticTank.GroupFrames.AutoBalance then RyticTank.GroupFrames.AutoBalance() end
end
function R.GroupSave()
    if RyticTank.GroupFrames and RyticTank.GroupFrames.SaveProgGroup then RyticTank.GroupFrames.SaveProgGroup() end
end
function R.GroupLoad()
    if RyticTank.GroupFrames and RyticTank.GroupFrames.LoadProgGroup then
        if not RyticTank.GroupFrames.LoadProgGroup() then d("|cFFAA00Rytic: No saved prog group with that name.|r") end
    end
end
function R.GroupPush(name)
    if RyticTank.GroupFrames and RyticTank.GroupFrames.PushOut then
        local ok,err=RyticTank.GroupFrames.PushOut(name)
        if not ok and err then d("|cFFAA00Rytic: "..tostring(err)..".|r") end
    end
end
function R.GroupClear()
    if RyticTank.GroupFrames and RyticTank.GroupFrames.ClearAssignments then RyticTank.GroupFrames.ClearAssignments() end
end


-- Named prog-group manager. Players can belong to different saved prog presets;
-- each preset is independent and can be loaded or prepared in party chat by name.
function R.CreateProgWindow()
    if R.progWindow then return end
    local w=WM:CreateTopLevelWindow("RyticProgGroupWindow"); R.progWindow=w
    w:SetDimensions(520,430); w:SetAnchor(CENTER,GuiRoot,CENTER,0,0); w:SetHidden(true); w:SetMovable(true); w:SetMouseEnabled(true); w:SetClampedToScreen(true); w:SetDrawTier(DT_HIGH)
    local bg=WM:CreateControl(nil,w,CT_BACKDROP); bg:SetAnchorFill(); bg:SetCenterColor(.012,.018,.028,.98); bg:SetEdgeColor(.25,.6,.9,1)
    local title=WM:CreateControl(nil,w,CT_LABEL); title:SetFont("ZoFontWinH2"); title:SetText("RYTIC — PROG GROUPS"); title:SetAnchor(TOPLEFT,w,TOPLEFT,16,10); title:SetDimensions(400,30)
    local close=button(w,"X",470,8,34,function() w:SetHidden(true) end)
    local drag=WM:CreateControl(nil,w,CT_CONTROL); drag:SetDimensions(450,40); drag:SetAnchor(TOPLEFT,w,TOPLEFT,0,0); drag:SetMouseEnabled(true); drag:SetHandler("OnMouseDown",function(_,b) if b==MOUSE_BUTTON_INDEX_LEFT then w:StartMoving() end end); drag:SetHandler("OnMouseUp",function(_,b) if b==MOUSE_BUTTON_INDEX_LEFT then w:StopMovingOrResizing() end end)
    local prompt=WM:CreateControl(nil,w,CT_LABEL); prompt:SetFont("ZoFontGame"); prompt:SetText("Prog group name:"); prompt:SetAnchor(TOPLEFT,w,TOPLEFT,18,55); prompt:SetDimensions(150,24)
    local edit=WM:CreateControlFromVirtual("RyticProgGroupName",w,"ZO_DefaultEditForBackdrop"); R.progEdit=edit; edit:SetDimensions(300,28); edit:SetAnchor(TOPLEFT,w,TOPLEFT,170,52); edit:SetMaxInputChars(40)
    local save=button(w,"SAVE CURRENT",18,92,145,function()
        local name=zo_strtrim(edit:GetText() or ""); if name=="" then d("|cFFAA00Rytic: enter a prog group name.|r"); return end
        if RyticTank.GroupFrames and RyticTank.GroupFrames.SaveProgGroup then RyticTank.GroupFrames.SaveProgGroup(name); d("|c55FF55Rytic: saved prog group "..name..".|r"); R.RefreshProgWindow() end
    end)
    local autoSave=button(w,"AUTO + SAVE",174,92,145,function()
        local name=zo_strtrim(edit:GetText() or ""); if name=="" then d("|cFFAA00Rytic: enter a prog group name.|r"); return end
        if RyticTank.GroupFrames and RyticTank.GroupFrames.AutoBalance then RyticTank.GroupFrames.AutoBalance() end
        if RyticTank.GroupFrames and RyticTank.GroupFrames.SaveProgGroup then RyticTank.GroupFrames.SaveProgGroup(name); d("|c55FF55Rytic: arranged and saved "..name..".|r"); R.RefreshProgWindow() end
    end)
    local note=WM:CreateControl(nil,w,CT_LABEL); note:SetFont("ZoFontGameSmall"); note:SetText("Each name is a separate preset. The same player can be saved in multiple prog groups."); note:SetAnchor(TOPLEFT,w,TOPLEFT,18,135); note:SetDimensions(480,35); note:SetColor(.7,.78,.86,1)
    R.progList=WM:CreateControl(nil,w,CT_CONTROL); R.progList:SetDimensions(485,235); R.progList:SetAnchor(TOPLEFT,w,TOPLEFT,18,175); R.progRows={}
end
function R.RefreshProgWindow()
    if not R.progWindow then return end
    for _,c in ipairs(R.progRows or {}) do c:SetHidden(true) end; R.progRows={}
    local G=RyticTank.GroupFrames; local names=(G and G.ListProgGroups and G.ListProgGroups()) or {}; local y=0
    if #names==0 then local l=WM:CreateControl(nil,R.progList,CT_LABEL); l:SetFont("ZoFontGame"); l:SetText("No saved prog groups yet."); l:SetAnchor(TOPLEFT,R.progList,TOPLEFT,0,5); R.progRows[#R.progRows+1]=l; return end
    for _,name in ipairs(names) do
        local row=WM:CreateControl(nil,R.progList,CT_BACKDROP); row:SetDimensions(485,38); row:SetAnchor(TOPLEFT,R.progList,TOPLEFT,0,y); row:SetCenterColor(.04,.055,.075,.98); row:SetEdgeColor(.18,.22,.28,1)
        local l=WM:CreateControl(nil,row,CT_LABEL); l:SetFont("ZoFontGameBold"); l:SetText(name); l:SetAnchor(LEFT,row,LEFT,8,0); l:SetDimensions(175,36)
        local load=button(row,"LOAD",185,3,82,function() if G and G.LoadProgGroup and G.LoadProgGroup(name) then R.progEdit:SetText(name); d("|c55FF55Rytic: loaded "..name..".|r") end end)
        local push=button(row,"CHAT PUSH",274,3,105,function() R.GroupPush(name) end)
        local del=button(row,"DELETE",386,3,88,function() if G and G.DeleteProgGroup and G.DeleteProgGroup(name) then R.RefreshProgWindow() end end)
        R.progRows[#R.progRows+1]=row; y=y+42
    end
end
function R.ToggleProgWindow() if defaults().enabled==false then return end; R.CreateProgWindow(); R.progWindow:SetHidden(not R.progWindow:IsHidden()); if not R.progWindow:IsHidden() then R.RefreshProgWindow() end end


function R.CreateGroupManager()
    if R.groupManager then return end
    local w=WM:CreateTopLevelWindow("RyticGroupManagerWindow"); R.groupManager=w
    w:SetDimensions(540,520); w:SetAnchor(CENTER,GuiRoot,CENTER,0,0); w:SetHidden(true); w:SetMovable(true); w:SetMouseEnabled(true); w:SetClampedToScreen(true); w:SetDrawTier(DT_HIGH)
    local bg=WM:CreateControl(nil,w,CT_BACKDROP); bg:SetAnchorFill(); bg:SetCenterColor(.012,.018,.028,.98); bg:SetEdgeColor(.25,.6,.9,1)
    local title=WM:CreateControl(nil,w,CT_LABEL); title:SetFont("ZoFontWinH2"); title:SetText("RYTIC — GROUP MANAGER"); title:SetAnchor(TOPLEFT,w,TOPLEFT,16,10); title:SetDimensions(430,30)
    button(w,"X",490,8,34,function() w:SetHidden(true) end)
    local drag=WM:CreateControl(nil,w,CT_CONTROL); drag:SetDimensions(470,40); drag:SetAnchor(TOPLEFT,w,TOPLEFT,0,0); drag:SetMouseEnabled(true); drag:SetHandler("OnMouseDown",function(_,b) if b==MOUSE_BUTTON_INDEX_LEFT then w:StartMoving() end end); drag:SetHandler("OnMouseUp",function(_,b) if b==MOUSE_BUTTON_INDEX_LEFT then w:StopMovingOrResizing() end end)
    local note=WM:CreateControl(nil,w,CT_LABEL); note:SetFont("ZoFontGameSmall"); note:SetText("ESO group leader is the authority. Assistants can manually adjust and PUSH the leader's layout. @Rytic, @Rytic's-WIFEY and @kimmi2510 automatically back one another up when one of them is leader."); note:SetAnchor(TOPLEFT,w,TOPLEFT,18,52); note:SetDimensions(500,54); note:SetColor(.75,.82,.9,1)
    R.groupManagerList=WM:CreateControl(nil,w,CT_CONTROL); R.groupManagerList:SetDimensions(500,390); R.groupManagerList:SetAnchor(TOPLEFT,w,TOPLEFT,18,112); R.groupManagerRows={}
end

function R.RefreshGroupManager()
    if not R.groupManager then return end
    for _,c in ipairs(R.groupManagerRows or {}) do c:SetHidden(true) end; R.groupManagerRows={}
    local G=RyticTank.GroupFrames; local size=GetGroupSize and GetGroupSize() or 0; local y=0
    for i=1,size do
        local tag=GetGroupUnitTagByIndex(i)
        if tag then
            local account=(GetUnitDisplayName and GetUnitDisplayName(tag)) or GetUnitName(tag) or tag
            local row=WM:CreateControl(nil,R.groupManagerList,CT_BACKDROP); row:SetDimensions(500,34); row:SetAnchor(TOPLEFT,R.groupManagerList,TOPLEFT,0,y); row:SetCenterColor(.04,.055,.075,.98); row:SetEdgeColor(.18,.22,.28,1)
            local l=WM:CreateControl(nil,row,CT_LABEL); l:SetFont("ZoFontGameBold"); l:SetText(account); l:SetAnchor(LEFT,row,LEFT,8,0); l:SetDimensions(260,32)
            local isLead=IsUnitGroupLeader and IsUnitGroupLeader(tag); local isAssist=G and G.IsAccountAssistant and G.IsAccountAssistant(account)
            local status=WM:CreateControl(nil,row,CT_LABEL); status:SetFont("ZoFontGame"); status:SetAnchor(LEFT,row,LEFT,270,0); status:SetDimensions(100,32); status:SetText(isLead and "|c55FF55LEADER|r" or (isAssist and "|c49BFFFASSIST|r" or "MEMBER"))
            if not isLead then
                local b=button(row,isAssist and "REMOVE" or "ASSIST",390,2,95,function()
                    if G and G.ToggleAssistant then
                        local ok,err=G.ToggleAssistant(account)
                        if not ok and err then d("|cFF4444Rytic: "..tostring(err)..".|r") end
                        R.RefreshGroupManager()
                    end
                end)
                b:SetEnabled(IsUnitGroupLeader and IsUnitGroupLeader("player"))
            end
            R.groupManagerRows[#R.groupManagerRows+1]=row; y=y+38
        end
    end
end

function R.ToggleGroupManager()
    if defaults().enabled==false then return end
    R.CreateGroupManager(); R.groupManager:SetHidden(not R.groupManager:IsHidden())
    if not R.groupManager:IsHidden() then R.RefreshGroupManager() end
end

local function showRaidControlsMenu(anchor)
    ClearMenu()
    AddMenuItem("READY CHECK",R.ReadyCheck)
    AddMenuItem("PULL "..tostring(defaults().pullSeconds or 5).."s",function() R.StartPull() end)
    AddMenuItem("DD POSITIONS",function()
        if RyticTank.Positions and RyticTank.Positions.ToggleBoard then RyticTank.Positions.ToggleBoard() else d("|cFFAA00Rytic: DD Positions is still loading. Try again after /reloadui.|r") end
    end)
    AddMenuItem("GROUP: Auto DPS Arrange",function()
        if RyticTank.GroupFrames and RyticTank.GroupFrames.AutoBalance then RyticTank.GroupFrames.AutoBalance() end
    end)
    AddMenuItem("PROG GROUPS...",R.ToggleProgWindow)
    AddMenuItem("GROUP MANAGER / ASSISTANTS...",R.ToggleGroupManager)
    AddMenuItem("GROUP: Clear Assignments",R.GroupClear)
    local P=RyticTank.Positions
    if P and P.GetZoneData then
        local zd=P.GetZoneData()
        if zd and zd.order then
            for _,mech in ipairs(zd.order) do
                AddMenuItem("DD: "..tostring(mech),function()
                    local msg=P.Assign(mech)
                    if msg then d("|c55FF55Rytic: "..tostring(mech).." positions assigned by shared DPS.|r") end
                end)
            end
            AddMenuItem("DD: Push Current Positions",function() P.Push() end)
        else
            AddMenuItem("DD: No positions for current zone",function() end)
        end
    end
    ShowMenu(anchor)
end

function R.Create()
    if R.root then return end
    local sv=defaults(); local root=WM:CreateTopLevelWindow("RyticRaidLeadRoot"); R.root=root
    local function attachFragment()
        if R.hudFragment or not SCENE_MANAGER or not HUD_SCENE or not HUD_UI_SCENE then return end
        local fragment=ZO_HUDFadeSceneFragment and ZO_HUDFadeSceneFragment:New(root,nil,0) or (ZO_SimpleSceneFragment and ZO_SimpleSceneFragment:New(root))
        if fragment then
            HUD_SCENE:AddFragment(fragment)
            HUD_UI_SCENE:AddFragment(fragment)
            R.hudFragment=fragment
            fragment:RegisterCallback("StateChange",function(_,newState)
                if newState==SCENE_FRAGMENT_SHOWN then
                    root:SetHidden(defaults().enabled==false)
                elseif newState==SCENE_FRAGMENT_HIDDEN then
                    root:SetHidden(true)
                end
            end)
        end
    end
    root:SetDimensions(145,34)
    -- Use one coordinate system for both axes.  Older builds stored Y as a
    -- BOTTOMLEFT offset (normally negative), which can leave the movable root
    -- clamped against the bottom edge.  Convert that legacy value once to a
    -- normal TOPLEFT screen position, then save X/Y as GetLeft()/GetTop().
    local startX=tonumber(sv.x) or 248
    local startY=tonumber(sv.y)
    if not sv.positionUsesTopLeft then
        local guiHeight=(GuiRoot.GetHeight and GuiRoot:GetHeight()) or 1080
        startY=guiHeight+(startY or -58)-34
        sv.y=startY
        sv.positionUsesTopLeft=true
    elseif not startY then
        startY=200
    end
    root:SetAnchor(TOPLEFT,GuiRoot,TOPLEFT,startX,startY)
    root:SetScale(sv.scale or 1); root:SetMovable(true); root:SetMouseEnabled(true); root:SetClampedToScreen(true)
    root:SetHandler("OnMouseDown",function(self,mouseButton) if mouseButton==MOUSE_BUTTON_INDEX_LEFT and defaults().unlocked then self:StartMoving() end end)
    local function saveRootPosition(self)
        local current=defaults()
        current.x=self:GetLeft() or current.x
        current.y=self:GetTop() or current.y
        current.positionUsesTopLeft=true
    end
    root:SetHandler("OnMouseUp",function(self,mouseButton)
        if mouseButton==MOUSE_BUTTON_INDEX_LEFT and defaults().unlocked then
            self:StopMovingOrResizing()
            saveRootPosition(self)
        end
    end)
    root:SetHandler("OnMoveStop",saveRootPosition)
    R.menu=button(root,"RAID CONTROLS",0,0,145,function(btn) showRaidControlsMenu(btn) end)
    R.readyButton=button(root,"READY CHECK",0,0,110,function() R.ReadyCheck() end)
    R.readyButton:ClearAnchors()
    R.readyButton:SetAnchor(LEFT,R.menu,RIGHT,10,0)
    R.pullButton=button(root,"PULL "..tostring(sv.pullSeconds or 5).."s",0,0,110,function() R.StartPull() end)
    R.pullButton:ClearAnchors()
    R.pullButton:SetAnchor(LEFT,R.readyButton,RIGHT,10,0)

    -- Dedicated drag overlay. The RAID CONTROLS button is a child control and
    -- otherwise consumes the mouse before the root sees a left-drag.
    local move=WM:CreateControl(nil,root,CT_BACKDROP); R.moveHandle=move
    move:SetAnchorFill(root)
    move:SetCenterColor(.08,.08,.08,.30)
    move:SetEdgeColor(1,1,1,1)
    move:SetDrawTier(DT_HIGH)
    move:SetDrawLayer(DL_OVERLAY)
    move:SetMouseEnabled(false)
    move:SetHidden(true)
    local moveText=WM:CreateControl(nil,move,CT_LABEL); R.moveText=moveText
    moveText:SetAnchorFill(); moveText:SetFont("ZoFontGameBold")
    moveText:SetHorizontalAlignment(TEXT_ALIGN_CENTER); moveText:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    moveText:SetText("DRAG RAID CONTROLS")
    move:SetHandler("OnMouseDown",function(_,mouseButton)
        if mouseButton==MOUSE_BUTTON_INDEX_LEFT and defaults().unlocked then root:StartMoving() end
    end)
    move:SetHandler("OnMouseUp",function(_,mouseButton)
        if mouseButton==MOUSE_BUTTON_INDEX_LEFT and defaults().unlocked then
            root:StopMovingOrResizing()
            saveRootPosition(root)
        end
    end)

    R.pullText=WM:CreateControl(nil,root,CT_LABEL); R.pullText:SetFont("ZoFontWinH1"); R.pullText:SetAnchor(TOP,root,BOTTOM,0,6); R.pullText:SetDimensions(300,55); R.pullText:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    root:SetHidden(not sv.enabled)
    attachFragment()
    if not R.hudFragment then zo_callLater(attachFragment,500) end
    R.SetUnlocked(sv.unlocked==true)
end
function R.IsEnabled()
    return defaults().enabled~=false
end

function R.SetUnlocked(unlocked)
    local sv=defaults(); sv.unlocked=unlocked and true or false
    if R.root then R.root:SetMovable(true) end
    if R.moveHandle then
        R.moveHandle:SetHidden(not sv.unlocked)
        R.moveHandle:SetMouseEnabled(sv.unlocked)
    end
    if R.menu then R.menu:SetText("RAID CONTROLS") end
end

function R.SetScale(scale)
    local sv=defaults()
    sv.scale=math_max(.5,math_min(2,tonumber(scale) or 1))
    if R.root then
        R.root:SetScale(sv.scale)
        R.root:ClearAnchors()
        R.root:SetAnchor(TOPLEFT,GuiRoot,TOPLEFT,sv.x or 248,sv.y or 200)
    end
end

function R.SetEnabled(enabled)
    local sv=defaults()
    sv.enabled=enabled and true or false

    if not sv.enabled then
        -- True module kill switch: stop the only repeating runtime owned here,
        -- clear countdown state, close RaidLead-owned windows, and relinquish
        -- the /pull hook to the command that existed before Rytic loaded.
        R.CancelPull()
        if R.root then R.root:SetHidden(true) end
        if R.progWindow then R.progWindow:SetHidden(true) end
        if R.groupManager then R.groupManager:SetHidden(true) end
        if RyticTank.Positions and RyticTank.Positions.SetEnabled then
            RyticTank.Positions.SetEnabled(false)
        elseif RyticTank.Positions and RyticTank.Positions.window then
            RyticTank.Positions.window:SetHidden(true)
        end
        if externalPullCommand then
            SLASH_COMMANDS["/pull"]=externalPullCommand
        elseif SLASH_COMMANDS["/pull"]==R.PullSlash then
            SLASH_COMMANDS["/pull"]=nil
        end
        return
    end

    if RyticTank.Positions and RyticTank.Positions.SetEnabled then RyticTank.Positions.SetEnabled(true) end
    if R.root then R.root:SetHidden(false) end
    SLASH_COMMANDS["/pull"]=R.PullSlash
end
function R.Toggle() R.SetEnabled(not defaults().enabled) end
function R.PullSlash(arg)
    if arg=="cancel" or arg=="stop" then R.CancelPull(); return end
    local seconds=math_max(3,math_min(60,math_floor(tonumber(arg) or defaults().pullSeconds or 5)))
    if externalPullCommand then externalPullCommand(tostring(seconds)) else R.StartPull(seconds,true) end
end
function R.Initialize()
    local existing=SLASH_COMMANDS["/pull"]
    if existing and existing~=R.PullSlash then externalPullCommand=existing end
    R.Create()
    SLASH_COMMANDS["/ryticready"]=R.ReadyCheck
    SLASH_COMMANDS["/ryticraid"]=R.Toggle
    R.SetEnabled(defaults().enabled~=false)
end
EM:RegisterForEvent("RyticRaidLeadBootstrap",EVENT_ADD_ON_LOADED,function(_,addonName)
    if addonName~="RyticTankTools" then return end
    EM:UnregisterForEvent("RyticRaidLeadBootstrap",EVENT_ADD_ON_LOADED); R.Initialize()
end)
