//
//  LoggerProtocol.swift
//  SecurityKeyBLE
//
//  Created by Benjamin P Toews on 9/13/16.
//  Copyright © 2016 GitHub. All rights reserved.
//

import Foundation

protocol LoggerProtocol {
    func log(msg: String)
    func warn(msg: String)
    func debug(msg: String)
}

extension LoggerProtocol {
    func log(msg: String)   { print(msg) }
    func warn(msg: String)  { print(msg) }
    func debug(msg: String) { print(msg) }
}

class PrintLogger: LoggerProtocol {}