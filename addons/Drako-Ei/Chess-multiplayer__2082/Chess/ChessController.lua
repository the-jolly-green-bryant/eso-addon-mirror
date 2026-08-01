Chess.currentGame = {}
Chess.auxGame = {}
Chess.lastPieceMovement = {}
Chess.currentTurn = "white"
Chess.isSelectingMovement = false
Chess.currentPossibleMovements = {}
Chess.selectionX = nil
Chess.selectionY = nil
Chess.playerColor = "white"
Chess.isActive = false
Chess.selectPromotion = false
Chess.pendingX1 = nil
Chess.pendingY1 = nil
Chess.pendingX2 = nil
Chess.pendingY2 = nil
Chess.enemyLastSquare = nil


function Chess:resetGame()
	-- REMOVE ALL PIECES
	for x = 0, 7, 1 do
		for y = 0, 7, 1 do
			Chess.currentGame[x..","..y] = nil
			Chess.auxGame[x..","..y] = nil
		end
	end
	-- CLEAR HISTORY
	for k in pairs(Chess.lastPieceMovement) do
		Chess.lastPieceMovement[k] = nil
	end
	Chess.enemyLastSquare = nil
	-- RESET TURN
	Chess.currentTurn = "white"
	Chess.selectPromotion = false
	Chess:cancelMovementSelection()
	-- GENERATE PAWNS
	for x = 0, 7, 1 do
		Chess.currentGame[x..",1"] = Chess:getPieceId("white", "pawn", x)
		Chess.currentGame[x..",6"] = Chess:getPieceId("black", "pawn", x)
	end
	-- GENERATE ALL OTHER PIECES
	Chess.currentGame["0,0"] = Chess:getPieceId("white", "rook", 0)
	Chess.currentGame["7,0"] = Chess:getPieceId("white", "rook", 1)
	Chess.currentGame["0,7"] = Chess:getPieceId("black", "rook", 0)
	Chess.currentGame["7,7"] = Chess:getPieceId("black", "rook", 1)

	Chess.currentGame["1,0"] = Chess:getPieceId("white", "knight", 0)
	Chess.currentGame["6,0"] = Chess:getPieceId("white", "knight", 1)
	Chess.currentGame["1,7"] = Chess:getPieceId("black", "knight", 0)
	Chess.currentGame["6,7"] = Chess:getPieceId("black", "knight", 1)

	Chess.currentGame["2,0"] = Chess:getPieceId("white", "bishop", 0)
	Chess.currentGame["5,0"] = Chess:getPieceId("white", "bishop", 1)
	Chess.currentGame["2,7"] = Chess:getPieceId("black", "bishop", 0)
	Chess.currentGame["5,7"] = Chess:getPieceId("black", "bishop", 1)

	Chess.currentGame["3,0"] = Chess:getPieceId("white", "queen", 0)
	Chess.currentGame["4,0"] = Chess:getPieceId("white", "king", 0)

	Chess.currentGame["3,7"] = Chess:getPieceId("black", "queen", 0)
	Chess.currentGame["4,7"] = Chess:getPieceId("black", "king", 0)

	Chess:syncBoard()
end

function Chess:saveGame()
	for x = 0, 7, 1 do
		for y = 0, 7, 1 do
			local spacialName = x..","..y
			Chess.auxGame[spacialName] = Chess.currentGame[spacialName]
		end
	end
end

function Chess:restoreGame()
	for x = 0, 7, 1 do
		for y = 0, 7, 1 do
			local spacialName = x..","..y
			Chess.currentGame[spacialName] = Chess.auxGame[spacialName]
		end
	end
end

function Chess:switchTurn()
	if (Chess.currentTurn == "white") then
		Chess.currentTurn = "black"
	else
		Chess.currentTurn = "white"
	end
end

function Chess:updateTitle()
	if (Chess.currentTurn == Chess.playerColor) then
		Chess:setWindowCaption("|c00FF00Your turn|r")
	else
		Chess:setWindowCaption("|cFF0000Waiting|r")
	end
end

function Chess:startNewGame(channel, color) 
	Chess.room = channel
	Chess.playerColor = color
	Chess:openWindow(color)
	Chess:resetGame()
	Chess:closeLobbyWindow()
