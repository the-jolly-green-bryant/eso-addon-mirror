local LIB = 'UI'
local FRAMENAMEPREFIX = 'FluffielsPanicBeamsFrame'
local TEXTUREPATHPREFIX = 'FluffielsPanicBeams/textures/'
local ui = FLUFFIELS_PANICBEAMS[LIB]

if not ui then

    ui = ui or {}
    FLUFFIELS_PANICBEAMS[LIB] = ui

    ui.TextureFrames = ui.TextureFrames or {}

    -- ******* CLASS TextureFrame *******

    local TextureFrame = FLUFFIELS_PANICBEAMS.Class(function(frame, name)
        frame.Name = name
        frame.SystemFrame = WINDOW_MANAGER:CreateControl(name, FluffielsPanicBeamsFrameRoot, CT_TEXTURE)
        frame.Color = { R = 1, G = 1, B = 1, A = 1 }
        frame.TextureRotation = 0
        frame.TextureRotationX = 0
        frame.TextureRotationY = 0
        frame.Texture = ''
        frame.Movable = false
        frame.Width = 0
        frame.Height = 0
    end)

    function TextureFrame:SetAlpha(value, f)
        if self.Color.A ~= value then
            self.Color.A = value
            self.SystemFrame:SetColor(self.Color.R, self.Color.G, self.Color.B, value)
        end
    end

    function TextureFrame:SetColor(r, g, b)
        if not g and type(r) == 'table' then
            g = r.G
            b = r.B
            r = r.R
        end
        if self.Color.R ~= r or self.Color.G ~= g or self.Color.B ~= b then
            self.Color.R = r
            self.Color.G = g
            self.Color.B = b
            self.SystemFrame:SetColor(r, g, b, self.Color.A)
        end
    end

    function TextureFrame:SetTextureCoords(left, right, top, bottom)
        if not self.TextureCoords then
            self.TextureCoords = { left, right, top, bottom }
            self.SystemFrame:SetTextureCoords(left, right, top, bottom)
        elseif self.TextureCoords[0] ~= left or self.TextureCoords[1] ~= right or
               self.TextureCoords[2] ~= top or self.TextureCoords[3] ~= bottom then
            self.TextureCoords[0] = left
            self.TextureCoords[1] = right
            self.TextureCoords[2] = top
            self.TextureCoords[3] = bottom
            self.SystemFrame:SetTextureCoords(left, right, top, bottom)
        end
    end

    function TextureFrame:SetTextureRotation(value, x, y)
        if x == nil then x = 0.5 end
        if y == nil then y = 0.5 end
        if self.TextureRotation ~= value or
           self.TextureRotationX ~= x or self.TextureRotationY ~= y then
            self.TextureRotation = value
            self.TextureRotationX = x
            self.TextureRotationY = y
            self.SystemFrame:SetTextureRotation(value, x, y)
        end
    end

    function TextureFrame:SetTexture(value)
        if self.Texture ~= value then
            self.Texture = value
            if string.sub(value, 1, 1) == '/' then
                self.SystemFrame:SetTexture(string.sub(value, 1, string.len(value) - 1))
            else
                self.SystemFrame:SetTexture(TEXTUREPATHPREFIX .. value)
            end
        end
    end

    function TextureFrame:SetTesoTexture(value)
        if self.Texture ~= value then
            self.Texture = value
            self.SystemFrame:SetTexture(value)
        end
    end

    function TextureFrame:SetMovable(value)
        if self.Movable ~= value then
            self.Movable = value
            self.SystemFrame:SetMovable(value)
        end
    end

    function TextureFrame:SetDimensions(width, height)
        if not height then height = width end
        if self.Width ~= width or self.Height ~= height then
            self.Width = width
            self.Height = height
            self.SystemFrame:SetDimensions(width, height)
        end
    end

    function TextureFrame:SetAnchor(parent, child, x, y)
        if not self.Anchor then self.Anchor = {} end
        if self.Anchor.Parent ~= parent or self.Anchor.Child ~= child or
           self.Anchor.X ~= x or self.Anchor.Y ~= y then
            self.Anchor.Parent = parent
            self.Anchor.Child = child
            self.Anchor.X = x
            self.Anchor.Y = y
            self.SystemFrame:ClearAnchors()
            self.SystemFrame:SetAnchor(parent, FluffielsPanicBeamsFrameRoot, child, x, y)
        end
    end

    function TextureFrame:Reset()
        self:SetAlpha(0)
        self:SetTextureCoords(0, 1, 0, 1)
        self:SetTextureRotation(0)
        self:SetMovable(false)
        self:SetDimensions(0, 0)
        self:SetColor(1, 1, 1)
    end

    -- ******* UI *******

    function ui:RequestTextureFrames(frames)
        local init
        for i,v in ipairs(frames) do
            if not self.TextureFrames[i] then
                self.TextureFrames[i] = TextureFrame(FRAMENAMEPREFIX .. 'Texture' .. i)
            end
        end
        for i,v in ipairs(ui.TextureFrames) do
            v:Reset()
            init = frames[i]
            if init then
                if init.Texture then v:SetTexture(init.Texture) end
                if init.Movable ~= nil then v:SetMovable(init.Movable) end
                if init.Anchor then v:SetAnchor(unpack(init.Anchor)) end
                if init.Dimensions then v:SetDimensions(unpack(init.Dimensions)) end
            end
        end
        return unpack(self.TextureFrames)
    end

end
