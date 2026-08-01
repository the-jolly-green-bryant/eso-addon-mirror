----------------------------------------
--[[ ESOA Ctrl ]]-- 
-- INTERNAL calls to switch vs Datastore and Legacy
----------------------------------------
 
----------------------------------------
-- ESOA Functions
----------------------------------------

------------------------------
-- View 
function ElderScrollsOfAlts.CtrlIsShowUiButton()
	--ElderScrollsOfAlts.debugMsg("CtrlIsShowUiButton: Called" )
	local retv = false
	if(ElderScrollsOfAlts.altData.accountdataonly) then
		ElderScrollsOfAlts.debugMsg("CtrlIsShowUiButton: Called 1" )
		retV = (ElderScrollsOfAlts.altData.uibutton.shown)
	else
		ElderScrollsOfAlts.debugMsg("CtrlIsShowUiButton: Called 2" )
		retV = (ElderScrollsOfAlts.savedVariables.uibutton.shown)
	end
	if(retV==nil) then
		retV = false
	end
	return retV
end

------------------------------
-- View 
function ElderScrollsOfAlts.CtrlSetShowUiButton(val)
	if(val==nil) then
		val = false
	end
	if(ElderScrollsOfAlts.altData.accountdataonly) then
		ElderScrollsOfAlts.debugMsg("CtrlSetShowUiButton: Called1", " val=",val )
		ElderScrollsOfAlts.altData.uibutton.shown = val
	else
		ElderScrollsOfAlts.debugMsg("CtrlSetShowUiButton: Called2", " val=",val )
		ElderScrollsOfAlts.savedVariables.uibutton.shown = val
	end
end

------------------------------
-- View  USED?
function ElderScrollsOfAlts.CtrlIsUIViewDropDown()
	local retv = false
	if(ElderScrollsOfAlts.altData.accountdataonly) then
		retV = (ElderScrollsOfAlts.altData.defaults.uiViewDropDown)
	else
		retV = (ElderScrollsOfAlts.savedVariables.viewdropdown.shown)
	end
	if(retV==nil) then
		retV = false
	end
	return retV
end

------------------------------
-- View  USED?
function ElderScrollsOfAlts.CtrlSetUIViewDropDown(val)
	if(val==nil) then
		val = false
	end
	if(ElderScrollsOfAlts.altData.accountdataonly) then
		ElderScrollsOfAlts.altData.defaults.uiViewDropDown = val
	else
		ElderScrollsOfAlts.savedVariables.viewdropdown.shown = val
	end
end

------------------------------
-- View 
-- ElderScrollsOfAlts.altData.defaults.uiMouseHighlight
-- ElderScrollsOfAlts.savedVariables.viewmousehighlight.shown
function ElderScrollsOfAlts.CtrlIsShowMouseHighlight()
	local retv = false
	if(ElderScrollsOfAlts.altData.accountdataonly) then
		retV = ElderScrollsOfAlts.altData.defaults.uiMouseHighlight
		--ElderScrollsOfAlts.debugMsg("CISMH: 1: retV=",retV )
	else
		retV = ElderScrollsOfAlts.savedVariables.viewmousehighlight.shown
		--ElderScrollsOfAlts.debugMsg("CISMH: 2: retV=",retV )
	end
	if(retV==nil) then
		retV = false
		--ElderScrollsOfAlts.debugMsg("CISMH: 3: retV=",retV )
	end
	--ElderScrollsOfAlts.debugMsg("CISMH: 4: retV=",retV )
	return retV
end

------------------------------
-- View 
function ElderScrollsOfAlts.CtrlSetShowMouseHighlight(val)
	if(val==nil) then
		val = false
	end
	if(ElderScrollsOfAlts.altData.accountdataonly) then
		ElderScrollsOfAlts.altData.defaults.uiMouseHighlight = val
	else
		ElderScrollsOfAlts.savedVariables.viewmousehighlight.shown = val
	end
end

------------------------------
--ElderScrollsOfAlts.savedVariables.pvpwarnings = ElderScrollsOfAlts.altData.defaults.pvpwarnings
function ElderScrollsOfAlts.CtrlIsShowPvpWarnings()
	local retv = false
	if(ElderScrollsOfAlts.altData.accountdataonly) then
		retV = (ElderScrollsOfAlts.altData.defaults.pvpwarnings)
	else
		retV = (ElderScrollsOfAlts.savedVariables.pvpwarnings)
	end
	if(retV==nil) then
		retV = false
	end
	return retV
end

