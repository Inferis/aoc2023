import Foundation
import Darwin

class BoardElement: CustomStringConvertible, Hashable
{
    var x: Int
    var y: Int
    private let _length: Int
    private(set) var length: Int {
        get { _length }
        set {}
    }

    init(x: Int, y: Int) {
        self.x = x
        self.y = y
        self._length = 1
    }

    var elementIndices: [(x: Int, y: Int)] {
        var result: [(x: Int, y: Int)] = []
        for i in 0..<length {
            result.append((x: x + i, y: y))
        }
        return result
    }

    var aroundIndices: [(x: Int, y: Int)] {
        var result: [(x: Int, y: Int)] = []
        for iy in -1...1 {
            if (iy == 0) {
                result.append((x: x - 1, y: y))
                result.append((x: x + length, y: y))
            }
            else {
                for ix in -1...length {
                    result.append((x: x + ix, y: y + iy))
                }
            }
        }

        return result
    }

    var description: String {
        return "@(\(x),\(y))-\(length)"
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }

    static func == (lhs: BoardElement, rhs: BoardElement) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y && lhs.length == rhs.length
    }
}

class BoardNumber: BoardElement 
{
    var number: String
    override var length: Int {
        number.count
    }

    override init(x: Int, y: Int) {
        self.number = ""
        super.init(x: x, y: y)
    }

    var value: Int? {
        Int(number)
    }

    func set(_ number: Int) {
        self.number = String(number) + self.number 
    }

    func prepend(_ number: Int) {
        if self.number.count > 0 {
            x -= 1
        }
        self.number = String(number) + self.number 
    }

    func append(_ number: Int) {
        self.number = self.number + String(number) 
    }

    override var description: String {
        return "@(\(x),\(y))-#\(number)"
    }

    override func hash(into hasher: inout Hasher) {
        super.hash(into: &hasher)
        hasher.combine(number)
    }

    static func == (lhs: BoardNumber, rhs: BoardNumber) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y && lhs.number == rhs.number
    }
}



class Board: CustomStringConvertible {
    var data: [[String]]
    let width: Int 
    let height: Int

    init(_ input: String) {
        let lines = input.split(separator: "\n")
        width = lines[0].count + 2
        height = lines.count + 2

        self.data = Array(repeating: Array(repeating: ".", count: width), count: height)
        var y = 1
        for line in lines {
            var x = 1
            for char in line {
                data[y][x] = String(char)
                x += 1
            }
            y += 1
        }
    }

    func numberAt(x: Int, y: Int) -> BoardNumber? {
        let number = BoardNumber(x: x, y: y)
        let line = data[y]
        var tx = x
        var test: Int?

        test = Int(line[tx])
        if test != nil {
            number.set(test!)
        }
        if (test != nil) {        
            tx = x - 1
            repeat {
                test = Int(line[tx])
                if test != nil {
                    number.prepend(test!)
                }
                tx -= 1
            } while (test != nil && tx > 0)

            tx = x + 1
            repeat {
                test = Int(line[tx])
                if test != nil {
                    number.append(test!)
                }
                tx += 1
            } while (test != nil && tx < height)
        }

        return number.value == nil ? nil : number                     
    }

    func includes(number: BoardNumber) -> Bool {
        for index in number.aroundIndices {
            let element = data[index.y][index.x]       
            if element != "." && Int(element) == nil {
                return true
            } 
        }        
        return false
    }

    func includes(gear: BoardElement) -> Bool {
        return numbersAround(element: gear).count == 2
    }

    func numbersAround(element: BoardElement) -> [BoardNumber] {
        var numbers = Set<BoardNumber>()
        for index in element.aroundIndices {
            let element = data[index.y][index.x]       
            if Int(element) != nil {
                if let number = numberAt(x: index.x, y: index.y) {
                    numbers.insert(number)
                }
            } 
        }        
        return Array(numbers)
    }

    func numbersAround(x: Int, y: Int) -> [BoardNumber] {
        return numbersAround(element: BoardElement(x: x, y: y))
    }

    func enumerateGears() -> [BoardElement] {
        var gears: [BoardElement] = []
        for y in 1..<height-1 {
            var x = 1
            while (x < width-1) {
                let gear = BoardElement(x: x, y: y)
                if data[y][x] == "*" {
                    gears.append(gear)
                    x = gear.elementIndices.last!.x + 1
                }
                x += 1
            }
        }
        return gears
    }

    func enumerateNumbers() -> [BoardNumber] {
        var numbers: [BoardNumber] = []
        for y in 1..<height-1 {
            var x = 1
            while (x < width-1) {
                if let number = self.numberAt(x: x, y: y) {
                    numbers.append(number)
                    x = number.elementIndices.last!.x + 1
                }
                x += 1
            }
        }
        return numbers
    }

    var description: String {
        var result = ""
        for y in 0..<height {
            for x in 0..<width {
                result += data[y][x]
            }
            result += "\n"
        }
        return result
    }
}

guard let input = try? String(contentsOf:URL(filePath: "input.txt"), encoding: .utf8) else { 
    print("No input")
    exit(0)
}

let board = Board(input)
//print(board.numberAt(x: 5, y: 1)?.numberIndices)
// if let num = board.numberAt(x: 5, y: 1) {
//     print(board.includes(number: num))
// }

// print(board.numberAt(x: 5, y: 1)?.aroundIndices)
// print(board.enumerateNumbers())
print(board)
// print(board.enumerateNumbers().compactMap({ board.includes(number: $0) ? $0 : nil }))
print(board.enumerateNumbers()
        .compactMap({ board.includes(number: $0) ? $0.value : nil })
        .reduce(0, { $0 + $1 })
)
print(board.enumerateGears()
        .compactMap({ board.includes(gear: $0) ? board.numbersAround(x: $0.x, y: $0.y) : nil })
        .map({ bns in bns.map({ $0.value! }).reduce(1, { $0 * $1 }) })
)
print(board.enumerateGears()
        .compactMap({ board.includes(gear: $0) ? board.numbersAround(x: $0.x, y: $0.y) : nil })
        .map({ bns in bns.map({ $0.value! }).reduce(1, { $0 * $1 }) })
        .reduce(0, { $0 + $1 })
)
