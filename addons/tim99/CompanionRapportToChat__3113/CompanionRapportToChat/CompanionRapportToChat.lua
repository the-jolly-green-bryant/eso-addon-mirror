CompanionRapportToChat = CompanionRapportToChat or {}
local COMPInfo = CompanionRapportToChat
local icoBitchUp = [[/CompanionRapportToChat/pics/rapport_up.dds]]
local icoBitchDown = [[/CompanionRapportToChat/pics/rapport_down.dds]]

COMPInfo.Name = "CompanionRapportToChat"
COMPInfo.Author = "tim99"
COMPInfo.Version = 2
COMPInfo.rappLvl = 0
COMPInfo.rappMin = GetMinimumRapport()
COMPInfo.rappMax = GetMaximumRapport()
--------------------------------------------------------------------------------------------------
local function createCompanionRapportLabels()
	local lblMin = WINDOW_MANAGER:CreateControl(nil, ZO_CompanionOverview_Panel_KeyboardRapportContainerProgressIconLeft, CT_LABEL)
	lblMin:SetAnchor(TOPLEFT, ZO_CompanionOverview_Panel_KeyboardRapportContainerProgressIconLeft, BOTTOMLEFT, -10, 0)
	lblMin:SetVerticalAlignment(TEXT_ALIGN_LEFT)
	lblMin:SetFont("ZoFontGame")
	lblMin:SetText(zo_strformat(SI_NUMBER_FORMAT, COMPInfo.rappMin))
	
	local lblMax = WINDOW_MANAGER:CreateControl(nil,ZO_CompanionOverview_Panel_KeyboardRapportContainerProgressIconRight, CT_LABEL)
	lblMax:SetAnchor(TOPLEFT, ZO_CompanionOverview_Panel_KeyboardRapportContainerProgressIconRight, BOTTOMLEFT, 0, 0)
	lblMax:SetVerticalAlignment(TEXT_ALIGN_LEFT)
	lblMax:SetFont("ZoFontGame")
	lblMax:SetText(zo_strformat(SI_NUMBER_FORMAT, COMPInfo.rappMax))
	
	COMPInfo.lblVal = WINDOW_MANAGER:CreateControl(nil, ZO_CompanionOverview_Panel_KeyboardRapportContainerProgressBar, CT_BUTTON)
	COMPInfo.lblVal:SetWidth(ZO_CompanionOverview_Panel_KeyboardRapportContainerProgressBar:GetWidth())
	COMPInfo.lblVal:SetAnchor(BOTTOM, ZO_CompanionOverview_Panel_KeyboardRapportContainerProgressBar, TOP, 0, 2)
	COMPInfo.lblVal:SetVerticalAlignment(TEXT_ALIGN_CENTER)
	COMPInfo.lblVal:SetFont("$(BOLD_FONT)|$(KB_18)|outline") --MEDIUM_FONT --BOLD_FONT
	
	COMPInfo.lblSrc = WINDOW_MANAGER:CreateControl(nil, ZO_CompanionCharacter_Keyboard_TopLevelNavigationContainer,CT_LABEL)
	COMPInfo.lblSrc:SetAnchor(BOTTOMLEFT,ZO_CompanionCharacter_Keyboard_TopLevelNavigationContainer,BOTTOMLEFT,40,0)
	COMPInfo.lblSrc:SetVerticalAlignment(TEXT_ALIGN_LEFT)
	COMPInfo.lblSrc:SetFont("ZoFontGame")
