//
//  Interpolatable.swift
//  Pods
//
//  Created by Nicholas Shipes on 5/13/16.
//
//

import Foundation
import QuartzCore

public enum InterpolatableType {
	case CATransform3D
	case CGAffineTransform
	case CGFloat
	case CGPoint
	case CGRect
	case CGSize
	case ColorHSB
	case ColorMonochrome
	case ColorRGB
	case Double
	case Int
	case NSNumber
	case UIEdgeInsets
}

public protocol Interpolatable {
	func vectorize() -> InterpolatableValue
}

extension CATransform3D: Interpolatable {
	public func vectorize() -> InterpolatableValue {
		return InterpolatableValue(type: .CATransform3D, vectors: m11, m12, m13, m14, m21, m22, m23, m24, m31, m32, m33, m34, m41, m42, m43, m44)
	}
}

extension CGAffineTransform: Interpolatable {
	public func vectorize() -> InterpolatableValue {
		return InterpolatableValue(type: .CGAffineTransform, vectors: a, b, c, d, tx, ty)
	}
}

extension CGFloat: Interpolatable {
	public func vectorize() -> InterpolatableValue {
		return InterpolatableValue(type: .CGFloat, vectors: self)
	}
}

extension CGPoint: Interpolatable {
	public func vectorize() -> InterpolatableValue {
		return InterpolatableValue(type: .CGPoint, vectors: x, y)
	}
}

extension CGRect: Interpolatable {
	public func vectorize() -> InterpolatableValue {
		return InterpolatableValue(type: .CGRect, vectors: origin.x, origin.y, size.width, size.height)
	}
}

extension CGSize: Interpolatable {
	public func vectorize() -> InterpolatableValue {
		return InterpolatableValue(type: .CGSize, vectors: width, height)
	}
}

extension Double: Interpolatable {
	public func vectorize() -> InterpolatableValue {
		return InterpolatableValue(type: .Double, vectors: CGFloat(self))
	}
}

extension Int: Interpolatable {
	public func vectorize() -> InterpolatableValue {
		return InterpolatableValue(type: .Int, vectors: CGFloat(self))
	}
}

extension NSNumber: Interpolatable {
	public func vectorize() -> InterpolatableValue {
		return InterpolatableValue(type: .NSNumber, vectors: CGFloat(self))
	}
}

extension UIColor: Interpolatable {
	public func vectorize() -> InterpolatableValue {
		var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
		
		if getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
			return InterpolatableValue(type: .ColorRGB, vectors: red, green, blue, alpha)
		}
		
		var white: CGFloat = 0
		
		if getWhite(&white, alpha: &alpha) {
			return InterpolatableValue(type: .ColorMonochrome, vectors: white, alpha)
		}
		
		var hue: CGFloat = 0, saturation: CGFloat = 0, brightness: CGFloat = 0
		
		getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
		
		return InterpolatableValue(type: .ColorHSB, vectors: hue, saturation, brightness, alpha)
	}
}

extension UIEdgeInsets: Interpolatable {
	public func vectorize() -> InterpolatableValue {
		return InterpolatableValue(type: .UIEdgeInsets, vectors: top, left, bottom, right)
	}
}

public struct InterpolatableValue {
	let type: InterpolatableType
	var vectors: [CGFloat]
	
	init(type: InterpolatableType, vectors: CGFloat...) {
		self.vectors = vectors
		self.type = type
	}
	
	init(type: InterpolatableType, vectors: [CGFloat]) {
		self.vectors = vectors
		self.type = type
	}
	
	func interpolateTo(to: InterpolatableValue, progress: Double) -> InterpolatableValue {
		var diff = [CGFloat]()
		let vectorCount = self.vectors.count
		
		for idx in 0..<vectorCount {
			let val = self.vectors[idx] + (to.vectors[idx] - self.vectors[idx]) * CGFloat(progress)
			diff.append(val)
		}
		
		return InterpolatableValue(type: self.type, vectors: diff)
	}
	
	func toInterpolatable() -> Interpolatable {
		switch type {
		case .CATransform3D:
			return CATransform3D(m11: vectors[0], m12: vectors[1], m13: vectors[2], m14: vectors[3], m21: vectors[4], m22: vectors[5], m23: vectors[6], m24: vectors[7], m31: vectors[8], m32: vectors[9], m33: vectors[10], m34: vectors[11], m41: vectors[12], m42: vectors[13], m43: vectors[14], m44: vectors[15])
		case .CGAffineTransform:
			return CGAffineTransform(a: vectors[0], b: vectors[1], c: vectors[2], d: vectors[3], tx: vectors[4], ty: vectors[5])
		case .CGFloat:
			return vectors[0]
		case .CGPoint:
			return CGPoint(x: vectors[0], y: vectors[1])
		case .CGRect:
			return CGRect(x: vectors[0], y: vectors[1], width: vectors[2], height: vectors[3])
		case .CGSize:
			return CGSize(width: vectors[0], height: vectors[1])
		case .ColorRGB:
			return UIColor(red: vectors[0], green: vectors[1], blue: vectors[2], alpha: vectors[3])
		case .ColorMonochrome:
			return UIColor(white: vectors[0], alpha: vectors[1])
		case .ColorHSB:
			return UIColor(hue: vectors[0], saturation: vectors[1], brightness: vectors[2], alpha: vectors[3])
		case .Double:
			return vectors[0]
		case .Int:
			return vectors[0]
		case .NSNumber:
			return vectors[0]
		case .UIEdgeInsets:
			return UIEdgeInsetsMake(vectors[0], vectors[1], vectors[2], vectors[3])
		}
	}
}