#!/usr/bin/env swift

import Foundation
import Darwin

guard let input = try? String(contentsOf:URL(filePath: "input2.txt"), encoding: .utf8) else { 
    print("No input")
    exit(0)
}

struct Coordinate: Hashable, Equatable {
    let x: Int
    let y: Int

    func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }

    static func ==(lhs: Coordinate, rhs: Coordinate) -> Bool {
        lhs.x == rhs.x && lhs.y == rhs.y
    }
} 

struct City: CustomStringConvertible {
    let data: [[Int]]

    init(input: String) {
        data = input.split(separator: "\n").map({ String($0).split(separator: "").map({ Int($0)! }) })
    }

    var width: Int {
        data[0].count
    }

    var height: Int {
        data.count
    }

    var startCoordinate: Coordinate {
        return Coordinate(x: 0, y: 0)
    }

    var endCoordinate: Coordinate {
        return Coordinate(x: width-1, y: height-1)
    }

    subscript(location: Location) -> Int {
        data[location.y][location.x]
    }
    
    subscript(x: Int, y: Int) -> Int {
        data[y][x]
    }
    
    var allCoordinates: Set<Coordinate> {
        var result = Set<Coordinate>()
        for y in 0..<data.count {
            for x in 0..<data[y].count {
                result.insert(Coordinate(x: x, y: y))
            }
        }
        return result
    }

    func pathDescription(_ path: Path) -> String {
        var description = ""
        for y in 0..<data.count {
            for x in 0..<data[y].count {
                if let direction = path.directionAt(x: x, y: y) {
                    switch direction {
                        case .up:
                            description += "^"
                            break
                        case .down:
                            description += "V"
                            break
                        case .left:
                            description += "<"
                            break
                        case .right:
                            description += ">"
                            break
                    }                    
                }
                else {
                    description += String(data[y][x])
                }
            }
            description += "\n"
        }
        return description
    }

    var description: String {
        data.map({ $0.map({ String($0) }).joined(separator: "") }).joined(separator: "\n")
    }
}

struct PathFinder: CustomStringConvertible {
    var paths: [Path]
    let city: City

    init(city: City) {
        let location = Location(x: 0, y: 0, incoming: .right)
        paths = [Path(location: location, city: city)]
        self.city = city
    }

    mutating func walk() -> Path? {
        var unvisited = Set<Coordinate>(city.allCoordinates)
        var paths: [Path] = [Path(location: Location(coordinate: city.startCoordinate, incoming: .right), city: city)]
        unvisited.remove(city.startCoordinate)
        
        let city = city
        let visitedDescription = {
            var description = city.description
            for coord in unvisited {
                let offset = coord.y * (city.width+1) + coord.x
                let index = description.index(description.startIndex, offsetBy: offset)
                description.replaceSubrange(index...index, with: ".")
            }
            return description
        }

        var i = 0
        while bestPath(of: paths) == nil {
            print()
            print("---------------------------------------------------------------------")
            print("[\(i)] Paths")
            // print("[\(i)] Paths: \(paths.count) -> \(paths)")
            if let bestPath = bestPath(of: paths) {
                print("  -- Bestpath: \(bestPath)")
            }
            i += 1
            var newPaths: [Path] = []
            print(visitedDescription())
            for path in paths.sorted(by: { $0.heatloss < $1.heatloss }) {
                unvisited.remove(path.head.coordinate)
                print()
                print("\(path.head) of \(path)")
                print(city.pathDescription(path))
                let current = path.head
                let nextPositions = [(x: 1, y: 0, direction: Direction.right), (x: 0, y: 1, direction: .down), (x: -1, y: 0, direction: Direction.left), (x: 0, y: -1, direction: .up)]
                for next in nextPositions {
                    let nx = current.x + next.x
                    let ny = current.y + next.y

                    // don't want coordinates outside the city
                    if nx < 0 || ny < 0 || nx >= city.width || ny >= city.height {
                        continue
                    }

                    let coordinate = Coordinate(x: nx, y: ny)
                    let peekLocation = Location(coordinate: coordinate, incoming: next.direction)
                    print("* next: \(peekLocation) = \(city[peekLocation])")

                    if unvisited.contains(coordinate) {
                        // can't go reverse
                        if !peekLocation.oppositeDirection(of: path.incoming) {
                            if !path.containsCoordinate(coordinate) {
                                var newPath = path
                                newPath.add(peekLocation)
                                if newPath.headLength <= 3 {
                                    newPaths.append(newPath)
                                    print("  -> unvisited new = \(newPath.headLength) -- \(newPath)")
                                }
                                else {
                                    print("  -> unvisited: headlength too much = \(newPath.headLength)")
                                }
                            }
                            else {
                                print("  -> unvisited: can't because path contains coordinate")
                            }
                        }
                        else {
                            print("  -> unvisited: can't because going opposite")
                        }
                    }
                    else {
                        print("  -> already visited")
                    }
                }

                // print("newPaths: \(newPaths)")
                
                // let city = city
                // let calcHeatloss: (Path) -> Int = { path in 
                //     var heatloss = city.heatLossForPath(path)
                //     heatloss *= (path.head.incoming == .up || path.head.incoming == .left) ? 2 : 1
                //     print("\(heatloss) \(path.head.incoming)")
                //     return heatloss
                // }
                // if let warmestPath = candidatePaths.min(by: { calcHeatloss($0) < calcHeatloss($1) }) {
                //     print("adding \(warmestPath)")
                //     newPaths.append(warmestPath)
                // }
            }

            // print("eval: \(newPaths)")
            // let fullPaths = newPaths.filter({ $0.head.coordinate == city.endCoordinate }).sorted(by: { $0.heatloss < $1.heatloss })
            // print(fullPaths)
            // if let fullPath = fullPaths.first {
            //     return fullPath
            // }

            // let calcHeatloss: (Path) -> Int = { path in 
            //     let adjustment = city[path.head] - city[path.head] * ((path.head.incoming == .up || path.head.incoming == .left) ? 2 : 1) 
            //     let heatloss = path.heatloss // - adjustment
            //     print("#### \(heatloss) \(path.head.incoming)")
            //     return heatloss
            // }
            // if let minPath = newPaths.min(by: { $0.heatloss < $1.heatloss }) {
            //     let heatloss = minPath.heatloss
            //     newPaths = newPaths.filter { $0.heatloss == heatloss }
            // }
            // print("NEW: \(newPaths.map({ $0.heatloss }).sorted())")
            //print("NEW: \(newPaths)")
            // for path in newPaths {
            //     print("* \(path)")
            // }

            paths = Array(newPaths.prefix(4))

            if readLine() == "q" {
                break
            } 
        }

        self.paths = paths
        return bestPath(of: paths)
    }

