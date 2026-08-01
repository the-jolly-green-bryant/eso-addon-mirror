# GuildBookkeeper
Monitor Guild Bank Activity for the game Elder Scrolls Online.  Intended for Guild Masters to monitor donations and corresponding values by Guild Members

Utilizes [LibHistoire](https://www.esoui.com/downloads/info2817-LibHistoire-GuildHistory.html) to capture Guild Bank events and parse them. A new array will be created for each guild the user selects to be monitored in the settings screen.  This is intended to help Guild Masters keep track of users donating and withdrawing items from the bank.

#### MasterMerchant Integration
If [MasterMerchant](https://www.esoui.com/downloads/info2753-MasterMerchant3.0.html) is installed it will fetch the average price for the respective item using the user's default MM day period.

#### TamrielTradeCenter Integration
If [TamrielTradeCenter](https://tamrieltradecentre.com/) is installed it will fetch the TTC average price.
*User must have most current price table updated if they want this to be accurate*

#### Companion App
*Currently only for Windows.*
The companion app, `Ledgers to CSV.exe` can be used to take the data captured and convert it into a CSV for easy manipulation.

#### Dependencies
LibAddonMenu-2.0>=31
LibHistoire>=392

##### Optional Dependencies
TamrielTradeCentre
MasterMerchant
