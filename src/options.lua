local options = {
	ignores = { "an", "a", "the", "for", "to", "at", "of",
		"with", "about", "on", "and", "from", "into" },
	synonyms = {
		{ "attack", "hit", "smash", "kick", "cut", "kill" },
		{ "go", "enter" },
		{ "insert", "put" },
		{ "take", "get", "pick" },
		{ "inventory", "i" },
		{ "examine", "x", "l", "look" },
		{ "north", "n" },
		{ "south", "s" },
		{ "east", "e" },
		{ "west", "w" },
		{ "northeast", "ne" },
		{ "southeast", "se" },
		{ "northwest", "nw" },
		{ "southwest", "sw" },
		{ "in", "inside" },
		{ "out", "outside" }
	},
	vowels = {"a", "e", "i", "o", "u"},
	directions = {
		"n","north",
		"s","south",
		"e","east",
		"w","west",
		"ne", "northeast",
		"se", "southeast",
		"nw", "northwest",
		"sw", "southwest",
		"up",
		"down",
		"in", "inside",
		"out", "outside",
		"under", "behind"
		},
	auto = {
		-- list all exits after the room description
		["list exits"] = true,
		-- list the contents of a container when opening it
		["list contents of opened"] = true,
		-- take things found while searching
		["take things searched"] = false,
		-- open things when unlocking them
		["open unlocked things"] = false
	},
	verbose = {
		rulebooks = true,
		parser = true,
		descriptions = false
	},
	testing = true
}

return options
