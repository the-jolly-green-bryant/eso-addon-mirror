-- SnapWin Dedicated Code ==================================================================================

local DOWN,UP = BSTATE_PRESSED,BSTATE_NORMAL

local fmt = string.format
local IsChecked = OT_IsButtonPressed

OTSnap.P1Fields = {
  {fid="Nom", name="Item Name",        head="Item"},
  {fid="Det", name="Details",          head="Details"},
  {fid="Id#", name="Item Id",          head="Id"},
  {fid="Amt", name="Quantity",         head="Qty"},
  {fid="Loc", name="Location",         head="Location"},
  {fid="Bag", name="Bag Id",           head="Bag"},
  {fid="ITx", name="Item Type",        head="Type"},
  {fid="IT#", name="Type Code",        head="Type#"},
  {fid="STx", name="Item Subtype",     head="Subtype"},
  {fid="ST#", name="Subtype Code",     head="Subtype#"},
  {fid="DQx", name="Disp Quality",     head="Quality"},
  {fid="DQ#", name="D. Quality Code",  head="Qual#"},
  {fid="FQx", name="Func Quality",     head="F.Quality"},
  {fid="FQ#", name="F. Quality Code",  head="F.Quality"},
  {fid="PVn", name="Price (Vendor)",   head="Vendor"},
  {fid="PAt", name="Price (ATT)",      head="ATT Price"},
  {fid="PMm", name="Price (MM)",       head="MM Price"},
  {fid="TTS", name="Price (TTC Sugg)", head="TTC Sugg"},
  {fid="TTA", name="Price (TTC Avg)",  head="TTC Avg"},
  {fid="TTL", name="Price (TTC Sale)", head="TTC Sale"},
  {fid="Bnd", name="Is Item Bound?",   head="Bound"},
  {fid="Sto", name="Is Item Stolen?",  head="Stolen"},
  {fid="Crw", name="Is Crown Item?",   head="Crown"},
  {fid="CrC", name="Is Crate Item?",   head="Crate"},
  {fid="MaR", name="Mail Received",    head="Mail Recd"},
  {fid="MaF", name="Mail From",        head="Mail From"},
  {fid="MaS", name="Mail Subject",     head="Mail Subj"},
  {fid="FuH", name="House Name",       head="House"},
  {fid="FuL", name="Furn Position",    head="Furn Pos"},
  {fid="FuR", name="Furn Orientation", head="Furn Or"}
} for ix=1,#OTSnap.P1Fields do
   OTSnap.P1Fields[ix].ser=ix
   OTSnap.P1Fields[ix].checked=false
end
OTSnap.P1Fields[1].checked=true
OTSnap.P1Fields[4].checked=true

OTSnap.P2G1List = {
  {fid="RMem", name="Membership Changes [ROSTER]" },
  {fid="RPro", name="Rank Changes [ROSTER]" },
  {fid="RApp", name="Applications [ROSTER]" },
  {fid="RBlk", name="Blacklist [ROSTER]" },
  {fid="IDep", name="Deposits [BANK ITEMS]" },
  {fid="IWdr", name="Withdrawals [BANK ITEMS]" },
  {fid="GDep", name="Deposits [BANK GOLD]" },
  {fid="GWdr", name="Withdrawals [BANK GOLD]" },
  {fid="GTra", name="Hired Trader [BANK GOLD]" },
  {fid="Sale", name="Sales Data [TRADER]" },
  {fid="Lock", name="Unlocks" },
  {fid="Cust", name="Customization" },
  {fid="AWar", name="Alliance War" }
} for ix=1,#OTSnap.P2G1List do
   OTSnap.P2G1List[ix].ser=ix
   OTSnap.P2G1List[ix].checked=false
end

-- Wed Mar 14, 9:40

-- =========================================================================================================

function OTSnap:GetDelimiter()                                                                 -- 2021/10/02
	if IsChecked(OTSnap_P9G2B1) then return "\t" end
	if IsChecked(OTSnap_P9G2B2) then return ";"  end
	if IsChecked(OTSnap_P9G2B3) then return "/"  end
	return ""
end

function OTSnap:ItemTypeReference()                                                            -- 2021/10/01
	OTSnap_P1G3B1T:SetText(OT_CleanNumberList(OTSnap_P1G3B1T:GetText()))
	if not OTType then
		CreateControlFromVirtual("OTType",nil,"OT_vRef")
		OTTypeTitle:SetText("Item Type Codes")
		OTType:ClearAnchors()
		OTType:SetAnchor(TOPLEFT,OTSnap_P1G3B1T,TOPLEFT,8,40)
		for ix=1,71 do
			local px,py = 8+math.floor((ix-1)/24)*197,35+math.fmod(ix-1,24)*21
			local labName = fmt("OTTypeBox%s",ix)
			local labText = OT_GetItemTypeName(ix)
			CreateControlFromVirtual(labName,OTType,"OT_vTextLine")
			_G[labName]:SetAnchor(TOPLEFT,OTRef,TOPLEFT,px,py)
			_G[labName]:SetText(fmt("%s. %s",ix,labText))
		end
	end
	OTType:SetHidden(not OTType:IsHidden())
