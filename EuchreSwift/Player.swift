//
//  Player.swift
//  EuchreSwift
//
//  Created by Tyler Rose on 12/10/16.
//  Copyright © 2016 Tyler Rose. All rights reserved.
//

import Foundation

class Player {
	private var m_hand = [Card]()
	private var m_whoami: Owner
	
	let myAI: AI
	private static var suits: Dictionary<Suit, Int> = [
		Suit.Hearts : 4,
		Suit.Spades : 3,
		Suit.Diamonds : 2,
		Suit.Clubs : 1
	]
	
	init(player: Owner) {
		m_whoami = player
		myAI = AI()
	}
	
	// Returns status 0: good, 1: not in suit, 2: not valid card
	func PlayCard(choice: Int, trick: Trick) -> Int {
		if choice > m_hand.count || choice < 0 {
			return 2
		}
		
		let card = m_hand[choice - 1]
		let leftBar = Card(value: Value.Jack, ofSuit: trick.GetLeft())
		
		// Determine if the player is allowed to lay this card
		if trick.GetLeadPlayer() != m_whoami {
			var CanFollowSuit = false
			for cards in m_hand {
				if cards.GetSuit() == trick.GetLeadSuit() && cards != leftBar {
					CanFollowSuit = true
					break
				}
				// if this card is left bar and lead is trump
				if cards == leftBar && trick.GetLeadSuit() == trick.GetTrump() {
					CanFollowSuit = true
					break
				}
			}
			
			if CanFollowSuit {
				var validCard = true
				if card.GetSuit() != trick.GetLeadSuit() {
					validCard = false
				}
				if trick.GetLeadSuit() != trick.GetTrump() && card == leftBar {
					validCard = false
				}
				if trick.GetLeadSuit() == trick.GetTrump() && card == leftBar {
					validCard = true
				}
				if !validCard {
					return 1
				}
			}
		}
		trick.SetCard(card: card)
		m_hand.remove(at: choice - 1)
		return 0
	}
	
	func GiveCard(choice: Int) -> Card {
		let tempCard = m_hand[choice - 1]
		m_hand.remove(at: choice - 1)
		return tempCard
	}
	
	func TakeCard(card: Card, choice: Int) {
		// be sure to set ownership to us now
		let tempCard = m_hand[choice - 1]
		m_hand.remove(at: choice - 1)
		card.SetOwner(owner: tempCard.GetOwner())
		Deck.GetInstance().Return(card: tempCard)
		m_hand.append(card)
	}
	
	func GetHand() {
		// Get 6 cards from the deck to my hand for the round
		let deck = Deck.GetInstance()
		for _ in 0...6 {
			let tempCard = deck.DrawCard()
			tempCard.SetOwner(owner: m_whoami)
			m_hand.append(tempCard)
		}
		SortHand()
		return
	}
	
	func PrintHand() {
		var i = 0
		for cards in m_hand {
			i += 1
			print("\(i): \(cards.Print())")
		}
	}
	
	func WhoAmI() -> Owner {
		return m_whoami
	}
	
	func SortHand(trump: Suit = Suit.High) {
		if trump == Suit.High {
			m_hand.sort(by: Player.CompareCards)
		}
		else {
			// Do fancy sort based on Trump
			let preCompareValue = Player.suits[trump]
			Player.suits[trump] = 5
			var swapped = false
			repeat {
				swapped = false
				for i in 0...5 {
					if Player.CompareCardsTrump(c1: m_hand[i + 1], c2: m_hand[i], trump: trump) {
						let tempCard = m_hand[i]
						m_hand[i] = m_hand[i + 1]
						m_hand[i + 1] = tempCard
						swapped = true
					}
				}
			} while swapped
			Player.suits[trump] = preCompareValue
		}
	}
	
	static func CompareCards(c1: Card, c2: Card) -> Bool {
		// Returns true if teh first card is greater than the second card
		// Sorts by suit first (hearts, spades, diamonds, clubs) then by value
		if c1.GetSuit() != c2.GetSuit() {
			return c1.GetSuit().rawValue > c2.GetSuit().rawValue
		}
		else {
			return c1.GetValue().rawValue > c2.GetValue().rawValue
		}
	}
	
	static func CompareCardsTrump(c1: Card, c2: Card, trump: Suit) -> Bool {
		let rightBar = Card(value: Value.Jack, ofSuit: trump)
		let leftBar = Card(value: Value.Jack, ofSuit: Trick.GetLeft(suit: trump))
		// Not the same suit and not dealing with left bar
		if c1.GetSuit() != c2.GetSuit() {
			if !(c1 == leftBar || c2 == leftBar) {
				return Player.suits[c1.GetSuit()]! > Player.suits[c2.GetSuit()]!
			}
		}
		if c1 == rightBar {
			return true
		}
		else if c2 == rightBar {
			return false
		}
		if c1 == leftBar {
			return true
		}
		else if c2 == leftBar {
			return false
		}
		return c1.GetValue().rawValue > c2.GetValue().rawValue
	}
}
