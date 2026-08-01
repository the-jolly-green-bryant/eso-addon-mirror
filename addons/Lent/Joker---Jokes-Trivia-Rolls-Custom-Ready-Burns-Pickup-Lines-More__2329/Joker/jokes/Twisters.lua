-- * _JOKER_VERSION: 0.0.1 ** Please do not modify this line.
--[[----------------------------------------------------------
	Joker - Jokes, Riddles, Fun Facts, & Other Tomfoolery
  ----------------------------------------------------------
  *
  * ADDING YOUR OWN JOKES:
  * Be aware that modifying this file incorrectly could break Joker,
  * so for normal users I recommend just compiling your jokes in the
  * '_MyCustomJokes.lua' file instead.
  *
  * COMPILATION: Tongue Twisters
	*
  * SOURCES:
  * pun.me,
  * smart-words.org,
  * Reddit Search, 
  * Google Search
	*
]]--

JokerData = JokerData or {}
JokerData.Config = JokerData.Config or {}

JokerData.Config.Twisters = {
  label = "Twisters",
  command = "twister",
  nsfw = false,
  joke = true,
  whitelistSlashCommand = true
}

JokerData.Twisters = {
  "Peter Piper picked a peck of pickled peppers. How many pickled peppers did Peter Piper pick?",
  "How can a clam cram in a clean cream can?",
  "Denise sees the fleece, Denise sees the fleas. At least Denise could sneeze and feed and freeze the fleas.",
  "Sheena leads, Sheila needs.",
  "The thirty-three thieves thought that they thrilled the throne throughout Thursday.",
  "Something in a thirty-acre thermal thicket of thorns and thistles thumped and thundered threatening the three-D thoughts of Matthew the thug - although, theatrically, it was only the thirteen-thousand thistles and thorns through the underneath of his thigh that the thirty year old thug thought of that morning.",
  "Can you can a can as a canner can can a can?",
  "Seth at Sainsbury's sells thick socks.",
  "Roberta ran rings around the Roman ruins.",
  "Clean clams crammed in clean cans.",
  "Six sick hicks nick six slick bricks with picks and sticks.",
  "I wish to wish the wish you wish to wish, but if you wish the wish the witch wishes, I won't wish the wish you wish to wish.",
  "Stupid superstition!",
  "Picky people pick Peter Pan Peanut-Butter, 'tis the peanut-butter picky people pick.",
  "If Stu chews shoes, should Stu choose the shoes he chews?",
  "There those thousand thinkers were thinking how did the other three thieves go through.",
  "Santa's Short Suit Shrunk",
  "I scream, you scream, we all scream for icecream!",
  "Wayne went to Wales to watch walruses",
  "Six sleek swans swam swiftly southwards",
  "Gobbling gorgoyles gobbled gobbling goblins.",
  "Pirates Private Property",
  "When you write copy you have the right to copyright the copy you write.",
  "A big black bug bit a big black dog on his big black nose!",
  "Ann and Andy's anniversary is in April.",
  "Hassock hassock, black spotted hassock. Black spot on a black back of a black spotted hassock.",
  "How many cookies could a good cook cook If a good cook could cook cookies? A good cook could cook as much cookies as a good cook who could cook cookies.",
  "How much ground would a groundhog hog, if a groundhog could hog ground? A groundhog would hog all the ground he could hog, if a groundhog could hog ground.",
  "How much pot, could a pot roast roast, if a pot roast could roast pot.",
  "How much wood could Chuck Woods' woodchuck chuck, if Chuck Woods' woodchuck could and would chuck wood? If Chuck Woods' woodchuck could and would chuck wood, how much wood could and would Chuck Woods' woodchuck chuck? Chuck Woods' woodchuck would chuck, he would, as much as he could, and chuck as much wood as any woodchuck would, if a woodchuck could and would chuck wood.",
  "Mr. Tongue Twister tried to train his tongue to twist and turn, and twit an twat, to learn the letter 'T'.",
  "Pete's pa pete poked to the pea patch to pick a peck of peas for the poor pink pig in the pine hole pig-pen.",
  "She saw Sherif's shoes on the sofa. But was she so sure she saw Sherif's shoes on the sofa?",
  "Thirty-three thirsty, thundering thoroughbreds thumped Mr. Thurber on Thursday.",
  "Four furious friends fought for the phone.",
  "Black background, brown background, black background, brown background, black background, brown background.",
  "Tie twine to three tree twigs.",
  "Rory the warrior and Roger the worrier were reared wrongly in a rural brewery.",
  "There was a fisherman named Fisher, who fished for some fish in a fissure. Till a fish with a grin, pulled the fisherman in. Now they're fishing the fissure for Fisher.",
  "Luke Luck likes lakes. Luke's duck likes lakes. Luke Luck licks lakes. Luck's duck licks lakes. Duck takes licks in lakes Luke Luck likes. Luke Luck takes licks in lakes duck likes.",
  "One-one was a race horse. Two-two was one too. One-one won one race. Two-two won one too.",
  "Mary Mac's mother's making Mary Mac marry me. My mother's making me marry Mary Mac. Will I always be so Merry when Mary's taking care of me? Will I always be so merry when I marry Mary Mac?",
  "Through three cheese trees three free fleas flew. While these fleas flew, freezy breeze blew. Freezy breeze made these three trees freeze. Freezy trees made these trees' cheese freeze. That's what made these three free fleas sneeze.",
  "Birdie birdie in the sky laid a turdie in my eye. If cows could fly I'd have a cow pie in my eye.",
  "How many cans can a cannibal nibble, if a cannibal can nibble cans? As many cans as a cannibal can nibble, if a cannibal can nibble cans.",
  "Bobby Bippy bought a bat. Bobby Bippy bought a ball. With his bat Bob banged the ball - banged it bump against the wall. But so boldly Bobby banged it that he burst his rubber ball. 'Boo!' cried Bobby, 'Bad luck, ball!' Bad luck Bobby, bad luck ball. Now to drown his many troubles, Bobby Bippy's blowing bubbles.",
  "She sells sea shells by the seashore.",
  "Betty bought a bit of butter. But the butter Betty bought was bitter. So Betty bought a better butter, and it was better than the butter Betty bought before.",
  "Silly Sally swiftly shooed seven silly sheep. The seven silly sheep Silly Sally shooed Shilly-shallied south. These sheep shouldn't sleep in a shack; Sheep should sleep in a shed.",
  "The sixth sick sheik's sixth sheep's sick. - Guinness Book of World Records says this is the toughest English tongue twister!",
  "Round the rough and rugged rock the ragged rascal rudely ran.",
  "All I want is a proper cup of coffee, made in a proper copper coffee pot. I may be off my dot, but I want a cup of coffee from a proper coffee pot. Tin coffee pots and iron coffee pots: they're no use to me! If I can't have a proper cup of coffee in a proper copper coffee pot, I'll have a cup of tea!",
  "Two tiny timid toads trying to trot to Tarrytown.",
  "Nine nimble noblemen nibbling nuts.",
  "Quizzical quiz, kiss me quick.",
  "Imagine an imaginary menagerie manager managing an imaginary menagerie.",
  "Eve eating eagerly elegant Easter eggs.",
  "Ingenious iguanas improvising an intricate impromptu on impossibly-impractical instruments.",
  "These thousand tricky tongue twisters trip thrillingly off the tongue.",
  "Can you say it 3 times? Six sticky skeletons.",
  "Can you say it 3 times? She sees cheese.",
  "Can you say it 3 times? Stupid superstition.",
  "Can you say it 3 times? Eleven benevolent elephants.",
  "Can you say it 3 times? Truly rural.",
  "Three thin thinkers thinking thick thoughtful thoughts.",
  "I thought, I thought of thinking of thanking you.",
  "Of all the felt I ever felt, I never felt a piece of felt which felt as fine as that felt felt, when first I felt that felt hat's felt.",
  "I wish to wish the wish you wish to wish, but if you wish the wish the witch wishes, I won't wish the wish you wish to wish.",
  "I thought a thought. But the thought I thought wasn't the thought I thought I thought. If the thought I thought I thought had been the thought I thought, I wouldn't have thought so much."
}
