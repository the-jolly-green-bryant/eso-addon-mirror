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
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_HIGHLIGHT_QUEST_ITEMS
        = "เน้นไอเทมเควสต์ที่ตรงกัน",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_HIGHLIGHT_QUEST_ITEMS_TOOLTIP
        = "เปลี่ยนไอคอนเป็นสีเขียวเมื่อไอเทมตรงกับแท็กของเควสต์ที่กำลังทำอยู่",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_HIGHLIGHT_ON
        = "การเน้นไอเทมเควสต์: เปิด",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_HIGHLIGHT_OFF
        = "การเน้นไอเทมเควสต์: ปิด",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_AUTOSKIP_TIPBOARD
        = "ข้ามข้อเสนอกระดานเคล็ดลับอัตโนมัติ",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_AUTOSKIP_TIPBOARD_TOOLTIP
        = "ปิดข้อเสนอกระดานเคล็ดลับที่ไม่ใช่เคาน์เตสผู้โลภโดยอัตโนมัติ",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_AUTOSKIP_TIPBOARD_WARNING
        = "การดำเนินการนี้จะปิดบทสนทนาที่ไม่ใช่เคาน์เตสโดยอัตโนมัติ",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_AUTOSKIP_ON
        = "ข้ามกระดานเคล็ดลับอัตโนมัติ: เปิด",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_AUTOSKIP_OFF
        = "ข้ามกระดานเคล็ดลับอัตโนมัติ: ปิด",
}

for stringId, stringValue in pairs(strings) do
    SafeAddString(_G[stringId], stringValue, 2)
end
