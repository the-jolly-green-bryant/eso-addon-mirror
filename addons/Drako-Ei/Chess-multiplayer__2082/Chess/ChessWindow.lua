-- GUI VALUES
Chess.squareSize = 100
Chess.pieceSize = 80
Chess.titlePadding = 50
Chess.desiredColor = nil
Chess.desiredChannel = 1
Chess.sizePreset = 1
Chess.sizePresetCount = 4
Chess.sizePresets = {}

Chess.sizePresets[1] = {
	['squareSize'] = Chess.squareSize,
	['pieceSize'] = Chess.pieceSize,
	['titlePadding'] = Chess.titlePadding,
	['titleSize'] = 1
}

Chess.sizePresets[2] = {
	['squareSize'] = 75,
	['pieceSize'] = 60,
	['titlePadding'] = 45,
	['titleSize'] = 2
}

Chess.sizePresets[3] = {
	['squareSize'] = 50,
	['pieceSize'] = 40,
	['titlePadding'] = 40,
	['titleSize'] = 3
}

Chess.sizePresets[4] = {
	['squareSize'] = 25,
	['pieceSize'] = 20,
	['titlePadding'] = 35,
	['titleSize'] = 4
}


function Chess:createWindow()

	-- LOBBY WINDOW CREATION
	local lobbyWindow = WINDOW_MANAGER:CreateTopLevelWindow("ChessLobby")
	lobbyWindow:SetDrawLayer(2)
	lobbyWindow:SetHidden(true)
	lobbyWindow:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
	lobbyWindow:SetClampedToScreen(true)
	lobbyWindow:SetMovable(true)
	lobbyWindow:SetMouseEnabled(true)
	lobbyWindow:SetDimensions(Chess.squareSize*2, Chess.squareSize*2+Chess.titlePadding + 50)

	-- LOBBY WINDOW BACKGROUND
	WINDOW_MANAGER:CreateControlFromVirtual("ChessLobby_BG", lobbyWindow, "ZO_DefaultBackdrop")

	-- LOBBY WINDOW TITLE
	local lobbyTitle = WINDOW_MANAGER:CreateControl("ChessLobby_Title", ChessLobby, CT_LABEL)
	lobbyTitle:SetText("|cFFFFFFNew game|r")
	lobbyTitle:SetFont("ZoFontWinH1")
	lobbyTitle:SetColor(1, 1, 1, 1)
	lobbyTitle:SetAnchor(TOP, ChessLobby, TOP, 0, 2)

	-- LOBBY CLOSE BUTTON
	local lobbyCloseButton = WINDOW_MANAGER:CreateControl("ChessLobby_Close", ChessLobby, CT_BUTTON)
	lobbyCloseButton:SetDimensions(25, 25)
	lobbyCloseButton:SetAnchor(TOPRIGHT, ChessLobby, TOPRIGHT, -3, 3)
	lobbyCloseButton:SetState(BSTATE_NORMAL)
	lobbyCloseButton:SetHandler("OnClicked", function()
			-- CLICK CLOSE BUTTON
			Chess:closeLobbyWindow()
		end)
	lobbyCloseButton:SetNormalTexture("ESOUI/art/buttons/decline_up.dds")
	lobbyCloseButton:SetMouseOverTexture("ESOUI/art/buttons/decline_over.dds")

	-- LOBBY WINDOW PIECES CREATION
	for x = 0, 1, 1 do

		local squareColor = nil;
			if (x%2 == 0) then
				squareColor = "white"
			else
				squareColor = "black"
			end

		local square = WINDOW_MANAGER:CreateControl("ChessLobby_Square_"..x, ChessLobby, CT_BUTTON)
		square:SetDimensions(Chess.squareSize, Chess.squareSize)
		square:SetState(BSTATE_NORMAL)
		square:SetNormalTexture("Chess/Resources/Chess-"..squareColor.."-unselected.dds")
		square:SetHandler("OnClicked", function()
			-- SELECT COLOR
			Chess.desiredColor = squareColor
			Chess:updateDesiredColor()
		end)
		square:SetAnchor(TOPLEFT, ChessLobby, TOPLEFT, Chess.squareSize*x, Chess.titlePadding)

		local highlight = WINDOW_MANAGER:CreateControl("ChessLobby_HightlightSquare_"..x, ChessLobby, CT_BUTTON)
		highlight:SetDimensions(Chess.squareSize, Chess.squareSize)
		highlight:SetNormalTexture("Chess/Resources/Chess-"..squareColor.."-selected.dds")
		highlight:SetDrawLevel(4)
		highlight:SetMouseEnabled(false)
		highlight:SetAnchor(TOPLEFT, square, TOPLEFT, 0, 0)
		highlight:SetHidden(true)

		local piece = WINDOW_MANAGER:CreateControl("ChessLobby_"..squareColor.."_"..x, ChessLobby, CT_BUTTON)
		piece:SetDimensions(Chess.pieceSize, Chess.pieceSize)
		piece:SetNormalTexture("Chess/Resources/Chess-"..squareColor.."-".."pawn"..".dds")
		piece:SetHidden(true)
		piece:SetDrawLevel(5)
		piece:SetMouseEnabled(false)

		Chess:attatchTo(piece, square)

	end

	-- LOBBY CHANNEL TRACKBAR
	local channelCaption = WINDOW_MANAGER:CreateControl("ChessLobby_ChannelCaption", ChessLobby, CT_LABEL)
	channelCaption:SetAnchor(TOPLEFT, ChessLobby, TOPLEFT, 25, Chess.titlePadding + Chess.squareSize + 25)
	channelCaption:SetText("|cFFFFFFChannel: |r")
	channelCaption:SetFont("ZoFontWinH2")
	channelCaption:SetColor(1, 1, 1, 1)

	local decreaseChannel = WINDOW_MANAGER:CreateControl("ChessLobby_DecreaseChannelNumber", ChessLobby, CT_BUTTON)
	decreaseChannel:SetAnchor(TOPRIGHT, channelCaption, TOPRIGHT, 30, 0)
	decreaseChannel:SetText("|cFFFFFF<|r")
	decreaseChannel:SetFont("ZoFontWinH2")
	decreaseChannel:SetState(BSTATE_NORMAL)
	decreaseChannel:SetDimensions(20, 20)
	decreaseChannel:SetHandler("OnClicked", function()
		Chess.desiredChannel = math.max(1, Chess.desiredChannel - 1)
		Chess:updateDesiredChannel()
	end)

	local channelNumber = WINDOW_MANAGER:CreateControl("ChessLobby_ChannelNumber", ChessLobby, CT_LABEL)
	channelNumber:SetAnchor(TOPRIGHT, decreaseChannel, TOPRIGHT, 20, 0)
	channelNumber:SetText("|cFFFFFF00|r")
	channelNumber:SetFont("ZoFontWinH2")
	channelNumber:SetColor(1, 1, 1, 1)

	local increaseChannel = WINDOW_MANAGER:CreateControl("ChessLobby_IncreaseChannelNumber", ChessLobby, CT_BUTTON)
	increaseChannel:SetAnchor(TOPRIGHT, channelNumber, TOPRIGHT, 20, 0)
	increaseChannel:SetState(BSTATE_NORMAL)
	increaseChannel:SetDimensions(20, 20)
	increaseChannel:SetText("|cFFFFFF>|r")
	increaseChannel:SetFont("ZoFontWinH2")
	increaseChannel:SetHandler("OnClicked", function()
		Chess.desiredChannel = math.min(99, Chess.desiredChannel + 1)
		Chess:updateDesiredChannel()
	end)

	-- START BUTTON
	local startButton = WINDOW_MANAGER:CreateControl("ChessLobby_Start", ChessLobby, CT_BUTTON)
	startButton:SetAnchor(CENTER, ChessLobby, TOP, 0, Chess.titlePadding + Chess.squareSize + 25 + 75)
	startButton:SetState(BSTATE_NORMAL)
	startButton:SetDimensions(100, 100)
	startButton:SetNormalTexture("ESOUI/art/mainmenu/menubar_skills_up.dds")
	startButton:SetMouseOverTexture("ESOUI/art/mainmenu/menubar_skills_over.dds")
	startButton:SetHandler("OnClicked", function()
		if (GetGroupSize() >= 2 and (not Chess.isActive)) then
			if (Chess.desiredColor ~= nil) then
				Chess:startNewGame(Chess.desiredChannel, Chess.desiredColor)
			else
				d("[Chess] Choose a color")
			end
		end
	end)

	-- PROMOTION WINDOW CREATION
	local promotionWindow = WINDOW_MANAGER:CreateTopLevelWindow("ChessProm")
	promotionWindow:SetDrawLayer(2)
	promotionWindow:SetHidden(true)
	promotionWindow:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
	promotionWindow:SetClampedToScreen(true)
	promotionWindow:SetMovable(true)
	promotionWindow:SetMouseEnabled(true)
	promotionWindow:SetDimensions(Chess.squareSize*4, Chess.squareSize*1+Chess.titlePadding)

	-- PROMOTION WINDOW BACKGROUND
	WINDOW_MANAGER:CreateControlFromVirtual("ChessProm_BG", ChessProm, "ZO_DefaultBackdrop")

	-- PROMOTION WINDOW TITLE
	local promotionTitle = WINDOW_MANAGER:CreateControl("ChessProm_Title", ChessProm, CT_LABEL)
	promotionTitle:SetText("|cFFFFFFSelect|r")
	promotionTitle:SetFont("ZoFontWinH1")
	promotionTitle:SetColor(1, 1, 1, 1)
	promotionTitle:SetAnchor(TOP, ChessWin, TOP, 0, 2)

	-- PROMOTION WINDOW PIECES CREATION
	for x = 0, 3, 1 do

		local squareColor = nil;
			if (x%2 == 0) then
				squareColor = "black"
			else
				squareColor = "white"
			end

		local square = WINDOW_MANAGER:CreateControl("ChessProm_Square_"..x, ChessProm, CT_BUTTON)
		square:SetDimensions(Chess.squareSize, Chess.squareSize)
		square:SetState(BSTATE_NORMAL)
		square:SetNormalTexture("Chess/Resources/Chess-"..squareColor.."-unselected.dds")
		square:SetMouseOverTexture("Chess/Resources/Chess-"..squareColor.."-selected.dds")
		square:SetHandler("OnClicked", function()
			-- CLICK CLOSE BUTTON
			Chess:choosePromotionPiece(x)
		end)
		square:SetAnchor(TOPLEFT, ChessProm, TOPLEFT, Chess.squareSize*x, Chess.titlePadding)

		local whitePiece = WINDOW_MANAGER:CreateControl("ChessProm_white_"..x, ChessProm, CT_BUTTON)
		whitePiece:SetDimensions(Chess.pieceSize, Chess.pieceSize)
		whitePiece:SetNormalTexture("Chess/Resources/Chess-".."white".."-"..Chess:getPromotionPieceFromId(x)..".dds")
		whitePiece:SetHidden(true)
		whitePiece:SetDrawLevel(5)
		whitePiece:SetMouseEnabled(false)

		local blackPiece = WINDOW_MANAGER:CreateControl("ChessProm_black_"..x, ChessProm, CT_BUTTON)
		blackPiece:SetDimensions(Chess.pieceSize, Chess.pieceSize)
		blackPiece:SetNormalTexture("Chess/Resources/Chess-".."white".."-"..Chess:getPromotionPieceFromId(x)..".dds")
		blackPiece:SetHidden(true)
		blackPiece:SetDrawLevel(5)
		blackPiece:SetMouseEnabled(false)
	end

	-- WINDOW CREATION
	local window = WINDOW_MANAGER:CreateTopLevelWindow("ChessWin")
	window:SetDrawLayer(1)
	window:SetHidden(true)
	window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
	window:SetClampedToScreen(true)
	window:SetMovable(true)
	window:SetMouseEnabled(true)
	window:SetDimensions(Chess.squareSize*8, Chess.squareSize*8+Chess.titlePadding)

	-- WINDOW BACKGROUND
	WINDOW_MANAGER:CreateControlFromVirtual("ChessWin_BG", ChessWin, "ZO_DefaultBackdrop")

	-- CLOSE BUTTON
	local closeButton = WINDOW_MANAGER:CreateControl("ChessWin_Close", ChessWin, CT_BUTTON)
	closeButton:SetDimensions(25, 25)
	closeButton:SetAnchor(TOPRIGHT, ChessWin, TOPRIGHT, -3, 3)
	closeButton:SetState(BSTATE_NORMAL)
	closeButton:SetHandler("OnClicked", function()
			-- CLICK CLOSE BUTTON
			Chess:closeWindow()
		end)
	closeButton:SetNormalTexture("ESOUI/art/buttons/decline_up.dds")
	closeButton:SetMouseOverTexture("ESOUI/art/buttons/decline_over.dds")

	-- RESIZE BUTTON
	local resizeButton = WINDOW_MANAGER:CreateControl("ChessWin_Resize", ChessWin, CT_BUTTON)
	resizeButton:SetDimensions(25, 25)
	resizeButton:SetAnchor(TOPRIGHT, ChessWin, TOPRIGHT, -3 -30 - 3, 3)
	resizeButton:SetState(BSTATE_NORMAL)
	resizeButton:SetHandler("OnClicked", function()
			-- CLICK CLOSE BUTTON
			local number = Chess.sizePreset + 1
			if (number > Chess.sizePresetCount) then
				number = 1
			end
			Chess.sizePreset = number
			Chess:updateSizes(Chess.playerColor)
		end)
	resizeButton:SetNormalTexture("ESOUI/art/buttons/edit_up.dds")
	resizeButton:SetMouseOverTexture("ESOUI/art/buttons/edit_over.dds")
	

	-- WINDOW TITLE
	local title = WINDOW_MANAGER:CreateControl("ChessWin_Title", ChessWin, CT_LABEL)
	title:SetText("|cFFFFFFChess|r")
	title:SetFont("ZoFontWinH1")
	title:SetColor(1, 1, 1, 1)
	title:SetAnchor(TOP, ChessWin, TOP, 0, 2)

	-- CHESS TABLE CREATION
	for x = 0, 7, 1 do
		for y = 0, 7, 1 do
			local squareColor = nil;
			if ((y+x)%2 == 0) then
				squareColor = "black"
			else
				squareColor = "white"
			end
			local currentX = x
			local currentY = y
			local square = WINDOW_MANAGER:CreateControl("ChessWin_Square_"..x.."_"..y, ChessWin, CT_BUTTON)
			square:SetDimensions(Chess.squareSize, Chess.squareSize)
			square:SetState(BSTATE_NORMAL)
			square:SetNormalTexture("Chess/Resources/Chess-"..squareColor.."-unselected.dds")
			square:SetHandler("OnClicked", function() Chess:clickSquare(squareColor, currentX, currentY) end)
			local highlight = WINDOW_MANAGER:CreateControl("ChessWin_HightlightSquare_"..x.."_"..y, ChessWin, CT_BUTTON)
			highlight:SetDimensions(Chess.squareSize, Chess.squareSize)
			highlight:SetNormalTexture("Chess/Resources/Chess-"..squareColor.."-selected.dds")
			highlight:SetDrawLevel(4)
			highlight:SetMouseEnabled(false)
			highlight:SetAnchor(TOPLEFT, square, TOPLEFT, 0, 0)
			highlight:SetHidden(true)
			local enemySquare = WINDOW_MANAGER:CreateControl("ChessWin_EnemySquare_"..x.."_"..y, ChessWin, CT_BUTTON)
			enemySquare:SetDimensions(Chess.squareSize, Chess.squareSize)
			enemySquare:SetNormalTexture("Chess/Resources/Chess-"..squareColor.."-enemy.dds")
			enemySquare:SetDrawLevel(3)
			enemySquare:SetMouseEnabled(false)
			enemySquare:SetAnchor(TOPLEFT, square, TOPLEFT, 0, 0)
			enemySquare:SetHidden(true)
		end
	end
