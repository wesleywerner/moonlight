--- The standard rulebooks module.
-- Provides functions to make working with rulebooks easier.
-- @module rulebooks
--
return function (rulebooks)

	--- A rule is a table with a name (string) and action (function).
	-- The action signature is (@{moonlight} instance, @{moonlight:command} object).
	-- @table rule
	-- @usage
	--
	-- local my_examine_rule = {
	-- 	name = "my examine rule",
	-- 	action = function (moonlight, command)
	-- 		if command.first_item and commandfirst_item.name == "mailbox" then
	-- 			-- the player has command.verb on the mailbox
	-- 		end
	-- 	end
	-- }

	--- A key-value table of rules that get triggered before a verb is actioned.
	-- The key being the verb, the value a @{rule}
	-- @table before
	-- @usage
	-- table.insert(moonlight.rulebooks.before.examine, my_before_examine_rule)

	--- A key-value table of rules that get triggered on a verb action.
	-- The key being the verb, the value a @{rule}
	-- @table on
	-- @usage
	-- table.insert(moonlight.rulebooks.on.examine, my_examine_rule)

	--- A key-value table of rules that get triggered after a verb was actioned.
	-- The key being the verb, the value a @{rule}
	-- @table after
	-- @usage
	-- table.insert(moonlight.rulebooks.after.examine, my_after_examine_rule)

	--- Ensures the default rule categories exist.
	function rulebooks.reset (self)
		self.before = { }
		self.on = { }
		self.after = { }
	end

	--- Get a list of recognised timings  in rulebooks.
	function rulebooks.listTimings (self)
		return { "before", "on", "after" }
	end

	--- Get a list of rulebook names.
	function rulebooks.listBooks (self)
		local timings = self:listTimings()
		local books = { }
		local skip = { }

		for _, timing in ipairs(timings) do
			for verb, ruleList in pairs(self[timing]) do
				-- unique items only
				if not skip[verb] then
					table.insert(books, verb)
					skip[verb] = true
				end
			end
		end

		-- sort alphabetically
		table.sort(books)

		return books
	end

	--- Get the list of rule names for a rulebook.
	function rulebooks.listRules (self, bookname)
		local output = { }
		local timings = self:listTimings()
		for _, timing in ipairs(timings) do
			for _, rule in ipairs(self[timing][bookname] or {}) do
				-- initialise table before adding the rule name
				output[timing] = output[timing] or { }
				table.insert(output[timing], rule.name)
			end
		end
		return output
	end

	--- Gets a formatted string of rules.
	function rulebooks.list (self)

		local output = { }
		local books = self:listBooks()
		local timings = self:listTimings()

		for _, bookname in ipairs(books) do
			table.insert(output, string.format("\n[%s rulebook]", bookname))
			local rules = self:listRules(bookname)
			for _, timing in ipairs(timings) do
				for _, rulename in ipairs(rules[timing] or {}) do
					table.insert(output, string.format("<%s> %q rule", timing, rulename))
				end
			end
		end

		return table.concat(output, "\n")

	end

	--- Add a before-rule.
	--
	-- @param self @{instance}
	--
	-- @param verb
	-- The verb affected by this rule
	function rulebooks.addBefore (self, verb, name, action)
		self.before[verb] = self.before[verb] or { }
		local newrule = { name = name, action = action }
		table.insert(self.before[verb], newrule)
	end

	function rulebooks.addOn (self, verb, name, action)
		self.on[verb] = self.on[verb] or { }
		local newrule = { name = name, action = action }
		table.insert(self.on[verb], newrule)
	end

	function rulebooks.addAfter (self, verb, name, action)
		self.after[verb] = self.after[verb] or { }
		local newrule = { name = name, action = action }
		table.insert(self.after[verb], newrule)
	end

	rulebooks.reset (rulebooks)

end
