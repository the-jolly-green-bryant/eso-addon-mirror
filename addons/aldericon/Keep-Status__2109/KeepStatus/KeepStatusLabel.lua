
KeepStatus.Label = {}
KeepStatus.Label.__index = KeepStatus.Label

setmetatable(KeepStatus.Label, {
    __call = function (cls, ...)
        return cls.new(...)
    end,
})

local Label = KeepStatus.Label

function Label.new()
    local self = setmetatable({}, KeepStatus.Label)

    self.num = (Label.entryCount or 0) + 1
    self.entryName = "KeepStatusEntry" .. self.num
    Label.entryCount = self.num
    self.entry = {}

    local entry = self.entry

    self.main = WINDOW_MANAGER:CreateControl(self.entryName .. "main", KeepStatus_UI, CT_BACKDROP)
    self.main:SetDimensions(KeepStatus.width, 35)
    self.main:SetAnchor(TOPLEFT, KeepStatus_UI, TOPLEFT, 0, self.num*35-5)
    self.main:SetCenterColor(KeepStatus.defaultBGColor:UnpackRGBA())
    self.main:SetEdgeColor(KeepStatus.invisColor:UnpackRGBA())

    entry.img1 = WINDOW_MANAGER:CreateControl(self.entryName .. "img1", self.main, CT_TEXTURE)
    entry.img2 = WINDOW_MANAGER:CreateControl(self.entryName .. "img2", self.main, CT_TEXTURE)
    entry.img3 = WINDOW_MANAGER:CreateControl(self.entryName .. "img3", self.main, CT_TEXTURE)

    entry.txt1 = WINDOW_MANAGER:CreateControl(self.entryName .. "txt1", self.main, CT_LABEL)
    entry.txt2 = WINDOW_MANAGER:CreateControl(self.entryName .. "txt2", self.main, CT_LABEL)
    entry.txt3 = WINDOW_MANAGER:CreateControl(self.entryName .. "txt3", self.main, CT_LABEL)
    entry.txt4 = WINDOW_MANAGER:CreateControl(self.entryName .. "txt4", self.main, CT_LABEL)

	local fontMain = "$(CHAT_FONT)|18|soft-shadow-thick"
    entry.txt1:SetFont(fontMain)
    entry.txt2:SetFont(fontMain)
    entry.txt3:SetFont(fontMain)
    entry.txt4:SetFont(fontMain)

    return self
end

function Label:hide()
    self.main:SetHidden(true)
end

function Label:show()
    self.main:SetHidden(false)
end

function Label:getControl(name)
    return self.entry[name]
end

function Label:moveControl(name, x, y)
    if self.entry[name] then
        self.entry[name]:ClearAnchors()
        self.entry[name]:SetAnchor(TOPLEFT, self.entry.main, TOPLEFT, x, y)
    end
end

function Label:resizeControl(name, width, height)
    if self.entry[name] then
        self.entry[name]:SetDimensions(width, height)
    end
end

function Label:positionControl(name, width, height, x, y)
    if self.entry[name] then
        self.entry[name]:ClearAnchors()
        self.entry[name]:SetAnchor(TOPLEFT, self.entry.main, TOPLEFT, x, y)
        self.entry[name]:SetDimensions(width, height)
    end
end

function Label:exposeControls(nImg, nText)
    for i=1,3 do
        self.entry["img"..i]:SetHidden(i > nImg)
    end

    for i=1,4 do
        self.entry["txt"..i]:SetHidden(i > nText)
    end
end

function Label:update(model)
    if self.type ~= model.type then
        model:configureLabel(self)
        self.type = model.type
        self:show()
    end

    model:updateLabel(self)
end
