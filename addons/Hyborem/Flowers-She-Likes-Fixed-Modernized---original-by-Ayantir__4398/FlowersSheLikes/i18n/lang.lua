FlowersSheLikes = FlowersSheLikes or {}
local L = {
    en = {
        opt = "Options", fav = "Favorite color", favTT = "Color of favorite flowers",
        wn = "Liked color", wnTT = "Color of flowers you also like",
        l1 = "My favorites", l2 = "Why not", l3 = "Unimportant",
        flowers = {"Blessed Thistle", "Entoloma", "Bugloss", "Columbine", "Corn Flower", "Dragonthorn", "Emetic Russula", "Imp Stool", "Lady's Smock", "Luminous Russula", "Mountain Flower", "Namira's Rot", "Nirnroot", "Nightshade", "Stinkhorn", "Violet Coprinus", "White Cap", "Wormwood", "Water Hyacinth", "Crimson Nirnroot"}
    },
    de = {
        opt = "Optionen", fav = "Lieblingsfarbe", favTT = "Farbe der Lieblingsblumen",
        wn = "Bevorzugte Farbe", wnTT = "Farbe der Blumen, die du auch magst",
        l1 = "Meine Favoriten", l2 = "Warum nicht", l3 = "Unwichtig",
        flowers = {"Benediktenkraut", "Entoloma", "Ochsenzunge", "Akelei", "Kornblume", "Drachenorn", "Brechtäubling", "Koboldschemel", "Wiesenschaumkraut", "Leuchtender Täubling", "Bergblume", "Namiras Fäulnis", "Nirnwurz", "Nachtschatten", "Stinkhorn", "Violetter Risspilz", "Weißkappe", "Wermut", "Wasserhyazinthe", "Rote Nirnwurz"}
    },
    fr = {
        opt = "Options", fav = "Couleur préférée", favTT = "Couleur des fleurs favorites",
        wn = "Couleur appréciée", wnTT = "Couleur des fleurs que vous aimez aussi",
        l1 = "Mes favoris", l2 = "Pourquoi pas", l3 = "Sans importance",
        flowers = {"Chardon béni", "Entolome", "Buglosse", "Ancolie", "Bleuet", "Epine-de-dragon", "Russule émétique", "Pied-de-lutin", "Cardamine des prés", "Russule lumineuse", "Fleur de mountain", "Cœur-de-Namira", "Nirnroot", "Morelle", "Satyre puant", "Coprin violet", "Chapeau-blanc", "Absinthe", "Jacinthe d'eau", "Nirnroot écarlate"}
    },
    ru = {
        opt = "Настройки", fav = "Любимый цвет", favTT = "Цвет любимых цветов",
        wn = "Желаемый цвет", wnTT = "Цвет цветов, которые вам тоже нравятся",
        l1 = "Избранное", l2 = "Почему бы и нет", l3 = "Неважно",
        flowers = {"Благословенный чертополох", "Энтолома", "Воловик", "Водосбор", "Василек", "Драконий шип", "Рвотная сыроежка", "Бесовский гриб", "Сердечник", "Светящаяся сыроежка", "Горный цветок", "Гниль Намиры", "Корни Нирна", "Паслен", "Вонючая головка", "Фиолетовый копринус", "Белая шляпка", "Полынь", "Водный гиацинт", "Алый корень Нирна"}
    }
}
for k, v in pairs(L) do FlowersSheLikes[k] = v end