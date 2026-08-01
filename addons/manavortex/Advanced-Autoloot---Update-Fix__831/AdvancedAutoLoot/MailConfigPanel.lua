local MailConfigPanel = ZO_Object:New()

function MailConfigPanel:New(control)
	local scene = ZO_Scene:New("MailConfigPanel", SCENE_MANAGER)
	scene:AddFragment(ZO_FadeSceneFragment:New(ADVANCEDAUTOLOOT_MailConfigPanel))
	scene:AddFragment(RIGHT_BG_FRAGMENT)
	scene:AddFragment(TITLE_FRAGMENT)
	scene:AddFragmentGroup(FRAGMENT_GROUP.UI_WINDOW)
	scene:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_STANDARD_RIGHT_PANEL)
	end
function ADVANCEDAUTOLOOT_MailConfigPanel_OnInitialized(self)
	MailConfigPanel:New(self)
end