LE_EmoteListMode = LE_ModeBase:New("EmoteList")

local function SetupEmoteList(self)
	if LovelyEmotes.EmoteList:CompareParent(self.ContentControl) == true then
		LovelyEmotes.EmoteList:ResetList()
	else
		LovelyEmotes.EmoteList:SetParent(self.ContentControl, 0, function(button, data)
			if not LovelyEmotes.IsEmoteSynchronizationActive() or button == 1 or data.ID < 0 then
				data.Play()
				return
			end

			LovelyEmotes.CreateSyncMessage(data)
		end)
	end
end

function LE_EmoteListMode:Activate()
	SetupEmoteList(self)

	LE_ModeBase.Activate(self)
end

function LE_EmoteListMode:Enable()
	LovelyEmotes.EmoteList:RefreshVisible()
end
