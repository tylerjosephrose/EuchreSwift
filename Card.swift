//
//  Card.swift
//  EuchreSwift
//
//  Created by Tyler Rose on 12/9/16.
//  Copyright © 2016 Tyler Rose. All rights reserved.
//

import Foundation

enum Value: Int {
	case Nine = 9, Ten = 10, Jack = 11, Queen = 12, King = 13, Ace = 14
}

enum Suit: Int {
	case Hearts = 1, Spades = 2, Diamonds = 3, Clubs = 4, High = 5, Low = 6
}

enum Owner {
	case Player_1
	case Player_2
	case Player_3
	case Player_4
	case MainDeck
	case InPlay
}

class Card {
	private var m_value: Value
	private var m_suit: Suit
	private var m_owner: Owner
	
	init(value: Value, ofSuit suit: Suit) {
		m_value = value
		m_suit = suit
		m_owner = Owner.MainDeck
	}
	
	func GetValue() -> Value {
		return m_value
	}
	
	func GetSuit() -> Suit {
		return m_suit
	}
	
	func GetOwner() -> Owner {
		return m_owner
	}
	
	func ValueToString() -> String {
		return String(describing: m_value)
	}
	
	func SuitToString() -> String {
		return String(describing: m_suit)
	}
	
	func OwnerToString() -> String {
		return String(describing: m_owner)
	}
	
	func SetOwner(owner: Owner) {
		m_owner = owner
	}
	
	static func ==(left: Card, right: Card) -> Bool {
		if left.GetSuit() == right.GetSuit() && left.GetValue() == right.GetValue() {
			return true
		}
		else {
			return false
		}
	}
	
	static func !=(left: Card, right: Card) -> Bool {
		return left == right
	}
}
