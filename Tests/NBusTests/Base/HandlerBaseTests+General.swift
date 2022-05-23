//
//  HandlerBaseTests+General.swift
//  BusTests
//
//  Created by nuomi1 on 2022/4/10.
//  Copyright © 2022 nuomi1. All rights reserved.
//

import Foundation

// MARK: - General - UniversalLink - Request

extension GeneralUniversalLinkRequestTestCase {

    /// Extract url using JSON
    func extract_JSON_ul(queryItems: inout [URLQueryItem], key: String) -> [String: Any] {
        let item = queryItems.removeFirst { $0.name == key }!

        let data = Data(base64Encoded: item.value!)!
        let dictionary = try! JSONSerialization.jsonObject(with: data) as! [String: Any]

        return dictionary
    }
}

// MARK: - General - Pasteboard - Request

extension GeneralPasteboardRequestTestCase {

    /// Extract pasteboard using KeyedArchiver
    func extract_KeyedArchiver_pb(items: inout [[String: Data]], key: String) -> [String: Any] {
        let item = items.removeFirst { $0.keys.contains(key) }!

        precondition(item.count == 1)

        let data = item[key]!
        let dictionary = NSKeyedUnarchiver.unarchiveObject(with: data) as! [String: Any]

        return dictionary
    }

    /// Extract pasteboard using PropertyList
    func extract_PropertyList_pb(items: inout [[String: Data]], key: String) -> [String: Any] {
        let item = items.removeFirst { $0.keys.contains(key) }!

        precondition(item.count == 1)

        let data = item[key]!
        let dictionary = try! PropertyListSerialization.propertyList(from: data, format: nil) as! [String: Any]

        return dictionary
    }
}
