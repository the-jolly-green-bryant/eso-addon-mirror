--Would like to have a function someone can call where they pass in a Control and some Data, and we fill that control with a QRCode representing that Data.
LibQRCode = LibQRCode or {}
local lib = LibQRCode

lib.name = "LibQRCode"
lib.version = 1
lib.svVersion = 0

local MAJOR, MINOR = lib.name, lib.version

local floatingWindow = nil
local qrContainer = nil

--We'd like to leave a border of at least one white "pixel" (however big we decide a pixel is) so that the QRCode can be cleanly detected.  Remove distortion so that if parentX and Y are not the same, we still have square pixels
local function GetPixelSize(parentX, parentY, rowcount, colcount)

	--however many columns we have, we want to split the parentX into that many columns Plus 2.
	--Same with rows, split parentY into that many rows Plus 2.  This will give at least one pixel border
	local pxX = parentX / (colcount+2)
	local pxY = parentY / (rowcount+2)
	
	--attempt to remove distortion by making the pixels square, simply take the smaller of the two
	local pxSize = math.min(pxX, pxY)
	-- round to the nearest multiple of 0.5 that's lower than the computed pixel size
	-- this will make the pixels square-enough, while also mostly removing distortion from having pixel size values
	-- that don't align well on pixel boundaries.  We could make this just a pure integer by doing 
	-- math.floor(math.min(pxX, pxY))
	-- but for QR Codes with a lot of data in them, that can cause the margins to become much larger than they need to be.
	return math.floor(pxSize*2)/2 
end

function LibQRCode.CreateQRControl(size, data)
	local control = WINDOW_MANAGER:CreateControl(nil, GuiRoot, CT_TEXTURE)
	--Draw Tier for the control should be low, we set the background to blank white, then draw the QR Code on top, and the background
	--acts as a ring of white pixels around the QR Code for ease-of-detection
	control:SetDrawTier(DT_LOW)
	control:SetDimensions(size, size)
	LibQRCode.DrawQRCode(control, data)
	return control
end

local function DrawStrip(composite, surfaceNum, left, right, top, bottom)
	composite:AddSurface(left, right, top, bottom)
	composite:SetInsets(surfaceNum, left, right, top, bottom)
	composite:SetColor(surfaceNum, 0, 0, 0, 1) -- black
end

local function DrawQRCodeWithCompositeTexture(control, qr_table)

	--reuse the container control if we've already created one with the given name.
	local parentControlName = control:GetName()
	if parentControlName == nil then
		parentControlName = "Default"
	end
	--use the global WindowManager GetControl() function to avoid issues with duplicate control names.
	local composite = WINDOW_MANAGER:GetControlByName(parentControlName .. "QRComposite")
	--if we've already created a composite for this parent, use that, otherwise, create one.
	
	if composite == nil then
		--d("Creating new composite")
		composite = WINDOW_MANAGER:CreateControl(parentControlName .. "QRComposite", control, CT_TEXTURECOMPOSITE)
	else
		--d("Found existing composite with ".. composite:GetNumSurfaces() .. " surfaces")
		composite:ClearAllSurfaces()
	end
	composite:SetParent(control)
	composite:SetDrawTier(control:GetDrawTier())
	composite:SetDrawLayer(DL_OVERLAY)
	composite:SetPixelRoundingEnabled(false)
	--d("Composite has " .. composite:GetNumSurfaces() .. " surfaces")
	
	local rowcount = #qr_table
	local colcount = #qr_table[1]
	local parentX, parentY = control:GetDimensions()
	--place a white border around the QRCode for easy detection
	local pxSize = GetPixelSize(parentX, parentY, rowcount, colcount)
	--d("QR Pixel Size is " .. pxSize)
	
	local yOffset = (parentY - (pxSize * rowcount)) / 2
	local xOffset = (parentX - (pxSize * colcount)) / 2
	
	composite:SetAnchor(TOPLEFT, control, TOPLEFT, xOffset, yOffset)
	composite:SetAnchor(BOTTOMRIGHT, control, BOTTOMRIGHT, -xOffset, -yOffset)
	
	--set the background of the parent control to white
	control:SetColor(1, 1, 1, 1)
	
	local width = composite:GetWidth()
	local height = composite:GetHeight()
	--d("Composite Width " .. width .. " and Height " .. height)
	
	local surfaceNum = 1
	--TextureComposite surfaces need to use Insets in order to place them in the CompositeControl correctly
	--The coordinates of the surface don't particularly seem to matter, but the Insets do.

	--Draw the QR Code's surface textures in Strips, to reduce the number of Surfaces we create and reduce the memory footprint
	--Whenever we find a black pixel, we set the Left side to that if it's the first black pixel we encounter after a white pixel
	--and whenever we find a white pixel, we render the strip and reset the Left tracker.
	for rownum,row_array in ipairs(qr_table) do
		--the Top inset will be non-negative, just the number of pixels from the Top of the composite
		local top = ((rownum-1)*pxSize)
		--The bottom inset will be non-positive, the number of pixels from the Bottom of the Composite
		--which is just the negation of: (Composite Height) - (the location of the Top inset) - (the size of the pixel)
		local bottom = top - height + pxSize -- this is just a rearranged version of: -(height - top - pxSize)
		
		local left = nil
		for colnum,cellValue in ipairs(row_array) do
			if cellValue > 0 then
				--the Left inset will be non-negative, just the number of pixels from the left side of the Composite
				--only set the Left value if we haven't started setting it for the current strip.
				if left == nil then
					left = ((colnum-1)*pxSize)
				end
				
			else
				--if this should be a white pixel, then draw the strip of black pixels leading up to this white pixel
				--if left is nil, then it's multiple white pixels in a row.
				if left ~= nil then
					--the Right inset will be non-positive, the number of pixels from the right side of the Composite
					--which is just the negation of: (Composite Width) - (the location of the right side of the left inset)
					local columnOffset = (colnum-1)*pxSize
					local right = columnOffset - width -- this is rearranged:  -(width - columnOffset)
					DrawStrip(composite, surfaceNum, left, right, top, bottom)
					surfaceNum = surfaceNum + 1
				end
				left = nil
			end
		end
		--if we're at the end of the row and we have Left defined (so we have some black pixels)
		if left ~= nil then
			local right = 0 --we're at the end of the row, the right inset is just zero
			DrawStrip(composite, surfaceNum, left, right, top, bottom)
			surfaceNum = surfaceNum + 1
		end
	end
	--d("Rendered QR Code using " .. composite:GetNumSurfaces() .. " surfaces")
