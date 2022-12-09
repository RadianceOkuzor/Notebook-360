//
//  CorePage+CoreDataProperties.swift
//  
//
//  Created by Radiance Okuzor on 12/6/22.
//
//

import Foundation
import CoreData


extension CorePage {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CorePage> {
        return NSFetchRequest<CorePage>(entityName: "CorePage")
    }

    @NSManaged public var authorId: String?
    @NSManaged public var dateCreated: Date?
    @NSManaged public var dateEdited: Date?
    @NSManaged public var drawing: Data?
    @NSManaged public var id: String?
    @NSManaged public var notes: String?
    @NSManaged public var pageType: String?
    @NSManaged public var title: String?
    @NSManaged public var book: CoreBook?

}
