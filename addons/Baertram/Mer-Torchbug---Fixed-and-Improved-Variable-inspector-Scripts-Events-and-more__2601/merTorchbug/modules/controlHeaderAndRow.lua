local tbug = TBUG or SYSTEMS:GetSystem("merTorchbug")

local types = tbug.types
local stringType = types.string
local numberType = types.number
local functionType = types.func
local tableType = types.table
local userDataType = types.userdata
local structType = types.struct

local strformat = string.format

local ROW_TYPE_HEADER = 6
local ROW_TYPE_PROPERTY = 7
tbug.RowTypes = {
    ROW_TYPE_HEADER =   ROW_TYPE_HEADER,
    ROW_TYPE_PROPERTY = ROW_TYPE_PROPERTY,
}

local isControl = tbug.isControl

local prepareItemLink = tbug.prepareItemLink

tbug.thChildrenId = nil
tbug.tdBuildChildControls = nil

local customKeysForInspectorRows = tbug.customKeysForInspectorRows
local customKey__Object = customKeysForInspectorRows.object




------------------------------------------------------------------------------------------------------------------------
-- Class locals for later usage below
-------------------------------------------------------------------------------------------------------------------------
local ColorProperty = {}
local AnchorAttribute = {}
local DimensionConstraint = {}
local ResizeToFitPadding = {}


------------------------------------------------------------------------------------------------------------------------
-- The different setupFunctions for the row types: e.g. td = normal row, th = header row
-------------------------------------------------------------------------------------------------------------------------
local noHeader = false
local currentHeader = 0

local function th(prop)
    noHeader = false
    prop.typ = ROW_TYPE_HEADER
    prop.isHeader = true
    currentHeader = currentHeader + 1
    prop.headerId = currentHeader

    return setmetatable(prop, prop.cls)
end
tbug.th = th

local function td(prop)
    prop.typ = ROW_TYPE_PROPERTY
    prop.isHeader = false
    if not noHeader then
        if not tbug.tdBuildChildControls then
            prop.parentId = currentHeader
        end
    end

    local getFuncName = prop.gets
    if getFuncName then
        local arg = prop.arg
        local idx = prop.idx
        local setFuncName = prop.sets
        if arg ~= nil then
            function prop.get(data, control)
                return (select(idx, control[getFuncName](control, arg)))
            end
            if setFuncName then
                function prop.set(data, control, value)
                    local values = {control[getFuncName](control, arg)}
                    values[idx] = value
                    control[setFuncName](control, arg, unpack(values))
                end
            end
        else
            function prop.get(data, control)
                return (select(idx, control[getFuncName](control)))
            end
            if setFuncName then
                function prop.set(data, control, value)
                    local values = {control[getFuncName](control)}
                    values[idx] = value
                    control[setFuncName](control, unpack(values))
                end
            end
        end
    end
    if prop.cls then
        if prop.cls == ColorProperty then
            prop.isColor = true
        end
    end
    return setmetatable(prop, prop.cls)
end
tbug.td = td


------------------------------------------------------------------------------------------------------------------------
--The setupFunctions of the rowtypes, e.g. td for normal row, and th for a header row
local rowTypeFuncs = {}
rowTypeFuncs["td"] = td
rowTypeFuncs["th"] = th



------------------------------------------------------------------------------------------------------------------------
--- Helper functions for the getter / setter of the row types
------------------------------------------------------------------------------------------------------------------------
local function getDataOfControl(control, entryName, entraNameAlt, skipAltOnControl)
    if control == nil or entryName == nil then return end
    local dataEntry = control.dataEntry
    if dataEntry and dataEntry.data then
        return dataEntry.data[entryName] or (entraNameAlt ~= nil and dataEntry.data[entraNameAlt])
    elseif dataEntry then
        return dataEntry[entryName] or (entraNameAlt ~= nil and dataEntry[entraNameAlt])
    else
        if not skipAltOnControl then
            if control[entryName] or (entraNameAlt ~= nil and control[entraNameAlt] ~= nil) then
                return control[entryName] or (entraNameAlt ~= nil and control[entraNameAlt])
            end
        else
            if control[entryName] then
                return control[entryName]
            end
        end
    end
    return
end



------------------------------------------------------------------------------------------------------------------------
--- Special lua object classes used at the row types (via "cls" identifier in the setup definition) to read or set some values
------------------------------------------------------------------------------------------------------------------------
ColorProperty.__index = ColorProperty


