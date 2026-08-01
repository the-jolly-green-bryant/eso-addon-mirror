AboveMe = AboveMe or {}
local AM = AboveMe
AM.ATLAS_TEXTURE = "AboveMe/assets/icon_atlas.dds"
AM.ICON_PACKS = {
    { id = "classic", name = "Classic" },
    { id = "emoji", name = "Emoji" },
    { id = "memes", name = "Meme Reactions" },
    { id = "gaming", name = "Gaming" },
    { id = "pixel", name = "8-Bit" },
    { id = "animals", name = "Animals" },
    { id = "food", name = "Food & Cheeky" },
    { id = "fantasy", name = "Fantasy & Edgy" },
    { id = "classes", name = "Classes" },
    { id = "roles", name = "Roles" },
}
AM.ICONS = {
    { id = 1, name = "None", pack = "classic", texture = nil },
    { id = 101, name = 'Crown', pack = "classic", texture = AM.ATLAS_TEXTURE, left = 0.002000, right = 0.123000, top = 0.002000, bottom = 0.123000 },
    { id = 102, name = 'Star', pack = "classic", texture = AM.ATLAS_TEXTURE, left = 0.127000, right = 0.248000, top = 0.002000, bottom = 0.123000 },
    { id = 103, name = 'Heart', pack = "classic", texture = AM.ATLAS_TEXTURE, left = 0.252000, right = 0.373000, top = 0.002000, bottom = 0.123000 },
    { id = 104, name = 'Diamond', pack = "classic", texture = AM.ATLAS_TEXTURE, left = 0.377000, right = 0.498000, top = 0.002000, bottom = 0.123000 },
    { id = 105, name = 'Shield', pack = "classic", texture = AM.ATLAS_TEXTURE, left = 0.502000, right = 0.623000, top = 0.002000, bottom = 0.123000 },
    { id = 106, name = 'Crossed Swords', pack = "classic", texture = AM.ATLAS_TEXTURE, left = 0.627000, right = 0.748000, top = 0.002000, bottom = 0.123000 },
    { id = 107, name = 'Skull', pack = "classic", texture = AM.ATLAS_TEXTURE, left = 0.752000, right = 0.873000, top = 0.002000, bottom = 0.123000 },
    { id = 108, name = 'Fire', pack = "classic", texture = AM.ATLAS_TEXTURE, left = 0.877000, right = 0.998000, top = 0.002000, bottom = 0.123000 },
    { id = 109, name = 'Laughing', pack = "emoji", texture = AM.ATLAS_TEXTURE, left = 0.002000, right = 0.123000, top = 0.127000, bottom = 0.248000 },
    { id = 110, name = 'Rolling Laugh', pack = "emoji", texture = AM.ATLAS_TEXTURE, left = 0.127000, right = 0.248000, top = 0.127000, bottom = 0.248000 },
    { id = 111, name = 'Heart Eyes', pack = "emoji", texture = AM.ATLAS_TEXTURE, left = 0.252000, right = 0.373000, top = 0.127000, bottom = 0.248000 },
    { id = 112, name = 'Cool', pack = "emoji", texture = AM.ATLAS_TEXTURE, left = 0.377000, right = 0.498000, top = 0.127000, bottom = 0.248000 },
    { id = 113, name = 'Wink', pack = "emoji", texture = AM.ATLAS_TEXTURE, left = 0.502000, right = 0.623000, top = 0.127000, bottom = 0.248000 },
    { id = 114, name = 'Thinking', pack = "emoji", texture = AM.ATLAS_TEXTURE, left = 0.627000, right = 0.748000, top = 0.127000, bottom = 0.248000 },
    { id = 115, name = 'Salute', pack = "emoji", texture = AM.ATLAS_TEXTURE, left = 0.752000, right = 0.873000, top = 0.127000, bottom = 0.248000 },
    { id = 116, name = 'Mind Blown', pack = "emoji", texture = AM.ATLAS_TEXTURE, left = 0.877000, right = 0.998000, top = 0.127000, bottom = 0.248000 },
    { id = 117, name = 'Dead', pack = "memes", texture = AM.ATLAS_TEXTURE, left = 0.002000, right = 0.123000, top = 0.252000, bottom = 0.373000 },
    { id = 118, name = 'Clown', pack = "memes", texture = AM.ATLAS_TEXTURE, left = 0.127000, right = 0.248000, top = 0.252000, bottom = 0.373000 },
    { id = 119, name = 'Moai', pack = "memes", texture = AM.ATLAS_TEXTURE, left = 0.252000, right = 0.373000, top = 0.252000, bottom = 0.373000 },
    { id = 120, name = 'Eyes', pack = "memes", texture = AM.ATLAS_TEXTURE, left = 0.377000, right = 0.498000, top = 0.252000, bottom = 0.373000 },
    { id = 121, name = 'Poop', pack = "memes", texture = AM.ATLAS_TEXTURE, left = 0.502000, right = 0.623000, top = 0.252000, bottom = 0.373000 },
    { id = 122, name = 'Goblin', pack = "memes", texture = AM.ATLAS_TEXTURE, left = 0.627000, right = 0.748000, top = 0.252000, bottom = 0.373000 },
    { id = 123, name = 'Alien', pack = "memes", texture = AM.ATLAS_TEXTURE, left = 0.752000, right = 0.873000, top = 0.252000, bottom = 0.373000 },
    { id = 124, name = 'Ghost', pack = "memes", texture = AM.ATLAS_TEXTURE, left = 0.877000, right = 0.998000, top = 0.252000, bottom = 0.373000 },
    { id = 125, name = 'Facepalm', pack = "memes", texture = AM.ATLAS_TEXTURE, left = 0.002000, right = 0.123000, top = 0.377000, bottom = 0.498000 },
    { id = 126, name = 'Shrug', pack = "memes", texture = AM.ATLAS_TEXTURE, left = 0.127000, right = 0.248000, top = 0.377000, bottom = 0.498000 },
    { id = 127, name = 'Raised Eyebrow', pack = "memes", texture = AM.ATLAS_TEXTURE, left = 0.252000, right = 0.373000, top = 0.377000, bottom = 0.498000 },
    { id = 128, name = 'Melting', pack = "memes", texture = AM.ATLAS_TEXTURE, left = 0.377000, right = 0.498000, top = 0.377000, bottom = 0.498000 },
    { id = 129, name = 'Controller', pack = "gaming", texture = AM.ATLAS_TEXTURE, left = 0.502000, right = 0.623000, top = 0.377000, bottom = 0.498000 },
    { id = 130, name = 'Joystick', pack = "gaming", texture = AM.ATLAS_TEXTURE, left = 0.627000, right = 0.748000, top = 0.377000, bottom = 0.498000 },
    { id = 131, name = 'Dice', pack = "gaming", texture = AM.ATLAS_TEXTURE, left = 0.752000, right = 0.873000, top = 0.377000, bottom = 0.498000 },
    { id = 132, name = 'Trophy', pack = "gaming", texture = AM.ATLAS_TEXTURE, left = 0.877000, right = 0.998000, top = 0.377000, bottom = 0.498000 },
    { id = 133, name = 'Target', pack = "gaming", texture = AM.ATLAS_TEXTURE, left = 0.002000, right = 0.123000, top = 0.502000, bottom = 0.623000 },
    { id = 134, name = 'Bomb', pack = "gaming", texture = AM.ATLAS_TEXTURE, left = 0.127000, right = 0.248000, top = 0.502000, bottom = 0.623000 },
    { id = 135, name = 'Puzzle', pack = "gaming", texture = AM.ATLAS_TEXTURE, left = 0.252000, right = 0.373000, top = 0.502000, bottom = 0.623000 },
    { id = 137, name = 'Pixel Heart', pack = "pixel", texture = AM.ATLAS_TEXTURE, left = 0.502000, right = 0.623000, top = 0.502000, bottom = 0.623000 },
    { id = 138, name = 'Pixel Sword', pack = "pixel", texture = AM.ATLAS_TEXTURE, left = 0.627000, right = 0.748000, top = 0.502000, bottom = 0.623000 },
    { id = 139, name = 'Pixel Ghost', pack = "pixel", texture = AM.ATLAS_TEXTURE, left = 0.752000, right = 0.873000, top = 0.502000, bottom = 0.623000 },
    { id = 140, name = 'Pixel Coin', pack = "pixel", texture = AM.ATLAS_TEXTURE, left = 0.877000, right = 0.998000, top = 0.502000, bottom = 0.623000 },
    { id = 141, name = 'Pixel Potion', pack = "pixel", texture = AM.ATLAS_TEXTURE, left = 0.002000, right = 0.123000, top = 0.627000, bottom = 0.748000 },
    { id = 142, name = 'Pixel Mushroom', pack = "pixel", texture = AM.ATLAS_TEXTURE, left = 0.127000, right = 0.248000, top = 0.627000, bottom = 0.748000 },
    { id = 143, name = 'Pixel Skull', pack = "pixel", texture = AM.ATLAS_TEXTURE, left = 0.252000, right = 0.373000, top = 0.627000, bottom = 0.748000 },
    { id = 144, name = 'Pixel Invader', pack = "pixel", texture = AM.ATLAS_TEXTURE, left = 0.377000, right = 0.498000, top = 0.627000, bottom = 0.748000 },
    { id = 145, name = 'Cat', pack = "animals", texture = AM.ATLAS_TEXTURE, left = 0.502000, right = 0.623000, top = 0.627000, bottom = 0.748000 },
    { id = 146, name = 'Dog', pack = "animals", texture = AM.ATLAS_TEXTURE, left = 0.627000, right = 0.748000, top = 0.627000, bottom = 0.748000 },
    { id = 147, name = 'Fox', pack = "animals", texture = AM.ATLAS_TEXTURE, left = 0.752000, right = 0.873000, top = 0.627000, bottom = 0.748000 },
    { id = 148, name = 'Wolf', pack = "animals", texture = AM.ATLAS_TEXTURE, left = 0.877000, right = 0.998000, top = 0.627000, bottom = 0.748000 },
    { id = 149, name = 'Frog', pack = "animals", texture = AM.ATLAS_TEXTURE, left = 0.002000, right = 0.123000, top = 0.752000, bottom = 0.873000 },
    { id = 150, name = 'Shark', pack = "animals", texture = AM.ATLAS_TEXTURE, left = 0.127000, right = 0.248000, top = 0.752000, bottom = 0.873000 },
    { id = 151, name = 'Owl', pack = "animals", texture = AM.ATLAS_TEXTURE, left = 0.252000, right = 0.373000, top = 0.752000, bottom = 0.873000 },
    { id = 152, name = 'Dragon', pack = "animals", texture = AM.ATLAS_TEXTURE, left = 0.377000, right = 0.498000, top = 0.752000, bottom = 0.873000 },
    { id = 153, name = 'Pizza', pack = "food", texture = AM.ATLAS_TEXTURE, left = 0.502000, right = 0.623000, top = 0.752000, bottom = 0.873000 },
    { id = 154, name = 'Burger', pack = "food", texture = AM.ATLAS_TEXTURE, left = 0.627000, right = 0.748000, top = 0.752000, bottom = 0.873000 },
    { id = 155, name = 'Donut', pack = "food", texture = AM.ATLAS_TEXTURE, left = 0.752000, right = 0.873000, top = 0.752000, bottom = 0.873000 },
    { id = 156, name = 'Banana', pack = "food", texture = AM.ATLAS_TEXTURE, left = 0.877000, right = 0.998000, top = 0.752000, bottom = 0.873000 },
    { id = 157, name = 'Peach', pack = "food", texture = AM.ATLAS_TEXTURE, left = 0.002000, right = 0.123000, top = 0.877000, bottom = 0.998000 },
    { id = 158, name = 'Eggplant', pack = "food", texture = AM.ATLAS_TEXTURE, left = 0.127000, right = 0.248000, top = 0.877000, bottom = 0.998000 },
    { id = 159, name = 'Wizard', pack = "fantasy", texture = AM.ATLAS_TEXTURE, left = 0.252000, right = 0.373000, top = 0.877000, bottom = 0.998000 },
    { id = 160, name = 'Ninja', pack = "fantasy", texture = AM.ATLAS_TEXTURE, left = 0.377000, right = 0.498000, top = 0.877000, bottom = 0.998000 },
    { id = 161, name = 'Vampire', pack = "fantasy", texture = AM.ATLAS_TEXTURE, left = 0.502000, right = 0.623000, top = 0.877000, bottom = 0.998000 },
    { id = 162, name = 'Unicorn', pack = "fantasy", texture = AM.ATLAS_TEXTURE, left = 0.627000, right = 0.748000, top = 0.877000, bottom = 0.998000 },
    { id = 163, name = 'Black Heart', pack = "fantasy", texture = AM.ATLAS_TEXTURE, left = 0.752000, right = 0.873000, top = 0.877000, bottom = 0.998000 },
    { id = 164, name = 'Devil', pack = "fantasy", texture = AM.ATLAS_TEXTURE, left = 0.877000, right = 0.998000, top = 0.877000, bottom = 0.998000 },
    { id = 201, name = 'Arcanist', pack = "classes", texture = "AboveMe/assets/class_roles_atlas.dds", left = 0.004000, right = 0.246000, top = 0.004000, bottom = 0.246000 },
    { id = 202, name = 'Dragonknight', pack = "classes", texture = "AboveMe/assets/class_roles_atlas.dds", left = 0.254000, right = 0.496000, top = 0.004000, bottom = 0.246000 },
    { id = 203, name = 'Nightblade', pack = "classes", texture = "AboveMe/assets/class_roles_atlas.dds", left = 0.504000, right = 0.746000, top = 0.004000, bottom = 0.246000 },
    { id = 204, name = 'Sorcerer', pack = "classes", texture = "AboveMe/assets/class_roles_atlas.dds", left = 0.754000, right = 0.996000, top = 0.004000, bottom = 0.246000 },
    { id = 205, name = 'Templar', pack = "classes", texture = "AboveMe/assets/class_roles_atlas.dds", left = 0.004000, right = 0.246000, top = 0.254000, bottom = 0.496000 },
    { id = 206, name = 'Warden', pack = "classes", texture = "AboveMe/assets/class_roles_atlas.dds", left = 0.254000, right = 0.496000, top = 0.254000, bottom = 0.496000 },
    { id = 207, name = 'Necromancer', pack = "classes", texture = "AboveMe/assets/class_roles_atlas.dds", left = 0.504000, right = 0.746000, top = 0.254000, bottom = 0.496000 },
    { id = 208, name = 'Vampire', pack = "classes", texture = "AboveMe/assets/class_roles_atlas.dds", left = 0.754000, right = 0.996000, top = 0.254000, bottom = 0.496000 },
    { id = 209, name = 'Werewolf', pack = "classes", texture = "AboveMe/assets/class_roles_atlas.dds", left = 0.004000, right = 0.246000, top = 0.504000, bottom = 0.746000 },
    { id = 210, name = 'Tank', pack = "roles", texture = "AboveMe/assets/class_roles_atlas.dds", left = 0.254000, right = 0.496000, top = 0.504000, bottom = 0.746000 },
    { id = 211, name = 'Healer', pack = "roles", texture = "AboveMe/assets/class_roles_atlas.dds", left = 0.504000, right = 0.746000, top = 0.504000, bottom = 0.746000 },
    { id = 212, name = 'Damage Dealer', pack = "roles", texture = "AboveMe/assets/class_roles_atlas.dds", left = 0.754000, right = 0.996000, top = 0.504000, bottom = 0.746000 },
}
AM.ICONS_BY_ID = {}
AM.PACKS_BY_ID = {}
for _, pack in ipairs(AM.ICON_PACKS) do AM.PACKS_BY_ID[pack.id] = pack end
for _, icon in ipairs(AM.ICONS) do AM.ICONS_BY_ID[icon.id] = icon end
function AM:GetIcon(id)
    return self.ICONS_BY_ID[tonumber(id) or 1] or self.ICONS_BY_ID[101]
