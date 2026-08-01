-- SPDX-FileCopyrightText: 2025 sirinsidiator
--
-- SPDX-License-Identifier: Artistic-2.0

--- @class LibGroupBroadcast
local LGB = LibGroupBroadcast
local MessageBase = LGB.internal.class.MessageBase

local ControlMessageBase = MessageBase:Subclass()
LGB.internal.class.ControlMessageBase = ControlMessageBase

local NUM_ID_BITS = 4
local NUM_DATA_BITS = 4

function ControlMessageBase:Initialize(id, data)
    MessageBase.Initialize(self, id, data, NUM_ID_BITS, NUM_DATA_BITS)
end

function ControlMessageBase.Deserialize(buffer)
    local id, data = MessageBase.Deserialize(buffer, NUM_ID_BITS, NUM_DATA_BITS)
    local message = ControlMessageBase:New(id, data)
    return message
end

ControlMessageBase:MUST_IMPLEMENT("CastFrom")
