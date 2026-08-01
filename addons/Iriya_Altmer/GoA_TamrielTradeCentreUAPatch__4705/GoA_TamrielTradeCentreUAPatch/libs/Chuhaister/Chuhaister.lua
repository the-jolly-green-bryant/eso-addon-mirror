Chuhaister = {
    name = "Chuhaister",
    author = "GoA",
	version = "1.0",
	displayName = "Chuhaister",
	savedVars = {
		language = "",
		APIVersion = 0,
		UpdateNeeded = false,
		UpdateCompleted = false,
		Data = {
			Items =  {},
			Sets = {},
		},
	},
}

function Chuhaister.getItemName(itemLink)
	local itemID = select(4, ZO_LinkHandler_ParseLink(itemLink))
	local itemType = GetItemLinkItemType(itemLink)
	if Chuhaister.savedVars.Data.Items[itemType] == nil then return nil end
	item=Chuhaister.savedVars.Data.Items[itemType][tonumber(itemID)]
	return item
end