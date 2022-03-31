-- ROBLOX upstream https://github.com/zenparsing/zen-observable/blob/v0.8.15/test/observer-error.js

local srcWorkspace = script.Parent.Parent
local rootWorkspace = srcWorkspace.Parent
local LuauPolyfill = require(rootWorkspace.LuauPolyfill)
local Boolean = LuauPolyfill.Boolean
type Object = LuauPolyfill.Object

local JestGlobals = require(rootWorkspace.Dev.JestGlobals)
local jestExpect = JestGlobals.expect

local Promise = require(rootWorkspace.Promise)

local testMethodProperty = require(script.Parent.properties).testMethodProperty

return function()
	-- ROBLOX deviation: upstream a global variable is created in the test setup.
	-- A local variable is created to avoid using _G.Observable in every test
	local Observable
	beforeEach(function()
		Observable = _G.Observable
	end)
	describe("observer.error", function()
		-- ROBLOX FIXME luau: cannot convert to `Object?` for some reason
		-- local function getObserver(inner: Object?)
		local function getObserver(inner: any)
			local observer
			Observable.new(function(x)
				observer = x
			end):subscribe(inner)
			return observer
		end

		it("is a method of SubscriptionObserver", function()
			local observer = getObserver()
			testMethodProperty(
				--ROBLOX deviation, getPrototypeof called in function
				observer,
				"error",
				{
					configurable = true,
					writable = true,
					length = 2, --[[ ROBLOX deviation: adds self arg ]]
				}
			)
		end)

		it("forwards the argument", function()
			local args
			local observer = getObserver({
				error = function(_self, ...)
					args = { ... }
				end,
			})
			observer:error(1)
			jestExpect(args).toEqual({ 1 })
		end)

		it("does not return a value", function()
			local observer = getObserver({
				error = function(_self)
					return 1
				end,
			})
			jestExpect(observer:error()).toBe(nil)
		end)

		it("does not throw when the subscription is complete", function()
			local observer = getObserver({ error = function(_self) end })
			observer:complete()
			observer:error("error")
		end)

		it("does not throw when the subscription is cancelled", function()
			local observer
			local subscription = Observable.new(function(x)
				observer = x
			end):subscribe({ error = function(_self) end })
			subscription:unsubscribe()
			observer:error(1)
			jestExpect(not Boolean.toJSBoolean(_G.hostError)).toBeTruthy()
		end)

		it("queues if the subscription is not initialized", function()
			local error_
			Observable.new(function(x)
				x:error_({})
			end):subscribe({
				error = function(_self, err)
					error_ = err
				end,
			})
			jestExpect(error_).toBe(nil)
			Promise.delay(0):expect()
			jestExpect(error_).toBeTruthy()
		end)

		it("queues if the observer is running", function()
			local observer
			local error_
			Observable.new(function(x)
				observer = x
			end):subscribe({
				next = function(_self)
					observer:error({})
				end,
				error = function(_self, e)
					error_ = e
				end,
			})
			observer:next()
			jestExpect(not Boolean.toJSBoolean(error_)).toBeTruthy()
			Promise.delay(0):expect()
			jestExpect(error_).toBeTruthy()
		end)

		it("closes the subscription before invoking inner observer", function()
			local closed
			local observer
			observer = getObserver({
				error = function(_self)
					closed = observer.closed
				end,
			})
			observer:error(1)
			jestExpect(closed).toBe(true)
		end)

		it('reports an error if "error" is not a method', function()
			local observer = getObserver({ error = 1 })
			observer:error(1)
			jestExpect(_G.hostError).toBeTruthy()
		end)

		it('reports an error if "error" is undefined', function()
			local error_ = {}
			local observer = getObserver({ ["error"] = nil })
			observer:error(error_)
			jestExpect(_G.hostError).toEqual(error_)
		end)

		it('reports an error if "error" is null', function()
			local error_ = {}
			local observer = getObserver({ error = nil })
			observer:error(error_)
			jestExpect(_G.hostError).toEqual(error_)
		end)

		it('reports error if "error" throws', function()
			local error_ = {}
			local observer = getObserver({
				error = function(self)
					error(error_)
				end,
			})
			observer:error(1)
			jestExpect(_G.hostError).toEqual(error_)
		end)

		it('calls the cleanup method after "error"', function()
			local calls = {}
			local observer
			Observable.new(function(x)
				observer = x
				return function()
					table.insert(calls, "cleanup")
				end
			end):subscribe({
				["error"] = function(_self)
					table.insert(calls, "error")
				end,
			})
			observer:error()
			jestExpect(calls).toEqual({ "error", "cleanup" })
		end)

		it('calls the cleanup method if there is no "error"', function()
			local calls = {}
			local observer
			Observable.new(function(x)
				observer = x
				return function()
					table.insert(calls, "cleanup")
				end
			end):subscribe({})
			local _ok, result, hasReturned = xpcall(function()
				observer:error()
			end, function(err) end)
			if hasReturned then
				return result
			end
			jestExpect(calls).toEqual({ "cleanup" })
		end)

		it("reports error if the cleanup function throws", function()
			local error_ = {}
			local observer
			Observable.new(function(x)
				observer = x
				return function()
					error(error_)
				end
			end):subscribe()
			observer:error(1)
			jestExpect(_G.hostError).toEqual(error_)
		end)
	end)
end
