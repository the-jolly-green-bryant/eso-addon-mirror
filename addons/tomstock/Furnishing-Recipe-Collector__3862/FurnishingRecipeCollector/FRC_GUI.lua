FurnishingRecipeCollector = FurnishingRecipeCollector or {}
local FRC = FurnishingRecipeCollector
local LCK = LibCharacterKnowledge

local tos = tostring
FRC.isGuiLoading = true
FRC.sortOptions =
  {
    ["Location"] = {
      "locationSort",
      {
        ["locationSort"]=
          {
            tiebreaker = "rResultName",
            tieBreakerSortOrder=ZO_SORT_ORDER_UP
          },
        ["rResultName"]=
          {
          }
      }
    },
    ["Item"] = {
      "rResultName",
      {
        ["rResultName"]=
          {
          }
      }
    },
    ["Knowledge"] = {
      "kKnown",
      {
        ["kKnown"]=
          {
            tiebreaker = "locationSort",
            tieBreakerSortOrder=ZO_SORT_ORDER_UP
          },
        ["locationSort"]=
        {
          tiebreaker = "rResultName",
          tieBreakerSortOrder=ZO_SORT_ORDER_UP
        },
        ["rResultName"]=
        {
        }
      }
    },
    ["Price"] = {
      "ttcPrice",
      {
        ["ttcPrice"]=
          {
            tiebreaker = "rResultName",
            tieBreakerSortOrder=ZO_SORT_ORDER_UP,
            isNumeric = true
          },
        ["rResultName"]=
        {
        }
      }
    }
  }

--[[
  Global Window Events
]]
function FRC.GuiShowTooltip(control, tooltiptext, reAnchor)
  InitializeTooltip(InformationTooltip, control, BOTTOM, 0, 0, 0)
  InformationTooltip:SetHidden(false)
  InformationTooltip:ClearLines()
  InformationTooltip:AddLine(tooltiptext)

  if reAnchor then
    InformationTooltip:ClearAnchors()
    InformationTooltip:SetAnchor(TOPRIGHT, control, TOPLEFT, -10, 0)
  end
end
function FRC.GuiHideTooltip(control)
  InformationTooltip:ClearLines()
  InformationTooltip:SetHidden(true)
end
function FRC.GuiOnResizeStop()
  FRC.GuiSaveFrameInfo()
  if FRC.isGuiLoading == true then
    return
  end
  FRC.UpdateLineVisibility()
  FRC.UpdateInventoryScroll()
end
function FRC.GuiOnSliderUpdate(slider, value)
  if nil == slider or FRC.isGuiLoading == true then
    return
  end
  if not value or (slider and slider.locked) then
    return
  end
  local relativeValue = math.floor(FRC_GUI_ListHolder.dataOffset - value)
  FRC.GuiOnScroll(slider, relativeValue)
