ChatHotKeys = {}
ChatHotKeys.name = "ChatHotKeys"
ChatHotKeys.version = "1.0.019"
ChatHotKeys.Vars = {}
ChatHotKeys.settings = nil

local chattxt = {}
local em = GetEventManager()

function ChatHotKeys.OnAddOnLoaded(event, addonName)
  if addonName == ChatHotKeys.name then --if its us, handle it
	em:UnregisterForEvent(ChatHotKeys.name, EVENT_ADD_ON_LOADED)
    ChatHotKeys:Initialize()
  end
end

function ChatHotKeys:Initialize()
	ChatHotKeys.CreateChatConfigMenu()
	
	-- SavedVars Variables
    self.Vars.savedVariablesName = 'ChatHotKeys_SavedVariables'
    self.Vars.configVersion      = 1
    self.Vars.configNamespace    = 'GIT'
	self.Vars.profile            = nil
    self.Vars.configDefaults     = {
        ["configVersion"]           = self.Vars.configVersion,
        ["debug"]                   = false,
		["chattxt"]				 = {
						"/s testchat0",
						"/s testchat1",
						"/s testchat2",
						"/s testchat3",
						"/s testchat4",
						"/s testchat5",
						"/s testchat6",
						"/s testchat7",
						"/s testchat8",
						"/s testchat9",
		}
    }  
  
	self.settings = ZO_SavedVars:NewAccountWide(
		self.Vars.savedVariablesName,
		self.Vars.configVersion,
		self.Vars.configNamespace,
		self.Vars.configDefaults,
		self.Vars.profile
	)
end 
 
function ChatHotKeys.DoChatItem(index)
	--d(ChatHotKeys.settings.chattxt[index])
	CHAT_SYSTEM:StartTextEntry(ChatHotKeys.settings.chattxt[index]) 
end  
  
EVENT_MANAGER:RegisterForEvent(ChatHotKeys.name, EVENT_ADD_ON_LOADED, ChatHotKeys.OnAddOnLoaded)