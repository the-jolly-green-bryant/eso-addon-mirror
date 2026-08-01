--[[
    =======================================
                Racing Panel
            Proudly Sponsored By
            N'wah Leaf Importers
	=======================================
	       @Undyne Keith Mitchell
]]--=======================================
--[[
    Version 1.1 2019-05-11
    =================================================================
    How "fast" is the default reference speed?

     1. The default speed can be called jogging.
        In ESO, Walking is 30% of jogging.
        In ESO, Sprinting is 140% of jogging.

        Default Speeds (on foot)
        ========================
          walk    1.35 m/s    3.01986 mph    4.86 kph    walk
           jog    4.50 m/s   10.06620 mph   16.20 kph    jog
        sprint    6.30 m/s   14.09268 mph   22.68 kph    sprint

        However, we allow for a calibration adjustment of the default
        1.35 m/s walking speed, from 1.25 m/s (-7.4%) to 1.60 m/s (+18.5%).

     2. Our walking speed is just under a common crosswalk measurement
          (people move slightly faster in crosswalks).
        A 3-mph treadmill exactly matches our walking footfall animation.
        It's just below the speed used by the Design Manual for Roads and Bridges.
        It's just above the speed recommended by The Transport for London.

     3. The default jogging speed is 60 minutes for 10.0662 miles.
        That's just under a 6-minute mile-- a decent mile.
        You may not win a track meet, but that's faster than most people can run.

     4. Sprinting speed is a mile in 4 minutes and 15 1/2 seconds.
        That's 60 minutes for 14.09268 miles, or 4.257529 minutes per mile.
        Over 1400 humans have been measured to be able to run a mile at this speed.
        This is a respectable sprint speed for an athletic hero who saves the day.

     5. The fastest available riding creature or vehicle is going to be moving
        at roughly 30mph when sprinting.

     6. Prior to the removal of the Ward of Cyrodiil mounted speed buff,
        top speed was well over 30 mph and racing was quite fun, with the
        "adrenalin rush" racing-game effect and everything. The nerf was roughly
        the same speed change, as if they were to remove Horse Speed Training
        from the game. If you can imagine horses having a max speed of a brand new
        character-- that's how much top speed they removed from ESO.

    =================================================================
    An overview of the speed calculation.

     1. In any ESO map--
        Built-in ESO Game functions can be used with simple math, to easily get
        character speed on that particular map, in map-units per second. Or, since
        map grids are huge-- thousandths of map units per second (milli-map-units/s).

        Every map has a different size grid and a different length of map unit.
        This plugin's job is to convert milli-map-units/s ON EVERY MAP
        (which are very easy to calculate... ) to mph, kmp, and m/s. That's it!

        To calibrate every map-- Sampling was done at default (jogging) speed in
        a straight line on the smoothest level surfaces available.

        The built-in sampling tool says (when calibrating maps),--
            Look! I am moving at the default movement speed on this map.
            I don't want to stop or bump anything, how fast am I going?
            Tell me in your native language, 'Units-of-this-map, per second'.
            I will note that number as the scale of this map.

     2. If "x" milli-map-units/sec = 4.5 m/s, then we can say:
        "x" milli-map-units = 4.5 meters.

        If (ref-number) milli-map-units = 4.5 meters, then
            1 meter = (ref-number/4.5) milli map units

        So if 1 meter = (ref-number/4.5) milli map units, then
            1 milli map unit = (4.5/ref-number) meters
            X milli map units = (X * 4.5)/ref-number meters

        So X milli map units / sec <-- what we measure when sampling
        = (X * 4.5)/ ref-number meters/sec.

        To get meters/sec, multiply the measured milli map units per second,
        by 4.5 and divide by ref-units.

        If our reference-number is 10, and that equals 4.5 m/s, then
        A measurement of "20" would be equal to 20 * 4.5 / 10, or 9.

     3. Sample functions:

        function Example_GetSpeed_Meters_Per_Second_mps(measured_value, scale)
            return ((measured_value * 4.5) / scale)
        end

        function Example_GetSpeed_Miles_Per_Hour_mph(measured_value, scale)
            return ((measured_value * 10.0662) / scale)
        end

        function Example_GetSpeed_Kilometers_Per_Hour_kph(measured_value, scale)
            return ((measured_value * 16.2) / scale)
        end

    =================================================================
    How the plugin works

    I am a software architect who designs around query performance.
    Here are the considerations which affected my methodology choice.

     1. Every map in Elder Scrolls Online has a different grid size.
        Imagine that every map you can visit-- whether it's a region,
        an area, a village or city, a dungeon or trial-- was drawn on
        engineering graph paper. But sometimes, the map was designed on
        graph paper with 1/8" squares, and sometimes, the map was designed
        on paper with 2" squares.
     2. You can ask the game for the zone and subzone you're currently seeing
        with your character, and it will provide a two-part identifier you can use
        to uniquely identify that map. As long as you do not move to a new zone
        or to a new subzone-- the map grid will be the same size everywhere you go.
     3. Each map has a 0,0 coordinate in one corner. The game can quickly
        and easily tell you the x,y coordinates of your current position,
        in your current map, using the map grid which has origins at map corner.
        EACH map has an accessible GPS applicable ONLY TO THAT MAP.
     4. The map grids are huge, to your character. If you run through a swamp for
        half a minute, you may only have travelled a percent of a map grid unit.
        Perhaps .425896585475 map units. That is an invented example.

    IMPORTANT : WE GRAB SPEED EFFORTLESSLY IN MILLI-MAP-UNITS PER SECOND

     5. Racing Panel can measure character speed accurately on any ESO map,
        in thousandths of map units per milli-second or per second. Here's how:
        Regularly, we read ("poll") the x,y position of our character on the current map
        (this is very easy, and takes almost no computation). At the same time (as close as
        possible with code), we take a very precise timestamp, accurate to milliseconds.
        We wait some pre-defined amount of time, and then we do it again, whether we're
        moving or not. Each time we collect an x,y position and timestamp, we subtract the
        last timestamp to get the exact time difference from one measurement to the next.
        It's not important we make the instant of our samples precise, it's only important
        that we subtract the values and get the exact time difference between samples.
        Any exact time interval and coordinate distance will produce an exact speed.

        We use simple geometry to measure the distance (in map unit coordinates)
        between the two samples. We assume neither the polling interval or map coordinate
        distance. We must measure both. They are very easy measurements, and everything
        has been optimized to simplicity, including the modest geometry calculations.

        With VERY LITTLE CALCULATION COST, we can very accurately determine speed
        on a given map, in milli-map-units per second (or milli-map-units per ms).
        This takes almost no processor power from the game-- which is VERY GOOD!!
        If we want to be very accurate with our polling (i.e., to determine the winner
        of a race)-- we could be doing all these calculations every few milliseconds.

    IMPORTANT : THE GLOBAL GPS SYSTEM WE DON'T USE, AND THE COST

     6. There is already excellent ESO geo-data efforts. There are libs for global
        coordinates which work all across Tamriel. The global GPS is used for such great
        Addons as Map Pins, I think. It's awesome work, but probably does many things we
        can't use, and it is a hundred of times more complex than my few lines of code.
        I assume it's written well but we don't need it. Racing Panel does its simple thing
        in a much simpler and much less complex way. There will be programmers who say,
        it's a modern computer, efficiency doesn't matter. But it always matters in code.

        I am not out to contribute to interface bloat on my favorite game, so I have
        written simple and VERY FAST code. I hope racing tools based on the global
        system are written but I don't want Racing Panel to do that.

        Of course, there is one problem to my elegant vision. For every single map,
        I need a magic number. Mister Efficiency here can only work his magic, if he has
        a magic number for every single map. I need a magic number I can multiply by
        that map's milli-map-units per second (mmu/s) to get miles per hour (mph),
        kilometers per hour (kph), or meters per second (m/s). If I don't have a magic
        number for a map, I can display no readout or meter.

        More importantly, this magic number would effectively be a scaling ratio
        for each map, which allows us to have a hard-coded (fast) geo-data scaling
        multiplier for relating geo-data from different maps.

        If we have map scaling data, for every map we want to use Racing Panel--
        we can get character speed whenever we want from featherweight code.

    =================================================================
    How we got our map scale data

    Short answer: With an automated tool running on every frame update.
    We turn on the sampler tool with a console command, and start taking samples.

    The sampler is built in!
    How the sampler works, internally:

    IMPORTANT : This is about a hidden tool for getting map scale data.
                This is not about how the plugin works for normal players.

    IMPORTANT : TO TAKE A SAMPLE: YOU MUST BE MOVING.
                YOU MUST NOT CHANGE MAPS. YOU MUST NOT STOP OR TURN.

     1. Start moving forward in a straight line on smooth level ground, with
        no speed modifiers (that includes Champion Point perks!!).
        Move at the default speed. Not walking or sprinting, jogging.
     2. Without stopping, the sampler takes a reference timestamp in
        milliseconds.
     3. If the player stops moving, the sampler takes a new reference
        timestamp in the next frame update where player is moving.
        The sampler starts over whenever you stop moving.
     4. If map (zone or subzone) changes, the sampler takes a new reference
        timestamp in the next frame update where player is moving.
        The sampler starts over whenever you change zones or sub-zones.
     5. The sampler is always running when it is enabled.

    IMPORTANT : ALL SAMPLES START WITH A 3-SECONDS OF STABILIZATION.
                YOU GET GOING FOR 3 SECONDS BEFORE THE START POINT.

     6. Without stopping, the sampler gets coordinates and timestamp at
        the first game-tick over 3000ms from start. This means that every sample
        will have at least 3 seconds of character movement before starting,
        to stabilize speed. This is the start timestamp and location.

    IMPORTANT : THE DEFAULT SAMPLE SIZE IS 10-SECONDS OF STRAIGHT MOVEMENT.
                IF YOU HIT A ROCK OR A STEP OR A RAMP OR TURN SLIGHTLY,
                YOUR SAMPLE SHOULD BE DISCARDED.

     7. Without stopping, the sampler gets coordinates and timestamp at the first
        game-tick over 13000ms from reference. This is very close to 10 seconds from
        the start. (10.007 seconds for example.) This is the end timestamp (and x/y).

        This is in the case of the default 10s sample size. You specify the sampler's
        sample size when you enable it. The sample size is specified as the time
        between the start and end timestamps, which is after the run-up period,
        and which is the period over which the character's speed will be measured.

     8. The sampler subtracts the start and end timestamps to get an exact time
        (in seconds, to the millisecond) from sample start to sample end.
     9. The sampler calculates the distance in map units from the start coordinate
        to the end coordinate, to available decimal places.

        This distance in map units is small (0.008293747823784 etc.).
        Map units are large. The sampler multiplies by 1000 to get the sample distance
        in thousandths of map units (milli-map-units, 8.293747823784 etc.).

        Safely ignore the tiny calculation-cost because the sample is already taken.

    10. The sampler divides the distance by the exact time in fractional seconds,
        to get an exact thousandths of map units, per second. (8.293747823784 etc.)
    11. The sampler saves the sample data, as a single number, to an internal table.
        The table is keyed to the zone and subzone. The sampler creates the table if there
        is no existing sample data for the current zone and subzone.

        If motion continues, take a reference timestamp, starting the next sample process.

    =================================================================
    How to actually use the built-in sampler

    First, you must choose the absolutely smoothest and straightest run of
    perfectly smooth glassy ground in the entire region to be measured.
    For instance, the longest side-terrace of Vivec's Fountain, with
    nothing and no one to bump you, avoiding any turns at each end.
    Often, the flattest path may not be an obvious straight paved road.
    It may be a stretch of shallow water with no rocks or plants.
    It may be a long bridge or a flat beach.

    You must be able to travel in a straight and level line for the duration
    of the sample length. The default is 10 seconds. If you must use a
    shorter sample time than 10 seconds (i.e. Murkmire villages) do not
    use less than 5 seconds.

     1. Start the sampler by typing "rp_sampling_on 10" in the chat/console,
        and pressing Enter. This is a 10-second sample length. Try to take
        reliable samples at this length, for new maps. If you absolutely cannot
        find a place to take a 10-second sample, do not go less than 5 seconds.

     2. You should see a message in a partially transparent box in the center of
        your screen which tells you the zone and what to do. For instance:

            Sampling: vvardenfell:viveccity_base
            Jog steadily to take a sample

     3. Start moving, and 3 seconds later, the bottom line of the display
        should change to an indicator and a running stopwatch timer:

            Sampling: vvardenfell:viveccity_base
            Sample Started... 4.5 sec  <-- this number should increase in realtime

     4. If you stop, you'll return to the "Jog steadily to take a sample" message.
        If you continue moving, the stopwatch should count all the way up to your
        sample length (the default is 10 seconds).

     5. If you reach the sample length, without stopping, you will see this display:

            Sampling: vvardenfell:viveccity_base
            Sample Taken: 1.304914574856

        The sample value is stored automatically.

        If you stop, you'll return to the "Jog steadily to take a sample" message.
        If you continue moving, the sampler will automatically start again shortly

     6. Continue until you have sufficiently converging samples.

     7. Quit the sampler by typing "rp_sampling_off" in the chat/console,
        and pressing Enter.

    =================================================================
    How to process your own sample data

     1. View your data by typing "rp_show_raw_data" in the chat/console,
        and pressing Enter. This provides summary data about the zones
        and subzones you've sampled, sample counts, averages, and individual
        sample data per zone.

     2. Navigate to the SavedVariables folder in your ESO install.
        Open RacingPanel.lua in your favorite editor.

     3. Find the character you were using to run the sampler. Below, my
        character is Drel Trandel. Find the "data" node, and locate the
        zone and subzone for which you wish to process sample data.
        Below, find the data for "rootwhisper_base".

            ["Drel Trandel"] = 
            {
                ["EU Megaserver"] = 
                {
                    ["data"] = 
                    {
                        ["murkmire"] = 
                        {
                            ["murkmire_base"] = 
                            {
                                [1] = 2.6421193024,
                            },
                            ["rootwhisper_base"] = 
                            {
                                [1] = 16.4836344105,
                                [2] = 16.4397318962,
                                [3] = 16.4753091948,
                                [4] = 16.4762114431,
                                [5] = 16.4835624969,
                                [6] = 16.4786349874,
                                [7] = 16.4788593148,
                                [8] = 16.4736277141,
                                [9] = 16.4738509228,
                                [10] = 16.4746879926,
                                [11] = 16.3055499496,
                            },
                        },
                    },
                },
            },

     4. Here is the data for "rootwhisper_base", arranged in
        order of value:

            16.3055499496,
            16.4397318962,
            16.4736277141,
            16.4738509228,
            16.4746879926,
            16.4753091948,
            16.4762114431,
            16.4786349874,
            16.4788593148,
            16.4835624969,
            16.4836344105,

        Now, toss all significant variations. It's not relevant to
        someone else's speed, if you hit a rock or whatever, during
        your sample. We are trying to gather data which agrees on
        a specific value, preferably to at least 2 decimals.

            16.4736277141,
            16.4738509228,
            16.4746879926,
            16.4753091948,
            16.4762114431,
            16.4786349874,
            16.4788593148,

        You'll want 30 or 40 values with this level of grouping
        or better. If you gather them at various places all over
        the map, that's ever better.

    IMPORTANT : A NOTE ABOUT SIGNIFICANT DIGITS

     5. You can truncate at this point to 5 decimal places.

        Let's go measure Sadrith Mora as an exaample.

            Scale value = 14.590974013164
            Random measured value = 20.2346859478

        Using all 12 decimal places in our Sadrith Mora data,
        our code is going to produce this speed, for the given
        measured distance:

            6.240576309912488 m/s
            6.240576 m/s

        Using only 6 decimal places from our Sadrith Mora data,
        our code is going to produce this speed, for the given
        measured distance:

            6.240578026347803 m/s
            6.240578 m/s

        So if we truncate our values, our speed is STILL consistent
        to the HUNDREDTH OF A MILLIMETER per second. I believe we agree,
        after seeing sample variations, that it would be crazy to assume
        our samples are that accurate. But, why round further!!

     6. Average your best data cluster, preferably with many more
        data points than this example:

            16.47362
            16.47385
            16.47468
            16.47530
            16.47621
            16.47863
            16.47885
            ===========
            16.47587

            Not bad for 5 minutes. Compare to 16.47651, our production value,
            which was produced from a larger sample group, on a different day.

     7. Now you have map scale data for Root-Whisper Village
        in Murkmire!

     8. While you are in your SavedVariables file, remove unwanted data.
        You can use the command, rp_delete_raw_data, but the SavedVariables
        file may not update if you have it open. Just zero the data node,
        for the characters who were sampling, when you are done sampling.
        Don't forget to save the file and close it.

                    ["data"] = 
                    {
                    },

     9. Add the zone and subzone to the data portion of your own
        MapScaleData.lua file.

         ["murkmire"] = 
         {
             ["rootwhisper_base"] = 16.47651,
         },

        Boom! your speedometer now works on that map!

        If you do something crazy like sample all the delves--
        send me the data, and I'll test it if I can, and ask others to help
        test it, and we'll try to share it.


    10. Fun Facts
        Smallest scaling multipliers:

        ["cyrodiil"]["ava_whole"] = 0.66996,
        ["vvardenfell_base"] = 1.48353,
        ["deshaan_base"] = 1.66297,

        Largest scaling multipliers

        ["eldenrootcrafting_base"] = 36.63666,
        ["eldenrootservices_base"] = 30.63275,
        ["brightthroatvillage_base"] = 24.90971,
        ["hoarfrost_base"] = 22.68366,
        ["dhalmora_base"] = 22.55969,


    =================================================================
    Samples used to provide map scale data:

     1. The samples represent: Thousandths of map units, per second,
        at default movement speed on level ground in a straight line,
        measured to milliseconds (thousandths of a second).

     2. Samples were colelected with a default length of 10-seconds.
        Some confined areas were sampled with shorter sample length.

     3. Data provided is generally: An average of hundreds and sometimes
        thousands of seconds of data, for each zone and subzone.

     4. Extraneous data was weeded before averaging. Preference was shown
        to high-precision groupings. This methodology produces consistent
        deviation. Even a slight bump against a small rock can produce a
        skewed data point. A few such bumps can affect the speedo output.

    =================================================================
]]

-------------------------------
