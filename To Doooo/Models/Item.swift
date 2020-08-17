//
//  Item.swift
//  To Doooo
//
//  Created by Fahim Shahriar on 17/8/20.
//  Copyright © 2020 Fahim Shahriar. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var dateCreated: Date?
    let parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
