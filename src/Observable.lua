local function hasSymbols()
	return typeof(Symbol) == "function"
end
local function hasSymbol(name)
	return --[[ ROBLOX TODO: Unhandled node for type: LogicalExpression ]]
	--[[ hasSymbols() && Boolean(Symbol[name]) ]]
end
local function getSymbol(name)
	return --[[ ROBLOX TODO: Unhandled node for type: ConditionalExpression ]]
	--[[ hasSymbol(name) ? Symbol[name] : '@@' + name ]]
end
--[[ ROBLOX TODO: Unhandled node for type: IfStatement ]]
--[[ if (hasSymbols() && !hasSymbol('observable')) {
  Symbol.observable = Symbol('observable');
} ]]
local SymbolIterator = getSymbol("iterator")
local SymbolObservable = getSymbol("observable")
local SymbolSpecies = getSymbol("species")
local function getMethod(obj, key)
	local value = obj[tostring(key)]
	--[[ ROBLOX TODO: Unhandled node for type: IfStatement ]]
	--[[ if (value == null)
    return undefined; ]]
	--[[ ROBLOX TODO: Unhandled node for type: IfStatement ]]
	--[[ if (typeof value !== 'function')
    throw new TypeError(value + ' is not a function'); ]]
	return value
end
local function getSpecies(obj)
	local ctor = obj.constructor
	--[[ ROBLOX TODO: Unhandled node for type: IfStatement ]]
	--[[ if (ctor !== undefined) {
    ctor = ctor[SymbolSpecies];
    if (ctor === null) {
      ctor = undefined;
    }
  } ]]
	return --[[ ROBLOX TODO: Unhandled node for type: ConditionalExpression ]]
	--[[ ctor !== undefined ? ctor : Observable ]]
end
local function isObservable(x)
	return --[[ ROBLOX TODO: Unhandled node for type: BinaryExpression ]]
	--[[ x instanceof Observable ]]
end
local function hostReportError(e)
	--[[ ROBLOX TODO: Unhandled node for type: IfStatement ]]
	--[[ if (hostReportError.log) {
    hostReportError.log(e);
  } else {
    setTimeout(() => { throw e });
  } ]]
end
local function enqueue(fn)
	Promise:resolve():then_(function()
		--[[ ROBLOX TODO: Unhandled node for type: TryStatement ]]
		--[[ try { fn() }
    catch (e) { hostReportError(e) } ]]
	end)
end
local function cleanupSubscription(subscription)
	local cleanup = subscription._cleanup
	--[[ ROBLOX TODO: Unhandled node for type: IfStatement ]]
	--[[ if (cleanup === undefined)
    return; ]]
	--[[ ROBLOX TODO: Unhandled node for type: AssignmentExpression ]]
	--[[ subscription._cleanup = undefined ]]
	--[[ ROBLOX TODO: Unhandled node for type: IfStatement ]]
	--[[ if (!cleanup) {
    return;
  } ]]
	--[[ ROBLOX TODO: Unhandled node for type: TryStatement ]]
	--[[ try {
    if (typeof cleanup === 'function') {
      cleanup();
    } else {
      let unsubscribe = getMethod(cleanup, 'unsubscribe');
      if (unsubscribe) {
        unsubscribe.call(cleanup);
      }
    }
  } catch (e) {
    hostReportError(e);
  } ]]
end
local function closeSubscription(subscription)
	--[[ ROBLOX TODO: Unhandled node for type: AssignmentExpression ]]
	--[[ subscription._observer = undefined ]]
	--[[ ROBLOX TODO: Unhandled node for type: AssignmentExpression ]]
	--[[ subscription._queue = undefined ]]
	--[[ ROBLOX TODO: Unhandled node for type: AssignmentExpression ]]
	--[[ subscription._state = 'closed' ]]
end
local function flushSubscription(subscription)
	local queue = subscription._queue
	--[[ ROBLOX TODO: Unhandled node for type: IfStatement ]]
	--[[ if (!queue) {
    return;
  } ]]
	--[[ ROBLOX TODO: Unhandled node for type: AssignmentExpression ]]
	--[[ subscription._queue = undefined ]]
	--[[ ROBLOX TODO: Unhandled node for type: AssignmentExpression ]]
	--[[ subscription._state = 'ready' ]]
	--[[ ROBLOX TODO: Unhandled node for type: ForStatement ]]
	--[[ for (let i = 0; i < queue.length; ++i) {
    notifySubscription(subscription, queue[i].type, queue[i].value);
    if (subscription._state === 'closed')
      break;
  } ]]