end

function Chess:openPromotionWindow(color)

	for x = 0, 3, 1 do
		local whitePiece = WINDOW_MANAGER:GetControlByName("ChessProm_white_"..x)
		local blackPiece = WINDOW_MANAGER:GetControlByName("ChessProm_black_"..x)
		whitePiece:SetHidden(true)
		whitePiece:ClearAnchors()
		blackPiece:SetHidden(true)
		blackPiece:ClearAnchors()
	end
	for x = 0, 3, 1 do
		local piece = WINDOW_MANAGER:GetControlByName("ChessProm_"..color.."_"..x)
		local square = WINDOW_MANAGER:GetControlByName("ChessProm_Square_"..x)
		Chess:attatchTo(piece, square)
	end

	ChessProm:SetHidden(false)
end

function Chess:updateDesiredColor()
	local white = WINDOW_MANAGER:GetControlByName("ChessLobby_HightlightSquare_0")
	local black = WINDOW_MANAGER:GetControlByName("ChessLobby_HightlightSquare_1")
	white:SetHidden(true)
	black:SetHidden(true)
	if (Chess.desiredColor == 'white') then
		white:SetHidden(false)
		black:SetHidden(true)
	elseif (Chess.desiredColor == 'black') then
		white:SetHidden(true)
		black:SetHidden(false)
	end
