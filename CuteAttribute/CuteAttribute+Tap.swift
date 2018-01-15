//
//  CuteAttribute+Tap.swift
//  CuteAttribute
//
//  Created by vsccw on 2017/10/8.
//  Copyright © 2017年 https://vsccw.com. All rights reserved.
//

import UIKit

public enum CuteAttributeTapType {
    case link
    case phoneNumber
    case custom(CuteAttributeTapCustom) // Regex or other string.
}

public enum CuteAttributeTapCustom {
    case regex(String)
    case origin(String)
}

extension CuteAttribute where Base: NSMutableAttributedString {
    
    /// Set tap action for `UILabel`.
    ///
    /// - Parameter type: CuteAttributeTapType without default value.
    /// - Returns: self
    public func tap(_ type: CuteAttributeTapType) -> CuteAttribute<Base> {
        switch type {
        case .link:
            self.tapRanges = rangesFrom(checkingType: .link)
        case .phoneNumber:
            self.tapRanges = rangesFrom(checkingType: .phoneNumber)
        case .custom(let tapCustom):
            switch tapCustom {
            case .origin(let originString):
                self.tapRanges = rangeFrom(string: originString)
            case .regex(let regexString):
                self.tapRanges = rangesFrom(regex: regexString)
            }
        }
        return self
    }
    
    
    //TODO: add highlighted state
    public func highlight(_ highlight: CuteHighlight) -> CuteAttribute<Base> {
        self.labelHighlight = highlight
        return self
    }
    
    internal func rangesFrom(checkingType: NSTextCheckingResult.CheckingType) -> [NSRange] {
        do {
            let dataHelper = try DataDetectorHelper(types: checkingType.rawValue)
            return dataHelper.matches(string: base.string)
        }
        catch {
            return []
        }
    }
    
    internal func rangeFrom(string str: String) -> [NSRange] {
        var range = base.string.range(substring: str)
        var tapRanges: [NSRange] = []
        assert(range.location != NSNotFound, "Substring must be in string.")
        tapRanges.append(range)
        repeat {
            let location = range.location + range.length
            let length = base.string.length - location
            let allRange = NSMakeRange(location, length)
            range = base.string.range(substring: str, options: [], range: allRange)
            if range.length == 0 || range.location == NSNotFound {
                break
            }
            tapRanges.append(range)
        } while true
        return tapRanges
    }
    
    internal func rangesFrom(regex re: String) -> [NSRange] {
        do {
            let regex = try RegexHelper(pattern: re)
            return regex.matchs(input: base.string)
        }
        catch {
            return []
        }
    }
    
    internal var tapRanges: [NSRange] {
        get {
            let value = (objc_getAssociatedObject(base, CuteAttributeKey.tapRangesKey) as? Box<[NSRange]>)?.value
            return value ?? []
        }
        set {
            objc_setAssociatedObject(base, CuteAttributeKey.tapRangesKey, Box(newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    internal var labelHighlight: CuteHighlight? {
        get {
            return (objc_getAssociatedObject(base, CuteAttributeKey.highlightKey) as? Box<CuteHighlight?>)?.value
        }
        
        set {
            objc_setAssociatedObject(base, CuteAttributeKey.highlightKey, Box(newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
