#!/usr/bin/env swift -enable-bare-slash-regex

import Foundation
import Darwin

guard let input = try? String(contentsOf:URL(filePath: "input2.txt"), encoding: .utf8) else { 
    print("No input")
    exit(0)
}

typealias Partition = [Range<Int>]

struct Rule: CustomStringConvertible {
    let category: String
    let op: String
    let value: Int
    let compare: (Int) -> Bool
    let destination: String

    init(input: String) {
        let pattern = /(.+)([<|>|=])(\d+):(.+)/
        if let match = try? pattern.wholeMatch(in: input) {
            category = String(match.output.1)
            op = String(match.output.2)
            value = Int(match.output.3)!
            destination = String(match.output.4)

            let value = value
            switch op {
                case "<":
                    compare = { content in content < value } 
                    break
                case ">":
                    compare = { content in content > value } 
                    break
                default:
                    fatalError("invalid operator \(op)")
            }
        }
        else {
            category = ""
            op = "@"
            value = 0
            compare = { _ in print("xxx"); return true }
            destination = input
        }
    }

    func createPartition(max: Int) -> [String:Partition]? {
        if isSentinel {
            return nil
        }
        return [category:[1..<value, value..<max+1]]
    }

    var isSentinel: Bool {
        category == ""
    }

    var description: String {
        if isSentinel {
            "(-> \(destination))"
        }
        else {
            "(\(category)\(op)\(value) -> \(destination))"
        }
    }
}

struct Workflow: CustomStringConvertible {
    let name: String
    let rules: [Rule]

    init(input: String) {
        let pattern = /(.+){(.+)}/
        if let match = try? pattern.wholeMatch(in: input) {
            name = String(match.output.1)
            rules = match.output.2.split(separator: ",").map { Rule(input: String($0)) }
        }
        else {
            fatalError("Invalid workflow \"\(input)\"")
        }
    }

    init(name: String) {
        self.name = name
        self.rules = []
    }

    func createPartitions(max: Int) -> [String:Partition] {
        var partitions = Dictionary<String, Partition>()
        for rule in rules {
            if let partition = rule.createPartition(max: max) {
                partitions.merge(partition, uniquingKeysWith: { a, b in a + b })
            }
        }
        return partitions
    }

    func evaluate(ratings: Ratings) -> String {
        // print("Rules: \(rules)")
        // for rating in ratings {
        //     if let rule = rules.first(where: { $0.category == rating }) {
        //         if rule.compare(ratings[rating]) {
        //             // print("match \(rating)")
        //             return rule.destination
        //         }
        //     }
        // }   
        for rule in rules {
            if let rating = ratings.first(where: { $0 == rule.category }) {
                if rule.compare(ratings[rating]) {
                    // print("match \(rating)")
                    return rule.destination
                }
            }            
        }
        return rules.last(where: { $0.isSentinel })!.destination
    }

    var isAccepted: Bool {
        name == "A"
    }

    var isRejected: Bool {
        name == "R"
    }

    var description: String {
        "{\"\(name)\": \(rules.map({ $0.description }).joined(separator: ">"))}"
    }

    static var accepted: Workflow {
        Workflow(name: "A")
    }

    static var rejected: Workflow {
        Workflow(name: "R")
    }
}

struct WorkflowGroup {
    let workflows: [Workflow]

    init(input: String) {
        var workflows = input.split(separator: "\n").map { Workflow(input: String($0)) }
        workflows.append(contentsOf: [Workflow.accepted, Workflow.rejected])
        self.workflows = workflows
    }

    func run(ratings: Ratings) -> Int {
        var workflow = startWorkflow
        while workflow != nil && !workflow!.isAccepted && !workflow!.isRejected {
            if let nextWorkflowName = workflow?.evaluate(ratings: ratings) {
                //print("Next: \(nextWorkflowName)")
                workflow = workflows.first(where: { $0.name == nextWorkflowName })
            }
            else {
                workflow = nil
            }
        }

        return (workflow?.isAccepted ?? false) ? ratings.value : 0
    }

