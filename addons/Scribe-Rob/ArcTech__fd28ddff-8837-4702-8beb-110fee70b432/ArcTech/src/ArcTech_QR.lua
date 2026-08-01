-- ArcTech_QR.lua
ArcTech = ArcTech

function CreateQRCode(parent)
    local size = ArcTech.QR.size
    local data = ArcTech.QR.data

    -- Most libs follow: CreateQRControl(name, parent, size, data)
    -- If your LibQRCode signature differs, adjust the first two args.
    local qr = LibQRCode:CreateQRControl("ArcTech_QR", parent, size, data)

    qr:ClearAnchors()
    qr:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, 0)

    return qr
end