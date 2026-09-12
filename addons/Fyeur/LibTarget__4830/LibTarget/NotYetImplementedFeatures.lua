
function LibTG:MultiScanner(name, posList)
	local intersection = {}
	for pIndex, pPos in ipairs(posList) do
		for i = pIndex + 1, #posList do
			local angA, angB = math.rad(pPos["Ang"]/100), math.rad(posList[i]["Ang"]/100)
			local xa, za = pPos["PosX"], pPos["PosZ"]
			local xb, zb = posList[i]["PosX"], posList[i]["PosZ"]
			
			local dxA, dzA = math.sin(angA), math.cos(angA)
			local dxB, dzB = math.sin(angB), math.cos(angB)
			
			local det = dxA * dzB - dzA * dxB
			if math.abs(det) > 0.001 then
				local t = ((xb - xa) * dzB - (zb - za) * dxB) / det 
				local s = ((xa - xb) * dzA - (za - zb) * dxA) / -det
				
				if t < 0 and s < 0 and math.abs(t) < 5400 and math.abs(s) < 5400 then
					local xi = xa + t * dxA
					local zi = za + t * dzA
					
					table.insert(intersection, {xi, zi})
					-- d(string.format("Intersection : %.2f, %.2f", xi, zi)) 
				end
			end
		end
	end
	local clusters = {}
	local r2 = 500000
	for _, p in ipairs(intersection) do
		local found = false
		if clusters then
			for _,c in ipairs(clusters) do
				local dx = p[1] - c[1]
				local dz = p[2] - c[2]
				if dx*dx + dz*dz <= r2 then
					c[3] = c[3] + 1
					c[1] = c[1] + (p[1] - c[1])/c[3]
					c[2] = c[2] + (p[2] - c[2])/c[3]
					found = true
					break
				end
			end
		end
		if not found then
			table.insert(clusters, {p[1], p[2], 1})
		end
	end
	CH.MobPos[name] = {}
	for i, v in ipairs(clusters) do
		if v[3] >= 6 then
			local ZoneId, _, y, _ = GetUnitWorldPosition("player")
			CH.MobPos[name][i] = {ZoneId, v[1], y, v[2], GetFrameTimeSeconds()}
		end
	end
end
