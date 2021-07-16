-- ROBLOX upstream https://github.com/zenparsing/zen-observable/blob/v0.8.15/src/Observable.js
local srcWorkspace = script.Parent
local rootWorkspace = srcWorkspace.Parent

local LuauPolyfill = require(rootWorkspace.Dev.LuauPolyfill)
local Promise = require(rootWorkspace.Dev.Promise)
local instanceOf = LuauPolyfill.instanceof
local Boolean = LuauPolyfill.Boolean
local setTimeout = LuauPolyfill.setTimeout

-- ROBLOX TODO: There isn't yet a need to convert the majority of this code.
--              The Apollo Client conversion only needs the Observable class,
--              the 'of' static method, and the subscribe instance method.

-- local function hasSymbols() return typeof(Symbol) == "function" end
-- local function hasSymbol(name)
--     return (function()
--         if Boolean.toJSBoolean(hasSymbols()) then
--             return Boolean(Symbol[tostring(name)])
--         else
--             return hasSymbols()
--         end
--     end)()
-- end
-- local function getSymbol(name) return error("not implemented") --[[ ROBLOX TODO: Unhandled node for type: ConditionalExpression ]] --[[ hasSymbol(name) ? Symbol[name] : '@@' + name ]] end
-- if Boolean.toJSBoolean((function()
--     if Boolean.toJSBoolean(hasSymbols()) then
--         return not Boolean.toJSBoolean(hasSymbol("observable"))
--     else
--         return hasSymbols()
--     end
-- end)()) then undefined = Symbol("observable") end
-- local SymbolIterator = getSymbol("iterator")
-- local SymbolObservable = getSymbol("observable")
-- local SymbolSpecies = getSymbol("species")

local function getMethod(obj, key)
	local value = obj[tostring(key)]
	if value == nil then
		return nil
	end
	if typeof(value) ~= "function" then
		error(tostring(value) .. " is not a function")
	end
	return value
end

-- local function getSpecies(obj)
--     local ctor = obj.constructor
--     -- if Boolean.toJSBoolean(ctor ~= nil) then ctor = ctor[tostring(SymbolSpecies)],if Boolean.toJSBoolean(ctor == nil) then ctor = nil
--     -- end
--     -- end
--     return error("not implemented") --[[ ROBLOX TODO: Unhandled node for type: ConditionalExpression ]]
--     --[[ ctor !== undefined ? ctor : Observable ]]
-- end
-- local function isObservable(x)
--     error("not implemented"); --[[ ROBLOX TODO: Unhandled node for type: BinaryExpression ]]
--     --[[ x instanceof Observable ]]
--     return error("not implemented")
-- end