------------------------------
--ElderScrollsOfAlts.savedVariables.pvpwarnings = ElderScrollsOfAlts.altData.defaults.pvpwarnings
function ElderScrollsOfAlts.CtrlSetShowPvpWarningst(val)
	if(val==nil) then
		val = false
	end
	if(ElderScrollsOfAlts.altData.accountdataonly) then
		ElderScrollsOfAlts.altData.defaults.pvpwarnings = val
	else
		ElderScrollsOfAlts.savedVariables.pvpwarnings = val
	end
end

function ElderScrollsOfAlts.CtrlUnPackColor(colors)
	if(colors==nil) then
		return 
			ElderScrollsOfAlts.rgbaWhite.r,
			ElderScrollsOfAlts.rgbaWhite.g,
			ElderScrollsOfAlts.rgbaWhite.b,
			ElderScrollsOfAlts.rgbaWhite.a 
	end
	return
		colors.r,
		colors.g,
		colors.b,
		colors.a 
end

------------------------------
--ElderScrollsOfAlts.savedVariables.colors.colorTimerNear
--ElderScrollsOfAlts.altData.colors.colorTimerNear
function ElderScrollsOfAlts.CtrlGetColorTimerNear()
	if(ElderScrollsOfAlts.altData.accountdataonly) then
		if(ElderScrollsOfAlts.altData.colors==nil or ElderScrollsOfAlts.altData.colors.colorTimerNear==nil) then
			ElderScrollsOfAlts.SetupDefaultColors()
		end
		return
		  ElderScrollsOfAlts.altData.colors.colorTimerNear
	else
		if(ElderScrollsOfAlts.savedVariables.colors==nil or ElderScrollsOfAlts.savedVariables.colors.colorTimerNear==nil) then
			ElderScrollsOfAlts.SetupDefaultColors()
		end
		return
		  ElderScrollsOfAlts.savedVariables.colors.colorTimerNear 
	end
end
------------------------------
--ElderScrollsOfAlts.savedVariables.colors.colorTimerNear
--ElderScrollsOfAlts.altData.colors.colorTimerNear
function ElderScrollsOfAlts.CtrlSetColorTimerNear(r,g,b,a)
	if(ElderScrollsOfAlts.altData.accountdataonly) then
      ElderScrollsOfAlts.altData.colors.colorTimerNear = {}
      ElderScrollsOfAlts.altData.colors.colorTimerNear.r = r
      ElderScrollsOfAlts.altData.colors.colorTimerNear.g = g
      ElderScrollsOfAlts.altData.colors.colorTimerNear.b = b
      ElderScrollsOfAlts.altData.colors.colorTimerNear.a = a
	else
      ElderScrollsOfAlts.savedVariables.colors.colorTimerNear = {}
      ElderScrollsOfAlts.savedVariables.colors.colorTimerNear.r = r
      ElderScrollsOfAlts.savedVariables.colors.colorTimerNear.g = g
      ElderScrollsOfAlts.savedVariables.colors.colorTimerNear.b = b
      ElderScrollsOfAlts.savedVariables.colors.colorTimerNear.a = a
	end
end

------------------------------
--ElderScrollsOfAlts.savedVariables.colors.colorTimerNearer
--ElderScrollsOfAlts.altData.colors.colorTimerNearer
function ElderScrollsOfAlts.CtrlGetColorTimerNearer()
	ElderScrollsOfAlts.debugMsg("CtrlGetColorTimerNearer: accountdata?", ElderScrollsOfAlts.altData.accountdataonly )
	if(ElderScrollsOfAlts.altData.accountdataonly) then
		if(ElderScrollsOfAlts.altData.defaults==nil or ElderScrollsOfAlts.altData.colors.colorTimerNearer==nil) then
			ElderScrollsOfAlts.debugMsg("CtrlGetColorTimerNearer: SetupDefaultColors" )
			ElderScrollsOfAlts.SetupDefaultColors()
		end
		ElderScrollsOfAlts.debugMsg("CtrlGetColorTimerNearer: ret altData" )
		return
		  ElderScrollsOfAlts.altData.colors.colorTimerNearer
	else
		if(ElderScrollsOfAlts.savedVariables.colors==nil or ElderScrollsOfAlts.savedVariables.colors.colorTimerNearer==nil) then
			ElderScrollsOfAlts.debugMsg("CtrlGetColorTimerNearer: SetupDefaultColors2" )
			ElderScrollsOfAlts.SetupDefaultColors()
		end
		ElderScrollsOfAlts.debugMsg("CtrlGetColorTimerNearer: ret SV" )
		return
		  ElderScrollsOfAlts.savedVariables.colors.colorTimerNearer 
	end
