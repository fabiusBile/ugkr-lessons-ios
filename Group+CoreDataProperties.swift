//
//  Group+CoreDataProperties.swift
//  lessons
//
//  Created by Fabius Bile on 15.03.17.
//  Copyright © 2017 Fabius Bile. All rights reserved.
//

import Foundation
import CoreData


extension Group {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Group> {
        return NSFetchRequest<Group>(entityName: "Group");
    }
 

    
    @NSManaged public var name: String?
    @NSManaged public var code: String?
    @NSManaged public var isGroup: Bool
    @NSManaged public var favourite: Bool

}
