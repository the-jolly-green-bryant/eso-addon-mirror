
QualityFurnitureCrafter = {}

QualityFurnitureCrafter.name = "QualityFurnitureCrafter"

function QualityFurnitureCrafter:GetTextColor()
	local r, g, b, a = self.normalColor:UnpackRGBA()
    if self.selected then
        return r, g, b, 0.4
    elseif self.mouseover then
        return r, g, b, 0.7
	end
    return r, g, b, a
end

function QualityFurnitureCrafter.RecipeSetupFunction(node, control, data, open, userRequested, enabled)
	QualityFurnitureCrafter.oldSetupFunction(node, control, data, open, userRequested, enabled)
	local r, g, b = GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, data.quality)
	ZO_SelectableLabel_SetNormalColor (control, ZO_ColorDef:New(r,g,b))
	if control.GetTextColor ~= QualityFurnitureCrafter.GetTextColor then
		control.GetTextColor = QualityFurnitureCrafter.GetTextColor
	end
	control:RefreshTextColor()
end

function QualityFurnitureCrafter:Initialize()
    EVENT_MANAGER:RegisterForEvent("QualityFurnitureCrafter", EVENT_CRAFTING_STATION_INTERACT, function(eventCode, craftingType) 
		if QualityFurnitureCrafter.oldSetupFunction == nil then
			QualityFurnitureCrafter.oldSetupFunction = PROVISIONER.recipeTree.templateInfo.ZO_ProvisionerNavigationEntry.setupFunction
			PROVISIONER.recipeTree.templateInfo.ZO_ProvisionerNavigationEntry.setupFunction = QualityFurnitureCrafter.RecipeSetupFunction
		end	
	end)
 end
 
function QualityFurnitureCrafter.OnAddOnLoaded(event, addonName)
  if addonName ~= QualityFurnitureCrafter.name then
	return
  end
    QualityFurnitureCrafter:Initialize()
end

 
EVENT_MANAGER:RegisterForEvent(QualityFurnitureCrafter.name, EVENT_ADD_ON_LOADED, QualityFurnitureCrafter.OnAddOnLoaded)

