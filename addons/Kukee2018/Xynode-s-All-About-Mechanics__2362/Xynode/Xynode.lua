Xynode = Xynode or {}
local Xynode = Xynode

local savedVars
local UNITTAG_PLAYER = 'player'
local BossNameNear = ""

local wipe = {
	"EVERYBODY IS DEAD DAVE",
	"A DEAD DPS IS ZERO DPS",
	"DID YOU ALL STAND IN STUPID?",
	"WELL, THAT'S A WIPE",
	"Do YOU HAVE A FAKE TANK?",
	"IS IT *ALWAYS* THE HEALER'S FAULT?",
	"MAYBE YOU SHOULD READ THE GUIDE AGAIN",
	"LAG, DEFINITELY LAG"
}


Xynode.Dungeon = nil
Xynode.Boss = nil
Xynode.showHide = false
Xynode.ShowHidePanel = false
Xynode.GuideSoundPlayed = false
Xynode.BossSoundPlayed = false

Xynode.name = "Xynode"

Xynode.defaults = {
	hideControls = false,
	bgAlpha = 75,
	fgAlpha = 100,
	offsetWinX = 0,
	offsetWinY = 0,
	offsetPanelX = 0,
	offsetPanelY = 0,
	offsetGuideX = CENTER,
	offsetGuideY = CENTER,
	guidesound = "",
	bosssound = "",
	deathingroup = false,
}



function Xynode.Initialize()

	EVENT_MANAGER:RegisterForEvent(Xynode.name, EVENT_BOSSES_CHANGED, Xynode.CheckBoss)
	EVENT_MANAGER:RegisterForEvent(Xynode.name, EVENT_RETICLE_HIDDEN_UPDATE, Xynode.CheckBoss)
	EVENT_MANAGER:RegisterForEvent(Xynode.name, EVENT_PLAYER_ACTIVATED, Xynode.CheckBoss)
	EVENT_MANAGER:RegisterForEvent(Xynode.name, EVENT_LOOT_RECEIVED, Xynode.ItemLooted)
	CALLBACK_MANAGER:RegisterCallback("OnWorldMapChanged", Xynode.OnZoneChanged)

	-- New Group death stuff below
	EVENT_MANAGER:RegisterForEvent(Xynode.name, EVENT_UNIT_DEATH_STATE_CHANGED, GroupChanged)



	Xynode.savedVars = ZO_SavedVars:New("XynodeVariables", 1, nil, Xynode.defaults, GetWorldName())

	Xynode.CreateMenu(Xynode.defaults)
	Xynode.setUp()

end

local function GetRandomElement(array)
    local random = math.random() * #array
    local index = 1 + math.floor(random)
    return array[index]
end

function Xynode.ItemLooted(eventCode, whoBy, itemName, quantity, soundCategory, lootType, isPlayer, isPickpocketLoot, questItemIcon, itemId, isStolen)

	if(isPlayer) then
	--	d("Item: "..itemName.." ID: "..itemId)

		 local hasSet, setName, numBonuses, numEquipped, maxEquipped, setId = GetItemLinkSetInfo(itemName, false)
		if(hasSet) then
	--		d(setName.." "..setId)
		end
	end
end



function GroupChanged(eventCode, unitTag, isDead)
	if Xynode.savedVars.deathingroup == false then
	local groupSize = GetGroupSize()
	local numDead = 0

	for g =1, groupSize do
		local tag = GetGroupUnitTagByIndex(g)
		local role  = ""
		local colour = "ffffff"


		if IsUnitDead(tag) then
			numDead = numDead + 1
		end

		if(GetGroupMemberSelectedRole(tag)) == 1 then role = "DPS" colour = "4286f4" end
		if(GetGroupMemberSelectedRole(tag)) == 2 then role = "TANK" colour = "ffff00" end
		if(GetGroupMemberSelectedRole(tag)) == 3 then role = "SQUIRREL" colour = "ff0000" end
		if(GetGroupMemberSelectedRole(tag)) == 4 then role = "HEALER" colour = "00ff00" end

		if(unitTag == tag) then
			if(isDead) then
				if(numDead == groupSize) then
					local params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.ACHIEVEMENT_AWARDED)
					params:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_DISPLAY_ANNOUNCEMENT)
					params:SetText("|c00ff00"..GetRandomElement(wipe).."|r")
					CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(params)
				else

					local params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT, SOUNDS.ACHIEVEMENT_AWARDED)
					params:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_DISPLAY_ANNOUNCEMENT)
					params:SetText("|c"..colour..role.." DOWN: |r"..GetUnitName(unitTag).." ("..GetUnitDisplayName(unitTag)..")")
					CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(params)
				end
			end
		end
	end
	end
