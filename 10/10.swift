import Foundation
import Darwin

guard let input = try? String(contentsOf:URL(filePath: "input.txt"), encoding: .utf8) else { 
    print("No input")
    exit(0)
}

typealias Coord = (x: Int, y: Int)

struct Map: CustomStringConvertible {
    let data: [[String]]
    var distances: [[Int]]

    init(input: String) {
        data = input.split(separator: "\n").map({ String($0).split(separator: "").map({ String($0) }) })
        // weird
        distances = []
        distances = (0..<data.count).map({ Array(repeating: 0, count: data[$0].count) }) 
    }

    subscript(at: Coord) -> String {
        get { data[at.y][at.x] }
        set { }
    }

    var start: Coord? {
        for y in 0..<data.count {
            for x in 0..<data[y].count {
                if data[y][x] == "S" {
                    return Coord(x: x, y: y)
                }
            }
        }
        return nil
    }

    func toCoordinate(at: Coord, comingFrom direction: Direction) -> Coord {
        let pipe = data[at.y][at.x]
        let key = "\(direction.rawValue)\(pipe)"
        print("\\-- \"\(key)\"", terminator: "")
        var coord: Coord
        switch key {
            case "U-": print(); fatalError()
            case "U|": coord = Coord(x: 0, y: 1); break
            case "UF": print(); fatalError() //; coord = Coord(x: 0, y: 1); break
            case "U7": print(); fatalError() //; coord = Coord(x: 0, y: 1); break
            case "UJ": coord = Coord(x: -1, y: 0); break
            case "UL": coord = Coord(x: 1, y: 0); break

            case "D-": print(); fatalError()
            case "D|": coord = Coord(x: 0, y: -1); break
            case "DF": coord = Coord(x: 1, y: 0); break
            case "D7": coord = Coord(x: -1, y: 0); break
            case "DJ": print(); fatalError() //; coord = Coord(x: -1, y: 0); break
            case "DL": print(); fatalError() //; coord = Coord(x: 1, y: 0); break

            case "L-": coord = Coord(x: 1, y: 0); break
            case "L|": print(); fatalError()
            case "LF": print(); fatalError() // coord = Coord(x: 1, y: 0); break
            case "L7": coord = Coord(x: 0, y: 1); break
            case "LJ": coord = Coord(x: 0, y: -1); break
            case "LL": print(); fatalError(); // coord = Coord(x: 1, y: 0); break

            case "R-": coord = Coord(x: -1, y: 0); break
            case "R|": print(); fatalError()
            case "RF": coord = Coord(x: 0, y: 1); break
            case "R7": print(); fatalError() //; coord = Coord(x: 0, y: 1); break
            case "RJ": print(); fatalError() //; coord = Coord(x: 0, y: -1); break
            case "RL": coord = Coord(x: 0, y: -1); break

            default:
                coord = Coord(x: 0, y: 0)
        }

        coord = Coord(at.x + coord.x, at.y + coord.y)
        print(": \(at) -> \(coord)")
        return coord
    }

    mutating func setDistance(_ distance: Int, at: Coord) {
        distances[at.y][at.x] = distance
    }

    func findPipe(at: Coord, not: String) -> Coord {
        let allowed = [["F", "L", "-"], ["F", "7", "|"], ["7", "J", "-"], ["L", "J", "|"]]
        for (i, xy) in [Coord(x: -1, y: 0), Coord(x: 0, y: -1), Coord(x: 1, y: 0), Coord(x: 0, y: 1)].enumerated() {
            let x = at.x + xy.x
            let y = at.y + xy.y
            if (x >= 0 && x < data[0].count && y >= 0 && y < data.count) {
                let pipe = data[y][x]
                if pipe != "." && allowed[i].contains(pipe) && pipe != not {
                    print("\(xy.x),\(xy.y) = \(pipe)")
                    return Coord(x: x, y: y)
                }
            }
        }
        return at
    }

    var description: String {
        data.map({ $0.reduce("", { $0 + $1 }) }).reduce("", { "\($0)\n\($1)" })
    }

    var distanceDescription: String {
        var d: (Int) -> String = { $0 == 0 ? "." : "O" /*String(UnicodeScalar(55 + $0)!)*/ }
        return distances.map({ $0.reduce("", { $0 + d($1) }) }).reduce("", { "\($0)\n\($1)" }).trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

enum Direction: String {
    case up = "U"
    case down = "D"
    case left = "L"
    case right = "R"
    case inplace = "X"
}


func coming(from: Coord, to: Coord) -> Direction {
    print("D \(from) -> \(to) = from ", terminator: "")
    //             up 
    //       0,0 | 1,0 | 2,0
    //       ----|-----|----
    // left  0,1 | 1,1 | 2,1 right
    //       ----|-----|----
    //       0,2 | 1,2 | 2,2
    //             down
    //    
    // 0 | 2 to 1 = 1 - 2 = -1

    print("[[y: \(to.y)-\(from.y) = \(to.y - from.y)]]", terminator: "")
    var direction: Direction
    if (to.y - from.y == 1) {
        direction = .up
    }
    else if (to.y - from.y == -1) {
        direction = .down
    }
    else if (to.x - from.x == 1) {
        direction = .left
    }
    else if (to.x - from.x == -1) {
        direction = .right
    }
    else {
        direction = .inplace
    }

    print(direction)
    return direction
}

var map = Map(input: input)
print(map)
print()

if let start = map.start {
    print("Starting at \(start)")

    var forward = map.findPipe(at: start, not: "")
    var lastForward = start
    var backward = map.findPipe(at: start, not: map[forward])
    var lastBackward = start

    var distance = 1
    map.setDistance(distance, at: forward)
    map.setDistance(distance, at: backward)

    print("[Start] F: \(forward), B: \(backward) --> \(distance)")
    while (forward != backward) {
        print("\n-----\n")
        print(map.distanceDescription)
        print()
        print("forward    |backward     = \(forward)|\(backward)")
        print("lastForward|lastBackward = \(lastForward)|\(lastBackward)")
        print("distance                 = \(distance)")
        print()

        distance += 1

        print("NF", terminator: "")
        let newForward = map.toCoordinate(at: forward, comingFrom: coming(from: lastForward, to: forward))
        print("NB", terminator: "")
        let newBackward = map.toCoordinate(at: backward, comingFrom: coming(from: lastBackward, to: backward))
        map.setDistance(distance, at: newForward)
        map.setDistance(distance, at: newBackward)

        print("[New] F: \(newForward), B: \(newBackward) --> \(distance)")

        lastForward = forward
        lastBackward = backward
        forward = newForward
        backward = newBackward
    }

    print()
    print("Results: \(distance) steps")
    print(map.distanceDescription)
}
else {
    print("no start")
}