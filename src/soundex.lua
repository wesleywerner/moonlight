--- Provides phonetic sound matching
-- @module soundex

-- Code taken from https://www.rosettacode.org/wiki/Soundex#Lua

local d, digits, alpha = '01230120022455012623010202', {}, ('A'):byte()
local cache = { }

d:gsub(".", function(c)
	digits[string.char(alpha)] = c
	alpha = alpha + 1
end)

local function soundex(w)
  local res = {}
  for c in w:upper():gmatch'.' do
	local dig = digits[c]
	if dig then
	  if #res==0 then
		res[1] =  c
	  elseif #res==1 or dig ~= res[#res] then
		res[1+#res] = dig
	  end
	end
  end
  if #res == 0 then
	return '0000'
  else
	res = table.concat(res):gsub("0",'')
	return (res .. '0000'):sub(1,4)
  end
end

local function include (self, word)
	local wordex = soundex (word)
	cache[wordex] = word
end

local function calculate (self, word)
	local wordex = soundex (word)
	return cache[wordex]
end

return {
	set = include,
	get = calculate
}
