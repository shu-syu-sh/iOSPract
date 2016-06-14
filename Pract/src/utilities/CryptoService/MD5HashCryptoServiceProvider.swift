//
//  MD5HashCryptoServiceProvider.swift
//
//  Created by Kobayashi Ryo on 2015/08/17.
//
//

import Foundation

// MARK: MD5HashCryptoServiceProvider

/** MD5ハッシュアルゴリズム. */
public struct MD5HashCryptoServiceProvider : HashAlgorithm {

    /**
        イニシャライザ.
    */
    public init() {
        // nop
    }
    
    /**
        ハッシュ値を計算する.

        :param: data 文字列.
        :returns: ハッシュ値.
    */
    public func computeHash(_ data: String) -> String? {
        if let str = data.cString(using: String.Encoding.utf8) {
            let strLength = CUnsignedInt(data.lengthOfBytes(using: String.Encoding.utf8))
            let digestLength = Int(CC_MD5_DIGEST_LENGTH)
            let result = UnsafeMutablePointer<CUnsignedChar>(allocatingCapacity: digestLength)

            CC_MD5(str, strLength, result)

            let hash = NSMutableString()
            for i in 0 ..< digestLength {
                hash.appendFormat("%02x", result[i])
            }

            result.deinitialize()

            return String(format: hash as String)
        }
        return .none
    }
}
