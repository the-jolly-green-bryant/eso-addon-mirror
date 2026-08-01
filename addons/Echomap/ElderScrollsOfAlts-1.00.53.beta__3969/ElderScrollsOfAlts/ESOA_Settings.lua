--[[ Settings GUI ]]-- 
 
----------------------------------------
-- Functions to process Settings data --
----------------------------------------

------------------------------
-- UI Button
function ElderScrollsOfAlts:GetUIButtonShown()
   return (ElderScrollsOfAlts.savedVariables.uibutton.shown)
end

------------------------------
-- UI Button
function ElderScrollsOfAlts.SetUIButtonShown(value)
  ElderScrollsOfAlts.savedVariables.uibutton.shown = value
  ElderScrollsOfAlts.debugMsg("SetUIButtonShown: value=",tostring(value) )
  if not value then
    ElderScrollsOfAlts.HideUIButton()
  else
    ElderScrollsOfAlts.ShowUIButton()
  end  
end

------------------------------
-- View Dropdown
function ElderScrollsOfAlts:GetUIViewDropDownShown()
  return (ElderScrollsOfAlts.savedVariables.viewdropdown.shown)
end

------------------------------
-- View Dropdown
function ElderScrollsOfAlts.SetUIViewDropDownShown(value)
  ElderScrollsOfAlts.savedVariables.viewdropdown.shown = value
  ElderScrollsOfAlts.debugMsg("SetUIViewDropDownShown: value=", tostring(value) )
  --TODO update UI
end

------------------------------
-- Mouse Hightlight
function ElderScrollsOfAlts:GetUIViewMouseHighlightShown()
  return (ElderScrollsOfAlts.savedVariables.viewmousehighlight.shown)
end

------------------------------
--  Mouse Hightlight
function ElderScrollsOfAlts.SetUIViewMouseHighlightShown(value)
  ElderScrollsOfAlts.savedVariables.viewmousehighlight.shown = value
  ElderScrollsOfAlts.debugMsg("SetUIViewMouseHighlightShown: value=", tostring(value) )
  if(ESOA_GUI2_Body_ListHolder~=nil and ESOA_GUI2_Body_ListHolder.mouseHighlight~=nil) then
    ESOA_GUI2_Body_ListHolder.mouseHighlight:SetHidden(true)
  end
end

------------------------------
--Returns a list of character names
function ElderScrollsOfAlts:ListOfCharacterNames()
  local validChoices =  {}  
	table.insert(validChoices, "Select")
  if ElderScrollsOfAlts.altData.players ~= nil then
    for k, v in pairs(ElderScrollsOfAlts.altData.players) do
      if(k~=nil) then
        local displayName = k
        if(v~=nil and v.bio~=nil) then
            displayName = k .."("..tostring(v.bio.name)..")"
        end
        --debugMsg(ElderScrollsOfAlts.name .. " k " .. k)
        table.insert(validChoices, displayName ) --v.rawname)--v.bio.name )
      end
    end
  end
  return validChoices 
end

------------------------------
--SETTINGS For use by Settings dropdown
function ElderScrollsOfAlts:SelectCharacterName(choiceText)
  ElderScrollsOfAlts.savedVariables.selected.charactername = choiceText
end

------------------------------
--SETTINGS For use by Settings dropdown
function ElderScrollsOfAlts:DoDeleteSelectedCharacter()
  local charname = ElderScrollsOfAlts.savedVariables.selected.charactername
  if(charname~=nil)then
    ElderScrollsOfAlts.debugMsg("DoDeleteSelectedCharacter: Name=" .. tostring(charname) )
    --local displayName = k.."("..v.bio.name..")"
    local iStart, iEnd = string.find(charname, "%(" )
    local charKey = string.sub(charname,0,iStart-1) 
    ElderScrollsOfAlts.debugMsg("DoDeleteSelectedCharacter: charKey=" , tostring(charKey))
    if(ElderScrollsOfAlts.altData.players[charKey]~=nil)then
      ElderScrollsOfAlts.altData.players[charKey] = nil
      ElderScrollsOfAlts.outputMsg("ESOA deleted character: Name=" .. tostring(charname) )
    end
  end
end

---VIEWS

