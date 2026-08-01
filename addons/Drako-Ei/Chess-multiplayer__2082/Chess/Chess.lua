-- NAMESPACE
Chess = {}

-- PROPERTIES
Chess.name = "Chess"
Chess.room = 0
Chess.online = false
Chess.prefix = 64;

local LDS = LibDataShare
local pingSocket

-- UTILS

local function split(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t={}
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		table.insert(t, str)
	end
	return t
end

-- ENTRY POINT
function Chess.OnAddOnLoaded(event, addonName)
	if addonName == Chess.name then
		Chess:Initialize()
	end
end

function Chess.encodeData(channel, square1, square2)
	return Chess.prefix*1000000 + channel*10000 + square1*100 + square2
end

function Chess.decodeData(data)
	local channel = math.floor(data/10000)%100
	local square1 = math.floor(data/100)%100
	local square2 = data%100
	return channel, square1, square2
end

function Chess.dataHasPrefix(data)
	return math.floor(data/1000000) == Chess.prefix
end

function Chess.OnPingRecived(tag, data, ms)
	if Chess.dataHasPrefix(data) then
		local b0, b1, b2 = Chess.decodeData(data)
		if (Chess.room == b0) then
			local square1 = b1
			local square2 = b2
			local x1 = square1%8
			local y1 = math.floor(square1/8)
			local targetPiece = Chess:getPieceAt(x1, y1)
			if (targetPiece ~= nil) then
				local x2 = square2%8
				local y2 = math.floor(square2/8)
				local promotionPiece = 0
				if (Chess:getPieceType(targetPiece) == "pawn") then
					local pawnDirection = 1
					if (Chess:getPieceColor(targetPiece) == "black") then
						pawnDirection = -1
					end
					if (pawnDirection == 1 and y1 == 6) then
						promotionPiece = y2
						y2 = 7
					elseif (pawnDirection == -1 and y1 == 1) then
						promotionPiece = y2
						y2 = 0
					end
				end
				if (promotionPiece > 3 or promotionPiece < 0) then
					Chess:closeWindow()
					d("[Chess] Wrong data")
				else
					Chess:move(x1, y1, x2, y2, true, promotionPiece)
				end
			else
				Chess:closeWindow()
				d("[Chess] Desync detected: "..tostring(x1)..', '..tostring(y1))
				return
			end
		end
	end
end

function Chess:Initialize()
	-- CREATE GUI
	Chess:createWindow()
	Chess:createPieces()
	
end

function Chess:shareData(share)
	if (Chess.online ~= share) then
		Chess.online = share
		if (share) then
			pingSocket = LDS:RegisterMap("Chess", 31, Chess.OnPingRecived)
		else
			LDS:UnregisterMap(31)
			pingSocket = nil
		end
	end
end

function Chess:sendMovement(x1, y1, x2, y2, promotionPiece)
	if (GetGroupSize() >= 2) then
		local square1 = x1*1 + y1*8
		local square2 = x2*1 + y2*8
		local targetPiece = Chess:getPieceAt(x1, y1)
		if (targetPiece ~= nil) then
			if (Chess:getPieceType(targetPiece) == "pawn") then
				local pawnDirection = 1
				if (Chess:getPieceColor(targetPiece) == "black") then
					pawnDirection = -1
				end
				if ((pawnDirection == 1 and y1 == 6) or (pawnDirection == -1 and y1 == 1)) then
					square2 = x2*1 + promotionPiece*8
				end
			end
		end
		local data = Chess.encodeData(Chess.room, square1, square2)
		Chess.OnPingRecived(nil, data, nil);
		pingSocket:QueueData(data)
	else
		Chess:closeWindow()
		d("[Chess] You are not in a group")
	end
end

-- COMMANDS
SLASH_COMMANDS["/chess"] = function(args)
	if (not Chess.isActive) then
		if (GetGroupSize() >= 2) then
			Chess:openLobbyWindow()
		else
			d("[Chess] You must be in a group")
		end
	else
		d("[Chess] Close the current game to start a new game")
	end
end


-- CALL ENTRY POINT
EVENT_MANAGER:RegisterForEvent(Chess.name, EVENT_ADD_ON_LOADED, Chess.OnAddOnLoaded)	