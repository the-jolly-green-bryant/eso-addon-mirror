

HotepMRP = {
  name = "HotepMailRPatch",
  saved = {},
  sent = {},
  selected = false,
}

local ROWCOLOR_YELLOW = ZO_ColorDef:New(1, 1, 0, 1)




local UI_MailList = ZO_SortFilterList:Subclass()

UI_MailList.defaults = {}

UI_MailList.SORT_KEYS = {
  ["recipient"] = {},
  ["timesent"] = {},
  ["subject"] = {},
}

function UI_MailList:New(control, showingType)
  local filterlist = ZO_SortFilterList.New(self, control)
  
  filterlist.SHOWING_TYPE = showingType
  
  filterlist.masterList = {}
  
  ZO_ScrollList_AddDataType(filterlist.list, 1, "HOTEPMRP_UI_main_List_Row", 32, function(control, data) filterlist:SetupOrderRow(control, data) end)
  
  ZO_ScrollList_EnableHighlight(filterlist.list, "ZO_ThinListHighlight")
  
  filterlist.currentSortKey = "timesent" -- default sort
  filterlist.currentSortOrder = "ZO_SORT_ORDER_DOWN"
  
  filterlist.sortFunction = function(listEntry1, listEntry2)
      return ZO_TableOrderingFunction(listEntry1.data, listEntry2.data, filterlist.currentSortKey, filterlist.SORT_KEYS, filterlist.currentSortOrder)
    end
  
  filterlist:SetAlternateRowBackgrounds(true)
  
  return filterlist
end

---
-- @param rowControl @class table
-- @param data @class table
-- @return @class nil
function UI_MailList:SetupOrderRow(rowControl, data)
  
  local rowcolor = ZO_ColorDef:New(MailR.DEFAULT_SAVE_MAIL_COLOR_STRING:gsub("^|c", ""))
  if (self.SHOWING_TYPE == "SENT") then
    rowcolor = ZO_ColorDef:New(MailR.DEFAULT_SENT_MAIL_COLOR_STRING:gsub("^|c", ""))
  end
  
  if (HotepMRP.selected and (HotepMRP.selected.mailid == data.mailid)) then
    rowcolor = ROWCOLOR_YELLOW
  end
  
  rowControl.data = data
  rowControl.recipient = GetControl(rowControl, "recipient")
  rowControl.sent = GetControl(rowControl, "sent")
  rowControl.subject = GetControl(rowControl, "subject")
  rowControl.hotep = GetControl(rowControl, "hotep")
  
  rowControl.recipient:SetText(data.recipient)
  rowControl.sent:SetText(data.sent)
  rowControl.subject:SetText(data.subject)
  
  rowControl.recipient.normalColor = rowcolor
  rowControl.sent.normalColor = rowcolor
  rowControl.subject.normalColor = rowcolor
  
  if (HotepMRP.selected and (HotepMRP.selected.mailid == data.mailid)) then
    rowControl.hotep:SetHidden(false)
  else
    rowControl.hotep:SetHidden(true)
  end
  
  ZO_SortFilterList.SetupRow(self, rowControl, data)
end


function UI_MailList:BuildMasterList()
  self.masterList = HotepMRP.GetList(self.SHOWING_TYPE)
end


function UI_MailList:FilterScrollList()
  local scrollData = ZO_ScrollList_GetDataList(self.list)
  ZO_ClearNumericallyIndexedTable(scrollData)
  
  for i = 1, #self.masterList do
    local data = self.masterList[i]
    table.insert(scrollData, ZO_ScrollList_CreateDataEntry(1, data))
  end    
end


function UI_MailList:SortScrollList()
  local scrollData = ZO_ScrollList_GetDataList(self.list)
  table.sort(scrollData, self.sortFunction)
end





function HotepMRP.OnMouseEnter(rowControl)
  if (rowControl.data.showingType == "SAVED") then
    HotepMRP.UI_SavedList:Row_OnMouseEnter(rowControl)
  else
    HotepMRP.UI_SentList:Row_OnMouseEnter(rowControl)
  end
end

function HotepMRP.OnMouseExit(rowControl)
  if (rowControl.data.showingType == "SAVED") then
    HotepMRP.UI_SavedList:Row_OnMouseExit(rowControl)
  else
    HotepMRP.UI_SentList:Row_OnMouseExit(rowControl)
  end
end


function HotepMRP.MailClicked(rowControl, button, upInside)
  local mail = rowControl.data.mail
  
  if (HotepMRP.selected) then
    local rowcolor = ZO_ColorDef:New(MailR.DEFAULT_SAVE_MAIL_COLOR_STRING:gsub("^|c", ""))
    if (HotepMRP.selected.showingType == "SENT") then
      rowcolor = ZO_ColorDef:New(MailR.DEFAULT_SENT_MAIL_COLOR_STRING:gsub("^|c", ""))
    end
    
    if (HotepMRP.selected.mailid == rowControl.data.mailid) then
      HotepMRP.selected = false
      HotepMRP.UI_SavedList:RefreshData()
      HotepMRP.UI_SentList:RefreshData()
      HotepMRP.UI_SavedList:RefreshVisible()
      HotepMRP.UI_SentList:RefreshVisible()
      HOTEPMRP_UI_main_Mail:SetHidden(true)
      return
    end
  end
  
  
  HotepMRP.selected = rowControl.data
  
  HotepMRP.UI_SavedList:RefreshData()
  HotepMRP.UI_SentList:RefreshData()
  HotepMRP.UI_SavedList:RefreshVisible()
  HotepMRP.UI_SentList:RefreshVisible()
  
  HotepMRP.ShowMail(mail)
  HOTEPMRP_UI_main_Mail:SetHidden(false)
