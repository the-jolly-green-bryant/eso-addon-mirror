# CraftBagger

The CraftBagger addon is an Elder Scrolls Online utility with a singular purpose: To export the contents of your craftbag(s) to disk so that the data can be pulled into Excel or other tools for analysis.

As a crafter in Elder Scrolls Online, I am always looking for resources.  I have target amounts of things that I wish to manufacture in order to meet whatever profit goal I currently have, and determining how many resources I need is a monumental effort to do manually.  This is why this addon was created.  Instead of manually picking through my craft bag in game and keeping track in excel of how many of each item I have and what their cost is, with CraftBagger, I can export that data and then easily import it into Excel.

CraftBagger has two components; the lua based addon code which will cause Elder Scrolls Online to dump your craft bag contents (across all accounts) to a 'saved variables' file.  The second component is a command line based powershell script that will parse the non-standard output of the saved variables .lua file and save the contents as .CSV files (one per account).

**Elder Scrolls Online does not allow addons to create their own files, so CraftBagger is unable to export your craft bag contents directly to CSV.  Because of this, using CraftBagger is a multi-step process:**

- enter the command /savecraftbag from the in-game chat window.  
This will dump your craft bag to a saved variable.  
- enter the command /reloadui, or simply logout (or wait up to 3 minutes).  
This will cause Elder Scrolls Online to save the 'saved variables' to disk.

- execute the batch file 'run.cmd' from your AddOns\CraftBagger folder, located in %HOMEDRIVE%%HOMEPATH%\Documents\Elder Scrolls Online\live\AddOns\CraftBagger

This will create a CraftBagger-{AccountName}.csv file in this folder.  You can then import that CSV file into excel or your spreadsheet software of choice.  (It will create one file per account, assuming each account has contents in the craftbag)

If you have the library 'LibPrice' installed, then the csv file will contain 'suggested price' information, pulled from which ever pricing addon you use (Master Merchant, Tamriel Trade Center, Arkadius Trade Tools, etc).

## Windows Help
Windows sometimes knows when you download a file from the internet and sets a security flag on the file to block it from being executed.  If you get a warning about running files from the internet, you may have to unblock the .ps1 and .cmd files.  To do so, from windows explorer right click on the CraftBaggerCSVExport.ps1 script and select 'properties', then check the 'Unblock' box in the bottom 'security' section of the dialog.  Do the same for the run.cmd file.

