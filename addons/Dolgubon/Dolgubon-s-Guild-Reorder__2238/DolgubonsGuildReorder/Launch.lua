

DolgubonsGuildReorder = DolgubonsGuildReorder or {}
DolgubonsGuildReorder.folderName = "DolgubonsGuildReorder"
DolgubonsGuildReorder.name = "Dolgubon's Guild Re-order"
DolgubonsGuildReorder.versionAccount = 1.1
DolgubonsGuildReorder.defaultAccountWide = 
{
	["guildOrder"] = {1,2,3,4,5},
}

function DolgubonsGuildReorder:reloadKeyOrder()
	for k ,v in pairs(self.savedVarsAccountWide.guildOrder) do
	    self.keyOrder[v] = k
	end
end

function DolgubonsGuildReorder:Initialize ()
	self.savedVarsAccountWide = ZO_SavedVars:NewAccountWide(
		"DolgubonsGuildReorderSavedVars", self.versionAccount, nil, self.defaultAccountWide)
	self.setupReorder()

	self.keyOrder = {}
	DolgubonsGuildReorder:reloadKeyOrder()
	self.setupSettings()
end

local function OnAddOnLoaded(event, addonName)
    if addonName ~= DolgubonsGuildReorder.folderName then return end

	DolgubonsGuildReorder:Initialize()
end

local function resetWarning()
	if DolgubonsGuildReorder.savedVarsAccountWide.didWarn~=DolgubonsGuildReorder.versionAccount then
		DolgubonsGuildReorder.savedVarsAccountWide.didWarn= DolgubonsGuildReorder.versionAccount
		d("Note: Dolgubon's Guild Reorder has reset the saved variables due to an incompatability with the previous version")
	end
end


EVENT_MANAGER:RegisterForEvent(DolgubonsGuildReorder.folderName, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
EVENT_MANAGER:RegisterForEvent(DolgubonsGuildReorder.folderName, EVENT_PLAYER_ACTIVATED, resetWarning)



