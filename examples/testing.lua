--- Testing moonlight games.
-- This file lists the testing verbs available to to simulator.
--
-- PURLOIN
-- This moves a thing from anywhere in the world into the player's inventory.
-- It does not matter if the thing is in another room, in a closed container
-- or carried by another person. Because purloin does not leverage the
-- parser's ability to recognize known nouns in rooms other than the
-- current room, you need to give the full name.
--
-- > PURLOIN the brass lantern
