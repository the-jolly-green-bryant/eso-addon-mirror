LibAkaUtils = LibAkaUtils or {}

function LibAkaUtils.xyzStringToCoordinatesAndExtra(str)
	local x = LibAkaUtils.GetCoordinate(str, "-x")
	local y = LibAkaUtils.GetCoordinate(str, "-y")
	local z = LibAkaUtils.GetCoordinate(str, "-z")
	local extra = LibAkaUtils.GetExtra(str, "-e")
	return x,y,z,extra
end

function LibAkaUtils.GetCoordinate(str, coordinate)
	local out = nil
	string.replace(str, coordinate.."[0-9]+", function (st)
		out = st
		return ""
	end)
	out = string.replace(out, coordinate, "")
	return out
end

function LibAkaUtils.GetExtra(str, separator)
	local out = nil
	string.replace(str, separator.."[0-9,a-z,A-Z]+", function (st)
		out = st
		return ""
	end)
	out = string.replace(out, separator, "")
	return out
end

function LibAkaUtils.getCameraPositionWithOSI()
	if OSI == nil then
		return nil, nil, nil 
	end
	return GuiRender3DPositionToWorldPosition(OSI.ctrl:Get3DRenderSpaceOrigin())
end

function LibAkaUtils.getDistance(x1,y1,z1,x2,y2,z2)
	if x1 == nil then return math.huge end
	if y1 == nil then return math.huge end
	if z1 == nil then return math.huge end
	if x2 == nil then return math.huge end
	if y2 == nil then return math.huge end
	if z2 == nil then return math.huge end
	local dx = (x2-x1)^2
	local dy = (y2-y1)^2
	local dz = (z2-z1)^2
	return math.sqrt(dx+dy+dz)
end

function LibAkaUtils.getDistanceSquaredUnsafe(x1,y1,z1,x2,y2,z2)
	return ((x2-x1)^2)+((y2-y1)^2)+((z2-z1)^2)
end

function LibAkaUtils.getCameraYaw()
	return GetPlayerCameraHeading()
end

function LibAkaUtils.getCameraPitchWithOSI()
	if OSI == nil then
		return nil 
	end
	local _, pitch = OSI.ctrl:Get3DRenderSpaceForward()
	return pitch * (math.pi / 2)
end

function LibAkaUtils.radToAngle(value)
	return value * 180 / math.pi
end