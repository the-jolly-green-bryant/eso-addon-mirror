SIMPLEGROUPLEAVE = {}
SIMPLEGROUPLEAVE.version = 0.6
SIMPLEGROUPLEAVE.author = 'DeanGrey, modified by Baertram'

function SimpleGroupLeaveAbandon()
	if not IsUnitGrouped("player") then return end
	GroupLeave()
end
local leaveGroup = SimpleGroupLeaveAbandon

SLASH_COMMANDS["/gl"] 		  	= leaveGroup
SLASH_COMMANDS["/groupl"]		= leaveGroup
SLASH_COMMANDS["/groupleave"] 	= leaveGroup
SLASH_COMMANDS["/leavegroup"] 	= leaveGroup
