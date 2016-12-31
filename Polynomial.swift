//
//  Polinomial.swift
//  SwiftMath
//
//  Created by Matteo Battaglio on 08/01/15.
//  Copyright (c) 2015 Matteo Battaglio. All rights reserved.
//

import Foundation

extension Double {
    /// self * 1.0i
    public var i: Complex<Double> {
        return Complex<Double>(0.0, self)
    }
}

extension Float {
    /// self * 1.0i
    public var i: Complex<Float> {
        return Complex<Float>(0.0, self)
    }
}

public struct Complex<T: RealType> {
    
    public let (re, im): (T, T)
    
    public let isReal: Bool
    
    public init(_ re: T, _ im: T) {
        self.re = re
        self.im = im
        isReal = im =~ T(0)
    }
    
    public init() {
        self.init(T(0), T(0))
    }
    
    public init(abs: T, arg: T) {
        self.init(abs * arg.cos(), abs * arg.sin())
    }
    
    public static func id() -> Complex<T> {
        return Complex(1.0, 0.0)
    }
    
    public static func zero() -> Complex<T> {
        return Complex(0.0, 0.0)
    }
    
    public var isZero: Bool {
        return re.isZero && im.isZero
    }
    
    /// absolute value thereof
    public var abs: T {
        return re.hypot(im)
    }
    
    /// argument thereof
    public var arg: T {
        return im.atan2(re)
    }
    
    /// norm thereof
    public var norm: T {
        return re.hypot(im)
    }
    
    /// conjugate thereof
    public func conj() -> Complex<T> {
        return Complex(re, -im)
    }
    
    public func reciprocal() -> Complex<T> {
        let length = norm
        return conj() / (length * length)
    }
    
    /// projection thereof
    public func proj() -> Complex<T> {
        if re.isFinite && im.isFinite {
            return self
        } else {
            return Complex(T(1)/T(0), im.isSignMinus ? -T(0) : T(0))
        }
    }
    
    /// (real, imag)
    public var tuple: (T, T) {
        return (re, im)
    }
    
    /// z * i
    public var i: Complex<T> {
        return Complex(-im, re)
    }
    
    /// .hashvalue -- conforms to Hashable
    
}

extension Complex: Hashable {
    
    public var hashValue: Int { // take most significant halves and join
        let bits = sizeof(Int) * 4
        let mask = bits == 16 ? 0xffff : 0x7fffFFFF
        return (re.hashValue & ~mask) | (im.hashValue >> bits)
    }
    
}

public func == <T>(lhs: Complex<T>, rhs: Complex<T>) -> Bool {
    return lhs.re == rhs.re && lhs.im == rhs.im
}

public func == <T>(lhs: Complex<T>, rhs: T) -> Bool {
    return lhs.re == rhs && lhs.im.isZero
}

public func == <T>(lhs: T, rhs: Complex<T>) -> Bool {
    return rhs.re == lhs && rhs.im.isZero
}

extension Complex: CustomStringConvertible {
    
    public var description: String {
        let plus = im.isSignMinus ? "" : "+"
        return "(\(re)\(plus)\(im).i)"
    }
    
}

// operator definitions
infix operator ** { associativity right precedence 170 }
infix operator **= { associativity right precedence 90 }
infix operator =~ { associativity none precedence 130 }
infix operator !~ { associativity none precedence 130 }



// +, +=
public prefix func + <T>(z: Complex<T>) -> Complex<T> {
    return z
}

public func + <T>(lhs: Complex<T>, rhs: Complex<T>) -> Complex<T> {
    return Complex(lhs.re + rhs.re, lhs.im + rhs.im)
}

public func + <T>(lhs: Complex<T>, rhs: T) -> Complex<T> {
    return lhs + Complex(rhs, T(0))
}

public func + <T>(lhs: T, rhs: Complex<T>) -> Complex<T> {
    return Complex(lhs, T(0)) + rhs
}

public func += <T>(inout lhs: Complex<T>, rhs: Complex<T>) {
    lhs = Complex(lhs.re + rhs.re, lhs.im + rhs.im)
}

