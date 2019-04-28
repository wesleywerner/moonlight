--- The standard inserting things into other things rulebook.
-- @module insert_rules
return function (rulebooks)

	-- Note: the command direction will be "in" for containers
	-- when the input is "in" or "inside".
	rulebooks.before.insert = {
		{
			name = "the nouns exist",
			action = function (self, command)
				if not command.first_item then
					return string.format(self.responses.thing["not carried"], command.first_noun), false
				end
				if not command.second_item then
					return string.format(self.responses.unknown["thing"], command.second_noun), false
				end
			end
		},
		{
			name = "the player is carrying the first noun",
			action = function (self, command)
				if not self:is_carrying (command.first_item) then
					return string.format(self.responses.thing["not carried"], command.first_item.name), false
				end
			end
		},
		{
			name = "the second noun can contain things",
			action = function (self, command)
				if command.direction == "in" and type(command.second_item.contains) ~= "table" then
					return string.format(self.responses.insert["not container"], self:format_name (command.second_item)), false
				end
			end
		},
		{
			name = "the second noun can support things",
			action = function (self, command)
				if command.direction == nil and type(command.second_item.supports) ~= "table" then
					return string.format(self.responses.insert["not supporter"], self:format_name (command.second_item)), false
				end
			end
		},
		{
			name = "the second noun is a closed container",
			action = function (self, command)
				if command.second_item.closed == true then
					return string.format(self.responses.insert["into closed"], command.second_item.name), false
				end
			end
		}
	}

	rulebooks.on.insert = {
		{
			name = "move the noun into the container",
			action = function (self, command)
				if command.direction == "in" then
					self:move_thing_into (command.first_item, command.second_item)
					return string.format(self.responses.insert["in"], command.first_item.name, command.second_item.name)
				end
			end
		},
		{
			name = "move the noun onto the supporter",
			action = function (self, command)
				if command.direction == nil then
					self:move_thing_onto (command.first_item, command.second_item)
					return string.format(self.responses.insert["on"], command.first_item.name, command.second_item.name)
				end
			end
		}
	}

end
