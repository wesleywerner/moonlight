--- Provides helper functions to enhance the @{command} object.
--
-- @module command_functions
return function (command)

	--- Test if the first noun is present.
	-- The noun is the name of a thing as interpreted by the parser.
	-- The noun may refer to a thing that does not exist.
	-- @param self @{command}
	-- @return boolean
	command.has_first_noun = function (self)
		return type(self.nouns[1]) == "string"
	end

	--- Test if the second noun is present.
	-- The noun is the name of a thing as interpreted by the parser.
	-- The noun may refer to a thing that does not exist.
	-- @param self @{command}
	-- @return boolean
	command.has_second_noun = function (self)
		return type(self.nouns[2]) == "string"
	end

	--- Test if the first item is present.
	-- The item is the instance of a thing named after the noun.
	-- @param self @{command}
	-- @return boolean
	-- Truthy if the
	command.has_first_item = function (self)
		return type(self.item1) == "table"
	end

end
