//
//  AES256CryptoServiceProvider.swift
//
//  Created by Kobayashi Ryo on 2015/08/17.
//
//

import Foundation

/** AES256Cryptoサービス. */
public struct AES256CryptoServiceProvider : CryptoService {

    //適切なキーを設定する. このキーはサーバと共有する. セキュアに保存したい(ハードコーディングは避けたい.)
    /// このキーのMD5ハッシュを使用して暗号化/復号化する.
    static let KEY = "key"

    /// Base64Cryptサービス.
    let base64: Base64CryptoServiceProvider
    /// MS5ハッシュアルゴリズム.
    let md5HashAlgorithm: HashAlgorithm

    /**
        イニシャライザ.
    */
    public init(base64: Base64CryptoServiceProvider = Base64CryptoServiceProvider(), md5HashAlgorithm: HashAlgorithm = MD5HashCryptoServiceProvider()) {
        self.base64 = base64
        self.md5HashAlgorithm = md5HashAlgorithm
    }

    /**
        AES256で暗号化する.

        :param: message 文字列.
        :returns 暗号化済み文字列.
    */
    public func encrypt(message: String) -> String? {
        if let data = message.data(using: String.Encoding.utf8, allowLossyConversion: false),
           let cryptData = encrypt(data),
           let base64EncryptString = base64.encode(cryptData) {
                Logger.d("base64EncryptString = \(base64EncryptString)")
                return base64EncryptString
        }
        return .none
    }

    /**
        AES256で暗号化する.

        :param: data NSData
        :returns 暗号化済みNSData.
    */
    public func encrypt(data: Data) -> Data? {
        return crypt(data, operation: UInt32(kCCEncrypt))
    }

    /**
        AES256で復号化する.

        :param: encryptedMessage 文字列.
        :returns 復号化済み文字列.
    */
    public func decrypt(encryptedMessage: String) -> String? {
        if let base64DecryptData = base64.decode(encryptedMessage),
           let decryptData = decrypt(base64DecryptData) {
                let decryptString = NSString(data: decryptData, encoding: String.Encoding.utf8) as? String
                print("decryptString = \(decryptString)")
                return decryptString
        }
        return nil
    }

    /**
        AES256で復号化する.

        :param: encryptedData NSData.
        :returns 復号化済みNSData.
    */
    public func decrypt(encryptedData: NSData) -> NSData? {
        return crypt(encryptedData, operation: UInt32(kCCDecrypt))
    }

    /**
        暗号化または復号化処理を行う.
    
        :param: data 処理対象データ.
        :param: operation　UInt32(kCCEncrypt)またはUInt32(kCCDecrypt).
        :returns 処理済みNSData.
    */
    func crypt(data: Data, operation: CCOperation) -> Data? {
        if let keyData = computeHashedKeyData(AES256CryptoServiceProvider.KEY),
           let cryptData = NSMutableData(length: data.count + kCCBlockSizeAES128) {

                let algorithm: CCAlgorithm = UInt32(kCCAlgorithmAES128)
                let options: CCOptions = UInt32(kCCOptionECBMode + kCCOptionPKCS7Padding)
                let keyBytes = UnsafePointer<UInt8>((keyData as NSData).bytes)
                let keyLength = size_t(kCCKeySizeAES256)
                let dataBytes = UnsafePointer<UInt8>((data as NSData).bytes)
                let dataLength = size_t(data.count)
                let cryptPointer = UnsafeMutablePointer<UInt8>(cryptData.mutableBytes)
                let cryptLength = size_t(cryptData.length)

                Logger.d("\(keyData.count), keyData = \(keyData)")
                Logger.d("\(dataLength), data = \(data)")

                var numBytesCrypted: size_t = 0
                let cryptStatus: CCCryptorStatus = CCCrypt(
                    operation,
                    algorithm,
                    options,
                    keyBytes,
                    keyLength,
                    nil,
                    dataBytes,
                    dataLength,
                    cryptPointer,
                    cryptLength,
                    &numBytesCrypted
                )

                switch cryptStatus {
                case Int32(kCCSuccess):
                    cryptData.length = numBytesCrypted
                    Logger.d("cryptLength = \(numBytesCrypted), cryptData = \(cryptData)")
                    return cryptData as Data
                case Int32(kCCParamError):
                    Logger.d("Error: ParamError")
                case Int32(kCCBufferTooSmall):
                    Logger.d("Error: BufferToSmall")
                case Int32(kCCMemoryFailure):
                    Logger.d("Error: MemoryFailure")
                case Int32(kCCAlignmentError):
                    Logger.d("Error: AlignmentError")
                case Int32(kCCDecodeError):
                    Logger.d("Error: DecodeError")
                case Int32(kCCUnimplemented):
                    Logger.d("Error: Unimplemented")
                case Int32(kCCOverflow):
                    Logger.d("Error: Overflow")
                case Int32(kCCRNGFailure):
                    Logger.d("Error: RNGFailure")
                default:
                    Logger.d("Error: \(cryptStatus)")
                }
                return .none
        }
        return .none
    }

    /**
        keyのハッシュ値を計算し, NSDataを取得する.

        :param: key キー
        :returns: NSData キーのハッシュ値. ハッシュ値の計算に失敗した場合はnil.
    */
    func computeHashedKeyData(_ key: String) -> Data? {
        if let hash = md5HashAlgorithm.computeHash(AES256CryptoServiceProvider.KEY) {
            return (hash as NSString).data(using: String.Encoding.utf8, allowLossyConversion: false)
        }
        return .none
    }
}
