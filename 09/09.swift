import Foundation
import Darwin

guard let input = try? String(contentsOf:URL(filePath: "input.txt"), encoding: .utf8) else { 
    print("No input")
    exit(0)
}

let lines = input.split(separator: "\n")
let allValues = lines.map({ String($0).split(separator: " ").map({ Int(String($0))! }) })

var beginResult = 0, endResult = 0
for values in allValues {
    var valueLines = [values] 
    var currentLine = values
    while (!currentLine.allSatisfy({ $0 == 0 })) {
        var nextLine: [Int] = []
        var prevValue = currentLine.first!
        for value in currentLine[1..<currentLine.count] {
            nextLine.append(value-prevValue)
            prevValue = value
        }
        currentLine = nextLine
        valueLines.append(nextLine)
    }

    var beginIncrement = 0, endIncrement = 0
    for i in (0..<valueLines.count-1).reversed() {
        valueLines[i].append(valueLines[i].last! + endIncrement)
        valueLines[i].insert(valueLines[i].first! - beginIncrement, at: 0)
        beginIncrement = valueLines[i].first!
        endIncrement = valueLines[i].last!
    }

    let resultLine = valueLines.first!
    beginResult += resultLine.first!
    endResult += resultLine.last!
    print("\(resultLine) + \(beginResult)/\(endResult)")
}
