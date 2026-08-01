-------------------------------------------------------------------------------------------------------------------------------------------------
-- Base of CODE => Bandits User Interface by Hoft 
-------------------------------------------------------------------------------------------------------------------------------------------------

DsR    = DsR or {}
DsR.UI = DsR.UI or {}

local Localization={
	en={
		GUILD     = "ESOUI Addon",
		DONATION  = "Donation",
		GUILDINFO = "Chatlink",
		GUILDN    = "Guild",
	},
	de={
		GUILD     = "ESOUI Addon",
		DONATION  = "Spende",
		GUILDINFO = "Chatlink",
		GUILDN    = "Gilde",
	},
}

local DsRIcon = DsRglobals:HolidayIconLoad()
local lang    = GetCVar("language.2") if not Localization[lang] then lang="en" end
local Loc     = {}
local Menu,Panels,PanelIndex,Options=nil,{},0,{}
for param,value in pairs(Localization.en) do Loc[param]=Localization[lang][param] or value end
local icon_m_size=24
local font_bold="$(BOLD_FONT)|$(KB_18)|soft-shadow-thick"
local font_small="$(MEDIUM_FONT)|$(KB_16)|soft-shadow-thick"

-------------------------------------------------------------------------------------------------------------------------------------------------
--Menu
local function PopulateMenu(control)
	local entryList=ZO_ScrollList_GetDataList(control)
	ZO_ScrollList_Clear(control)
	for i, data in ipairs(Panels) do
		data.sortIndex=i
		entryList[i]=ZO_ScrollList_CreateDataEntry(1, data)
	end
	ZO_ScrollList_Commit(control)
	ZO_ScrollList_SelectData(control, Panels[1], nil)
end

-------------------------------------------------------------------------------------------------------------------------------------------------
--RELOAD UI
function DsR.Menu.HandleReloadUIPressed()
	SCENE_MANAGER:SetInUIMode(false)
	
	local params  = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_MAJOR_TEXT)
	local icon    = zo_iconFormat("/esoui/art/lfg/lfg_groupfinder_refreshsearch_down.dds", 64, 64)
	
	params:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_DAILY_LOGIN_REWARD_CLAIMED)
	params:SetText(icon .. "|c35fc38Reloading UI|r")

	CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(params)
	DsR.CallLater("ReloadUI",1000,ReloadUI)
end

function DsR.UI.ReloadUIButton()
	Menu.apply:SetHidden(false)
end

-------------------------------------------------------------------------------------------------------------------------------------------------
local function CreateMenuList(name, parent)
	local list=WINDOW_MANAGER:CreateControlFromVirtual(name, parent, "ZO_ScrollList")

	local function listRow_OnMouseDown(self, button)
		if button==1 then
			local data=ZO_ScrollList_GetData(self)
			ZO_ScrollList_SelectData(list, data, self)
		end
	end

	local function listRow_Select(previouslySelectedData, selectedData, reselectingDuringRebuild)
		if not reselectingDuringRebuild then
			if previouslySelectedData then
				previouslySelectedData.panel:SetHidden(true)
			end
			if selectedData then
				selectedData.panel:SetHidden(false)
				PlaySound(SOUNDS.MENU_SUBCATEGORY_SELECTION)
			end
		end
	end

	local function listRow_Setup(control, data)
		control:SetText(data.name)
		control:SetSelected(not data.panel:IsHidden())
	end

	ZO_ScrollList_AddDataType(list, 1, "ZO_SelectableLabel", 28, listRow_Setup)
	ZO_ScrollList_EnableSelection(list, "ZO_ThinListHighlight", listRow_Select)

	local addonDataType=ZO_ScrollList_GetDataTypeTable(list, 1)
	local listRow_CreateRaw=addonDataType.pool.m_Factory

	local function listRow_Create(pool)
		local control=listRow_CreateRaw(pool)
		control:SetHandler("OnMouseDown", listRow_OnMouseDown)
		control:SetHeight(28)
		control:SetFont(font_bold)
		control:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
		control:SetVerticalAlignment(TEXT_ALIGN_CENTER)
		control:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
		return control
	end

	addonDataType.pool.m_Factory=listRow_Create

	return list
