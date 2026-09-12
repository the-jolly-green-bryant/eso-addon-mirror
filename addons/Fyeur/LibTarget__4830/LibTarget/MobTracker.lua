
-- LibTarget : Vérification du bon changement de la table
LibTarget = LibTarget or {}
local LibTG = LibTarget


function LibTG:MonoScanner(num, posList)
	local sumA11, sumA12, sumA22 = 0, 0, 0
	local sumB1, sumB2 = 0, 0
	local life = 999999999

	for _, p in ipairs(posList) do
		local ang = math.rad(p["Ang"]/100)
		local s = math.cos(ang)
		local c = math.sin(ang)

		sumA11 = sumA11 + s * s
		sumA12 = sumA12 - s * c
		sumA22 = sumA22 + c * c

		sumB1 = sumB1 + (s * s * p["PosX"] - s * c * p["PosZ"])
		sumB2 = sumB2 + (-s * c * p["PosX"] + c * c * p["PosZ"])

		if p["currentLife"] < life then life = p["currentLife"] end
	end

	local det = sumA11 * sumA22 - sumA12 * sumA12
	if math.abs(det) > 0.001 then
		local x = (sumB1 * sumA22 - sumB2 * sumA12) / det
		local z = (sumA11 * sumB2 - sumA12 * sumB1) / det	

		local ZoneId, _, y, _ = GetUnitWorldPosition("player")
		
		LibTG.MobPosList[num]["ZoneId"] = ZoneId
		LibTG.MobPosList[num]["PosX"] = x
		LibTG.MobPosList[num]["PosZ"] = z
		LibTG.MobPosList[num]["LastR"] = GetFrameTimeSeconds()
	end
	
	LibTG.MobPosList[num]["maxLife"] = posList[1]["maxLife"]*100
	LibTG.MobPosList[num]["currentLife"] = life*100
	d(life*100)
end


function LibTG:MobTracker()
	for name, num in pairs(LibTG.MobList) do
		if LibTG.MobPosList[num] and LibTG.SwapingInfo[num] then
			local posList = {}
			for _, info in pairs(LibTG.SwapingInfo[num]) do
				if GetFrameTimeSeconds() - info["LastR"] < 2 then table.insert(posList, info) end
			end
			if #posList >= 2 then
				LibTG:MonoScanner(num, posList)
			end
		end
	end
end
