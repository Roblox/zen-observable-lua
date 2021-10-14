-- ROBLOX upstream: https://github.com/zenparsing/zen-observable/blob/v0.8.15/src/Observable.js
-- ROBLOX upstream for types: https://github.com/DefinitelyTyped/DefinitelyTyped/blob/master/types/zen-observable/index.d.ts
--!nonstrict

local srcWorkspace = script.Parent
local rootWorkspace = srcWorkspace.Parent

local LuauPolyfill = require(rootWorkspace.LuauPolyfill)
local Promise = require(rootWorkspace.Promise)
local instanceOf = LuauPolyfill.instanceof
local Boolean = LuauPolyfill.Boolean
local Error = LuauPolyfill.Error
local setTimeout = LuauPolyfill.setTimeout
local Array = LuauPolyfill.Array
local Symbol = LuauPolyfill.Symbol
type Object = LuauPolyfill.Object
type Array<T> = LuauPolyfill.Array<T>

type Promise<T> = LuauPolyfill.Promise<T> & { expect: (self: Promise<T>) -> T }

type Function = (...any) -> ...any

-- ROBLOX TODO. replace when fn generics are available
type T_ = any
type R_ = any
type S_ = any

-- Predefine variable
local Observable, SubscriptionObserver, notifySubscription, isObservableClass

--ROBLOX deviation: type "function" and callable tables need to be checked
local function isCallable(value): boolean
	if typeof(value) == "function" then
		return true
	end
	if typeof(value) == "table" then
		local mt = getmetatable(value)
		if mt and rawget(mt, "__call") then
			return true
		end
		if value._isMockFunction then
			return true
		end
	end
	return false
end

local function hasSymbols(): boolean
	-- ROBLOX deviation: check for table with __call method
	return typeof(Symbol) == "table" and typeof(getmetatable(Symbol)["__call"]) == "function"
end

local function hasSymbol(name: string): boolean
	return hasSymbols() and Boolean.toJSBoolean(Symbol[name])
end

local function getSymbol(name: string): string
	if hasSymbol(name) then
		return Symbol[name]
	else
		return "@@" .. name
	end
end

if hasSymbols() and not hasSymbol("observable") then
	Symbol.observable = Symbol("observable")
end

local _SymbolIterator = getSymbol("iterator")
local SymbolObservable = getSymbol("observable")
local SymbolSpecies = getSymbol("species")

local function getMethod(obj: Object, key): Function | nil
	local value = obj[key]
	if value == nil then
		return nil
	end
	--ROBLOX deviation: check for function and callable tables
	if not isCallable(value) then
		-- ROBLOX deviation: using Error instead of TypeError
		error(Error.new(tostring(value) .. " is not a function"))
	end
	return value
end

local function getSpecies(obj: Object)
	-- ROBLOX deviation: obj.constructor not available
	local ctor = obj[SymbolSpecies]
	if ctor ~= nil then
		return ctor
	else
		return Observable
	end
end

local function isObservable(x)
	return instanceOf(x, Observable) -- SPEC: Brand check
end

-- ROBLOX upstream deviation: hostReportError.log, lua functions does not support having other properties, so using setmetatable with __call enables to suppport this
local hostReportError: any
hostReportError = setmetatable({}, {
	__call = function(_self, e)
		if hostReportError.log then
			hostReportError:log(e)
		else
			setTimeout(function()
				error(e)
			end, 0)
		end
	end,
})

local function enqueue(fn)
	Promise.delay(0):doneCall(function()
		xpcall(fn, function(err)
			hostReportError(err)
		end)
	end)
end

local function cleanupSubscription(subscription: Subscription<any>)
	local cleanup = subscription._cleanup
	if cleanup == nil then
		return
	end

	subscription._cleanup = nil

	if not cleanup then
		return
	end

	local ok, err = pcall(function()
		-- ROBLOX deviation: check for functions and callable tables
		if isCallable(cleanup) then
			cleanup()
		else
			local unsubscribe = getMethod(cleanup, "unsubscribe")
			if unsubscribe then
				unsubscribe(cleanup)
			end
		end
	end)
	if not ok then
		hostReportError(err)
	end
end

local function closeSubscription(subscription)
	subscription._observer = nil
	subscription._queue = nil
	subscription._state = "closed"
end

local function flushSubscription(subscription)
	local queue = subscription._queue
	if not Boolean.toJSBoolean(queue) then
		return
	end

	subscription._queue = nil
	subscription._state = "ready"

	for i = 1, #queue, 1 do
		notifySubscription(subscription, queue[i].type, queue[i].value)
		if subscription._state == "closed" then
			break
		end
	end
