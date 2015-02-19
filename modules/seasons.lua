-- determine in-game season from real-life date, with realtime 2 weeks equalling 1 in-game year
-- returns two numbers: an integer 1-4 (the season) and a decimal between 0 and 1 (exactly how far into that season we are)
function getSeason()
   return math.modf(((os.time() / 302400)-1) % 4 + 1)
end

-- example of using those numbers
function natureGenerator()
   local season, day = getSeason()
   
   -- assuming you want month 1 to be the start of winter
   if season < 1 then
      -- it's winter, make snow
      if day > .7 then
         -- start making the snow melt
      end
   elseif season < 2 then
      -- it's spring, make green stuff
      if day < .2 then
         -- it's still chilly, so use some colder greens and shadows
      elseif day < .5 then
         -- higher chance of rain
      elseif day > .8 then
         -- everything should be about done blooming by now
      end
   elseif season < 3 then
      -- it's summer, use warm colors
      if day > .4 and day < .6 then
         -- if you've ever been to Florida, you'll agree this is the most wretched part of the year
      end
   else
      -- it's fall, time for naked trees
      if day > .8 then
         -- make a first little snowstorm or something
      end
   end
end

os.date ([format [, time]])

Returns a string or a table containing date and time, formatted according to the given string format.

If the time argument is present, this is the time to be formatted (see the os.time function for a description of this value). Otherwise, date formats the current time.

If format starts with '!', then the date is formatted in Coordinated Universal Time. After this optional character, if format is the string "*t", then date returns a table with the following fields: year (four digits), month (1--12), day (1--31), hour (0--23), min (0--59), sec (0--61), wday (weekday, Sunday is 1), yday (day of the year), and isdst (daylight saving flag, a boolean).

If format is not "*t", then date returns the date as a string, formatted according to the same rules as the C function strftime.

When called without arguments, date returns a reasonable date and time representation that depends on the host system and on the current locale (that is, os.date() is equivalent to os.date("%c")). 