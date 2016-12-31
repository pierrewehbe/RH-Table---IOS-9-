//
//  SecondViewController.swift
//  Connecting multiple Storyboard
//
//  Created by Pierre on 3/12/16.
//  Copyright © 2016 Pierre. All rights reserved.
//

import UIKit

enum Operand: String{
    case add = "+"
    case sub = "-"
    case div = "/"
    case mul = "*"
    case startPositive = " "
}


public typealias Fraction = Fractional<Int>

private func gcd<Number: IntegerType>(var lhs: Number, var _ rhs: Number) -> Number {
    while rhs != 0 { (lhs, rhs) = (rhs, lhs % rhs) }
    return lhs
}

private func lcm<Number: IntegerType>(lhs: Number, _ rhs: Number) -> Number {
    return lhs * rhs / gcd(lhs, rhs)
}

private func reduce<Number: IntegerType>(numerator numerator: Number, denominator: Number) -> (numerator: Number, denominator: Number) {
    var divisor = gcd(numerator, denominator)
    if divisor < 0 { divisor *= -1 }
    guard divisor != 0 else { return (numerator: numerator, denominator: 0) }
    return (numerator: numerator / divisor, denominator: denominator / divisor)
}

public struct Fractional<Number: IntegerType> {
    /// The numerator of the fraction.
    public let numerator: Number
    
    /// The (always non-negative) denominator of the fraction.
    public let denominator: Number
    
    private init(numerator: Number, denominator: Number) {
        var (numerator, denominator) = reduce(numerator: numerator, denominator: denominator)
        if denominator < 0 { numerator *= -1; denominator *= -1 }
								
        self.numerator = numerator
        self.denominator = denominator
    }
    
    /// Create an instance initialized to `value`.
    public init(_ value: Number) {
        self.init(numerator: value, denominator: 1)
    }
}

extension Fractional: Equatable {}
public func ==<Number: IntegerType>(lhs: Fractional<Number>, rhs: Fractional<Number>) -> Bool {
    return lhs.numerator == rhs.numerator && lhs.denominator == rhs.denominator
}

extension Fractional: Comparable {}
public func <<Number: IntegerType>(lhs: Fractional<Number>, rhs: Fractional<Number>) -> Bool {
    guard !lhs.isNaN && !rhs.isNaN else { return false }
    guard lhs.isFinite && rhs.isFinite else { return lhs.numerator < rhs.numerator }
    let (lhsNumerator, rhsNumerator, _) = Fractional.commonDenominator(lhs, rhs)
    return lhsNumerator < rhsNumerator
}

extension Fractional: Hashable {
    public var hashValue: Int {
        return numerator.hashValue ^ denominator.hashValue
    }
}

extension Fractional: Strideable {
    private static func commonDenominator(lhs: Fractional, _ rhs: Fractional) -> (lhsNumerator: Number, rhsNumberator: Number, denominator: Number) {
        let denominator = lcm(lhs.denominator, rhs.denominator)
        let lhsNumerator = lhs.numerator * (denominator / lhs.denominator)
        let rhsNumerator = rhs.numerator * (denominator / rhs.denominator)
        
        return (lhsNumerator, rhsNumerator, denominator)
    }
    
    public func advancedBy(n: Fractional) -> Fractional {
        let (selfNumerator, nNumerator, commonDenominator) = Fractional.commonDenominator(self, n)
        return Fractional(numerator: selfNumerator + nNumerator, denominator: commonDenominator)
    }
    
    public func distanceTo(other: Fractional) -> Fractional {
        return other.advancedBy(-self)
    }
}

extension Fractional: IntegerLiteralConvertible {
    public init(integerLiteral value: Number) {
        self.init(value)
    }
}

extension Fractional: SignedNumberType {}
public prefix func -<Number: IntegerType>(value: Fractional<Number>) -> Fractional<Number> {
    return Fractional(numerator: -1 * value.numerator, denominator: value.denominator)
}

