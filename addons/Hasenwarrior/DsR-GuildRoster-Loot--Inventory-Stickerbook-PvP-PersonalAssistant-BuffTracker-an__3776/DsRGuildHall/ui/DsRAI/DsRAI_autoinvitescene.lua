DsRAutoINVUI = DsRAutoINVUI or {}

local DsRIcon = DsRglobals:HolidayIconLoad()

function DsRAutoINVUI:CreateScene()
    local data =
    {
        name = GetString(SI_DsRAI),
        categoryFragment = DsRAI_SMALL_GROUP_LIST_FRAGMENT,
        normalIcon = DsRIcon,
        pressedIcon = "/DsRGuildHall/misc/DsR_normal_activ.dds",
        mouseoverIcon = DsRIcon,
    }
    GROUP_MENU_KEYBOARD:AddCategory(data)
end
