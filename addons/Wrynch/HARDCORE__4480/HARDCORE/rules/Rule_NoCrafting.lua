local HARDCORE = HARDCORE

local Rule = {
    id = "NoCrafting",
    title = "No crafting stations (except Alchemy & Cooking)",
    icon = "/esoui/art/inventory/inventory_craft_tabicon_active.dds",
    defaultEnabled = true
}

local NS = "HARDCORE_NoCrafting"
Rule.active = false
Rule._hooksInstalled = false

local CRAFTING_SCENES = {
    smithing = true,
    enchanting = true,
    scribing = true,
    scribingKeyboard = true,
    scribingGamepad = true,
    retrait = true,
    retrait_keyboard_root = true,
    retrait_gamepad_root = true,
    retrait_gamepad = true,
    universalDeconstructionSceneKeyboard = true,
    universalDeconstructionSceneGamepad = true
}

local function IsSelfMadeCraftingAllowed(craftSkill, craftMode)
    return HARDCORE and HARDCORE.CanSelfMadeUseCraftingStation and
        HARDCORE.CanSelfMadeUseCraftingStation(craftSkill, craftMode)
end

local function Announce()
    HARDCORE.ShowAlert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NEGATIVE_CLICK, "HARDCORE: Only Alchemy and Cooking are allowed.")
end

local function CleanExit(interactionType)
    zo_callLater(function()
        if IsInteracting and IsInteracting() and EndInteraction then
            EndInteraction(interactionType or INTERACTION_CRAFT)
        end
        if SCENE_MANAGER then
            SCENE_MANAGER:ShowBaseScene()
        end
    end, 60)
end

local function InstallHooks()
    if Rule._hooksInstalled then
        return
    end

    for name in pairs(CRAFTING_SCENES) do
        local scene = SCENE_MANAGER:GetScene(name)
        if scene then
            scene:RegisterCallback("StateChange", function(_, newState)
                if Rule.active and newState == SCENE_SHOWING then
                    if IsSelfMadeCraftingAllowed(GetCraftingInteractionType(), GetCraftingInteractionMode()) then
                        return
                    end
                    Announce()
                    SCENE_MANAGER:HideCurrentScene()
                    CleanExit()
                end
            end)
        end
    end

    EVENT_MANAGER:RegisterForEvent(NS .. "_INTERACT", EVENT_CRAFTING_STATION_INTERACT, function(_, craftSkill, _sameStation, craftMode)
        if not Rule.active then
            return
        end
        if IsSelfMadeCraftingAllowed(craftSkill, craftMode) then
            return
        end
        if craftSkill ~= CRAFTING_TYPE_ALCHEMY and craftSkill ~= CRAFTING_TYPE_PROVISIONING then
            Announce()
            CleanExit()
        end
    end)

    EVENT_MANAGER:RegisterForEvent(NS .. "_RETRAIT", EVENT_RETRAIT_STATION_INTERACT_START, function()
        if not Rule.active then
            return
        end
        Announce()
        CleanExit(INTERACTION_RETRAIT)
    end)

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
