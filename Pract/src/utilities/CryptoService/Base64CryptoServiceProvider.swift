//
//  Base64CryptoServiceProvider.swift
//
//  Created by Kobayashi Ryo on 2015/08/17.
//
//

import Foundation

/** Base64Cryptoサービス. */
public struct Base64CryptoServiceProvider {

    /**
        イニシャライザ.
    */
    public init() {
        // nop
    }

    /**
        Base64エンコードする.

        :param: data NSData.
        :returns: Base64エンコード済み文字列.
    */
    public func encode(data: Data) -> String? {
        return data.base64EncodedString(NSData.Base64EncodingOptions())
    }

    /**
        Base64デコードする.

        :param: encodedData 文字列.
        :returns: Base64デコード済みNSData.
    */
    public func decode(encodedData: String) -> Data? {
        return Data(base64Encoded: encodedData, options: NSData.Base64DecodingOptions())
    }
}
