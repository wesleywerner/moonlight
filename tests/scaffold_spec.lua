describe ("scaffold", function()

  local scaffold = require("scaffold")

  it ("parse 'key: value'", function()
    local output = scaffold.parse_line("    name: Mary Shelley")
    assert.are.equal (4, output.indent)
    assert.are.equal ("name", output.key)
    assert.are.equal ("Mary Shelley", output.value)
    assert.is_false(output.is_compound)
  end)

  it ("parse 'key:value'", function()
    local output = scaffold.parse_line("    name:Mary Shelley")
    assert.are.equal (4, output.indent)
    assert.are.equal ("name", output.key)
    assert.are.equal ("Mary Shelley", output.value)
    assert.is_false(output.is_compound)
  end)

  it ("parse without ':value'", function()
    local output = scaffold.parse_line("    The Relaxation Lounge")
    assert.are.equal ("The Relaxation Lounge", output.key)
    assert.is_false(output.is_compound)
  end)

  it ("parse a '-- comment line'", function()
    local output = scaffold.parse_line("    -- this is a comment: ignore it")
    assert.are.equal ("-- this is a comment: ignore it", output.key)
    assert.is_true(output.is_comment)
  end)

  it ("parse 'an_underscore_key'", function()
    local output = scaffold.parse_line("    an_underscore_key: some value")
    assert.are.equal ("an_underscore_key", output.key)
  end)

  it ("parse line with key_with_123", function()
    local output = scaffold.parse_line("    key_with_123: some value")
    assert.are.equal ("key_with_123", output.key)
  end)

  it ("parse line with empty value (container)", function()
    local output = scaffold.parse_line("    container:")
    assert.are.equal ("container", output.key)
    assert.is_true(output.is_compound)
  end)

  it ("parse quoted line", function()
    local output = scaffold.parse_line("    \"Quoted\"")
    assert.are.equal ("Quoted", output.key)
    assert.are.equal ("", output.value)
    assert.is_true(output.is_quoted)
  end)

  it ("builds a model from notation", function()
    local model = scaffold.build([[
The Relaxation Lounge
  description: This room looks very relaxed.
  contains:
    Cabinet
      description: It is a smoothly lacquered wooden cabinet.
      contains:
        Babushka Dolls
          description: Carved wooden dolls that fit into each other.
      supports:
        Scented Candle
          description: candle
        Apple
          description: apple
        Silver Key
          unlocks:
            "Cabinet"
    ]])
    --require 'pl.pretty'.dump(model)
    local expected = {
      {
        name = "The Relaxation Lounge",
        description = "This room looks very relaxed.",
        contains = {
          {
            name = "Cabinet",
            description = "It is a smoothly lacquered wooden cabinet.",
            contains = {
              {
                name = "Babushka Dolls",
                description = "Carved wooden dolls that fit into each other."
              }
            },
            supports = {
              {
                name = "Scented Candle",
                description = "candle"
              },
              {
                name = "Apple",
                description = "apple"
              },
              {
                name = "Silver Key",
                unlocks = {
                  "Cabinet"
                }
              }
            }
          }
        }
      }
    }
    --require 'pl.pretty'.dump(expected)
    assert.are.same(expected, model)
  end)

  it ("interprets boolean values", function()
    local model = scaffold.build([[
An empty room
  truthy_via_symbol: true
  truthy_via_synonym: yes
  falsy_via_symbol: false
  falsy_via_synonym: no
]])
    local expected = {
      {
        name = "An empty room",
        truthy_via_symbol = true,
        truthy_via_synonym = true,
        falsy_via_symbol = false,
        falsy_via_synonym = false
      }
    }
    --require 'pl.pretty'.dump(model)
    --require 'pl.pretty'.dump(expected)
    assert.are.same (expected, model)
  end)

end)
