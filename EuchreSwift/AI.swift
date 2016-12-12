//
//  AI.swift
//  EuchreSwift
//
//  Created by Tyler Rose on 12/10/16.
//  Copyright © 2016 Tyler Rose. All rights reserved.
//

import Foundation

class AI {
	private var m_bidScoring: Dictionary<Suit, Int> = [:]
	private var m_bestSuit: Suit?
	
	func DeterminePlayableCards(trick: Trick, player: Player, playableCards: inout [Card]) {
		let leftBar = Card(value: Value.Jack, ofSuit: trick.GetLeft())
		
		// Logic for if the card is valid
		if trick.GetLeadPlayer() != player.WhoAmI() {
			for cards in player.m_hand {
				if cards.GetSuit() == trick.GetLeadSuit() && cards != leftBar {
					playableCards.append(cards)
				}
				if trick.GetLeadSuit() == trick.GetTrump() && cards == leftBar {
					playableCards.append(cards)
				}
			}
			if playableCards.count == 0 {
				for cards in player.m_hand {
					playableCards.append(cards)
				}
			}
		}
		else {
			for cards in player.m_hand {
				playableCards.append(cards)
			}
		}
	}
	
	func DetermineBestCard(trick: Trick, player: Player, playableCards: inout [Card]) -> Card {
		// This does NOT look at the cards played already to find the best match!!
		// This is also heavily dependent on the hand being sorted according to trump
		
		// There should always be at least one card that is playable
		assert(playableCards.count != 0, "There are no playable Cards! Uh Oh!")
		
		let leftBar = Card(value: Value.Jack, ofSuit: trick.GetLeft())
		let rightBar = Card(value: Value.Jack, ofSuit: trick.GetTrump())
		let trump = trick.GetTrump()
		
		// If no choices then play the card
		if playableCards.count == 1 {
			return playableCards[0]
		}
		
		// Leading and it is the first hand or leading and not the bidder
		if trick.GetLeadPlayer() == player.WhoAmI() && (player.m_hand.count == 6 || trick.GetBidder() != player.WhoAmI()) {
			// Hold on to one card in case player is leading with all trump but no right bar
			let tempCard = playableCards[0]
			for i in 0...playableCards.count - 1 {
				if playableCards[i] == rightBar {
					return playableCards[i]
				}
				if playableCards[i].GetSuit() == trump || playableCards[i] == leftBar {
					playableCards.remove(at: i)
					continue
				}
				if playableCards[i].GetValue() == Value.Ace {
					return playableCards[i]
				}
			}
			if playableCards.count == 0 {
				return tempCard
			}
			else {
				// If tehre are no good cards then just play a random card left
				playableCards.shuffle()
				return playableCards[0]
			}
		}
		
		// Leading and bidder
		else if trick.GetLeadPlayer() == player.WhoAmI() && trick.GetBidder() == player.WhoAmI() {
			for cards in playableCards {
				if cards.GetSuit() == trump || cards == leftBar {
					return cards
				}
				if cards.GetValue() == Value.Ace {
					return cards
				}
			}
			// No trump or aces left so lets bank on partner help
			return playableCards[0]
		}
		// Not leading
		else {
			if trick.GetLeadSuit() != trump {
				var trumpCard: Card?
				for cards in playableCards {
					if cards.GetSuit() == trump || cards == leftBar {
						trumpCard = cards
					}
					if cards.GetSuit() == trick.GetLeadSuit() && cards.GetValue() == Value.Ace {
						return cards
					}
				}
				if (trumpCard != nil) {
					return trumpCard!
				}
				else {
					return playableCards[playableCards.count - 1]
				}
			}
		}
		assert(true, "Should never get to this part of DetermineBestCard")
		return Card(value: Value.Nine, ofSuit: Suit.Hearts)
	}
	
	func AIPlayCard(trick: Trick, player: Player) {
		var playableCards = [Card]()
		DeterminePlayableCards(trick: trick, player: player, playableCards: &playableCards)
		
		let toPlay = DetermineBestCard(trick: trick, player: player, playableCards: &playableCards)
		trick.SetCard(card: toPlay)
		
		//erase the played card
		var cardnum = -1
		for cards in player.m_hand {
			cardnum += 1
			if cards == toPlay {
				player.m_hand.remove(at: cardnum)
				break
			}
		}
	}
	
	
	func AIBid(trick: Trick, player: Player, currentBid: inout Int) {
		// Bidding for the AI will work by scoring the hand based on each suit. A given score will result in the bid amount and the suit picked 
		// or no pick
		m_bidScoring.removeAll()
		BidScoring(trick: trick, player: player)
		
		// Is this the last player with no curret bid?
		var forceBid = false
		if player.WhoAmI() == Owner(rawValue: (trick.GetLeadPlayer().rawValue + 3) % 4)! {
			forceBid = true
		}
		
		var highest = 0
		assert((m_bidScoring.count) < 6 && (m_bidScoring.count) > 0, "bidScoring should not have more than 6 choices")
		
		for (suit,value) in m_bidScoring {
			if value > highest {
				highest = value
				m_bestSuit = suit
			}
		}
		
		if highest > 88 {
			if currentBid < 8 {
				currentBid = 8
			}
		}
		else if highest > 80 {
			if currentBid < 7 {
				currentBid = 7
			}
		}
		else if highest > 75 {
			if currentBid < 5 {
				currentBid = 5
			}
		}
		else if highest > 62 {
			if currentBid < 4 {
				currentBid = 4
			}
		}
		else if highest > 55 || forceBid {
			if currentBid < 3 {
				currentBid = 3
			}
		}
		else {
			return
		}
	}
	
