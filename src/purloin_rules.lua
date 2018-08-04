return function (rulebooks)

	rulebooks.before.purloin = {
		{
			name = "thing exits",
			action = function (self, command)
				-- use a wizard search to find the thing in the entire world
				local noun = command.nouns[1]

				-- join the second noun.
				-- purloin calls search without known nouns lists, so
				-- include all noun parts to make a full name.
				if #command.nouns == 2 then
					noun = noun .. " " .. command.nouns[2]
				end

				local thing = self.searchFirst (self, noun, nil, true)
				if thing then
					command.item1 = thing
				else
					return string.format("%q not found in this world.", noun), false
				end
			end
		}
	}

	rulebooks.on.purloin = {
		{
			name = "purloin found thing",
			action = function (self, command)
				self.moveIn (self, command.item1, self.player)
				return string.format("The %s magically appears in your pocket.", command.item1.name)
			end
		}
	}

end