end
local function notifySubscription(subscription, type, value)
	--[[ ROBLOX TODO: Unhandled node for type: AssignmentExpression ]]
	--[[ subscription._state = 'running' ]]
	local observer = subscription._observer
	--[[ ROBLOX TODO: Unhandled node for type: TryStatement ]]
	--[[ try {
    let m = getMethod(observer, type);
    switch (type) {
      case 'next':
        if (m) m.call(observer, value);
        break;
      case 'error':
        closeSubscription(subscription);
        if (m) m.call(observer, value);
        else throw value;
        break;
      case 'complete':
        closeSubscription(subscription);
        if (m) m.call(observer);
        break;
    }
  } catch (e) {
    hostReportError(e);
  } ]]
	--[[ ROBLOX TODO: Unhandled node for type: IfStatement ]]
	--[[ if (subscription._state === 'closed')
    cleanupSubscription(subscription);
  else if (subscription._state === 'running')
    subscription._state = 'ready'; ]]
end
local function onNotify(subscription, type, value)
	--[[ ROBLOX TODO: Unhandled node for type: IfStatement ]]
	--[[ if (subscription._state === 'closed')
    return; ]]
	--[[ ROBLOX TODO: Unhandled node for type: IfStatement ]]
	--[[ if (subscription._state === 'buffering') {
    subscription._queue.push({ type, value });
    return;
  } ]]
	--[[ ROBLOX TODO: Unhandled node for type: IfStatement ]]
	--[[ if (subscription._state !== 'ready') {
    subscription._state = 'buffering';
    subscription._queue = [{ type, value }];
    enqueue(() => flushSubscription(subscription));
    return;
  } ]]
	notifySubscription(subscription, type, value)
