ProvinatusChat = ZO_Object:Subclass()

function ProvinatusChat:New(...)
  if not pChat and Provinatus.SavedVarsAccount.Chat.SaveChatCommands then
    ZO_PreHook(
      "ReloadUI",
      function()
        self:SaveCommandHistory()
      end
    )

    ZO_PreHook(
      "SetCVar",
      function()
        self:SaveCommandHistory()
      end
    )

    ZO_PreHook(
      "Logout",
      function()
        self:SaveCommandHistory()
      end
    )

    ZO_PreHook(
      "Quit",
      function()
        self:SaveCommandHistory()
      end
    )

    if not Provinatus.SavedVarsAccount.Chat.CommandHistory then
      Provinatus.SavedVarsAccount.Chat.CommandHistory = {}
    end

    for k, v in pairs(Provinatus.SavedVarsAccount.Chat.CommandHistory) do
      CHAT_SYSTEM.textEntry:AddCommandHistory(v)
    end
  end

  return ZO_Object.New(self)
end

function ProvinatusChat:SaveCommandHistory()
  if Provinatus.SavedVarsAccount.Chat.SaveChatCommands then
    Provinatus.SavedVarsAccount.Chat.CommandHistory = {}
    local Enumerator = CHAT_SYSTEM.textEntry.commandHistory:GetEnumerator()
    local _, Command = Enumerator()
    local LastCommand
    while Command do
      if Command ~= LastCommand then
        table.insert(Provinatus.SavedVarsAccount.Chat.CommandHistory, Command)
      end

      LastCommand = Command
      _, Command = Enumerator()
    end
  end
end

function ProvinatusChat:GetMenu()
  local Tooltip
  if pChat ~= nil then
    Tooltip = PROVINATUS_CHAT_DISABLE_PCHAT
  else
    Tooltip = PROVINATUS_CHAT_TT
  end
  return ProvinatusMenu.GetSubmenu(
    PROVINATUS_CHAT,
    {
      ProvinatusMenu.GetCheckbox(PROVINATIS_CHAT_SAVE_COMMAND_HISTORY, "Chat", "SaveChatCommands", Tooltip, "full", pChat ~= nil, false, nil, true)
    },
    nil,
    "esoui/art/tutorial/chat-notifications_up.dds"
  )
end
