local SCB = SatuveCoordinateBridge

SCB.Encoder = SCB.Encoder or {}
local Encoder = SCB.Encoder

local function AppendUnsigned(bits, value, width)
	value = math.floor(tonumber(value) or 0)
	local maximum = 2 ^ width - 1
	value = SCB.Clamp(value, 0, maximum)
	for bitIndex = width - 1, 0, -1 do
		bits[#bits + 1] = math.floor(value / (2 ^ bitIndex)) % 2
	end
end

local function ReadUnsigned(bits, firstIndex, width)
	local value = 0
	for index = firstIndex, firstIndex + width - 1 do
		value = value * 2 + (bits[index] or 0)
	end
	return value
end

local function BitsToBytes(bits)
	local bytes = {}
	for firstIndex = 1, #bits, 8 do
		bytes[#bytes + 1] = ReadUnsigned(bits, firstIndex, 8)
	end
	return bytes
end

function Encoder:CRC16(bytes)
	local crc = 0xFFFF
	for _, byte in ipairs(bytes) do
		crc = BitXor(crc, BitLShift(byte, 8))
		for _ = 1, 8 do
			if BitAnd(crc, 0x8000) ~= 0 then
				crc = BitXor(BitLShift(crc, 1), 0x1021)
			else
				crc = BitLShift(crc, 1)
			end
			crc = BitAnd(crc, 0xFFFF)
		end
	end
	return crc
end

function Encoder:BuildStatus(coordinatesValid, directionValid, speedValid)
	local status = 0
	if coordinatesValid then status = status + 1 end
	if directionValid then status = status + 2 end
	if speedValid then status = status + 4 end
	return status
end

function Encoder:Encode(fields)
	local payload = {}
	AppendUnsigned(payload, fields.version or SCB.protocolVersion, 8)
	AppendUnsigned(payload, fields.status, 8)
	AppendUnsigned(payload, fields.sequence, 16)
	AppendUnsigned(payload, fields.mapId, 24)
	AppendUnsigned(payload, fields.xEncoded, 20)
	AppendUnsigned(payload, fields.yEncoded, 20)
	AppendUnsigned(payload, fields.directionEncoded, 16)
	AppendUnsigned(payload, fields.speedEncoded, 16)

	local crc = self:CRC16(BitsToBytes(payload))
	local bits = {}
	AppendUnsigned(bits, SCB.Constants.SYNC, 16)
	for _, bit in ipairs(payload) do bits[#bits + 1] = bit end
	AppendUnsigned(bits, crc, 16)
	return bits, crc
end

function Encoder:BuildFrame(position, motion, sequence)
	local coordinatesValid = position and position.coordinatesValid == true
	local directionValid = motion and motion.directionValid == true
	local speedValid = motion and motion.speedValid == true
	local xEncoded = coordinatesValid and SCB.Round(position.x * SCB.Constants.POSITION_SCALE) or 0
	local yEncoded = coordinatesValid and SCB.Round(position.y * SCB.Constants.POSITION_SCALE) or 0
	local direction = motion and SCB.NormalizeAngle(motion.direction) or 0
	local directionEncoded = directionValid and
		SCB.Round(direction / (math.pi * 2) * 65535) or 0
	local speedEncoded = speedValid and SCB.Round((motion.speed or 0) * 100) or 0

	local frame = {
		version = SCB.protocolVersion,
		status = self:BuildStatus(coordinatesValid, directionValid, speedValid),
		sequence = SCB.Clamp(sequence or 0, 0, 65535),
		mapId = coordinatesValid and SCB.Clamp(position.mapId, 0, 0xFFFFFF) or 0,
		xEncoded = SCB.Clamp(xEncoded, 0, 0xFFFFF),
		yEncoded = SCB.Clamp(yEncoded, 0, 0xFFFFF),
		directionEncoded = SCB.Clamp(directionEncoded, 0, 0xFFFF),
		speedEncoded = SCB.Clamp(speedEncoded, 0, 0xFFFF),
		coordinatesValid = coordinatesValid,
		directionValid = directionValid,
		speedValid = speedValid,
		x = coordinatesValid and position.x or 0,
		y = coordinatesValid and position.y or 0,
		direction = direction,
		speed = speedValid and motion.speed or 0,
	}
	frame.bits, frame.crc = self:Encode(frame)
	return frame
end

function Encoder:SelfTest()
	local fields = {
		version = 2,
		status = 7,
		sequence = 123,
		mapId = 456,
		xEncoded = 523481,
		yEncoded = 381927,
		directionEncoded = 13500,
		speedEncoded = 642,
	}
	local bits, crc = self:Encode(fields)
	local bitsAgain, crcAgain = self:Encode(fields)
	local ok = #bits == 160 and #bitsAgain == 160 and crc == crcAgain and crc == 0xF416 and
		ReadUnsigned(bits, 1, 16) == SCB.Constants.SYNC and
		ReadUnsigned(bits, 17, 8) == fields.version and
		ReadUnsigned(bits, 25, 8) == fields.status and
		ReadUnsigned(bits, 33, 16) == fields.sequence and
		ReadUnsigned(bits, 49, 24) == fields.mapId and
		ReadUnsigned(bits, 73, 20) == fields.xEncoded and
		ReadUnsigned(bits, 93, 20) == fields.yEncoded and
		ReadUnsigned(bits, 113, 16) == fields.directionEncoded and
		ReadUnsigned(bits, 129, 16) == fields.speedEncoded and
		ReadUnsigned(bits, 145, 16) == crc
	return ok, crc
end