![screenshot](https://hekghg.ch.files.1drv.com/y4m__NCMj0bf1VQOGWzeDFzqcCyRl8zD47DfV2iYzFrFklSecGImDBn8O1eZtgx_HdlL8prDEXmS-o7bjPDzJ0-mY5TPNYjVr4okbFdjD3zQ6oKQTGTXhA7eQPSPfHJB1NloI7_qGxDDgVxg8pS9f0LsNvYKmPWF8D70uvI3jRpDkapawcctMtYpSc8fs3_cxuFGaQhY0DhSvyVCTvFReG87g?width=363&height=509&cropmode=none)

Windows should stop blocking you from executing the script now.

#### Creating a Desktop Shortcut
Unfortunately, Windows does not support easily 'pinning' a batch file (.cmd or .bat) to your start menu or taskbar.  However, there is a workaround that will allow you to create a desktop shortcut to running the run.cmd file.  

Step 1:  Right-click on an empty space on your desktop, select 'New', and then click on 'Shortcut'
![screenshot](https://iekghg.ch.files.1drv.com/y4m136ZNBy1Ypz2fFb22e1MsL-NqL4ZdHo4f2TGR0xXfTt9wjUiNM01HfVvEGre-VHEnJgCcPnWjphupBZRVrp8NFigo1YObxL3MJFs0xWsh29if0PQVPNosF0pBC3nAoMfkAPT_p6AxG-8cKEZzLDAFJCkrokPtNtuCcm6B0R1t2CN3YJdVHVuEVWhl64qZ5d63sowDWpkhO1pDOj6J3kqwg?width=681&height=499&cropmode=none)

Step 2: Enter the following text: 
cmd /c "%HOMEDRIVE%%HOMEPATH%\Documents\Elder Scrolls Online\live\AddOns\CraftBagger\run.cmd"

![screenshot](https://gpkghg.ch.files.1drv.com/y4mDtiuk1-6U9BEgHtKttMsAP2VE64dVC2qmXCxDzrCUH5HQgHXq5A-9-yt_Eh3hmdj28V-nNS_nqm8EGdhifjDwHIh2j55ErVaPC-zbsAttPN0dbwYuoFs6Z6fel3ixcoakRQfPSEVCEGFx5DMuJ48c6dH0jLsumoeRZ1M6dLu4Z6671OaWphwkABzw6p9gF1CVx_i9_93Fe1HVvv4O7Rk8w?width=621&height=457&cropmode=none)

Step 3: Give the shortcut a name and click on 'finish'

![screenshot](https://iokghg.ch.files.1drv.com/y4mgp0uQFW4kIdDJzJeS4UKRED9xNyT9A8x6fZvPheoBmOW5WTpRi_YinnxiztgHjj1ySuFIA6AgW63bJyPvizN0ZCemn3d7zA_DoDXGP8h1-DFOqVPrNzyghmjUJQooqxwwsWsTvwr6Nj3gvnPY998fI0kfM3e3w9KLVWXYBy47UaIDRujZ60ar3FAvXQ_C88hBh3lg524ZHDctXSHzUzG8Q?width=622&height=460&cropmode=none)

This will put an icon on your desktop so now all you have to do is click on the icon to refresh the CSV.

![shortcut icon](https://hukghg.ch.files.1drv.com/y4mxqj12a82w0Wzby2G0JhCGdkvp54SKTc0LwMg4vBQ23OunqCDNcd-25LpbR-ZRoC1sdNsaFPty25IFazxKzLSHzbEe8MnkmihUdaMV0zQaENaIPlZRxS4NCwS2n_i4OOfC_ULcDxe_2KvhF1hvFRI4UYPOSIWBgotuLfUAhN3W-6I3t5GnXkFLo3EmBLZn2nS95A3_sU7zkP_dtszbYgMrA?width=80&height=82&cropmode=none)

## DateTime Appended to CSV file
As of v1.06.03 there are two options in the CraftBagger settings window in-game that control how the CSV file is created.  By default, a csv file is created unique to each account, but this file is overwritten each time you run the batch file (or run the powershell script).  There are two settings that allow you to append a date/time stamp to the filename instead of overwriting it.  The first of this is "Append DateTime stamp to CSV".  This is a TRUE/FALSE value that controls if the file is overwritten (FALSE), or if TRUE, appends a date/time stamp.  The second setting 'Date Time Format String' gives you control over the specific date/time stamp format that is used.  This string must be a powershell date/time format string.  For more information, see: https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/get-date?view=powershell-7

Please note: if you remove the TIME from the format string, then only the date portion will be included in the filename.  This may cause your file to be overwritten if you output more than one file per day per account.

The powershell script will read your chosen settings from the saved variables file and create the csv accordingly.  You can also override the settings on the command line when running the powershell script directly, please see the included powershell help file for more information.

## Credits
I have reviewed the lua script for several addons to see how a particular addon implemented something. I want to give credit here to the most influential.

[CombatMetrics by Solinur](https://www.esoui.com/downloads/info1360-CombatMetrics.html) for assistance with settings configurations. 

[MiniMap by Fyrakin](https://www.esoui.com/downloads/info605-MiniMapbyFyrakin.html) for inspiration with debug output coloring and displaying the add-on version at load.

[Tamriel Trade Center by Cyxui](https://www.esoui.com/downloads/info1245-TamrielTradeCentre.html) for convincing me that an addon requiring a separate executable could work.

I want to especially thank [Sirinsidiator](https://www.esoui.com/forums/member.php?action=getinfo&userid=5815) & [Seerah](https://www.esoui.com/forums/member.php?action=getinfo&userid=7) for [LibAddonMenu](https://www.esoui.com/downloads/info7-LibAddonMenu.html) and [Ziggr](https://www.esoui.com/forums/member.php?action=getinfo&userid=11671) for [LibPrice](https://www.esoui.com/downloads/info2204-LibPrice.html)