--Returns a list of view Indexes
function ElderScrollsOfAlts:SettingsListOfViews()
  local validChoices =  {}  
	table.insert(validChoices, "Select")
  local viewCnt = 0
  if(ElderScrollsOfAlts.savedVariables.gui==nil)then
    ElderScrollsOfAlts.outputMsg("InitializeGui wasn't called first")
    ElderScrollsOfAlts.InitializeGui()
  end  
  for viewIdx = 1, #ElderScrollsOfAlts.savedVariables.gui do
    local guiLine = ElderScrollsOfAlts.savedVariables.gui[viewIdx]
    local viewName = guiLine.name
    table.insert(validChoices, viewIdx)-- viewName )  
  end
  return validChoices 
end

------------------------------
--
function ElderScrollsOfAlts:SettingsListOfViewTemplateNames()
  local validChoices =  {}  
	table.insert(validChoices, "Select")
  for k_entry, guiTemplate in pairs(ElderScrollsOfAlts.view.guiTemplates) do
    local viewName = k_entry--guiTemplate.name
    table.insert(validChoices, viewName)
  end
  return validChoices 
end

--REMOVE
--function ElderScrollsOfAlts:SettingsSelectView(choiceText)
--  ElderScrollsOfAlts.savedVariables.selected.viewidx = choiceText
--end

------------------------------
--
function ElderScrollsOfAlts:RefreshSettingsDropdowns()
  local myFpsLabelControl = WINDOW_MANAGER:GetControlByName("ESOA_SETTINGS_DD_SelectView", "")
  if(myFpsLabelControl~=nil) then
    local vals = ElderScrollsOfAlts:SettingsListOfViews()
    myFpsLabelControl:UpdateChoices(vals )
  else
    ElderScrollsOfAlts.outputMsg("WARN: Dropdown not found, changes will not be reflected until /reloadui")
  end
end

------------------------------
-- view: Delete
function ElderScrollsOfAlts:DoDeleteSelectedView()
 local guiLine = ElderScrollsOfAlts.savedVariables.gui[ElderScrollsOfAlts.savedVariables.selected.viewidx]
  local viewText = ""
  if(guiLine~=nil)then
    --ElderScrollsOfAlts.outputMsg("Edit view found as <".. tostring(guiLine.name)..">" )
    ElderScrollsOfAlts.savedVariables.gui[ElderScrollsOfAlts.savedVariables.selected.viewidx] = nil
    ElderScrollsOfAlts.outputMsg("Deleted view " .. ElderScrollsOfAlts.savedVariables.selected.viewidx)
  end
  ElderScrollsOfAlts:RefreshSettingsDropdowns()
end

------------------------------
-- view: Select
function ElderScrollsOfAlts:DoTestSelectedView()
  local guiLine2B = ElderScrollsOfAlts.savedVariables.gui[ElderScrollsOfAlts.savedVariables.selected.viewidx]
  if(guiLine2B==nil)then
    ElderScrollsOfAlts.outputMsg("Failed test: Can't find data line")
    return
  end
  
  if(ElderScrollsOfAlts.view.SettingsViewName==nil or ElderScrollsOfAlts.view.SettingsViewName=="") then
    ElderScrollsOfAlts.outputMsg("Failed test: nil name")
  end
  
  local viewText = (ElderScrollsOfAlts.view.SettingsViewData)
  if(ElderScrollsOfAlts.view.SettingsViewData==nil or ElderScrollsOfAlts.view.SettingsViewData=="") then
    ElderScrollsOfAlts.outputMsg("Failed test: nil DATA")
    return
  end
  
  local tempTable = {}
  for k, v in viewText:gmatch("(%b{})" ) do    
    local val = tostring(k)
    val = val:gsub("{","")
    val = val:gsub("}","")
    table.insert( tempTable, val  )
    --tempTable[tostring(k)] = tostring(k)
    --ElderScrollsOfAlts.outputMsg("DoTestSelectedView: match val=".. tostring(val) )
  end
  
  --Test names, check in ElderScrollsOfAlts.allowedViewEntries
  local goodEntries = {}
  for kk,vv in pairs(tempTable) do
    local fEntry = ElderScrollsOfAlts.allowedViewEntries[tostring(vv)]      
    --ElderScrollsOfAlts.outputMsg( "Check value: k="..tostring(kk).." v="..tostring(vv) )
    if(fEntry~=nil)then
      table.insert(goodEntries, tostring(vv) )
    else
      fEntry = ElderScrollsOfAlts.allowedViewEntriesLC[string.lower(vv)]
      if(fEntry~=nil)then
        table.insert( goodEntries, tostring(vv) )
      else
        ElderScrollsOfAlts.outputMsg("Failed test: entry failed as k="..tostring(kk).." v="..tostring(vv))
      end
    end
  end