end





function Xynode.setUp()

	local bgAlpha = Xynode.savedVars.bgAlpha
	local offsetPanelX = Xynode.savedVars.offsetPanelX
	local offsetPanelY = Xynode.savedVars.offsetPanelY
	local offsetGuideX = Xynode.savedVars.offsetGuideX
	local offsetGuideY = Xynode.savedVars.offsetGuideY


	XynodePanel:SetHidden(Xynode.savedVars.hideControls)

	XynodePanel:ClearAnchors()
	XynodePanel:SetAnchor(TOPLEFT,GuiRoot,TOPLEFT,offsetPanelX,offsetPanelY)
	XynodeGuide:ClearAnchors()
	XynodeGuide:SetAnchor(TOPLEFT,GuiRoot,TOPLEFT,offsetGuideX,offsetGuideY)

	XynodePanelButtonFullGuide:SetMouseEnabled(false)
	XynodePanelButtonFullGuide:SetEnabled(false)

	XynodePanelButtonBossGuide:SetMouseEnabled(false)
	XynodePanelButtonBossGuide:SetEnabled(false)

	XynodePanelYouTubeFull:SetMouseEnabled(false)
	XynodePanelYouTubeFull:SetEnabled(false)

	Xynode.OnZoneChanged()
	Xynode.CheckBoss()

	XynodePanelButtonBossGuide:SetAlpha(0.25)



end


function OnMoveStop()

	Xynode.savedVars.offsetPanelX = XynodePanel:GetLeft()
	Xynode.savedVars.offsetPanelY = XynodePanel:GetTop()

end

function OnXynodeGuideMoveStop()
	Xynode.savedVars.offsetGuideX = XynodeGuide:GetLeft()
	Xynode.savedVars.offsetGuideY = XynodeGuide:GetTop()

end

function Xynode.OnZoneChanged()
	Xynode.zoneName = GetUnitZone(UNITTAG_PLAYER)
	Xynode.zoneWorldPosition = GetUnitWorldPosition(UNITTAG_PLAYER)
	Xynode.Dungeon = nil
	Xynode.MapContentType = GetMapContentType()

		for key, value in pairs(Xynode.dungeons)
		do

			if(Xynode.dungeons[key].zoneid == Xynode.zoneWorldPosition) then
				Xynode.Dungeon = Xynode.dungeons[key]

				XynodePanelCounter:SetHidden(false)
				XynodePanelButton:SetHidden(false)
				XynodePanelCounter:SetText(Xynode.zoneName)
			end
		end
		if(Xynode.Dungeon ~= nil) then
			XynodePanel:SetHidden(false)
			XynodePanelButtonFullGuide:SetMouseEnabled(true)
			XynodePanelButtonFullGuide:SetEnabled(true)
			XynodePanelYouTubeFull:SetMouseEnabled(true)
			XynodePanelYouTubeFull:SetEnabled(true)
			XynodePanelButtonFullGuide:SetAlpha(1)
			XynodePanelYouTubeFull:SetAlpha(1)
			XynodePanelCounter:SetText(Xynode.zoneName)
			if(Xynode.GuideSoundPlayed == false) then
				PlaySound(SOUNDS[Xynode.savedVars.guidesound])
				Xynode.GuideSoundPlayed = true
			end

		else
			XynodePanelButtonFullGuide:SetMouseEnabled(false)
			XynodePanelButtonFullGuide:SetEnabled(false)
			XynodePanelYouTubeFull:SetMouseEnabled(false)
			XynodePanelYouTubeFull:SetEnabled(false)
			XynodePanelButtonFullGuide:SetAlpha(0.25)
			XynodePanelYouTubeFull:SetAlpha(0.25)
			XynodePanelCounter:SetText(Xynode.zoneName)



			Xynode.Dungeon = nil
			Xynode.GuideSoundPlayed = false
			XynodePanel:SetHidden(Xynode.savedVars.hideControls)

	end
	Xynode.CheckBoss()
