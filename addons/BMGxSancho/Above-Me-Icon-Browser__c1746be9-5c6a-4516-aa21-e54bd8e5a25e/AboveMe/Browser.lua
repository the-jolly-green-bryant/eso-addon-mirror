AboveMe = AboveMe or {}
local AM = AboveMe
local WM = WINDOW_MANAGER

local function MakeLabel(parent, font, text, color)
    local label = WM:CreateControl(nil, parent, CT_LABEL)
    label:SetFont(font)
    label:SetText(text or "")
    if color then label:SetColor(unpack(color)) end
    return label
end

function AM:CreateIconBrowser()
    local window = WM:CreateTopLevelWindow("AboveMeIconBrowser")
    window:SetAnchorFill(GuiRoot)
    window:SetHidden(true)
    window:SetDrawLayer(DL_OVERLAY)
    window:SetDrawTier(DT_HIGH)
    window:SetDrawLevel(200)

    local shade = WM:CreateControl(nil, window, CT_BACKDROP)
    shade:SetAnchorFill(window)
    shade:SetCenterColor(0.015, 0.02, 0.035, 0.78)
    shade:SetEdgeColor(0, 0, 0, 0)

    local panel = WM:CreateControl(nil, window, CT_BACKDROP)
    panel:SetDimensions(780, 720)
    panel:SetAnchor(CENTER, window, CENTER, 0, -54)
    panel:SetCenterColor(0.025, 0.03, 0.05, 0.96)
    panel:SetEdgeColor(0.85, 0.68, 0.22, 1)
    panel:SetEdgeTexture("EsoUI/Art/Tooltips/Gamepad/gp_tooltip_edge.dds", 128, 16, 16)

    local inner = WM:CreateControl(nil, panel, CT_BACKDROP)
    inner:SetAnchor(TOPLEFT, panel, TOPLEFT, 24, 24)
    inner:SetAnchor(BOTTOMRIGHT, panel, BOTTOMRIGHT, -24, -24)
    inner:SetCenterColor(0.02, 0.025, 0.04, 0.48)
    inner:SetEdgeColor(0.34, 0.38, 0.48, 0.85)
    inner:SetEdgeTexture("EsoUI/Art/Tooltips/Gamepad/gp_tooltip_edge.dds", 128, 16, 16)

    local title = MakeLabel(panel, "ZoFontGamepadBold34", "ABOVE ME", {0.95, 0.78, 0.25, 1})
    title:SetAnchor(TOP, panel, TOP, 0, 34)
    title:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

    local divider = WM:CreateControl(nil, panel, CT_TEXTURE)
    divider:SetTexture("EsoUI/Art/Miscellaneous/horizontalDivider.dds")
    divider:SetDimensions(560, 8)
    divider:SetAnchor(TOP, title, BOTTOM, 0, 16)

    local category = MakeLabel(panel, "ZoFontGamepadBold27", "")
    category:SetAnchor(TOP, divider, BOTTOM, 0, 14)
    category:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

    local previewFrame = WM:CreateControl(nil, panel, CT_BACKDROP)
    previewFrame:SetDimensions(300, 300)
    previewFrame:SetAnchor(CENTER, panel, CENTER, 0, -18)
    previewFrame:SetCenterColor(0.04, 0.05, 0.075, 0.92)
    previewFrame:SetEdgeColor(0.55, 0.58, 0.68, 0.9)
    previewFrame:SetEdgeTexture("EsoUI/Art/Tooltips/Gamepad/gp_tooltip_edge.dds", 128, 16, 16)

    local preview = WM:CreateControl(nil, previewFrame, CT_TEXTURE)
    preview:SetDimensions(236, 236)
    preview:SetAnchor(CENTER, previewFrame, CENTER, 0, 0)

    local name = MakeLabel(panel, "ZoFontGamepadBold34", "")
    name:SetAnchor(TOP, previewFrame, BOTTOM, 0, 14)
    name:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

    local count = MakeLabel(panel, "ZoFontGamepad27", "", {0.78, 0.8, 0.86, 1})
    count:SetAnchor(TOP, name, BOTTOM, 0, 6)
    count:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

    local fav = MakeLabel(panel, "ZoFontGamepad27", "", {1, 0.82, 0.15, 1})
    fav:SetAnchor(TOP, count, BOTTOM, 0, 4)
    fav:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

    local browseHint = MakeLabel(panel, "ZoFontGamepad22", "", {0.72, 0.75, 0.82, 1})
    browseHint:SetAnchor(BOTTOM, panel, BOTTOM, 0, -34)
    browseHint:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

    self.iconBrowser = {
        window=window, panel=panel, categoryLabel=category, preview=preview,
        nameLabel=name, countLabel=count, favLabel=fav, browseHint=browseHint, packIndex=1, iconIndex=1,
    }

    local scene = ZO_Scene:New("AboveMeIconBrowserScene", SCENE_MANAGER)
    scene:AddFragmentGroup(FRAGMENT_GROUP.GAMEPAD_DRIVEN_UI_WINDOW)
    scene:AddFragment(GAMEPAD_NAV_QUADRANT_1_BACKGROUND_FRAGMENT)
    scene:AddFragment(MINIMIZE_CHAT_FRAGMENT)
    scene:AddFragment(GAMEPAD_MENU_SOUND_FRAGMENT)
    scene:AddFragment(ZO_FadeSceneFragment:New(window))
    self.iconBrowser.scene = scene

    self.iconBrowserKeybinds = {
        alignment = KEYBIND_STRIP_ALIGN_LEFT,
        {name="Select Icon", keybind="UI_SHORTCUT_PRIMARY", callback=function()
            local icon=self:GetBrowserIcon(); if icon then self:SelectIcon(icon.id); self:RefreshIconBrowser() end
            return true
        end},
        {name=function() local i=self:GetBrowserIcon(); return i and self:IsFavorite(i.id) and "Remove Favorite" or "Add Favorite" end,
         keybind="UI_SHORTCUT_TERTIARY", callback=function()
            local i=self:GetBrowserIcon(); if i then self:SetFavorite(i.id, not self:IsFavorite(i.id)); self:RefreshIconBrowser(); KEYBIND_STRIP:UpdateKeybindButtonGroup(self.iconBrowserKeybinds) end
            return true
         end},
        {name="Previous Category", keybind="UI_SHORTCUT_LEFT_SHOULDER", ethereal=true, callback=function() self:StepBrowserPack(-1); PlaySound(SOUNDS.GAMEPAD_MENU_UP); return true end},
        {name="Next Category", keybind="UI_SHORTCUT_RIGHT_SHOULDER", ethereal=true, callback=function() self:StepBrowserPack(1); PlaySound(SOUNDS.GAMEPAD_MENU_DOWN); return true end},
        {name="Previous Icon", keybind="UI_SHORTCUT_LEFT_TRIGGER", ethereal=true, callback=function() self:StepBrowserIcon(-1); PlaySound(SOUNDS.GAMEPAD_MENU_UP); return true end},
        {name="Next Icon", keybind="UI_SHORTCUT_RIGHT_TRIGGER", ethereal=true, callback=function() self:StepBrowserIcon(1); PlaySound(SOUNDS.GAMEPAD_MENU_DOWN); return true end},
        {name=GetString(SI_GAMEPAD_BACK_OPTION), keybind="UI_SHORTCUT_NEGATIVE", callback=function() SCENE_MANAGER:Hide("AboveMeIconBrowserScene"); return true end},
    }

    scene:RegisterCallback("StateChange", function(_, newState)
        if newState == SCENE_SHOWING then
            self:RefreshIconBrowser()
            KEYBIND_STRIP:AddKeybindButtonGroup(self.iconBrowserKeybinds)
        elseif newState == SCENE_HIDDEN then
            KEYBIND_STRIP:RemoveKeybindButtonGroup(self.iconBrowserKeybinds)
            preview:SetTexture(nil)
        end
    end)
