#!/usr/bin/env swift -enable-bare-slash-regex

import Foundation
import Darwin

guard let input = try? String(contentsOf:URL(filePath: "input.txt"), encoding: .utf8) else { 
    print("No input")
    exit(0)
}

func hash(string: String.SubSequence) -> Int {
    return hash(string: String(string))
}

func hash(string: String) -> Int {
    var value = 0
    for (_, c) in string.enumerated() {
        value += Int(c.asciiValue!)
        value *= 17
        value %= 256
    }

    return value
}

let sum = input.split(separator: ",").reduce(0, { $0 + hash(string: $1) })
print("Sum: \(sum)")

struct Lens: CustomStringConvertible, Equatable {
    let label: String 
    let focalLength: Int

    var description: String {
        "\(label) \(focalLength)"
    }

    static func ==(lhs: Lens, rhs: Lens) -> Bool {
        return lhs.focalLength == rhs.focalLength && lhs.label == rhs.label
    }
}

struct Box: CustomStringConvertible {
    var lenses: [Lens] = []
    let index: Int

    init(index: Int) {
        self.index = index
    }

    mutating func performLensOperation(_ operation: String, label: String, focalLength: Int) {
        // print("\(operation) \(label) \(focalLength)")
        if operation == "-" {
            for (i, lens) in lenses.enumerated() {
                if lens.label == label {
                    lenses.remove(at: i)
                    return
                }
            }
        }
        else if operation == "=" {
            let lens = Lens(label: label, focalLength: focalLength)
            if let existingIndex = lenses.firstIndex(where: { $0.label == label }) {
                lenses.remove(at: existingIndex)
                lenses.insert(lens, at: existingIndex)
            }
            else {
                lenses.append(lens)
            }
        }
        else {
            fatalError()
        }
    }

    func focusingPowerOfLens(_ lens: Lens) -> Int {
        (index+1) * (lenses.firstIndex(where: { $0 == lens })!+1) * lens.focalLength
    }

    var focusingPower: Int {
        lenses.reduce(0, { $0 + self.focusingPowerOfLens($1) })
    }

    var description: String {
        "\(index)(\(lenses.map({ $0.description }).joined(separator: "|")))"
    }
}

var boxes: [Box] = (0..<256).map { Box(index: $0) }
let pattern = /(.+)([-|=])(\d)?/

for element in input.split(separator: ",").map({ String($0) }) {
    if let data = try? pattern.wholeMatch(in: element) {
        let boxIndex = hash(string: data.output.1)
        let label = String(data.output.1)
        let op = String(data.output.2)
        let focalLength = Int(data.output.3 ?? "0")!
        boxes[boxIndex].performLensOperation(String(op), label: String(label), focalLength: focalLength)
    }
}

var focusingPower: [String:Int] = [:]
for box in boxes {
    for lens in box.lenses {
        if focusingPower[lens.label] == nil {
            focusingPower[lens.label] = box.focusingPowerOfLens(lens)
        }
        else {
            focusingPower[lens.label] = focusingPower[lens.label]! * box.focusingPowerOfLens(lens)
        }
    }
}

print("Focusing power: \(focusingPower.values.reduce(0, { $0 + $1 }))")



