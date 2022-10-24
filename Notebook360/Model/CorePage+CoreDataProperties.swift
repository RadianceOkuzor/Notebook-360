//
//  CorePage+CoreDataProperties.swift
//  
//
//  Created by Radiance Okuzor on 10/22/22.
//
//

import Foundation
import CoreData


extension CorePage {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CorePage> {
        return NSFetchRequest<CorePage>(entityName: "CorePage")
    }

    @NSManaged public var pageType: String?
    @NSManaged public var title: String?
    @NSManaged public var id: String?
    @NSManaged public var dateCreated: Date?
    @NSManaged public var dateEdited: Date?
    @NSManaged public var notes: String?
    @NSManaged public var drawing: Data?
    @NSManaged public var authorId: String?
    @NSManaged public var book: CoreBook?

}
