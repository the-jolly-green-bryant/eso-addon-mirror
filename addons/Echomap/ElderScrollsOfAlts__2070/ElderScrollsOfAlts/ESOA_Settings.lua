----------------------------------------
--[[ Settings GUI ]]-- 
----------------------------------------
-- LAM to create Settings data --
----------------------------------------

------------------------------
-- UI Button
function ElderScrollsOfAlts.SetUIButtonShown(value)
  ElderScrollsOfAlts.CtrlSetShowUiButton(value)
  ElderScrollsOfAlts.debugMsg("SetUIButtonShown: value=",tostring(value) )
  if not value then
    ElderScrollsOfAlts.HideUIButton()
  else
    ElderScrollsOfAlts.ShowUIButton()
  end  
end

------------------------------
-- View Dropdown USED?
function ElderScrollsOfAlts.SetUIViewDropDownShown(value)
  ElderScrollsOfAlts:CtrlSetUIViewDropDown(value)
  ElderScrollsOfAlts.debugMsg("SetUIViewDropDownShown: value=", tostring(value) )
  --TODO update UI
end

------------------------------
--  Mouse Hightlight
function ElderScrollsOfAlts.SetUIViewMouseHighlightShown(value)
  ElderScrollsOfAlts.CtrlSetShowMouseHighlight(value)
  ElderScrollsOfAlts.debugMsg("SetUIViewMouseHighlightShown: value=", tostring(value) )
  --if(ESOA_GUI2_Body_ListHolder~=nil and ESOA_GUI2_Body_ListHolder.mouseHighlight~=nil) then
  --  ESOA_GUI2_Body_ListHolder.mouseHighlight:SetHidden(true)
  --end
end

------------------------------
--Returns a list of font sizes
function ElderScrollsOfAlts:GetSelectedFontSize()
	if(ElderScrollsOfAlts.savedVariables.selected.textFontSize~=nil) then 
		--TODO KB vs console!!
		--local sz = string.format("$(KB_%s)", ElderScrollsOfAlts.savedVariables.selected.textFontSize )
		return ElderScrollsOfAlts.savedVariables.selected.textFontSize
	end
	return GetString(ESOA_SETTINGS_SELECT)
end

------------------------------
--Returns a list of font sizes
function ElderScrollsOfAlts:ListOfFontSizes2()
	local validChoices =  {}  
	table.insert(validChoices, "Select")
	table.insert(validChoices, "$(KB_14)" )
	table.insert(validChoices, "$(KB_15)" )
	table.insert(validChoices, "$(KB_16)" )
	table.insert(validChoices, "$(KB_17)" )
	table.insert(validChoices, "$(KB_18)" )
	table.insert(validChoices, "$(KB_19)" )
	table.insert(validChoices, "$(KB_20)" )
	table.insert(validChoices, "$(KB_24)" )
	return validChoices 
end
------------------------------
--Returns a list of font sizes
function ElderScrollsOfAlts:ListOfFontSizes()
	local validChoices =  {}  
	table.insert(validChoices, "Select")
	table.insert(validChoices, "14" )
	table.insert(validChoices, "15" )
	table.insert(validChoices, "16" )
	table.insert(validChoices, "17" )
	table.insert(validChoices, "18" )
	table.insert(validChoices, "19" )
	table.insert(validChoices, "20" )
	table.insert(validChoices, "24" )
	return validChoices 
end

------------------------------
--SETTINGS For use by Settings dropdown
function ElderScrollsOfAlts:SelectFontSize(choiceText)
	ElderScrollsOfAlts.savedVariables.selected.textFontSize = choiceText
	if(choiceText==nil) then
		return
	end
	ElderScrollsOfAlts.outputMsg("ESOA font size set to=" .. tostring(choiceText) )
	ElderScrollsOfAlts:UpdateLineEntriesFont()
end

