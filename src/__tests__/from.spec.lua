-- ROBLOX upstream https://github.com/zenparsing/zen-observable/blob/v0.8.15/test/from.js

local srcWorkspace = script.Parent.Parent
local rootWorkspace = srcWorkspace.Parent

local LuauPolyfill = require(rootWorkspace.LuauPolyfill)
type Array<T> = LuauPolyfill.Array<T>
type Record<T, U> = { [T]: U }
local Symbol = LuauPolyfill.Symbol

local Promise = require(rootWorkspace.Promise)

local JestGlobals = require(rootWorkspace.Dev.JestGlobals)
local jestExpect = JestGlobals.expect

return function()
	-- ROBLOX deviation: upstream a global variable is created in the test setup.
	-- A local variable is created to avoid using _G.Observable in every test
	local Observable
	beforeEach(function()
		Observable = _G.Observable
	end)
	describe("from", function()
		-- local iterable = {[tostring(Symbol.iterator)] = function(self)
		-- error("not implemented") --[[ ROBLOX TODO: Unhandled node for type: YieldExpression ]]
		--  --[[ yield 1 ]];
		-- error("not implemented") --[[ ROBLOX TODO: Unhandled node for type: YieldExpression ]]
		--  --[[ yield 2 ]];
		-- error("not implemented") --[[ ROBLOX TODO: Unhandled node for type: YieldExpression ]]
		--  --[[ yield 3 ]];
		-- end}
		-- ROBLOX deviation: prototype not available, we just check that method exists
		it("is a method on Observable", function()
			jestExpect(function()
				Observable.from({ "a-string" })
			end).never.toThrowError()
		end)

		it("throws if the argument is null", function()
			jestExpect(function()
				Observable.from(nil)
			end).toThrowError()
		end)
		it("throws if the argument is undefined", function()
			jestExpect(function()
				Observable.from(nil)
			end).toThrowError()
		end)

		it("throws if the argument is not observable or iterable", function()
			jestExpect(function()
				-- ROBLOX deviation: table needs key/value to differentiate from empty Array
				return Observable.from({ key = "value" })
			end).toThrowError()
		end)
		describe("observables", function()
			it('returns the input if the constructor matches "this"', function()
				-- ROBLOX deviation = we need the Obervable symbol to distinguish "this" and use it as "this"
				local ctor = { new = function() end, [Symbol.observable] = Observable[Symbol.observable] }
				local observable = Observable.new(function() end)
				observable.new = ctor.new
				jestExpect(Observable.from(ctor, observable)).toEqual(observable)
			end)

			-- ROBLOX comment: the obj is considered an instance of Observable on Polyfill implementation
			xit("wraps the input if it is not an instance of Observable", function()
				local obj = {
					new = Observable.new,
					[Symbol.observable] = function(self)
						return self
					end,
				}
				jestExpect(Observable.from(obj) ~= obj).toBeTruthy()
			end)
			it("throws if @@observable property is not a method", function()
				jestExpect(function()
					return Observable.from({ [Symbol.observable] = 1 })
				end).toThrowError()
			end)
			it("returns an observable wrapping @@observable result", function()
				local observer
				local cleanupCalled = true
				local inner = {
					subscribe = function(_self, x)
						observer = x
						return function()
							cleanupCalled = true
						end
					end,
				}
				local observable = Observable.from({
					[Symbol.observable] = function(_self)
						return inner
					end,
				})
				observable:subscribe()
				jestExpect(typeof(observer.next)).toBe("function")
				observer:complete()
				jestExpect(cleanupCalled).toBe(true)
			end)
		end)
		describe("iterables", function()
			-- it("throws if @@iterator is not a method", function()
			-- assert:throws(function()
			-- return Observable:from({[tostring(Symbol.iterator)] = 1})
			-- end);
			-- end);
			-- it("returns an observable wrapping iterables", function()
			-- local calls = {}
			-- local subscription = Observable:from(iterable):subscribe({next = function(self, v)
			-- calls:push({"next", v});
			-- end, complete = function(self)
			-- calls:push({"complete"});
			-- end})
			-- assert:deepEqual(calls, {});
			-- error("not implemented") --[[ ROBLOX TODO: Unhandled node for type: AwaitExpression ]]
			--  --[[ await null ]];
			-- assert:deepEqual(calls, {{"next", 1}, {"next", 2}, {"next", 3}, {"complete"}});
			-- end);

			-- ROBLOX comment: not present upstream
			it("returns an observable wrapping Array", function()
				local calls = {}
				local _subscription = Observable.from({ 1, 2, 3 }):subscribe({
					next = function(_self, v: number)
						table.insert(calls, { "next", v :: any })
					end,
					complete = function(_self)
						table.insert(calls, { "complete" })
					end,
				})
				jestExpect(calls).toEqual({})
				Promise.delay(0):expect()
				jestExpect(calls).toEqual({
					{ "next", 1 :: any },
					{ "next", 2 :: any },
					{ "next", 3 :: any },
					{ "complete" },
				})
			end)
		end)
	end)
end