end

function AM:GetBrowserPack() return self.ICON_PACKS[self.iconBrowser.packIndex] end
function AM:GetBrowserIcons() local p=self:GetBrowserPack(); return p and self:GetIconsForPack(p.id) or {} end
function AM:GetBrowserIcon() local icons=self:GetBrowserIcons(); return icons[self.iconBrowser.iconIndex] end
function AM:StepBrowserPack(delta)
    local n=#self.ICON_PACKS
    self.iconBrowser.packIndex=((self.iconBrowser.packIndex-1+delta)%n)+1
    self.iconBrowser.iconIndex=1
    self:RefreshIconBrowser()
end
function AM:StepBrowserIcon(delta)
    local icons=self:GetBrowserIcons(); if #icons==0 then return end
    self.iconBrowser.iconIndex=((self.iconBrowser.iconIndex-1+delta)%#icons)+1
    self:RefreshIconBrowser()
end
function AM:RefreshIconBrowser()
    local b=self.iconBrowser; if not b then return end
    local p=self:GetBrowserPack(); local icons=self:GetBrowserIcons(); local icon=self:GetBrowserIcon()
    b.categoryLabel:SetText(string.format("◀   %s   ▶", p and p.name or ""))
    if icon then
        b.preview:SetTexture(icon.texture)
        b.preview:SetTextureCoords(icon.left or 0, icon.right or 1, icon.top or 0, icon.bottom or 1)
        b.nameLabel:SetText(icon.name)
        b.countLabel:SetText(string.format("%d / %d", b.iconIndex, #icons))
        b.favLabel:SetText(self:IsFavorite(icon.id) and "★ FAVORITE" or "")
        b.browseHint:SetText("L1 / R1  CATEGORIES     L2 / R2  ICONS")
    end
end
function AM:OpenIconBrowser()
    if not self.iconBrowser then self:CreateIconBrowser() end
    local selected=self:GetIcon(self.saved.iconId)
    for pi,p in ipairs(self.ICON_PACKS) do
        if p.id==selected.pack then
            self.iconBrowser.packIndex=pi
            local icons=self:GetIconsForPack(p.id)
            for ii,i in ipairs(icons) do if i.id==selected.id then self.iconBrowser.iconIndex=ii break end end
            break
        end
    end
    SCENE_MANAGER:Show("AboveMeIconBrowserScene")
end
