--- The standard opening things rulebook.
-- @module open_rules
return function (rulebooks)

	rulebooks.before.open = {
		{
			name = "check items exist",
			action = function (self, command)
				if not command.item1 then
					return string.format(self.template.missingFirstNoun, command.verb), false
				end
			end
		},
		{
			name = "not something that can open",
			action = function (self, command)
				if command.item1.closed == nil then
					return string.format(self.template.notOpenable, command.item1.name), false
				end
			end
		},
		{
			name = "already open",
			action = function (self, command)
				if command.item1.closed == false then
					return string.format(self.template.alreadyOpen, command.item1.name), false
				end
			end
		},
	}

	rulebooks.on.open = {
		{
			name = "opening",
			action = function (self, command)
				command.item1.closed = false
				return string.format(self.template.opened, command.item1.name)
			end
		},
		{
			name = "auto listing opened contents",
			action = function (self, command)
				if self.options.auto["list contents of opened"] == true then
					local contents = self:listContents (command.item1)
					return contents
				end
			end
		}
	}

end
