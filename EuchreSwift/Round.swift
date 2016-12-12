//
//  Round.swift
//  EuchreSwift
//
//  Created by Tyler Rose on 12/10/16.
//  Copyright © 2016 Tyler Rose. All rights reserved.
//

import Foundation

class Round {
	private var m_teamBid: Int
	private var m_bidAmount: Int?
	private var m_currentBid: Int?
	private var m_playerBid: Int?
	private var m_currentTrick = Trick()
	
	init(LeadPlayer: Owner) {
		m_currentTrick.SetLeadPlayer(owner: LeadPlayer)
		m_teamBid = 0
	}
	
	func PlayRound(Players: inout [Player], Points: inout [Int]) {
		Players[0].GetHand()
		Players[1].GetHand()
		Players[2].GetHand()
		Players[3].GetHand()
		
		GetBids(Players: &Players)
		
		var Team1Tricks = 0
		var Team2Tricks = 0
		
		if m_bidAmount == 7 {
			SetUpShoot(Players: &Players)
		}
		if m_bidAmount! > 6 {
			for _ in 0...5 {
				if m_currentTrick.GetWinner() != .InPlay {
					m_currentTrick.SetLeadPlayer(owner: m_currentTrick.GetWinner())
				}
				
				PlayTrickLone(Players: &Players)
				
				m_currentTrick.Evaluate()
				if m_currentTrick.GetWinner() == .Player_1 || m_currentTrick.GetWinner() == .Player_3 {
					Team1Tricks += 1
				}
				else {
					Team2Tricks += 1
				}
			}
		}
		else {
			for _ in 0...5 {
				if m_currentTrick.GetWinner() != .InPlay {
					m_currentTrick.SetLeadPlayer(owner: m_currentTrick.GetWinner())
				}
				
				PlayTrick(Players: &Players)
				
				m_currentTrick.Evaluate()
				if m_currentTrick.GetWinner() == .Player_1 || m_currentTrick.GetWinner() == .Player_3 {
					Team1Tricks += 1
				}
				else {
					Team2Tricks += 1
				}
			}
		}
		SetScore(team1Tricks: Team1Tricks, team2Tricks: Team2Tricks, Points: &Points)
	}
	
	func GetBids(Players: inout [Player]) {
		let lead = m_currentTrick.GetLeadPlayer().rawValue
		m_currentBid = 2
		var playerUp = 0
		var player = (lead - 1) % 4
		
		for i in 0...3 {
			playerUp = (lead + i) % 4
			var j = 1
			if playerUp != 0 {
				let temp = m_currentBid
				Players[playerUp].myAI.AIBid(trick: m_currentTrick, player: Players[playerUp], currentBid: &m_currentBid!)
				if m_currentBid == 8 {
					FinalizeBid(playerBid: playerUp, Players: &Players)
					break
				}
				if temp != m_currentBid {
					player = playerUp
				}
				j = 0
			}
			while j == 1 {
				// Print current bid info
				if m_currentBid == 2 {
					print("There is no current bid")
				}
				else {
					print("The current bid is: \(m_currentBid) by Player \(player + 1)")
				}
				print("Player \(playerUp + 1), place a bid. (enter 0 to pass)")
				print("Options are 3, 4, 5, shoot, alone")
				// Print hand of player
				Players[playerUp].PrintHand()
				// Take input of card here instead of force
				let propose = "3"
				
				// Not bidding and not the last player to go with no previous bid
				if propose.caseInsensitiveCompare("0") == .orderedSame && i != 3 {
					j = 0
					break
				}
				// not bidding and is teh last player with no previous bid
				if propose.caseInsensitiveCompare("0") == .orderedSame && i == 3 && m_currentBid == 2 {
					print("You are last and no one has made a bid. You must bid")
					m_currentBid = 3
					j = 1
				}
				// Not bidding and last player but there is already a bid
				if propose.caseInsensitiveCompare("0") == .orderedSame && i == 3 {
					j = 0
					break
				}
				if propose.caseInsensitiveCompare("alone") == .orderedSame {
					m_currentBid = 8
					player = playerUp
					m_bidAmount = m_currentBid
					FinalizeBid(playerBid: player, Players: &Players)
					return
				}
				else if propose.caseInsensitiveCompare("shoot") == .orderedSame {
					j = 0
					m_currentBid = 7
					player = playerUp
				}
				else if Int(propose)! > m_currentBid! {
					if Int(propose)! > 8 {
						print("Not a valid bid")
						j = 1
					}
					else {
						j = 0
						m_currentBid = Int(propose)!
						player = playerUp
					}
				}
				else if Int(propose)! < m_currentBid! {
					print("You did not bid high enough")
					j = 1
				}
			}
		}
		m_playerBid = player
		m_bidAmount = m_currentBid
		FinalizeBid(playerBid: player, Players: &Players)
	}
	
