import Foundation
import Darwin

guard let input = try? String(contentsOf:URL(filePath: "input.txt"), encoding: .utf8) else { 
    print("No input")
    exit(0)
}

// let values = input
//     .split(separator: "\n")
//     .flatMap({ $0.enumerated() })
//     .map({ Int(String($0.element)) ?? 0 })
//     // .reduce(0, { $0 + $1 })
// print(values)

var stringDigits = ["zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine"]
var valueDigits = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]

var sum = 0
for inputLine in input.split(separator: "\n") {
    let line = " \(inputLine) "

    var transformedLine = String(line)
    var numbers: [Int] = []
    for index in line.indices {
        if let number = Int(line[index...index]) {
            print("N \(number)")
            numbers.append(number)
        }
        else {
            for digit in stringDigits { 
                let lineRange = index..<line.endIndex
                // print("<> \(line.distance(from: line.startIndex, to: index)) -- \(line[lineRange])")
                if let digitRange = line.range(of: digit, options: .anchored, range: lineRange, locale: nil) {
                    let stringDigit = transformedLine.substring(with: digitRange.lowerBound..<digitRange.upperBound)
                        // print("> \(stringDigit)")
                    if let digitIndex = stringDigits.firstIndex(of: stringDigit) {
                        print("SN \(stringDigit)")
                        numbers.append(valueDigits[digitIndex])
                    }
                }
            }
        }
    }

    let first = numbers.first?.description ?? ""
    let last = numbers.last?.description ?? ""
    if let total = Int(first + last) {
        sum += total
        print("\(line) -> [\(first)..\(last)] \(total)")     
    }
    // repeat {
    //     var indices: [Range<String.Index>] = []
    //     for digit in stringDigits { 
    //         if let lb = transformedLine.range(of: digit)?.lowerBound, 
    //            let ub = transformedLine.range(of: digit)?.upperBound {
    //             let sub: String? = transformedLine.substring(with: lb..<ub)
    //             let i = transformedLine.distance(from: transformedLine.startIndex, to: lb)
    //             print("* \(sub) found \(i)")
    //         }
    //     }

    //     if let stringDigitRange = indices.sorted(by: { $0.lowerBound < $1.lowerBound }).first {
    //         let stringDigit = transformedLine[stringDigitRange]
    //         if let valueDigitIndex = stringDigits.firstIndex(of: String(stringDigit)) {
    //             let valueDigit = valueDigits[valueDigitIndex]            
    //             transformedLine = String(transformedLine.replacingOccurrences(of: stringDigit, with: valueDigit, options: .literal, range: nil))
    //             // print(transformedLine)
    //         }
    //         else {
    //             break
    //         }
    //     }
    //     else {
    //         break
    //     }
    // } while true

    // for digit in digits {
    //     transformedLine = String(transformedLine.replacingOccurrences(of: digit.key, with: digit.value, options: .literal, range: nil))
    // }

    // for char in transformedLine.enumerated() {
    //     let value = String(char.element)
    //     if Int(value) != nil {
    //         if first == nil {
    //             first = value
    //         }
    //         last = value
    //     }
    // } 

    // let total =  (first ?? "") + (last ?? "")
    // if let total = Int(total) {
    //     sum += total
    // }
    // print("\(line) -> \(transformedLine) -> \(total)")     
}

print("==============")
print(sum)