    func bestPath(of paths: [Path]) -> Path? {
        let sortedPaths = paths.sorted(by: { $0.heatloss < $1.heatloss })
        if let path = sortedPaths.first(where: { $0.head.coordinate == city.endCoordinate }) {
            return path
        }
        else {
            return nil
        }
    }

    var description: String {
        var description = "\(paths.count) paths {"
        for path in paths {
            description += "    \(path)" 
        }
        description += "}"
        return description
    }

}

struct Path: CustomStringConvertible, Equatable {
    var locations: [Location]
    let city: City

    init(location: Location, city: City) {
        self.locations = [location]
        self.city = city
    }

    init(path: Path) {
        locations = path.locations
        city = path.city
    }

    mutating func add(_ location: Location) {
        var found = false
        for p in [(x: 0, y: -1), (x: 1, y: 0), (x: 0, y: 1), (x: -1, y: 0)] {
            if head.x + p.x == location.x && head.y + p.y == location.y {
                found = true
                break
            } 
        }

        if !found {
            fatalError()
        }

        locations.append(location)
    }

    func directionAt(x: Int, y: Int) -> Direction? {
        locations.first(where: { $0.x == x && $0.y == y })?.incoming
    }

    func containsCoordinate(_ coordinate: Coordinate) -> Bool {
        locations.first(where: { $0.x == coordinate.x && $0.y == coordinate.y }) != nil
    }

    var headLength: Int {
        var found = 1
        for i in (0..<locations.count-1).reversed() {
            let location = locations[i]
            if (location.x == head.x && location.y != head.y) || (location.x != head.x && location.y == head.y) {
                found += 1
            }
            else {
                return found
            }
        }
        return found
    }

    var isMaxHeadLength: Bool {
        var found = 1
        for i in (0..<locations.count-1).reversed() {
            let location = locations[i]
            if location.x != head.x || location.y != head.y {
                return false
            }
            else {
                found += 1
                if found >= 3 {
                    return true
                }
            }
        }
        return false
    }

    var heatloss: Int {
        var loss = 0
        for location in locations {
            loss += city[location]
        }
        return loss
    }

    var incoming: Direction {
        return head.incoming
    }

    var head: Location {
        return locations.last!
    } 

    var tail: Location {
        return locations.first!
    } 

    var count: Int {
        locations.count
    }

    var description: String {
        "\(heatloss)º (\(locations.count))[\(locations.map({ $0.description }).joined(separator: ", "))]"
    }

    static func ==(lhs: Path, rhs: Path) -> Bool {
        return lhs.locations == rhs.locations
    }
}

enum Direction {
    case up
    case down
    case left
    case right
}

struct Location: CustomStringConvertible, Equatable, Hashable {
    let x: Int
    let y: Int
    let incoming: Direction

    init(x: Int, y: Int, incoming: Direction) {
        self.x = x
        self.y = y
        self.incoming = incoming
    }

    init(coordinate: Coordinate, incoming: Direction) {
        self.x = coordinate.x
        self.y = coordinate.y
        self.incoming = incoming
    }

    var coordinate: Coordinate {
        Coordinate(x: x, y: y)
    }

    var description: String {
        var g = "x"
        switch incoming {
            case .up: g = "^"; break
            case .down: g = "v"; break
            case .left: g = "<"; break
            case .right: g = ">"; break
        }
        return "{\(x),\(y) \(g)}"
    }

    func oppositeDirection(of direction: Direction) -> Bool {
        (incoming == .up && direction == .down) ||
        (incoming == .down && direction == .up) ||
        (incoming == .left && direction == .right) ||
        (incoming == .right && direction == .left)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
        hasher.combine(incoming)
    }

    static func ==(lhs: Location, rhs: Location) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y && lhs.incoming == rhs.incoming
    } 
}



let city = City(input: input)
print("Size: \(city.width)x\(city.height)")
print("Path: \(city.startCoordinate) -> \(city.endCoordinate)")
print(city)
print()

var pathFinder = PathFinder(city: city)
if let path = pathFinder.walk() {
    print()
    print(path)
    print()
    print(city.pathDescription(path))
    print()
    print(path.heatloss)
}
else {
    print("No path")
}