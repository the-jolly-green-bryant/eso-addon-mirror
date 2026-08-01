LibLazy = {}

function LibLazy.values(hashTable)
	local ret = {}
	for k, v in pairs(hashTable) do
		ret[#ret+1] = v
	end
	return ret
end
function LibLazy.keys(hashTable)
	local ret = {}
	for k, v in pairs(hashTable) do
		ret[#ret+1] = k
	end
	return ret
end
function LibLazy.findInArray(array, arg)
	if nil == array or nil == arg then return false end
	for k, v in pairs(array) do
		if (k==arg or v==arg) then 
			return true
		end
	end
	return false
end 
function LibLazy.IsAddonEnabled(addonName) 
	local addonManager = GetAddOnManager() 
	for i = 1, addonManager:GetNumAddOns() do 
		local name, _, _, _, enabled = addonManager:GetAddOnInfo(i) 
		if(string.match(name, addonName) and enabled) then return true end 
	end 
end