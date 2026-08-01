AUI_PinBlobManager = ZO_ObjectPool:Subclass()

function AUI_PinBlobManager:New(blobContainer)
    local blobFactory = function(pool) return ZO_ObjectPool_CreateNamedControl("AUI_QuestPinBlob", "ZO_PinBlob", pool, blobContainer) end
    return ZO_ObjectPool.New(self, blobFactory, ZO_ObjectPool_DefaultResetControl)
end