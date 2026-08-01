Chess.pieces = {}

function Chess:createPieces()
	-- PAWNS
	for x = 0, 7, 1 do
		Chess:registerPiece("white", "pawn", "white_pawn_"..x)
		Chess:registerPiece("black", "pawn", "black_pawn_"..x)

		Chess:registerPiece("white", "rook", "white_rook_1"..x)
		Chess:registerPiece("black", "rook", "black_rook_1"..x)

		Chess:registerPiece("white", "knight", "white_knight_1"..x)
		Chess:registerPiece("black", "knight", "black_knight_1"..x)

		Chess:registerPiece("white", "bishop", "white_bishop_1"..x)
		Chess:registerPiece("black", "bishop", "black_bishop_1"..x)

		Chess:registerPiece("white", "queen", "white_queen_1"..x)
		Chess:registerPiece("black", "queen", "black_queen_1"..x)
	end

	-- ROOKS, KNIGHTS, BISHOPS
	for x = 0, 2, 1 do
		Chess:registerPiece("white", "rook", "white_rook_"..x)
		Chess:registerPiece("black", "rook", "black_rook_"..x)

		Chess:registerPiece("white", "knight", "white_knight_"..x)
		Chess:registerPiece("black", "knight", "black_knight_"..x)

		Chess:registerPiece("white", "bishop", "white_bishop_"..x)
		Chess:registerPiece("black", "bishop", "black_bishop_"..x)
	end

	-- KINGS, QUEENS
	Chess:registerPiece("white", "queen", "white_queen_0")
	Chess:registerPiece("black", "queen", "black_queen_0")

	Chess:registerPiece("white", "king", "white_king_0")
	Chess:registerPiece("black", "king", "black_king_0")
end

function Chess:getPiece(color, type, id)
	return Chess.pieces[Chess:getPieceID(color, type, id)]
end

function Chess:getPieceId(color, type, id)
	return color.."_"..type.."_"..id
end

function Chess:getPieceById(completeID)
	return Chess.pieces[completeID]
end

function Chess:getPieceColor(pieceName)
	return Chess:split(pieceName, "_")[1]
end

function Chess:getPieceType(pieceName)
	return Chess:split(pieceName, "_")[2]
end

function Chess:getPieceNumber(pieceName)
	return Chess:split(pieceName, "_")[3]
end

function Chess:registerPiece(color, file, id)
	local piece = WINDOW_MANAGER:CreateControl("ChessWin_Piece_"..id, ChessWin, CT_BUTTON)
	piece:SetDimensions(Chess.pieceSize, Chess.pieceSize)
	piece:SetNormalTexture("Chess/Resources/Chess-"..color.."-"..file..".dds")
	piece:SetHidden(true)
	piece:SetDrawLevel(5)
	piece:SetMouseEnabled(false)
	Chess.pieces[id] = piece
end

function Chess:resizePiece(pieceID, size)
	local piece = WINDOW_MANAGER:GetControlByName("ChessWin_Piece_"..pieceID)
	piece:SetDimensions(size, size)
end

function Chess:resizePieces(size)
	-- PAWNS
	for x = 0, 7, 1 do
		Chess:resizePiece("white_pawn_"..x, size)
		Chess:resizePiece("black_pawn_"..x, size)

		Chess:resizePiece("white_rook_1"..x, size)
		Chess:resizePiece("black_rook_1"..x, size)

		Chess:resizePiece("white_knight_1"..x, size)
		Chess:resizePiece("black_knight_1"..x, size)

		Chess:resizePiece("white_bishop_1"..x, size)
		Chess:resizePiece("black_bishop_1"..x, size)

		Chess:resizePiece("white_queen_1"..x, size)
		Chess:resizePiece("black_queen_1"..x, size)
	end

	-- ROOKS, KNIGHTS, BISHOPS
	for x = 0, 2, 1 do
		Chess:resizePiece("white_rook_"..x, size)
		Chess:resizePiece("black_rook_"..x, size)

		Chess:resizePiece("white_knight_"..x, size)
		Chess:resizePiece("black_knight_"..x, size)

		Chess:resizePiece("white_bishop_"..x, size)
		Chess:resizePiece("black_bishop_"..x, size)
	end

	-- KINGS, QUEENS
	Chess:resizePiece("white_queen_0", size)
	Chess:resizePiece("black_queen_0", size)

	Chess:resizePiece("white_king_0", size)
	Chess:resizePiece("black_king_0", size)
end

function Chess:resetPieces()
	for k, v in pairs(Chess.pieces) do
		v:SetHidden(true)
		v:ClearAnchors()
	end
end

