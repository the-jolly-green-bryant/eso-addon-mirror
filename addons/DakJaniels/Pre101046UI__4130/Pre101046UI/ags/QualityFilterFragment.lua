local AGS = AwesomeGuildStore
if not AGS then return end
local SimpleIconButton = AGS.class.SimpleIconButton
local QUALITY_BUTTON_ICON = "Pre101046UI/images/qualitybuttons/qualitybutton_%s.dds"
local windowManager = GetWindowManager()
function AGS.class.QualityFilterFragment:CreateButton(container, i, data)
    local control = windowManager:CreateControlFromVirtual("$(parent)Button", container, "AwesomeGuildStoreQualityButtonTemplate", i)
    local button = SimpleIconButton:New(control)
    button:SetSize(36)
    button:SetTooltipText(data.label)
    button:SetTextureTemplate(QUALITY_BUTTON_ICON)
    button.value = data.id
    control:GetNamedChild("Color"):SetColor(data.color:UnpackRGBA())
    return button
 end