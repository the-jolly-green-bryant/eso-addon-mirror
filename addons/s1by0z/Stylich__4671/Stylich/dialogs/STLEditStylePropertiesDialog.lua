--[[

Dialog to edit Style properties

--]]

-- addon namespace (single global table, defined in STLConstants.lua)
local STLESPD = Stylich.ESPD
local STLUI = Stylich.UI
local STLModel = Stylich.Model

function STLESPD:Commit(control)
    local currentId = STLUI.GetCurrentStyleSetId()
	local style = STLModel.GetStyleById(currentId)

	if not style then return end

    local ctrlContent = GetControl(control, "Content")
    local editStyleName = GetControl(ctrlContent, "StyleName")
    local editStyleSortKey = GetControl(ctrlContent, "StyleSortKey")
    local checkIgnoreTitle = GetControl(ctrlContent, "IgnoreTitleCheck")

	local oldName = style.Name
	
	style.Name = editStyleName:GetText()
    style.SortKey = editStyleSortKey:GetText()
    style.IgnoreTitle =  ZO_CheckButton_IsChecked(checkIgnoreTitle)
	
	if oldName ~= style.Name  then
		d("Style '"..oldName.."' renamed to '"..style.Name.."'")
	end

    STLUI.ShowStyleSetsTab()
end

function STLESPD:Setup(control)
    local currentId = STLUI.GetCurrentStyleSetId()
	local style = STLModel.GetStyleById(currentId)

	if not style then return end

    local ctrlContent = GetControl(control, "Content")
    local editStyleName = GetControl(ctrlContent, "StyleName")
    local editStyleSortKey = GetControl(ctrlContent, "StyleSortKey")
    local checkIgnoreTitle = GetControl(ctrlContent, "IgnoreTitleCheck")

	editStyleName:SetText(style.Name)
    editStyleSortKey:SetText(style.SortKey or '')
    
    if (style.IgnoreTitle) then
        ZO_CheckButton_SetChecked(checkIgnoreTitle)
    else
        ZO_CheckButton_SetUnchecked(checkIgnoreTitle)
    end    
end


function STLESPD.Initialize()
	local control = STLEditStylePropertiesDialog

    ZO_Dialogs_RegisterCustomDialog("STL_EDIT_STYLE_PROPERTIES_DIALOG", {
        customControl = control,
        title = { text = "Style Properties" },
		setup = function(self) STLESPD:Setup(control) end,
        buttons =
        {
            {
                control =   GetControl(control, "Accept"),
                text =      SI_DIALOG_ACCEPT,
                keybind =   "DIALOG_PRIMARY",
                callback =  function(dialog)
                                STLESPD:Commit(control)
                            end,
            },  
            {
                control =   GetControl(control, "Cancel"),
                text =      SI_DIALOG_CANCEL,
                keybind =   "DIALOG_NEGATIVE",
                callback =  function(dialog)
                            end,
            },
		
        },
    })
end

STLESPD.Initialize()