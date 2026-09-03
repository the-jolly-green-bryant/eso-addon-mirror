-- ArcTech_QR.lua
ArcTech = ArcTech

function CreateQRCode(parent)
	local size = ArcTech.QR.size
	local data = ArcTech.QR.data

	local qr = LibQRCode.CreateQRControl(size, data)
	qr.SetParent(parent)
	qr.ClearAnchors()
	qr.SetAnchor(TOPLEFT, parent, TOPLEFT, 0, 0)

	return qr
end