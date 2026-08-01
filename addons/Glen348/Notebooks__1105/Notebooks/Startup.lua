--if NBUI == nil then NBUI = {} end

NBUI = {}
---------------------------------------------------------------------------------------------------
--  Initialize Variables  --
---------------------------------------------------------------------------------------------------
NBUI.name = "Notebooks"
NBUI.version = "3.2"
NBUI.settings = {}

--local NBUI_MainWindow, NB1_IndexPool, currentlyViewing
---------------------------------------------------------------------------------------------------
--  Functions  --
---------------------------------------------------------------------------------------------------
function ProtectText(text)
	return text:gsub([[\]], [[%%92]])
end
---------------------------------------------------------------------------------------------------
function UnprotectText(text)
	return text:gsub([[%%92]], [[\]])
end
---------------------------------------------------------------------------------------------------
--  Initialize Function  --
---------------------------------------------------------------------------------------------------
function NBUI.Initialize()
	NBUIDB = NBUIDB or {}
	for k,v in pairs(NBUI.defaults) do
	    if type(NBUIDB[k]) == "nil" then
			NBUIDB[k] = v
	    end
	end
	NBUIDB.NB1Pages = NBUIDB.NB1Pages or {}
	NBUIDB.NB2Pages = NBUIDB.NB2Pages or {}
	NBUIDB.NB3Pages = NBUIDB.NB3Pages or {}		
	
	NB1_IndexPool = ZO_ObjectPool:New(Create_NB1_IndexButton, Remove_NB1_IndexButton)
	NB2_IndexPool = ZO_ObjectPool:New(Create_NB2_IndexButton, Remove_NB2_IndexButton)
	NB3_IndexPool = ZO_ObjectPool:New(Create_NB3_IndexButton, Remove_NB3_IndexButton)
	
	CreateNBUISettings()
end
---------------------------------------------------------------------------------------------------
--  OnAddOnLoaded  --
---------------------------------------------------------------------------------------------------
function NBUI.OnAddOnLoaded(event, addonName)
  if addonName == NBUI.name then
	NBUI.Initialize()
	
	CreateNB1()
	CreateNB2()
	CreateNB3()
	
	Populate_NB1_ScrollList()
	Populate_NB2_ScrollList()
	Populate_NB3_ScrollList()
	
	ZO_CreateStringId("SI_BINDING_NAME_NBUI_NB1TOGGLE", GetString(SI_NBUI_NB1KEYBIND_LABEL))
	ZO_CreateStringId("SI_BINDING_NAME_NBUI_NB2TOGGLE", GetString(SI_NBUI_NB2KEYBIND_LABEL))
	ZO_CreateStringId("SI_BINDING_NAME_NBUI_NB3TOGGLE", GetString(SI_NBUI_NB3KEYBIND_LABEL))
  end
end
---------------------------------------------------------------------------------------------------
--  Register Events  --
---------------------------------------------------------------------------------------------------
EVENT_MANAGER:RegisterForEvent(NBUI.name, EVENT_ADD_ON_LOADED, NBUI.OnAddOnLoaded)
---------------------------------------------------------------------------------------------------
--  Chat Commands  --
---------------------------------------------------------------------------------------------------
SLASH_COMMANDS["/rl"] = ReloadUI