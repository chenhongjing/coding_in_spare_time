//
//  ToDoListItem+CoreDataProperties.swift
//  ToDoList
//
//
//

import Foundation
import CoreData


extension ToDoListItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ToDoListItem> {
        return NSFetchRequest<ToDoListItem>(entityName: "ToDoListItem")
    }

    @NSManaged public var name: String?
    @NSManaged public var date: Date?

}

extension ToDoListItem : Identifiable {

}
