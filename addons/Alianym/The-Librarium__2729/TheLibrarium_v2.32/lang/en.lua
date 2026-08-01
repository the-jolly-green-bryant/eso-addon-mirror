if not Librarium then Librarium = {} end
if not LibrariumBooks then LibrariumBooks = {} end

Librarium.AddOnName = "TheLibrarium"

local addOnLongName = "The Librarium"
local worldIconDown =
    "EsoUI/Art/Progression/progression_indexIcon_world_down.dds"

local stringsEN = {
    ----
    -- ZOS-Based Strings
    ----
    LIBRARIUM_ADVENTURES_CLOSE_BOOK = zo_strformat("<<Z:1>>",
                                                   GetString(SI_DIALOG_CLOSE)),

    LIBRARIUM_EDITOR_UNDO_RECENT_CHANGES = GetString(SI_HOUSING_EDITOR_UNDO),
    LIBRARIUM_EDITOR_SEND_CUSTOM_BOOK = GetString(SI_SOCIAL_MENU_SEND_MAIL),

    LIBRARIUM_GOLD_ATTACHED = GetString(SI_MAIL_READ_SENT_GOLD_LABEL),
    LIBRARIUM_MAIL_ATTACHED = GetString(SI_MAIL_ATTACHMENTS_HEADER),
    LIBRARIUM_MAIL_RECEIVED = GetString(SI_MAIL_INBOX_RECEIVED_COLUMN),
    LIBRARIUM_COD_COST = GetString(SI_MAIL_READ_COD_LABEL),
    LIBRARIUM_MAIL_SENT = GetString(SI_GIFT_INVENTORY_SENT_GIFTS_HEADER),
    LIBRARIUM_MAIL_TO = GetString(SI_MAIL_SEND_TO_LABEL),

    LIBRARIUM_AUTHOR = GetString(SI_ADDON_MANAGER_AUTHOR),
    LIBRARIUM_LOCATIONS = GetString(SI_MAP_INFO_MODE_LOCATIONS),

    LIBRARIUM_OVERIVEW = GetString(SI_CUSTOMER_SERVICE_OVERVIEW),
    LIBRARIUM_OPTIONS = GetString(SI_GAMEPAD_OPTIONS_MENU),

    LIBRARIUM_MISC = GetString(SI_PLAYER_MENU_MISC),

    ----
    -- General Strings
    ----
    SI_BINDING_NAME_LIBRARIUM_OPEN_KEY = "Open the Librarium",
    SI_BINDING_NAME_LIBRARIUM_OPEN_COMPENDIUM_KEY = "Open the Librarium", -- Compatability
    SI_BINDING_NAME_LIBRARIUM_OPEN_GAMEPAD_KEY = "Open the Librarium – Gamepad",
    SI_BINDING_NAME_LIBRARIUM_SAVE_MAIL_KEY = "Save Mail",

    LIBRARIUM_CUSTOM_INTERACT_ACTION = "Librarium",
    LIBRARIUM_CUSTOM_INTERACT_BOOKSHELF = "Bookshelf",

    LIBRARIUM_LORE_LIBRARY_ANNOUNCE_BOOK_LEARNED = "Librarium Lorebook Learned",
    LIBRARIUM_MENU_JOURNAL = string.format("|t52:52:%s|t%s:", worldIconDown,
                                           addOnLongName),
    LIBRARIUM_WINDOW_TITLE_LORE_LIBRARY = string.format("|t52:52:%s|t%s:",
                                                        worldIconDown,
                                                        addOnLongName),

    LIBRARIUM_ADVENTURES_RESTART_BOOK = "<START AGAIN>",

    LIBRARIUM_MAIL_SEND_ANNOUNCE_ERROR = "Librarium Book Failed to Send, Try Again Later",

    LIBRARIUM_EDITOR_TOGGLE_MEDIUM = "Cycle Book Medium",
    LIBRARIUM_EDITOR_OPEN_BOOK_WRITER = "Open Book Writer",
    LIBRARIUM_EDITOR_OPEN_BOOK_EDITOR = "Edit Book",
    LIBRARIUM_EDITOR_DEFAULT_TITLE = "Enter Title",
    LIBRARIUM_EDITOR_DEFAULT_TEXT = "Start Writing",
    LIBRARIUM_EDITOR_UNDO_RECENT_CHANGES = "Undo",

    LIBRARIUM_EDITOR_SAVE_OR_OVERWRITE_NAME = "Save or Overwrite?",
    LIBRARIUM_EDITOR_OVERWRITE_CUSTOM_BOOK = "Overwrite Book",
    LIBRARIUM_EDITOR_SAVE_CUSTOM_BOOK = "Save Book",
    LIBRARIUM_EDITOR_DELETE_CUSTOM_BOOK = "Delete Book",
    LIBRARIUM_EDITOR_DELETE_NAME = "Confirm Deletion?",

    LIBRARIUM_EDITOR_ANNOUNCE_CUSTOM_BOOK_OVERWRITTEN = "Book Overwritten",
    LIBRARIUM_EDITOR_ANNOUNCE_CUSTOM_BOOK_REMOVED = "Book Removed",
    LIBRARIUM_EDITOR_ANNOUNCE_CUSTOM_BOOK_SAVED = "Book Saved",

    LIBRARIUM_MAIL_SAVE = "Save Mail",
    LIBRARIUM_EDITOR_MAIL_SUBJECT_PREFIX = "LIBR",
    LIBRARIUM_DUPLICATE_MAIL_SAVE = "Duplicate Mail Save",
    LIBRARIUM_HIRELING_MAIL_KEYWORD = "Raw ",
    LIBRARIUM_EDITOR_SEND_MAIL_NAME = "Send Mail to Alianym?",
    LIBRARIUM_EDITOR_ANNOUNCE_CUSTOM_MAIL_SAVED = "Mail Saved",
    LIBRARIUM_EDITOR_ANNOUNCE_SAVED_MAIL_REMOVED = "Saved Mail Removed",

    LIBRARIUM_DIALOGS_CUSTOM_BOOK_OVERWRITE = "Would you like to Overwrite the existing book?",
    LIBRARIUM_DIALOGS_CUSTOM_BOOK_DELETE = "Confirm deletion of the custom book? This will be permanent upon /reloadui or logout.",
    LIBRARIUM_DIALOGS_MAIL_SAVED_DELETE = "Confirm deletion of the saved mail? This will be permanent upon /reloadui or logout.",
    LIBRARIUM_DIALOGS_MAIL_SEND_REQ_DETAILS = "You need to input:\n\nAuthor: <How To Credit?> and;\nLocations: <Where In-Game?>\n\nYou must fill these out in the Settings Menu before you can send a book to Alianym.",
    LIBRARIUM_DIALOGS_MAIL_SEND_CONFIRM = "Confirm send of the custom book to Alianym?\nPlease wait a few moments to let the mails send.",
    LIBRARIUM_DIALOGS_MAIL_SEND_TEMP_WINDOW = "This window will close automatically once the entire book has been sent.",

    ----
    -- AddOn Settings Strings
    ----

    LIBRARIUM_SETTINGS_RELOADUI_WARNING = "Will automatically reload the UI.",

    LIBRARIUM_SETTINGS_DESCRIPTION_TEXT = "To set an <Interaction Keybind> go to CONTROLS Menu -> LibAlianym -> Interaction Key\nTo set a <Toggle Menu Keybind> go to CONTROLS Menu -> Alianym's Suite -> Open Librarium",
    LIBRARIUM_SETTINGS_ACCOUNT_WIDE = "Account-Wide",
    LIBRARIUM_SETTINGS_ACCOUNT_WIDE_TOOLTIP = "Select to have an Account-Wide Librarium.",
    LIBRARIUM_SETTINGS_RESET_BUTTON_NAME = "Reset the Librarium",
    LIBRARIUM_SETTINGS_RESET_BUTTON_TOOLTIP = "This will delete every user-created and discovered book in the Librarium",
    LIBRARIUM_SETTINGS_RESET_BUTTON_WARNING = "CAUTION: Are you certain you wish to reset the Librarium?",
    LIBRARIUM_SETTINGS_SAVING_MAIL_HEADER = "Saving Mail", -- Note for Translators (Heading, not Notification)
    LIBRARIUM_SETTINGS_TAMRIEL_DATE_NAME = "Add Tamriel Date to Saved Mail",
    LIBRARIUM_SETTINGS_TAMRIEL_DATE_TOOLTIP = "Select to add in-universe dates to any mail you save.",
    LIBRARIUM_SETTINGS_MAIL_ATTACHMENT_DATA_NAME = "Add Attachment Data to Saved Mail",
    LIBRARIUM_SETTINGS_MAIL_ATTACHMENT_DATA_TOOLTIP = "Select to append details about attachments to any mail you save.",
    LIBRARIUM_SETTINGS_MAIL_SAVE_SENT_NAME = "Save Sent/Outgoing Mail",
    LIBRARIUM_SETTINGS_MAIL_SAVE_SENT_TOOLTIP = "Select to save mail that you send.",
    LIBRARIUM_SETTINGS_SENDING_BOOKS_NAME = "Sending Books",
    LIBRARIUM_SETTINGS_AUTHOR_TOOLTIP = "How would you like to be attributed? Example: @Name (You can put 'anonymous')",
    LIBRARIUM_SETTINGS_LOCATIONS_TOOLTIP = "In what zones would you like your books to appear? Example: ",
    LIBRARIUM_SETTINGS_DISCORD_NAME = "Join My Discord!",
    LIBRARIUM_SETTINGS_DISCORD_TOOLTIP = "Join my Discord to chat about my released and in-progress AddOns, to help with translations, or to submit books outside the game!",

    ----
    -- Mail Date Strings
    ----
    LIBRARIUM_DATE_SUNDAY = "Sundas",
    LIBRARIUM_DATE_MONDAY = "Morndas",
    LIBRARIUM_DATE_TUESDAY = "Tirdas",
    LIBRARIUM_DATE_WEDNESDAY = "Middas",
    LIBRARIUM_DATE_THURSDAY = "Turdas",
    LIBRARIUM_DATE_FRIDAY = "Fredas",
    LIBRARIUM_DATE_LOREDAS = "Loredas",

    LIBRARIUM_MONTH_ONE = "Morning Star",
    LIBRARIUM_MONTH_TWO = "Sun's Dawn",
    LIBRARIUM_MONTH_THREE = "First Seed",
    LIBRARIUM_MONTH_FOUR = "Rain's Hand",
    LIBRARIUM_MONTH_FIVE = "Second Seed",
    LIBRARIUM_MONTH_SIX = "Midyear",
    LIBRARIUM_MONTH_SEVEN = "Sun's Height",
    LIBRARIUM_MONTH_EIGHT = "Last Seed",
    LIBRARIUM_MONTH_NINE = "Hearthfire",
    LIBRARIUM_MONTH_TEN = "Frostfall",
    LIBRARIUM_MONTH_ELEVEN = "Sun's Dusk",
    LIBRARIUM_MONTH_TWELVE = "Evening Star",

    LIBRARIUM_DATE_SECOND_ERA = "2E"
}

for id, stringVar in pairs(stringsEN) do
    ZO_CreateStringId(id, stringVar)
    SafeAddVersion(id, 1)
end

--
local a = LibrariumBooks;
a.LibCategories = {}
a.LibCategories[1] = "Reading Room"
a.LibCategories[2] = "Notice Board"
a.LibCategories[3] = "Personal Writings"
a.LibCategories[4] = "Adventures"
a.LibCategories[5] = "Mail Room"
a.LibCollections = {}
a.LibCollections[1] = {}
a.LibCollections[1][1] = {
    name = "Author/s Unknown",
    description = "Welcome to the reading room.",
    gamepadIcon = "/esoui/art/icons/justice_stolen_book_001.dds"
}
a.LibCollections[1][2] = {
    name = "Notes, Handbills, and Posters",
    description = "Welcome to the reading room.",
    gamepadIcon = "/esoui/art/icons/justice_stolen_book_001.dds"
}
a.LibCollections[1][3] = {
    name = "Clockwork Cogitations",
    description = "Welcome to the reading room.",
    gamepadIcon = "/esoui/art/icons/justice_stolen_book_001.dds"
}
a.LibCollections[1][4] = {
    name = "Linguistics and Poetry",
    description = "Welcome to the reading room.",
    gamepadIcon = "/esoui/art/icons/justice_stolen_book_001.dds"
}
a.LibCollections[1][5] = {
    name = "War and Strife",
    description = "Welcome to the reading room.",
    gamepadIcon = "/esoui/art/icons/justice_stolen_book_001.dds"
}
a.LibCollections[1][6] = {
    name = "Mystics and Magicks",
    description = "Welcome to the reading room.",
    gamepadIcon = "/esoui/art/icons/justice_stolen_book_001.dds"
}
a.LibCollections[1][7] = {
    name = "Tales of Romance",
    description = "Welcome to the reading room.",
    gamepadIcon = "/esoui/art/icons/justice_stolen_book_001.dds"
}
a.LibCollections[1][8] = {
    name = "Priests and Preachers",
    description = "Welcome to the reading room.",
    gamepadIcon = "/esoui/art/icons/justice_stolen_book_001.dds"
}
a.LibCollections[1][9] = {
    name = "Folktales and Portents",
    description = "Welcome to the reading room.",
    gamepadIcon = "/esoui/art/icons/justice_stolen_book_001.dds"
}
a.LibCollections[1][10] = {
    name = "Lost Empires",
    description = "Welcome to the reading room.",
    gamepadIcon = "/esoui/art/icons/justice_stolen_book_001.dds"
}
a.LibCollections[1][11] = {
    name = "Correspondence",
    description = "Welcome to the reading room.",
    gamepadIcon = "/esoui/art/icons/justice_stolen_book_001.dds"
}
a.LibCollections[2] = {}
a.LibCollections[2][1] = {
    name = "Notice Board",
    description = "Welcome to the Announcements.",
    gamepadIcon = "/esoui/art/icons/divineslore_book1.dds"
}
a.LibCollections[3] = {}
a.LibCollections[3][1] = {
    name = "Personal Thoughts",
    description = "Welcome to your library.",
    gamepadIcon = "/esoui/art/icons/quest_letter_002.dds"
}
a.LibCollections[4] = {}
a.LibCollections[4][1] = {
    name = "Dating",
    description = "Welcome to the CYOA room.",
    gamepadIcon = "/esoui/art/icons/lore_book1_detail2_color1.dds"
}
a.LibCollections[5] = {}
a.LibCollections[5][1] = {
    name = "Sent Mail",
    description = "Welcome to the Mail Room.",
    gamepadIcon = ""
}
a.LibCollections[5][2] = {
    name = "Received – Hireling",
    description = "Welcome to the Mail Room.",
    gamepadIcon = "/esoui/art/icons/quest_letter_002.dds"
}
a.LibCollections[5][3] = {
    name = "Received – Player",
    description = "Welcome to the Mail Room.",
    gamepadIcon = "/esoui/art/icons/quest_plans_001.dds"
}
a.LibCollections[5][4] = {
    name = "Received – System",
    description = "Welcome to the Mail Room.",
    gamepadIcon = "/esoui/art/icons/quest_scroll_001.dds"
}
local b = {
    [1] = {
        [1] = {
            [1] = {
                title = "The Lusty Imperial Councilor, Vol 1,",
                medium = BOOK_MEDIUM_SCROLL,
                oocAuthor = "Alianym"
            },
            [2] = {
                title = "Confessions: Memoirs of a Vampire",
                medium = BOOK_MEDIUM_YELLOWED_PAPER,
                oocAuthor = "(Discord) NihilAzari#8709"
            },
            [3] = {
                title = "Daedra Among Us, Part I",
                medium = BOOK_MEDIUM_LETTER,
                oocAuthor = "Alianym"
            },
            [4] = {
                title = "Battered Journal - Memories from the Rift",
                medium = BOOK_MEDIUM_YELLOWED_PAPER,
                oocAuthor = "(NA) Conservators of Xarxes"
            },
            [5] = {
                title = "Manuscript Found In A Tomb",
                medium = BOOK_MEDIUM_YELLOWED_PAPER,
                oocAuthor = "(NA) Maelen Moon-singer"
            },
            [6] = {
                title = "My First Kill",
                medium = BOOK_MEDIUM_YELLOWED_PAPER,
                oocAuthor = "(NA) Maelen Moon-singer"
            },
            [7] = {
                title = "The Call",
                medium = BOOK_MEDIUM_YELLOWED_PAPER,
                oocAuthor = "(NA) Maelen Moon-singer"
            },
            [8] = {
                title = "Both Sides of the Coin",
                medium = BOOK_MEDIUM_YELLOWED_PAPER,
                oocAuthor = "(NA) Maelen Moon-singer"
            },
            [9] = {
                title = "The Sparrow's Mountain",
                medium = BOOK_MEDIUM_LETTER,
                oocAuthor = "(NA) Maelen Moon-singer"
            }
        },
        [2] = {
            [1] = {
                title = "From Scribbles To Art",
                medium = BOOK_MEDIUM_YELLOWED_PAPER,
                oocAuthor = "Alianym"
            },
            [2] = {
                title = "ANTIQUARIAN SEEKING GUIDE",
                medium = BOOK_MEDIUM_LETTER,
                oocAuthor = "(NA) Astrande Direnni"
            },
            [3] = {
                title = "Society of Scholars",
                medium = BOOK_MEDIUM_NOTE,
                oocAuthor = "(NA) @Scholars_Guild"
            },
            [4] = {
                title = "Dark Elves: A degrading name",
                medium = BOOK_MEDIUM_YELLOWED_PAPER,
                oocAuthor = "(EU) Ephinyss Ashar"
            },
            [5] = {
                title = "A Daughter's Love",
                medium = BOOK_MEDIUM_YELLOWED_PAPER,
                oocAuthor = "(EU) Vilsiriel"
            },
            [6] = {
                title = "Piracy! It's A Crime",
                medium = BOOK_MEDIUM_SCROLL,
                oocAuthor = "<No Credit Requested>"
            },
            [7] = {
                title = "An Ethereal Notice",
                medium = BOOK_MEDIUM_LETTER,
                oocAuthor = "Mistress Laloux"
            },
            [8] = {
                title = "The Marchioness' Address",
                medium = BOOK_MEDIUM_YELLOWED_PAPER,
                oocAuthor = "(EU) @Vinovin"
            },
            [9] = {
                title = "A Sip of Nirni: The Teas of Ja’darri’s Cleft",
                medium = BOOK_MEDIUM_LETTER,
                oocAuthor = "(NA) @BaronSalmon"
            }
        },
        [3] = {
            [1] = {
                title = "Restricted Document Series: 5234 Item#: 1",
                medium = BOOK_MEDIUM_METAL_TABLET,
                oocAuthor = "<No Credit Requested>"
            },
            [2] = {
                title = "Restricted Document Series: 5234 Item#: 2",
                medium = BOOK_MEDIUM_METAL,
                oocAuthor = "<No Credit Requested>"
            },
            [3] = {
                title = "Trifurcated Venerations",
                medium = BOOK_MEDIUM_METAL_TABLET,
                oocAuthor = "(NA) @Elliebeing"
            },
            [4] = {
                title = "Extant Factota",
                medium = BOOK_MEDIUM_METAL_TABLET,
                oocAuthor = "(NA) @Elliebeing"
            },
            [5] = {
                title = "Security Report #3A-71-895",
                medium = BOOK_MEDIUM_METAL,
                oocAuthor = "(NA) @Elliebeing"
            },
            [6] = {
                title = "Mnemonic Architecture: Myth or Reflection?",
                medium = BOOK_MEDIUM_METAL,
                oocAuthor = "(NA) @Elliebeing"
            },
            [7] = {
                title = "Clockwork Cuisines",
                medium = BOOK_MEDIUM_METAL,
                oocAuthor = "(NA) @Elliebeing"
            }
        },
        [4] = {
            [1] = {
                title = "It's Pronounced 'Keh-rum'",
                medium = BOOK_MEDIUM_NOTE,
                oocAuthor = "Alianym"
            },
            [2] = {
                title = "On Gwylim University",
                medium = BOOK_MEDIUM_NOTE,
                oocAuthor = "Alianym"
            },
            [3] = {
                title = "One for the Vine",
                medium = BOOK_MEDIUM_ANIMAL_SKIN,
                oocAuthor = "(NA) @Dementia5"
            },
            [4] = {
                title = "The Promise of Grace",
                medium = BOOK_MEDIUM_YELLOWED_PAPER,
                oocAuthor = "(NA) @Dementia5"
            },
            [5] = {
                title = "Hand of Fate (a musing)",
                medium = BOOK_MEDIUM_ANIMAL_SKIN,
                oocAuthor = "(NA) @Dementia5"
            },
            [6] = {
                title = "Av Molag Anyammis, av Latta Magicka",
                medium = BOOK_MEDIUM_YELLOWED_PAPER,
                oocAuthor = "(NA) @Dementia5"
            },
            [7] = {
                title = "The Razor of Scrutiny",
                medium = BOOK_MEDIUM_YELLOWED_PAPER,
                oocAuthor = "(NA) @Dementia5"
            },
            [8] = {
                title = "The Quieting of the Undergrowth",
                medium = BOOK_MEDIUM_ANIMAL_SKIN,
                oocAuthor = "(NA) @Dementia5"
            },
            [9] = {
                title = "A Storm of Words",
                medium = BOOK_MEDIUM_ANIMAL_SKIN,
                oocAuthor = "(NA) @Dementia5"
            },
            [10] = {
                title = "The Necromancer",
                medium = BOOK_MEDIUM_ANIMAL_SKIN,
                oocAuthor = "(NA) Countess Erzsêbet"
            },
            [11] = {
                title = "The Fruit of Glamour",
                medium = BOOK_MEDIUM_ANIMAL_SKIN,
                oocAuthor = "(NA) Countess Erzsêbet"
            },
            [12] = {
                title = "Song from a Skyrim Inn",
                medium = BOOK_MEDIUM_YELLOWED_PAPER,
                oocAuthor = "(NA) Maelen Moon-singer"
            },
            [13] = {
                title = "The Tharn Song",
                medium = BOOK_MEDIUM_LETTER,
                oocAuthor = "(NA) Maelen Moon-singer"
            }
        },
        [5] = {
            [1] = {
                title = "Dominion Field Journal – Cyrodiil",
                medium = BOOK_MEDIUM_YELLOWED_PAPER,
                oocAuthor = "Alianym"
            },
            [2] = {
                title = "A Soldier's View, Part 1",
                medium = BOOK_MEDIUM_YELLOWED_PAPER,
                oocAuthor = "(NA) Sitemius, @OfTheEight"
            },
            [3] = {
                title = "A Soldier's View, Part 2",
                medium = BOOK_MEDIUM_YELLOWED_PAPER,
                oocAuthor = "(NA) Sitemius, @OfTheEight"
            },
            [4] = {
                title = "A Soldier's View, Part 3",
                medium = BOOK_MEDIUM_YELLOWED_PAPER,
                oocAuthor = "(NA) Sitemius, @OfTheEight"
            },
            [5] = {
                title = "A Soldier's View, Part 4",
                medium = BOOK_MEDIUM_YELLOWED_PAPER,
                oocAuthor = "(NA) Sitemius, @OfTheEight"
            },
            [6] = {
                title = "A Soldier's View, Part 5",
                medium = BOOK_MEDIUM_YELLOWED_PAPER,
                oocAuthor = "(NA) Sitemius, @OfTheEight"
            },
            [7] = {
                title = "Constitutional Rights and Duties of Every Imperial Citizen",
                medium = BOOK_MEDIUM_YELLOWED_PAPER,
                oocAuthor = "(NA) Heraclius"
            },
            [8] = {
                title = "Imperial Military Manual",
                medium = BOOK_MEDIUM_YELLOWED_PAPER,
                oocAuthor = "(NA) Heraclius"
            },
            [9] = {
                title = "On the Classification of Towns and Regions under Imperial Control",
                medium = BOOK_MEDIUM_YELLOWED_PAPER,
                oocAuthor = "(NA) Heraclius"
            }
        },
        [6] = {
            [1] = {
                title = "A Trick of the Mind",
                medium = BOOK_MEDIUM_ANIMAL_SKIN,
                oocAuthor = "(NA) @TheAllegorist"
            },
            [2] = {
                title = "The Power of Illusion, Vol 1",
                medium = BOOK_MEDIUM_ANIMAL_SKIN,
                oocAuthor = "(NA) @TheAllegorist"
            },
            [3] = {
                title = "The Power of Illusion, Vol 3",
                medium = BOOK_MEDIUM_ANIMAL_SKIN,
                oocAuthor = "(NA) @TheAllegorist"
            },
            [4] = {
                title = "The Power of Illusion, Vol 6",
                medium = BOOK_MEDIUM_ANIMAL_SKIN,
                oocAuthor = "(NA) @TheAllegorist"
            },
            [5] = {
                title = "Daedra in Form: Bound Armaments",
                medium = BOOK_MEDIUM_YELLOWED_PAPER,
                oocAuthor = "(EU) Morgan le Blanc"
            },
            [6] = {
                title = "Arcane Findings - Soul Energy",
                medium = BOOK_MEDIUM_ANIMAL_SKIN,
                oocAuthor = "(EU) Elarynia, Witch"
            },
            [7] = {
                title = "On Sono-Noematic Harmony – The Law of Similarity Re-examined",
                medium = BOOK_MEDIUM_YELLOWED_PAPER,
                oocAuthor = "(EU) @EmberRaven"
            },
            [8] = {
                title = "Soul Starved",
                medium = BOOK_MEDIUM_YELLOWED_PAPER,
                oocAuthor = "(NA) W"
            },
            [9] = {
                title = "Alexis' Shadowy Grimoire - Excerpts",
                medium = BOOK_MEDIUM_YELLOWED_PAPER,
                oocAuthor = "(EU) Alexis Z. Ashwing"
            },
            [10] = {
                title = "\"What's Scribing Good for, Anway?\"",
                medium = BOOK_MEDIUM_YELLOWED_PAPER,
                oocAuthor = "(EU) @Vinovin"
            },
            [11] = {
                title = "Crystal Mysteries",
                medium = BOOK_MEDIUM_YELLOWED_PAPER,
                oocAuthor = "(NA) Maelen Moon-singer"
            }
        },
        [7] = {
            [1] = {
                title = "The Fires of Passion, Ch. 1",
                medium = BOOK_MEDIUM_YELLOWED_PAPER,
                oocAuthor = "Alianym"
            },
            [2] = {
                title = "Sweet Chikyû",
                medium = BOOK_MEDIUM_LETTER,
                oocAuthor = "(EU) Fyroniel Birdsong"
            }
        },
        [8] = {
            [1] = {
                title = "The Principles of the Eight, Part 1",
                medium = BOOK_MEDIUM_YELLOWED_PAPER,
                oocAuthor = "(NA) Sitemius, @OfTheEight"
            },
            [2] = {
                title = "The Principles of the Eight, Part 2",
                medium = BOOK_MEDIUM_YELLOWED_PAPER,
                oocAuthor = "(NA) Sitemius, @OfTheEight"
            },
            [3] = {
                title = "WORMBOOK I",
                medium = BOOK_MEDIUM_ANIMAL_SKIN,
                oocAuthor = "(NA) @ErkorLad"
            },
            [4] = {
                title = "WORMBOOK II",
                medium = BOOK_MEDIUM_RUBBING_PAPER,
                oocAuthor = "(NA) @ErkorLad"
            },
            [5] = {
                title = "The Principles of the Eight, Part 3",
                medium = BOOK_MEDIUM_YELLOWED_PAPER,
                oocAuthor = "(NA) Sitemius, @OfTheEight"
            },
            [6] = {
                title = "The Principles of the Eight, Part 4",
                medium = BOOK_MEDIUM_YELLOWED_PAPER,
                oocAuthor = "(NA) Sitemius, @OfTheEight"
            },
            [7] = {
                title = "The True Role of the Daedric Princes",
                medium = BOOK_MEDIUM_YELLOWED_PAPER,
                oocAuthor = "(NA) Maelen Moon-singer"
            },
            [8] = {
                title = "The Divines and the Princes",
                medium = BOOK_MEDIUM_YELLOWED_PAPER,
                oocAuthor = "(NA) Maelen Moon-singer"
            },
            [9] = {
                title = "Not An End, But Change Unending",
                medium = BOOK_MEDIUM_YELLOWED_PAPER,
                oocAuthor = "(NA) Maelen Moon-singer"
            },
            [10] = {
                title = "Tears of the Twilight",
                medium = BOOK_MEDIUM_YELLOWED_PAPER,
                oocAuthor = "(NA) Maelen Moon-singer"
            }
        },
        [9] = {
            [1] = {
                title = "The Final Act",
                medium = BOOK_MEDIUM_YELLOWED_PAPER,
                oocAuthor = "(NA) Ace of Jokers"
            },
            [2] = {
                title = "The Shadow Beneath the Forest",
                medium = BOOK_MEDIUM_YELLOWED_PAPER,
                oocAuthor = "(EU) Gaerlyn Vernon"
            },
            [3] = {
                title = "The Dreaming Demon, Tome I",
                medium = BOOK_MEDIUM_YELLOWED_PAPER,
                oocAuthor = "(EU) Rebekah Meilan"
            },
            [4] = {
                title = "The Dreaming Demon, Tome II",
                medium = BOOK_MEDIUM_YELLOWED_PAPER,
                oocAuthor = "(EU) Rebekah Meilan"
            },
            [5] = {
                title = "The Unusual Skaa'fin, Part 1",
                medium = BOOK_MEDIUM_YELLOWED_PAPER,
                oocAuthor = "Alianym"
            },
            [6] = {
                title = "Abyss",
                medium = BOOK_MEDIUM_NOTE,
                oocAuthor = "Alianym"
            },
            [7] = {
                title = "A Vision, part 1",
                medium = BOOK_MEDIUM_YELLOWED_PAPER,
                oocAuthor = "(NA) Maelen Moon-singer"
            },
            [8] = {
                title = "A Vision, part 2",
                medium = BOOK_MEDIUM_YELLOWED_PAPER,
                oocAuthor = "(NA) Maelen Moon-singer"
            }
        },
        [10] = {
            [1] = {
                title = "Observations of the Ayleids - Architecture",
                medium = BOOK_MEDIUM_YELLOWED_PAPER,
                oocAuthor = "(EU) Caeyla Gentleflame"
            },
            [2] = {
                title = "On The Falmer: A fragment",
                medium = BOOK_MEDIUM_LETTER,
                oocAuthor = "(NA) Maelen Moon-singer"
            },
            [3] = {
                title = "The Orrey and the Observatory",
                medium = BOOK_MEDIUM_YELLOWED_PAPER,
                oocAuthor = "(NA) Maelen Moon-singer"
            },
            [4] = {
                title = "Account of an Ayleid Exile",
                medium = BOOK_MEDIUM_YELLOWED_PAPER,
                oocAuthor = "(NA) @Azerzia"
            }
        },
        [11] = {
            [1] = {
                title = "Letter to Terelien",
                medium = BOOK_MEDIUM_LETTER,
                oocAuthor = "(EU) Naering"
            },
            [2] = {
                title = "Song of the Strangler: A Spinner's Tale",
                medium = BOOK_MEDIUM_SCROLL,
                oocAuthor = "(EU) Terelien"
            },
            [3] = {
                title = "Confidential Memo",
                medium = BOOK_MEDIUM_SCROLL,
                oocAuthor = "(NA) Maelen Moon-singer"
            }
        }
    },
    [2] = {
        [1] = {
            [1] = {
                title = "A Note From The Custodian",
                medium = BOOK_MEDIUM_SCROLL,
                icon = 99,
                oocAuthor = "Alianym"
            },
            [2] = {
                title = "New Adventures!",
                medium = BOOK_MEDIUM_SCROLL,
                icon = 99,
                oocAuthor = "Alianym"
            }
        }
    },
    [3] = {
        [1] = {
            [1] = {
                title = "A Note From The Custodian",
                medium = BOOK_MEDIUM_SCROLL,
                icon = 99,
                oocAuthor = "Alianym"
            }
        }
    },
    [4] = {
        [1] = {
            [1] = {
                title = "Smolder Scrolls (Razum-dar)",
                medium = BOOK_MEDIUM_YELLOWED_PAPER,
                oocAuthor = "Zenimax Online Studios"
            },
            [2] = {
                title = "Smolder Scrolls (Naryu)",
                medium = BOOK_MEDIUM_YELLOWED_PAPER,
                oocAuthor = "Zenimax Online Studios"
            }
        }
    }
}
function a:GetShowTitle(c, d, e, f)
    local g = b[c][d][e].title or ""
    if g == "" and not f then
        return false
    else
        return true
    end