	func FinalizeBid(playerBid: Int, Players: inout [Player]) {
		switch playerBid {
		case 0:
			m_teamBid = 1
			break
		case 1:
			m_teamBid = 2
			break
		case 2:
			m_teamBid = 1
			break
		case 3:
			m_teamBid = 2
			break
		default:
			assert(true, "One of the teams should have made a bid (FinalizeBid)")
			break
		}
		
		if playerBid != 0 {
			Players[playerBid].myAI.AIFinalizeBid(trick: m_currentTrick)
			m_currentTrick.SetBidder(owner: Owner(rawValue: playerBid)!)
			for players in Players {
				players.SortHand(trump: m_currentTrick.GetTrump())
			}
			return
		}
		
		var input: String?
		print("Player \(playerBid + 1), What suit do you want?")
		// Need to get input from UI
		input = "Spades"
		
		if input?.caseInsensitiveCompare("Hearts") == .orderedSame {
			m_currentTrick.SetTrump(trump: .Hearts)
		}
		if input?.caseInsensitiveCompare("Spades") == .orderedSame {
			m_currentTrick.SetTrump(trump: .Spades)
		}
		if input?.caseInsensitiveCompare("Diamonds") == .orderedSame {
			m_currentTrick.SetTrump(trump: .Diamonds)
		}
		if input?.caseInsensitiveCompare("Clubs") == .orderedSame {
			m_currentTrick.SetTrump(trump: .Clubs)
		}
		if input?.caseInsensitiveCompare("High") == .orderedSame {
			if GameSettings.AllowHigh {
				m_currentTrick.SetTrump(trump: .High)
			}
			else {
				print("High is not allowed in your settings. Try a different suit")
				FinalizeBid(playerBid: playerBid, Players: &Players)
			}
		}
		if input?.caseInsensitiveCompare("Low") == .orderedSame {
			if GameSettings.AllowLow {
				m_currentTrick.SetTrump(trump: .Low)
			}
			else {
				print("Low is not allowed in your settings. Try a different suit")
				FinalizeBid(playerBid: playerBid, Players: &Players)
			}
		}
		m_currentTrick.SetBidder(owner: Owner(rawValue: playerBid)!)
		for players in Players {
			players.SortHand(trump: m_currentTrick.GetTrump())
		}
	}

	func PlayTrick(Players: inout [Player]) {
		let lead = m_currentTrick.GetLeadPlayer().rawValue
		for i in 0...3 {
			let playerUp = (lead + i) % 4
			var good = 1
			if playerUp != 0 {
				Players[playerUp].myAI.AIPlayCard(trick: m_currentTrick, player: Players[playerUp])
			}
			else {
				while good != 0 {
					good = AskPlayCard(trick: m_currentTrick, player: Players[playerUp])
				}
			}
		}
	}
	
