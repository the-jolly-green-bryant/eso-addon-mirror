function HealerHelper.GetRelativeXYWithRotation(unit1,unit2)
	if not DoesUnitExist(unit1) or not DoesUnitExist(unit2) or IsUnitDead(unit1) or IsUnitDead(unit2) then
		return nil, nil
	end
	local zone1, x1, y1, z1 = GetUnitWorldPosition(unit1)
	local zone2, x2, y2, z2 = GetUnitWorldPosition(unit2)

	if IsUnitInGroupSupportRange(unit2)==false then
		return nil, nil
	end  -- add extra distance because the unit is out of support range

	if zone1~=zone2 then
	    return nil, nil
	else
        local rx = x1 - x2
        local ry = z1 - z2
        local heading = GetPlayerCameraHeading()
        --d("relative("..rx..","..ry..") radians:".. heading)

        local sin = math.sin(heading)
        local cos = math.cos(heading)

        --d("sin("..sin..") cos(".. cos..")")

        local rrx = rx * cos - ry * sin
        local rry = rx * sin + ry * cos

        --d("relativeRot("..rrx..","..rry..")")
        return rrx, rry
	end
end


function HealerHelper.GetDistance(unit1,unit2)
	if not DoesUnitExist(unit1) or not DoesUnitExist(unit2) or IsUnitDead(unit1) or IsUnitDead(unit2) then
		return -1
	end
	local zone1, x1, y1, z1 = GetUnitWorldPosition(unit1)
	local zone2, x2, y2, z2 = GetUnitWorldPosition(unit2)

	local verticalOffset = 0-- this doesn't work for SS portals
    if math.abs((y1-y2)/100)>10 then --  if the player if 10 meters above or below the player, we'll just assume they are too far away to get buffs
        verticalOffset=30 -- add 30 meters to distance so we don't try to buff them
    end

	if IsUnitInGroupSupportRange(unit2)==false then
		verticalOffset=30
	end -- add extra distance because the unit is out of support range


	if zone1~=zone2 then
		return -1, -1, -1
	else
		return(zo_sqrt((x1 - x2)^2 + (z1 - z2)^2) / 100+verticalOffset), x2, z2
	end

	--if zone1~=zone2 then
	--	return -1
	--else
	--	return(zo_sqrt((x1 - x2)^2 + (z1 - z2)^2) / 100)
	--end
end
