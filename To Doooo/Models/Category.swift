//
//  Category.swift
//  To Doooo
//
//  Created by Fahim Shahriar on 17/8/20.
//  Copyright © 2020 Fahim Shahriar. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var bcColor: String = ""
    let items = List<Item>()
}
