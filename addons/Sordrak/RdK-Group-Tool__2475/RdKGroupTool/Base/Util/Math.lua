-- RdK Group Tool Util Math
-- By @s0rdrak (PC / EU)

RdKGTool = RdKGTool or {}
RdKGTool.util = RdKGTool.util or {}
local RdKGToolUtil = RdKGTool.util
RdKGToolUtil.math = RdKGToolUtil.math or {}
local RdKGToolMath = RdKGToolUtil.math

function RdKGToolMath.IsBitFieldPresent(bx, bitfield)
	local isPresent = false
	if bx ~= nil and bitfield ~= nil then
		local hasBitfieldMarkerErrors = false
		
		bx = RdKGToolMath.DecodeBitArrayHelper(bx)
		bitfield = RdKGToolMath.DecodeBitArrayHelper(bitfield)

		for i = 1, #bx do
			if bitfield[i] == 1 and bx[i] == 1 then
				isPresent = true
			elseif bitfield[i] == 1 and bx[i] == 0 then
				hasBitfieldMarkerErrors = true
			end
		end
		if hasBitfieldMarkerErrors == true then
			isPresent = false
		end
	end
	return isPresent
end

function RdKGToolMath.CreateEmptyBitfield(size)
	local array = {}
	if size ~= nil then
		for i = 1, size do
			array[i] = 0
		end
	end
	return array
end

function RdKGToolMath.CopyBitfieldRange(origin, destination, size, originFrom, destinationFrom)
	if origin ~= nil and destination ~= nil and size ~= nil and originFrom ~= nil and destinationFrom ~= nil then
		if destinationFrom + size - 1 <= #destination and originFrom + size - 1 <= #origin then
			--d(originFrom + size - 1)
			for i = 1, size do
				destination[destinationFrom + i - 1] = origin[originFrom + i - 1]
			end
		end
	end
	return destination
end

function RdKGToolMath.BitToBoolean(value)
	local retVal = nil
		if value == 0 then
			retVal = false
		elseif value == 1 then
			retVal = true
		end
	return retVal
end

function RdKGToolMath.BooleanToBit(value)
	local retVal = 0
	if value == true then
		retVal = 1
	end
	return retVal
end

function RdKGToolMath.Int32ToArray(int32)
	return RdKGToolMath.IntToArray(int32, 4294967295, 31)
end

function RdKGToolMath.IntToArray(int, maxVal, exponent)
	local array = {}
	if int ~= nil and int <= maxVal then
		--d(int)
		for i = exponent, 0, -1 do
			if int >= 2 ^ i then
				array[i + 1] = 1
				int = int - (2 ^ i)
				--d(int)
			else
				array[i + 1] = 0
			end
		end
	end
	return array
end

function RdKGToolMath.Int24ToArray(int24)
	return RdKGToolMath.IntToArray(int24, 16777215, 23)
	--[[
	local array = {}
	if int24 ~= nil and int24 <= 16777215 then
		--d(int24)
		for i = 23, 0, -1 do
			if int24 >= 2 ^ i then
				array[i + 1] = 1
				int24 = int24 - (2 ^ i)
				--d(int24)
			else
				array[i + 1] = 0
			end
		end
	end
	return array
	]]
end

function RdKGToolMath.ArrayToInt24(array)
	--[[
	1			00000000 00000000 00000001
	2			00000000 00000000 00000010
	4			00000000 00000000 00000100
	8			00000000 00000000 00001000
	16			00000000 00000000 00010000
	32			00000000 00000000 00100000
	64			00000000 00000000 01000000
	128			00000000 00000000 10000000
	256			00000000 00000001 00000000
	512			00000000 00000010 00000000
	1024		00000000 00000100 00000000
	2048		00000000 00001000 00000000
	4096		00000000 00010000 00000000
	8192		00000000 00100000 00000000
	16384		00000000 01000000 00000000
	32768		00000000 10000000 00000000
	65536		00000001 00000000 00000000
	131072		00000010 00000000 00000000
	262144		00000100 00000000 00000000
	524288		00001000 00000000 00000000
	1048576		00010000 00000000 00000000
	2097152		00100000 00000000 00000000
	4194304		01000000 00000000 00000000
	8388608		10000000 00000000 00000000
	]]
	local retVal = 0
	if array ~= nil then
		for i = 1, #array do
			if array[i] == 1 then
				retVal = retVal + 2 ^ (i - 1)
			end
		end
	end
	return retVal
end

function RdKGToolMath.EncodeBitArrayHelper(array, offset)
	--[[
	1       0x1     00000001
	2       0x2     00000010
	4       0x4     00000100
	8       0x8     00001000
	16      0x10    00010000
	32      0x20    00100000
	64      0x40    01000000
	128     0x80    10000000
	]]
	local bx = 0
	if array[1 + offset] == 1 then
		bx = bx + 1
	end
	if array[2 + offset] == 1 then
		bx = bx + 2
	end
	if array[3 + offset] == 1 then
		bx = bx + 4
	end
	if array[4 + offset] == 1 then
		bx = bx + 8
	end
	if array[5 + offset] == 1 then
		bx = bx + 16
	end
	if array[6 + offset] == 1 then
		bx = bx + 32
	end
	if array[7 + offset] == 1 then
		bx = bx + 64
	end
	if array[8 + offset] == 1 then
		bx = bx + 128
	end
	return bx
end