end
--------------------------------------------------------------------------------------------------
local function OnOpenCompanionMenu()
	--rapport
	COMPInfo.lblVal:SetText(zo_strformat(SI_NUMBER_FORMAT, GetActiveCompanionRapport()))
	--sources
	local activeComp=GetActiveCompanionDefId()
	local compname=zo_strformat("<<1>>:", GetCompanionName(activeComp)) --/script d(GetActiveCompanionDefId())
	local sources={}
	table.insert(sources, string.format("|c9B30FF%s|r", compname))
	if activeComp==1 then     --basti
		table.insert(sources, "- Mages Guild daily |cffcc00(125)|r")
		table.insert(sources, "- Visit Artaeum |c3399ff(10)|r")
		table.insert(sources, "- Read book |c5cd65c(1)|r")
	elseif activeComp==2 then --mirri
		table.insert(sources, "- Ashlander daily |cffcc00(125)|r")
		table.insert(sources, "- Fighters Guild daily |cffcc00(125)|r")
		table.insert(sources, "- Visit Daedric Delve |c3399ff(10)|r")
		table.insert(sources, "- Visit Brass Fortress |c3399ff(10)|r")
		table.insert(sources, "- Read book |c5cd65c(1)|r")
		table.insert(sources, "- Kill snake |c5cd65c(1)|r")
		table.insert(sources, "- Craft alcohol |c5cd65c(1)|r")
	elseif activeComp==5 then --funke
		table.insert(sources, "- Mages Guild daily |cffcc00(125)|r")
		table.insert(sources, "- High Isle Delve daily |cffcc00(125)|r")
		table.insert(sources, "- “Flee” options by Guards |c3399ff(10)|r")
		table.insert(sources, "- Outlaws refuge |c5cd65c(1)|r")
		table.insert(sources, "- Runestone/Wolf |c5cd65c(1)|r")
	elseif activeComp==6 then --iso
		table.insert(sources, "- Bolgrul daily |cffcc00(125)|r")
		table.insert(sources, "- High Isle WB daily |cffcc00(125)|r")
		table.insert(sources, "- Kill any Boss |c3399ff(5)|r")
		table.insert(sources, "- Craft Blacksmith/Sweets |c3399ff(5)|r")
		table.insert(sources, "- Visit Undaunted |c3399ff(5)|r")
	elseif activeComp==8 then --gerissen
		table.insert(sources, "- Ashlander Hunt daily |cffcc00(125)|r")
		table.insert(sources, "- Necrom WB daily |cffcc00(125)|r")
		table.insert(sources, "- Visit Hist Trees |c3399ff(10)|r")
		table.insert(sources, "- Harvest Alchemy/Fish |c5cd65c(1)|r")
	elseif activeComp==9 then --aza
		table.insert(sources, "- Enchanting Crafting Writ |cffcc00(125)|r")
		table.insert(sources, "- Necrom Delve daily |cffcc00(125)|r")
		table.insert(sources, "- Visit Mundus Stones |c3399ff(10)|r")
		table.insert(sources, "- Visit Coldharbour/Brass Fortress |c3399ff(10)|r")
		table.insert(sources, "- Craft Tea |c5cd65c(1)|r")
	--whoever told zos how to count should be ashamed for the rest of his life...!
	elseif activeComp==12 then --tanlorin
		table.insert(sources, "- Alchemy Crafting Writ |cffcc00(125)|r")
		table.insert(sources, "- Fighters Guild daily |cffcc00(125)|r")
		table.insert(sources, "- Visit a Mundus Stone |c3399ff(10)|r")
		table.insert(sources, "- Visit Alinor |c3399ff(5)|r")
		table.insert(sources, "- Use the Campfire Kit memento |c3399ff(5)|r")
		table.insert(sources, "- Drink wine |c3399ff(5)|r")
		table.insert(sources, "- Lockpick a lock |c3399ff(5)|r")
		table.insert(sources, "- Mount an Indrik |c5cd65c(1)|r")
		table.insert(sources, "- Harvest a flower |c5cd65c(1)|r")
	elseif activeComp==13 then --zerith-var
		table.insert(sources, "- Daily quest of Zahari (Grathwood)|cffcc00(125)|r")
		table.insert(sources, "- ToT daily quest |cffcc00(125)|r")
		table.insert(sources, "- Dark Anchor encounter |c3399ff(10)|r")
		table.insert(sources, "- Kill a Dragon |c3399ff(10)|r")
		table.insert(sources, "- Complete a ToT match |c3399ff(10)|r")
		table.insert(sources, "- Visit Baandari Trading Post |c3399ff(5)|r")
		table.insert(sources, "- Kill Vampire/Skeleton/Dro-m'Athra |c5cd65c(1)|r")
	end
	COMPInfo.lblSrc:SetText(table.concat(sources,"\n"))
end
--------------------------------------------------------------------------------------------------
local function OnRapportUpdate(event, compId, prevRapport, currRapport)
	local myGain = currRapport - prevRapport
	local myIcon = (currRapport > prevRapport) and icoBitchUp or icoBitchDown
	local myText = zo_strformat('<<1>> ', myGain)
	if (currRapport > prevRapport) then myText = zo_strformat('+<<1>> ', myGain) end

	CHAT_SYSTEM:AddMessage(zo_strformat('|c666666[<<1>>]|r <<2>>: |t18:18:<<3>>|t<<4>>|u1:2::|u(<<5>> / <<6>>)', GetTimeString(), GetCompanionName(compId), myIcon, myText, zo_strformat(SI_NUMBER_FORMAT, currRapport), zo_strformat(SI_NUMBER_FORMAT, COMPInfo.rappMax)))
	--if GetActiveCompanionRapportLevel()~= 7 then
	--	if COMPInfo.rappLvl ~= GetActiveCompanionRapportLevel() then
	--		COMPInfo.rappLvl = GetActiveCompanionRapportLevel()
	--		CHAT_SYSTEM:AddMessage(zo_strformat('Rapport-Info: <<1>> is level <<2>> / 7', GetCompanionName(compId), COMPInfo.rappLvl))
	--	end
	--end
end
--------------------------------------------------------------------------------------------------
function COMPInfo.init(event, addonName)
	if addonName ~= COMPInfo.Name then return end
	
	EVENT_MANAGER:UnregisterForEvent(COMPInfo.Name, EVENT_ADD_ON_LOADED)
	EVENT_MANAGER:RegisterForEvent(COMPInfo.Name, EVENT_COMPANION_RAPPORT_UPDATE, OnRapportUpdate)
	
	if not IsInGamepadPreferredMode() then
		createCompanionRapportLabels()
		EVENT_MANAGER:RegisterForEvent(COMPInfo.Name, EVENT_OPEN_COMPANION_MENU, OnOpenCompanionMenu)
	end
end
--------------------------------------------------------------------------------------------------
EVENT_MANAGER:RegisterForEvent(COMPInfo.Name, EVENT_ADD_ON_LOADED, COMPInfo.init)