end






function AddLine(text, font, align, color)

    font  = (type(font)  == "string") and font  or "ZoFontGame"
    text  = (type(text)  == "string") and text  or ""
    align = (type(align) == "number") and align or TEXT_ALIGN_LEFT
    color = (type(color) == "table")  and color or ZO_NORMAL_TEXT


    parent = XynodeGuideContentScrollChild
	numchild = parent:GetNumChildren()

	if(numchild==0) then
		label = WINDOW_MANAGER:CreateControl("GuideText", parent, CT_LABEL)
		label:SetWidth(700)
		label:SetHorizontalAlignment(align)
		label:SetFont(font)
		label:SetText(text)
		label:SetColor(color:UnpackRGBA())
		label:SetAnchor(TOP, parent, TOPLEFT, 375, 6)
	else
		label = GuideText
	end


	label:SetText(text)


    return label
end


function ShowWebsite()
	RequestOpenUnsafeURL("https://www.xynodegaming.com/allaboutmechanics")
end

function ShowSettings()
	local LAM = LibStub("LibAddonMenu-2.0")
	LAM:OpenToPanel(addOnPanelXy)
end

function ShowAbout()
	aboutText = "Live Streamer and content creator covering The Elder Scrolls Online.\nI create content to help players with the game itself as well as characters, classes, builds, content guides and much more. I offer as much help and explanation for the reasons why things do and don't work in the game as possible.\n\nThe two biggest questions in the world are both 'how?' and 'why?'... I will do my best to answer them both!\n\nPatreon - https://www.patreon.com/xynode\nWebsite - http://www.xynodegaming.com\nTwitter - https://twitter.com/Xynode\nTwitch - http://twitch.tv/xynode\nFacebook - https://www.facebook.com/Xynodegaming/\n\nThis Add-on is not created by, affiliated with or sponsored by ZeniMax Media Inc. or its affiliates. The Elder Scrolls� and related logos are registered trademarks or trademarks of ZeniMax Media Inc. in the United States and/or other countries. All rights reserved.\nhttps://account.elderscrollsonline.com/add-on-terms"
	XynodeAboutAboutText:SetText(aboutText)
	XynodeGuide:SetHidden(true)
	XynodeAbout:SetHidden(not XynodeAbout:IsHidden())
end

function ShowWebPage()
	if(Xynode.Dungeon ~= nil) then
		RequestOpenUnsafeURL(Xynode.Dungeon.link)
	end
end



function ShowHide()
	if (Xynode.showHide) then
		XynodeGuide:ClearAnchors()
		XynodeGuide:SetAnchor(TOPLEFT,GuiRoot,TOPLEFT,Xynode.savedVars.offsetGuideX,Xynode.savedVars.offsetGuideY)
		XynodeGuideButtonHideShow:SetNormalTexture("EsoUI/Art/charactercreate/charactercreate_leftarrow_down.dds")
		Xynode.showHide = false
		SetGameCameraUIMode(true)
	else
		XynodeGuide:ClearAnchors()
		XynodeGuide:SetAnchor(TOPLEFT,GuiRoot,TOPLEFT,-750, XynodeGuide:GetTop())
		XynodeGuideButtonHideShow:SetNormalTexture("EsoUI/Art/charactercreate/charactercreate_rightarrow_down.dds")
		Xynode.showHide = true
	end
end

function ShowHidePanel()
	XynodePanel:SetHidden(not XynodePanel:IsHidden())
end



