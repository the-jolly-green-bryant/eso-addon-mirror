EmoteShortcuts = {}
EmoteShortcuts.name = "EmoteShortcuts"
EmoteShortcuts.version = "1.0"
EmoteShortcuts.Vars = {}
EmoteShortcuts.settings = nil


local emotes = {}
local emoteList = {}


function EmoteShortcuts.OnAddOnLoaded(event, addonName)
  -- The event fires each time *any* addon loads - but we only care about when our own addon loads.
  if addonName == EmoteShortcuts.name then
    EmoteShortcuts:Initialize()
  end
end

function EmoteShortcuts:Initialize()
    
	EmoteShortcuts.CreateConfigMenuX()
	
	-- SavedVars Variables
    self.Vars.savedVariablesName = 'EmoteShortcuts_SavedVariables'
    self.Vars.configVersion      = 1
    self.Vars.configNamespace    = 'EK'
    self.Vars.profile            = nil
    self.Vars.configDefaults     = {
        ["configVersion"]           = self.Vars.configVersion,
        ["debug"]                   = false,
		["emote"]				 = {
						"/cheer",
						"/lol",
						"/torch",
						"/leaveme",
						"/threaten",
						"/thanks",
						"/armscrossed",
						"/beg",
						"/kneelpray",
						"/sit",
		}
    }  
  
	self.settings = ZO_SavedVars:NewAccountWide(
		self.Vars.savedVariablesName,
		self.Vars.configVersion,
		self.Vars.configNamespace,
		self.Vars.configDefaults,
		self.Vars.profile
	)
	
	SLASH_COMMANDS['/emotelist'] = function()
		d(emoteList)
	end
	
end 

function EmoteShortcuts.test(event, addonName)
  d("EmoteShortcuts loaded.")
  
  local numEmotes = GetNumEmotes()
    for e = 1, numEmotes, 1 do
		emotes[GetEmoteSlashNameByIndex(e)] = e
		emoteList[e] = GetEmoteSlashNameByIndex(e)
	end 
end  
  
function EmoteShortcuts.DoEmoteSlot(slot)
	d("Playing "..GetEmoteSlashNameByIndex(emotes[EmoteShortcuts.settings.emote[slot]]))
	PlayEmoteByIndex(emotes[EmoteShortcuts.settings.emote[slot]])
end  
  
-- Finally, we'll register our event handler function to be called when the proper event occurs.
EVENT_MANAGER:RegisterForEvent(EmoteShortcuts.name, EVENT_ADD_ON_LOADED, EmoteShortcuts.OnAddOnLoaded)
EVENT_MANAGER:RegisterForEvent(EmoteShortcuts.name, EVENT_PLAYER_ACTIVATED  , EmoteShortcuts.test)