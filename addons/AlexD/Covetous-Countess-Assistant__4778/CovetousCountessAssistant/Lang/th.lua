local strings = {
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_TRACK_COUNTESS
        = "ติดตามเคาน์เตสผู้โลภ",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_TRACK_COUNTESS_TOOLTIP
        = "ทำเครื่องหมายสมบัติที่ใช้ได้สำหรับการล่าสมบัติของเคาน์เตสผู้โลภ",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_TRACK_CROW
        = "ติดตามเจ้าหน้าที่คลังบรรณาการ",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_TRACK_CROW_TOOLTIP
        = "ทำเครื่องหมายสมบัติที่ใช้ได้สำหรับการล่าสมบัติของเจ้าหน้าที่คลังบรรณาการ (กา)",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_SETTINGS
        = "การตั้งค่า",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_COUNTESS_ON
        = "ติดตามเคาน์เตสผู้โลภ: เปิด",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_COUNTESS_OFF
        = "ติดตามเคาน์เตสผู้โลภ: ปิด",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_CROW_ON
        = "ติดตามเจ้าหน้าที่คลังบรรณาการ: เปิด",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_CROW_OFF
        = "ติดตามเจ้าหน้าที่คลังบรรณาการ: ปิด",
}

for stringId, stringValue in pairs(strings) do
    SafeAddString(_G[stringId], stringValue, 2)
end
