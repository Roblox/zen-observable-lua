-- ROBLOX upstream https://github.com/zenparsing/zen-observable/blob/v0.8.15/test/properties.js
-- ROBLOX comment: this file contains many deviations to achieve similar checks
local exports = {}
local srcWorkspace = script.Parent.Parent
local rootWorkspace = srcWorkspace.Parent
local LuauPolyfill = require(rootWorkspace.LuauPolyfill)
local Boolean = LuauPolyfill.Boolean
local Array = LuauPolyfill.Array
local Object = LuauPolyfill.Object
type Object = LuauPolyfill.Object

local JestGlobals = require(rootWorkspace.Dev.JestGlobals)
local jestExpect = JestGlobals.expect

local function getPrototypeOf(obj)
	return getmetatable(obj)
end

local function testMethodProperty(
	object: Object,
	key: string,
	options: {
		enumerable: boolean?,
		configurable: boolean?, -- ROBLOX comment: not used
		writable: boolean?, -- ROBLOX comment: not used
		length: number?,
		get: boolean?,
		set: boolean?,
	}
)
	local desc = object[key]
	local proto = getPrototypeOf(object :: any)
	local enumerable, _configurable, _writable, length =
		options.enumerable :: boolean, options.configurable :: boolean, options.writable :: boolean, options.length

	if options.enumerable == nil then
		enumerable = false
	end
	if options.configurable == nil then
		_configurable = false
	end
	if options.writable == nil then
		_writable = false
	end

	jestExpect(desc).toBeDefined()

	if Boolean.toJSBoolean(options.get) or Boolean.toJSBoolean(options.set) then
		jestExpect(typeof(object.__index)).toBe("function")
		jestExpect(typeof(object.__newindex)).toBe("function")
		if Boolean.toJSBoolean(options.get) then
			jestExpect(function()
				(proto.__index :: any)(object, key)
			end).never.toThrow()
		else
			jestExpect(function()
				(proto.__index :: any)(object, key)
			end).toThrow()
		end
		if Boolean.toJSBoolean(options.set) then
			jestExpect(function()
				(proto.__newindex :: any)(object, key)
			end).never.toThrow()
		else
			jestExpect(function()
				(proto.__newindex :: any)(object, key)
			end).toThrow()
		end
	else
		jestExpect(typeof(desc)).toBe("function")
		if length ~= nil then -- ROBLOX deviation: added this check to make sure length is defined
			local argumentCount, _variadic = (debug :: any).info(desc, "a")
			jestExpect(argumentCount :: number).toBe(length)
		end
	end

	if enumerable then
		jestExpect(Array.some(Object.keys(object), function(k)
			return k == key
		end)).toBe(true)
	end
end

exports.testMethodProperty = testMethodProperty

return exports
