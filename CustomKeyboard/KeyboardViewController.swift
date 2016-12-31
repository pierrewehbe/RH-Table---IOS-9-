//
//  KeyboardViewController.swift
//  CustomKeyboard
//
//  Created by Pierre on 3/12/16.
//  Copyright © 2016 Pierre. All rights reserved.
//

import UIKit



//// MARK: Protocols
//protocol DetailsDelegate: class {
//    func updateLabel(withAttString string: NSAttributedString?)
//}
//
//weak var delegate: DetailsDelegate?


class KeyboardViewController: UIInputViewController  {
    
    

    @IBOutlet var nextKeyboardButton: UIButton!

    override func updateViewConstraints() {
        super.updateViewConstraints()
    
        // Add custom view sizing constraints here
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    
        let buttonTitles1 = ["s", "power(", ")"]
        let buttonTitles2 = ["1", "2", "3"]
        let buttonTitles3 = ["4", "5", "6"]
        let buttonTitles4 = ["7", "8", "9"]
        let buttonTitles5 = ["+", "0", "-"]
        let buttonTitles6 = ["CHG", "/", "BP"]
        
        let row1 = createRowOfButtons(buttonTitles1)
        let row2 = createRowOfButtons(buttonTitles2)
        let row3 = createRowOfButtons(buttonTitles3)
        let row4 = createRowOfButtons(buttonTitles4)
        let row5 = createRowOfButtons(buttonTitles5)
        let row6 = createRowOfButtons(buttonTitles6)
        
        self.view.addSubview(row1)
        self.view.addSubview(row2)
        self.view.addSubview(row3)
        self.view.addSubview(row4)
        self.view.addSubview(row5)
        self.view.addSubview(row6)
        
        row1.translatesAutoresizingMaskIntoConstraints  = false
        row2.translatesAutoresizingMaskIntoConstraints  = false
        row3.translatesAutoresizingMaskIntoConstraints  = false
        row4.translatesAutoresizingMaskIntoConstraints  = false
        row5.translatesAutoresizingMaskIntoConstraints  = false
        row6.translatesAutoresizingMaskIntoConstraints  = false
        
        addConstraintsToInputView(self.view, rowViews: [row1, row2, row3, row4 , row5 ,row6])
        
        
        
//        // Perform custom UI setup here
//        self.nextKeyboardButton = UIButton(type: .System)
//    
//        self.nextKeyboardButton.setTitle(NSLocalizedString("Next Keyboard", comment: "Title for 'Next Keyboard' button"), forState: .Normal)
//        self.nextKeyboardButton.sizeToFit()
//        self.nextKeyboardButton.translatesAutoresizingMaskIntoConstraints = false
//    
//        self.nextKeyboardButton.addTarget(self, action: "advanceToNextInputMode", forControlEvents: .TouchUpInside)
//        
//        self.view.addSubview(self.nextKeyboardButton)
//    
//        self.nextKeyboardButton.leftAnchor.constraintEqualToAnchor(self.view.leftAnchor).active = true
//        self.nextKeyboardButton.bottomAnchor.constraintEqualToAnchor(self.view.bottomAnchor).active = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated
    }

    override func textWillChange(textInput: UITextInput?) {
        // The app is about to change the document's contents. Perform any preparation here.
    }

    override func textDidChange(textInput: UITextInput?) {
       
   
//        // The app has just changed the document's contents, the document context has been updated.
//    
//        var textColor: UIColor
//        let proxy = self.textDocumentProxy
//        if proxy.keyboardAppearance == UIKeyboardAppearance.Dark {
//            textColor = UIColor.whiteColor()
//        } else {
//            textColor = UIColor.blackColor()
//        }
//        self.nextKeyboardButton.setTitleColor(textColor, forState: .Normal)
    }

    
    
    
    // MARK: - New code added

    
    
    func createButtonWithTitle(title: String) -> UIButton {
    
    let button = UIButton(type: .System) as UIButton
    button.frame = CGRectMake(0, 0, 20, 20)
    button.setTitle(title, forState: .Normal)
    button.sizeToFit()
    button.titleLabel!.font = UIFont.systemFontOfSize(15)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
    button.setTitleColor(UIColor.darkGrayColor(), forState: .Normal)
    
    button.addTarget(self, action: "didTapButton:", forControlEvents: .TouchUpInside)
    
    return button
    }
    

    
    /*
    In the method above, we implement the Swift way of writing a button event handler. AnyObject is like the id object in Objective-C. We cast the sender into a UIButton and then get the title of the button which in this case, will be the text we want to enter in the text field.
    */
    
