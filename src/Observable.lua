local rootWorkspace = script.Parent
local PackagesWorkspace = rootWorkspace.Parent

local LuauPolyfill = require(PackagesWorkspace.Dev.LuauPolyfill)
local instanceOf = LuauPolyfill.instanceof
local Boolean = LuauPolyfill.Boolean

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
-- local function getMethod(obj, key)
--     local value = obj[tostring(key)]
--     if Boolean.toJSBoolean(value == nil --[[ ROBLOX CHECK: loose equality used upstream ]] ) then
--         return nil
--     end
--     if Boolean.toJSBoolean(typeof(value) ~= "function") then
--         error("not implemented"); --[[ ROBLOX TODO: Unhandled node for type: ThrowStatement ]]
--         --[[ throw new TypeError(value + ' is not a function'); ]]
--     end
--     return value
-- end
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
-- local function hostReportError(e)
--     if Boolean.toJSBoolean(hostReportError.log) then
--         hostReportError:log(e)
--     else
--         setTimeout(
--             function() error("not implemented"); --[[ ROBLOX TODO: Unhandled node for type: ThrowStatement ]] --[[ throw e ]] end)
--     end
-- end
-- local function enqueue(fn)
--     Promise:resolve():then_(function()
--         error("not implemented"); --[[ ROBLOX TODO: Unhandled node for type: TryStatement ]]
--         --[[ try { fn() }
--       catch (e) { hostReportError(e) } ]]
--     end)
-- end
-- local function cleanupSubscription(subscription)
--     local cleanup = subscription._cleanup
--     if Boolean.toJSBoolean(cleanup == nil) then return end
--     undefined = nil
--     if not Boolean.toJSBoolean(cleanup) then return end
--     error("not implemented"); --[[ ROBLOX TODO: Unhandled node for type: TryStatement ]]
--     --[[ try {
--       if (typeof cleanup === 'function') {
--         cleanup();
--       } else {
--         let unsubscribe = getMethod(cleanup, 'unsubscribe');
--         if (unsubscribe) {
--           unsubscribe.call(cleanup);
--         }
--       }
--     } catch (e) {
--       hostReportError(e);
--     } ]]
-- end
-- local function closeSubscription(subscription)
--     undefined = nil
--     undefined = nil
--     undefined = "closed"
-- end
-- local function flushSubscription(subscription)
--     local queue = subscription._queue
--     if not Boolean.toJSBoolean(queue) then return end
--     undefined = nil
--     undefined = "ready"
--     error("not implemented"); --[[ ROBLOX TODO: Unhandled node for type: ForStatement ]]
--     --[[ for (let i = 0; i < queue.length; ++i) {
--       notifySubscription(subscription, queue[i].type, queue[i].value);
--       if (subscription._state === 'closed')
--         break;
--     } ]]
-- end
-- local function notifySubscription(subscription, type, value)
--     undefined = "running"
--     local observer = subscription._observer
--     error("not implemented"); --[[ ROBLOX TODO: Unhandled node for type: TryStatement ]]
--     --[[ try {
--       let m = getMethod(observer, type);
--       switch (type) {
--         case 'next':
--           if (m) m.call(observer, value);
--           break;
--         case 'error':
--           closeSubscription(subscription);
--           if (m) m.call(observer, value);
--           else throw value;
--           break;
--         case 'complete':
--           closeSubscription(subscription);
--           if (m) m.call(observer);
--           break;
--       }
--     } catch (e) {
--       hostReportError(e);
--     } ]]
--     if Boolean.toJSBoolean(subscription._state == "closed") then
--         cleanupSubscription(subscription)
--     elseif Boolean.toJSBoolean(subscription._state == "running") then
--         undefined = "ready"
--     end
-- end
-- local function onNotify(subscription, type, value)
--     if Boolean.toJSBoolean(subscription._state == "closed") then return end
--     -- if Boolean.toJSBoolean(subscription._state == "buffering") then subscription._queue:push({type = type, value = value}),return
--     -- end
--     -- if Boolean.toJSBoolean(subscription._state ~= "ready") then undefined = "buffering",undefined = {{type = type, value = value}},enqueue(function()
--     -- return flushSubscription(subscription)
--     -- end),return
--     -- end
--     notifySubscription(subscription, type, value)
-- end
-- error("not implemented"); --[[ ROBLOX TODO: Unhandled node for type: ClassDeclaration ]]
-- --[[ class Subscription {

--     constructor(observer, subscriber) {
--       // ASSERT: observer is an object
--       // ASSERT: subscriber is callable

--       this._cleanup = undefined;
--       this._observer = observer;
--       this._queue = undefined;
--       this._state = 'initializing';

--       let subscriptionObserver = new SubscriptionObserver(this);

--       try {
--         this._cleanup = subscriber.call(undefined, subscriptionObserver);
--       } catch (e) {
--         subscriptionObserver.error(e);
--       }

--       if (this._state === 'initializing')
--         this._state = 'ready';
--     }

--     get closed() {
--       return this._state === 'closed';
--     }

--     unsubscribe() {
--       if (this._state !== 'closed') {
--         closeSubscription(this);
--         cleanupSubscription(this);
--       }
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

-- error("not implemented"); --[[ ROBLOX TODO: Unhandled node for type: ExportNamedDeclaration ]]
-- --[[ export class Observable {

--     subscribe(observer) {
--       if (typeof observer !== 'object' || observer === null) {
--         observer = {
--           next: observer,
--           error: arguments[1],
--           complete: arguments[2],
--         };
--       }
--       return new Subscription(observer, this._subscriber);
--     }

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

--     static of(...items) {
--       let C = typeof this === 'function' ? this : Observable;

--       return new C(observer => {
--         enqueue(() => {
--           if (observer.closed) return;
--           for (let i = 0; i < items.length; ++i) {
--             observer.next(items[i]);
--             if (observer.closed) return;
--           }
--           observer.complete();
--         });
--       });
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