end

function Chess:updateDesiredChannel()
	local number = WINDOW_MANAGER:GetControlByName("ChessLobby_ChannelNumber")
	if (Chess.desiredChannel >= 10) then
		number:SetText("|cFFFFFF"..Chess.desiredChannel.."|r")
	else
		number:SetText("|cFFFFFF0"..Chess.desiredChannel.."|r")
	end
end

function Chess:openLobbyWindow()
	Chess.desiredColor = nil
	Chess.desiredChannel = 1
	Chess:updateDesiredColor()
	Chess:updateDesiredChannel()
	ChessLobby:SetHidden(false)
end

function Chess:closeLobbyWindow()
	ChessLobby:SetHidden(true)
end

function Chess:closePromotionWindow()
	ChessProm:SetHidden(true)
end

function Chess:closeWindow()
	Chess:shareData(false)
	ChessWin:SetHidden(true)
	Chess:closePromotionWindow()
	Chess.isActive = false
end

function Chess:highLight(x, y)
	Chess:setHighLight(x, y, false)
end

function Chess:setHighLight(x, y, value)
	local highlight = WINDOW_MANAGER:GetControlByName("ChessWin_HightlightSquare_"..x.."_"..y)
	highlight:SetHidden(value)
end

function Chess:setEnemySquare(x, y, value)
	local enemySquare = WINDOW_MANAGER:GetControlByName("ChessWin_EnemySquare_"..x.."_"..y)
	enemySquare:SetHidden(value)