function ColorProperty.getRGBA(data, control)
    local getFuncName = data.prop.getFuncName
    if not getFuncName then
        getFuncName = "Get" .. data.prop.name:gsub("^%l", string.upper, 1)
        data.prop.getFuncName = getFuncName
    end

    local r, g, b, a = control[getFuncName](control)
    return r, g, b, a
end

function ColorProperty.getFormatedRGBA(data, r, g, b, a)
    local s = data.prop.scale or 255
    if a then
        return strformat("rgba(%.0f, %.0f, %.0f, %.2f)",
                         r * s, g * s, b * s, a * s / 255)
    else
        return strformat("rgb(%.0f, %.0f, %.0f)",
                         r * s, g * s, b * s)
    end
end

function ColorProperty.get(data, control)
    local r, g, b, a = ColorProperty.getRGBA(data, control)
    return ColorProperty.getFormatedRGBA(data, r, g, b, a)
end

function ColorProperty.set(data, control, value)
    local setFuncName = data.prop.setFuncName
    if not setFuncName then
        setFuncName = "Set" .. data.prop.name:gsub("^%l", string.upper, 1)
        data.prop.setFuncName = setFuncName
    end

    local color = tbug.parseColorDef(value)
    control[setFuncName](control, color:UnpackRGBA())
end

------------------------------------------------------------------------------------------------------------------------
AnchorAttribute.__index = AnchorAttribute


function AnchorAttribute.get(data, control)
    local anchorIndex = math.floor(data.prop.idx / 10)
    local valueIndex = data.prop.idx % 10
    return (select(valueIndex, control:GetAnchor(anchorIndex)))
end


function AnchorAttribute.set(data, control, value)
    local anchor0 = {control:GetAnchor(0)}
    local anchor1 = {control:GetAnchor(1)}

    if data.prop.idx < 10 then
        anchor0[data.prop.idx] = value
    else
        anchor1[data.prop.idx % 10] = value
    end

    control:ClearAnchors()

    if anchor0[2] ~= NONE then
        control:SetAnchor(unpack(anchor0, 2))
    end

    if anchor1[2] ~= NONE then
        control:SetAnchor(unpack(anchor1, 2))
    end
end

------------------------------------------------------------------------------------------------------------------------
DimensionConstraint.__index = DimensionConstraint


function DimensionConstraint.get(data, control)
    return (select(data.prop.idx, control:GetDimensionConstraints()))
end


function DimensionConstraint.set(data, control, value)
    local constraints = {control:GetDimensionConstraints()}
    constraints[data.prop.idx] = value
    control:SetDimensionConstraints(unpack(constraints))
end


------------------------------------------------------------------------------------------------------------------------
ResizeToFitPadding.__index = ResizeToFitPadding

function ResizeToFitPadding.get(data, control)
    return (select(data.prop.idx, control:GetResizeToFitPadding()))
end


function ResizeToFitPadding.set(data, control, value)
    local padding = {control:GetResizeToFitPadding()}
    padding[data.prop.idx] = value
    control:GetResizeToFitPadding(unpack(padding))
end
------------------------------------------------------------------------------------------------------------------------