end

function Chess:getPieceAt(x, y)
	local spacialName = x..","..y
	return Chess.currentGame[spacialName]
end

function Chess:removePieceAt(x, y)
	local spacialName = x..","..y
	Chess.currentGame[spacialName] = nil
end

function Chess:registerPieceLastMovement(sourceX, sourceY, piece)
	local spacialName = sourceX..","..sourceY
	Chess.lastPieceMovement[piece] = spacialName
end

function Chess:putPieceAt(x, y, piece)
	local spacialName = x..","..y
	Chess.currentGame[spacialName] = piece
end

function Chess:cancelMovementSelection()
	Chess.isSelectingMovement = false
	Chess.currentPossibleMovements = {}
	Chess.selectionX = nil
	Chess.selectionY = nil
	Chess:removeHightLight()
end

function Chess:isInRange(x, y)
	return (x >= 0 and x <= 7 and y >= 0 and y <= 7)
end

function Chess:selectPieceToMove(x, y, squareColor, pieceColor, pieceType, pieceNumber)
	if (pieceColor == Chess.playerColor) then
		Chess.currentPossibleMovements = Chess:getPossibleMovements(x, y, pieceColor, pieceType, pieceNumber, true)
		if (Chess:isListNotEmpty(Chess.currentPossibleMovements)) then
			Chess.selectionX = x
			Chess.selectionY = y
			Chess:removeHightLight()
			for k, v in pairs(Chess.currentPossibleMovements) do
				local vector = Chess:split(v, ",")
				Chess:highLight(vector[1], vector[2])
			end
			Chess:highLight(x, y)
			Chess.isSelectingMovement = true
		end
	end
end

function Chess:isSquareEmpty(x, y)
	if (Chess:getPieceAt(x, y) == nil) then
		return true
	end
	return false
end

function Chess:isAllyAt(x, y, color)
	local pieceName = Chess:getPieceAt(x, y)
	if (pieceName ~= nil) then
		local pieceColor = Chess:getPieceColor(pieceName)
		return pieceColor == color
	end
	return false
end

function Chess:isEnemyAt(x, y, color)
	local pieceName = Chess:getPieceAt(x, y)
	if (pieceName ~= nil) then
		local pieceColor = Chess:getPieceColor(pieceName)
		return pieceColor ~= color
	end
	return false
end

function Chess:isSquareUnderAttack(x, y, color)
	local targetSquareName = x..","..y
	for pieceLocation, pieceName in pairs(Chess.currentGame) do
		local coordsList = Chess:split(pieceLocation, ",")
		local currentX = coordsList[1]
		local currentY = coordsList[2]
		local currentPieceName = pieceName
		local currentPieceColor = Chess:getPieceColor(currentPieceName)
		local currentPieceType = Chess:getPieceType(currentPieceName)
		local currentPieceNumber = Chess:getPieceNumber(currentPieceName)
		if (currentPieceColor ~= color) then
			local possibleMovements = Chess:getPossibleMovements(currentX, currentY, currentPieceColor, currentPieceType, currentPieceNumber, false)
			for _, currentLocation in pairs(possibleMovements) do
				if (currentLocation == targetSquareName) then
					return true
				end
			end
		end
	end
	return false
end

function Chess:hasPieceMoved(pieceName)
	return Chess.lastPieceMovement[pieceName] ~= nil
end