extension Fractional {
    /// The reciprocal of the fraction.
    public var reciprocal: Fractional {
        get {
            return Fractional(numerator: denominator, denominator: numerator)
        }
    }
    
    /// `true` iff `self` is neither infinite nor NaN
    public var isFinite: Bool {
        return denominator != 0
    }
    
    /// `true` iff the numerator is zero and the denominator is nonzero
    public var isInfinite: Bool {
        return denominator == 0 && numerator != 0
    }
    
    /// `true` iff both the numerator and the denominator are zero
    public var isNaN: Bool {
        return denominator == 0 && numerator == 0
    }
    
    /// The positive infinity.
    public static var infinity: Fractional {
        return 1 / 0
    }
    
    /// Not a number.
    public static var NaN: Fractional {
        return 0 / 0
    }
}

extension Fractional: CustomStringConvertible {
    public var description: String {
        guard !isNaN else { return "NaN" }
        guard !isInfinite else { return (self >= 0 ? "+" : "-") + "Inf" }
        
        switch denominator {
        case 1: return "\(numerator)"
        default: return "\(numerator)/\(denominator)"
        }
    }
}

/// Add `lhs` and `rhs`, returning a reduced result.
public func +<Number: IntegerType>(lhs: Fractional<Number>, rhs: Fractional<Number>) -> Fractional<Number> {
    guard !lhs.isNaN && !rhs.isNaN else { return .NaN }
    guard lhs.isFinite && rhs.isFinite else {
        switch (lhs >= 0, rhs >= 0) {
        case (false, false): return -.infinity
        case (true, true):   return .infinity
        default:			 return .NaN
        }
    }
    return lhs.advancedBy(rhs)
}
public func +=<Number: IntegerType>(inout lhs: Fractional<Number>, rhs: Fractional<Number>) {
    lhs = lhs + rhs
}

/// Subtract `lhs` and `rhs`, returning a reduced result.
public func -<Number: IntegerType>(lhs: Fractional<Number>, rhs: Fractional<Number>) -> Fractional<Number> {
    return lhs + -rhs
}
public func -=<Number: IntegerType>(inout lhs: Fractional<Number>, rhs: Fractional<Number>) {
    lhs = lhs - rhs
}

/// Multiply `lhs` and `rhs`, returning a reduced result.
public func *<Number: IntegerType>(lhs: Fractional<Number>, rhs: Fractional<Number>) -> Fractional<Number> {
    let swapped = (Fractional(numerator: lhs.numerator, denominator: rhs.denominator), Fractional(numerator: rhs.numerator, denominator: lhs.denominator))
    return Fractional(numerator: swapped.0.numerator * swapped.1.numerator, denominator: swapped.0.denominator * swapped.1.denominator)
}
public func *=<Number: IntegerType>(inout lhs: Fractional<Number>, rhs: Fractional<Number>) {
    lhs = lhs * rhs
}

/// Divide `lhs` and `rhs`, returning a reduced result.
public func /<Number: IntegerType>(lhs: Fractional<Number>, rhs: Fractional<Number>) -> Fractional<Number> {
    return lhs * rhs.reciprocal
}
public func /=<Number: IntegerType>(inout lhs: Fractional<Number>, rhs: Fractional<Number>) {
    lhs = lhs / rhs
}

extension Double {
    /// Create an instance initialized to `value`.
    init<Number: IntegerType>(_ value: Fractional<Number>) {
        self.init(Double(value.numerator.toIntMax()) / Double(value.denominator.toIntMax()))
    }
}

extension Float {
    /// Create an instance initialized to `value`.
    init<Number: IntegerType>(_ value: Fractional<Number>) {
        self.init(Float(value.numerator.toIntMax()) / Float(value.denominator.toIntMax()))
    }
}