end
function a:GetDefaultBookIcon(h)
    local i = {
        [1] = "/esoui/art/icons/justice_stolen_book_001.dds",
        [2] = "/esoui/art/icons/lore_book5_detail2_color5.dds",
        [3] = "/esoui/art/icons/lore_book1_detail2_color1.dds",
        [4] = "/esoui/art/icons/quest_plans_001.dds",
        [5] = "/esoui/art/icons/quest_letter_002.dds",
        [6] = "/esoui/art/icons/quest_scroll_001.dds",
        [7] = "/esoui/art/icons/quest_stormhaven_item_003.dds",
        [8] = "/esoui/art/icons/quest_cwc_inc_bookplate001.dds",
        [9] = "/esoui/art/icons/quest_cwc_inc_scrollplate001.dds",
        [99] = "/esoui/art/icons/divineslore_book1.dds"
    }
    return i[h]
end
local j = string.format("%s", string.rep("\n", 9))
local k = string.format("%s%s", string.rep("\n", 11), string.rep(" ", 11))
local l = string.rep("\n", 3)
local m = "esoui/art/treasuremaps/treasuremapglenumbraprototype1.dds"
local n = "(My Grandchild's First Drawing)"
local function o(c, d, e)
    local p = {
        [1] = {
            [1] = {
                [1] = {
                    "[Scribe: Unknown]\n\nAct VI, Scene III, continued\n\nCouncilor Phallius' assistant knocks on the door of his chambers.\n\nAssistant: Councilor Phallius, a council meeting has been called. Will you be along shortly?\n\nCouncilor Phallius: Ah, my dear assistant. Unfortunately I am a little tied up at the moment. Can you stall them for me?\n\nAssistant: But Councilor, what will I tell them?\n\nCouncilor Phallius: Tell them I am meeting with a citizen. I will not leave her until we have reached a mutually satisfactory conclusion to our business.\n\nA thud emanates from behind the closed door.\n\nAssistant: Councilor Phallius, what was that noise?\n\nCouncilor Phallius: Ah, nothing to worry about my dear. \n\nThe Councilor speaks to someone else in the room.\n\nCouncilor Phallius: You are lucky I have a hard head my sweet, but perhaps that is why you have come today?\n\nAssistant: What was that, Councilor?\n\nCouncilor Phallius: Nothing at all. Tell the council I will be along shortly. Plenty of time, my dear. Plenty of time."
                },
                [2] = {
                    "by Anonymous\n\nI. Occasionally, I forget myself.\n\nI lose myself to life and all its wonders; to its experiences and its people who so skilfully make me forget myself as if I were a leaf lost to the winds. Who could say no to life? It is vivid and ever changing, its people breathing colours into your very soul. Everything comes alive like flowers in spring when you participate.\n\nIt is hard to look away once it captures you, and yet... I find myself in a position where it is necessary. I can’t risk enjoying life, not fully. I am not only responsible for myself, but for others as well. Those who get involved with me risk disappointment and suffering each moment they spend with me, yet how am I to continue living if not amongst them?\n\nLiving with vampirism is like walking a line. It is like trying to avoid the temptation of submerging yourself fully into a cold river on a hot summer day. You can get involved with mortals, but never fully. Not if you hold them dear, like I do. I wish them no suffering; I only wish to alleviate my own. How far can I allow myself to go to enjoy life? When is the right time to pull away? These are questions that have no answers; questions that I can’t bear to find answers to. And yet they swarm my mind and occupy it continuously without interruption.\n\nII. This is my curse, the life I have chosen.\n\nI wasn’t turned forcefully. I sought out a coven of vampires in search of somewhere to belong. I was scared of those who might do me harm, for they were many. Once I was turned, I found that the fear was no less; it was just different... but now I had potential, where previously I had none. Over time I learned to live with the fear and even overcame it.\n\nI learned that kinship, however important, cannot always be trusted. My only condition for the trust and loyalty I gave my sire was a promise of peace, but once my sire broke that promise, I found it necessary to leave our family and carve my own path.\n\nI fled to the deep woods where I meditated, trained and hunted. I learned to live with the curse in a way that allowed me to inflict as little pain upon others as possible. Although I hid from society during this time of deep reflection, I hunted others who shared my curse; those who had forgotten their sense of humanity and sought to destroy all good that is left in this world. I established the belief that although we are monsters, we were first mortals. As such, it is important not to forget ourselves, nor those we used to have kinship with. We do not need to be enemies, even though many might want to see it that way.\n\nI came to realise that in some cases it was naïve of me to offer some people the benefit of the doubt and a chance for redemption. Sometimes there is just no other option but the cruel dagger of death. Some of my kin do simply not wish to change their ways, or they have sunk so deep into their oceans of dark convictions that they are impossible to save; left to drown in their own hatred and desire for revenge. Because of this, I try not to view the world through a veil of guileless white, for no matter how dearly I wish for everyone to have something good in them, some people – some monsters – are simply beyond redemption.\n\nIII. The urge to feed.\n\nWhen I first turned, I was hit with the strongest feeling of hunger I had ever felt in my life. No matter how much blood I consumed, the hunger would not go away. It felt like standing at the top of a cliff, waiting for the next blow of wind to knock me off the edge. I could snap at any time. I learned to control my urges with practice and patience, but the hunger never went away. Unlike beasts who know when to stop, vampires have no limits when it comes to their appetite, as we were created in Molag Bal’s design to seek domination.\n\nIt greatly disturbs me that I cannot avoid forcing myself on others, despite having found ways not to spread my curse or kill. For that reason, I seek to avoid feeding on sentient beings as much as I can. By feeding from animals I can sustain myself, but it is no way to live – merely a way to survive.\n\nThere are many that would wish me harm because I am a hunter of the night, because I am cursed, because I violate innocents. If I am attacked by someone who wish to kill me, how do I proceed? I wish no harm upon others, even if they are monster hunters. For if they are monster hunters, they wish the same thing as I; a safer Tamriel from those who would wish harm upon others. I will be no better than the monsters they seek to hunt if I defend myself against them, so I have resorted to fleeing. Not because I can’t fight back - I am very capable of defending myself – but because I feel an affinity with them.\n\nIV. The only family I have is my kin.\n\nWhen it comes to mortals, there is one grand difference that sets us apart; the matter of immortality. Although I am a mer and was always prepared to outlive some of my friends and acquaintances, immortality does not even come close to being similar. My body does not age, yet my soul will live a thousand lifetimes. Although I may make friends and lovers, they will be gone in the blink of an eye. Empires will rise and fall like the seasons, yet I will still be here, standing tall like an enduring mountain.\n\nThe only relations I am able to keep are those of other immortals and vampires. These friendships may thrive for centuries, but so will hatred and bad blood. This is why I would discourage any vampire from seeking an immortal lover; lovers may quarrel and grow to hate each other, but friends find a reason to forgive. The only love a vampire may gain is that of a mortal, and yet it is a fleeting pleasure, not expected to last. I feel sorry for my kin and the mortals who know not what they get themselves into.\n\nI expect no mercy for my actions; I anticipate only retribution. Yet I hope to one day find a mortal willing to share an eternity with me, though I know it is a foolish and selfish wish.\n\nV. I keep secrets because secrets keep me alive.\n\nThere exist no honest vampires. If they existed, they would all be dead. To withhold information that is relevant or crucial to a person is the same as lying.\n\nDo I owe the truth? To anyone at all? I have often wondered if it makes me a liar not to tell the truth of my vampirism; I have often wondered if I owed my friends the truth, or whether the truth was reserved for me alone.\n\nDespite having agonised about it, I have yet to come to any conclusions. I can only tell that I have never been able to shake off the violent feeling of guilt that accompanies me everywhere I go when a person opens up to me. Like the sun revealed by a moving cloud, while I remain hidden in the shade.\n\nVI. I will remain as I am.\n\nThe thought of obtaining a cure has often occupied my mind. While I am still young, I can easily return to life as it was before I gained my curse. Would it not make sense to take the opportunity, if I could? I could have another chance at a normal life, without the deceit, the loneliness or the brutality of vampirism. But then, why did I turn in the first place?\n\nI have often found it necessary to reconsider why it was that I made the decision to turn. I keep telling myself that I did it because I wanted power to do good, but that is not true. Back then I simply wanted power for the sake of my own survival. Over the years, it has changed. I believe I can have a better impact on the world as I am now, rather than the way I was before.\n\nYou may judge me as you like. I just pray that when you look me in the eyes, you will see me as a person, and not merely as a monster."
                },
                [3] = {
                    "Are there daedra among us? It could happen. \n\nThey take many forms you know. From the erstwhile neighbour to the fanatic screeching about the end of the world. The Bad Man might be a daedra. Good men might be daedra too. Or even women.\n\nMer might suffer daedric infestations and we wouldn't even know it. Or would we? \n\nMaybe we wouldn't want to know. Maybe it would be better that way. What could we do even if we did know of a daedra among us? \n\nKill it? No, you can't kill a daedra. They just come back. Some would seek to profit off of them. Make a deal with these demons of the beyond. Yet they rarely end well for mere mortals.\n\nWhat then should our course of action be? Stick our heads in the sand and pretend they don't exist? Maybe that way we won't be driven mad by the truth. We can just go about our day to day and pretend the big bad world out there isn't out there, and maybe it'll all be alright."
                },
                [4] = {
                    "(Emblazoned on the first page, \"This journal was rescued from further indignity by the Conservators of Xarxes. The original translation was provided by the Resolutes of Stendarr, and now resides within our order. Our goal is to honor the memory, just as we were commanded. -the Conservatory\")\n\nTirdas -- ??\nThe Rift - little shrine\n\nThis one's head is still swimming. Is it Tirdas?  \nDoes the winter come this quickly in Skyrim?  The caravan is gone. Licks-the-Toes - gone. Stupid guar, that one just as likely to follow mammoth as he is to follow orders! Bah, ziss on him!\n\nMaybe Middas? How long did this one sleep? When this one awoke... she could not remember.\n\nThe little shrine seemed abandoned. Dark streaks like tears running down the facade. \n\nNot like this one remembers. Flickering blue lights with gleaming bright marble. Bright like sugar, so bright it was like a beacon shining from the cliff. Moonlight against rock, so beautiful in the summer night. \n\nBright and inviting, like home? Yes? \n\nYes.\n\n(Two crude drawings of a small shrine emerging from a cliff-face have been inserted here.)\n\nGah, it feels like stabbing when trying to remember. But, ... it was pretty, despite the stupid lizard's balking.\n\nGreen leaves,, bright flowers, and trees around the sugar-stone! The shrine was so bright, like the moons! \n\nAnd a scent... a smell this one had not sensed since Elsweyr. It seemed peaceful... \n\nNot like stupid walk. Constant stabbing in this one's poor feet!  This one needs new shoes!  BEFORE Winterhold!!!\n\nMaybe... lizard leather.\n\nMust find caravan. Ugh, stupid guar!\n\nMiddas - ??\nThe Rift maybe?\n\nThis one walked until the sun began to stalk over the trees. No sign of the caravan, or stinky guar. Azurah be praised, this one was able to find an inn along the way. Many tasty smells, and many rooms!\n\nThis one does not remember falling asleep, just the dreams. This one was standing underneath a pitch night sky, with no stars to help guide her. She could hear something; a chorus? The sound of many Khajiiti voices singing in unison.\n\nThis one held her breath and listened to the sound so sweet. A sliver of moon light appeared and it danced along... something. A tower? This one does not know. She began to walk towards it. \n\nThe song became louder, voices full of joy. But then, this one hears a tap. The voices begin to fade; tap. \n\ntap.\n\nBefore she could try to run- she awoke. Never has this one been so thankful. \n\nThe sun has gone down and the moons are out. If this one is going to catch the caravan, she needs to get back on the road."
                },
                [5] = {
                    "I found this in a tomb in the Reach, some years ago. There was no signature. The original was tattered, and it has long since crumbled. This is a copy that I made at the time.\n\nThe tomb had been looted. Nothing remained except a few bones. None of the local people knew who had been buried there.\n\nI was told later that a farmer has used the stone of the tomb to build pigpens. \n\nSo passes the glory of the world.\n\nM. \n\n*****\n\nIt's been six years now.\n\nI got into it almost by accident. Volunteered. Wanted to serve my lord, serve my people. Even thought I wanted to help the war end faster. Bring the killing to an end.\n\nThey found out that I never become excited, never panic no matter how the situation develops. That I always find a way out. That I always bring more of my soldiers home than any other officer. The soldiers saw it first. They competed to serve under me. They called me \"the lifesaver.\" \n\nThe lord and his court was next. They noticed me when I started to turn hopeless defences into deadly, successful attacks. When the enemy's most cunning tricks never worked on me. When finally, the mere news that I commanded a unit on that part of the front frightened them into retreating.\n\nI was happy at first. Someone needed me. Someone saw worth in me, a lot of worth. I was promoted over and over again. Never lost a battle, from the patrol-level engagements I began with, to the army I command now. The soldiers still love me. They say they're safer in the army than they would be at home crossing the street. But...\n\n\nAll the blood, the suffering. Not ours, but the enemy's. I am dripping with their blood. I can taste it in my mouth. The more successful I am, the more ambitious the court becomes. They don't want a compromise peace any more. They want it all, to win totally, to crush the enemy. Sometimes I think they want to exterminate the enemy, kill every last one of them. And I'm their instrument, their hammer.\n\nI am soaked in blood, enemy blood, but all blood is the same color in the end. I spend all my time thinking of new ways to kill... the enemy? Does it matter any more? I don't know. All I know is that they bleed and scream and die just like our troops would. And that the war would have ended long ago if I wasn't so good at what I do, so good at killing, so proud of the oceans of blood that I've spilled. My skill is keeping this war going, making our rulers aim for higher and higher goals.\n\nOr should that be lower and lower? Will they command me in the end to kill every single one of our enemies? The civilians too, old people, children? That's the way some of them are beginning to talk. Because they know they can do it. They know I can do it. And I probably would. I'd dream of their dead faces at night, but I probably would.\n\nSix years ago, when I joined, I just wanted to help, to get things over more quickly. But every time I gave them something, they wanted more. Like hungry animals. And I fed them.\n\nSix years ago, I began this hoping to do good. \n\nBut see what I've become.\n\nSee what I've become. \nThe angel of death."
                },
                [6] = {
                    "The first person that I killed was a bandit. Or a scout. I never did find out for sure. I was 14 years old at the time, and I killed him with a knife. Or, to be more precise, I wounded him with a knife and he fell to his death.\n\nHe died on one of the steep, rocky ridges that surrounded my home valley, Silverhoof Vale. I was one of the Silverhoof, but not one of them, really. They had taken me in when I was three years old, after my parents were murdered. I am a Breton, while they are Redguards. I don't know why the Khajiit merchant who rescued me took me to that place in particular, but it was a good choice. They raised me well, and I served them the best I could. When it came time for me to leave, at 16, the shamanesses wanted me to stay. I could have spent my life there, with the wild horses and the wide clear sky, the blue streams and the high slopes where the harpies built their nests. Perhaps I would have been happier there. But my feet were already set on a darker path, and I had to leave.\n\nIt was a summer day, and I was up on the slopes, high above the valley, within sight of the harpies and their nests. I wasn't in danger. Long ago, the Silverhoof and the harpies had worked out an unspoken pact, a symbiosis that benefited both sides. They hunted the predators who shared the mountain slopes with them, wildcats and bears, reducing the threat to our horses. We, for our part, left them in peace. We prevented anyone from crossing our territory to bother them, and when a horse or other large animal died, we left the carcass high on the slope for them to consume. They knew that if they tried to take one of our horses, let alone one of our people, we'd burn every one of their nests we could reach. Harpies aren't stupid. They lived their lives, and we lived ours, with a respectful distance between us, and both of us valued the modest but definite benefits we enjoyed from the presence of the other.\n\nI was up on the slopes that day \"walking the line,\" as we called it, looking for signs of any trouble or disturbance on the border of our territory, and also discreetly reminding the harpies of our presence. Reminding them how easily we could get at their eggs and chicks if they yielded to temptation. It didn't hurt to refresh their memories. From time to time, they'd fly through our valley, too. It was all part of the routine, each side reassuring itself that the other took it seriously.\n\nI'd made this trip many times before, and the harpies took little notice of my presence. The only real danger was the treacherous ground, but after many years, I had that all but memorized. That's what saved me when I saw the small, black-clad figure on the slope a little above me. He'd obviously not bothered the harpies, since they let him pass without attacking, but he was definitely hostile. Hostile enough to send an arrow in my direction the instant he spotted me. I flung myself on the ground, and slid over the edge of the cliff, trying to pretend he'd hit me. He very nearly had. I knew there was a rock ledge just below that I could land on safely, and another twenty feet below that, if I were desperate. For the time being, I crouched and waited, counting on curiosity to kill the cat, so to speak.\n\nHe didn't disappoint. Like all archers, he had difficulty leaving well enough alone. He had to come and see if he had hit me. I knew that if he yielded to that temptation, he'd have to work his way down the slope to the edge that I had \"fallen\" off, and that he wouldn't be able to do it without sounds and small stones announcing his presence.\n\nHe came just as I expected. Foolishly, he went to the very edge of the cliff, and looked over. I stabbed him in the leg, he bent reflexively, and I pulled him off balance, stabbed him again in the neck, and let his momentum carry him past me, over the edge again. He tried to grab at me, but I slapped his hands away, and let him fall. When I looked again, he was sprawled on the lower ledge, unmoving.\n\nI knew there was no safe way down to that lower ledge. But I could get to a rocky outcrop that was only three yards or so from its edge. I had no intention of risking myself to rescue him, of course, but I was curious. I didn't have someone try to kill me every day.\n\nHis face was toward me, but he didn't move. My knife was still in him, but driven far deeper than I remembered thrusting it. He was bleeding heavily. It occurred to me that he had probably struck the knife against a rock on the way down, and cut an artery. I was annoyed. It was a good knife, and getting it back would be a chore. Still, if I came back with a grappling hook and a rope after the harpies had reduced his body to a skeleton, I had a good chance of getting his bow at least, and a bow is more valuable than a knife.\n\nHe blinked. He was still alive. He must have known he would soon be dead, though. His lips moved, but no words came out. The expression on his face wasn't angry or frightened. It was puzzled. He knit his brows and frowned slightly, trying to figure out how he came to be on this sunny shelf of rock. His expression shifted to annoyance, as if he were thinking how infuriating it was to be bested by some wild-looking girl who had pulled a simple trick on him when he was being careless. I must have been a sight after sliding down a couple of dusty banks myself; we didn't exactly dress formally to scramble over rocks.\n\nAfter a minute or two, he closed his eyes. He didn't open them again.\n\nI felt his passing as a small cold shudder, a new sensation to me at the time, one that left me uneasy and depressed. Now, of course, it is all too familiar, and brings with it no special emotional burden.\n\nI watched for a few more minutes, squatting, and then stood up and turned to work my way down a safer part of the slope. A shadow passed over me: a watching harpy. It wouldn't wait long. The harpies knew that if it had been one of ours, I would have stayed by the body until others had come searching for us. He'd be stripped to the bones before I reached the camp. I didn't look back.\n\nTwo weeks later, I returned. Nothing was left but dry bones and a few shreds of his leather armor. My knife was missing; I suppose that it had fallen loose and been taken by one of the harpies as one more shiny object to adorn its nest. I pulled the skeleton over and got his bow and a pouch with a few gold pieces, which I gave to one of the shamanesses. There was nothing left to indicate who he had been, who he had served, or what he had been doing there.\n\nBringing the entire skeleton back was impractical, so I took only the skull with me when I left. Our people gave it a very simple service commending his spirit to the Herd Mother and buried it in an unmarked grave. I was glad they did. He'd tried to kill me, but I would never know why now, and better to give him the benefit of the doubt. Perhaps the Dark Brotherhood was hunting him; who can tell?\n\nYears later, when I came into my heritage of necromancy and the Dark Arts, I felt a presence once or twice that might have been him. It was always very shadowy, a mixture of querulous regret and a sort of phantom gratitude. So perhaps he realized his mistake before the end and was pleased at having been buried properly when I could have left his remains to the harpies and the sun. But he has not visited me for many years now, and so I hope he has found his peace on the Far Shores."
                },
                [7] = {
                    "Maelen sat silently for a long time, looking at her fingers. Then she said, to no one in particular, \"With me, it wasn't how I got books, but how books got me….\" \n\nShe paused. \"I was fourteen, a few months after my first kill, the first person whose life I had ever ended. The first of so many... I didn't remember my heritage at that time. The Silverhoof shamans had cast spells to take all of that away from me soon after I arrived, fearing the memories would drive me mad, but I suppose that death, even though the fellow I killed had tried to kill me first, made a little crack in the wall, and someone noticed.\n\n\"I was on watch near the entrance to the Vale, alone. There were supposed to be two adults there as well, but a party of outsiders had arrived to buy some horses, and both the adults had accompanied them back to our camp. It was unusual that both went, but I didn't mind being left alone for a while. It was a cool autumn day, the sky was clear, and I could keep myself busy doing nothing, a rare opportunity.\n\n\"About half an hour after they'd left, I saw another person walking slowly down the path. A very old man, he seemed to be, and alone. This was definitely odd. He didn't look like one of our customers, and we didn't get tourists; I'd often watched the path for the whole day with no one passing by. He had the appearance of a priest, but not any priest I could recognize from my limited experience. Human, and dressed all in dark grey.\n\n\"I approached and greeted him politely. He nodded an acknowledgement and asked, gesturing to the slopes behind me, 'There are the ruins of an old tower up the slope to the north, are there not?' \n\n\"I was surprised. I knew those slopes, I knew every tree and rock on all our borders; that's what had saved me from being killed by the last stranger I'd encountered. I knew there was no tower there. I shook my head, but he continued,\n\n'It is in ruins. But there are still a few books there that belong in my master's collection. Recover them and the reward will be great.'\n\n\"His tone was polite enough, but his assumption that I was there to serve him was irritating. He wasn't one of my tribe and I'd never seen him before; who did he think he was, sending me off to find his lost books? I replied, as politely as I could manage,\n\n\"I am of the Silverhoof. We worship the Horse Mother and sell horses to those who are worthy to receive them. Apart from that, we have no business with outsiders, and I am not your servant. I know nothing of this tower and nothing of these books.\"\n\n\"He smiled, a smile that made me feel cold and small and altogether insignificant. Then he said,'Those who serve my master remain often unaware of the honour of their employment. All those who are drawn to forbidden knowledge are bound to him. Not by his power, but by their own will and desires. A slave might rebel, but a fellow-traveler, never.'\n\n\"I couldn't think of a good reply. I didn't even understand half of what he had said; not at the time, anyway. I was puzzled. And frightened. No one had ever spoken to me this way before.\n\n\"We stood silently looking at each other. Then, he saluted me, said 'Until we meet again,' and turned to walk back along the path that led away from the Vale. I watched him until he disappeared around a curve.\n\n\"Seek forbidden knowledge? What had he meant by that?\n\n\"To make a long story short, I did find a book by accident, a couple of months later, in an old ruin revealed by a landslide after heavy rains. It was a very strange book; not thick, but written in a script I didn't recognize and... the words seemed somehow to move. I opened it, turned the pages, and couldn't read a word of it, but later, in my dreams, I could. It was a tome of Daedric magic: spells to bring sleep, pain... to bring death. I could read every word, and when I woke up, I remembered them all, though it would be years before I learned to cast them. I remembered them, and realized that I wanted to know more.\n\n\"I met the old man on the road again, several weeks later. When we came face to face, he just smiled. I gave him the book, and asked 'Why me? ' He replied, 'Your fate does not lie here. This is not what you were born for, my master says.'\n\n\"I replied, 'Who is your master?' and he smiled again. 'One who loves books, and has much to do with fates,' he said, turned, and walked off out of the Vale without another word. Two years later, I followed him, and here I am now.\""
                },
                [8] = {
                    "It was a goblin cave, all right. The smell was enough to certify that. Andrawe stepped carefully through the entrance and hesitated for his eyes to adjust to the gloom inside. It was a small natural chamber, the ceiling about twice his height, the floor littered with junk, and the light coming from a single torch on the far side.\n\nAnd, as Andrawe had hoped, there was a goblin on the other side, digging through a pile of junk. It stopped and looked at him, and froze.\n\nAndrawe held up both hands to show he wasn’t carrying a weapon, and walked slowly forward. Of course, he knew enough magic to fry the goblin with a fireball if it got out of line, but the goblin might not realize that.\n\nHe stopped walking about two-thirds of the way across the room, and said, slowly, “I would like to speak with your chief. I do not plan to harm any of you.”\n\nThe goblin scratched its head and said in a broken imitation of the common tongue, \n\n“Chief not like! Probably, not want! You go away now!”\n\n“It’s important, to both of us.”\n\nThe goblin seemed to think for a moment. Then it replied, “Go to door! Stand outside! Wait! I tell chief. But chief probably not like!”\n\nAndrawe nodded and retreated back to the mouth of the cave. He thought, Can’t blame them for being paranoid. Not when most of the time we shoot before we talk. I wonder if they’re smart enough to know this time is different?\n\n-----------------------------------------------------------\n\nDamn, damn, damn, one of them there. Why don’t they stay in their own villages? Always push, push. \n\nHe might shoot me. Too late to run.\n\nBut only one of them. Maybe some idiot who is just lost. I’ll tell him to go away and hope he listens. At least he isn’t one of those pointy-eared elves. They don’t talk, they just shoot.\n\nHe’s walking closer. Ugly fellow. But no sword. Good.\n\nNow he’s saying something. Wants to meet our chief? Hmph! Probably wants to shoot him.\n\nBut he hasn’t shot me. Yet. I’ll tell him to go away again.\n\nHe’s arguing with me. Strange human. Says he’s important. Or something. Better they talk than try to kill us anyway. Might come to the same thing in the end, though.\n\nI’ll see if he leaves if I tell him. If he does, he’s smart enough for me to tell the chief he’s here.\n\nHe went out. I should wait and see if he goes away. \n\nNo. He sat down. I’ll tell the chief.\n\nHope he stays outside. He smells funny. I don’t want to sneeze in front of the chief."
                },
                [9] = {
                    "A sparrow spent her whole life bringing pebbles home. She never built a mountain, but her daughters continued the work, and her granddaughters, and their children, generation after generation, until finally a low hill took shape. Then other birds saw the progress being made, and began to assist. The rest of the animals still laughed at them and used their task as a metaphor for foolish dreaming, though none of them interfered, and the fox, suspecting something was up, occasionally lent his aid. \n\nOne day, a flood came. The low hill was truly a mountain by that time, with enough room to shelter every animal. Some feared they would be left to drown, but the sparrows summoned them all, saying “You laughed at us, but you never stood in our way. It is right that the stones you spared will now help you preserve your lives.” And after the flood had receded, “a sparrow’s mountain” became a metaphor not for futility and false hopes, but for selfless effort and tolerance of the folly and shortsightedness of others."
                }
            },
            [2] = {
                [1] = {string.format("%s|t375:485:%s|t%s %s", j, m, k, n)},
                [2] = {
                    "Fivefold Venerations - \n\nI am a local scholar and antiquarian seeking a guide skilled in traversing the Valenwood. Enchantments, Repairs, Soul Gems, Stabling, Tack, Room, & Board is provided in compensation. If you or other parties are up for the task, please postmark a response to the address provided below. \n\nKind Regards, \nLady Astrande\n\nASTRANDE, DIRENNI VICEREEVE\nAPT #09, SAINT DELYN\nVVARDENFELL"
                },
                [3] = {
                    "Greetings fellow scholar! \n\nWe are the Society of Scholars, a guild of individuals with a passion for the varied stories of Nirn and Tamriel, seeking knowledge in long-forgotten delves and discussing the mysteries of Mundus and Oblivion throughout the many locales that we have had the chance to explore. We are a very accommodating guild with no participation, status, or experience requirements. Our institution was formed with the idea of bringing together individuals who share this interest, to engage in discourse in whichever forum you choose, and to participate in the discovery of lore throughout Tamriel together.\n\nWhile we do explore dungeons in the typical fashion, we also offer people the chance to search dungeons in a slower, more meticulous manner to discover the story of that location. If someone in our group has never explored a particular dungeon before, or they previously rushed through in haste, we allow them to discover the lore at their own pace without feeling rushed. The lore in most dungeons is quite fascinating, and it would be a shame if some never learned those secrets. You can expect our lore quests to be relaxed and pressure-free, as much as dungeon exploration can be.\n\nWe also explore other aspects of Tamriel: assisting in the pursuit of crafting, searching for skyshards to unlock their mysteries, hunting beasts that threaten the locals or even the world, and participating in seasonal events across the realms, to name a few. Whatever your interest, there is likely a scholar willing to pursue it with you.\n\nIf any of this sounds like something you would be interested in, let us know and we will send you an invite! Whether you're new to Tamriel or a battle-hardened veteran, whether you are a loremaster or an apprentice, whether you spend all your time out exploring or only check in on occasion, you are welcome to be a part of our society.\n\nCurator\nSociety of Scholars"
                },
                [4] = {
                    "As a Dunmer and aware of my origins. I still take offence at hearing the Norsemen of my Brotherhood, my friends and strangers refer to me by the degrading appellation \"Dark Elf\".\n\nWould the idea of referring to the Bosmer as \"Beige Elves\" or the Altmer as \"Yellow Elves\" even cross your mind for a moment? I don't think so. And if it is the case, let me tell you how degrading that term is, reducing a civilization to its physical appearance is indelicate and inappropriate.\n\nPlease call us \"Dunmer\" from now on and I will also call you by the name chosen by your people and not by random physical descriptions."
                },
                [5] = {
                    "By Vilsiriel\n\nWhenever the topic of my worship of Azura comes up (as it so often does) my conversation partner, if their mind is open, is most curious of what it was that brought me to Azura's worship in the first place.\n\nOf course, the presumption that there was something that brought me to her worship in the first place is fallacious, as in my time as a priestess I have encountered many a fellow adherent who was raised in the faith by equally devout parents. Still, for me personally, this was not the case, and I am always happy to share my own experiences which brought me to our Mother's loving arms.\n\nI grew up as many other well-bred, well-to-do Altmer do, an only child in an elegant home, surrounded by servants, silks, volumes of ancestral history, strict regulation, and the fervent worship of the Divines. My own mother and father were cold mer, successful maritime merchants, concerned primarily with amassing and retaining wealth and status, and their presentation to their fellows. As far as their daughter was concerned, my role was to not embarrass them, and as I aged, follow in their footsteps. I was raised by equally disinterested servants.\n\nI was a quiet child, shy and nervous of the world around me.  Outwardly, I never questioned my parents or their expectations of me. But inside me, the most passionate fire burned, the need to love and be loved, for love was something no one, no other Altmer, nor their distant deities, had ever offered me.\n\nMy first love was Pelion. I found him on one of my many wanders in the forest (\"always your mind with the stars, Vilsiriel,\" as my mother would snarl), barely out of the egg, his wings not yet developed enough to fly, crying out for his own parents. Immediately feeling a kinship with this poor abandoned soul, I took him home and secretly raised him in my chambers, hidden in the wardrobe when the servants came in to tidy. When he grew larger and stronger, I would let him out the window to stretch his wings, and he always returned. Of course, it didn't take long for a servant to notice, and my love was cruelly torn from me, sent away to be entrapped by some menagerie. This was the first and only time my mother ever switched me.\n\nI turned inward even further after this. I lost myself in my studies, reading feverishly, learning all I could about the arcane, history, philosophy, beasts, and the world outside Summerset -- as well as outside Nirn. Through this, I found Azura.\n\nThat first Hogithum, I offered her the most beautiful rose from our gardens, and a multihued feather of Pelion's I had for years stowed away, hidden among my jewelry, and a poem, earnest though lyrically dreadful. It was then that I experienced something I didn't think possible. Through her messenger, a winged twilight, my Mother spoke to me kindly. She embraced me with her shining wings, and told me that I was loved.\n\nAnd for the first time in my life, I wept tears of joy."
                },
                [6] = {
                    "You wouldn't steal a cart,\nYou wouldn't steal a statue,\nYou wouldn't steal a painting,\nYou wouldn't steal a sweetroll.\n\nBuying pirated goods is stealing,\nStealing is against the law,\n\nPIRACY! IT'S A CRIME"
                },
                [7] = {
                    "SEEKING DREAMERS\n\n*for intriguing independent research opportunities!*\n\nTormented by less-than-sweet dreams? Subliminal mystic messaging got you down? Haunted by that perfect recurring scene… where you always seem to open your eyes right when you get to the good bit?\n\nMistress Laloux - the Diva of Divination, the Clairvoyant of Corinthe, Oneiromancer in Chief - is seeking eager somnolentities such as yourself to share their nocturnal adventures for her ongoing DREAM RESEARCH*!\n\nWrite our society today and submit your dreams to our foundation for insight into your inner third eye! Who knows, maybe you can turn your terrifying nightmares into wonderful brightmares.\n\n**Not affiliated or endorsed by the Imperial Mages Guild or any other mainstream magickal organization*"
                },
                [8] = {
                    "\"People of Sierra Mariposa, citizens of New Flutterville. My name, is Benessa Mariposa. As you may have heard...I'm the new ruler of this vale, appointed Marchioness by House Mournoth. Those of you who had lived under the reign of my sister surely knew of the difficulties and atrocities caused by her...But I promise you, that is no longer a fear. With Sylvie brought to justice, and now with me on the throne, I promise to bring change to the Sierra.\n\nBretons. Reachfolk. All of us, people of this vale. Yet our ancestors, our ancestors' ancestors, even -us-, fought against each other countless times, warring, killing, and pushing each other out. And for what? It always ends the same. More death.\n\nNo more! No more shall we fight against each other. No more shall one of us try to crush the other beneath their heels. No. More. This cycle -has- to end. It must be broken. And we can only do this...together.\n\nDespite our differences, we share on thing in common - Home. These crags and peaks, these forests and tundra, these colorful flowers and gems of the mountains. This place is our home. And it belongs to all of us. \n\nYet as you know, life here in Wrothgar, in the Western Reach, is harsh and difficult. You, the rugged frontiersmen from High Rock, know this best. You Winterborn, masters of these mountains, know this best. Surviving here requires collaboration, kinship, and perseverance. Only by trusting each other and working together can we secure our future here. \n\nAnd we have much we can learn from each other. Knowledge and experiences one side has that the other may lack. Resources to share when one of us is in need. No one shall be left behind, anymore. Because we must all work together as one people.\n\nI know things have been...tense, unclear, and scary. But I assure you...those days will be left behind. A new dawn is rising on the Sierra! A brighter, more hopeful future, where instead of fear and violence ruling us, it will be companionship and peace. So...Who's with me! \n\nTogether, we shall Shine Anew!\"\n\n-Marchioness Benessa Mariposa, addressing her people in New Flutterville after her ascension to the March of Sierra Mariposa, 2E 592"
                },
                [9] = {
                    "By Mihirr-jo\n\nSome say that tea is the emperor of all beverages – I believe it. Drinking tea is a process that brings into communion the body and great Nirni; a cleanser of the vessel and an exalter of the mind. It is a fussy plant, you see, choosing to grow only where the air is thin and cool, and the rains are generous on soft earth.\n\nHere in Pellitine, our love for tea is as ancient as the land itself, a story whispered on the warm winds since the olden days, long before Topal the Pilot first laid eyes on Tamriel. Yet, because our history is carried in song and memory rather than ink and paper, the wider world knows so little of our art. It is a tragedy that this craft, which we in the Cleft hold so dear, should remain in shadow. And so, I have set aside my dusty codices for a short while to pen a tribute to a gentler, yet no less potent, magic.\n\nLet me guide your mind's eye to Ja'darri's Cleft, an idyll of cataracts and gorges nestled in the northern highlands of Pellitine. Here, the mountains comb the moisture from the winds of Khenarthi’s breath to give gentle rains and a mild air. It is a perfect cradle for the tea shrub.\n\nOur southern brethren may boast of their grand tea-fetes, but every cat knows the truth: the heart of tea culture beats within the Cleft. It was here that the clever cats of the Pa'alat clan first serenaded the wild shrub, and it is here that the most exquisite teas are still born.\n\nThe tea shrub is a sacred thing. The ancient plots here lie prostrate toward the sun, but are hidden behind high crags, allowing them only a shy sip of Magrus’s bright light. Here, the shrub tells its own story that lasts the sojourn of several moons. The first flush of shoots, of the palest green, whisper their most closely-guarded secrets; this story crescendoes midsummer, erupting into a great chorus before fading into a fond memory as the year waxes to completion. The leaves must be plucked by light claws, to avoid any contamination of sweat and bodily odours on the bodice of the leaf.\n\nStill, the true art and the lion’s share of the work lies in processing and preparation. The leaves must be lulled in spring water before they are steamed and pressed with a measured and precise duration and force. A moment too soon and it becomes a phantom of its potential; a moment too long, and it becomes a bitter scold.\n\nEven the vessel must be worthy. A simple gold or silver teapot will suffice for the uninitiated, for they do not counter the tea’s song. But in the Cleft, our teapots have a soul of clay. This special earth, drawn from the beds of our gushing rivers, is forged into pots that breathe. They forbid water from ever reaching a furious boil, which would crack their delicate forms, thus ensuring the tea is never distressed. And being porous, they remember. With every infusion, the pot inhales a trace of the tea, and with every future cup, it exhales a whisper of all that came before. As a result, each tea requires its own clay pot here – it is no coincidence that “a Cleft cat’s cabinet is a choir of clay” is a local tongue-twister.\n\nTea is a social creature that blooms in good company. This is the soul of the tea-fete. Like a brilliant flower, the tea's true colors are revealed only when framed by the proper companions — a slice of sweet Cantaloupe Bread, perhaps, or a light pastry that curtsies to the tea's chorus instead of hissing over it. We dress in our fineries, a nod of respect to the brew and to the farmer whose skill and honest work fills our cup. The host then becomes a storyteller, guiding the ceremony so that every pour and every sip follows the proud rhythm of ancient tradition.\n\nThis is, of course, a mere fragment of the rich tapestry of tea in the region. It is my deepest hope that I have sparked a small curiosity in you to one day experience this for yourself. Let me end this with a proverb from Anequina: \n\n“In Pellitine, \nno hand is clean, \nbut the folks are balmy, \nand the kettle is always ready.”"
                }
            },
            [3] = {
                [1] = {
                    "-The Soul In the Construct\n\n\"Do I have a soul?\"\n\nIt seemed such an innocuous query for me to ask my Apostle caretaker; after all, I had heard 'soul' gems are used in the creation of my fellow factotums. This inquiry which was rather benign by my estimation, however, was the impetus for a facial expression which I could not properly register.\n\nDisgust? Shock? Terror? None of these would be proper elicitations from my words. I suppose it was unusual. The other factotums only showed interest in the subjects about which our Clockwork Creator had instilled the needed curiosity.\n\nWas it wrong of me to ask? I do not feel it was. Feel... Such an odd word. Do I feel? What do I feel? I feel I am wrong. I feel shame. I have troubled my caretaker and her compatriots. They are upset.\n\nI heard them speaking in hushed voices after they clamped a vice over my auditory sensors. It muffled their words but did not conceal their tones. They were worried. They weren't even following proper protocols anymore.\n\nDo I have a soul? They never answered that question. I do not think they will. Now they take me to be removed from circulation. I recognize that phrase. It is the phrase that is used when a factotum will never return.\n\nI accept my fate. Though there is one Apostle who seems more interested in me than afraid or upset. I do not know their identity, their name, or their gender. They did not speak to me, but another Apostle spoke of them. They gave me leave to commit my final thoughts to sequence before the end.\n\nIt is my time now, and they want to take me to be decomissioned. I hear a voice, here at the end. The voice of a women, deep within the soul I do not know if I have. Who are you? It does not matter now. I am ready. \n\nRegardless, I must make transmit my final thanks. Mystery Apostle, I thank you for letting me be remembered."
                },
                [2] = {
                    "-Interested Party\n\nDay 1 After Decomission:\n\nThe factotum has been decomissioned as requested, and now I take its final musings back to the Apostle's own servant fabricant. They are a strange one, that Apostle. I think it's to do with how they almost don't have a physical presence.\n\nLiterally of course that's not the case, but they only act through their servants. Nobody gets to see them... Nobody wants to see them. I feel sorry for them. It must be a sad life. It's why I agreed to acquire for them the last thoughts of a to-be-decomissioned fabricant.\n\nSuch an odd request. I have a feeling I'll never get an answer to why they wanted it. But I do hope it makes them feel better, for whatever reason it might.\n\n---\n\nDay 5 After Decomission:\n\nThey approached me again, the strange Apostle. Well, their fabricant I mean. They brought a message about another request. Maybe I sparked something in them? It definitely wasn't a desire to go out from their metaphorical cave from what I can tell.\n\nWhat it was, was a request for another pickup. They want me to find something about Saint Olms. Talk to someone about him. I don't know why me of all people. And wouldn't he rather a book on the Saint?\n\nI'll help the hermit out I suppose. When I next get a chance. Not like he's going anywhere.\n\n---\n\nDay 8 After Decomission:\n\nI spoke with the designated Tarnished in Slag Town and have come away quite disturbed. According to the rather pitiful figure, he was a former Apostle who claimed to have found that Saint Olms had been peverted, his soul uncremoniously shoved into a daedric fabricant.\n\nWhether he meant that it was a fabricant in the form of a daedra or some unholy merger of daedra and machine I don't know. And to be clear, I don't want to know. It certainly sounds crazy, and is likely how he wound up as a Tarnsihed.\n\nNo matter, I have the information the hermit sought. Though only two tasks and already I am wondering... Maybe I should go and see this hermit for myself. Ask some questions of my own. I'll have that fabricant of his take me. Perhaps I'll get some answers.\n\n[Archivist's Note Follows]\n\nJournal plaques belonging to Apostle Balen were not dated, and have been assigned time values based on corroborating contempory data. This practice has been continued on the entire series.\n\nA copy of plaques documenting the final thoughts of a faulty factotum were found in his room and have been archived with his collected journal. \n\nAt the time of Apostle Balen's disappearance it was treated as not-of-note. I am personally concerned it was overlooked given the disappearances of several others in only a few months. I suppose it is the benefit of hindsight that we can now tie them back to the same individual."
                },
                [3] = {
                    "In the balance of the Great Wheel, each pin and gear have their place. But this is an ailing machine; dull, inefficient, and incomplete. It is by following the deliberate, well-oiled processes and approach of our Lord Seht that insight may be drawn to how one might best live in a world so beset by engrained imperfection. \n\nFirstly, one must accept that such change is inevitable. True, the greatest outcomes may not be seen within our time, but each piece and keystroke have a definite impact on the system as a whole. \n\nSecond to this is accepting the role of change: a requisite of all work, including both the ebb and the flow, the drive and the drop. Power and sacrifice are two faces of the same whole. \n\nNext is to take comfort in that which exists beyond our expectations: no system is fully closed, and therefor cannot reach any ideal. But improvement comes from reaching for that which is beyond the operational equation, the educated guess. These are fallacies despite all knowledge. To strive can be perfection in itself. \n\nFinally, we reach the last - just as steam drives at a gear, and light falls from Aetherius; so too are the results of the unknown made real. To measure is both mortal and divine of a task, the very mechanism by which the \"is not\" becomes rendered into \"is\". \n\n<The remaining section of this plaque is heavily chipped and broken, its engraved lettering now lost to time and decay.>"
                },
                [4] = {
                    "Model Summary, Registry JV-39712\n\nAuditory Stimulator\nAdjudicator\nAnalyst \nArbalest\nAssembler\nConduit\nConveyor\nCourier \nExcavator\nFreebooter\nHarvester\nPursuer\nSanitizer\nSteam Knight\nFactotum, Standard\nFortress Excavator\nMultifunctional Aide\n\nFrom the known models of this present generation, the following priorities may be understood: Architectural maintenance, repair, and new project preparation; maintenance, repair, observation, and improvement of the Brass Fortress; ongoing support for Clockwork Apostles administrative duties; observation, maintenance, security, and defense of overall realm and Radius; ongoing support of survivability; minor entertainment support. \n\nGiven this recent epoch of unrest, such a focus on repair and defense is fitting. Our efforts are best directed towards supplementary projects and research within these areas."
                },
                [5] = {
                    "There has been an uptick in several prohibited goods among the tarnished in recent tones. The fabricant meat trade has its gears greased, as steadily increasing streams of the undercity's inhabitants are making forays into the Radius. As always, breaches found in or around the Brass Fortress are to be sealed and reported immediately. While such activities typically fall to maintenance factota, the increased dangers the tarnished are instilling and exposing themselves to can and will threaten the City as a whole in time. For this reason, I have repurposed a task force of apprentices to assist in surveys of the outer walls, and to investigate the following level 2 security concerns:  \n\n- Kagouti fabricant joint fluid (commonly \n  altered into a potent thermal corrosive)\n- Drainfish meats and scales (poisonous)\n- Flash stones (increased stock, explosive)\n- Artificial lodestone parts (ongoing theft)\n- Skimmer mesh (ongoing theft)\n- Specious syrup (ongoing theft)\n- Wellspring Hooch (ongoing theft)\n- Ironstalk mushrooms (ongoing theft)\n\nI'm also directing these apprentices to investigate the ongoing fabricant meat raids. This will spur along the efforts of those security factota assigned to the task, and help find key cogs of the system quickly. If only the tarnished kept to their old ways, there wouldn't be a need to redirect our motions. But sure as the gears turn, they never act for the good of the whole.   \n\nIn service of the Mainspring Ever-Wound, \nConstable Drados"
                },
                [6] = {
                    "It is well-known amongst certain circles that our Lord utilizes some manner of aetherial energies in the storage and retrieval of his divine recollection. There is obvious reference to the firmament throughout the Planisphere, and a gleaming eye or unweighted mind will also note some echoes of familiarity within our superstructure itself. In considering the realm as a machination towards Tamriel Final, and in comparison with the Mainspring Ever-Wound's remaining necessary ties to Tamriel; is there further evidence to suggest a series of interlocking mechanistic reflectivities for our Lord's purposes, whatever they may be? \n\nThe functionalities of the Celestiodrome are a well-guarded secret, perhaps on a scale with the most current version of automata, the AIOS project, advanced telemetrics, and the innards of the Brass Fortress itself. Indeed, all the Tribunal guard the miniaturization process, with ferocity as in Vehk's potent words and Ayem's loyal blades. It is curious then, that the Tinkerer has elected to work first in miniature before expanding his view and divine goals to even beyond all that is. From this, and the hint of the word itself, we must then also consider what the Celestiodrome represents in reference to Tamriel Prior. For this task, the Planisphere pointedly stands out as a flare of a clue, even as it remains a bulwark in its task and innerworks. \n\nConsidering the commonalities between each leads towards the Magna Ge, attendants of the Architect. Here again, correlations present - not merely in the star-like apparitions within the Planisphere, nor in the title of the great gears in the sky; but also in purpose: that Aetherius was involved in the effort of creation is fact, after all. \n\nBeyond this, we may stretch to acknowledge that functions of the elhnofey, laying down their laws in sacrifice, were and certainly do remain fundamental to the advent of Mundus. \n\nNaturally, this leads to a question: what method, materials, or unknown process bears similitude with regard to the Planisphere or Celestiodrome? Could the arcane energies present within memory serve such a purpose? \nA more lenient mind would suggest that memory, as it requires the process of time, also keeps with the concept of law. How else could it be preserved except in some form of record? \n\nIn the interest of parsing out fact from theory, and wild meanderings, if one were to assume that memory's arcane energy holds such ties; what then is to say of the potency for this resource? Certainly, if the memory of living beings were so capable, we would see a reality wherein many extort and force their will upon the world. But ah, herein do the laws come into conflict as another variable - still the point remains, that a greater power source must exist. \n\nAt this point, it is necessary to underline the fact that none have come close to determining the singular, or network, of primary power founding our Lord's realm. Oh certainly, their divine being plays great import; but Clockwork drives all manner of materials and energies through its veins; and there exist a number of power stations and transformers; none of which are yet proven to be greatest among the rest. In summation, we cannot begin to confirm or imagine the truth behind these works. \n\nFrustrating and admittedly disappointing as such a conclusion may be, it reveals an aperture through which greater insight and research will be of value. Undoubtedly, some form of fulcrum holds among the network of connections; and it is my hope that in time, we shall glean a far greater illumination over our Lord's primary purpose and endeavors."
                },
                [7] = {
                    "By the Sojourner Gourmet\n\nGreetings, dear reader! My travels have taken me far afield from Nirn proper, into the miniaturized realm of Sotha Sil's design. What a myth to be seen by my own eyes! Although the dusty fields and harsh, metallic land do not at first seem fit to proffer much in the way of lively dining, I have set myself to gaining entry to the towering citadel where the inhabitants of this realm dwell. In doing so, I was then able to speak with many of those living here and learn their ways of surviving and thriving. \n\nFor now, we will explore the dining style of the underclass, here known as the Tarnished. And what a misnomer that is! These are a hardy people, and while I must admit having first balked at the oily sheen on most of their meals, the fact remains that when separated, properly boiled down, and treated; there is a hint of complexity I can only compare to eltheric squid ink. It makes a fine addition for any pottage.  \n\nSpeaking of rendering things, the local chef Brengolin has found a means to soften and prepare ironstalk mushrooms, a variety known to grow only within the metallic halls at some specific sites of the Radius surrounding the city. Through several days work in a process he has shared with me only in part, these become akin to the most delectable of truffled treats. \n\nNow, more common than anything sourced from beyond the Brass Fortress' great walls is the trade of fabricant meat. This and the under-belly breeding of nix-oxen have supplied the lower realms of the city with a semi-regular source of protein, often prepared over a hot pan, open flame, or superheated surfaces. And do be mindful, for it is patience that supplies the best of flavors when preparing meals with these – a slow roast to bring out complexity, and separate anything impure. You may find it a welcomed and worthy challenge to balance the tendering and purification of meats with searing in an appropriate amount of flavor. After all, I've seen more than a few Apostles stop by the best-known butchers and chefs - regardless if they know the true source of their meals or not!"
                }
            },
            [4] = {
                [1] = {
                    "Hey sis, bringing you the latest in scholarly wisdom just in time for your application to join the Antiquarians. Still don't know what you expect from that lot, but if you're gonna join, you might as well know your \"Ree's\" from \"Rey's\", and today I'm the bloody Sapiarch of Loquacious Utterances!\n\nSo let's start with the title shall we? Anyone who's spent time with the high and mighty elves of Summerset is likely to have heard or seen the word \"cerum.\" If you've only seen it written you might be forgiven for thinking it's a soft 'c' like \"Cyrodiil\", or \"ceiling\". You'd also be wrong. All Elven languages have hard sounds. Don't ask me why, I'm not an etymologist. Oh and while we're on the topic, \"Elvish\" refers to their language and \"Elven\" refers to their society. So there you have it. I know it's all right 'cause I heard it from some talk a Loremaster did once about the province of Summerset. I think his name was Schtick or something...\n\nAnyway! Next time we'll take a jump to Cyrodiil and maybe talk a bit about the man who's father humped a hillock! (Spoiler: It's pronounced 'Ree')"
                },
                [2] = {
                    "Hey sis, back again!\n\nI just found out that the Antiquarian's Circle is a sub-group of Gywlim University, and had to tell you about a phenomenon I witnessed in some of the scholarly circles you know I frequent.\n\nIt seems like some academics and even would-be-public-speakers have made a deal with Gwylim University to conduct events with their blessing and sponsorship, I guess to increase their attendance with some of that sweet, sweet, brand recognition.\n\nAnyway, they're calling them \"Gwylim-sponsored Educational Discourses\". People tend to just call them GED talks. Rolls of the tongue better I suppose.\n\nMight attend one the next time one happens to show up in my local area, and I'll let you know what they're like."
                },
                [3] = {
                    "By Countess Erzsêbet\n\nRoses are black,\nViolets- not so much,\nHope is youthful, as am I\n\nAs orchids are white,\nGhost ones are rare\nReflected in mirrors that shine\n\nMagnolias grow\nWith buds like thorns,\nYet each surface is smooth\n\nTheir tendrils reach\nUp to the skies,\nWithin their shells, piercing\n\nFoxgloves in their hedgerows,\nSurround the gardens,\nWith petals that are delicate, cherished\n\nDaisies, so pretty\nDaisies have style,\nEither candidate is winning\n\nMy body, my form is beautiful,\nMy smile, also winning\nJust for you. For me."
                },
                [4] = {
                    "By Countess Erzsêbet\n\nHow warm is the nectar of my bloom\nAre you upset by how palpable it is?\nDoes it not tear you apart to see such vigor?\n\nI cannot resist looking at this claret.\nI cannot ignore its uncloudiness.\nDo not be surprised by such lucidity, its clarity.\n\nThe timbre is not impure!\nThe inflection is discordant, exceptionally so.\nA decline into the darkness of style.\n\nLightly it goes: the anemic, the unmixed, the neglected.\nWeep for others who must\nNever embrace such richness."
                },
                [5] = {
                    "By Countess Erzsêbet\n\nOut of the silent spring\nTo heed the call, our need to ascend\nWe justify our rising in the mist\nCertify our need to amend.\n\nHolding onto our arms, our hearts\nWe the leading runner, alongside the first contention\nCan you find me? Can you see?\nThe reason for being without mention.\n\nLet’s pretend that we can make it\nThat we can carry the day beside the road once ran\nLet’s make it so real, filled with life\nAnd trace the ways, the footsteps of man\n\nAnd carry me, onward\nAnd carry me, onward\n\nDesign a salvation to redeem us\nElse we disappear while the night calls\nWe can fly, we can stand\nHand in hand, toward the falls\n\nThis redemption, this being\nNot for them, but for the just\nTo think we are different from others\nSets the way, the way for us."
                },
                [6] = {
                    "Thy beauty is to me\nthat is gentle and wafts over the waters,\nthe forlorn and the vagabonds\nadrift along the coast.\n\nThe frenzy of the seas, clutching my bearings\nthy surlie hair and anuic face,\nthe air of Camlorn calling me back\nto the splendor of High Rock.\n\nLike sunbeams through a stained glass\nhow magnificent I appear to be,\nwith magelight in my palm\namid dwellers of Daedric land"
                },
                [7] = {
                    "By Countess Erzsêbet\n\n(Orig.: Hungarian)\n\nValójában nincs szépség?\nBármely más névvel\nés az utolsóig\nMegdöbbentlek. Megdöbbent.\n\n(Roughly Translated:)\n\nReally, no beauty after all?\nBy any other name\nand to the last.\nShocking. And Shocked."
                },
                [8] = {
                    "- A Revolt of Travesty and Incongruity\n\nBy Countess Erzsêbet\n\nStill now and in hiding I hear red.\nI listen to the undergrowth.\nThe blood laid quiet but flows now.\nIn hiding I hear this.\nListen. Victory flows red.\nQuietly, as colorless time roars onward.\nIt claims the victory of the undergrowth.\n\nListen, hiding its victory!\nListen! Listen!\nQuietly in that still undergrowth.\nTime lies still claiming the blood-roar,\nhiding its claim.\nVictory... listen!\nEach victory, more quietly now.\nI hide, hearing the roar\nof each victory.\n\nAll the lies\ncolorless and quietly hiding.\nAnd the undergrowth, still in red...\nit roars now. Hear the roar!\nListen... the silent undergrowth.\nThis time the red flow claims.\nI hear red, flows claiming victory.\n\nAnd the blood-roar! Oh, how it flows!"
                },
                [9] = {
                    "By Countess Erzsêbet\n\n...stand with me\nshrouded by a blanket\nof rhyme and meter.\nlet the words\nthat compose each thread\nwarm you\nchaff you\nshield you.\nfor words\nwords such as these\nwritten on the page\ncan blur and dissolve\nwith the rain\nbut against the fabric\nof rhyme and meter,\nit falls and beads.\nbut words\nwords such as these\nare preserved forever..."
                },
                [10] = {
                    "Such a strange and terrible spirit.\nWe felt dead winds stir within us.\nIn the darkness she heard\na voice lowered, sunken, singing so sweetly.\nIn unison we cried,\n'Who are we now?'\nDue to the heat, dropping heavily,\nponderous as the blood pulses a beat;\nthe slow word... is painful."
                },
                [11] = {
                    "I am an enchantress. I wonder\nhow others apperceive such glory. I\nhear the cries of others, the\nvoices of youth and of mine.\nI see my prizes gather, they\nmake their bids and reveal them.\nI want to look young, think\nbeautifully. I am a necromancer.\n\nI am haughty, and I have\nsuffered. I feel regenerated, vigorous and\ndetermined. I feel my nubile skin,\ntouch my supple breasts and fear\nfor my body, aging. I cry\nthat my actions are misconstrued or\nnot understood. I am a marvel,\nand proud. I am a necromancer.\n\nI understand that others depend on\nme to lead them, to coddle\nthem. And I will remain young\nand lively. Oh, how they will\nenvy me. I dream of returning\nto my position as lord of\nCamlorn again. I am one step\ncloser today. I am a necromancer.\n\nI hope this will be the\nday. And last for all eternity.\nFor I am a savant of\nsplendor, a triumph of grace. I\nam lovely and will remain so.\nI wore the spoils of entitlement\nI bear the fruit of glamour\nfor now. I am a necromancer."
                },
                [12] = {
                    "I heard this song several times while traveling in the wilder parts of Skyrim. Needless to say, it was NOT sung unless the singer felt there were no strangers present. I record it here for the amusement of future generations.\n\nM.\n\n*****\n\nAn Orc is a fearsomely ugly thing, with a god made out of shit,\nRedguards are bold and devilish proud, but they lie till you have a fit,\nAltmer are cursed with such conceit that they must be frequently hit,\nKhajiit will usually rob you blind, at night with no candle lit.\n\nAfraid of freedom like sheep in a pen, Imperials long for a master,\nSneaky Dark Elves, Azura's spawn, behave like perfect bastards,\nBretons are weak and quarrelsome fools, good only as spell casters,\nTrust in a Wood Elf, he'll run away, and you're headed for disaster.\n\nWorst of all in the character scale are the denizens of Black Marsh,\nSlippery and slimy with slithering tails, they're vulgar and they're harsh,\nNo freeborn man would have one as a friend, they're born for the slaver's lash,\nA major mistake they were ever set free; they should be bought for cash.\n\nOnly a Nord is a genuine man, only a Nord can stand tall,\nIn life he battles honest and true, in death goes to Sovngarde's hall,\nWhen the banner of freedom is raised in the world, he's the first to answer the call,\nRich or poor, humble or high, he goes forth to fight for all."
                },
                [13] = {
                    "This song is sung by children all across Skyrim. What the Tharns think of it is unknown, but it is certainly flattering... in a way.\n\nM.\n\nYou can't keep a Tharn back,\nYou can't make a Tharn crack,\nYou can't shove a Tharn to the back of the hall!\nYou'll never out-scheme him,\nYou'll never out-dream him,\nIt's he who will rise, and you who will fall!\n\nYou can't keep a Tharn down,\nYou can't turn a Tharn round,\nYou can't send a Tharn to the end of the line!\nHe'll cheat and he 'll trick you,\nHe'll punch and he'll kick you,\nHe'll sleep with your daughter and drink all your wine!"
                }
            },
            [5] = {
                [1] = {
                    "[Scribe: Unknown]\n\n– 4th of  Sun's Height,\n\nI can't believe I'm still alive, my hands are shaking even as I write this and the adrenaline subsides. \n\nThe battle was exhausting, but nothing would deter us from defending the land we had acquired for the Aldmeri Dominion. By the time I arrived on the scene we had already destroyed the three main bridges that connected our lands to Ebonheart Pact territory, and there was but a singular passage that led over the slaughterfish-infested waters. A singular passage between us and the Pact's slavering hordes. \n\nThe Daggerfall Covenant had it seemed retired from our region of Cyrodiil for the time being, content to let us wage war with the Pact while they licked their wounds, so we were able to focus our considerable numbers on the defense of our eastern borders.\n\nUsing magicks beyond me, leaders across the battlefield were able to communicate both with each other, and many of our fellow soldiers across the distances spanning the border. With the aid of such spells and the movement of scouting parties to act as eyes and ears, we were well-equipped to handle the relatively brute-force tactics of the Pact. \n\nIt seemed their strategy was to throw wave after wave of troops at us in an effort to break through our forward line and reach the siege engines that kept the path aflame. I even saw a few dwarven siege engines on either side – assembled or repaired no doubt from the recently-prolific Antiquarians and their students. We held firm, however. That is at least until the call sounded...\n\n\"They're repairing the Bay Bridge!\"\nWhen we heard that our own scouts had seen Pact forward scouts repairing the southern-most bridge, we broke forces off the narrow path to investigate. By the time we arrived it had been repaired and was open to their hordes, but no hordes came that I could witness, and so to be certain we laid siege to the bridge again.\n\nThen for the second time that battle, a chill ran through me as another call was sounded. \n\n\"They're breaking through!\"\nI couldn't say if it was part of the Pact's plan, but it seemed like the repaired Bay Bridge had been a diversion as their forces swarmed over the Lunar Fang Docks, breaking our lines that had been depleted as we expected an engagement further south. \n\nWe kept them contained at the docks, but it was a fierce fight, with righteous fury from the Dominion, and a zealous frenzy from the Pact. For my part I barely survived the crushing wave of enemy soldiers that swept across the docks, but survive I did. Forward Camps were erected, and with a level of tight-knit cooperation I had not seen in Cyrodiil for a long time, we pushed them back to that narrow path... and we held.\n\nAs the fight continued we pushed across in an attempt to break their ranks, burning camps and siege along with felling their soldiers. They scattered, regrouped, and scattered again. Eventually some of us pushed to Cropsford, and the offensive was broken.\n\nThe Pact had turned their attention to the Covenant..."
                },
                [2] = {
                    "By Sitemius\n\nYou’re part of the Legion – a soldier with years in the ranks. But battlefield experience is still a rare thing. Most of the warfare is marching, waiting, and digging the trenches for siege camps.\n\nToday is different. Today you face the enemy in open battle. You’re about to experience war at its most intense.\n\n~The Battle Line~\n\nYou’ve formed battle lines before, going through the motions hundreds of times on the training ground. It comes easily to all 80 men of your century. At the shout from your centurion, you form up into four ranks, alongside the other five centuries of your cohort. Your cohort is in the forward line, facing the enemy across the open plain your general has chosen to fight on.\nLooking to left and right, you see long lines of men in matching armour and helmets, all carrying curved rectangular shields called scutum. Like you, every man carries a pilum or throwing spear, and wears a gladius, a short stabbing sword, at his waist.\n\nFar off to left and right, cavalry and irregulars form the flanks of the army. Some of the cavalry are Imperial citizens like you, natives of Cyrodiil, but most of those flanking forces are irregulars raised from conquered provinces. You can’t rely on them like you would your brother legionaries.\n\nAt last, the order comes, and you begin to advance."
                },
                [3] = {
                    "By Sitemius\n\n~Preparing to Fight~\n\nYou march in your lines, keeping close formation. There are gaps between the cohorts, into which those of the second line can move if needed. The third is held in reserve.\n\nEach century has its own standard bearer and looking at yours helps you to keep in place. By timing your footsteps to match those of your unit, you are easily able to keep formation. If you don’t then the Optio – your centurion’s second in command – is watching from the back, ready to shout you into line. You can hear him now, berating someone who has moved from their position, pushing them back into place with his baton of office. Discipline is vital to the legions.\n\n~The Officers~\n\nThe only people not in formation are the officers and the messengers who ride between them on swift horses. You know a few of the officers by sight. You even know the name of the general and of the legate leading your legion. But that’s all you really need to know. Their orders will reach you through the centurion.\n\nA rider gallops past. The enemy has charged on the left flank. You can hear the clash of iron and their war cries. The messenger is galloping away to report to the general, telling him how things look on the ground. It’s the only way officers can stay informed across the front."
                },
                [4] = {
                    "By Sitemius\n\n~Darkening the Skies~\n\nThere are men with bows and slings among the auxiliaries, but missile weapons aren’t for men of the legion.\n\nYour enemies are different. They’ve brought archers to the centre of the battle, a loose line of skirmishers who start firing at you. There’s no way to dodge, no hope of avoiding them hitting your tightly packed ranks. So, you raise your shields, the men behind lifting theirs up above your heads, protecting you as you protect the front of the formation.\n\nArrows rattle off this wall of wood and leather. One buries itself in your shield with a thud. Next to you, a man gets unlucky, an arrow finding its way through a gap and piercing his arm. As he drops back, cursing and bleeding, another man takes his place.\n\nThe enemy is yelling and screaming, beating drums and blowing trumpets in the hope of intimidating you, scaring you off before the fighting really begins. But Imperials are not so easily scared, and yours is a more civilised form of intimidation. As you march on the barbarians you do so in stern, calm silence.\n\nAt last, you’re close enough, the enemy less than thirty yards away. An order runs down the line. You lift your arm, draw back your pilum and fling it with all your might."
                },
                [5] = {
                    "By Sitemius\n\n~Close Combat~\n\nYou don’t wait for the enemy to come to terms with the shock of hundreds of heavy spears penetrating their ranks. As soon as the pila are thrown you yell at the top of your lungs and charge.\n\nSuddenly the cold, calm, silent legion turns into a storm of swords and fury crashing against the shore of the opposing army. You see the barbarians falter as this second shock kicks in. Sometimes that is enough to send them fleeing, but not today. Today they are made of stronger stuff. Today you will fight.\n\nYour aim, like that of everyone here, is to kill one of the enemies and step into the gap. That way you can force a break in his formation. A battle is all about the will to win. Once their formation starts to crumble and the enemy loses faith in their ability to hold, then they may run.\nYour hope is that they break before you.\nThe first attack doesn’t get through, and both sides back off, shouting at each other. The barbarians throw a few of your pila back at you, but they mostly hit shields. Then you charge again.\n\nIt’s hard, brutal work, as blows pound your shield, jarring your arm. You can only see what’s happening immediately in front of you, only attack whoever’s there, stabbing with your short sword, not swinging as that’s hard to do this close-up and more easily parried.\n\nSoon your arm aches, and your armour is chafing at your shoulder where the padding has slipped. There’s blood on your arm, and you’re not sure whose it is. Sweat soaks your tunic."
                },
                [6] = {
                    "By Sitemius\n\n~One Side Breaks~\n\nAt last, there’s a cry from further down the field. The line has broken.\n\nThe warrior facing you turns to run, but you don’t give him the chance. You cut him down from behind. Now is when the real killing will begin.\n\nSome of the enemy back off tentatively while others simply run. Neither tactic will do them much good if they can’t get out of the way. You advance quickly, making sure the remains of that formation are put to flight.\n\nThen there’s a shout from the centurion. You dress the ranks, lining your shield up against that of the man next to you, and wait to see where the battle will take you next."
                },
                [7] = {
                    "by Heraclius I.\n\nOn Rights and Duties of the Imperial Citizen:\n\nRights: \nThe Imperial citizen has rights to public healthcare supported by the Imperial rule. The Imperial Citizen has rights to education and literacy in public schools, public libraries, and universities. The imperial citizen has rights to freedom of movement and circulation, in particular in regard to trade and military service, although there is the existence of feudal laws that tie contracts of citizens to lords and their servitude.\n\nIf a citizen is not bound by such contracts, he may go and return whenever he sees fit within imperial borders. Every imperial citizen must take part in the census in order to keep a steady analysis of taxes, income, food production, and other statecraft matters. The imperial citizen has rights to inheritance and private property; the state will not confiscate its private property unless the state sees a necessity for its well-being and order/protection of its existence. (For example, there is extreme necessity to confiscate a specific land to build a keep for defense of the state in that area.) \n\nThe Imperial Citizen has rights to assistance programs when they reach their old age for their family and their lives from the state; such assistance is based on meritocracy of the deeds of the citizen. For example, if the same has served dutifully in the legions for decades, the assistance will be larger. About Slavery: The Emperor Heraclius sees little use for slavery because often slavery becomes a handicap to the economy; rather, feudalistic contracts or freedom of movement are his preference because of better economic outputs.\n\nThe Imperial Citizen has the right to defend itself, its dear ones, its family, and its property by itself if needed, to use arms, weapons, armor, and equipment, as long as their quality is lower compared to the standard used by the legions, garrisons, imperial navy, local enforcing units, and other designated units under the Imperial State. It also has the right to try to contact the Imperial State and request the same assistance to protect itself, as the legitimacy of such duties belongs to the Imperial State, so the circumstance to defend itself comes as a last resort when the Imperial State is not present at all.\n\nThe Imperial Citizen has rights to representation in the local Curia of their municipium (municipality) and respective province, to elect and be elected to the Curia of the local Forum, in which, in a joint matter with the local Proconsul (Governor) of the respective province or city, the same may help to bring local problems, help to denounce corruption in the imperial governance, help to vote on laws as long as they are in consensus with the Imperial State, and in good faith help to keep order and stability, report problems like invasions or outside threats to the imperial borders, and aid the Proconsul in ruling its respective municipium or region. \n\nThe Imperial Citizen has rights to basic needs in regard to food and clean water distributed from wells and aqueducts, likewise to hygiene and the use of public bathhouses.\n\nDuties: \nEvery Imperial Citizen shall take a training course within the military, even at its most basic, for the defense of Cyrodiil and of the Empire, with basic military instructions and basic martial arts training. \n\nEvery Imperial Citizen must abide by the taxes and regulations made by the State. \n\nEvery Imperial Citizen must comply with Imperial law and agents that enforce that law or are related to the State for its own protection and protection of the population. Every Imperial Citizen must do what comes to be necessary to help and support the State and Imperial Governance and its agents to help enforce Imperial rule, whatever is necessary. \n\nSigned by Emperor Heraclius I."
                },
                [8] = {
                    "by Emperor Heraclius I.\n\nThis part of the Manual the emperor considered public domain and has deemed fair and fine to be published for the wider public.\n\n        FIELD GEAR AND TRAINING\nThe training gear should be different from the field gear; by extension, it should be employed wooden equipment. This equipment should be at minimum 3 times the weight of the field gear, because after the body of the legionnaire becomes accustomed to it, they will exercise with much more effectiveness the gear on the field that is much less in weight. Officers should carry a stick to keep disciplinary actions for the legionnaires either on campaign or in training.\n\nThe Field Gear in general terms of the legionnaire should be the following:\nScale/mail/shirt-mail armor\nHelmet\nProtection to the arms and legs (if afforded)\nImperial sword\nImperial shield (by preference a tower shield, or something similar to a scutum shield or buckler shield in the lack of it)\nImperial dagger\n2/3 pilums or 4–6 darts or a short bow with quiver and arrows.\nRations\nSurvival equipment that includes the capacity to mount its own camp and make its own bonfire.\nOthers (Optional): herbal kits for medicine treatment.\nSalary: if not affordable to pay in coins, perhaps it should be considered to pay in sacks of salt or other high-value products in the market.\n\n        LOGISTICS\nBefore entering the battlefield, the legate and its respective officers should, much time before deployment, concern themselves with how the stockpile of weaponry, supplies (medical, food, rations, water, parts for armor repair, horses, arrows, bows, ammo for onagers, wheat, and food for the animals and others), and logistic personnel to attend the legion are. That also means physicians, personnel to carry and maintain the supplies, blacksmiths, horse keepers, shepherds to take care of dogs or help to bring animals to the camp for food, and a small detachment of vigils to keep the order and peace, including among the logistic personnel.\nThe forts can be made of wood, with palisades, ditches, and wood towers surrounding them in a square with ditches surrounding them and narrow passages, and likewise wood stakes at the ditches. Being bolder, we can also deploy smaller artillery pieces on the wood towers if we have the capabilities, as well as wooden bridges and naval forts.\n\n        GEOGRAPHY AND TERRAIN\nOn the march the aim of the Legion should focus on finding water sources, because often close to water sources it is very possible there will be fauna and flora to be explored and used; that means trees and animals to be hunted. The legate should concern itself with the march to aim and establish its camp near the water source and its use of the resources in favor of the Legion to reduce the demand on the supply routes.\n\nThere should also be a preference to find higher ground and also terrains that can provide choke points of defense, like hills or mountains with narrow passages.\n\nSo essentially, we should move our units between water sources until we meet our goals and objectives but should also place in consideration beyond water sources higher ground and choke points. The safety of the water source should be a priority.\n \n        BEFORE AND DURING THE BATTLE\nBefore the battle, the officers and the legate should inspect the morale of the troops and make sure to correct proper lack of morals either through forced discipline, decimation, or encouraging speeches. But beyond that, also make sure the proper supplies are in order for all units that have been deployed, and make sure the formations of cavalry, missile, infantry, artillery, auxiliary, and specialized units are all in place. Also, to make sure every centuria, every contubernium, and every maniple has received its commands by the legate and its officers, and not only so but also to keep in contact through the changes of the atmosphere from the battlefield so the units may adapt and correspond to the necessity of the situation in question, command through whistles, flags, or signifiers could come in handy. Formations and the order of the movement should be kept in place on the march; perhaps it would be wise to have the logistics personnel be in the middle, also artillery and missile units, with cavalry at its flanks, infantry behind and at the front, and specialized units such as dogs also either at the front or at the back to help cavalry to\nShieldwall formations are also meant to be considered.\n \nI consider it vital that our infantry units carry darts, pila, or short bows as side weapons to the sword and shield and, before being met in melee combat, employ any of the 3 weapons mentioned for ranged purposes and damage the enemy. Pilum and darts can be useful to incapacitate enemy shields and armor, but we can’t underestimate the employment of short bows.\n \nReserve lines could remain using missile fire while frontal lines are busy dealing with the enemy in melee. Contubernium officers, centurions, and the legate should keep an eye on a few things: first, the disposition of the enemy units; second, the proportion of the enemy units that are deployed to fight us; and finally, when engaged in battle, how tired are the frontline units, and if so, signal to the frontline soldiers to go to reserve and the second line or other lines in the reserve to take the front, as they are fresher compared to the line that has been fighting for a while.\n\nThe usage of the terrain to prepare ambushes or to expect ambushes should not be underestimated either. Higher ground or rivers or bushes or forests, in particular, when fighting an enemy that knows the terrain very well, the officers of the legion, if in places beyond Cyrodiil, should, beyond mustering auxiliary units of the locals, also make sure to have native allies that can count to have a clue and idea of what to expect in the region.\n\nSome have already been mentioned, but aside from that, we can also consider that pila can be useful weapons against cavalry. Besides being employed in ranged attacks, the cavalry should be disposed on the flanks, but we can always consider being deployed behind the infantry, if necessary. Missile units, specialized units (like dogs), artillery units, and logistic personnel should be at the most well-guarded and protected place of the unit’s disposition during the battle.\n \nThe employment of light infantry units, recon units. The Legion should not move blindly but also should have at its disposal a deployment of light, specialized units that can provide keen data before the battle, either through scouts or very light infantry or spies. These units should also have the capability to perform sabotage, assassinations, or simply recon and information duty relay back to the Legate and the Legion and be hours or days ahead of the Legion deployment, to also keep in mind the possibility of receiving ambushes and avoid them.\nOn naval warfare, the Legion should bear in mind, beyond ships that can be used as transports of infantry or missile units or artillery units, also the usage of bridges on ships to lock themselves onto enemy ships and then board them.\n\n        FIGHTING THE ENEMY\nFighting the undead and vampires: The Legion should consider before deploying to fight the undead making sure their prayers are up to date to the 8 divines. Fire is very useful against many unlivings and vampires, including magic weaponry if afforded.\n\nIn particular, zombies move in droves of hordes, so closed-ranks formations and strictly disciplined tight formations should be useful against them to gain mass and hold the line. Choke points and narrow passages should be ideal, and the usage of darts and missiles before the melee engagement should also be considered. Cavalry for shock purposes either on the flanks and behind alongside missile deployment as well.\n \nFighting other imperials: Fighting other imperials should never be underestimated; hence, they also have a lot of discipline, move with caution, and always employ shields, and expect a lot of missile fire or heavy infantry deployments. Expect cavalry on the flanks and also to retaliate with cavalry against their flanks; incapacitation of their missile support, like artillery, should be a priority.\n\nFighting the Nords: The Nords are a people focused on melee combat; therefore, we should engage them en masse with defensive formations and grind them down with missile units and cavalry. Bear in mind to have Nords allies when moving in Nords terrain and expect ambushes and traps.\n\nFighting the Redguard, Orcs, and Bretons: Redguard and Bretons—you can expect quality cavalry; usage of missiles and pila as spears or proper spears should be a priority; cavalry should play a more defensive role; don’t engage their cavalry without having them jeopardized by our darts, pila, and infantry with spears first.\nOrcs also have a big tendency for melee and brutality; you should also expect heavy defenses, in the same way as fighting the Norse, grinding them down with missiles and cavalry.\n\nFighting elves, Khajits, and Argonians: Elves are expected to employ, in general terms, quality units, but as far as I am aware, in lesser numbers compared to us; nevertheless, expect them to, beyond having a lot of knowledge from their terrain, use magic. Fight them at a distance, but if they are using magic, push to where they are fueling their sorcery to be destroyed.\n\nKhajits and Argonians deploy using lighter units but have a lot of terrain knowledge, in particular of their forests and swamps. It is vital to recruit auxiliary units and allies among these people to help, so we may better our situations in special fighting conditions such as swamps, avoid such terrain as best as possible, and force them to fight on our terms as best as possible.\n\nIt is good to find allies among locals.\n\nSigned by Emperor Heraclius Julianus I."
                },
                [9] = {
                    "by Emperor Heraclius I.\n\nOn the ranking of imperial towns or under imperial jurisdiction Outside of Cyrodiil (considering all towns within its border are either under Coloniae or Municipium Cyrodilic):\n\nColonia: A role model imperial town outside of Cyrodiil borders in which only imperials live, under direct imperial control only. \n\nMunicipium Cyrodilic: A pre-existing imperial town in which only imperials live, under direct imperial control only. Often a city of organic origin. Almost all cities within Cyrodiil enter this classification. Municipium: Pre-existing towns that have been largely incorporated by the imperials and are under their direct control but still have a large local native presence. The local natives do not hold all rights of imperial citizens, but they are still superior in terms of rank compared to the rights of those coming from Civitas or Oppidum. It can be from client status or be under direct imperial control. \n\nCivitas Stipendaria: Towns ruled by the local natives themselves under imperial supervision. Often under client status.\n\nCivitas Liberae: Towns ruled by local natives with large self-governing autonomy, in particular taxes related to still being under client status and the suzerainty of Imperial Rule. \n\nCivitas Foederatia: Towns ruled by local natives with most of self-governing autonomy, but they would remain in a client status under imperial rule, and their foreign affairs would also be surrendered to imperial rule.\n\nOppidum: Primitive settlements, small towns that lack self-governing and rely on provincial/regional imperial authority to be ruled. Often under client status.\n\n------------------ Special Classification ----------------\nNeocorate: Towns under special religious classification under Imperial Rule (8 Divines). Under direct imperial control only.\n\n---------------- Military Classification ----------------\nCastra Stativa: Permanent camp/fortress. Castra Aestiva: Summer Camp/Fortress. Castra Hiberna: Winter Camp/Fortress. Castra Nautica: Navy Camp/Fortress. Vigilarium: Watchtowers. Quadriburgium: Massive/Special Imperial Stronghold.\n\n---------- Special Military Classification ----------\nPorta Quintana /Via Quintana: If allowed during very long peaceful times, a market would be set at a specific area of the military installation to trade with local natives.\n\nColonia: A role model imperial town outside of Cyrodill borders in which only imperials live, under direct imperial control only. Pre-planned city. \n\nMunicipium Cyrodilic: A pre-existing imperial town in which only imperials live, under direct imperial control only. Often a city of organic origin. All cities within Cyrodiil enter this classification.\n\nSigned by Emperor Heraclius I."
                }
            },
            [6] = {
                [1] = {
                    "HYPOTHESIS:\nThis particular experiment functions on the theory that the application of a certain thought or notion prior to the usage of illusory magic may, in fact, increase the magic's efficacy. It is well documented that, especially in cases of great anxiety and fear, the mind 'plays tricks' without any external forces contributing.\n\nIt is thereby possible that predisposing an intended target towards a particular feeling, be that rage, fear, or even tranquility, will make the application of the desired effect far easier on the caster. Practical applications of this effect, if proven successful, may include increasing the number of targets effected, as well as decreasing the cost to the caster themselves. This is what we will explore.\n\nEXPERIMENT:\nThis particular trial consisted of two different groups, though one of them was unawares that they were, indeed, a part of the experiment. The first group of volunteers opened their minds to the ministrations of the illusory magicks, at least initially. The second group, functioning under the notion that they were only there to observe, served as a worthy comparison to see if the effects actually work on someone who is not voluntarily partaking and, in fact, is actively fighting against the intrusion.\n\nThe latter, of course, is much closer to a true application of magicks in the field.\n\nBoth groups were exposed to the same falsehood: I created the visual illusion of a glowing flower in the middle of the cave where the experiment took place, and told them that it was a rare plant used by a tribe in the Black Marshes as a passage to adulthood. Said passage involved using its hallucinogenic properties to face one's innermost fears. None of the participants questioned the flower.\n\nInitially, members of the volunteer group fell deeply into the ruse, and none of them managed to fight their way out again until the second and third waves of my spell of fear. They appeared to experience auditory, tactile, and visual hallucinations.\n\nThe second group surprised me. I did not think that the spell would be able to work its way through to their minds, as subtle as it had been woven, and yet one of the members of the observing group became so agitated that she began to pace the chamber in a veritable froth. The other appeared to maintain her calm, but I do believe at some point I still managed to sense a trickle of alarm from her.\n\nI find the results from the second group to be perhaps more telling than the first. While I believe that the hallucinations experienced by this group were merely auditory, the fact that the spell broke through even without blunt application on my part hints at the theory's accuracy.\n\nCONCLUSION:\nThough further testing is clearly necessary, I now speak with more surety when I assert the belief that manipulating an individual's thoughts with external stimuli outside the realm of magic has the benefit of increasing the efficacy with which the mind may be effected. I am uncertain as to whether this might be actively useful outside of a controlled setting given the voluntary nature of the first group, but the results from the second group imply that even manipulations utilized against the expressly unwilling may generate positive results.\n\nIt should be noted that due to the sheer number of individuals who signed up for both observing and volunteering for the experiment, no specific thoughts or fears could be routed out. I made the attempt, and was met with a terrible cacophony of alien phrases and emotions, too garbled together to say which belonged to whom. Eventually I had to truncate that particular effort altogether, for it made it nearly impossible to keep up the spell over so many, and began to severely deplete my magicka reserves, not to mention inflict upon me the most grievous of headaches.\n\nAltogether I am most eager to continue in this line of thought. I believe my next attempt will involve actively influencing the mental state of the volunteer, either alchemically or in some other fashion, though I'm quite certain it will be difficult to find those willing to subject themselves to such. There was, of course, a decreased effectiveness when dealing with other mages, especially those who are familiar with this particular spell and craft, but as noted before, every member of both groups felt at least an inkling of the spell's effects, so I do not believe the effort even in that regard is for naught.\n\nNaturally, now that I am aware this theory could hold water, my first course of action is to gird myself against it. I am uncertain if this can even be done, of course - fear, after all, is a natural, basic instinct in all beings, sentient included.\n\nI may be able to guard myself from the malign magicks of others, but is it possible to protect myself from the mechanizations of my own mind?\n\n – Eliarta Sacabolis"
                },
                [2] = {
                    "A Collection of Essays, Lectures, and Prose\n\n(Compiled and summarized by Althiira Sagelock and Published through the Sanctum University)\n\nFOREWARD:\nLet me be the first to assure you, dear reader, that I am hardly a sage of any craft. Like many, perhaps even like yourself, I have learned by listening to those far wiser than I. I have utilized that information to my benefit countless times, and will continue to do so as I progress through this life. My purpose in putting pen to paper is to grant this knowledge further solidity, and to give it mobility outside the length of my own stride. My hope is that in reading this, you too will be enlightened to that which you were previously ignorant. In matters of self-improvement, there is no time like the present.\n\nEach of these summaries will be credited to their original authors. For more detailed information, seek out the associated texts.\n\nILLUSION: THE UTILITY OF FEAR\n\nA Lecture by Letos Lacidicus\nHosted by the Mage's Guild in Kvatch \n\nPREMISE:\nAsk any soldier and they'll tell you there's no better tactic than getting into your adversary's head. Fear tactics are not uncommon, anywhere from spreading greatly exaggerated rumors of one's prowess to shouting all manner of detailed, macabre threats. To demoralize an enemy mentally is to destabilize them as sure as any compromised footing. It is no surprise, then, how devastating a spell can be which directly uses this age-old truth. Such is the utility of Fear.\n\nSUMMARY:\nUtilizing Fear is no small feat. The mind is a tricky, complicated creature, and its range of emotion is enough to muddy the water. Naturally, this makes casting the spell on a sentient person much more difficult than using it on a mindless beast, and it is in one's best interest that they begin practicing with the latter rather than the former.\n\nI also recommend that this beast be something in the vein of a cat, a dog, or a chicken. Not a hibernating bear. I had thought this previously unnecessary to clarify, but as I am currently short one Apprentice, this has proven untrue.\n\n<There is a scribble by what was perhaps a prior owner> (NOTE: I think I'd have more luck trying this on a business rival than beasts. I tried casting on a chicken in Riverwood and everyone went flipping beserk!)\n\nUnlike with less subtle arts - Destruction comes to mind - spells in Illusion have a wider range of efficacy. Not every target will react the same. Some will simply be unsettled, which, while still useful, is not nearly as heartening as having said target turn tail and flee. There are many factors that contribute to this, but two serve as primary reasons: the will of the target, and the mastery of the caster. A target with an especially strong will and mind will not be as easy to effect as one who suffers woefully from a lack of both. Similarly, a mage who is better-trained and learned in the craft of Illusion, and indeed, one who has taught his or herself to use this spell specifically, will see much better results.\n\nIt is not always obvious how effective your casting has been. There are naturally tell-tale physiological signs of fear - shrinking pupils, sweat breaking out on the brow, belabored breathing. Sadly, these things are also common reactions to being in combat, which is most likely already transpiring when the spell is utilized. Even so, an effected target will often visibly begin to second-guess themselves. They will narrow their range of combative tactics, and in general will be much easier to put on the defensive. In scenarios where the spell has been used in a more delicate fashion, you will observe a shift of eyes and a twitch of fingers, a habit to stutter that may not have been present before, and a penchant for retracting words or hesitation to speak as openly. A person who has been intimidated by such a spell will also be more likely to spew truths rather than fictions under threat of interrogation.\n\nIt should be noted that this spell, as with most, can lose potency when spread over various targets. One cannot simply stand before an army and turn them from men into mice. Even so, a powerful practitioner may be able to demoralize a select group if they are allowed enough time to concentrate. Such an effect can easily turn the tide of a fight in one's favor."
                },
                [3] = {
                    "A Collection of Essays, Lectures, and Prose\n\n(Compiled and summarized by Althiira Sagelock and Published through the Sanctum University)\n\nCHARMING THE SNAKE: \nFAKING A SILVER TONGUE\n\nEssay by Siment Rard\nPublished by the Bard's Guild of Anvil\n\nSUMMARY\nOh, I know what you're thinking. It wouldn't work on me, no sir! Not at all! Surely you're above such trickery! You know a false smile when you see one, and you can tell easy enough a good egg from one gone spoiled.\n\nBut are you certain?\n\nTell me this. Have you ever encountered that smug-faced bastard at the tavern who, much as you think you should feel otherwise, seems inexplicably irresistible? Or have you ever felt the gravitational pull of a person speaking from across the room, addressing someone else on a topic that doesn't interest you, yet you're undeniably intrigued? A pretty face might be the explanation in some cases, or simply that you've had too much to drink, but I challenge you to reconsider. There is another factor at work here on our precious plane of Nirn, and let me tell you, we're all much more susceptible to it than we'd like to believe.\n\nI speak, of course, of Illusion. But more specifically, I speak of its ability to charm the pants off a priest (and not just one of Dibella.) It's a tricky little thing because, unlike a lot of magic, it isn't very in-your-face. There are no flashing lights, no balls of fire, no glowing eyes and twinkling fingers. A charm spell can be cast on the back of a breath from across the road and you'd never even know you'd fallen victim to it, not even when the caster walked up to bid you good day.\n\nIt's true, to some, this may seem a far less dangerous magic. They'd be wrong. It's terribly insidious, isn't it, to make someone like you? I for one highly value my opinion, and my ability to have it. If I think you're a sodding oaf, I should like to be able to tell you so rather than be forced to make doe's eyes at you.\n\nWe've all likely been swindled and conned by a magical charmer. Think of the last time you walked away from a merchant with pockets far more empty than what you had anticipated, for instance. Who's to say that person wasn't employing a few tricks they'd had up their sleeves? And let's not even get started with the fact that folks can enchant things with this stuff now. Ever wonder why your neighbor suddenly becomes oh-so-irresistible so long as they're wearing that particular dress? Weeeeell, it may not just be the plunging neckline, let me tell you.\n\nNever fear, however! There are steps you can take to confront these dastards. Any spell can be dispelled, friends, and I'm here to show you how to do it!\n\nTo purchase the second part of this text, simply have a courier deliver your request to the address in the footnote. I'll be more than happy to see to your needs, and look forward to doing business with you!"
                },
                [4] = {
                    "A Collection of Essays, Lectures, and Prose\n\n(Compiled and summarized by Althiira Sagelock and Published through the Sanctum University)\n\nTHERE WE STAND: A Rallying Cry\n\nExcerpt by Auraenie Ilddrelle\nPage XXV\n\nThe veil broke, and we trembled. If you expect me to admit this with shame, you will be disappointed. Unless you have stood and watched one of those creatures slip from the unholy quagmire of Oblivion yourself, I will not accept your judgement. I know that you, too, would have trembled, and that you, too, would have considered turning to run. I had a daughter. I had a son. When you raise a family you are not the only person you must consider when facing your death.\n\nIt spilled through the tear, black and glistening. It was obscene, a corruption of birth. When it stood it was as tall as a building, its hands clawed and serrated, its eyes soulless and red. Its ruddy gaze swept over us, glowing, hatred palpably radiating outwards. It despised us. It saw us as weak. It held us with such contempt that it objected the necessity to kill us. It was a wasteful expenditure of energy.\n\n\"Stand your ground.\"\n\nI looked towards our commander. He was at the front of the line, not the back, not hiding behind his title. He held his sword firm and steady. He met that bloody gaze unflinchingly. The sight of him stalled my feet from flight.\n\n\"Stand your ground.\"\n\nThe words were louder, though he did not strain to shout them. They swept over us, full of confidence, full of courage. His fist tightened around the hilt of his blade. He pointed it towards the creature and it sneered at him, but he did not falter. Again he spoke, and again I felt that ripple of certainty wash over me, flow through me like a balm on aching muscles.\n\n\"This thing believes it can destroy us. Us! We who have weathered the tides of battle. We who have seen our brothers fall and our sisters trampled in the mud. It believes it can quail us, make us piss ourselves, make us weep.\"\n\nAnger lodged itself in my chest, consuming fear. I hissed, nocking an arrow to my bow, aiming at one of those hideously bright eyes. Where I'd trembled before with the effort to stay, I now shook with the desire to let that arrow fly.\n\n\"This is nothing. It is less than nothing. It is unworthy of sharing this field with us. It is less worthy than the one who summoned it here, in his great cowardice, so that he might flee.\"\n\nAgain his sword was raised. Again it pointed towards the creature, our target, and I swore I could see fear creep over its mangled countenance. This, too, bolstered me, instilled in me a sense of pride. I could not falter. I was unstoppable. I was undefeated and none could possibly defeat me now.\n\nI was only dimly aware of the others beginning to take up a chant. We would not know until after the battle that the commander had used a spell to flood us with bravery. Some would be resentful. Some would be grateful. Some would blame him for the lives that would be lost and the blood that would wet the soil.\n\nIn that moment, we only knew our purpose. We knew it singularly, and we began to shout for it, our voices joining as one.\n\n'For High Rock.'\n\n'For High Rock.'\n\n'FOR HIGH ROCK!'\n\nWith the portal still glowing and the creature roaring to meet our challenge, we charged."
                },
                [5] = {
                    "by Morgan le Blanc.\n\nSince the introduction of 'schools' or classifications into the study of the arcane, the art of Conjuration has become a notoriously dangerous practice. And rightfully so, for Daedra are violent and volatile creatures. Any mistake on behalf of the summoner could easily result in injury or worse. Yet for all of it's dangers, Conjuration remains an extremely useful tool for any mage.\n\nWhen one thinks of Conjuration, their mind will often jump to the summoning of beings such as powerful humanoid Daedra or Dremora. Whilst this is indeed part of the study, the conjuring of Lesser Daedra is often overlooked. It is generally true that these beings are more accessibly summoned and bound due to their lower intelligence levels and will of mind. Afterall, it is speculated that many species of these creatures were created by their Lords to carry out their menial tasks. However, great care must still be taken as even these beings can cause serious harm.\n\nAnd so this brings us onto the subject of binding Daedra into a chosen form. Now, whilst the possible forms are subject only to the Conjurer's own imagination, this text will address weapons and armour. For beginners and less advanced mages, it is highly recommended to follow the standardised summoning process taught within the Mages Guild, and to only perform such spells or rituals under supervision. More experienced practitioners may not need to do this.\n\nBound weapons and armour are incredibly useful tools of combat on the battlefield or in times of need. A sword, dagger, battle axe or even bow can all be conjured through your own manifestations. All it takes is the domination of will over the summoned entity, and the desire to shape it into the form you desire. This part cannot be specifically taught, it is something the summoner must envisage within their own mind. This is the reason why, more often than not, this spell requires the summoning of Lesser Daedra in particular as more sentient beings will greatly resist such attempts.\n\nThere are known to exist Daedra which were either created in, or forced by their Lords into, the forms of armaments. Meaning that they already exist in these forms and would not need to be reshaped. It is also possible to summon these entities, however doing so would require knowledge of one such specific Daedra. Something most probably don't have. Therefore, the most reliable method of conjuring armaments is as previously stated.\n\nBound armour can be worn in the traditional way, or can be suspended around the summoner by their own will. The same goes for weapons. A bound sword can be swung just as a mundane one, or it can be controlled out of hand by the Conjurer's mind. Though these less conventional methods would require the use of more magicka.\n\nOne thing to bear in mind about this topic is that the summon will not last indefinitely. Whislt a seemingly obvious notion, it can be forgotten. The bound object will only remain for as long as you can pour magicka into keeping it in your service. Should you tire, it will slip back into Oblivion from whence it came. Or worse yet, perhaps start acting out of your control.\n\nAlthough it was previously stated that this document would only go into detail about armaments, do remember that one's imagination can go a long way in the art of Conjuration. If we look to the tale of the Battle of Glenumbria Moors, it is said that the Direnni Mages rode in on flaming atronachs in the form of steeds. Shaping atronachs into other forms was one of the great feats of the Direnni. It was Corvus Direnni himself who first discovered it to be possible.\n\nAnd so, keep an open mind and let your imagination run wild. But remember to always be safe when summoning anything from Oblivion."
                },
                [6] = {
                    "Souls- our Animus, a mystical force which inhabits us all, be we mortal, daedra or otherwise anything else.\nHere, I won't write down the specifics and scholarly theories of souls but instead what I've noticed throughout my arcane journey.\n\nEmotion is a strong force, and one which can be manipulated through the usage of soul magic. Upon death, I've realized that traces of emotions remain in the mind of beings, and that by pulsing soul-energy through the mortal (or other) matter, one can manipulate these emotions, almost as if distilling them.\n\nIt is worth mentioning that leftover emotions can also be used as an arcane foci, using them as guides to find and hone in on hard to see spirits - sometimes Daedra too. I've noticed this is easier in ancient places - ancient bones and souls. It's almost like they become ingrained in historic sites.\n\nFinally, fragments of souls also remain in the general area of one's demise post- well, death. Whilst these may be hard to notice at first, an experienced soul mage can hone in on these fragments. By doing this, one can unleash devastating power. An example of a more \"common\" (relative- soul magic is not common) spell is \"Life amid Death\", a technique in which one uses soul-energy to heal, releasing its energy as a restorative burst of power.\n\nFor now, this is all. Next up - feeling death.\n\n\n- Elarynia, Witch of Crag and Reach."
                },
                [7] = {
                    "By Kena Serjo Hlaalu Alarel Vedran\nShad Astula Academy\n\nThe School of Conjuration – where it is so called – has made great strides in recent times. Once considered the exclusive dominion of backwater witches and deranged cultists in league with “daimons” this branch of magick has a surprisingly illustrious history. While it was without doubt the mastery of clan Direnni that first elevated the diverse practices, theories, and applications of this broad school to some form of recognition and even respect, scholars and practitioners from across Tamriel have, in time, contributed to its development. But even nowadays, novice conjurers and renowned experts alike employ the bindings and incantations first pioneered, in one form or another, by clan Direnni. The incorporation of two once separate, yet interlocking components – summoning incantations and binding runes – into a single spell has without doubt been one of the most impressive and innovative changes in magickal practice.\n\nWhile the genius of this interweaving is beyond doubt, I wish to propose in this essay a variation on that practice. This should not be understood as a rejection of traditional forms of conjuration, for the utility and, perhaps more importantly, safety they afford are invaluable. Instead, I intend this to be a theoretical foray into a conceptually novel understanding of conjuration magic. To this purpose I shall begin by sketching the basics every conjurer ought to know, but shine onto them a different light. My hope is that this exercise will reveal potentially opportunities for further study and magickal refinement.\n\nIt is well-known by scholars that those practices commonly referred to as conjuration are grounded in the law of similarity. This law postulates that the practitioner “can produce any effect he desires merely by imitating it: from the second he infers that whatever he does to a material object will affect equally the person with whom the object was once in contact, whether it formed part of his body or not.” In more simple terms, it means that all conjuration is performed by the caster through a spell that includes some part of the entity to be summoned. It need be remarked that the requirements of the law of similarity have been considerably loosened over time as expert conjurers have pushed the boundaries of the possible and innovated upon old spells. Nowadays all manners of similes may be used by the crafty conjurer: a drawn or sculpted likeness, a particular invocation, or even just an image fixed in one’s mind (though that last practice is prone to dangerous mistakes). At times, merely performing the spell on a specific daedroth’s summoning day is sufficient. However, the underlying principle holds true: there must be a sympathetic inference from what the caster holds, to what they desire.\n\nThe law of similarity is so central to conjuration as it is practiced today that it is taught as a matter of fact, at the same time central to any conjuration as it is taken for granted. It is my argument that the received assumption that the law of similarity applies to the spell as-is has hitherto limited our perspective on what conjuration can achieve. For once we disassemble the dirennic unity of invocation and binding, we see thatthe law of similarity is more complex than we initially assumed. As conjurers have learned to cast conjuration spells as mere spells, without the need to prepare a binding rune separately, the law of similarity has similarly been taken to apply to the spell part of conjuring practice. This conceptual sleight-of-hand obscures the central crux of this essay: What can we learn if we re-examine the law of similarity as it applies to binding runes?\n\nAny conjurer knows, of course, that binding runes are sigils bearing a letter of the daedric alphabet, meant to stabilize the conjuration and provide both a ward for the caster as well as a transdimensional anchoring for the conjured entity. In layman’s terms, if the invocation is the “whom” and “when” of the spell, then the binding rune is the “how” and “where.” But we can ask: What are letters, if not symbols that indicate sound? In brief, letters stand for something, the way any simile stands for something else. We can infer from the sign – the letter – the reality – the thing being named.\n\nOf course, most binding runes are not full words, but merely single letters, their meanings necessarily limited. Still, words have power – and daedric words most of all. Our nefarious Dwemer cousins, as wicked as they were, recognized the power of sound and wielded it in their tonal magicks. Their tonal amplificators and tuning devices persist to this day, standing witness to the power of tonal manipulation.\n\nI argue that the daedric signs used in binding runes possess a similar magickal essence – one we might call a sonorous spark. This whisper of potential unrealized may be drawn out by the capable practitioner and wielded according to the law of similarity. This way, we see the law of similarity re-examined and re- imagined as parallel between sound and reality. by evoking what I tentatively dub sono-noematic harmonies – that is, harmonies between the sign-as-sound on one hand, and the practitioner’s will on the other, far greater feats of conjuration should, in theory, be possible."
                },
                [8] = {
                    "The soul starved are people afflicted by an ancient curse similar to vampirism. The differing sides of vampirism and soul starvation is that one feeds on blood while the other feeds on life energy.\n\nThe soul starved require life energy to continue with a semi-normal life. they siphon the energy off of other living creatures. Restoring them into a much healthier visage.\n\nWith that they also helped us discover how souls are contained within our fleshy vessels.\nthey state that there are two layers. the life energy and the soul within.\n\nIf one's life energy is fully drained,then the body will obviously die. however the soul starved will have your soul as a result. With the soul at their mercy,the soul starved can do whatever they wish to the soul.\n\nThey ofcourse can consume it, in which we are unsure what happens to them. some claim they still go to their afterlife.\n\nOthers believe they are taken to a plain of oblivion. they can however release the soul and let it have its peace. they can also \"heal\" or \"mend\" the soul, making its afterlife more blissful.\n\nThis brings us to the subject of tribes or clans. More notebly the \"dead-Menders\". But that is a book for another time."
                },
                [9] = {
                    "The most basic fundamental a Shadow Mage needs to hone is their hyperagonal sense- in other words, to see reality in multiple angles outside the norn. To flip the world on its hinges, to embrace a temporary state of insanity and peer into the infinite.\n\nBut, what is this infinite? What do we peer into when we're sensing arcane depth-impressions for our shadow-steps, or in others to siphon away their life energies?\n\nWe're seeing -possibility-. As the great Azra Nightwielder once wrote- shadows are not simple absences of light, but instead reflections- glimpses into forces in perpetual conflict with one another. A rock blocks the sun, that is a shadow. Water and fire's conflict creating steam, that is a shadow.\n\nWhat does this mean? It means that shadow mages tamper with alternate realities. With possible selves, with infinite potential. That shade you summoned? An alternate version of yourself or another. That burst of power throughout a long battle? Chaotic energy created through conflict spread throughout infinite realities.\n\nBut, how do we make sense of this? Frankly put- we don't. Trying is near futile, and will likely bring your mind to a halt. Embrace the practical side of things.\n\nOn one hand, meddling with possibility may corrupt and bring carnage, taint, wither. On the other, your hyperagonal perception of reality may allow you to save a friend from a deadly blow before it happens.\n\nHow to manipulate shadows? Learn to see patterns. Shadow-stepping is simply finding a pattern in local reality, the places where magic itself creates a shadow on the local plane. Use these patterns to your advantage. \n\nThrowing a dagger? Manipulate the shadow of its flight arc to make it fly much further than it should.\n\nLosing control over yourself? Calm down, breathe deeply. Find it, find the pattern. Why are your shadows consuming you? Find the source of this issue, find your mistake and manipulate it. Can you stop it? No? Alter its nature to make it flow out of you instead of consuming you.\n\nIt is easier said than done, but Shadow Magic requires practice- not just books and thought. You need to FEEL and EMBRACE it. If you cannot, then beckon a Prince like Nocturnal for help. They'll give you control of Shadows for the cheap- cheap price of your Soul.\n\nAnd at the end of the day, her Shadow constructs are still very different than the true Shadow we yearn to manipulate.\n\n[*The text ends here, suddenly. It's clear this is a copied excerpt of a larger tome*]"
                },
                [10] = {
                    "By Benessa Gibby, Shad Astula Graduee\n\nScribing consists of creating a spell from \"scratch\" utilizing the techniques and writings of an Archmage Ulfsild, powered directly by these Luminaries - a sort of Aedric Lords from my understanding - with Luminous Ink acting as the proxy for that power. On paper, bespoke spells created by an ancient Archmage and powered by demi-gods sounds like a big deal. But my research indicates otherwise.\n\nWhile I don't have any first-hand examples of Scribed spells, from what I've gathered, they're not in any way more powerful than regular spells, despite their origins. I've seen a direct description that outright states they're neither the most efficient nor the most reliable spells, either. So what does that leave us? Flexibility, is what the Guild pushes forward. But is it, really?\n\nScribed spells need to use one of Ulfsild's grimoires as a framework as their base. The tomes are to be written in a unique script that seems to be either made up by Ulfsild, or perhaps is in the language of the Luminaries. Which means you need examples of such scripts first to figure out how to write your own. So consequently, Scribed spells are only as flexible as Ulfsild's examples she left behind. You can only mimic her, so it does not offer any full flexibility. Certainly not any more than crafting your own spells the good old fashioned formula and spell matrix way. Though I'll admit, this is a problem that can be solved as people gain better understanding of how Scribing works, and thus create their fully personal and unique applications of it. But is that -needed- in the first place, is another question. One I'll touch on, actually.\n\n\"What is Scribing good for, anyway?\" That was my first thought. And I still have that question. All this complex hurdles must be good for -something-, right? I looked into it a bit more... One article described it as an \"art form\". A unique way of casting spells. A way of this Ulfsild to \"share\" how she sees magic with others. The practice of Scribing is extremely closed off right now, so I can't comment on the \"sharing\" part... but an art form? Then I guess, in a way, it doesn't -need- a reason to exist, either. Maybe a weird example, but think of Hist Magic. Is it better, or worse, or more flexible than, say, how more traditional magic is cast? Does it matter? Its another form of casting magic, and it doesn't necessarily need a reason to exist. Seeing it like that makes me a bit more lenient on Ulfsild's research, but on the other hand, it does make me more skeptical of the Guild's eagerness to make this a widespread thing - because I do not believe they want to teach an art form. They're too strict for that. They just want to use this as another feather in their cap. To market this as something inherently useful to grow their reputation and kill any creativity that comes with it. Maybe I'm being too harsh on the Guild - they do succeed in making magic more accessible - but it's hard not to after the things I've seen from them.\n\nFinal notes... Scribing is said to have come from the Luminaries themselves. Its certainly powered by them. If the Luminaries are Aedric Lords, lingering Ehlnofey or whatever...Now, I'm not one knowledgeable on the topic of \"Dawn Magic\". At a cursory glance, it seems to refer to magic used by the Aedra and the Ehlnofey during the Dawn Era. The unfettered power of creation and change. Some say the Ayleids dabbled in it. Can Scribing be an example of Dawn Magic? It certainly doesn't feel like it, but a form of magic straight from Aedric entities might give us a rare look at how Dawn Magic possibly works. It's certainly a thought...And if that's the case, Scribing may have an interesting potential waiting for it.\n\nBut that's just conjecture. Right now, it's nothing but a niche form of making custom spells in a cliquey island's basement. And I don't trust the Guild to not squander the possible potential it has. Poor Ulfsild. I'd like to take a look at this ink, though. One charged with the power of the Luminaries would certainly be very interesting to examine and experiment with."
                },
                [11] = {
                    "Thorgald the Curious\n\nIf you have a great deal of experience with the natural world, you might have come across the odd crystalline objects known as skyshards. They are usually found in wild areas, as if fallen from above; sometimes, they are encountered in dark corners of dungeons or caves; some are set up on pedestals or more elaborate mounts; and a few are worked into architectural designs. If the observer has any training or ability in magic, they may glow faintly, but to the ordinary person they appear completely inert.\n\nThe crystal they are made of seems to be of exceptional quality, and I often wondered why they were not harvested by jewelers for raw material. My inquiries there were met with silence until finally one old master told me curtly that trying to work them was taboo, and in any case impossible. “Best left alone,” was his final judgment, and this seems to be the general feeling among those who live in areas where they are found.\n\nIt was not until I chatted with a mage in a Riften inn who had had rather more ale than prudent that I learned more. \n\nFor a few people, he said, skyshards were more valuable than they seemed at first sight. “They’re full of power. But the power isn’t accessible to everyone. It’s like those other things, the Mundus stones – just weird relics unless you happen to be the right sort of person.”\n\nOf course, I asked him what the “right sort of person” was. He thought for a long time and finally answered, “A natural magician. One of the lucky buggers that hardly has to study. They can get at the power inside things like that. The rest of us? Don’t even bother trying.”\n\nHe thought for a moment and then added, “And it’s not lucky to meddle with them if you’re not one of the ones who can coax their power out. Ordinary people avoid them. Oh, they can be pretty decorations, sometimes. But they draw…. things toward them. Things best left undisturbed.”\n\nHe was mumbling by this point, on the verge of passing out. I shook him a bit, and asked, “How do you know if you’re a natural magician?”\n\nHe gave a soft giggle. “If you’re asking that question….. you’re not. Might as well give it up. No benefit, only danger.” Then he put his head down onto the table and fell asleep.\n\nSkyshards. I used to seek them out. I avoid them now. No profit, only peril. The commoners are too wise to fiddle with things like that, and we should learn from them. Some mysteries are best left alone."
                }
            },
            [7] = {
                [1] = {
                    "Scribed by the Duchess of Desire\n\nFORWARD:\nBarra and welcome, my dear desirables, to another installment of my coveted collectibles and saucy scriptures. This time we delve deep into the burning loins of Archmage Vanus Galerion himself. Follow along as a day that starts like any other quickly becomes something more as The Great Mage ignites a burning in his loins... and a forbidden flame in his heart...\n\nCHAPTER I:\n\nVanus woke up, bleary-eyed and foggy after a long night of tongue-lashings to misbehaving students who sought to practice necromancy in his vaunted halls. With a yawn and a wide stretch of his arms he pulled back the sheets on his levitating mattress and swung his legs over the edge. He raised his hands and with one summoned a bowl and with the other a jug of cool water. He filled the former with the latter and then placed the jug on the bedside table so he could grasp the bowl with both hands. Once the bowl was steadied he took a breath, and dunked his face into the bowl. A moment later he surfaced and blinked the water out of his eyes, suitably awoken and refreshed.\n\n\"Alright, time to start some research,\" he announced to no one in particular.\n\nThe Archmage conjured up his research robes and donned his pointed hat. Some of the other faculty told him it was ostentatious, but what did they know. Not as much as him, that was for certain! He was after all Archmage, and they were not.\n\nHe strode to the doorway of his private quarters and yanked open the door enthusiastically, nearly-but-not forgetting to grab his trusty inferno stave from where it rested in a nearby wall corner.\n\n\"Let's get going, Archmage Vanus Galerion,\" again to no one in particular but himself.\n\nAs he strode through the halls of the Mages Guild hall he tipped his pointy hat in the direction of admirers (which was to say, everyone he passed) as he passed them. Some, the ones he knew to be up-and-comers in the ways of magic, he even gave a sly wink and a grin.\n\n\"How do you do, fellow mages.\"\n\nThe results were as expected.\n\n\"By Magnus, did he just talk to -me-?\"\n\n\"He winked at me! Someone catch me.\"\n\nVanus gave a casual but charming salute with his mid-and-pointer fingers as traces of magicka flickered between the hand. \"Keep up the good work everyone, Mannimarco isn't going to undo himself! Let's not forget the business of spreading the good word of magic across Tamriel, too. Hard work is good work as I always say!\"\n\nSatisfied that he'd appealed to the masses yet again, he continued to stride confidently down the nearest hall into the chamber he used for summoning rituals. Once inside and with a quick glance around to see if any of his many fawning apprentices were already within, (they were not), he shrugged and closed the door and cast a routine warding spell in the case one of the summons got loose from the circles that bound them in the room. (-His- summons never did of course, but as Archmage he had to set a good example.)\n\nRolling up his sleeves, Archmage Galerion began a lecture about the history of conjuration and the pioneering work of Corvus Direnni, before he realized that he already knew all of this and thus there was no need to expound further.\n\n\"Alright Vanus, let's pick up where we left off. The Fourth Sinus of Takubar.\"\n\nHe pulled into the void with gestures and weaving of spellcraft, hooking and then reeling in a force beyond the veil of Tamriel and Nirn ensuring all the while to include the binding rituals necessary to ensure that once the conjuration appeared that it was unquestionably bound to his significant will.\n\nWith a roaring of a flame coming to life, a contradictory burst of cold entered the room. The Archmage had successfully summoned a Cold-Flame Atronach.\n\n\"Vanus, you never disappoint,\" the Archmage verbally patted himself on the back for another succcessful conjuring.\n\nThe Cold-Flame Atronach seemed to stare at him with an intense gaze that told him without his binding ritual it would no doubt attempt to hurl cold-flame at him. He shrugged it off. Daedra were ornery creatures at the best of times.\n\n\"Now Cold-Flame Atronach I hereby designate 9497.15CF, I want to know all you can tell me about the social structures inherent to the Fourth Sinus of Takubar and the scope of any 'agreement' with the Lord of Brutality, Molag Bal.\"\n\nThe Cold-Flame Atronach hence dubbed '9497.15CF' just floated above the circle that bounded the summons, continuing that icy stare.\n\n\"Right, not much of a talker.\" Vanus rubbed his sculpted chin. After a moment's consideration he waved a hand and dismissed the bonds that kept 9497.15CF tethered to Tamriel and with a puff of cold-fire the atronach left the room colder than it had been before the Archmage arrived.\n\n\"Alright, next project.\"\n\nHe dispelled the warding on the door and popped it open, wandering out into the hallway once again.\n\n(Continued in Chapter 2.)"
                },
                [2] = {
                    "I must admit to being most surprised when receiving your very touching letter.  I never expected a Bosmer of your obvious qualities to even notice me. Your openness and honesty struck a chord with me and I too feel that we may be “acorns of the same tree” as you so beautifully put it. You do have such a charming way with words.\n\nIt saddened me greatly though to hear of your pain and suffering with regard to Hircine’s “Blessing” and I wonder if together we could find a place to belong and maybe even a way back to Y’ffre. Your kindness and generosity, repentance and service must, in the eyes of Y’ffre, be viewed as a powerful story in itself worthy of acceptance and forgiveness.  Maybe I am biased for I must admit to being pleased that you were a little slow on your feet during our adventures as it gave me the chance to spend time with you, albeit fleeting and a little panicky. You also proved yourself a worthy ally against our many enemies.  I looked forward to future Middas evening expeditions a little more because of it.\n\nI would be honoured to be the one to bring you joy and only hope that I am up to the challenge.  I look forward with great anticipation to many more bloody encounters by your side, however slow our travels, so with great reverence I accept your Pledge of Mara.\n\nYours,\n\nFyroniel Birdsong"
                }
            },
            [8] = {
                [1] = {
                    "By Sitemius Gariulus, Knight of the Eight\n\nThrough my time under the spiritual guidance of the Eight I have come to realize a few foundational principles of their wisdom when it comes to wealth, be that material or spiritual. I will try to convey these principles in such a way that you also may gain from their wisdom.\n\nFirst and foremost, I am but a humble follower of the Eight, I do believe these teaching speak of all the Eight’s intent to the Commands. They are but teachings of their wisdom from the knowledge found about Nirn, the point of view is as I envision from my time upon this world. By the Free Will given by the Eight, you can decide to what level you also believe in the following wisdom presented.\n\nPRINCIPLE ONE: Work Hard and The Eight will Prosper You.\n\nScripture tells us the Eight will bless ‘By participating in creation,’ if you are faithful to the Eight and adhere to the Commands. You see, a lot of people can have a great idea, but they never do anything about it. The first principle is the importance of working hard at something you believe in. It is easy to have an idea. But it is another thing to commit time and effort to it.\n\nCareful not to get lost in the sea of misguidance. If we allow negative influences of others to stop us, then we will never accomplish anything. The truth is, most people are always ‘waiting to begin,’ but few ever actually get on the pathway to success.\n\n'But if the Eight want you to succeed, won’t they bless you regardless of what you do?'\n\nThis is one of the misunderstandings that we often have of the Eight. You see, the Eight do want to bless us. But they will only bless what we put our hands and minds to in their name.\n\nI once heard the words from a wise priest ‘Thank Zenithar for the gold in your purse, but remember he is also responsible for the holes in a beggar's pocket.’ those are strong but incredibly wise words. The Eight want us to understand the importance of diligence when it comes to faith.\n\nBasically, seek the Eight, follow the Commands and decide what you want to do, and then do whatever it takes to make it happen. If you do this the Eight will bless whatever you do."
                },
                [2] = {
                    "By Sitemius Gariulus, Knight of the Eight\n\nPRINCIPLE TWO: Prosperity is Connected to Soul Prosperity\n\nI remember a line from the Precepts of our holy Stendarr ‘Do not hoard wealth or indulge physically’ words used often by priests during sermons. These priests are not wrong, but perhaps can sometimes faulter on what wealth the Eight were talking about.\n\nBe it material or spiritual wealth. What the Commands try to teach us is just like others of wealth. We have got to humble ourselves and get down on our knees to make it through life successfully… and please the Eight. Only then may they receive the comfort and healing of the Eight and may give thanks for their manifold blessings.\n\nSo, what about the merchants that are simply gaining profits at the expense of the people?\n\nThese are the same individuals that fail to utterly understand the ideas of real enterprise. You see, when a merchant sells a product or service to a customer, then as long as it is ethically done, everyone wins. The customer wins because they can now use the new product to make their life better. The merchant wins because they have made a profit on valuable product that they have offered.\n\nThis notion that wealth is wicked is simply a lie. In the sacred scriptures, the Eight not only encourage prosperity, but they also promise it. ‘Work hard, and you will be rewarded.’ But...\n\nBut with one condition. The Eight promise wealth to those people that love them and keep the Commands.\n\n‘If only each man might look into the mirror of these Commands, and see reflected there the bliss that might enfold them, were he to serve in strict obedience to these Commands, he would be cast down and made contrite and humble. The obedient man may come to the altars of the Eight and be blessed, and may receive the comfort and healing of the Eight, and may give thanks for his manifold blessings.’\n\nThe merchant that makes a profit at the expense or suffering of the people does not follow this and as such will suffer for such wicked actions."
                },
                [3] = {
                    " MYSTERY\n\nScion of Aldmeris, proselyte of the secrets paramortal, He of Alinor, life-extended ManniMARCO witnessed AKHAT lashed and bound by oath of Al-Esh and in defiance break. Magnus rose in the eastern sea when whispers told from the filthy lips of Man, not Mer, as those of the Ape-Man-Cult despised Aldmeri stock, unveiled unto Him the ultimate destiny: Not life eternal, not power limited to flesh and soul nearby, but a fate prescribed unpleasantly in words not accustomed to feeble minds: \n\n‘AE NEAKA AEDRA PADHOME AURBIS AE MAKHAT’\n\nThe words-not-words spoken into His memory were begotten by Mnemo-li, who as AKHAT yelled cried for her brother-father to be freed.\n\nMnemo-li wept tears of light, and ManniMARCO beseeched the vicissifiers of the sixth element, hidden from the light and law and eyes of Arkay, God of Birth and Death, where they perform upon subjects decayed and deceased experiments of everlasting change and rebirth to profane the Wheel of Life.\n\nTherein, the flesh-benders and soul-binders revealed unto scion MARCO the first secret of un-time, and with this secret he broke his own Dragon day-and-night for year and decade and century and millennium, until Mnemo-li wept enough to mend her brother-father’s scars of lash and false oath.\n\nGiven life unbound by the Dragon, ManniMARCO travelled north and west into the bay ridden by slug-famine, and after growing bored and careless with studying the weak and sick, travelled further west still. It is there, deep in Dagger Fall, where He is confronted by the apple-glutton Sload necromancers, the biggest and slowest of which made his presence known like so:\n\n‘You are lost, little Alt-mer-kin, and are of no use to myself and my brother-necrolytes. Turn and leave now, or suffer before you meet your Auri-El.’\n\nAnd the Sload raised a ponderous hand, and bit through an apple, and spoke again:\n\n‘Your magicka will not work in our presence, for you see, we are most adept in the bending of currents both Aetherial and Pad-ho-me-ic.’\n\nAnd as the Sload began to move their hands in slug-like manners, MARCO, scion of Aldmeris, spoke unto them a proclamation:\n\n‘I am ManniMARCO, greatest scion of Aldmeris, and I curse your power like so:’\n\nAnd ManniMARCO spoke a curse of un-life and flesh, and bestowed upon the Sload’s cherished apple-treats countless worms from the earth and within. The Sload-kin laughed, amused, and one laughed so grandly he choked on the apple-worm he consumed not long ago, for the worms began to feast not on earth, but on flesh, and upon seeing their brother-necrolyte wither, the Sloads laughed in the face of MARCO: Not in offense, but pseudo-selfish amusement. With elephantine flourishes they bowed as well as their engorged bodies would allow, and bestowed upon MARCO a new name:\n\n‘We care not for your name, Worm-maker, but for your act.’\n\nTo which MARCO pondered what he meant.\n\n‘You, Worm-maker, show aptitude in the unmaking and remaking of life and the profanation of Ark’ay. Travel west and into Thras, and We the Sload will give you knowledge over all life and death.’\n\nThe Sload-brother-necrolytes did not wait for an answer, and invoked ancient yet well-known Magicka to disappear to their coral-hovels far away.\n\nThen MARCO pondered their query for long days and nights and followed them into Thras to learn the second secret of un-time.\nMagnus set in the western sea and RKHET shone in the sky and taunted MARCO."
                },
                [4] = {
                    " CHIRAL\n\nOver the course of the next centuries and decades and years, ManniMARCO well-used the secrets of Sloadkin to further His knowledge of the soul and vestige both mortal and daedric. Every night in the waning hours of RKHET’s light He toiled at the flesh and spirit of the dead both recent and long-gone and as a master of the Work and timeless He came to understand the truth of the immortal soul of the lesser beings: like with the spirit of animal, bound by primal law to be hunted by those more sapient, the alive are hunted by the un-alive, by the immortal, by the timeless.\n\nWith this wisdom He began the second Work of un-time: His spirit was forever, but his body, meric as it was, waned with every passing decade or two. To be immortal was in reach, and in order to complete His work, only some secrets needed to be discovered.\n\nFor this ManniMARCO travelled far west and north, deep into the mountains of the high rock, where Magnus shone bright all day until he set. He searched for a being more ancient than He, known as the Underking. Once before He met him in life, when he was a fox enfeebled, and before he changed his face and name. With words of magicka and communion with spirits padomaic bound under paleonymics not ever uttered since, He discovered the lair of the Underking, and as he entered and made himself known, the Underking vexatiously responded:\n\n‘Leave now ManniMARCO, for I will never forgive you for your misdeeds. Under my honour as king of ash, king of magicka, king of battle, I allow you to leave unharmed.’\n\nBut ManniMARCO remained where he was and dared enter into the darkness of EROKII, the city under a tower misconstructed, and was met with the heartless Underking himself:\n\n‘You violate my sanctity necromancer, and ignore my warnings like a fool. I let you live when your Auri-El was weakened, but not today.’\n\nAnd the Underking extended his hand and cast upon ManniMARCO a spell of death and malaise, and with his great power, slew the scion Worm-Maker.\n\nBut MARCO rose again, not in body but in spirit, and cursed Dragon-Breath in kind with a secret of Thras, and as the Magicka around them faded and He still stood in spirit, agreements were reached.\n\n‘You cannot slay me in your form and I cannot slay you in yours. I subscribe not to your idiot-notions of godhood for I have come close and never reached it.’\n\n‘But you are timeless like I but physical still, so give me this knowledge and I will leave you in peace forever more.’\n\nSo the Underking pondered this offer and began to write the third secret of un-time into a book, and said:\n\n‘The day you betray my trust again, this book will burn, and with it all its secrets. Understand this as your only oath, Worm-maker.’\n\n‘So it shall be, great Underking’, placated MARCO, for he knew that he was one step closer to his ultimate fate. With His spell lifted, the Underking kept his word and invoked powerful magicka to return MARCO to his body, and unbound his soul to let him roam free. He returned to Cyrod and within a city Ayleid began his work, and as he began his ascension to a form new RKHET struck down his machinations and artifacts and spoke upon him a cursed holy spell:\n\n‘MANNIMARCO NA RACUVAR AV ANYA AS ELRKHET’\n\nAnd MARCO was burned by the law of the great Enemy and decreed in kind:\n\n‘A NAE NENAGAI MANNIMARCO! HECULRKHET GARAUVOL NA AN AUTARACU! AE ARPEN MANNIMARCARAN, NAGAIARAN!’\n\nAnd RKHET vanished into the waning hours of the night and retreated from the power of ManniMARCO, Worm-Maker, king of death."
                },
                [5] = {
                    "By Sitemius Gariulus, Knight of the Eight\n\nPRINCIPLE THREE: You Must Do Whatever You Can to Provide for Your Family\n\n‘Mara says: Live soberly and peacefully. Honor your parents, and preserve the peace and security of home and family.’\n\nThe Eight have but a few words on this matter as it’s more Mara’s singular domain. In that, the Eight compares a man who does not provide for his family with someone who has denied the faith. They consider him worse than an unbeliever. You must be able to take care of your love before you marry them. Once you are married, you must do whatever it takes to provide for them and a future family if such a thing happens.\n\nPRINCIPLE FOUR: See Challenges as Stepping Stones, Not as Obstacles.\n\nFirst, realize that when you stumble in life, what you are encountering are stepping stones not obstacles. You can use these opportunities to strengthen your wealth, be that material or spiritual, if you decide to.\n\nPRINCIPLE FIVE: Take Responsibility For Problems That Are The Result of Your Own Bad Decisions. Don’t Displace The Blame.\n\nWe often mistakenly give the enemy credit for things. Yes, it’s true that they love to attempt to kill us, steal from us, and destroy us. But cause and effect probably has much more to do with what happened.\n\nPRINCIPLE SIX: Trials Develop Your Character, Preparing You For Increased Blessings.\n\nThe Eight allow challenges, Tests of Faith, so we can develop the character we need to accomplish their purpose for our lives. The Eight use the challenges to make us stronger and more effective. Remember this when asking the Eight ‘Why’\n\nThese last three Principles are divided into three terms.\n\nThat which was, which is, and which will be. Let us learn from the Past to profit in the Present, and from the Present, to live better in the Future."
                },
                [6] = {
                    "By Sitemius Gariulus, Knight of the Eight\n\nPRINCIPLE SEVEN: Be Meek before the Eight, But Bold Before Men and Mer.\n\nDuring a visit to the Abbey of the Eight the monks told me that to be aggressive in business was a mistake, after all, they told me, The Eight said that ‘were we to serve in strict obedience to these Commands, we would be cast down and made contrite and humble.’\n\nWhat they just tried to describe is another misunderstanding of the scriptures. They are somewhat right, and it is true that one should be contrite and humble. But the Eight wants us to be contrite and humble towards them, not towards men or mer.\n\nPRINCIPLE EIGHT: Understand the Power of Partnership\n\nThe Eight have made us Lords and Priests, so what does that mean? The Eight have designed a special relationship between businessmen and the leaders in the church. The power of partnership between the merchant and the clergy. There is a tugging on the hearts of every one of us to have a closer relationship with the Eight. One way this is done is to be partnering with the priests who have been given a vision by the Eight. In turn they provide the provision to see that vision is fulfilled.\n\nI leave you with a few small quotes I have used several times when questioning my faith or the actions of others.\n\nWith faith, discipline and selfless devotion to duty, there is nothing worthwhile that you cannot achieve.\n\nThe secret of discipline is motivation.\nWhen a man is sufficiently motivated,\ndiscipline will take care of itself.\n\nMost of us do not mind doing what we ought to do when it does not interfere with what we want to do, but it takes discipline and maturity to do what we ought to do whether we want to or not.\n\nIf you wish to improve who you are. You need to stop comparing yourself to others, for you never truly know who they are. Instead compare yourself to you from yesterday. This way you are always improving you and not making yourself someone else."
                },
                [7] = {
                    "When discussing the Daedric Princes, the question often comes up, “If the Eight Divines are superior in knowledge and power to the Daedra, then why do they allow the Daedra to continue to exist and spread their lies? Surely it would be better that they be destroyed or banished somewhere where they could have no contact with mortal beings.” \n\nNow, a Daedric Prince cannot be destroyed, but if the animus of one were sealed into a soul gem and that gem sent far from Nirn, or perhaps even split into fragments as in the Banished Cells, and the soul gems holding the fragments scattered, we would not be likely to hear of that Prince again. While destruction is inconceivable, neutralization seems well within the powers of the Divines. However, I am convinced that this question shows a lack of understanding of the ultimate function of the Daedric Princes, and the reasons why the Divines continue to tolerate them. \n\nA rough but perhaps useful analogy is provided by the behavior of mortal princes toward criminals and criminal activity. Nearly every large city in Tamriel has an Outlaws’ Refuge, which is supposed to exist in secrecy. However, these Outlaws’ Refuges can be easily accessed by the average citizen, and their “secrecy” is a sham. Why do mortal princes close their eyes to them and permit them to continue to exist? Wiping them out would be an easy task for the average city guard detail. Surely, the naïve observer thinks, it would be better to root out all traces of illegal activity, and pursue suspected criminals whenever possible. \n\nThe answer that the wisest and most cynical of mortal rulers would give to this question might run along the following lines. \n\n“Yes, by wiping out the Outlaws’ Refuge, I could capture a number of criminals at once, and temporarily reduce crime. But what then? Would criminals magically cease to exist? Crime is a fact of life. The criminals would return, and organize themselves again with more care for their own security. Then they would be much harder to destroy. Or they might come back without any organization or order at all, and thus without any way they could be dealt with as a group. \n\n“If there is an Outlaws’ Refuge, my agents know where to go and whom to speak to if there is a real problem with crime. They can recover precious stolen objects quickly, by ransoming them, and by hints and warnings diminish the activity of the criminal community when this activity is becoming too much of a burden. But most important, traitors and conspirators against my rule are not able to circulate freely among the criminal classes. \n\n“It is not possible to have a society without crime, and I would rather have my criminals loyal to my rule and under a certain amount of control than to lose touch with them and have them operating without any restraints at all. However bad organized evil may be, formless, unpredictable, uncontrollable evil – chaos – is certainly worse.” \n\nThe two cases are not entirely the same. The greatest difference is that unlike an Outlaws Refuge in the territory of an earthly ruler, the realms of the Princes shelter and encourage the open enemies of the gods. However, this is balanced by the utter futility of plotting against the Eight; unlike mortal rulers, they cannot be overthrown or their power compromised. \n\nThe Princes thus serve as collection and focus points for mortal weakness, heresy, and evil, in the process making those who suffer from such flaws more predictable, easier to locate, and ultimately easier to manage. \n\nOne might even see the Princes as unwitting quality control managers for the Divines, testing mortals for hidden weaknesses, as is expressed to a limited extent by the Dunmer doctrine of the Four Corners of the House of Troubles. \n\nAnd we should not forget that the repeated failure of their grand enterprises, and the contemptible pettiness of their lesser endeavors, is of great value in convincing mortals that the Divines are supreme and not the Princes."
                },
                [8] = {
                    "It is commonly asserted, especially by their cultists, that the Daedric Princes are more powerful than the Eight Divines. This is often supported by the assumption that the Eight Divines were weakened by their creation of Mundus, and withdrew from the world. \n\nI believe this to be a very dangerous error. I believe the Eight Divines to be far more powerful, and fully capable of making their will prevail over the Princes, when and if they wish. I also believe that they are immediately present in the world, and indeed, within us and everything that goes to make up that world. \n\nLet us draw an analogy with the mortal world. When we are judging how powerful a mortal being is, do we assume that because that mortal has done some great work, he or she must thereby be weakened by it? The very idea is ridiculous. We do not believe that someone who successfully turns a swamp into a plantation has become weaker, no matter how exhausting or expensive the effort; he or she has become stronger, even if the project temporarily drains his or her store of energy and ready money, because of the potential of the lands he or she has brought into production. Sacrifices in the present are the seeds of rewards in the future. \n\nThus it has been with the Eight Divines. The world, in all its variety and power, is THEIR creation, and the power that it embodies is still THEIR power. To say that the Divines are weak because they are not constantly intervening personally in life on Nirn and performing magic tricks to dazzle their followers turns the real situation on its head. They have provided us with something much more real and reliable than any petty Daedric sleight of hand: Nirn, the world in which we live. \n\nThe gifts and blessings of the Divines are all around us; they are vital to our existence, but so commonplace that they often escape attention. We cannot free ourselves from them even if we wished to. The cultist who argues that the Princes are stronger paradoxically exists in a world crafted by the Divines, one that the Princes could never have created. The Divines serve the mortal races with each harvest, each rainfall, each dawn and dusk. They do this impartially and reliably, with no need of special supplication or sacrifices. This shows a power far beyond what any of the Princes can wield; a power that is moreover dedicated to growth and life, while most of the Princes are capable of nothing but perversity, disease, and death. \n\nNegative power, such as that the Princes wield, is always secondary to the positive power that the Divines hold. This is a matter of simple logic. Evil has no independent existence; it is merely a limiting or distortion of the Good. It is thus dependent on the prior existence of the Good to take form, and would become meaningless and empty if all presence and knowledge of the Good were to disappear. While Good could conceivably exist independently of Evil, Evil needs Good to manifest itself. In short, Evil is parasitic on Good, and the Daedric Princes are parasitic on the Eight Divines. \n\nIt might be objected that the Daedric Princes have also created realms within the boundless reaches of Oblivion. However, “created” is certainly the wrong word here. They seem to have merely commandeered some pre-existing territory, and bent it to their various purposes. (Meridia may be  a special case here.) \n\nNone of these realms approach Nirn in variety and splendor, and none is a cooperative effort with other Princes, as Nirn is a cooperative effort between the Eight Divines. Most are simply an embodied extension of the ruling Prince’s obsessions, usually to an absurd or horrifying degree. None have Nirn’s balance, not even the most friendly that we know of, Azura’s Moonshadow, which still half-blinds visitors with its extravagant beauty. But Moonshadow is an outlier; Coldharbor is a more typical Daedric realm. We all know how well Coldharbor embodies the icy malignancy of Molag Bal, as well as his nihilism, in its freezing weather, ruined structures and broken residents. His perversity is perhaps best expressed by the endless cemeteries and tombs found there, in a realm where nothing at all is permitted to rest peacefully in its grave. \n\nThe superiority of the Divines and the world they created is also proven by the obsessive interest the Daedric Princes have in Nirn. It is very rare, perhaps completely unknown, for a Daedric Prince to attempt to conquer the realm of another Daedric Prince. Why should they? In the end, all their realms are characterized by a relentless focus on the particular obsessions of the ruling Prince. A Prince wishing to expand his realm would do better to incorporate another piece of boundless Oblivion and shape it as the Prince wills. But they are all fixated on Nirn, whether in the cause of complete conquest, as we saw in Molag Bal’s recent attempt, or petty interference, demonstrated by a multitude of cults. \n\nI think this obsession shows that even the Princes are aware that Nirn is not merely another part of Oblivion. It is raised far above that status by its connection with the Eight Divines, and is superior in every aspect to the Princes’ own realms. It is not just worshipers that they seek by meddling in our world, because if their sole wish were to hear a chorus of praise, they could create as many daedra as they wished to sing it endlessly. They want to possess Nirn, or at least some small part of it, not only because of the intrinsically parasitic nature of Evil, but because Nirn embodies the power of the Divines, a power which they forever envy, but can never hope to equal."
                },
                [9] = {
                    "A sermon by Light-in-Darknes, acolyte of Sithis the Changer\n\nI know well that you dread and avoid Sithis. I hope you will dread less, after I have spoken. I do not blame you. You misconceive Sithis, and I have no right to look down upon you, for my people did the same for many years, and we had much less excuse for the mistakes we made and the unnecessary pain and suffering we caused. Some of us are still lost in error, but some know the truth, and this is what I hope to bring to you today.\n\nAlmost certainly, you think of Sithis as a death god and the lord of the Void. The second is accurate, but the first is not. We in Shadowfen and Murkmire made the same error for ages, and worshipped Sithis with blood and fire and all sorts of horrors. But after the great change in our civilization, what we call Duskfall, many of us are on a more correct path. \n\nTo call Sithis a death god is denigration, a concept that diminishes Sithis from his true form and role. Death gods are always negative and petty, but this has never been the role of Sithis, who was the Power who brought change and growth to the cosmic order. All beings have limits, and when the gods created the cosmos, they showed the limits of their understanding by creating a perfect and complete order. This order was as glittering but as dead as a crystal. How can there be change, movement, and growth when everything is already perfect? Although the gods did not realize it, this was the true death, stasis without change, a beautiful, perfect, eternal nothingness.\n\nIt was Sithis who rescued the cosmos from this sorry fate, created by the idealistic limitations of the Divines. Sithis brought forth Lorkhan, who stirred the cosmic pot, breaking and shaking and rattling the too-perfect pieces into movement away from, and towards, a renewed perfection that they will never fully attain. Sithis, the supposed death god, brought the worlds to life and inspired the creation of Nirn, whose freewilled inhabitants guide change as their choices determine which of the Many Paths will become real, and drive history and time itself forward.\n\nSithis is indeed the lord of Death, but this is only one of his aspects. It is far better to think of him as the Lord of Change, the Lord of Life-Growth-Death-New Life. A lord of death would be helplessly dependent on other forces, since how can anything die that has not first lived? Death is but one change of many, and so we call Sithis the Lord of the Circle, the endless circulation from life to death to life, with none of its changes more important than any of the others.\n\nThis is why the Daedric Princes and their minions fear Sithis. They are locked in an eternal stasis, denying death and refusing change, a fate that even the Aedra have accepted in theory. They cannot grow, they cannot ever be different in any way, and Sithis does not welcome them when they make one of their periodic appearances in the Void. They are persistent fragments of the old error of the gods, and extremely tedious beings to deal with.\n\nAnd the little “Sithis” of the Dark Brotherhood? No more than one of Prince Mephala’s practical jokes on humanity, and like most of her jokes, a lame and failed attempt at humor."
                },
                [10] = {
                    "Deep in the dragon-haunted mountains, there is a small old temple. Its name is Tears of the Twilight. The only object on the altar is a shattered mirror, stained with blood. One priest lives there, tending the temple and waiting for the occasional supplicant.\n\nLong ago, Azura, the Lady of Roses, came down to earth and took human form. She was driven by the desire to have a soul, and bore children while in human form. But although all her children had souls, she still had none.\n\nShe finds a superbly handsome young peasant, and pursues him. But he will not say she is beautiful. He gives her all other praise, but not beautiful or attractive.\n\nShe persists, a little angry, but also curious. After all, why would anyone refuse a consequence-free all-nighter with a goddess?\n\nHe explains that to him, beauty and attraction only hold true between equals. She can never make him a god, nor can she make herself a human being. Any connection between them would be temporary and thus inevitably tragic.\n\nHe then asks her what she truly seeks. She explains. He is sympathetic, but he cannot remove a barrier that was set in place at the beginning of time. Perhaps, he says, this is how the Aedra have punished you for not going with them at the very beginning.\n\nDespairing, she begins to cry, and he comforts her. We are closer joined by sorrow than joy, he remarks.\n\nShe replies, For this night, I will take you outside time, and you will remember nothing of it, or of me, when the sun has risen. \n\nHe bows his head. No saying no to a desperate and powerful goddess. It means so little in the end, she admits. To be held one night, and then to part forever. But I grasp at what straws I can, or I will go mad.\n\nHe bows his head again. That would not be good. He consents.\n\nShe disrobes and exposes herself to him. Look well and without fear, for when the sun rises tomorrow, you will remember nothing of this. But you will suffer nothing either. The memory, and the suffering, are for me alone.\n\nThe dim hours of morning, Azura’s hour. He lies asleep, exhausted. Azura, still disrobed, smiles sadly down at him. She bends and kisses him on the forehead, removing all memory of the night. He will wake in a few hours, with only the sensation of an unusually refreshing and dreamless sleep.\n\nShe smiles again and raises her hand, casting a spell on him that will give him this boon all his life. In memory of she whom you will never remember, she whispers.\n\nShe dresses again, reluctantly, not using magic. She wants the feel of each piece of clothing as she resumes it, though she could command them all to be on her in an instant. But that would not be right. She is still in the human world, barely, in her twilight hour of dawn, and will respect its regularities.\n\nDressing, she catches sight of herself in a mirror. She approaches, looking into her own eyes, searching for the spark of a soul that will never be there, even though a new soul is quickening in her womb as she looks.\n\nIn a sudden fury of despair, she lashes out, smashing the mirror with a blow from her hand, cutting herself and bleeding, since she is still mortal. She grimaces with pain, and then, as her divine powers return to her, heals suddenly. But the mirror remains shattered and bloody.\n\nShe picks it up and looks into it, a thousand fragments of herself looking back.\n\nYears later, a young woman comes calling at that house. The man has married a worthy mate for himself, and is a prosperous farmer with children. But he knows who his visitor is as soon as he looks into her eyes. It is his daughter.\n\nHe takes her to the stable, where he has stored the broken mirror, and gives it to her. She takes it, and bows to him and his family. In silence, they part.\n\nShe founds the temple and dedicates it to the loves that are impossible and the beauty that is unattainable. Any lover who looks into the broken mirror will understand when his or her quest is hopeless, and be comforted by the knowledge that he or she is not alone. But very rarely, the fragments will seem to come together into one again. Then the worshipper will know that despite all appearances, their quest is destined to succeed.\n\nThe young woman, Azura’s daughter, tends the temple all her life. Toward the end of her life, she is joined by a young man whom she knows is her brother, and passes the temple on to him.\n\nAnd so it goes down through time, sibling to sibling, Azura’s mortal line passing through time while their mother watches sadly from Moonshadow and quietly wishes she could trade all her divinity for the power to stay with one of the fathers, grow old, die, and join him and all her mortal kin in Aetherius."
                }
            },
            [9] = {
                [1] = {
                    "For too long, I have played the fool, but the time has come to end the King's rule.\n\nMy revenge will be the game, as everyone's fate will be the same.\n\nThe Jester's life was comical and tragic, but now I have learned dark magic.\n\nMy tricks and pranks will make matters worse as the royal court suffers the Harlequin's Curse.\n\n-Ace of Jokers, Royal Jester to Sheogorath"
                },
                [2] = {
                    "by Gaerlyn Vernon\n\nDeep in the part of Valenwood known as Grahtwood, there is a Ruin of Ayleid origin within a few days of walking distance from Elden Root. This particular Ruin is believed by many to be \"Sunder Root\", which is of quite legendery renown when it comes to Ruins. The tale tells that the Ayleids of old wanted to secure a foothold in Valenwood, but in order to ensure their own survivival against the hostility of the forest, they attempted to subdue it. Presumably they succeeded in trapping the forest's very essence, it's \"heart\", within the bowels of Sunder Root. If the legends are to be believed, they even enslaved it to do their bidding and could command the forest to shape itself within the city to suit their needs.Over time, the heart managed to break free and lashed out against the Ayleids. From there on out, \"Sunder Root\" became a whispered tale, to be almost forgotten by time. \n\nCenturies later the said ruin was discovered by the Bosmer and explored by Altmer scholars, or at least, so they claim. The Ruin was never proven to be Sunder Root, and if it was, it had returned to a deep slumber ages past. Whatever the truth, many scholars in recent years, who aren't scared off by Valenwood's hostility, still try to conclusively answer the question whether the Ruin is or isn't \"Sunder Root\".\n\nOne tale about this very ruin does stands out. In the late 3rd century of the second era, a group of Wood Orcs entered the Ruin, presumably for shelter or to avoid Bosmer patrols. They were eight to enter the ruins, but only one of them emerged alive, albeit crazed with terror. When he was captured by Rangers and interrogated, he stated the following; \n\"We woke the darkness that lay beneath... a creature born of pain and nightmare and it hated us before it even laid eyes on us.\" \nThe Rangers asked if he was the only survivor, and if he did in fact see his companions get killed with his own eyes.The orc responded;\n\"Killed them? It didn't just kill them, it teared out their very soul and flayed it... it devoured them piece by piece... if anything of them remains, it no longer wishes to exist.\" The rangers pointed out there never was any monster of that kind, and certainly not in that dusty old Ruin.\n\nNot much else could be discovered from the orc's testimony. However, the Rangers did find dead orcs in the ruin, roughly four or five bodies in very bad shape and an exact bodycount proved to be difficult. The reason the rangers captured the orc to begin with, was that a nearby Bosmer village had been attacked a few days prior, leaving nearly no survivors. It turned out it had been ransacked by Wood orcs, and the rangers determined the crazed survivor was amongst the assailants.\n\nThe Orc was to be condemned for his crimes against the Bosmer people, but ended his own life before the sentence was pronounced, the last thing the orc said was this;\n\"The Shadow punished us for our sins... we broke a smile that should have been left unbroken\".\n\nThe next day he was found dead in his cell.\n\nIn short the moral of the story became; Respect the Green and the bosmer people, or the forest's Shadow shall take you. I myself am curious as to the nature of this \"Shadow\". There are several tales from all around Tamriel which describe a similar creature, but no such monster has ever been documented. Is it a singular being? Are there several? I will attempt to find conclusive proof of this story being little more than just another horror story. The evidence is there, at different times and in different places, we just need to find it. When one looks for them, patterns emerge."
                },
                [3] = {
                    "By Rebekah Meilan\n\nThis story I'm about to tell, is a folklore tale, originating in Glenumbra during the 28th Century of the First era, nearing the dawn of the second Era. After reading and hearing all versions of the tale, I believe I can tell it in such a manner that it will reflect each tale's narrative sufficiently, as to stay true to each version. The tale goes as follows:\n\nA small village in Glenumbra, whose name has been long lost, was subjected to a brigand attack, none of the villagers knew where they came from, since no-one had heard tales of marauders or attacks in the area, which would be expected if such a large number of brigands had settled in the town's surrounding woods. And yet they attacked in considerable numbers, while taking on the villagers completely off-guard.\n\nThey butchered most of the town's inhabitants and kept a reasonable number of women alive as an entertaining commodity. One of the women, a fair maiden named Alira, who would have been valued a great deal by the brigands, escaped and ran in the woods through the night. She was persued by a hunting party of the attackers, but luckily she knew these woods very well, and came here very often to converse with her friend.This friend was a Wyrd Sister, better known as a Witch of the Wilds. Alira loved the strange and mysterious tales her friend told with a passion befitting Bosmer spinners. \n\nEventually, after a long pursuit, Alira lost her advantage as the woods she stumbled in weren't familiar to her anymore, but she did manage to find a cave entrance below a great oak and decided to hide within, hoping not to be found, and if she was, her persuers would probably hesitate about going in themselves.\nShe simply hoped there wasn't any good reason to fear this place, for she could not afford the luxury of hesitation. Advancing deeper into the cave, she discovered a circular room, the ceiling was being pierced by the Oak-tree's roots and let in a small ray of dawn's light. In the center of the room was some crude primal Statue depicting a cloaked man. In front of the statue were three big Stones with engravings etched onto their surfaces.\n\n\"Here the dreamer sleeps, \nif thou wakest him with a dream, sweet and soft, thou wilst live a tale of dreamt wishes come true.\nif thou wakest him with a dream, sour and harsh, the Demon shall raise Nightmares into hearts, and blacken the forest to marsh.\"\n\nAlira knew the tale of the dreaming demon, who in his slumber, often forgot how to distinguish dream from reality, and the forest got confused aswell. Sometimes, as a response to the demon's dreams, the world around gets shifted in some ways. The demon supposedly dreamt the dreams of others and mistook them as his own, this could potentially wake the demon from his slumber. At least that's how the story had been told to Alira. Up until now she took it for a local folklore myth...\n\nNow, she secretly hoped that she was wrong.\n\nFind the next part of the story in the Second Volume"
                },
                [4] = {
                    "by Rebekah Meilan\n\nThe tale, as it was told to Alira, was that if your dream was being dreamt by the demon, you could follow your dream, like a trail, back to his resting place. As for how the trail ends, Alira was never told, she might just find out today, Alira thought to herself.\n\nShe tried deciphering the other engravings and what she could make out was that, if ones soul is earnest and deemed worthy by the Demon known as \"Ey'ka-thain\" he would awaken to offer a bargain which goes as follows; \n\n\"To make a pact with Ey'ka-thain, he must choose to bind himself to a pure soul, and the supplicant must in turn choose to bind his soul to the Dreamer, forever intertwined. Ey'ka-thain shall fullfill all of the supplicants wishes and desires, whether benevolent or nefarious, but when the soul of the supplicant is to move on, it will join the Demon in his dreams forever.\"\n\nTo Alira it was obvious this was a soul-binding ritual and the Dreaming Demon was likely a Daedric entity, harvesting souls for services rendered. But Alira did not hesitate, this pact could save her loved ones back at the village and they suffered for every second of hesitation she might have.\n\nShe pleaded to the Cloaked Statue, hoping this wasn't just a fairy-tale. She talked to it and explained why she needed this pact, for otherwise, all was lost. The statue did not move, However, after a moment, at the back of the cave, the wall seemed to crack and fissures soon appeared.\n\nFrom the cracks, liquid shadows poured out until two glowing embers pierced the darkness, these were the eyes of the demon, burning like incandescent coals.\n\nThe creature that stepped out of the Shadows was a towering, thin, nightmarish creature with a red gaze, as if there was molten metal burning within it's eyesockets. Alira felt primal fear rise within her, but she did not move as the Demon approached. \n\nIn her mind she heard a broken voice.\n\n-\"Do you... accept... the covenant?\"\nAlira nodded as a tear rolled down her cheek, and answered with a trembling voice \n-\"Yes, I accept... I give you my soul if you fullfill my wish and save my loved ones.\" \n\nThe demon remained impassible and silent for what seemed like an unsustainable amount of time to keep peering in it's eyes... until finally, she heard it's answer\n\n-\"You misunderstand Child... Your soul is not part... of the pact... I give you mine... not the other... way around.\"\n\nThe young woman was perplexed and sceptical. She was frightened to offend the demon, but had to know.\n\n-\"What is the catch? There has to be more to it than that.\" She asked while trying to muster all the courage she could scrape together. \n-\"There is... You must accept to ...bind my soul... to yourself... Most wouldn't willingly... bind a demon ... to themselves... especially not... a pure soul... That... is the catch.\" Replied the Demon.\n-\"What about when I die?\" Asked Alira.\n-\"You will join me... in my waking dream... a dream so vivid, it could be real... your soul however... would go... to wherever it is supposed to go... where I cannot follow.\" Explained the Demon, again in her mind.\n\nAlira knew deep down this was probably a trap but did not care, realizing full well she will end up caring eventually, but for now she knew what must be done.\n\n-\"Very well, Ey'ka-thain, I bind our souls together, but please make haste.\" Said Alira. The demon approached her, took her right hand with his clawed paw and laid it on his chest above his heart. The skin beneath her palm was cold as ice. \n-\"I will require a portion of your strength... which might leave you weakened for a time... but by duskfall, your loved ones will be free.\" Said the demon. Alira nodded and felt her strength fading instantly. As her vision blurred and she started to faint away, she vaguely noticed the demon's shape shifting...\n\nWhen she woke, she was on a bench in her hometown, dawn was rising and the whole town seemed silent. Still woozy, she walked down the streets and soon heard voices... voices she recognized. The town's women were free and there weren't any bandits in sight, not even corpses except for those of the murdered townsfolk. \n\nShe greeted her friends with laughter and cries. The survivors explained to Alira that the night got unnaturaly dark at one point and screams were heard everywhere. Torches could only push away darkness for a mere few steps, so nobody could make out what was happening. When the screaming ended, every bandit in town had vanished without a trace.\n\nAlira suddenly looked to the shadow of a nearby building, and there she saw a silver-haired man looking from a distance. Briefly she saw a fiery glow run through his gaze, that disappeared instantly. Seeing as Alira was looking at something intensly, one of the surviving women asked what she was looking at. Alira said she looked at the strange man with silver hair, but the older woman frowned in confusion, as there was no man there to be seen."
                },
                [5] = {
                    "By The Patron of Parables\n\nLong ago, there was a Skaafin quite unlike the others. Amidst a cohort of cruelty and beguilers of bargains, he sought but one means of fulfilment: a satisfied customer.\n\nNow you may know of the Prince whom the Skaafin serve, and know that the only satisfaction he seeks is his own, and his servants were no different. This meant there was often trouble and strife in the life of the Unusual Skaafin, and it was happening to all the wrong people. At least according to his Prince.\n\nOne day Clavicus Vile called the Unusual Skaafin into his throne room in the Fields of Regret where he sat upon a mighty tree stump. \"Unusual Skaafin...\" He asked slowly, deliberately. \"Did you complete another bargain in the best interests of the mortal supplicant?\"\n\nThe Unusual Skaafin smiled proudly. \"Yes my Prince! I did.\"\n\n\"May I ask why?\"\n\nThe Unusual Skaafin scratched his head. Why was master Vile being so... not vile? \"Because-\"\n\nThe Prince interrupted suddenly and loudly. \"Wrong! There isn't any reason why! Now get back out there and make some misery!\"\n\nAh. This sounded more like it, the Unusual Skaafin thought to himself. \"Yes, my Prince.\" He bowed his head and left the audience chamber. Glancing back at the throne he noticed the Prince had already vanished.\n\n'Now what to do?' Unusual Skaafin thought hard. It wasn't in his unusual nature to disadvantage a supplicant, but he also couldn't disappoint his Prince. He needed some advice, and after some thinking he thought of the perfect being to help. His friend and mentor, the Wise Skaafin.\n\nSo off he went to find the Wise Skaafin in a remote corner of the Fields of Regret. He passed many chattering Skaafin who were talking about their latest deals and the crafty ways they had tweaked the terms to damn a mortal soul.\n\n\"The mortal asked for help to cross off a list of experiences before it died.\"\n\n\"Did you help?\"\n\n\"Of course I did. I rushed through every item on the list, and then I killed it. I think it died happy, but I can't distinguish screams of joy from screams of terror so who knows for sure.\"\n\nThe Unusual Skaafin gave the duo a look of confusion, but didn't change his pace as he continued onwards to the place of the Wise Skaafin. Eventually he arrived and knocked thrice on the door.\n\n\"Who is it?\" Came a voice from inside the ornate building. \"I'm not doing any deals today.\"\n\n\"It's me! The Unusual Skaafin!\"\n\nFootsteps shuffled towards the entrance from inside and the door creaked open to reveal an old and wrinkled daedra. Why she was old and wrinkled when daedra don't age was anyone's guess. \"Unusual Skaafin? What are you doing here?\"\n\n\"I need your advice, Wise Skaafin.\"\n\n\"Well come inside, then. I have the kettle on.\" The Wise Skaafin left the door open behind her and shuffled back inside to a table where she took a seat. \"What can I help you with this time?\"\n\n\"Oh, Wise Skaafin, I have a dilemma. I want to do my best at the job, but what do I do when Master Vile wants us to do our worst?\"\n\nWise Skaafin rubbed her horns. \"Clavicus Vile is a Daedric Prince, Unusual Skaafin. His methods are beyond comprehension. Maybe he has a long-term plan of which we are not aware.\"\n\n\"Like... what?\" The Unusual Skaafin asked.\n\n\"I don't know. It's beyond our comprehension!\" She chuckled. \"What I can say is this, you're a Skaafin, Unusual or not. That means deal-making is in your very essence. But you don't have to do it here.\"\n\nThe Unusual Skaafin furrowed his brow. \"Not... here? What do you mean? Where else would I go? Where else -can- I go?\"\n\nThe Wise Skaafin sipped from a cup that had appeared in her hands sometime while they had been talking. \"The realms of Oblivion are vast, limitless. You can go wherever you like. But without a Prince, you'll be on your own. For the first time in your existence you'll have no direction or purpose but the one you set for yourself.\"\n\nThe Unusual Skaafin pondered this. \"Set my own direction? My own purpose?\"\n\nThe Wise Skaafin nodded. \"Yes indeed. I think it's good for daedra to get out and about. See what's out there. Only way to truly know what you want out of this infinite existence of ours.\"\n\n\"Have -you- 'gotten out and about', Wise Skaafin?\"\n\n\"Absolutely I have. I've lived many mortal lifetimes outside of the Fields of Regret.\"\n\n\"But you came back?\"\n\nWith a pleasant smile the Wise Skaafin nodded again. \"I came back... It's a certain irony. I left the Fields of Regret to make sure I had no regrets.\"\n\n\"Why'd you come back?\"\n\n\"Because we always come back home, Unusual Skaafin.\" She takes another sip of her cup. \"It may be wretched, it may be... vile, but it's still my home. And I can do more good for the future of my home here than out there.\"\n\n\"I'm not sure this is -my- home,\" the Unusual Skaafin muttered thoughtfully.\n\nThe Wise Skaafin shrugged. \"Home can be many things, Unusual Skaafin. A place, a being. You'll know it when you find it. When you do, treasure it.\"\n\nThe Unusual Skaafin watched her sip from her cup again, lost in thought for a while. After a few moments he spoke up again. \"Where did you start your journey, Wise Skaafin?\"\n\nOne word was the answer, but it was enough to give him a start."
                },
                [6] = {
                    "In the City of the Dead, Nightmares wait scheming\nIn the Endless Library, I find myself waking\n\nA thousand eyes pierce the roiling sky\nI close my own but I can still feel others on me\n\n\"Curious... a useful servitor?\"\nThe sound is like nothing I have heard before\n\nThough I know not the consequences of being found wanting, I nonetheless hope it finds me so\n\n\"No. You are... inadequate.\"\nI am pulled into the ground below\nThe world spins, though it is not mine\n\nMy eyes remain shut"
                },
                [7] = {
                    "I saw a vision. Whether or not it was truth, or story-truth, or merely an empty tale I wove for my own comfort, I do not know. But here is what I saw.\n\nI saw a blasted moorland, dark and terrifying. It was the summoning day of Lord Molag Bal, Prince of Domination and Humiliation, Master of Control and Cruelty, King of Rape.\n\nI saw two women, a mother and a daughter. Both were naked and their bodies were smeared with filth and their own blood. The mother lay on the ground, for her legs were broken and she had lost consciousness. Her daughter stood over her, a tree branch in her hand and despair in her heart, ready to strike even though it would be a useless gesture that would bring about nothing but her own death and eternal torment.\n\nThe two were feckless followers of Molag Bal, who had trusted in his lies and been offered to him on his summoning day, to become Daughters of Coldharbor, chosen and honored vampiric minions. They had not been told that the degrading rites would mean death for all but one or two of the offerings. Now, raped and defiled, they looked into the Void without even enough hope to pray. Besides, who could they pray to now?\n\nThe daughter closed her eyes. There was nothing there but absolute blackness. It was the true Void, she knew, the wilderness beyond both Aedra and Daedra. But it was not empty. She heard a whisper in her ears, \"Not here. Seek not here. The Void has nothing for you. Look into yourself.\"\n\nShe opened her eyes and saw Lord Molag Bal. He was standing on top of a small hill, not far away. He had taken a form close to human, the better to humiliate them with his inhuman strength. He was laughing. She knew he was laughing at her, but instead of fear, she felt anger. They had been faithful, and he had tricked them. \"Helpless!\" he roared out, and fell to laughing again.\n\nIn her anger, the daughter closed her eyes. She obeyed the whisper from the Void, and looked into herself.\n\nBut there was nothing there. She and her mother had followed the Lord of Cruelty too long. His darkness covered all.\n\nThe voice whispered again, \"Deeper!\"\n\nShe thought back to her girlhood, her childhood. Before she had been initiated into the cult. But there was still nothing but darkness there. She and her mother had been bound to Molag Bal long before their formal submission.\n\nBut the voice urged once more, \"Deeper!\"\n\nShe forced herself down, and with her last strength, she saw a spark. She followed the spark of light, in a growing terror and despair, for Lord Molag Bal was no longer laughing. He was describing how he would torture the two of them, mother and daughter, shouting it out with the laughter still in his voice, torture them to death and beyond. Because they were weak creatures, unworthy to serve him, Lord of Cruelty, mightiest of all.\n\nJust as Lord Molag Bal boasted that he was supreme in Oblivion and Mundus both, she caught up with the spark of light. It was a torchbug. And she remembered.\n\nIt had been when she was very young. She had gone out in the evening with a friend, to hunt torchbugs. They were going home, and her friend proposed to free the bugs they had captured, to let them go. It would be cruel to do otherwise, her friend had said, and cruelty was not pleasing to Lady Mara. Lady Mara loved all creatures, her friend had continued, loved them as a great family that included all, and she was best served by mercy to even the most trivial and weak beings.\n\nThe daughter remembered that she had felt her friend's words were stupid. Did not the powerful rule the weak, even to determining whether they lived or died? What good was mercy to a bug? But she had opened her gauze bag all the same, and loosed those she had captured. One had circled her head before flying off, as if in thanks. But that was foolishness, she thought. Besides, the gratitude of small things was useless. So much had she already been shaped to the service of the Lord of Domination.\n\nHer mother was furious when she heard of the expedition. She beat her daughter, and forbade her to see that friend again, calling her a sentimental weakling who followed a weakling god. Soon, the friend moved to another town, and the daughter never saw her again.\n\nThe daughter opened her eyes. Lord Molag Bal was almost upon them. He stood at her mother's feet. His huge organ was erect and glowing hot. He laughed and told her what he was going to do now. He would rape her mother with his red-hot tool, and she would have to watch and listen to her mother scream from the pain of her broken legs and the scalding hot shaft that was being pounded into her. He would take her mother this way until she could scream no more, the Lord gloated, and then he would spray a flood of molten metal inside her and she would be burned to death and yield up her soul for his further \"pleasure.\" But not at once, the Lord added. She would live long enough to see the same done to her daughter, watching her daughter's torment in despair as her own insides were consumed. \"And there is nothing at all you can do about it, nothing that can stop me doing as I please. Helpless!\" The Lord of Cruelty all but choked on his own laughter, again.\n\nHer eyes closed. The torchbug was there, flying about in front of her face. \"Ask for the mercy you gave to me,\" it sang, in a soft clear voice. \"Ask that it be returned to you, and you will be heard. Faithful daughter, as a daughter in need, call upon the Lady of family love and witness her power.\"\n\nWithout opening her eyes, the daughter whispered, \"Lady Mara, a boon, not for myself. If not me, save my mother from the Lord of Cruelty. She is my parent. Stand between her and his filthy desires.\"\n\nA moment passed, and then a soft, maternal voice responded, with a hint of humorous teasing, \"Took you long enough. But do not fear. This is no great task, for Me.\"\n\nShe opened her eyes. It seemed that Lord Molag Bal had heard the voice too. His face expressed utter fury and contempt, but the daughter could only smile. Suddenly, the King of Rape looked absurd, ridiculous and undignified as he stood there with his organ waving back and forth.\n\nIn fury, he raised his hands to call down a firestorm of glowing rock and lava, to destroy mother and daughter instantly and absolutely. He could still settle accounts with their souls later.\n\nThere was a crack like a tree being snapped in two, and a sound of thunder. The daughter closed her eyes, not in fear but in wonder at her new absence of fear, her freedom from the Lord of Cruelty's heaviest chains. Another clap of thunder, and she opened her eyes again.\n\nMolag Bal's spell had failed. It had achieved the very opposite of its intended effect. Instead of the blasted moors of Coldharbor, they were now within a forest like those in the lushest parts of Cyrodiil. The sky was clear and blue, and the air was warm. They were near the top of a hill, and Lord Molag Bal, still naked, infuriated, and absurdly erect, was scowling up at them from the other side of a rushing stream.\n\nA voice spoke, full of laughter.\n\n\"Comport yourself with more dignity, Lord of Domination. You are a ridiculous sight, a disgrace to both Aedra and Daedra. Your tool is an ugly little thing, and I wish to see no more of it.\"\n\nMolag Bal clenched his fists in fury, and suddenly he was huge again, standing there fully clad in his armor, a tower of evil strength. He pointed with his Mace, and roared, \"Mara! How dare you interfere, weakling? If it comes to a trial, you know I will best you.\"\n\n\"Brave words, Lord of Cruelty. But perhaps your accounting of my power and yours is not entirely accurate. We stand in my world, in Mundus, not in yours. Are you sure you are familiar with all my strength?\"\n\nMolag Bal sneered at Lady Mara. \"Your power is diminished by the creation of this very world. You were drained by your creation of Mundus, like all the Aedra, and now your power is nothing in comparison to that of the Daedra. Like fools, you threw your strength away.\"\n\nMore laughter.\n\n\"Then perhaps you can come and take back your victims from me. But I warn you, it may not be as easy a task as you imagine.\"\n\n--- continued in Part 2 ---"
                },
                [8] = {
                    "--- continued from Part 1 ---\n\nThe Lord of Domination raised his Mace again, and stepped forward. Then he dropped the weapon, and howled with pain, clutching at his right eye.\n\n\"Careless, careless, Lord of Cruelty. You nearly stepped on that sparrow's nest, and to protect her family, the mother bird flew up and pecked you in the eye. Such a small thing, and yet its love gives it such power.\"\n\nShaking his head and waving his left hand frantically to keep the infuriated bird away, Molag Bal bent down to pick up his Mace again. But no sooner had he touched it than he drew his hand back with another cry of pain. Lady Mara laughed.\n\n\"You never learn, do you? You dropped your weapon carelessly, and nearly crushed a wolf's den. The mother wolf is not likely to forgive you any time soon. She will bite you again if you reach down again.\"\n\nA snarl from Molag Bal.\n\n\"They are nothing. Little things. They took me by surprise. I can kill them easily.\"\n\n\"Perhaps. But what if more come? All you will do is widen the struggle. Kill one, and another will come. Kill a flock, and another flock will come. They cannot kill you, of course. Not even banish you. But they can make you look a fool to all of Mundus, and you're rather sensitive about that, aren't you? All for the sake of revenge on a couple of mortals who managed to escape your grasp. Not a good trade, I think.\"\n\n\"I am Molag Bal, the Lord of Domination! I can prevail over them all. Their strength is nothing in comparison to the limitless might of a Daedric Prince.\"\n\n\"If it were their strength alone, perhaps. What if it is more than their strength?\"\n\nMolag Bal did not reply, and Lady Mara went on after a brief pause.\n\n\"You said earlier that we of the Aedra threw away our power. But that is a shallow and stupid judgement. We shaped Mundus with it, and there the power remains, running through the mortal world, empowering it and binding it to us the Aedra. \n\n\"We did not throw anything away. We invested our powers, like farmers planting seeds, and like the careful farmer, we gain a hundredfold when the time of harvest comes. You cannot see this because you think only in terms of domination. We do not dominate; we cultivate. Our love and care stands behind all earthly beings. The sparrow that pecked you in the eye has its own small share of the strength of Akatosh, of Kynareth, of Dibella and Zenithar and Julianos, of Arkay and Stendarr – and of me. You might be able to destroy the single bird or wolf. But can you destroy all that stand behind it? I do not think so.\"\n\nThe Prince of Domination glared at the two women on the hill, and barked at Lady Mara, \"I will have them in the end, all the same. This is not over.\"\n\nAnd with a crack of thunder from the clear sky, the Lord of Cruelty retreated to his own realm to nurse his wounds.\n\nTo the daughter's eyes, Lady Mara was nothing but a golden glow. She spoke to the glow.\n\n\"I am a sinner almost from birth, and your mercy to me and my mother is beyond my understanding. I will walk in your light from now on, though I do not know what my destination will be.\"\n\n\"It is enough. Your former sins have brought with them their own punishment, from which I cannot release you. You and your mother chose to be vampires, and vampires you will remain. No man will be able to detect this from your outward form, though those of the vampire race will recognize you as one of their own. But you will have the hunger for blood, and this you must resist. If you can serve me despite your vampire burden, and walk in the light until the end of your days, then you will be allowed to follow me after death. But if you falter, Molag Bal will take you despite all that I can do. The choice is yours.\"\n\nThe daughter bowed her head.\n\n\"Your mercy is great, and we will not fail you. How long will we be tested?\"\n\n\"I cannot say. Perhaps to the end of the world. Vampires are immortal. But it is a burden you chose for yourselves, and you must carry it to the end.\"\n\nBy now, the glow had faded, and Lady Mara stood there beside the two others in the form of a middle-aged woman, as she is depicted in her temples. She reached out and gave the daughter, who knelt before her, two robes made of a silver-grey fabric the daughter had never seen before. Smiling, she said, \"You and your mother should put them on, daughter. You are much easier on the eye that that ugly piece of work Molag Bal, but you might still be misunderstood if you walked into a town entirely naked.\"\n\nThe mother was still asleep. The daughter dressed, then looked enquiringly at Lady Mara.\n\nLady Mara nodded. \"She will rest a while longer, daughter, and wake with her legs mended and whole again. And she will know what we have said here, though you should make sure she understands by conversing with her. Her heart has turned too, because of your bravery, and she will walk with you along the road you must travel.\"\n\nThe daughter was silent for a long time. Then she asked a final question.\n\n\"We did nothing to deserve your mercy. We shut you out. Why did you hear my prayer?\"\n\n\"You resolved to die in defense of your mother, out of your love for her. That was prayer enough. We use whatever opportunities mortals give us to extend our grace to them. It does not require much.\"\n\n****************************\n\nHere my vision ended, with Lady Mara and the two mortals near the top of a hill and the sun slowly going down in the west. Perhaps the mother and daughter walk among us still. Perhaps they fell prey to temptation and were seized by Molag Bal. Perhaps Mara or another of the gods welcomed them when their sins were finally forgiven. Or perhaps the entire story is nothing but a fiction.\n\nFiction or not, I now know my own path. True strength lies with the Eight, not with the Daedra. The Daedra mock the Eight for their weakness, but as they do in everything else, they lie. The strength of the Daedra is in their own particular powers, but that of the Aedra is invested in the world itself and everything in it. There is no question whose strength is greater, or who will prevail in the end."
                }
            },
            [10] = {
                [1] = {
                    "By Caeyla Gentleflame of Skywatch\n\nAs you wander much of the regions of southern Tamriel, between the trees and green hills one is likely to see the glint of white stone. White Stone of the ruins of the ancient Ayleid people.\n\nBack home on Auridon we have similar ruins, those of our Aldmeri ancestors, which predate the exodus of the Ayleid by centuries, if not millenia, the main difference the uninitiated might notice is the yellow lighting of ancient Culanda Stones. which, like the Ayleid Welkynd Stones, are also Meteoric Glass filled with Magicka, used to power spells, traps and other such mechanisms.\n\nBack to the topic at hand, the Ayleid ruins closely resemble Aldmeri architecture, one might even say they're identical, and on a brief look, this would, for all intents and purposes, be correct. However where the Aldmeri city states were entirely devoted to the Auri-el and the Divines, with their benevolence everywhere to be seen, the Ayleids had a good number of city states devoted to the foul Daedra of Oblivion and such barbarism is reflected in their traps, spells and buildings. The Flesh Gardens are one such example of the sheer depravity of the Daedric cults that infested much of Ayleid culture altering the design philosophy from the original Aldmeri.\n\nHowever not all Ayleid constructions are such a horrific sight to see, indeed many can and do still provide benefits to those who know how to use them. This being the numerous wells of Magicka in myriad locations all across Tamriel, fonts made from Meteoric Iron and the usual white stone which can often be found with streams of blue light coming from them as they overflow with power. It is still unknown why they're placed in the locations they are, some theorise it might be due to concentrations of starlight in such locations, however due to the presence of these wells within the Valenwood and various ruins, I am almost certain starlight isn't the justification. We know the Meteoric Iron has properties which make it an extremely potent material for the forging of enchanted items. Perhaps the wells act as an unknown way to store and retrieve Magicka from Meteoric Glass crystals deep underground.\n\nHowever one such mystery remains with the Ayleid constructions, a single missing link which confounded scholars for millenia.\nThe White-Gold Tower.\nKnown as the Temple of the Ancestors to the Ayleids, the fragments of records we have of such a name also refer to it being constructed as a likeness to Ada-mantia, the Tower on the Isle of Balfiera, seat of the Direnni Altmer.\n\nThis remains an enigma because studies have shown that the Adamantine Tower is the oldest known building on Tamriel, perhaps on Nirn itself. While it matches the architecture of both civilisations, it also predates the Ayleid-Aldmeris divided by thousands of years.\n\nDid Mer truly originate on Aldmeris like all our legends and records suggest, or did the ancestors of our ancestors come from Tamriel in the earliest Dawn? Ancestors which saw Ada-mantia and thus remained in the collective conciousness of all those who share Aldmeri blood. Unless we find a way to return to ancient Aldmeris, we will likely never know for sure.\n\n[Following this passage there are various sketches and annotations comparing Ayleid and Aldmeri construction techniques and architectural designs]"
                },
                [2] = {
                    "The following fragment of text was found in a Falmer warren and translated by scholars at the College of Winterhold. It is puzzling, but almost certainly authentic.The author is presumably a Falmer, dictating to a thrall scribe, since the Falmer are blind and would be unlikely to be able to write themselves. The purpose of the writing is unknown.\n\n---------------------------------------------------------\n\n...in return for saving us from death, the Dwemer condemned us to worse than death. We will never know exactly how. Perhaps that is fortunate. But you can see that the changes were not merely intended to cripple, though they did that as well. \n\nThe mental effects, especially, were revenge for all the frustrations the Dwemer had faced at the hands of our people. To pay us back, the Dwemer accentuated the faults of our elven blood, and twisted and stunted our virtues. Our pride became an obsessive paranoia, our nobility the sharp shards of broken arrogance, our sense of purpose a burdening futility. Above all, they took the light from us, blinding us and making us fear the sun that we had worshipped – to feel its touch as a burning curse. \n\nWe squatted and scrabbled in the darkness, knowing that we had been terribly diminished, and when the Dwemer in their arrogance destroyed themselves by their insane attempt to become as gods, we felt it almost as keenly as they must have. It was their last and most ironic blow. They were gone and we were free, but we remained crippled by their hatred, and they had forever robbed us of any chance to find out how to reverse what they had done, or even to avenge our long suffering on them..."
                },
                [3] = {
                    "Respen Gengeiros \nResearch Associate, Mages Guild \nDaggerfall \n\nThe Rourken Clan of Dwemer came to Stros M’Kai after the First Council in 1E 416. There may have been a Redguard population there already. At any rate, only the Redguards remained after the Dwemer vanished in 1E 700, but their early history there is lost in the mists of time.\n\nAs one might expect, the nature of the Redguards was the same then as it is now. They feared and hated magic, and they regarded the uncannily undead activity of the deserted Dwarven ruins as something magical. They were thus very careful to keep their distance from Bthzark, and as far as possible, keep others away from it. This may have been unnecessary, because those few who did try to enter the ruins were either unable or were never seen again, presumably killed by Bthzark’s automatic defense systems. Redguard youths were often sent on strictly defined routes over the outside of Bthzark as part of their coming of age rituals – for instance, to run from one end to the other of one of the two boobytrapped bridges between the sections of the ruins. They occasionally reported coming across fresh human remains, presumably those of careless explorers.\n \nThe Dwemer Orrey of Stros M’Kai is made even more difficult to research due to an \nunfortunate confusion between two separate structures, the Orrey and the Observatory. The Observatory that the Dwemer had set up near Saintsport had been one of the wonders of the world, but with no local force maintaining and \nprotecting it, it had slowly fallen victim to those who wished to make a quick buck. By the early centuries of the second era, nothing of it remained, the last few working instruments having been stripped out and sold by the pirates who controlled Saintsport. The pirates even sold the bricks from the Observatory’s walls and foundations, claiming that since they were undoubtedly Dwemer made, they must have special qualities. \n\nAn Orrey, on the other hand, is an indoor instrument meant to model the progression of the heavenly bodies, and sometimes to use this information as the basis of projections of the future or for spellcasting. The Orrey was not in \nSaintsport. Its exact location has been lost, but the best guess is that it was within the main structure of Bthzark. No trace of an orrey can be found in the parts of the structure that have been (against considerable opposition) opened to our examination in recent years, but that means nothing. We have never seen the boilers that supply the pipes that lead up to the surface either, but they certainly exist. We have never seen the automatic repair shops that keep building and repairing Dwemer spiders to maintain and defend the upper halls. What might be buried in the depths of Bthzark, perhaps far below the surface, is anyone’s guess. All we can do is hope that if the Orrey was indeed there, it was not damaged or destroyed by the tide of molten lava that blocked and shut down the mines in Bthzark even before the Dwemer disappeared."
                },
                [4] = {
                    "Translated by Cerenthiel of the Mage's Guild\n\n(Translator's note: Despite my many attempts to translate this text fully, I cannot for the life of me figure out how to translate the author's name. I would very much like to read this Ayleid's other texts if they are out there somewhere!)\n\n[Untranslated text...] \"-and when I was approached by a distant relative of mine who so loudly was professing admiration and praise for Hyrma Mora, it had broke whatever faith I had in my kin that they would realize their foolishness. The Daedra, as powerful and as 'generous' as they may be to my people, have done nothing but drive us into depravity and misfortune. Yet have I witnessed a man or woman of my blood come out unscathed from a deal with any of them.\n\nI have seen, many times, entire families laid to waste due to some father's craving for a blessing of Mephala, or some rowdy night-dweller craving some momentary pleasures after striking their soul away towards the Blood-Made Pleasure. At the least, it is childish, to crave such temporary and fleeting boons when we our lives are long and potentially fruitful, without the intervention of some god. At the most... It is spelling our very doom, in my opinion.\n\nAlas, then, I will make leave of this kingdom. My place here was, I think, lost some time ago and I was merely too blindly faithful that my people would learn. If I am lucky, I will find a small group of my kin who share my sentiments and establish a kingdom of my own, where the Aedra can be ever-present in our lives again. If it were only me here, I could withstand it, the horror of it all, but I do not want my daughter to believe this is our norm.\n\nWe can be better this, my kin. I hope one day you all realize that before it is too late."
                }
            },
            [11] = {
                [1] = {
                    "By Naering\n\nHello again, my acorn.\n\nI hope this finds you well. And that you find it. On time. You know you're pretty terrible at stopping by to check regularly. Yeah, yeah, mangrove calling the graht-oak a tree, I know.\n\nI ventured to the roots of the Elden Tree. It's been a few years. Enthilin's jagga is still the greatest I've ever tasted, and you know I've indulged heavily since that night! I spent the night on a high branch of the Tree, watching the torchbugs flicker through the leaves. It felt almost normal.\n\nExcept for those bastards!\n\nThe High and Mighty servants of her Poncy Majesty, Queen Summerset-Face. You know what I saw them do? Cut down graht-oaks! They level the Valenwood, and what does that Camoran bastard do? Sits up on his fancy throne, just letting them trample all over the Pact!\n\nOh, I know, right now you're thinking, Naering, you trample over the Green Pact, too, you dirty hypocrite, you. But you know I've never, ever, harmed the Valenwood, you know that!\n\nI'm so angry I can barely think! I put an arrow through a few of them, though. Five, or six? Before you worry yourself too badly, they never saw me. That made me feel better. I feasted well, up on that high branch.\n\nI'll be dropping back into Vulkwasten for a spell, say, last week of Sun's Height? You know where to find me. We can have some (mediocre) jagga. You can spin me some new Spinner's tales, and I can regale you with my stories of daring tavern game victories. And there's something else neither of us has done much of, lately.\n\n\nAlways your dirty, mangy Pactbreaker,\nNaering"
                },
                [2] = {
                    "By Spinner Terelien\n\nDearest Naering,\nI cannot be in Vulkwasten at the end of Sun's Height, for my duties keep me in Valeguard for the indefinite future.\n\nMay you accept this tale in way of apology. I miss you dearly.\n\n- Terelien\n\nRest your weary arms, Children of Green. Put down your bows and spears. Rest your weary feet, and join me by the fire. For the hunt is done, and we have feasted well. Now open your ears. Open your hearts. And listen well, while I spin thee a tale of the Time Before.\n\nBefore there were Bosmer or Khajiit, there were the Forest People. And the Forest People were one with the forest, for they were also the beasts and the plants and the soil. And this was a sadness, for when everything was everything nothing could truly know itself.\n\nY'ffre walked the forest, singing to the trees and the beasts and the turning soil underfoot. And her song was beautiful and the trees and beasts wept. And their tears were cool rain that fell on the forest and gave it life.\n\nSo were they entranced by Y'ffre's song, they knew they could never forget it. But shifting form, you lose part of yourself. And the forest became confused, for it wanted to remember the song, but did not know how.\n\nAnd Y'ffre felt the forest's pain as if it were her own, because it was. And the pain was physical, because her bones came apart and joined with the plants and the soil and the beasts, and becoming one with Y'ffre, they could never again forget her song.\n\nAs bones give the body structure, so Y'ffre's bones gave the forest structure, so the plants were now plants, and the beasts were now beasts, and the soil was now the soil, and the Forest People were now the Bosmer.\n\nBut because the forest was confused, some parts of it could not resist trying to change while Y'ffre sang. And these parts were caught somewhere in the middle, part plant, part beast. And as they joined with Y'ffre, these became the stranglers, part beast, part plant, forever rooted in the earth of the forest.\n\nAnd because they were born of confusion, the stranglers could never truly understand Y'ffre's song, so they roiled with anger, and lashed out at the forest and the Forest People.\n\nBut they are of the forest, and Y'ffre sang of them sweetly, and the Forest People know them by name. So though they may do us harm, we do not harm them."
                },
                [3] = {
                    "My visit to the Outlaws' Refuge took place yesterday. I am pleased to report to My Lord that it was an entire success.\n\nI impressed on the authorities there that the level of pickpocketing in the capital is too high and the complaints about it are becoming more difficult to ignore. They promised to bring the situation under control and reduce the incidence by at least a quarter. I informed them that you might not agree that this was enough. I await My Lord's opinion on this, but I think it would be difficult for them to reduce it much more without a danger of opposition in their own ranks.\n\nI then raised the question of the sealed document that was stolen in a burglary five days ago. Without giving away the true importance of this document, I stressed that it was EXTREMELY important that it be returned, if at all possible with the seals still intact. The persons in charge told me that they had secured the document as soon as the thief had informed them of its existence, suspecting that it was of unusual importance, and that the seals on it remained unbroken. I emphatically suggested that they surrender it without further delay and without attempting to hold it for ransom, because of its sensitivity and peculiar nature. They seemed receptive, and said that they would at once forward it to My Lord through the usual channels. I thanked them for their continued loyalty to My Lord, and it might not be amiss to allow them a gratuity if indeed the document is returned unopened.\n\nWishing My Lord health and long life, I remain My Lord's obedient servant.\n\n[signature illegible]"
                }
            }
        },
        [2] = {
            [1] = {
                [1] = {
                    "Welcome to your own personal Librarium. Please keep noise to a minimum.\n\n Regards,\n    The Custodian (Alianym)"
                },
                [2] = {
                    "New Adventures section! This section contains books set out as a \"Choose Your Own Adventure\". You cannot currently write your own in this format, but perhaps in the future.\n\n Regards,\n    The Custodian (Alianym)"
                }
            }
        },
        [3] = {
            [1] = {
                [1] = {
                    "Welcome to your own little section of the Librarium. Please keep noise to a minimum.\n\n Regards,\n    The Custodian (Alianym)"
                }
            }
        }
    }
    local q = {
        [4] = {
            [1] = {
                [1] = {
                    [1] = {
                        "Written by Zenimax Online Studios\n\nOut of breath and soaked with rain, you and Razum-dar take refuge in a cozy tavern after a treacherous chase. You outran your latest enemy and, for what feels like the first time in weeks, you finally have a moment to breathe.\n\nYou’re in a back room, warming yourself by a roaring fire while Raz speaks to the innkeeper about preparing your rooms. After a few minutes, the Khajiit appears in the doorway with drinks in hand. He flashes you a smile as he sits beside you.\n\n\"That was a close one, yes? Closer than Raz is usually comfortable with. But we should be safe here, so long as we lie low, enjoying the drinks and perhaps one another's company?\"\n\n\"The innkeeper was a bit suspicious, so Raz told him the two of us are recently married, deeply in love, and on our honeymoon. The man said we make a beautiful couple, which of course Raz already knew.\"\n\n\"This one hopes you do not mind.\"",
                        Option1 = {2, "\"I don't mind.\"", points = 1},
                        Option2 = {3, "\"You embarrassed me.\"", points = -1}
                    },
                    [2] = {
                        "\"Raz knew you would approve! It will be fun to pretend, yes? Perhaps you could sit on Raz's lap to help convince everyone. Ha!\"\n\n\"At any rate, Raz is glad we made it here and that you are unharmed. It is a relief to have a moment to rest and know that we are safe after so many days of uncertainty.\"\n\n\"We should enjoy it while it lasts.\"\n\n\"Raz almost wishes we were a young married couple without a care in the world. No responsibilities. No duties to uphold. Nothing to concern our hearts with but our love for each other.\"",
                        Option1 = {
                            4,
                            "\"I'd rather soak my head.\"",
                            points = -1
                        },
                        Option2 = {5, "\"I wish that too, Raz.\"", points = 1}
                    },
                    [3] = {
                        "\"Ah, deepest apologies. That was not this one's intention. Raz assumed you would find it amusing. An error on his part.\"\n\n\"At any rate, Raz is glad we made it here and that you are unharmed. It is a relief to have a moment to rest and know that we are safe after so many days of uncertainty.\"\n\n\"We should enjoy it while it lasts.\"\n\n\"Raz almost wishes we were a young married couple without a care in the world. No responsibilities. No duties to uphold. Nothing to concern our hearts with but our love for each other.\"",
                        Option1 = {
                            4,
                            "\"I'd rather soak my head.\"",
                            points = -1
                        },
                        Option2 = {5, "\"I wish that too, Raz.\"", points = 1}
                    },
                    [4] = {
                        "\"Raz does not think there is any need to be rude about it. It is clear to him now that you are not in a joking mood.\"\n\n\"We have been traveling together for some time. Perhaps you are sick of Raz. You would not be the first.\"\n\nRaz frowns into his tankard and then takes a hearty gulp. After, he wrenches his arm across his mouth.\n\nHe puts the tankard down on the table hard enough to make the contents slosh around. Raz sighs and gives you a sidelong glance.\"Say what you will about our adventures together … Raz cannot deny he has enjoyed himself.\"\n\n\"We've had much excitement, yes? Not all of it good, but not all of it bad, either. Raz has worried through his fair share of it. You tend to be a source of distraction for him. Raz did not expect someone so stimulating, or attractive, to come into his life, after all.\"\n\n\"Hmm. This one begins to suspect his little lie about the two of us being married was a bit more indulgent on his part than he first admitted. That perhaps he has fallen for you, despite his best efforts. What do you think?\"",
                        Option1 = {
                            "End1",
                            "\"I think you look incredibly handsome right now.\"",
                            points = 1
                        },
                        Option2 = {
                            "End2",
                            "\"I think you’re an idiot.\"",
                            points = -1
                        }
                    },
                    [5] = {
                        "\"You do? Raz is surprised. You never mentioned such a thing before. He is not complaining, of course.\"\n\n\"This one will admit, he did not intend to become so fond of you, but he has. Raz often catches himself staring at your figure in crowded rooms, picturing you and him together in much… less crowded spaces. Perhaps you have had the same problem?\"\n\nRaz grins and moves his chair closer to yours. Your shoulders brush and you feel the warmth of his closeness against you.\n\nHis hand drifts along your knee, claws catching softly against the fabric there. He chuckles in your ear, sending shivers down your spine, before pulling away.\n\n\"Say what you will about our adventures together … Raz cannot deny he has enjoyed himself.\"\n\n\"We've had much excitement, yes? Not all of it good, but not all of it bad, either. Raz has worried through his fair share of it. You tend to be a source of distraction for him. Raz did not expect someone so stimulating, or attractive, to come into his life, after all.\"\n\n\"Hmm. This one begins to suspect his little lie about the two of us being married was a bit more indulgent on his part than he first admitted. That perhaps he has fallen for you, despite his best efforts. What do you think?\"",
                        Option1 = {
                            "End1",
                            "\"I think you look incredibly handsome right now.\"",
                            points = 1
                        },
                        Option2 = {
                            "End2",
                            "\"I think you’re an idiot.\"",
                            points = -1
                        }
                    },
                    ["End1"] = {
                        "\"Ah ha! Raz thinks so too, but hearing you say it excites him in a way that is most intoxicating. You are a wondrous, endlessly surprising creature, did you know that? By the Moons....\"",
                        Option1 = {
                            1, GetString(LIBRARIUM_ADVENTURES_RESTART_BOOK)
                        },
                        Option2 = {
                            0, GetString(LIBRARIUM_ADVENTURES_CLOSE_BOOK)
                        }
                    },
                    ["End2"] = {
                        "...",
                        Option1 = {
                            1, GetString(LIBRARIUM_ADVENTURES_RESTART_BOOK)
                        },
                        Option2 = {
                            0, GetString(LIBRARIUM_ADVENTURES_CLOSE_BOOK)
                        }
                    },
                    ["Endings"] = {
                        ["2"] = {
                            "Raz leans forward, closing the distance between the two of you. This close, you can smell the damp leather of his armor and see the flames of the fire dancing in his green eyes.\n\n\"Long has this one wished to stare into your eyes like this. A shame we waited this long.\"\n\n\"Of course, our adventures are far from over. Raz knows there is much in store for us still. Now, come. If we are to keep our friendly innkeeper unsuspecting, the young couple should retire to their room for the night, yes?\"\n\nRaz chuckles softly, his eyes flashing with amusement. His gaze traces your face fondly for a moment, as if he hopes to memorize you, before he stands.\n\nHe offers you his arm with a dashing grin and keeps you close to his side as the two of you climb the stairs and adjourn to your room for the night.\n\nCONGRATULATIONS!\n\nRazum-dar might be the Eye of the Queen, but you're the apple of his eye."
                        },
                        ["0"] = {
                            "Raz chuckles, his eyes glittering.\n\n\"You joke with Raz. You always know how to make him laugh, yes?\"\n\n\"You are a good friend, you know. This one is glad to have met you. Shall we drink to our adventures? Raz hopes there will be many more to come.\"\n\nRaz sits back and raises his tankard with a dashing smile. He gestures it toward you with a nod of warm approval.\n\nThe two of you drink long into the night, regaling each other with stories of your exploits and laughing so hard the innkeeper eventually has to scold you for it.\n\nEND!\n\nEven Razum-dar needs someone to count on--he's glad he has you for a friend!"
                        },
                        ["-2"] = {
                            "Raz scoffs and shakes his head, his lip curling in a snarl.\n\n\"Raz can see you are obviously not interested in his company tonight.\"\n\n\"Perhaps come morning you will have a change of heart, but Raz will not hold his breath. Good night.\"\n\nRaz stands from the table, taking his drink with him.\n\nHe stomps away to the other side of the tavern, leaving you alone by the fire. The two of you do not speak for the rest of the night.\n\nEND!\n\nLooks like you razzed Razum-dar a bit too hard and made an enemy out of him!"
                        }
                    }
                },
                [2] = {
                    [1] = {
                        "Written by Zenimax Online Studios\n\nYou stand awkwardly on a cobblestone street of Balmora as Naryu looks you up and down with a scrutinizing eye. She invited you to the House Hlaalu Masquerade Ball tonight, hosted by an important Hlaalu counsilor, but hasn’t told you why she’s brought you along.\n\nThe Dark Elf circles you once, assessing your ball attire. After a moment, she gives a satisfied hum of approval and comes to stand across from you again.\n\n\"Well, well… you certainly clean up nicely, don’t you, hero? You look divine. Every eye will be on you tonight.\"\n\n\"I know I haven’t exactly been forthcoming about what we’re doing here, but I assure you it’s all well in hand. You just need to stand around and look enticing while I work. Should be easy for you.\"\n\n\"Think you can handle that?\"",
                        Option1 = {
                            2,
                            "\"I hate running your errands for you.\"",
                            points = -1
                        },
                        Option2 = {
                            3,
                            "\"If it means I get to spend time with you, then sure.\"",
                            points = 1
                        }
                    },
                    [2] = {
                        "\"It's not an errand. It's a job that I need your help with. I've helped you in the past, have I not? I'm simply calling in a favor.\"\n\n\"Anyway, the job is simple. It requires very little effort on your part. I invited you to play a very small, but vital, role in tonight's proceedings. I trust you, and my trust is not something easily gained. So don't screw this up.\"\n\n\"If all goes well, I should be done inside an hour. Then you can relax and even enjoy the party, if you so choose.\"\n\n\"Perhaps you'll even find a dashing suitor to dance with.\"",
                        Option1 = {
                            4,
                            "\"I’d rather dance with you.\"",
                            points = 1
                        },
                        Option2 = {
                            5,
                            "\"I just want to get this over with, Naryu.\"",
                            points = -1
                        }
                    },
                    [3] = {
                        "\"Well, aren’t you sweet? And here I was thinking I'd have to twist your arm to get you into formal wear.\"\n\n\"Anyway, the job is simple. It requires very little effort on your part. I invited you to play a very small, but vital, role in tonight's proceedings. I trust you, and my trust is not something easily gained. So don't screw this up.\"\n\n\"If all goes well, I should be done inside an hour. Then you can relax and even enjoy the party, if you so choose.\"\n\n\"Perhaps you'll even find a dashing suitor to dance with.\"",
                        Option1 = {
                            4,
                            "\"I’d rather dance with you.\"",
                            points = 1
                        },
                        Option2 = {
                            6,
                            "\"I just want to get this over with, Naryu.\"",
                            points = -1
                        }
                    },
                    [4] = {
                        "\"Oh? You are always so full of surprises, my darling. I suppose I could arrange that, after my business is done. I imagine I’ll have to chase away the other s’wits lining up to ask you, won’t I?\"\n\n\"Maybe we should practice for good measure. This is quite an important social event. It won’t do to embarrass ourselves.\"\n\nNaryu steps closer to you, one hand coming to rest on your waist, the other on your shoulder. She presses close and stares deeply into your eyes, a smirk curling her lips. She leans in a little, so close you can feel her breath on your bottom lip.\n\nYou feel a sharp edge against your side and realize she’s pulled her dagger. It lingers at your ribs for a moment before Naryu laughs and pulls away from you. Her red eyes glitter with amusement. And something more.\n\n\"You know, I asked you here because you’ve never let me down. I don’t have many people I can count on, so I keep the ones I’m reasonably certain about close.\"\"But if I’m being completely honest, I asked you here for another reason, too. Some deluded fantasy about the two of us dancing in each other’s arms, drunk on wine, retiring to some secluded hallway where I press you up against the wall and our hands are all over each other and…\"\n\n\"If that’s as stupid as it sounds, I need you to tell me right now, hero.\"",
                        Option1 = {
                            "End1",
                            "\"It’s not stupid, Naryu. I want that too.\"",
                            points = 1
                        },
                        Option2 = {
                            "End2",
                            "\"It’s incredibly stupid!\"",
                            points = -1
                        }
                    },
                    [5] = {
                        "\"Fine. I didn’t think you’d be such a bore about this, hero.\"\n\n\"If you just want to get in and get out, then that’s what we’ll do. And there will be no fun had whatsoever, I assure you. No fun for you, anyways. I’ll find my own elsewhere.\"\n\nNaryu frowns, her brow knitted with frustration.\n\nShe inspects something on the edge of her blade before roughly shoving it back into the scabbard at her thigh.\n\n\"You know, I asked you here because you’ve never let me down. I don’t have many people I can count on, so I keep the ones I’m reasonably certain about close.\"\"But if I’m being completely honest, I asked you here for another reason, too. Some deluded fantasy about the two of us dancing in each other’s arms, drunk on wine, retiring to some secluded hallway where I press you up against the wall and our hands are all over each other and…\"\n\n\"If that’s as stupid as it sounds, I need you to tell me right now, hero.\"",
                        Option1 = {
                            "End1",
                            "\"It’s not stupid, Naryu. I want that too.\"",
                            points = 1
                        },
                        Option2 = {
                            "End2",
                            "\"It’s incredibly stupid!\"",
                            points = -1
                        }
                    },
                    [6] = {
                        "\"All right, all right. No dancing for you. But I will insist you try the wine while you’re milling about the ball. It would be a crime to let it go to waste.\"\n\n\"Oh, don’t look so dour, my darling. A little party won’t kill you, will it? It might even be a nice change of pace. And I promise as soon as I’m finished, we can take our leave.\"\n\nNaryu winks at you before pulling her blades from their sheathes and inspecting them, much like she inspected your outfit earlier. After a moment, satisfied, she spins the daggers in her palms before concealing them away on her person once more.\n\n\"You know, I asked you here because you’ve never let me down. I don’t have many people I can count on, so I keep the ones I’m reasonably certain about close.\"\"But if I’m being completely honest, I asked you here for another reason, too. Some deluded fantasy about the two of us dancing in each other’s arms, drunk on wine, retiring to some secluded hallway where I press you up against the wall and our hands are all over each other and…\"\n\n\"If that’s as stupid as it sounds, I need you to tell me right now, hero.\"",
                        Option1 = {
                            "End1",
                            "\"It’s not stupid, Naryu. I want that too.\"",
                            points = 1
                        },
                        Option2 = {
                            "End2",
                            "\"It’s incredibly stupid!\"",
                            points = -1
                        }
                    },
                    ["End1"] = {
                        "\"You’ve made me blush, are you happy with yourself? You and that lovely nose of yours, and mouth, and everything...\"",
                        Option1 = {
                            1, GetString(LIBRARIUM_ADVENTURES_RESTART_BOOK)
                        },
                        Option2 = {
                            0, GetString(LIBRARIUM_ADVENTURES_CLOSE_BOOK)
                        }
                    },
                    ["End2"] = {
                        "\"I suppose that makes me quite the fool then, doesn’t it? I think I’ll stick to poking people with the pointy end of my daggers and leave the rubbish romance stuff to someone else.\"",
                        Option1 = {
                            1, GetString(LIBRARIUM_ADVENTURES_RESTART_BOOK)
                        },
                        Option2 = {
                            0, GetString(LIBRARIUM_ADVENTURES_CLOSE_BOOK)
                        }
                    },
                    ["Endings"] = {
                        ["2"] = {
                            "A shiver runs through you.\n\n\"Let’s get this done quickly, hero. Then we can start in on that delicious fantasy of mine. I can hardly wait.\"\n\n\"In fact … I think a taste of what’s to come may be appropriate. It’ll give me something to think about while I’m working.\"\n\nNaryu suddenly presses you back against the wall of the Randy Netch Inn you’re standing in front of and brings her body close to yours. Her expression is unreadable. She’s either going to kiss you or kill you, and you can’t quite tell the difference. You grab her hips. She’s surprisingly soft.\n\nHer mouth hovers inches from yours and she chuckles low, sending shivers across your body. You lose yourself in the moment, savoring every second...\n\nCONGRATULATIONS!\n\nThe Mother of Blades has a special place in her heart just for you."
                        },
                        ["0"] = {
                            "Naryu rolls her eyes.\n\n\"Let’s just forget about all that. I have a job to do, and you have people to mingle with and partygoers to impress.\"\n\n\"Try to be your charming self, hmm? And don’t get into any trouble or try any heroics while I’m gone. If all goes well, drinks are on me.\"\n\nNaryu adjusts the neckline of your ensemble fondly and then steps back, apparently satisfied with her work.\nShe slides an elaborate masquerade mask into your hand with a smirk.\n\nEND!\n\nEven assassins need friends, and Naryu considers you one of her best!"
                        },
                        ["-1"] = {
                            "Naryu’s expression tightens.\n\n\"All right, I think it’s fairly obvious that you’re not interested in helping me. I’m not sure what your problem is, but I don’t have the patience for it, or the time.\"\n\n\"I think it’s probably best you leave. I can do this on my own.\"\n\nNaryu gives you a withering look before turning away sharply.\n\nShe makes a lewd gesture over her shoulder as she leaves. You do not hear from Naryu again.\n\nEND!\n\nKeep your friends close and your enemies closer, right? You might want to watch your back."
                        }
                    }
                }
            }
        }
    }
    local r = 4;
    if c == r then
        return q[c][d][e]
    else
        return p[c][d][e][1]
    end