end

-------------------------------------------------------------------------------------------------------------------------------------------------
local function SettingsWindow_Init()
	local width, height = GuiRoot:GetDimensions()
	local ui = DsR.UI.TopLevelWindow("DsR_SettingsWindow", GuiRoot, {1110,height}, {LEFT,LEFT,245,0}, true)
	Menu = ui

	ui.bgLeft=DsR.UI.Texture("$(parent)_bgLeft", ui, {1124,height*1.1}, {TOPLEFT,TOPLEFT,0,40}, "EsoUI/Art/Miscellaneous/centerscreen_left.dds", false, DL_BACKGROUND)
	ui.bgLeft:SetExcludeFromResizeToFitExtents(true)


	ui.logo=DsR.UI.Texture("$(parent)_logo", ui, {100,100}, {TOPRIGHT,TOPRIGHT,-20,60}, "/"..DsRIcon, false, DL_BACKGROUND)

	ui.title=DsR.UI.Label("$(parent)_title", ui, {1010,30}, {TOPLEFT,TOPLEFT,65,70}, "ZoFontWinH1", nil, nil, DsR.DisplayName)

	ui.divider=WINDOW_MANAGER:CreateControlFromVirtual("$(parent)_divider", ui, "ZO_Options_Divider")
	ui.divider:SetAnchor(TOPLEFT, nil, TOPLEFT, -100, 108)
	ui.divider:SetHeight(10)
	ui.divider:SetWidth(1024)
	ui.divider:SetTexture("/esoui/art/miscellaneous/horizontaldivider_mythic.dds")
	
	ui.menu=DsR.UI.Control("$(parent)_menu", ui, {285,height}, {TOPLEFT,TOPLEFT,65,160})
	ui.menu=CreateMenuList("$(parent)AddonList", ui)
	ui.menu:SetAnchor(TOPLEFT, nil, TOPLEFT, 65, 160)
	ui.menu:SetDimensions(355, height)

	ui.panel=DsR.UI.Control("$(parent)_panel", ui, {640,height*0.75}, {TOPLEFT,TOPLEFT,420,120})

    -- Donation
    ui.guildsite=WINDOW_MANAGER:CreateControl("$(parent)guildsite", ui, CT_BUTTON)
	ui.guildsite:SetClickSound("Click")
	ui.guildsite:SetFont("ZoFontGameSmall")
	ui.guildsite:SetNormalFontColor(ZO_ColorDef:New("00CDCD"):UnpackRGBA())
	ui.guildsite:SetMouseOverFontColor(ZO_ColorDef:New("B8B8D3"):UnpackRGBA())
	ui.guildsite:SetAnchor(TOPRIGHT, nil, TOPRIGHT, -355, 85)
	ui.guildsite:SetText(Loc["GUILDINFO"])
	ui.guildsite:SetDimensions(ui.guildsite:GetLabelControl():GetTextDimensions())
	ui.guildsite:SetHandler("OnClicked",function(self) CHAT_SYSTEM:Maximize() d("|c00CDCDLINK >>>> |H1:guild:155508|hDie sieben Raben|h <<<<|r") end)

    -- Donation
    ui.donation=WINDOW_MANAGER:CreateControl("$(parent)Donation", ui, CT_BUTTON)
	ui.donation:SetClickSound("Click")
	ui.donation:SetFont("ZoFontGameSmall")
	ui.donation:SetNormalFontColor(ZO_ColorDef:New("00CDCD"):UnpackRGBA())
	ui.donation:SetMouseOverFontColor(ZO_ColorDef:New("B8B8D3"):UnpackRGBA())
	ui.donation:SetAnchor(TOPRIGHT, nil, TOPRIGHT, -230, 85)
	ui.donation:SetText(Loc["DONATION"])
	ui.donation:SetDimensions(ui.donation:GetLabelControl():GetTextDimensions())
	ui.donation:SetHandler("OnClicked",function(self) DsRglobals:DsRdonation() end)

    -- ESOUI Addon
    ui.guildesoui=WINDOW_MANAGER:CreateControl("$(parent)guildesoui", ui, CT_BUTTON)
	ui.guildesoui:SetClickSound("Click")
	ui.guildesoui:SetFont("ZoFontGameSmall")
	ui.guildesoui:SetNormalFontColor(ZO_ColorDef:New("5959D5"):UnpackRGBA())
	ui.guildesoui:SetMouseOverFontColor(ZO_ColorDef:New("B8B8D3"):UnpackRGBA())
	ui.guildesoui:SetAnchor(TOPRIGHT, nil, TOPRIGHT, -120, 85)
	ui.guildesoui:SetText(Loc["GUILD"])
	ui.guildesoui:SetDimensions(ui.guildesoui:GetLabelControl():GetTextDimensions())
	ui.guildesoui:SetHandler("OnClicked",function(self)RequestOpenUnsafeURL("https://www.esoui.com/downloads/info3776-DsRGuildRoster.html")end)

    -- Autoren- und Versionsinfo
    local version    = DsRVersion.version
    local author     = "|cD8F781Has|r|cF3F781enw|r|cF5DA81arr|r|cF7BE81ior|r"
    local authoricon = zo_iconFormat("/DsRGuildHall/misc/Hasenwarrior.dds", 20, 20)
    ui.info = WINDOW_MANAGER:CreateControl("$(parent)_info", ui, CT_LABEL)
    ui.info:SetFont("ZoFontGameSmall")
    ui.info:SetAnchor(TOPLEFT, ui, TOPLEFT, 300, 85)
    ui.info:SetText("Autor: " .. authoricon .. author .. " |       Version: " .. version  .. " |       " .. Loc["GUILDN"] .. ": Die sieben Raben")
	
	-- RELOADUI-Button
	ui.apply=WINDOW_MANAGER:CreateControlFromVirtual("$(parent)_apply", ui, "ZO_DialogButton")
	ZO_KeybindButtonTemplate_Setup(ui.apply, "OPTIONS_APPLY_CHANGES", DsR.Menu.HandleReloadUIPressed, GetString(SI_ADDON_MANAGER_RELOAD))
	ui.apply:SetAnchor(TOPRIGHT, ui.menu, BOTTOMRIGHT, -150, -height*0.3)
	ui.apply:SetHidden(true)

	--Scene
	local scene=ZO_FadeSceneFragment:New(ui, true, 100)
	scene:RegisterCallback("StateChange", function(oldState, newState)
		if(newState==SCENE_FRAGMENT_SHOWN) then
			PushActionLayerByName("OptionsWindow")
		elseif(newState==SCENE_FRAGMENT_HIDDEN) then
			RemoveActionLayerByName("OptionsWindow")
		end
	end)

	--Settings menu entry
	ui.id=KEYBOARD_OPTIONS.currentPanelId
	local data={
		id=ui.id,
		name=DsR.ShortName,
		longname=DsR.DisplayName,
		callback=function()
			SCENE_MANAGER:AddFragment(scene)
			if not ui.init then
				table.sort(Panels, function(a, b) return a.name<b.name end)
				PopulateMenu(ui.menu)
				ui.init=true
			end
		end,
		unselectedCallback=function()
			SCENE_MANAGER:RemoveFragment(scene)
			if SetCameraOptionsPreviewModeEnabled then
				SetCameraOptionsPreviewModeEnabled(false)
			end
		end
	}
	KEYBOARD_OPTIONS.currentPanelId=ui.id+1
	KEYBOARD_OPTIONS.panelNames[ui.id]=data.name
	ZO_GameMenu_AddSettingPanel(data)

	--Highlight
	ui.highlight=DsR.UI.Texture("$(parent)_highlight", ui, {(645-20)/3*2,26}, {TOPLEFT,TOPLEFT,0,0}, "esoui/art/miscellaneous/listitem_highlight.dds",true,nil,{0,1,0,.625})
