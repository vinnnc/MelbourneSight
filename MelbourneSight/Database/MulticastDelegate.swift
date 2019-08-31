//
//  MulticastDelegate.swift
//  MelbourneSight
//
//  Created by Wenchu Du on 2019/8/31.
//  Copyright © 2019 Wenchu Du. All rights reserved.
//

import Foundation

class MulticastDelegate<T> {
    private var delegates = Set<WeakObjectWrapper>()
    
    func addDelegate(_ delegate: T) {
        let delegateObject = delegate as AnyObject
        delegates.insert(WeakObjectWrapper(value: delegateObject))
    }
    
    func removeDelegate(_ delegate: T) {
        let delegateObject = delegate as AnyObject
        delegates.remove(WeakObjectWrapper(value: delegateObject))
    }
    
    func invoke(invocation: (T) -> ()) {
        delegates.forEach { (delegateWrapper) in
            if let delegate = delegateWrapper.value {
                invocation(delegate as! T)
            }
        }
    }
}

private class WeakObjectWrapper: Equatable, Hashable {
    weak var value: AnyObject?
    
    init(value: AnyObject) {
        self.value = value
    }
    
    // Hash based on the address (pointer) of the value.
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(value!).hashValue)
    }
    
    // Equate based on equality of the value pointers of two wrappers.
    static func == (lhs: WeakObjectWrapper, rhs: WeakObjectWrapper) -> Bool {
        return lhs.value === rhs.value
    }
}
