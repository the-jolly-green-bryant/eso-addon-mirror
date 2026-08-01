# ESOGuildMemberNoteTemplateAddon
Elder Scrolls Online Guild Member Note Template Addon

Available on Minion / ESOUI at: https://www.esoui.com/downloads/info2196-GuildMemberNoteTemplate.html

/gmnt - Guild Member Note Template
Usage: <index> <@handle> [arguments...]
 - index: REQUIRED. The 1-based number corresponding to the template to apply (see addon settings)
 - @handle: REQUIRED. The @handle (including '@') for the member to set a guild note for
 - arguments: OPTIONAL. A space-delimited list of arguments to apply to the template. If an argument has a space in it, surround it in quotes. If you need quotes inside the argument, escape them with a backslash.

Templates support the following variables:
 - $DATE - the current date in MM/DD/YYYY format.
 - $SELFAT - the @handle of YOUR account (the one running the command).
 - $SELFCHAR - the character name of YOUR character (the one currently logged in).
 - $THEMAT - the @handle of the person whose guild note is being changed.
 - $THEMCHAR - the character name of the target's currently logged-in character.
 - $1, $2, $3, etc - space-separated arguments on the command line
 
 # Example
 /gmnt 3 @Coorbin one "second argument" third "fourth\'argument"
 - index => 3, meaning the third template is being used
 - @handle => @Coorbin, meaning the guild note will be updated for @Coorbin
 - $1 => one
 - $2 => second argument
 - $3 => third
 - $4 => fourth argument
 
In the above example, if template #3's text is:

```
Hello 
Date: $DATE 
Source: $SELFCHAR
Target:$THEMAT
Arg1: $1
Arg2: $2
Arg3: $3
Arg4: $4
```

And:
 - Assuming the current date is 11/9/2018
 - Assuming the person running this command is logged on as the character Foo McGee

Then the "filled-out" template from the above example would be:

```
Hello 
Date: 11/9/2018
Source: Foo McGee
Target: @Coorbin
Arg1: one
Arg2: second argument
Arg3: third
Arg4: fourth'argument
```