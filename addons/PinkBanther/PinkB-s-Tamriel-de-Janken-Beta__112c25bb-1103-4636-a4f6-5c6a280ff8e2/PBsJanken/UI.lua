PBJ = PBJ or {}
local UI = {}
UI.__index=UI
PBJ.UI=UI
local textures={"rock","paper","scissors"}
local function label(parent,name,y,size,color)
    local c=WINDOW_MANAGER:CreateControl(name,parent,CT_LABEL)
    c:SetFont(size or "ZoFontGamepad34")
    c:SetAnchor(TOP,parent,TOP,0,y)
    c:SetDimensions(840,65)
    c:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    c:SetColor(unpack(color or {0.88,0.84,0.74,1}))
    c:SetDrawLayer(DL_TEXT)
    return c
end
function UI.New(app)
    local self=setmetatable({app=app},UI)
    local root=WINDOW_MANAGER:CreateTopLevelWindow("PBsJankenWindow")
    root:SetDimensions(960,720)
    root:SetAnchor(CENTER,GuiRoot,CENTER,0,-15)
    root:SetHidden(true)
    local bg=WINDOW_MANAGER:CreateControl(nil,root,CT_BACKDROP)
    bg:SetAnchorFill(root)
    bg:SetDrawLayer(DL_BACKGROUND)
    bg:SetCenterColor(0.025,0.035,0.045,0.98)
    bg:SetEdgeColor(0.62,0.48,0.26,1)
    bg:SetEdgeTexture("",1,1,2)
    self.root=root
    local eyebrow=label(root,nil,18,"ZoFontGamepad18",{0.54,0.65,0.63,1})
    eyebrow:SetDimensions(840,24)
    eyebrow:SetText(PBJ.Text("eyebrow"))
    local title=label(root,nil,48,"ZoFontGamepad42",{0.85,0.69,0.39,1})
    title:SetDimensions(840,52)
    title:SetText(PBJ.Text("title"))
    local subtitle=label(root,nil,102,"ZoFontGamepad27")
    subtitle:SetDimensions(840,34)
    subtitle:SetText(PBJ.Text("subtitle"))
    self.mode=label(root,nil,141,"ZoFontGamepad22",{0.35,0.78,0.74,1})
    self.mode:SetDimensions(840,30)
    self.peer=label(root,nil,177,"ZoFontGamepad27")
    self.peer:SetDimensions(840,36)
    self.status=label(root,nil,217,"ZoFontGamepad27")
    self.status:SetDimensions(840,85)
    self.timer=label(root,nil,287,"ZoFontGamepad22",{0.95,0.72,0.32,1})
    self.timer:SetDimensions(840,30)
    self.cards={}
    for i=1,3 do
        local card=WINDOW_MANAGER:CreateControl(nil,root,CT_CONTROL)
        card:SetDimensions(248,268)
        card:SetAnchor(TOPLEFT,root,TOPLEFT,84+(i-1)*272,318)
        local border=WINDOW_MANAGER:CreateControl(nil,card,CT_BACKDROP)
        border:SetAnchorFill(card)
        border:SetDrawLayer(DL_BACKGROUND)
        border:SetDrawLevel(1)
        border:SetCenterColor(0.065,0.079,0.087,1)
        border:SetEdgeColor(0.3,0.28,0.23,1)
        border:SetEdgeTexture("",1,1,2)
        local texture=WINDOW_MANAGER:CreateControl(nil,card,CT_TEXTURE)
        texture:SetDimensions(210,210)
        texture:SetDrawLayer(DL_CONTROLS)
        texture:SetDrawLevel(2)
        texture:SetAnchor(TOP,card,TOP,0,5)
        local text=label(card,nil,222,"ZoFontGamepad27")
        text:SetDimensions(240,40)
        card:SetMouseEnabled(true)
        card:SetHandler("OnMouseUp",function(_,button,upInside)
            if button==MOUSE_BUTTON_INDEX_LEFT and upInside then self:Action(i) end
        end)
        local fallback=label(card,nil,85,"ZoFontGamepad42")
        fallback:SetDimensions(240,65)
        fallback:SetHidden(true)
        self.cards[i]={root=card,border=border,texture=texture,label=text,fallback=fallback}
    end
    self.footer=label(root,nil,605,"ZoFontGamepad22")
    label(root,nil,659,"ZoFontGamepad18"):SetText(PBJ.Text("rules"))
    self.keybinds={alignment=KEYBIND_STRIP_ALIGN_CENTER}
    for i,key in ipairs({"UI_SHORTCUT_PRIMARY","UI_SHORTCUT_SECONDARY","UI_SHORTCUT_TERTIARY"}) do
        local index=i
        self.keybinds[#self.keybinds+1]={keybind=key,
            name=function() return self:ActionName(index) end,
            visible=function() return self:ActionName(index)~="" end,
            enabled=function() return self:ActionEnabled(index) end,
            callback=function() self:Action(index) end}
    end
    self.keybinds[#self.keybinds+1]={keybind="UI_SHORTCUT_NEGATIVE",name=function()
        local game=app.game
        return PBJ.Text(game.state=="invited" and "decline" or (game:IsActive() and "cancel" or "close"))
    end,callback=function() self:Close() end}
    self.scene=ZO_Scene:New("pbjGame",SCENE_MANAGER)
    self.scene:AddFragment(ZO_SimpleSceneFragment:New(root))
    self.scene:AddFragmentGroup(FRAGMENT_GROUP.GAMEPAD_DRIVEN_UI_WINDOW)
    self.scene:RegisterCallback("StateChange",function(_,state)
        if state==SCENE_SHOWING then
            self:Refresh()
            KEYBIND_STRIP:AddKeybindButtonGroup(self.keybinds)
        elseif state==SCENE_HIDING then
            KEYBIND_STRIP:RemoveKeybindButtonGroup(self.keybinds)
            if app.game:IsActive() then app.game:Cancel() end
        end
    end)
    return self