end

------------------------------
-- view: Add
function ElderScrollsOfAlts:DoAddNewViewData()
  local viewTemplate = ElderScrollsOfAlts.view.guiTemplates[ElderScrollsOfAlts.savedVariables.selected.viewTemplate]
  if(viewTemplate==nil)then
    ElderScrollsOfAlts.outputMsg("Failed to find specified template view w/name='".. tostring(ElderScrollsOfAlts.savedVariables.selected.viewTemplate).."'")
    return
  end
  local newView= {}
  newView["name"] = "New View"
  newView["view"] = ElderScrollsOfAlts:deepcopy( viewTemplate["view"] )
  table.insert( ElderScrollsOfAlts.savedVariables.gui, newView )
  ElderScrollsOfAlts.outputMsg("Added new view")
  ElderScrollsOfAlts:RefreshSettingsDropdowns()
end

------------------------------
--Save DATA from FORM
function ElderScrollsOfAlts:DoSaveSelectedView()
  --TODO
  local guiLine = ElderScrollsOfAlts.savedVariables.gui[ElderScrollsOfAlts.savedVariables.selected.viewidx]
  if(guiLine~=nil)then
    guiLine["name"] = tostring(ElderScrollsOfAlts.view.SettingsViewName)
    --guiLine["view"] = ElderScrollsOfAlts.view.SettingsViewData 
    local viewText = (ElderScrollsOfAlts.view.SettingsViewData)
    ElderScrollsOfAlts.debugMsg("DoSaveSelectedView: viewText=", viewText)
    local tempTable = {}
    --for k, v in string.gmatch(tostring(viewText), "(%b{})" ) do    
    for k, v in viewText:gmatch("(%b{})" ) do    
      local val = tostring(k)
      val = val:gsub("{","")
      val = val:gsub("}","")
      table.insert( tempTable, val  )
      --tempTable[tostring(k)] = tostring(k)
      --ElderScrollsOfAlts.outputMsg("DoSaveSelectedView: match k=",tostring(k)," v=", tostring(v) )
    end
    --TODO output fails etc
    --for kk,vv in pairs(tempTable) do
    --  ElderScrollsOfAlts.outputMsg( "tempTable: k="..tostring(kk).." v=",tostring(vv) )
    --end
    --Test names, check in ElderScrollsOfAlts.allowedViewEntries    
    --
    local dataToAllowIfStart = {
      "companion_", "buff_"
    }
    --Test names, check in ElderScrollsOfAlts.allowedViewEntries
    local goodEntryKeys = {}
    local goodEntries = {}
    local validated = true -- if any failed...
    for kk,vv in pairs(tempTable) do
      local fEntry = ElderScrollsOfAlts.allowedViewEntries[tostring(vv)]
      --ElderScrollsOfAlts.outputMsg( "Check value: k="..tostring(kk).." v="..tostring(vv) )
      if(ElderScrollsOfAlts.savedVariables.allowsaveoddviewnames)then
        validated = true
        table.insert(goodEntries, tostring(vv) )
        --goodEntryKeys[tostring(vv)] = true
        ElderScrollsOfAlts.debugMsg("DoSaveSelectedView: allowed '"..tostring(vv) .. "' per all allowed")
      elseif(fEntry~=nil) then      
        if(goodEntryKeys[tostring(vv)]~=nil) then
          ElderScrollsOfAlts.outputMsg("Had to remove element per already in view, '"..tostring(vv) .. "' #="..tostring(kk) )
        else
          table.insert(goodEntries, tostring(vv) )
          goodEntryKeys[tostring(vv)] = true
          --validated = true
          ElderScrollsOfAlts.debugMsg("DoSaveSelectedView: allowed '"..tostring(vv) .. "'")
        end
      else 
        local validatedL = false
        for key,value in pairs(dataToAllowIfStart) do
          if( ElderScrollsOfAlts.starts_with( tostring(vv), value ) ) then  
            if(goodEntryKeys[tostring(vv)]~=nil) then
              ElderScrollsOfAlts.outputMsg("Had to remove element per already in view, '"..tostring(vv) .. "' #="..tostring(kk) )
            else
              validatedL = true
              table.insert(goodEntries, tostring(vv) )
              goodEntryKeys[tostring(vv)] = true
              ElderScrollsOfAlts.debugMsg("DoSaveSelectedView: allowed '"..tostring(vv) .. "' per good start")
            end
          end
        end
        if(validatedL==false) then
            validated = false
            ElderScrollsOfAlts.outputMsg("Saving entry failed '"..tostring(vv).. "' #="..tostring(kk) )
        end
      end
    end
    guiLine["view"] = goodEntries
    if(validated) then
      ElderScrollsOfAlts.outputMsg( "All were validated" )
    end
  
    --[[for k2,v2 in pairs(guiLine.view) do
      ElderScrollsOfAlts.outputMsg("DoSaveSelectedView: k="..tostring(k2).." v="..tostring(v2) )
    end
    --]]
    --ElderScrollsOfAlts.savedVariables.gui[ElderScrollsOfAlts.savedVariables.selected.viewidx].name = ElderScrollsOfAlts.view.newViewName
    --ElderScrollsOfAlts.savedVariables.gui[ElderScrollsOfAlts.savedVariables.selected.viewidx].veiw = ElderScrollsOfAlts.view.newViewEntry
    ElderScrollsOfAlts.outputMsg("Saved View")
  else
    ElderScrollsOfAlts.outputMsg("DoSaveSelectedView: Can't find data line")
  end