end
function FRC.GuiOnScroll(control, delta)
  if nil == control or FRC.isGuiLoading == true then
    return
  end
  if not delta then
    return
  end
  if delta == 0 then
    return
  end

  local slider = FRC_GUI_ListHolder_Slider
  --  slider.locked = true
  -- negative delta means scrolling down

  local value = (FRC_GUI_ListHolder.dataOffset - delta)
  local total = #FRC_GUI_ListHolder.dataLines -FRC_GUI_ListHolder.maxLines

  if value < 0 then
    value = 0
  end
  if value > total then
    value = total
  end
  if total < 0 then
    value = 0
    total = #FRC_GUI_ListHolder.dataLines
  end
  FRC_GUI_ListHolder.dataOffset = value

  slider:SetValue(FRC_GUI_ListHolder.dataOffset)

  FurnishingRecipeCollector.UpdateInventoryScroll()

  --This is used to troubleshoot scrolling issues
  --local min, max=slider:GetMinMax()
  --FRC.logger:Debug("Scrolling to: " .. value.." of "..total.."; DataOffset="..tos(FRC_GUI_ListHolder.dataOffset).."; Delta="..tos(delta).."; Data Lines="..tos(#FRC_GUI_ListHolder.dataLines).."; Max Lines="..tos(FRC_GUI_ListHolder.maxLines).."; MinMax"..min.."/"..max.."; Step: "..slider:GetValueStep())

  FurnishingRecipeCollector.GuiLineOnMouseEnter(moc())
end
function FRC.GuiLineOnMouseEnter(lineControlChild)

  local lineControl = lineControlChild:GetParent()

  if nil == lineControl or FRC.isGuiLoading == true then
    return
  end

  if (lineControl.rFolioItemLink or "") == "" and (lineControl.rGrabBagItemLink or "") == "" and (lineControl.rRecipeItemLink or "") == "" then
    return
  end


  if moc():GetName() == lineControl.lblLocation:GetName() then
    if lineControl.rFolioItemLink ~= nil then
      InitializeTooltip(ItemTooltip, lineControl, LEFT, 0, 0, 0)
      ItemTooltip:SetLink(lineControl.rFolioItemLink)
    elseif lineControl.rGrabBagItemLink ~= nil then
      InitializeTooltip(ItemTooltip, lineControl, LEFT, 0, 0, 0)
      ItemTooltip:SetLink(lineControl.rGrabBagItemLink)
    end
  elseif lineControl.rRecipeItemLink ~= nil then
    InitializeTooltip(ItemTooltip, lineControl, LEFT, 0, 0, 0)
    ItemTooltip:SetLink(lineControl.rRecipeItemLink)
  end
end
function FRC.GuiLineOnMouseExit(lineControlChild)
  if nil == lineControlChild or FRC.isGuiLoading == true then
    return
  end
  ClearTooltip(ItemTooltip)
end
function FRC.GuiSaveFrameInfo(calledFrom)
  --functions hooked from GUI can't be local
  local gui_s = FRC.savedVariables["gui"]

  gui_s.lastX = FRC_GUI:GetLeft()
  gui_s.lastY = FRC_GUI:GetTop()
  gui_s.width = FRC_GUI:GetWidth()
  gui_s.height = FRC_GUI:GetHeight()

  if FRC.isGuiLoading == false then
    FRC.UpdateInventoryScroll()
  end
end
function FRC.GUIButtonRefreshOnMouseUp(calledFrom,mouseButton)
  FRC.UpdateGui()
end

function FRC.GuiOnSort(sortKey)
  if FRC.savedVariables.gui.sort == sortKey then
    if FRC.savedVariables.gui.sortDirection == ZO_SORT_ORDER_UP then
      FRC.savedVariables.gui.sortDirection = ZO_SORT_ORDER_DOWN
    else
      FRC.savedVariables.gui.sortDirection = ZO_SORT_ORDER_UP
    end
  else
    FRC.savedVariables.gui.sortDirection = ZO_SORT_ORDER_UP
  end
  FRC.savedVariables.gui.sort = sortKey
  FRC.UpdateGui()
end

--[[
    Global functions used by other addon callbacks or XML
]]
function FRC.SortDataLines(data,orderIndex,direction)
  table.sort(data, function(item1, item2) return ZO_TableOrderingFunction(item1, item2, FRC.sortOptions[orderIndex][1],FRC.sortOptions[orderIndex][2],direction) end)
end
function FRC.FRC_Toggle()
  --functions hooked from other addons can't be local
  SCENE_MANAGER:ToggleTopLevel(FRC_GUI)
end
function FRC.FRC_Show()
  --functions hooked from other addons can't be local
  SCENE_MANAGER:ShowTopLevel(FRC_GUI)
end
function FRC.CalculateMaxLines()
  if not FRC_GUI_Header then
    return
  end
  FRC_GUI_ListHolder:SetHeight(FRC_GUI:GetHeight() - FRC_GUI_Header:GetHeight())
  FRC_GUI_ListHolder.maxLines = math.floor((FRC_GUI_ListHolder:GetHeight()) / FRC_GUI_ListHolder.lines[1]:GetHeight())
  return FRC_GUI_ListHolder.maxLines
end
function FRC.UpdateInventoryScroll()
  FRC_GUI_ListHolder.dataOffset = FRC_GUI_ListHolder.dataOffset or 0
  FRC_GUI_ListHolder.dataOffset = math.max(FRC_GUI_ListHolder.dataOffset, 0)

  FRC.CalculateMaxLines()

  local total = #FRC_GUI_ListHolder.dataLines - FRC_GUI_ListHolder.maxLines
  if total > 0 then
    FRC_GUI_ListHolder_Slider:SetMinMax(0, total)
  else
    FRC_GUI_ListHolder_Slider:SetMinMax(0, #FRC_GUI_ListHolder.dataLines)
  end
  FRC.UpdateLineVisibility()
end
function FRC.UpdateLineVisibility()
  local function fillLine(curLine, curData, lineIndex)
    if nil == curLine then
      return
    end

    local dataLines = FRC_GUI_ListHolder.dataLines
    local maxLines = FRC_GUI_ListHolder.maxLines

    local hidden = lineIndex > #dataLines or lineIndex > maxLines
    curLine:SetHidden(hidden) --this may not be working
    if curData == nil or hidden then
      curLine.rItemLinkId = 0
      curLine.rItemName = ""
      curLine.rItemType = 0
      curLine.rSpecialType = 0
      curLine.rFolioItemLinkId = 0
      curLine.rFolioItemLink = ""
      curLine.rRecipeItemLinkId = 0
      curLine.rRecipeItemLink = ""
      curLine.rRecipeItemName = ""
      curLine.rGrabBagItemLinkId = 0
      curLine.rGrabBagItemLink = ""
      curLine.rLocation = ""
      curLine.rResultLinkId = 0
      curLine.rResultLink = ""
      curLine.rResultName = ""
      curLine.kKnown = ""
      curLine.ttcPrice = ""
      curLine.lblRecipeName:SetText("")
      curLine.lblLocation:SetText("")
      curLine.lblKnowledge:SetText("")
      curLine.lblPrice:SetText("")
    else
      curLine.rItemLinkId = curData.rItemLinkId
      curLine.rItemName = curData.rItemName
      curLine.rItemType = curData.rItemType
      curLine.rSpecialType = curData.rSpecialType
      curLine.rFolioItemLinkId = curData.rFolioItemLinkId
      curLine.rFolioItemLink = curData.rFolioItemLink
      curLine.rRecipeItemLinkId = curData.rRecipeItemLinkId
      curLine.rRecipeItemLink = curData.rRecipeItemLink
      curLine.rRecipeItemName = curData.rRecipeItemName
      curLine.rGrabBagItemLinkId = curData.rGrabBagItemLinkId
      curLine.rGrabBagItemLink = curData.rGrabBagItemLink
      curLine.rLocation = curData.rLocation
      curLine.rResultLinkId = curData.rResultLinkId
      curLine.rResultLink = curData.rResultLink
      curLine.rResultName = curData.rResultName
      curLine.kKnown = curData.kKnown
      curLine.ttcPrice = curData.ttcPrice
      curLine.lblRecipeName:SetText(curData.rRecipeItemLink)
      curLine.lblLocation:SetText(curData.rFolioItemLink or curData.rGrabBagItemLink or curData.rLocation)
      curLine.lblKnowledge:SetText(curData.kKnown)
      curLine.lblPrice:SetText(zo_strformat("<<1>>", ZO_LocalizeDecimalNumber(curData.ttcPrice or 0)))
    end
  end

  FRC.CalculateMaxLines()

  local function redrawList()
    local maxLines = FRC_GUI_ListHolder.maxLines
    local dataLines = FRC_GUI_ListHolder.dataLines

    local offset = FRC_GUI_ListHolder_Slider:GetValue()
    if offset > #dataLines then
      offset = 0
    end
    FRC_GUI_ListHolder_Slider:SetValue(offset)

    local curLine, curData

    for i = 1, FRC_GUI_ListHolder:GetNumChildren() do
      curLine = FRC_GUI_ListHolder.lines[i]
      curData = FRC_GUI_ListHolder.dataLines[offset + i]
      fillLine(curLine, curData, i)
    end
    local total = #FRC_GUI_ListHolder.dataLines - FRC_GUI_ListHolder.maxLines
    if total > 0 then
      FRC_GUI_ListHolder_Slider:SetMinMax(0, total)
    else
      FRC_GUI_ListHolder_Slider:SetMinMax(0, #FRC_GUI_ListHolder.dataLines)
    end
  end

  redrawList()
end
function FRC.RestorePosition()
  local control = FRC_GUI
  local gui_s = FRC.savedVariables["gui"]
  local left = gui_s.lastX
  local top = gui_s.lastY

  control:SetHeight(gui_s.height)
  control:SetWidth(gui_s.width)

  control:ClearAnchors()
  control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)

  zo_callLater(function()
    FRC.UpdateInventoryScroll()
  end, 100)
end
function FRC.UpdateSortIcons()
  --EsoUI/Art/Miscellaneous/list_sortHeader_icon_sortUp.dds
  --EsoUI/Art/Miscellaneous/list_sortHeader_icon_sortDown.dds
  --EsoUI/Art/Miscellaneous/list_sortHeader_icon_over.dds
  --EsoUI/Art/Miscellaneous/list_sortheader_icon_neutral.dds
  FRC_GUI_ListHolder.SortLocation.icon:SetNormalTexture("EsoUI/Art/Miscellaneous/list_sortheader_icon_neutral.dds")
  FRC_GUI_ListHolder.SortLocation.icon:SetMouseOverTexture("EsoUI/Art/Miscellaneous/list_sortHeader_icon_over.dds")
  FRC_GUI_ListHolder.SortItem.icon:SetNormalTexture("EsoUI/Art/Miscellaneous/list_sortheader_icon_neutral.dds")
  FRC_GUI_ListHolder.SortItem.icon:SetMouseOverTexture("EsoUI/Art/Miscellaneous/list_sortHeader_icon_over.dds")
  FRC_GUI_ListHolder.SortKnowledge.icon:SetNormalTexture("EsoUI/Art/Miscellaneous/list_sortheader_icon_neutral.dds")
  FRC_GUI_ListHolder.SortKnowledge.icon:SetMouseOverTexture("EsoUI/Art/Miscellaneous/list_sortHeader_icon_over.dds")
  FRC_GUI_ListHolder.SortPrice.icon:SetNormalTexture("EsoUI/Art/Miscellaneous/list_sortheader_icon_neutral.dds")
  FRC_GUI_ListHolder.SortPrice.icon:SetMouseOverTexture("EsoUI/Art/Miscellaneous/list_sortHeader_icon_over.dds")

  if FRC.savedVariables.gui.sort == "Location" then
    if FRC.savedVariables.gui.sortDirection == ZO_SORT_ORDER_UP then
      FRC_GUI_ListHolder.SortLocation.icon:SetNormalTexture("EsoUI/Art/Miscellaneous/list_sortHeader_icon_sortDown.dds")
    else
      FRC_GUI_ListHolder.SortLocation.icon:SetNormalTexture("EsoUI/Art/Miscellaneous/list_sortHeader_icon_sortUp.dds")
    end
  end
  if FRC.savedVariables.gui.sort == "Item" then
    if FRC.savedVariables.gui.sortDirection == ZO_SORT_ORDER_UP then
      FRC_GUI_ListHolder.SortItem.icon:SetNormalTexture("EsoUI/Art/Miscellaneous/list_sortHeader_icon_sortDown.dds")
    else
      FRC_GUI_ListHolder.SortItem.icon:SetNormalTexture("EsoUI/Art/Miscellaneous/list_sortHeader_icon_sortUp.dds")
    end
  end
  if FRC.savedVariables.gui.sort == "Knowledge" then
    if FRC.savedVariables.gui.sortDirection == ZO_SORT_ORDER_UP then
      FRC_GUI_ListHolder.SortKnowledge.icon:SetNormalTexture("EsoUI/Art/Miscellaneous/list_sortHeader_icon_sortDown.dds")
    else
      FRC_GUI_ListHolder.SortKnowledge.icon:SetNormalTexture("EsoUI/Art/Miscellaneous/list_sortHeader_icon_sortUp.dds")
    end
  end
  if FRC.savedVariables.gui.sort == "Price" then
    if FRC.savedVariables.gui.sortDirection == ZO_SORT_ORDER_UP then
      FRC_GUI_ListHolder.SortPrice.icon:SetNormalTexture("EsoUI/Art/Miscellaneous/list_sortHeader_icon_sortDown.dds")
    else
      FRC_GUI_ListHolder.SortPrice.icon:SetNormalTexture("EsoUI/Art/Miscellaneous/list_sortHeader_icon_sortUp.dds")
    end
  end
end
function FRC.UpdateScrollDataLinesData()
  FRC_GUI_ListHolder.SortPrice:SetText(FRC.savedVariables.price.." Price")

  local dataLines = {}

  local function fillDataLine(recipe)
    local vItemLinkId, vItemName, vItemFunctionalQuality, vItemType, vSpecialType, vFolioItemLinkId, vFolioItemLink, vFolioItemName, vRecipeItemLinkId, vRecipeItemLink, vRecipeItemName, vGrabBagItemLinkId, vGrabBagItemLink, vGrabBagItemName, vLocation, vResultLinkId, vResultLink, vResultName, vRecipePrice, vRecipeListing = FRC.GetRecipeDetail(recipe)
    local vCharacterStringLong, vCharacterStringShort, vCharTrackedCount, vCharKnownCount = FRC.GetRecipeKnowledge(vRecipeItemLinkId)
    local tempDataLine = {}
    if not ((FRC.savedVariables.gui.filterQuality == "All") or
      (FRC.savedVariables.gui.filterQuality == "Normal" and vItemFunctionalQuality == (ITEM_FUNCTIONAL_QUALITY_NORMAL or ITEM_FUNCTIONAL_QUALITY_TRASH)) or
      (FRC.savedVariables.gui.filterQuality == "Magic" and vItemFunctionalQuality == ITEM_FUNCTIONAL_QUALITY_MAGIC) or
      (FRC.savedVariables.gui.filterQuality == "Superior" and vItemFunctionalQuality == ITEM_FUNCTIONAL_QUALITY_ARCANE) or
      (FRC.savedVariables.gui.filterQuality == "Epic" and vItemFunctionalQuality == ITEM_FUNCTIONAL_QUALITY_ARTIFACT) or
      (FRC.savedVariables.gui.filterQuality == "Legendary" and vItemFunctionalQuality == ITEM_FUNCTIONAL_QUALITY_LEGENDARY)) then
      return nil
    end
    if not ((FRC.savedVariables.gui.filterKnowledge == "All") or
      LCK.GetItemKnowledgeForCharacter( vRecipeItemLink, nil, FRC.savedVariables.gui.filterKnowledge )==LCK.KNOWLEDGE_UNKNOWN) then
      return nil
    end
    tempDataLine.rItemLinkId = vItemLinkId
    tempDataLine.rItemName = vItemName
    tempDataLine.rItemFunctionalQuality = vItemFunctionalQuality
    tempDataLine.rItemType = vItemType
    tempDataLine.rSpecialType = vSpecialType
    tempDataLine.rFolioItemLinkId = vFolioItemLinkId
    tempDataLine.rFolioItemLink = vFolioItemLink
    tempDataLine.rFolioItemName = vFolioItemName or ""
    tempDataLine.rRecipeItemLinkId = vRecipeItemLinkId
    tempDataLine.rRecipeItemLink = vRecipeItemLink
    tempDataLine.rRecipeItemName = vRecipeItemName
    tempDataLine.rGrabBagItemLinkId = vGrabBagItemLinkId
    tempDataLine.rGrabBagItemLink = vGrabBagItemLink
    tempDataLine.rGrabBagItemName = vGrabBagItemName or ""
    tempDataLine.rLocation = vLocation
    tempDataLine.rResultLinkId = vResultLinkId
    tempDataLine.rResultLink = vResultLink
    tempDataLine.rResultName = vResultName
    tempDataLine.kKnown = vCharacterStringShort
    tempDataLine.ttcPrice = vRecipePrice or 0
    return tempDataLine
  end

  for i_key,i_value in pairs(FRC.Data.FurnisherDocuments) do
    for j_key,j_value in pairs(FRC.Data.FurnisherDocuments[i_key]) do
      if FRC.savedVariables.gui.filterLocation ~= "All" and FRC.savedVariables.gui.filterLocation ~= i_key then
        break
      end
      local tempDataLine = fillDataLine(FRC.Data.FurnisherDocuments[i_key][j_key])
      if tempDataLine ~= nil then
        table.insert(dataLines, tempDataLine)
      end
    end
  end
  for i_key,i_value in pairs(FRC.Data.Folios) do
    for j_key,j_value in pairs(FRC.Data.Folios[i_key]) do
      if FRC.savedVariables.gui.filterLocation ~= "All" and FRC.savedVariables.gui.filterLocation ~= i_key then
        break
      end
      local tempDataLine = fillDataLine(FRC.Data.Folios[i_key][j_key])
      if tempDataLine ~= nil then
        table.insert(dataLines, tempDataLine)
      end
    end
  end
  for i_key,i_value in pairs(FRC.Data.Misc) do
    if FRC.savedVariables.gui.filterLocation ~= "All" and FRC.savedVariables.gui.filterLocation ~= "Misc" then
      break
    end
    local tempDataLine = fillDataLine(i_key)
    if tempDataLine ~= nil then
      table.insert(dataLines, tempDataLine)
    end
  end

  for i,line in pairs(dataLines) do
    if line.rFolioItemLinkId ~= nil then
      line.locationSort = "1_"..line.rFolioItemName
    elseif line.rGrabBagItemLinkId ~= nil then
      line.locationSort = "2_"..line.rGrabBagItemName
    else line.locationSort = "3_"..line.rLocation
    end
  end

  local headerControl = _G["FRC_GUI_Header_HeaderLabel"]
  headerControl:SetText("Furnishing Recipe Collector - "..#dataLines.." Recipes")

  FRC.SortDataLines(dataLines,FRC.savedVariables.gui.sort, FRC.savedVariables.gui.sortDirection)

  FRC_GUI_ListHolder.dataLines = dataLines
end
function FRC.LoadingStart()
  if FRC.logger ~= nil then FRC.logger:Verbose("Loading Start") end
  FRC.isGuiLoading = true
  FRC_GUI_ListHolder:SetHidden(true)
  FRC_GUI_Wait:SetHidden(false)
end

function FRC.LoadingStop()
  if FRC.logger ~= nil then FRC.logger:Verbose("Loading Stop") end
  FRC.isGuiLoading = false
  FRC_GUI_ListHolder:SetHidden(false)
  FRC_GUI_Wait:SetHidden(true)
end
local function CreatePostXMLGui()
  local function CreateInventoryScroll()
    if FRC.logger ~= nil then FRC.logger:Debug("CreateInventoryScroll") end
    local function createLine(i, predecessor)
      predecessor = predecessor or FRC_GUI_ListHolder

      --@type Control
      local line = WINDOW_MANAGER:CreateControlFromVirtual("FRC_GUI_ItemListRow_" .. i, FRC_GUI_ListHolder, "FRC_GUI_ItemListRow")

      line.lblRecipeName = line:GetNamedChild("_RecipeName")
      line.lblLocation = line:GetNamedChild("_Location")
      line.lblKnowledge = line:GetNamedChild("_Knowledge")
      line.lblPrice = line:GetNamedChild("_Price")

      line:SetHidden(false)
      line:SetMouseEnabled(true)

      if i == 1 then
        line:SetAnchor(TOPLEFT, FRC_GUI_ListHolder, TOPLEFT, 0, 4)
        line:SetAnchor(TOPRIGHT, FRC_GUI_ListHolder, TOPRIGHT, -30, 0)
      else
        line:SetAnchor(TOPLEFT, predecessor, BOTTOMLEFT, 0, 0)
        line:SetAnchor(TOPRIGHT, predecessor, BOTTOMRIGHT, 0, 0)
      end
      return line
    end

    FRC_GUI_ListHolder.dataOffset = 0
    FRC_GUI_ListHolder.maxLines = 60
    FRC_GUI_ListHolder.dataLines = {}
    FRC_GUI_ListHolder.lines = {}
    FRC_GUI_ListHolder.SortLocation = FRC_GUI_SortBar_SortLocation:GetNamedChild("_Name")
    FRC_GUI_ListHolder.SortLocation.icon = FRC_GUI_SortBar_SortLocation:GetNamedChild("_Button")
    FRC_GUI_ListHolder.SortItem = FRC_GUI_SortBar_SortItem:GetNamedChild("_Name")
    FRC_GUI_ListHolder.SortItem.icon = FRC_GUI_SortBar_SortItem:GetNamedChild("_Button")
    FRC_GUI_ListHolder.SortKnowledge = FRC_GUI_SortBar_SortKnowledge:GetNamedChild("_Name")
    FRC_GUI_ListHolder.SortKnowledge.icon = FRC_GUI_SortBar_SortKnowledge:GetNamedChild("_Button")
    FRC_GUI_ListHolder.SortPrice = FRC_GUI_SortBar_SortPrice:GetNamedChild("_Name")
    FRC_GUI_ListHolder.SortPrice.icon = FRC_GUI_SortBar_SortPrice:GetNamedChild("_Button")

    local predecessor
    for i = 1, FRC_GUI_ListHolder.maxLines do
      FRC_GUI_ListHolder.lines[i] = createLine(i, predecessor)
      predecessor = FRC_GUI_ListHolder.lines[i]
    end

    -- setup slider
    local total = #FRC_GUI_ListHolder.dataLines - FRC_GUI_ListHolder.maxLines
    if total > 0 then
      FRC_GUI_ListHolder_Slider:SetMinMax(0, total)
    else
      FRC_GUI_ListHolder_Slider:SetMinMax(0, #FRC_GUI_ListHolder.dataLines)
    end

    return FRC_GUI_ListHolder.lines
  end

  local function CreateDropDown(dropDownType)
    if FRC.logger ~= nil then FRC.logger:Debug("CreateDropDown") end
    local filterControl = nil
    local data = {}
    local comboBox = nil
    local defValue = nil

    local function OnItemSelect(comboBox, itemName, item, selectionChanged, oldItem)
      local ctrlName = comboBox:GetUniqueName()

      if ctrlName == "FRC_GUI_FilterFolio" then
        if FRC.logger ~= nil then FRC.logger:Verbose("Filter Folio: " .. item.key) end
        FRC.savedVariables.gui.filterLocation = item.key
      elseif ctrlName == "FRC_GUI_FilterQuality" then
        if FRC.logger ~= nil then FRC.logger:Verbose("Filter Quality: " .. item.key) end
        FRC.savedVariables.gui.filterQuality = item.key
      elseif ctrlName == "FRC_GUI_FilterKnowledge" then
        if FRC.logger ~= nil then FRC.logger:Verbose("Filter Knowledge: " .. item.key) end
        FRC.savedVariables.gui.filterKnowledge = item.key
      end
      if FRC.isGuiLoading == false then
        FRC.UpdateGui()
      end

    end

    if dropDownType == "Folio" then
      filterControl = _G["FRC_GUI_FilterFolio"]
      defValue = FRC.savedVariables.gui.filterLocation

      table.insert(data,{callback=OnItemSelect,enabled=true,name="Location: No Filter",itemLinkId="",itemName="",categoryId="0NoSelection",key="All"})

      --Grabbed structure of combobox item from zo_combobox_base.lua
      for key,value in pairs(FRC.Data.Folios) do
        local vItemLinkId, vItemName, vItemFunctionalQuality, vItemType, vSpecialType, vFolioItemLinkId, vFolioItemLink, vFolioItemName, vRecipeItemLinkId, vRecipeItemLink, vRecipeItemName, vGrabBagItemLinkId, vGrabBagItemLink, vGrabBagItemName, vLocation, vResultLinkId, vResultLink, vResultName, vRecipePrice, vRecipeListing = FRC.GetRecipeDetail(key)
        table.insert(data,{callback=OnItemSelect,enabled=true,name=vFolioItemLink,itemLinkId=vItemLinkId,itemName=vItemName,categoryId="1Folio",key=vFolioItemLinkId})
      end
      for key,value in pairs(FRC.Data.FurnisherDocuments) do
        local vItemLinkId, vItemName, vItemFunctionalQuality, vItemType, vSpecialType, vFolioItemLinkId, vFolioItemLink, vFolioItemName, vRecipeItemLinkId, vRecipeItemLink, vRecipeItemName, vGrabBagItemLinkId, vGrabBagItemLink, vGrabBagItemName, vLocation, vResultLinkId, vResultLink, vResultName, vRecipePrice, vRecipeListing = FRC.GetRecipeDetail(key)
        table.insert(data,{callback=OnItemSelect,enabled=true,name=vGrabBagItemLink,itemLinkId=vItemLinkId,itemName=vItemName,categoryId="2FurnisherDocuments",key=vGrabBagItemLinkId})
      end
      table.insert(data,{callback=OnItemSelect,name="Misc",categoryId="3Misc",key="Misc"})

      table.sort(data, function(item1, item2) return ZO_TableOrderingFunction(item1, item2, "categoryId",{["categoryId"]={tiebreaker = "itemName",tieBreakerSortOrder=ZO_SORT_ORDER_UP},["itemName"]={caseInsensitive=true}},ZO_SORT_ORDER_UP) end)
    elseif dropDownType == "Quality" then
      filterControl = _G["FRC_GUI_FilterQuality"]
      defValue = FRC.savedVariables.gui.filterQuality

      table.insert(data,{callback=OnItemSelect,enabled=true,name="Quality: No Filter",sort=0,key="All"})
      table.insert(data,{callback=OnItemSelect,enabled=true,name=string.format("|c%06X%s|r", FRC.savedVariables.colorQualityNormal,"Normal"),sort=1,key="Normal"})
      table.insert(data,{callback=OnItemSelect,enabled=true,name=string.format("|c%06X%s|r", FRC.savedVariables.colorQualityMagic,"Magic"),sort=2,key="Magic"})
      table.insert(data,{callback=OnItemSelect,enabled=true,name=string.format("|c%06X%s|r", FRC.savedVariables.colorQualitySuperior,"Superior"),sort=3,key="Superior"})
      table.insert(data,{callback=OnItemSelect,enabled=true,name=string.format("|c%06X%s|r", FRC.savedVariables.colorQualityEpic,"Epic"),sort=4,key="Epic"})
      table.insert(data,{callback=OnItemSelect,enabled=true,name=string.format("|c%06X%s|r", FRC.savedVariables.colorQualityLegendary,"Legendary"),sort=5,key="Legendary"})

      table.sort(data, function(item1, item2) return ZO_TableOrderingFunction(item1, item2, "sort",{["sort"]={}},ZO_SORT_ORDER_UP) end)
    elseif dropDownType == "Knowledge" then
      filterControl = _G["FRC_GUI_FilterKnowledge"]
      defValue = FRC.savedVariables.gui.filterKnowledge
      table.insert(data,{callback=OnItemSelect,enabled=true,name="Unknown Knowledge: No Filter",sort=0,key="All"})
      if LCK ~= nil then
        local chrList=LCK.GetCharacterList( nil )

        for i, chr in ipairs(chrList) do

          table.insert(data,{callback=OnItemSelect,enabled=true,name=chr["name"],sort=5,key=chr["id"]})
        end
      end
      table.sort(data, function(item1, item2) return ZO_TableOrderingFunction(item1, item2, "sort",{["sort"]={}},ZO_SORT_ORDER_UP) end)

    else return
    end

    filterControl.comboBox = filterControl.comboBox or ZO_ComboBox_ObjectFromContainer(filterControl)
    comboBox = filterControl.comboBox

    local scrollHelper = AddCustomScrollableComboBoxDropdownMenu(comboBox, filterControl, {})

    comboBox:ClearItems()

		comboBox:AddItems(data)

    local defIndex = 1
    for i in pairs(data) do
      if data[i].key == defValue then
        defIndex = i
        break
      end
    end

    comboBox:SelectItemByIndex(defIndex,false)
  end

  CreateInventoryScroll()
  CreateDropDown("Folio")
  CreateDropDown("Quality")
  CreateDropDown("Knowledge")

  local slider = FRC_GUI_ListHolder_Slider
  slider:SetMinMax(1, #FRC_GUI_ListHolder.dataLines)
end

function FRC.UpdateGui()
  FRC.LoadingStart()
  FRC.UpdateScrollDataLinesData()
  zo_callLater(function()
    FRC.UpdateInventoryScroll()
    FRC.UpdateSortIcons()
    FRC.LoadingStop()
  end, 100)
end

function FRC.InitGui()
  local control = FRC_GUI

  FRC.RestorePosition()

  CreatePostXMLGui()

  local slider = FRC_GUI_ListHolder_Slider
  slider:SetMinMax(1, #FRC_GUI_ListHolder.dataLines)

  FRC.UpdateGui()

  SCENE_MANAGER:RegisterTopLevel(control, false)
end
