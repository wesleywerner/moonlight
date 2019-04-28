return function (rulebooks)

	rulebooks.before.purloin = {
		{
			name = "the noun exits",
			action = function (self, command)
				-- use a wizard search to find the thing in the entire world
				local noun = command.first_noun

				-- join the second noun.
				-- purloin calls search without known nouns lists, so
				-- include all noun parts to make a full name.
				if #command.nouns == 2 then
					noun = noun .. " " .. command.second_noun
				end

				local thing = self.search_first (self, noun, nil, true)
				if thing then
					command.first_item = thing
				else
					return string.format("%q not found in this world.", noun), false
				end
			end
		}
	}

	rulebooks.on.purloin = {
		{
			name = "move the item to the player",
			action = function (self, command)
				self.move_thing_into (self, command.first_item, self.player)
			end
		}
	}

	rulebooks.after.purloin = {
		{
			name = "report",
			action = function (self, command)
				return string.format("The %s magically appears in your pocket.", command.first_item.name)
			end
		}
	}

end
