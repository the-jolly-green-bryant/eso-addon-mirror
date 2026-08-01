WritCreater = WritCreater or {}

local AddOnManager = GetAddOnManager()
for i = 1, AddOnManager:GetNumAddOns() do
	local name = AddOnManager:GetAddOnInfo(i)
	if name == "DolgubonsLazyWritCreator" then
		WritCreater.patchedVersion = AddOnManager:GetAddOnVersion(i) or 0
		break
	end
end
