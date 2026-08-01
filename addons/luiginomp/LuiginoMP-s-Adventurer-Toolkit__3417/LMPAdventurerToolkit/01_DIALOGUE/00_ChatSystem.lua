LMP_CHAT_SYSTEM = {}

SLASH_COMMANDS["/chatbuffertest"] = function() CHAT_SYSTEM.containers[1].windows[1].buffer:AddMessage("test") end
SLASH_COMMANDS["/chattest"] = function() CHAT_SYSTEM:AddMessage("test") end