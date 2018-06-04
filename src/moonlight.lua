

local options = {
	ignores = {"an", "a", "the", "for", "to", "at", "of", "with", "about", "on"},
	synonymns = {
		{"attack", "hit", "smash", "kick", "cut", "kill"},
		{"insert", "put"},
		{"take", "get", "pick"},
		{"inventory", "i"},
		{"examine", "x", "l", "look"},
	},
	vowels = {"a", "e", "i", "o", "u"},
	directions = {
		"north", "n",
		"south", "s",
		"east", "e",
		"west", "w",
		"northeast", "ne",
		"southeast", "se",
		"northwest", "nw",
		"southwest", "sw",
		"up", "down", "in", "out"
		}
}


--- Split a string.
local function split(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end


local function find (t, f)
	for k, v in pairs(t) do
		if f(k, v) then
			return v
		end
	end
	return nil
end


local function filter (t, f)
	local matches = {}
	for k, v in pairs(t) do
		if f(k, v) then
			table.insert(matches, v)
		end
	end
	return matches
end


local function indexOf (t, cmp)
	for k, v in pairs(t) do
		if v == cmp then
			return k
		end
	end
	return 0
end


local function contains (t, cmp)
	if t == nil then
		print("this one is nil", cmp)
	end
	return indexOf(t, cmp) > 0
end


--- Our sentence parser.
local function parse (self, sentence, known_nouns)

--		// split the parts of the sentence. Always work in lowercase.
--		var parts = sentence.toLowerCase().split(' ');
--		var sense = { };

	local parts = split(sentence:lower(), " ")
	
--		
--		// find directions
--		sense.dir = parts.find(function (item) { return directions.indexOf(item) > -1 });

	local direction = find(parts, function(k, v)
		return contains(self.options.directions, v)
	end)


--		// remove ignored and directions from further processing
--		parts = parts.filter(function (item) { return _options.ignores.indexOf(item) == -1 });
--		parts = parts.filter(function (item) { return directions.indexOf(item) == -1 });

	parts = filter(parts, function(k, v) 
		return not contains(self.options.directions, v)
	end)

	parts = filter(parts, function(k, v) 
		return not contains(self.options.ignores, v)
	end)

--
--		// replace any partial nouns with the known nouns.
--		// this works for the most part, except if a partial can
--		// match multiple known nouns, it will match the last one.
--		if (known_nouns) {
--			parts.forEach(function (singlepart, i, arr) {
--				// match start of word boundary, but allow a wildcard ending.
--				// this allows for more relaxed noun matching.
--				var re = new RegExp('\\b'+singlepart);
--				known_nouns.forEach(function (noun) {
--					var match = noun.match(re);
--					if (match != null) {
--						arr[i] = noun;
--					}
--				});
--			});
--		}


	if known_nouns then
		for partno, part in ipairs(parts) do
			for nounno, noun in ipairs(known_nouns) do
				-- if the part matches a known noun
				if string.match(noun, part) then
					-- replace the part with the match
					parts[partno] = noun
				end
			end
		end
	end

--		
--		// remove duplicates.
--		// this can happen when known nouns are matched to multiple parts.
--		parts = parts.filter(function (item, index, arr) {
--			return arr.indexOf(item) == index;
--		});

	parts = filter(parts, function(k, v)
		return indexOf(parts, v) == k
	end)


--		
--		sense.verb = (parts.length > 0) && parts[0] || null;
--		sense.item = (parts.length > 1) && parts[1] || null;
--		sense.nouns = (parts.length > 2) && parts.slice(2) || null;
--		sense.all = parts;

	local verb = #parts > 0 and parts[1]
	
	local item = nil
	if #parts > 1 then
		item = parts[2]
	end
	
		-- remove first two parts to get the nouns
	local nouns = parts
	if #parts > 2 then
		table.remove(nouns, 1)
		table.remove(nouns, 1)
	else
		nouns = nil
	end

--		
--		// change verbs to their root synonymn. The first entry is the root word.
--		_options.synonymns.forEach(function(wordlist) {
--			if (wordlist.indexOf(sense.verb) > 0) {
--				sense.verb = wordlist[0];
--			}
--		});
--		
--		return sense;

	for i, wl in ipairs(self.options.synonymns) do
		if contains(wl, verb) then
			verb = wl[1]
		end
	end


	return { verb=verb, item=item, direction=direction, nouns=nouns }

end

-- return the lantern object
return { options=options, parse=parse }
