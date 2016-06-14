//
//  KeychainService.swift
//  Pract
//
//  Created by Kobayashi Ryo on 2016/06/14.
//  Copyright © 2016年 ShuSyuSh. All rights reserved.
//

import Foundation

/** キーチェーンサービス. */
public struct KeychainService {

    /**
     イニシャライザ.
     */
    public init() {

    }

    /**
     データを指定されたキーに紐付けて格納する.

     :param: value データ
     :param: forKey キー
     :returns: true 格納成功
     */
    public func store(value: NSData, forKey key: String) -> Bool {
        let query = createQuery(forKey: key, type: QueryType.none)
        let found = queryFirst(query)
        // キーが既に存在すれば上書きする. 存在しなければ追加する.
        let succeed = found.map {
            _ -> Bool in
            let update = [ Sec.ValueData : value ] as NSDictionary
            return self.updateItem(query, update)
            }.orElse {
                () -> Bool in
                let item = self.createItem(data: value, forKey: key)
                return self.addItem(item)
        }
        return succeed
    }

    /**
     指定されたキーに紐付いたデータを取得する.

     :param: forKey キー
     :returns: データ.
     */
    public func find(forKey key: String) -> NSData? {
        let result = queryFirst(createQuery(forKey: key))
        if let value = result.value {
            return value
        }
        return .None
    }

    /**
     データを指定されたキーに紐付けて格納する.

     :param: value データ
     :param: forKey キー
     :returns: true 格納成功
     */
    public func store(value: String, forKey key: String) -> Bool {
        let data = value.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        return store(data!, forKey: key)
    }

    /**
     指定されたキーに紐付いたデータを取得する.

     :param: key キー
     :returns: データ.
     */
    public func find(key: String) -> String? {
        let result = find(forKey: key).flatMap() { NSString(data: $0, encoding: NSUTF8StringEncoding) as? String }
        return result
    }

    /**
     指定されたキーに紐付いたデータを削除する.

     :param: forKey キー.
     :returns: true 削除成功.
     */
    public func delete(forKey key: String) -> Bool {
        let query = createQuery(forKey: key, type: QueryType.none)
        let found = queryFirst(query)
        // キーが既に存在すれば削除する.
        let succeed = found.map {
            _ -> Bool in
            return self.deleteItem(query)
        }
        return succeed ?? false
    }

    /**
     アイテムを作成する.

     :param: service サービス. デフォルトはアプリのbundle identifier
     :param: key キー
     :param: data データ
     */
    public func createItem(service: String = NSBundle.mainBundle().bundleIdentifier!, data: NSData, forKey key: String) -> NSDictionary {
        return [
            Sec.Class       : Sec.ClassGenericPassword,
            Sec.AttrService : service,
            Sec.AttrAccount : key,
            Sec.ValueData   : data
            ] as NSDictionary
    }

    /**
     クエリを作成する.

     :param: service サービス. デフォルトはアプリのbundle identifier
     :param: key キー
     :param: type クエリ種別. デフォルトはQueryType.Data
     */
    public func createQuery(service: String = NSBundle.mainBundle().bundleIdentifier!, forKey key: String, type: QueryType = .data) -> NSDictionary {
        var query = [
            Sec.Class         : Sec.ClassGenericPassword,
            Sec.AttrService   : service,
            Sec.AttrAccount   : key,
            ] as [NSString: AnyObject]

        if let attributeKey = type.attributeKey {
            query[attributeKey] = kCFBooleanTrue
        }

        return query as NSDictionary
    }

    /**
     最初にヒットしたデータを取得する.

     :param: query クエリ.
     */
    public func queryFirst(query: NSDictionary) -> Result<NSData?, QueryResult> {
        var returnedData: AnyObject?
        let results = Int(SecItemCopyMatching(query, &returnedData))

        switch results {
        case Int(errSecSuccess):
            let data = returnedData as? NSData
            return Result(value: data)
        case Int(errSecItemNotFound):
            return Result(value: QueryResult.notFound)
        default:
            return Result(value: QueryResult.other)
        }
    }

    /**
     項目をキーチェーンに追加する.

     :param: item 項目.

     :returns: true 追加成功.
     */
    public func addItem(item: NSDictionary) -> Bool {
        var result: AnyObject?
        let status = Int(SecItemAdd(item, &result))

        switch status {
        case Int(errSecSuccess):
            print("Successfully stored the value")
            return true
        case Int(errSecDuplicateItem):
            print("This item is already saved. Cannot duplicate it")
            return false
        default:
            print("An error occurred with code \(status)")
            return false
        }
    }

    /**
     キーチェーンの項目を更新する.

     :param: query クエリ.
     :param: updateAttributes 更新データ.

     :returns: true 更新成功
     */
    public func updateItem(query: NSDictionary, _ updateAttributes: NSDictionary) -> Bool {
        let updated = Int(SecItemUpdate(query, updateAttributes))
        switch updated {
        case Int(errSecSuccess):
            print("Successfully updated the value")
            return true
        default:
            print("An error occurred with code \(updated)")
            return false
        }
    }

    /**
     キーチェーンの項目を削除する.

     :param: query クエリ.

     :returns: true 削除成功
     */
    public func deleteItem(query: NSDictionary) -> Bool {
        let deleted = Int(SecItemDelete(query))
        switch deleted {
        case Int(errSecSuccess):
            print("Successfully deleted the value")
            return true
        default:
            print("An error occurred with code \(deleted)")
            return false
        }
    }

    /** クエリ結果. */
    public enum QueryResult {
        /// 成功
        case success
        /// 見つからない
        case notFound
        /// その他エラー.
        case other
    }

    /** クエリ種別. */
    public enum QueryType {
        /// データ.
        case data
        /// メタ情報(作成日, 更新日, etc...).
        case attributes
        /// 追加情報なし.
        case none

        /// クエリに含める際の表現.
        public var attributeKey: NSString? {
            switch self {
            case .data:
                return Sec.ReturnData
            case .attributes:
                return Sec.ReturnAttrivutes
            case .none:
                return nil
            }
        }
    }

    /** Securityフレームワークの定数ラッパー. */
    struct Sec {
        /// Dictionary key whose value is the item's class code
        static let Class: NSString = kSecClass

        /// Generic item password
        static let ClassGenericPassword: NSString = kSecClassGenericPassword

        /// Service attributes key.
        static let AttrService: NSString = kSecAttrService

        /// Account attributes key.
        static let AttrAccount: NSString = kSecAttrAccount

        /// Data attributes key.
        static let ValueData: NSString = kSecValueData

        /// Return attributes attribute key.
        static let ReturnAttrivutes: NSString = kSecReturnAttributes

        /// Return data attribute key
        static let ReturnData: NSString = kSecReturnData
    }
}
