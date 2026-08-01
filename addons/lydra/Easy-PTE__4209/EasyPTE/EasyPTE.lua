EASYPTE = {}
EASYPTE.version = "0.1.1"
EASYPTE.author = 'Lydra'

function EASYPTE.Abandon()
	if not IsUnitInDungeon("player") then return end
	ExitInstanceImmediately()
end

local GetOut = EasyPTEAbandon

SLASH_COMMANDS["/pte"] 		  	= GetOut