end

function Chess:setWindowCaption(text)
	local title = WINDOW_MANAGER:GetControlByName("ChessWin_Title")
	title:SetText(text)
end

function Chess:enemySquare(x, y)
	Chess:setEnemySquare(x, y, false)
end

function Chess:removeEnemySquare()
	for x = 0, 7, 1 do
		for y = 0, 7, 1 do
			Chess:setEnemySquare(x, y, true)
		end
	end
end

function Chess:removeHightLight()
	for x = 0, 7, 1 do
		for y = 0, 7, 1 do
			Chess:setHighLight(x, y, true)
		end
	end
end

function Chess:setSide(color, titlePadding, squareSize)
	for y = 0, 7, 1 do
		-- FIRST SQUARE OF CURRENT ROW (OR Y POSITION)
		local anchorSquare = nil
		for x = 0, 7, 1 do
			local fixedX = x
			local fixedY = 7 - y
			if (color=="black") then
				fixedX = 7 - fixedX
				fixedY = 7 - fixedY
			end
			local currentSquare = WINDOW_MANAGER:GetControlByName("ChessWin_Square_"..fixedX.."_"..fixedY)
			currentSquare:ClearAnchors()
			if (x==0) then
				currentSquare:SetAnchor(TOPLEFT, ChessWin, TOPLEFT, 0, titlePadding + y*squareSize)
				anchorSquare = currentSquare
			else
				currentSquare:SetAnchor(LEFT, anchorSquare, LEFT, x*squareSize, 0)
			end
		end
	end
