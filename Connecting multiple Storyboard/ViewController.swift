//
//  ViewController.swift
//  Connecting multiple Storyboard
//
//  Created by Pierre on 3/12/16.
//  Copyright © 2016 Pierre. All rights reserved.
//

import UIKit
import Foundation

// MARK: EXTENSIONS


extension String {
    
    subscript (i: Int) -> Character {
        return self[self.startIndex.advancedBy(i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        let start = startIndex.advancedBy(r.startIndex)
        let end = start.advancedBy(r.endIndex - r.startIndex)
        return self[Range(start: start, end: end)]
    }
}





class ViewController: UIViewController , UITextFieldDelegate  /*,DetailsDelegate*/ {
    
    
    @IBOutlet weak var numerator: UILabel!
    @IBOutlet weak var denom: UILabel!
    
    @IBOutlet weak var firstTextField: UITextField!
    
//    func updateLabel(withAttString string: NSAttributedString?) {
//        numerator.attributedText = string
//        numerator.text = "piwrerg n"
//    }


    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //For keyboard purpose
        self.firstTextField.delegate = self
        firstTextField.secureTextEntry = false;
        firstTextField.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        
          }
    
    
   //var denominator : Bool = false
    
    func textFieldDidChange(textField: UITextField) {
        //your code
        print ("Button Tapped")
//        if ( firstTextField.text?.characters.last == "/"){
//        denominator = true;
//        }
        
       if ( firstTextField.text?.characters.last == "+" || firstTextField.text?.characters.last == "-" || firstTextField.text?.characters.last == "." ){
        setTF()
        }
    }
    
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
  
    
    

    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Some needed extension / types
    
    typealias Coefficient = ( Variable : String , coeff: Int )// = ("" , 0 ) ;

    
    
    func getOperand ( a: Operand ) -> String{
        switch ( a ) {
        case .add:
            return "+"
        case .sub:
            return "-"
        case .div:
            return "/"
        case .mul:
            return "*"
        default:
            return " "
            
            
        }
        
    }
    
    
    
    // MARK:  Each time a button is typed I need to parse the information
    
    
    //Global constant variables
    var powerString : String = "power("
    var variableSymbol : String = "s"
    
    //var oldTF : String = "spower(7)-3spower(5)+3spower(5)+1spower(4)+spower(3)+3spower(2)+3spower(1)+1-1+1."
    var oldTF : String = ""
    var location : [ (Location : Int , Length : Int , Number : String  , Coefficient : Coefficient , Sign : Bool , Operand: Operand) ] = []

    func setTF() //-> NSAttributedString
    {
        oldTF = firstTextField.text!
        // Needed variables
         location  = []
        
        var leftLimit : Int = 0 ;
        var temp : String = ""
        //var sizeofprevious : Int = 0 // size = 0 initially
        var tempLocation : Int = 0
        var tempLength : Int = 0 // done
        var tempNumber : String = "" //done
        var tempCoefficient : Coefficient = ("" , 0) // did the variable part  --
        var temp_sign : Bool = false; //DONE
        var temp_Operand : Operand = Operand.add //DONE
        //var g :[String] = []
        var done : Bool = false
        var newTF : String = ""
        
        
        
        
        // Start of function
        for ( var k : Int = 1 ; k < oldTF.characters.count && !done ; k++)
        {
            // When the user submits it append a point at the end of the expression
            if ( oldTF[k] == "+" || oldTF[k] == "-" || oldTF[k] == "/" || oldTF[k] == "*" || oldTF[k] == "." )
            {
                
                if ( oldTF[k] == ".")
                {
                    done = true
                }
                
                
                // my string is now limited from leftLimit to rigth limit wich is the position just preceding the pushed operand
                temp = oldTF.substringWithRange(Range<String.Index>(start: oldTF.startIndex.advancedBy(leftLimit) , end: oldTF.startIndex.advancedBy(k)) )//(oldTF.characters.count - 1)) )
                
//                g.append(temp)
//                print(g)
                
                
                
                k++ // to skip incase to consecutive operator
                
                // Analyse this substring and fill locations
                if ( temp.containsString(variableSymbol)) // if my Coefficient contains variable
                {
                    //it must contain a power >=2
                    //if no power( is present then it is implied that is is to he power 1
                    
                    if ( temp.containsString(powerString))
                    {
                        // Power >=2
                        //Scpe = temp variable
                        for ( var i: Int  = 0 ; i < temp.characters.count - powerString.characters.count + 1 ; i++)
                        {
                            if ( temp[i...( i + powerString.characters.count - 1 )] == powerString)
                            {
                                var counter = 0
                                var j : Int = i + powerString.characters.count
                                
                                while ( temp[j] != ")")
                                {
                                    counter++;
                                    j++;
                                }
                                
                                // Assigne the length of the power
                                tempLength = counter
                                tempNumber = temp.substringWithRange(Range<String.Index>(start: temp.startIndex.advancedBy(i + powerString.characters.count) , end: temp.startIndex.advancedBy(j)))
                                
                                // ?? break; // since I will only have 11 occurence of power()
                            }
                        }
                    }else{
                        //Power == 1
                        tempNumber = "1"
                    }
                    
                    
                    // How to parse the variable and coefficient
                    
                    for ( var i: Int  = 0 ; i < temp.characters.count - variableSymbol.characters.count + 1 ; i++)
                    {
                        if ( temp[i...( i + variableSymbol.characters.count - 1 )] == variableSymbol )
                        {
                            // found the location of the variable
                            tempCoefficient.Variable = temp[i...( i + variableSymbol.characters.count - 1 )]
                            
                            
                            // To account for remove symbols
                            var tempCounter : Int = 0
                            
                            if ( temp.containsString("+"))
                            {
                                temp_Operand = Operand.add
                                temp_sign = false
                                tempCounter++
                            }
                            if ( temp.containsString("-"))
                            {
                                temp_Operand = Operand.sub
                                temp_sign = true
                                tempCounter++
                            }
                            //put this after so that if user input *+ sign is finally positve but Opeand is final
                            if ( temp.containsString("/"))
                            {
                                temp_Operand = Operand.div
                                tempCounter++
                            }
                            if ( temp.containsString("*"))
                            {
                                temp_Operand = Operand.mul
                                tempCounter++
                            }
                            
                            // Need to remove now all signs since I know how it will look
                            temp = temp.stringByReplacingOccurrencesOfString("+" , withString: "")
                            temp = temp.stringByReplacingOccurrencesOfString("-" , withString: "")
                            temp = temp.stringByReplacingOccurrencesOfString("*" , withString: "")
                            temp = temp.stringByReplacingOccurrencesOfString("/" , withString: "")
                            
                            
                            
                            //need to account if there is no '1'
                            if ( i > tempCounter )
                            {
                                tempCoefficient.coeff = (Int)(temp[(0)...(i - 1 - tempCounter )])!
                            }else{
                                tempCoefficient.coeff = 1 ;
                            }
                        }
                        
                        
                    }
                    
                } // End it contain a variable
                else { // it is a constant term
                    
                    // oldTF.substringWithRange( 1 , 6 )
                    //could contain a unique! power
                    
                    if ( temp.containsString(powerString))
                    {
                        // contains a power
                        
                        // Power >=2
                        //Scpe = temp variable
                        for ( var i: Int  = 0 ; i < temp.characters.count - powerString.characters.count + 1 ; i++)
                        {
                            if ( temp[i...( i + powerString.characters.count - 1 )] == powerString)
                            {
                                var counter = 0
                                var j : Int = i + powerString.characters.count
                                
                                while ( temp[j] != ")")
                                {
                                    counter++;
                                    j++;
                                }
                                
                                // Assigne the length of the power
                                tempLength = counter
                                tempNumber = temp.substringWithRange(Range<String.Index>(start: temp.startIndex.advancedBy(i + powerString.characters.count) , end: temp.startIndex.advancedBy(j)))
                                
                                var tempCounter : Int = 0
                                
                                if ( temp.containsString("+"))
                                {
                                    temp_Operand = Operand.add
                                    temp_sign = false
                                    tempCounter++
                                }
                                if ( temp.containsString("-"))
                                {
                                    temp_Operand = Operand.sub
                                    temp_sign = true
                                    tempCounter++
                                }
                                //put this after so that if user input *+ sign is finally positve but Opeand is final
                                if ( temp.containsString("/"))
                                {
                                    temp_Operand = Operand.div
                                    tempCounter++
                                }
                                if ( temp.containsString("*"))
                                {
                                    temp_Operand = Operand.mul
                                    tempCounter++
                                }
                                
                                tempCoefficient.Variable = ""
                                
                                
                                // Need to remove now all signs since I know how it will look
                                temp = temp.stringByReplacingOccurrencesOfString("+" , withString: "")
                                temp = temp.stringByReplacingOccurrencesOfString("-" , withString: "")
                                temp = temp.stringByReplacingOccurrencesOfString("*" , withString: "")
                                temp = temp.stringByReplacingOccurrencesOfString("/" , withString: "")
                                
                                
                                //need to assign the coefficeint +
                                if ( i > tempCounter )
                                {
                                    tempCoefficient.coeff = (Int)(temp[(0)...(i - 1 - tempCounter)])!
                                    tempCoefficient.coeff = (Int)(pow((Double)(tempCoefficient.coeff), (Double)(tempNumber)!))
                                    tempLength = (String)(tempCoefficient.coeff).characters.count
                                    tempNumber = "0"
                                    
                                }else{
                                    tempCoefficient.coeff = 1 ;
                                }
                                
                                
                                
                                
                                // ?? break; // since I will only have 11 occurence of power()
                            }
                            
                            
                            
                        }//contains power + contant only without variable
                    }else{
                        // contains only a constant term
                        
                        if ( temp.containsString("+"))
                        {
                            temp_Operand = Operand.add
                            temp_sign = false
                        }
                        if ( temp.containsString("-"))
                        {
                            temp_Operand = Operand.sub
                            temp_sign = true
                        }
                        //put this after so that if user input *+ sign is finally positve but Opeand is final
                        if ( temp.containsString("/"))
                        {
                            temp_Operand = Operand.div
                        }
                        if ( temp.containsString("*"))
                        {
                            temp_Operand = Operand.mul
                        }
                        
                        tempCoefficient.Variable = ""
                        
                        
                        // Need to remove now all signs since I know how it will look
                        temp = temp.stringByReplacingOccurrencesOfString("+" , withString: "")
                        temp = temp.stringByReplacingOccurrencesOfString("-" , withString: "")
                        temp = temp.stringByReplacingOccurrencesOfString("*" , withString: "")
                        temp = temp.stringByReplacingOccurrencesOfString("/" , withString: "")
                        
                        
                        tempCoefficient.coeff = (Int)(temp)!
                        tempNumber = "0"
                        tempLength = 0
                        
                    }//only constant term without power
                    
                    
                } // emd it contains a constant variable only
                
                
                // update left limit
                leftLimit = k - 1  ;
                
                
                //update the new TF that will be outputed to the user
                // newTF += (String)( getOperand(temp_Operand) + tempCoefficient.coeff + tempCoefficient.Variable + tempNumber + " " )
                // need to take care of the location of the power
                // I chose the location of the power to be localized to the obeject itself
                // It takes into consideration : variable + coeff nut for now not the sign
                
                var tempCoeffLength : Int
                if ( tempCoefficient.coeff == 1  )
                {
                    tempCoeffLength = 0
                    
                }else{
                    tempCoeffLength = (String)(tempCoefficient.coeff).characters.count
                    
                }
                
                //want to add ot location the length of the previous term
                tempLocation = tempCoefficient.Variable.characters.count + tempCoeffLength + getOperand(temp_Operand).characters.count //+ sizeofprevious
                location.append((Location: tempLocation, Length: tempLength, Number: tempNumber, Coefficient: tempCoefficient, Sign: temp_sign, Operand: temp_Operand))
                
                // sizeofprevious = temp.characters.count
                
            }
            
        }
        
   //     print (location)
        
        location.sortInPlace { ( a :(Location: Int, Length: Int, Number: String, Coefficient: Coefficient , Sign: Bool, Operand: Operand), b:(Location: Int, Length: Int, Number: String, Coefficient: Coefficient , Sign: Bool, Operand: Operand)) -> Bool in
            a.Number > b.Number
            // &&  a.Coefficient.Variable == "s"
        }
      //  print(location)
        
        
        //can try to combine terms with the same power
        var current : Int = 0 ;
        var cur : Int = 1 ;
        var sign : Int = 1;
        for ( current = 0 ; current < location.count-1 ; current++)
        {
            cur = 1
            while ( location[current].Number == location[current+cur].Number )
            {
                //combine
                
                if (location[current+cur].Sign == false){ // Addition
                    
                    if (location[current].Sign == false)
                    {
                        sign = 1
                    }else{
                        sign = -1
                    }
                    location[current].Coefficient.coeff = location[current].Coefficient.coeff*sign + location[current+cur].Coefficient.coeff
                   // print(location[current].Coefficient.coeff)
                    //Update location
                    if ( (location[current].Coefficient.coeff) < 0  )
                    {
                        location.removeAtIndex(current+cur) // remove the other element
                        location[current].Coefficient.coeff *= -1
                        location[current].Sign = true
                        location[current].Operand = Operand.sub
                        //Update location
                        location[current].Location = location[current].Coefficient.Variable.characters.count + (String)(location[current].Coefficient.coeff).characters.count + getOperand(temp_Operand).characters.count //+ sizeofprevious
                        
                    }else if ((location[current].Coefficient.coeff) == 0  )
                    {
                        location.removeAtIndex(current+cur) // remove the other element
                        location.removeAtIndex(current) // remove the other element since it is null
                    }else{
                        location.removeAtIndex(current+cur) // remove the other element
                        //Update location
                        location[current].Location = location[current].Coefficient.Variable.characters.count + (String)(location[current].Coefficient.coeff).characters.count + getOperand(temp_Operand).characters.count //+ sizeofprevious
                    }
                    
                    
                }
                else{ // Substraction
                    if (location[current].Sign == false)
                    {
                        sign = 1
                    }else{
                        sign = -1
                    }
                    location[current].Coefficient.coeff = location[current].Coefficient.coeff*sign - location[current+cur].Coefficient.coeff
                 //   print(location[current].Coefficient.coeff)
                    
                    if ( (location[current].Coefficient.coeff) < 0  )
                    {
                        location.removeAtIndex(current+cur) // remove the other element
                        location[current].Coefficient.coeff *= -1
                        location[current].Sign = true
                        location[current].Operand = Operand.sub
                        //Update location
                        location[current].Location = location[current].Coefficient.Variable.characters.count + (String)(location[current].Coefficient.coeff).characters.count + getOperand(temp_Operand).characters.count //+ sizeofprevious
                        
                    }else if ((location[current].Coefficient.coeff) == 0  )
                    {
                        location.removeAtIndex(current+cur) // remove the other element
                        location.removeAtIndex(current) // remove the other element since it is null
                    }else{
                        location.removeAtIndex(current+cur) // remove the other element
                        //Update location
                        location[current].Location = location[current].Coefficient.Variable.characters.count + (String)(location[current].Coefficient.coeff).characters.count + getOperand(temp_Operand).characters.count //+ sizeofprevious
                    }
                    
                    
                }
                
                
                if ( (current + cur) < location.count - 1  )
                {
                    cur++
                }
                else{
                    cur = 1 // reeinitilize
                    break;
                }
                
            }
            
        }
        
        
        
        //Remove the first "+" in case positve
        //Must replace it with a space so not to modify the locations
        if (location[0].Sign == false)
        {
            location[0].Operand = Operand.startPositive
        }
        
        // Need to merge the terms with same power && variable into 1
        
        for ( var  i : Int = 0  ; i < location.count ; i++)
        {
            if(location[i].Coefficient.coeff == 1){
                if ( location[i].Number == "0"  ||  location[i].Number == "1" )
                {
                    
                    location[i].Location += newTF.characters.count
                    newTF +=  getOperand(location[i].Operand) + location[i].Coefficient.Variable + (String)(location[i].Coefficient.coeff)
                }else{
                    location[i].Location += newTF.characters.count
                    newTF +=  getOperand(location[i].Operand) + location[i].Coefficient.Variable +  location[i].Number
                }
            }
            else{
                if ( location[i].Number == "0" ||  location[i].Number == "1" )
                {
                    location[i].Location += newTF.characters.count
                    newTF +=  getOperand(location[i].Operand) + (String)(location[i].Coefficient.coeff) + location[i].Coefficient.Variable
                }else{
                    location[i].Location += newTF.characters.count
                    newTF +=  getOperand(location[i].Operand) + (String)(location[i].Coefficient.coeff) + location[i].Coefficient.Variable +  location[i].Number
                }
            }
        }
        
        

        //FONT REARRANGMENT
        let font:UIFont? = UIFont(name: "Helvetica", size:20)
        let fontSuper:UIFont? = UIFont(name: "Helvetica", size:10)
        let attString:NSMutableAttributedString = NSMutableAttributedString(string: newTF, attributes: [NSFontAttributeName:font!] )
        
        // Modifying the string ( removing power() )
        for ( var i : Int  = 0 ; i < location.count ; i++ )
        {
            if(!( location[i].Number == "0"  ||  location[i].Number == "1" )) // then I don't have a number to superscript
            {attString.setAttributes([NSFontAttributeName:fontSuper!,NSBaselineOffsetAttributeName:10], range: NSRange(location: location[i].Location,  length: location[i].Length))
            }
            
        }
        
        
        //Underlining if there is a division
         //  if ( denominator == true ){
        let stringRange = NSMakeRange(0, attString.length)
        
        attString.beginEditing()
        attString.addAttribute(NSUnderlineStyleAttributeName, value: 1, range: stringRange)
        attString.endEditing()
        numerator.attributedText = attString

      //  }
        
        
        
        // Send it back to the numerator
        //delegate?.updateLabel(withAttString: attString)
        
        
        // return attString;
        
    } //end setTF

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        //Choosing a specific Segue
        if (segue.identifier == "showSecondViewController" )
        {
            //asssigning a globalVariable to the second view controller
            let secondViewController = segue.destinationViewController as! SecondViewController
            secondViewController.location = location
            
            
        }
    }

}

