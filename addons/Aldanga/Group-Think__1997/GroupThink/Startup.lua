local ADDON_NAME = 'GroupThink'

GroupThink = ZO_Object:Subclass()

function GroupThink:OnAddOnLoaded(event, addonName)
  if (addonName ~= ADDON_NAME) then
    return
  end

  EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
  self:Initialize()
end

function GroupThink:Initialize()
  GroupThink:ConsoleCommands()
end

local function Election(electionType, message)
  local trimmedParam = string.gsub(message, '%s$', '')
  if trimmedParam == '' then
    d('You must supply an election message.')
  else
    BeginGroupElection(electionType, trimmedParam)
  end
end

function GroupThink:ConsoleCommands()
  SLASH_COMMANDS['/gt'] = function()
    d('Group Think: Easy elections for groups')
    d('Initiate a unanimous vote with /gtvote')
    d('Initiate a majority vote with /gtvotemaj')
    d('Initiate a supermajority vote with /gtvotesup')
  end
  SLASH_COMMANDS['/gtvote'] = function(param)
    Election(GROUP_ELECTION_TYPE_GENERIC_UNANIMOUS, param)
  end
  SLASH_COMMANDS['/gtvotemaj'] = function(param)
    Election(GROUP_ELECTION_TYPE_GENERIC_SIMPLEMAJORITY, param)
  end
  SLASH_COMMANDS['/gtvotesup'] = function(param)
    Election(GROUP_ELECTION_TYPE_GENERIC_SUPERMAJORITY, param)
  end
end

EVENT_MANAGER:RegisterForEvent(
  ADDON_NAME,
  EVENT_ADD_ON_LOADED,
  function(...)
    GroupThink:OnAddOnLoaded(...)
  end
)
