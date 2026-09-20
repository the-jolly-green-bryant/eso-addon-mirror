-- Private modal scene: input belongs to this panel only while it is showing.
SXUI_BeaconMoveMode={active=false,moving=false,selected=1}
local M=SXUI_BeaconMoveMode
local S,R=SXUI_BeaconSettings,SXUI_BeaconRenderer
local SCENE,EVENT="sxuiBeaconPetSettings","SXUIBeaconPetPanel"
M.Width=600
M.TitleFont="$(GAMEPAD_BOLD_FONT)|36|soft-shadow-thick"
M.RowFont="$(GAMEPAD_MEDIUM_FONT)|27|soft-shadow-thick"
M.MoveFont="$(GAMEPAD_MEDIUM_FONT)|30|soft-shadow-thick"
M.HelpFont="$(GAMEPAD_MEDIUM_FONT)|24|soft-shadow-thick"
ZO_CreateStringId("SI_BINDING_NAME_SXUI_BEACON_SETTINGS","SXUI Beacon Pet: Settings")

local function Label(parent,name,y,font)
    local label=WINDOW_MANAGER:CreateControl("SXUIBeaconPet"..name,parent,CT_LABEL)
    label:SetFont(font or M.RowFont)
    label:SetAnchor(TOPLEFT,parent,TOPLEFT,28,y)
    label:SetDimensions(544,58)
    label:SetColor(1,.95,.84,1)
    return label
end

function M:Create()
    if self.control then return end
    local c=WINDOW_MANAGER:CreateTopLevelWindow("SXUIBeaconPetSettingsPanel")
    self.control=c
    c:SetDimensions(self.Width,600)
    c:SetClampedToScreen(true)
    c:SetAnchor(TOPRIGHT,GuiRoot,TOPRIGHT,-40,65)
    c:SetDrawTier(DT_HIGH)
    c:SetDrawLevel(100)
    c:SetMouseEnabled(true)
    c:SetHidden(true)
    local background=WINDOW_MANAGER:CreateControl("SXUIBeaconPetSettingsBackground",c,CT_BACKDROP)
    background:SetAnchorFill(c)
    background:SetCenterColor(.018,.022,.03,.98)
    background:SetEdgeColor(.67,.43,.19,1)
    background:SetEdgeTexture("",1,1,2,0)
    background:SetMouseEnabled(false)
    self.title=Label(c,"SettingsTitle",26,self.TitleFont)
    self.title:SetText("SXUI Beacon Pet")
    self.rows={}
    for i=1,7 do
        local index=i
        local row=Label(c,"SettingsRow"..i,105+(i-1)*54)
        row:SetMouseEnabled(true)
        row:SetHandler("OnMouseUp",function(_,button,upInside)
            if button==MOUSE_BUTTON_INDEX_LEFT and upInside then
                if self.moving then
                    if index==2 then self:Close(true)
                    elseif index==3 then self:Close(false) end
                    return
                end
                self.selected=index
                self:Accept()
            end
        end)
        self.rows[i]=row
    end
    self.hint=Label(c,"SettingsHint",515,self.HelpFont)
    self.hint:SetDimensions(544,76)
    self.scene=ZO_Scene:New(SCENE,SCENE_MANAGER)
    self.scene:AddFragment(ZO_SimpleSceneFragment:New(c))
    self.scene:AddFragment(MOUSE_UI_MODE_FRAGMENT)
    -- ESO's standard scene fragments own native UI routing and restore it on hide.
    self.scene:AddFragment(GAMEPAD_UI_MODE_FRAGMENT)
    self.scene:AddFragment(UI_SHORTCUTS_ACTION_LAYER_FRAGMENT)
    self.scene:AddFragment(KEYBIND_STRIP_GAMEPAD_FRAGMENT)
    self.scene:RegisterCallback("StateChange",function(_,newState)
        if newState==SCENE_SHOWING then self:Activate()
        elseif newState==SCENE_HIDING or newState==SCENE_HIDDEN then self:Release() end
    end)
    c:SetHandler("OnHide",function() self:Release() end)
    self.keybinds={
        alignment=KEYBIND_STRIP_ALIGN_LEFT,
        {keybind="UI_SHORTCUT_INPUT_UP",ethereal=true,callback=function() self:Direction(0,-1) end},
        {keybind="UI_SHORTCUT_INPUT_DOWN",ethereal=true,callback=function() self:Direction(0,1) end},
        {keybind="UI_SHORTCUT_INPUT_LEFT",ethereal=true,callback=function() self:Direction(-1,0) end},
        {keybind="UI_SHORTCUT_INPUT_RIGHT",ethereal=true,callback=function() self:Direction(1,0) end},
        {keybind="UI_SHORTCUT_PRIMARY",name=function() return self.moving and "Place Pet" or "Select" end,
            handlesKeyUp=true,callback=function(up) if up then self:Accept() end end},
        {keybind="UI_SHORTCUT_NEGATIVE",name=function() return self.moving and "Cancel" or "Close" end,
            handlesKeyUp=true,callback=function(up) if up then self:Close(false) end end},
    }
end

