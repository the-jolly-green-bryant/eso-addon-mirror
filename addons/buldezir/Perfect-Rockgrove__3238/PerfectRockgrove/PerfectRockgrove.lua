local NAME = 'PerfectRockgrove'

--------------------------------------------------------------------------
--Consts--
--------------------------------------------------------------------------
local RG_ZONE_ID = 1263

local ICON_SQUARE_GREEN = "PerfectRockgrove/icons/square_green.dds"
local ICON_SQUARE_YELLOW = "PerfectRockgrove/icons/square_yellow.dds"
local ICON_SQUARE_ORANGE = "PerfectRockgrove/icons/square_orange.dds"
local ICON_SQUARE_RED = "PerfectRockgrove/icons/square_red.dds"
local ICON_SQUARE_PINK = "PerfectRockgrove/icons/square_pink.dds"
local ICON_SQUARETO_PINK = "PerfectRockgrove/icons/squaretwo_pink.dds"
--------------------------------------------------------------------------
local iconN = 0
--------------------------------------------------------------------------
--CallEvery--
--------------------------------------------------------------------------
local CallEveryId = 1
local function CallEvery(func, ms, times)
    local id = CallEveryId
    local name = "CallEveryFunction" .. id
    CallEveryId = CallEveryId + 1
    func(id, times)
    EVENT_MANAGER:RegisterForUpdate(name, ms,
            function()
                if times < 1 then
                    EVENT_MANAGER:UnregisterForUpdate(name)
                else
                    times = times - 1
                    func(id, times)
                end
            end)
    return id
end

local function RemoveCallEvery(id)
    if id then
        EVENT_MANAGER:UnregisterForUpdate("CallEveryFunction" .. id)
    end
end

local function chatMsg(message)
    return CHAT_ROUTER:AddSystemMessage(message)
end
--------------------------------------------------------------------------
--Icon class--
--------------------------------------------------------------------------
local Icon = ZO_Object:Subclass()
function Icon:New(...)
    local obj = ZO_Object.New(self)
    obj:Initialize(...)
    return obj
end

function Icon:Initialize(mapId, x, y, z, texture)
    iconN = iconN + 1
    -- todo: use ~ ZO_ControlPool
    local ctrl = CreateControl("PerfectRgIcon" .. iconN, GuiRoot, CT_TEXTURE)
    ctrl:SetTexture(texture)
    ctrl:SetDimensions(180, 180)
    ctrl:SetPixelRoundingEnabled(false)
    ctrl:SetHidden(true)
    ctrl:SetDrawLayer(DL_CONTROLS)
    self.control = ctrl

    local label = ctrl:CreateControl(ctrl:GetName() .. "Label", CT_LABEL)
    label:SetAnchor(CENTER, ctrl, CENTER, 0, 0)
    label:SetFont("$(BOLD_FONT)|$(KB_54)|outline")
    label:SetScale(2)
    label:SetColor(0.9, 0.9, 0.9, 0.85)
    label:SetText("")
    self.label = label

    local obj3d = Lib3dObjectCoord:New(ctrl, x, y, z)
    obj3d:SetMinFadeOpacity(0.6)
    self.obj3d = obj3d

    self.originalTexture = texture
    self.currentCallId = nil
end

function Icon:Enable()
    Lib3dObjectManager:Attach(self.obj3d)
end

function Icon:Reset()
    RemoveCallEvery(self.currentCallId)
    self.currentCallId = nil
    self:SetTexture(self.originalTexture)
    self:SetText("")
end

function Icon:Disable()
    self:Reset()
    Lib3dObjectManager:Detach(self.obj3d)
end

function Icon:SetText(text)
    self.label:SetText(text)
end

function Icon:SetTexture(texture)
    if self.control:GetTextureFileName() ~= texture then
        self.control:SetTexture(texture)
    end
end

function Icon:CallEvery(func, ms, times)
    RemoveCallEvery(self.currentCallId)
    self.currentCallId = CallEvery(func, ms, times)
    return self.currentCallId
