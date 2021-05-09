//
//  DateExtension.swift
//  ExpencesApp
//
//  Created by Justyna Bucko on 09/05/2021.
//

import Foundation
import UIKit



extension Date {
    func asString() -> String {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "MM-dd-yyyy HH:mm"
        return dateFormater.string(from: self)
    }
}
