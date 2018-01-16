/* Copyright 2017 The Octadero Authors. All Rights Reserved.
 Created by Volodymyr Pavliukevych on 2017.
 
 Licensed under the Apache License 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 https://github.com/Octadero/MemoryLayoutKit/blob/master/LICENSE
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

import Foundation
import Dispatch

/// A thread-safe array.
public class SynchronizedArray<Element> {
     let queue = DispatchQueue(label: "com.octadero.SynchronizedArray", qos: .userInteractive, attributes: .concurrent)
    fileprivate var array = [Element]()
    
    public init() {}
    
    public var elements: [Element] {
        var value = [Element]()
        queue.sync(flags: .barrier) {
            value = array
        }
        return value
    }
}

// MARK: - Properties
public extension SynchronizedArray {
    
    /// The first element of the collection.
    var first: Element? {
        var result: Element?
        queue.sync { result = self.array.first }
        return result
    }
    
    /// The last element of the collection.
    var last: Element? {
        var result: Element?
        queue.sync { result = self.array.last }
        return result
    }
    
    /// The number of elements in the array.
    var count: Int {
        var result = 0
        queue.sync { result = self.array.count }
        return result
    }
    
    /// A Boolean value indicating whether the collection is empty.
    var isEmpty: Bool {
        var result = false
        queue.sync { result = self.array.isEmpty }
        return result
    }
    
    /// A textual representation of the array and its elements.
    var description: String {
        var result = ""
        queue.sync { result = self.array.description }
        return result
    }
}

// MARK: - Immutable
public extension SynchronizedArray {
    /// Returns the first element of the sequence that satisfies the given predicate or nil if no such element is found.
    ///
    /// - Parameter predicate: A closure that takes an element of the sequence as its argument and returns a Boolean value indicating whether the element is a match.
    /// - Returns: The first match or nil if there was no match.
    func first(where predicate: (Element) -> Bool) -> Element? {
        var result: Element?
        queue.sync { result = self.array.first(where: predicate) }
        return result
    }
    
    /// Returns an array containing, in order, the elements of the sequence that satisfy the given predicate.
    ///
    /// - Parameter isIncluded: A closure that takes an element of the sequence as its argument and returns a Boolean value indicating whether the element should be included in the returned array.
    /// - Returns: An array of the elements that includeElement allowed.
    func syncFilter(_ isIncluded: (Element) -> Bool) -> [Element] {
        var result = [Element]()
        queue.sync { result = self.array.filter(isIncluded) }
        return result
    }
    
    /// Returns the first index in which an element of the collection satisfies the given predicate.
    ///
    /// - Parameter predicate: A closure that takes an element as its argument and returns a Boolean value that indicates whether the passed element represents a match.
    /// - Returns: The index of the first element for which predicate returns true. If no elements in the collection satisfy the given predicate, returns nil.
    func index(where predicate: (Element) -> Bool) -> Int? {
        var result: Int?
        queue.sync { result = self.array.index(where: predicate) }
        return result
    }
    
    /// Returns the elements of the collection, sorted using the given predicate as the comparison between elements.
    ///
    /// - Parameter areInIncreasingOrder: A predicate that returns true if its first argument should be ordered before its second argument; otherwise, false.
    /// - Returns: A sorted array of the collection’s elements.
    func sorted(by areInIncreasingOrder: (Element, Element) -> Bool) -> [Element] {
        var result = [Element]()
        queue.sync { result = self.array.sorted(by: areInIncreasingOrder) }
        return result
    }
    
    /// Returns an array containing the non-nil results of calling the given transformation with each element of this sequence.
    ///
    /// - Parameter transform: A closure that accepts an element of this sequence as its argument and returns an optional value.
    /// - Returns: An array of the non-nil results of calling transform with each element of the sequence.
    func flatMap<ElementOfResult>(_ transform: (Element) -> ElementOfResult?) -> [ElementOfResult] {
        var result = [ElementOfResult]()
        queue.sync { result = self.array.flatMap(transform) }
        return result
    }
    
    /// Calls the given closure on each element in the sequence in the same order as a for-in loop.
    ///
    /// - Parameter body: A closure that takes an element of the sequence as a parameter.
    func forEach(_ body: (Element) -> Void) {
        queue.sync { self.array.forEach(body) }
    }
    
    /// Returns a Boolean value indicating whether the sequence contains an element that satisfies the given predicate.
    ///
    /// - Parameter predicate: A closure that takes an element of the sequence as its argument and returns a Boolean value that indicates whether the passed element represents a match.
    /// - Returns: true if the sequence contains an element that satisfies predicate; otherwise, false.
    func contains(where predicate: (Element) -> Bool) -> Bool {
        var result = false
        queue.sync { result = self.array.contains(where: predicate) }
        return result
    }
}

// MARK: - Mutable
public extension SynchronizedArray {
    
    /// Adds a new element at the end of the array.
    ///
    /// - Parameter element: The element to append to the array.
    func append( _ element: Element) {
        queue.async(flags: .barrier) {
            self.array.append(element)
        }
    }
    
    /// Adds a new element at the end of the array.
    ///
    /// - Parameter element: The element to append to the array.
    func append(_ elements: [Element]) {
        queue.async(flags: .barrier) {
            self.array += elements
        }
    }
    
    public func append<S>(contentsOf newElements: S) where S : Sequence, S.Iterator.Element == Element {
        queue.async(flags: .barrier) {
            self.array.append(contentsOf: newElements)
        }
    }
    
    /// Inserts a new element at the specified position.
    ///
    /// - Parameters:
    ///   - element: The new element to insert into the array.
    ///   - index: The position at which to insert the new element.
    func insert( _ element: Element, at index: Int) {
        queue.async(flags: .barrier) {
            self.array.insert(element, at: index)
        }
    }
    
    /// Removes and returns the element at the specified position.
    ///
    /// - Parameters:
    ///   - index: The position of the element to remove.
    ///   - completion: The handler with the removed element.
    func remove(at index: Int, completion: @escaping ((Element?) -> Void)) {
        queue.async(flags: .barrier) {
            guard self.array.count > index else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            let element = self.array.remove(at: index)
            
            DispatchQueue.main.async {
                completion(element)
            }
        }
    }
    
    func remove(at index: Int) -> Element? {
        var result: Element?
        queue.sync(flags: .barrier) {
            guard self.array.count > index else {
                return
            }
            result = self.array.remove(at: index)
        }
        return result
    }
    
    /// Removes and returns the element at the specified position.
    ///
    /// - Parameters:
    ///   - predicate: A closure that takes an element of the sequence as its argument and returns a Boolean value indicating whether the element is a match.
    ///   - completion: The handler with the removed element.
    func remove(where predicate: @escaping (Element) -> Bool, completion: @escaping ((Element) -> Void)) {
        queue.async(flags: .barrier) {
            guard let index = self.array.index(where: predicate) else { return }
            let element = self.array.remove(at: index)
            
            DispatchQueue.main.async {
                completion(element)
            }
        }
    }
    
    /// Removes all elements from the array.
    ///
    /// - Parameter completion: The handler with the removed elements.
    func removeAll(completion: @escaping (([Element]) -> Void)) {
        queue.async(flags: .barrier) {
            let elements = self.array
            self.array.removeAll()
            
            DispatchQueue.main.async {
                completion(elements)
            }
        }
    }
    
    func removeAll() {
        queue.sync(flags: .barrier) {
            self.array.removeAll()
        }
    }
}

extension SynchronizedArray : Sequence {
    
    public typealias Iterator = IndexingIterator<Array<Element>>
    public typealias SubSequence = ArraySlice<Element>
    
    public func makeIterator() -> SynchronizedArray.Iterator {
        var result : SynchronizedArray.Iterator?
        queue.sync(flags: .barrier) {
            result = self.array.makeIterator()
        }
        return result!
    }
    
    public var underestimatedCount: Int {
        var result: Int = 0
        queue.async(flags: .barrier) {
            result = self.array.underestimatedCount
        }
        return result
    }
    
    public func map<T>(_ transform: (SynchronizedArray.Iterator.Element) throws -> T) rethrows -> [T]{
        var result = [T]()
        try queue.sync(flags: .barrier) {
            result = try self.array.map(transform)
        }
        return result
    }
    
    public func filter(_ isIncluded: @escaping (SynchronizedArray.Iterator.Element) throws -> Bool) rethrows -> [SynchronizedArray.Iterator.Element] {
        var result: [SynchronizedArray.Iterator.Element]?
        try queue.sync(flags: .barrier) {
            result = try array.filter(isIncluded)
        }
        return result!
    }
    
    public func forEach(_ body: (SynchronizedArray.Iterator.Element) throws -> Swift.Void) rethrows {
        try queue.sync(flags: .barrier) {
            try array.forEach(body)
        }
    }
    
    public func dropFirst(_ n: Int) -> SynchronizedArray.SubSequence {
        var result: SynchronizedArray.SubSequence?
        queue.sync(flags: .barrier) {
            result = array.dropFirst(n)
        }
        return result!
    }
    
    public func dropLast(_ n: Int) -> SynchronizedArray.SubSequence {
        var result: SynchronizedArray.SubSequence?
        queue.sync(flags: .barrier) {
            result = array.dropLast(n)
        }
        return result!
    }
    
    public func drop(while predicate: (SynchronizedArray.Iterator.Element) throws -> Bool) rethrows -> SynchronizedArray.SubSequence {
        var result: SynchronizedArray.SubSequence?
        try queue.sync(flags: .barrier) {
            result = try array.drop(while: predicate)
        }
        return result!
    }
    
    public func prefix(_ maxLength: Int) -> SynchronizedArray.SubSequence {
        var result: SynchronizedArray.SubSequence?
        queue.sync(flags: .barrier) {
            result = array.prefix(maxLength)
        }
        return result!
    }
    
    public func prefix(while predicate: (SynchronizedArray.Iterator.Element) throws -> Bool) rethrows -> SynchronizedArray.SubSequence {
        var result: SynchronizedArray.SubSequence?
        try queue.sync(flags: .barrier) {
            result = try array.prefix(while: predicate)
        }
        return result!
    }
    
    public func suffix(_ maxLength: Int) -> SynchronizedArray.SubSequence {
        var result: SynchronizedArray.SubSequence?
        queue.sync(flags: .barrier) {
            result = array.suffix(maxLength)
        }
        return result!
    }
    public func split(maxSplits: Int, omittingEmptySubsequences: Bool, whereSeparator isSeparator: (SynchronizedArray.Iterator.Element) throws -> Bool) rethrows -> [SynchronizedArray.SubSequence] {
        var result: [SynchronizedArray.SubSequence]?
        try queue.sync(flags: .barrier) {
            result = try array.split(maxSplits: maxSplits, omittingEmptySubsequences: omittingEmptySubsequences, whereSeparator: isSeparator)
        }
        return result!
    }
    
}

// MARK: - Equatable
public extension SynchronizedArray where Element: Equatable {
    
    /// Returns a Boolean value indicating whether the sequence contains the given element.
    ///
    /// - Parameter element: The element to find in the sequence.
    /// - Returns: true if the element was found in the sequence; otherwise, false.
    func contains(_ element: Element) -> Bool {
        var result = false
        queue.sync { result = self.array.contains(element) }
        return result
    }
}

public extension SynchronizedArray where Element == String {
    func joined(separator: String) -> String {
        var result = ""
        queue.async(flags: .barrier) {
            result = self.array.joined(separator: separator)
        }
        return result
    }
}

public extension SynchronizedArray {
    
    func removeSubrange(_ bounds: ClosedRange<SynchronizedArray.Index>) {
        queue.async(flags: .barrier) {
            self.array.removeSubrange(bounds)
        }
    }
    
    func removeSubrange(_ bounds: CountableRange<SynchronizedArray.Index>) {
        queue.async(flags: .barrier) {
            self.array.removeSubrange(bounds)
        }
    }
}

extension SynchronizedArray: Collection {
    public typealias Index = Array<Element>.Index
    
    public subscript(bounds: Range<Array<Element>.Index>) -> ArraySlice<Element> {
        var result: ArraySlice<Element>?
        queue.sync(flags: .barrier) {
            result = self.array[bounds]
        }
        return result!
    }
    
    public subscript(index: Int) -> Element {
        get {
            var result: Element?
            queue.sync {
                guard self.array.startIndex..<self.array.endIndex ~= index else { return }
                result = self.array[index]
            }
            return result!
        }
        set {
            queue.async(flags: .barrier) {
                self.array[index] = newValue
            }
        }
    }
    
    public var startIndex: Index {
        var result: Index?
        queue.sync(flags: .barrier) {
            result = self.array.startIndex
        }
        return result!
    }
    
    public var endIndex: Index {
        var result: Index?
        queue.sync(flags: .barrier) {
            result = self.array.endIndex
        }
        return result!
    }
    
    public func index(after i: Index) -> Index {
        var result: Index?
        queue.sync(flags: .barrier) {
            result = array.index(after: i)
        }
        return result!
    }
}

// MARK: - Infix operators
public extension SynchronizedArray {
    
    static func +=(left: inout SynchronizedArray, right: Element) {
        left.append(right)
    }
    
    static func +=(left: inout SynchronizedArray, right: [Element]) {
        left.append(right)
    }
}
