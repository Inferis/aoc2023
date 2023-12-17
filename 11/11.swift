import Foundation
import Darwin

guard let input = try? String(contentsOf:URL(filePath: "input2.txt"), encoding: .utf8) else { 
    print("No input")
    exit(0)
}

struct Coord: CustomStringConvertible {
    let x: Int
    let y: Int

    var description: String {
        "{\(x),\(y)}"
    }
}

class Map: CustomStringConvertible {
    var space: [[String]]
    var galaxies: [Coord] = []
    var expansions: (rows: [Int], columns: [Int]) = (rows: [], columns: [])
    var expansionFactor: Int

    init(input: String, expansionFactor factor: Int) {
        space = input.split(separator: "\n").map({ String($0).split(separator: "").map({ String($0) }) })
        expansionFactor = factor
        calculateExpansions()
        detectGalaxies()
    }

    var description: String {
        space.map({ $0.joined(separator: "") }).joined(separator: "\n")
    }

    private func calculateExpansions() {
        let width = space[0].count
        let height = space.count

        let rows = Array((0..<height)
            .reversed()
            .filter({ row in (0..<width).allSatisfy({ col in space[row][col] == "." }) }))

        let columns = Array((0..<width)
            .reversed()
            .filter({ col in (0..<height).allSatisfy({ row in space[row][col] == "." }) }))

        expansions = (rows: rows, columns: columns)
    }

    func detectGalaxies() {
        galaxies = (0..<space.count)
            .flatMap({ y in 
                (0..<space.count)
                    .filter({ x in space[y][x] == "#" })
                    .map({ x in Coord(x: x, y: y) }) 
            })
    }

    var pairs: [(Int, Int)] {
        var pairs: [(Int, Int)] = []

        for i in 0..<galaxies.count {
            for i2 in i+1..<galaxies.count {
                pairs.append((i + 1, i2 + 1))
            }
        }

        return pairs
    }

    func pathLengthForPair(_ pair: (Int, Int)) -> Int {
        let g1 = galaxies[pair.0-1]
        let g2 = galaxies[pair.1-1] 
        let start = Coord(x: min(g1.x, g2.x), y: min(g1.y, g2.y))
        let end = Coord(x: max(g1.x, g2.x), y: max(g1.y, g2.y))

        let expandedRows = expansions.rows
            .filter({ row in (start.y...end.y).contains(row) })
            .count
        let expandedCols = expansions.columns
            .filter({ col in (start.x...end.x).contains(col) })
            .count

        return (end.x - start.x) + (end.y - start.y) + (expandedRows + expandedCols) * expansionFactor
    }
}

print("Map (1)")
print("=======")
let map = Map(input: input) 
print("\(map.galaxies.count) galaxies creating \(map.pairs) pairs")
var length = 0
for pair in map.pairs {
    length += map.pathLengthForPair(pair)
}
print("Total distance (expansion 1): \(length)")

print()
print("Expanded Map (1,000,000)")
print("========================")
let expandedMap = Map(input: input, expansionFactor: 10) 
print("\(expandedMap.galaxies.count) galaxies creating \(expandedMap.pairs.count) pairs")
length = 0
for pair in expandedMap.pairs {
    length += expandedMap.pathLengthForPair(pair)
}
print("Total distance (expansion 1,000,000): \(length)")