end
------------------------------
--ElderScrollsOfAlts.savedVariables.colors.colorTimerNearer
--ElderScrollsOfAlts.altData.colors.colorTimerNearer
function ElderScrollsOfAlts.CtrlSetColorTimerNearer(r,g,b,a)
	if(ElderScrollsOfAlts.altData.accountdataonly) then
      ElderScrollsOfAlts.altData.colors.colorTimerNearer = {}
      ElderScrollsOfAlts.altData.colors.colorTimerNearer.r = r
      ElderScrollsOfAlts.altData.colors.colorTimerNearer.g = g
      ElderScrollsOfAlts.altData.colors.colorTimerNearer.b = b
      ElderScrollsOfAlts.altData.colors.colorTimerNearer.a = a
	else
      ElderScrollsOfAlts.savedVariables.colors.colorTimerNearer = {}
      ElderScrollsOfAlts.savedVariables.colors.colorTimerNearer.r = r
      ElderScrollsOfAlts.savedVariables.colors.colorTimerNearer.g = g
      ElderScrollsOfAlts.savedVariables.colors.colorTimerNearer.b = b
      ElderScrollsOfAlts.savedVariables.colors.colorTimerNearer.a = a
	end
end

------------------------------
--ElderScrollsOfAlts.savedVariables.colors.colorTimerDone
--ElderScrollsOfAlts.altData.colors.colorTimerDone
function ElderScrollsOfAlts.CtrlGetColorTimerDone()
	if(ElderScrollsOfAlts.altData.accountdataonly) then
		if(ElderScrollsOfAlts.altData.defaults==nil or ElderScrollsOfAlts.altData.colors.colorTimerDone==nil) then
			ElderScrollsOfAlts.SetupDefaultColors()
		end
		return
		  ElderScrollsOfAlts.altData.colors.colorTimerDone 
	else
		if(ElderScrollsOfAlts.savedVariables.colors==nil or ElderScrollsOfAlts.savedVariables.colors.colorTimerDone==nil) then
			ElderScrollsOfAlts.SetupDefaultColors()
		end
		return
		  ElderScrollsOfAlts.savedVariables.colors.colorTimerDone
	end
end
------------------------------
--ElderScrollsOfAlts.savedVariables.colors.colorTimerDone
--ElderScrollsOfAlts.altData.colors.colorTimerDone
function ElderScrollsOfAlts.CtrlSetColorTimerDone(r,g,b,a)
	if(ElderScrollsOfAlts.altData.accountdataonly) then
      ElderScrollsOfAlts.altData.colors.colorTimerDone = {}
      ElderScrollsOfAlts.altData.colors.colorTimerDone.r = r
      ElderScrollsOfAlts.altData.colors.colorTimerDone.g = g
      ElderScrollsOfAlts.altData.colors.colorTimerDone.b = b
      ElderScrollsOfAlts.altData.colors.colorTimerDone.a = a
	else
      ElderScrollsOfAlts.savedVariables.colors.colorTimerDone = {}
      ElderScrollsOfAlts.savedVariables.colors.colorTimerDone.r = r
      ElderScrollsOfAlts.savedVariables.colors.colorTimerDone.g = g
      ElderScrollsOfAlts.savedVariables.colors.colorTimerDone.b = b
      ElderScrollsOfAlts.savedVariables.colors.colorTimerDone.a = a
	end
end

------------------------------
--ElderScrollsOfAlts.savedVariables.colors.colorTimerNone
--ElderScrollsOfAlts.altData.colors.colorTimerNone
function ElderScrollsOfAlts.CtrlGetColorTimerNone()
	if(ElderScrollsOfAlts.altData.accountdataonly) then
		if(ElderScrollsOfAlts.altData.defaults==nil or ElderScrollsOfAlts.altData.colors.colorTimerNone==nil) then
			ElderScrollsOfAlts.SetupDefaultColors()
		end
		return
		  ElderScrollsOfAlts.altData.colors.colorTimerNone
	else
		if(ElderScrollsOfAlts.savedVariables.colors==nil or ElderScrollsOfAlts.savedVariables.colors.colorTimerNone==nil) then
			ElderScrollsOfAlts.SetupDefaultColors()
		end
		return
		  ElderScrollsOfAlts.savedVariables.colors.colorTimerNone
	end
