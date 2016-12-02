//
//  TestEnt+CoreDataProperties.swift
//  CoredataSwift3
//
//  Created by Amrit on 12/2/16.
//  Copyright © 2016 Amrit. All rights reserved.
//

import Foundation
import CoreData


extension TestEnt {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TestEnt> {
        return NSFetchRequest<TestEnt>(entityName: "TestEnt");
    }

    @NSManaged public var name: String
    @NSManaged public var id: Int64

}
