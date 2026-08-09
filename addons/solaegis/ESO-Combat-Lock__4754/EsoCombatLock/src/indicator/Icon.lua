-- EsoCombatLock - indicator icon resolution

local ECL = EsoCombatLock
ECL.Indicator = ECL.Indicator or {}
local Indicator = ECL.Indicator
Indicator.Icon = Indicator.Icon or {}
local Icon = Indicator.Icon
local State = Indicator.State

local function setIndicatorTexture(texture)
    if not State.iconTexture then
        return
    end
    State.iconTexture:SetTexture(texture or State.FALLBACK_TEXTURE)
end

local function resolveCollectibleTexture(collectibleId)
    if collectibleId and collectibleId > 0 and GetCollectibleIcon then
        local icon = GetCollectibleIcon(collectibleId)
        if icon and icon ~= "" then
            return icon
        end
    end
    return nil
end

--- Wheel-slot art for a collectible (survives combat parking onto another slot).
local function resolveWheelTexture(collectibleId)
    if not collectibleId or collectibleId <= 0 or not ECL.Slots then
        return nil
    end
    local slot = ECL.Slots.FindSlotForResource(ACTION_TYPE_COLLECTIBLE, collectibleId)
    if not slot then
        return nil
    end
    return ECL.Slots.GetSlotTexture(slot)
end

local function textureForCollectible(collectibleId)
    -- Prefer the slotted quickslot portrait: GetCollectibleIcon is empty/wrong for
    -- some companions, and the parked slot must never replace this face.
    local wheel = resolveWheelTexture(collectibleId)
    if wheel then
        return wheel
    end
    return resolveCollectibleTexture(collectibleId)
end

--- Active companion / assistant / pet collectible — never the parked quickslot.
local function resolveIndicatorCollectibleId()
    if State.armedCollectibleId and State.armedCollectibleId > 0 then
        return State.armedCollectibleId
    end
    if ECL.Slots and ECL.Slots.GetActiveCompanionCollectibleId then
        local companionId = ECL.Slots.GetActiveCompanionCollectibleId()
        if companionId then
            return companionId
        end
    end
    -- Direct collectible API: more reliable than defId→collectible for some companions.
    if GetActiveCollectibleByType and COLLECTIBLE_CATEGORY_TYPE_COMPANION then
        local id = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_COMPANION, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
        if id and id > 0 then
            return id
        end
    end
    if ECL.Slots and ECL.Slots.GetActiveRiskyCollectibleId then
        local activeRiskyId = ECL.Slots.GetActiveRiskyCollectibleId()
        if activeRiskyId then
            return activeRiskyId
        end
    end
    if State.isGuardArmed() and ECL.Guard and ECL.Guard.GetState then
        return ECL.Guard.GetState().companionCollectibleId
    end
    return nil
end

local function resolveIndicatorTexture()
    local collectibleId = resolveIndicatorCollectibleId()
    local collectibleTexture = textureForCollectible(collectibleId)
    if collectibleTexture then
        return collectibleTexture
    end

    -- While a companion is out (or the guard remembered one), never show the
    -- parked memento/potion face — better a generic fallback than the wrong art.
    if collectibleId or State.hasActiveCompanion() or (State.armedCollectibleId and State.armedCollectibleId > 0) then
        return State.FALLBACK_TEXTURE
    end

    if ECL.Slots then
        local texture = ECL.Slots.GetSlotTexture(ECL.Slots.GetCurrent())
        if texture then
            return texture
        end
    end
    return State.FALLBACK_TEXTURE
end

--- Slot the quickslot key would activate in combat (park / substitute / last-safe).
--- Resolves without requiring combat so reposition mode can preview the prospective
--- target; callers decide whether the preview should be visible.
local function resolveParkPreviewSlot()
    if not ECL.Slots then
        return nil
    end
    local Slots = ECL.Slots
    local Guard = ECL.Guard
    -- While armed on a safe slot, Q fires that slot — show its art.
    if Guard and Guard.IsArmed and Guard.IsArmed() then
        local cur = Slots.GetCurrent()
        if Slots.IsSafe(cur) then
            return cur
        end
        local lastSafe = Guard.GetState and Guard.GetState().lastSafeSlot or nil
        return select(1, Slots.ResolveParkPreviewSlot(lastSafe))
    end
    local lastSafe = Guard and Guard.GetState and Guard.GetState().lastSafeSlot or nil
    return select(1, Slots.ResolveParkPreviewSlot(lastSafe))
end

local function textureForParkSlot(slot)
    if not slot or not ECL.Slots then
        return State.FALLBACK_TEXTURE
    end
    local Slots = ECL.Slots
    if Slots.IsEmpty(slot) then
        return State.EMPTY_PARK_TEXTURE or ECL.EMPTY_PARK_TEXTURE
    end
    local texture = Slots.GetSlotTexture(slot)
    if texture then
        return texture
    end
    if Slots.GetType(slot) == ACTION_TYPE_COLLECTIBLE and GetCollectibleIcon then
        local id = Slots.GetBoundId(slot)
        if id and id > 0 then
            local icon = GetCollectibleIcon(id)
            if icon and icon ~= "" then
                return icon
            end
        end
    end
    return State.FALLBACK_TEXTURE
end

local function refreshParkPreview()
    if not State.parkPreviewTexture then
        return
    end
    -- Same visibility as the indicator: Always show, combat+companion, reposition, or testglow.
    if not Indicator.Visibility.ShouldShow() then
        State.parkPreviewTexture:SetHidden(true)
        if Indicator.Frame and Indicator.Frame.ApplySize then
            Indicator.Frame.ApplySize()
        end
        return
    end
    local slot = resolveParkPreviewSlot()
    local texture = textureForParkSlot(slot) or State.FALLBACK_TEXTURE
    State.parkPreviewTexture:SetTexture(texture)
    -- ESO has no DestroyControl: a named control created under an earlier build of
    -- this addon can persist across /reloadui with stale color/alpha. Force fully
    -- opaque white every refresh so a leftover transparent tint can never hide it.
    State.parkPreviewTexture:SetColor(1, 1, 1, 1)
    State.parkPreviewTexture:SetHidden(false)
    if Indicator.Frame then
        Indicator.Frame.ApplyParkPreviewDrawOrder()
        Indicator.Frame.ApplySize()
    end
end

function Icon.SetArmedCollectibleId(collectibleId)
    if collectibleId and collectibleId > 0 then
        State.armedCollectibleId = collectibleId
    else
        State.armedCollectibleId = nil
    end
end

function Icon.ClearArmedCollectibleId()
    State.armedCollectibleId = nil
end

function Icon.Refresh()
    setIndicatorTexture(resolveIndicatorTexture())
    refreshParkPreview()
end

--- Exposed for unit tests.
function Icon.ResolveTextureForTest()
    return resolveIndicatorTexture()
end

--- Exposed for unit tests.
function Icon.ResolveParkPreviewTextureForTest()
    if not Indicator.Visibility.ShouldShow() then
        return nil
    end
    return textureForParkSlot(resolveParkPreviewSlot())
end

--- Exposed for unit tests.
function Icon.IsParkPreviewHiddenForTest()
    if not State.parkPreviewTexture then
        return true
    end
    return State.parkPreviewTexture:IsHidden()
end
