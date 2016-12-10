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
			for _ in 0...6 {
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
			for _ in 0...6 {
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
		
		for i in 0...4 {
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
		
	}
	
	func SetScore(team1Tricks: Int, team2Tricks: Int, Points: inout [Int]) {
		
	}
	
	private func AskPlay(trick: Trick, player: Player) -> Int {
		return 0
	}
	
	private func SetUpShoot(Players: inout [Player]) {
		
	}
	
	private func PlayTrickLone(Players: inout [Player]) {
		
	}
}