end

--Control should be a TextureControl
--data should be a string
function LibQRCode.DrawQRCode(control, data)
	if control:GetType() ~= CT_TEXTURE then
		error("Expected a ControlTexture (Type="..CT_TEXTURE.."), but found Type="..control:GetType())
	end
	local ok, qr_table = qrcode(data, 2)
	if ok then
		DrawQRCodeWithCompositeTexture(control, qr_table)
	else
		d("failed to generate qr code from input data")
	end
end

local function DrawQRCode_Floating(data)
	local defaultTextureSize = 200
	local defaultHeaderHeight = 30
	local defaultXInset = 5
	local defaultYInset = 5
	if floatingWindow == nil then
		--Create a basic window to hold the QR code
		floatingWindow = WINDOW_MANAGER:CreateTopLevelWindow("LibQRCodeWindow")
		--these dimensions will make the QRCode a square accounting for the headers and offsets in the window.
		floatingWindow:SetDimensions(defaultTextureSize + 2*defaultXInset, defaultTextureSize + defaultHeaderHeight + 3 * defaultYInset)
		floatingWindow:SetAnchor(CENTER)
		floatingWindow:SetMovable(true)
		floatingWindow:SetMouseEnabled(true)
		floatingWindow:SetClampedToScreen(true)
		--make a simple window title
		local header = WINDOW_MANAGER:CreateControl("LibQRWindowTitle", floatingWindow, CT_LABEL)
		header:SetText("LibQRCode")
		header:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
		header:SetDimensions(defaultTextureSize, defaultHeaderHeight)
		header:SetColor(0.5, 0.5, 1, 1) -- a nice blue color
		header:SetAnchor(TOP, floatingWindow, TOP, 0, defaultYInset)
		header:SetFont("ZoFontAnnounceMedium")
		--attach a backdrop to make the window easy to move around.
		local backdrop = WINDOW_MANAGER:CreateControlFromVirtual("LibQRCodeBackdrop", floatingWindow, "ZO_DefaultBackdrop")
		backdrop:SetAnchorFill()
		backdrop:SetDrawTier(DT_LOW)
		--Make a close button for the window, put it in the top right of the window
		local closeButton = WINDOW_MANAGER:CreateControl("LibQRCodeCloseButton", floatingWindow, CT_BUTTON)
		closeButton:SetDimensions(defaultHeaderHeight, defaultHeaderHeight)
		closeButton:SetAnchor(TOPRIGHT, floatingWindow, TOPRIGHT, defaultXInset, defaultYInset)
		closeButton:SetHandler("OnClicked", function() 
			SCENE_MANAGER:ToggleTopLevel(floatingWindow) 
			floatingWindow:SetHidden(true) 
		end)
		closeButton:SetEnabled(true)
		closeButton:SetNormalTexture("EsoUI/Art/Buttons/closebutton_up.dds")
		closeButton:SetPressedTexture("EsoUI/Art/Buttons/closebutton_down.dds")
		closeButton:SetMouseOverTexture("EsoUI/Art/Buttons/closebutton_mouseover.dds")
		closeButton:EnableMouseButton(MOUSE_BUTTON_INDEX_LEFT, true)
		--Draw the QRCode in a section of the window that doesn't include the close button, but includes the rest of the window below it
		
	else
		SCENE_MANAGER:ToggleTopLevel(floatingWindow) 
		floatingWindow:SetHidden(false) 
	end
	
	if qrContainer == nil then
		qrContainer = LibQRCode.CreateQRControl(defaultTextureSize, data)
	else
		LibQRCode.DrawQRCode(qrContainer, data)
	end
	--WINDOW_MANAGER:CreateControl("LibQRCodeDrawing", floatingWindow, CT_TEXTURE)
	qrContainer:SetParent(floatingWindow)
	qrContainer:SetAnchor(TOPLEFT, floatingWindow, TOPLEFT, defaultXInset, defaultHeaderHeight + 2 * defaultYInset)
	qrContainer:SetAnchor(BOTTOMRIGHT, floatingWindow, BOTTOMRIGHT, -defaultXInset, -defaultYInset)
end

local function DrawQRCode_FloatingTest(n)
	local data = ""
	for i=1000,1000+n do
		data = data..i
	end
	DrawQRCode_Floating(data)
end

SLASH_COMMANDS["/qrcode"] = DrawQRCode_Floating
--SLASH_COMMANDS["/qrcodetest"] = DrawQRCode_FloatingTest

--Addon loaded function
local function OnLibraryLoaded(event, name)
	if name ~= MAJOR then return end
	EVENT_MANAGER:UnregisterForEvent(MAJOR, EVENT_ADD_ON_LOADED)
end

--Load the addon now
EVENT_MANAGER:UnregisterForEvent(MAJOR, EVENT_ADD_ON_LOADED)
EVENT_MANAGER:RegisterForEvent(MAJOR, EVENT_ADD_ON_LOADED, OnLibraryLoaded)