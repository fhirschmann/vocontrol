-----------------------------------------------------------------------------
-- JSON4Lua: JSON encoding / decoding support for the Lua language.
-- json Module.
-- Author: Craig Mason-Jones
-- Homepage: http://json.luaforge.net/
-- Version: 0.9
-- This module is released under the The GNU General Public License (GPL).
-- Please see LICENCE.txt for details.
--
-- USAGE:
-- This module exposes two functions:
--   encode(o)
--     Returns the table / string / boolean / number / nil value as a JSON-encoded string.
--   decode(json_string)
--     Returns a Lua object populated with the data encoded in the JSON string json_string.
--
-- REQUIREMENTS:
--   compat-5.1 if using Lua 5.0
-----------------------------------------------------------------------------

-- Edited by Scuba Steve 9.0 to make this play nice with VO plugins
-- isArray backported from upstream by Fabian Hirschmann

-----------------------------------------------------------------------------
-- Module declaration
-----------------------------------------------------------------------------
local json = {}
-----------------------------------------------------------------------------
-- Internal, PRIVATE functions.
-- Following a Python-like convention, I have prefixed all these 'PRIVATE'
-- functions with an underscore.
-----------------------------------------------------------------------------
--- Scans a JSON string skipping all whitespace from the current start position.
-- Returns the position of the first non-whitespace character, or nil if the whole end of string is reached.
-- @param s The string being scanned
-- @param startPos The starting position where we should begin removing whitespace.
-- @return int The first position where non-whitespace was encountered, or string.len(s)+1 if the end of string
-- was reached.
local function _decode_scanWhitespace(s,startPos)
  local whitespace=" \n\r\t"
  local stringLen = string.len(s)
  while ( string.find(whitespace, string.sub(s,startPos,startPos), 1, true)  and startPos <= stringLen) do
    startPos = startPos + 1
  end
  return startPos
end

--- Scans an array from JSON into a Lua object
-- startPos begins at the start of the array.
-- Returns the array and the next starting position
-- @param s The string being scanned.
-- @param startPos The starting position for the scan.
-- @return table, int The scanned array as a table, and the position of the next character to scan.
local function _decode_scanArray(s,startPos)
  local array = {}      -- The return value
  local stringLen = string.len(s)
  local object
  assert(string.sub(s,startPos,startPos)=='[','_decode_scanArray called but array does not start at position ' .. startPos .. ' in string:\n'..s )
  startPos = startPos + 1
  -- Infinite loop for array elements
  repeat
    startPos = _decode_scanWhitespace(s,startPos)
    assert(startPos<=stringLen,'JSON String ended unexpectedly scanning array.')
    local curChar = string.sub(s,startPos,startPos)
    if (curChar==']') then
      return array, startPos+1
    end
    if (curChar==',') then
      startPos = _decode_scanWhitespace(s,startPos+1)
    end
    assert(startPos<=stringLen, 'JSON String ended unexpectedly scanning array.')
    object, startPos = json.decode(s,startPos)
    table.insert(array,object)
  until false
end

--- Scans for given constants: true, false or null
-- Returns the appropriate Lua type, and the position of the next character to read.
-- @param s The string being scanned.
-- @param startPos The position in the string at which to start scanning.
-- @return object, int The object (true, false or nil) and the position at which the next character should be 
-- scanned.
local function _decode_scanConstant(s, startPos)
  local consts = { ["true"] = true, ["false"] = false, ["null"] = nil }
  local constNames = {"true","false","null"}
  for i,k in pairs(constNames) do
    --print ("[" .. string.sub(s,startPos, startPos + string.len(k) -1) .."]", k)
    if string.sub(s,startPos, startPos + string.len(k) -1 )==k then
      return consts[k], startPos + string.len(k)
    end
  end
  assert(nil, 'Failed to scan constant from string ' .. s .. ' at starting position ' .. startPos)
end