end

-------------------------------------------------------------------------------------------------------------------------------------------------
local function CheckDisabledOptions(panel)
	if not Options[panel] then return end
	local function Update(data)
		local disabled=data.disabled and data.disabled()
		if data.frame.color then
			data.frame.color:SetDisabled(disabled)
			if data.frame.color2 then
				data.frame.color2:SetDisabled(disabled)
				data.frame:SetColors(disabled and function() return .2,.2,.2,1 end or data.getFunc, disabled and function() return .2,.2,.2,1 end or data.getFunc2)
			end
		elseif data.frame.control then
			if data.frame.control.SetDisabled then
				data.frame.control:SetDisabled(disabled)
			end
		elseif data.frame.label then
			local color=disabled and {.3,.3,.3,1} or {.8,.8,.6,1}
			data.frame.label:SetColor(unpack(color))
		end
	end

	for i,data in pairs(Options[panel]) do
		if data.frame then
			Update(data)
		elseif data.controls then
			for _,sub_data in pairs(data.controls) do
				if sub_data.frame then Update(sub_data) end
			end
		end
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
local function CreateOptions(parent,options,panel,submenu)
	local w,h=695-20,26
	local space=5
	local h1=h+space
	local anchor={TOPLEFT,TOPLEFT,0,0,parent}
	local highlight=DsR_SettingsWindow.highlight
	for i,data in pairs(options) do
		local frame
		local func=function(...) data.setFunc(...) CheckDisabledOptions(panel) end
		
		local name    = ""
		local tooltip = ""
		if DsR.Localization[DsR.language][data.name] ~= nil then
			name = data.name and (data.icon and zo_iconFormat(data.icon,icon_m_size,icon_m_size).." " or "") .. DsR.Localization[DsR.language][data.name]
			tooltip=DsR.Localization[DsR.language][data.name.."Desc"] or nil
		else
			name    = data.name
			tooltip = ""
		end

		if data.type=="header" then
			frame=DsR.UI.Backdrop("$(parent)_Header"..i, parent, {w,h}, anchor, {.4,.4,.4,.3}, {0,0,0,0})
			frame.label=DsR.UI.Label("$(parent)_Label", frame, {w,h}, {TOPLEFT,TOPLEFT,0,0}, font_bold, {.8,.8,.6,1}, {1,1}, name)
			anchor={TOPLEFT,BOTTOMLEFT,0,space,frame}
		elseif data.type=="subheader" then
			frame=DsR.UI.Backdrop("$(parent)_Subheader"..i, parent, {w,h}, anchor, {.4,.4,.4,.3}, {0,0,0,15})
			frame.label=DsR.UI.Label("$(parent)_Label", frame, {w,h}, {TOPLEFT,TOPLEFT,0,0}, font_bold, {.8,.8,.6,1}, {1,1}, name)
			anchor={TOPLEFT,BOTTOMLEFT,0,space,frame}
		elseif data.type=="description" then
			frame=DsR.UI.Backdrop("$(parent)_Description"..i, parent, {0,17}, anchor, {.4,.4,.4,.3}, {0,0,0,0})
			frame.label=DsR.UI.Label("$(parent)_Label", frame, {w,17}, {TOPLEFT,TOPLEFT,0,0}, font_small, {.8,.8,.6,1}, {1,1}, name)
			anchor={TOPLEFT,BOTTOMLEFT,0,space,frame}
		elseif data.type=="attention" then
			frame=DsR.UI.Backdrop("$(parent)_Attention"..i, parent, {0,h}, anchor, {.4,.4,.4,.3}, {0,0,0,0})
			frame.label=DsR.UI.Label("$(parent)_Label", frame, {w,h}, {TOPLEFT,TOPLEFT,0,0}, font_bold, {.8,.8,.6,1}, {1,1}, name)
			anchor={TOPLEFT,BOTTOMLEFT,0,space,frame}
		elseif data.type=="checkbox" then
			frame=DsR.UI.Control("$(parent)_Check"..i, parent, {w,h}, anchor)
			frame.label=DsR.UI.Label("$(parent)_Label", frame, {w/3*2,h}, {TOPLEFT,TOPLEFT,0,0}, font_bold, {.8,.8,.6,1}, {0,1}, name)
			frame.control=DsR.UI.CheckBox("$(parent)_CheckBox", frame.label, {h,h}, {TOPLEFT,TOPRIGHT,0,0}, data.getFunc(),func, tooltip)
			anchor={TOPLEFT,BOTTOMLEFT,0,space,frame}
		elseif data.type=="button" then
			frame=DsR.UI.Control("$(parent)_Frame"..i, parent, {w,h}, anchor)
			button=WINDOW_MANAGER:CreateControlFromVirtual(data.reference or "$(parent)_Button", frame, "ZO_DefaultButton")
			button:SetWidth(180, 28)
			button:SetFont(font_bold)
			button:SetText(name)
			button:SetAnchor(TOP,frame,TOP,0,0)
			button:SetClickSound("Click")
			button:SetHandler("OnClicked", data.func)
			anchor={TOPLEFT,BOTTOMLEFT,0,space,frame}
		elseif data.type=="editbox" then
			frame=DsR.UI.Control("$(parent)_Edit"..i, parent, {w,h}, anchor)
			frame.label=DsR.UI.Label("$(parent)_Label", frame, {w/3*2,h}, {TOPLEFT,TOPLEFT,0,0}, font_bold, {.8,.8,.6,1}, {0,1}, name)
			frame.control=DsR.UI.TextBox("$(parent)_EditBox", frame.label, {w/3,h}, {TOPLEFT,TOPRIGHT,0,0}, 200, data.getFunc,func)
			anchor={TOPLEFT,BOTTOMLEFT,0,space,frame}
		elseif data.type=="editboxMulti" then
			frame=DsR.UI.Control("$(parent)_EditMulti"..i, parent, {w,h*3}, anchor)
			frame.label=DsR.UI.Label("$(parent)_Label", frame, {w/3*2,h*3}, {TOPLEFT,TOPLEFT,0,0}, font_bold, {.8,.8,.6,1}, {0,1}, name)
			frame.control=DsR.UI.TextBoxMulti("$(parent)_EditBoxMulti", frame.label, {w/3,h*3}, {TOPLEFT,TOPRIGHT,0,0}, 200, data.getFunc,func)
			anchor={TOPLEFT,BOTTOMLEFT,0,space,frame}
		elseif data.type=="editboxMultiBig" then
			frame=DsR.UI.Control("$(parent)_EditMultiBig"..i, parent, {w,h*6}, anchor)
			local ctrlName=data.controlName or "$(parent)_EditBoxMultiBig"
			frame.control=DsR.UI.TextBoxMultiBig(ctrlName, frame, {w,h*6}, {RIGHT,TOPLEFT,0,0}, 1000, data.getFunc, func)
			anchor={TOPLEFT,BOTTOMLEFT,0,space,frame}
		elseif data.type=="dropdown" then
			frame=DsR.UI.Control("$(parent)_Drop"..i, parent, {w,h}, anchor)
			frame.label=DsR.UI.Label("$(parent)_Label", frame, {w/3*2,h}, {TOPLEFT,TOPLEFT,0,0}, font_bold, {.8,.8,.6,1}, {0,1}, name)
			frame.control=DsR.UI.ComboBox(data.reference or "$(parent)_DropBox", frame.label, {w/3,28}, {TOPLEFT,TOPRIGHT,0,0}, data.choices, data.getFunc(),func,false,data.scrollable)
			anchor={TOPLEFT,BOTTOMLEFT,0,space,frame}
		elseif data.type=="colorpicker" then
			frame=DsR.UI.Control("$(parent)_Color"..i, parent, {w,h}, anchor)
			frame.label=DsR.UI.Label("$(parent)_Label", frame, {w/3*2,h}, {TOPLEFT,TOPLEFT,0,0}, font_bold, {.8,.8,.6,1}, {0,1}, name)
			frame.color=DsR.UI.ColorPicker("$(parent)_ColorPick", frame, {40,22}, {TOPLEFT,TOPLEFT,w/3*2,0}, data.getFunc,func)
			anchor={TOPLEFT,BOTTOMLEFT,0,space,frame}
		elseif data.type=="slider" then
			frame=DsR.UI.Control("$(parent)_Slider"..i, parent, {w,h}, anchor)
			frame.label=DsR.UI.Label("$(parent)_Label", frame, {w/3*2,h}, {TOPLEFT,TOPLEFT,0,0}, font_bold, {.8,.8,.6,1}, {0,1}, name)
			frame.control=DsR.UI.Slider("$(parent)_Slider", frame.label, {w/3,h}, {TOPLEFT,TOPRIGHT,0,0}, false,func, {data.min,data.max,data.step},true)
			frame.control:UpdateValue(data.getFunc())
			anchor={TOPLEFT,BOTTOMLEFT,0,space,frame}
		elseif data.type=="texture" then
			frame=DsR.UI.Control("$(parent)_Frame"..i, parent, {w,data.dimensions[2]}, anchor)
			frame.texture=DsR.UI.Texture("$(parent)_Texture", frame, data.dimensions, {TOP,TOP,0,0}, data.texture)
			anchor={TOPLEFT,BOTTOMLEFT,0,space,frame}
		elseif data.type=="submenu" then
			local frame=DsR.UI.Control("$(parent)_Sub"..i, parent, {w,h}, anchor)
			frame.header=DsR.UI.Backdrop("$(parent)_Bg", frame, {w,h}, {TOPLEFT,TOPLEFT,0,0}, {.4,.4,.4,.3}, {0,0,0,0})
			frame.label=DsR.UI.Label("$(parent)_Label", frame, {w,h}, {TOPLEFT,TOPLEFT,0,0}, font_bold, {.8,.8,.6,1}, {1,1}, name)
			frame.total=#data.controls
			frame.content=DsR.UI.Control("$(parent)_Content", frame, {w,h1*frame.total}, {TOPLEFT,TOPLEFT,0,h1}, true)
			frame.control=DsR.UI.SlideBox(nil, frame.header, {22,22}, {RIGHT,RIGHT,-20,0}, true, function(self,value)
				frame:SetHeight(value and h or h1*(frame.total+1))
				frame.content:SetHidden(value)
			end)
			CreateOptions(frame.content,data.controls,panel,true)
			anchor={TOPLEFT,BOTTOMLEFT,0,space,frame}
		end
		if frame then
			if frame.label and data.type~="header" and data.type~="subheader" and data.type~="submenu" then
				frame:SetMouseEnabled(true)
				frame:SetHandler("OnMouseEnter", function(self)
					highlight:ClearAnchors()
					highlight:SetAnchor(LEFT,self,LEFT,0,0)
					highlight:SetHidden(false)
					if tooltip then ZO_Tooltips_ShowTextTooltip(self,BOTTOM,tooltip) end
				end)
				frame:SetHandler("OnMouseExit", function() highlight:SetHidden(true) ZO_Tooltips_HideTextTooltip() end)
			end
			if data.warning then
				local warn=DsR.UI.Texture(nil, frame, {h,h}, {LEFT,LEFT,w/3*2-h,0}, "/esoui/art/miscellaneous/eso_icon_warning.dds")
				warn:SetMouseEnabled(true)
				warn:SetDrawTier(DT_HIGH)
				warn:SetDrawLayer(DL_CONTROLS)
				warn:SetColor( .85, .65, .13, 1 )
				warn:SetHandler("OnMouseEnter", function(self)
					ZO_Tooltips_ShowTextTooltip(self,TOP,type(data.warning)=="string" and DsR.Localization[DsR.language][data.warning] or DsR.Loc("ReloadUiWarn1"))
				end)
				warn:SetHandler("OnMouseExit", ZO_Tooltips_HideTextTooltip)
			end
			options[i].frame=frame
		end
	end
	if not submenu then CheckDisabledOptions(panel) end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
