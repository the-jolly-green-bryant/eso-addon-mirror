PBT=PBT or {}
-- The gamepad main menu goes two levels deep and no further: its sub-list always shows the
-- children of whatever is selected in the main list. A third level therefore has to be a
-- screen of its own, pushed on top of the sub-menu the way the client's own Options screen is,
-- which also gives Back its usual meaning of returning to the level above.
local M=ZO_Gamepad_ParametricList_Screen:Subclass();PBT.ModeMenu=M
M.SCENE='pbtModeMenu'
M.TITLE='タムリエル de テトリス'
M.MODES={{name='タムリエル de テトリス（ノーマル）',force20G=false},{name='タムリエル de テトリス（20G）',force20G=true}}
local icon='EsoUI/Art/HUD/Gamepad/gp_radialIcon_duel_down.dds'
function M:Initialize(control,app)
 self.app=app
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
 if mode then self.app:Solo(false,mode.force20G) end
end
function M:PerformUpdate()
 self.dirty=false
 local list=self:GetMainList();list:Clear()
 for _,mode in ipairs(M.MODES) do
  local entry=ZO_GamepadEntryData:New(mode.name,icon)
  entry:SetIconTintOnSelection(true);entry.force20G=mode.force20G
  list:AddEntry('ZO_GamepadMenuEntryTemplate',entry)
 end
 list:Commit()
end