public func += <T>(inout lhs: Complex<T>, rhs: T) {
    lhs = Complex(lhs.re + rhs, lhs.im)
}

// -, -=
public prefix func - <T>(z: Complex<T>) -> Complex<T> {
    return Complex<T>(-z.re, -z.im)
}

public func - <T>(lhs: Complex<T>, rhs: Complex<T>) -> Complex<T> {
    return Complex(lhs.re - rhs.re, lhs.im - rhs.im)
}

public func - <T>(lhs: Complex<T>, rhs: T) -> Complex<T> {
    return lhs - Complex(rhs, T(0))
}

public func - <T>(lhs: T, rhs: Complex<T>) -> Complex<T> {
    return Complex(lhs, T(0)) - rhs
}

public func -= <T>(inout lhs: Complex<T>, rhs: Complex<T>) {
    lhs = Complex(lhs.re - rhs.re, lhs.im - rhs.im)
}

public func -= <T>(inout lhs: Complex<T>, rhs: T) {
    lhs = Complex(lhs.re - rhs, lhs.im)
}

// *, *=
public func * <T>(lhs: Complex<T>, rhs: Complex<T>) -> Complex<T> {
    return Complex(
        lhs.re * rhs.re - lhs.im * rhs.im,
        lhs.re * rhs.im + lhs.im * rhs.re
    )
}

public func * <T>(lhs: Complex<T>, rhs: T) -> Complex<T> {
    return Complex(lhs.re * rhs, lhs.im * rhs)
}

public func * <T>(lhs: T, rhs: Complex<T>) -> Complex<T> {
    return Complex(lhs * rhs.re, lhs * rhs.im)
}

public func *= <T>(inout lhs: Complex<T>, rhs: Complex<T>) {
    lhs = lhs * rhs
}

public func *= <T>(inout lhs: Complex<T>, rhs: T) {
    lhs = lhs * rhs
}

// /, /=
//
// cf. https://github.com/dankogai/swift-complex/issues/3
//
public func / <T>(lhs: Complex<T>, rhs: Complex<T>) -> Complex<T> {
    if rhs.re.abs >= rhs.im.abs {
        let r = rhs.im / rhs.re
        let d = rhs.re + rhs.im * r
        return Complex (
            (lhs.re + lhs.im * r) / d,
            (lhs.im - lhs.re * r) / d
        )
    } else {
        let r = rhs.re / rhs.im
        let d = rhs.re * r + rhs.im
        return Complex (
            (lhs.re * r + lhs.im) / d,
            (lhs.im * r - lhs.re) / d
        )
        
    }
}

public func / <T>(lhs: Complex<T>, rhs: T) -> Complex<T> {
    return Complex(lhs.re / rhs, lhs.im / rhs)
}

public func / <T>(lhs: T, rhs: Complex<T>) -> Complex<T> {
    return Complex(lhs, T(0)) / rhs
}

public func /= <T>(inout lhs: Complex<T>, rhs:Complex<T>) {
    lhs = lhs / rhs
}

public func /= <T>(inout lhs: Complex<T>, rhs: T) {
    lhs = lhs / rhs
}

// exp(z)
public func exp<T>(z: Complex<T>) -> Complex<T> {
    let abs = z.re.exp()
    let arg = z.im
    return Complex(abs * arg.cos(), abs * arg.sin())
}

// log(z)
public func log<T>(z: Complex<T>) -> Complex<T> {
    return Complex(z.abs.log(), z.arg)
}

// log10(z) -- just because C++ has it
public func log10<T: RealType>(z: Complex<T>) -> Complex<T> {
    return log(z) / T(log(10.0))
}

public func log10<T: RealType>(r: T) -> T {
    return r.log() / T(log(10.0))
}

