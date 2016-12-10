//
//  Deck.swift
//  EuchreSwift
//
//  Created by Tyler Rose on 12/10/16.
//  Copyright © 2016 Tyler Rose. All rights reserved.
//

import Foundation

extension MutableCollection where Indices.Iterator.Element == Index {
	/// Shuffles the contents of this collection.
	mutating func shuffle() {
		let c = count
		guard c > 1 else { return }
		
		for (firstUnshuffled , unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
			let d: IndexDistance = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
			guard d != 0 else { continue }
			let i = index(firstUnshuffled, offsetBy: d)
			swap(&self[firstUnshuffled], &self[i])
		}
	}
}

extension Sequence {
	/// Returns an array with the contents of this sequence, shuffled.
	func shuffled() -> [Iterator.Element] {
		var result = Array(self)
		result.shuffle()
		return result
	}
}

class Deck {
	private var m_cards = [Card]()
	private static var m_deckInstance: Deck?
	
	init() {
		let suits = [Suit.Hearts, Suit.Spades, Suit.Diamonds, Suit.Clubs]
		let values = [Value.Nine, Value.Ten, Value.Jack, Value.Queen, Value.King, Value.Ace]
		for suit in suits {
			for value in values {
				m_cards.append(Card(value: value, ofSuit: suit))
			}
		}
	}
	
	func Shuffle() {
		m_cards.shuffle()
	}
	
	func DrawCard() -> Card {
		assert(m_cards.count != 0, "The Deck doesn't have any more cards!!!")
		let temp = m_cards[m_cards.count - 1]
		m_cards.removeLast()
		return temp
	}
	
	func Return(card: Card) {
		card.SetOwner(owner: Owner.MainDeck)
		m_cards.append(card)
	}
	
	func PrintDeck() {
		for cards in m_cards {
			print("\(cards.ValueToString()) of \(cards.SuitToString())\n")
		}
	}
	
	func DeckSize() -> Int {
		return m_cards.count
	}
	
	static func GetInstance() -> Deck {
		if m_deckInstance == nil {
			m_deckInstance = Deck()
		}
		// Because of the statement above, this should never return nil
			return m_deckInstance!
	}
}
