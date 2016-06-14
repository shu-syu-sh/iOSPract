//
//  CryptoService.swift
//
//  Created by Kobayashi Ryo on 2015/07/23.
//
//

import Foundation

/** CryptoService. */
public protocol CryptoService {

    /**
        暗号化する.
    
        :param: message 文字列.
        :returns 暗号化済み文字列.
    */
    func encrypt(_ message: String) -> String?

    /**
        暗号化する.
    
        :param: data NSData.
        :returns 暗号化済みNSData.
    */
    func encrypt(_ data: Data) -> Data?

    /**
        復号化する.

        :param: encryptedMessage 暗号化された文字列.
        :returns 復号化済み文字列.
    */
    func decrypt(_ encryptedMessage: String) -> String?

    /**
        復号化する.
    
        :param: encryptedData 暗号化されたNSData.
        :returns 復号化済みNSData.
    */
    func decrypt(_ encryptedData: Data) -> Data?
}