end
function UI:ActionName(i)
    if self.diagnostic then return i==1 and "画像を再確認" or "" end
    local game=self.app.game
    if i==1 then
        if game.state=="invited" then return PBJ.Text("accept") end
        if not game:IsActive() and game.peer then return PBJ.Text("again") end
    end
    -- The three hands stay on the strip for the whole round so the buttons do
    -- not disappear between the invitation and the result.
    return PBJ.Text(textures[i])
end
function UI:ActionEnabled(i)
    if self.diagnostic then return i==1 end
    local game=self.app.game
    if game.state=="choosing" then return true end
    return i==1 and (game.state=="invited" or (not game:IsActive() and game.peer~=nil)) or false
end
function UI:Action(i)
    if self.diagnostic then
        if i==1 then self.diagnosticSetup=nil; self:Refresh() end
        return
    end
    local game=self.app.game
    if game.state=="choosing" then game:Choose(i)
    elseif i==1 and game.state=="invited" then game:Accept()
    elseif i==1 and not game:IsActive() and game.peer then self.app:Replay() end
end
function UI:Show(diagnostic)
    self.diagnostic=diagnostic==true
    self.diagnosticSetup=nil
    self:Refresh()
    SCENE_MANAGER:Show("pbjGame")
end
function UI:Close()
    if self.app.game:IsActive() then self.app.game:Cancel() end
    SCENE_MANAGER:Hide("pbjGame")
