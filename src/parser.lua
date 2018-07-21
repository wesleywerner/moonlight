--- The parser
-- @module parser

local utils = require("utils")
local soundexlib = require("soundex")

--- Parse a sentence into a command object.
-- It extracts the verb and nouns from the sentence, and partially
-- input noun names are replaced by their full equivalent.
-- @function parse
--
-- @param self
--
-- @param sentence
-- The sentence to parse.
--
-- @param options
-- Table of options.
-- known_nouns
-- (a table of noun names to match partial noun names in the sentence),
-- directions (a table of known compass directions in all variations),
-- ignores
-- (a table of words to ignore)
-- synonyms
-- (a list of tables of synonymous words, the first word being the root)
--
-- @return @{moonlight:command}
return function (sentence, options)

	-- assume safe defaults
	options = options or { }
	options.directions = options.directions or { }
	options.ignores = options.ignores or { }
	options.synonyms = options.synonyms or { }
	options.known_nouns = options.known_nouns or { }

	-- precalculate the sounds of known words
	if options.soundex == true then
		for _, word in ipairs(options.known_nouns) do
			soundexlib:set (word)
		end
		--for _, word in ipairs(options.ignores) do
		--	soundexlib:set (word)
		--end
		--for _, wordlist in ipairs(options.synonyms) do
		--	for _, word in ipairs(wordlist) do
		--		soundexlib:set (word)
		--	end
		--end
	end

	-- Split the sentence into parts. Always work in lowercase.
	local parts = utils.split(sentence:lower(), " ")

	-- Extract the verb
	local verb = table.remove(parts, 1)

	-- use soundex matching
	if options.soundex then
		for i, v in ipairs(parts) do
			local match = soundexlib:get (v)
			if match then
				parts[i] = match
			end
		end
	end

	-- Extract the direction.
	local function findDirectionFilter(k, v)
		return utils.contains(options.directions, v)
	end

	local direction = utils.find(parts, findDirectionFilter)

	-- Remove directions
	local function removeDirectionsFilter(k, v)
		return not utils.contains(options.directions, v)
	end

	parts = utils.filter(parts, removeDirectionsFilter)

	-- Remove ignored words
	local function removeIgnoresFilter(k, v)
		return not utils.contains(options.ignores, v)
	end

	parts = utils.filter(parts, removeIgnoresFilter)

	local nouns = { }

	local function matches (test)
		local count = 0
		local match = nil
		for _, trueNoun in ipairs (options.known_nouns) do
			local s, e, m = string.find (trueNoun:lower(), test)
			if s then
				count = count + 1
				match = trueNoun
			end
		end
		return count, match
	end


	-- match known nouns in the sentence using iterative scanning.
	-- start with the first word. if it has multiple matches
	-- then include the next word and scan again
	-- until exactly one or none match.
	for position = 1, #parts do

		local noun = parts[position]

		-- get the number of matches
		local matchCount, matchWord = matches (noun)

		-- if a word does not match, include it in the noun list
		-- unless it is part of a multi-match scenario
		local skipNegativeInclude = false

		-- multi matches: include the next noun and try again
		while (matchCount > 1) and (position <= #parts) do
			-- including the extra word moves the position forward
			position = position + 1
			skipNegativeInclude = true
			matchCount, matchWord = matches (string.format ("%s %s", noun, parts[position]))
		end

		-- a single match is success
		if matchCount == 1 then
			if not utils.contains (nouns, matchWord) then
				table.insert (nouns, matchWord)
			end
		else
			-- no match will use the player provided word as the noun.
			-- this allows rulebooks to refer to this noun even though
			-- it does not match any known thing.
			if not skipNegativeInclude then
				table.insert (nouns, noun)
			end
		end

		position = position + 1

	end


	-- Change verbs to their root synonym.
	-- The first entry is the synonym list is the root word.
	for i, wl in ipairs(options.synonyms) do
		if utils.contains(wl, verb) then
			verb = wl[1]
		end
	end

	-- Change direction to the root synonym.
	for i, wl in ipairs(options.synonyms) do
		if utils.contains(wl, direction) then
			direction = wl[1]
		end
	end

	return { verb=verb, nouns=nouns, direction=direction }

end

