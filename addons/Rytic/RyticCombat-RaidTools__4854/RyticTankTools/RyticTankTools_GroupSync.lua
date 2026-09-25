------------------------------------------------------------
-- RYTIC COMBAT & RAID TOOLS GROUP SYNC v3.0.0
-- LibGroupBroadcast transport for raid Team A/B assignments.
-- Permanent registered protocol: RyticRaidSync / ID 180.
------------------------------------------------------------
RyticTank=RyticTank or {}
local RyticTank=RyticTank
RyticTank.GroupSync=RyticTank.GroupSync or {}
local Sync=RyticTank.GroupSync
local EM,WM=EVENT_MANAGER,WINDOW_MANAGER

local PROTOCOL_ID=180
local PROTOCOL_NAME="RyticRaidSync"
local HANDLER_NAME="RyticTankTools"
local MAX_RAID=24
local MAX_NAME=64
local TRUSTED={ ["@rytic"]=true,["@rytic's-wifey"]=true,["@kimmi2510"]=true,["@vonziklar"]=true }

local function norm(v) return zo_strformat("<<z:1>>",tostring(v or "")):lower():gsub("%s+","") end
local function account(tag) return (GetUnitDisplayName and GetUnitDisplayName(tag)) or "" end
local function leaderTag()
    local n=GetGroupSize and GetGroupSize() or 0
    for i=1,n do local t=GetGroupUnitTagByIndex(i); if t and IsUnitGroupLeader and IsUnitGroupLeader(t) then return t end end
    if IsUnitGroupLeader and IsUnitGroupLeader("player") then return "player" end
end
local function isSenderAllowed(tag)
    if not tag or not DoesUnitExist(tag) then return false end
    if IsUnitGroupLeader and IsUnitGroupLeader(tag) then return true end
    local a=norm(account(tag))
    if Sync.sessionAssistantsInitialized then
        -- Once crown has published the session authority list, it is authoritative.
        -- Anyone crown removed is denied until crown restores/pushes them again.
        return Sync.sessionAssistants and Sync.sessionAssistants[a] == true
    end

    -- No crown authority list has been published yet: an RCRT sender defaults to
    -- ASSIST while grouped. Reaching this function through protocols 180/181/182
    -- already proves the sender is participating in RCRT transport.
    if IsUnitGrouped and IsUnitGrouped("player") then
        return true
    end

    local lt=leaderTag(); local la=lt and norm(account(lt)) or ""
    return TRUSTED[la] and TRUSTED[a] and a~=la
end

local function popup(sender)
    if not Sync.notice then
        local w=WM:CreateTopLevelWindow("RyticRaidSyncNotice"); Sync.notice=w
        w:SetDimensions(620,105); w:SetAnchor(TOP,GuiRoot,TOP,0,150); w:SetDrawTier(DT_HIGH); w:SetDrawLayer(DL_OVERLAY); w:SetHidden(true)
        local bg=WM:CreateControl(nil,w,CT_BACKDROP); bg:SetAnchorFill(); bg:SetCenterColor(.02,.08,.14,.96); bg:SetEdgeColor(.2,.65,1,1); bg:SetEdgeTexture("",1,1,3,0)
        local title=WM:CreateControl(nil,w,CT_LABEL); title:SetFont("ZoFontWinH2"); title:SetAnchor(TOP,w,TOP,0,12); title:SetDimensions(590,34); title:SetHorizontalAlignment(TEXT_ALIGN_CENTER); title:SetText("RYTIC RAID ASSIGNMENTS UPDATED")
        local sub=WM:CreateControl(nil,w,CT_LABEL); Sync.noticeSub=sub; sub:SetFont("ZoFontGameBold"); sub:SetAnchor(TOP,w,TOP,0,53); sub:SetDimensions(590,32); sub:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    end
    Sync.noticeSub:SetText("Pushed by "..tostring(sender or "raid lead").." — CHECK TEAM / POSITION")
    Sync.notice:SetHidden(false)
    if PlaySound and SOUNDS then PlaySound(SOUNDS.READY_CHECK or SOUNDS.DUEL_START) end
    Sync.noticeGeneration=(Sync.noticeGeneration or 0)+1
    local generation=Sync.noticeGeneration
    zo_callLater(function()
        if Sync.notice and Sync.noticeGeneration==generation then Sync.notice:SetHidden(true) end
    end,2000)
end