end

--------------------------------------------------------------------------
--- Oaxiltso
--------------------------------------------------------------------------
local OaxiltsoBossLogic = LibBossMechanicBase:Subclass()
function OaxiltsoBossLogic:New(...)
    return LibBossMechanicBase.New(self, ...)
end
function OaxiltsoBossLogic:Initialize()
    self.zoneId = RG_ZONE_ID
    self.iconList = {}
    self.pool_cooldown = 25
    self.sofreshsoclean_buff_id = 152456
end
function OaxiltsoBossLogic:OnZoneEnter()
    if #self.iconList == 0 then
        self.iconList = {
            Icon:New(RG_ZONE_ID, 92710, 36200, 78130, ICON_SQUARE_GREEN),
            Icon:New(RG_ZONE_ID, 87910, 36200, 77796, ICON_SQUARE_GREEN),
            Icon:New(RG_ZONE_ID, 92772, 36200, 81495, ICON_SQUARE_GREEN),
            Icon:New(RG_ZONE_ID, 87875, 36200, 81755, ICON_SQUARE_GREEN),
        }
    end
end
function OaxiltsoBossLogic:GetName()
    return "Oaxiltso"
end
function OaxiltsoBossLogic:OnCombatExit()
    EVENT_MANAGER:UnregisterForEvent("OaxiltsoBossLogic", EVENT_EFFECT_CHANGED)
    EVENT_MANAGER:UnregisterForEvent("OaxiltsoBossLogic", EVENT_POWER_UPDATE)
    for i = #self.iconList, 1, -1 do
        self.iconList[i]:Disable()
    end
end