end

function Chess:clickSquare(color, x, y)
	if (Chess.isSelectingMovement) then
		Chess:clickSquareAfterSelection(color, x, y)
	else
		local pieceName = Chess:getPieceAt(x, y)
		if (pieceName ~= nil) then
			local pieceColor = Chess:getPieceColor(pieceName)
			local pieceType = Chess:getPieceType(pieceName)
			local pieceNumber = Chess:getPieceNumber(pieceName)
			if (Chess.isSelectingMovement == false and Chess.currentTurn == pieceColor and Chess.playerColor == pieceColor) then
				Chess:selectPieceToMove(x, y, color, pieceColor, pieceType, pieceNumber)
			end
		end
	end
end

function Chess:getSquare(x, y)
	return WINDOW_MANAGER:GetControlByName("ChessWin_Square_"..x.."_"..y)
end

function Chess:attatchTo(piece, square)

	local pieceWidth, pieceHeight = piece:GetDimensions()
	local squareWidth, squareHeight = square:GetDimensions()

	local piecePadding = (squareWidth - pieceWidth) / 2
	piece:SetHidden(false)
	piece:ClearAnchors()
	piece:SetAnchor(TOPLEFT, square, TOPLEFT, piecePadding, piecePadding)

end

function Chess:updateSizes(color)
	local sizes = Chess.sizePresets[Chess.sizePreset]
	Chess:resize(color, sizes['squareSize'], sizes['pieceSize'], sizes['titlePadding'], sizes['titleSize'])
