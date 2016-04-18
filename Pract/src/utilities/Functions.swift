//
//  Functions.swift
//  Pract
//
//  Created by 小林涼 on 2016/04/18.
//  Copyright © 2016年 ShuSyuSh. All rights reserved.
//

import Foundation


func delay(seconds: Double, block: () -> ()) {
    let time = dispatch_time(DISPATCH_TIME_NOW, Int64(seconds * Double(NSEC_PER_SEC)))
    dispatch_after(time,dispatch_get_main_queue(), block)
}