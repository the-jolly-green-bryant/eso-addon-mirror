local C = Conductor
C.RaidPlanSerializer = C.RaidPlanSerializer or {}
local Serializer=C.RaidPlanSerializer
function Serializer:Encode(plan) return C.SessionSerializer:Encode(plan) end
function Serializer:Decode(value) return C.SessionSerializer:Decode(value) end
function Serializer:Checksum(value) return C.SessionSerializer:Checksum(value) end
