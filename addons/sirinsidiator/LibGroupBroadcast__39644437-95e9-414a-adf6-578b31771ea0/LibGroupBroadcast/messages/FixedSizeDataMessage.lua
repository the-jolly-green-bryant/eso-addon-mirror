-- SPDX-FileCopyrightText: 2025 sirinsidiator
--
-- SPDX-License-Identifier: Artistic-2.0

--- @class LibGroupBroadcast
local LGB = LibGroupBroadcast
local DataMessageBase = LGB.internal.class.DataMessageBase

--- @class FixedSizeDataMessage : DataMessageBase
local FixedSizeDataMessage = DataMessageBase:Subclass()
LGB.internal.class.FixedSizeDataMessage = FixedSizeDataMessage

local NUM_ID_BITS = 9
local NUM_DATA_BITS = 7

function FixedSizeDataMessage:Initialize(id, data, options)
    DataMessageBase.Initialize(self, id, data, NUM_ID_BITS, NUM_DATA_BITS, options)
end

function FixedSizeDataMessage:GetSize()
    return 2
end

function FixedSizeDataMessage.Deserialize(buffer)
    local id, data = DataMessageBase.Deserialize(buffer, NUM_ID_BITS, NUM_DATA_BITS)
    local message = FixedSizeDataMessage:New(id, data)
    return message
end