end

function notifySubscription(subscription, type, value)
	subscription._state = "running"
	local observer = subscription._observer

	local ok, err = pcall(function()
		local m = getMethod(observer, type)
		if type == "next" then
			if m then
				m(observer, value)
			end
		elseif type == "error" then
			closeSubscription(subscription)
			if m then
				m(observer, value)
			else
				error(value)
			end
		elseif type == "complete" then
			closeSubscription(subscription)
			if m then
				m(observer, value)
			end
		end
	end)
	if not ok then
		hostReportError(err)
	end

	if subscription._state == "closed" then
		cleanupSubscription(subscription)
	elseif subscription._state == "running" then
		subscription._state = "ready"
	end
end

local function onNotify(subscription, type, value: any?)
	if subscription._state == "closed" then
		return
	end
	if subscription._state == "buffering" then
		table.insert(subscription._queue, { type = type, value = value })
		return
	end
	if subscription._state ~= "ready" then
		subscription._state = "buffering"

		subscription._queue = { { type = type, value = value } }
		enqueue(function()
			return flushSubscription(subscription)
		end)
		return
	end
	notifySubscription(subscription, type, value)
end

export type Observer<T> = {
	start: ((subscription: Subscription<T>) -> any)?,
	next: ((self: Observer<T>, value: T) -> ())?,
	error: ((self: Observer<T>, errorValue: any) -> ())?,
	complete: ((self: Observer<T>) -> ())?,
}
-- ROBLOX deviation: This appears to be a mistake in DefinitelyTyped
export type Subscriber<T> = (SubscriptionObserver<T>) -> () | (() -> ()) -- | Subscription<T>

export type Subscription<T> = {
	closed: boolean,
	unsubscribe: (self: Subscription<T>) -> (),
	_state: string?,
	_queue: Array<any>?,
	_cleanup: Function | Object | nil,
	_observer: Object, -- ROBLOX FIXME: avoid pitfall of recursive type with differing args check, revisit after https://jira.rbx.com/browse/CLI-47160
}

local Subscription = {}
Subscription.__index = function(t, k)
	if k == "closed" then
		return t._state == "closed"
	end
	if rawget(t, k) then
		return rawget(t, k)
	end
	if rawget(Subscription, k) then
		return rawget(Subscription, k)
	end
	return nil
end
Subscription.__newindex = function(t, k, v)
	if k == "closed" then
		error("setting getter-only property 'closed'")
	end
	rawset(t, k, v)
end

function Subscription.new(observer: Observer<any>, subscriber: Subscriber<any>): Subscription<any>
	local self = setmetatable({}, Subscription)
	-- ASSERT: observer is an object
	-- ASSERT: subscriber is callable
	self._cleanup = nil
	self._observer = observer
	self._queue = nil
	self._state = "initializing"

	local subscriptionObserver = SubscriptionObserver.new(self :: any)

	local ok, _err = pcall(function()
		self._cleanup = (subscriber :: Function)(subscriptionObserver)
	end)

	if ok == false then
		subscriptionObserver:error(_err)
	end

	if self._state == "initializing" then
		self._state = "ready"
	end

	return self
end

function Subscription:unsubscribe()
	if self._state ~= "closed" then
		closeSubscription(self)
		cleanupSubscription(self)
	end
end

type SubscriptionObserver<T> = {
	closed: boolean,
	next: (self: SubscriptionObserver<T>, value: T) -> (),
	error: (self: SubscriptionObserver<T>, error: any) -> (),
	complete: (self: SubscriptionObserver<T>) -> (),
	_subscription: Subscription<any>,
}

SubscriptionObserver = {}
SubscriptionObserver.__index = function(t, k)
	if k == "closed" then
		return t._subscription._state == "closed"
	end
	if rawget(SubscriptionObserver, k) then
		return rawget(SubscriptionObserver, k)
	end
	return rawget(t, k)
end
SubscriptionObserver.__newindex = function(t, k, v)
	if k == "closed" then
		error("setting getter-only property 'closed'")
	end
	rawset(t, k, v)
end

function SubscriptionObserver.new(subscription: Subscription<any>)
	local self = setmetatable({}, SubscriptionObserver)
	self._subscription = subscription
	return self
end

function SubscriptionObserver:next(value)
	onNotify(self._subscription, "next", value)
end

function SubscriptionObserver:error(value)
	onNotify(self._subscription, "error", value)
