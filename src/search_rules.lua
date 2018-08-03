--- The standard search rulebook.
-- @module search_rules
return function (rulebooks)

	rulebooks.before.search = rulebooks.before.search or { }

	rulebooks.before.search = {
		{
			name = "a seen thing",
			action = function (self, command)
				if not command.item1 then
					return self.template.search["too broad"], false
				end
			end
		},
		{
			name = "that which does not hide",
			action = function (self, command)
				if not command.item1.hides then
					return self.template.search["unlucky"], false
				end
			end
		},
		{
			name = "",
			action = function (self, command)

			end
		},
	}

	rulebooks.on.search = {
		{
			name = "report action",
			action = function (self, command)
				return string.format (self.template.search["report"], command.item1.name)
			end
		},
		{
			name = "take action",
			action = function (self, command)
				local parent = command.item1
				for _, found in ipairs(command.item1.hides) do
					if parent.supports then
						self:moveOn (found, parent)
					elseif parent.contains then
						self:moveIn (found, parent)
					else
						self:moveIn (found, self.room)
					end
					table.insert (self.responses,
						string.format(self.template.search["found"], self:withArticle(found)))
				end
			end
		},
	}

	rulebooks.after.search = {

	}

end
