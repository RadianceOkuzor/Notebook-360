//
//  CoreBook+CoreDataProperties.swift
//  
//
//  Created by Radiance Okuzor on 10/22/22.
//
//

import Foundation
import CoreData


extension CoreBook {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoreBook> {
        return NSFetchRequest<CoreBook>(entityName: "CoreBook")
    }

    @NSManaged public var title: String?
    @NSManaged public var color: String?
    @NSManaged public var id: String?
    @NSManaged public var pages: NSSet?

}

// MARK: Generated accessors for pages
extension CoreBook {

    @objc(addPagesObject:)
    @NSManaged public func addToPages(_ value: CorePage)

    @objc(removePagesObject:)
    @NSManaged public func removeFromPages(_ value: CorePage)

    @objc(addPages:)
    @NSManaged public func addToPages(_ values: NSSet)

    @objc(removePages:)
    @NSManaged public func removeFromPages(_ values: NSSet)

}
