local HARDCORE = HARDCORE

local Rule = {
    id = "EquipmentCitySkills",
    title = "Skills only in city/town",
    icon = "/esoui/art/icons/ability_uprising.dds",
    defaultEnabled = true
}

local NS = "HARDCORE_EquipmentCitySkills"
Rule.active = false
Rule._hooksInstalled = false

local function IsPlayerInCity()
    if not IsInJusticeEnabledZone() or IsInOutlawZone() or IsInAvAZone() then
        return false
    end

    local zoneIndex, poiIndex = GetCurrentSubZonePOIIndices()
    if not zoneIndex or not poiIndex then
        return false
    end

    local poiName = GetPOIInfo(zoneIndex, poiIndex)
    if not poiName or poiName == "" then
        return false
    end

    local poiType = GetPOIType(zoneIndex, poiIndex)
    return poiType == POI_TYPE_STANDARD or poiType == POI_TYPE_OBJECTIVE
end

local function Announce()
    HARDCORE.ShowAlert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NEGATIVE_CLICK, "HARDCORE: Skills can only be managed in a city/town!")
end

local function Install()
    if Rule._hooksInstalled then
        return
    end

    local scene = SCENE_MANAGER and SCENE_MANAGER:GetScene("skills")
    if scene then
        scene:RegisterCallback("StateChange", function(_, newState)
            if Rule.active and newState == SCENE_SHOWING and not IsPlayerInCity() then
                Announce()
                SCENE_MANAGER:HideCurrentScene()
            end
        end)
    end

    Rule._hooksInstalled = true
end

function Rule:OnEnable()
    self.active = true
    Install()
end

function Rule:OnDisable()
    self.active = false
end

HARDCORE.RuleManager:RegisterRule(Rule)
