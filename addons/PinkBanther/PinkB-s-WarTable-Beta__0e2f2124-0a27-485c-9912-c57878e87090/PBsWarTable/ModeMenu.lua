-- Third level of the gamepad menu: ゲームセンターPX → 三旗の戦卓 → each way to play.
-- Pushed as its own scene, the way the client pushes Options over the sub-menu, so Back
-- returns to the PX list instead of closing the whole menu.
local M=ZO_Gamepad_ParametricList_Screen:Subclass(); PBWT.ModeMenu=M
M.SCENE='pbwtModeMenu'
M.TITLE=PBWT.Config.TITLE
local function entries()
    local list={}
    for _,key in ipairs({'standard','light'}) do
        local variant=PBWT.Config.VARIANTS[key]
        for _,mode in ipairs({{name='COM初級',mode='solo',difficulty='beginner'},
            {name='COM中級',mode='solo',difficulty='intermediate'},
            {name='COM上級',mode='solo',difficulty='advanced'},
            {name='ローカル検証',mode='local'}}) do
            list[#list+1]={name=variant.name..'：'..mode.name,mode=mode.mode,difficulty=mode.difficulty,variant=key}
        end
    end
    list[#list+1]={name='チュートリアル（軽量版）',mode='tutorial',variant='light'}
    return list
end
M.MODES=entries()
local icon='EsoUI/Art/HUD/Gamepad/gp_radialIcon_duel_down.dds'
function M:Initialize(control)
    local scene=ZO_Scene:New(M.SCENE,SCENE_MANAGER)
    ZO_Gamepad_ParametricList_Screen.Initialize(self,control,ZO_GAMEPAD_HEADER_TABBAR_DONT_CREATE,true,scene)
    scene:AddFragmentGroup(FRAGMENT_GROUP.GAMEPAD_DRIVEN_UI_WINDOW)
    scene:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_GAMEPAD)
    scene:AddFragment(ZO_SimpleSceneFragment:New(control))
    scene:AddFragment(GAMEPAD_NAV_QUADRANT_1_BACKGROUND_FRAGMENT)
    scene:AddFragment(MINIMIZE_CHAT_FRAGMENT)
    scene:AddFragment(GAMEPAD_MENU_SOUND_FRAGMENT)
    self.headerData={titleText=M.TITLE}
    ZO_GamepadGenericHeader_Refresh(self.header,self.headerData)
end
function M:InitializeKeybindStripDescriptors()
    self.keybindStripDescriptor={alignment=KEYBIND_STRIP_ALIGN_LEFT,
        KEYBIND_STRIP:GetDefaultGamepadBackButtonDescriptor(),
        {name=GetString(SI_GAMEPAD_SELECT_OPTION),keybind='UI_SHORTCUT_PRIMARY',callback=function() self:Launch() end}}
end
function M:Launch()
    local mode=self:GetMainList():GetTargetData()
    if mode then PBWT.Open(mode.mode,mode.difficulty,mode.variant) end
end
function M:PerformUpdate()
    self.dirty=false
    local list=self:GetMainList(); list:Clear()
    for _,mode in ipairs(M.MODES) do
        local entry=ZO_GamepadEntryData:New(mode.name,icon)
        entry:SetIconTintOnSelection(true)
        entry.mode,entry.difficulty,entry.variant=mode.mode,mode.difficulty,mode.variant
        list:AddEntry('ZO_GamepadMenuEntryTemplate',entry)
    end
    list:Commit()
end