--- Scans a number from the JSON encoded string.
-- (in fact, also is able to scan numeric +- eqns, which is not
-- in the JSON spec.)
-- Returns the number, and the position of the next character
-- after the number.
-- @param s The string being scanned.
-- @param startPos The position at which to start scanning.
-- @return number, int The extracted number and the position of the next character to scan.
local function _decode_scanNumber(s,startPos)
  local endPos = startPos+1
  local stringLen = string.len(s)
  local acceptableChars = "+-0123456789.e"
  while (string.find(acceptableChars, string.sub(s,endPos,endPos), 1, true)
        and endPos<=stringLen
        ) do
    endPos = endPos + 1
  end
  local stringValue = 'return ' .. string.sub(s,startPos, endPos-1)
  local stringEval = loadstring(stringValue)
  assert(stringEval, 'Failed to scan number [ ' .. stringValue .. '] in JSON string at position ' .. startPos .. ' : ' .. endPos)
  return stringEval(), endPos
end

--- Scans a JSON object into a Lua object.
-- startPos begins at the start of the object.
-- Returns the object and the next starting position.
-- @param s The string being scanned.
-- @param startPos The starting position of the scan.
-- @return table, int The scanned object as a table and the position of the next character to scan.
local function _decode_scanObject(s,startPos)
  local object = {}
  local stringLen = string.len(s)
  local key, value
  assert(string.sub(s,startPos,startPos)=='{','decode_scanObject called but object does not start at position ' .. startPos .. ' in string:\n' .. s)
  startPos = startPos + 1
  repeat
    startPos = _decode_scanWhitespace(s,startPos)
    assert(startPos<=stringLen, 'JSON string ended unexpectedly while scanning object.')
    local curChar = string.sub(s,startPos,startPos)
    if (curChar=='}') then
      return object,startPos+1
    end
    if (curChar==',') then
      startPos = _decode_scanWhitespace(s,startPos+1)
    end
    assert(startPos<=stringLen, 'JSON string ended unexpectedly scanning object.')
    -- Scan the key
    key, startPos = json.decode(s,startPos)
    assert(startPos<=stringLen, 'JSON string ended unexpectedly searching for value of key ' .. key)
    startPos = _decode_scanWhitespace(s,startPos)
    assert(startPos<=stringLen, 'JSON string ended unexpectedly searching for value of key ' .. key)
    assert(string.sub(s,startPos,startPos)==':','JSON object key-value assignment mal-formed at ' .. startPos)
    startPos = _decode_scanWhitespace(s,startPos+1)
    assert(startPos<=stringLen, 'JSON string ended unexpectedly searching for value of key ' .. key)
    value, startPos = json.decode(s,startPos)
    object[key]=value
  until false   -- infinite loop while key-value pairs are found
end

