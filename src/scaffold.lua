--- Provides helper methods for easier world building.
-- You can model a world using a simple shorthand notation, as
-- an alternative to building the tables by hand. See @{model_notation.lua}
-- for the notation format and examples.
--
-- @module scaffold

--- Splits a block of text into lines by
-- either win32 or POSIX line ending.
-- @function split_lines
--
-- @param str string
-- @return table of lines
local function split_lines (str)
   local t = {}
   local function helper(line)
      table.insert(t, line)
      return ""
   end
   helper((str:gsub("(.-)\r?\n", helper)))
   return t
end

--- Trims spaces from either side of a string.
-- @function trim
-- @param str string
-- @return trimmed string
local function trim (str)
  return string.match(str, "^%s*(.-)%s*$")
end

--- A table with line context information.
-- @table line_context
--
-- @field indent number
-- The indentation amount.
--
-- @field key string
-- The value of the key.
--
-- @field value variant
-- The value of the key, can be of any simple data type.
--
-- @field is_comment boolean
-- True if the key is a commented line
--
-- @field is_compound boolean
-- True if the context begins a new compound property, i.e.
-- a property which contains other properties.
-- This is identified as a line contains a colon with no inline value.
--
-- @field is_empty boolean
-- true if the key and value are both empty.


--- Extracts indentation information and
-- name/value pairs from a string.
-- @function parse_line
--
-- @param line string
-- @return instance of @{line_context}
local function parse_line(line)

  local indent = 0
  local key, value = "", ""
  local is_compound = false

  -- count the number of indents
  for n in string.gmatch(line, ".") do
    if n == " " then
      indent = indent + 1
    else
      break
    end
  end

  -- split key/value
  local seperator_position = string.find(line, ":")
  if seperator_position then
    -- previous key match pattern: "(%a+):"
    key = string.match(line, "[%a_]+[%a%d_]*")
    value = string.match(line, ":(.+)")
    value = trim(value or "")
    -- an empty value makes this line a container
    is_compound = value == ""
  else
    -- simply trim the line to get the key
    key = trim(line)
  end

  local is_comment = string.find(key, "^%-%-") and true or false

  -- interpret booleans
  if value == "true" or value == "yes" then
    value = true
  end
  if value == "false" or value == "no" then
    value = false
  end

  return {
    indent = indent,
    key = key,
    value = value,
    is_comment = is_comment,
    is_compound = is_compound,
    is_empty = key == "" and value == ""
  }

end

--- Constructs a world model from a multi-line shorthand notation.
-- @function build
--
-- @param string input
-- The world model definition.
--
-- @return A table representing the world model.
local function build (input)

  local model = { }
  local stack = { model }
  local top = stack[#stack]
  local indent_factor = nil
  local last_indent = nil
  local lines = split_lines(input)

  for no, line in ipairs(lines) do

    -- parse this line into a indent/key/value context
    local context = parse_line(line)

    if not context.is_comment and not context.is_empty then

      -- adjust indent by factor of 2 to get 1:1 ratio of indentation changes
      context.indent = context.indent / 2

      -- indent n-1 pops the stack
      if last_indent then
          local indent_amount = context.indent - last_indent
          -- pop the stack for each indent level below zero
          while indent_amount < 0 do
              table.remove(stack)
              indent_amount = indent_amount + 1
              -- refocus top
              top = stack[#stack]
          end
      end

      -- push a new table to the stack
      if context.is_compound then
        local new_item = { }
        --new_item["line no"] = no
        top[context.key] = new_item
        -- push it to the stack
        table.insert(stack, new_item)
        top = stack[#stack]
      else
        if context.value == "" then
          -- new room/thing by name
          local new_item = { ["name"] = context.key }
          --new_item["line no"] = no
          table.insert(top, new_item)
          table.insert(stack, new_item)
          top = stack[#stack]
        elseif context.key ~= "" then
          -- direct property assignment
          top[context.key] = context.value
        end
      end

      -- store indent for next iteration
      last_indent = context.indent

    end

  end

  return model

end

return {
  build = build,
  split_lines = split_lines,
  parse_line = parse_line
}
