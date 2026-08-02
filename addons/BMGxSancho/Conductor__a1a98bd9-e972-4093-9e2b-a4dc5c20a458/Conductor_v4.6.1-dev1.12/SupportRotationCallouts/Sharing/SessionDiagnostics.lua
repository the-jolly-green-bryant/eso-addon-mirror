local C = Conductor
C.SessionShareDiagnostics = C.SessionShareDiagnostics or {}
local Diagnostics = C.SessionShareDiagnostics

function Diagnostics:Reset()
    self.current = { state="IDLE", direction="NONE", failureReason="" }
end

function Diagnostics:Update(fields)
    self.current = self.current or {}
    for key, value in pairs(fields or {}) do self.current[key] = value end
end

function Diagnostics:Fail(reason)
    self:Update({ state="FAILED", failureReason=tostring(reason or "unknown failure"), completedAt=GetGameTimeMilliseconds and GetGameTimeMilliseconds() or 0 })
end

function Diagnostics:GetSnapshot()
    self.current = self.current or { state="IDLE", direction="NONE", failureReason="" }
    local copy = {}
    for key, value in pairs(self.current) do copy[key] = value end
    return copy
end
