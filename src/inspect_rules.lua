return function (rulebooks)

	rulebooks.before.inspect = {
    {
      name = "noun is given",
      action = function (self, command)
        if not command.first_noun then
          return "Give the name of the thing to inspect.", false
        end
      end
    },
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

	rulebooks.on.inspect = { }

	rulebooks.after.inspect = {
		{
			name = "report",
			action = function (self, command)
        require 'pl.pretty'.dump(command.first_item)
				return ""
			end
		}
	}

end