function ShowGuide(bossOnly)

		DungeonText = ""
		DungeonName = ""
		if(bossOnly) then
			if(Xynode.Boss~= nil) then 
				if(GetUnitWorldPosition(UNITTAG_PLAYER) == 1436 and Xynode.Boss.iamechanic ~= nil) then
					DungeonText = Xynode.Boss.iamechanic
				else
					DungeonText = Xynode.Boss.mechanic
			end
				DungeonName = Xynode.Boss.Name
			end
		else
		DungeonName = Xynode.Dungeon.name
			-- add sets here
			--for key, value in ipairs(Xynode.Dungeon.Sets)
			--do
				--DungeonText = DungeonText..value.
			--end
			-- end sets temp
			for key, value in ipairs(Xynode.Dungeon.bosses)
			do
				DungeonText = DungeonText..Xynode.bosses[value].mechanic
			end
		end
		AddLine(DungeonText)


		if(not XynodeGuide:IsHidden()) then
			XynodeGuide:SetHidden(not XynodeGuide:IsHidden())
			XynodeGuideDungeonTitle:SetText(DungeonName)
		else



		if(DungeonText ~= "") then
			XynodeAbout:SetHidden(true)
			XynodeGuide:SetHidden(not XynodeGuide:IsHidden())
			XynodeGuideBG:SetAlpha(Xynode.savedVars.bgAlpha / 100)
			XynodeGuideContent:SetAlpha(Xynode.savedVars.fgAlpha / 100)
			XynodeGuideDungeonTitle:SetText(DungeonName)
			SetGameCameraUIMode(true)
		end
	end
end

function ShowYouTube()
	if(bossvideo ~= nil) then
		RequestOpenUnsafeURL(bossvideo)
	else
		RequestOpenUnsafeURL(Xynode.Dungeon.video)
	end
end



function CloseGuide()
    XynodeGuide:SetHidden(not XynodeGuide:IsHidden())
end





function Xynode.CheckBoss()
	BossNameNear = ""
	BossNameNearD = ""
	Xynode.Boss = nil
	bossvideo = nil



		for i = 1, MAX_BOSSES do
			if DoesUnitExist("boss"..i) then
				BossNameNear = GetUnitName('boss'..i)

				for key, value in ipairs(Xynode.bosses)
				do
					inDungeon = zo_strformat("<<Z:1>>",value.name)
					inFile = zo_strformat("<<Z:1>>", BossNameNear)
					if(string.find(inFile,inDungeon,1,true) ~= nil) then
						Xynode.Boss = Xynode.bosses[key]
					end
					if(Xynode.Boss ~= nil) then
						XynodePanelButtonBossGuide:SetMouseEnabled(true)
						XynodePanelButtonBossGuide:SetEnabled(true)
						if(Xynode.bosses[key].video ~= nil) then
							bossvideo = Xynode.bosses[key].video
						end
					end
					if(Xynode.Boss ~= nil) then
						break
					end
				end
			end
			if BossNameNear  ~= "" then

				XynodePanelButtonBossGuide:SetAlpha(1)
				XynodePanelCounter:SetText(BossNameNear)

				if(Xynode.BossSoundPlayed == false) then
					PlaySound(SOUNDS[Xynode.savedVars.bosssound])
					Xynode.BossSoundPlayed = true
				end



			else
				XynodePanelCounter:SetText(Xynode.zoneName)
				XynodePanelButtonBossGuide:SetMouseEnabled(false)
				XynodePanelButtonBossGuide:SetEnabled(false)
				XynodePanelButtonBossGuide:SetAlpha(0.25)
				Xynode.BossSoundPlayed = false

				bossvideo = nil
			end
		end
end


function Xynode.onAddonLoaded(event, addonName)
	if addonName ~= Xynode.name then return end
	EVENT_MANAGER:UnregisterForEvent(Xynode.name, EVENT_ADD_ON_LOADED)
	Xynode.Initialize()
end


EVENT_MANAGER:RegisterForEvent(Xynode.name, EVENT_ADD_ON_LOADED, Xynode.onAddonLoaded)

ZO_CreateStringId("SI_KEYBINDINGS_CATEGORY_XYNODE",    "|cffff00Xynode's|r All About Mechanics")
ZO_CreateStringId("SI_BINDING_NAME_XYNODE_SHOW_PANEL",  "Show/Hide Panel")
ZO_CreateStringId("SI_BINDING_NAME_XYNODE_SHOW_GUIDE",  "Show/Hide Guide")
ZO_CreateStringId("SI_BINDING_NAME_XYNODE_SHOW_BOSS_GUIDE",  "Show/Hide Boss Guide")
ZO_CreateStringId("SI_BINDING_NAME_XYNODE_SHOW_WEBSITE",  "All About Mechanics Website")
ZO_CreateStringId("SI_BINDING_NAME_XYNODE_SHOW_SETTINGS",  "Settings")
ZO_CreateStringId("SI_BINDING_NAME_XYNODE_SHOW_ABOUT",  "About Xynode")