------------------------------
--Returns a list of character names
function ElderScrollsOfAlts:ListOfCharacterNames()
	local validChoices =  {}  
	table.insert(validChoices, "Select")	
	if( ESOADatastore~=nil ) then
		local reval = EchoESOADatastore.getCharacterList(GetDisplayName())
		if(reval~=nil) then
			for index, tvalue in pairs(reval) do				
				--ElderScrollsOfAlts.outputMsg("name=".. tostring(tvalue.name) .. " id=".. tostring(tvalue.id) .. " account=".. tostring(tvalue.account ) )
				table.insert(validChoices, "[data]"..tvalue.id .."("..tostring(tvalue.name)..")"  )
			end
		else
			--ElderScrollsOfAlts.outputMsg("No players listed in datastsore")
		end
	end -- TODO else
	--
	if ElderScrollsOfAlts.altData.players ~= nil then
		for k, v in pairs(ElderScrollsOfAlts.altData.players) do
		if(k~=nil) then
			local displayName = "[esoa]".. k
			if(v~=nil and v.bio~=nil) then
				displayName = "[esoa]"..k .."("..tostring(v.bio.name)..")"
			end
				--debugMsg(ElderScrollsOfAlts.name .. " k " .. k)
				table.insert(validChoices, displayName ) --v.rawname)--v.bio.name )
			end
		end
	end
	--end
	return validChoices 
end

------------------------------
--SETTINGS For use by Settings dropdown
function ElderScrollsOfAlts:SelectCharacterName(choiceText)
	ElderScrollsOfAlts.outputMsg("SelectCharacterName: choiceText=",tostring(choiceText) )
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
	--[data]
	iStart, iEnd = string.find(charKey, "%]" )
	ElderScrollsOfAlts.debugMsg("DoDeleteSelectedCharacter: iStart=" , tostring(iStart), " iEnd=" , tostring(iEnd))
	if(iStart>0) then
		charKey = string.sub(charKey,iStart+1) 
		ElderScrollsOfAlts.debugMsg("DoDeleteSelectedCharacter: charKey2=" , tostring(charKey))
	end
	--
	local deletedOk = false
    if(ElderScrollsOfAlts.altData.players[charKey]~=nil)then
      ElderScrollsOfAlts.altData.players[charKey] = nil
	  deletedOk = true
    end
	-- 
	if( ESOADatastore~=nil ) then	
		ESOADatastore.deleteCharacterByID(charKey,GetDisplayName())
		 deletedOk = true
	end
	if(deletedOk) then
		ElderScrollsOfAlts.outputMsg("ESOA deleted character: Name=" , tostring(charname) )
	else
		ElderScrollsOfAlts.outputMsg("ESOA Error deleting character: Name=" , tostring(charname) )
	end
  end
end

---VIEWS

--Returns a list of view Indexes
function ElderScrollsOfAlts:SettingsListOfViews()
  local validChoices =  {}  
	table.insert(validChoices, "Select")
  local viewCnt = 0
  if(not ElderScrollsOfAlts.CtrlIsGUIViewInitialized()) then
    ElderScrollsOfAlts.outputMsg("InitializeGui wasn't called first")
    ElderScrollsOfAlts.InitializeGui()
  end
  local guiview = ElderScrollsOfAlts.CtrlGetGUIView()
  for viewIdx = 1, #guiview do
    local guiLine = guiview[viewIdx]
	if(guiLine~=nil) then
		local viewName = guiLine.name
		table.insert(validChoices, viewIdx)-- viewName )  
	end
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
	local guiview = ElderScrollsOfAlts.CtrlGetGUIView()
	local guiLine = guiview[ElderScrollsOfAlts.savedVariables.selected.viewidx]
	local viewText = ""
	if(guiLine~=nil)then
		--ElderScrollsOfAlts.outputMsg("Edit view found as <".. tostring(guiLine.name)..">" )
		table.remove(guiview, ElderScrollsOfAlts.savedVariables.selected.viewidx)
		--guiview[ElderScrollsOfAlts.savedVariables.selected.viewidx] = nil
		ElderScrollsOfAlts.outputMsg("Deleted view " , ElderScrollsOfAlts.savedVariables.selected.viewidx)
	end
	ElderScrollsOfAlts:RefreshSettingsDropdowns()
end

------------------------------
-- view: Select
function ElderScrollsOfAlts:DoTestSelectedView()
	local guiview = ElderScrollsOfAlts.CtrlGetGUIView()
	local guiLine2B = guiview[ElderScrollsOfAlts.savedVariables.selected.viewidx]
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
	local hadfailure = false
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
				hadfailure = true
				
				ElderScrollsOfAlts.outputMsg( GetString(ESOA_SETTINGS_TEST_FAIL) ..tostring(kk).." v="..tostring(vv))
			end
		end
	end
	if(hadfailure==false) then
         ElderScrollsOfAlts.outputMsg(GetString(ESOA_SETTINGS_TEST_SUCCESS));
	end
