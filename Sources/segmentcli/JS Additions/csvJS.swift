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

class CSVJS: JavascriptClass, JSConvertible {
    internal let csv: CSV?
    
    static var className = "CSV"
    
    static var staticProperties = [String: JavascriptProperty]()
    static var staticMethods = [String: JavascriptMethod]()
    var instanceProperties: [String: JavascriptProperty] = [
        "rows": JavascriptProperty(get: { weakSelf, this in
            guard let self = weakSelf as? CSVJS else { return nil }
            return self.csv?.namedRows.count
        })
    ]
    
    var instanceMethods: [String : JavascriptMethod] = [
        "value": JavascriptMethod { weakSelf, this, params in
            guard let self = weakSelf as? CSVJS else { return nil }
            guard let row = params[0]?.typed(Int.self) else { return nil }
            guard let columnName = params[1]?.typed(String.self) else { return nil }
            let result = self.csv?.namedRows[row][columnName]
            return result
        }
    ]
    
    public required init(context: JSContext, params: JSConvertible?...) throws {
        guard let csvPath = params[0]?.typed(String.self) else { throw "Unable to load specified CSV file." }
        let delimiter = params[1]?.typed(String.self) ?? "|"
        let loadColumns = params[2]?.typed(Bool.self) ?? true

        let url = URL(fileURLWithPath: csvPath)
        self.csv = try CSV(url: url, delimiter: delimiter.first ?? "|", encoding: .utf8, loadColumns: loadColumns)
    }

}
