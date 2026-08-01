windexAddon.buildMenuOptions("Chat Window MiniBar", "chatWindowMiniBar", "baseInterface")

function windexAddon.pluginLoadFunctions.chatWindowMiniBar(noToggleCall)
  if windexAddonDB.chatWindowMiniBar and CHAT_SYSTEM and ZO_ChatWindowMinBar and not windexAddon.chatSystemHook then
    ZO_ChatWindowMinBar:SetHidden(true)

    windexAddon.chatSystemHook = CHAT_SYSTEM.Minimize

    function CHAT_SYSTEM:Minimize(...)
      windexAddon.chatSystemHook(self, ...)

      if ZO_ChatWindowMinBar then ZO_ChatWindowMinBar:SetHidden(not windexAddonDB.isDisabled and windexAddonDB.chatWindowMiniBar) end
    end

  elseif windexAddon.chatSystemHook and not windexAddonDB.chatWindowMiniBar then
    windexAddon.pluginToggleFunctions.chatWindowMiniBar()

    CHAT_SYSTEM.Minimize = windexAddon.chatSystemHook
    windexAddon.chatSystemHook   = nil
  end

  if not noToggleCall then windexAddon.pluginToggleFunctions.chatWindowMiniBar() end
end

function windexAddon.pluginToggleFunctions.chatWindowMiniBar()
  if windexAddonDB.chatWindowMiniBar and not windexAddon.chatSystemHook then
    windexAddon.pluginLoadFunctions.chatWindowMiniBar(true)
  end

  if CHAT_SYSTEM and CHAT_SYSTEM:IsMinimized() then
    if ZO_ChatWindowMinBar then ZO_ChatWindowMinBar:SetHidden(not windexAddonDB.isDisabled and windexAddonDB.chatWindowMiniBar) end
  end
end