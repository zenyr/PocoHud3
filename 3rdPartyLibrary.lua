-------- External functions: SimpleMenuV2, JSON, Inspect --
if not SimpleMenuV2 then
	SimpleMenuV2 = class() -- SimpleMenu By Harfartus

	function SimpleMenuV2:init(title, message, options)
			self.dialog_data = { title = title, text = message, button_list = {},
													 id = tostring(math.random(0,0xFFFFFFFF)) }
			self.visible = false
			for _,opt in ipairs(options) do
					local elem = {}
					elem.text = opt.text
					opt.data = opt.data or nil
					opt.callback = opt.callback or nil
					elem.callback_func = callback(self, self, "_do_callback",
																				{ data = opt.data,
																					callback = opt.callback,
																					Class = opt.Class or nil})
					elem.cancel_button = opt.is_cancel_button or false
					if opt.is_focused_button then
							self.dialog_data.focus_button = #self.dialog_data.button_list+1
					end
					table.insert(self.dialog_data.button_list, elem)
			end
			return self
	end

	function SimpleMenuV2:_do_callback(info)
			if info.callback then
					if info.data then
							if info.Class then
									info.callback(info.Class, info.data)
							else
									info.callback(info.data)
							end
					else
							if info.Class then
									info.callback(info.Class)
							else
									info.callback()
							end
					end
			end
			self.visible = false
	end

	function SimpleMenuV2:show()
			if self.visible then
					return
			end
			self.visible = true
			managers.system_menu:show(self.dialog_data)
	end

	function SimpleMenuV2:hide()
			if self.visible then
					managers.system_menu:close(self.dialog_data.id)
					self.visible = false
					return
			end
	end

	patched_update_input = patched_update_input or function (self, t, dt )
			if self._data.no_buttons then
					return
			end

			local dir, move_time
			local move = self._controller:get_input_axis( "menu_move" )

			if( self._controller:get_input_bool( "menu_down" )) then
					dir = 1
			elseif( self._controller:get_input_bool( "menu_up" )) then
					dir = -1
			end

			if dir == nil then
					if move.y > self.MOVE_AXIS_LIMIT then
							dir = 1
					elseif move.y < -self.MOVE_AXIS_LIMIT then
							dir = -1
					end
			end

			if dir ~= nil then
					if( ( self._move_button_dir == dir ) and self._move_button_time and ( t < self._move_button_time + self.MOVE_AXIS_DELAY ) ) then
							move_time = self._move_button_time or t
					else
							self._panel_script:change_focus_button( dir )
							move_time = t
					end
			end

			self._move_button_dir = dir
			self._move_button_time = move_time

			local scroll = self._controller:get_input_axis( "menu_scroll" )
			if( scroll.y > self.MOVE_AXIS_LIMIT ) then
					self._panel_script:scroll_up()
			elseif( scroll.y < -self.MOVE_AXIS_LIMIT ) then
					self._panel_script:scroll_down()
			end
	end
	if managers then
		managers.system_menu.DIALOG_CLASS.update_input = patched_update_input
		managers.system_menu.GENERIC_DIALOG_CLASS.update_input = patched_update_input
	end
end

