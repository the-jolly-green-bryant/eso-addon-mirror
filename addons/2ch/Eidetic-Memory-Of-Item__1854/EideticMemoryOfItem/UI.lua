EMOI.UI = {}
EMOI.UI.page = 1
local function ShowTooltip(self)
	if string.match(self:GetText(),"|H(.-):(.-)|h(.-)|h")then
		InitializeTooltip(ItemTooltip, self)
		ItemTooltip:SetLink(self:GetText())
	end
end
local function HideTooltip(self)
	ClearTooltip(ItemTooltip)
end
local function OnClickedLine(self,btn)
	if btn == 1 then -- RMB==2, LMB==1
	--[[
		ClearMenu()
		AddMenuItem("quick brown", function() d("fox") end)
		AddMenuItem("lazy", function() d("dog") end)
		ShowMenu(self)
		--]]
	end
end
local function GetItemID(itemLink)
  local itemId = itemLink:match("|H[^:]+:item:([^:]+):")
  -- d("itemLink:"..itemLink)
  return tonumber(itemId)
end
local function addChatText(text)
	text = _G["ZO_ChatWindowTextEntryEditBox"]:GetText()..text
	_G["ZO_ChatWindowTextEntryEditBox"]:SetText(text)
end
local function OnMouseUpLine(self,btn,upInside)
	if btn == 2 then -- RMB==2, LMB==1
		ClearMenu()
		AddMenuItem("Link in Chat", function() addChatText(self.data.itemLink) end)
		if self.data.zoneIndex ~= nil then
			AddMenuItem(GetZoneNameByIndex(self.data.zoneIndex), function()  end)
		end
		AddMenuItem(self.data.charName, function() end)
		AddMenuItem(os.date("%c",self.data.time), function() end)
		--AddMenuItem("memo", function() d(self.data.itemName) end)
		AddMenuItem("delete", function() 
			table.remove(EMOI.SavedVar.savedVariables.saveData, self.tableIndex)
			EMOI.setLines(EMOI.UI.page)
		end)
		ShowMenu(self)
		
	end
end
local function OnReceiveDrag(...)
	if GetCursorContentType() == MOUSE_CONTENT_INVENTORY_ITEM then
		local data = {}
		local itemLink = GetItemLink(GetCursorBagId(),GetCursorSlotIndex())
		data.itemLink = itemLink
		data.time = os.time()
		data.charName = GetUnitName("player")
		data.zoneIndex = GetCurrentMapZoneIndex()
		data.itemID = GetItemID(itemLink)
		data.itemName = GetItemLinkName(itemLink)
		data.memo = ""
		table.insert(EMOI.SavedVar.savedVariables.saveData, data)
		if EMOI.SavedVar.savedVariables.addedLog then d("EMOI_added:"..data.itemLink) end
		--EMOI.addData(itemLink)
		EMOI.sort("time",true)
		EMOI.lastestPage()
	elseif type == MOUSE_CONTENT_EQUIPPED_ITEM then
		
	end
	ClearCursor()
end
local function OnClickedButtonP()
	if EMOI.UI.page == 1 then 
		local maxPage = table.maxn(EMOI.SavedVar.savedVariables.filteredList) / EMOI.SavedVar.savedVariables.pageLines
		maxPage = math.ceil(maxPage)
		EMOI.setLines(maxPage)
	else
		EMOI.setLines(EMOI.UI.page - 1)
	end
end
local function OnClickedButtonN()
	local maxPage = table.maxn(EMOI.SavedVar.savedVariables.filteredList) / EMOI.SavedVar.savedVariables.pageLines
	maxPage = math.ceil(maxPage)
	if EMOI.UI.page + 1 > maxPage then
		EMOI.setLines(1)
	else
		EMOI.setLines(EMOI.UI.page + 1)
	end
end
local function OnMoveStop()
	EMOI.SavedVar.savedVariables.posX = EMOI.UI.bg:GetLeft()
	EMOI.SavedVar.savedVariables.posY = EMOI.UI.bg:GetTop()
end
local function OnClickedButtonX()
	EMOI.UI.MainAnchor:SetHidden(true)
end
local function OnClickedButtonS(str)
	EMOI.sort(str)
end
local function OnTextChangedFilter()
	if EMOI.init then
		EMOI.SavedVar.savedVariables.filter = EMOI.UI.filter:GetText()
		EMOI.sort(EMOI.SavedVar.savedVariables.mode)
	end
end
local function OnMouseDownF()
	EMOI.UI.filter:TakeFocus()