    func didTapButton(sender: AnyObject?) {
        
        let button = sender as! UIButton
        
        let proxy = textDocumentProxy as UITextDocumentProxy
        
        print( "tapped" )
        
        if let title = button.titleForState(.Normal) as String? {
            switch title {
            case "BP":
                proxy.deleteBackward()
            case "RETURN":
                proxy.insertText("\n")
            case "SPACE":
                proxy.insertText(" ")
            case "CHG":
                self.advanceToNextInputMode()
            case "/" :
                break
            default:
                proxy.insertText(title)
                          }
        }
    }
    
    
    
    
    /*
Now with this new piece of code, we have created and array of button titles and we create a list of buttons from these. Each button is now added to an array as well as a UIView which will be our first row of keys. This view is then added to the main keyboard view.

If you run this, you will probably only see the P key since all the buttons are in the same location. We need to add some constraints programmatically so they can be aligned in a row.

So we will create a new method to create the constraints
*/
    
    
    func addIndividualButtonConstraints(buttons: [UIButton], rowView: UIView){
        
        for (index, button) in buttons.enumerate() {
            
            let topConstraint = NSLayoutConstraint(item: button, attribute: .Top, relatedBy: .LessThanOrEqual, toItem: rowView, attribute: .Top, multiplier: 1.0, constant: 1.0)
            let bottomConstraint = NSLayoutConstraint(item: button, attribute: .Bottom, relatedBy: .GreaterThanOrEqual, toItem: rowView, attribute: .Bottom, multiplier: 1.0, constant: -1.0)
            
            var rightConstraint : NSLayoutConstraint!
            
            if index == buttons.count - 1 {
                
                rightConstraint = NSLayoutConstraint(item: button, attribute: .Right, relatedBy: .GreaterThanOrEqual, toItem: rowView, attribute: .Right, multiplier: 1.0, constant: 0.0)
                
            } else {
                
                let nextButton = buttons[index+1]
                rightConstraint = NSLayoutConstraint(item: button, attribute: .Right, relatedBy: .Equal, toItem: nextButton, attribute: .Left, multiplier: 1.0, constant: -1.0)
            }
            
            
            var leftConstraint : NSLayoutConstraint!
            
            if index == 0 {
                
                leftConstraint = NSLayoutConstraint(item: button, attribute: .Left, relatedBy: .LessThanOrEqual, toItem: rowView, attribute: .Left, multiplier: 1.0, constant: 0.0)
                
            } else {
                
                let prevtButton = buttons[index-1]
                leftConstraint = NSLayoutConstraint(item: button, attribute: .Left, relatedBy: .Equal, toItem: prevtButton, attribute: .Right, multiplier: 1.0, constant: 1.0)
                
                let firstButton = buttons[0]
                let widthConstraint = NSLayoutConstraint(item: firstButton, attribute: .Width, relatedBy: .Equal, toItem: button, attribute: .Width, multiplier: 1.0, constant: 0.0)
                
                widthConstraint.priority = 800.0
                rowView.addConstraint(widthConstraint)
            }
            
            rowView.addConstraints([topConstraint, bottomConstraint, rightConstraint, leftConstraint])
        }
    }
    
    
    func addConstraintsToInputView(inputView: UIView, rowViews: [UIView]){
        
        for (index, rowView) in rowViews.enumerate() {
            
            let rightSideConstraint = NSLayoutConstraint(item: rowView, attribute: .Right, relatedBy: .Equal, toItem: inputView, attribute: .Right, multiplier: 1.0, constant: 0.0)
            let leftConstraint = NSLayoutConstraint(item: rowView, attribute: .Left, relatedBy: .Equal, toItem: inputView, attribute: .Left, multiplier: 1.0, constant: 0.0)
            
            inputView.addConstraints([leftConstraint, rightSideConstraint])
            
            var topConstraint: NSLayoutConstraint
            
            if index == 0 {
                topConstraint = NSLayoutConstraint(item: rowView, attribute: .Top, relatedBy: .Equal, toItem: inputView, attribute: .Top, multiplier: 1.0, constant: 0.0)
            } else {
                
                let prevRow = rowViews[index-1]
                topConstraint = NSLayoutConstraint(item: rowView, attribute: .Top, relatedBy: .Equal, toItem: prevRow, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
                
                let firstRow = rowViews[0]
                let heightConstraint = NSLayoutConstraint(item: firstRow, attribute: .Height, relatedBy: .Equal, toItem: rowView, attribute: .Height, multiplier: 1.0, constant: 0.0)
                
                heightConstraint.priority = 800.0
                inputView.addConstraint(heightConstraint)
            }
            inputView.addConstraint(topConstraint)
            
            var bottomConstraint: NSLayoutConstraint
            
            if index == (rowViews.count - 1) {
                bottomConstraint = NSLayoutConstraint(item: rowView, attribute: .Bottom, relatedBy: .Equal, toItem: inputView, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
                
            } else {
                
                let nextRow = rowViews[index+1]
                bottomConstraint = NSLayoutConstraint(item: rowView, attribute: .Bottom, relatedBy: .Equal, toItem: nextRow, attribute: .Top, multiplier: 1.0, constant: 0.0)
            }
            
            inputView.addConstraint(bottomConstraint)
        }
        
    }
    
    
    
    func createRowOfButtons(buttonTitles: [NSString]) -> UIView {
        
        var buttons = [UIButton]()
        let keyboardRowView = UIView(frame: CGRectMake(0, 0, 320, 50))
        
        for buttonTitle in buttonTitles{
            
            let button = createButtonWithTitle(buttonTitle as String)
            buttons.append(button)
            keyboardRowView.addSubview(button)
        }
        
        addIndividualButtonConstraints(buttons, rowView: keyboardRowView)
        
        return keyboardRowView
    }
    
    

    
          
}



