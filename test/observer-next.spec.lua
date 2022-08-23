-- ROBLOX upstream https://github.com/zenparsing/zen-observable/blob/v0.8.15/test/observer-next.js

local rootWorkspace = script.Parent.Parent
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
	describe("observer.next", function()
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
				"next",
				{
					configurable = true,
					writable = true,
					length = 2, --[[ ROBLOX deviation: adds self arg ]]
				}
			)
		end)

		it("forwards the first argument", function()
			local args
			local observer = getObserver({
				next = function(self, ...)
					args = { ... }
				end,
			})
			observer:next(1, 2)
			jestExpect(args).toEqual({ 1 })
		end)

		it("does not return a value", function()
			local observer = getObserver({
				next = function(self)
					return 1
				end,
			})
			jestExpect(observer:next()).toBe(nil)
		end)

		it("does not forward when the subscription is complete", function()
			local count = 0
			local observer = getObserver({
				next = function(self)
					count += 1
				end,
			})
			observer:complete()
			observer:next()
			jestExpect(count).toBe(0)
		end)

		it("does not forward when the subscription is cancelled", function()
			local count = 0
			local observer
			local subscription = Observable.new(function(x)
				observer = x
			end):subscribe({
				next = function(self)
					count += 1
				end,
			})
			subscription:unsubscribe()
			observer:next()
			jestExpect(count).toBe(0)
		end)

		it('remains closed if the subscription is cancelled from "next"', function()
			local observer
			local subscription
			subscription = Observable.new(function(x)
				observer = x
			end):subscribe({
				next = function(self)
					subscription:unsubscribe()
				end,
			})
			observer:next()
			jestExpect(observer.closed).toBe(true)
		end)

		it("queues if the subscription is not initialized", function()
			local values = {}
			local observer
			Observable.new(function(x)
				observer = x
				x:next(1)
			end):subscribe({
				next = function(self, val)
					table.insert(values, val)
					if val == 1 then
						observer:next(3)
					end
				end,
			})
			observer:next(2)
			jestExpect(values).toEqual({})
			Promise.delay(0):expect()
			jestExpect(values).toEqual({ 1, 2 })
			Promise.delay(0):expect()
			jestExpect(values).toEqual({ 1, 2, 3 })
		end)

		it("drops queue if subscription is closed", function()
			local values = {}
			local subscription = Observable.new(function(x)
				x:next(1)
			end):subscribe({
				next = function(self, val)
					table.insert(values, val)
				end,
			})
			jestExpect(values).toEqual({})
			subscription:unsubscribe()
			Promise.delay(0):expect()
			jestExpect(values).toEqual({})
		end)

		it("queues if the observer is running", function()
			local observer
			local values = {}
			Observable.new(function(x)
				observer = x
			end):subscribe({
				next = function(self, val)
					table.insert(values, val)
					if val == 1 then
						observer:next(2)
					end
				end,
			})
			observer:next(1)
			jestExpect(values).toEqual({ 1 })
			Promise.delay(0):expect()
			jestExpect(values).toEqual({ 1, 2 })
		end)

		it('reports error if "next" is not a method', function()
			local observer = getObserver({ next = 1 })
			observer:next()
			jestExpect(_G.hostError).toBeTruthy()
		end)

		it('does not report error if "next" is undefined', function()
			local observer = getObserver({ next = nil })
			observer:next()
			jestExpect(not Boolean.toJSBoolean(_G.hostError)).toBeTruthy()
		end)

		it('does not report error if "next" is null', function()
			local observer = getObserver({ next = nil })
			observer:next()
			jestExpect(not Boolean.toJSBoolean(_G.hostError)).toBeTruthy()
		end)

		it('reports error if "next" throws', function()
			local error_ = {}
			local observer = getObserver({
				next = function(self)
					error(error_)
				end,
			})
			observer:next()
			jestExpect(_G.hostError).toEqual(error_)
		end)

		it("does not close the subscription on error", function()
			local observer = getObserver({
				next = function(self)
					error({})
				end,
			})
			observer:next()
			jestExpect(observer.closed).toBe(false)
		end)
	end)
end