local function raidWarningPopup(message)
    -- Local presentation preference only. Protocol 182 remains active so this
    -- client can still receive RCRT traffic and other players are unaffected.
    RyticTank.saved=RyticTank.saved or {}
    if RyticTank.saved.raidWarningsEnabled==false then return end
    message=tostring(message or "")
    if message=="" then return end
    if not Sync.rwNotice then
        local w=WM:CreateTopLevelWindow("RyticRaidWarningNotice"); Sync.rwNotice=w
        w:SetDimensions(720,92); w:SetAnchor(TOP,GuiRoot,TOP,0,145); w:SetDrawTier(DT_HIGH); w:SetDrawLayer(DL_OVERLAY); w:SetHidden(true)
        local bg=WM:CreateControl(nil,w,CT_BACKDROP); bg:SetAnchorFill(); bg:SetCenterColor(.02,.08,.14,.96); bg:SetEdgeColor(.2,.65,1,1); bg:SetEdgeTexture("",1,1,3,0)
        local label=WM:CreateControl(nil,w,CT_LABEL); Sync.rwLabel=label
        label:SetFont("ZoFontWinH2"); label:SetAnchorFill(); label:SetHorizontalAlignment(TEXT_ALIGN_CENTER); label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    end
    Sync.rwLabel:SetText(message)
    Sync.rwNotice:SetHidden(false)
    if PlaySound and SOUNDS then PlaySound(SOUNDS.READY_CHECK or SOUNDS.DUEL_START) end
    Sync.rwGeneration=(Sync.rwGeneration or 0)+1
    local generation=Sync.rwGeneration
    zo_callLater(function()
        if Sync.rwNotice and Sync.rwGeneration==generation then Sync.rwNotice:SetHidden(true) end
    end,2000)
end

local function setSessionAssistants(list)
    Sync.sessionAssistants={}
    Sync.sessionAssistantsInitialized=true
    for _,a in ipairs(list or {}) do Sync.sessionAssistants[norm(a)]=true end
    if RyticTank.GroupFrames and RyticTank.GroupFrames.SetSessionAssistants then
        RyticTank.GroupFrames.SetSessionAssistants(list or {})
    end
end

