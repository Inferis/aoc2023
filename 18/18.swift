#!/usr/bin/env swift -enable-bare-slash-regex

import Foundation
import Darwin

guard let input = try? String(contentsOf:URL(filePath: "input2.txt"), encoding: .utf8) else { 
    print("No input")
    exit(0)
}

enum Direction {
    case up
    case down
    case left
    case right
}

typealias Color = (r: Int, g: Int, b: Int)

struct Coordinate: Hashable, CustomStringConvertible {
    let x: Int 
    let y: Int

    func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }

    var description: String {
        "(\(x),\(y))"
    }
}

struct Dig: CustomStringConvertible {
    let direction: Direction
    let distance: Int 
    let color: Color

    init(input: String, useColorForDistance: Bool) {
        if !useColorForDistance {
            let pattern = /([U|R|L|D])\s+(\d+)\s+\(#(..)(..)(..)\)/
            if let match = try? pattern.wholeMatch(in: input) {
                switch match.output.1 {
                    case "U": direction = .up 
                    case "R": direction = .right 
                    case "D": direction = .down 
                    case "L": direction = .left 
                    default: fatalError("Invalud direction")
                }
                distance = Int(match.output.2)!
                color = Color(r: Int(match.output.3, radix: 16)!, g: Int(match.output.4, radix: 16)!, b: Int(match.output.5, radix: 16)!)
            }
            else {
                fatalError("Invalid line")
            }
        }
        else {
            let pattern = /.\s+\d+\s+\(#(.....)(.)\)/
            if let match = try? pattern.wholeMatch(in: input) {
                switch match.output.2 {
                    case "3": direction = .up 
                    case "0": direction = .right 
                    case "1": direction = .down 
                    case "2": direction = .left 
                    default: fatalError("Invalud direction")
                }
                distance = Int(match.output.1, radix: 16)!
                color = Color(r: 0, g: 0, b: 0)
            }
            else {
                fatalError("Invalid line")
            }
        }
        //print("going \(distance) \(direction) colored \(color)")
    }

    var description: String {
        var g = "x"
        switch direction {
            case .up: g = "^"; break
            case .down: g = "v"; break
            case .left: g = "<"; break
            case .right: g = ">"; break
        }
        return "\(distance)\(g)"
    }

    static func parseAll(input: String, useColorForDistance: Bool = false) -> [Dig] {
        input.split(separator: "\n").map { Dig(input: String($0), useColorForDistance: useColorForDistance) }
    }
}

struct Lagoon: CustomStringConvertible {
    var edges: [[Color?]]
    var filled: [[Color?]]
    var digLocation: Coordinate
    var joints: [Coordinate]

    init() {
        edges = [[nil]]
        filled = []
        digLocation = Coordinate(x: 0, y: 0)
        joints = [digLocation]
    }

    mutating func dig(_ digs: [Dig]) {
        for dig in digs {
            self.dig(dig)
        }
        //joints.append(joints[0])
    }

    mutating func dig(_ dig: Dig) {
        switch dig.direction {
            case .up: 
                if digLocation.y - dig.distance < 0 {
                    expandUp(dig.distance - digLocation.y)
                }
                // for y in 0...dig.distance {
                //     edges[digLocation.y - y][digLocation.x] = dig.color
                // }
                digLocation = Coordinate(x: digLocation.x, y: digLocation.y - dig.distance)
                break           
            case .down: 
                if digLocation.y + dig.distance + 1 > height {
                    expandDown(height - digLocation.y + dig.distance - 1)
                }
                // for y in 0...dig.distance {
                //     edges[digLocation.y + y][digLocation.x] = dig.color
                // }
                digLocation = Coordinate(x: digLocation.x, y: digLocation.y + dig.distance)
                break           
            case .left: 
                if digLocation.x - dig.distance < 0 {
                    expandLeft(dig.distance - digLocation.x)
                }
                // for x in 0...dig.distance {
                //     edges[digLocation.y][digLocation.x - x] = dig.color
                // }
                digLocation = Coordinate(x: digLocation.x - dig.distance, y: digLocation.y)
                break           
            case .right: 
                if digLocation.x + dig.distance + 1 > width {
                    expandRight(width - digLocation.x + dig.distance - 1)
                }
                // for x in 0...dig.distance {
                //     edges[digLocation.y][digLocation.x + x] = dig.color
                // }
                digLocation = Coordinate(x: digLocation.x + dig.distance, y: digLocation.y)
                break           
        }
        joints.append(digLocation)
    }

    mutating func expandLeft(_ extra: Int) {
        // for y in 0..<self.height {
        //     edges[y].insert(contentsOf: Array(repeating: nil, count: extra), at: 0)            
        // }
        digLocation = Coordinate(x: digLocation.x + extra, y: digLocation.y)
        for j in 0..<joints.count {
            joints[j] = Coordinate(x: joints[j].x + extra, y: joints[j].y)
        }
    }

    mutating func expandRight(_ extra: Int) {
        // for y in 0..<self.height {
        //     edges[y].append(contentsOf: Array(repeating: nil, count: extra))            
        // }
    }

    mutating func expandUp(_ extra: Int) {
        // edges.insert(contentsOf: Array(repeating: Array(repeating: nil, count: width), count: extra), at: 0)
        digLocation = Coordinate(x: digLocation.x, y: digLocation.y + extra)
        for j in 0..<joints.count {
            joints[j] = Coordinate(x: joints[j].x, y: joints[j].y + extra)
        }
    }

    mutating func expandDown(_ extra: Int) {
        // edges.append(contentsOf: Array(repeating: Array(repeating: nil, count: width), count: extra))
    }

    func isPointInPath(x: Int, y: Int) -> Bool {
        var result = false
        var j = joints.first!
        for i in joints[1..<joints.count] {
            if x == i.x && y == i.y {
                // corner
                return true
            }
            else if (i.y > y) != (j.y > y) {
                let slope = (x - i.x) * (j.y - i.y) - (j.x - i.x) * (y - i.y)
                if slope == 0 {
                    return true
                }
                if (slope < 0) != (j.y < i.y) {
                    result = !result
                }
            }
            j = i
        }
        return result
    }

    var filledVolume: Int {
        var volume = 0
        for y in 0..<height {
            for x in 0..<width {
                if isPointInPath(x: x, y: y) {
                    volume += 1
                }
            }
        }
        return volume
    }

    // mutating func fill2() {
    //     var todo = Set<Coordinate>()
    //     do {
    //         let x = joints[0].x
    //         let y = joints[0].y
    //         for loc in [(x: 1, y: 1), (x: 1, y: -1), (x: -1, y: -1), (x: -1, y: 1), (x: 1, y: 0), (x: 0, y: 1), (x: -1, y: 0), (x: 0, y: -1)] {
    //             let lx = x + loc.x
    //             let ly = y + loc.y 
    //             if lx >= 0 && lx < width && ly >= 0 && ly < height && edges[ly][lx] == nil {
    //                 todo.insert(Coordinate(x: lx, y: ly))
    //                 break
    //             }
    //         }
    //     }

    //     while todo.count > 0 {
    //         //print("todo = \(todo)")
    //         let c = todo.removeFirst()
    //         if edges[c.y][c.x] == nil {
    //             edges[c.y][c.x] = Color(r: 0, g: 0, b: 0)
    //         }
    //         for loc in [(x: -1, y: -1), (x: 0, y: -1), (x: 1, y: -1), (x: -1, y: 0), (x: 1, y: 0), (x: -1, y: 1), (x: 0, y: 1), (x: 1, y: 1)] {
    //             let lx = c.x + loc.x
    //             let ly = c.y + loc.y 
    //             if lx >= 0 && lx < width && ly >= 0 && ly < height && edges[ly][lx] == nil {
    //                 todo.insert(Coordinate(x: lx, y: ly))
    //             }
    //         }
    //     }
    // }

    var width: Int {
        var m = 0
        print(joints)
        for j in joints {
            m = max(j.x, m)
        }
        return m
    }

    var height: Int {
        var m = 0
        for j in joints {
            m = max(j.y, m)
        }
        return m
    }

    var volume: Int {
        if filled.count == 0 {
            edges.flatMap({ $0 }).filter({ $0 != nil }).count
        }
        else {
            filled.flatMap({ $0 }).filter({ $0 != nil }).count
        }
    }

    var description: String {
        if filled.count == 0 {
            edges.map({ $0.map({ $0 != nil ? "#" : "." }).joined(separator: "") }).joined(separator: "\n")
        }
        else {
            filled.map({ $0.map({ $0 != nil ? "#" : "." }).joined(separator: "") }).joined(separator: "\n")
        }
    }

    var colorDescription: String {
        edges.map({ $0.map({ $0 != nil ? String(format: "%02x%02x%02x ", $0!.r, $0!.b, $0!.g) : "...... " }).joined(separator: "") }).joined(separator: "\n")
    }
}

do {
    var lagoon = Lagoon()
    let digs = Dig.parseAll(input: input, useColorForDistance: false)
    lagoon.dig(digs)
    print(lagoon.width, lagoon.height)
    print("Using Distance = \(lagoon.volume), \(lagoon.filledVolume)")
}

do {
    var lagoon = Lagoon()
    let digs = Dig.parseAll(input: input, useColorForDistance: true)
    lagoon.dig(digs)
    print(lagoon.width, lagoon.height)
    print("Using Color = \(lagoon.volume), \(lagoon.filledVolume)")
}