end
function AM:GetIconsForPack(packId)
    local result = {}
    for _, icon in ipairs(self.ICONS) do
        if icon.texture and icon.pack == packId then result[#result + 1] = icon end
    end
    return result
end
function AM:IsFavorite(id)
    return self.saved and self.saved.favorites and self.saved.favorites[tostring(id)] == true
end
function AM:SetFavorite(id, value)
    if not self.saved then return end
    self.saved.favorites = self.saved.favorites or {}
    self.saved.favorites[tostring(id)] = value and true or nil
end
function AM:SelectIcon(id)
    local icon = self:GetIcon(id)
    self.saved.iconId = icon.id
    self.saved.selectedCategory = icon.pack
    self.saved.recentIcons = self.saved.recentIcons or {}
    for i = #self.saved.recentIcons, 1, -1 do if self.saved.recentIcons[i] == icon.id then table.remove(self.saved.recentIcons, i) end end
    table.insert(self.saved.recentIcons, 1, icon.id)
    while #self.saved.recentIcons > 12 do table.remove(self.saved.recentIcons) end
end
function AM:ChooseRandomFavorite()
    local ids = {}
    for id, enabled in pairs(self.saved.favorites or {}) do if enabled and self.ICONS_BY_ID[tonumber(id)] then ids[#ids + 1] = tonumber(id) end end
    if #ids > 0 then self:SelectIcon(ids[math.random(#ids)]) end
end