end

function SubscriptionObserver:complete()
	onNotify(self._subscription, "complete")
end

type ObservableLike<T> = {
	subscribe: (self: ObservableLike<T>) -> (Subscriber<T> | nil)?,
}
-- ROBLOX FIXME: this is a workaround for the 'recursive type with different args' error, remove this once that's fixed
type _Observable<T> = {
	subscribe: (self: _Observable<T>, observer: Observer<T>) -> Subscription<T>,
	map: (self: _Observable<T>, fn: ((value: T) -> R_)) -> any,
	forEach: (self: _Observable<T>, fn: (value: T, cancel: (() -> ())?) -> ...any) -> Promise<nil>,
	flatMap: (self: _Observable<T>, callback: (value: T) -> ObservableLike<R_>) -> any,
	concat: (self: _Observable<T>, ...any) -> any,
	reduce: (
		self: _Observable<T>,
		callback: (previousValue: R_, currentValue: T) -> R_,
		initialValue: R_?
	) -> any,
	filter: (self: _Observable<T>, callback: (value: T) -> boolean) -> any,
}
export type Observable<T> = {
	subscribe: (self: Observable<T>, observer: Observer<T>) -> Subscription<T>,
	-- ROBLOX TODO: function generics: map<R>(callback: (value: T) => R): Observable<R>
	map: (self: Observable<T>, fn: ((value: T) -> R_)) -> _Observable<R_>,
	forEach: (self: Observable<T>, fn: (value: T, cancel: (() -> ())?) -> ...any) -> Promise<nil>,
	-- ROBLOX TODO: function generics: flatMap<R>(callback: (value: T) => ZenObservable.ObservableLike<R>): Observable<R>;
	flatMap: (self: Observable<T>, callback: (value: T) -> ObservableLike<R_>) -> _Observable<R_>,
	-- ROBLOX TODO: function generics: concat<R>(...observable: Array<Observable<R>>): Observable<R>;
	concat: (self: Observable<T>, ..._Observable<R_>) -> _Observable<R_>,
	-- ROBLOX TODO: function generics: reduce<R>(callback: (previousValue: R, currentValue: T) => R, initialValue?: R): Observable<R>;
	reduce: (
		self: Observable<T>,
		callback: (previousValue: R_, currentValue: T) -> R_,
		initialValue: R_?
	) -> _Observable<R_>,
	-- ROBLOX TODO: function generics:  filter<S extends T>(callback: (value: T) => value is S): Observable<S>;
	filter: (self: Observable<T>, callback: (value: T) -> boolean) -> _Observable<S_>,
}

Observable = {}
Observable.__index = Observable

-- ROBLOX deviation: adding this method to allow overriding the class of static methods
function isObservableClass(obj: any)
	return typeof(obj) == "table"
		and obj[SymbolObservable] == Observable[SymbolObservable]
		and typeof(rawget(obj, "new")) == "function"
end

function Observable.new(subscriber)
	local self = setmetatable({}, Observable)

	if not instanceOf(self, Observable) then
		error("Observable cannot be called as a function")
	end

	--ROBLOX deviation: check for function and callable tables
	if not isCallable(subscriber) then
		error("Observable initializer must be a function")
	end

	self._subscriber = subscriber

	return self
end

function Observable:subscribe(observer, error_, complete)
	if typeof(observer) ~= "table" or observer == nil then
		observer = { next = observer, error = error_, complete = complete }
	end

	local subscription = Subscription.new(observer, self._subscriber)
	return subscription
end

function Observable:forEach(fn: (value: any, cancel: (() -> ())?) -> ...any)
	return Promise.new(function(resolve, reject)
		--ROBLOX deviation: check for function and callable tables
		if not isCallable(fn) then
			--ROBLOX deviation: using Error instead of TypeError
			reject(Error.new(tostring(fn) .. " is not a function"))
			return
		end

		--ROBLOX deviation: predefine variable
		local subscription
		local function done()
			subscription:unsubscribe()
			resolve()
		end

		subscription = self:subscribe({
			next = function(_self, value)
				local ok, result = pcall(function()
					fn(value, done)
				end)

				if not ok then
					reject(result)
					subscription:unsubscribe()
				end
			end,
			error = function(_self, e)
				reject(e)
			end,
			complete = function(_self)
				resolve()
			end,
		})
	end)
end

