local HARDCORE = HARDCORE

local ID = "NoNpcTalk"
local NS = "HARDCORE_NoNpcTalk"

local ICON_NO_NPC_TALK = "EsoUI/Art/MainMenu/menuBar_social_up.dds"

local Rule = {
    id = ID,
    title = "Silent Pilgrim: no NPC conversations",
    icon = ICON_NO_NPC_TALK,
    defaultEnabled = false
}

Rule.active = false
Rule._hooksInstalled = false
Rule._lastAlertMs = 0

local function IsHardcoreActive()
    return HARDCORE and HARDCORE.saved and HARDCORE.saved.isActive
end

local function AnnounceBlocked()
    local now = GetFrameTimeMilliseconds()
    if now - Rule._lastAlertMs > 1200 then
        Rule._lastAlertMs = now
        HARDCORE.ShowAlertNoSuppression(UI_ALERT_CATEGORY_ALERT, SOUNDS.NEGATIVE_CLICK,
            "HARDCORE: NPC conversations are disabled.")
    end
end

local function EndNpcInteraction()
    EndInteraction(INTERACTION_CONVERSATION)
    EndInteraction(INTERACTION_QUEST)
end

local function BlockNpcTalk()
    EndNpcInteraction()
    AnnounceBlocked()
end

local function ShouldBlockNpcTalk()
    return Rule.active and IsHardcoreActive()
end

local function InstallHooks()
    if Rule._hooksInstalled then
        return
    end

    if not (INTERACT_WINDOW and ZO_PreHook) then
        return
    end

    ZO_PreHook(INTERACT_WINDOW, "ShowInteractWindow", function()
        if ShouldBlockNpcTalk() then
            BlockNpcTalk()
            return true
        end
    end)

    Rule._hooksInstalled = true
end

local function OnNpcDialogueStarted()
    if ShouldBlockNpcTalk() then
        InstallHooks()
        BlockNpcTalk()
    end
end

local function RegisterEvents()
    EVENT_MANAGER:UnregisterForEvent(NS .. "_CHATTER", EVENT_CHATTER_BEGIN)
    EVENT_MANAGER:UnregisterForEvent(NS .. "_QUEST_OFFERED", EVENT_QUEST_OFFERED)
    EVENT_MANAGER:UnregisterForEvent(NS .. "_QUEST_COMPLETE", EVENT_QUEST_COMPLETE_DIALOG)

    EVENT_MANAGER:RegisterForEvent(NS .. "_CHATTER", EVENT_CHATTER_BEGIN, OnNpcDialogueStarted)
    EVENT_MANAGER:RegisterForEvent(NS .. "_QUEST_OFFERED", EVENT_QUEST_OFFERED, OnNpcDialogueStarted)
    EVENT_MANAGER:RegisterForEvent(NS .. "_QUEST_COMPLETE", EVENT_QUEST_COMPLETE_DIALOG, OnNpcDialogueStarted)
end

local function UnregisterEvents()
    EVENT_MANAGER:UnregisterForEvent(NS .. "_CHATTER", EVENT_CHATTER_BEGIN)
    EVENT_MANAGER:UnregisterForEvent(NS .. "_QUEST_OFFERED", EVENT_QUEST_OFFERED)
    EVENT_MANAGER:UnregisterForEvent(NS .. "_QUEST_COMPLETE", EVENT_QUEST_COMPLETE_DIALOG)
end

function Rule:OnEnable()
    self.active = true
    InstallHooks()
    RegisterEvents()
end

function Rule:OnDisable()
    self.active = false
    UnregisterEvents()
end

HARDCORE.RuleManager:RegisterRule(Rule)
