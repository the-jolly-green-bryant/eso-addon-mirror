local CharacterListFragment = ZO_Object:Subclass()
SocialIndicators.CharacterListFragment = CharacterListFragment

function CharacterListFragment:New(db)
	local index = ZO_Object.New(self)
	index:Initialize(db)
	return index
end

function CharacterListFragment:Initialize(db)
	self.db = db
	self.control = SocialIndicatorsPlayerDetailScreenCharacterList
	self.fragment = ZO_FadeSceneFragment:New(self.control, nil, 0)

	local control = self.control
	control:GetNamedChild("Label"):SetText("Characters:")
	self.container = control:GetNamedChild("Container")
	local container = self.container
	local function EntryFactory(pool)
		local nameEntry = CreateControlFromVirtual("$(parent)Entry" .. pool:GetNextControlId(), container, "SocialIndicatorsPlayerDetailCharacterEntry")
		nameEntry:SetMouseEnabled(true)
		nameEntry:SetHandler("OnMouseUp", function(control, ...)
			PlaySound("Click")
			CALLBACK_MANAGER:FireCallbacks("SocialIndicatorsCharacterChanged", nameEntry.character)
		end)
		return nameEntry
	end

	local function ResetFunction(nameEntry)
		nameEntry:SetHidden(true)
		nameEntry.character = nil
	end

	self.pool = ZO_ObjectPool:New(EntryFactory, ResetFunction)
end

function CharacterListFragment:SetPlayer(player)
	self.currentPlayer = player
	self:Update()
end

function CharacterListFragment:Update()
	if(not self.fragment:IsShowing()) then return end
	local player = self.currentPlayer

	local pool = self.pool
	pool:ReleaseAllObjects()
	local characters = self.db:GetCharactersForPlayer(player.displayName) -- TODO: add convenience function to player
	local previous
	for i = 1, #characters do
		local character = characters[i]
		local nameEntry = pool:AcquireObject()
		nameEntry:SetHidden(false)
		nameEntry.character = character

		local classIcon = nameEntry.class
		classIcon:SetHidden(true)
		if(character:HasValidClass()) then
			classIcon:SetTexture(character:GetClassIcon())
			classIcon:SetColor(character:GetClassColor():UnpackRGBA())
			classIcon:SetHidden(false)
		end

		local avaRankIcon = nameEntry.avaRank
		avaRankIcon:SetHidden(true)
		avaRankIcon:SetTexture(character:HasValidAvARank() and character:GetAvARankIcon() or character:GetAllianceIcon())
		avaRankIcon:SetColor(character:GetAllianceColor():UnpackRGBA())
		avaRankIcon:SetHidden(false)

		local name = nameEntry.name
		name:SetText(string.format("%s %s", character:IsChampion() and zo_iconFormat(GetChampionPointsIcon(), 20, 20) or "", character.characterName))
		name:SetColor(character:GetGenderColor():UnpackRGBA())

		if(not previous) then
			nameEntry:SetAnchor(TOPLEFT, self.control, TOPLEFT, 0, 20)
		else
			nameEntry:SetAnchor(TOPLEFT, previous, BOTTOMLEFT, 0, 0)
		end
		previous = nameEntry
	end
end
