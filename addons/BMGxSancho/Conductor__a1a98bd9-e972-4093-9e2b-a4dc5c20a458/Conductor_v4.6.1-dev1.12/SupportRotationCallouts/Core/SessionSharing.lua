local C = Conductor
C.SessionSharing = C.SessionSharing or {}
local SessionSharing = C.SessionSharing

local function Normalize(value)
    if C.NormalizeAccountName then return C:NormalizeAccountName(value or "") end
    return tostring(value or "")
end

local function Alert(message)
    if CHAT_SYSTEM and CHAT_SYSTEM.AddMessage then CHAT_SYSTEM:AddMessage(message) elseif d then d(message) end
    if ZO_Alert then pcall(ZO_Alert, UI_ALERT_CATEGORY_ALERT, nil, message) end
end

function SessionSharing:Initialize()
    if C.SessionShareDiagnostics then C.SessionShareDiagnostics:Reset() end
    if C.SessionDialogs then C.SessionDialogs:Register() end
    self.initialized = C.SessionTransfer and C.SessionTransfer:Initialize() or false
    return self.initialized
end

function SessionSharing:ShareActiveSession()
    local session = C.RaidSession and C.RaidSession:GetActive()
    if not session then return false, "No active Raid Session is available." end
    local localAccount = Normalize(GetDisplayName and GetDisplayName() or "")
    if Normalize(session.hostAccount) ~= localAccount then return false, "Only the Raid Plan host can share it." end

    local snapshot = session.raidPlan or (C.RaidPlanCompiler and C.RaidPlanCompiler:Compile(session))
    if not snapshot then return false, "The Raid Plan could not be compiled." end
    local serialized, serializationError = C.RaidPlanSerializer:Encode(snapshot)
    if not serialized then return false, serializationError end
    if #serialized > C.RaidPlan.MAX_SERIALIZED_BYTES then return false, "The Raid Plan exceeds the supported transfer size." end

    local decoded, decodeError = C.RaidPlanSerializer:Decode(serialized)
    if not decoded then return false, "Snapshot round-trip validation failed: " .. tostring(decodeError) end
    local valid, validationError = C.RaidPlan:Validate(decoded, true)
    if not valid then return false, "Snapshot round-trip validation failed: " .. tostring(validationError) end

    local shared, transferOrError = C.SessionTransfer:Start(snapshot, serialized)
    if not shared then return false, transferOrError end
    if C.RaidSession then C.RaidSession:Transition(C.RaidSession.STATES.SHARED, "Raid Plan transfer started") end
    Alert(string.format("|c55FF55Conductor started sharing %s.|r", tostring(snapshot.teamName or "Raid Session")))
    return true, transferOrError
end

function SessionSharing:AcceptPendingInvitation()
    local transfer = C.SessionTransfer and C.SessionTransfer.pendingValidated
    if not transfer or not transfer.snapshot then return false end
    local imported, importError = C.RaidPlanImporter:Import(transfer.snapshot, transfer.sender)
    if not imported then
        C.SessionTransfer:SendResponse(transfer.token, transfer.sender, C.SessionTransfer.STATUS.IMPORT_FAILED)
        if C.SessionShareDiagnostics then C.SessionShareDiagnostics:Fail(importError) end
        Alert("|cFF5555Conductor could not import the shared team:|r " .. tostring(importError or "unknown error"))
        return false
    end
    C.SessionTransfer:SendResponse(transfer.token, transfer.sender, C.SessionTransfer.STATUS.ACCEPTED)
    C.SessionTransfer:SetIncoming(transfer.sender, transfer.token, nil)
    C.SessionTransfer.pendingValidated = nil
    if C.SessionShareDiagnostics then C.SessionShareDiagnostics:Update({ state="ACCEPTED", response="ACCEPTED" }) end
    Alert(string.format("|c55FF55%s accepted and loaded.|r", tostring(transfer.snapshot.teamName or "Shared Raid Plan")))
    if C.EventBus then C.EventBus:Publish("RAID_PLAN_INVITATION_ACCEPTED", { session=imported, host=transfer.sender, transferId=transfer.token }) end
    return true
end

function SessionSharing:DeclinePendingInvitation()
    local transfer = C.SessionTransfer and C.SessionTransfer.pendingValidated
    if not transfer then return false end
    C.SessionTransfer:SendResponse(transfer.token, transfer.sender, C.SessionTransfer.STATUS.DECLINED)
    C.SessionTransfer:SetIncoming(transfer.sender, transfer.token, nil)
    C.SessionTransfer.pendingValidated = nil
    if C.SessionShareDiagnostics then C.SessionShareDiagnostics:Update({ state="DECLINED", response="DECLINED" }) end
    Alert(string.format("|cFFD447%s declined.|r", tostring(transfer.snapshot and transfer.snapshot.teamName or "Shared Raid Plan")))
    if C.EventBus then C.EventBus:Publish("RAID_PLAN_INVITATION_DECLINED", { snapshot=transfer.snapshot, host=transfer.sender, transferId=transfer.token }) end
    return true
end

function SessionSharing:CancelShare()
    return C.SessionTransfer and C.SessionTransfer:CancelOutgoing() or false
end

function SessionSharing:CloseSharedSession()
    if C.SessionTransfer then C.SessionTransfer:SendControl(C.SessionTransfer.COMMAND.CLOSE) end
    if C.RaidSession then C.RaidSession:Archive("host closed shared Raid Plan") end
    return true
end

function SessionSharing:LeaveSharedSession()
    local session = C.RaidSession and C.RaidSession:GetActive()
    if not session or not session.remoteHost then return false end
    C.RaidSession:Archive("left shared Raid Plan")
    return true
end

function SessionSharing:GetSynchronizationSummary()
    local transfer = C.SessionTransfer and C.SessionTransfer:GetStatus() or {}
    local responses = transfer.responses or {}
    local counts = { accepted=0, declined=0, failed=0, pending=0 }
    for _, response in pairs(responses) do
        if response.status == C.SessionTransfer.STATUS.ACCEPTED then counts.accepted = counts.accepted + 1
        elseif response.status == C.SessionTransfer.STATUS.DECLINED then counts.declined = counts.declined + 1
        else counts.failed = counts.failed + 1 end
    end
    local session = C.RaidSession and C.RaidSession:GetActive()
    local expected = 0
    if session then
        local localAccount = Normalize(GetDisplayName and GetDisplayName() or "")
        for _, player in ipairs(session.players or {}) do if Normalize(player.accountName) ~= localAccount then expected = expected + 1 end end
    end
    counts.pending = math.max(0, expected - counts.accepted - counts.declined - counts.failed)
    return counts, responses, transfer
end

function SessionSharing:PrintSynchronizationSummary()
    local counts, responses, transfer = self:GetSynchronizationSummary()
    Alert(string.format("|cFFD447Conductor Share Status|r Accepted %d | Declined %d | Failed %d | Pending %d", counts.accepted, counts.declined, counts.failed, counts.pending))
    for account, response in pairs(responses) do
        if CHAT_SYSTEM and CHAT_SYSTEM.AddMessage then
            CHAT_SYSTEM:AddMessage(string.format("%s: %s (%s)", account, tostring(response.statusName), tostring(response.version or "unknown version")))
        end
    end
    return transfer
end

-- Legacy generic-network entry point intentionally remains inert. Session sharing
-- now uses dedicated LibGroupBroadcast protocols and never tunnels through P3.
function SessionSharing:ParsePayload()
    return false
end