end

function Chess:resize(color, squareSize, pieceSize, titlePadding, titleSize)

	ChessWin:SetDimensions(squareSize*8, squareSize*8+titlePadding)

	local title = WINDOW_MANAGER:GetControlByName("ChessWin_Title")
	title:SetFont("ZoFontWinH"..titleSize)

	-- CHESS TABLE RESIZE
	for x = 0, 7, 1 do
		for y = 0, 7, 1 do

			local square = WINDOW_MANAGER:GetControlByName("ChessWin_Square_"..x.."_"..y)
			square:SetDimensions(squareSize, squareSize)
			
			local highlight = WINDOW_MANAGER:GetControlByName("ChessWin_HightlightSquare_"..x.."_"..y)
			highlight:SetDimensions(squareSize, squareSize)

			local enemySquare = WINDOW_MANAGER:GetControlByName("ChessWin_EnemySquare_"..x.."_"..y)
			enemySquare:SetDimensions(squareSize, squareSize)

		end
	end

	Chess:resizePieces(pieceSize)

	Chess:setSide(color, titlePadding, squareSize)

	Chess:syncBoard()
end

function Chess:openWindow(color)
	Chess:shareData(true)
	Chess.sizePreset = 1
	Chess:updateSizes(color)
	Chess:updateTitle()
	ChessWin:SetHidden(false)
	Chess.isActive = true
end