end
function UI:Refresh()
    local game=self.app.game
    self.root:SetScale(math.min(1,(GuiRoot:GetWidth()-80)/960,(GuiRoot:GetHeight()-100)/720))
    if self.diagnostic then self:RefreshDiagnostic(); return end
    self.mode:SetText(PBJ.Text(self.app.practice and "practice" or "online"))
    self.peer:SetText(self.app.practice and PBJ.Text("trainingPartner") or (game.peer or ""))
    local statusKey=game.reason or game.result or game.state
    if game.state=="locked" and game.choice==0 then statusKey="timeLossPending" end
    self.status:SetText(PBJ.Text(statusKey))
    self:RefreshTimer()
    local result=game.state=="result"
    for i,card in ipairs(self.cards) do
        local choice=i
        card.root:SetHidden(result and i==3)
        card.root:ClearAnchors()
        card.root:SetAnchor(TOPLEFT,self.root,TOPLEFT,(result and 200+(i-1)*312 or 84+(i-1)*272),318)
        if result then choice=i==1 and game.choice or game.otherChoice end
        local textureName=textures[choice] or "hidden"
        PBJ.Textures:Apply(card.texture,textureName)
        card.fallback:SetText(PBJ.Text(choice==0 and "noHand" or textureName))
        card.texture:SetAlpha(not result and game.choice and game.choice~=i and 0.45 or 1)
        card.label:SetText(result and (PBJ.Text(i==1 and "you" or "opponent").." · "..PBJ.Text(choice==0 and "noHand" or textureName)) or PBJ.Text(textures[i]))
        local selected=not result and game.choice==i
        card.border:SetEdgeColor(selected and 0.3 or 0.4,selected and 0.85 or 0.32,selected and 0.76 or 0.2,1)
    end
    local stats=self.app.saved
    self.footer:SetText(string.format(PBJ.Text("stats"),stats.win,stats.lose,stats.draw))
    if self.scene:IsShowing() then KEYBIND_STRIP:UpdateKeybindButtonGroup(self.keybinds) end
end
function UI:RefreshDiagnostic()
    self.mode:SetText("画像の読み込み診断")
    self.peer:SetText("左：標準アイコン　中央：ゲームの格納先　右：従来パス")
    self.status:SetText("中央・右は512×512のグー画像です。\n1×1などの表示は、本来の画像の読込成功ではありません。")
    self.timer:SetText("")
    if not self.diagnosticSetup then
        self.diagnosticPaths={
            "EsoUI/Art/HUD/Gamepad/gp_radialIcon_duel_down.dds",
            PBJ.Textures:Path("rock",#PBJ.Textures.roots),
            PBJ.Textures.legacyRoot.."assets/rock.dds",
        }
        for i,card in ipairs(self.cards) do
            card.root:SetHidden(false)
            card.root:ClearAnchors()
            card.root:SetAnchor(TOPLEFT,self.root,TOPLEFT,84+(i-1)*272,318)
            card.texture.pbjName=nil
            card.texture:SetTexture(self.diagnosticPaths[i])
            card.texture:SetHidden(false)
            card.texture:SetAlpha(1)
            card.fallback:SetHidden(true)
        end
        self.diagnosticSetup=true
    end
    local reports={}
    for i,card in ipairs(self.cards) do
        local status=PBJ.Textures.Status(card.texture,i==1 and 64 or 512)
        card.label:SetText(status)
        reports[i]=self.diagnosticPaths[i].." : "..status
    end
    self.textureReport=table.concat(reports,"\n")
    self.footer:SetText("この画面は対戦しません。\n詳細なパスは /pbj debug でチャットに表示できます。")
    if self.scene:IsShowing() then KEYBIND_STRIP:UpdateKeybindButtonGroup(self.keybinds) end
end
function UI:RefreshTimer()
    if self.diagnostic then self:RefreshDiagnostic(); return end
    local game=self.app.game
    local remaining=game.state=="choosing" and math.max(0,math.ceil(game.choiceDeadline-game.o.now()))
    self.timer:SetText(remaining and string.format(PBJ.Text("remaining"),remaining) or "")
    for _,card in ipairs(self.cards) do
        local usable=PBJ.Textures:Poll(card.texture,512)
        card.texture:SetHidden(not usable)
        card.fallback:SetHidden(usable)
    end
end
