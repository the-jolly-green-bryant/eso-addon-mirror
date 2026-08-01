-- * _JOKER_VERSION: 8.0.0 ** Please do not modify this line.
--[[----------------------------------------------------------
	Joker - Jokes, Riddles, Fun Facts, & Other Tomfoolery
  ----------------------------------------------------------
  *
  * ADDING YOUR OWN JOKES:
  * Be aware that modifying this file incorrectly could break Joker,
  * so for normal users I recommend just compiling your jokes in the
  * '_MyCustomJokes.lua' file instead.
  *
  * COMPILATION: "Top Stories" (Jokes meant moreso in a news/headline format)
	*
	* SOURCES:
  * Whose Line Is It Anyways (Weird Newscasters & Similar)
  * Google Search
	*
]]--

JokerData = JokerData or {}
JokerData.Config = JokerData.Config or {}

JokerData.Config.News = {
  command = "news",
  label = "News",
  joke = true,
  nsfw = false,
  usePrefix = true,
  whitelistSlashCommand = true
}

JokerData.News = {
  "Nine out of ten dentists agree the tenth one should really chill out.",
  "Researchers working at two major universities have discovered that nobody cares anymore if you work at a major university.",
  "Auto makers have found that people who believe in reincarnation are less likely to wear a seatbelt.",
  "Wives live longer than husbands because they're not married to women.",
  "Welcome to the 6 o'clock news! Unfortunately, everything happened at 3:48 today, so we have nothing to tell you.",
  "Nine out of ten Americans believe that, out of ten people, one American will always disagree with the other nine.",
  "A large wooden object with a pointy end was found spinning in the downtown core. That's our top story.",
  "Donors are wanted for a man whose buttocks are blown off in industrial accident. Doctors report no end in sight.",
  "Our top story tonight interestingly is not about a top but a dreidel.",
  "Tragedy struck the Teletubbies this week when during a camping trip, Dipsy and Laa-Laa were mauled to death by bears.",
  "Nationwide law enforcement officials honor the Los Angeles Police Department with a congeniality award. And Arizona changes its state motto to 'Damn, it's hot.'",
  "Famous TV dolphin Flipper was arrested today on prostitution ring charges. He allegedly was seen transporting two sixteen-year olds across state lines for immoral porpoises.",
  "Mississippi changes its official state motto to 'Hey, We're All Named Bubba,' and the President celebrates the latest casual Friday at the White House by wearing leather chaps.",
  "Insane cow tries moon jump. Dish and spoon still missing.",
  "Hollywood was saddened when Foghorn Leghorn died today at the age of 65. Memorial services will be held tomorrow after which the deceased will be served in a nice orange sauce.",
  "Disaster struck a ceiling fan convention tonight when the scheduled entertainment Dr. Linguini and his trampolining sheep hit the floor. According to one eye witness, everything was fine until one extremely high bounce and then the sheep hit the fan.",
  "Elvis Presley found working at Doug's Snack & Bowl in Dothan, Alabama. Also, a News 10 exclusive: a tragic fudge accident takes the life of the Keebler Elves. More tonight at 7.",
  "After a disappointing summer, Humpty Dumpty has a great fall.",
  "Financial analysts have figured out a way to take out a second mortgage on your home so you can afford a full tank of gas.",
  "60's musical group The Byrds today announced their twenty-four city reunion tour their new band member George W. Bush. To save on money, Mr. Bush will play guitars and drums. According to a spokesman, a Bush in the band is worth two in the Byrds.",
  "A man who had been swallowed by a whale escaped today by running as hard as he could 'til he was all pooped out.",
  "An entire cult of dead killer bees were found dead. They are thought to have committed insecticide.",
  "NASA sends probe to Uranus. People everywhere giggle.",
  "Kathie Lee Gifford still unemployed. And Britney Spears makes a mistake. Oops, she did it again.",
  "Convicted hitman Jimmy Two-Shoes McClardy confessed today that he was once hired to beat a cow to death in a rice field using only two small porcelain figures. Police admit this may be the first known case of a knick knack paddy whack.",
  "Veteran British rockers Roger Daltrey, Pete Townshend and John Entwistle broke into an animal hospital today and set free all of the doberman pinschers. The police said that they now have proof that The Who let the dogs out.",
  "Ninety-five-year-old Fred Scapese was found not guilty today of sexual harrassment. The ninety-five-year-old, however, was arraigned on charges of assault with a dead weapon.",
  "A man is still in critical condition after swallowing two hundred and fifty thousand dollars in large bills. No change is expected.",
  "Disaster at the Los Angeles zoo today when the snake pit was accidentally filled in. Said the zoo director, 'It's terrible terrible news. Now the snakes don't even have a pit to hiss in.'",
  "A fight was started downtown by a man wearing a suit made completely of mirrors The police said the man apologized once he had time to sit down and reflect.",
  "The great Jamboni, eccentric human cannonball known for taking his lucky donkey to all his performances, escaped near tragedy today when the donkey climbed into the cannon muzzle just as Jamboni was taking off. It took the surgeons three hours to remove Jamboni's head from his ass. Both are resting comfortably.",
  "Famous Playboy Hugh Hefner managed to successfully stop an order of monks from operating a business on his property. The police forced the friars to close down their stall which was outside the Playboy Mansion where they had been selling flowers. Said one friar, 'Well, if it was anyone else, we may have gotten away from it, but unfortunately, only Hugh can prevent florist friars.'",
  "Rudolph the red-nosed reindeer dead at 53. I know, it is sad. Over Barcelona today the famed reindeer was hit by a flock of seagulls and a 747. Eyewitnesses report that the reindeer in Spain was hit mainly by the plane.",
  "Noted archaelogist Fred Flinsteen made an amazing discovery today in Sweden. On a wind-swept fjord he came across some primitive musical instruments plus some miniscule deposits of fossilized stool. When asked what the stool could be, Flinsteen replied, 'A dab o' ABBA doo.'",
  "The Great Flydini, The Shrekman Circus flying cannonball for the last fifty years retired yesterday. When asked if he was gonna be replaced, the circus owner said, 'No, it's hard to find a man of that caliber.'",
  "Bars across America were saddened today by the death of Dr. Joseph Loungstein. The famous doctor had a sideline making exotic drinks from wood sap died suddenly today. This is one patron who's really going to miss the Hickory Daiquiri Doc.",
  "A concert promoter who said he had the world's tallest piano player was found to be lying today, when his piano player was five foot ten. Just another case of a man lying about the size of his pianist.",
  "Scientists turn back time, end up with the word emit.",
  "Nine out of ten people addicted brake fluid, can't stop.",
  "Scientists have discovered that three out of five of habitual marijuana smokers develops over productive saliva glands. When asked if there was anything to do one scientist advised, yes you can spit or get off the pot.",
  "Arnold Schwarzenegger announced today that he'll be starring in a new movie about 17th century composer. Said Mr. Schwarzenegger, I'll be Bach.",
  "A monkey was arrested today when he started throwing lit feces at zoo employees. Three of the zoo employees were rushed to the hospital with turd debris burns.",
  "Researchers conclude today, one out of every seven dwarves is dopey.",
  "In Wyoming, a man totally covered in brown wrapping paper was arrested for rustling."
}
