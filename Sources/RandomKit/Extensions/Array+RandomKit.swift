//
//  Array+RandomKit.swift
//  RandomKit
//
//  The MIT License (MIT)
//
//  Copyright (c) 2015-2016 Nikolai Vazquez
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

extension Array: Shuffleable {

    /// Shuffles the elements in `self` and returns the result.
    public func shuffled() -> Array {
        return shuffled(from: startIndex, to: endIndex)
    }

    /// Shuffles the elements in `self`.
    public mutating func shuffle() {
        shuffle(from: startIndex, to: endIndex)
    }

    /// Shuffles the elements in `self` from `startIndex` to `endIndex` and returns the result.
    public func shuffled(from startIndex: Index, to endIndex: Index) -> Array {
        var copy = self
        copy.shuffle(from: startIndex, to: endIndex)
        return copy
    }

    /// Shuffles the elements in `self` from `startIndex` to `endIndex`.
    public mutating func shuffle(from startIndex: Index, to endIndex: Index) {
        let range = startIndex ..< endIndex
        for i in range {
            if let j = Int.random(within: range), j != i {
                swap(&self[i], &self[j])
            }
        }
    }

}

extension Array where Element: Random {

    /// Construct an Array of random elements.
    public init(randomCount: Int) {
        self.init(Element.randomSequence(maxCount: randomCount))
    }

}

extension Array where Element: RandomWithinClosedRange {

    /// Construct an Array of random elements from within the closed range.
    public init(randomCount: Int, within closedRange: ClosedRange<Element>) {
        self.init(Element.randomSequence(within: closedRange, maxCount: randomCount))
    }

}

extension Array {

    /// Returns an array of randomly choosen elements.
    ///
    /// If `elementCount` >= `count` a copy of this array is returned
    ///
    /// - Parameters:
    ///     - elementCount: The number of element to return
    public func randomSlice(_ elementCount: Int) -> Array {
        if elementCount <= 0  {
            return []
        }
        if elementCount >= self.count {
            return Array(self)
        }
        // Algorithm R
        // fill the reservoir array
        var result = Array(self[0..<elementCount])
        // replace elements with gradually decreasing probability
        for i in elementCount..<self.count {
            let j = Int.random(within: 0 ... i-1)
            if j < elementCount {
                result[j] = self[i]
            }
        }
        return result
    }

    /// Returns an array of `elementCount` randomly choosen elements.
    ///
    /// If `elementCount` >= `count` or `weights.count` < `count`
    /// a copy of this array is returned
    ///
    /// - Parameters:
    ///     - elementCount: The number of element to return
    ///     - weights: Apply weights on element.
    public func randomSlice(_ elementCount: Int, weights: [Double]) -> Array {
        if elementCount <= 0  {
            return []
        }
        if elementCount >= self.count || weights.count < self.count {
            return Array(self)
        }

        // Algorithm A-Chao
        var result = Array(self[0..<elementCount])
        var weightSum: Double = weights[0..<elementCount].reduce(0.0) { (total, value) in
            total + value
        }
        for i in elementCount..<self.count {
            let p = weights[i] / weightSum
            let j = Double.random(within: 0.0...1.0)
            if j <= p {
                let index = Int.random(within: 0 ... elementCount-1)
                result[index] = self[i]
            }
            weightSum += weights[i]
        }
        return result
    }

}