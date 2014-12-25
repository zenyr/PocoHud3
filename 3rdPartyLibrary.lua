-------- External functions: SimpleMenuV2, JSON, Inspect, table.deepcopy --
Poco = Poco or {}
local r,err = pcall(function()
do -- SimpleMenu By Harfatus
	local SimpleMenuV2 = class()
	Poco.SimpleMenuV2 = SimpleMenuV2

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

	Poco.patched_update_input = Poco.patched_update_input or function (self, t, dt )
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
		managers.system_menu.DIALOG_CLASS.update_input = Poco.patched_update_input
		managers.system_menu.GENERIC_DIALOG_CLASS.update_input = Poco.patched_update_input
	end
end

do -- JSON
	--=============== JSON
	-- -*- coding: utf-8 -*-
	--
	-- Simple JSON encoding and decoding in pure Lua.
	--
	-- Copyright 2010-2014 Jeffrey Friedl
	-- http://regex.info/blog/
	--
	-- Latest version: http://regex.info/blog/lua/json
	--
	-- This code is released under a Creative Commons CC-BY "Attribution" License:
	-- http://creativecommons.org/licenses/by/3.0/deed.en_US
	--
	-- It can be used for any purpose so long as the copyright notice and
	-- web-page links above are maintained. Enjoy.
	--
	local VERSION = 20140911.12  -- version history at end of file
	local OBJDEF = { VERSION = VERSION }


	--
	-- Simple JSON encoding and decoding in pure Lua.
	-- http://www.json.org/
	--
	--
	--   JSON = (loadfile "JSON.lua")() -- one-time load of the routines
	--
	--   local lua_value = JSON:decode(raw_json_text)
	--
	--   local raw_json_text    = JSON:encode(lua_table_or_value)
	--   local pretty_json_text = JSON:encode_pretty(lua_table_or_value) -- "pretty printed" version for human readability
	--
	--
	-- DECODING
	--
	--   JSON = (loadfile "JSON.lua")() -- one-time load of the routines
	--
	--   local lua_value = JSON:decode(raw_json_text)
	--
	--   If the JSON text is for an object or an array, e.g.
	--     { "what": "books", "count": 3 }
	--   or
	--     [ "Larry", "Curly", "Moe" ]
	--
	--   the result is a Lua table, e.g.
	--     { what = "books", count = 3 }
	--   or
	--     { "Larry", "Curly", "Moe" }
	--
	--
	--   The encode and decode routines accept an optional second argument, "etc", which is not used
	--   during encoding or decoding, but upon error is passed along to error handlers. It can be of any
	--   type (including nil).
	--
	--   With most errors during decoding, this code calls
	--
	--      JSON:onDecodeError(message, text, location, etc)
	--
	--   with a message about the error, and if known, the JSON text being parsed and the byte count
	--   where the problem was discovered. You can replace the default JSON:onDecodeError() with your
	--   own function.
	--
	--   The default onDecodeError() merely augments the message with data about the text and the
	--   location if known (and if a second 'etc' argument had been provided to decode(), its value is
	--   tacked onto the message as well), and then calls JSON.assert(), which itself defaults to Lua's
	--   built-in assert(), and can also be overridden.
	--
	--   For example, in an Adobe Lightroom plugin, you might use something like
	--
	--          function JSON:onDecodeError(message, text, location, etc)
	--             LrErrors.throwUserError("Internal Error: invalid JSON data")
	--          end
	--
	--   or even just
	--
	--          function JSON.assert(message)
	--             LrErrors.throwUserError("Internal Error: " .. message)
	--          end
	--
	--   If JSON:decode() is passed a nil, this is called instead:
	--
	--      JSON:onDecodeOfNilError(message, nil, nil, etc)
	--
	--   and if JSON:decode() is passed HTML instead of JSON, this is called:
	--
	--      JSON:onDecodeOfHTMLError(message, text, nil, etc)
	--
	--   The use of the fourth 'etc' argument allows stronger coordination between decoding and error
	--   reporting, especially when you provide your own error-handling routines. Continuing with the
	--   the Adobe Lightroom plugin example:
	--
	--          function JSON:onDecodeError(message, text, location, etc)
	--             local note = "Internal Error: invalid JSON data"
	--             if type(etc) = 'table' and etc.photo then
	--                note = note .. " while processing for " .. etc.photo:getFormattedMetadata('fileName')
	--             end
	--             LrErrors.throwUserError(note)
	--          end
	--
	--            :
	--            :
	--
	--          for i, photo in ipairs(photosToProcess) do
	--               :
	--               :
	--               local data = JSON:decode(someJsonText, { photo = photo })
	--               :
	--               :
	--          end
	--
	--
	--
	--

	-- DECODING AND STRICT TYPES
	--
	--   Because both JSON objects and JSON arrays are converted to Lua tables, it's not normally
	--   possible to tell which a JSON type a particular Lua table was derived from, or guarantee
	--   decode-encode round-trip equivalency.
	--
	--   However, if you enable strictTypes, e.g.
	--
	--      JSON = (loadfile "JSON.lua")() --load the routines
	--      JSON.strictTypes = true
	--
	--   then the Lua table resulting from the decoding of a JSON object or JSON array is marked via Lua
	--   metatable, so that when re-encoded with JSON:encode() it ends up as the appropriate JSON type.
	--
	--   (This is not the default because other routines may not work well with tables that have a
	--   metatable set, for example, Lightroom API calls.)
	--
	--
	-- ENCODING
	--
	--   JSON = (loadfile "JSON.lua")() -- one-time load of the routines
	--
	--   local raw_json_text    = JSON:encode(lua_table_or_value)
	--   local pretty_json_text = JSON:encode_pretty(lua_table_or_value) -- "pretty printed" version for human readability

	--   On error during encoding, this code calls:
	--
	--    JSON:onEncodeError(message, etc)
	--
	--   which you can override in your local JSON object.
	--
	--   If the Lua table contains both string and numeric keys, it fits neither JSON's
	--   idea of an object, nor its idea of an array. To get around this, when any string
	--   key exists (or when non-positive numeric keys exist), numeric keys are converted
	--   to strings.
	--
	--   For example,
	--     JSON:encode({ "one", "two", "three", SOMESTRING = "some string" }))
	--   produces the JSON object
	--     {"1":"one","2":"two","3":"three","SOMESTRING":"some string"}
	--
	--   To prohibit this conversion and instead make it an error condition, set
	--      JSON.noKeyConversion = true


	--
	-- SUMMARY OF METHODS YOU CAN OVERRIDE IN YOUR LOCAL LUA JSON OBJECT
	--
	--    assert
	--    onDecodeError
	--    onDecodeOfNilError
	--    onDecodeOfHTMLError
	--    onEncodeError
	--
	--  If you want to create a separate Lua JSON object with its own error handlers,
	--  you can reload JSON.lua or use the :new() method.
	--
	---------------------------------------------------------------------------

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

		 local _, match_end = text:find("^[ \n\r\t]+", start) -- [http://www.ietf.org/rfc/rfc4627.txt] Section 2
		 if match_end then
				return match_end + 1
		 else
				return start
		 end
	end

	local grok_one -- assigned later

	local function grok_object(self, text, start, etc)
		 if text:sub(start,start) ~= '{' then
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

				local new_val, new_i = grok_one(self, text, i)

				VALUE[key] = new_val

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
		 if text:sub(start,start) ~= '[' then
				self:onDecodeError("expected '['", text, start, etc)
		 end

		 local i = skip_whitespace(text, start + 1) -- +1 to skip the '['
		 local VALUE = self.strictTypes and self:newArray { } or { }
		 if text:sub(i,i) == ']' then
				return VALUE, i + 1
		 end

		 local VALUE_INDEX = 1

		 local text_len = text:len()
		 while i <= text_len do
				local val, new_i = grok_one(self, text, i)

				-- can't table.insert(VALUE, val) here because it's a no-op if val is nil
				VALUE[VALUE_INDEX] = val
				VALUE_INDEX = VALUE_INDEX + 1

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

		 local success, value = pcall(grok_one, self, text, 1, etc)

		 if success then
				return value
		 else
				-- if JSON:onDecodeError() didn't abort out of the pcall, we'll have received the error message here as "value", so pass it along as an assert.
				if self.assert then
					 self.assert(false, value)
				else
					 assert(false, value)
				end
				-- and if we're still here, return a nil and throw the error message on as a second arg
				return nil, value
		 end
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

				if self.noKeyConversion then
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

	--
	-- Version history:
	--
	--   20140911.12   Minor lua cleanup.
	--                 Fixed internal reference to 'JSON.noKeyConversion' to reference 'self' instead of 'JSON'.
	--                 (Thanks to SmugMug's David Parry for these.)
	--
	--   20140418.11   JSON nulls embedded within an array were being ignored, such that
	--                     ["1",null,null,null,null,null,"seven"],
	--                 would return
	--                     {1,"seven"}
	--                 It's now fixed to properly return
	--                     {1, nil, nil, nil, nil, nil, "seven"}
	--                 Thanks to "haddock" for catching the error.
	--
	--   20140116.10   The user's JSON.assert() wasn't always being used. Thanks to "blue" for the heads up.
	--
	--   20131118.9    Update for Lua 5.3... it seems that tostring(2/1) produces "2.0" instead of "2",
	--                 and this caused some problems.
	--
	--   20131031.8    Unified the code for encode() and encode_pretty(); they had been stupidly separate,
	--                 and had of course diverged (encode_pretty didn't get the fixes that encode got, so
	--                 sometimes produced incorrect results; thanks to Mattie for the heads up).
	--
	--                 Handle encoding tables with non-positive numeric keys (unlikely, but possible).
	--
	--                 If a table has both numeric and string keys, or its numeric keys are inappropriate
	--                 (such as being non-positive or infinite), the numeric keys are turned into
	--                 string keys appropriate for a JSON object. So, as before,
	--                         JSON:encode({ "one", "two", "three" })
	--                 produces the array
	--                         ["one","two","three"]
	--                 but now something with mixed key types like
	--                         JSON:encode({ "one", "two", "three", SOMESTRING = "some string" }))
	--                 instead of throwing an error produces an object:
	--                         {"1":"one","2":"two","3":"three","SOMESTRING":"some string"}
	--
	--                 To maintain the prior throw-an-error semantics, set
	--                      JSON.noKeyConversion = true
	--
	--   20131004.7    Release under a Creative Commons CC-BY license, which I should have done from day one, sorry.
	--
	--   20130120.6    Comment update: added a link to the specific page on my blog where this code can
	--                 be found, so that folks who come across the code outside of my blog can find updates
	--                 more easily.
	--
	--   20111207.5    Added support for the 'etc' arguments, for better error reporting.
	--
	--   20110731.4    More feedback from David Kolf on how to make the tests for Nan/Infinity system independent.
	--
	--   20110730.3    Incorporated feedback from David Kolf at http://lua-users.org/wiki/JsonModules:
	--
	--                   * When encoding lua for JSON, Sparse numeric arrays are now handled by
	--                     spitting out full arrays, such that
	--                        JSON:encode({"one", "two", [10] = "ten"})
	--                     returns
	--                        ["one","two",null,null,null,null,null,null,null,"ten"]
	--
	--                     In 20100810.2 and earlier, only up to the first non-null value would have been retained.
	--
	--                   * When encoding lua for JSON, numeric value NaN gets spit out as null, and infinity as "1+e9999".
	--                     Version 20100810.2 and earlier created invalid JSON in both cases.
	--
	--                   * Unicode surrogate pairs are now detected when decoding JSON.
	--
	--   20100810.2    added some checking to ensure that an invalid Unicode character couldn't leak in to the UTF-8 encoding
	--
	--   20100731.1    initial public release
	--
	Poco.JSON = OBJDEF:new()
end


do -- Inspect
	local inspect ={
		_VERSION = 'inspect.lua 2.0.0',
		_URL     = 'http://github.com/kikito/inspect.lua',
		_DESCRIPTION = 'human-readable representations of tables',
		_LICENSE = [[
			MIT LICENSE

			Copyright (c) 2013 Enrique Garc�a Cota

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
	Poco.inspect = inspect
	setmetatable(inspect, { __call = function(_, ...) return Poco.inspect.inspect(...) end })
end

do --[[ deepcopy.lua

    Deep-copy function for Lua - v0.2
    ==============================
      - Does not overflow the stack.
      - Maintains cyclic-references
      - Copies metatables
      - Maintains common upvalues between copied functions (for Lua 5.2 only)

    TODO
    ----
      - Document usage (properly) and provide examples
      - Implement handling of LuaJIT FFI ctypes
      - Provide option to only set metatables, not copy (as if they were
        immutable)
      - Find a way to replicate `debug.upvalueid` and `debug.upvaluejoin` in
        Lua 5.1
      - Copy function environments in Lua 5.1 and LuaJIT
        (Lua 5.2's _ENV is actually a good idea!)
      - Handle C functions

    Usage
    -----
        copy = table.deecopy(orig)
        copy = table.deecopy(orig, params, customcopyfunc_list)

    `params` is a table of parameters to inform the copy functions how to
    copy the data. The default ones available are:
      - `value_ignore` (`table`/`nil`): any keys in this table will not be
        copied (value should be `true`). (default: `nil`)
      - `value_translate` (`table`/`nil`): any keys in this table will result
        in the associated value, rather than a copy. (default: `nil`)
        (Note: this can be useful for global tables: {[math] = math, ..})
      - `metatable_immutable` (`boolean`): assume metatables are immutable and
        do not copy them (only set). (default: `false`)
      - `function_immutable` (`boolean`): do not copy function values; instead
        use the original value. (default: `false`)
      - `function_env` (`table`/`nil`): Set the enviroment of functions to
        this value (via fourth arg of `loadstring`). (default: `nil`)
        this value. (default: `nil`)
      - `function_upvalue_isolate` (`boolean`): do not join common upvalues of
        copied functions (only applicable for Lua 5.2 and LuaJIT). (default:
        `false`)
      - `function_upvalue_dontcopy` (`boolean`): do not copy upvalue values
        (does not stop joining). (default: `false`)

    `customcopyfunc_list` is a table of typenames to copy functions.
    For example, a simple solution for userdata:
    { ["userdata"] = function(stack, orig, copy, state, arg1, arg2)
        if state == nil then
            copy = orig
            local orig_uservalue = debug.getuservalue(orig)
            if orig_uservalue ~= nil then
                stack:recurse(orig_uservalue)
                return copy, 'uservalue'
            end
            return copy, true
        elseif state == 'uservalue' then
            local copy_uservalue = arg2
            if copy_uservalue ~= nil then
                debug.setuservalue(copy, copy_uservalue)
            end
            return copy, true
        end
    end }
    Any parameters passed to the `params` are available in `stack`.
    You can use custom paramter names, but keep in mind that numeric keys and
    string keys prefixed with a single underscore are reserved.

    License
    -------
    Copyright (C) 2012 Declan White

    Permission is hereby granted, free of charge, to any person obtaining a
    copy of this software and associated documentation files (the "Software"),
    to deal in the Software without restriction, including without limitation
    the rights to use, copy, modify, merge, publish, distribute, sublicense,
    and/or sell copies of the Software, and to permit persons to whom the
    Software is furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
    THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
    FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
    DEALINGS IN THE SOFTWARE.
]]
    local type = type
    local rawget = rawget
    local rawset = rawset
    local next = next
    local getmetatable = debug and debug.getmetatable or getmetatable
    local setmetatable = debug and debug.setmetatable or setmetatable
    local debug_getupvalue = debug and debug.getupvalue or nil
    local debug_setupvalue = debug and debug.setupvalue or nil
    local debug_upvalueid = debug and debug.upvalueid or nil
    local debug_upvaluejoin = debug and debug.upvaluejoin or nil
    local unpack = unpack
    local table = table
    table.deepcopy_copyfunc_list = {
      --["type"] = function(stack, orig, copy, state, temp1, temp2, temp..., tempN)
      --
      --    -- When complete:
      --    state = true
      --
      --    -- Store temporary variables between iterations using these:
      --    -- (Note: you MUST NOT call these AFTER recurse)
      --    stack:_push(tempN+1, tempN+2, tempN+..., tempN+M)
      --    stack:_pop(K)
      --    -- K is the number to pop.
      --    -- If you wanted to pop two from the last state and push four new ones:
      --    stack:_pop(2)
      --    stack:_push('t', 'e', 's', 't')
      --
      --    -- To copy a child value:
      --    -- (Note: any calls to push or pop MUST be BEFORE a call to this)
      --    state:recurse(childvalue_orig)
      --    -- This will leave two temp variables on the stack for the next iteration
      --    -- .., childvalue_orig, childvalue_copy
      --    -- which are available via the varargs (temp...)
      --    -- (Note: the copy may be nil if it was not copied (because caller
      --    -- specified it not to be)).
      --    -- You can only call this once per iteration.
      --
      --    -- Return like this:
      --    -- (Temp variables are not part of the return list due to optimisation.)
      --    return copy, state
      --
      --end,
        _plainolddata = function(stack, orig, copy, state)
            return orig, true
        end,
        ["table"] = function(stack, orig, copy, state, arg1, arg2, arg3, arg4)
            local orig_prevkey, grabkey = nil, false
            if state == nil then -- 'init'
                -- Initial state, check for metatable, or get first key
                -- orig, copy:nil, state
                copy = stack[orig]
                if copy ~= nil then -- Check if already copied
                    return copy, true
                else
                    copy = {} -- Would be nice if you could preallocate sizes!
                    stack[orig] = copy
                    local orig_meta = getmetatable(orig)
                    if orig_meta ~= nil then -- This table has a metatable, copy it
                        if not stack.metatable_immutable then
                            stack:_recurse(orig_meta)
                            return copy, 'metatable'
                        else
                            setmetatable(copy, orig_meta)
                        end
                    end
                end
                -- No metatable, go straight to copying key-value pairs
                orig_prevkey = nil -- grab first key
                grabkey = true --goto grabkey
            elseif state == 'metatable' then
                -- Metatable has been copied, set it and get first key
                -- orig, copy:{}, state, metaorig, metacopy
                local copy_meta = arg2--select(2, ...)
                stack:_pop(2)

                if copy_meta ~= nil then
                    setmetatable(copy, copy_meta)
                end

                -- Now start copying key-value pairs
                orig_prevkey = nil -- grab first key
                grabkey = true --goto grabkey
            elseif state == 'key' then
                -- Key has been copied, now copy value
                -- orig, copy:{}, state, keyorig, keycopy
                local orig_key = arg1--select(1, ...)
                local copy_key = arg2--select(2, ...)

                if copy_key ~= nil then
                    -- leave keyorig and keycopy on the stack
                    local orig_value = rawget(orig, orig_key)
                    stack:_recurse(orig_value)
                    return copy, 'value'
                else -- key not copied? move onto next
                    stack:_pop(2) -- pop keyorig, keycopy
                    orig_prevkey = orig_key
                    grabkey = true--goto grabkey
                end
            elseif state == 'value' then
                -- Value has been copied, set it and get next key
                -- orig, copy:{}, state, keyorig, keycopy, valueorig, valuecopy
                local orig_key   = arg1--select(1, ...)
                local copy_key   = arg2--select(2, ...)
              --local orig_value = arg3--select(3, ...)
                local copy_value = arg4--select(4, ...)
                stack:_pop(4)

                if copy_value ~= nil then
                    rawset(copy, copy_key, copy_value)
                end

                -- Grab next key to copy
                orig_prevkey = orig_key
                grabkey = true --goto grabkey
            end
            --return
            --::grabkey::
            if grabkey then
                local orig_key, orig_value = next(orig, orig_prevkey)
                if orig_key ~= nil then
                    stack:_recurse(orig_key) -- Copy key
                    return copy, 'key'
                else
                    return copy, true -- Key is nil, copying of table is complete
                end
            end
            return
        end,
        ["function"] = function(stack, orig, copy, state, arg1, arg2, arg3)
            local grabupvalue, grabupvalue_idx = false, nil
            if state == nil then
                -- .., orig, copy, state
                copy = stack[orig]
                if copy ~= nil then
                    return copy, true
                elseif stack.function_immutable then
                    copy = orig
                    return copy, true
                else
                    copy = loadstring(string.dump(orig), nil, nil, stack.function_env)
                    stack[orig] = copy

                    if debug_getupvalue ~= nil and debug_setupvalue ~= nil then
                        grabupvalue = true
                        grabupvalue_idx = 1
                    else
                        -- No way to get/set upvalues!
                        return copy, true
                    end
                end
            elseif --[[this_state]]false == 'upvalue' then
                -- .., orig, copy, state, uvidx, uvvalueorig, uvvaluecopy
                local orig_upvalue_idx   = arg1
              --local orig_upvalue_value = arg2
                local copy_upvalue_value = arg3
                stack:_pop(3)

                debug_setupvalue(copy, orig_upvalue_idx, copy_upvalue_value)

                grabupvalue_idx = orig_upvalue_idx+1
                stack:_push(grabupvalue_idx)
                grabupvalue = true
            end
            if grabupvalue then
                -- .., orig, copy, retto, state, uvidx
                local upvalue_idx_curr = grabupvalue_idx
                for upvalue_idx = upvalue_idx_curr, math.huge do
                    local upvalue_name, upvalue_value_orig = debug_getupvalue(orig, upvalue_idx)
                    if upvalue_name ~= nil then
                        local upvalue_handled = false
                        if not stack.function_upvalue_isolate and debug_upvalueid ~= nil and debug_upvaluejoin ~= nil then
                            local upvalue_uid = debug.upvalueid(orig, upvalue_idx)
                            -- Attempting to store an upvalueid of a function as a child of root is UB!
                            local other_orig = stack[upvalue_uid]
                            if other_orig ~= nil then
                                for other_upvalue_idx = 1, math.huge do
                                    if upvalue_uid == debug_upvalueid(other_orig, other_upvalue_idx) then
                                        local other_copy = stack[other_orig]
                                        debug_upvaluejoin(
                                            copy, upvalue_idx,
                                            other_copy, other_upvalue_idx
                                        )
                                        break
                                    end
                                end
                                upvalue_handled = true
                            else
                                stack[upvalue_uid] = orig
                            end
                        end
                        if not stack.function_upvalue_dontcopy and not upvalue_handled and upvalue_value_orig ~= nil then
                            stack:_recurse(upvalue_value_orig)
                            return copy, 'upvalue'
                        end
                    else
                        stack:_pop(1) -- pop uvidx
                        return copy, true
                    end
                end
            end
        end,
        ["userdata"] = nil,
        ["lightuserdata"] = nil,
        ["thread"] = nil,
    }
    table.deepcopy_copyfunc_list["number" ] = table.deepcopy_copyfunc_list._plainolddata
    table.deepcopy_copyfunc_list["string" ] = table.deepcopy_copyfunc_list._plainolddata
    table.deepcopy_copyfunc_list["boolean"] = table.deepcopy_copyfunc_list._plainolddata
    -- `nil` should never be encounted... but just in case:
    table.deepcopy_copyfunc_list["nil"    ] = table.deepcopy_copyfunc_list._plainolddata

    do
        local ORIG, COPY, RETTO, STATE, SIZE = 0, 1, 2, 3, 4
        function table.deepcopy_push(...)
            local arg_list_len = select('#', ...)
            local stack_offset = stack._top+1
            for arg_i = 1, arg_list_len do
                stack[stack_offset+arg_i] = select(arg_i, ...)
            end
            stack._top = stack_top+arg_list_len
        end
        function table.deepcopy_pop(stack, count)
            stack._top = stack._top-count
        end
        function table.deepcopy_recurse(stack, orig)
            local retto = stack._ptr
            local stack_top = stack._top
            local stack_ptr = stack_top+1
            stack._top = stack_top+SIZE
            stack._ptr = stack_ptr
            stack[stack_ptr+ORIG ] = orig
            stack[stack_ptr+COPY ] = nil
            stack[stack_ptr+RETTO] = retto
            stack[stack_ptr+STATE] = nil
        end
        function table.deepcopy(root, params, customcopyfunc_list)
            local stack = params or {}
            --orig,copy,retto,state,[temp...,] partorig,partcopy,partretoo,partstate
            stack[1+ORIG ] = root stack[1+COPY ] = nil
            stack[1+RETTO] = nil  stack[1+STATE] = nil
            stack._ptr = 1 stack._top = 4
            stack._push = table.deepcopy_push stack._pop = table.deepcopy_pop
            stack._recurse = table.deepcopy_recurse
            --[[local stack_dbg do -- debug
                stack_dbg = stack
                stack = setmetatable({}, {
                    __index = stack_dbg,
                    __newindex = function(t, k, v)
                        stack_dbg[k] = v
                        if tonumber(k) then
                            local stack = stack_dbg
                            local line_stack, line_label, line_stptr = "", "", ""
                            for stack_i = 1, math.max(stack._top, stack._ptr) do
                                local s_stack = (
                                        (type(stack[stack_i]) == 'table' or type(stack[stack_i]) == 'function')
                                            and string.gsub(tostring(stack[stack_i]), "^.-(%x%x%x%x%x%x%x%x)$", "<%1>")
                                    or  tostring(stack[stack_i])
                                ), type(stack[stack_i])
                                local s_label = ""--dbg_label_dict[stack_i] or "?!?"
                                local s_stptr = (stack_i == stack._ptr and "*" or "")..(stack_i == k and "^" or "")
                                local maxlen = math.max(#s_stack, #s_label, #s_stptr)+1
                                line_stack = line_stack..s_stack..string.rep(" ", maxlen-#s_stack)
                                --line_label = line_label..s_label..string.rep(" ", maxlen-#s_label)
                                line_stptr = line_stptr..s_stptr..string.rep(" ", maxlen-#s_stptr)
                            end
                            io.stdout:write(
                                          line_stack
                                --..  "\n"..line_label
                                ..  "\n"..line_stptr
                                ..  ""
                            )
                            io.read()
                        elseif false then
                            io.stdout:write(("stack.%s = %s"):format(
                                k,
                                (
                                        (type(v) == 'table' or type(v) == 'function')
                                            and string.gsub(tostring(v), "^.-(%x%x%x%x%x%x%x%x)$", "<%1>")
                                    or  tostring(v)
                                )
                            ))
                            io.read()
                        end
                    end,
                })
            end]]
            local copyfunc_list = table.deepcopy_copyfunc_list
            repeat
                local stack_ptr = stack._ptr
                local this_orig = stack[stack_ptr+ORIG]
                local this_copy, this_state
                stack[0] = stack[0]
                if stack.value_ignore and stack.value_ignore[this_orig] then
                    this_copy = nil
                    this_state = true --goto valuefound
                else
                    if stack.value_translate then
                        this_copy = stack.value_translate[this_orig]
                        if this_copy ~= nil then
                            this_state = true --goto valuefound
                        end
                    end
                    if not this_state then
                        local this_orig_type = type(this_orig)
                        local copyfunc = (
                                customcopyfunc_list and customcopyfunc_list[this_orig_type]
                            or  copyfunc_list[this_orig_type]
                            or  error(("cannot copy type %q"):format(this_orig_type), 2)
                        )
                        this_copy, this_state = copyfunc(
                            stack,
                            this_orig,
                            stack[stack_ptr+COPY],
                            unpack(stack--[[_dbg]], stack_ptr+STATE, stack._top)
                        )
                    end
                end
                stack[stack_ptr+COPY] = this_copy
                --::valuefound::
                if this_state == true then
                    local retto = stack[stack_ptr+RETTO]
                    stack._top = stack_ptr+1 -- pop retto, state, temp...
                    -- Leave orig and copy on stack for parent object
                    stack_ptr = retto -- return to parent's stack frame
                    stack._ptr = stack_ptr
                else
                    stack[stack_ptr+STATE] = this_state
                end
            until stack_ptr == nil
            return stack[1+COPY]
        end
    end
end

end) -- pcall
JSON = JSON or Poco.JSON
if not r then
	io.stderr:write(err)
end