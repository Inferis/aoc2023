import Foundation
import Darwin

struct Card: CustomStringConvertible {
    var index: Int = 0
    var winning: [Int] = []
    var played: [Int] = []

    init(source: String) {
        (index, winning, played) = parse(source)
    }

    func parse(_ source: String) -> (Int, [Int], [Int]) {
        let pattern = /Card\s+(\d+):\s+(.+)?\s+\|\s+(.+)?/
        guard let result = try? pattern.wholeMatch(in: source) else {
            return (0, [], [])
        }

        let index = Int(result.output.1) ?? 0
        let winning = result.output.2!.split(separator: " ").map({ Int($0)! })
        let played = result.output.3!.split(separator: " ").map({ Int($0)! })
        return (index, winning, played)
    }

    var matching: [Int] {
        return Array(Set(winning).intersection(played))
    }

    var score: Int {
        return 1 << (matching.count-1)
    }

    var cardCopies: [Int] {
        var cardIndex = index
        var copies: [Int] = []
        for _ in matching {
            cardIndex += 1
            copies.append(cardIndex)
        }
        return copies
    }

    var description: String {
        "\(index)"
    }

    var ordinalIndex: Int {
        index - 1
    }
}

struct CardStack {
    let card: Card
    var count: Int

    mutating func increment(by: Int = 1) {
        count += by
    }
}

class CardPile: CustomStringConvertible {
    var cardStacks: [CardStack]

    init(cards: [Card], count: Int = 0) {
        cardStacks = cards.map( { CardStack(card: $0, count: count)})
    }

    var topCardStack: CardStack? {
        return cardStacks.first(where: { $0.count > 0})
    }

    func removeCardStack(_ cardStack: CardStack) {
        cardStacks[cardStack.card.index-1].count = 0                
    }

    func addCardstack(_ cardStack: CardStack) {
        cardStacks[cardStack.card.index-1].increment(by: cardStack.count)         
    }

    var count: Int {
        cardStacks.reduce(0, { $0 + $1.count })
    }

    var description: String {
        var result = "{"
        for stack in cardStacks {
            if stack.count > 0 {
                if result.count > 1 {
                    result += ", "
                }
                result += "[\(stack.card): \(stack.count)]"
            }
        }        
        result += "}"
        return result
    }
}

guard let input = try? String(contentsOf:URL(filePath: "input.txt"), encoding: .utf8) else { 
    print("No input")
    exit(0)
}

let cardLines = input.split(separator: "\n")

var totalScore = 0
for cardLine in cardLines {
    let card = Card(source: String(cardLine))
    totalScore += card.score
}
print(totalScore)
print()

var allCards = cardLines.map({ Card(source: String($0)) })

var todoPile = CardPile(cards: allCards, count: 1)
var donePile = CardPile(cards: allCards, count: 0)

print("todo = \(todoPile)")
while let cardStack = todoPile.topCardStack {
    print(cardStack.card)

    // add the stack to the done pile
    donePile.addCardstack(cardStack)
    todoPile.removeCardStack(cardStack)
    for copyIndex in cardStack.card.cardCopies {
        let card = allCards[copyIndex-1]
        todoPile.addCardstack(CardStack(card: card, count: cardStack.count))
    }
    print("done = \(donePile)")
    print("todo = \(todoPile)")
}
print(donePile.count)

// var todoPile = allCards.map({ (count: 1, card: $0) })
// var donePile: [Card] = [] 

// for card in allCards {
//     print("\(card): \(card.matching.count) - \(card.cardCopies)")
// }


// print("todo \(todoPile)")
// print()
// while (todoPile.count > 0) {
//     let cardStack = todoPile.removeFirst()
//     for i in cardStack.card.cardCopies {
//         todoPile.append(allCards[i-1])
//     }
//     // print("\(card): \(card.cardCopies)")
//     donePile.append(card) 
//     todoPile.sort(by: { (a, b) in a.index < b.index })
//     print("\(card.cardCopies): \(todoPile.count) -> \(donePile.count)")
//     // print()
// }
//     print(donePile.count)
