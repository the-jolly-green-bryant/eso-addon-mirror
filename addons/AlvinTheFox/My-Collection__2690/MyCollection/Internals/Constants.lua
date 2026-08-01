local Internals = MyCollection.Internals
Internals.Constants = {}
local Constants = MyCollection.Internals.Constants

--https://wiki.esoui.com/Constant_Values
Constants.EquipTypes = {
    Armors = {
        Head = 1,
        Chest = 3,
        Shoulders = 4,
        Waist = 8,
        Legs = 9,
        Feet = 10,
        Hand = 13,
    },
    Jewelleries = {
        Neck = 2,
        Ring = 12,
    },
    Weapons = {
        OneHand = 5,
        OffHand = 7,
        TwoHand = 6,
        MainHand = 14,
    },
}

Constants.WeaponTypes = {
    Axe = 1,
    Hammer = 2,
    Sword = 3,
    TwoHandedSword = 4,
    TwoHandedAxe = 5,
    TwoHandedHammer = 6,
    Bow = 8,
    HealingStaff = 9,
    Dagger = 11,
    FireStaff = 12,
    FrostStaff = 13,
    LightningStaff = 15,
    Shield = 14,
}

Constants.ArmorTypes = {
    None = 0,
    Light = 1,
    Medium = 2,
    Heavy = 3,
}

Constants.TraitTypes = {
    None = 0,
    Armor = {
        Sturdy = 11,
        Impenetrable = 12,
        Reinforced = 13,
        WellFitted = 14,    
        Training = 15,
        Infused = 16,
        Invigorating = 17,
        --Prosperous = 17,
        --Exploration = 17,
        --Ornate = 19,
        Divines = 18,
        --Intricate = 20,
        Nirnhorned = 25,
    },
    Jewelleries = {  
        Healthy = 21,    
        Arcane = 22,
        Robust = 23,
        --Ornate = 24,
        --Intricate = 27,
        Swift = 28,
        Harmony = 29,
        Triune = 30,
        Bloodthirsty = 31,
        Protective = 32,
        Infused = 33,
    },
    Weapons = {
        Powered = 1,
        Charged = 2,
        Precise = 3,
        Infused = 4,
        Defending = 5,
        Training = 6,
        Sharpened = 7,
        Decisive = 8,
        --Weighted = 8,
        --Intricate = 9,
        --Ornate = 10,
        Nirnforned = 26,
    },
}

Constants.BagTypes = {
    Worn = 0,
    Backpack = 1,
    Bank = 2,
    GuildBank = 3,
    BuyBack = 4,
    CraftBag = 5,
    SubscriberBank = 6,
    HouseOne = 7,
    HouseTwo = 8,
    HouseThree = 9,
    HouseFour = 10,
    HouseFive = 11,
    HouseSix = 12,
    HouseSeven = 13,
    HouseEight = 14,
    HouseNine = 15,
    HouseTen = 16,
}