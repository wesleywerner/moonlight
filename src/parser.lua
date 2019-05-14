--- The parser
-- @module parser

--local dbg = require("debugger")
--dbg.auto_where = 2
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

	-- List known nouns that contains "test"
	local function match_filter (test)
		local count = 0
		local match = nil
		for _, trueNoun in ipairs (options.known_nouns) do
			-- trueNoun contains test
			if string.match (trueNoun:lower(), test) then
				count = count + 1
				match = trueNoun
			end
		end
		return count, match
	end

	-- Process each part of the sentence
	while #parts > 0 do

		-- test the next part
		local test_part = table.remove(parts)

		-- get a list of known nouns that contains test_part
		local matched_names = utils.filter(options.known_nouns,
			function(_idx, v)
				return string.match (v:lower(), test_part)
			end)

		if #matched_names == 0 then
			-- take the input value for no match.
			-- the value is kept so that rulebooks can refer to it later.
			table.insert (nouns, 1, test_part)
		elseif #matched_names == 1 then
			-- accept a single match (ignores duplicates)
			if (nouns[1] ~= matched_names[1]) then
				table.insert (nouns, 1, matched_names[1])
			end
		else
			-- AMBIGUOUS MATCH
			-- If there are multiple known nouns that match our part
			-- then we will try one more time by combining the
			-- current part with the next part.
			-- This will catch nouns composed of multiple words.
			-- There are edge cases - similar nouns that start with
			-- 2 or more matching words.
			-- It is just bad game design to name items so similarly IMHO.
			if #parts > 0 then
				-- get next word and combine with current
				local next_part = table.remove(parts)
				test_part = next_part .. " " .. test_part
				-- find matches again
				local matched_names = utils.filter(options.known_nouns,
					function(_idx, v)
						return string.match (v:lower(), test_part)
					end)
				-- only settle for exact matches
				if #matched_names == 1 then
					-- accept and ignore duplicates
					if (nouns[1] ~= matched_names[1]) then
						table.insert (nouns, 1, matched_names[1])
					end
				else
					-- put the next_part back for the next iteration
					table.insert(parts, next_part)
				end
			end
		end

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