-- ROBLOX upstream deviation: hostReportError.log, lua functions does not support having other properties, so using setmetatable with __call enables to suppport this
local hostReportError
hostReportError = setmetatable({}, {
	__call = function(e)
		if Boolean.toJSBoolean(hostReportError.log) then
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
		local _status, _err = pcall(function()
			fn()
		end)
		if _err ~= nil then
			hostReportError(_err)
		end
	end)
end

local function cleanupSubscription(subscription)
	local cleanup = subscription._cleanup
	if cleanup == nil then
		return
	end

	subscription._cleanup = nil

	if not Boolean.toJSBoolean(cleanup) then
		return
	end

	local ok, err = pcall(function()
		if typeof(cleanup) == "function" then
			cleanup()
		else
			local unsubscribe = getMethod(cleanup, "unsubscribe")
			if Boolean.toJSBoolean(unsubscribe) then
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

local function notifySubscription(subscription, type, value)
	subscription._state = "running"
	local observer = subscription._observer

	local ok, err = pcall(function()
		local m = getMethod(observer, type)
		if type == "next" then
			if Boolean.toJSBoolean(m) then
				m(observer, value)
			end
		elseif type == "error" then
			closeSubscription(subscription)
			if Boolean.toJSBoolean(m) then
				m(observer, value)
			else
				error(value)
			end
		elseif type == "complete" then
			if Boolean.toJSBoolean(m) then
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

local function onNotify(subscription, type, value)
	if subscription._state == "closed" then
		return
	end
	if subscription._state == "buffering" then
		subscription._queue:push({ type = type, value = value })
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

local SubscriptionObserver = {}
SubscriptionObserver.__index = SubscriptionObserver

function SubscriptionObserver.new(subscription)
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

local Subscription = {}
Subscription.__index = Subscription

function Subscription.new(observer, subscriber)
	local self = setmetatable({}, Subscription)
	-- ASSERT: observer is an object
	-- ASSERT: subscriber is callable
	self._cleanup = nil
	self._observer = observer
	self._queue = nil
	self._state = "initializing"

	local subscriptionObserver = SubscriptionObserver.new(self)

	local _status, _err = pcall(function()
		self._cleanup = subscriber(subscriptionObserver)
	end)
	if _err ~= nil then
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

-- --[[ class Subscription {

--     get closed() {
--       return this._state === 'closed';
--     }

--   } ]]
-- error("not implemented"); --[[ ROBLOX TODO: Unhandled node for type: ClassDeclaration ]]

-- --[[ class SubscriptionObserver {
--     constructor(subscription) { this._subscription = subscription }
--     get closed() { return this._subscription._state === 'closed' }
--     next(value) { onNotify(this._subscription, 'next', value) }
--     error(value) { onNotify(this._subscription, 'error', value) }
--     complete() { onNotify(this._subscription, 'complete') }
--   } ]]

local Observable = {}
Observable.__index = Observable

function Observable.new(subscriber)
	local self = setmetatable({}, Observable)

	if not Boolean.toJSBoolean(instanceOf(self, Observable)) then
		error("Observable cannot be called as a function")
	end

	if type(subscriber) ~= "function" then
		error("Observable initializer must be a function")
	end

	self._subscriber = subscriber
	return self
end

function Observable:of(...)
	local items = table.pack(...)
	local C
	if typeof(self) == "function" then
		C = self
	else
		C = Observable.new
	end
	return C(function(observer)
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

function Observable:subscribe(observer, error, complete)
	if typeof(observer) ~= "table" or observer == nil then
		observer = { next = observer, error = error, complete = complete }
	end

	local subscription = Subscription.new(observer, self._subscriber)
	return subscription
end

-- error("not implemented"); --[[ ROBLOX TODO: Unhandled node for type: ExportNamedDeclaration ]]
-- --[[ export class Observable {
--     forEach(fn) {
--       return new Promise((resolve, reject) => {
--         if (typeof fn !== 'function') {
--           reject(new TypeError(fn + ' is not a function'));
--           return;
--         }

--         function done() {
--           subscription.unsubscribe();
--           resolve();
--         }

--         let subscription = this.subscribe({
--           next(value) {
--             try {
--               fn(value, done);
--             } catch (e) {
--               reject(e);
--               subscription.unsubscribe();
--             }
--           },
--           error: reject,
--           complete: resolve,
--         });
--       });
--     }

--     map(fn) {
--       if (typeof fn !== 'function')
--         throw new TypeError(fn + ' is not a function');

--       let C = getSpecies(this);

--       return new C(observer => this.subscribe({
--         next(value) {
--           try { value = fn(value) }
--           catch (e) { return observer.error(e) }
--           observer.next(value);
--         },
--         error(e) { observer.error(e) },
--         complete() { observer.complete() },
--       }));
--     }

--     filter(fn) {
--       if (typeof fn !== 'function')
--         throw new TypeError(fn + ' is not a function');

--       let C = getSpecies(this);

--       return new C(observer => this.subscribe({
--         next(value) {
--           try { if (!fn(value)) return; }
--           catch (e) { return observer.error(e) }
--           observer.next(value);
--         },
--         error(e) { observer.error(e) },
--         complete() { observer.complete() },
--       }));
--     }

--     reduce(fn) {
--       if (typeof fn !== 'function')
--         throw new TypeError(fn + ' is not a function');

--       let C = getSpecies(this);
--       let hasSeed = arguments.length > 1;
--       let hasValue = false;
--       let seed = arguments[1];
--       let acc = seed;

--       return new C(observer => this.subscribe({

--         next(value) {
--           let first = !hasValue;
--           hasValue = true;

--           if (!first || hasSeed) {
--             try { acc = fn(acc, value) }
--             catch (e) { return observer.error(e) }
--           } else {
--             acc = value;
--           }
--         },

--         error(e) { observer.error(e) },

--         complete() {
--           if (!hasValue && !hasSeed)
--             return observer.error(new TypeError('Cannot reduce an empty sequence'));

--           observer.next(acc);
--           observer.complete();
--         },

--       }));
--     }

--     concat(...sources) {
--       let C = getSpecies(this);

--       return new C(observer => {
--         let subscription;
--         let index = 0;

--         function startNext(next) {
--           subscription = next.subscribe({
--             next(v) { observer.next(v) },
--             error(e) { observer.error(e) },
--             complete() {
--               if (index === sources.length) {
--                 subscription = undefined;
--                 observer.complete();
--               } else {
--                 startNext(C.from(sources[index++]));
--               }
--             },
--           });
--         }

--         startNext(this);

--         return () => {
--           if (subscription) {
--             subscription.unsubscribe();
--             subscription = undefined;
--           }
--         };
--       });
--     }

--     flatMap(fn) {
--       if (typeof fn !== 'function')
--         throw new TypeError(fn + ' is not a function');

--       let C = getSpecies(this);

--       return new C(observer => {
--         let subscriptions = [];

--         let outer = this.subscribe({
--           next(value) {
--             if (fn) {
--               try { value = fn(value) }
--               catch (e) { return observer.error(e) }
--             }

--             let inner = C.from(value).subscribe({
--               next(value) { observer.next(value) },
--               error(e) { observer.error(e) },
--               complete() {
--                 let i = subscriptions.indexOf(inner);
--                 if (i >= 0) subscriptions.splice(i, 1);
--                 completeIfDone();
--               },
--             });

--             subscriptions.push(inner);
--           },
--           error(e) { observer.error(e) },
--           complete() { completeIfDone() },
--         });

--         function completeIfDone() {
--           if (outer.closed && subscriptions.length === 0)
--             observer.complete();
--         }

--         return () => {
--           subscriptions.forEach(s => s.unsubscribe());
--           outer.unsubscribe();
--         };
--       });
--     }

--     [SymbolObservable]() { return this }

--     static from(x) {
--       let C = typeof this === 'function' ? this : Observable;

--       if (x == null)
--         throw new TypeError(x + ' is not an object');

--       let method = getMethod(x, SymbolObservable);
--       if (method) {
--         let observable = method.call(x);

--         if (Object(observable) !== observable)
--           throw new TypeError(observable + ' is not an object');

--         if (isObservable(observable) && observable.constructor === C)
--           return observable;

--         return new C(observer => observable.subscribe(observer));
--       }

--       if (hasSymbol('iterator')) {
--         method = getMethod(x, SymbolIterator);
--         if (method) {
--           return new C(observer => {
--             enqueue(() => {
--               if (observer.closed) return;
--               for (let item of method.call(x)) {
--                 observer.next(item);
--                 if (observer.closed) return;
--               }
--               observer.complete();
--             });
--           });
--         }
--       }

--       if (Array.isArray(x)) {
--         return new C(observer => {
--           enqueue(() => {
--             if (observer.closed) return;
--             for (let i = 0; i < x.length; ++i) {
--               observer.next(x[i]);
--               if (observer.closed) return;
--             }
--             observer.complete();
--           });
--         });
--       }

--       throw new TypeError(x + ' is not observable');
--     }

--     static get [SymbolSpecies]() { return this }

--   } ]]
-- if Boolean.toJSBoolean(hasSymbols()) then
--     Object:defineProperty(Observable, Symbol("extensions"), {
--         value = {symbol = SymbolObservable, hostReportError = hostReportError},
--         configurable = true
--     })
-- end

return { Observable = Observable }
