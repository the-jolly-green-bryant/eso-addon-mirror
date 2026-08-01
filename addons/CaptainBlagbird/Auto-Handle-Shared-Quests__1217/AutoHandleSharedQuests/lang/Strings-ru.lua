--[[

Auto Handle Shared Quests
by CaptainBlagbird
https://github.com/CaptainBlagbird

--]]

-- Settings
local strings = {
    SI_AHSQ_ACTION_NONE = "Нет",
    SI_AHSQ_ACTION_ACCEPT = "Принять",
    SI_AHSQ_ACTION_DECLINE = "Отклонить",

    SI_AHSQ_DESC_AVA = "Действие в локации войны альянсов",
    SI_AHSQ_DESC_PVE = "Действие в PvE локациях",

    SI_AHSQ_TT_AVA = "Действие, когда игрок находится в локации войны альянсов",
    SI_AHSQ_TT_PVE = "Действие, когда игрок находится в PvE локациях",

    -- Other
    SI_AHSQ_MSG_ACCEPTED = "Задание принято: |cFFFFFF<<1>>|r",
    SI_AHSQ_MSG_DECLINED = "Задание отклонено: |cFFFFFF<<1>>|r",
}
for key, value in pairs(strings) do
   SafeAddString(key, value, 1)
end