end--DoSaveSelectedView

------------------------------
--Edit button puts data into FORM
function ElderScrollsOfAlts:DoEditSelectedView()
  local guiLine = ElderScrollsOfAlts.savedVariables.gui[ElderScrollsOfAlts.savedVariables.selected.viewidx]
  local viewText = ""
  if(guiLine~=nil)then
    --ElderScrollsOfAlts.outputMsg("Edit view found as <".. tostring(guiLine.name)..">" )
    --test guiLine
    --translate guiLine
    ElderScrollsOfAlts.view.SettingsViewName = guiLine.name
    local vName = guiLine["name"]
    local vView = guiLine["view"]
    --ElderScrollsOfAlts.outputMsg("Edit view text as <".. tostring(vName)..">" )
    --
    if(vView~=nil)then
      for i = 1, #vView do
        local entry = vView[i]      
        viewText = zo_strformat( "<<1>>{<<2>>} ", viewText, entry )
      end
    end 
  else
    ElderScrollsOfAlts.view.SettingsViewData = ""  
    ElderScrollsOfAlts.view.SettingsViewName = ""
  end
  ElderScrollsOfAlts.view.SettingsViewData = viewText
end

------------------------------
--
function ElderScrollsOfAlts:GetEditSelectedViewName()
  return tostring(ElderScrollsOfAlts.view.SettingsViewName)
end

------------------------------
--Called when Box looses focus
function ElderScrollsOfAlts.SetEditSelectedViewName(newText)
  ElderScrollsOfAlts.view.SettingsViewName = tostring(newText)
  ElderScrollsOfAlts.debugMsg("SetEditSelectedViewName: set text as=",newText)
end


------------------------------
--Called when Box looses focus
function ElderScrollsOfAlts.SetEditSelectedViewText(newText)
  ElderScrollsOfAlts.view.SettingsViewData = newText
  ElderScrollsOfAlts.debugMsg("SetEditSelectedViewText: set text as=",newText)
end

------------------------------
--
function ElderScrollsOfAlts.GetEditSelectedViewText()
  return (ElderScrollsOfAlts.view.SettingsViewData)
end

------------------------------
--
function ElderScrollsOfAlts.GetAllAllowedViewEntries()
  local printEntries = "" 
  for kName, kVal in pairs(ElderScrollsOfAlts.allowedViewEntries) do
    printEntries = zo_strformat("<<1>> {<<2>>},", printEntries, kName )
  end
  --printEntries = "Allowable entry names: " .. printEntries
  --ElderScrollsOfAlts.outputMsg(printEntries)
  return printEntries
end

------------------------------
--Returns a list of character names
function ElderScrollsOfAlts:ListOfViewEntries1()
  local validChoices =  {}  
	table.insert(validChoices, "Select")
  
  local ave = ElderScrollsOfAlts.allowedViewEntries
  table.sort( ave )
  local cnt = 0
  for kName, kVal in pairs( ave ) do  
    table.insert(validChoices, kName )
    cnt = cnt+1
    if(cnt>40) then
      break
    end
  end
  table.sort( validChoices )
  return validChoices 
end

