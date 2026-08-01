Breadcrumbs = Breadcrumbs or {}

function Breadcrumbs.InitialiseIcons()
    Breadcrumbs.marker1 = Breadcrumbs.window:CreateControl("BreadcrumbsMarker1", Breadcrumbs.win, CT_TEXTURE)
    Breadcrumbs.marker2 = Breadcrumbs.window:CreateControl("BreadcrumbsMarker2", Breadcrumbs.win, CT_TEXTURE)
    Breadcrumbs.marker1:SetTexture(Breadcrumbs.iconTextures[1])
    Breadcrumbs.marker2:SetTexture(Breadcrumbs.iconTextures[2])
    Breadcrumbs.marker1:SetHidden(true)
    Breadcrumbs.marker2:SetHidden(true)
end