-- ROBLOX TODO: function generics: map<R>(callback: (value: T) => R): Observable<R>
function Observable:map(fn: (value: T_) -> R_): Observable<R_>
	--ROBLOX deviation: check for function and callable tables
	if not isCallable(fn) then
		--ROBLOX deviation: using Error instead of TypeError
		error(Error.new(tostring(fn) .. " is not a function"))
	end

	local C = getSpecies(self)

	return C.new(function(observer)
		return self:subscribe({
			next = function(_self, value)
				--[[ ROBLOX COMMENT: try-catch block conversion ]]
				local ok, result = pcall(function()
					value = fn(value)
				end)
				if not ok then
					return observer:error(result)
				end
				observer:next(value)
				return nil
			end,
			error = function(_self, e)
				observer:error(e)
			end,
			complete = function(_self)
				observer:complete()
			end,
		})
	end)
end

-- ROBLOX TODO: function generics:  filter<S extends T>(callback: (value: T) => value is S): Observable<S>;
function Observable:filter(fn: (value: T_) -> boolean): Observable<S_>
	--ROBLOX deviation: check for function and callable tables
	if not isCallable(fn) then
		--ROBLOX deviation: using Error instead of TypeError
		error(Error.new(tostring(fn) .. " is not a function"))
	end

	local C = getSpecies(self)

	return C.new(function(observer)
		return self:subscribe({
			next = function(_self, value)
				--[[ ROBLOX COMMENT: try-catch block conversion ]]
				local _ok, result, hasReturned = xpcall(function()
					if not Boolean.toJSBoolean(fn(value)) then
						return nil, true
					end
					return nil
				end, function(e)
					return observer:error(e), true
				end)
				if hasReturned then
					return result
				end
				observer:next(value)
				return nil
			end,
			error = function(_self, e)
				observer:error(e)
			end,
			complete = function(_self)
				observer:complete()
			end,
		})
	end)
end

-- ROBLOX TODO: function generics: reduce<R>(callback: (previousValue: R, currentValue: T) => R, initialValue?: R): Observable<R>;
function Observable:reduce(
	fn: (previousValue: R_, currentValue: T_) -> R_,
	... --[[ROBLOX deviation: upstream uses 'arguments' to check for seed]]
): Observable<R_>
	local arguments = { fn, ... }
	--ROBLOX deviation: check for function and callable tables
	if not isCallable(fn) then
		--ROBLOX deviation: using Error instead of TypeError
		error(Error.new(tostring(fn) .. " is not a function"))
	end

	local C = getSpecies(self)

	local hasSeed = #arguments > 1
	local hasValue = false
	local seed = arguments[2]
	local acc = seed
	return C.new(function(observer)
		return self:subscribe({
			next = function(_self, value)
				local first = not hasValue
				hasValue = true
				if not first or hasSeed then
					--[[ ROBLOX COMMENT: try-catch block conversion ]]
					local _ok, result, hasReturned = xpcall(function()
						acc = fn(acc, value)
					end, function(e)
						return observer:error(e), true
					end)
					if hasReturned then
						return result
					end
				else
					acc = value
				end
				return nil
			end,
			error = function(_self, e)
				observer:error(e)
			end,
			complete = function(_self)
				if not hasValue and not hasSeed then
					--ROBLOX deviation: using Error instead of TypeError
					return observer:error(Error.new("Cannot reduce an empty sequence"))
				end
				observer:next(acc)
				observer:complete()
				return nil
			end,
		})
	end)
end

-- ROBLOX TODO: function generics: concat<R>(...observable: Array<Observable<R>>): Observable<R>;
function Observable:concat(...: Observable<R_>): Observable<R_>
	local sources = { ... }

	local C = getSpecies(self)

	return C.new(function(observer)
		local subscription
		local index = 1 -- [[ ROBLOX deviation: index starts from 1 in Lua]]
		local function startNext(next)
			subscription = next:subscribe({
				next = function(_self, v)
					observer:next(v)
				end,
				error = function(_self, e)
					observer:error(e)
				end,
				complete = function(_self)
					if
						index == #sources + 1 --[[ ROBLOX deviation, index starts at 1]]
					then
						subscription = nil
						observer:complete()
					else
						startNext(C.from(sources[(function()
							local result = index
							index += 1
							return result
						end)()]))
					end
				end,
			})
		end

		startNext(self)

		return function()
			if Boolean.toJSBoolean(subscription) then
				subscription:unsubscribe()
				subscription = nil
			end
		end
	end)
end

