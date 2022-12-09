//
//  CoreBook+CoreDataProperties.swift
//  
//
//  Created by Radiance Okuzor on 12/6/22.
//
//

import Foundation
import CoreData


extension CoreBook {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoreBook> {
        return NSFetchRequest<CoreBook>(entityName: "CoreBook")
    }

    @NSManaged public var color: String?
    @NSManaged public var id: String?
    @NSManaged public var title: String?
    @NSManaged public var pages: NSSet?
    @NSManaged public var bookIds: NSSet?

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

// MARK: Generated accessors for bookIds
extension CoreBook {

    @objc(addBookIdsObject:)
    @NSManaged public func addToBookIds(_ value: StringHolder)

    @objc(removeBookIdsObject:)
    @NSManaged public func removeFromBookIds(_ value: StringHolder)

    @objc(addBookIds:)
    @NSManaged public func addToBookIds(_ values: NSSet)

    @objc(removeBookIds:)
    @NSManaged public func removeFromBookIds(_ values: NSSet)

}
