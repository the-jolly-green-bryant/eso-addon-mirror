LibTextFormat = LibTextFormat or {}
local LTF = LibTextFormat


function LTF:ListProtocols()
  return self:GetVar("protocols")
end

function LTF:GetProtocol(protocolName)
  return self:GetVarByValue("protocols", protocolName)
end

function LTF:RegisterProtocol(name, protocol)
    local protocols = self:ListProtocols() or {}
    protocols[name] = protocol
    self:SaveToVars("protocols", protocols)
end

function LTF:RegisterProtocolsBulk(object, version, selectiveOverrides)
  for key, protocol in pairs(object[version]) do
    self:RegisterProtocol(key, protocol)
  end
  for ver, overridden in pairs(selectiveOverrides) do
   if object[ver] ~= nil then
    self:RegisterProtocol(overridden, object[ver])
   end
  end
end
