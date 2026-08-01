local localization =
{
    ATT_STR_MYDONATION               = "My Donation",
	ATT_STR_NAME                     = "Name",
    ATT_STR_GUILD                    = "Guild",
	ATT_STR_DEPOSIT                  = "Donation",
 	ATT_STR_TIME	                 = "Time",
	
    ATT_STR_TODAY                    = "Today",
    ATT_STR_YESTERDAY                = "Yesterday",
    ATT_STR_TWO_DAYS_AGO             = "Two days ago",
    ATT_STR_THIS_WEEK                = "This week",
    ATT_STR_LAST_WEEK                = "Last week",
    ATT_STR_PRIOR_WEEK               = "Prior week",
    ATT_STR_7_DAYS                   = "7 days",
    ATT_STR_10_DAYS                  = "10 days",
    ATT_STR_14_DAYS                  = "14 days",
    ATT_STR_30_DAYS                  = "30 days",
	ATT_STR_3_MONTHS                 = "3 months",
	ATT_STR_6_MONTHS                 = "6 months",
	ATT_STR_365_DAYS                 = "12 months",
	
    ATT_STR_KEEP_DEPOSIT_FOR_DAYS  	 = "Keep donations for x days",

    ATT_STR_FILTER_TEXT_TOOLTIP      = "Text search for user- or guild names",
    ATT_STR_FILTER_SUBSTRING_TOOLTIP = "Toggle between search for exact strings or substrings. Case sensitivity is ignored in both cases.",
    ATT_STR_FILTER_COLUMN_TOOLTIP    = "Exclude/include this column from/to the text search",
}

ZO_ShallowTableCopy(localization, ArkadiusTradeTools.Modules.MyDonation.Localization)