------------------------------
--Returns a list of character names
function ElderScrollsOfAlts:ListOfViewEntries2()
  local validChoices =  {}  
	table.insert(validChoices, "Select")
  
  local ave = ElderScrollsOfAlts.allowedViewEntries
  --table.sort( ave )
  local cnt = 0
  for kName, kVal in pairs( ave ) do    
    cnt = cnt+1
    if(cnt>80) then
      break
    end
    if(cnt>40) then
      table.insert(validChoices, kName )
    end
  end
  table.sort( validChoices )
  return validChoices 
end

------------------------------
--Returns a list of character names
function ElderScrollsOfAlts:ListOfViewEntries3()
  local validChoices =  {}  
	table.insert(validChoices, "Select")
  
  local ave = ElderScrollsOfAlts.allowedViewEntries
  --table.sort( ave )
  local cnt = 0
  for kName, kVal in pairs( ave ) do   
    cnt = cnt+1
    if(cnt>120) then
      break
    end
    if(cnt>80) then
      table.insert(validChoices, kName )
    end  end
  table.sort( validChoices )
  return validChoices 
end

------------------------------
--Returns a list of character names
function ElderScrollsOfAlts:ListOfViewEntries4()
  local validChoices =  {}  
	table.insert(validChoices, "Select")
  
  local ave = ElderScrollsOfAlts.allowedViewEntries
  --table.sort( ave )
  local cnt = 0
  for kName, kVal in pairs( ave ) do   
    cnt = cnt+1
    if(cnt>120) then
      table.insert(validChoices, kName )
    end
  end
  table.sort( validChoices )
  return validChoices 
end

------------------------------
--SETTINGS For use by Settings dropdown
function ElderScrollsOfAlts:SetSelectedAllowedViewEntry(choiceText)
  if(choiceText==nil) then
    ElderScrollsOfAlts.savedVariables.selected.viewentry = " "
  else
    --choiceText2 = zo_strformat("<<1>> {<<2>>},", printEntries, kName )
    --choiceText2 = string.format("%s%s%s","{",choiceText,"}")
    ElderScrollsOfAlts.savedVariables.selected.viewentry = zo_strformat("{<<1>>}", choiceText )
  end  
end

------------------------------
--SETTINGS For use by Settings dropdown
function ElderScrollsOfAlts:GetSelectedAllowedViewEntry()
  local viewentry = ElderScrollsOfAlts.savedVariables.selected.viewentry
  if(viewentry~=nil)then
     return viewentry
  end
  return ""
end

------------------------------
--SETTINGS For use by Settings dropdown
function ElderScrollsOfAlts:SetUIHIdeInMenues(value)
  ElderScrollsOfAlts.savedVariables.hideinmenus = value  
  HUD_SCENE:AddFragment(ElderScrollsOfAlts.view.esoagui2fragment)
  --HUD_UI_SCENE:AddFragment(ElderScrollsOfAlts.view.esoagui2fragment)
   
  if(ElderScrollsOfAlts.savedVariables.hideinmenus) then
    HUD_SCENE:Hide(ElderScrollsOfAlts.view.esoagui2fragment)
  else
    HUD_SCENE:RemoveFragment(ElderScrollsOfAlts.view.esoagui2fragment)
    --HUD_UI_SCENE:RemoveFragment(ElderScrollsOfAlts.view.esoagui2fragment)
  end
end
 
------------------------------
--SETTINGS For use by Settings dropdown
function ElderScrollsOfAlts:GetSelectedAllowedViewEntry()
  local viewentry = ElderScrollsOfAlts.savedVariables.selected.viewentry
  if(viewentry~=nil)then
     return viewentry
  end
  return ""
end
  
------------------------------
-- UNUSED?
function ElderScrollsOfAlts:SetAllAllowedViewEntries(newName)
  --
end