end	
function EMOI.UI.createUI()
	if (EMOI.UI.MainAnchor ~= nil) then return end
	EMOI.UI.MainAnchor = WINDOW_MANAGER:CreateTopLevelWindow("EMOI_MainAnchor")
	EMOI.UI.bg = WINDOW_MANAGER:CreateControl("EMOI_BG", EMOI.UI.MainAnchor, CT_BACKDROP)
	EMOI.UI.bg:SetAnchor(0, EMOI.UI.MainAnchor, TOPLEFT, EMOI.SavedVar.savedVariables.posX, EMOI.SavedVar.savedVariables.posY)
	EMOI.UI.bg:SetDimensions(500, 400)
	EMOI.UI.bg:SetCenterColor(0, 0, 0, 1)
	EMOI.UI.bg:SetEdgeColor(0.2, 0.2, 0.2, 1)
	EMOI.UI.bg:SetMovable(true)
	EMOI.UI.bg:SetMouseEnabled(true)	
	EMOI.UI.bg:SetHandler("OnReceiveDrag", OnReceiveDrag)
	EMOI.UI.bg:SetHandler("OnMoveStop", OnMoveStop)
	EMOI.UI.bg:SetHandler("OnClicked", OnClickedLine)
	EMOI.UI.xBtn = WINDOW_MANAGER:CreateControl("EMOI_xButton", EMOI.UI.bg, CT_BUTTON)
	EMOI.UI.xBtn:SetAnchor(0, EMOI.UI.bg, TOPRIGHT, -16, 0)
	EMOI.UI.xBtn:SetDimensions(16, 16)
	EMOI.UI.xBtn:SetNormalTexture("EideticMemoryOfItem/img/x.dds")
	EMOI.UI.xBtn:SetText("x")
	EMOI.UI.xBtn:SetHandler("OnClicked", OnClickedButtonX )
		
	EMOI.UI.label = WINDOW_MANAGER:CreateControl("EMOIlabel1", EMOI.UI.MainAnchor, CT_LABEL)
	EMOI.UI.label:SetFont("ZoFontGame")
	EMOI.UI.label:SetAnchor(TOPLEFT, EMOI.UI.bg, TOPLEFT, 180, 20)
	EMOI.UI.label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
	EMOI.UI.label:SetDrawLayer(2)
	
	EMOI.UI.label2 = WINDOW_MANAGER:CreateControl("EMOIlabel2", EMOI.UI.MainAnchor, CT_LABEL)
	EMOI.UI.label2:SetFont("ZoFontGame")
	EMOI.UI.label2:SetAnchor(TOPLEFT, EMOI.UI.bg, TOPLEFT, 10, 50)
	EMOI.UI.label2:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
	EMOI.UI.label2:SetDrawLayer(2)
	EMOI.UI.label2:SetText("Sort:")

	EMOI.UI.label3 = WINDOW_MANAGER:CreateControl("EMOIlabel3", EMOI.UI.MainAnchor, CT_LABEL)
	EMOI.UI.label3:SetFont("ZoFontGame")
	EMOI.UI.label3:SetAnchor(TOPLEFT, EMOI.UI.bg, TOPLEFT, 235, 50)
	EMOI.UI.label3:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
	EMOI.UI.label3:SetDrawLayer(2)
	EMOI.UI.label3:SetText("Search:")
	
	EMOI.UI.filterBg = WINDOW_MANAGER:CreateControl("EMOI_FilerBG", EMOI.UI.MainAnchor, CT_BACKDROP)
	EMOI.UI.filterBg:SetAnchor(TOPLEFT, EMOI.UI.bg, TOPLEFT, 280, 50)
	EMOI.UI.filterBg:SetDimensions(200, 23)
	EMOI.UI.filterBg:SetCenterColor(0.2, 0.2, 0.2, 1)
	EMOI.UI.filterBg:SetEdgeColor(0.2, 0.2, 0.2, 0)
	EMOI.UI.filterBg:SetDrawLayer(2)
		
	EMOI.UI.filter = WINDOW_MANAGER:CreateControl("EMOIeditbox", EMOI.UI.MainAnchor, CT_EDITBOX)
	EMOI.UI.filter:SetFont("ZoFontGame")
	EMOI.UI.filter:SetAnchor(TOPLEFT, EMOI.UI.bg, TOPLEFT, 280, 50)
	EMOI.UI.filter:SetDimensions(200, 23)
	EMOI.UI.filter:SetMouseEnabled(true)
	EMOI.UI.filter:SetEditEnabled(true)
	EMOI.UI.filter:SetDrawLayer(3)
	--EMOI.UI.filter:SetColor(0.9,0.9,0.9,1)
	EMOI.UI.filter:SetHandler("OnTextChanged", OnTextChangedFilter)
	EMOI.UI.filter:SetHandler("OnMouseDown", OnMouseDownF)
	EMOI.UI.filter:SetText(EMOI.SavedVar.savedVariables.filter)
			
	EMOI.UI.pBtn = WINDOW_MANAGER:CreateControl("EMOI_prevButton", EMOI.UI.bg, CT_BUTTON)
	EMOI.UI.pBtn:SetAnchor(0, EMOI.UI.bg, TOPLEFT, 10, 10)
	EMOI.UI.pBtn:SetDimensions(64, 32)
	EMOI.UI.pBtn:SetNormalTexture("EideticMemoryOfItem/img/prev.dds")
	EMOI.UI.pBtn:SetText("<")
	EMOI.UI.pBtn:SetHandler("OnClicked", OnClickedButtonP)
	EMOI.UI.pBtn.page = 1

	EMOI.UI.nBtn = WINDOW_MANAGER:CreateControl("EMOI_nextButton", EMOI.UI.bg, CT_BUTTON)
	EMOI.UI.nBtn:SetAnchor(0, EMOI.UI.bg, TOPLEFT, 100, 10)
	EMOI.UI.nBtn:SetDimensions(64, 32)
	EMOI.UI.nBtn:SetNormalTexture("EideticMemoryOfItem/img/next.dds")
	EMOI.UI.nBtn:SetText(">")
	EMOI.UI.nBtn:SetHandler("OnClicked", OnClickedButtonN)
	EMOI.UI.nBtn.page = 1
	EMOI.UI.MainAnchor:SetHidden(true)
	
	EMOI.UI.sort1Btn = WINDOW_MANAGER:CreateControl("EMOI_s1Button", EMOI.UI.bg, CT_BUTTON)
	EMOI.UI.sort1Btn:SetAnchor(0, EMOI.UI.bg, TOPLEFT, 50, 50)
	EMOI.UI.sort1Btn:SetDimensions(50, 25)
	EMOI.UI.sort1Btn:SetNormalTexture("EideticMemoryOfItem/img/name.dds")
	EMOI.UI.sort1Btn:SetText("s")
	EMOI.UI.sort1Btn:SetHandler("OnClicked",function () OnClickedButtonS("itemName") end)

	EMOI.UI.sort2Btn = WINDOW_MANAGER:CreateControl("EMOI_s2Button", EMOI.UI.bg, CT_BUTTON)
	EMOI.UI.sort2Btn:SetAnchor(0, EMOI.UI.bg, TOPLEFT, 50+50+5, 50)
	EMOI.UI.sort2Btn:SetDimensions(50, 25)
	EMOI.UI.sort2Btn:SetNormalTexture("EideticMemoryOfItem/img/id.dds")
	EMOI.UI.sort2Btn:SetText("s")
	EMOI.UI.sort2Btn:SetHandler("OnClicked",function () OnClickedButtonS("itemID") end)

	EMOI.UI.sort3Btn = WINDOW_MANAGER:CreateControl("EMOI_s3Button", EMOI.UI.bg, CT_BUTTON)
	EMOI.UI.sort3Btn:SetAnchor(0, EMOI.UI.bg, TOPLEFT, 50+100+10, 50)
	EMOI.UI.sort3Btn:SetDimensions(50, 25)
	EMOI.UI.sort3Btn:SetNormalTexture("EideticMemoryOfItem/img/time.dds")
	EMOI.UI.sort3Btn:SetText("s")
	EMOI.UI.sort3Btn:SetHandler("OnClicked",function () OnClickedButtonS("time") end)

	EMOI.UI.lines = {}
	for i = 1 , EMOI.SavedVar.savedVariables.pageLines do
		EMOI.UI.lines[i] = WINDOW_MANAGER:CreateControl("EMOILine"..i, EMOI.UI.bg, CT_LABEL)
		EMOI.UI.lines[i]:SetFont("$(MEDIUM_FONT)|"..EMOI.SavedVar.savedVariables.fontSize.."|soft-shadow-thin")
		EMOI.UI.lines[i]:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
		EMOI.UI.lines[i]:SetDrawLayer(2)
		EMOI.UI.lines[i]:SetText("---")
		if i == 1 then
			EMOI.UI.lines[i]:SetAnchor(TOPLEFT, EMOI.UI.bg, TOPLEFT, 10, 100)
		else
			local _,_,_,_,_,top = EMOI.UI.lines[i-1]:GetAnchor()
			EMOI.UI.lines[i]:SetAnchor(TOPLEFT, EMOI.UI.bg, TOPLEFT, 10, ((EMOI.UI.lines[i-1]:GetFontHeight()+2) + top))
		end
		EMOI.UI.lines[i]:SetMouseEnabled(true)
		EMOI.UI.lines[i]:SetHandler("OnMouseEnter", ShowTooltip)
		EMOI.UI.lines[i]:SetHandler("OnMouseExit", HideTooltip)
		EMOI.UI.lines[i]:SetHandler("OnMouseUp", OnMouseUpLine)
	end
	local _,_,_,_,_,h = EMOI.UI.lines[EMOI.SavedVar.savedVariables.pageLines]:GetAnchor()
	h = (EMOI.UI.lines[EMOI.SavedVar.savedVariables.pageLines]:GetFontHeight()+2) + h+10
	EMOI.UI.bg:SetDimensions(500, h)