end

function OTSnap:PageBack()
	SnapShot.PageNum = SnapShot.PageNum-1
	self:ShowPage()
end

function OTSnap:PageFore()
	SnapShot.PageNum = SnapShot.PageNum+1
	self:ShowPage()
end

function OTSnap:RotateText(uiObject)
	local roTable = {}
	if not uiObject.TextToRotate then uiObject:SetText("[*list error*]") return end
	for t in string.gmatch(uiObject.TextToRotate,"[^~]+") do table.insert(roTable,fmt("[%s]",t)) end
	for ix=1,#roTable do
		if uiObject:GetText() == roTable[ix] then
			if ix == #roTable
				then uiObject:SetText(roTable[1])
				else uiObject:SetText(roTable[ix+1])
			end
			SnapShot.saved.Texts[uiObject:GetName()] = uiObject:GetText()
			return
		end
	end
  uiObject:SetText(roTable[1])
end

function OTSnap:SetAllDrinks(state)                                                            -- 2021/10/10
	local buttonList = {8,9,10,11,12,13,14,15}
	local commonState = UP
	if state then commonState = DOWN end
	for i=1,#buttonList do
		local b = fmt("OTSnap_P4G1B%s",buttonList[i])
		_G[b]:SetState(commonState)
		SnapShot.saved.Buttons[b] = commonState
	end
end

function OTSnap:SetAllFood(state)                                                              -- 2021/10/10
	local buttonList = {1,2,3,4,5,6,7,16}
	local commonState = UP
	if state then commonState = DOWN end
	for i=1,#buttonList do
		local b = fmt("OTSnap_P4G1B%s",buttonList[i])
		_G[b]:SetState(commonState)
		SnapShot.saved.Buttons[b] = commonState
	end
end

function OTSnap:SetAllPlans(state)                                                             -- 2021/10/10
	local buttonList = {17,18,19,20,21,22,23,24,25,26,27,28,29,30}
	local commonState = UP
	if state then commonState = DOWN end
	for i=1,#buttonList do
		local b = fmt("OTSnap_P4G1B%s",buttonList[i])
		_G[b]:SetState(commonState)
		SnapShot.saved.Buttons[b] = commonState
	end
end

