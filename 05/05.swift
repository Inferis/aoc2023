
import Foundation
import Darwin

struct Map: CustomStringConvertible {
    struct Rule: Comparable, CustomStringConvertible {
        let sourceRange: Range<Int>
        let destOrigin: Int

        init(input: String) {
            let values = input.split(separator: " ").map({ Int($0)! })
            destOrigin = values[0]
            sourceRange = values[1]..<(values[1]+values[2])
            print("init(\(sourceRange) --> \(destRange))")
        }

        func inRange(source: Int) -> Bool {
            sourceRange.contains(source)
        }

        func translate(source: Int) -> Int {
            source - sourceRange.lowerBound + destOrigin
        }

        static func < (lhs: Rule, rhs: Rule) -> Bool {
            if lhs.sourceRange.lowerBound != rhs.sourceRange.lowerBound {
                return lhs.sourceRange.lowerBound < rhs.sourceRange.lowerBound
            } 
            else if lhs.destOrigin != rhs.destOrigin {
                return lhs.destOrigin < rhs.destOrigin
            } 
            else {
                return lhs.sourceRange.upperBound < rhs.sourceRange.upperBound
            }
        }

        var destRange: Range<Int> {
            destOrigin..<(destOrigin+sourceRange.upperBound-sourceRange.lowerBound)
        }

        var description: String {
            "[\(sourceRange.lowerBound)...\(sourceRange.upperBound)-\(destRange.lowerBound)...\(destRange.upperBound)]"
        }
    }

    let from: String
    let to: String
    var rules: [Rule]

    init(input: [String]) {
        if let match = try? (/(.+?)\s+map:/).wholeMatch(in: input[0]) {
            let name = String(match.output.1).split(separator: "-").map({ String($0) })
            from = name.first!
            to = name.last!
        }
        else {
            from = "unknown"
            to = "unknown"
        }

        rules = input[1..<input.count].map({ Rule(input: $0) })
        rules.sort()
    }

    func sourceToDestination(_ source: Int) -> Int {
        for rule in rules {
            if rule.inRange(source: source) {
                return rule.translate(source: source)                
            }
        }
        return source
    }

    var name: String {
        "\(from)-to-\(to)"
    }

    var description: String {
        "{\(name) #\(rules.count)}"
    }

}

extension Range where Element : Comparable {
    public func intersect(with other: Range) -> Range? {
        guard endIndex > other.startIndex else {
            return nil
        }
        guard other.endIndex > startIndex else {
            return nil
        }
        let s = other.startIndex > startIndex ? other.startIndex : startIndex
        let e = other.endIndex < endIndex ? other.endIndex : endIndex
        return s..<e
    }
}

func parseInput(_ input: String) -> ([Int], [Map]) {
    let parts = input.split(separator: "\n\n").map({ $0.split(separator:"\n") })

    let seeds = parts[0].joined(separator: "").split(separator: " ").compactMap({ Int(String($0)) })
    let maps = parts[1..<parts.count].map({ Map(input: $0.map({ String($0) })) })

    return (seeds, maps)
}

// ----------------------------------

guard let input = try? String(contentsOf:URL(filePath: "input.txt"), encoding: .utf8) else { 
    print("No input")
    exit(0)
}

var (seeds, maps) = parseInput(input)

print(maps.map({ "\($0.name) \($0.rules)\n" }).joined(separator: "\n"))
print()

var lastTo = "seed"
var sortedMaps: [Map] = []
while let map = maps.first(where: { $0.from == lastTo }) {
    sortedMaps.append(map)
    lastTo = map.to
}

var lowest = Int.max
for seed in seeds {
    var source = seed
    print("Seed: \(seed)", terminator: "")
    // print(String(repeating: "-", count: "Seed: \(seed)".count))
    for map in sortedMaps {
        let destination = map.sourceToDestination(source)
        print("\(map.name) \(source) -> \(destination)")
        source = destination
    }
    lowest = min(lowest, source)
    print(" -> \(source)")
}

print("Lowest: \(lowest)")
print()

var seedRanges: [Range<Int>] = []
for i in stride(from: 0, to: seeds.count, by: 2) {
    seedRanges.append(seeds[i]..<(seeds[i] + seeds[i+1]))    
}

func process(seedRanges: [Range<Int>], maps: [Map]) -> Int {
    var ranges = seedRanges
    for map in maps {
        print("MAP \(map.name)") 
        for rule in map.rules {
            print("RULE \(rule)") 
            var newRanges: [Range<Int>] = []
            for range in ranges {
                if let ruleRange = range.intersect(with: rule.sourceRange) {
                    // print("\(range)%\(rule.sourceRange) -> \(ruleRange)")
                    if range.startIndex != ruleRange.startIndex {
                        newRanges.append(range.startIndex..<ruleRange.startIndex)
                    }
                    newRanges.append(ruleRange)
                    if range.endIndex != ruleRange.endIndex {
                        newRanges.append(ruleRange.endIndex..<range.endIndex)
                    }
                }
                else {
                    newRanges.append(range)
                }
            }
            if (ranges != newRanges) {
                ranges = newRanges
            }
        }

        var newRanges: [Range<Int>] = []
        for range in ranges {
            newRanges.append(map.sourceToDestination(range.startIndex)..<map.sourceToDestination(range.endIndex-1)+1)
        }
        ranges = newRanges
    }

    return ranges.map({ $0.startIndex }).reduce(Int.max, { $0 < $1 ? $0 : $1 })
}

lowest = Int.max
for seedRange in seedRanges {
    let rangeLowest = process(seedRanges: [seedRange], maps: sortedMaps)
    lowest = min(lowest, rangeLowest) 
}

print("Lowest: \(lowest)")