------------------------------------------------------------------------------------------------------------------------
-- The normal (td) and header (th) row definitions for the insepctors
--> name: the shown string in the inspector
--> get/set the getter and setter functions used to show the value or set the value (on double click or change via editbox/slider)
--> checkFunc: function executed before the row is shown, returning a boolean. true: Show the row, false: hide the row
--> enum = the ENUeration table name where the possible enums can be found
--> cls = use that specil lua object class fo the propery. That classes need to be defined in the same file above -> See e.g. ResizeToFitPadding
--> idx = index to be used in combination with cls: The index defined at data.prop.idx which can be used to distinguish different rows using the same cls
---------------------------------------------------------------------------------------------------------------------------
local ALL_INSPECTED = 99999
local controlAndHeaderRowSetupData = {
    ["g_commonProperties_parentSubject"] = {
        [ALL_INSPECTED] = { --ALL_INSPECTED is used to make the parsing function recognize we got no CT_* or other dependency here -> Counts for all controls/inspected things
            { rowType = "td", name = customKey__Object, get = function(data, control)
                --"__Object"
                if control then
                    if control.GetName then
                        return control:GetName()
                    elseif control.name then
                        return control.name
                    else
                        return control
                    end
                end
                return
            end },
        }
    },

 ------------------------------------------------------------------------------------------------------------------------
    --Common properties used for all kind of controls or inspected values
    -->Shown at the top of the inspector
    ["g_commonProperties"] = {
        [ALL_INSPECTED] = { --ALL_INSPECTED is used to make the parsing function recognize we got no CT_* or other dependency here -> Counts for all controls/inspected things
            { rowType = "td", name = "__index",
              get     = function(data, control, inspectorBase)
                  return getmetatable(control).__index
              end,
            },
            { rowType = "td", name = "name", get = "GetName" },
            { rowType = "td", name = "type", get = "GetType", enum = "CT_names" },
            { rowType = "td", name = "parent", get = "GetParent", set = "SetParent", enum = "CT_names" },
            { rowType = "td", name = "owningWindow", get = "GetOwningWindow", enum = "CT_names" },
            { rowType = "td", name = "hidden", checkFunc = function(control) return isControl(control) end, get = "IsHidden", set = "SetHidden" },
            { rowType = "td", name = "outline", checkFunc = function(control) return ControlOutline ~= nil and isControl(control) end,
                get = function(data, control)
                    return ControlOutline_IsControlOutlined(control)
                end,
                set = function(data, control)
                    ControlOutline_ToggleOutline(control)
                end
            },
        },
    },

------------------------------------------------------------------------------------------------------------------------
    --Control properties, based on CT_* control types
    -->Shown below the top properties at the inspector
    ["g_controlPropListRow"] = {
        [CT_BUTTON] =
        {
            {rowType = "th",  name="Button properties"},
            {rowType = "td",  name="bagId",        get=function(data, control)
                    return control.bagId or control.bag
                end, enum = "Bags", --> see glookup.lua -> g_enums["Bags"]
            isSpecial = true},
            {rowType = "td",  name="slotIndex",    get=function(data, control)
                    return control.slotIndex
                end,
            isSpecial = true},
            {rowType = "td",  name="itemLink",    get=function(data, control)
                    return prepareItemLink(control, false)
                end,
            isSpecial = true},
            {rowType = "td",  name="itemLink plain text",    get=function(data, control)
                    return prepareItemLink(control, true)
                end,
            isSpecial = true},
        },
        [CT_CONTROL] =
        {
            {rowType="th", name="List row data properties"},
            {rowType="td",name="dataEntry.data",  get=function(data, control)
                local dataEntry = control.dataEntry
                return ((dataEntry and dataEntry.data) or dataEntry) or control
            end},
            {rowType="td",name="bagId",        get=function(data, control)
                local bagId = getDataOfControl(control, "bagId", "bag")
                if bagId == nil then bagId = getDataOfControl(control:GetParent(), "bagId", "bag", false) end
                return bagId
            end,
            enum = "Bags", --> see glookup.lua -> g_enums["Bags"]
            isSpecial = true},
            {rowType="td",name="slotIndex",    get=function(data, control)
                local slotIndex = getDataOfControl(control, "slotIndex", "slot")
                if slotIndex == nil then slotIndex = getDataOfControl(control:GetParent(), "slotIndex", "index", true) end
                return slotIndex
            end,
            isSpecial = true},
            {rowType="td",name="itemLink",    get=function(data, control)
                    return prepareItemLink(control, false)
                end,
            isSpecial = true},
            {rowType="td",name="itemLink plain text",    get=function(data, control)
                    return prepareItemLink(control, true)
                end,
            isSpecial = true},
        },
    },

------------------------------------------------------------------------------------------------------------------------
    --Common properties 2 used for all kind of controls or inspected values
    -->Shown further down at the inspector
    ["g_commonProperties2"] = {
        [ALL_INSPECTED] = { --ALL_INSPECTED is used to make the parsing function recognize we got no CT_* or other dependency here -> Counts for all controls/inspected things
            { rowType="th",   name="Anchor #0",        get="GetAnchor"},

            { rowType="td",   name ="point",              cls = AnchorAttribute, idx =2, enum ="AnchorPosition",  getOrig ="GetAnchor"},
            { rowType="td",   name ="relativeTo",         cls = AnchorAttribute, idx =3, enum = "CT_names",       getOrig ="GetAnchor"},
            { rowType="td",   name ="relativePoint",      cls = AnchorAttribute, idx =4, enum ="AnchorPosition",  getOrig ="GetAnchor"},
            { rowType="td",   name ="offsetX",            cls = AnchorAttribute, idx =5,                          getOrig ="GetAnchor"},
            { rowType="td",   name ="offsetY",            cls = AnchorAttribute, idx =6,                          getOrig ="GetAnchor"},
            { rowType="td",   name ="anchorConstrains",   cls = AnchorAttribute, idx =7, enum="AnchorConstrains", getOrig ="GetAnchor"},

            { rowType="th",   name="Anchor #1",        get="GetAnchor"},

            { rowType="td",   name ="point",              cls = AnchorAttribute, idx =12, enum ="AnchorPosition", getOrig ="GetAnchor"},
            { rowType="td",   name ="relativeTo",         cls = AnchorAttribute, idx =13, enum = "CT_names",      getOrig ="GetAnchor"},
            { rowType="td",   name ="relativePoint",      cls = AnchorAttribute, idx =14, enum ="AnchorPosition", getOrig ="GetAnchor"},
            { rowType="td",   name ="offsetX",            cls = AnchorAttribute, idx =15, getOrig ="GetAnchor"},
            { rowType="td",   name ="offsetY",            cls = AnchorAttribute, idx =16, getOrig ="GetAnchor"},
            { rowType="td",   name ="anchorConstrains",   cls = AnchorAttribute, idx =17, enum="AnchorConstrains", getOrig ="GetAnchor"},

            { rowType="th",   name="Dimensions",       get="GetDimensions"},

            { rowType="td",   name="width",            get="GetWidth", set="SetWidth"},
            { rowType="td",   name="height",           get="GetHeight", set="SetHeight"},
            { rowType="td",   name="desiredWidth",     get="GetDesiredWidth"},
            { rowType="td",   name="desiredHeight",    get="GetDesiredHeight"},
            { rowType="td",   name="DimensionConstraints", get="GetDimensionConstraints"},
            { rowType="td",   name="minWidth",         cls=DimensionConstraint, idx=1,                         getOrig="GetDimensionConstraints"},
            { rowType="td",   name="minHeight",        cls=DimensionConstraint, idx=2,                         getOrig="GetDimensionConstraints"},
            { rowType="td",   name="maxWidth",         cls=DimensionConstraint, idx=3,                         getOrig="GetDimensionConstraints"},
            { rowType="td",   name="maxHeight",        cls=DimensionConstraint, idx=4,                         getOrig="GetDimensionConstraints"},
        }
    },

    ------------------------------------------------------------------------------------------------------------------------
    --Special control properties, based on CT_* control types
    --> Shown below the Common properties 2 at the inspector
    ["g_specialProperties"] = {
        [CT_CONTROL] =
        {
            { rowType="th",    name="Control properties"},

            { rowType="td",    name="alpha",                get="GetAlpha", set="SetAlpha", sliderData={min=0, max=1, step=0.1}},
            { rowType="td",    name="clampedToScreen",      get="GetClampedToScreen", set="SetClampedToScreen"},
            { rowType="td",    name="controlAlpha",         get="GetControlAlpha"},
            { rowType="td",    name="controlHidden",        get="IsControlHidden"},
            { rowType="td",    name="excludeFromResizeToFitExtents",
                                            get="GetExcludeFromResizeToFitExtents",
                                            set="SetExcludeFromResizeToFitExtents"},
            { rowType="td",    name="hidden",               get="IsHidden", set="SetHidden"},
            { rowType="td",    name="inheritAlpha",         get="GetInheritsAlpha", set="SetInheritAlpha"},
            { rowType="td",    name="inheritScale",         get="GetInheritsScale", set="SetInheritScale"},
            { rowType="td",    name="keyboardEnabled",      get="IsKeyboardEnabled", set="SetKeyboardEnabled"},
            { rowType="td",    name="layer", enum="DL_names",     get="GetDrawLayer", set="SetDrawLayer"},
            { rowType="td",    name="level",                get="GetDrawLevel", set="SetDrawLevel", sliderData={min=0, max=100, step=1}},
            { rowType="td",    name="mouseEnabled",         get="IsMouseEnabled", set="SetMouseEnabled"},
            { rowType="td",    name="resizeToFitDescendents",
                                            get="GetResizeToFitDescendents",
                                            set="SetResizeToFitDescendents"},
            { rowType="td",    name="resizeToFitConstrains", enum="AnchorConstrains",
                                            get="GetResizeToFitConstrains",
                                            set="SetResizeToFitConstrains"},
            { rowType="td",    name="resizeToFitPaddingX",  cls=ResizeToFitPadding, idx=1,                    getOrig="GetResizeToFitPadding"},
            { rowType="td",    name="resizeToFitPaddingY",  cls=ResizeToFitPadding, idx=2,                    getOrig="GetResizeToFitPadding"},
            { rowType="td",    name="scale",                get="GetScale", set="SetScale", sliderData={min=0, max=5, step=0.1}},
            { rowType="td",    name="tier",  enum="DT_names",     get="GetDrawTier", set="SetDrawTier"},

            { rowType="th",    name="Children",             get="GetNumChildren", isChildrenHeader = true}, --name will be replaced at controlinspector.lua -> BuildMasterList
        },
        [CT_BACKDROP] =
        {
            { rowType="th",    name="Backdrop properties"},

            { rowType="td",    name="centerColor",          cls=ColorProperty,                  getOrig="GetColor"},
            { rowType="td",    name="pixelRoundingEnabled", get="IsPixelRoundingEnabled",
                                            set="SetPixelRoundingEnabled"},
        },
        [CT_BUTTON] =
        {
            { rowType="th",    name="Button properties"},

            { rowType="td",    name="label",                get="GetLabelControl", enum = "CT_names"},
            { rowType="td",    name="pixelRoundingEnabled", get="IsPixelRoundingEnabled",
                                            set="SetPixelRoundingEnabled"},
            { rowType="td",    name="state", enum="BSTATE", get="GetState", set="SetState"},
        },
        [CT_COLORSELECT] =
        {
            { rowType="th",    name="ColorSelect properties"},

            { rowType="td",    name="colorAsRGB",               cls=ColorProperty,              getOrig="GetColor"},
            { rowType="td",    name="colorWheelTexture",        get="GetColorWheelTextureControl",
                                                set="SetColorWheelTextureControl"},
            { rowType="td",    name="colorWheelThumbTexture",   get="GetColorWheelThumbTextureControl",
                                                set="SetColorWheelThumbTextureControl"},
            { rowType="td",    name="fullValuedColorAsRGB",     get=ColorProperty.get},
            { rowType="td",    name="value",                    get="GetValue", set="SetValue"},
        },
        [CT_COMPASS] =
        {
            { rowType="th",    name="Compass properties"},

            { rowType="td",    name="numCenterOveredPins",  get="GetNumCenterOveredPins"},
        },
        [CT_COOLDOWN] =
        {
            { rowType="th",    name="Cooldown properties"},

            { rowType="td",    name="duration",             get="GetDuration"},
            { rowType="td",    name="percentCompleteFixed", get="GetPercentCompleteFixed",
                                            set="SetPercentCompleteFixed"},
            { rowType="td",    name="timeLeft",             get="GetTimeLeft"},
        },
        [CT_EDITBOX] =
        {
            { rowType="th",    name="Edit properties"},

            { rowType="td",    name="copyEnabled",          get="GetCopyEnabled", set="SetCopyEnabled"},
            { rowType="td",    name="cursorPosition",       get="GetCursorPosition", set="SetCursorPosition"},
            { rowType="td",    name="editEnabled",          get="GetEditEnabled", set="SetEditEnabled"},
            { rowType="td",    name="fontHeight",           get="GetFontHeight"},
            { rowType="td",    name="multiLine",            get="IsMultiLine", set="SetMultiLine"},
            { rowType="td",    name="newLineEnabled",       get="GetNewLineEnabled", set="SetNewLineEnabled"},
            { rowType="td",    name="pasteEnabled",         get="GetPasteEnabled", set="SetPasteEnabled"},
            { rowType="td",    name="scrollExtents",        get="GetScrollExtents"},
            { rowType="td",    name="text",                 get="GetText", set="SetText"},
            { rowType="td",    name="topLineIndex",         get="GetTopLineIndex", set="SetTopLineIndex"},
        },
        [CT_LABEL] =
        {
            { rowType="th",    name="Label properties"},

            { rowType="td",    name="color",                cls=ColorProperty,              getOrig="GetColor"},
            { rowType="td",    name="didLineWrap",          get="DidLineWrap"},
            { rowType="td",    name="fontHeight",           get="GetFontHeight"},
            { rowType="td",    name="font",                 get="GetFont"},
			{ rowType="td",    name="fontFace",             get="GetFontFaceName"},
            { rowType="td",    name="fontSize",             get="GetFontSize"},
            { rowType="td",    name="fontStyle",            get="GetFontStyle"},
            { rowType="td",    name="horizontalAlignment",  get="GetHorizontalAlignment",
               enum="TEXT_ALIGN_horizontal",set="SetHorizontalAlignment"},
            { rowType="td",    name="modifyTextType",       get="GetModifyTextType",
               enum="MODIFY_TEXT_TYPE",     set="SetModifyTextType"},
            { rowType="td",    name="numLines",             get="GetNumLines"},
            { rowType="td",    name="styleColor",           cls=ColorProperty, scale=1,     getOrig="GetColor"},
            { rowType="td",    name="text",                 get="GetText", set="SetText"},
            { rowType="td",    name="textHeight",           get="GetTextHeight"},
            { rowType="td",    name="textWidth",            get="GetTextWidth"},
            { rowType="td",    name="verticalAlignment",    get="GetVerticalAlignment",
               enum="TEXT_ALIGN_vertical",  set="SetVerticalAlignment"},
            { rowType="td",    name="wasTruncated",         get="WasTruncated"},
        },
        [CT_LINE] =
        {
            { rowType="th",    name="Line properties"},

            { rowType="td",    name="blendMode",            get="GetBlendMode",
               enum="TEX_BLEND_MODE",       set="SetBlendMode"},
            { rowType="td",    name="color",                cls=ColorProperty,              getOrig="GetColor"},
            { rowType="td",    name="desaturation",         get="GetDesaturation",
                                            set="SetDesaturation"},
            { rowType="td",    name="pixelRoundingEnabled", get="IsPixelRoundingEnabled",
                                            set="SetPixelRoundingEnabled"},
            { rowType="td",    name="textureCoords.left",   gets="GetTextureCoords", idx=1,
                                            sets="SetTextureCoords"},
            { rowType="td",    name="textureCoords.right",  gets="GetTextureCoords", idx=2,
                                            sets="SetTextureCoords"},
            { rowType="td",    name="textureCoords.top",    gets="GetTextureCoords", idx=3,
                                            sets="SetTextureCoords"},
            { rowType="td",    name="textureCoords.bottom", gets="GetTextureCoords", idx=4,
                                            sets="SetTextureCoords"},
            { rowType="td",    name="textureFileName",      get="GetTextureFileName",
                                            set="SetTexture"},
            { rowType="td",    name="textureFileWidth",     gets="GetTextureFileDimensions", idx=1},
            { rowType="td",    name="textureFileHeight",    gets="GetTextureFileDimensions", idx=2},
            { rowType="td",    name="textureLoaded",        get="IsTextureLoaded"},
        },
        [CT_MAPDISPLAY] =
        {
            { rowType="th",    name="MapDisplay properties"},

            { rowType="td",    name="zoom",                 get="GetZoom", set="SetZoom"},
        },
        [CT_SCROLL] =
        {
            { rowType="th",    name="Scroll properties"},

            { rowType="td",    name="extents.horizontal",   gets="GetScrollExtents", idx=1},
            { rowType="td",    name="extents.vertical",     gets="GetScrollExtents", idx=2},
            { rowType="td",    name="offsets.horizontal",   gets="GetScrollOffsets", idx=1,
                                            set="SetHorizontalScroll"},
            { rowType="td",    name="offsets.vertical",     gets="GetScrollOffsets", idx=2,
                                            set="SetVerticalScroll"},
        },
        [CT_SLIDER] =
        {
            { rowType="th",    name="Slider properties"},

            { rowType="td",    name="allowDraggingFromThumb",   get="DoesAllowDraggingFromThumb",
                                                set="SetAllowDraggingFromThumb"},
            { rowType="td",    name="enabled",                  get="GetEnabled", set="SetEnabled"},
            { rowType="td",    name="orientation",              get="GetOrientation",
               enum="ORIENTATION",              set="SetOrientation"},
            { rowType="td",    name="thumbTexture",             get="GetThumbTextureControl"},
            { rowType="td",    name="valueMin",          idx=1, gets="GetMinMax", sets="SetMinMax"},
            { rowType="td",    name="value",                    get="GetValue", set="SetValue"},
            { rowType="td",    name="valueMax",          idx=2, gets="GetMinMax", sets="SetMinMax"},
            { rowType="td",    name="valueStep",                get="GetValueStep", set="SetValueStep"},
            { rowType="td",    name="thumbFlushWithExtents",    get="IsThumbFlushWithExtents",
                                                set="SetThumbFlushWithExtents"},
        },
        [CT_STATUSBAR] =
        {
            { rowType="th",    name="StatusBar properties"},

            { rowType="td",    name="valueMin",          idx=1, gets="GetMinMax", sets="SetMinMax"},
            { rowType="td",    name="value",                    get="GetValue", set="SetValue"},
            { rowType="td",    name="valueMax",          idx=2, gets="GetMinMax", sets="SetMinMax"},
        },
        [CT_TEXTBUFFER] =
        {
            { rowType="th",    name="TextBuffer properties"},

            { rowType="td",    name="drawLastEntryIfOutOfRoom", get="GetDrawLastEntryIfOutOfRoom",
                                                set="SetDrawLastEntryIfOutOfRoom"},
            { rowType="td",    name="linkEnabled",              get="GetLinkEnabled",
                                                set="SetLinkEnabled"},
            { rowType="td",    name="maxHistoryLines",          get="GetMaxHistoryLines",
                                                set="SetMaxHistoryLines"},
            { rowType="td",    name="numHistoryLines",          get="GetNumHistoryLines"},
            { rowType="td",    name="numVisibleLines",          get="GetNumVisibleLines"},
            { rowType="td",    name="scrollPosition",           get="GetScrollPosition",
                                                set="SetScrollPosition"},
            { rowType="td",    name="splitLongMessages",        get="IsSplittingLongMessages",
                                                set="SetSplitLongMessages"},
            { rowType="td",    name="timeBeforeLineFadeBegins", gets="GetLineFade", idx=1,
                                                sets="SetLineFade"},
            { rowType="td",    name="timeForLineToFade",        gets="GetLineFade", idx=2,
                                                sets="SetLineFade"},
        },
        [CT_TEXTURE] =
        {
            { rowType="th",    name="Texture properties"},

            { rowType="td",    name="addressMode",          get="GetAddressMode",
               enum="TEX_MODE",             set="SetAddressMode"},
            { rowType="td",    name="blendMode",            get="GetBlendMode",
               enum="TEX_BLEND_MODE",       set="SetBlendMode"},
            { rowType="td",    name="color",                cls=ColorProperty,              getOrig="GetColor"},
            { rowType="td",    name="desaturation",         get="GetDesaturation",
                                            set="SetDesaturation"},
            { rowType="td",    name="pixelRoundingEnabled", get="IsPixelRoundingEnabled",
                                            set="SetPixelRoundingEnabled"},
            { rowType="td",    name="resizeToFitFile",      get="GetResizeToFitFile",
                                            set="SetResizeToFitFile"},
            { rowType="td",    name="textureCoords.left",   gets="GetTextureCoords", idx=1,
                                            sets="SetTextureCoords"},
            { rowType="td",    name="textureCoords.right",  gets="GetTextureCoords", idx=2,
                                            sets="SetTextureCoords"},
            { rowType="td",    name="textureCoords.top",    gets="GetTextureCoords", idx=3,
                                            sets="SetTextureCoords"},
            { rowType="td",    name="textureCoords.bottom", gets="GetTextureCoords", idx=4,
                                            sets="SetTextureCoords"},
            { rowType="td",    name="textureFileName",      get="GetTextureFileName",
                                            set="SetTexture"},
            { rowType="td",    name="textureFileWidth",     gets="GetTextureFileDimensions", idx=1},
            { rowType="td",    name="textureFileHeight",    gets="GetTextureFileDimensions", idx=2},
            { rowType="td",    name="textureLoaded",        get="IsTextureLoaded"},

            { rowType="td",    name="VERTEX_POINTS_BOTTOMLEFT.U",   gets="GetVertexUV", idx=1,
               arg=VERTEX_POINTS_BOTTOMLEFT,        sets="SetVertexUV"},
            { rowType="td",    name="VERTEX_POINTS_BOTTOMLEFT.V",   gets="GetVertexUV", idx=2,
               arg=VERTEX_POINTS_BOTTOMLEFT,        sets="SetVertexUV"},
            { rowType="td",    name="VERTEX_POINTS_BOTTOMRIGHT.U",  gets="GetVertexUV", idx=1,
               arg=VERTEX_POINTS_BOTTOMRIGHT,       sets="SetVertexUV"},
            { rowType="td",    name="VERTEX_POINTS_BOTTOMRIGHT.V",  gets="GetVertexUV", idx=2,
               arg=VERTEX_POINTS_BOTTOMRIGHT,       sets="SetVertexUV"},
            { rowType="td",    name="VERTEX_POINTS_TOPLEFT.U",      gets="GetVertexUV", idx=1,
               arg=VERTEX_POINTS_TOPLEFT,           sets="SetVertexUV"},
            { rowType="td",    name="VERTEX_POINTS_TOPLEFT.V",      gets="GetVertexUV", idx=2,
               arg=VERTEX_POINTS_TOPLEFT,           sets="SetVertexUV"},
            { rowType="td",    name="VERTEX_POINTS_TOPRIGHT.U",     gets="GetVertexUV", idx=1,
               arg=VERTEX_POINTS_TOPRIGHT,          sets="SetVertexUV"},
            { rowType="td",    name="VERTEX_POINTS_TOPRIGHT.V",     gets="GetVertexUV", idx=2,
               arg=VERTEX_POINTS_TOPRIGHT,          sets="SetVertexUV"},
        },
        [CT_TEXTURECOMPOSITE] =
        {
            { rowType="th",    name="TextureComposite properties"},

            { rowType="td",    name="blendMode",            get="GetBlendMode",
               enum="TEX_BLEND_MODE",       set="SetBlendMode"},
            { rowType="td",    name="desaturation",         get="GetDesaturation",
                                            set="SetDesaturation"},
            { rowType="td",    name="numSurfaces",          get="GetNumSurfaces"},
            { rowType="td",    name="pixelRoundingEnabled", get="IsPixelRoundingEnabled",
                                            set="SetPixelRoundingEnabled"},
            { rowType="td",    name="textureFileName",      get="GetTextureFileName",
                                            set="SetTexture"},
            { rowType="td",    name="textureFileWidth",     gets="GetTextureFileDimensions", idx=1},
            { rowType="td",    name="textureFileHeight",    gets="GetTextureFileDimensions", idx=2},
            { rowType="td",    name="textureLoaded",        get="IsTextureLoaded"},
        },
        [CT_TOOLTIP] =
        {
            { rowType="th",    name="Tooltip properties"},

            { rowType="td",    name="owner",                get="GetOwner", enum = "CT_names"},
        },
        [CT_TOPLEVELCONTROL] =
        {
            { rowType="th",    name="TopLevelControl properties"},

            { rowType="td",    name="allowBringToTop",      get="AllowBringToTop",
                                            set="SetAllowBringToTop", enum = "CT_names"},
        },
    },



    --> At the bottom of the inspector the "Children" properties are shown
    --> See special properties g_specialProperties -> name "Children"
}

