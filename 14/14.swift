#!/usr/bin/env swift

import Foundation
import Darwin

guard let input = try? String(contentsOf:URL(filePath: "input.txt"), encoding: .utf8) else { 
    print("No input")
    exit(0)
}

enum TiltDirection: CaseIterable {
    case neutral
    case north
    case west
    case south
    case east 
}

struct Platform: CustomStringConvertible, Equatable, Hashable {
    var data: [[String]]
    var tilt: TiltDirection

    init(input: String) {
        data = input.split(separator: "\n").map({ String($0).split(separator: "").map({ String($0) }) })
        tilt = .neutral
    }

    private init(data: [[String]], tilt: TiltDirection) {
        self.data = data
        self.tilt = tilt
    }

    func tilting(_ tilt: TiltDirection) -> Platform {
        let width = data[0].count
        let height = data.count
        var d = data
        switch tilt {
            case .north:
                for x in 0..<width {
                    for y in 1..<height {
                        if d[y][x] == "O" {
                            var dy = y
                            while dy > 0 && d[dy-1][x] == "." {
                                dy -= 1
                            }
                            d[y][x] = "."
                            d[dy][x] = "O"
                        }
                    }
                }
                break
            case .south:
                for x in 0..<width {
                    for y in (0..<height-1).reversed() {
                        if d[y][x] == "O" {
                            var dy = y
                            while dy < height-1 && d[dy+1][x] == "." {
                                dy += 1
                            }
                            d[y][x] = "."
                            d[dy][x] = "O"
                        }
                    }
                }
                break
            case .east:
                for y in 0..<height {
                    for x in (0..<width-1).reversed() {
                        if d[y][x] == "O" {
                            var dx = x
                            while dx < width-1 && d[y][dx+1] == "." {
                                dx += 1
                            }
                            d[y][x] = "."
                            d[y][dx] = "O"
                        }
                    }
                }
                break
            case .west:
                for y in 0..<height {
                    for x in 1..<width {
                        if d[y][x] == "O" {
                            var dx = x
                            while dx > 0 && d[y][dx-1] == "." {
                                dx -= 1
                            }
                            d[y][x] = "."
                            d[y][dx] = "O"
                        }
                    }
                }
                break
            case .neutral:
                return self
        }

        return Platform(data: d, tilt: tilt)
    }

    mutating func tilt(_ tilt: TiltDirection) {
        let width = data[0].count
        let height = data.count
        switch tilt {
            case .north:
                for x in 0..<width {
                    for y in 1..<height {
                        if data[y][x] == "O" {
                            var dy = y
                            while dy > 0 && data[dy-1][x] == "." {
                                dy -= 1
                            }
                            data[y][x] = "."
                            data[dy][x] = "O"
                        }
                    }
                }
                break
            case .south:
                for x in 0..<width {
                    for y in (0..<height-1).reversed() {
                        if data[y][x] == "O" {
                            var dy = y
                            while dy < height-1 && data[dy+1][x] == "." {
                                dy += 1
                            }
                            data[y][x] = "."
                            data[dy][x] = "O"
                        }
                    }
                }
                break
            case .east:
                for y in 0..<height {
                    for x in (0..<width-1).reversed() {
                        if data[y][x] == "O" {
                            var dx = x
                            while dx < width-1 && data[y][dx+1] == "." {
                                dx += 1
                            }
                            data[y][x] = "."
                            data[y][dx] = "O"
                        }
                    }
                }
                break
            case .west:
                for y in 0..<height {
                    for x in 1..<width {
                        if data[y][x] == "O" {
                            var dx = x
                            while dx > 0 && data[y][dx-1] == "." {
                                dx -= 1
                            }
                            data[y][x] = "."
                            data[y][dx] = "O"
                        }
                    }
                }
                break
            case .neutral:
                break
        }
        self.tilt = tilt
    }

    func cycling() -> Platform {
        var platform = self
        for tilt in TiltDirection.allCases {
            platform = platform.tilting(tilt)
        }
        return platform
    }

    mutating func cycle() {
        for tilt in TiltDirection.allCases {
            self.tilt(tilt)
        }
    }

    var load: Int {
        let width = data[0].count
        let height = data.count
        var load = 0
        for y in 0..<height {
            for x in 0..<width {
                if data[y][x] == "O" {
                    load += width-y
                } 
            }
        }
        return load
    }

    var description: String {
        data.map({ $0.joined(separator: "") }).joined(separator: "\n")
    }

    var dataDescription: String {
        "\(data.map({ $0.joined(separator: "") }).joined(separator: "|")):\(load)"
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(data)
    }

    static func == (lhs: Platform, rhs: Platform) -> Bool {
        let lhd = lhs.dataDescription
        let rhd = rhs.dataDescription
        //print("\(lhd):\(lhs.load)\n\(rhd):\(rhs.load)")
        return lhd == rhd    
    }
}

var platform = Platform(input: input)
print(platform.tilting(.north).load)
print()    

var last = [platform]
var current = platform
var times = 0
let max = 1_000_000_000
var i = 0
var skip = false
while i <= max {
    current = current.cycling()
    if last.contains(current) && !skip {
        last.append(current)
        let firstIndex = last.firstIndex(where: { $0 == current })!
        let lastIndex = last.lastIndex(where: { $0 == current })!
        let modulo = lastIndex - firstIndex
        i = max - ((max - 1) % modulo) + 2
        print("\(firstIndex) \(lastIndex) -> \(modulo)")
        print(">> \(i) \(current.dataDescription)")
        skip = true
    }
    last.append(current)
    print(i)
    // print("\(i)\(current.dataDescription):\(current.load)")
    i += 1
}

print()
print(current.dataDescription)
print(current.load)
