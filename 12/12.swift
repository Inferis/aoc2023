import Foundation
import Darwin

guard let input = try? String(contentsOf:URL(filePath: "input.txt"), encoding: .utf8) else { 
    print("No input")
    exit(0)
}

struct Record {
    let data: String 
    let control: [Int]

    private init(data: String, control: [Int]) {
        self.data = data
        self.control = control
    }

    init(input: String) {
        let parts = input.split(separator: " ")
        data = String(parts[0])
        control = String(parts[1]).split(separator: ",").map { Int(String($0))! }
    }

    func isValid() -> Bool {
        return runs == control
    }

    var numExpected: Int {
        control.reduce(0, { $0 + $1 })
    }

    var numSet: Int {
        data.filter({ $0 == "#" }).count
    }

    var numTargeted: Int {
        data.filter({ $0 == "?" }).count
    }

    var runs: [Int] {
        runs(data: data)
    }

    func runs(data: String) -> [Int] {
        var runs: [Int] = []

        var lastRun = (index: -1, count: 0)
        for (i, d) in data.enumerated() {
            if d == "#" {
                if (lastRun.index < 0) {
                    lastRun.index = i
                }
                lastRun.count += 1                 
            }
            else if (lastRun.index >= 0) {
                runs.append(lastRun.count)
                lastRun = (index: -1, count: 0)
            }
        }   
        if (lastRun.index >= 0) {
            runs.append(lastRun.count)
        }
        return runs
    }

    func numArrangements() -> Int {
        print("Checking: {\(data)} \(control)")
        var count = 0
        enumeratePositions({ positions in
            if verify(positions: positions) { count += 1 }
        })
        print(" -> \(count)")
        return count
    }

    func verify(positions: [Int]) -> Bool {
        var index = 0
        var result = data

        for (i, d) in data.enumerated() {       
            if d == "?" {
                let value = positions[index] == 1 ? "#" : "."
                result = result.prefix(i) + value + result.dropFirst(i + 1)
                index += 1
            }
            if (index >= positions.count) {
                break
            }
        }

        // print("\"\(result)\" \(control)")
        return runs(data: result) == control
    }

    private func generate(needed: Int, targeted: Int, depth: Int = 0, first: Bool = true) -> [[Int]] {
        // if depth > needed {
        //     print(depth, needed, targeted)
        //     return []
        // }
        var list: [[Int]] = []
        if (targeted > 1) {
            for i in 0..<2 {
                var subList = generate(needed: needed, targeted: targeted-1, depth: depth+1, first: false)
                subList = subList.map { [i] + $0 }
                list.append(contentsOf: subList)
            }
        }
        else {
            return (0..<2).map{ [$0] }        
        }

        if first {
            list = list.filter({ $0.filter({ $0 == 1 }).count == needed })
        }

        return list
    }

    func enumeratePositions(_ handler: ([Int]) -> ()) {
        let needed = numExpected - numSet
        let generated = generate(needed: needed, targeted: numTargeted)
        for positions in generated  {
            handler(positions)
        }
    }

    func expand() -> Record {
        let data = String(repeating: data, count: 5)
        var control: [Int] = []
        for _ in 0..<5 {
            control.append(contentsOf: self.control)
        }
        return Record(data: data, control: control)
    }
}

var records = input.split(separator: "\n")
    .map({ Record(input: String($0)) })

// part 1
let numArrangements = records
    .reduce(0, { $0 + $1.numArrangements() })
print("Total: \(numArrangements)")

let expandedNumArrangements = records
    .map({ $0.expand() })
    .reduce(0, { $0 + $1.numArrangements() })
print("Expanded Total: \(numArrangements)")