function Chess:move(sourceX, sourceY, targetX, targetY, commitChanges, promotionPiece)

	local pieceName = Chess:getPieceAt(sourceX, sourceY)
	local pieceColor = Chess:getPieceColor(pieceName)
	local pieceType = Chess:getPieceType(pieceName)
	local pieceNumber = Chess:getPieceNumber(pieceName)
	local targetPieceName = pieceName

	if (pieceType == "pawn") then
		local pawnDirection = 1
		if (pieceColor == "black") then
			pawnDirection = -1
		end
		-- EN PASSANT CAPTURE
		if (Chess:isSquareEmpty(targetX, targetY)) then
			Chess:removePieceAt(targetX, targetY-pawnDirection)
		end
		-- QUEEN PROMOTION
		if ((pawnDirection == 1 and targetY >= 7) or (pawnDirection == -1 and targetY <= 0)) then
			targetPieceName = Chess:getPieceId(pieceColor, Chess:getPromotionPieceFromId(promotionPiece), "1"..pieceNumber)
		end
	elseif (pieceType == "king") then
		-- CASTLING
		local leftRook = Chess:getPieceId(pieceColor, "rook", 0)
		local rightRook = Chess:getPieceId(pieceColor, "rook", 1)
		if (sourceX == 4) then
			if (targetX == 2) then
				Chess:removePieceAt(0, targetY)
				Chess:putPieceAt(3, targetY, leftRook)
			elseif (targetX == 6) then
				Chess:removePieceAt(7, targetY)
				Chess:putPieceAt(5, targetY, rightRook)
			end
		end
	end
	Chess:removePieceAt(targetX, targetY)
	Chess:removePieceAt(sourceX, sourceY)
	Chess:putPieceAt(targetX, targetY, targetPieceName)
	if (commitChanges) then
		Chess:registerPieceLastMovement(sourceX, sourceY, targetPieceName)
		Chess:switchTurn()
		if (pieceColor ~= Chess.playerColor) then
			Chess.enemyLastSquare = targetX..","..targetY
		else
			Chess.enemyLastSquare = nil
		end
		Chess:syncBoard()
	end
end

function Chess:fillPossibleMovementsListWithDirection(possibleMovements, sourceX, sourceY, dx, dy, pieceColor)
	local currentX = sourceX + dx
	local currentY = sourceY + dy
	while ((not Chess:isAllyAt(currentX, currentY, pieceColor)) and Chess:isInRange(currentX, currentY)) do
		table.insert(possibleMovements, currentX..","..currentY)
		if (Chess:isEnemyAt(currentX, currentY, pieceColor)) then
			break
		end
		currentX = currentX + dx
		currentY = currentY + dy
	end
end

function Chess:getPieceLocation(pieceName)
	for k, v in pairs(Chess.currentGame) do
		if (v == pieceName) then
			return k
		end
	end
	return nil
end

function Chess:areSquaresEmpty(squareList)
	for k, v in pairs(squareList) do
		if (not Chess:isSquareEmpty(v[1], v[2])) then
			return false
		end
	end
	return true
end

function Chess:areSquaresUnderAttack(squareList, color)
	for k, v in pairs(squareList) do
		if (Chess:isSquareUnderAttack(v[1], v[2], color)) then
			return true
		end
	end
	return false
end
function Chess:fillPossibleMovementsListWithList(possibleMovements, sourceX, sourceY, movementList, pieceColor)
	for k, v in pairs(movementList) do
		local targetX = sourceX+v[1]
		local targetY = sourceY+v[2]
		if (Chess:isInRange(targetX, targetY)) then
			if (not Chess:isAllyAt(targetX, targetY, pieceColor)) then
				table.insert(possibleMovements, targetX..","..targetY)
			end
		end
	end
end

