-- Example dialog tree

-- Defining of all nodes here, because we are jumping, the dialog tree needs to be constructed from the bottom up.
-- This means the root of the dialog tree is the lowest here, since we are referencing other parts that need to be defined beforehand


LibCustomDialog.TEST_DIALOG_YES = {
    speaker = "MrPikPik",
    text = "I knew you would like them.",
}

LibCustomDialog.TEST_DIALOG_NO = {
    speaker = "MrPikPik",
    text = "Very well. If you don't think so...",
}

LibCustomDialog.TEST_DIALOG_OPTION_INTIM = {
    text = "You believe I would not be interested?",
    decorator = LibCustomDialog.DECORATOR_INTIMIDATE,
    nextDialog = LibCustomDialog.TEST_DIALOG_YES,
}

LibCustomDialog.TEST_DIALOG_OPTION_PERS = {
    text = "Trust me, I'm not doubting they are possible, they are pretty cool.",
    decorator = LibCustomDialog.DECORATOR_PERSUADE,
    nextDialog = LibCustomDialog.TEST_DIALOG_YES,
}

LibCustomDialog.TEST_DIALOG_OPTION_YES = {
    text = "Yeah, custom dialogs are pretty neat!",
    important = true,
    nextDialog = LibCustomDialog.TEST_DIALOG_YES,
}
        
LibCustomDialog.TEST_DIALOG_OPTION_NO = {
    text = "No, why would anyone want custom dialogs anyway?",
    important = true,
    nextDialog = LibCustomDialog.TEST_DIALOG_NO,
}

LibCustomDialog.TEST_DIALOG_WHAT = {
    speaker = "MrPikPik",
    text = "You doubt, this is possible? As you can see right here, it works. Flawless too! As far as I know at least.",
    options = {
        [1] = LibCustomDialog.TEST_DIALOG_OPTION_PERS,
        [2] = LibCustomDialog.TEST_DIALOG_OPTION_INTIM,
        [3] = LibCustomDialog.TEST_DIALOG_OPTION_NO,
        [4] = LibCustomDialog.TEST_DIALOG_OPTION_YES,    
    }
}

LibCustomDialog.TEST_DIALOG_OPTION_WHAT = {
    text = "What? How are custom dialogs possible?",
    nextDialog = LibCustomDialog.TEST_DIALOG_WHAT,
}

LibCustomDialog.TEST_DIALOG_ENTRY = {
    speaker = "MrPikPik",
    text = "Hello, <<1>>!\n\nSeems like, you are the kind of man that is showing interest in |c006900custom dialogs|r, aren't you?",
    textfemale = "Hello, <<1>>!\n\nSeems like, you are the kind of woman that is showing interest in |c006900custom dialogs|r, aren't you?",
    insertCharName = true,
    options = {
        [1] = LibCustomDialog.TEST_DIALOG_OPTION_WHAT,
        [2] = LibCustomDialog.TEST_DIALOG_OPTION_NO,
        [3] = LibCustomDialog.TEST_DIALOG_OPTION_YES,   
    }
}



function LibCustomDialog.ShowExample()
    LibCustomDialog.ShowDialog(LibCustomDialog.TEST_DIALOG_ENTRY)
end