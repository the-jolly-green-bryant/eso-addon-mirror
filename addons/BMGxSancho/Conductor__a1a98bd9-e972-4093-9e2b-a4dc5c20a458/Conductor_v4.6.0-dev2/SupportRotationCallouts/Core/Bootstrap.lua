SupportRotationCallouts = SupportRotationCallouts or {}
Conductor = SupportRotationCallouts

local C = Conductor
C.Platform = C.Platform or {}
C.Platform.version = "4.6.0-dev2"
C.Platform.schemaVersion = 5
C.Platform.protocolVersion = 3
C.Platform.build = "raid-plan-sharing"
C.Platform.legacyNamespace = "SupportRotationCallouts"
C.Platform.publicNamespace = "Conductor"

function C.Platform:GetVersion()
    return self.version
end

function C.Platform:IsDevelopmentBuild()
    return string.find(self.version or "", "dev", 1, true) ~= nil
end
