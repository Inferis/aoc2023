#!/usr/bin/env swift

import Foundation
import Darwin

guard let input = try? String(contentsOf:URL(filePath: "input2.txt"), encoding: .utf8) else { 
    print("No input")
    exit(0)
}

struct Map: CustomStringConvertible {
    private let data: [[String]]
    
    init(input: String) {
        data = input.split(separator: "\n").map({ String($0).split(separator:"").map({ String($0) })})
    }

    subscript(x: Int, y: Int) -> String {
        data[y][x]   
    }

    var width: Int {
        data[0].count
    }

    var height: Int {
        data.count
    }

    var description: String {
        data.map({ $0.joined(separator: "") }).joined(separator: "\n")
    }
}

enum Direction {
    case up
    case down
    case left
    case right
}

struct Ray: CustomStringConvertible, Equatable, Hashable {
    let x: Int
    let y: Int
    let going: Direction

    var description: String {
        "{\(x),\(y) ->\(going)}"
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
        hasher.combine(going)
    }

    static func ==(lhs: Ray, rhs: Ray) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y && lhs.going == rhs.going
    } 
}

struct MapTraverser: CustomStringConvertible {
    let map: Map
    var energyMap: [[Bool]]
    var directionMap: [[[Direction:Bool]]]
    var rays = [Ray(x: 0, y: 0, going: Direction.right )]

    init(map: Map) {
        self.map = map
        energyMap = (0..<map.height).map({ _ in Array(repeating: false, count: map.width) })
        directionMap = Array(repeating: Array(repeating: [:], count: map.width), count: map.height)
    }

    mutating func traverse() { 
        var lastEnergyMap = ""
        while (rays.count > 0) {
            // if self.energyDescription == lastEnergyMap {
            //     break
            // }
            lastEnergyMap = self.energyDescription

            print()
            print("Loop: \(rays)")
            print(self.energyDescription)
            print()
            print(self.trackDescription)

            var toRemove = Set<Ray>()
            var toAdd = Set<Ray>()
            var index = 0
            print("<Cleanup")
            while index < rays.count {
                let ray = rays[index]
                index += 1

                if let present = directionMap[ray.y][ray.x][ray.going], present {
                    print("    Marking for removing \(ray) because present")
                    toRemove.insert(ray)
                }

                if (ray.x < 0 || ray.x >= map.width || ray.y < 0 || ray.y >= map.height) {
                    print("    Marking for removing \(ray)")
                    toRemove.insert(ray)
                    continue
                }

                if toRemove.count > 0 {
                    print("    Removing:")
                    for ray in toRemove.reversed() {
                        remove(ray: ray)
                        print("    - \(ray)")
                    }
                    print("    --> \(rays)")
                }
            }
            print("Cleanup>")

            index = 0
            while index < rays.count {
                let ray = rays[index]
                print("> \(index)/\(rays.count) = \(ray) ")

                energyMap[ray.y][ray.x] = true
                switch map[ray.x, ray.y] {
                    case ".":
                        print("    - move")
                        move(index: index, ray: ray)
                        break
                    case "|":
                        switch ray.going {
                            case .up, .down:
                                print("    - up or down = move")
                                move(index: index, ray: ray)
                                break
                            case .left, .right:
                                print("  > | left or right")
                                toRemove.insert(ray)

                                let upRay = Ray(x: ray.x, y: ray.y-1, going: .up)
                                let downRay = Ray(x: ray.x, y: ray.y+1, going: .down)
                                toAdd.insert(upRay)
                                toAdd.insert(downRay)

                                print("    Generated: up=\(upRay) down=\(downRay)")
                                break
                        }
                        break
                    case "-":
                        switch ray.going {
                            case .left, .right:
                                print("    - left or right = move")
                                move(index: index, ray: ray)
                                break
                            case .up, .down:
                                print("    - up or down")
                                toRemove.insert(ray)

                                let leftRay = Ray(x: ray.x-1, y: ray.y, going: .left)
                                let rightRay = Ray(x: ray.x+1, y: ray.y, going: .right)
                                toAdd.insert(leftRay)
                                toAdd.insert(rightRay)

                                print("    Generated: left=\(leftRay) right=\(rightRay)")
                                break
                        }
                        break
                    case "\\":
                        print("    \\ \(ray.going)")
                        var newRay = ray
                        switch ray.going {
                            case .left:
                                newRay = Ray(x: ray.x, y: ray.y-1, going: .up)
                                break
                            case .right:
                                newRay = Ray(x: ray.x, y: ray.y+1, going: .down)
                                break
                            case .up:
                                newRay = Ray(x: ray.x-1, y: ray.y, going: .left)
                                break
                            case .down:
                                newRay = Ray(x: ray.x+1, y: ray.y, going: .right)
                                break
                        }
                        rays[index] = newRay
                        break
                    case "/":
                        print("    / \(ray.going)")
                        var newRay = ray
                        switch ray.going {
                            case .left:
                                newRay = Ray(x: ray.x, y: ray.y+1, going: .down)
                                break
                            case .right:
                                newRay = Ray(x: ray.x, y: ray.y-1, going: .up)
                                break
                            case .up:
                                newRay = Ray(x: ray.x+1, y: ray.y, going: .right)
                                break
                            case .down:
                                newRay = Ray(x: ray.x-1, y: ray.y, going: .left)
                                break
                        }
                        rays[index] = newRay
                        break
                    default:
                        print("    ?")
                        fatalError()
                }

                index += 1
            }

            if toAdd.count > 0 {
                print("    Adding:")
                for ray in toAdd {
                    if (ray.x >= 0 && ray.x < map.width && ray.y >= 0 && ray.y < map.height) {
                        rays.append(ray)
                        // directionMap[ray.y][ray.x][ray.going] = true
                        print("    - \(ray)")
                    }
                    else {
                        print("    x \(ray)")
                    }

                }
                print("    --> \(rays)")
            }

            print("End Loop: \(rays)")
            if readLine() == "q" {
                break
            }
        }

        print(self.energyDescription)
    }