end


function HotepMRP.ShowMail(mail)
  
  local body = mail.body .. "\n\n"
  
  local flag = false
  
  if (mail.postage and (mail.postage > 0)) then
    body = body .. zo_strformat("Postage: <<1>>g   ", mail.postage)
    flag = true
  end
  
  if (mail.gold and (mail.gold > 0)) then
    if (mail.cod) then
      body = body .. zo_strformat("COD: <<1>>g", mail.gold)
    else
      body = body .. zo_strformat("Gold Attached: <<1>>g", mail.gold)
    end
    flag = true
  end
  
  
  local attach = {}
  
  for _,a in pairs(mail.attachments) do
    if (a.link) then
      table.insert(attach, a)
    end
  end
  
  if (#attach > 0) then
    local s = ""
    if (#attach > 1) then
      s = "s"
    end
    
    if (flag) then
      body = body .. "\n\n"
    end
    
    body = body .. zo_strformat("<<1>> Attachment<<2>>:\n", #attach, s)
  end
  
  
  HOTEPMRP_Body:SetHeight(1000)
  HOTEPMRP_Body:SetText(body)
  HOTEPMRP_Body:SetHeight(HOTEPMRP_Body:GetTextHeight() + 10)
  
  local labels = {
    HOTEPMRP_Attach1,
    HOTEPMRP_Attach2,
    HOTEPMRP_Attach3,
    HOTEPMRP_Attach4,
    HOTEPMRP_Attach5,
    HOTEPMRP_Attach6,
  }
  
  for i = 1,6 do
    local control = labels[i]
    control:SetHidden(true)
  end
  
  for i,a in pairs(attach) do
    local text = zo_strformat("<<1>>x |t48:48:<<2>>|t [<<3>>]", a.stack, a.icon, a.link)
    local control = labels[i]
    control:SetText(text)
    control.ITEMLINK = a.link
    control:SetHidden(false)
  end
  
end



function HotepMRP.ToggleUIMain()
  HotepMRP.SortMail()
  SCENE_MANAGER:ToggleTopLevel(HOTEPMRP_UI_main)
  HotepMRP.UI_SavedList:RefreshData()
  HotepMRP.UI_SentList:RefreshData()
  HotepMRP.UI_SavedList:RefreshVisible()
  HotepMRP.UI_SentList:RefreshVisible()
end



function HotepMRP.InitUIWindows()
  HotepMRP.UI_SavedList = UI_MailList:New(HOTEPMRP_UI_main_Saved, "SAVED")
  HotepMRP.UI_SentList = UI_MailList:New(HOTEPMRP_UI_main_Sent, "SENT")
  
  SCENE_MANAGER:RegisterTopLevel(HOTEPMRP_UI_main, false)
  HOTEPMRP_UI_main:SetDrawTier(2)
end



function HotepMRP.GetList(showingType)
  
  local list;
  
  if (showingType == "SAVED") then
    list = HotepMRP.saved
  else
    list = HotepMRP.sent
  end
  
  local dataItems = {}
  
  for id,mail in pairs(list) do
    
    local data = {
      showingType = showingType,
      mailid = id,
      recipient = mail.recipient,
      subject = mail.subject,
      timesent = mail.timeSent,
      sent = ZO_FormatDurationAgo(GetDiffBetweenTimeStamps(GetTimeStamp(), mail.timeSent)),
      mail = mail,
    }
    
    table.insert(dataItems, data)
  end
  
  
  return dataItems
end



function HotepMRP.SortMail()
  
  HotepMRP.sent = {}
  HotepMRP.saved = {}
  
  for id,mail in pairs(MailR.SavedMail.sent_messages) do
    if (mail.isSentMail) then
      HotepMRP.sent[id] = mail
    else
      HotepMRP.saved[id] = mail
    end
  end
end




function HotepMRP:Initialize()
  
  ZO_CreateStringId("SI_BINDING_NAME_HOTEPMRP_Show", "View Saved and Sent Mail")
  
  HotepMRP.SortMail()
  
  HotepMRP.InitUIWindows()
end


function HotepMRP.OnAddOnLoaded(event, addonName)
  if (addonName == HotepMRP.name) then
    EVENT_MANAGER:UnregisterForEvent(HotepMRP.name, EVENT_ADD_ON_LOADED)
    HotepMRP:Initialize()
  end
end


EVENT_MANAGER:RegisterForEvent(HotepMRP.name, EVENT_ADD_ON_LOADED, HotepMRP.OnAddOnLoaded)

