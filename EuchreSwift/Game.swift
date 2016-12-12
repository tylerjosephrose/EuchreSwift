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
	var m_teamOneScore: Int?
	var m_teamTwoScore: Int?
	var winningScore = 32
	var numOfRounds = 0
	var Points = [0, 0]
	private static var m_gameInstance: Game?
	
	static func GetInstance() -> Game {
		if m_gameInstance == nil {
			m_gameInstance = Game()
		}
		// Because of the statement above, this should never return nil
		return m_gameInstance!
	}
	
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
			round.PlayRound(Players: &Players)
			SetScore()
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
	
	func SetScore() {
		m_teamOneScore! += Points[0]
		m_teamTwoScore! += Points[1]
	}
	
	func FinalizeGame() {
		PrintScore()
		
		if m_teamOneScore! > m_teamTwoScore! {
			print("Team 1 won")
		}
		else {
			print("Team 2 won")
		}
	}
}
