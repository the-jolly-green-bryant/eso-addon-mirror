-- ESO Adventurer Suite
-- v0.29.520 - Dungeon Finder HUD state/layout fix.
-- Hide the move/resize helper during normal gameplay and hide the queue HUD
-- completely once the player has entered a dungeon.

local EPC = ESOProgressionCoach
if not EPC or not EPC.DungeonFinder then return end
local D = EPC.DungeonFinder

local function safe(fn, fallback, ...)
    if type(fn) ~= "function" then return fallback end
    local ok, a, b, c, d = pcall(fn, ...)
    if not ok then return fallback end
    return a, b, c, d
end

local function getHint()
    return rawget(_G, "EAS_DungeonQueueHUDHint2768")
end

function D:ApplyQueueHudHintVisibility029519()
    local hint = getHint()
    if hint and type(hint.SetHidden) == "function" then
        hint:SetHidden(self.queueHudLayoutMode2768 ~= true)
    end
end

local baseCreate = D.CreateQueueHud2768
if type(baseCreate) == "function" and not D._easQueueCreateWrapped029519 then
    D._easQueueCreateWrapped029519 = true
    function D:CreateQueueHud2768(...)
        local frame = baseCreate(self, ...)
        self:ApplyQueueHudHintVisibility029519()
        return frame
    end
end

local baseLayout = D.SetLayoutMode
if type(baseLayout) == "function" and not D._easQueueLayoutWrapped029519 then
    D._easQueueLayoutWrapped029519 = true
    function D:SetLayoutMode(active, ...)
        local result = baseLayout(self, active, ...)
        self:ApplyQueueHudHintVisibility029519()
        return result
    end
end

local baseRefresh = D.RefreshQueueHud2768
if type(baseRefresh) == "function" and not D._easQueueRefreshWrapped029519 then
    D._easQueueRefreshWrapped029519 = true
    function D:RefreshQueueHud2768(status, ...)
        local inDungeon = safe(IsUnitInDungeon, false, "player") == true

        -- Once the player is physically inside a dungeon, the queue/search HUD
        -- has served its purpose. Hide it completely even if ESO still reports
        -- a stale QUEUED or IN_PROGRESS Activity Finder status.
        if inDungeon and self.queueHudLayoutMode2768 ~= true then
            local frame = self:CreateQueueHud2768()
            if frame and type(frame.SetHidden) == "function" then frame:SetHidden(true) end
            self:ApplyQueueHudHintVisibility029519()
            return
        end

        local result = baseRefresh(self, status, ...)
        self:ApplyQueueHudHintVisibility029519()
        return result
    end
end

-- Correct the display immediately after loading into/out of a dungeon.
if EVENT_PLAYER_ACTIVATED and EVENT_MANAGER then
    EVENT_MANAGER:RegisterForEvent((EPC.name or "ESOAdventurerSuite") .. "_QueueHudState029519", EVENT_PLAYER_ACTIVATED, function()
        if D and type(D.RefreshQueueHud2768) == "function" then D:RefreshQueueHud2768() end
    end)
end

if type(zo_callLater) == "function" then
    zo_callLater(function()
        if D then
            D:ApplyQueueHudHintVisibility029519()
            if type(D.RefreshQueueHud2768) == "function" then D:RefreshQueueHud2768() end
        end
    end, 700)
end
