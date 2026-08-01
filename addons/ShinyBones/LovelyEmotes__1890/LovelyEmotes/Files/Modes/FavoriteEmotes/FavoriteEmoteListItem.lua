LE_FavoriteEmoteListItem = ZO_Object:Subclass()

function LE_FavoriteEmoteListItem:New(index, control)
	local obj = ZO_Object.New(self)
	obj:Initialize(index, control)

	return obj
end

function LE_FavoriteEmoteListItem:Initialize(index, control)
	self.Index = index
	self.IsSelected = false

	self.BaseControl = control
	self.EmoteButton = control:GetNamedChild("EmoteButton")
	self.ConfigButton = control:GetNamedChild("ConfigButton")
end

function LE_FavoriteEmoteListItem:IsControlHidden()
	return self.BaseControl:IsControlHidden()
end

function LE_FavoriteEmoteListItem:SetHidden(isHidden)
	self.BaseControl:SetHidden(isHidden)
end

function LE_FavoriteEmoteListItem:Refresh()
	local targetEmote = LovelyEmotes.GetSavedEmote(self.Index)

	if not targetEmote then
		self.EmoteButton:SetEnabled(false)

		if (targetEmote == nil) then
			self.EmoteButton:SetText(LE_Const_EmoteUnknownDisplayName)
		else
			self.EmoteButton:SetText("")
		end

		return
	end

	if self.IsSelected == false then
		self.EmoteButton:SetNormalFontColor(LovelyEmotes.GetEmoteTextColor(targetEmote))
	end

	self.EmoteButton:SetEnabled(true)
	self.EmoteButton:SetText(LovelyEmotes.GetEmoteDisplayName(targetEmote))
end

function LE_FavoriteEmoteListItem:Select()
	if self.IsSelected == true then return end
	self.IsSelected = true

	self.EmoteButton:SetNormalFontColor(LOVELYEMOTES_COLOR_SELECTED_FAVORITE:UnpackRGBA())
	self.EmoteButton:SetDisabledFontColor(LOVELYEMOTES_COLOR_SELECTED_FAVORITE:UnpackRGBA())
end

function LE_FavoriteEmoteListItem:Deselect()
	if self.IsSelected == false then return end
	self.IsSelected = false

	self.EmoteButton:SetNormalFontColor(LovelyEmotes.GetEmoteTextColor(LovelyEmotes.GetSavedEmote(self.Index)))
	self.EmoteButton:SetDisabledFontColor(ZO_DISABLED_TEXT:UnpackRGBA())
end