------------------------------------------------------------------------------------------------------------------------
--lua tables for the row types
tbug.controlInspectorDataTypes = {
    g_commonProperties_parentSubject =  {},
    g_commonProperties =                {},
    g_controlPropListRow =              {},
    g_commonProperties2 =               {},
    g_specialProperties =               {},
}
local tbug_controlInspectorDataTypes = tbug.controlInspectorDataTypes


--Parser function to build the row table entries based on table controlAndHeaderRowSetupData
local function parseRowSetupAndPreparePropertyTables()
    for rowSetupPropertiesType, rowSetupPropertiesTypeData in pairs(controlAndHeaderRowSetupData) do
        for controlTypeOrInspectorKey, rowSetupProperties in pairs(rowSetupPropertiesTypeData) do
            local isValidForAllControlTypes = (controlTypeOrInspectorKey == ALL_INSPECTED and true) or false
            for _, rowSetupData in ipairs(rowSetupProperties) do
                local rowType = rowSetupData.rowType
                local rowName = rowSetupData.name
                if rowType ~= nil and rowName ~= nil then
                    local rowTypeFunc = rowTypeFuncs[rowType]
                    if rowTypeFunc ~= nil then
                        if isValidForAllControlTypes then
                           tbug_controlInspectorDataTypes[rowSetupPropertiesType][#tbug_controlInspectorDataTypes[rowSetupPropertiesType]+1] = rowTypeFunc(rowSetupData)
                        else
                            tbug_controlInspectorDataTypes[rowSetupPropertiesType][controlTypeOrInspectorKey] = tbug_controlInspectorDataTypes[rowSetupPropertiesType][controlTypeOrInspectorKey] or {}
                            tbug_controlInspectorDataTypes[rowSetupPropertiesType][controlTypeOrInspectorKey][#tbug_controlInspectorDataTypes[rowSetupPropertiesType][controlTypeOrInspectorKey]+1] = rowTypeFunc(rowSetupData)
                        end
                    end
                end
            end
        end
    end
end

--Set the noHeader flag to true: Will be set to false at th row setup function, and if it's false the next td entry will set the parentId = last headerId then
noHeader = true

------------------------------------------------------------------------------------------------------------------------
--Build the table entries into tbug.controlInspectorDataTypes.g_commonProperties_parentSubject, tbug.controlInspectorDataTypes.g_commonProperties, ...
parseRowSetupAndPreparePropertyTables()


