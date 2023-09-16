
//////////////////////////////////////////////////////////////////////////////////
//
//  SYMBIOSE
//  Copyright 2021 Symbiose Technologies, Inc
//  All Rights Reserved.
//
//  NOTICE: This software is proprietary information.
//  Unauthorized use is prohibited.
//
// Fractal
// Created by: Ryan Mckinney on 2/11/23
//
////////////////////////////////////////////////////////////////////////////////

import Foundation

//Resource: https://www.swiftbysundell.com/articles/caching-in-swift/

class SymAttributedStringCache {
    
    static let shared = SymAttributedStringCache()
    
    var attrStrCache = SymMemoryCache<CachedInlinesAttributedStringKey, AttributedString>(
        itemsShouldExpire: false,
        cacheMaxItems: 500)
    
}

struct CachedInlinesAttributedStringKey: Hashable {
    var inlineNodes: [InlineNode]
    var attributes: AttributeContainer
}



final class SymMemoryCache<Key: Hashable, Value> {
    private let wrapped: NSCache<WrappedKey, Entry>
    private let dateProvider: () -> Date
    private let entryLifetime: TimeInterval

    let itemsShouldExpire: Bool
    
    let itemMaxCount: Int?
    
    init(itemsShouldExpire: Bool,
         cacheMaxItems: Int? = nil,
         dateProvider: @escaping () -> Date = Date.init,
         entryLifetime: TimeInterval = 12 * 60 * 60) {
        self.itemsShouldExpire = itemsShouldExpire
        self.itemMaxCount = cacheMaxItems
        self.dateProvider = dateProvider
        self.entryLifetime = entryLifetime
        let cache = NSCache<WrappedKey, Entry>()
        if let maxItems = cacheMaxItems {
            cache.countLimit = maxItems
        }
        self.wrapped = cache
    }
    
    
    func insert(_ value: Value, forKey key: Key) {
        if self.itemsShouldExpire {
            let date = dateProvider().addingTimeInterval(entryLifetime)
            let entry = Entry(value: value, expirationDate: date)
            wrapped.setObject(entry, forKey: WrappedKey(key))
        } else {
            let entry = Entry(value: value, expirationDate: nil)
            wrapped.setObject(entry, forKey: WrappedKey(key))
        }
        
        //print the current size of the NSCache in Mb
//        debugMemorySize(self.wrapped, name: "MemoryCache: ")
    }
    func removeValue(forKey key: Key) {
        wrapped.removeObject(forKey: WrappedKey(key))
    }

    func value(forKey key: Key) -> Value? {
        guard let entry = wrapped.object(forKey: WrappedKey(key)) else {
            return nil
        }

        if self.itemsShouldExpire {
            guard let expireDate = entry.expirationDate,
                    dateProvider() < expireDate else {
                // Discard values that have expired
                removeValue(forKey: key)
                return nil
            }
            
            return entry.value
        } else {
            return entry.value
        }
    }
    
    
}

private extension SymMemoryCache {
    
    final class Entry {
        let value: Value
        let expirationDate: Date?

        init(value: Value, expirationDate: Date?) {
            self.value = value
            self.expirationDate = expirationDate
        }
    }
}




private extension SymMemoryCache {
    final class WrappedKey: NSObject {
        let key: Key

        init(_ key: Key) { self.key = key }

        override var hash: Int { return key.hashValue }

        override func isEqual(_ object: Any?) -> Bool {
            guard let value = object as? WrappedKey else {
                return false
            }

            return value.key == key
        }
    }
}

extension SymMemoryCache {
    subscript(key: Key) -> Value? {
        get { return value(forKey: key) }
        set {
            guard let value = newValue else {
                // If nil was assigned using our subscript,
                // then we remove any value for that key:
                removeValue(forKey: key)
                return
            }

            insert(value, forKey: key)
        }
    }
}
