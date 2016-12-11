//
//  BackgroundView.swift
//  EuchreSwift
//
//  Created by Tyler Rose on 12/11/16.
//  Copyright © 2016 Tyler Rose. All rights reserved.
//

import UIKit

class Background: UIView {
	
	override func draw(_ rect: CGRect) {
		let background: UIImage = #imageLiteral(resourceName: "pool-table-felt-texture-and-snooker")
		background.draw(in: rect)
	}
}
