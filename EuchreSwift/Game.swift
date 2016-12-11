//
//  Game.swift
//  EuchreSwift
//
//  Created by Tyler Rose on 12/10/16.
//  Copyright © 2016 Tyler Rose. All rights reserved.
//

import Foundation

struct GameSettings {
	static var AllowLow = false
	static var AllowHigh = true
	static var ScrewTheDealer = true
}

class Game {
	private var m_teamOneScore: Int?
	private var m_teamTwoScore: Int?
	
	func PlayGame() {
		GameSettings.AllowHigh = true
		GameSettings.AllowLow = false
		GameSettings.ScrewTheDealer = true
		
		let Player1 = Player(player: .Player_1)
		let Player2 = Player(player: .Player_2)
		let Player3 = Player(player: .Player_3)
		let Player4 = Player(player: .Player_4)
		
		var Players = [Player1, Player2, Player3, Player4]
		
		m_teamOneScore = 0
		m_teamTwoScore = 0
		
		// Pick the player to lead
		let lead = (arc4random() % 4) + 1
		
		let WinningScore = 32
		var numOfRounds = 0
		while m_teamOneScore! < WinningScore && m_teamTwoScore! < WinningScore {
			numOfRounds += 1
			Deck.GetInstance().Shuffle()
			print("Round \(numOfRounds)")
			let round = Round(LeadPlayer: Owner(rawValue: Int(lead))!)
			var Points = [0, 0]
			round.PlayRound(Players: &Players, Points: &Points)
			SetScore(Points: &Points)
			PrintScore()
		}
		if m_teamOneScore! > m_teamTwoScore! {
			print("Team 1 won")
		}
		else {
			print("Team 2 won")
		}
	}
	
	func PrintScore() {
		print("Team 1: \(m_teamOneScore)")
		print("Team 2: \(m_teamTwoScore)")
	}
	
	func SetScore(Points: inout [Int]) {
		m_teamOneScore! += Points[0]
		m_teamTwoScore! += Points[1]
	}
}