end
------------------------------
--ElderScrollsOfAlts.savedVariables.colors.colorTimerNone
--ElderScrollsOfAlts.altData.colors.colorTimerNone
function ElderScrollsOfAlts.CtrlSetColorTimerNone(r,g,b,a)
	if(ElderScrollsOfAlts.altData.accountdataonly) then
      ElderScrollsOfAlts.altData.colors.colorTimerNone = {}
      ElderScrollsOfAlts.altData.colors.colorTimerNone.r = r
      ElderScrollsOfAlts.altData.colors.colorTimerNone.g = g
      ElderScrollsOfAlts.altData.colors.colorTimerNone.b = b
      ElderScrollsOfAlts.altData.colors.colorTimerNone.a = a
	else
      ElderScrollsOfAlts.savedVariables.colors.colorTimerNone = {}
      ElderScrollsOfAlts.savedVariables.colors.colorTimerNone.r = r
      ElderScrollsOfAlts.savedVariables.colors.colorTimerNone.g = g
      ElderScrollsOfAlts.savedVariables.colors.colorTimerNone.b = b
      ElderScrollsOfAlts.savedVariables.colors.colorTimerNone.a = a
	end
end

------------------------------
--ElderScrollsOfAlts.savedVariables.colors.colorSkillsMax
--ElderScrollsOfAlts.altData.defaultskillsMax
--
function ElderScrollsOfAlts.CtrlGetColorSkillsMax()
	--ElderScrollsOfAlts.debugMsg("CGCSK: accountonly?",ElderScrollsOfAlts.altData.accountdataonly )
	if(ElderScrollsOfAlts.altData.accountdataonly) then
		if(ElderScrollsOfAlts.altData.defaults==nil or ElderScrollsOfAlts.altData.colors.colorSkillsMax==nil) then
			ElderScrollsOfAlts.SetupDefaultColors()
		end
		return
		  ElderScrollsOfAlts.altData.colors.colorSkillsMax
	else
		if(ElderScrollsOfAlts.savedVariables.colors==nil or ElderScrollsOfAlts.savedVariables.colors.colorSkillsMax==nil) then
			ElderScrollsOfAlts.SetupDefaultColors()
		end
		return
		  ElderScrollsOfAlts.savedVariables.colors.colorSkillsMax
	end
end
------------------------------
--ElderScrollsOfAlts.savedVariables.colors.colorSkillsMax
--ElderScrollsOfAlts.altData.defaultskillsMax
--
function ElderScrollsOfAlts.CtrlSetColorSkillsMax(r,g,b,a)
	if(ElderScrollsOfAlts.altData.accountdataonly) then
      ElderScrollsOfAlts.altData.colors.colorSkillsMax = {}
      ElderScrollsOfAlts.altData.colors.colorSkillsMax.r = r
      ElderScrollsOfAlts.altData.colors.colorSkillsMax.g = g
      ElderScrollsOfAlts.altData.colors.colorSkillsMax.b = b
      ElderScrollsOfAlts.altData.colors.colorSkillsMax.a = a
	else
      ElderScrollsOfAlts.savedVariables.colors.colorSkillsMax = {}
      ElderScrollsOfAlts.savedVariables.colors.colorSkillsMax.r = r
      ElderScrollsOfAlts.savedVariables.colors.colorSkillsMax.g = g
      ElderScrollsOfAlts.savedVariables.colors.colorSkillsMax.b = b
      ElderScrollsOfAlts.savedVariables.colors.colorSkillsMax.a = a
	end
end

------------------------------
--ElderScrollsOfAlts.savedVariables.colors.colorSkillsNearMax
--ElderScrollsOfAlts.altData.defaultskillsNearMax
--
function ElderScrollsOfAlts.CtrlGetColorSkillsNearMax()
	if(ElderScrollsOfAlts.altData.accountdataonly) then
		if(ElderScrollsOfAlts.altData.defaults==nil or ElderScrollsOfAlts.altData.colors.colorSkillsNearMax==nil) then
			ElderScrollsOfAlts.SetupDefaultColors()
		end
		return
		  ElderScrollsOfAlts.altData.colors.colorSkillsNearMax
	else
		if(ElderScrollsOfAlts.savedVariables.colors==nil or ElderScrollsOfAlts.savedVariables.colors.colorSkillsNearMax==nil) then
			ElderScrollsOfAlts.SetupDefaultColors()
		end
		return
		  ElderScrollsOfAlts.savedVariables.colors.colorSkillsNearMax
	end
end

