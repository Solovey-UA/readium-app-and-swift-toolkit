//
//  Copyright 2022 Readium Foundation. All rights reserved.
//  Use of this source code is governed by the BSD-style license
//  available in the top-level LICENSE file of the project.
//

import Foundation

extension NSRegularExpression {
    
    public convenience init(_ pattern: String, options: NSRegularExpression.Options = []) {
        do {
            try self.init(pattern: pattern, options: options)
        } catch {
            preconditionFailure("Illegal regular expression: \(pattern).")
        }
    }

    public func matches(in text: String) -> [NSTextCheckingResult] {
        let range = NSRange(text.startIndex..., in: text)
        return matches(in: text, range: range)
    }

    public func matchesGroups(in text: String) -> [[String]] {
        matches(in: text).map { $0.groups(in: text) }
    }
}

extension NSTextCheckingResult {

    public func range(in text: String) -> Range<String.Index>? {
        range.range(in: text)
    }
    
    public func groups(in text: String) -> [String] {
        return (0..<numberOfRanges).compactMap { i in
            guard let range = range(at: i).range(in: text) else {
                return nil
            }
            return String(text[range])
        }
    }
}

extension NSRange {
    public func range(in text: String) -> Range<String.Index>? {
        guard location != NSNotFound else {
            return nil
        }
        return Range(self, in: text)
    }
}

public final class ReplacingRegularExpression: NSRegularExpression {
    
    public typealias Replace = (NSTextCheckingResult, [String]) -> String
    
    private let replace: Replace
    
    public init(_ pattern: String, replace: @escaping Replace) {
        do {
            self.replace = replace
            try super.init(pattern: pattern)
        } catch {
            preconditionFailure("Illegal regular expression: \(pattern).")
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func replacementString(for result: NSTextCheckingResult, in string: String, offset: Int, template templ: String) -> String {
        return replace(result, result.groups(in: string))
    }
    
    public func stringByReplacingMatches(in string: String, options: NSRegularExpression.MatchingOptions = []) -> String {
        let range = NSRange(string.startIndex..., in: string)
        return stringByReplacingMatches(in: string, options: options, range: range, withTemplate: "")
    }
}