local function assignmentsMatchCurrent(incoming)
    local G=RyticTank.GroupFrames
    if not G or not G.ExportSyncState then return false end
    local current=G.ExportSyncState()
    local function signature(rows)
        local out={}
        for _,row in ipairs(rows or {}) do
            out[#out+1]=norm(row.account)..":"..tostring(tonumber(row.team) or 0)..":"..(row.locked and "1" or "0")
        end
        table.sort(out)
        return table.concat(out,";")
    end
    return signature(current)==signature(incoming)
end

local function refreshGroupManagerIfOpen()
    local function redraw()
        local RL=RyticTank.RaidLead
        -- If the Group Manager has been created, rebuild its rows even if ESO's
        -- scene/fragment state temporarily reports the window hidden. This keeps
        -- the next visible frame current without requiring close/reopen.
        if RL and RL.groupManager and RL.RefreshGroupManager then
            RL.RefreshGroupManager()
        end
    end
    redraw()
    if zo_callLater then
        zo_callLater(redraw,50)
        zo_callLater(redraw,200)
    end
end

local function receive(unitTag,data)
    if not isSenderAllowed(unitTag) then
        d("|cFFAA00Rytic: ignored raid assignment push from unauthorized sender.|r")
        return
    end
    local rev=tonumber(data.revision) or 0
    if Sync.lastRevision and rev<Sync.lastRevision then return end
    Sync.lastRevision=rev
    local assignmentChanged=not assignmentsMatchCurrent(data.assignments or {})
    if IsUnitGroupLeader and IsUnitGroupLeader(unitTag) then
        setSessionAssistants(data.assistants)
    end
    local who=account(unitTag)
    d("|c88CCFFRytic SYNC DEBUG: sender="..tostring(who).." | protocol=180|r")

    -- A LibGroupBroadcast sender can receive its own packet. The sender already
    -- owns this exact local state, so never re-apply its own broadcast. This
    -- keeps the useful RECEIVED debug line without letting self-receive cause
    -- UI refreshes or any path back into Push().
    local selfAccount=account("player")
    local isSelf=(norm(who)~="" and norm(who)==norm(selfAccount))
    if not isSelf and RyticTank.GroupFrames and RyticTank.GroupFrames.ApplySyncState then
        Sync.applyingRemote=true
        RyticTank.GroupFrames.ApplySyncState(data.assignments or {})
        Sync.applyingRemote=false
    end
    -- Final operation for an incoming authority packet: redraw manager rows from
    -- the now-applied session assistant state. This is UI-only; no RW is sent.
    refreshGroupManagerIfOpen()
    if assignmentChanged then popup(who) end
    d("|c55FF55Rytic: raid assignments received from "..tostring(who).." (rev "..tostring(rev)..")"..(isSelf and " [self-check]." or ".").."|r")
end

local function initProtocol()
    local LGB=LibGroupBroadcast
    if not LGB then d("|cFF4444Rytic: LibGroupBroadcast is required for raid sync.|r"); return false end
    local ok,err=pcall(function()
        local h=LGB:RegisterHandler(HANDLER_NAME,"RyticRaid")
        if not h then error("handler registration failed") end
        h:SetDisplayName("Rytic Raid Sync")
        h:SetDescription("Shares RyticTankTools raid assignments and team titles with grouped addon users.")
        local row=LGB.CreateTableField("assignments",{
            LGB.CreateStringField("account",{maxLength=MAX_NAME}),
            LGB.CreateNumericField("team",{minValue=1,maxValue=2}),
            LGB.CreateFlagField("locked"),
        })
        local assistant=LGB.CreateStringField("assistants",{maxLength=MAX_NAME})
        local p=h:DeclareProtocol(180,"RyticRaidSync")
        p:AddField(LGB.CreateNumericField("revision",{minValue=0,maxValue=65535}))
        p:AddField(LGB.CreateArrayField(row,{maxLength=MAX_RAID}))
        p:AddField(LGB.CreateArrayField(assistant,{maxLength=MAX_RAID}))
        p:OnData(receive)
        if not p:Finalize({isRelevantInCombat=false,replaceQueuedMessages=true}) then error("protocol 180 finalize failed") end
        Sync.protocol=p

        local names=h:DeclareProtocol(181,"RyticRaidTeamNames")
        names:AddField(LGB.CreateNumericField("revision",{minValue=0,maxValue=65535}))
        names:AddField(LGB.CreateStringField("teamNameA",{maxLength=18}))
        names:AddField(LGB.CreateStringField("teamNameB",{maxLength=18}))
        names:OnData(function(unitTag,data)
            local who=account(unitTag)
            d("|c88CCFFRytic NAME DEBUG: sender="..tostring(who).." | teamNameA="..tostring(data.teamNameA).." | teamNameB="..tostring(data.teamNameB).."|r")
            if not isSenderAllowed(unitTag) then return end
            local isSelf=(norm(who)~="" and norm(who)==norm(account("player")))
            if not isSelf and RyticTank.GroupFrames and RyticTank.GroupFrames.ExportSyncState and RyticTank.GroupFrames.ApplySyncState then
                local currentAssignments=RyticTank.GroupFrames.ExportSyncState()
                Sync.applyingRemote=true
                RyticTank.GroupFrames.ApplySyncState(currentAssignments or {},{data.teamNameA,data.teamNameB})
                Sync.applyingRemote=false
            end
        end)
        if not names:Finalize({isRelevantInCombat=false,replaceQueuedMessages=true}) then error("protocol 181 finalize failed") end
        Sync.nameProtocol=names

        -- Custom RCRT raid warning transport. Kept separate from assignment
        -- protocols so /rw never mutates team/mechanic state.
        local rw=h:DeclareProtocol(182,"RyticRaidWarning")
        rw:AddField(LGB.CreateStringField("message",{maxLength=180}))
        rw:OnData(function(unitTag,data)
            if not isSenderAllowed(unitTag) then return end
            raidWarningPopup(data and data.message or "")
        end)
        if not rw:Finalize({isRelevantInCombat=true,replaceQueuedMessages=false}) then error("protocol 182 finalize failed") end
        Sync.rwProtocol=rw
    end)
    if not ok then d("|cFF4444Rytic raid sync protocol failed: "..tostring(err).."|r"); return false end
    d("|c55FF55Rytic raid sync transport ready (protocols 180 + 181).|r")
    return true
end

function Sync.SendRaidWarning(message)
    message=tostring(message or ""):gsub("^%s+",""):gsub("%s+$","")
    if message=="" then return false,"message is empty" end
    if not IsUnitGrouped("player") then return false,"you are not grouped" end
    if not isSenderAllowed("player") then return false,"group lead or Rytic assistant authority is required" end
    if not Sync.rwProtocol then return false,"Rytic raid-warning transport is unavailable" end
    if Sync.rwProtocol.IsEnabled and not Sync.rwProtocol:IsEnabled() then return false,"Rytic raid-warning transport is disabled" end
    local ok=Sync.rwProtocol:Send({message=message})
    if not ok then return false,"Rytic raid warning could not be queued" end
    -- Show immediately for the sender too; remote clients render on receive.
    raidWarningPopup(message)
    return true
end

function Sync.SendUpdateNotice(message)
    return Sync.SendRaidWarning(message)
end

function Sync.PushAssistants()
    if Sync.applyingRemote then return true,"remote-apply-suppressed" end
    if not (IsUnitGroupLeader and IsUnitGroupLeader("player")) then
        return false,"Only the current ESO group leader can change RCRT assistant authority"
    end
    if not Sync.protocol then return false,"LibGroupBroadcast protocol is unavailable" end
    if Sync.protocol.IsEnabled and not Sync.protocol:IsEnabled() then return false,"Rytic raid sync is disabled in LibGroupBroadcast settings" end
    local G=RyticTank.GroupFrames
    if not G or not G.ExportSyncState then return false,"Group frame sync state is unavailable" end
    local assignments,assistants=G.ExportSyncState()
    Sync.lastRevision=((tonumber(Sync.lastRevision) or 0)+1)%65536
    local ok=Sync.protocol:Send({revision=Sync.lastRevision,assignments=assignments,assistants=assistants})
    if not ok then return false,"LibGroupBroadcast could not queue the assistant update" end
    setSessionAssistants(assistants)
    refreshGroupManagerIfOpen()
    return true
end

function Sync.Push()
    -- Incoming state is apply-only. It must never be allowed to echo back out.
    if Sync.applyingRemote then return true,"remote-apply-suppressed" end
    if not Sync.protocol then return false,"LibGroupBroadcast protocol is unavailable" end
    if Sync.protocol.IsEnabled and not Sync.protocol:IsEnabled() then return false,"Rytic raid sync is disabled in LibGroupBroadcast settings" end
    local G=RyticTank.GroupFrames
    if not G or not G.ExportSyncState then return false,"Group frame sync state is unavailable" end
    local assignments,assistants,teamNames=G.ExportSyncState()
    teamNames=teamNames or {"TEAM A","TEAM B"}

    local rows={}
    for _,row in ipairs(assignments or {}) do
        rows[#rows+1]=norm(row.account)..":"..tostring(row.team)..":"..(row.locked and "1" or "0")
    end
    table.sort(rows)
    local as={}
    for _,name in ipairs(assistants or {}) do as[#as+1]=norm(name) end
    table.sort(as)
    local snapshot=table.concat(rows,";").."|"..table.concat(as,";").."|"..norm(teamNames[1]).."|"..norm(teamNames[2])
    if Sync.lastSentSnapshot==snapshot then return true,"unchanged" end

    -- Changed explicit PUSH state is queued immediately. Unchanged snapshots above
    -- remain suppressed so UI refreshes cannot rebroadcast the same state.
    Sync.lastRevision=((tonumber(Sync.lastRevision) or 0)+1)%65536
    local ok=Sync.protocol:Send({revision=Sync.lastRevision,assignments=assignments,assistants=assistants})
    if not ok then return false,"LibGroupBroadcast could not queue the assignment push" end
    if Sync.nameProtocol then
        Sync.nameProtocol:Send({
            revision=Sync.lastRevision,
            teamNameA=teamNames[1] or "TEAM A",
            teamNameB=teamNames[2] or "TEAM B"
        })
    end
    Sync.lastSentSnapshot=snapshot
    Sync.lastSendMs=GetFrameTimeMilliseconds and GetFrameTimeMilliseconds() or 0
    if IsUnitGroupLeader and IsUnitGroupLeader("player") then
        setSessionAssistants(assistants)
    end
    popup(account("player"))
    d("|c55FF55Rytic: raid assignments queued for broadcast (rev "..tostring(Sync.lastRevision)..").|r")
    return true
end

local function resetSession()
    Sync.sessionAssistants={}; Sync.sessionAssistantsInitialized=false; Sync.lastRevision=nil
    if RyticTank.GroupFrames then
        RyticTank.GroupFrames.sessionAssistants={}
        RyticTank.GroupFrames.sessionAssistantsInitialized=false
        RyticTank.GroupFrames.sessionAssistantOverrides={}
    end
    Sync.lastSentSnapshot=nil; Sync.lastSendMs=nil
    Sync.pendingSnapshot=nil; Sync.pendingAssignments=nil; Sync.pendingAssistants=nil; Sync.pendingTeamNames=nil; Sync.pendingScheduled=false
    Sync.applyingRemote=false
end

EM:RegisterForEvent("RyticRaidSyncBootstrap",EVENT_ADD_ON_LOADED,function(_,addonName)
    if addonName~="RyticTankTools" then return end
    EM:UnregisterForEvent("RyticRaidSyncBootstrap",EVENT_ADD_ON_LOADED)
    resetSession(); initProtocol()
    EM:RegisterForEvent("RyticRaidSyncGroupUpdate",EVENT_GROUP_UPDATE,function() if not IsUnitGrouped("player") then resetSession() end end)
end)