end

------------------------------
-- view: Add
function ElderScrollsOfAlts:DoAddNewViewData()
  ElderScrollsOfAlts.debugMsg("DoAddNewViewData: called")
  local viewTemplate = ElderScrollsOfAlts.view.guiTemplates[ElderScrollsOfAlts.savedVariables.selected.viewTemplate]
  if(viewTemplate==nil)then
    ElderScrollsOfAlts.outputMsg("Failed to find specified template view w/name='".. tostring(ElderScrollsOfAlts.savedVariables.selected.viewTemplate).."'")
    return
  end
  local newView = {}
  local numBtns = #ElderScrollsOfAlts.view.viewButtons
  newView["name"] = "NewView" .. tostring(numBtns)
  newView["view"] = ElderScrollsOfAlts:deepcopy( viewTemplate["view"] )
  local guiview = ElderScrollsOfAlts.CtrlGetGUIView()
  table.insert( guiview, newView )
  ElderScrollsOfAlts.outputMsg("Added new view")
  ElderScrollsOfAlts:RefreshSettingsDropdowns()
end

------------------------------
--Save DATA from FORM
function ElderScrollsOfAlts:DoSaveSelectedView()
  --TODO  
  local guiview = ElderScrollsOfAlts.CtrlGetGUIView()
  local guiLine = guiview[ElderScrollsOfAlts.savedVariables.selected.viewidx]
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
    --guiview[ElderScrollsOfAlts.savedVariables.selected.viewidx].name = ElderScrollsOfAlts.view.newViewName
    --guiview[ElderScrollsOfAlts.savedVariables.selected.viewidx].veiw = ElderScrollsOfAlts.view.newViewEntry
    ElderScrollsOfAlts.outputMsg("Saved View")
  else
    ElderScrollsOfAlts.outputMsg("DoSaveSelectedView: Can't find data line")
  end
end--DoSaveSelectedView

------------------------------
--Edit button puts data into FORM
function ElderScrollsOfAlts:DoEditSelectedView()
  local guiview = ElderScrollsOfAlts.CtrlGetGUIView()
  local guiLine = guiview[ElderScrollsOfAlts.savedVariables.selected.viewidx]
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
	if(ElderScrollsOfAlts.altData.defaults==nil) then
		ElderScrollsOfAlts.altData.defaults = {}
	end
	ElderScrollsOfAlts.altData.defaultsSaveTime = GetTimeStamp()
	ElderScrollsOfAlts.altData.useAsDefault = pName
	--
	ElderScrollsOfAlts.altData.defaults.uiButtonShow       = ElderScrollsOfAlts.savedVariables.uibutton.shown
	--USED? ElderScrollsOfAlts.altData.defaults.uiViewDropDown = ElderScrollsOfAlts.GetUIViewDropDownShown()
	ElderScrollsOfAlts.altData.defaults.uiMouseHighlight   = ElderScrollsOfAlts.savedVariables.viewmousehighlight.shown
	--
	ElderScrollsOfAlts.altData.defaults.hideinmenus        = ElderScrollsOfAlts.savedVariables.hideinmenus
	ElderScrollsOfAlts.altData.defaults.cpactivebar1Show   = ElderScrollsOfAlts.savedVariables.cpactivebar1.show
	ElderScrollsOfAlts.altData.defaults.cpactivebar2Show   = ElderScrollsOfAlts.savedVariables.cpactivebar2.show
	--
	--TODO Views?
	ElderScrollsOfAlts.altData.defaults.pvpwarnings = ElderScrollsOfAlts.savedVariables.pvpwarnings
	--
	if(ElderScrollsOfAlts.savedVariables.colors~=nil) then
		ElderScrollsOfAlts.altData.defaults.colorTimerNear     = ElderScrollsOfAlts.savedVariables.colors.colorTimerNear
		ElderScrollsOfAlts.altData.defaults.colorTimerNearer   = ElderScrollsOfAlts.savedVariables.colors.colorTimerNearer
		ElderScrollsOfAlts.altData.defaults.colorTimerDone     = ElderScrollsOfAlts.savedVariables.colors.colorTimerDone
		ElderScrollsOfAlts.altData.defaults.colorTimerNone     = ElderScrollsOfAlts.savedVariables.colors.colorTimerNone
		ElderScrollsOfAlts.altData.defaults.colorSkillsMax     = ElderScrollsOfAlts.savedVariables.colors.colorSkillsMax
		ElderScrollsOfAlts.altData.defaults.colorSkillsNearMax = ElderScrollsOfAlts.savedVariables.colors.colorSkillsNearMax
	else
		--
	end
  --
  --TODO guiviews?
