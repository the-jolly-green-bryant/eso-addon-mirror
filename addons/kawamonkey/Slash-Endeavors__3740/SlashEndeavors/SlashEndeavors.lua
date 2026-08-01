SLASH_COMMANDS[GetString(SI_ENDEAVORSCOM)] = function ()
    for activityType = TIMED_ACTIVITY_TYPE_MIN_VALUE, TIMED_ACTIVITY_TYPE_MAX_VALUE do
        if TIMED_ACTIVITIES_MANAGER.availableActivityTypes[activityType] then
            local numActivitiesCompleted, activityLimit = TIMED_ACTIVITIES_MANAGER:GetTimedActivityTypeLimitInfo(activityType)

            CHAT_ROUTER:AddSystemMessage(
                zo_strformat(
                    "|c<<1>><<2>> [<<3>>/<<4>>]|r",
                    numActivitiesCompleted == activityLimit and "00ff00" or "ff0000",
                    GetString("SI_ENDEAVORS", activityType),
                    numActivitiesCompleted,
                    activityLimit
                )
            )

            local activityTypeFilters

            if activityType == TIMED_ACTIVITY_TYPE_DAILY then
                activityTypeFilters = { ZO_TimedActivityData.IsDailyActivity }
            elseif activityType == TIMED_ACTIVITY_TYPE_WEEKLY then
                activityTypeFilters = { ZO_TimedActivityData.IsWeeklyActivity }
            end

            for _, activityData in TIMED_ACTIVITIES_MANAGER:ActivitiesIterator(activityTypeFilters) do
                local maxProgress = activityData:GetMaxProgress()
                local maxProgressCommaDelimited = ZO_CommaDelimitNumber(maxProgress)

                CHAT_ROUTER:AddSystemMessage(
                    zo_strformat(
                        "|t14:14:<<1>>|t |cffffff<<2>> [<<3>>/<<4>>]|r",
                        "/esoui/art/buttons/gamepad/gp_menu_rightarrow.dds",
                        activityData:GetName():gsub(maxProgress, maxProgressCommaDelimited),
                        ZO_CommaDelimitNumber(activityData:GetProgress()),
                        maxProgressCommaDelimited
                    )
                )
            end
		end
	end
end