function RdKGToolMath.DecodeBitArrayHelper(bx)
	local array = {}
	if bx >= 128 then
		bx = bx - 128
		array[8] = 1
	else
		array[8] = 0
	end
	if bx >= 64 then
		bx = bx - 64
		array[7] = 1
	else
		array[7] = 0
	end
	if bx >= 32 then
		bx = bx - 32
		array[6] = 1
	else
		array[6] = 0
	end
	if bx >= 16 then
		bx = bx - 16
		array[5] = 1
	else
		array[5] = 0
	end
	if bx >= 8 then
		bx = bx - 8
		array[4] = 1
	else
		array[4] = 0
	end
	if bx >= 4 then
		bx = bx - 4
		array[3] = 1
	else
		array[3] = 0
	end
	if bx >= 2 then
		bx = bx - 2
		array[2] = 1
	else
		array[2] = 0
	end
	if bx >= 1 then
		bx = bx - 1
		array[1] = 1
	else
		array[1] = 0
	end
	return array
end

function RdKGToolMath.FloatingPointToByte(value)
	--[[
	if value ~= nil and value >= 0 and value <= 1 then
		return math.floor(value * 255)
	end
	return nil]]
	return RdKGToolMath.FloatingPointToValue(value, 255)
end

function RdKGToolMath.ByteToFloatingPoint(value)
	--[[
	if value ~= nil and value >= 0 and value <= 255 then
		return 1 / 255 * value
	end
	return nil
	]]
	return RdKGToolMath.ValueToFloatingPoint(value, 255)
end

function RdKGToolMath.ValueToFloatingPoint(value, base)
	if value ~= nil and base ~= nil and value >= 0 and value <= base then
		return 1 / base * value
	end
	return nil
end

function RdKGToolMath.FloatingPointToValue(value, base)
	if value ~= nil and base ~= nil and value >= 0 and value <= base then
		return math.floor(value * base)
	end
	return nil
end

function RdKGToolMath.FourBitValueToHex(value)
	local hex = {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F"}
	if value == nil or type(value) ~= "number" or value < 0 or value > 15 then
		return nil
	end
	return hex[value + 1]
end

function RdKGToolMath.ByteToHex(value)
	if value == nil then
		return nil
	end
	if type(value) ~= "table" then
		value = RdKGToolMath.DecodeBitArrayHelper(value)
	end
	local bitfield = RdKGToolMath.CreateEmptyBitfield(4)
	local rValue = RdKGToolMath.FourBitValueToHex(RdKGToolMath.EncodeBitArrayHelper(RdKGToolMath.CopyBitfieldRange(value, bitfield, 4, 1, 1), 0))
	local lValue = RdKGToolMath.FourBitValueToHex(RdKGToolMath.EncodeBitArrayHelper(RdKGToolMath.CopyBitfieldRange(value, bitfield, 4, 5, 1), 0))
	if rValue ~= nil and lValue ~= nil then
		return lValue .. rValue
	end
	return nil
end

function RdKGToolMath.Int32ToHex(value)
	if value ~= nil and value <= 4294967295 then
		local byte1 = math.floor(value / 16777216)
		local byte2 = math.floor((value % 16777216) / 65536)
		local byte3 = math.floor((value % 65536) / 256)
		local byte4 = value % 256
		byte1 = RdKGToolMath.ByteToHex(byte1)
		byte2 = RdKGToolMath.ByteToHex(byte2)
		byte3 = RdKGToolMath.ByteToHex(byte3)
		byte4 = RdKGToolMath.ByteToHex(byte4)
		if byte1 ~= nil and byte2 ~= nil and byte3 ~= nil and byte4 ~= nil then
			return byte1 .. byte2 .. byte3 .. byte4
		end
	end
	return nil
end

function RdKGToolMath.HexToFourBitValue(value)
	local hex = {["1"] = 1, ["2"] = 2, ["3"] = 3, ["4"] = 4, ["5"] = 5, ["6"] = 6, ["7"] = 7, ["8"] = 8, ["9"] = 9, ["A"] = 10, ["B"] = 11, ["C"] = 12, ["D"] = 13, ["E"] = 14, ["F"] = 15}
	if type(value) ~= "string" and string.len(value) ~= 1 then
		return nil
	end
	return hex[value]
end

function RdKGToolMath.HexToByte(value)
	if type(value) ~= "string" and string.len(value) ~= 2 then
		return nil
	end
	local rValue = RdKGToolMath.HexToFourBitValue(value:sub(2))
	local lValue = RdKGToolMath.HexToFourBitValue(value:sub(1,1))
	if lValue ~= nil and rValue ~= nil then
		local bitfield = RdKGToolMath.CreateEmptyBitfield(8)
		bitfield = RdKGToolMath.CopyBitfieldRange(RdKGToolMath.DecodeBitArrayHelper(rValue), bitfield, 4, 1, 1)
		bitfield = RdKGToolMath.CopyBitfieldRange(RdKGToolMath.DecodeBitArrayHelper(lValue), bitfield, 4, 1, 5)
		return RdKGToolMath.EncodeBitArrayHelper(bitfield, 0)
	end
	return nil
end

function RdKGToolMath.HexToInt32(value)
	if value ~= nil and string.len(value) <= 8 then
		if string.len(value) ~= 8 then
			local prefix = ""
			for i = string.len(value), 8 do
				prefix = prefix + "0"
			end
			value = prefix .. value
		end
		local byte1 = RdKGToolMath.HexToByte(value:sub(1,2))
		local byte2 = RdKGToolMath.HexToByte(value:sub(3,4))
		local byte3 = RdKGToolMath.HexToByte(value:sub(5,6))
		local byte4 = RdKGToolMath.HexToByte(value:sub(7,8))
		if byte1 ~= nil and byte2 ~= nil and byte3 ~= nil and byte4 ~= nil then
			return byte1 * 16777216 + byte2 * 65536 + byte3 * 256 + byte3
		end
	end
	return nil
end