class SecondViewController: UIViewController , UITableViewDelegate {
    
    
    @IBOutlet weak var secondLabel: UILabel!
    
    
    typealias Coefficient = ( Variable : String , coeff: Int )// = ("" , 0 ) ;
    
    
    
    var location  : [ (Location : Int , Length : Int , Number : String  , Coefficient : Coefficient , Sign : Bool , Operand: Operand) ] = []
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        // secondLabel.text = status
        
        funcRH_Table()
    }
    
    
    @IBAction func Correct(sender: UIBarButtonItem) {
        checkForSpecialCases(intRH_Table)
    }
    
    @IBAction func CheckSpecialCases(sender: UIBarButtonItem) {
        checkForSpecialCasesWithoutCorecting(intRH_Table)
    }
    
    
    
    
    
    @IBOutlet weak var myRHTable: UITableView!
    
    // MARK: RH Function Analysis
    
    var RH_Table : [String] = []
    var intRH_Table : [[Fraction]] = [[]]
    
    
    func funcRH_Table() -> [String]
    {
        
        //Need to fill in location the powers that have not been accounted for
        // check if one entry is missing
        if ( location.count > 1 ){
            while ( ( (Int)(location[0].Number)! + 1  )  != location.count     )
            {
                // there are terms that are missing
                for ( var i : Int = 1 ; i < location.count ; i++)
                {
                    if ( (Int)(location[i].Number) != (Int)(location[i-1].Number)! - 1 )
                    {
                        //then I need to insert an element here with all coeffictient to 0
                        location.insert((Location: 0, Length: 0, Number: (String)((Int)(location[0].Number)! - i), Coefficient: (Variable: "", coeff: 0), Sign: false, Operand: Operand.add), atIndex: i)
                        
                        
                    }//end if
                    
                }//end for
                
                print("inf loop")
                
            }//end while
        }//end if
        
        
        
        
        intRH_Table = [[]]
        RH_Table = [] // initialize it again to 0
        // My Transfer Function has a numerator and denominator
        // I am going to work with the denominator alone
        
        
        
        
        
        //I have this much coeffiction
        var ligne = location.count
        
        
        // Filling the first 2 rows ( if possible )
        var step : String = ""
        var intStep : [Fraction] = []  // Want Fractions !
        //row 1
        if ( location.count > 0 )
        {
            for ( var i : Int = 0 ; i < location.count ; i+=2 )
            {
                step =  step + (String)(location[i].Coefficient.coeff) + "\t\t"
                intStep.append((Fraction)(location[i].Coefficient.coeff))
            }
            intRH_Table[0] = (intStep)
            
            
            RH_Table.append("s^" + location[0].Number + "\t\t"  + step)
            
            step = ""
            intStep = []
            //row2
            //if ( location[1].Number == (location[0].Number - 1)
            if ( location.count > 1 )
            {
                for ( var i : Int = 1 ; i <  location.count  ; i+=2 )
                {
                    step =  step + (String)(location[i].Coefficient.coeff) + "\t\t"
                    intStep.append((Fraction)(location[i].Coefficient.coeff))
                    
                }
                
                RH_Table.append("s^" + location[1].Number + "\t\t"  + step)
                intRH_Table.append(intStep)
                
            }
            
            ligne-=2;
            
            // NEED TO APPEND LOCATION FOR NON EXISTING S ( CHECK IF COUNT = MAX POWER + 1 ?
            print("2 first rows " )
            
            if ( location.count > 1){
                print ( intRH_Table[0])
                print ( intRH_Table[1])
            }
            
        }
        
        
        fillRemainingRows(ligne)
        return RH_Table;
        
    }
    
    
    
    
    
    
    
    
    
    // can correct only if we can access the row above : craches if we put 0 !
    
    
    
    
    
    
    
    
    func fillRemainingRows(var ligne : Int )
    {
        //Want to fill remaing lines ( from highest power to lowest
        while ( ligne > 0 )
        {
            
            
            var step : String = ""
            var intStep : [Fraction] = []  // Want Fractions !
            
            
            let op1 :Fraction =  (intRH_Table[location.count - ligne - 1 ] )[0]
            let op2 :Fraction =  (intRH_Table[location.count - ligne - 2 ] )[0]
            
            
            
            for ( var j : Int =  1 ; j < (intRH_Table[location.count-ligne - 2 ]).count ; j++ )
            {
                // Attention on peut avoir moins de entries dans la 2eme ligne
                if ( j < (intRH_Table[location.count-ligne - 1 ]).count) // there must be a number
                {
                    
                    let temp:Fraction = (  (op1) * (intRH_Table[location.count-ligne - 2 ])[j]  - (op2) * (intRH_Table[location.count-ligne - 1 ])[j]    ) / (op1 )
                    intStep.append( temp )
                    step += (String)(temp) + "\t\t"
                    
                }else{ // We assume there are 0's
                    
                    let temp:Fraction = (intRH_Table[location.count-ligne - 2 ])[j]
                    intStep.append(temp)
                    step += (String)(temp) + "\t\t"
                    
                }
                
                
            }
            
            RH_Table.append("s^" + (String)(ligne-1) + "\t\t"  + step)
            intRH_Table.append(intStep)
            ligne-- ;
        }
        
        print(RH_Table)
        myRHTable.reloadData()
        
    }
    
    
    
    
    
    
    
    
    
    
    
    // Can inputted to check for special case after each line that I insert !
    func checkForSpecialCases ( var intRHTable : [[Fraction]] )//->(rOf0 : Bool, oF0 :Bool , affectedIndex : Int)
    {
        
        var rowOfZeros : Bool = false;
        var onlyFirstIsZero : Bool = false ;
        var affectedIndex :Int = -1 ;
        
        for ( var i : Int = 0 ; i < intRHTable.count ; i++    ) // loop in all lines
        {
            var counter : Int = 0 ;
            for ( var j  : Int = 0 ; j < (intRHTable[i]).count ; j++ ) // inner loops have variable length !
            {
                if ( intRHTable[i][j] == 0)
                {
                    counter++;
                }
            }
            //Setting Special Cases Boolean
            if ( counter == (intRHTable[i]).count)
            {
                rowOfZeros = true ;
                affectedIndex = i
            }
            else{
                if ( intRHTable[i][0] == 0 )
                {
                    onlyFirstIsZero = true;
                    affectedIndex = i
                }
            }
            if ( onlyFirstIsZero || rowOfZeros ){
                Correct( onlyFirstIsZero ,rOf0: rowOfZeros , affectedIndex: affectedIndex );
                // return ( rowOfZeros , onlyFirstIsZero , affectedIndex) // while one of them is true -> need to call function again
            }
        }
        //return ( rowOfZeros , onlyFirstIsZero , affectedIndex);
        // maybe cout some message
        
    }
    
    
    
    
    // Can inputted to check for special case after each line that I insert !
    func checkForSpecialCasesWithoutCorecting ( var intRHTable : [[Fraction]] )//->(rOf0 : Bool, oF0 :Bool , affectedIndex : Int)
    {
        
        var rowOfZeros : Bool = false;
        var onlyFirstIsZero : Bool = false ;
        var affectedIndex :Int = -1 ;
        
        for ( var i : Int = 0 ; i < intRHTable.count ; i++    ) // loop in all lines
        {
            var counter : Int = 0 ;
            for ( var j  : Int = 0 ; j < (intRHTable[i]).count ; j++ ) // inner loops have variable length !
            {
                if ( intRHTable[i][j] == 0)
                {
                    counter++;
                }
            }
            //Setting Special Cases Boolean
            if ( counter == (intRHTable[i]).count)
            {
                rowOfZeros = true ;
                affectedIndex = i
            }
            else{
                if ( intRHTable[i][0] == 0 )
                {
                    onlyFirstIsZero = true;
                    affectedIndex = i
                }
            }
            if ( onlyFirstIsZero ){
                secondLabel.text = "First element in row \(affectedIndex) is ZERO"
                
            }else if(rowOfZeros){
                secondLabel.text = "Row \(affectedIndex + 1 ) is a ROW OF ZERO"
                
            }else{
                secondLabel.text = "No special cases"
                
            }
            
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    //Global variable
    var result :[Complex] = []
    

    func Correct (oF0: Bool ,rOf0: Bool , affectedIndex : Int) //-> (oF0: Bool ,rOf0: Bool)
    {
        //var temp: (oF0: Bool ,rOf0: Bool , affectedIndex : Int ) = checkForSpecialCases (  intRH_Table )
        
        if ( oF0)
        {
            // 2 Methods
            
            //1 Epsilon Method
            //2 new TF
            
            // 1 epsilon
            
            let epsilon : Fraction = 1/100000
            
            intRH_Table[affectedIndex][0] = epsilon ;
            //need to correct RHTable
            
            explanation.text =  explanation.text! + "\nWe replaced the first zero with a very small positive nubmer > 0 "
            
            
        }else if ( rOf0 )
        {
            // Jumping one row back
            
            
            var A_s : [( Coefficient : Fraction , Power : Fraction)] = [] ; // initialize the Transfer function
            
            var maxPower = location.count - 1 ;
            for ( var i : Int  = 0 ; i < intRH_Table[affectedIndex-1].count ; i++) // row just before the affected one
            {
                A_s.append((Coefficient: intRH_Table[affectedIndex - 1 ][i], Power: (Fraction)(maxPower - affectedIndex + 1 )))
                maxPower -= 2;
            }
            
            
            
            // Need  to set the explanation for A(s) 's roots
            //            {
            //
            //            }
            
            
            var arr : [Double] = []
            for ( var i : Int = A_s.count - 1  ; i >= 0  ; i--)
            {
                arr.append((Double)(A_s[i].Coefficient))
            }
            var A = Polynomial()
            A.coeffs = arr
            
            let roots : [Double] = A.roots
            print(roots)
            
            
            
            if(A_s[0].Power < 2){ // 1 || 0
                // then a real root must exist
                
            }else if ( A_s[0].Power >= 2 ){
                // could exist or could be complex
                var temp = Complex(real: 0,imag: 0)
                
                let a = Double( A_s[0].Coefficient)
                let b = 0.0//Double(A_s[1].Coefficient)
                let c = Double(A_s[1].Coefficient) // since we are skipping an index
                //coeffs[1] / coeffs[2], coeffs[0] / coeffs[2]
                if ( A_s[0].Power == (2 as Fraction) )
                {
                    let del = b * b - 4 * a * c
                    if del == 0  {
                        
                        temp.real = -b/(2*a)
                        temp.imag = 0
                    } else if del > 0 {
                        let sqrt_del = sqrt((Double)(del))
                        temp.real = 0.5 * (sqrt_del - b) / a
                        temp.imag = 0
                        result.append(temp)
                        temp.real = 0.5 * (-sqrt_del - b) / a
                        temp.imag = 0
                        result.append(temp)
                        
                        //return [0.5 * (sqrt_del - b), 0.5 * (-sqrt_del - b)]
                    }
                    // if complex
                    else{
                    let sqrt_del = sqrt(-del)
                    temp.real = 0.5 * (-b) / a
                    temp.imag = 0.5 * (sqrt_del) / a
                    result.append(temp)
                    temp.real = 0.5 * (-b) / a
                    temp.imag = 0.5 * (-sqrt_del) / a
                    result.append(temp)
                    }//maybe it is correcting 2 times ?
                }
                
                
                
            }
            
                
                
                
                
                
                
                
                
                var A_s_derivative : [( Coefficient : Fraction , Power : Fraction)] = A_s ;
                for ( var i : Int = 0 ; i < intRH_Table[affectedIndex-1].count ; i++)
                {
                    A_s_derivative[i].Coefficient *= A_s_derivative[i].Power;
                    A_s_derivative[i].Power = A_s_derivative[i].Power - 1 ;
                    if  (A_s_derivative[i].Power < 0 )
                    {
                        A_s_derivative.removeLast()  // Dropping if negative power
                    }
                    
                }
                
                print("Affected Row  is \(affectedIndex) " );
                print("Previous Row is :" )
                print (A_s)
                print("Derivative A'(s) is :" )
                print (A_s_derivative)
                
                
                // modify the initial branch
                var step : String = ""
                for ( var i : Int = 0 ; i <  intRH_Table[affectedIndex].count ; i++)
                {
                    intRH_Table[affectedIndex][i] = A_s_derivative[i].Coefficient;
                    step += (String)(A_s_derivative[i].Coefficient) + "\t\t"
                    
                }
                
                RH_Table[affectedIndex] = ("s^" + (String)(location.count - affectedIndex - 1) + "\t\t"  + step )
                
            }
            
            // location.count - affectedIndex - 1  remaining rows to fill and rearrange
            //Before we fill them, we need to pop the bad values
            for  ( var i : Int = 0 ; i < location.count - affectedIndex - 1 ; i++ )
            {
                intRH_Table.removeLast();
                RH_Table.removeLast();
                
            }
            
            
            fillRemainingRows(location.count - affectedIndex - 1)
            
            
            
            //After correction is Done check if there are still special cases
            checkForSpecialCases (  intRH_Table )
            
            // It will loop and correct until there are no more mistakes
            
            
            
            //return (temp.oF0 , temp.rOf0)
            
            
        }
        
        @IBOutlet weak var explanation: UILabel!
        
        func getExplanation(){
            
            // after correction!
            
            var counter : Int = 0 ;
            var initialSign :Fraction = intRH_Table[0][0] / intRH_Table[0][0]
            var nextSign :Fraction
            for ( var i : Int = 1 ; i < intRH_Table.count ; i++){
                print(initialSign)
                nextSign = intRH_Table[i][0] / abs(intRH_Table[i][0])
                if  ( nextSign != initialSign){
                    counter++
                    initialSign = nextSign
                }
            }
            print("results")
            print(result)
            var counterJW_Axis : Int = 0
            
            for ( var i : Int = 0 ; i < result.count ; i++)
            {
                if(result[i].real == 0 && result[i].imag != 0 ){
                    counterJW_Axis++
                    
                }
            }
            if ( counterJW_Axis > 0){
                explanation.text = explanation.text! + "\nThere is \(counterJW_Axis) pole on the jw axis"
                for ( var i : Int = 0 ; i < result.count ; i++)
                {  explanation.text = explanation.text! + "\n\(result[i].imag)j"
                }
                print (explanation)}
            
            
            print (intRH_Table)
            explanation.text =  explanation.text! + "\nThere are \(counter) poles in the RHS "
            explanation.text =  explanation.text! + "\nThere are \( (Int)(location[0].Number)! - (counter + counterJW_Axis)) poles in the LHS "
            
        }
        
        
        @IBAction func getExplanations(sender: UIBarButtonItem) {
            getExplanation()
//            let arr : [Double] = [ 1.0 , 2.0 , 3.0 ]
//            var A = Polynomial()
//            A.coeffs = arr
//            print(A.roots)
        }
        
        
        
        // MARK: Table Functions
        
        func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
        {
            return RH_Table.count  // return number of rows we need
        }
        
        
        
        
        func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
        {
            // Defines the content of each individual cell
            let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
            cell.textLabel?.text = RH_Table[indexPath.row]
            return cell;
            
        }
        
        
        
        
        
        
        
        
        
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
        
        
        /*
        // MARK: - Navigation
        
        // In a storyboard-based application, you will often want to do a little preparation before navigation
        override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        }
        */
        
}
