-- Solution_Controls.lua
--- Retrieves an existing control from the parent or creates a new control from a virtual control template.
--- If an existing control with the specified controlName is found, it is returned. Otherwise, a new control is created using the virtualControlName.
--- @param parent table The parent control to search for the control.
--- @param controlName string The name of the control to retrieve or create.
--- @param virtualControlName string The name of the virtual control template to use for creating a new control.
--- @return table The retrieved or created control.
function Solution_GetOrCreateControlFromVirtual(parent, controlName, virtualControlName)
    if not parent then return {} end

    local numChildren = parent:GetNumChildren()
    if numChildren > 0 then
        for i = 1, numChildren do
            local child = parent:GetChild(i)
            if child and child:GetName() == controlName then
                return child
            end
        end
    end

    return CreateControlFromVirtual(controlName, parent, virtualControlName)
end