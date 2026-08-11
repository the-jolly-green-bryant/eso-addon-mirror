local CC = CombatCoordination

----------------------------------------------------------------------------------------------------
-- MODULE VARS AND SVARS
----------------------------------------------------------------------------------------------------
local Module = {
    name      = "ArcanistFatecarver",
    menuName  = "ARCANIST FATECARVER",
    iconPath  = "/esoui/art/icons/ability_arcanist_015.dds",
    menuLayer = 2,

    currentEffectId = nil,
    currentLabelId = nil,
    activeSkillData = nil,

    TextureChoices = CC.SQUARE_CHOICES,
    TextureValues  = CC.SQUARE_VALUES,

    CombatEvent = {
        ["Fatecarver"]            = { 193331, },
        ["Exhausting Fatecarver"] = { 193397, },
        ["Pragmatic Fatecarver"]  = { 193398, },
    },
    SkillData = {
        ["Fatecarver"] = {
            type = 0, offsetPlayer = 1.5, maxRange = 0, width = 3, height = 22, durationSec = 4.5,
        },
        ["Exhausting Fatecarver"] = {
            type = 0, offsetPlayer = 1.5, maxRange = 0, width = 3, height = 22, durationSec = 5.5,
        },
        ["Pragmatic Fatecarver"] = {
            type = 0, offsetPlayer = 1.5, maxRange = 0, width = 3, height = 22, durationSec = 4.5,
        },
    },

    Default = {
        enableDrawSelf = false,
        enableGameAoeFriendlyColor = false,
        ColorSelf = { 0.75, 1, 0.25, 0.5 },
        texture = "/textures/square_8_clean.dds",
    },
    ---@type table|any
    SV = {},
}

----------------------------------------------------------------------------------------------------
-- UPDATE
----------------------------------------------------------------------------------------------------
function Module:OnUpdate()
    if not self.currentEffectId or not self.activeSkillData then
        self:StopChannel()
        return
    end

    local Effect = CC.DisplayEffect.TrackedEffects[self.currentEffectId]
    if not Effect or not Effect.Control then
        self:StopChannel()
        return
    end

    local _, worldX, worldY, worldZ = GetUnitRawWorldPosition("player")
    if not worldX then return end

    local forwardX, forwardY, forwardZ = GetCameraForward(SPACE_WORLD)
    local cameraYaw = math.atan2(forwardX, forwardZ) - math.pi
    local forwardDistance = math.sqrt(forwardX^2 + forwardZ^2)
    local cameraPitch = math.atan2(forwardY, forwardDistance)

    local height = self.activeSkillData.height * 100
    local offsetPlayer = (self.activeSkillData.offsetPlayer or 0) * 100
    local offsetHinge = offsetPlayer + (height / 2)

    local TX = worldX + (forwardX * offsetHinge)
    local TY = worldY + (forwardY * offsetHinge)
    local TZ = worldZ + (forwardZ * offsetHinge)

    local RX = -(math.pi / 2) + cameraPitch
    local RY = cameraYaw
    local RZ = 0

    local offsetTY = CC.DisplayEffect.SV.offsetTY
    local renderX, renderY, renderZ = WorldPositionToGuiRender3DPosition(TX, TY + offsetTY, TZ)

    Effect.Control:Set3DRenderSpaceOrigin(renderX, renderY, renderZ)
    Effect.Control:Set3DRenderSpaceOrientation(RX, RY, RZ)
end

----------------------------------------------------------------------------------------------------
-- START CHANNEL
----------------------------------------------------------------------------------------------------
function Module:StartChannel(ID, SkillData)
    self:StopChannel()
    if not ID or not SkillData then return end

    self.activeSkillData = SkillData

    local width = (SkillData.width * 100)
    local height = (SkillData.height * 100)
    local offsetPlayer = (SkillData.offsetPlayer or 0) * 100

    local offsetHinge = offsetPlayer + (height / 2)

    local _, worldX, worldY, worldZ = GetUnitRawWorldPosition("player")

    local forwardX, forwardY, forwardZ = GetCameraForward(SPACE_WORLD)
    local cameraYaw = math.atan2(forwardX, forwardZ) - math.pi
    local forwardDistance = math.sqrt(forwardX^2 + forwardZ^2)
    local cameraPitch = math.atan2(forwardY, forwardDistance)

    local TX = worldX + (forwardX * offsetHinge)
    local TY = worldY + (forwardY * offsetHinge)
    local TZ = worldZ + (forwardZ * offsetHinge)

    local texture = self.SV.texture
    local Color = self.SV.enableGameAoeFriendlyColor and CC.GetGameAoeFriendlyColor() or self.SV.ColorSelf
    local durationMs = (SkillData.durationSec or 4.5) * 1000
    local isHidden = (not self.SV.enableDrawSelf and not CC.enablePreview)

    local RX = -(math.pi / 2) + cameraPitch
    local RY = cameraYaw
    local RZ = 0

    self.currentEffectId = CC.DisplayEffect:Draw3DEffect(
    {
        ID = ID,

        TX = TX, RX = RX, FX = false,
        TY = TY, RY = RY, FY = false,
        TZ = TZ, RZ = RZ, FZ = false,

        width = width,
        height = height,

        texture = texture,
        Color = Color,
        isHidden = isHidden,
        durationMs = durationMs,
    })

    if self.currentEffectId then
        EVENT_MANAGER:RegisterForUpdate(CC.NAME .. "ArcanistFatecarver_OnUpdate", 10, function() self:OnUpdate() end)
    end
end

----------------------------------------------------------------------------------------------------
-- STOP CHANNEL
----------------------------------------------------------------------------------------------------
function Module:StopChannel()
    EVENT_MANAGER:UnregisterForUpdate(CC.NAME .. "ArcanistFatecarver_OnUpdate")
    if self.currentEffectId then
        CC.DisplayEffect:RemoveTrackedEffect(self.currentEffectId)
        self.currentEffectId = nil
    end
    self.activeSkillData = nil
end

----------------------------------------------------------------------------------------------------
-- COMBAT EVENT
----------------------------------------------------------------------------------------------------
function Module:HandleCombatEvent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
    if sourceType == COMBAT_UNIT_TYPE_PLAYER and result == ACTION_RESULT_EFFECT_GAINED then
        local ID = abilityId
        local SkillData = CC.SkillData[ID]
        if not SkillData then return end

        self:StartChannel(ID, SkillData)

    elseif targetType == COMBAT_UNIT_TYPE_PLAYER and result == ACTION_RESULT_EFFECT_FADED then
        self:StopChannel()
    end
end

-- CUSTOM COMBAT EVENT
Module.GetMenuOptions = function(self) return CC.CreateModuleSettings(self, self.menuName, self.iconPath) end

CC[Module.name] = Module
table.insert(CC.Modules, Module)