function Chess:getPossibleMovements(x, y, pieceColor, pieceType, pieceNumber, preventCheck)
	local possibleMovements = {}
	local completePieceID = Chess:getPieceId(pieceColor, pieceType, pieceNumber)
	if (pieceType == "pawn") then
		local pawnDirection = 1
		if (pieceColor == "black") then
			pawnDirection = -1
		end
		-- NORMAL PAWN MOVEMENT
		if (Chess:isSquareEmpty(x, y+pawnDirection)) then
			table.insert(possibleMovements, x..","..(y+pawnDirection))
			-- DOUBLE MOVEMENT
			if (Chess:isSquareEmpty(x, y+pawnDirection*2) and (not Chess:hasPieceMoved(completePieceID))) then
				table.insert(possibleMovements, x..","..(y+pawnDirection*2))
			end
		end
		-- LATERAL CAPTURE LEFT
		if (Chess:isEnemyAt(x-1, y+pawnDirection, pieceColor)) then
			table.insert(possibleMovements, (x-1)..","..(y+pawnDirection))
		end
		-- LATERAL CAPTURE RIGHT
		if (Chess:isEnemyAt(x+1, y+pawnDirection, pieceColor)) then
			table.insert(possibleMovements, (x+1)..","..(y+pawnDirection))
		end
		-- EN PASSANT RIGHT
		if (Chess:isEnemyAt(x+1, y, pieceColor)) then
			local enemyPiece = Chess:getPieceAt(x+1, y)
			local enemyPieceType = Chess:getPieceType(enemyPiece)
			if (enemyPieceType == "pawn") then
				local enemyPieceLastExpectedPosition = (x+1)..","..(y+pawnDirection*2)
				if (Chess.lastPieceMovement[enemyPiece] == enemyPieceLastExpectedPosition) then
					table.insert(possibleMovements, (x+1)..","..(y+pawnDirection))
				end
			end
		end
		-- EN PASSANT LEFT
		if (Chess:isEnemyAt(x-1, y, pieceColor)) then
			local enemyPiece = Chess:getPieceAt(x-1, y)
			local enemyPieceType = Chess:getPieceType(enemyPiece)
			if (enemyPieceType == "pawn") then
				local enemyPieceLastExpectedPosition = (x-1)..","..(y+pawnDirection*2)
				if (Chess.lastPieceMovement[enemyPiece] == enemyPieceLastExpectedPosition) then
					table.insert(possibleMovements, (x-1)..","..(y+pawnDirection))
				end
			end
		end
	elseif (pieceType == "knight") then
		local knightLeaps = {{1, 2},{1, -2},{-1, 2},{-1, -2},{2, 1},{2, -1},{-2, 1},{-2, -1}}
		Chess:fillPossibleMovementsListWithList(possibleMovements, x, y, knightLeaps, pieceColor)
	elseif (pieceType == "bishop") then
		Chess:fillPossibleMovementsListWithDirection(possibleMovements, x, y, 1, 1, pieceColor)
		Chess:fillPossibleMovementsListWithDirection(possibleMovements, x, y, 1, -1, pieceColor)
		Chess:fillPossibleMovementsListWithDirection(possibleMovements, x, y, -1, 1, pieceColor)
		Chess:fillPossibleMovementsListWithDirection(possibleMovements, x, y, -1, -1, pieceColor)
	elseif (pieceType == "rook") then
		Chess:fillPossibleMovementsListWithDirection(possibleMovements, x, y, 0, 1, pieceColor)
		Chess:fillPossibleMovementsListWithDirection(possibleMovements, x, y, 0, -1, pieceColor)
		Chess:fillPossibleMovementsListWithDirection(possibleMovements, x, y, 1, 0, pieceColor)
		Chess:fillPossibleMovementsListWithDirection(possibleMovements, x, y, -1, 0, pieceColor)
	elseif (pieceType == "queen") then
		Chess:fillPossibleMovementsListWithDirection(possibleMovements, x, y, 1, 1, pieceColor)
		Chess:fillPossibleMovementsListWithDirection(possibleMovements, x, y, 1, -1, pieceColor)
		Chess:fillPossibleMovementsListWithDirection(possibleMovements, x, y, -1, 1, pieceColor)
		Chess:fillPossibleMovementsListWithDirection(possibleMovements, x, y, -1, -1, pieceColor)
		Chess:fillPossibleMovementsListWithDirection(possibleMovements, x, y, 0, 1, pieceColor)
		Chess:fillPossibleMovementsListWithDirection(possibleMovements, x, y, 0, -1, pieceColor)
		Chess:fillPossibleMovementsListWithDirection(possibleMovements, x, y, 1, 0, pieceColor)
		Chess:fillPossibleMovementsListWithDirection(possibleMovements, x, y, -1, 0, pieceColor)
	elseif (pieceType == "king") then
		local kingMovements = {{1, 0},{0, 1},{-1, 0},{0, -1},{1, 1},{1, -1},{-1, 1},{-1, -1}}
		Chess:fillPossibleMovementsListWithList(possibleMovements, x, y, kingMovements, pieceColor)
		-- CASTLING
		if (preventCheck) then
			if (not Chess:hasPieceMoved(completePieceID)) then
				local targetY = 0
				if (pieceColor == "black") then
					targetY = 7
				end
				local leftRook = Chess:getPieceId(pieceColor, "rook", 0)
				local rightRook = Chess:getPieceId(pieceColor, "rook", 1)
				local mustBeEmptyLeft = {{1, targetY},{2, targetY},{3, targetY}}
				local mustBeSafeLeft = {{2, targetY},{3, targetY}}
				local mustBeEmptyAndSafeRight = {{5, targetY},{6, targetY}}
				if (not Chess:hasPieceMoved(leftRook)) then
					if ((not Chess:areSquaresUnderAttack(mustBeSafeLeft, pieceColor)) and Chess:areSquaresEmpty(mustBeEmptyLeft)) then
						table.insert(possibleMovements, "2,"..targetY)
					end
				end
				if (not Chess:hasPieceMoved(rightRook)) then
					if ((not Chess:areSquaresUnderAttack(mustBeEmptyAndSafeRight, pieceColor)) and Chess:areSquaresEmpty(mustBeEmptyAndSafeRight)) then
						table.insert(possibleMovements, "6,"..targetY)
					end
				end
			end
		end
	end
	-- REMOVE MOVEMENTS THAT WOULD RESULT IN CHECK
	if (preventCheck) then
		for indexMovement, movementName in pairs(possibleMovements) do
			local movementCoords = Chess:split(movementName, ",")
			local movementX = movementCoords[1]*1
			local movementY = movementCoords[2]*1
			local shouldRemoveMovement = false

			Chess:saveGame()
			Chess:move(x, y, movementX, movementY, false, 0)

			local kingLocation = Chess:getPieceLocation(Chess:getPieceId(pieceColor, "king", 0))
			local kingCoords = Chess:split(kingLocation, ",")
			local kingX = kingCoords[1]
			local kingY = kingCoords[2]

			if (Chess:isSquareUnderAttack(kingX, kingY, pieceColor)) then
				shouldRemoveMovement = true
			end

			Chess:restoreGame()

			if (shouldRemoveMovement) then
				possibleMovements[indexMovement] = nil
			end
		end
	end

	return possibleMovements
