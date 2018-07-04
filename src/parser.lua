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

	-- Replace any partial nouns with the known nouns.
	-- If a partial matches multiple known nouns, it will match the last one.
	if options.known_nouns then
		for partno, part in ipairs(parts) do
			for nounno, noun in ipairs(options.known_nouns) do
				-- if the part matches a known noun
				if string.match(noun, part) then
					-- replace the part with the match
					parts[partno] = noun
				end
			end
		end
	end

	-- Remove duplicates which can occur from the above step.
	local function removeDuplicatesFilter(k, v)
		return utils.indexOf(parts, v) == k
	end

	parts = utils.filter(parts, removeDuplicatesFilter)

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

	return { verb=verb, nouns=parts, direction=direction }

end