if not JSONParser then
    local VERSION = 20140116.10  -- version history at end of file
    local OBJDEF = { VERSION = VERSION }
    local author = "-[ JSON.lua package by Jeffrey Friedl (http://regex.info/blog/lua/json), version " .. tostring(VERSION) .. " ]-"
    local isArray  = { __tostring = function() return "JSON array"  end }    isArray.__index  = isArray
    local isObject = { __tostring = function() return "JSON object" end }    isObject.__index = isObject


    function OBJDEF:newArray(tbl)
       return setmetatable(tbl or {}, isArray)
    end

    function OBJDEF:newObject(tbl)
       return setmetatable(tbl or {}, isObject)
    end

    local function unicode_codepoint_as_utf8(codepoint)
       --
       -- codepoint is a number
       --
       if codepoint <= 127 then
          return string.char(codepoint)

       elseif codepoint <= 2047 then
          --
          -- 110yyyxx 10xxxxxx         <-- useful notation from http://en.wikipedia.org/wiki/Utf8
          --
          local highpart = math.floor(codepoint / 0x40)
          local lowpart  = codepoint - (0x40 * highpart)
          return string.char(0xC0 + highpart,
                             0x80 + lowpart)

       elseif codepoint <= 65535 then
          --
          -- 1110yyyy 10yyyyxx 10xxxxxx
          --
          local highpart  = math.floor(codepoint / 0x1000)
          local remainder = codepoint - 0x1000 * highpart
          local midpart   = math.floor(remainder / 0x40)
          local lowpart   = remainder - 0x40 * midpart

          highpart = 0xE0 + highpart
          midpart  = 0x80 + midpart
          lowpart  = 0x80 + lowpart

          --
          -- Check for an invalid character (thanks Andy R. at Adobe).
          -- See table 3.7, page 93, in http://www.unicode.org/versions/Unicode5.2.0/ch03.pdf#G28070
          --
          if ( highpart == 0xE0 and midpart < 0xA0 ) or
             ( highpart == 0xED and midpart > 0x9F ) or
             ( highpart == 0xF0 and midpart < 0x90 ) or
             ( highpart == 0xF4 and midpart > 0x8F )
          then
             return "?"
          else
             return string.char(highpart,
                                midpart,
                                lowpart)
          end

       else
          --
          -- 11110zzz 10zzyyyy 10yyyyxx 10xxxxxx
          --
          local highpart  = math.floor(codepoint / 0x40000)
          local remainder = codepoint - 0x40000 * highpart
          local midA      = math.floor(remainder / 0x1000)
          remainder       = remainder - 0x1000 * midA
          local midB      = math.floor(remainder / 0x40)
          local lowpart   = remainder - 0x40 * midB

          return string.char(0xF0 + highpart,
                             0x80 + midA,
                             0x80 + midB,
                             0x80 + lowpart)
       end
    end

    function OBJDEF:onDecodeError(message, text, location, etc)
       if text then
          if location then
             message = string.format("%s at char %d of: %s", message, location, text)
          else
             message = string.format("%s: %s", message, text)
          end
       end

       if etc ~= nil then
          message = message .. " (" .. OBJDEF:encode(etc) .. ")"
       end

       if self.assert then
          self.assert(false, message)
       else
          assert(false, message)
       end
    end

    OBJDEF.onDecodeOfNilError  = OBJDEF.onDecodeError
    OBJDEF.onDecodeOfHTMLError = OBJDEF.onDecodeError

    function OBJDEF:onEncodeError(message, etc)
       if etc ~= nil then
          message = message .. " (" .. OBJDEF:encode(etc) .. ")"
       end

       if self.assert then
          self.assert(false, message)
       else
          assert(false, message)
       end
    end

    local function grok_number(self, text, start, etc)
       --
       -- Grab the integer part
       --
       local integer_part = text:match('^-?[1-9]%d*', start)
                         or text:match("^-?0",        start)

       if not integer_part then
          self:onDecodeError("expected number", text, start, etc)
       end

       local i = start + integer_part:len()

       --
       -- Grab an optional decimal part
       --
       local decimal_part = text:match('^%.%d+', i) or ""

       i = i + decimal_part:len()

       --
       -- Grab an optional exponential part
       --
       local exponent_part = text:match('^[eE][-+]?%d+', i) or ""

       i = i + exponent_part:len()

       local full_number_text = integer_part .. decimal_part .. exponent_part
       local as_number = tonumber(full_number_text)

       if not as_number then
          self:onDecodeError("bad number", text, start, etc)
       end

       return as_number, i
    end


    local function grok_string(self, text, start, etc)

       if text:sub(start,start) ~= '"' then
          self:onDecodeError("expected string's opening quote", text, start, etc)
       end

       local i = start + 1 -- +1 to bypass the initial quote
       local text_len = text:len()
       local VALUE = ""
       while i <= text_len do
          local c = text:sub(i,i)
          if c == '"' then
             return VALUE, i + 1
          end
          if c ~= '\\' then
             VALUE = VALUE .. c
             i = i + 1
          elseif text:match('^\\b', i) then
             VALUE = VALUE .. "\b"
             i = i + 2
          elseif text:match('^\\f', i) then
             VALUE = VALUE .. "\f"
             i = i + 2
          elseif text:match('^\\n', i) then
             VALUE = VALUE .. "\n"
             i = i + 2
          elseif text:match('^\\r', i) then
             VALUE = VALUE .. "\r"
             i = i + 2
          elseif text:match('^\\t', i) then
             VALUE = VALUE .. "\t"
             i = i + 2
          else
             local hex = text:match('^\\u([0123456789aAbBcCdDeEfF][0123456789aAbBcCdDeEfF][0123456789aAbBcCdDeEfF][0123456789aAbBcCdDeEfF])', i)
             if hex then
                i = i + 6 -- bypass what we just read

                -- We have a Unicode codepoint. It could be standalone, or if in the proper range and
                -- followed by another in a specific range, it'll be a two-code surrogate pair.
                local codepoint = tonumber(hex, 16)
                if codepoint >= 0xD800 and codepoint <= 0xDBFF then
                   -- it's a hi surrogate... see whether we have a following low
                   local lo_surrogate = text:match('^\\u([dD][cdefCDEF][0123456789aAbBcCdDeEfF][0123456789aAbBcCdDeEfF])', i)
                   if lo_surrogate then
                      i = i + 6 -- bypass the low surrogate we just read
                      codepoint = 0x2400 + (codepoint - 0xD800) * 0x400 + tonumber(lo_surrogate, 16)
                   else
                      -- not a proper low, so we'll just leave the first codepoint as is and spit it out.
                   end
                end
                VALUE = VALUE .. unicode_codepoint_as_utf8(codepoint)

             else

                -- just pass through what's escaped
                VALUE = VALUE .. text:match('^\\(.)', i)
                i = i + 2
             end
          end
       end

       self:onDecodeError("unclosed string", text, start, etc)
    end

    local function skip_whitespace(text, start)

       local match_start, match_end = text:find("^[ \n\r\t]+", start) -- [http://www.ietf.org/rfc/rfc4627.txt] Section 2
       if match_end then
          return match_end + 1
       else
          return start
       end
    end

    local grok_one -- assigned later

    local function grok_object(self, text, start, etc)
       if not text:sub(start,start) == '{' then
          self:onDecodeError("expected '{'", text, start, etc)
       end

       local i = skip_whitespace(text, start + 1) -- +1 to skip the '{'

       local VALUE = self.strictTypes and self:newObject { } or { }

       if text:sub(i,i) == '}' then
          return VALUE, i + 1
       end
       local text_len = text:len()
       while i <= text_len do
          local key, new_i = grok_string(self, text, i, etc)

          i = skip_whitespace(text, new_i)

          if text:sub(i, i) ~= ':' then
             self:onDecodeError("expected colon", text, i, etc)
          end

          i = skip_whitespace(text, i + 1)

          local val, new_i = grok_one(self, text, i)

          VALUE[key] = val

          --
          -- Expect now either '}' to end things, or a ',' to allow us to continue.
          --
          i = skip_whitespace(text, new_i)

          local c = text:sub(i,i)

          if c == '}' then
             return VALUE, i + 1
          end

          if text:sub(i, i) ~= ',' then
             self:onDecodeError("expected comma or '}'", text, i, etc)
          end

          i = skip_whitespace(text, i + 1)
       end

       self:onDecodeError("unclosed '{'", text, start, etc)
    end

    local function grok_array(self, text, start, etc)
       if not text:sub(start,start) == '[' then
          self:onDecodeError("expected '['", text, start, etc)
       end

       local i = skip_whitespace(text, start + 1) -- +1 to skip the '['
       local VALUE = self.strictTypes and self:newArray { } or { }
       if text:sub(i,i) == ']' then
          return VALUE, i + 1
       end

       local text_len = text:len()
       while i <= text_len do
          local val, new_i = grok_one(self, text, i)

          table.insert(VALUE, val)

          i = skip_whitespace(text, new_i)

          --
          -- Expect now either ']' to end things, or a ',' to allow us to continue.
          --
          local c = text:sub(i,i)
          if c == ']' then
             return VALUE, i + 1
          end
          if text:sub(i, i) ~= ',' then
             self:onDecodeError("expected comma or '['", text, i, etc)
          end
          i = skip_whitespace(text, i + 1)
       end
       self:onDecodeError("unclosed '['", text, start, etc)
    end


    grok_one = function(self, text, start, etc)
       -- Skip any whitespace
       start = skip_whitespace(text, start)

       if start > text:len() then
          self:onDecodeError("unexpected end of string", text, nil, etc)
       end

       if text:find('^"', start) then
          return grok_string(self, text, start, etc)

       elseif text:find('^[-0123456789 ]', start) then
          return grok_number(self, text, start, etc)

       elseif text:find('^%{', start) then
          return grok_object(self, text, start, etc)

       elseif text:find('^%[', start) then
          return grok_array(self, text, start, etc)

       elseif text:find('^true', start) then
          return true, start + 4

       elseif text:find('^false', start) then
          return false, start + 5

       elseif text:find('^null', start) then
          return nil, start + 4

       else
          self:onDecodeError("can't parse JSON", text, start, etc)
       end
    end

    function OBJDEF:decode(text, etc)
       if type(self) ~= 'table' or self.__index ~= OBJDEF then
          OBJDEF:onDecodeError("JSON:decode must be called in method format", nil, nil, etc)
       end

       if text == nil then
          self:onDecodeOfNilError(string.format("nil passed to JSON:decode()"), nil, nil, etc)
       elseif type(text) ~= 'string' then
          self:onDecodeError(string.format("expected string argument to JSON:decode(), got %s", type(text)), nil, nil, etc)
       end

       if text:match('^%s*$') then
          return nil
       end

       if text:match('^%s*<') then
          -- Can't be JSON... we'll assume it's HTML
          self:onDecodeOfHTMLError(string.format("html passed to JSON:decode()"), text, nil, etc)
       end

       --
       -- Ensure that it's not UTF-32 or UTF-16.
       -- Those are perfectly valid encodings for JSON (as per RFC 4627 section 3),
       -- but this package can't handle them.
       --
       if text:sub(1,1):byte() == 0 or (text:len() >= 2 and text:sub(2,2):byte() == 0) then
          self:onDecodeError("JSON package groks only UTF-8, sorry", text, nil, etc)
       end

       return grok_one(self, text, 1, etc)
    end

    local function backslash_replacement_function(c)
       if c == "\n" then
          return "\\n"
       elseif c == "\r" then
          return "\\r"
       elseif c == "\t" then
          return "\\t"
       elseif c == "\b" then
          return "\\b"
       elseif c == "\f" then
          return "\\f"
       elseif c == '"' then
          return '\\"'
       elseif c == '\\' then
          return '\\\\'
       else
          return string.format("\\u%04x", c:byte())
       end
    end

    local chars_to_be_escaped_in_JSON_string
       = '['
       ..    '"'    -- class sub-pattern to match a double quote
       ..    '%\\'  -- class sub-pattern to match a backslash
       ..    '%z'   -- class sub-pattern to match a null
       ..    '\001' .. '-' .. '\031' -- class sub-pattern to match control characters
       .. ']'

    local function json_string_literal(value)
       local newval = value:gsub(chars_to_be_escaped_in_JSON_string, backslash_replacement_function)
       return '"' .. newval .. '"'
    end

    local function object_or_array(self, T, etc)
       --
       -- We need to inspect all the keys... if there are any strings, we'll convert to a JSON
       -- object. If there are only numbers, it's a JSON array.
       --
       -- If we'll be converting to a JSON object, we'll want to sort the keys so that the
       -- end result is deterministic.
       --
       local string_keys = { }
       local number_keys = { }
       local number_keys_must_be_strings = false
       local maximum_number_key

       for key in pairs(T) do
          if type(key) == 'string' then
             table.insert(string_keys, key)
          elseif type(key) == 'number' then
             table.insert(number_keys, key)
             if key <= 0 or key >= math.huge then
                number_keys_must_be_strings = true
             elseif not maximum_number_key or key > maximum_number_key then
                maximum_number_key = key
             end
          else
             self:onEncodeError("can't encode table with a key of type " .. type(key), etc)
          end
       end

       if #string_keys == 0 and not number_keys_must_be_strings then
          --
          -- An empty table, or a numeric-only array
          --
          if #number_keys > 0 then
             return nil, maximum_number_key -- an array
          elseif tostring(T) == "JSON array" then
             return nil
          elseif tostring(T) == "JSON object" then
             return { }
          else
             -- have to guess, so we'll pick array, since empty arrays are likely more common than empty objects
             return nil
          end
       end

       table.sort(string_keys)

       local map
       if #number_keys > 0 then
          --
          -- If we're here then we have either mixed string/number keys, or numbers inappropriate for a JSON array
          -- It's not ideal, but we'll turn the numbers into strings so that we can at least create a JSON object.
          --

          if JSON.noKeyConversion then
             self:onEncodeError("a table with both numeric and string keys could be an object or array; aborting", etc)
          end

          --
          -- Have to make a shallow copy of the source table so we can remap the numeric keys to be strings
          --
          map = { }
          for key, val in pairs(T) do
             map[key] = val
          end

          table.sort(number_keys)

          --
          -- Throw numeric keys in there as strings
          --
          for _, number_key in ipairs(number_keys) do
             local string_key = tostring(number_key)
             if map[string_key] == nil then
                table.insert(string_keys , string_key)
                map[string_key] = T[number_key]
             else
                self:onEncodeError("conflict converting table with mixed-type keys into a JSON object: key " .. number_key .. " exists both as a string and a number.", etc)
             end
          end
       end

       return string_keys, nil, map
    end

    --
    -- Encode
    --
    local encode_value -- must predeclare because it calls itself
    function encode_value(self, value, parents, etc, indent) -- non-nil indent means pretty-printing

       if value == nil then
          return 'null'

       elseif type(value) == 'string' then
          return json_string_literal(value)

       elseif type(value) == 'number' then
          if value ~= value then
             --
             -- NaN (Not a Number).
             -- JSON has no NaN, so we have to fudge the best we can. This should really be a package option.
             --
             return "null"
          elseif value >= math.huge then
             --
             -- Positive infinity. JSON has no INF, so we have to fudge the best we can. This should
             -- really be a package option. Note: at least with some implementations, positive infinity
             -- is both ">= math.huge" and "<= -math.huge", which makes no sense but that's how it is.
             -- Negative infinity is properly "<= -math.huge". So, we must be sure to check the ">="
             -- case first.
             --
             return "1e+9999"
          elseif value <= -math.huge then
             --
             -- Negative infinity.
             -- JSON has no INF, so we have to fudge the best we can. This should really be a package option.
             --
             return "-1e+9999"
          else
             return tostring(value)
          end

       elseif type(value) == 'boolean' then
          return tostring(value)

       elseif type(value) == 'userdata' then
          return json_string_literal(tostring(value))

       elseif type(value) ~= 'table' then
          self:onEncodeError("can't convert " .. type(value) .. " to JSON", etc)

       else
          --
          -- A table to be converted to either a JSON object or array.
          --
          local T = value

          if parents[T] then
             self:onEncodeError("table " .. tostring(T) .. " is a child of itself", etc)
          else
             parents[T] = true
          end

          local result_value

          local object_keys, maximum_number_key, map = object_or_array(self, T, etc)
          if maximum_number_key then
             --
             -- An array...
             --
             local ITEMS = { }
             for i = 1, maximum_number_key do
                table.insert(ITEMS, encode_value(self, T[i], parents, etc, indent))
             end

             if indent then
                result_value = "[ " .. table.concat(ITEMS, ", ") .. " ]"
             else
                result_value = "[" .. table.concat(ITEMS, ",") .. "]"
             end

          elseif object_keys then
             --
             -- An object
             --
             local TT = map or T

             if indent then

                local KEYS = { }
                local max_key_length = 0
                for _, key in ipairs(object_keys) do
                   local encoded = encode_value(self, tostring(key), parents, etc, "")
                   max_key_length = math.max(max_key_length, #encoded)
                   table.insert(KEYS, encoded)
                end
                local key_indent = indent .. "    "
                local subtable_indent = indent .. string.rep(" ", max_key_length + 2 + 4)
                local FORMAT = "%s%" .. string.format("%d", max_key_length) .. "s: %s"

                local COMBINED_PARTS = { }
                for i, key in ipairs(object_keys) do
                   local encoded_val = encode_value(self, TT[key], parents, etc, subtable_indent)
                   table.insert(COMBINED_PARTS, string.format(FORMAT, key_indent, KEYS[i], encoded_val))
                end
                result_value = "{\n" .. table.concat(COMBINED_PARTS, ",\n") .. "\n" .. indent .. "}"

             else

                local PARTS = { }
                for _, key in ipairs(object_keys) do
                   local encoded_val = encode_value(self, TT[key],       parents, etc, indent)
                   local encoded_key = encode_value(self, tostring(key), parents, etc, indent)
                   table.insert(PARTS, string.format("%s:%s", encoded_key, encoded_val))
                end
                result_value = "{" .. table.concat(PARTS, ",") .. "}"

             end
          else
             --
             -- An empty array/object... we'll treat it as an array, though it should really be an option
             --
             result_value = "[]"
          end

          parents[T] = false
          return result_value
       end
    end


    function OBJDEF:encode(value, etc)
       if type(self) ~= 'table' or self.__index ~= OBJDEF then
          OBJDEF:onEncodeError("JSON:encode must be called in method format", etc)
       end
       return encode_value(self, value, {}, etc, nil)
    end

    function OBJDEF:encode_pretty(value, etc)
       if type(self) ~= 'table' or self.__index ~= OBJDEF then
          OBJDEF:onEncodeError("JSON:encode_pretty must be called in method format", etc)
       end
       return encode_value(self, value, {}, etc, "")
    end

    function OBJDEF.__tostring()
       return "JSON encode/decode package"
    end

    OBJDEF.__index = OBJDEF

    function OBJDEF:new(args)
       local new = { }

       if args then
          for key, val in pairs(args) do
             new[key] = val
          end
       end

       return setmetatable(new, OBJDEF)
    end

    JSON = OBJDEF:new()
end

local inspect ={
  _VERSION = 'inspect.lua 2.0.0',
  _URL     = 'http://github.com/kikito/inspect.lua',
  _DESCRIPTION = 'human-readable representations of tables',
  _LICENSE = [[
    MIT LICENSE

    Copyright (c) 2013 Enrique García Cota

    Permission is hereby granted, free of charge, to any person obtaining a
    copy of this software and associated documentation files (the
    "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish,
    distribute, sublicense, and/or sell copies of the Software, and to
    permit persons to whom the Software is furnished to do so, subject to
    the following conditions:

    The above copyright notice and this permission notice shall be included
    in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
    OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
    CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
  ]]
}

-- Apostrophizes the string if it has quotes, but not aphostrophes
-- Otherwise, it returns a regular quoted string
local function smartQuote(str)
  if str:match('"') and not str:match("'") then
    return "'" .. str .. "'"
  end
  return '"' .. str:gsub('"', '\\"') .. '"'
end

local controlCharsTranslation = {
  ["\a"] = "\\a",  ["\b"] = "\\b", ["\f"] = "\\f",  ["\n"] = "\\n",
  ["\r"] = "\\r",  ["\t"] = "\\t", ["\v"] = "\\v"
}

local function escapeChar(c) return controlCharsTranslation[c] end

local function escape(str)
  local result = str:gsub("\\", "\\\\"):gsub("(%c)", escapeChar)
  return result
end

local function isIdentifier(str)
  return type(str) == 'string' and str:match( "^[_%a][_%a%d]*$" )
end

local function isArrayKey(k, length)
  return type(k) == 'number' and 1 <= k and k <= length
end

local function isDictionaryKey(k, length)
  return not isArrayKey(k, length)
end

local defaultTypeOrders = {
  ['number']   = 1, ['boolean']  = 2, ['string'] = 3, ['table'] = 4,
  ['function'] = 5, ['userdata'] = 6, ['thread'] = 7
}

local function sortKeys(a, b)
  local ta, tb = type(a), type(b)

  -- strings and numbers are sorted numerically/alphabetically
  if ta == tb and (ta == 'string' or ta == 'number') then return a < b end

  local dta, dtb = defaultTypeOrders[ta], defaultTypeOrders[tb]
  -- Two default types are compared according to the defaultTypeOrders table
  if dta and dtb then return defaultTypeOrders[ta] < defaultTypeOrders[tb]
  elseif dta     then return true  -- default types before custom ones
  elseif dtb     then return false -- custom types after default ones
  end

  -- custom types are sorted out alphabetically
  return ta < tb
end

local function getDictionaryKeys(t)
  local keys, length = {}, #t
  for k,_ in pairs(t) do
    if isDictionaryKey(k, length) then table.insert(keys, k) end
  end
  table.sort(keys, sortKeys)
  return keys
end

local function getToStringResultSafely(t, mt)
  local __tostring = type(mt) == 'table' and rawget(mt, '__tostring')
  local str, ok
  if type(__tostring) == 'function' then
    ok, str = pcall(__tostring, t)
    str = ok and str or 'error: ' .. tostring(str)
  end
  if type(str) == 'string' and #str > 0 then return str end
end

local maxIdsMetaTable = {
  __index = function(self, typeName)
    rawset(self, typeName, 0)
    return 0
  end
}

local idsMetaTable = {
  __index = function (self, typeName)
    local col = setmetatable({}, {__mode = "kv"})
    rawset(self, typeName, col)
    return col
  end
}

local function countTableAppearances(t, tableAppearances)
  tableAppearances = tableAppearances or setmetatable({}, {__mode = "k"})

  if type(t) == 'table' then
    if not tableAppearances[t] then
      tableAppearances[t] = 1
      for k,v in pairs(t) do
        countTableAppearances(k, tableAppearances)
        countTableAppearances(v, tableAppearances)
      end
      countTableAppearances(getmetatable(t), tableAppearances)
    else
      tableAppearances[t] = tableAppearances[t] + 1
    end
  end

  return tableAppearances
end

local function parse_filter(filter)
  if type(filter) == 'function' then return filter end
  -- not a function, so it must be a table or table-like
  filter = type(filter) == 'table' and filter or {filter}
  local dictionary = {}
  for _,v in pairs(filter) do dictionary[v] = true end
  return function(x) return dictionary[x] end
end

local function makePath(path, key)
  local newPath, len = {}, #path
  for i=1, len do newPath[i] = path[i] end
  newPath[len+1] = key
  return newPath
end

-------------------------------------------------------------------
function inspect.inspect(rootObject, options)
  options       = options or {}
  local depth   = options.depth or 1 or math.huge
  local filter  = parse_filter(options.filter or {})
	local _mt		= options.mt

  local tableAppearances = countTableAppearances(rootObject)

  local buffer = {}
  local maxIds = setmetatable({}, maxIdsMetaTable)
  local ids    = setmetatable({}, idsMetaTable)
  local level  = 0
  local blen   = 0 -- buffer length

  local function puts(...)
    local args = {...}
    for i=1, #args do
      blen = blen + 1
      buffer[blen] = tostring(args[i])
    end
  end

  local function down(f)
    level = level + 1
    f()
    level = level - 1
  end

  local function tabify()
    puts("\n", string.rep("  ", level))
  end

  local function commaControl(needsComma)
    if needsComma then puts(',') end
    return true
  end

  local function alreadyVisited(v)
    return ids[type(v)][v] ~= nil
  end

  local function getId(v)
    local tv = type(v)
    local id = ids[tv][v]
    if not id then
      id         = maxIds[tv] + 1
      maxIds[tv] = id
      ids[tv][v] = id
    end
    return id
  end

  local putValue -- forward declaration that needs to go before putTable & putKey

  local function putKey(k)
    if isIdentifier(k) then return puts(k) end
    puts( "[" )
    putValue(k, {})
    puts("]")
  end

  local function putTable(t, path)
    if alreadyVisited(t) then
      puts('<table ', getId(t), '>')
    elseif level >= depth then
      puts('{...}')
    else
      if tableAppearances[t] > 1 then puts('<', getId(t), '>') end

      local dictKeys          = getDictionaryKeys(t)
      local length            = #t
      local mt                = getmetatable(t)
      local to_string_result  = getToStringResultSafely(t, mt)

      puts('{')
      down(function()
        if to_string_result then
          puts(' -- ', escape(to_string_result))
          if length >= 1 then tabify() end -- tabify the array values
        end

        local needsComma = false
        for i=1, length do
          needsComma = commaControl(needsComma)
          puts(' ')
          putValue(t[i], makePath(path, i))
        end

        for _,k in ipairs(dictKeys) do
          needsComma = commaControl(needsComma)
          tabify()
          putKey(k)
          puts(' = ')
          putValue(t[k], makePath(path, k))
        end

        if mt then
          needsComma = commaControl(needsComma)
          tabify()
					if _mt then
						puts('<metatable> = ')
						putValue(mt, makePath(path, '<metatable>'))
					else
						puts('<metatable>')
					end
        end
      end)

      if #dictKeys > 0 or mt then -- dictionary table. Justify closing }
        tabify()
      elseif length > 0 then -- array tables have one extra space before closing }
        puts(' ')
      end

      puts('}')
    end

  end

  -- putvalue is forward-declared before putTable & putKey
  putValue = function(v, path)
    if filter(v, path) then
      puts('<filtered>')
    else
      local tv = type(v)

      if tv == 'string' then
        puts(smartQuote(escape(v)))
      elseif tv == 'number' or tv == 'boolean' or tv == 'nil' then
        puts(tostring(v))
      elseif tv == 'table' then
        putTable(v, path)
      else
        puts('<',tv,' ',getId(v),'>')
      end
    end
  end

  putValue(rootObject, {})

  return table.concat(buffer)
end

setmetatable(inspect, { __call = function(_, ...) return inspect.inspect(...) end })

_G.zinspect = inspect

-----------
local utf8unicode
local shift_6  = 2^6
local shift_12 = 2^12
local shift_18 = 2^18
utf8unicode = function(str, i, j, byte_pos)
	i = i or 1
	j = j or i

	if i > j then return end

	local char,bytes

	if byte_pos then
		bytes = utf8charbytes(str,byte_pos)
		char  = str:sub(byte_pos,byte_pos-1+bytes)
	else
		char,byte_pos = str:usub(i,i)
		bytes         = #char
	end

	local unicode

	if bytes == 1 then unicode = string.byte(char) end
	if bytes == 2 then
		local byte0,byte1 = string.byte(char,1,2)
		local code0,code1 = byte0-0xC0,byte1-0x80
		unicode = code0*shift_6 + code1
	end
	if bytes == 3 then
		local byte0,byte1,byte2 = string.byte(char,1,3)
		local code0,code1,code2 = byte0-0xE0,byte1-0x80,byte2-0x80
		unicode = code0*shift_12 + code1*shift_6 + code2
	end
	if bytes == 4 then
		local byte0,byte1,byte2,byte3 = string.byte(char,1,4)
		local code0,code1,code2,code3 = byte0-0xF0,byte1-0x80,byte2-0x80,byte3-0x80
		unicode = code0*shift_18 + code1*shift_12 + code2*shift_6 + code3
	end

	return unicode,utf8unicode(str, i+1, j, byte_pos+bytes)
end
utf8.unicode = utf8unicode