-- * _JOKER_VERSION: 0.0.1 ** Please do not modify this line.
--[[----------------------------------------------------------
	Joker - Jokes, Riddles, Fun Facts, & Other Tomfoolery
  ----------------------------------------------------------
  *
  * COMPILATION: Science trivia
	*
]]--

JokerData = JokerData or {}
JokerData.Config = JokerData.Config or {}

JokerData.Config.TriviaScience = {
  label = "Science Trivia",
  command = "trivia-science",
  trivia = true,
  nsfw = false,
  whitelistSlashCommand = false
}

JokerData.TriviaScience = {
  -- Chemistry & Elements
  { q = "What is the chemical symbol for Gold?", a = "Au" },
  { q = "What is the chemical formula for water?", a = "H2O" },
  { q = "What is the chemical symbol for Sodium?", a = "Na" },
  { q = "What is the chemical symbol for Iron?", a = "Fe" },
  { q = "What is the chemical symbol for oxygen?", a = "O" },
  { q = "What is the atomic number of Carbon?", a = "6" },
  { q = "What is the atomic number of Hydrogen?", a = "1" },
  { q = "What is the hardest natural substance on Earth?", a = "Diamond" },
  { q = "What is the only metal that is liquid at room temperature?", a = "Mercury" },
  { q = "What is the common name for dihydrogen monoxide?", a = "Water" },
  { q = "What is the main gas that humans exhale?", a = "Carbon dioxide" },
  { q = "What gas do plants absorb during photosynthesis?", a = "Carbon dioxide" },
  { q = "What gas do humans need to breathe to survive?", a = "Oxygen" },
  { q = "What is the boiling point of water in Celsius?", a = "100 degrees Celsius" },
  { q = "What is the freezing point of water in Celsius?", a = "0 degrees Celsius" },
  
  -- Astronomy & Space
  { q = "How many planets are in our solar system?", a = "Eight (8)" },
  { q = "What is the largest planet in our solar system?", a = "Jupiter" },
  { q = "Which planet is known as the Red Planet?", a = "Mars" },
  { q = "What planet is the hottest in our solar system?", a = "Venus" },
  { q = "What planet is famous for its beautiful rings?", a = "Saturn" },
  { q = "How many planets in our solar system have rings?", a = "Four (Jupiter, Saturn, Uranus, Neptune)" },
  { q = "What star is closest to Earth?", a = "The Sun" },
  { q = "What is the name of the galaxy that contains our Solar System?", a = "Milky Way" },
  { q = "What is the main component of the Sun?", a = "Hydrogen" },
  { q = "What is the name of Earth's natural satellite?", a = "The Moon" },
  { q = "What is the speed of light in a vacuum (approximately)?", a = "299,792,458 meters per second (or about 300,000 km/s)" },
  
  -- Biology & Human Body
  { q = "What is the powerhouse of the cell?", a = "Mitochondria" },
  { q = "How many bones are in the adult human body?", a = "206" },
  { q = "What organ do humans use to breathe?", a = "Lungs" },
  { q = "What is the largest internal organ inside the human body?", a = "Liver" },
  { q = "What is the largest organ in the human body?", a = "Skin" },
  { q = "What part of the human body contains the most bones?", a = "Hands" },
  { q = "What is the soft tissue inside bones that produces blood cells?", a = "Bone marrow" },
  { q = "What do you call an animal that eats only plants?", a = "Herbivore" },
  { q = "What do you call an animal that eats both plants and meat?", a = "Omnivore" },
  { q = "What type of animal is a Komodo dragon?", a = "Lizard" },
  { q = "What is the largest land animal?", a = "African elephant" },
  { q = "How many hearts does an octopus have?", a = "Three (3)" },
  { q = "What is the smallest unit of life?", a = "Cell" },
  { q = "What molecule carries genetic information in living organisms?", a = "DNA (Deoxyribonucleic acid)" },
  
  -- Physics & General Science
  { q = "What is the name of the force that keeps us grounded on Earth?", a = "Gravity" },
  { q = "What force keeps us on the ground and stops us from floating into space?", a = "Gravity" },
  { q = "What is the charge of an electron?", a = "Negative" },
  { q = "What is the center of an atom called?", a = "Nucleus" },
  { q = "What is the smallest particle of an element called?", a = "Atom" },
  { q = "What is the process of water turning into vapor called?", a = "Evaporation" },
  { q = "What do you call a scientist who studies rocks?", a = "Geologist" },
  { q = "What do you call a scientist who studies weather?", a = "Meteorologist" },
  { q = "What scale is used to measure the magnitude of earthquakes?", a = "Richter scale (or Moment Magnitude Scale)" },
  { q = "What is the study of living organisms called?", a = "Biology" },
  { q = "What is the study of matter and its properties called?", a = "Chemistry" },
  { q = "What is the study of celestial objects called?", a = "Astronomy" },
  { q = "What device is used to measure temperature?", a = "Thermometer" },
  { q = "What device is used to measure atmospheric pressure?", a = "Barometer" },
  
  -- Earth Science & Environment
  { q = "What are the three states of matter?", a = "Solid, liquid, and gas" },
  { q = "What is the layer of gases surrounding Earth called?", a = "Atmosphere" },
  { q = "What is the most abundant gas in Earth's atmosphere?", a = "Nitrogen" },
  { q = "What percentage of Earth is covered by water?", a = "About 71 percent" },
  { q = "What do you call molten rock beneath the Earth's surface?", a = "Magma" },
  { q = "What do you call molten rock that has erupted onto the surface?", a = "Lava" },
  { q = "What is the outermost layer of Earth called?", a = "Crust" },
  { q = "What natural phenomenon is measured by the Richter scale?", a = "Earthquakes" },
  { q = "What is the process by which plants make food using sunlight?", a = "Photosynthesis" },
  { q = "What gas is produced during photosynthesis?", a = "Oxygen" },
  { q = "What is the term for animals that are active at night?", a = "Nocturnal" },
  { q = "What is the term for animals that are active during the day?", a = "Diurnal" },
}
