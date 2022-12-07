//
//  StringHolder+CoreDataProperties.swift
//  
//
//  Created by Radiance Okuzor on 12/6/22.
//
//

import Foundation
import CoreData


extension StringHolder {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StringHolder> {
        return NSFetchRequest<StringHolder>(entityName: "StringHolder")
    }

    @NSManaged public var string: String?
    @NSManaged public var book: CoreBook?

}