end

------------------------------
-- ProfileSettings, from settings
function ElderScrollsOfAlts:DoLoadProfileSettings()
  if(ElderScrollsOfAlts.altData.useAsDefault~=nil and ElderScrollsOfAlts.altData.defaults~=nil )then
    --
    ElderScrollsOfAlts.SetUIButtonShown(ElderScrollsOfAlts.altData.defaults.uiButtonShow)
    ElderScrollsOfAlts.SetUIViewMouseHighlightShown(ElderScrollsOfAlts.altData.defaults.uiMouseHighlight)
    -- USED? ElderScrollsOfAlts.SetUIViewDropDownShown(ElderScrollsOfAlts.altData.defaults.uiViewDropDown)
    
    ElderScrollsOfAlts.savedVariables.hideinmenus       = ElderScrollsOfAlts.altData.defaults.hideinmenus
    ElderScrollsOfAlts.savedVariables.cpactivebar1.show = ElderScrollsOfAlts.altData.defaults.cpactivebar1Show
    ElderScrollsOfAlts.savedVariables.cpactivebar2.show = ElderScrollsOfAlts.altData.defaults.cpactivebar2Show
    --
	--TODO Views?
	ElderScrollsOfAlts.savedVariables.pvpwarnings = ElderScrollsOfAlts.altData.defaults.pvpwarnings
	--
    ElderScrollsOfAlts.savedVariables.colors.colorTimerNear     = ElderScrollsOfAlts.altData.defaults.colorTimerNear
    ElderScrollsOfAlts.savedVariables.colors.colorTimerNearer   = ElderScrollsOfAlts.altData.defaults.colorTimerNearer
    ElderScrollsOfAlts.savedVariables.colors.colorTimerDone     = ElderScrollsOfAlts.altData.defaults.colorTimerDone
    ElderScrollsOfAlts.savedVariables.colors.colorTimerNone     = ElderScrollsOfAlts.altData.defaults.colorTimerNone
    ElderScrollsOfAlts.savedVariables.colors.colorSkillsMax     = ElderScrollsOfAlts.altData.defaults.colorSkillsMax
    ElderScrollsOfAlts.savedVariables.colors.colorSkillsNearMax = ElderScrollsOfAlts.altData.defaults.colorSkillsNearMax
    --
    ElderScrollsOfAlts:RefreshTabs()
  end
end

------------------------------
-- ProfileSettings, from settings,
-- (ElderScrollsOfAlts.altData.accountdataonly)
function ElderScrollsOfAlts:SetupAccountWideOnly()
	ElderScrollsOfAlts.debugMsg("SetupAccountWideOnly: Called" )
	if(ElderScrollsOfAlts.altData.defaults==nil) then
		ElderScrollsOfAlts.altData.defaults = {}
	end
	-- copy player to account
	-- all things savedvars will be from accoutnvars
	-- data migrated?
	if(ElderScrollsOfAlts.altData.uibutton==nil) then
		ElderScrollsOfAlts.altData.uibutton = {
			["shown"] = ElderScrollsOfAlts.savedVariables.uibutton.shown,
			["top"]   = ElderScrollsOfAlts.savedVariables.uibutton.top,
			["left"]  = ElderScrollsOfAlts.savedVariables.uibutton.left,
		}
	end
	if not ElderScrollsOfAlts.altData.uibutton.shown then
		ElderScrollsOfAlts.HideUIButton()
	else
		ElderScrollsOfAlts.ShowUIButton()
	end
	--
	if(ElderScrollsOfAlts.savedVariables.viewmousehighlight==nil or ElderScrollsOfAlts.savedVariables.viewmousehighlight.shown==nil) then
		ElderScrollsOfAlts.altData.defaults.uiMouseHighlight = true
	else
		ElderScrollsOfAlts.altData.defaults.uiMouseHighlight = ElderScrollsOfAlts.savedVariables.viewmousehighlight.shown
	end
	--colors
	ElderScrollsOfAlts.SetupDefaultColors()
	--
	if(ElderScrollsOfAlts.altData.tabviewdata==nil) then	
		if(ElderScrollsOfAlts.savedVariables.gui~=nil) then
			ElderScrollsOfAlts.altData.tabviewdata = ElderScrollsOfAlts:deepcopy( ElderScrollsOfAlts.savedVariables.gui )
		else
			ElderScrollsOfAlts:ResetUIViews(self)
		end
	end
	--views