end
function EMOI.UI.ToggleUI()
	if (EMOI.UI.MainAnchor == nil) then return end
	EMOI.UI.MainAnchor:ToggleHidden()
	if(not EMOI.UI.MainAnchor:IsHidden()) then
		ShowMouse(true)
	end
end
function EMOI.UI.ReflectSetting()
	local fontSize = EMOI.SavedVar.savedVariables.fontSize or EMOI.SavedVar.Default.fontSize
	for i = 1 , EMOI.SavedVar.savedVariables.pageLines do
		if EMOI.UI.lines[i] == nil then
			EMOI.UI.lines[i] = WINDOW_MANAGER:CreateControl("EMOILine"..i, EMOI.UI.bg, CT_LABEL)
			EMOI.UI.lines[i]:SetFont("$(MEDIUM_FONT)|"..EMOI.SavedVar.savedVariables.fontSize.."|soft-shadow-thin")
			EMOI.UI.lines[i]:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
			EMOI.UI.lines[i]:SetDrawLayer(2)
			EMOI.UI.lines[i]:SetText("---")
			if i == 1 then
				EMOI.UI.lines[i]:SetAnchor(TOPLEFT, EMOI.UI.bg, TOPLEFT, 10, 100)
			else
				local _,_,_,_,_,top = EMOI.UI.lines[i-1]:GetAnchor()
				EMOI.UI.lines[i]:SetAnchor(TOPLEFT, EMOI.UI.bg, TOPLEFT, 10, ((EMOI.UI.lines[i-1]:GetFontHeight()+2) + top))
			end
			EMOI.UI.lines[i]:SetMouseEnabled(true)
			EMOI.UI.lines[i]:SetHandler("OnMouseEnter", ShowTooltip)
			EMOI.UI.lines[i]:SetHandler("OnMouseExit", HideTooltip)
			EMOI.UI.lines[i]:SetHandler("OnMouseUp", OnMouseUpLine)
			EMOI.UI.lines[i]:SetHidden(false)
		else
			EMOI.UI.lines[i]:SetFont("$(MEDIUM_FONT)|"..EMOI.SavedVar.savedVariables.fontSize.."|soft-shadow-thin")
			EMOI.UI.lines[i]:SetText("---")
			if i == 1 then
				EMOI.UI.lines[i]:SetAnchor(TOPLEFT, EMOI.UI.bg, TOPLEFT, 10, 100)
			else
				local _,_,_,_,_,top = EMOI.UI.lines[i-1]:GetAnchor()
				EMOI.UI.lines[i]:SetAnchor(TOPLEFT, EMOI.UI.bg, TOPLEFT, 10, ((EMOI.UI.lines[i-1]:GetFontHeight()+2) + top))
			end
			EMOI.UI.lines[i]:SetHidden(false)
		end
	end
	for j, line in ipairs(EMOI.UI.lines) do
		if j > EMOI.SavedVar.savedVariables.pageLines then
			line:SetHidden(true)
		end
	end
	local _,_,_,_,_,h = EMOI.UI.lines[EMOI.SavedVar.savedVariables.pageLines]:GetAnchor()
	h = (EMOI.UI.lines[EMOI.SavedVar.savedVariables.pageLines]:GetFontHeight()+2) + h+10
	EMOI.UI.bg:SetDimensions(500, h)
	EMOI.setLines(nil)
end
