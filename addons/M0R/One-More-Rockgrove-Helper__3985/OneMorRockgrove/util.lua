local omr = OneMorRockgrove

-- distance weighted mean, xbar = Σ_i(w_i * x_i)/Σ_i(w_i), where w_i = n/Σ_j(|x_i-x_j|), and n = int (usually number of points)
function omr.distanceWeightedMean(positions)
	local avgx = 0
	local avgy = 0
	local weightings = 0
	local n = #positions

	-- do 1 weighting for radius, use to eval both x and y avg
	for i,v in pairs(positions) do
		local ri = math.sqrt(v[1]^2 + v[2]^2) -- radius of point i
		local w = 0
		for j,k in pairs(positions) do
			local rj = math.sqrt(k[1]^2 + k[2]^2) -- radius of point j
			w = w + math.abs(ri-rj)
		end
		w = n/w
		weightings = weightings + w

		avgx = avgx+w*v[1]
		avgy = avgy+w*v[2]
	end

	avgx = avgx/weightings
	avgy = avgy/weightings
	return avgx,avgy
end

-- obtained from https://stackoverflow.com/a/39996227
function omr.insidePolygon(polygon, point)
    local oddNodes = false
    local j = #polygon
    for i = 1, #polygon do
        if (polygon[i][2] < point[2] and polygon[j][2] >= point[2] or polygon[j][2] < point[2] and polygon[i][2] >= point[2]) then
            if (polygon[i][1] + ( point[2] - polygon[i][2] ) / (polygon[j][2] - polygon[i][2]) * (polygon[j][1] - polygon[i][1]) < point[1]) then
                oddNodes = not oddNodes;
            end
        end
        j = i;
    end
    return oddNodes 
end


function omr.sendCSA(message, secondMessage, sound)
	local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, sound)
    messageParams:SetText(message,secondMessage)
    messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_BATTLEGROUND_NEARING_VICTORY)
    messageParams:MarkShowImmediately()
    messageParams:MarkQueueImmediately()
    messageParams:SetLifespanMS(5500)
    CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
end


do
	local Border -- yoinked from Combat Alerts
	local function GetBorder()
		if (not Border) then
			Border = LibCombatAlerts.ScreenBorder:New()
		end
		return Border
	end

	function omr.border(id, duration, colour, enable)
		if enable then
			GetBorder():Enable(colour, duration, id)
		else
			GetBorder():Disable(id)
		end
	end
end