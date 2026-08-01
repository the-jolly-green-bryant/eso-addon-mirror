-- * _JOKER_VERSION: 0.0.1 ** Please do not modify this line.
--[[----------------------------------------------------------
	Joker - Jokes, Riddles, Fun Facts, & Other Tomfoolery
  ----------------------------------------------------------
  *
  * COMPILATION: Geography trivia
	*
]]--

JokerData = JokerData or {}
JokerData.Config = JokerData.Config or {}

JokerData.Config.TriviaGeography = {
  label = "Geography Trivia",
  command = "trivia-geography",
  trivia = true,
  nsfw = false,
  whitelistSlashCommand = false
}

JokerData.TriviaGeography = {
  { q = "What is the capital of France?", a = "Paris" },
  { q = "Which is the largest ocean on Earth?", a = "Pacific Ocean" },
  { q = "What is the longest river in the world?", a = "The Nile River (or Amazon, depending on measurement)" },
  { q = "Which country has the most natural lakes?", a = "Canada" },
  { q = "What is the smallest country in the world?", a = "Vatican City" },
  { q = "Which mountain is the tallest in the world?", a = "Mount Everest" },
  { q = "What is the capital of Japan?", a = "Tokyo" },
  { q = "Which desert is the largest in the world?", a = "Antarctic Desert (or Sahara if excluding polar)" },
  { q = "How many continents are there?", a = "Seven (7)" },
  { q = "What is the capital of Australia?", a = "Canberra" },
  { q = "Which country is known as the Land of the Rising Sun?", a = "Japan" },
  { q = "What is the largest country by land area?", a = "Russia" },
  { q = "Which river flows through London?", a = "Thames River" },
  { q = "What is the capital of Canada?", a = "Ottawa" },
  { q = "Which ocean is the Bermuda Triangle located in?", a = "Atlantic Ocean" },
  { q = "What is the tallest waterfall in the world?", a = "Angel Falls" },
  { q = "Which country has the largest population?", a = "China (or India, depending on recent data)" },
  { q = "What is the capital of Germany?", a = "Berlin" },
  { q = "Which sea separates Europe and Africa?", a = "Mediterranean Sea" },
  { q = "What is the official language of Brazil?", a = "Portuguese" },
  { q = "Which U.S. state is the Grand Canyon located in?", a = "Arizona" },
  { q = "What is the capital of Italy?", a = "Rome" },
  { q = "Which country is home to the Great Barrier Reef?", a = "Australia" },
  { q = "What is the largest island in the world?", a = "Greenland" },
  { q = "Which city is known as the Big Apple?", a = "New York City" },
  { q = "What is the capital of Spain?", a = "Madrid" },
  { q = "Which African country has the most pyramids?", a = "Sudan" },
  { q = "What is the deepest ocean trench?", a = "Mariana Trench" },
  { q = "Which country has the most time zones?", a = "France" },
  { q = "What is the capital of Egypt?", a = "Cairo" },
  
  -- World Capitals & Cities
  { q = "What is the capital of Brazil?", a = "Brasília" },
  { q = "What is the capital of Portugal?", a = "Lisbon" },
  { q = "What is the capital of Bhutan?", a = "Thimphu" },
  { q = "What is the capital of Senegal?", a = "Dakar" },
  { q = "What is the capital of Nova Scotia?", a = "Halifax" },
  { q = "Which city spans two continents, Europe and Asia?", a = "Istanbul" },
  { q = "Which city is famously known for its canals and gondolas?", a = "Venice" },
  { q = "Which city is known as the 'Mile High City'?", a = "Denver, Colorado" },
  { q = "Which city is known as the Glass Capital of the World?", a = "Toledo, Ohio" },
  { q = "What is the world's largest city by population?", a = "Tokyo" },
  
  -- Countries & Borders
  { q = "Which country has the longest coastline in the world?", a = "Canada" },
  { q = "Which country has the most neighboring countries?", a = "China (14 countries)" },
  { q = "Which country is known as the Land of Fire and Ice?", a = "Iceland" },
  { q = "Which country is made up of approximately 7,000 islands?", a = "The Philippines" },
  { q = "Which country has the most islands?", a = "Sweden" },
  { q = "What is the world's second-largest country by land area?", a = "Canada" },
  { q = "Which country is both in Europe and has territory in Africa?", a = "Spain" },
  { q = "What is the only country that borders the United Kingdom?", a = "Ireland" },
  { q = "Which African country on the mainland is the smallest by land area?", a = "The Gambia" },
  
  -- Physical Geography - Rivers & Water
  { q = "Which river forms a natural boundary between the United States and Mexico?", a = "The Rio Grande" },
  { q = "What is the longest river in North America?", a = "The Missouri River" },
  { q = "What is the longest river in Europe?", a = "The Volga River" },
  { q = "What is the longest river in Asia?", a = "The Yangtze River" },
  { q = "What is the world's shortest river?", a = "The Roe River in Montana" },
  { q = "How many states does the Mississippi River run through?", a = "10 states" },
  { q = "Which sea is the world's saltiest?", a = "The Dead Sea" },
  { q = "What canal connects the Mediterranean Sea to the Red Sea?", a = "The Suez Canal" },
  { q = "Which two oceans are connected by the Panama Canal?", a = "The Atlantic and Pacific Oceans" },
  { q = "Which ocean lies between Australia and Antarctica?", a = "The Southern Ocean" },
  { q = "What is the world's smallest ocean?", a = "The Arctic Ocean" },
  { q = "Which country is known to have the best quality tap water?", a = "Switzerland" },
  
  -- Physical Geography - Mountains & Ranges
  { q = "What is the highest mountain in North America?", a = "Denali (formerly Mount McKinley)" },
  { q = "Which mountain range separates Europe and Asia?", a = "The Ural Mountains" },
  { q = "Which mountain range begins in Canada and stretches to New Mexico?", a = "The Rocky Mountains" },
  
  -- Islands & Regions
  { q = "What is the largest island in the Mediterranean Sea?", a = "Sicily" },
  { q = "What do you call a cluster of islands?", a = "An archipelago" },
  { q = "Which continent is known as the 'Land Down Under'?", a = "Australia" },
  
  -- Deserts & Climate
  { q = "What is the driest continent on Earth?", a = "Antarctica" },
  { q = "In what country is the Kalahari Desert found?", a = "Botswana" },
  
  -- Landmarks & Structures
  { q = "In which country can you find Machu Picchu?", a = "Peru" },
  { q = "Which country is home to the ancient city of Petra?", a = "Jordan" },
  { q = "In which continent is the Amazon rainforest?", a = "South America" },
  { q = "What is the highest man-made structure ever built?", a = "The Burj Khalifa in Dubai" },
  
  -- US Geography
  { q = "Which U.S. state has the longest coastline?", a = "Alaska" },
  { q = "After Alaska, which U.S. state has the longest coastline?", a = "Florida" },
  { q = "What is the largest state in the US by land area?", a = "Alaska" },
  { q = "Which US state has the most active volcanoes?", a = "Alaska" },
  { q = "What is the flattest state in the US?", a = "Florida" },
  { q = "Which U.S. state is known as the Land of 10,000 Lakes?", a = "Minnesota" },
  { q = "Which U.S. state is home to the giant sequoias?", a = "California" },
  { q = "What is the capital of New Jersey?", a = "Trenton" },
}