// pow(b, x)
public func pow<T>(lhs: Complex<T>, _ rhs: Complex<T>) -> Complex<T> {
    if rhs.isZero {
        return Complex(T(1), T(0)) // x ** 0 == 1
    } else if lhs.isZero && rhs.isReal && rhs.re > T(0) {
        return Complex.zero() // 0 ** x == 0 (when x > 0)
    } else if lhs.isReal && lhs.re > T(0) { // b^z == e^(z*ln(b)) (when b is a positive real number)
        let z = log(lhs) * rhs
        return exp(z)
    } else {
        // FIXME: Implement general case of complex powers of complex numbers the right way
        let z = log(lhs) * rhs
        return exp(z)
    }
}

public func pow<T>(lhs: Complex<T>, _ rhs: T) -> Complex<T> {
    return pow(lhs, Complex(rhs, T(0)))
}

public func pow<T>(lhs:T, _ rhs: Complex<T>) -> Complex<T> {
    return pow(Complex(lhs, T(0)), rhs)
}

// **, **=
public func ** <T: RealType>(lhs: T, rhs: T) -> T {
    return lhs.pow(rhs)
}

public func ** <T>(lhs: Complex<T>, rhs: Complex<T>) -> Complex<T> {
    return pow(lhs, rhs)
}

public func ** <T>(lhs: T, rhs: Complex<T>) -> Complex<T> {
    return pow(lhs, rhs)
}

public func ** <T>(lhs: Complex<T>, rhs: T) -> Complex<T> {
    return pow(lhs, rhs)
}

public func **= <T: RealType>(inout lhs: T, rhs: T) {
    lhs = lhs.pow(rhs)
}

public func **= <T>(inout lhs: Complex<T>, rhs: Complex<T>) {
    lhs = pow(lhs, rhs)
}

public func **= <T>(inout lhs: Complex<T>, rhs: T) {
    lhs = pow(lhs, rhs)
}

// sqrt(z)
public func sqrt<T>(z: Complex<T>) -> Complex<T> {
    // return z ** 0.5
    if z.isReal && z.re >= 0.0 {
        return Complex(z.re.sqrt(), 0.0)
    }
    
    let d = z.abs
    let re = ((z.re + d)/T(2)).sqrt()
    if z.im < T(0) {
        return Complex(re, -((-z.re + d)/T(2)).sqrt())
    } else {
        return Complex(re,  ((-z.re + d)/T(2)).sqrt())
    }
}

// cos(z)
public func cos<T>(z: Complex<T>) -> Complex<T> {
    return (exp(z.i) + exp(-z.i)) / T(2)
}

// sin(z)
public func sin<T>(z:Complex<T>) -> Complex<T> {
    return -(exp(z.i) - exp(-z.i)).i / T(2)
}

// tan(z)
public func tan<T>(z: Complex<T>) -> Complex<T> {
    let ezi = exp(z.i), e_zi = exp(-z.i)
    return (ezi - e_zi) / (ezi + e_zi).i
}

// atan(z)
public func atan<T>(z: Complex<T>) -> Complex<T> {
    let l0 = log(T(1) - z.i), l1 = log(T(1) + z.i)
    return (l0 - l1).i / T(2)
}

public func atan<T:RealType>(r: T) -> T {
    return atan(Complex(r, T(0))).re
}

// atan2(z, zz)
func atan2<T>(z: Complex<T>, zz: Complex<T>) -> Complex<T> {
    return atan(z / zz)
}

// asin(z)
public func asin<T>(z: Complex<T>) -> Complex<T> {
    return -log(z.i + sqrt(T(1) - z*z)).i
}

// acos(z)
public func acos<T>(z: Complex<T>) -> Complex<T> {
    return log(z - sqrt(T(1) - z*z).i).i
}

// sinh(z)
public func sinh<T>(z: Complex<T>) -> Complex<T> {
    return (exp(z) - exp(-z)) / T(2)
}

// cosh(z)
public func cosh<T>(z: Complex<T>) -> Complex<T> {
    return (exp(z) + exp(-z)) / T(2)
}

// tanh(z)
public func tanh<T>(z: Complex<T>) -> Complex<T> {
    let ez = exp(z), e_z = exp(-z)
    return (ez - e_z) / (ez + e_z)
}

