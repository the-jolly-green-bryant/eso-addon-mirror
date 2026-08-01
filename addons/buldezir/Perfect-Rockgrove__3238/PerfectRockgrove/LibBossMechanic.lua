
local function bool2str(boolval)
    return boolval and "true" or "false"
end
-------------------------------------
--Boss Mechanic--
-------------------------------------
LibBossMechanicBase = ZO_Object:Subclass()
function LibBossMechanicBase:New(...)
    local obj = ZO_Object.New(self)
    obj:Initialize(...)
    return obj
end

function LibBossMechanicBase:Initialize()
end
function LibBossMechanicBase:GetZoneId()
    return self.zoneId
end
function LibBossMechanicBase:GetName()
    -- this method can return language-specific boss name using GetCVar("language.2")
end
function LibBossMechanicBase:IsOnBoss()
    -- logic can be modified for edge case like Triplets boss in HOF
    return self:GetName() == GetUnitName("boss1")
end
function LibBossMechanicBase:OnCombatEnter()

end
function LibBossMechanicBase:OnCombatExit()

end
function LibBossMechanicBase:OnZoneEnter()

end
function LibBossMechanicBase:OnZoneExit()

end

-------------------------------------
--Manager--
-------------------------------------
local ObjectPool = ZO_Object:Subclass()
function ObjectPool:New()
    local obj = ZO_Object.New(self)
    obj:Initialize()
    return obj
end
function ObjectPool:Initialize()
    self.pool = {}
    self.currentBossObject = nil
    self.currentZoneId = nil
end

do
    local playerInCombat = false
    local playerIsDeadInCombat = false
    local LazyInited = false

    -- return true if state changed
    local function inCombatCheck(this)
        -- combat state actually changed
        local newState = IsUnitInCombat("player")
        if playerInCombat ~= newState then
            playerInCombat = newState
            if playerInCombat then
                this:OnCombatEnter()
            else
                this:OnCombatExit()
            end
            return true
        end
        return false
    end

    function ObjectPool:LazyInit()
        if not LazyInited then
            LazyInited = true

            -- суммон в бой не вызывает EVENT_PLAYER_ACTIVATED и после суммона EVENT_PLAYER_COMBAT_STATE не сразу идет
            EVENT_MANAGER:RegisterForEvent("LibBossMechanic", EVENT_PLAYER_ACTIVATED, function()
                local newZone = GetZoneId(GetUnitZoneIndex("player"))
                if newZone ~= self.currentZoneId then
                    if self.currentZoneId then
                        self:OnZoneExit(self.currentZoneId)
                    end
                    self:OnZoneEnter(newZone)
                    self.currentZoneId = newZone
                end

                if IsUnitDead("player") and IsUnitInCombat("player") then
                    playerIsDeadInCombat = true
                end
                inCombatCheck(self)
            end)
            --EVENT_MANAGER:RegisterForEvent("LibBossMechanic", EVENT_BOSSES_CHANGED, function(_, forceReset)
            --    --d("EVENT_BOSSES_CHANGED forceReset=" .. bool2str(forceReset))
            --    --d("EVENT_BOSSES_CHANGED inCombat=" .. bool2str(IsUnitInCombat("player")))
            --    --if playerInCombat and self.currentBossObject == nil then
            --    --    -- this expected to fire when u summoned into combat
            --    --    self:OnCombatEnter()
            --    --end
            --end)

            --  если дохнешь последним сначала приходит EVENT_UNIT_DEATH_STATE_CHANGED, потом EVENT_PLAYER_COMBAT_STATE false, то есть выходишь из комбата мертвым

            -- если просто дохнешь а группа дерется, то только EVENT_UNIT_DEATH_STATE_CHANGED
            -- а когда тебя ресают - то приходт EVENT_UNIT_DEATH_STATE_CHANGED, а потом
            -- EVENT_PLAYER_COMBAT_STATE false, и сразу после EVENT_PLAYER_COMBAT_STATE true
            EVENT_MANAGER:RegisterForEvent("LibBossMechanic", EVENT_UNIT_DEATH_STATE_CHANGED, function(_, _, isDead)
                --d("EVENT_UNIT_DEATH_STATE_CHANGED isDead=" .. bool2str(isDead))
                -- если умер и реснули в бою надо обработать ситуацию что приходит ивент выхода из боя, а потом снова вход
                -- а так же если умер и пока лежал - вайп = легитимный выход из боя
                if isDead and IsUnitInCombat("player") then
                    playerIsDeadInCombat = true
                end
            end)
            EVENT_MANAGER:AddFilterForEvent("LibBossMechanic", EVENT_UNIT_DEATH_STATE_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")



            EVENT_MANAGER:RegisterForEvent("LibBossMechanic", EVENT_PLAYER_COMBAT_STATE, function(_, inCombat)
                --d("EVENT_PLAYER_COMBAT_STATE inCombat=" .. bool2str(inCombat))
                --d("EVENT_PLAYER_COMBAT_STATE isDead=" .. bool2str(IsUnitDead("player")))

                if not inCombat and IsUnitDead("player") then
                    -- wipe
                    inCombatCheck(self)
                    playerIsDeadInCombat = false
                    return
                end

                if playerIsDeadInCombat then
                    playerIsDeadInCombat = IsUnitDead("player")
                    -- ignore
                    return
                end

                inCombatCheck(self)
            end)
        end
    end
end
function ObjectPool:OnZoneEnter(zoneId)
    for i = #self.pool, 1, -1 do
        if self.pool[i]:GetZoneId() == zoneId then
            self.pool[i]:OnZoneEnter()
            --d("OnZoneEnter, name=" .. self.pool[i]:GetName())
        end
    end
end
function ObjectPool:OnZoneExit(zoneId)
    for i = #self.pool, 1, -1 do
        if self.pool[i]:GetZoneId() == zoneId then
            self.pool[i]:OnZoneExit()
            --d("OnZoneExit, name=" .. self.pool[i]:GetName())
        end
    end
end
function ObjectPool:OnCombatEnter()
    --d("OnCombatEnter")
    for i = #self.pool, 1, -1 do
        local newBossObj = self.pool[i]
        if newBossObj:IsOnBoss() then
            --d("OnBossSelected, name=" .. newBossObj:GetName())
            self.currentBossObject = newBossObj
            self.currentBossObject:OnCombatEnter()
            break
        end
    end
end
function ObjectPool:OnCombatExit()
    --d("OnCombatExit")
    if self.currentBossObject then
        self.currentBossObject:OnCombatExit()
        self.currentBossObject = nil
    end
end
function ObjectPool:Register(obj)
    self:LazyInit()
    obj.poolIndex = #self.pool + 1
    self.pool[obj.poolIndex] = obj
end
function ObjectPool:Unregister(obj)
    if obj.poolIndex and self.pool[obj.poolIndex] then
        self.pool[obj.poolIndex] = nil
    end
end

LibBossMechanicManager = ObjectPool:New()