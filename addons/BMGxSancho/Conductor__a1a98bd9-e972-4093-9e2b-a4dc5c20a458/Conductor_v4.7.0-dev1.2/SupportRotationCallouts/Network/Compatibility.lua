Conductor.NetworkCompatibility = Conductor.NetworkCompatibility or {}

function Conductor.NetworkCompatibility:IsCompatible(protocolVersion)
    return tonumber(protocolVersion) == tonumber(Conductor.Network.protocolVersion)
end