function M:Refresh()
    if not self.beacon then return end
    local s=self.beacon.settings
    self.title:SetText(self.moving and "Move Beacon Pet" or "SXUI Beacon Pet")
    self.control:SetDimensions(self.Width,self.moving and 470 or 600)
    local values={"Enable Pet: "..(s.enabled and "On" or "Off"),
        string.format("Scale: %.0f%%",s.scale*100),
        "Lock Position: "..(s.locked and "On" or "Off"),
        "Move Beacon Pet", "Reset Position",
        "Demo Animations: "..(s.demoAnimations and "On" or "Off"),"Close"}
    for i,row in ipairs(self.rows) do
        row:SetHidden(self.moving and i>3)
        row:ClearAnchors()
        row:SetAnchor(TOPLEFT,self.control,TOPLEFT,28,self.moving and (126+(i-1)*76) or (105+(i-1)*54))
        if self.moving then
            row:SetFont(self.MoveFont)
            row:SetText(i==1 and "D-Pad: Move" or i==2 and "A: Save / Place" or "B: Cancel")
            row:SetColor(1,.95,.84,1)
        else
            row:SetFont(self.RowFont)
            row:SetText((i==self.selected and ">  " or "   ")..values[i])
            row:SetColor(1,i==self.selected and .84 or .95,i==self.selected and .48 or .84,1)
        end
    end
    self.hint:ClearAnchors()
    self.hint:SetAnchor(TOPLEFT,self.control,TOPLEFT,28,self.moving and 382 or 515)
    self.hint:SetText(self.moving and "Mouse: click Save or Cancel.\nYour position saves when you place the pet."
        or "D-Pad: select / adjust scale\nA: select    B: close    Mouse: click")
    if self.keybindsAdded then KEYBIND_STRIP:UpdateKeybindButtonGroup(self.keybinds) end
    SXUI_BeaconVisibility:Refresh()
end

function M:Activate()
    if self.active then return end
    self.active=true
    KEYBIND_STRIP:AddKeybindButtonGroup(self.keybinds)
    self.keybindsAdded=true
    EVENT_MANAGER:RegisterForEvent(EVENT,EVENT_PLAYER_DEACTIVATED,function() self:Close(false) end)
    R:Place(self.beacon.settings)
    if self.pendingMove then
        self.pendingMove=false
        self:BeginMove()
    end
    self:Refresh()
end

function M:Release()
    if self.keybindsAdded then
        KEYBIND_STRIP:RemoveKeybindButtonGroup(self.keybinds)
        self.keybindsAdded=false
    end
    EVENT_MANAGER:UnregisterForEvent(EVENT,EVENT_PLAYER_DEACTIVATED)
    self.active,self.moving,self.pendingMove=false,false,false
    self.draft,self.snapshot=nil,nil
    if self.beacon then R:Place(self.beacon.settings) end
    SXUI_BeaconVisibility:Refresh()
end

function M:Show(beacon,move)
    if not beacon or not beacon.settings then return end
    self.beacon=beacon
    self:Create()
    if not self.active then
        -- ESO may first animate another scene out. Start the draft on SHOWING.
        self.pendingMove=move==true
        SCENE_MANAGER:Show(SCENE)
    elseif move then self:BeginMove() end
    self:Refresh()
end

function M:BeginMove()
    if not self.active or not self.beacon.settings.enabled then
        S.Say("Enable the pet before moving it.")
        return false
    end
    local s=self.beacon.settings
    if self.moving then return true end
    self.snapshot={x=s.x,y=s.y}
    self.draft={x=s.x,y=s.y,scale=s.scale}
    self.moving=true
    self:Refresh()
    return true
end

function M:Close(save)
    if not self.active then return end
    if save and self.moving and self.draft then
        local s=self.beacon.settings
        s.x,s.y=self.draft.x,self.draft.y
        S:Clamp(s)
    elseif self.moving and self.snapshot then
        self.beacon.settings.x,self.beacon.settings.y=self.snapshot.x,self.snapshot.y
    end
    self:Release()
    if SCENE_MANAGER:IsShowing(SCENE) then SCENE_MANAGER:HideCurrentScene() end
end

function M:Direction(x,y)
    if not self.active then return end
    if self.moving then
        self.draft.x,self.draft.y=self.draft.x+x*4,self.draft.y+y*4
        S:Clamp(self.draft)
        R:Place(self.beacon.settings,self.draft.x,self.draft.y)
    elseif y~=0 then self.selected=(self.selected-1+y)%7+1
    elseif x~=0 and self.selected==2 then
        local s=self.beacon.settings
        s.scale=s.scale+x*.05
        S:Clamp(s)
        R:Place(s)
    end
    self:Refresh()
end

function M:Accept()
    if not self.active then return end
    if self.moving then self:Close(true); return end
    local s=self.beacon.settings
    if self.selected==1 then s.enabled=not s.enabled; self.beacon:Start()
    elseif self.selected==2 then
        s.scale=s.scale>=S.MaxScale-.001 and S.MinScale or s.scale+.1
        S:Clamp(s); R:Place(s)
    elseif self.selected==3 then s.locked=not s.locked; R:Place(s)
    elseif self.selected==4 then self:BeginMove()
    elseif self.selected==5 then S:Reset(s)
    elseif self.selected==6 then s.demoAnimations=not s.demoAnimations; self.beacon:Start()
    elseif self.selected==7 then self:Close(false); return end
    self:Refresh()
end
