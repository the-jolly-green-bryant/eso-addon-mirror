This addon was previously known as "TamrielTrashCentre".
Backward compatibility is maintained: the global table `TamrielTrashCentre` is an alias for `LWTPriceInfo`.

If you wish to use this addon's API calls, here's some useful info:

HOW TO GET PRICE:
The only thing you'll need to get all the price info is to call LWTPriceInfo.GetPriceData(itemLink).
(Legacy: TamrielTrashCentre.GetPriceData(itemLink) also works)

It will return a table, structured like this:
{
	"PriceProviderName": // "TTC", "MM", ... 
	{
		"Listed Avg": 0, // Price that sellers list it for
		"Suggested": 0, // Suggested price for you to sell
		"Sale Avg": 0, // Price that buyers are willing to pay
		"Amount": 0, // Number of listings
		"Count": 0 // Number of buys
	},
	"AnotherPriceProvider":
	{
		...
	}
}

Remember, that some price providers do not give you all the info I've listed above, so I imitate it one way or the other!
For example, ESOHUB does not give you the actual "Suggested" price, so I use price in between of "Sale Avg" and "Listed Avg" :)
Another example: there is no data about sales in ATT, so I just hide it. And in MM I reuse "listed amount" for "bought amount".

All currently used names are stored in LWTPriceInfo.ProviderNames, so you can iterate if you need to.
(Legacy: TamrielTrashCentre.ProviderNames also works)

If you have no idea what provider you can and can't call - you can call LWTPriceInfo.GetAvailablePriceProvider("suspected available provider name")
It will return name of available provider by this priority:
1) Your suspected available provider if it's active
2) First available provider by priority (if we get to "NPC" something is wrong)
3) nil (something is VERY wrong)

HOW TO ADD MORE PROVIDERS:
Check out LWTPriceInfoProviders.lua, it's pretty straightforward!
