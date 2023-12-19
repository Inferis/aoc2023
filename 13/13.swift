#!/usr/bin/env swift

import Foundation
import Darwin

guard let input = try? String(contentsOf:URL(filePath: "input.txt"), encoding: .utf8) else { 
    print("No input")
    exit(0)
}

enum ReflectionOrientation {
    case horizontal
    case vertical
}

struct Grid: CustomStringConvertible {
    let data: [String]

    init() {
        data = []
    }

    private init(data: [String]) {
        self.data = data
    }

    private init(data sourceData: [String], line: String) {
        var sourceData = sourceData
        sourceData.append(line)
        data = sourceData
    }

    func appending(input: String) -> Grid {
        Grid(data: data, line: input)
    }

    func rotated() -> Grid {
        var rotated = Array(repeating: "", count: data[0].count) 
        for y in 0..<data.count {
            for x in 0..<data[y].count {
                let index = data[y].index(data[y].startIndex, offsetBy: x)
                rotated[x] += data[y][index...index]
            }
        }
        return Grid(data: rotated)
    }

    func findReflection(orientation: ReflectionOrientation) -> Int {
        let source = orientation == .horizontal ? data : self.rotated().data
        for y in 1..<source.count {
            let out = min(y, source.count-y)
            // print("out=\(out)")
            let found = (0..<out).allSatisfy { o in 
                // print("\(y+o) \"\(source[y+o])\" == \(y-o) \"\(source[y-o-1])\" -> \(source[y+o] == source[y-o-1])")
                return source[y+o] == source[y-o-1] 
            }
            if found {
                return y
            }
        }
        return 0
    }

    var score: Int {
        return findReflection(orientation: .horizontal) * 100
            + findReflection(orientation: .vertical)
    }

    var isEmpty: Bool { return data.count == 0 }

    var description: String {
        data.joined(separator: "\n") 
    }
}


var grids: [Grid] = []
var grid = Grid()
for line in input.split(separator: "\n", omittingEmptySubsequences: false) {
    if line.count == 0 {
        grids.append(grid)
        grid = Grid()
    }
    else {
        grid = grid.appending(input: String(line))
    }
}
if !grid.isEmpty {
    grids.append(grid)
}

// print(grids[0])
// print(grids[0].findReflection(orientation: .horizontal))
// print(grids[0].findReflection(orientation: .vertical))

// print(grids[1])
// print(grids[1].findReflection(orientation: .horizontal))
// print(grids[1].findReflection(orientation: .vertical))

var total = 0
for grid in grids {
    let score = grid.score
    total += score
    print(score)
}
print("Total: \(total)")