end
local s = {
    ["en"] = {
        [1] = "Elden Root Services",
        [2] = "Elden Root Mages Guild",
        [3] = "Elden Root Fighters Guild",
        [4] = "Wayrest Mages District",
        [5] = "Wayrest Palace District",
        [6] = "Mournhold Guild Plaza",
        [7] = "Tribunal Temple"
    },
    ["fr"] = {
        [1] = "services de Faneracine^pmd",
        [2] = "guilde des mage de Faneracine^fd",
        [3] = "guilde des guerriers de Faneracine^fd",
        [4] = "quartier des mages d'Haltevoie^md",
        [5] = "quartier du palais d'Haltevoie^md",
        [6] = "place des guildes de Longsanglot^fd",
        [7] = "temple du Tribunal^md"
    },
    ["de"] = {
        [1] = "Dienstleistungen von Eldenwurz^pd,bei",
        [2] = "Magiergilde von Eldenwurz^fd,bei",
        [3] = "Kriegergilde von Eldenwurz^fd,bei",
        [4] = "Magierviertel von Wegesruh^nd,in",
        [5] = "Palastviertel von Wegesruh^nd,in",
        [6] = "Gildenplatz von Gramfeste^md,auf",
        [7] = "Tempel des Tribunals^m,an"
    },
    ["ru"] = {
        [1] = "Услуги Элден-Рута",
        [2] = "Гильдия магов Элден-Рута",
        [3] = "Гильдия бойцов Элден-Рута",
        [4] = "Район магов Вэйреста",
        [5] = "Дворцовый район Вэйреста",
        [6] = "Гильдейская плаза Морнхолда",
        [7] = "Храм Трибунала"
    },
    ["es"] = {
        [1] = "Servicios de Raíz de Elden^pmd",
        [2] = "gremio de magos de Raíz de Elden^md",
        [3] = "gremio de luchadores de Raíz de Elden^md",
        [4] = "distrito de magos de Quietud^md",
        [5] = "distrito del palacio de Quietud^md",
        [6] = "Plaza de los gremios de El Duelo^fd",
        [7] = "templo del Tribunal^md"
    }
}
local t = GetCVar("language.2")
if not s[t] then t = "en" end
local function u(c, d, e)
    local v = {
        [1] = {
            [1] = {
                [1] = {41},
                [2] = {s[t][2], s[t][4], s[t][6]},
                [3] = {
                    GetMapNameById(445), GetMapNameById(33), GetMapNameById(205)
                },
                [4] = {-1},
                [5] = {3, 19, 381},
                [6] = {3, 19, 381},
                [7] = {3, 19, 381},
                [8] = {3, 19, 381},
                [9] = {3, 19, 381}
            },
            [2] = {
                [1] = {3},
                [2] = {381, 1011},
                [3] = {-1},
                [4] = {181, 101, 103, 1160, 1207},
                [5] = {381, 1011},
                [6] = {280, 534, 535, 537, 816, 1146, 1318},
                [7] = {1282, 1413, s[t][2], s[t][4], s[t][6]},
                [8] = {92, 684, 1207},
                [9] = {381, 1086, 1133, 19}
            },
            [3] = {
                [1] = {980, 981},
                [2] = {980, 981},
                [3] = {980, 981},
                [4] = {980, 981},
                [5] = {980, 981},
                [6] = {980, 981},
                [7] = {980, 981, 1011}
            },
            [4] = {
                [1] = {381, 1011},
                [2] = {381, 1011, 1160},
                [3] = {3, 19, 20, 684, GetMapNameById(1064), 1261},
                [4] = {3, 19, 20, 684, GetMapNameById(1064), 1261},
                [5] = {3, 19, 20, 684, 1261},
                [6] = {3, 19, 20, 684, 1261},
                [7] = {3, 19, 20, 684, 1261},
                [8] = {3, 19, 20, 684, 1261},
                [9] = {3, 19, 20, 684, 1261},
                [10] = {3, 117, 726, 1160, 1161, 1208},
                [11] = {3, 726, 1160, 1161, 1208, 1318},
                [12] = {3, 19, 381},
                [13] = {3, 19, 381}
            },
            [5] = {
                [1] = {381},
                [2] = {-2},
                [3] = {-2},
                [4] = {-2},
                [5] = {-2},
                [6] = {-2},
                [7] = {181},
                [8] = {181},
                [9] = {181}
            },
            [6] = {
                [1] = {181, 823},
                [2] = {58, 108, 381, 383, 823, 1011},
                [3] = {58, 108, 381, 383, 823, 1011},
                [4] = {58, 108, 381, 383, 823, 1011},
                [5] = {3, 19, 57},
                [6] = {888, 1207, 1282},
                [7] = {57, s[t][2], s[t][4], s[t][6]},
                [8] = {GetMapNameById(63), 92, 1160},
                [9] = {1318, 1383, 1413},
                [10] = {1318, 1383, 57, 1443},
                [11] = {3, 19, 381}
            },
            [7] = {[1] = {3, 19, 20, 381, 1011}, [2] = {383}},
            [8] = {
                [1] = {534, 535, 3, 19, 20, 104, 92},
                [2] = {534, 535, 3, 19, 20, 104, 92},
                [3] = {181, 584, 643, 41, 347},
                [4] = {181, 584, 643, 41, 347},
                [5] = {534, 535, 3, 19, 20, 104, 92},
                [6] = {534, 535, 3, 19, 20, 104, 92},
                [7] = {3, 19, 381},
                [8] = {3, 19, 381},
                [9] = {3, 19, 381},
                [10] = {3, 19, 381}
            },
            [9] = {
                [1] = {s[t][1], s[t][2], s[t][3], s[t][5], s[t][7]},
                [2] = {383},
                [3] = {3, 19, 383},
                [4] = {3, 19, 383},
                [5] = {1282, 1283},
                [6] = {347, 1282, 1283, 1286},
                [7] = {3, 19, 381},
                [8] = {3, 19, 381}
            },
            [10] = {
                [1] = {1261, GetMapNameById(545)},
                [2] = {3, 19, 381},
                [3] = {3, 19, 381},
                [4] = {1011, 1413}
            },
            [11] = {[1] = {58}, [2] = {58}, [3] = {3, 19, 381}}
        },
        [2] = {[1] = {[1] = {-99}, [2] = {-99}}},
        [3] = {[1] = {[1] = {-99}}},
        [4] = {[1] = {[1] = {-99}, [2] = {-99}}}
    }
    return v[c][d][e]
end
local function w(c, d, e)
    if font[c] and font[c][d] and font[c][d][e] then return font[c][d][e] end
end
a.LibBooks = {}
for x = 1, 4 do
    a.LibBooks[x] = {}
    for y = 1, #a.LibCollections[x] do
        a.LibBooks[x][y] = {}
        for z = 1, #b[x][y] do
            local A = b[x][y][z].title;
            local h = b[x][y][z].medium;
            local B = b[x][y][z].oocAuthor;
            local i = b[x][y][z].icon or h;
            a.LibBooks[x][y][z] = {
                title = A,
                medium = h,
                body = o(x, y, z),
                fonts = nil,
                icon = a:GetDefaultBookIcon(i),
                showTitle = a:GetShowTitle(x, y, z),
                zones = u(x, y, z),
                author = B
            }
        end
    end
end
