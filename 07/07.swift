import Foundation
import Darwin

guard let input = try? String(contentsOf:URL(filePath: "input.txt"), encoding: .utf8) else { 
    print("No input")
    exit(0)
}


class Hand: Comparable, Equatable, CustomStringConvertible {
    let cards: [String]
    let bid: Int

    init(cards: [String], bid: Int) {
        self.cards = cards
        self.bid = bid
    }

    init(cardsInput: String, bid: Int) {
        self.cards = cardsInput.split(separator: "").map({ String($0) })
        self.bid = bid
    }

    var description: String {
        "{\(cards.joined(separator: "")) =\(strength) $\(bid)}"
    }

    var strength: Int {
        var perCard: [String: Int] = [:]

        for card in cards {
            if perCard.keys.contains(card) {
                perCard[card]! += 1
            }
            else {
                perCard[card] = 1
            }
        }

        var perStrength: [Int:[String]] = [:]
        for (card, count) in perCard {
            if perStrength.keys.contains(count) {
                perStrength[count]!.append(card)
            }
            else {
                perStrength[count] = [card]
            }
        }

        perStrength = transform(perStrength: perStrength)

        if let _ = perStrength[5] {
            return 6            
        }
        else if let _ = perStrength[4] {
            return 5            
        }
        else if let _ = perStrength[3], let _ = perStrength[2] {
            return 4            
        }
        else if let _ = perStrength[3] {
            return 3
        }
        else if let twos = perStrength[2], twos.count >= 2 {
            return 2
        }
        else if let _ = perStrength[2] {
            return 1
        }
        else {
            return 0
        }
    }

    func transform(perStrength: [Int:[String]]) -> [Int:[String]] {
        return perStrength
    }

    static func < (lhs: Hand, rhs: Hand) -> Bool {
        if lhs.strength == rhs.strength {
            for i in 0..<lhs.cards.count {
                let score = lhs.scoreVs(index: i, otherHand: rhs)
                if score < 0 {
                    return true
                }
                else if score > 0 {
                    return false
                }
            }
            return false            
        }
        else {
            return lhs.strength < rhs.strength
        }
    }

    static func == (lhs: Hand, rhs: Hand) -> Bool {
        if lhs.strength != rhs.strength {
            for i in 0..<lhs.cards.count {
                let score = lhs.scoreVs(index: i, otherHand: rhs)
                if score == 0 {
                    return true
                }
            }
            return false            
        }
        else {
            return true
        }
    }

    var scoreValues: [String:Int] {
        ["2": 2, "3": 3, "4": 4, "5": 5, "6": 6, "7": 7, "8": 8, "9": 9, "T": 10, "J": 11, "Q": 12, "K": 13, "A": 14]
    }

    func scoreVs(index: Int, otherHand: Hand) -> Int {
        if let score1 = scoreValues[self.cards[index]] {
            if let score2 = scoreValues[otherHand.cards[index]] {
                return score1 == score2 ? 0 : (score1 < score2 ? -1 : 1) 
            }
            else {
                return 1
            }
        }
        else {
            if let _ = scoreValues[otherHand.cards[index]] {
                return -1
            }
            else {
                return 0
            }
        }
    }
}

class JokerHand: Hand {
    override var scoreValues: [String:Int] {
        ["J": 1, "2": 2, "3": 3, "4": 4, "5": 5, "6": 6, "7": 7, "8": 8, "9": 9, "T": 10, "Q": 12, "K": 13, "A": 14]
    }

    override func transform(perStrength: [Int:[String]]) -> [Int:[String]] {
        var newPerStrength = perStrength

        for si in 1...4 {
            if let src = perStrength[si], src.contains("J") {
                newPerStrength[si]!.removeAll(where: { $0 == "J" })
                if (newPerStrength[si]?.count == 0) {
                    newPerStrength[si] = nil
                }
                for di in (1...5).reversed() {
                    if var dst = newPerStrength[di] {
                        newPerStrength[di] = nil
                        dst.removeAll(where: { $0 == "J" })
                        if newPerStrength.keys.contains(di+si) {
                            newPerStrength[di+si]!.append(contentsOf: dst)
                        }
                        else {
                            newPerStrength[di+si] = dst
                        }
                        print("!! \(format(perStrength)) -> \(format(newPerStrength))")
                        return newPerStrength
                    }
                }
            }
        }
        print("   \(format(perStrength)) -> \(format(newPerStrength))")
        return newPerStrength
    }
}

func format(_ perStrength: [Int:[String]]) -> String {
    var result = ""
    for s in perStrength.keys.sorted() {
        for c in perStrength[s]! {
            result += "\(s):\(c)/"
        }
    }
    result.removeLast()
    result += "="
    for s in perStrength.keys.sorted() {
        for c in perStrength[s]! {
            result += String(repeating: c, count: s)
        }
    }
    return result
}

let hands = input
    .split(separator: "\n")
    .map({ String($0).split(separator: " ") })
    .map({ Hand(cardsInput: String($0[0]), bid: Int(String($0[1]))!) })
    .sorted()

func winnings(_ hands: [Hand]) -> Int {
    hands
        .enumerated()
        .map({ (i, h) in h.bid * (i+1) })
        .reduce(0, { $0 + $1 })
}

print("HANDS")
print(hands)
print(winnings(hands))

let jokerHands = input
    .split(separator: "\n")
    .map({ String($0).split(separator: " ") })
    .map({ JokerHand(cardsInput: String($0[0]), bid: Int(String($0[1]))!) })
    .sorted()

print("JOKERHANDS")
print(jokerHands)
print(winnings(jokerHands))

// let fourOfAKind = Hand(cardsInput: "4444T")
// let fiveOfAKind = Hand(cardsInput: "44444")
// let fullHouse = Hand(cardsInput: "KK333")
// let fourOfAKind2 = Hand(cardsInput: "K1111")
// let twoPairs = Hand(cardsInput: "KTTKK")

// print(fourOfAKind == fourOfAKind2)