// asinh(z)
public func asinh<T>(z: Complex<T>) -> Complex<T> {
    return log(z + sqrt(z*z + T(1)))
}

// acosh(z)
public func acosh<T>(z: Complex<T>) -> Complex<T> {
    return log(z + sqrt(z*z - T(1)))
}

// atanh(z)
public func atanh<T>(z: Complex<T>) -> Complex<T> {
    let t = log((1.0 + z)/(1.0 - z))
    return t / 2.0
}

// for the compatibility's sake w/ C++11
public func abs<T>(z: Complex<T>) -> T { return z.abs }
public func arg<T>(z: Complex<T>) -> T { return z.arg }
public func real<T>(z: Complex<T>) -> T { return z.re }
public func imag<T>(z: Complex<T>) -> T { return z.im }
public func norm<T>(z: Complex<T>) -> T { return z.norm }
public func conj<T>(z: Complex<T>) -> Complex<T> { return z.conj() }
public func proj<T>(z: Complex<T>) -> Complex<T> { return z.proj() }

//
// approximate comparisons
//
public func =~ <T>(lhs: Complex<T>, rhs: Complex<T>) -> Bool {
    if lhs == rhs {
        return true
    }
    return lhs.abs =~ rhs.abs
}

public func =~ <T>(lhs: Complex<T>, rhs: T) -> Bool {
    return lhs.abs =~ rhs.abs
}

public func =~ <T>(lhs: T, rhs: Complex<T>) -> Bool {
    return lhs.abs =~ rhs.abs
}

public func !~ <T>(lhs: Complex<T>, rhs: Complex<T>) -> Bool {
    return !(lhs =~ rhs)
}

func !~ <T>(lhs: Complex<T>, rhs: T) -> Bool {
    return !(lhs =~ rhs)
}

func !~ <T>(lhs: T, rhs: Complex<T>) -> Bool {
    return !(lhs =~ rhs)
}

// typealiases
typealias Complex64 = Complex<Double>
typealias Complex32 = Complex<Float>

public protocol RealType: FloatingPointType, Hashable, FloatLiteralConvertible, SignedNumberType, CustomStringConvertible {
    
    init(_ value: Double)
    init(_ value: Float)
    
    // Built-in operators
    
    prefix func + (_: Self) -> Self
    prefix func - (_: Self) -> Self
    func + (_: Self, _: Self) -> Self
    func - (_: Self, _: Self) -> Self
    func * (_: Self, _: Self) -> Self
    func / (_: Self, _: Self) -> Self
    func += (inout _: Self, _: Self)
    func -= (inout _: Self, _: Self)
    func *= (inout _: Self, _: Self)
    func /= (inout _: Self, _: Self)
    
    // Methodized functions for protocol's sake
    
    var abs: Self { get }
    static var epsilon: Self { get }
    func cos() -> Self
    func exp() -> Self
    func log() -> Self
    func sin() -> Self
    func sqrt() -> Self
    func hypot(_: Self) -> Self
    func atan2(_: Self) -> Self
    func pow(_: Self) -> Self
    
    // Constants
    
    static var PI: Self { get }
    static var π: Self { get }
    static var E: Self { get }
    static var e: Self { get }
    static var LN2: Self { get }
    static var LOG2E: Self { get }
    static var LN10: Self { get }
    static var LOG10E: Self { get }
    static var SQRT2: Self { get }
    static var SQRT1_2: Self { get }
}

// MARK: - Constants

extension RealType {
    public var abs: Self { return Swift.abs(self) }
    
    public static var PI: Self { return 3.14159265358979323846264338327950288419716939937510 }
    public static var π: Self { return PI }
    public static var E: Self { return 2.718281828459045235360287471352662497757247093699 }
    public static var e: Self { return E }
    public static var LN2: Self { return 0.6931471805599453094172321214581765680755001343602552 }
    public static var LOG2E: Self { return 1.0 / LN2 }
    public static var LN10: Self { return 2.3025850929940456840179914546843642076011014886287729 }
    public static var LOG10E: Self { return 1.0 / LN10 }
    public static var SQRT2: Self { return 1.4142135623730950488016887242096980785696718753769480 }
    public static var SQRT1_2: Self { return 1.0 / SQRT2 }
}

