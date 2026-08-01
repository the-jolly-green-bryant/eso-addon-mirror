# LoreBooks

By: Garkin (original author), Ayantir, Kyoma, Sharlikran

## Maintainers Timeline

- **Ales Machat (Garkin)** — original creator, started 2014-04-18  
- **Ayantir** — active maintainer and contributor from 2015-11-07  
- **Kyoma** — contributor and maintainer starting 2018-05-30  
- **Sharlikran** — current maintainer since 2022-11-12

## License

This addon incorporates contributions under the following licenses:

- **MIT License** — for original work by Garkin (2014–2015)  
- **Creative Commons Attribution-NonCommercial-ShareAlike 4.0** — for contributions by Ayantir (2015–2020)  
- **Creative Commons Attribution-NonCommercial-ShareAlike 4.0** — for contributions by Sharlikran (2022–present)

Please see the LICENSE file for complete terms.

## Contributor Acknowledgments

Thanks to the following individuals and community members who contributed book data, corrections, or testing:

**Book Location and Eidetic Memory Contributions**:  
oath2order, yachoor, Sharlikran, desertforce, Schiffy, BixenteN7Akantor, shadowcep, vampire1326, Anceane, Devil73, NeuroticPixels, ILDaR_F, XXXspartiateXXX, DakJaniels

**Bug reports and notes**:  
Dirty_Mongrel, Rhynchelma

**Translations**:  
- Brazilian Portuguese: mlsevero  
- Japanese: BowmoreLover  
- Russian: KiriX  
- French: Childeric, Ykses  
- German: Bl4ckSh33p

If we’ve missed credit for your contributions, please contact the maintainer via ESOUI or GitHub.

---

## Description

Displays map pins for Shalidor's Library books and Eidetic Memory Scrolls.

## Shalidor Data Syntax

format: (table) `{` Normalized Coordinates X`,` Normalized Coordinates Y`,` collectionIndex`,` bookIndex`,`Map ID`,`Location Details `}`

- Map ID:
  - Map Id used to get the Map Name
- Location Details: (table)
  - nil or false = default
  - 1 = on town map
  - 2 = Delve (SI CONST)
  - 3 = Public Dungeon (SI CONST)
  - 4 = under ground
  - 5 = Group Instance (SI CONST)
  - 6 = Inside Inn
  - 7 = Guest Room
  - 8 = Attic Room
  - 9 = Hidden Basement
  - 10 = Bookshelf
  - 9999 = Breadcrumb so don't add to right click menu
  - ld = { X } where X is the arbitrary key for the location details
  - `["ld"] = { 6, 7 }`, "Inside Inn" and "Guest Room" would be added to the Tooltip for the details

NOTE: (SI CONST): Means it is an ingame localization and doesn't have to be translated

### Example of fake Shalidor Library pin

- `{ 0.5086468458, 0.8415690064, 1, 5, ["ld"] = { 9999, } } -- Guide to the Daggerfall Covenant, systres/u34_systreszone_base_0`

## Eidetic Memory Data Syntax

- `["c"] = true`: Collection information exists for this book
- `["cn"]`: Category Name of the Lorebook
- `["n"]`: Lorebook Name
- `["q"]`: Quest ID of the Lorebook
- `["e"]`: Eidetic Memory Locations for the book
  - `["pm"]`: Map ID of the book’s Primary Location
  - `["zm"]`: Zone's Map ID of the Lorebook
  - `["sm"]`: Map ID of the source map the Coordinates were taken from
  - `["px"], ["py"]`: LibGPS Global Coordinates for the Primary Location
  - `["zx"], ["zy"]`: LibGPS Global Coordinates for the Zone's Map ID
  - `["pnx"], ["pny"]`: Normalized Coordinates for the Primary Location
  - `["znx"], ["zny"]`: Normalized Coordinates for the Zone's Map ID
  - `["d"]= true`: Dungeon Pin. Usually anything in a zone that you enter (Delve, Mine, Cave, etc.)
  - `["fp"] = true`: Indicates this is a fake pin. It will be used as a Map Pin but not for locations from the Lore Library menu
  - `["ld"]`: Location Details for the Lorebook
  - `["qp"] = true`: Player must have the Quest in their Quest Journal to view the location
  - `["qc"] = true`: Player must have Completed the Quest to view the location
- `["r"]= true`: Random book appears in a Bookshelf
- `["m"]`: Map ID locations where the book can be found
  - `[MapIdNumber] = count`: Map ID and number of reports