	private func PlayTrickLone(Players: inout [Player]) {
		let lead = m_currentTrick.GetLeadPlayer().rawValue
		
		for i in 0...3 {
			let playerUp = (lead + i) % 4
			if playerUp == (m_playerBid! + 2) % 4 {
				continue
			}
			var good = 1
			print("This is \(Players[playerUp].WhoAmI())")
			if playerUp != 0 {
				Players[playerUp].myAI.AIPlayCard(trick: m_currentTrick, player: Players[playerUp])
			}
			else {
				while good == 1 {
					good = AskPlayCard(trick: m_currentTrick, player: Players[playerUp])
				}
			}
		}
	}
	
	private func AskPlayCard(trick: Trick, player: Player) -> Int {
		print("Trump is \(trick.GetTrump())")
		print("The cards played so far are:")
		trick.PrintTrick()
		print("Pick what card number you want to play")
		player.PrintHand()
		let choice = 1
		// Get choice from UI
		let result = player.PlayCard(choice: choice, trick: m_currentTrick)
		if result == 1 {
			print("Did not follow Lead Suit of \(trick.GetLeadSuit())")
			return 1
		}
		else if result == 2 {
			print("Picked a card not in your hand")
			return 2
		}
		return 0
	}
	
	private func SetUpShoot(Players: inout [Player]) {
		let givingPlayer = (m_playerBid! + 2) % 4
		var tempCard: Card?
		if givingPlayer != 0 {
			tempCard = Players[givingPlayer].myAI.AIPassCard(trick: m_currentTrick, player: Players[givingPlayer])
		}
		else {
			print("Your teammate is shooting it in \(m_currentTrick.GetTrump())")
			print("What card will you give them?")
			Players[0].PrintHand()
			let choice = 1
			// Get choice from UI
			tempCard = Players[0].GiveCard(choice: choice)
		}
		
		// This part is for recieving the card
		if m_playerBid != 0 {
			Players[m_playerBid!].myAI.AITakeCard(trick: m_currentTrick, player: Players[m_playerBid!], card: tempCard!)
		}
		else {
			print("Player 1, your teammate is giving you the \(tempCard?.Print())")
			print("What card will you discard for it?")
			Players[0].PrintHand()
			let choice = 1
			// Get choice from UI
			Players[0].TakeCard(card: tempCard!, choice: choice)
			Players[0].SortHand(trump: m_currentTrick.GetTrump())
		}
		
		// Return the other Players hand to the deck
		if givingPlayer == 0 {
			for _ in 0...4 {
				let temp = Players[(m_playerBid! + 2) % 4].GiveCard(choice: 1)
				Deck.GetInstance().Return(card: temp)
			}
		}
	}
	
	func SetScore(team1Tricks: Int, team2Tricks: Int, Points: inout [Int]) {
		// Loner
		if m_bidAmount == 8 {
			if(m_teamBid == 1 && team1Tricks < 6) {
				Points[0] = -12
				Points[1] = team2Tricks
				return
			}
			else if m_teamBid == 2 && team2Tricks < 6 {
				Points[0] = team1Tricks
				Points[1] = -12
				return
			}
			else if m_teamBid == 1 {
				Points[0] = 12
				return
			}
			else {
				Points[1] = 12
				return
			}
		}
		
		// shoot
		if m_bidAmount == 7 {
			if(m_teamBid == 1 && team1Tricks < 6) {
				Points[0] = -8
				Points[1] = team2Tricks
				return
			}
			else if m_teamBid == 2 && team2Tricks < 6 {
				Points[0] = team1Tricks
				Points[1] = -8
				return
			}
			else if m_teamBid == 1 {
				Points[0] = 8
				return
			}
			else {
				Points[1] = 8
				return
			}
		}
		
		// team1 fails bid
		if m_teamBid == 1 && m_bidAmount! > team1Tricks {
			Points[0] = m_bidAmount! * -1
			Points[1] = team2Tricks
			return
		}
		
		// team 2 fails bid
		else if m_teamBid == 2 && m_bidAmount! > team2Tricks {
			Points[0] = team1Tricks
			Points[1] = m_bidAmount! * -1
			return
		}
		
		// either team completes the bid
		else {
			Points[0] = team1Tricks
			Points[1] = team2Tricks
			return
		}
	}
}