------------------------------
--ElderScrollsOfAlts.savedVariables.colors.colorSkillsNearMax
--ElderScrollsOfAlts.altData.defaults.killsNearMax
--
function ElderScrollsOfAlts.CtrlSetColorSkillsNearMax(r,g,b,a)
	--ElderScrollsOfAlts.debugMsg("CSCSNM: accountonly?",ElderScrollsOfAlts.altData.accountdataonly )
	if(ElderScrollsOfAlts.altData.accountdataonly) then
		if(ElderScrollsOfAlts.altData.defaults==nil or ElderScrollsOfAlts.altData.colors.colorSkillsNearMax==nil) then
			ElderScrollsOfAlts.SetupDefaultColors()
		end
		ElderScrollsOfAlts.altData.colors.colorSkillsNearMax = {}
		ElderScrollsOfAlts.altData.colors.colorSkillsNearMax.r = r
		ElderScrollsOfAlts.altData.colors.colorSkillsNearMax.g = g
		ElderScrollsOfAlts.altData.colors.colorSkillsNearMax.b = b
		ElderScrollsOfAlts.altData.colors.colorSkillsNearMax.a = a
	else
		if(ElderScrollsOfAlts.savedVariables.colors==nil or ElderScrollsOfAlts.savedVariables.colors.colorSkillsNearMax==nil) then
			ElderScrollsOfAlts.SetupDefaultColors()
		end
		ElderScrollsOfAlts.savedVariables.colors.colorSkillsNearMax = {}
		ElderScrollsOfAlts.savedVariables.colors.colorSkillsNearMax.r = r
		ElderScrollsOfAlts.savedVariables.colors.colorSkillsNearMax.g = g
		ElderScrollsOfAlts.savedVariables.colors.colorSkillsNearMax.b = b
		ElderScrollsOfAlts.savedVariables.colors.colorSkillsNearMax.a = a
	end
end

------------------------------
--ElderScrollsOfAlts.savedVariables.gui
--ElderScrollsOfAlts.altData.tabviewdata
--
function ElderScrollsOfAlts.CtrlGetGUIView()
	--ElderScrollsOfAlts.debugMsg("CSCSNM: accountonly?",ElderScrollsOfAlts.altData.accountdataonly )
	if(ElderScrollsOfAlts.altData.accountdataonly) then
		if(ElderScrollsOfAlts.altData.tabviewdata==nil or #ElderScrollsOfAlts.altData.tabviewdata==0) then
			ElderScrollsOfAlts.altData.tabviewdata = {}
		end
		return ElderScrollsOfAlts.altData.tabviewdata
	else
		if(ElderScrollsOfAlts.savedVariables.gui==nil or #ElderScrollsOfAlts.savedVariables.gui==0) then
			ElderScrollsOfAlts.savedVariables.gui = {}
		end
		return ElderScrollsOfAlts.savedVariables.gui
	end
end

------------------------------
-- use either shared tabviewdata or character specific SV.gui
function ElderScrollsOfAlts.CtrlIsGUIViewInitialized()
	--ElderScrollsOfAlts.debugMsg("CSCSNM: accountonly?",ElderScrollsOfAlts.altData.accountdataonly )
	if(ElderScrollsOfAlts.altData.accountdataonly) then
		if(ElderScrollsOfAlts.altData.tabviewdata~=nil and #ElderScrollsOfAlts.altData.tabviewdata>0) then
			return true
		end
	else
		if( ElderScrollsOfAlts.savedVariables.gui~=nil and #ElderScrollsOfAlts.savedVariables.gui>0) then
			return true
		end
	end
	return false
end

-----------------------------
-- 
function ElderScrollsOfAlts.CtrlGetViewCustomColWidths()
	if(ElderScrollsOfAlts.altData.ViewCustomColWidths==nil) then
		ElderScrollsOfAlts.altData.ViewCustomColWidths = ""
	end
	return ElderScrollsOfAlts.altData.ViewCustomColWidths
end

-----------------------------
-- 
function ElderScrollsOfAlts.CtrlSetViewCustomColWidths(val)
	ElderScrollsOfAlts.altData.ViewCustomColWidths = val
	--ElderScrollsOfAlts.outputMsg("customwidth CTRL text='",val,"'")
end

-----------------------------
-- 
function ElderScrollsOfAlts.CtrlGetViewCustomColWidthsParsed()
	if( ElderScrollsOfAlts.altData.ViewCustomColWidths==nil ) then
		ElderScrollsOfAlts.debugMsg("CustomWidths: are nil")
		return nil
	else
		--ElderScrollsOfAlts.outputMsg("CustomWidths: -->")
		local str = ElderScrollsOfAlts.altData.ViewCustomColWidths
		local pkvTable = ElderScrollsOfAlts:parseKeyValues(str)
		--ElderScrollsOfAlts:dumpPrintTable(pkvTable)
		--ElderScrollsOfAlts.outputMsg("<-- CustomWidths")
		return pkvTable
	end
end




------------------------------

----------------------------------------
--[[ ESOA Ctrl ]]-- 
----------------------------------------