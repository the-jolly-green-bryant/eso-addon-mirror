ACMB = {}

function ACMB.MMSliderDisable()
    if not MasterMerchant then return true end
    return false
end

function ACMB.TTCSliderDisable()
    if not TamrielTradeCentre then return true end
    return false
end

local function tablemerge(t1, t2)
    for k,v in ipairs(t2) do
       table.insert(t1, v)
    end

    return t1
 end

local function pairsByKeys (t, f)
    local a = {}
    for n in pairs(t) do table.insert(a, n) end
    table.sort(a, f)
    local i = 0      -- iterator variable
    local iter = function ()   -- iterator function
      i = i + 1
      if a[i] == nil then return nil
      else return a[i], t[a[i]]
      end
    end
    return iter
end

local function ReadableName(name)
    if string.find( name,"Deconstruct_Set_Type_") then
        name = string.gsub(name,"Deconstruct_Set_Type_","Deconstruct_Set_Type:_")
    end
        name = string.gsub( name,"_"," ")
        return name
end

local function CreatePannel(pname,scommand,pcolor)
    local dname= pcolor .. pname
    local p = {}
    p.type = "panel"
    p.name = pname
    p.displayName = "|c"..dname.."|r"
    p.author = "Methos_Frost"
	p.version = AllCraft.version
    p.slashCommand = scommand

    return p
end
ACMB.CreatePannel = CreatePannel

local function HeaderMenuAdd(headerText)
    local s = {}
        s.type = "header"
        s.name = headerText
        s.width = "full"

    return s
end

local function CheckboxMenuAdd(settingName)
    local set = settingName
    local setting = AllCraft_Decon.deconSettings
    local s = {}
        s.type = "checkbox"
        s.name = ReadableName(settingName)
        s.getFunc = function() return setting[set] end
        s.setFunc = function(value) setting[set] = value end
    return s
end

local function SliderMenuAdd(settingName)
    local set = settingName
    local setting = AllCraft_Decon.deconSettings
    local s = {}
    s.type = "slider"
    s.name = ReadableName(settingName)
    s.getFunc = function() return setting[set] end
    s.setFunc = function(value) setting[set] = value end
    s.tooltip = ""

    return s
end

local function NewSubMenu( subname )
    local sm = {}
    sm.name = subname
    sm.type="submenu"
    sm.controls = {}

    return sm
end

function ACLoadMenu()
    local t = getmetatable(AllCraft_Decon.deconSettings).__index
    local setting = AllCraft_Decon.deconSettings
    local menu = {}
    local setTypeSM = {}
    local qualitySM, ts = {}
    local Enchanting,Woodworking,Jewlery,Clothing,Blacksmithing = {}
    for key, value in pairsByKeys(t) do
        if key ~= "version" then
            if string.find( key,"Deconstruct_Set_Type_") and setting.Deconstruct_Set_Items then
                if next(setTypeSM) == nil then
                    setTypeSM = NewSubMenu("Set Deconstruction Options")
                end
                table.insert (setTypeSM.controls, CheckboxMenuAdd(key))
            end
            if string.find( key, "Extraction") then
                if setting.Account_Wide_Settings then --add both
                    if next(qualitySM) == nil then
                        qualitySM = NewSubMenu("Item Quality Deconstruction Options")
                    end
                    --[[ local  ws = {}
                    for w in key:gmatch("([^_]+)") do table.insert( ws,w ) end
                    local k = tostring(ws[1]) ]]
                    table.insert( qualitySM.controls, SliderMenuAdd(key) )
                end
            end
        end
    end
   --[[  for e in ipairs(ts) do
        table.insert( setTypeSM.controls,e )
    end ]]

    if setTypeSM.controls ~= nil and #setTypeSM.controls ~= 0 then menu = setTypeSM end
    return menu
end