end
--[[ ROBLOX TODO: Unhandled node for type: ClassDeclaration ]]
--[[ class Subscription {

  constructor(observer, subscriber) {
    // ASSERT: observer is an object
    // ASSERT: subscriber is callable

    this._cleanup = undefined;
    this._observer = observer;
    this._queue = undefined;
    this._state = 'initializing';

    let subscriptionObserver = new SubscriptionObserver(this);

    try {
      this._cleanup = subscriber.call(undefined, subscriptionObserver);
    } catch (e) {
      subscriptionObserver.error(e);
    }

    if (this._state === 'initializing')
      this._state = 'ready';
  }

  get closed() {
    return this._state === 'closed';
  }

  unsubscribe() {
    if (this._state !== 'closed') {
      closeSubscription(this);
      cleanupSubscription(this);
    }
  }
} ]]
--[[ ROBLOX TODO: Unhandled node for type: ClassDeclaration ]]
--[[ class SubscriptionObserver {
  constructor(subscription) { this._subscription = subscription }
  get closed() { return this._subscription._state === 'closed' }
  next(value) { onNotify(this._subscription, 'next', value) }
  error(value) { onNotify(this._subscription, 'error', value) }
  complete() { onNotify(this._subscription, 'complete') }
} ]]
--[[ ROBLOX TODO: Unhandled node for type: ExportNamedDeclaration ]]
--[[ export class Observable {

  constructor(subscriber) {
    if (!(this instanceof Observable))
      throw new TypeError('Observable cannot be called as a function');

    if (typeof subscriber !== 'function')
      throw new TypeError('Observable initializer must be a function');

    this._subscriber = subscriber;
  }

  subscribe(observer) {
    if (typeof observer !== 'object' || observer === null) {
      observer = {
        next: observer,
        error: arguments[1],
        complete: arguments[2],
      };
    }
    return new Subscription(observer, this._subscriber);
  }

  forEach(fn) {
    return new Promise((resolve, reject) => {
      if (typeof fn !== 'function') {
        reject(new TypeError(fn + ' is not a function'));
        return;
      }

      function done() {
        subscription.unsubscribe();
        resolve();
      }

      let subscription = this.subscribe({
        next(value) {
          try {
            fn(value, done);
          } catch (e) {
            reject(e);
            subscription.unsubscribe();
          }
        },
        error: reject,
        complete: resolve,
      });
    });
  }

  map(fn) {
    if (typeof fn !== 'function')
      throw new TypeError(fn + ' is not a function');

    let C = getSpecies(this);

    return new C(observer => this.subscribe({
      next(value) {
        try { value = fn(value) }
        catch (e) { return observer.error(e) }
        observer.next(value);
      },
      error(e) { observer.error(e) },
      complete() { observer.complete() },
    }));
  }

  filter(fn) {
    if (typeof fn !== 'function')
      throw new TypeError(fn + ' is not a function');

    let C = getSpecies(this);

    return new C(observer => this.subscribe({
      next(value) {
        try { if (!fn(value)) return; }
        catch (e) { return observer.error(e) }
        observer.next(value);
      },
      error(e) { observer.error(e) },
      complete() { observer.complete() },
    }));
  }

  reduce(fn) {
    if (typeof fn !== 'function')
      throw new TypeError(fn + ' is not a function');

    let C = getSpecies(this);
    let hasSeed = arguments.length > 1;
    let hasValue = false;
    let seed = arguments[1];
    let acc = seed;

    return new C(observer => this.subscribe({

      next(value) {
        let first = !hasValue;
        hasValue = true;

        if (!first || hasSeed) {
          try { acc = fn(acc, value) }
          catch (e) { return observer.error(e) }
        } else {
          acc = value;
        }
      },

      error(e) { observer.error(e) },

      complete() {
        if (!hasValue && !hasSeed)
          return observer.error(new TypeError('Cannot reduce an empty sequence'));

        observer.next(acc);
        observer.complete();
      },

    }));
  }

  concat(...sources) {
    let C = getSpecies(this);

    return new C(observer => {
      let subscription;
      let index = 0;

      function startNext(next) {
        subscription = next.subscribe({
          next(v) { observer.next(v) },
          error(e) { observer.error(e) },
          complete() {
            if (index === sources.length) {
              subscription = undefined;
              observer.complete();
            } else {
              startNext(C.from(sources[index++]));
            }
          },
        });
      }

      startNext(this);

      return () => {
        if (subscription) {
          subscription.unsubscribe();
          subscription = undefined;
        }
      };
    });
  }

  flatMap(fn) {
    if (typeof fn !== 'function')
      throw new TypeError(fn + ' is not a function');

    let C = getSpecies(this);

    return new C(observer => {
      let subscriptions = [];

      let outer = this.subscribe({
        next(value) {
          if (fn) {
            try { value = fn(value) }
            catch (e) { return observer.error(e) }
          }

          let inner = C.from(value).subscribe({
            next(value) { observer.next(value) },
            error(e) { observer.error(e) },
            complete() {
              let i = subscriptions.indexOf(inner);
              if (i >= 0) subscriptions.splice(i, 1);
              completeIfDone();
            },
          });

          subscriptions.push(inner);
        },
        error(e) { observer.error(e) },
        complete() { completeIfDone() },
      });

      function completeIfDone() {
        if (outer.closed && subscriptions.length === 0)
          observer.complete();
      }

      return () => {
        subscriptions.forEach(s => s.unsubscribe());
        outer.unsubscribe();
      };
    });
  }

  [SymbolObservable]() { return this }

  static from(x) {
    let C = typeof this === 'function' ? this : Observable;

    if (x == null)
      throw new TypeError(x + ' is not an object');

    let method = getMethod(x, SymbolObservable);
    if (method) {
      let observable = method.call(x);

      if (Object(observable) !== observable)
        throw new TypeError(observable + ' is not an object');

      if (isObservable(observable) && observable.constructor === C)
        return observable;

      return new C(observer => observable.subscribe(observer));
    }

    if (hasSymbol('iterator')) {
      method = getMethod(x, SymbolIterator);
      if (method) {
        return new C(observer => {
          enqueue(() => {
            if (observer.closed) return;
            for (let item of method.call(x)) {
              observer.next(item);
              if (observer.closed) return;
            }
            observer.complete();
          });
        });
      }
    }

    if (Array.isArray(x)) {
      return new C(observer => {
        enqueue(() => {
          if (observer.closed) return;
          for (let i = 0; i < x.length; ++i) {
            observer.next(x[i]);
            if (observer.closed) return;
          }
          observer.complete();
        });
      });
    }

    throw new TypeError(x + ' is not observable');
  }

  static of(...items) {
    let C = typeof this === 'function' ? this : Observable;

    return new C(observer => {
      enqueue(() => {
        if (observer.closed) return;
        for (let i = 0; i < items.length; ++i) {
          observer.next(items[i]);
          if (observer.closed) return;
        }
        observer.complete();
      });
    });
  }

  static get [SymbolSpecies]() { return this }

} ]]
--[[ ROBLOX TODO: Unhandled node for type: IfStatement ]]
--[[ if (hasSymbols()) {
  Object.defineProperty(Observable, Symbol('extensions'), {
    value: {
      symbol: SymbolObservable,
      hostReportError,
    },
    configurable: true,
  });
} ]]
