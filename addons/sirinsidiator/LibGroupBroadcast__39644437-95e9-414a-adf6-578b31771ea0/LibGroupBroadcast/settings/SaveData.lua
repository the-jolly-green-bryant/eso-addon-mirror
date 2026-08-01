--- @class LibGroupBroadcastInternal
local internal = LibGroupBroadcast.internal

--- @class RawSaveData
--- @field version number
--- @field customEventDisabled table<number, boolean>
--- @field protocolDisabled table<number, boolean>

--- @type RawSaveData
local DEFAULT_SAVE_DATA = {
    version = 1,
    customEventDisabled = {},
    protocolDisabled = {},
}

local SAVED_VAR_NAME = "LibGroupBroadcast_Data"

--- @class SaveData
--- @field New fun(self: SaveData, context?: table): SaveData
local SaveData = ZO_InitializingObject:Subclass()
internal.class.SaveData = SaveData

function SaveData:Initialize(context)
    local displayName = GetDisplayName()
    context = context or _G
    context[SAVED_VAR_NAME] = context[SAVED_VAR_NAME] or {}
    context[SAVED_VAR_NAME][displayName] = context[SAVED_VAR_NAME][displayName] or {}
    local data = context[SAVED_VAR_NAME][displayName]

    if not data.version then
        ZO_DeepTableCopy(DEFAULT_SAVE_DATA, data)
    end

    data.sendDataWhileInvisible = nil

    self.data = data
end

function SaveData:GetCustomEventDisabled()
    return self.data.customEventDisabled
end

function SaveData:GetProtocolDisabled()
    return self.data.protocolDisabled
end
