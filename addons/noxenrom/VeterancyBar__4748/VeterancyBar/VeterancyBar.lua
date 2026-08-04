local ADDON_NAME = "VeterancyBar"

local VeterancyBar = {}
VeterancyBar.bar = nil
VeterancyBar.label = nil


------------------------------------------------------------
-- Get current veterancy data
------------------------------------------------------------

local function GetVeterancyProgress()

    local trackType = REWARD_TRACK_TYPE_AVA_VETERANCY

    local trackId = GetActiveReferenceTrackIdsForRewardTrackType(trackType)
    if not trackId then
        return 0, 100, 0
    end

    local trackIndex = GetReferenceTrackIndex(trackType, trackId)
    if not trackIndex then
        return 0, 100, 0
    end

    local _, rank, progress =
        GetInfoForRewardTrack(trackType, trackIndex)

    local rewardTrackId =
        GetRewardTrackIdFromReferenceTrackId(trackType, trackId)

    local total =
        GetTotalProgressAtRewardTrackTier(
            rewardTrackId,
            rank
        )

    if not total or total <= 0 then
        total = 100
    end

    return progress, total, rank
end


------------------------------------------------------------
-- Update bar
------------------------------------------------------------

function VeterancyBar:Update()

    local current, max, rank =
        GetVeterancyProgress()

    self.bar:SetMinMax(0, max)
    self.bar:SetValue(current)

    local percent = math.floor((current / max) * 100)

    self.label:SetText(
        string.format("Vet %d  %d%%", rank, percent)
    )
end


------------------------------------------------------------
-- Create UI
------------------------------------------------------------

function VeterancyBar:CreateUI()

    local window =
        WINDOW_MANAGER:CreateTopLevelWindow(
            "VeterancyBarWindow"
        )

    window:SetDimensions(260, 25)

    -- Left of compass
    window:SetAnchor(
        TOP,
        GuiRoot,
        TOP,
        -220,
        8
    )


    local background =
        WINDOW_MANAGER:CreateControl(
            nil,
            window,
            CT_BACKDROP
        )

    background:SetAnchorFill()
    background:SetCenterColor(
        1,
        1,
        1,
        1
    )


    local bar =
        WINDOW_MANAGER:CreateControl(
            nil,
            window,
            CT_STATUSBAR
        )

    bar:SetAnchorFill()

    bar:SetColor(
        0.094,
        1,
        0.976,
        1
    )

    self.bar = bar


    local label =
        WINDOW_MANAGER:CreateControl(
            nil,
            window,
            CT_LABEL
        )

    label:SetAnchor(
        CENTER,
        window,
        CENTER
    )

    label:SetFont(
        "ZoFontGameMedium"
    )

    label:SetHorizontalAlignment(
        TEXT_ALIGN_CENTER
    )

    label:SetVerticalAlignment(
        TEXT_ALIGN_CENTER
    )

    label:SetColor(
        0.05,
        0.05,
        0.05,
        1
    )

    self.label = label


    self.window = window
end


------------------------------------------------------------
-- Events
------------------------------------------------------------

local function OnLoaded(event, addon)

    if addon ~= ADDON_NAME then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(
        ADDON_NAME,
        EVENT_ADD_ON_LOADED
    )

    VeterancyBar:CreateUI()

    VeterancyBar:Update()


    EVENT_MANAGER:RegisterForEvent(
        ADDON_NAME,
        EVENT_REWARD_TRACK_PROGRESS_GAINED,
        function(_, trackType)

            if trackType ==
                REWARD_TRACK_TYPE_AVA_VETERANCY then

                VeterancyBar:Update()

            end
        end
    )


	EVENT_MANAGER:RegisterForEvent(
		ADDON_NAME,
		EVENT_PLAYER_ACTIVATED,
		function()

			VeterancyBar:Update()

			zo_callLater(function()
				VeterancyBar:Update()
			end, 500)

			zo_callLater(function()
				VeterancyBar:Update()
			end, 1500)

		end
	)
end


EVENT_MANAGER:RegisterForEvent(
    ADDON_NAME,
    EVENT_ADD_ON_LOADED,
    OnLoaded
)