end

function Chess:getPromotionPieceFromId(promotionPiece)
	local promotionName = "queen"
		if (promotionPiece == 1) then
			promotionName = "rook"
		elseif (promotionPiece == 2) then
			promotionName = "bishop"
		elseif (promotionPiece == 3) then
			promotionName = "knight"
		end
	return promotionName
end 

function Chess:choosePromotionPiece(x)
	Chess:closePromotionWindow()
	Chess:sendMovement(Chess.pendingX1, Chess.pendingY1, Chess.pendingX2, Chess.pendingY2, x)
	Chess:cancelMovementSelection()
end

function Chess:clickSquareAfterSelection(squareColor, x, y)
	if (Chess:listContainsElement(Chess.currentPossibleMovements, x..","..y)) then
		local movingPiece = Chess:getPieceAt(Chess.selectionX, Chess.selectionY)
		if (Chess:getPieceType(movingPiece) == "pawn") then
			if (y <= 0 or y >= 7) then
				Chess.pendingX1 = Chess.selectionX
				Chess.pendingY1 = Chess.selectionY
				Chess.pendingX2 = x
				Chess.pendingY2 = y
				Chess:openPromotionWindow(Chess.currentTurn)
				return
			end
		end
		Chess:sendMovement(Chess.selectionX, Chess.selectionY, x, y, 0)
	end
	Chess:cancelMovementSelection()
end



function Chess:syncBoard()
	Chess:resetPieces()
	Chess:removeHightLight()
	Chess:removeEnemySquare()
	for x = 0, 7, 1 do
		for y = 0, 7, 1 do
			local pieceName = Chess:getPieceAt(x, y)
			if (pieceName ~= nil) then
				local piece = Chess:getPieceById(pieceName)
				local square = Chess:getSquare(x, y)
				Chess:attatchTo(piece, square)
			end
		end
	end
	if (Chess.enemyLastSquare ~= nil) then
		local enemySquareCords = Chess:split(Chess.enemyLastSquare, ",")
		Chess:enemySquare(enemySquareCords[1], enemySquareCords[2])
	end
	Chess:updateTitle()
end