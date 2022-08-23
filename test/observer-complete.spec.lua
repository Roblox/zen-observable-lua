-- ROBLOX upstream https://github.com/zenparsing/zen-observable/blob/v0.8.15/test/observer-complete.js

local rootWorkspace = script.Parent.Parent
local LuauPolyfill = require(rootWorkspace.LuauPolyfill)
local instanceOf = LuauPolyfill.instanceof
local Error = LuauPolyfill.Error
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
	describe("observer.complete", function()
		local function getObserver(inner: Object?)
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
				"complete",
				{
					configurable = true,
					writable = true,
					length = 1, --[[ ROBLOX deviation: adds self arg ]]
				}
			)
		end)

		it("does not forward arguments", function()
			local args
			local observer = getObserver({
				complete = function(_self, ...)
					args = { ... }
				end,
			})
			observer:complete(1)
			jestExpect(args).toEqual({})
		end)

		it("does not return a value", function()
			local observer = getObserver({
				complete = function(_self)
					return 1
				end,
			})
			jestExpect(observer:complete()).toBe(nil)
		end)

		it("does not forward when the subscription is complete", function()
			local count = 0
			local observer = getObserver({
				complete = function(_self)
					count += 1
				end,
			})
			observer:complete()
			observer:complete()
			jestExpect(count).toBe(1)
		end)

		it("does not forward when the subscription is cancelled", function()
			local count = 0
			local observer
			local subscription = Observable.new(function(x)
				observer = x
			end):subscribe({
				complete = function(self)
					count += 1
				end,
			})
			subscription:unsubscribe()
			observer:complete()
			jestExpect(count).toBe(0)
		end)

		it("queues if the subscription is not initialized", function()
			local completed = false
			Observable.new(function(x)
				x:complete()
			end):subscribe({
				complete = function(self)
					completed = true
				end,
			})
			jestExpect(completed).toBe(false)
			Promise.delay(0):expect()
			jestExpect(completed).toBe(true)
		end)

		it("queues if the observer is running", function()
			local observer
			local completed = false
			Observable.new(function(x)
				observer = x
			end):subscribe({
				next = function(self)
					observer:complete()
				end,
				complete = function(self)
					completed = true
				end,
			})
			observer:next()
			jestExpect(completed).toBe(false)
			Promise.delay(0):expect()
			jestExpect(completed).toBe(true)
		end)

		it("closes the subscription before invoking inner observer", function()
			local closed
			local observer
			observer = getObserver({
				complete = function(self)
					closed = observer.closed
				end,
			})
			observer:complete()
			jestExpect(closed).toBe(true)
		end)

		it('reports error if "complete" is not a method', function()
			local observer = getObserver({ complete = 1 })
			observer:complete()
			jestExpect(instanceOf(_G.hostError, Error)).toBeTruthy()
		end)

		it('does not report error if "complete" is undefined', function()
			local observer = getObserver({ complete = nil })
			observer:complete()
			jestExpect(not Boolean.toJSBoolean(_G.hostError)).toBeTruthy()
		end)

		it('does not report error if "complete" is null', function()
			local observer = getObserver({ complete = nil })
			observer:complete()
			jestExpect(not Boolean.toJSBoolean(_G.hostError)).toBeTruthy()
		end)

		it('reports error if "complete" throws', function()
			local error_ = {}
			local observer = getObserver({
				complete = function(self)
					error(error_)
				end,
			})
			observer:complete()
			jestExpect(_G.hostError).toEqual(error_)
		end)

		it('calls the cleanup method after "complete"', function()
			local calls = {}
			local observer
			Observable.new(function(x)
				observer = x
				return function()
					table.insert(calls, "cleanup")
				end
			end):subscribe({
				complete = function(_self)
					table.insert(calls, "complete")
				end,
			})
			observer:complete()
			jestExpect(calls).toEqual({ "complete", "cleanup" })
		end)

		it('calls the cleanup method if there is no "complete"', function()
			local calls = {}
			local observer
			Observable.new(function(x)
				observer = x
				return function()
					table.insert(calls, "cleanup")
				end
			end):subscribe({})
			observer:complete()
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
			observer:complete()
			jestExpect(_G.hostError).toEqual(error_)
		end)
	end)
end
