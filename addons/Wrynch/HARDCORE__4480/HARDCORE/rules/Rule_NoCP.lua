local HARDCORE = HARDCORE

local Rule = {
    id = "NoCP",
    title = "No Champion Points UI",
    icon = "/esoui/art/armory/buildicons/buildicon_5.dds",
    defaultEnabled = true,
}

local NS = "HARDCORE_NoCP"
Rule.active = false
Rule._hooksInstalled = false
Rule._lastAlertMs = 0

local BLOCKED_SCENES = {
    ["champion"] = true,
    ["championPerks"] = true,
    ["gamepad_championPerks_root"] = true
}

local function ShouldThrottle()
    local now = GetFrameTimeMilliseconds()
    if (now - Rule._lastAlertMs) > 1200 then
        Rule._lastAlertMs = now
        return false
    end
    return true
end

local function Announce()
    if ShouldThrottle() then return end
    HARDCORE.ShowAlert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NEGATIVE_CLICK, "HARDCORE: Champion Points are disabled.")
end

local function InstallHooks()
    if Rule._hooksInstalled then return end

    local function AttachCloseOnShow(sceneName)
        local scene = SCENE_MANAGER and SCENE_MANAGER:GetScene(sceneName)
        if not scene then return end
        scene:RegisterCallback("StateChange", function(_, newState)
            if Rule.active and newState == SCENE_SHOWING then
                Announce()
                SCENE_MANAGER:HideCurrentScene()
            end
        end)
    end

    for name in pairs(BLOCKED_SCENES) do
        AttachCloseOnShow(name)
    end
    Rule._hooksInstalled = true
end

function Rule:OnEnable()
    self.active = true
    InstallHooks()
end

function Rule:OnDisable()
    self.active = false
end

HARDCORE.RuleManager:RegisterRule(Rule)
