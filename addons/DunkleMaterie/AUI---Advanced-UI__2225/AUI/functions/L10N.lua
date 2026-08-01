AUI.L10n = {}

function AUI.L10n.GetString(_key)
	local str = AUI.L10n[_key]
	if AUI.String.IsEmpty(str) then	
		return _key
	end
	
	return str
end