local n="HerosCompass"
local s={
{[4584]={map=567,x=.4335,y=.2946}}
}
local o=
{
[1]={1,}
,[5590]={5708,}
,[5591]={5708,}
,[5592]={5708,}
,[5593]={5708,}
,[5594]={5708,}
,[5614]={5708,}
,[5616]={5708,}
,[5617]={5708,}
,[5618]={5708,}
,[5619]={5708,}
,[5620]={5708,}
,[5621]={5708,}
,[5622]={5708,}
,[5624]={5708,}
,[5625]={5708,}
,[5626]={5708,}
,[5627]={5708,}
,[5629]={5708,}
,[5630]={5708,}
,[5631]={5708,}
,[5632]={5708,}
,[5633]={5708,}
,[5649]={5708,}
,[5650]={5708,}
,[5651]={5708,}
,[5652]={5708,}
,[5653]={5708,}
,[5654]={5708,}
,[5655]={5708,}
,[5656]={5708,}
,[5657]={5708,}
,[5658]={5708,}
,[5659]={5708,}
,[5660]={5708,}
,[5661]={5708,}
,[5662]={5708,}
,[5663]={5708,}
,[5665]={5708,}
,[5666]={5708,}
,[5667]={5708,}
,[5669]={5708,}
,[5670]={5708,}
,[5671]={5708,}
,[5672]={5708,}
,[5673]={5708,}
,[5674]={5708,}
,[5675]={5708,}
,[5676]={5708,}
,[5677]={5708,}
,[5678]={5708,}
,[5679]={5708,}
,[5680]={5708,}
,[5681]={5708,}
,[5682]={5708,}
,[5683]={5708,}
,[5684]={5708,}
,[5685]={5708,}
,[5687]={5708,}
,[5688]={5708,}
,[5689]={5708,}
,[5690]={5708,}
,[5691]={5708,}
,[5692]={5708,}
,[5693]={5708,}
,[5694]={5708,}
,[5695]={5708,}
,[5696]={5708,}
,[5697]={5708,}
,[5698]={5708,}
,[5699]={5708,}
,[5700]={5708,}
,[5701]={5708,}
,[5703]={5708,}
,[5704]={5708,}
,[5705]={5708,}
,[5706]={5708,}
,[5707]={5708,}
,[5709]={5708,}
,[5710]={5708,}
,[5711]={5708,}
,[4364]={4369,4370,}
,[4369]={4364,4370,}
,[4370]={4364,4369,}
,[4654]={4679,}
,[4679]={4654,}
,[1803]={1804,}
,[1804]={1803,}
,[5036]={3981,}
,[4816]={2184,}
,[3598]={3595,}
,[3595]={3598,}
,[5088]={4546,}
,[3658]={3653,}
,[3653]={3658,}
,[4953]={4896,}
,[4896]={4953,}
,}
local t=ZO_Gamepad_ParametricList_Screen:Subclass()
function t:New(...)
return ZO_Gamepad_ParametricList_Screen.New(self,...)
end
local e={}
local a={}
local i=false
local function h()
local i=GetQuestName
local n=HasCompletedQuest
local s=GetQuestZoneId
local h=GetZoneNameById
e={}
for t=1,10000 do
local a=s(t)
e[t]={name=i(t),
isCompleted=n(t),
zoneId=a,
zoneName=h(a),
}
end
e[6455]=nil
e[6110]=nil
e[6646]=nil
e[6541]=nil
e[6324]=nil
e[6339]=nil
e[6143]=nil
e[5804]=nil
e[5623]=nil
e[5743]=nil
for t,o in pairs(o)do
if not e[t].isCompleted then
local a=false
for o,t in pairs(o)do
if e[t].isCompleted then
a=true
end
end
if a then
e[t].isbc=true
e[t].isCompleted=true
end
end
end
a={}
local t={}
for o,e in pairs(e)do
if not e.isCompleted and e.name~=""and e.zoneName~=""then
if not a[e.zoneId]then
t[e.zoneId]={}
a[e.zoneId]={}
end
if not t[e.zoneId][e.name]then
table.insert(a[e.zoneId],o)
t[e.zoneId][e.name]=true
end
end
end
HEROS_COMPASS_MENU:ShowZoneList()
end
function t:ShowZoneList()
self.inSubmenu=false
self.list:Clear()
if self.questInfoBackdrop then
self.questInfoBackdrop:SetHidden(true)
end
local e=ZO_GamepadEntryData:New("REFRESH LIST")
e.callback=function()
h()
end
e.customColor={.95,.925,.825,1}
self.list:AddEntry("ZO_GamepadItemEntryTemplate",e)
for t,a in pairs(a)do
local e=GetZoneNameById(t)
if e==""then e="No Zone"end
local e=ZO_GamepadEntryData:New(e.." ("..tostring(#a)..")")
e:SetModifyTextType(MODIFY_TEXT_TYPE_NONE)
e.zoneId=t
e.callback=function()
self:ShowQuestSubmenu(t)
end
self.list:AddEntry("ZO_GamepadItemEntryTemplate",e)
end
self.list:Commit()
if self.lastZoneIndex then
self.list:SetSelectedIndexWithoutAnimation(self.lastZoneIndex)
self.lastZoneIndex=nil
end
end
function t:ShowQuestSubmenu(o)
self.inSubmenu=true
self.lastZoneIndex=self.list:GetSelectedIndex()
self.list:Clear()
local t=a[o]
if t then
for h,a in ipairs(t)do
local n=e[a].name
local e=s[a]
local t=ZO_GamepadEntryData:New(n)
t:SetModifyTextType(MODIFY_TEXT_TYPE_NONE)
local i=GetZoneNameById(o)
if e~=nil then
i=GetMapNameById(e[1])
end
local e=""
e=e.."QuestId: "..a.." ZoneId: "..o.."\n"
e=e.."This is a description for "..n.."\n"
e=e.."Go find it in "..i.."\n"
if HasQuest(a)then e=e.."Quest active\n"else e=e..".\n"end
t.descriptionText=e
t.callback=function(e)
if e=="primary"then
HEROS_COMPASS_MENU.questInfoLabel:SetText(t.descriptionText)
HEROS_COMPASS_MENU.questInfoBackdrop:SetHidden(false)
end
if e=="secundary"then
local e=s[a]
if e~=nil then
SCENE_MANAGER:Push("gamepad_worldMap")
WORLD_MAP_MANAGER:SetMapById(439)
ZO_WorldMap_GetPanAndZoom():SetCurrentNormalizedZoom(0)
WORLD_MAP_MANAGER:SetMapById(e[1])
CALLBACK_MANAGER:FireCallbacks("OnWorldMapChanged")
ZO_WorldMap_PanToNormalizedPosition(e[2],e[3])
end
end
end
if h==1 then
t:SetHeader(GetZoneNameById(o))
self.list:AddEntry("ZO_GamepadItemEntryTemplateWithHeader",t)
else
self.list:AddEntry("ZO_GamepadItemEntryTemplate",t)
end
end
end
self.list:Commit()
self.list:SetSelectedIndexWithoutAnimation(1)
end
function t:Initialize(e)
self.control=e
self.scene=ZO_Scene:New("heros_compass_scene",SCENE_MANAGER)
self.fragment=ZO_SimpleSceneFragment:New(e)
self.fragment:SetHideOnSceneHidden(true)
self.scene:AddFragment(self.fragment)
self.scene:AddFragmentGroup(FRAGMENT_GROUP.GAMEPAD_DRIVEN_UI_WINDOW)
self.scene:AddFragment(GAMEPAD_NAV_QUADRANT_1_BACKGROUND_FRAGMENT)
self.scene:RegisterCallback("StateChange",function(e,e)
end)
local t=true
ZO_Gamepad_ParametricList_Screen.Initialize(self,e,ZO_DO_NOT_CREATE_TAB_BAR,t,self.scene)
self.headerData={
titleText="Hero's Compass",
}
ZO_GamepadGenericHeader_Refresh(self.header,self.headerData)
self.questInfoBackdrop=WINDOW_MANAGER:CreateControl(nil,e,CT_BACKDROP)
self.questInfoBackdrop:SetDimensions(800,200)
self.questInfoBackdrop:SetAnchor(CENTER,e,CENTER,650,50)
self.questInfoBackdrop:SetCenterColor(0,0,0,.6)
self.questInfoBackdrop:SetEdgeColor(1,1,1,.2)
self.questInfoBackdrop:SetEdgeTexture(nil,1,1,1)
self.questInfoBackdrop:SetHidden(true)
self.questInfoLabel=WINDOW_MANAGER:CreateControl(nil,self.questInfoBackdrop,CT_LABEL)
self.questInfoLabel:SetFont("ZoFontGamepad34")
self.questInfoLabel:SetDimensions(760,180)
self.questInfoLabel:SetAnchor(CENTER,self.questInfoBackdrop,CENTER,0,0)
self.questInfoLabel:SetWrapMode(TEXT_WRAP_MODE_WORD)
self.questInfoLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
self.questInfoLabel:SetVerticalAlignment(TEXT_ALIGN_TOP)
self:InitializeList()
end
function t:InitializeList()
local function a(e,t,a,o,n,i)
ZO_SharedGamepadEntry_OnSetup(e,t,a,o,n,i)
e.label:SetFont("ZoFontGamepad34")
if not t.icon then
e.label:ClearAnchors()
e.label:SetAnchor(LEFT,e,LEFT,40,0)
e.label:SetAnchor(RIGHT,e,RIGHT,-40,0)
e.label:SetDimensionConstraints(0,0,1000,0)
end
if t.customColor then
e.label:SetColor(unpack(t.customColor))
end
end
self.list=self:GetMainList()
self.list:Clear()
self.list:AddDataTemplate("ZO_GamepadItemEntryTemplate",a,ZO_GamepadMenuEntryTemplateParametricListFunction)
self.list:AddDataTemplateWithHeader("ZO_GamepadItemEntryTemplate",a,ZO_GamepadMenuEntryTemplateParametricListFunction,USE_DEFAULT_COMPARISON,"MyGamepadHeaderTemplate")
local e=ZO_GamepadEntryData:New("REFRESH LIST")
e.callback=function()
h()
end
e.customColor={.95,.925,.825,1}
self.list:AddEntry("ZO_GamepadItemEntryTemplate",e)
self.list:SetOnSelectedDataChangedCallback(function(e,e)
if self.questInfoBackdrop then
self.questInfoBackdrop:SetHidden(true)
end
end)
self.list:Commit()
self.lastZoneIndex=nil
end
function t:InitializeKeybindStripDescriptors()
self.keybindStripDescriptor={
alignment=KEYBIND_STRIP_ALIGN_LEFT,
{
name="Select",
keybind="UI_SHORTCUT_PRIMARY",
callback=function()
local e=self.list:GetTargetData()
if e and e.callback then
e.callback("primary")
end
end,
visible=function()
return self.list:GetSelectedIndex()~=0
end,
enabled=function()
return true
end,
},
{
name="Back",
keybind="UI_SHORTCUT_NEGATIVE",
callback=function()
if self.inSubmenu then
self:ShowZoneList()
else
SCENE_MANAGER:Hide(self.scene.name)
end
end,
},
{name=GetString(SI_QUEST_JOURNAL_SHOW_ON_MAP),
keybind="UI_SHORTCUT_SECONDARY",
alignment=KEYBIND_STRIP_ALIGN_CENTER,
callback=function()
local e=self.list:GetTargetData()
if e and e.callback and i then
e.callback("secundary")
end
end,
visible=function()
return i
end
},
}
end
function t:OnShowing()
ZO_Gamepad_ParametricList_Screen.OnShowing(self)
self:SetCurrentList(self.list)
self:ActivateCurrentList()
self.list:RefreshVisible()
KEYBIND_STRIP:AddKeybindButtonGroup(self.keybindStripDescriptor)
end
function t:OnHiding()
ZO_Gamepad_ParametricList_Screen.OnHiding(self)
KEYBIND_STRIP:RemoveKeybindButtonGroup(self.keybindStripDescriptor)
end
function t:PerformUpdate()
self.dirty=false
end
function HerosCompass_MenuScreen_OnInitialized(e)
HEROS_COMPASS_MENU=t:New(e)
end
local function o()
local e={
name="Hero's Compass",icon="EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_journal.dds",
scene="heros_compass_scene",
}
local t=ZO_GamepadEntryData:New(e.name,e.icon)
t.data={
name=e.name,icon=e.icon,
scene=e.scene,sceneName=e.scene,
disableWhenDead=false,disableWhenInCombat=false,
disableWhenReviving=false,disableWhenSwimming=false,
disableWhenWerewolf=false,disableWhenPassenger=false,
shouldDisableFunction=function()return false end,
}
t.callback=function()SCENE_MANAGER:Show(e.scene)end
local e=0
for a,o in pairs(ZO_MENU_ENTRIES[ZO_MENU_MAIN_ENTRIES.JOURNAL].subMenu)do
if type(a)=="number"and a>e then
e=a
end
end
t.id=e+1
ZO_MENU_ENTRIES[ZO_MENU_MAIN_ENTRIES.JOURNAL].subMenu[t.id]=t
end
local function t(t,e)
if e==n then
o()
EVENT_MANAGER:UnregisterForEvent(n,EVENT_ADD_ON_LOADED)
end
end
EVENT_MANAGER:RegisterForEvent(n,EVENT_ADD_ON_LOADED,t)
local function e(e)
if e=="testmapfunc"then i=true end
end
SLASH_COMMANDS["/heroscompass"]=function(t)e(t)end