    func createPartitions(max: Int) -> [String:Partition] {
        var partitions = Dictionary<String, Partition>()
        for workflow in workflows {
            partitions.merge(workflow.createPartitions(max: max),
                             uniquingKeysWith: { a, b in a + b })
        }

        var mergedPartitions = Dictionary<String, Partition>()
        for (key, list) in partitions {
            let uniqueValues = Set<Int>(list.flatMap({ [$0.startIndex, $0.endIndex] }))
            var last: Int? = nil
            let sorted = Array(uniqueValues).sorted().flatMap({ value in
                let range = last == nil ? [] : [(last ?? 1)..<value]
                last = value
                return range
            })
            mergedPartitions[key] = sorted
        } 
        return mergedPartitions
    }


    var startWorkflow: Workflow? {
        workflows.first(where: { $0.name == "in" })
    }
}

struct Ratings: CustomStringConvertible, Sequence {
    let ratings: [String:Int]    
    let names: [String]

    init(x: Int, m: Int, a: Int, s: Int) {
        self.ratings = ["x": x, "m": m, "a": a, "s": s]
        self.names = ["x", "m", "a", "s"]
    }

    init(input: String) {
        let trimmed = input[input.index(input.startIndex, offsetBy: 1)..<input.index(input.endIndex, offsetBy: -1)]
        let ratings = trimmed.split(separator: ",").map { String($0) }.map { let parts = $0.split(separator: "="); return (String(parts[0]), Int(parts[1])! ) }
        self.names = ratings.map { $0.0 }
        self.ratings = Dictionary<String, Int>(ratings, uniquingKeysWith: { (k, _) in k })
    }

    func rating(name: String) -> Int? {
        return ratings.first(where: { k, _ in k == name })?.value
    }

    var value: Int {
        return ratings.values.reduce(0, { $0 + $1 })
    }

    subscript(name: String) -> Int {
        return ratings[name] ?? 0
    }

    func makeIterator() -> Array<String>.Iterator {
        return names.makeIterator()
    }

    var description: String {
        "(" + names.map({ "\($0)=\(ratings[$0]!)" }).joined(separator: ", ") + " -> \(value))"
    }
}

extension Range<Int>: Comparable {
    public static func <(lhs: Range<Int>, rhs: Range<Int>) -> Bool {
        return lhs.startIndex < rhs.startIndex ? true : (lhs.endIndex < rhs.endIndex)
    }
   
}

let inputs = input.split(separator: "\n\n")
let workflowGroup = WorkflowGroup(input: String(inputs.first!))
let allRatings = inputs.last!.split(separator: "\n").map { Ratings(input: String($0)) }

print(workflowGroup.workflows)

var value = 0
for ratings in allRatings {
    print(ratings, terminator: " -> ")
    let run = workflowGroup.run(ratings: ratings)
    print(run)
    value += run 
}
print()
print("Result: \(value)")

var combinations = 0
let partitions = workflowGroup.createPartitions(max: 4000)
print(partitions["x"]!.count)
print(partitions["m"]!.count)
print(partitions["a"]!.count)
print(partitions["s"]!.count)
for xRange in partitions["x"]! {
    print("x")
    for mRange in partitions["m"]! {
        print("m")
        for aRange in partitions["a"]! {
            for sRange in partitions["s"]! {
                //print(xRange, mRange, aRange, sRange)
                let ratings = Ratings(x: xRange.startIndex, m: mRange.startIndex, a: aRange.startIndex, s: sRange.startIndex)
                let run = workflowGroup.run(ratings: ratings)
                if run > 0 {
                    combinations += (xRange.count-1) * (mRange.count-1) * (aRange.count-1) * (sRange.count-1)
                }
            }
        }
    }
}
print()
print("All Combinations: \(combinations)")