--- Scans a JSON string from the opening inverted comma or single quote to the
-- end of the string.
-- Returns the string extracted as a Lua string,
-- and the position of the next non-string character
-- (after the closing inverted comma or single quote).
-- @param s The string being scanned.
-- @param startPos The starting position of the scan.
-- @return string, int The extracted string as a Lua string, and the next character to parse.
local function _decode_scanString(s,startPos)
  assert(startPos, '_decode_scanString(..) called without start position')
  local startChar = string.sub(s,startPos,startPos)
  assert(startChar==[[']] or startChar==[["]],'decode_scanString called for a non-string')
  local escaped = false
  local endPos = startPos + 1
  local bEnded = false
  local stringLen = string.len(s)
  repeat
    local curChar = string.sub(s,endPos,endPos)
    if not escaped then 
      if curChar==[[\]] then
        escaped = true
      else
        bEnded = curChar==startChar
      end
    else
      -- If we're escaped, we accept the current character come what may
      escaped = false
    end
    endPos = endPos + 1
    assert(endPos <= stringLen+1, "String decoding failed: unterminated string at position " .. endPos)
  until bEnded
  local stringValue = 'return ' .. string.sub(s, startPos, endPos-1)
  local stringEval = loadstring(stringValue)
  assert(stringEval, 'Failed to load string [ ' .. stringValue .. '] in JSON4Lua.decode_scanString at position ' .. startPos .. ' : ' .. endPos)
  return stringEval(), endPos  
end
--- Encodes a string to be JSON-compatible.
-- This just involves back-quoting inverted commas, back-quotes and newlines, I think ;-)
-- @param s The string to return as a JSON encoded (i.e. backquoted string)
-- @return The string appropriately escaped.
local function _encodeString(s)
  s = string.gsub(s,'\\','\\\\')
  s = string.gsub(s,'"','\\"')
  s = string.gsub(s,"'","\\'")
  s = string.gsub(s,'\n','\\n')
  s = string.gsub(s,'\t','\\t')
  return s
end

--- Determines whether the given Lua object / table / variable can be JSON encoded. The only
-- types that are JSON encodable are: string, boolean, number, nil and table.
-- In this implementation, all other types are ignored.
-- @param o The object to examine.
-- @return boolean True if the object should be JSON encoded, false if it should be ignored.
local function _isEncodable(o)
  return type(o)=='string' or type(o)=='boolean' or type(o)=='number' or type(o)=='nil' or type(o)=='table'
end

function _isArray(t)
  -- Next we count all the elements, ensuring that any non-indexed elements are not-encodable 
  -- (with the possible exception of 'n')
  local maxIndex = 0
  for k,v in pairs(t) do
    if (type(k)=='number' and math.floor(k)==k and 1<=k) then	-- k,v is an indexed pair
      if (not _isEncodable(v)) then return false end	-- All array elements must be encodable
      maxIndex = math.max(maxIndex,k)
    else
      if (k=='n') then
        if v ~= table.getn(t) then return false end  -- False if n does not hold the number of elements
      else -- Else of (k=='n')
        if _isEncodable(v) then return false end
      end  -- End of (k~='n')
    end -- End of k,v not an indexed pair
  end  -- End of loop across all pairs
  return true, maxIndex
end

-----------------------------------------------------------------------------
-- PUBLIC functions
-----------------------------------------------------------------------------
--- Encodes an arbitrary Lua object / variable.
-- @param v The Lua object / variable to be JSON encoded.
-- @return String containing the JSON encoding in internal Lua string format (i.e. not unicode)
local function encode (v)
  -- Handle nil values
  if v==nil then
    return "null"
  end
  
  -- Handle strings
  if type(v)=='string' then    
    return '"' .. _encodeString(v) .. '"'           -- Need to handle encoding in string
  end
  
  -- Handle booleans
  if type(v)=='number' or type(v)=='boolean' then
    return tostring(v)
  end
  
  -- Handle tables
  if type(v)=='table' then
    local rval = {}
    -- Consider arrays separately
    local bArray, _ = _isArray(v)
    for i,j in pairs(v) do
      if (not (bArray)) or (i~='n') then
        if _isEncodable(i) and _isEncodable(j) then
		  if(table.getn(rval) > 0) then
			table.insert(rval, ',')
		  end
          if bArray then
            if (i~='n') then
			  table.insert(rval, json.encode(j))
            end
          else
            table.insert(rval, '"')
			table.insert(rval, _encodeString(i))
			table.insert(rval, '":')
			table.insert(rval, json.encode(j))
          end
        end
      end
    end
    if bArray then
	  table.insert(rval, ']')
      return '[' .. table.concat(rval)
    else
	  table.insert(rval, '}')
      return '{' .. table.concat(rval)
    end
  end
  assert(false,'encode attempt to encode unsupported type ' .. type(v) .. ':' .. tostring(v))
end


--- Decodes a JSON string and returns the decoded value as a Lua data structure / value.
-- @param s The string to scan.
-- @param [startPos] Optional starting position where the JSON string is located. Defaults to 1.
-- @param Lua object, number The object that was scanned, as a Lua table / string / number / boolean or nil,
-- and the position of the first character after
-- the scanned JSON object.
local function decode(s, startPos)
  startPos = startPos or 1
  startPos = _decode_scanWhitespace(s,startPos)
  assert(startPos<=string.len(s), 'Unterminated JSON encoded object found at position in [' .. s .. ']')
  local curChar = string.sub(s,startPos,startPos)
  -- Object
  if curChar=='{' then
    return _decode_scanObject(s,startPos)
  end
  -- Array
  if curChar=='[' then
    return _decode_scanArray(s,startPos)
  end
  -- Number
  if string.find("+-0123456789.e", curChar, 1, true) then
    return _decode_scanNumber(s,startPos)
  end
  -- String
  if curChar==[["]] or curChar==[[']] then
    return _decode_scanString(s,startPos)
  end
  -- Otherwise, it must be a constant
  return _decode_scanConstant(s,startPos)
end

--This exports the functions.
json.encode = encode
json.decode = decode

return json
