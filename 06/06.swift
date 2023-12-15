import Foundation
import Darwin

typealias Race = (time: Int, distance: Int)

guard let input = try? String(contentsOf:URL(filePath: "input.txt"), encoding: .utf8) else { 
    print("No input")
    exit(0)
}

func calculateHoldTime(race: Race) -> [Int] {
    var holdTimes: [Int] = []
    for time in 0..<race.time {
        let leftOverTime = race.time - time        
        let distance = leftOverTime * time
        if (distance > race.distance) {
            // print("\(time) --> \(distance)")
            holdTimes.append(time)
        }
    }
    return holdTimes
}

func parseIndividualLine(_ line: String) -> [Int] {
    let result = line.split(separator: " ").map({ String($0) })
    return result[1..<result.count].map({ Int($0)! })
}

func parseCombinedLine(_ line: String) -> [Int] {
    let result = line.split(separator: " ").map({ String($0) })
    return [Int(Array(result[1..<result.count]).joined(separator: ""))!]
}

func runRaces(from parser: (String) -> [Int]) {
    let lines = input.split(separator: "\n").map({ parser(String($0)) })
    let races = (0..<lines[0].count).map({ Race(time: lines[0][$0], distance: lines[1][$0]) })

    var result = 1
    for race in races {
        let title = "Race: \(race.time)ms for \(race.distance)mm"
        print(title)
        print(String(repeating: "-", count: title.count)) 
        result *= calculateHoldTime(race: race).count
        print()
    }
    print(result)
}

runRaces(from: parseIndividualLine)
runRaces(from: parseCombinedLine)
