local orgGetUnitName = GetUnitName

function GetUnitName(unitTag)
	local name = orgGetUnitName(unitTag)

	if name == "Vulkhel Guard" then
		name = "Vulkhel Guard²"
	end

	return name
end