-- ROBLOX TODO: function generics: flatMap<R>(callback: (value: T) => ZenObservable.ObservableLike<R>): Observable<R>;
function Observable:flatMap(fn: (value: T_) -> ObservableLike<R_>): Observable<R_>
	-- ROBLOX deviation: predefine variable
	local completeIfDone
	--ROBLOX deviation: check for function and callable tables
	if not isCallable(fn) then
		--ROBLOX deviation: using Error instead of TypeError
		error(Error.new(tostring(fn) .. " is not a function"))
	end

	local C = getSpecies(self)

	return C.new(function(observer)
		local subscriptions = {}
		local outer = self:subscribe({
			next = function(_self, value)
				if Boolean.toJSBoolean(fn) then
					--[[ ROBLOX COMMENT: try-catch block conversion ]]
					local _ok, result, hasReturned = xpcall(function()
						value = fn(value)
					end, function(e)
						return observer:error(e), true
					end)
					if hasReturned then
						return result
					end
				end

				local inner
				inner = C.from(value):subscribe({
					next = function(__self, value)
						observer:next(value)
					end,
					error = function(__self, e)
						observer:error(e)
					end,
					complete = function(__self)
						local i = Array.indexOf(subscriptions, inner)
						if
							i >= 1 --[[ ROBLOX deviation: index start from 1 in Lua ]]
						then
							Array.splice(subscriptions, i, 1)
						end
						completeIfDone()
					end,
				})

				table.insert(subscriptions, inner)
				return nil
			end,
			error = function(_self, e)
				observer:error(e)
			end,
			complete = function(_self)
				completeIfDone()
			end,
		})

		function completeIfDone()
			if outer.closed and #subscriptions == 0 then
				observer:complete()
			end
		end

		return function()
			Array.forEach(subscriptions, function(s)
				return s:unsubscribe()
			end)
			outer:unsubscribe()
		end
	end)
end

Observable[SymbolObservable] = function(self)
	return self
end

--ROBLOX TODO: function generics: from<R>(observable: Observable<R> | ZenObservable.ObservableLike<R> | ArrayLike<R>): Observable<R>;
function Observable.from(C_, x_: Object?): Observable<R_>
	local C, x
	if isObservableClass(C_) then
		C = C_
		x = x_
	else
		C = Observable
		x = C_
	end

	if x == nil then
		--ROBLOX deviation: using Error instead of TypeError
		error(Error.new(tostring(x) .. " is not an object"))
	end

	local method = getMethod(x, SymbolObservable)
	if method then
		local observable = method(x)

		--   if (Object(observable) ~= observable) then
		-- 	--ROBLOX deviation: using Error instead of TypeError
		-- 	error(Error.new(tostring(observable) .. " is not an object"));
		--   end

		if isObservable(observable) and observable.new == C.new then
			return observable
		end

		return C.new(function(observer)
			return observable:subscribe(observer)
		end)
	end

	-- 	if (hasSymbol('iterator')) {
	-- 	  method = getMethod(x, SymbolIterator);
	-- 	  if (method) {
	-- 		return new C(observer => {
	-- 		  enqueue(() => {
	-- 			if (observer.closed) return;
	-- 			for (let item of method.call(x)) {
	-- 			  observer.next(item);
	-- 			  if (observer.closed) return;
	-- 			}
	-- 			observer.complete();
	-- 		  });
	-- 		});
	-- 	  }
	-- 	}

	if Array.isArray(x) then
		return Observable.new(function(observer)
			enqueue(function()
				if observer.closed then
					return
				end
				for _, item in pairs(x) do
					observer:next(item)
					if observer.closed then
						return
					end
				end

				observer:complete()
			end)
		end)
	end

	--ROBLOX deviation: using Error instead of TypeError
	error(Error.new(tostring(x) .. " is not observable"))
end

-- ROBLOX TODO: function generics: of<R>(...items: R[]): Observable<R>;
function Observable.of(C_, ...: R_): Observable<R_>
	local C, items
	if isObservableClass(C_) then
		C = C_
		items = { ... }
	else
		C = Observable
		items = { C_, ... }
	end

	return C.new(function(observer)
		enqueue(function()
			if observer.closed then
				return
			end
			for _, item in ipairs(items) do
				observer:next(item)
				if observer.closed then
					return
				end
			end
			observer:complete()
		end)
	end)
end

--     static get [SymbolSpecies]() { return this }

--   } ]]

if hasSymbols() then
	Observable[Symbol("extensions")] = {
		symbol = SymbolObservable,
		hostReportError = hostReportError,
	}
end

return { Observable = Observable }
