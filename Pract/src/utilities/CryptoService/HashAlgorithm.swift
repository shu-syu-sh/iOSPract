//
//  HashAlgorithm.swift
//
//  Created by Kobayashi Ryo on 2015/08/17.
//
//

import Foundation

/** ハッシュアルゴリズム. */
public protocol HashAlgorithm {

    /**
        ハッシュ値を計算する.

        :param: data 文字列.
        :returns: ハッシュ値.
    */
    func computeHash(_ data: String) -> String?
}