------------------------------
-- ProfileSettings, from settings
function ElderScrollsOfAlts:DoSaveProfileSettings()
  local pName = GetUnitName("player")  
  ElderScrollsOfAlts.altData.defaults = {}
  ElderScrollsOfAlts.altData.defaultsSaveTime = GetTimeStamp()
  ElderScrollsOfAlts.altData.useAsDefault = pName
  --
  ElderScrollsOfAlts.altData.defaults.uiButtonShow       = ElderScrollsOfAlts:GetUIButtonShown()
  ElderScrollsOfAlts.altData.defaults.uiMouseHighlight   = ElderScrollsOfAlts.GetUIViewMouseHighlightShown()
  ElderScrollsOfAlts.altData.defaults.uiViewDropDown     = ElderScrollsOfAlts.GetUIViewDropDownShown()
  
  ElderScrollsOfAlts.altData.defaults.hideinmenus      = ElderScrollsOfAlts.savedVariables.hideinmenus
  ElderScrollsOfAlts.altData.defaults.cpactivebar1Show = ElderScrollsOfAlts.savedVariables.cpactivebar1.show
  ElderScrollsOfAlts.altData.defaults.cpactivebar2Show = ElderScrollsOfAlts.savedVariables.cpactivebar2.show
  
  ElderScrollsOfAlts.altData.defaults.colorTimerNear     = ElderScrollsOfAlts.savedVariables.colors.colorTimerNear
  ElderScrollsOfAlts.altData.defaults.colorTimerNearer   = ElderScrollsOfAlts.savedVariables.colors.colorTimerNearer
  ElderScrollsOfAlts.altData.defaults.colorTimerDone     = ElderScrollsOfAlts.savedVariables.colors.colorTimerDone
  ElderScrollsOfAlts.altData.defaults.colorTimerNone     = ElderScrollsOfAlts.savedVariables.colors.colorTimerNone
  ElderScrollsOfAlts.altData.defaults.colorSkillsMax     = ElderScrollsOfAlts.savedVariables.colors.colorSkillsMax
  ElderScrollsOfAlts.altData.defaults.colorSkillsNearMax = ElderScrollsOfAlts.savedVariables.colors.colorSkillsNearMax
  --
end

------------------------------
-- ProfileSettings, from settings
function ElderScrollsOfAlts:DoLoadProfileSettings()
  if(ElderScrollsOfAlts.altData.useAsDefault~=nil and ElderScrollsOfAlts.altData.defaults~=nil )then
    --
    ElderScrollsOfAlts.savedVariables.immersive        = ElderScrollsOfAlts.altData.defaults.immersive
    ElderScrollsOfAlts.savedVariables.showmdk          = ElderScrollsOfAlts.altData.defaults.showmdk
    ElderScrollsOfAlts.savedVariables.showdiscovery    = ElderScrollsOfAlts.altData.defaults.showdiscovery
    ElderScrollsOfAlts.savedVariables.sessiontracking  = ElderScrollsOfAlts.altData.defaults.sessiontracking
    ElderScrollsOfAlts.savedVariables.lifetimetracking = ElderScrollsOfAlts.altData.defaults.lifetimetracking
   
    --
    ElderScrollsOfAlts.SetUIButtonShown(ElderScrollsOfAlts.altData.defaults.uiButtonShow)
    ElderScrollsOfAlts.SetUIViewMouseHighlightShown(ElderScrollsOfAlts.altData.defaults.uiMouseHighlight)
    ElderScrollsOfAlts.SetUIViewDropDownShown(ElderScrollsOfAlts.altData.defaults.uiViewDropDown)
    
    ElderScrollsOfAlts.savedVariables.hideinmenus       = ElderScrollsOfAlts.altData.defaults.hideinmenus
    ElderScrollsOfAlts.savedVariables.cpactivebar1.show = ElderScrollsOfAlts.altData.defaults.cpactivebar1Show
    ElderScrollsOfAlts.savedVariables.cpactivebar2.show = ElderScrollsOfAlts.altData.defaults.cpactivebar2Show
    
    
    ElderScrollsOfAlts.savedVariables.colors.colorTimerNear     = ElderScrollsOfAlts.altData.defaults.colorTimerNear
    ElderScrollsOfAlts.savedVariables.colors.colorTimerNearer   = ElderScrollsOfAlts.altData.defaults.colorTimerNearer
    ElderScrollsOfAlts.savedVariables.colors.colorTimerDone     = ElderScrollsOfAlts.altData.defaults.colorTimerDone
    ElderScrollsOfAlts.savedVariables.colors.colorTimerNone     = ElderScrollsOfAlts.altData.defaults.colorTimerNone
    ElderScrollsOfAlts.savedVariables.colors.colorSkillsMax     = ElderScrollsOfAlts.altData.defaults.colorSkillsMax
    ElderScrollsOfAlts.savedVariables.colors.colorSkillsNearMax = ElderScrollsOfAlts.altData.defaults.colorSkillsNearMax
    --
   
    --
    ElderScrollsOfAlts:RefreshTabs()
  end
end

------------------------------
--EOF