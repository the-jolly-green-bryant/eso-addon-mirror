--[[ 

function OSI.FixLibAddonMenu( LAM )
    -- FIXME:
    -- hack #1 to fix duplicate name
    -- error in case LibAddonMenu has
    -- been loaded 2 times. this happens
    -- when LibStub is not loaded as
    -- library but directly from within
    -- an old addon like OpenGlaza and
    -- HealersGroupFrame
    local fixOnMouseEnter = false
    if LibStub then
        local oldlam = LibStub.libs["LibAddonMenu-2.0"]
        if oldlam and oldlam ~= LAM then
            -- LibAddonMenu before r18 did not have the IconPicker control
            if oldlam.util and oldlam.util.GetIconPickerMenu ~= nil then
                LAM.util.GetIconPickerMenu = oldlam.util.GetIconPickerMenu
                fixOnMouseEnter            = true
            end

            -- FIXME:
            -- hack #2 to fix nil error
            -- create a dummy control for
            -- old and buggy LAM versions
            if not oldlam.applyButton then
                oldlam.applyButton = OSI.window:CreateControl( "OSIDummyCtrl", GuiRoot, CT_LABEL )
                oldlam.applyButton:SetDimensions( 0, 0 )
            end
        end
    end

    -- FIXME:
    -- hack #3 to fix icons from
    -- other iconpickers to appear
    -- below current selection
    local lipm        = LAM.util.GetIconPickerMenu()
    local lipmClear   = lipm.Clear
    local lipmAddIcon = lipm.AddIcon
    function lipm:Clear()
        lipmClear( self )
        local num = self.scroll:GetNumChildren()
        for i = 1, num do
            local ctrl  = self.scroll:GetChild( i )
            ctrl:SetHidden( true )
        end
    end
    function lipm:AddIcon( ... )
        lipmAddIcon( self, ... )
        self.icons[#self.icons]:SetHidden( false )
    end
    
    -- FIXME:
    -- hack #4 in case LibAddonMenu was
    -- loaded twice and iconpicker from
    -- old version is used, overload
    -- the hover function to avoid
    -- showing empty tooltips
    if fixOnMouseEnter then
        local lipmOnHover = lipm.OnMouseEnter
        function lipm:OnMouseEnter( icon )
            local tooltipText = icon.tooltip and LAM.util.GetStringFromValue( icon.tooltip )
            if tooltipText and tooltipText ~= "" then
                lipmOnHover( self, icon )
            end
        end
    end

    -- FIXME:
    -- hack #5 to change the color of
    -- the preview icon according to
    -- the users selection
    if LAMCreateControl and LAMCreateControl.iconpicker then
        local lccbak = LAMCreateControl.iconpicker
        LAMCreateControl.iconpicker = function( parent, iconpickerData, controlName )
            local control = lccbak( parent, iconpickerData, controlName )
            local role    = iconpickerData and iconpickerData.osirole or nil
            if role then
                local color = OSI.GetOption( role ).color
                local icon  = control.icon
                local scbak = icon.SetColor
                icon.SetColor = function( self, r, g, b, a, osi )
                    if type( control.data.disabled ) == "function" then
                        self:SetAlpha( control.data.disabled() and 0.3 or 1 )
                    end
                    if osi then
                        scbak( self, r, g, b, 1 )
                    end
                end
                icon:SetColor( color[1], color[2], color[3], 1, true )
                OSI.LAMControls[role] = control
            end
            return control
        end
    end
end

]]