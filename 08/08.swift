import Foundation
import Darwin

guard let input = try? String(contentsOf:URL(filePath: "input.txt"), encoding: .utf8) else { 
    print("No input")
    exit(0)
}

struct Node: CustomStringConvertible {
    let id: String 
    let left: String 
    let right: String 

    var description: String {
        "\(id) -> (\(left), \(right))"
    }

    func toDirection(_ direction: String) -> String {
        if direction == "L" {
            return left
        }
        else if (direction == "R") {
            return right
        }
        else {
            fatalError()
        }
    }

    func traverse() -> Int {
        var currentDirectionIndex = 0
        var steps = 0
        var currentNode: Node? = self

        while (currentNode != nil && !currentNode!.id.hasSuffix("Z")) {
            steps += 1
            print("\(directions[currentDirectionIndex]) -- \(currentNode!)")
            currentNode = nodes.first(where: { $0.id == currentNode!.toDirection(directions[currentDirectionIndex]) })
            currentDirectionIndex = (currentDirectionIndex+1) % directions.count 
        }

        return steps
    }
}


let lines = input.split(separator: "\n")
let directions = lines[0].split(separator: "").map({ String($0) })

var nodes: [Node] = []
for nodeLine in lines[1..<lines.count] {
    if let data = try? /(.+?)\s+=\s+\((.+?),\s+(.+?)\)/.wholeMatch(in: nodeLine) {
        let node = Node(id: String(data.output.1), left: String(data.output.2), right: String(data.output.3))
        nodes.append(node)
    }
} 

// print(directions)
// print(nodes)

// part 1
print("Part 1: \(nodes.first(where: { $0.id == "AAA" })?.traverse() ?? 0)")

// part 2
var currentDirectionIndex = 0
var steps = 0
var traversingNodes: [Node] = nodes.filter({ $0.id.hasSuffix("A") })
while (!traversingNodes.allSatisfy({ $0.id.hasSuffix("Z") })) {
    for i in 0..<traversingNodes.count {
        // print("# \(directions[currentDirectionIndex]) -- \(traversingNodes[i])")
        let toNodeId = traversingNodes[i].toDirection(directions[currentDirectionIndex])
        traversingNodes[i] = nodes.first(where: { $0.id == toNodeId })!
    }
    currentDirectionIndex = (currentDirectionIndex+1) % directions.count 
    steps += 1
    if (steps % 10000 == 0) {
        print(steps)
    }
}

print("Part 2: \(steps)")