local HARDCORE = HARDCORE

local Rule = {
  id = "NoMail",
  title = "No mail",
  icon = "/esoui/art/addons/gamepad/gp_mod_listing_category_mail.dds",
  defaultEnabled = true,
}

local NS = "HARDCORE_NoMail"
Rule.active = false
Rule._hooksInstalled = false

local function Announce()
  HARDCORE.ShowAlert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NEGATIVE_CLICK, "HARDCORE: Mail is disabled.")
end

local function InstallHooks()
  if Rule._hooksInstalled then return end

  local inbox = SCENE_MANAGER:GetScene("mailInbox")
  if inbox then
    inbox:RegisterCallback("StateChange", function(_, newState)
      if Rule.active and newState == SCENE_SHOWING then
        Announce()
        SCENE_MANAGER:HideCurrentScene()
      end
    end)
  end

  local send = SCENE_MANAGER:GetScene("mailSend")
  if send then
    send:RegisterCallback("StateChange", function(_, newState)
      if Rule.active and newState == SCENE_SHOWING then
        Announce()
        SCENE_MANAGER:HideCurrentScene()
      end
    end)
  end

  EVENT_MANAGER:RegisterForEvent(NS.."_MAILBOX", EVENT_MAIL_OPEN_MAILBOX, function()
    if Rule.active then
      Announce()
      if CloseMailbox then
        CloseMailbox()
      end

      local current = SCENE_MANAGER:GetCurrentScene()
      if current then
        local name = current:GetName()
        if name == "mailInbox" or name == "mailSend" then
          SCENE_MANAGER:HideCurrentScene()
        end
      end
    end
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