// MARK: - Double extension to conform to RealType

// Double is default since floating-point literals are Double by default
extension Double: RealType {
    
    public func cos() -> Double { return Foundation.cos(self) }
    public func exp() -> Double { return Foundation.exp(self) }
    public func log() -> Double { return Foundation.log(self) }
    public func sin() -> Double { return Foundation.sin(self) }
    public func sqrt() -> Double { return Foundation.sqrt(self) }
    public func atan2(y: Double) -> Double { return Foundation.atan2(self, y) }
    public func hypot(y: Double) -> Double { return Foundation.hypot(self, y) }
    public func pow(y: Double) -> Double { return Foundation.pow(self, y) }
    
    public static let epsilon = 0x1p-52
}

// MARK: - Float extension to conform to RealType

// But when explicitly typed you can use Float
extension Float: RealType {
    public func cos() -> Float { return Foundation.cos(self) }
    public func exp() -> Float { return Foundation.exp(self) }
    public func log() -> Float { return Foundation.log(self) }
    public func sin() -> Float { return Foundation.sin(self) }
    public func sqrt() -> Float { return Foundation.sqrt(self) }
    public func hypot(y: Float) -> Float { return Foundation.hypot(self, y) }
    public func atan2(y: Float) -> Float { return Foundation.atan2(self, y) }
    public func pow(y: Float) -> Float { return Foundation.pow(self, y) }
    
    public static let epsilon: Float = 0x1p-23
}

//
// approximate comparison
//
public func =~ <T: RealType>(lhs: T, rhs: T) -> Bool {
    if lhs == rhs {
        return true
    }
    return (rhs - lhs).abs < T.epsilon
    //    let epsilon = sizeof(T) < 8 ? 0x1p-23 : 0x1p-52
    //    return t.abs <= T(2) * T(epsilon)
}

public func !~ <T: RealType>(lhs: T, rhs: T) -> Bool {
    return !(lhs =~ rhs)
}

// MARK: CustomStringConvertible

extension RealType {
    
    var description: String {
        if self is Double {
            return (self as! Double).description
        } else {
            return (self as! Float).description
        }
    }
    
}


public struct Polynomial<Real: RealType>: Equatable {
    
    let coefficients: [Real]
    
    /**
    Creates a new instance of `Polynomial` with the given coefficients.
    
    :param: coefficients The coefficients for the terms of the polinomial, ordered from the coefficient for the highest-degree term to the coefficient for the 0 degree term.
    */
    public init(_ coefficients: Real...) {
        self.init(coefficients)
    }
    
    /**
    Creates a new instance of `Polynomial` with the given coefficients.
    
    :param: coefficients The coefficients for the terms of the polinomial, ordered from the coefficient for the highest-degree term to the coefficient for the 0 degree term.
    */
    public init(_ coefficients: [Real]) {
        if coefficients.count == 0 || (coefficients.count == 1 && coefficients[0].isZero) {
            preconditionFailure("the zero polynomial is undefined")
        }
        self.coefficients = coefficients
    }
    
    /// The grade of the polinomial. It's equal to the number of coefficient minus one.
    public var degree: Int {
        return coefficients.count - 1
    }
    
    /// Finds the roots of the polinomial.
    public func roots(preferClosedFormSolution preferClosedFormSolution: Bool = true) -> Multiset<Complex<Real>> {
        if (preferClosedFormSolution && degree <= 4) {
            switch degree {
            case 0:
                return [] // Empty set (i.e. no solutions to `k = 0`, when k != 0)
            case 1:
                return linear()
            case 2:
                return quadratic()
            case 3:
                return cubic()
            case 4:
                return quartic()
            default:
                fatalError("Not reachable")
            }
        } else {
            return durandKernerMethod()
        }
    }
    
    // MARK: Private methods
    
