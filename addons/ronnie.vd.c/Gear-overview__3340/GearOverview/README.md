# Usage

This addon provides an interface to display what items you have in a set in your bank or bag, primarily to verify sets to give roles in discord guilds.

If you have Inventory Insight installed. This addon lists also your gear on other characters.

Usage:
1) Open the settings with `/gear` or Settings > Addon Settings > Gear Overview
2) Select the guild list you would like to match to. As of right now these are built into the addon, but they will be modular later on.
3) Click the Show Window or the Take Screenshot button

3.5) If you click the save icon in the bottom right corner of the window, that will take a screenshot and save it to your Documents folder.

This addon is based on GearTracker . But adds Inventory Insight integration and shows what items are craftable via collections.

# Add new sets

Done via JS:

```
function search2(items) {
	let outAll = ''
	items.split(',').forEach((item) => {
		output = ''
		setSummary.forEach((x) => {
			if (x.setName.toLowerCase().includes(item.toLowerCase())) {
				output += '{name="'+x.setName+'", id='+x.gameId+'},\n'
			}
		})
		if (output == '') {
			output = "No set found for "+item
		}
		outAll += output
	})
	console.log(outAll)
}

const response = await fetch('https://esolog.uesp.net/exportJson.php?table=setSummary');
const jsonData = await response.json() ;
const setSummary = jsonData.setSummary;
```

```
search2("Earthgore")
search2("Sentinel")
search2("Tremorscale")
search2("Engine Guardian")
search2("Stonekeeper")
search2("Troll King")
search2("Ring of the wild Hunt")
search2("Death Dealer's Fete")
search2("Torc of Tonal Constancy")
```

# Resources

- https://wiki.esoui.com/Main_Page
- https://wiki.esoui.com/API
- http://observertim.com/gamerefs/esouidocs/API100035.htm
- https://www.esoui.com/downloads/info731-InventoryInsight.html

# Licence
MIT - See LICENCE