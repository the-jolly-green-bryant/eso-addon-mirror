local HARDCORE = HARDCORE

local BankRule = {
    id = "NoBank",
    title = "No banks",
    icon = "/esoui/art/vendor/vendor_tabicon_repair_down.dds",
    defaultEnabled = true
}

local GuildStoreRule = {
    id = "NoGuildStore",
    title = "No guild stores",
    icon = "/esoui/art/tutorial/gamepad/gp_playermenu_icon_guilds.dds",
    defaultEnabled = true
}

local NS = "HARDCORE_NoBank"
BankRule.active = false
GuildStoreRule.active = false
local hooksInstalled = false

local function Announce(what)
    local msg = string.format("HARDCORE: %s is disabled.", what or "Banking / Guild Store")
    HARDCORE.ShowAlert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NEGATIVE_CLICK, msg)
end

local function HideIf(name)
    local current = SCENE_MANAGER:GetCurrentScene()
    if current and current.GetName and current:GetName() == name then
        SCENE_MANAGER:HideCurrentScene()
    end
end

local function InstallHooks()
    if hooksInstalled then
        return
    end

    local names = {"bank", "guildBank", "tradinghouse"}
    for _, sceneName in ipairs(names) do
        local scene = SCENE_MANAGER:GetScene(sceneName)
        if scene then
            scene:RegisterCallback("StateChange", function(_, newState)
                local bankBlocked = BankRule.active and (sceneName == "bank" or sceneName == "guildBank")
                local storeBlocked = GuildStoreRule.active and sceneName == "tradinghouse"
                if (bankBlocked or storeBlocked) and newState == SCENE_SHOWING then
                    Announce(sceneName == "tradinghouse" and "Guild Store" or
                             (sceneName == "guildBank" and "Guild Bank" or "Bank"))
                    SCENE_MANAGER:HideCurrentScene()
                end
            end)
        end
    end

    EVENT_MANAGER:RegisterForEvent(NS .. "_BANK", EVENT_OPEN_BANK, function()
        if BankRule.active then
            Announce("Bank")
            if EndInteraction then
                EndInteraction(INTERACTION_BANK)
            end
            HideIf("bank")
        end
    end)

    EVENT_MANAGER:RegisterForEvent(NS .. "_GBANK", EVENT_OPEN_GUILD_BANK, function()
        if BankRule.active then
            Announce("Guild Bank")
            if EndInteraction then
                EndInteraction(INTERACTION_GUILDBANK)
            end
            HideIf("guildBank")
        end
    end)

    EVENT_MANAGER:RegisterForEvent(NS .. "_TH", EVENT_OPEN_TRADING_HOUSE, function()
        if GuildStoreRule.active then
            Announce("Guild Store")
            if EndInteraction then
                EndInteraction(INTERACTION_TRADINGHOUSE)
            end
            HideIf("tradinghouse")
        end
    end)

    EVENT_MANAGER:RegisterForEvent(NS .. "_CHATTER", EVENT_CHATTER_BEGIN, function()
        if BankRule.active and EndInteraction then
            EndInteraction(INTERACTION_BANK)
            EndInteraction(INTERACTION_GUILDBANK)
        end
        if GuildStoreRule.active and EndInteraction then
            EndInteraction(INTERACTION_TRADINGHOUSE)
        end
    end)

    hooksInstalled = true
end

function BankRule:OnEnable()
    self.active = true
    InstallHooks()
end

function BankRule:OnDisable()
    self.active = false
end

function GuildStoreRule:OnEnable()
    self.active = true
    InstallHooks()
end

function GuildStoreRule:OnDisable()
    self.active = false
end

HARDCORE.RuleManager:RegisterRule(BankRule)
HARDCORE.RuleManager:RegisterRule(GuildStoreRule)
