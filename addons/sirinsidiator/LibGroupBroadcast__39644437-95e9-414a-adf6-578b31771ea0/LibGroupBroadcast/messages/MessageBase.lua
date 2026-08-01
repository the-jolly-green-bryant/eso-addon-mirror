-- SPDX-FileCopyrightText: 2025 sirinsidiator
--
-- SPDX-License-Identifier: Artistic-2.0

--- @class LibGroupBroadcast
local LGB = LibGroupBroadcast
local BinaryBuffer = LGB.internal.class.BinaryBuffer

--- @class MessageBase
local MessageBase = ZO_InitializingObject:Subclass()
LGB.internal.class.MessageBase = MessageBase

function MessageBase:Initialize(id, data, idBits, dataBits)
    if data then data:Rewind() end
    self.id = id
    self.data = data or BinaryBuffer:New(dataBits)
    self.idBits = idBits
    self.dataBits = dataBits or data:GetNumBits()
end

function MessageBase:GetId()
    return self.id
end

function MessageBase:GetData()
    return self.data
end

function MessageBase:Serialize(buffer)
    buffer:WriteUInt(self.id, self.idBits)
    buffer:WriteBuffer(self.data, self.dataBits)
end

function MessageBase.Deserialize(buffer, idBits, dataBits)
    local id = buffer:ReadUInt(idBits)
    local data = buffer:ReadBuffer(dataBits)
    return id, data
end