local function TogglePanel(panel)
	if Menu.current and Menu.current~=panel then
		Menu.current:SetHidden(true)
	end
	Menu.current=panel

	--refresh visible rows to reflect panel IsHidden status
	ZO_ScrollList_RefreshVisible(Menu.menu)

	if not panel.init and Options[panel.name] then
		CreateOptions(panel.scroll,Options[panel.name],panel.name)
		panel.init=true
	end
end

--Options
function DsR.Menu.UpdateOptions(panel)
	if Options[panel]==nil then return end

	local function Update(data)	
		if data.frame.control then
			local value=data.getFunc and data.getFunc() or nil
			if data.frame.control.UpdateValue then
				data.frame.control:UpdateValue(value)
			elseif data.frame.control.UpdateValues then
				data.frame.control:UpdateValues(nil,value)
			end
		elseif data.frame.color then
			local r,g,b,a=data.getFunc()
			data.frame.color:UpdateValue(r,g,b,a)
			if data.frame.color2 then
				local r2,g2,b2,a2=data.getFunc2()
				data.frame.color2:UpdateValue(r2,g2,b2,a2)
				if data.frame.SetColors then
					data.frame.SetColors(data.frame,data.getFunc,data.getFunc2)
				end
			end
		end
	end

	for i,data in pairs(Options[panel]) do
		if data.frame then
			Update(data)
		elseif data.controls then
			for _,sub_data in pairs(data.controls) do
				if sub_data.frame then Update(sub_data) end
			end
		end
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsR.Menu.Open()
	local function SettingsMenu()
		local gameMenu=ZO_GameMenu_InGame.gameMenu.headerControls[GetString(SI_GAME_MENU_SETTINGS)]
		if gameMenu then
			local children=gameMenu:GetChildren()
			for i=1, (children and #children or 0) do
				local child=children[i]
				local data=child:GetData()
				if data and data.id==DsR_SettingsWindow.id then
					child:GetTree():SelectNode(child)
					break
				end
			end
		end
	end

	if SCENE_MANAGER:GetScene("gameMenuInGame"):GetState()==SCENE_SHOWN then
		SettingsMenu()
	else
		SCENE_MANAGER:CallWhen("gameMenuInGame", SCENE_SHOWN, SettingsMenu)
		SCENE_MANAGER:Show("gameMenuInGame")
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsR.Menu.RegisterOptions(name, data)
	Options[name]=data
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsR.Menu.RegisterPanel(name, data)
	local width, height = GuiRoot:GetDimensions()
	local panel=DsR.UI.Control(name, DsR_SettingsWindow.panel, {695,height*0.75}, {TOPLEFT,TOPLEFT,0,0}, true)
	panel.name=name
	panel.data=data

	panel.label=WINDOW_MANAGER:CreateControlFromVirtual(nil, panel, "ZO_Options_SectionTitleLabel")
	panel.label:SetAnchor(TOPLEFT, panel, TOPLEFT, 0, 4)
	panel.label:SetText(data.displayName or data.name)

	local container=WINDOW_MANAGER:CreateControlFromVirtual("$(parent)_Scroll", panel, "ZO_ScrollContainer")
	container:SetAnchor(TOPLEFT, panel, TOPLEFT, 0, 50)
	container:SetAnchor(BOTTOMRIGHT, panel, BOTTOMRIGHT, 0, 150) -- 0
	panel.scroll=GetControl(container, "ScrollChild")
	panel.scroll:SetResizeToFitPadding(0,0)

	panel:SetHandler("OnShow", function(self)
		TogglePanel(self)
		DsR.Menu.UpdateOptions(self.name)
		CheckDisabledOptions(self.name)
	end)
	table.insert(Panels, {panel=panel,name=data.name})

	return panel
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsR.Menu.Init()
    SettingsWindow_Init()
	DsR.InternalMenu=true
end

local function Initialize(eventCode, addOnName)
    EVENT_MANAGER:UnregisterForEvent("DsRMenuFunc_Event", EVENT_ADD_ON_LOADED)
    DsR.Menu.Init()

    CALLBACK_MANAGER:FireCallbacks("DsR_Ready")
end

EVENT_MANAGER:RegisterForEvent("DsRMenuFunc_Event", EVENT_ADD_ON_LOADED, Initialize)
