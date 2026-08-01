Flex = {}
 
Flex.name = "Flex"

function Flex.VSS()
	ZO_LinkHandler_InsertLink(ZO_LinkHandler_CreateChatLink(GetAchievementLink, 2435))
end

function Flex.VCR0()
	ZO_LinkHandler_InsertLink(ZO_LinkHandler_CreateChatLink(GetAchievementLink, 2133))
end

function Flex.VCR1()
	ZO_LinkHandler_InsertLink(ZO_LinkHandler_CreateChatLink(GetAchievementLink, 2134))
end

function Flex.VBRP()
	ZO_LinkHandler_InsertLink(ZO_LinkHandler_CreateChatLink(GetAchievementLink, 2363))
end

function Flex.VDSA()
	ZO_LinkHandler_InsertLink(ZO_LinkHandler_CreateChatLink(GetAchievementLink, 1140))
end

function Flex.VMOL()
	ZO_LinkHandler_InsertLink(ZO_LinkHandler_CreateChatLink(GetAchievementLink, 1368))
end

function Flex.NCR3()
	ZO_LinkHandler_InsertLink(ZO_LinkHandler_CreateChatLink(GetAchievementLink, 2132))
end

function Flex:Initialize()

end
 
function Flex.OnAddOnLoaded(event, addonName)
  if addonName == Flex.name then
    Flex:Initialize()
  end
end
 
EVENT_MANAGER:RegisterForEvent(Flex.name, EVENT_ADD_ON_LOADED, Flex.OnAddOnLoaded)


SLASH_COMMANDS["/flex.vcr0"] = Flex.VCR0
SLASH_COMMANDS["/flex.vcr1"] = Flex.VCR1
SLASH_COMMANDS["/flex.vss"] = Flex.VSS 
SLASH_COMMANDS["/flex.vmol"] = Flex.VMOL
SLASH_COMMANDS["/flex.vbrp"] = Flex.VBRP
SLASH_COMMANDS["/flex.vdsa"] = Flex.VDSA
SLASH_COMMANDS["/flex.ncr3"] = Flex.NCR3