    private func linear() -> Multiset<Complex<Real>> {
        let a = coefficients[0]
        let b = coefficients[1]

        if a.isZero {
            return []
        }
        
        let x = -b/a
        return [Complex(x, 0.0)]
    }
    
    private func quadratic() -> Multiset<Complex<Real>> {
        let a = coefficients[0]
        let b = coefficients[1]
        let c = coefficients[2]
        
        if a.isZero {
            return Polynomial(b, c).roots()
        }
        
        if c.isZero {
            return [Complex.zero()] + Polynomial(a, b).roots()
        }
        
        let discriminant = (b * b) - (4.0 * a * c)
        var dSqrt = sqrt(Complex(discriminant, 0.0))
        if b.isSignMinus {
            dSqrt = -dSqrt
        }
        let x1 = -(b + dSqrt) / (2.0 * a)
        let x2 = c / (a * x1)
        
        return [x1, x2]
    }
    
    private func cubic() -> Multiset<Complex<Real>> {
        let a = coefficients[0]
        var b = coefficients[1]
        var c = coefficients[2]
        var d = coefficients[3]
        
        if a.isZero {
            return Polynomial(b, c, d).roots()
        }
        if d.isZero {
            return [Complex.zero()] + Polynomial(a, b, c).roots()
        }
        if a != Real(1) {
            b /= a
            c /= a
            d /= a
        }
        
        let b2 = b*b
        let b3 = b2*b
        
        let D0 = b2 - (3.0 * c)
        let bc9 = 9.0 * b * c
        let D1 = (2.0 * b3) - bc9 + (27.0 * d)
        let D12 = D1 * D1
        let D03 = D0 * D0 * D0
        let minus27D = D12 - (4.0 * D03)
        var squareRoot = sqrt(Complex(minus27D, 0.0))
        let oneThird: Real = 1.0/3.0
        let zero: Real = 0.0
        
        switch (D0.isZero, minus27D.isZero) {
        case (true, true):
            let x = Complex(-oneThird * b, zero)
            return [x, x, x]
        case (false, true):
            let d9 = 9.0 * d
            let bc4 = 4.0 * b * c
            let x12 = Complex((d9 - b * c) / (2.0 * D0), zero)
            let x3 = Complex((bc4 - d9 - b3) / D0, zero)
            return [x12, x12, x3]
        case (true, false):
            if (D1 + squareRoot) == zero {
                squareRoot = -squareRoot
            }
            fallthrough
        default:
            let C = pow(0.5 * (D1 + squareRoot), oneThird)
            
            let im = Complex(0.0, Real(0.5*sqrt(3.0)))
            let u2 = Real(-0.5) + im
            let u3 = Real(-0.5) - im
            let u2C = u2 * C
            let u3C = u3 * C
            
            let x13 = b + C + (D0 / C)
            let x23 = b + u2C + (D0 / u2C)
            let x33 = b + u3C + (D0 / u3C)
            
            let x1 = -oneThird * x13
            let x2 = -oneThird * x23
            let x3 = -oneThird * x33
            
            return [x1, x2, x3]
        }
    }
    