function OaxiltsoBossLogic:OnCombatEnter()
    for i = #self.iconList, 1, -1 do
        self.iconList[i]:Enable()
    end
    EVENT_MANAGER:RegisterForEvent("OaxiltsoBossLogic", EVENT_EFFECT_CHANGED, function(...)
        self:OnEffectChanged(...)
    end)
    EVENT_MANAGER:AddFilterForEvent("OaxiltsoBossLogic", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")

    if GetSelectedLFGRole() == LFG_ROLE_HEAL then
        EVENT_MANAGER:RegisterForEvent("OaxiltsoBossLogic", EVENT_POWER_UPDATE, function(_, ...)
            self:OnHPChanged(...)
        end)
        EVENT_MANAGER:AddFilterForEvent("OaxiltsoBossLogic", EVENT_POWER_UPDATE, REGISTER_FILTER_UNIT_TAG, "boss1")
        EVENT_MANAGER:AddFilterForEvent("OaxiltsoBossLogic", EVENT_POWER_UPDATE, REGISTER_FILTER_POWER_TYPE, POWERTYPE_HEALTH)
    end
end

function OaxiltsoBossLogic:OnHPChanged(unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax)
    local percent = 0
    if powerMax ~= 0 then
        percent = (powerValue / powerMax) * 100
    end
    if percent > 0 and percent < 50.5 then
        EVENT_MANAGER:UnregisterForEvent("OaxiltsoBossLogic", EVENT_POWER_UPDATE)
        if CombatAlerts then
            CombatAlerts.Alert("", "DOUBLE CHARGES!", 0xFF0000FF, SOUNDS.CHAMPION_POINTS_COMMITTED, 3000)
        end
    end
end


function OaxiltsoBossLogic:OnEffectChanged(_, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
    if changeType == EFFECT_RESULT_GAINED and abilityId == self.sofreshsoclean_buff_id then
        self:OnPoolCleanseUsed(unitTag)
    end
end

function OaxiltsoBossLogic:FindPool(x, y, z)
    -- 1: Entrance Left
    -- 2: Entrance Right
    -- 3: Exit Left
    -- 4: Exit Right
    local bestDist = 9999999999
    local ans = 0
    local oaxiltso_pools = { { 91603, 35770, 78323 }, -- entrance left (HM banner)
                             { 88065, 35770, 78664 }, -- entrance right
                             { 91973, 35770, 81764 }, -- exit left
                             { 87733, 35770, 81384 } }; -- exit right
    for i = 1, 4 do
        local dist = zo_distance3D(x, y, z,
                oaxiltso_pools[i][1],
                oaxiltso_pools[i][2],
                oaxiltso_pools[i][3])
        if dist < bestDist then
            bestDist = dist
            ans = i
        end
    end
    return ans
end

function OaxiltsoBossLogic:OnPoolCleanseUsed(unitTag)
    local _, px, py, pz = GetUnitWorldPosition(unitTag)
    local poolId = self:FindPool(px, py, pz)
    if poolId > 0 then
        local iconObj = self.iconList[poolId]
        iconObj:CallEvery(function(id, n)
            if n == 0 then
                iconObj:SetTexture(ICON_SQUARE_GREEN)
                iconObj:SetText("")
            elseif n <= 3 then
                iconObj:SetTexture(ICON_SQUARE_YELLOW)
                iconObj:SetText(n)
            elseif n <= 10 then
                iconObj:SetTexture(ICON_SQUARE_ORANGE)
                iconObj:SetText(n)
            elseif n <= 18 then
                iconObj:SetTexture(ICON_SQUARE_RED)
                iconObj:SetText(n)
            else
                iconObj:SetTexture(ICON_SQUARE_PINK)
                iconObj:SetText(n)
            end
        end, 1000, self.pool_cooldown)
    end
end
--------------------------------------------------------------------------
--- Bahsei
--------------------------------------------------------------------------
local BahseiBossLogic = LibBossMechanicBase:Subclass()
function BahseiBossLogic:New(...)
    return LibBossMechanicBase.New(self, ...)
end
function BahseiBossLogic:Initialize()
    self.zoneId = RG_ZONE_ID
    self.EmbraceOfDeathDistance = 480
    self.DeathTouchId = 150078
    self.AtLeastOneExplode = false
    self.Deadpool = {}
    self.ExplodeMessages = {
        "Wow, %s brutally killed %s",
        "Why u so cruel %s? %s is dead now",
        "%s lands headshot on %s"
    }
end
function BahseiBossLogic:GetName()
    return "Flame-Herald Bahsei"
end
function BahseiBossLogic:PrintDeadpool()
    chatMsg("DeadPool: ")
    local flag = false
    for k, v in pairs(self.Deadpool) do
        chatMsg(k .. " : " .. v)
        flag = true
    end
    if not flag then
        chatMsg("ITS MIRACLE!")
    end
end
function BahseiBossLogic:OnZoneEnter()
    self.Deadpool = {}
end
function BahseiBossLogic:OnZoneExit()
    self:PrintDeadpool()
end
function BahseiBossLogic:OnCombatEnter()
    EVENT_MANAGER:RegisterForEvent("BahseiBossLogic", EVENT_UNIT_DEATH_STATE_CHANGED, function(_, unitTag1, isDead)
        if isDead then
            self:OnGroupMemberDeath(unitTag1)
        end
    end)
    EVENT_MANAGER:AddFilterForEvent("BahseiBossLogic", EVENT_UNIT_DEATH_STATE_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
end
function BahseiBossLogic:OnCombatExit()
    if self.AtLeastOneExplode then
        self:PrintDeadpool()
        chatMsg("-------------------------")
    end
    EVENT_MANAGER:UnregisterForEvent("BahseiBossLogic", EVENT_UNIT_DEATH_STATE_CHANGED)
end
function BahseiBossLogic:OnGroupMemberDeath(unitTag1)
    local _, x1, y1, z1 = GetUnitWorldPosition(unitTag1)
    for i = 1, GROUP_SIZE_MAX do
        local unitTag2 = "group"..i
        if unitTag1 ~= unitTag2 and DoesUnitExist(unitTag2) then
            local _, x2, y2, z2 = GetUnitWorldPosition(unitTag2)
            local dst = 1 + zo_distance3D(x1, y1, z1, x2, y2, z2)
            -- if unit in radius
            if dst <= self.EmbraceOfDeathDistance then
                if self:DoesUnitHaveFreshBuff(unitTag2, self.DeathTouchId) then
                    local killer = GetUnitDisplayName(unitTag2)
                    local msg = self.ExplodeMessages[math.random(#self.ExplodeMessages)]
                    chatMsg(string.format(msg, killer, GetUnitDisplayName(unitTag1)))
                    if self.Deadpool[killer] ~= nil then
                        self.Deadpool[killer] = self.Deadpool[killer] + 1
                    else
                        self.Deadpool[killer] = 1
                    end
                    self.AtLeastOneExplode = true
                end
            end
        end
    end
end
function BahseiBossLogic:DoesUnitHaveFreshBuff(unitTag, buffId)
    local currentTime = GetFrameTimeSeconds()
    for i = 1, GetNumBuffs(unitTag) do
        local buffName, timeStarted, timeEnding, buffSlot, stackCount, iconFilename, buffType, effectType, abilityType, statusEffectType, abilityId, _, castByPlayer = GetUnitBuffInfo(unitTag, i)
        -- is fresh debuff
        if abilityId == buffId and currentTime - timeStarted < 1 then
            return true
        end
    end
    return false
end
--------------------------------------------------------------------------
--- Xalvakka
--------------------------------------------------------------------------
local XalvakkaBossLogic = LibBossMechanicBase:Subclass()
function XalvakkaBossLogic:New(...)
    return LibBossMechanicBase.New(self, ...)
end
function XalvakkaBossLogic:Initialize()
    self.zoneId = RG_ZONE_ID
    self.iconList = {}
end
function XalvakkaBossLogic:OnZoneEnter()
    if #self.iconList == 0 then
        self.iconList = {
            -- 2 floor
            Icon:New(RG_ZONE_ID, 161658, 34500 + 500, 161179, ICON_SQUARETO_PINK),
            Icon:New(RG_ZONE_ID, 159807, 34500 + 500, 158763, ICON_SQUARETO_PINK),
            Icon:New(RG_ZONE_ID, 158659, 34500 + 500, 160797, ICON_SQUARETO_PINK),
            -- 3 floor
            Icon:New(RG_ZONE_ID, 161943, 38500 + 500, 159268, ICON_SQUARETO_PINK),
            Icon:New(RG_ZONE_ID, 159803, 38500 + 500, 161564, ICON_SQUARETO_PINK),
            Icon:New(RG_ZONE_ID, 158790, 38500 + 500, 158695, ICON_SQUARETO_PINK),
        }
    end
end
function XalvakkaBossLogic:GetName()
    return "Xalvakka"
end
function XalvakkaBossLogic:GetShellName()
    return "Volatile Shell"
end
function XalvakkaBossLogic:OnCombatExit()
    EVENT_MANAGER:UnregisterForEvent("XalvakkaBossLogic", EVENT_RETICLE_TARGET_CHANGED)
    for i = #self.iconList, 1, -1 do
        self.iconList[i]:Disable()
    end
end

function XalvakkaBossLogic:OnCombatEnter()

    local currentTargetIsVolatileShell = false

    local function onShellsAppear()
        local currentTargetHP, maxTargetHP, _ = GetUnitPower("boss1", POWERTYPE_HEALTH)
        local percent = 0
        if maxTargetHP ~= 0 then
            percent = (currentTargetHP / maxTargetHP) * 100
        end
        if percent > 40 and percent <= 70 then
            self.iconList[1]:Enable()
            self.iconList[1]:SetText("A")
            self.iconList[2]:Enable()
            self.iconList[2]:SetText("B")
            self.iconList[3]:Enable()
            self.iconList[3]:SetText("C")
        elseif percent <= 40 then
            self.iconList[4]:Enable()
            self.iconList[4]:SetText("A")
            self.iconList[5]:Enable()
            self.iconList[5]:SetText("B")
            self.iconList[6]:Enable()
            self.iconList[6]:SetText("C")
        end
    end

    local function onShellsDisappear()
        for i = #self.iconList, 1, -1 do
            self.iconList[i]:Disable()
        end
    end

    EVENT_MANAGER:RegisterForEvent("XalvakkaBossLogic", EVENT_RETICLE_TARGET_CHANGED, function()
        local targetName = GetUnitName("reticleover")
        if not currentTargetIsVolatileShell and targetName == self:GetShellName() then
            -- activate shell markers
            currentTargetIsVolatileShell = true
            onShellsAppear()
        end
        if currentTargetIsVolatileShell and targetName == self:GetName() then
            -- activate normal mode
            currentTargetIsVolatileShell = false
            onShellsDisappear()
        end
    end)
end
--------------------------------------------------------------------------
--------------------------------------------------------------------------
local TestBossLogic = LibBossMechanicBase:Subclass()
function TestBossLogic:New(...)
    return LibBossMechanicBase.New(self, ...)
end
function TestBossLogic:Initialize()
    self.zoneId = 1051
    self.iconList = {
        Icon:New(1051, 159500, 31450, 93024, ICON_SQUARE_GREEN),
        Icon:New(1051, 157644, 31450, 94208, ICON_SQUARE_GREEN),
        Icon:New(1051, 157224, 31450, 96284, ICON_SQUARE_GREEN),
        Icon:New(1051, 158498, 31450, 97768, ICON_SQUARE_GREEN),
        Icon:New(1051, 160683, 31950, 98145, ICON_SQUARE_GREEN),
        Icon:New(1051, 162071, 31950, 96924, ICON_SQUARE_GREEN),
        Icon:New(1051, 162492, 31950, 94869, ICON_SQUARE_GREEN),
        Icon:New(1051, 161225, 31950, 93351, ICON_SQUARE_GREEN),
    }
end
function TestBossLogic:GetName()
    return "Z'Maja"
end
function TestBossLogic:OnCombatEnter()
    for i = #self.iconList, 1, -1 do
        self.iconList[i]:Enable()
    end
end
function TestBossLogic:OnCombatExit()
    for i = #self.iconList, 1, -1 do
        self.iconList[i]:Disable()
    end
end
--------------------------------------------------------------------------
--Funcs--
--------------------------------------------------------------------------
----- /script dumpCurLoc()
--function dumpCurLoc()
--    --local zoneid, x, y, z = GetUnitWorldPosition("player")
--    --d("x="..x.." | y="..y.." | z="..z)
--    BahseiBossLogic.DoesUnitHaveFreshBuff({}, "player", 61737)
--end
--
----- /script dumpDist("group1")
--function dumpDist(unitTag1)
--    local _, x1, y1, z1 = GetUnitWorldPosition(unitTag1)
--    for i = 1, GROUP_SIZE_MAX do
--        local unitTag2 = "group"..i
--        if unitTag1 ~= unitTag2 and DoesUnitExist(unitTag2) then
--            local _, x2, y2, z2 = GetUnitWorldPosition(unitTag2)
--            local dst = 1 + zo_sqrt(GetDist(x1, y1, z1, x2, y2, z2))
--            d("dist from " .. unitTag1 .. " to " .. unitTag2 .. " = " .. dst)
--        end
--    end
--end
-------------------------------------
--Init--
-------------------------------------
local function init()
    -- LibBossMechanicManager:Register(TestBossLogic:New())

    LibBossMechanicManager:Register(OaxiltsoBossLogic:New())
    LibBossMechanicManager:Register(BahseiBossLogic:New())
    LibBossMechanicManager:Register(XalvakkaBossLogic:New())

end

local function OnAddOnLoaded(_, addonName)
    if addonName == NAME then
        init()
        EVENT_MANAGER:UnregisterForEvent(NAME, EVENT_ADD_ON_LOADED)
    end
end

EVENT_MANAGER:RegisterForEvent(NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)