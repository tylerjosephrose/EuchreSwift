//
//  CardButton.swift
//  EuchreSwift
//
//  Created by Tyler Rose on 12/11/16.
//  Copyright © 2016 Tyler Rose. All rights reserved.
//

import UIKit

class CardButton: UIButton {
	private var m_image: UIImage?
	private var m_card: Card?
	
	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)!
	}
	
	func SetUp(card: Card) {
		m_card = card
		if card.GetValue() == .Ten {
			let imageName = "10_of_" + card.SuitToString().lowercased()
			m_image = UIImage(named: imageName)
		}
		else if card.GetValue() == .Nine {
			let imageName = "9_of_" + card.SuitToString().lowercased()
			m_image = UIImage(named: imageName)
		}
		else if card.GetValue() == .Ace {
			let imageName = card.ValueToString().lowercased() + "_of_" + card.SuitToString().lowercased()
			m_image = UIImage(named: imageName)
		}
		else {
			let imageName = card.ValueToString().lowercased() + "_of_" + card.SuitToString().lowercased() + "2"
			m_image = UIImage(named: imageName)
		}
		self.setImage(m_image, for: UIControlState.normal)
	}
	
	func GetCard() -> Card {
		return m_card!
	}
}
