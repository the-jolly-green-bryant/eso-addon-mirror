-- ArcTech_Housing.lua
ArcTech = ArcTech

function JumpToHouseEntry(house)
	if not house or not house.id or house.id == 0 then return end

	local owner = house.owner
	local houseId = house.id

	local me = string.lower(GetDisplayName() or "")
	local ownerLower = owner and string.lower(owner) or ""

	if ownerLower == "" or ownerLower == me then
		RequestJumpToHouse(houseId)
	else
		JumpToSpecificHouse(owner, houseId, false)
	end
end

function HandleGuildhouseSlash(arg)
	arg = string.lower(tostring(arg or ""))

	if arg == "" or arg == "main" then JumpToHouseEntry(ArcTech.houses.main) return end
	if arg == "pvp" then self:JumpToHouseEntry(ArcTech.houses.pvp) return end
	if arg == "auction" then self:JumpToHouseEntry(ArcTech.houses.auction) return end

	d("|cffff00ArcTech|r usage: /arctech dhouse main/pvp/auction")
end