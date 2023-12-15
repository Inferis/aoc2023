import Foundation
import Darwin

typealias Cube = (number: Int, color: String)
typealias Game = (index: Int, grabs: [[Cube]])

guard let input = try? String(contentsOf:URL(filePath: "input.txt"), encoding: .utf8) else { 
    print("No input")
    exit(0)
}

// \\s+(\\d+):\\s+\\((.+);)+ Game\s+(\d+?):(?:\s+([^;]+?);)+
guard let regex = try? Regex("Game\\s+(\\d+?)\\:\\s+(.+)") else {
    print("boo")
    exit(0)
}

// guard let cubeRegex = try? Regex<[String]>("(\\d+)\\s+(.+)") else {
//     print("boo2")
//     exit(0)
// }

var bag: [String:Int] = ["blue": 14, "green": 13, "red": 12]

var games: [Game] = []
for inputLine in input.split(separator: "\n") {
    let line = "\(inputLine);"
    if let result = try? regex.wholeMatch(in: line) {
        let gameIndex = Int(result.output[1].value as? Substring ?? "0")!
        var grabs: [[Cube]] = []
        if let matchedGrabs = (result.output[2].value ?? "") as? Substring {
            for matchedGrab in matchedGrabs.split(separator: ";") {
                var grab: [Cube] = []
                for matchedCube in matchedGrab.split(separator: ",") {
                    let matchedCubeInfo = matchedCube.split(separator: " ")
                    let cube = Cube(number: Int(matchedCubeInfo[0])!, color: String(matchedCubeInfo[1]))
                    grab.append(cube)
                }
                grabs.append(grab)
            }
        }

        let game = Game(index: gameIndex, grabs: grabs)
        games.append(game)
    }
}

var total = 0
for game in games {
    var goodGrabs = 0
    for grab in game.grabs {
        var goodCubes = 0
        for cube in grab {
            if cube.number <= bag[cube.color]! {
                goodCubes += 1
            }
        }
        if goodCubes == grab.count {
            goodGrabs += 1
        }
    }
    if goodGrabs == game.grabs.count {
        print("\(game.index), ", terminator: "")        
        total += game.index
    }
}

print("\n=========")
print(total)
print()

total = 0
for game in games {
    var minimum: [String:Int] = ["red": 0, "green": 0, "blue": 0]
    for grab in game.grabs {
        for cube in grab {
            minimum[cube.color] = max(minimum[cube.color] ?? 0, cube.number)
        }
    }
    let power = minimum["red"]! * minimum["green"]! * minimum["blue"]!
    print("\(game.index): \(minimum["red"] ?? 0) red, \(minimum["green"] ?? 0) green, \(minimum["blue"] ?? 0) blue = \(power)")
    total += power
}
print("=========")
print(total)
