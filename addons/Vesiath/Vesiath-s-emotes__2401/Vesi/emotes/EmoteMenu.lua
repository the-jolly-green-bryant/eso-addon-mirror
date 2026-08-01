local WM = GetWindowManager()

V.Emotes.EmoteMenu = {
    menuopen = false,
    defaults = {
        X = "0",
        Y = "-128",
        point = BOTTOM,
        relativePoint = BOTTOM,
        edgeColor =  ZO_ColorDef:New(255, 255, 255, .5),
        backgroundColor = ZO_ColorDef:New(0, 0, 0, .5),
        textColor = ZO_ColorDef:New(172, 136, 239),
    },
    sv = nil,
    list = nil,

    Init = function(self)
        self.sv = V:RegisterSavedVars("emotemenu", self.defaults)
        VesiPanel:SetAnchor(self.sv.point, nil, self.sv.relativePoint, self.sv.X, self.sv.Y)
        VesiPanelHeading:SetColor(self:GetColor(self.sv.textColor))
        VesiPanelBG:SetCenterColor(self:GetColor(self.sv.backgroundColor))
        VesiPanelBG:SetEdgeColor(self:GetColor(self.sv.edgeColor))

        self.MenuSettings:Build()
        self:InitPanel()
    end,

    InitPanel = function(self)
        self.list = self:SortList()
        for i=1, #self.list do
            self:CreateEmotePanel(i, self.list[i].name, VesiPanelEmotePanelScrollChild, 24)
        end
    end,

    CreateEmotePanel = function(self, nr, name, parent, size)
        local emote = V.Emotes:Get(name)
        local img = V.Emotes:GetImage(emote.img)

        local n = "Emote_" .. name
        local c = WM:CreateControl(n, parent, CT_BUTTON)
        local icon = WM:CreateControl(n.. "_icon", c, CT_TEXTURE)
        local label = WM:CreateControl(n .. "_label", c, CT_LABEL)
        local overlay = WM:CreateControl(n .. "_overlay", c, CT_TEXTURE)

        c:SetDimensions(300, size+6)
        c:SetAnchor(3, nil, 3, 0, (size+6)*(nr-1))
        c:SetHandler("OnClicked", function() V.Util:TextEntry(name) end)
		c:SetHandler("OnMouseEnter", function() overlay:SetHidden(false) end)
        c:SetHandler("OnMouseExit", function() overlay:SetHidden(true) end)
        
        icon:SetAnchor(3, nil, 3, 10, 3)
        icon:SetDimensions(size, size)
        icon:SetTexture(img)
        icon:SetDrawLayer(2)

        label:SetAnchor(3, nil, 3, 40, 3)
        label:SetText(name)
        label:SetColor(self:GetColor(self.sv.textColor))
        label:SetDimensions(256, size)
        label:SetFont("ZoFontWinH4")
        label:SetDrawLayer(3)
        
        overlay:SetAnchorFill(c)
        overlay:SetDimensions(300, 28)
        overlay:SetDrawTier(4)
        overlay:SetDrawLayer(1)
        overlay:SetTexture("esoui/art/chatwindow/chat_bg_center.dds")
        overlay:SetHidden(true)
    end,

    ClearEmotePanel = function(self)
        for i=1, #self.list do
            local n = "Emote_" .. self.list[i].name
            local c = WM:GetControlByName(n)
            c:SetHidden(true)
        end
    end,

    UpdatePanel = function(self)
        self:ClearEmotePanel()
        self.list = self:SortList()
        for i=1, #self.list do
            self:UpdateEmotePanel(i, self.list[i].name, 24)
        end
    end,

    UpdateEmotePanel = function(self, nr, name, size)
        local n = "Emote_" .. name
        local c = WM:GetControlByName(n)

        c:SetAnchor(3, nil, 3, 0, (size+6)*(nr-1))
        c:SetHidden(false)
    end,

    UpdateText = function(self)
        for i=1, #self.list do
            local n = "Emote_" .. self.list[i].name .. "_label"
            local label = WM:GetControlByName(n)
            label:SetColor(self:GetColor(self.sv.textColor))
        end
    end,

    SavePos = function(self)
        local _,point,_,relativePoint,offsetX,offsetY = VesiPanel:GetAnchor()
		self.sv.X = offsetX
		self.sv.Y = offsetY
		self.sv.point = point
		self.sv.relativePoint = relativePoint
    end,

    SortList = function(self)
        local t = {}
        local search = VesiPanelSearchBGBox:GetText()
        if search == "" then
            for key, value in pairs(V.Emotes:Get()) do
                table.insert(t, {name=key})
            end
        else
            for key, value in pairs(V.Emotes:Get()) do
                if string.match(key:lower(), search:lower()) then
                    table.insert(t, {name=key})
                end
            end
        end
        table.sort(t, V.Util.Sort_By_Name)
        return t
    end,

    SearchText = function(self, control)
        local text = control:GetText()
        VesiPanelSearchBGBoxText:SetHidden(text~=nil and text>"")
        self:UpdatePanel()
    end,

    ClearSearch = function(self)
        VesiPanelSearchBGBox:SetText("")
    end,

    IsMenuOpen = function(self)
        return self.menuopen
    end,

    ToggleMenu = function(self)
        self.menuopen = not self.menuopen
        VesiPanel:SetHidden(not self.menuopen)
    end,

    SetBackgroundColor = function(self, r,g,b,a)
        self.sv.backgroundColor = ZO_ColorDef:New(r, g, b, a)
        VesiPanelBG:SetCenterColor(r, g, b, a)
    end,

    SetEdgeColor = function(self, r, g, b, a)
        self.sv.edgeColor = ZO_ColorDef:New(r, g, b, a)
        VesiPanelBG:SetEdgeColor(r, g, b, a)
    end,

    SetTextColor = function(self, r, g, b)
        self.sv.textColor = ZO_ColorDef:New(r, g, b)
        VesiPanelHeading:SetColor(r, g, b)
        self:UpdateText()
    end,

    GetColor = function(self, color)
        return color.r, color.g, color.b, color.a
    end,
}

SLASH_COMMANDS["/em"] = function() V.Emotes.EmoteMenu:ToggleMenu() end