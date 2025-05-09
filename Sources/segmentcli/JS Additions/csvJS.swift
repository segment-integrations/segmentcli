//
//  File.swift
//  
//
//  Created by Brandon Sneed on 5/10/22.
//

import Foundation
import SwiftCSV
import Substrata

/*
@objc protocol JSCSVExports: JSExport {
    init(path: String)
    func rowCount() -> Int
    func rowValueForColumnName(_ row: Int, _ columnName: String) -> String?
}

@objc public class JSCSV: NSObject, JSCSVExports {
    let csv: CSV?
    
    required init(path: String) {
        let url = URL(fileURLWithPath: path)
        do {
            self.csv = try CSV(url: url, delimiter: "|", encoding: .utf8, loadColumns: true)
        } catch {
            self.csv = nil
            print("Error: \(error)")
        }
    }
    
    func rowCount() -> Int {
        if let csv = csv {
            return csv.namedRows.count
        }
        return 0
    }
    
    func rowValueForColumnName(_ row: Int, _ columnName: String) -> String? {
        let result = csv?.namedRows[row][columnName]
        return result
    }  
}
*/

class CSVJS: JSExport {
    internal var csv: CSV? = nil

    required init() {
        super.init()
        
        exportProperty(named: "rows") {
            guard let csv = self.csv else { throw "No CSV file loaded." }
            return csv.namedRows.count
        }
        
        exportMethod(named: "value") { args in
            guard let csv = self.csv else { throw "No CSV file loaded." }
            guard let row = args.typed(as: Int.self, index: 0) else { return nil }
            guard let columnName = args.typed(as: String.self, index: 1) else { return nil }
            return csv.namedRows[row][columnName]
        }
    }
    
    override func construct(args: [JSConvertible?]) throws {
        guard let csvPath = args.typed(as: String.self, index: 0) else { throw "Unable to load specified CSV file." }
        let delimiter = args.typed(as: String.self, index: 1) ?? "|"
        let loadColumns = args.typed(as: Bool.self, index: 2) ?? true

        let url = URL(fileURLWithPath: csvPath)
        self.csv = try CSV(url: url, delimiter: delimiter.first ?? "|", encoding: .utf8, loadColumns: loadColumns)
    }
}
