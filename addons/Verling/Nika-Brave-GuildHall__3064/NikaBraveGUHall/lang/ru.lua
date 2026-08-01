-- Russian Version

local local_strings = {

        MH_text_0  = "Дома",
        MH_text_1  = "Дом по умолчанию",
        MH_text_01 = "Пивная Поцелуй Мары",
        MH_text_02 = "Румяный лев",
        MH_text_03 = "Комната в гостинице Эбонитовоая фляга",
        MH_text_06 = "Роскошная мансарда в Пламенной никс",
        MH_text_13 = "Уютный древесный дом",
        MH_text_25 = "Сиродильский дом в джунглях",
        MH_text_31 = "Загородный дом у молота смерти",
        MH_text_32 = "Мурнотская крепость",
        MH_text_42 = "Квартира в округе святого Делина",
        MH_text_47 = "Невероятное поместье в Хладной Гавани",
        MH_text_58 = "Мансарда в Золотом грифоне",
        MH_text_62 = "Большая вилла псиджиков",
        MH_text_63 = "Дом в зачарованном снежном шаре",
        MH_text_70 = "Чертоги Лунного Избранника",
        MH_text_80 = "Приют тихих вод",
        MH_text_90 = "Плато гибильного пепла",
        MH_text_95 = "Покои паломника",                           -- комната на высоком острове.


        MH_text_in  = "Внутрь",
        MH_text_out = "Вне",
	}
	
for stringId, stringValue in pairs(local_strings) do
	ZO_CreateStringId(stringId, stringValue)
        SafeAddVersion(stringId, 1)
end