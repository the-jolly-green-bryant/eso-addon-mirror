if not ALCINamespace then ALCINamespace = {} end
ALCINamespace.AddOnName = "LibCustomInteract"

ALCI_ON_INTERACT_FOUND_NOT_FOUND = "OnInteractableFoundNotFound"
ALCI_ON_RETICLE_UPDATE = "OnReticleUpdate"

local function OnLoad(e, addOnName)
	if addOnName ~= ALCINamespace.AddOnName then return end

	EVENT_MANAGER:UnregisterForEvent(ALCINamespace.AddOnName, EVENT_ADD_ON_LOADED) 
end
EVENT_MANAGER:RegisterForEvent(ALCINamespace.AddOnName, EVENT_ADD_ON_LOADED, OnLoad)

ALCINamespace["CustomChoiceDialog"] = {
	speaker = "LibCustomInteract",
	text = "<Select an interaction with which to proceed>",
	options = {},
}

local function CreateChoiceDialog(OnInteractFuncTable)
	for i=1, #OnInteractFuncTable do
		ALCINamespace["CustomChoiceDialog"].options[i] = {
			text = zo_strformat("<<<1>>> <<2>>", OnInteractFuncTable[i].name, OnInteractFuncTable[i].action),
			callback = function() zo_callLater(function() OnInteractFuncTable[i].func() end, 1000) end,
			endDialog = true,
		}
	end

	LibCustomDialog.ShowDialog(ALCINamespace["CustomChoiceDialog"])
end

function ALCINamespace:OnInteract()
	local OnInteractFuncTable = {}
	local numPossibleInteractions = 0

	for key, _ in pairs(ALCINamespace.ALCIHookRegister) do		
		if ALCINamespace.ALCIReticleShown[key].result then
			numPossibleInteractions = numPossibleInteractions + 1
			local name = ALCINamespace.ALCIHookRegister[key].addOnName
			local action = ALCINamespace.ALCIReticleShown[key].action
			local OnInteractFunction = ALCINamespace.ALCIHookRegister[key].OnInteractionFunction

			OnInteractFuncTable[numPossibleInteractions] = {name=name, action=action, func=OnInteractFunction}
		end
	end

	if numPossibleInteractions == 1 then
		OnInteractFuncTable[1].func()
	elseif numPossibleInteractions > 1 then
		CreateChoiceDialog(OnInteractFuncTable)
	end
end