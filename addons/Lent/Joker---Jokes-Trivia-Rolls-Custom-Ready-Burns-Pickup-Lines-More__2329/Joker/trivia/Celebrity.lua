-- * _JOKER_VERSION: 0.0.1 ** Please do not modify this line.
--[[----------------------------------------------------------
	Joker - Jokes, Riddles, Fun Facts, & Other Tomfoolery
  ----------------------------------------------------------
  *
  * COMPILATION: Celebrity trivia
	*
]]--

JokerData = JokerData or {}
JokerData.Config = JokerData.Config or {}

JokerData.Config.TriviaCelebrity = {
  label = "Celebrity Trivia",
  command = "trivia-celebrity",
  trivia = true,
  nsfw = false,
  whitelistSlashCommand = false
}

JokerData.TriviaCelebrity = {
  { q = "Which actor played Iron Man in the Marvel Cinematic Universe?", a = "Robert Downey Jr." },
  { q = "Who is known as the 'King of Pop'?", a = "Michael Jackson" },
  { q = "Which actress played Hermione Granger in the Harry Potter films?", a = "Emma Watson" },
  { q = "Who directed the movie 'Titanic'?", a = "James Cameron" },
  { q = "Which singer is known for the hit song 'Thriller'?", a = "Michael Jackson" },
  { q = "Who played Jack Dawson in Titanic?", a = "Leonardo DiCaprio" },
  { q = "Which actress won an Oscar for her role in 'La La Land'... just kidding, it was 'Moonlight'. Who won?", a = "The confusion was real, but Emma Stone won for La La Land" },
  { q = "Who is the lead singer of the band Queen?", a = "Freddie Mercury" },
  { q = "Which actor played the Joker in 'The Dark Knight'?", a = "Heath Ledger" },
  { q = "Who is known as 'The Rock' in Hollywood?", a = "Dwayne Johnson" },
  { q = "Which singer performed at the Super Bowl 2020 halftime show alongside Shakira?", a = "Jennifer Lopez (JLo)" },
  { q = "Which actor is famous for playing James Bond in seven films?", a = "Roger Moore" },
  { q = "Who sang 'Rolling in the Deep'?", a = "Adele" },
  { q = "Which actress starred in 'Breakfast at Tiffany's'?", a = "Audrey Hepburn" },
  { q = "Who is the lead vocalist of the band U2?", a = "Bono" },
  { q = "Which actor played Wolverine in the X-Men film series?", a = "Hugh Jackman" },
  { q = "Who is known for the song 'Bohemian Rhapsody'?", a = "Queen (Freddie Mercury)" },
  { q = "Which actress played Katniss Everdeen in The Hunger Games?", a = "Jennifer Lawrence" },
  { q = "Who composed the music for 'The Lord of the Rings' trilogy?", a = "Howard Shore" },
  
  -- Movies & TV (Modern)
  { q = "Who played Captain Jack Sparrow in the 'Pirates of the Caribbean' series?", a = "Johnny Depp" },
  { q = "Which actor won an Oscar for portraying the Joker in 2019?", a = "Joaquin Phoenix" },
  { q = "Who directed the Oscar-winning film 'Parasite'?", a = "Bong Joon-ho" },
  { q = "Which actor played Paul Atreides in the 2021 film 'Dune'?", a = "Timothée Chalamet" },
  { q = "Who became the first woman to win the Best Director Oscar?", a = "Kathryn Bigelow" },
  { q = "Who portrayed Imperator Furiosa in 'Mad Max: Fury Road'?", a = "Charlize Theron" },
  { q = "Who led 'Black Panther' as King T'Challa?", a = "Chadwick Boseman" },
  { q = "Who starred as Walter White in 'Breaking Bad'?", a = "Bryan Cranston" },
  { q = "Who portrayed Daenerys Targaryen in 'Game of Thrones'?", a = "Emilia Clarke" },
  { q = "Which actor played Neo in the 'Matrix' series?", a = "Keanu Reeves" },
  { q = "Who won Best Actress for 'Everything Everywhere All at Once' (2023)?", a = "Michelle Yeoh" },
  { q = "Who voiced Elsa in the movie 'Frozen'?", a = "Idina Menzel" },
  { q = "Who was the first Black woman to win an Academy Award for Best Actress?", a = "Halle Berry" },
  { q = "Who won an Oscar for their portrayal of Queen Elizabeth II in 'The Queen'?", a = "Helen Mirren" },
  { q = "Who won Best Actor for their role as Ray Charles in 'Ray'?", a = "Jamie Foxx" },
  { q = "Who is the current host of 'The Tonight Show'?", a = "Jimmy Fallon" },
  { q = "Who was the first woman to host 'Saturday Night Live'?", a = "Candice Bergen" },
  
  -- Music (Diverse Genres)
  { q = "Who is widely known as the 'Queen of Pop'?", a = "Madonna" },
  { q = "Which artist holds the all-time record for Grammy wins?", a = "Beyoncé" },
  { q = "Who became the first rapper to win a Pulitzer Prize for music?", a = "Kendrick Lamar" },
  { q = "Which K-pop group scored a global No. 1 hit with 'Dynamite'?", a = "BTS" },
  { q = "Which musician starred in the film 'Purple Rain'?", a = "Prince" },
  { q = "Which Beatle wrote and performed 'Imagine' as a solo artist?", a = "John Lennon" },
  { q = "Beyoncé first rose to fame with which group?", a = "Destiny's Child" },
  { q = "Which artist holds a record four Grammy Album of the Year wins?", a = "Taylor Swift" },
  { q = "Which American rocker is nicknamed 'The Boss'?", a = "Bruce Springsteen" },
  { q = "Which artist created the Ziggy Stardust persona?", a = "David Bowie" },
  { q = "Who performed 'Despacito' alongside Daddy Yankee?", a = "Luis Fonsi" },
  { q = "What pop star sang the hit single 'Bad Guy'?", a = "Billie Eilish" },
  { q = "What is Billie Eilish's full real name?", a = "Billie Eilish Pirate Baird O'Connell" },
  { q = "What is the real name of the artist known as Post Malone?", a = "Austin Richard Post" },
  { q = "Who is the lead vocalist of Coldplay?", a = "Chris Martin" },
  { q = "Which British band is known for hits like 'Yellow' and 'Viva La Vida'?", a = "Coldplay" },
  { q = "Who is known as the 'Godfather of Soul'?", a = "James Brown" },
  { q = "Which female artist is known as 'Queen Bey'?", a = "Beyoncé" },
  { q = "Who was the lead singer of Nirvana?", a = "Kurt Cobain" },
  { q = "Which artist performed at the 2021 Super Bowl halftime show?", a = "The Weeknd" },
  
  -- Sports Celebrities
  { q = "Which basketball player is nicknamed 'King James'?", a = "LeBron James" },
  { q = "Who holds the record for the most Olympic gold medals?", a = "Michael Phelps" },
  { q = "Which boxer was known as 'The Greatest'?", a = "Muhammad Ali" },
  { q = "Who is the fastest man in the world, holding the 100m world record?", a = "Usain Bolt" },
  { q = "Which NBA player was nicknamed 'The Black Mamba'?", a = "Kobe Bryant" },
  { q = "Which professional athlete is the most followed person on Instagram?", a = "Cristiano Ronaldo" },
  { q = "Who was the first African American to play in Major League Baseball?", a = "Jackie Robinson" },
  { q = "Which soccer player is often compared with Cristiano Ronaldo as the greatest of all time?", a = "Lionel Messi" },
  { q = "Who is the most decorated gymnast in World Championship history?", a = "Simone Biles" },
  { q = "Which tennis player has won the most Grand Slam singles titles in history?", a = "Novak Djokovic" },
  
  -- Modern Pop Culture & Social Media
  { q = "Who was the first Black actor to achieve EGOT status?", a = "Viola Davis" },
  { q = "Which two musical divas feuded during their time as judges on 'American Idol'?", a = "Nicki Minaj and Mariah Carey" },
  { q = "What was Raven-Symoné's last name in 'That's So Raven'?", a = "Baxter" },
  { q = "Which Black content creator became the most followed on TikTok in 2023?", a = "Khaby Lame" },
  { q = "Which celebrity couple's divorce popularized the phrase 'conscious uncoupling'?", a = "Gwyneth Paltrow and Chris Martin" },
  { q = "Who is the youngest member of the Kardashian-Jenner family?", a = "Kylie Jenner" },
  { q = "What did Michelle Obama call her 2018 memoir?", a = "Becoming" },
  { q = "Who is the richest self-made woman in America according to Forbes?", a = "Oprah Winfrey (accept: varies by year)" },
  { q = "Which YouTuber became the first to reach 100 million subscribers?", a = "PewDiePie" },
  { q = "Who created the fashion brand Fenty Beauty?", a = "Rihanna" },
  
  -- Classic Hollywood & Literature
  { q = "Who played Dorothy in 'The Wizard of Oz'?", a = "Judy Garland" },
  { q = "Which actor starred in 'Casablanca' and 'The Maltese Falcon'?", a = "Humphrey Bogart" },
  { q = "Who was known as 'The Little Tramp' in silent films?", a = "Charlie Chaplin" },
  { q = "Which blonde bombshell starred in 'Some Like It Hot'?", a = "Marilyn Monroe" },
  { q = "Who played Scarlett O'Hara in 'Gone with the Wind'?", a = "Vivien Leigh" },
  { q = "Which actress was known as 'America's Sweetheart' in the 1910s-1920s?", a = "Mary Pickford" },
  { q = "Who wrote the play 'Romeo and Juliet'?", a = "William Shakespeare" },
  { q = "Who wrote the fantasy series 'The Lord of the Rings'?", a = "J.R.R. Tolkien" },
  { q = "What is the pen name of author Samuel Clemens?", a = "Mark Twain" },
  { q = "Who is the author of the 'Game of Thrones' book series?", a = "George R.R. Martin" },
  { q = "Who wrote 'The Catcher in the Rye'?", a = "J.D. Salinger" },
  { q = "Who wrote the 'Harry Potter' series?", a = "J.K. Rowling" },
  
  -- Directors & Creators
  { q = "Who directed 'The Shawshank Redemption'?", a = "Frank Darabont" },
  { q = "Who directed 'Pulp Fiction' and 'Kill Bill'?", a = "Quentin Tarantino" },
  { q = "Who directed the 'Dark Knight' trilogy?", a = "Christopher Nolan" },
  { q = "Who created the Marvel Cinematic Universe films as producer?", a = "Kevin Feige" },
  { q = "Who directed 'Jaws' and 'E.T.'?", a = "Steven Spielberg" },
  { q = "Who directed 'The Godfather' trilogy?", a = "Francis Ford Coppola" },
  { q = "Who created and directed the TV series 'Stranger Things'?", a = "The Duffer Brothers (Matt and Ross Duffer)" },
  { q = "Who created the animated series 'The Simpsons'?", a = "Matt Groening" },
  
  -- Historical Figures & Icons
  { q = "Who was the first female Prime Minister of the United Kingdom?", a = "Margaret Thatcher" },
  { q = "In which country was Nelson Mandela born?", a = "South Africa" },
  { q = "Who developed the theory of evolution by natural selection?", a = "Charles Darwin" },
  { q = "Who painted the Mona Lisa?", a = "Leonardo da Vinci" },
  { q = "Who was the first person to walk on the moon?", a = "Neil Armstrong" },
  { q = "Who invented the telephone?", a = "Alexander Graham Bell" },
  { q = "Who was known as the 'Iron Lady'?", a = "Margaret Thatcher" },
  
  -- Fun Facts & Miscellaneous
  { q = "Which actor is known for collecting typewriters and wrote 'Uncommon Type'?", a = "Tom Hanks" },
  { q = "Which celebrity once worked as a mall Christmas elf?", a = "Ryan Gosling" },
  { q = "Which actor voices Groot in the Marvel Cinematic Universe?", a = "Vin Diesel" },
  { q = "Who played both Anakin Skywalker and Darth Vader in the Star Wars prequels?", a = "Hayden Christensen (Anakin), James Earl Jones (Vader's voice)" },
  { q = "Which actress played both Princess Leia and appeared in 'When Harry Met Sally'?", a = "Carrie Fisher" },
  { q = "Who is the voice of Darth Vader?", a = "James Earl Jones" },
  { q = "Which comedian and actor starred in 'Mrs. Doubtfire' and 'Good Will Hunting'?", a = "Robin Williams" },
  { q = "Who played Forrest Gump?", a = "Tom Hanks" },
  { q = "Which actress played Rachel Green on 'Friends'?", a = "Jennifer Aniston" },
  { q = "Who played Chandler Bing on 'Friends'?", a = "Matthew Perry" },
}