function OTSnap:ShowReport()                                                                   -- 2021/10/11
	if not OT_IsButtonPressed(OTSnap_P1G3B6) then
		local tHead = table.concat(SnapShot.Header,OTSnap:GetDelimiter())
		table.insert(SnapShot.Lines,1,tHead)
	end

	if #SnapShot.Lines > 0 then
		local lineLen,maxLine,sumChars = 0,0,0
		for ix=1,#SnapShot.Lines do
			lineLen = string.len(SnapShot.Lines[ix])+2
			sumChars = sumChars + lineLen
			if lineLen > maxLine then maxLine = lineLen end
		end
		SnapShot.PageLength = math.floor(26000 / math.ceil(sumChars/#SnapShot.Lines))
		if SnapShot.PageLength>600 then SnapShot.PageLength = 600 end
		SnapShot.PageCount = math.ceil(#SnapShot.Lines / SnapShot.PageLength)
	else
		SnapShot.PageLength = 600
		SnapShot.PageCount = 1
	end
	SnapShot.PageNum = 1
	if SnapShot.PageCount == 1 then SnapShot.PageLength = #SnapShot.Lines end
	d(fmt("Total |c40FF80%s|r pages of |c40FF80%s|r lines.",
		SnapShot.PageCount,SnapShot.PageLength))
	local tFoot = fmt("%s Pg %s of %s",
		SnapShot.ReportName,
		SnapShot.PageNum,
		SnapShot.PageCount
	)
	OTSnap_R0Edit:SetText(table.concat(SnapShot.Lines,"\n",1,SnapShot.PageLength))
	OTSnap_R0Edit:SetCursorPosition(1)
	OTSnap_R0:SetHidden(false)
	OTSnapPageIndicator:SetText(tFoot)
end

function OTSnap:ShowPage()
	if SnapShot.PageNum <= 1 then SnapShot.PageNum = 1 end
	if SnapShot.PageNum >= SnapShot.PageCount then SnapShot.PageNum = SnapShot.PageCount end
	local startAt = (SnapShot.PageNum-1)*SnapShot.PageLength+1
	local stopAt = SnapShot.PageNum*SnapShot.PageLength
	local tFoot = fmt("%s Page %s of %s",
		SnapShot.ReportName,
		SnapShot.PageNum,
		SnapShot.PageCount
	)
	if stopAt > #SnapShot.Lines then stopAt = #SnapShot.Lines end
	OTSnap_R0Edit:SetText(table.concat(SnapShot.Lines,"\n",startAt,stopAt))
	OTSnap_R0Edit:SetCursorPosition(1)
	OTSnapPageIndicator:SetText(tFoot)
end

-- =========================================================================================================

function OTSnap:GuildMakeList()                                                                -- 2021/10/03
	local gName = ""
	for ix=1,MAX_GUILDS do
		if ix <= GetNumGuilds()
			then gName = OT_GetGuildNameFromIndex(ix)
			else gName = "(empty slot)"
		end
		_G[fmt("OTSnap_P3G5B%sL",ix)]:SetText(gName)
		_G[fmt("OTSnap_G%s",ix)]:SetText(fmt("%s. %s",ix,gName))
	end
end

function OTSnap:GuildPick(uiObject)                                                            -- 2021/10/10
	ctrlNum=tonumber(string.sub(uiObject:GetName(),-1))
	if ctrlNum <= GetNumGuilds() then
		SnapShot.saved.Guild = ctrlNum
		OTSnap_GuildName:SetText(OT_GetGuildNameFromIndex(SnapShot.saved.Guild))
		if not OTSnap_P2:IsHidden() then
		end
	end
	OTSnap_G:SetHidden(not OTSnap_G:IsHidden())
end

function OTSnap:HandleCheckBox(button,buttonType)                                              -- 2021/10/27
	function Check(b)   ZO_CheckButton_SetChecked(b)   SnapShot.saved.Buttons[b:GetName()] = 1 end
	function Uncheck(b) ZO_CheckButton_SetUnchecked(b) SnapShot.saved.Buttons[b:GetName()] = 0 end
	if string.sub(button:GetName(),-1) == "L" then
		button = button:GetParent()
	end
	ZO_CheckButton_OnClicked(button)

	local bgroup = button:GetParent():GetName()
	local bname  = button:GetName()

	SnapShot.saved.Buttons[bname] = button:GetState()

	if bgroup == "OTSnap_P9G2" then -- Delimiter Radio
		for i=1,5 do
			local bt = GetControl("OTSnap_P9G2B",i)
			Uncheck(bt)
		end
		Check(button)
	end
	if bname == "OTSnap_P3G4B3" then -- Multi-Guild List
		OTSnap_P3G5:SetHidden(not IsChecked(button))
		OTSnap_P3G6:SetHidden(not IsChecked(button))
	end
	if IsChecked(button) then -- Exclusive buttons
		if     bname == "OTSnap_P3G4B1" then Uncheck(OTSnap_P3G4B2)
		elseif bname == "OTSnap_P3G4B2" then Uncheck(OTSnap_P3G4B1)
		elseif bname == "OTSnap_P4G3B1" then Uncheck(OTSnap_P4G3B2)
		elseif bname == "OTSnap_P4G3B2" then Uncheck(OTSnap_P4G3B1)
		elseif bname == "OTSnap_P7G1B1" then Uncheck(OTSnap_P7G1B2)
		elseif bname == "OTSnap_P7G1B2" then Uncheck(OTSnap_P7G1B1)
		end
	end
end

function OTSnap:MainMenuClick(target)                                                          -- 2021/10/03
	local targetp = _G[string.gsub(target:GetName(),"_M","_P")]
	OTSnap_R0:SetHidden(true)
	for ix=1,9 do
		_G[fmt("OTSnap_M%s",ix)]:SetState(UP)
		_G[fmt("OTSnap_P%s",ix)]:SetHidden(true)
	end
	target:SetState(DOWN)
	targetp:SetHidden(false)
	OTSnap_ML:SetText(string.upper(target:GetLabelControl():GetText()))
end

function OTSnap:SetToolTip(target,tipText)                                                     -- 2021/10/25
	InitializeTooltip(InformationTooltip, target, BOTTOM, 0, 0, TOP)
	SetTooltipText(InformationTooltip, tipText)
end

function OTSnap:ShowTextTip(target)
	if target.TipText then
		InitializeTooltip(InformationTooltip, target, TOPLEFT, 0, 0, BOTTOMLEFT)
		SetTooltipText(InformationTooltip, target.TipText)
	end
end

function OTSnap:WindowInitialize(wTop,wLeft)                                                   -- 2021/10/29
	self:ClearAnchors()
	self:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, wLeft, wTop)
	self:GuildMakeList()
	if SnapShot.saved.Guild > 0
		then OTSnap_GuildName:SetText(OT_GetGuildNameFromIndex(SnapShot.saved.Guild))
		else OTSnap_GuildName:SetText("(no guild)")
	end
	self:MainMenuClick(OTSnap_M1)

	OTSnap_Character:SetText(GetUnitName("player"))
	OTSnap_Account:SetText(GetDisplayName())

	for k,v in pairs(SnapShot.saved.Buttons) do
		if _G[k] then
			if v == 1
				then ZO_CheckButton_SetChecked(_G[k])
				else ZO_CheckButton_SetUnchecked(_G[k])
			end
		end
	end
	for k,v in pairs(SnapShot.saved.Texts) do
		if _G[k] then _G[k]:SetText(v) end
	end
	local delimiter = false
	for i=1,5 do delimiter = delimiter or IsChecked(GetControl("OTSnap_P9G2B",i)) end
	if not delimiter then OTSnap:HandleCheckBox(OTSnap_P9G2B1,"R") end

  OTSnap.SetupP1FieldList()
  OTSnap.SetupP2G1List()
end

function OTSnap:WindowSavePosition()                                                           -- 2021/10/04
  SnapShot.saved.winLeft = OTSnap:GetLeft()
  SnapShot.saved.winTop  = OTSnap:GetTop()
end

-- =========================================================================================================

function OTSnap.SetupP1FieldList()
  ZO_ScrollList_AddDataType(OTSnap_P1FieldList,1,"ZO_SelectableLabel",24,OTSnap.LayoutRow,nil,nil,nil)
  OTSnap.UpdateScrollList(OTSnap_P1FieldList,OTSnap.P1Fields,1)
end
function OTSnap.SetupP2G1List()
  ZO_ScrollList_AddDataType(OTSnap_P2G1List,1,"ZO_SelectableLabel",24,OTSnap.LayoutRow,nil,nil,nil)
  OTSnap.UpdateScrollList(OTSnap_P2G1List,OTSnap.P2G1List,1)
end

function OTSnap.LayoutRow(rowControl, data, scrollList)
  rowControl:SetFont("ZoFontWinH4")
  rowControl:SetMaxLineCount(1)
  if data.checked
    then rowControl:SetText(data.name.." √")
    else rowControl:SetText(data.name)
  end
  rowControl:SetHandler("OnMouseUp",function() OTSnap.CheckLabel(scrollList,rowControl) end)
end

function OTSnap.CheckLabel(self,control)
  local me = control:GetParent():GetParent():GetName()
  local ser = control.dataEntry.data.ser

  if me == "OTSnap_P1FieldList" then
    OTSnap.P1Fields[ser].checked = not OTSnap.P1Fields[ser].checked
    if OTSnap.P1Fields[ser].checked
      then control:SetText(OTSnap.P1Fields[ser].name.." √")
      else control:SetText(OTSnap.P1Fields[ser].name)
    end
    SnapShot.saved.P1Fields[OTSnap.P1Fields[ser].fid] = OTSnap.P1Fields[ser].checked
    OTSnap.UpdateScrollList(OTSnap_P1FieldList,OTSnap.P1Fields,1)
  end
  if me == "OTSnap_P2G1List" then
    OTSnap.P2G1List[ser].checked = not OTSnap.P2G1List[ser].checked
    if OTSnap.P2G1List[ser].checked
      then control:SetText(OTSnap.P2G1List[ser].name.." √")
      else control:SetText(OTSnap.P2G1List[ser].name)
    end
    SnapShot.saved.P2G1List[OTSnap.P2G1List[ser].fid] = OTSnap.P2G1List[ser].checked
    OTSnap.UpdateScrollList(OTSnap_P2G1List,OTSnap.P2G1List,1)
  end
end

function OTSnap.UpdateScrollList(control,data,rowType)
  local dataCopy = ZO_DeepTableCopy(data)
  local dataList = ZO_ScrollList_GetDataList(control)
  ZO_ScrollList_Clear(control)
  for key, value in ipairs(dataCopy) do
    local entry = ZO_ScrollList_CreateDataEntry(rowType, value)
    table.insert(dataList, entry)
  end
	ZO_ScrollList_Commit(control)
end


--[[
function OTSnap.OnRowSelect(previouslySelectedData, selectedData, reselectingDuringRebuild)
  if not selectedData then return end
  if selectedData.sel
    then selectedData.sel = false selectedData.name = string.gsub(selectedData.name, " √","")
    else selectedData.sel = true  selectedData.name = selectedData.name.." √"
  end
	ZO_ScrollList_Commit(OTSnap_P1FieldList)
end
--]]
function OTSnap:GoToLastPage()
    -- Set the current page to the last page
    SnapShot.PageNum = SnapShot.PageCount
    self:ShowPage()  -- Refresh the UI to display the last page
end