end

------------------------------
-- ProfileSettings, from settings,
-- (ElderScrollsOfAlts.altData.accountdataonly)
function ElderScrollsOfAlts:SetupNotAccountWideOnly()
	ElderScrollsOfAlts.debugMsg("SetupNotAccountWideOnly: Called" )
	if ElderScrollsOfAlts.savedVariables.uibutton==nil or not ElderScrollsOfAlts.savedVariables.uibutton.shown then
		ElderScrollsOfAlts.HideUIButton()
	else
		ElderScrollsOfAlts.ShowUIButton()
	end
	--
	ElderScrollsOfAlts.SetupDefaultColors()
	--
end

------------------------------
-- ProfileSettings, from settings, WILL REMOVE all character specific VIEW settings
-- (ElderScrollsOfAlts.altData.accountdataonly)
function ElderScrollsOfAlts:ClearNonAccountWideData()
	ElderScrollsOfAlts.outputMsg("-Clearing this Characters NonAccountWideData" )
	-- data migrated?
	-- remove players data
	ElderScrollsOfAlts.savedVariables.viewmousehighlight = nil
	ElderScrollsOfAlts.savedVariables.uibutton 		= nil
    ElderScrollsOfAlts.savedVariables.hideinmenus	= nil
    ElderScrollsOfAlts.savedVariables.cpactivebar1	= nil
    ElderScrollsOfAlts.savedVariables.cpactivebar2 	= nil
	ElderScrollsOfAlts.savedVariables.pvpwarnings	= nil
	ElderScrollsOfAlts.savedVariables.viewdropdown	= nil
	ElderScrollsOfAlts.savedVariables.fieldWidthForName 	= nil
	ElderScrollsOfAlts.savedVariables.allowsaveoddviewnames = nil	
	--
    ElderScrollsOfAlts.savedVariables.gui			= nil
	--
    ElderScrollsOfAlts.savedVariables.colors		= nil
    --
    --ElderScrollsOfAlts:RefreshTabs()
	--
end


-----------------------------
-- 
function ElderScrollsOfAlts.GetViewCustomColWidths()
	return ElderScrollsOfAlts.CtrlGetViewCustomColWidths()
end

-----------------------------
-- 
function ElderScrollsOfAlts.SetViewCustomColWidths(val)
	--ElderScrollsOfAlts.outputMsg("customwidth text='",val,"'")
	ElderScrollsOfAlts.CtrlSetViewCustomColWidths(val)
end

-----------------------------
-- 
function ElderScrollsOfAlts.SetViewCustomColWidths2()		
	local textCtr = WINDOW_MANAGER:GetControlByName("ESOA_SETTINGS_CUSTOMWIDTH_TEXT", "")
	if(textCtr~=nil and textCtr.editbox~=nil) then
		local textCtrT = textCtr.editbox:GetText()
		--ElderScrollsOfAlts.outputMsg("customwidth textCtrT='",textCtrT,"'")
		ElderScrollsOfAlts.CtrlSetViewCustomColWidths(textCtrT)
		ElderScrollsOfAlts.CtrlGetViewCustomColWidthsParsed()
	else	
		ElderScrollsOfAlts.outputMsg("Warn: ESOA_SETTINGS_CUSTOMWIDTH_TEXT not found")
	end	
end


-----------------------------
-----------------------------

----------------------------------------
--[[ Settings GUI ]]-- 
----------------------------------------