	func BidScoring(trick: Trick, player: Player) {
		// Score the hand on each suit
		for i in 1...4 {
			var score = 0
			let right = Suit(rawValue: i)!
			let left = Trick.GetLeft(suit: right)
			let leftBar = Card(value: Value.Jack, ofSuit: left)
			
			for cards in player.m_hand {
				if cards == leftBar {
					score += 20
					continue
				}
				if cards.GetSuit() == right {
					if cards.GetValue() == Value.Jack {
						score += 40
						continue
					}
					if cards.GetValue() == Value.Ace {
						score += 10
						continue
					}
					if cards.GetValue() == Value.King {
						score += 9
						continue
					}
					if cards.GetValue() == Value.Queen {
						score += 8
						continue
					}
					if cards.GetValue() == Value.Ten {
						score += 7
						continue
					}
					if cards.GetValue() == Value.Nine {
						score += 6
						continue
					}
					else {
						assert(true, "If it was trump, it should have gotten caught (BidScoring)")
					}
				}
				else if cards.GetValue() == Value.Ace {
					score += 5
					continue
				}
			}
			m_bidScoring[right] = score
		}
		
		// Score the hand on high
		if GameSettings.AllowHigh {
			var score = 0
			if trick.GetLeadPlayer() == player.WhoAmI() {
				score += 10
			}
			
			var Aces = [Suit]()
			var AceKings = [Suit]()
			
			for cards in player.m_hand {
				if cards.GetValue() == .Ace {
					score += 20
					Aces.append(cards.GetSuit())
					continue
				}
				else if cards.GetValue() == .King {
					score += 10
					for suits in Aces {
						if suits == cards.GetSuit() {
							score += 5
							AceKings.append(cards.GetSuit())
							continue
						}
					}
				}
				else if cards.GetValue() == .Queen {
					score += 2
					for suits in AceKings {
						if suits == cards.GetSuit() {
							score += 5
							continue
						}
					}
				}
			}
			m_bidScoring[.High] = score
		}
		// Score the hand on low
		if GameSettings.AllowLow {
			
		}
	}
	
	func AIFinalizeBid(trick: Trick) {
		trick.SetTrump(trump: m_bestSuit!)
	}
	
	func AIPassCard(trick: Trick, player: Player) -> Card {
		var trumpCards = [Card]()
		var offAces = [Card]()
		
		for cards in player.m_hand {
			let leftBar = Card(value: .Jack, ofSuit: trick.GetLeft())
			let rightBar = Card(value: .Jack, ofSuit: trick.GetTrump())
			if cards == leftBar || cards == rightBar {
				let tempCard = cards
				CleanupHand(player: player)
				return tempCard
			}
			if cards.GetSuit() == trick.GetTrump() {
				trumpCards.append(cards)
			}
			if cards.GetValue() == .Ace && cards.GetSuit() != trick.GetTrump() {
				offAces.append(cards)
			}
		}
		if trumpCards.count > 0 {
			let tempCard = trumpCards[0]
			CleanupHand(player: player)
			return tempCard
		}
		else if offAces.count > 0 {
			let tempCard = offAces[0]
			CleanupHand(player: player)
			return tempCard
		}
		else {
			let tempCard = player.m_hand[0]
			CleanupHand(player: player)
			return tempCard
		}
	}
	
	func AITakeCard(trick: Trick, player: Player, card: Card) {
		var cardnum = -1
		var lastCard = 0
		let leftBar = Card(value: .Jack, ofSuit: trick.GetLeft())
		var possibilities = [Card]()
		
		for cards in player.m_hand {
			cardnum += 1
			if cards.GetSuit() != trick.GetTrump() && cards != leftBar && cards.GetValue() != .Ace {
				possibilities.append(cards)
				lastCard = cardnum
			}
		}
		
		let tempCard: Card?
		if possibilities.count > 0 {
			tempCard = possibilities.last
			player.m_hand.remove(at: lastCard)
			card.SetOwner(owner: (tempCard?.GetOwner())!)
			Deck.GetInstance().Return(card: tempCard!)
			player.m_hand.append(card)
		}
		else {
			tempCard = player.m_hand.last
			player.m_hand.removeLast()
			card.SetOwner(owner: (tempCard?.GetOwner())!)
			Deck.GetInstance().Return(card: tempCard!)
			player.m_hand.append(card)
		}
	}
	
	func CleanupHand(player: Player) {
		while player.m_hand.count > 0 {
			let tempCard = player.m_hand[0]
			player.m_hand.removeLast()
			Deck.GetInstance().Return(card: tempCard)
		}
	}
}