    private func quartic() -> Multiset<Complex<Real>> {
        var a = coefficients[0]
        var b = coefficients[1]
        var c = coefficients[2]
        var d = coefficients[3]
        let e = coefficients[4]
        
        if a.isZero {
            return Polynomial(b, c, d, e).roots()
        }
        if e.isZero {
            return [Complex.zero()] + Polynomial(a, b, c, d).roots()
        }
        if b.isZero && d.isZero { // Biquadratic
            let squares = Polynomial(a, c, e).roots()
            return squares.flatMap { (square: Complex<Real>) -> Multiset<Complex<Real>> in
                let x = sqrt(square)
                return [x, -x]
            }
        }
        
        // Lodovico Ferrari's solution
        
        // Converting to a depressed quartic
        let a1 = b/a
        b = c/a
        c = d/a
        d = e/a
        a = a1
        
        let a2 = a*a
        let minus3a2 = -3.0*a2
        let ac64 = 64.0*a*c
        let a2b16 = 16.0*a2*b
        let aOn4 = a/4.0
        
        let p = b + minus3a2/8.0
        let ab4 = 4.0*a*b
        let q = (a2*a - ab4)/8.0 + c
        let r1 = minus3a2*a2 - ac64 + a2b16
        let r = r1/256.0 + d
        
        // Depressed quartic: u^4 + p*u^2 + q*u + r = 0
        
        if q.isZero { // Depressed quartic is biquadratic
            let squares = Polynomial(1.0, p, r).roots()
            return squares.flatMap { (square: Complex<Real>) -> Multiset<Complex<Real>> in
                let x = sqrt(square)
                return [x - aOn4, -x - aOn4]
            }
        }
        
        let p2 = p*p
        let q2On8 = q*q/8.0
        
        let cb = 2.5*p
        let cc = 2.0*p2 - r
        let cd = 0.5*p*(p2-r) - q2On8
        let yRoots = Polynomial(1.0, cb, cc, cd).roots()
        
        let y = yRoots[yRoots.startIndex]
        let y2 = 2.0*y
        let sqrtPPlus2y = sqrt(p + y2)
        precondition(sqrtPPlus2y.isZero == false, "Failed to properly handle the case of the depressed quartic being biquadratic")
        let p3 = 3.0*p
        let q2 = 2.0*q
        let fraction = q2/sqrtPPlus2y
        let p3Plus2y = p3 + y2
        let u1 = 0.5*(sqrtPPlus2y + sqrt(-(p3Plus2y + fraction)))
        let u2 = 0.5*(-sqrtPPlus2y + sqrt(-(p3Plus2y - fraction)))
        let u3 = 0.5*(sqrtPPlus2y - sqrt(-(p3Plus2y + fraction)))
        let u4 = 0.5*(-sqrtPPlus2y - sqrt(-(p3Plus2y - fraction)))
        return [
            u1 - aOn4,
            u2 - aOn4,
            u3 - aOn4,
            u4 - aOn4
        ]
    }
    
    /// Implementation of the [Durand-Kerner-Weierstrass method](https://en.wikipedia.org/wiki/Durand%E2%80%93Kerner_method).
    private func durandKernerMethod() -> Multiset<Complex<Real>> {
        var coefficients = self.coefficients.map { Complex($0, Real(0)) }
        
        let one = Complex(Real(1), Real(0))
        
        if coefficients[0] != one {
            coefficients = coefficients.map { coefficient in
                coefficient / coefficients[0]
            }
        }
        
        var a0 = [one]
        for _ in 1..<coefficients.count-1 {
            a0.append(a0.last! * Complex(Real(0.4), Real(0.9)))
        }
        
        var count = 0
        while count++ < 1000 {
            var roots: [Complex<Real>] = []
            for var i = 0; i < a0.count; i++ {
                var result = one
                for var j = 0; j < a0.count; j++ {
                    if i != j {
                        result = (a0[i] - a0[j]) * result
                    }
                }
                roots.append(a0[i] - (eval(coefficients, a0[i]) / result))
            }
            if done(a0, roots) {
                return Multiset(roots)
            }
            a0 = roots
        }
        
        return Multiset(a0)
    }
    
    private func eval<Real: RealType>(coefficients: [Complex<Real>], _ x: Complex<Real>) -> Complex<Real> {
        var result = coefficients[0]
        for i in 1..<coefficients.count {
            result = (result * x) + coefficients[i]
        }
        return result
    }
    
    private func done<Real: RealType>(aa: [Complex<Real>], _ bb: [Complex<Real>], _ epsilon: Real = Real.epsilon) -> Bool {
        for (a, b) in zip(aa, bb) {
            let delta = a - b
            if delta.abs > epsilon {
                return false
            }
        }
        return true
    }
    
}

// MARK: Equatable

public func == <Real: RealType>(lhs: Polynomial<Real>, rhs: Polynomial<Real>) -> Bool {
    return lhs.coefficients == rhs.coefficients
}

