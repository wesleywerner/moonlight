describe ("parser", function()

	local ml = require("src/lantern")

	it ("verb noun", function() 
		local result = ml:parse("open door")		
		local expected = {
			verb="open",
			item="door"
			}
		assert.are.same(expected, result)
	end)
	
	it ("ignored words", function() 
		local result = ml:parse("open the door")		
		local expected = {
			verb="open",
			item="door"
			}
		assert.are.same(expected, result)
	end)

	it ("listing nouns: the gargoyle", function() 
		local result = ml:parse("give sword to gargoyle")		
		local expected = {
			verb="give",
			item="sword",
			nouns={"gargoyle"}
			}
		assert.are.same(expected, result)
	end)
	
	it ("listing nouns: the gate and the skeleton key", function() 
		local result = ml:parse("unlock the gate with the skeleton key", {"gate", "skeleton key"})		
		local expected = {
			verb="unlock",
			item="gate",
			nouns={"skeleton key"}
			}
		assert.are.same(expected, result)
	end)
	
	it ("listing nouns: the gate and the skeleton key (lazy)", function() 
		local result = ml:parse("unlock gate skel", {"gate", "skeleton key"})		
		local expected = {
			verb="unlock",
			item="gate",
			nouns={"skeleton key"}
			}
		assert.are.same(expected, result)
	end)
	
	it ("listing nouns: the unseen tablet", function() 
		local result = ml:parse("ask the wise guy about an unseen tablet", {"wise guy", "computer"})		
		local expected = {
			verb="ask",
			item="wise guy",
			nouns={"unseen", "tablet"}
			}
		assert.are.same(expected, result)
	end)
	
	it ("interpolate synonymns: look/examine", function() 
		local result = ml:parse("look at the gate")		
		local expected = {
			verb="examine",
			item="gate"
			}
		assert.are.same(expected, result)
	end)
	
	it ("interpolate synonymns: get/take", function() 
		local result = ml:parse("get an apple")		
		local expected = {
			verb="take",
			item="apple"
			}
		assert.are.same(expected, result)
	end)

	it ("interpolate synonymns: put/insert", function() 
		local result = ml:parse("put the box on the table")		
		local expected = {
			verb="insert",
			item="box",
			nouns={"table"}
			}
		assert.are.same(expected, result)
	end)

	it ("interpolate synonymns: x/examine", function() 
		local result = ml:parse("x red apple", {"red apple"})		
		local expected = {
			verb="examine",
			item="red apple"
			}
		assert.are.same(expected, result)
	end)

	it ("interpolate synonymns: i/inventory", function() 
		local result = ml:parse("i")		
		local expected = {
			verb="inventory"
			}
		assert.are.same(expected, result)
	end)

	it ("recognizing known nouns: the old man", function() 
		local result = ml:parse("talk to the old man", {"old man"})		
		local expected = {
			verb="talk",
			item="old man"
			}
		assert.are.same(expected, result)
	end)

	it ("recognizing known nouns: the red stone", function() 
		local result = ml:parse("take red", {"red stone", "blue stone"})		
		local expected = {
			verb="take",
			item="red stone"
			}
		assert.are.same(expected, result)
	end)

	it ("recognizing known nouns: the wise guy", function() 
		local result = ml:parse("ask the wise guy about the computer", {"wise guy", "computer"})		
		local expected = {
			verb="ask",
			item="wise guy",
			nouns={"computer"}
			}
		assert.are.same(expected, result)
	end)

	it ("recognizing known nouns: the wise guy (lazy)", function() 
		local result = ml:parse("ask guy the comp", {"wise guy", "computer"})		
		local expected = {
			verb="ask",
			item="wise guy",
			nouns={"computer"}
			}
		assert.are.same(expected, result)
	end)

	it ("recognizing known nouns: the wormwood herb", function() 
		local result = ml:parse("eat herb", {"wormwood herb"})		
		local expected = {
			verb="eat",
			item="wormwood herb"
			}
		assert.are.same(expected, result)
	end)

	it ("recognizing directions: going northwest", function() 
		local result = ml:parse("go northwest")		
		local expected = {
			verb="go",
			direction="northwest"
			}
		assert.are.same(expected, result)
	end)

	it ("recognizing directions: looking east", function() 
		local result = ml:parse("look e")		
		local expected = {
			verb="examine",
			direction="e"
			}
		assert.are.same(expected, result)
	end)

	it ("recognizing directions: in", function() 
		local result = ml:parse("look in mirror")		
		local expected = {
			verb="examine",
			item="mirror",
			direction="in"
			}
		assert.are.same(expected, result)
	end)


end)