    private mutating func move(index: Int, ray: Ray) {
        var newRay = ray
        switch ray.going {
            case .up:
                newRay = Ray(x: ray.x, y: ray.y-1, going: .up)
                break
            case .down:
                newRay = Ray(x: ray.x, y: ray.y+1, going: .down)
                break
            case .left:
                newRay = Ray(x: ray.x-1, y: ray.y, going: .left)
                break
            case .right:
                newRay = Ray(x: ray.x+1, y: ray.y, going: .right)
                break
        }
        print("      MOVE[\(index)](\(ray) -> \(newRay))")
        directionMap[ray.y][ray.x][ray.going] = true
        // directionMap[newRay.y][newRay.x][newRay.going] = true
        rays[index] = newRay
    }

    private mutating func remove(ray: Ray) {
        rays = rays.filter({ $0 != ray })
    }

    var description: String {
        energyMap.map({ $0.map({ $0 ? "#" : "." }).joined(separator: "") }).joined(separator: "\n")
    }

    var trackDescription: String {
        var description = map.description
        for y in 0..<directionMap.count {
            for x in 0..<directionMap[y].count {
                let directions = directionMap[y][x]
                let offset = y * (map.width+1) + x
                let index = description.index(description.startIndex, offsetBy: offset)
                if directions.count > 1 {
                    description.replaceSubrange(index...index, with: String(directions.count))
                }
                else if let (direction, value) = directions.first {
                    if value {
                        var d = "X"
                        switch direction {
                            case .up:
                                d = "^"
                                break
                            case .down:
                                d = "v"
                                break
                            case .left:
                                d = "<"
                                break
                            case .right:
                                d = ">"
                                break
                        }
                        description.replaceSubrange(index...index, with: d)
                    }
                }
            } 
        } 
        return description
    }

    var energyDescription: String {
        energyMap.map({ $0.map({ $0 ? "#" : "." }).joined(separator: "") }).joined(separator: "\n")
    }
}

let map = Map(input: input)

var traverser = MapTraverser(map: map)
traverser.traverse()

print(map)
print()
print(traverser)

