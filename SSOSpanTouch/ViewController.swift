//
//  ViewController.swift
//  SSOSpanTouch
//
//  Created by Stoo on 2017-01-16.
//  Copyright © 2017 StooSepp. All rights reserved.
//

import UIKit

class ViewController: UIViewController, CircleButtonDelegate {
    
    //MARK: - HOW THIS ALL WORKS
     /*
     
     Practice
     Part A) 4 Trials with letter sets from 2-3 (Counts 2,2,3,3 in order)
     Part B) 15 Trials and of math task
     Part C) Combined practice of recalling sequence of letters (set size 2 only) and math problem: each letter is
     preceded by a math problem (3 trials)
     Letter recall is done by picking out letters from a provided letter matrix
     
     Test
     15 Trials (15 = 3 repetitions of 5 set sizes; order of set sizes is randomly determined):
     Recalling sequences of letters (set size 3-7): each letter is preceded by a math problem;
     Array of Set Sizes - (3,3,3,4,4,4,5,5,5,6,6,6,7,7,7)
     
     Scoring - 5 Values
     1) OSPAN Absolute Score - Sum of all perfectly recalled letter sets
     2) OSPAN Total Correct - Total number of letters recalled in the correct position
     3) Math Total Errors - Total numer of errors in math responses (correct answers or time related)
     4) Math Accuracy Errors - Was the answer correct errors
     5) Math Speed Errors - total number of times participant ran out of time in solving the math problem
 */

    //StoryBoard Elements
    @IBOutlet var letterResponseStackView:UIStackView!
    @IBOutlet var letterCountStackView:UIStackView!
    @IBOutlet var primaryLabel:UILabel!
    @IBOutlet var instructionsLabel:UILabel!
    @IBOutlet var percentageCorrectLabel:UILabel!
    @IBOutlet var percentageReminderLabel:UILabel!
    @IBOutlet var letterButtonStackView:UIStackView!
    @IBOutlet var questionMarkButton:CircleButton!
    @IBOutlet var backSpaceButton:CircleButton!
    @IBOutlet var trueButton:CircleButton!
    @IBOutlet var falseButton:CircleButton!
    @IBOutlet var confirmButton:UIButton!
    
    //Letter Response
    var letterResponseLabelArray = [UILabel]()
    
    var letterResponseCount:Int = 0
    //var letterResponseString = ""
    
    //General Setup
    let letterDuration = 1000 //milliseconds
    var avgMathSolveDuration = 5.0//seconds
    var mathQuestionDuration = [Double]()
    var hasSetupTestData = false
    
    
    var now:Date!
    
    //Arrays
    
    //universal
    var letterArray = [String]()
    var currentLetterSet = [String]()
    var currentScreen = 0
    var currentQuestionIndex = 0
    var hasSeenEquation = false
    var hasInputtedLetters = false
    
    //Practice
    var equationArray = [String]()//static equations
    var equationAnswersArray = [String]()//static equations
    var equationTFArray = [String]()
    
    //Practice & Test Both
    var currentSequenceArray = [Int]()
    var questionsCompleted = 0
    var currentSequenceIndex = 0
    var currentEquationSet = [(equationString:String, TFString:String)]()
    
    
    //Scoring
    var OSpanAbsoluteScore = 0//Sum of all perfectly recalled letter sets
    var OSpanTotalCorrect = 0//Total number of letters recalled in the correct position
    var mathTotalErrors = 0//Total numer of errors in math responses (correct answers or time related)
    var mathAccuracyErrors = 0//True or False Math Accuracy Errors
    var mathSpeedErrors = 0//Total times participant ran out of time in solving the math problem
    
    //Constants    
    let kLetterPractice = 0
    let kMathPractice = 1
    let kBothPractice = 2
    let kBothTest = 3
    var currentPhase:Int = 0
    
    var delayedTaskArray = [DispatchWorkItem]()
    
   
    //MARK: - VIEW LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Setup StackView
        for stackView in letterButtonStackView.arrangedSubviews{
            for circle in (stackView as! UIStackView).arrangedSubviews{
                let circleButton = circle as! CircleButton
                circleButton.delegate = self
            }
        }
        questionMarkButton.delegate = self
        backSpaceButton.delegate = self
        falseButton.delegate = self
        trueButton.delegate = self
        
        
        
        //Setup Instructions
        let constants = OSpanConstants.init()
       
        instructionsLabel.sizeToFit()
        instructionsLabel.text = "In this game you will solve simple math problems while you try to remember letters shown on the screen.\n\nIn the next few minutes, you will have some practice to get you familiar with how the game works. It's meant to be challenging, so just try your best.\n\nWe will begin by practicing the letter part of the experiment.\n\nTap the Confirm button below to begin."
        
        letterArray = constants.lettersArray
        equationArray = constants.practiceOperationsArray
        equationAnswersArray = constants.practiceAnswerArray
        equationTFArray = constants.practiceTrueFalseArray
        
        //Hidden Stuff First
       
        trueButton.isHidden = true
        falseButton.isHidden = true
        
        letterResponseStackView.isHidden = true
        letterCountStackView.isHidden = true
        questionMarkButton.isHidden = true
        backSpaceButton.isHidden = true
        letterButtonStackView.isHidden = true
        percentageCorrectLabel.isHidden = true
        //percentageReminderLabel.isHidden = true
        
        primaryLabel.isHidden = true
        
        
        //Setup
     
    
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //Setup
    func setupLetterResponseWithCount(_ count:Int){
        //Remove All subviews
        letterResponseLabelArray.removeAll()
        for letterCountLabel in letterCountStackView.arrangedSubviews{
            letterCountLabel.removeFromSuperview()
        }
        for letterResponseLabel in letterResponseStackView.arrangedSubviews{
            letterResponseLabel.removeFromSuperview()
        }
        for index in 1...count{
            //Add Letter Count
            let countLabel = UILabel()
            countLabel.text = "\(index)"
            countLabel.textColor = UIColor.lightGray
            countLabel.font = UIFont.systemFont(ofSize: 20)
            countLabel.textAlignment = .center
            letterCountStackView.addArrangedSubview(countLabel)
            
            //Add Letter Label
            let letterLabel = UILabel()
            letterLabel.text = "-"
            letterLabel.font = UIFont.systemFont(ofSize: 40)
            letterLabel.textAlignment = .center
            letterResponseStackView.addArrangedSubview(letterLabel)
            //letterResponseLabelArray.append(letterLabel)
            
            let widthConstraint1 = NSLayoutConstraint(item: countLabel, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 75)
             let widthConstraint2 = NSLayoutConstraint(item: letterLabel, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 75)
            let heightConstraint = NSLayoutConstraint(item: letterLabel, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 100)
            
            letterCountStackView.addConstraints([widthConstraint1])
            letterResponseStackView.addConstraints([widthConstraint2,heightConstraint])
        }
    }
    
    func updateLetterSet(from:Int,to:Int){
        currentLetterSet.removeAll()
        for index in from...to{
            let letter = letterArray[index]
            currentLetterSet.append(letter)
        }
    }
    
    func updateLetterSetToRandom(_ withCount:Int){
        currentLetterSet.removeAll()
        for index in 0...withCount{
            //do stuff here
        }
    }
    

    
    /*
     print("Delay is \(avgTimeMilliseconds) milliseconds.")
     let time = DispatchTime.now() + Double(Int64(avgTimeMilliseconds)
     delayedTask = DispatchWorkItem {
     //Do stuff after delay here
     }
     DispatchQueue.main.asyncAfter(deadline: time, execute: delayedTask)
     
      */
    
    
    //MARK: - User Interactions
    func deleteTapped(){
        if letterResponseLabelArray.count != 0{
            let currentLabel = letterResponseStackView.arrangedSubviews[letterResponseLabelArray.count-1] as! UILabel
            currentLabel.text = "-"
            letterResponseLabelArray.removeLast()
        }
        else{
            AnimationsHelper.shakeView(letterResponseStackView)
        }
        
    }
    func hideLetterAnswerElements(){
        AnimationsHelper.fadeOut(letterButtonStackView)
        AnimationsHelper.fadeOut(questionMarkButton)
        AnimationsHelper.fadeOut(backSpaceButton)
        AnimationsHelper.fadeOut(letterResponseStackView)
        AnimationsHelper.fadeOut(letterCountStackView)
        //AnimationsHelper.fadeOut(confirmButton)
    }
    
    func showLetterAnswerElements(){
        AnimationsHelper.fadeIn(letterButtonStackView)
        AnimationsHelper.fadeIn(questionMarkButton)
        AnimationsHelper.fadeIn(backSpaceButton)
        AnimationsHelper.fadeIn(letterResponseStackView)
        AnimationsHelper.fadeIn(letterCountStackView)
        AnimationsHelper.fadeIn(confirmButton)
    }
    func hideTrueAndFalseElements(){
        AnimationsHelper.fadeOut(trueButton)
        AnimationsHelper.fadeOut(falseButton)
    }
    
    func showTrueAndFalseElements(){
        AnimationsHelper.fadeIn(trueButton)
        AnimationsHelper.fadeIn(falseButton)
    }
    
    func resetLetterIntput(){
        
    }
    
    //MARK: Confirm Button Pressed
    @IBAction func confirmButtonPressed(_ sender: UIButton) {
        switch currentPhase {
        case kLetterPractice:
            switch currentScreen {
            case 0:
                currentScreen += 1
                instructionsLabel.text = "For this first set of practice questions, letters will appear on the screen one at a time. Try to remember each letter in the order presented.\n\nWhen you're ready, tap the Confirm button below, and the letters will immediately appear."
            case 1:
                runLetterPractice(sequence: [0,1])
            case 2:
                if checkLetters() == true{
                    hideLetterAnswerElements()
                    AnimationsHelper.fadeIn(instructionsLabel)
                    
                    if answerCorrect() == true{
                        instructionsLabel.text = "Well done, you got them both right.\n\nTap the confirm button to move onto the next set."
                    }
                    else{
                        instructionsLabel.text = "Good try, the correct letters were \(currentLetterSet[0]) and \(currentLetterSet[1])\n\nTap the confirm button to move onto the next set."
                    }
                    currentScreen += 1
                }
                else{
                    for index in 0...currentLetterSet.count - 1{
                        let label = letterResponseStackView.arrangedSubviews[index] as! UILabel
                        AnimationsHelper.shakeView(label)
                    }
                }
                
            case 3:
                runLetterPractice(sequence: [2,3])
            case 4:
                if checkLetters() == true{
                    hideLetterAnswerElements()
                    AnimationsHelper.fadeIn(instructionsLabel)
                    if answerCorrect() == true{
                        instructionsLabel.text = "Well done, you got them both right.\n\nTap the confirm button to move onto the next set."
                    }
                    else{
                        instructionsLabel.text = "Good try, the correct letters were \(currentLetterSet[0]) and \(currentLetterSet[1])\n\nTap the confirm button to move onto the next set."
                    }
                    currentScreen += 1
                }
                else{
                    for index in 0...currentLetterSet.count - 1{
                        let label = letterResponseStackView.arrangedSubviews[index] as! UILabel
                        AnimationsHelper.shakeView(label)
                    }
                }
            case 5:
                runLetterPractice(sequence: [4,5,6])
            case 6:
                if checkLetters() == true{
                    hideLetterAnswerElements()
                    AnimationsHelper.fadeIn(instructionsLabel)
                    if answerCorrect() == true{
                        instructionsLabel.text = "Well done, you got them all right.\n\nTap the confirm button to move onto the next set."
                    }
                    else{
                        instructionsLabel.text = "Good try, the correct letters were \(currentLetterSet[0]),\(currentLetterSet[1]) and \(currentLetterSet[2])\n\nTap the confirm button to move onto the next set."
                    }
                    currentScreen += 1
                }
                else{
                    for index in 0...currentLetterSet.count - 1{
                        let label = letterResponseStackView.arrangedSubviews[index] as! UILabel
                        AnimationsHelper.shakeView(label)
                    }
                }
            case 7:
                runLetterPractice(sequence: [7,8,9])
            case 8:
                if checkLetters() == true{
                    hideLetterAnswerElements()
                    AnimationsHelper.fadeIn(instructionsLabel)
                    if answerCorrect() == true{
                        instructionsLabel.text = "Well done, you got them all right.\n\nTap the confirm button to move onto the math practice."
                    }
                    else{
                        instructionsLabel.text = "Good try, the correct letters were \(currentLetterSet[0]),\(currentLetterSet[1]) and \(currentLetterSet[2])\n\nTap the confirm button to move onto math practice section."
                    }
                    currentScreen = 0
                    currentPhase = kMathPractice
                }
                else{
                    for index in 0...currentLetterSet.count - 1{
                        let label = letterResponseStackView.arrangedSubviews[index] as! UILabel
                        AnimationsHelper.shakeView(label)
                    }
                }
                
            default:
                print("")
            }
            
        case kMathPractice:
            if currentScreen == 0{
                currentQuestionIndex = 0
                resetEveryValue()
                currentScreen += 1
                 instructionsLabel.text = "For this set of practice questions, simple math problems will appear on the screen one at a time. Your job is to look at the math question and its answer and figure out if the answer is true or false. \n\nTake as much time as you need to get the answer right, then tap 'True' or 'False', then the Confirm Button below."
            }
            else{
                runMathPractice()
            }
          
        case kBothPractice:
            if currentScreen == 0{
                print("Avg Question Delay:\(avgMathSolveDuration)")
                if mathQuestionDuration.count != 0{
                    let newQuestionDelay = standardDeviation(mathQuestionDuration) * 2.5
                    print("SD of times was \(standardDeviation(mathQuestionDuration))" )
                    avgMathSolveDuration += Swift.abs(newQuestionDelay)
                }
               
                print("New Avg Question Delay:\(avgMathSolveDuration)")
                AnimationsHelper.fadeOut(percentageCorrectLabel)
                resetEveryValue()
                currentScreen += 1
                instructionsLabel.text = "For this set of practice questions, the math and letter questions will be combined into 3 sets of 2 letters and math questions.\n\nFirst you will see a math question and just like the last activity, you'll choose whether the answer is true or false, then a letter will appear.\n\nTap the Confirm Button below"
            }
            else if currentScreen == 1{
                instructionsLabel.text = "The challenge is that now there is a time limit. It is the average time it took you to solve the math questions you just completed plus a little extra time. If you don't solve the math question in time, the letter to remember will appear after your time is up, followed by the next math question.\n\nWhen you're ready, tap the confirm to show the first math question."
                currentScreen += 1
            }
            else{
                currentSequenceArray = [2,2,2]
                runBoth(sequenceArray: currentSequenceArray)
            }
        case kBothTest:
            if currentScreen == 0{
                //Reset Everything
                resetEveryValue()
                AnimationsHelper.fadeOut(percentageCorrectLabel)
                currentScreen += 1
                jumbleTestSetSizes()
                
                instructionsLabel.text = "Now it's time to complete the actual test. This will take about 15 mins.\n\nIn this section, you'll be given 15 different sets of math questions and letters to remember, ranging in size from 3 to 7.\n\nThis will be even more challenging than the last practice activity, so try your best, but above all, make sure you get the math True or False questions correct.\n\nTap the Confirm button below to start the test."
            }
            else{
                
                runBoth(sequenceArray:currentSequenceArray)
            }
        default:
            print("")
        }
    }
    
    func resetEveryValue(){
        currentSequenceArray.removeAll()
        currentQuestionIndex = 0
        currentSequenceIndex = 0
        OSpanAbsoluteScore = 0
        OSpanTotalCorrect = 0
        mathAccuracyErrors = 0
        mathSpeedErrors = 0
        mathTotalErrors = 0
        questionsCompleted = 0
        hasSeenEquation = false
        hasSetupTestData = false
    }
    
    func updateAndShowPercentageCorrect(){
        let percentage = Float(questionsCompleted - (mathSpeedErrors + mathAccuracyErrors)) / Float(questionsCompleted)
        print("Score: \(questionsCompleted - (mathSpeedErrors + mathAccuracyErrors))/\(questionsCompleted) = \(percentage)")
        
        percentageCorrectLabel.text = "\(Int(percentage*100))%" //Correct"
        hideTrueAndFalseElements()
        if percentageCorrectLabel.isHidden == true{
            AnimationsHelper.fadeIn(percentageCorrectLabel)
        }
//        if percentageReminderLabel.isHidden == true && currentPhase == kBothPractice{
//            AnimationsHelper.fadeIn(percentageReminderLabel)
//        }

    }
   

    //MARK: - AOSPAN Functions
    func runLetterPractice(sequence:[Int]){
        AnimationsHelper.fadeOut(instructionsLabel)
        AnimationsHelper.fadeOut(confirmButton)
        //wait
        updateLetterSet(from: sequence.first!, to: sequence.last!)
        let delayedAppearance = DispatchTime.now() + .milliseconds(letterDuration)
        let waitTask = DispatchWorkItem {
            //Show First letter
            self.primaryLabel.isHidden = false
            self.primaryLabel.text = self.currentLetterSet[0]
            
        }
        DispatchQueue.main.asyncAfter(deadline: delayedAppearance, execute: waitTask)
        //setup Letters
        for index in 0...sequence.count - 1{
            let delayInMilliseconds = letterDuration * (index + 1)
            let taskAppearance = DispatchTime.now() + .milliseconds(delayInMilliseconds)
            let task = DispatchWorkItem {
                //Show First letter
                self.primaryLabel.text = self.currentLetterSet[index]
            }
            DispatchQueue.main.asyncAfter(deadline: taskAppearance, execute: task)
        }
        //Last One
        let finalDelay = letterDuration  *  (sequence.count + 1)
        let endOfSequenceAppearance = DispatchTime.now() + .milliseconds(finalDelay)
        let endSequenceTask = DispatchWorkItem {
            //Show SecondLetter
            self.primaryLabel.isHidden = true
            self.showLetterAnswerElements()
            
            if self.currentScreen == 1{
                AnimationsHelper.fadeIn(self.instructionsLabel)
                 self.instructionsLabel.text = "Great! Tap the letters below in the order you saw them. If you don't remember which letter appeared in the sequence, just tap the '?' button in its place. \n\nTap the Confirm button when you're finished."
            }
            
            if self.currentScreen == 3{
                AnimationsHelper.fadeIn(self.instructionsLabel)
               self.instructionsLabel.text = "Great! Tap the letters below in the order you saw them.  \n\nTap the Confirm button when you're finished."
            }
         
            
            self.setupLetterResponseWithCount(self.currentLetterSet.count)
            self.currentScreen += 1
        }
        DispatchQueue.main.asyncAfter(deadline: endOfSequenceAppearance, execute: endSequenceTask)
    }
    
    func runMathPractice(){
        //Run Math Test
        if hasSeenEquation == false{
            for task in delayedTaskArray{
                task.cancel()
            }
            delayedTaskArray.removeAll()
            AnimationsHelper.fadeOut(instructionsLabel)
            AnimationsHelper.fadeOut(percentageCorrectLabel)
            let delayedAppearance = DispatchTime.now() + .milliseconds(letterDuration)
            let waitTask = DispatchWorkItem {
                //Show First letter
                if self.currentQuestionIndex < 4{
                    self.instructionsLabel.isHidden = false
                    self.instructionsLabel.text = "Choose if this is the correct answer, then Tap the Confirm Button below to check your answer."
                }
                else{
                    self.instructionsLabel.isHidden = true
                }
                self.primaryLabel.isHidden = false
                self.primaryLabel.alpha = 1.0
                let equationString = self.equationArray[self.currentQuestionIndex] + " = " + self.equationAnswersArray[self.currentQuestionIndex]
                self.primaryLabel.text = equationString
                self.trueButton.isHidden = false
                self.falseButton.isHidden = false
                self.confirmButton.isHidden = false
                self.now = Date()
                print("Timer Fired to show equation")
                self.hasSeenEquation = true
            }
            delayedTaskArray.append(waitTask)
            DispatchQueue.main.asyncAfter(deadline: delayedAppearance, execute: waitTask)
        }
        else{
            for task in delayedTaskArray{
                task.cancel()
            }
            delayedTaskArray.removeAll()
          if (trueButton.selected == false && falseButton.selected == false){
                AnimationsHelper.shakeView(trueButton)
                AnimationsHelper.shakeView(falseButton)
            }
            else{
           
                questionsCompleted += 1
                let questionEndedTime = Date()
                let offset = offsetinSecondsFrom(now, toDate: questionEndedTime)
                mathQuestionDuration.append(offset)
                var totalMathOffset = 0.0
                for offsetInstance in mathQuestionDuration{
                    totalMathOffset += offsetInstance
                }
                avgMathSolveDuration = totalMathOffset/Double(mathQuestionDuration.count)
                instructionsLabel.isHidden = false
                AnimationsHelper.fadeOut(primaryLabel)
                if currentQuestionIndex < 4{
                    if answerCorrect() == true {
                        instructionsLabel.text = "You're right! The answer was \(equationTFArray[currentQuestionIndex]).\n\nDuring this exercise, it's important to keep your math accuracy above 85% -  your current accuracy is shown the top right corner. If it drops below 85%, the game can't record your score, so concentrate on your math, and only tap the confirm button when you're sure you have the T/F answer right.\n\nTap the Confirm Button below to show the next question."
                    }
                    else{
                        instructionsLabel.text = "Better luck next time! \(equationAnswersArray[currentQuestionIndex]) was actually \(equationTFArray[currentQuestionIndex]).\n\nDuring this exercise, it's important to keep your math accuracy above 85% - your current accuracy is shown the top right corner. If it drops below 85%, the game can't record your score, so concentrate on the math, and only tap the confirm button when you're sure you have the T/F Answer right.\n\nTap the Confirm Button below to show the next question."
                        mathAccuracyErrors += 1
                    }
                }
                else if currentQuestionIndex >= 4 && currentQuestionIndex < 8{
                    if answerCorrect() == true {
                        instructionsLabel.text = "Well done. Remember to keep your accuracy up above 85%.\n\nTap the Confirm Button below to show the next question."
                    }
                    else{
                        instructionsLabel.text = "Better luck next time! \(equationAnswersArray[currentQuestionIndex]) was actually \(equationTFArray[currentQuestionIndex]).\n\nRemember to keep your accuracy up above 85%.\n\nTap the Confirm Button below to show the next question."
                        mathAccuracyErrors += 1
                    }
                }
                else if currentQuestionIndex >= 8 && currentQuestionIndex < equationAnswersArray.count - 1{
                    if answerCorrect() == false {
                        mathAccuracyErrors += 1
                    }
                    instructionsLabel.text = "Tap the Confirm Button to show the next question."
                }
                else if currentQuestionIndex == equationAnswersArray.count - 1{
                    //This is over
                    instructionsLabel.text = "Well done. You've finished this practice set.\n\nTap the Confirm Button below to move on to the next practice activity."
                    currentPhase = kBothPractice
                    currentScreen = 0
                    trueButton.selected = false
                    falseButton.selected = false
                    
                }
                updateAndShowPercentageCorrect()
                hideTrueAndFalseElements()
                if percentageCorrectLabel.isHidden == true{
                    AnimationsHelper.fadeIn(percentageCorrectLabel)
                }
                currentQuestionIndex += 1
                hasSeenEquation = false
               
            }
        }
    }
    func movetoNextSequence(){
         //print("Speed Errors: \(mathSpeedErrors)\nAccuracy Errors:\(mathAccuracyErrors)\nOSpanAbsScore:\(OSpanAbsoluteScore)\nOSpanTotalCorrect:\(OSpanTotalCorrect))")
        hasSeenEquation = false
        currentQuestionIndex = 0
        currentSequenceIndex += 1
        hideLetterAnswerElements()
        runBoth(sequenceArray: currentSequenceArray)
    }
   
    
    func runBoth(sequenceArray:[Int]){
       
        if hasSeenEquation == true{
             //Stop Delayed Tasks and show True or False for Equation
           
            
            if hasSetupTestData == false{//At the end of a sequence
                print("At the end of a sequence")
                if checkLetters() == true{
                    if answerCorrect(){
                        OSpanAbsoluteScore += 1
                        print("Got them both right")
                    }
                    else{
                        print("Didn't get them both right.")
                    }
                    //Move onto the Next Sequence
                    
                    movetoNextSequence()
                }
                else{
                    for index in 0...currentLetterSet.count - 1{
                        let label = letterResponseStackView.arrangedSubviews[index] as! UILabel
                        AnimationsHelper.shakeView(label)
                    }
                }
                
                
            }
            else{ //In the middle of a sequence
                print("In the middle of a sequence")
                //Show TF Screen
                if (trueButton.selected == false && falseButton.selected == false){
                    AnimationsHelper.shakeView(trueButton)
                    AnimationsHelper.shakeView(falseButton)
                }
                else{
                    if answerCorrect() == false{
                        mathAccuracyErrors += 1
                        print("Got this Question Wrong")
                    }
                    //Do stuff after TF answered
                    self.questionsCompleted += 1
                    self.confirmButton.isHidden = true
                    hideTrueAndFalseElements()
                    
                    for task in delayedTaskArray{
                        task.cancel()
                    }
                    delayedTaskArray.removeAll()
                    startTimedSequence(mathIncluded: false)
                }
            }
        }
        else{
            //Setup equations for Array
            if currentSequenceIndex < sequenceArray.count{
    
                //Run the test
                let count = sequenceArray[currentSequenceIndex]
                print("There are \(count) questions in this sequence.")
                print("Sequence:\(currentSequenceIndex) Question:\(currentQuestionIndex)")
                if currentQuestionIndex < count{
                    
                    //Run
                    if hasSetupTestData == false{
                        setCurrentLetterSet(setCount: count)
                        setRandomMathEquation(setCount: count)
                        hasSetupTestData = true
                        print("Setting up data with count:\(count), Sequence letters are \(currentLetterSet)")
                        //AnimationsHelper.fadeOut(instructionsLabel)
                    }
                    else{
                        print("Data Already setup with Count:\(count) sequences")
                        print("Did Tap Confirm button on Equation: \(hasSeenEquation)")
                    }
                    
                    startTimedSequence(mathIncluded: true)
                    hasSeenEquation = true
                }
                else{
                    print("Got to end of this sequence")
                    //Show Letter Matrix
                    hasSeenEquation = true
                    hasSetupTestData = false
                    showLetterAnswerElements()
                    updateAndShowPercentageCorrect()
                    self.setupLetterResponseWithCount(count)
                    
                }

            }
            else{
                //It's over
                print("Whole Sequence is over")
                
                AnimationsHelper.fadeIn(instructionsLabel)
                updateAndShowPercentageCorrect()
                let percentage = Float(questionsCompleted - (mathSpeedErrors + mathAccuracyErrors)) / Float(questionsCompleted)
                if currentPhase == kBothPractice{
                    if percentage < 0.85{
                        instructionsLabel.text = "Great Job. Here are your results:\n\nMath Timer expired: \(mathSpeedErrors) || Incorrect Math Question: \(mathAccuracyErrors) || Sets of letters correct: \(OSpanAbsoluteScore) || Total letters correct: \(OSpanTotalCorrect)\n\nYour math score was below 85%, as shown above, so when you're doing the test section next, concentrate on the math True and False questions as your priority.\n\nTap the confirm button to continue."
                    }
                    else{
                        instructionsLabel.text = "Great Job.\n\n Here are your results:\nMath Timer expired: \(mathSpeedErrors) || Incorrect on Math Question: \(mathAccuracyErrors) || Sets of letters correct: \(OSpanAbsoluteScore) || Individual letters correct: \(OSpanTotalCorrect)\n\nYour math score was above 85%, as shown above. Keep correct answers on the math True and False questions as your priority.\n\nTap the confirm button to continue."
                    }
                     currentPhase = kBothTest
                }
                else if currentPhase == kBothTest{
                    if percentage < 0.85{
                        instructionsLabel.text = "Great Job. Here are your results:\n\nMath Timer expired: \(mathSpeedErrors)\nIncorrect Math Question: \(mathAccuracyErrors)\nSets of letters correct: \(OSpanAbsoluteScore)\nTotal letters correct: \(OSpanTotalCorrect)\n\nYour math score was below 85%, as shown above, so we cannot use your score.\n\nTap the confirm button to continue."
                    }
                    else{
                        instructionsLabel.text = "Great Job.\n\n Here are your results:\nMath Timer expired: \(mathSpeedErrors)\nIncorrect on Math Question: \(mathAccuracyErrors)\nSets of letters correct: \(OSpanAbsoluteScore)\nTotal letters correct: \(OSpanTotalCorrect)\n\nYour math score was above 85%, as shown above so we can use your score. Well done.\n\nTap the confirm button to continue."
                    }
                }
             
               
                currentScreen = 0
                
                
            }
        }
        
    }

    func startTimedSequence(mathIncluded:Bool){
        
        self.primaryLabel.isHidden = true
        AnimationsHelper.fadeOut(instructionsLabel)
        if percentageCorrectLabel.isHidden == false{
            AnimationsHelper.fadeOut(percentageCorrectLabel)
        }
        var delayInMilleseconds = 1000//Initial Delay
        var delayTime = DispatchTime.now() + .milliseconds(delayInMilleseconds)
        hasSeenEquation = true
        if mathIncluded == true{
            
            //Wait then show Question
            let waitTask = DispatchWorkItem {
                //Show Equation
                self.primaryLabel.isHidden = false
                self.hasSeenEquation = true
                self.primaryLabel.alpha = 1.0
                self.primaryLabel.text = self.currentEquationSet[self.currentQuestionIndex].equationString
                self.confirmButton.isHidden = false
                
                self.trueButton.isHidden = false
                self.falseButton.isHidden = false
            }
            delayedTaskArray.append(waitTask)
            DispatchQueue.main.asyncAfter(deadline: delayTime, execute: waitTask)
            
            //Wait then Show Letter
            delayInMilleseconds = delayInMilleseconds + Int(avgMathSolveDuration * 1000)
            delayTime = DispatchTime.now() + .milliseconds(delayInMilleseconds)
        }
        //Wait then Show Letter
        let showLetterTask = DispatchWorkItem{
            self.primaryLabel.isHidden = false
            self.primaryLabel.text = self.currentLetterSet[self.currentQuestionIndex]
            self.hasSeenEquation = false
            self.trueButton.isHidden = true
            self.falseButton.isHidden = true
            self.confirmButton.isHidden = true
            if mathIncluded == true{
                self.questionsCompleted += 1
                self.mathSpeedErrors += 1
                self.trueButton.selected = false
                self.falseButton.selected = false
                
            }
            
        }
        delayedTaskArray.append(showLetterTask)
        DispatchQueue.main.asyncAfter(deadline: delayTime, execute: showLetterTask)
         print("Letter shown after \(delayInMilleseconds) milliseconds")
       
        //Wait then Hide Letter
        delayInMilleseconds = delayInMilleseconds + 1000
        delayTime = DispatchTime.now() + .milliseconds(delayInMilleseconds)
        let hideLetterTask = DispatchWorkItem {
            //Hide Letter
            self.primaryLabel.isHidden = true
           
            
    
        }
        delayedTaskArray.append(hideLetterTask)
        DispatchQueue.main.asyncAfter(deadline: delayTime, execute: hideLetterTask)
        
        //Hide Letter and Wait
        delayInMilleseconds = delayInMilleseconds + 1000
        delayTime = DispatchTime.now() + .milliseconds(delayInMilleseconds)
        let startNextQuestionTask = DispatchWorkItem {
            //Show Equation
            self.currentQuestionIndex += 1
            self.hasSeenEquation = false
            print("Current Sequence is \(self.currentSequenceArray)")
            self.runBoth(sequenceArray: self.currentSequenceArray)
        }
        delayedTaskArray.append(startNextQuestionTask)
        DispatchQueue.main.asyncAfter(deadline: delayTime, execute: startNextQuestionTask)
    }
    
    //MARK: - Question Generation
    //Testing shit
    
    func jumbleTestSetSizes(){
        
        currentLetterSet.removeAll()
        let constants = OSpanConstants.init()
        var setCountArray = constants.setCountArray
        while setCountArray.count != 0{
            //Get Bool Value
            let randomNumberIndex = Int(arc4random_uniform(UInt32(setCountArray.count)))
            let randomNumber = setCountArray[randomNumberIndex]
            currentSequenceArray.append(randomNumber)
            setCountArray.remove(at: randomNumberIndex)
        }
        print("JumbledSet - \(currentSequenceArray)")
    }
    
    func setCurrentLetterSet(setCount:Int){
        currentLetterSet.removeAll()
        let constants = OSpanConstants.init()
        var lettersArray = constants.lettersArray
        for _ in 1...setCount{
            //Get Bool Value
            let randomLetterIndex = Int(arc4random_uniform(UInt32(lettersArray.count)))
            let randomLetter = lettersArray[randomLetterIndex]
            currentLetterSet.append(randomLetter)
            lettersArray.remove(at: randomLetterIndex)
        }
    }
    
    func answerFromString(equationString:String) ->Int{
        var finalEquationString = ""
        if equationString.contains("x"){
            finalEquationString = (equationString as NSString).replacingOccurrences(of: "x", with: "*")
        }
        else{
            finalEquationString = equationString
        }
        let expn = NSExpression(format:finalEquationString)
        let answer = expn.expressionValue(with: nil, context: nil)
        return answer as! Int
    }
    
    func setRandomMathEquation(setCount:Int){//->[(equationString:String, TFString:String, answerString:String)]{
        currentEquationSet.removeAll()
        //equationArray.removeAll()
        //Generating the math problem has 4 steps
        //1. Selection of the first operation, MathOpt01: "(9/3)"
        //2. Selection of the second operation, MathOpt012: "- 2"
        //3. Selection of whether the answer presented to subjects should be true or false, MathCorrect: "TRUE" or "FALSE"
        //4. A random number added to the correct answer to make it false, MathRand: "3"
        //Setup
        //var randomMathEquations = [(equationString:String, TFString:String, answerString:String)]()

        let constants = OSpanConstants.init()
        let trueFalseArray = constants.trueFalseArray
        let equationArray = constants.testOperationsArray
        let signsArray = constants.signsArray
        let modifierArray = constants.modifiersArray
        
        for index in 1...setCount{
            //Get Bool Value
            let randomTFIndex = Int(arc4random_uniform(UInt32(trueFalseArray.count)))
            let trueFalseString = trueFalseArray[randomTFIndex]
            let trueFalseValue = boolValue(bool: trueFalseString)
            
             //Get Equation
            let randomEquationIndex = Int(arc4random_uniform(UInt32(equationArray.count)))
            let randomSignIndex = Int(arc4random_uniform(UInt32(signsArray.count)))
            let randomModifierIndex = Int(arc4random_uniform(UInt32(modifierArray.count)))
            let tempEquationString = equationArray[randomEquationIndex]
            var signString = signsArray[randomSignIndex]
            var modiferString = modifierArray[randomModifierIndex]
            var finalString = "\(tempEquationString) \(signString) \(modiferString)"
            var answer = answerFromString(equationString: finalString)
            
            if answer < 1{
                var revisedAnswer = 0
                while revisedAnswer < 1{
                    //print("Answer is less than 1")
                    let revisedSignIndex = Int(arc4random_uniform(UInt32(signsArray.count)))
                    let revisedModifierIndex = Int(arc4random_uniform(UInt32(modifierArray.count)))
                    signString = signsArray[revisedSignIndex]
                    modiferString = modifierArray[revisedModifierIndex]
                    finalString = "\(tempEquationString) \(signString) \(modiferString)"
                    
                    revisedAnswer = answerFromString(equationString: finalString)
                    
                }
                answer = revisedAnswer
                
            }
            //Make True Question
            if trueFalseValue == true{
                print("\(index) - T: \(finalString) = \(answer)")
                currentEquationSet.append((equationString:"\(finalString) = \(answer)", TFString:trueFalseString))
            }
            //Make False Question
            else{
                //Get Correct Answer
                let correctAnswer = answerFromString(equationString: finalString)
                
                //Modify It
                let revisedSignIndex = Int(arc4random_uniform(UInt32(signsArray.count)))
                let revisedModifierIndex = Int(arc4random_uniform(UInt32(modifierArray.count)))
                signString = signsArray[revisedSignIndex]
                modiferString = modifierArray[revisedModifierIndex]
                let wrongString = "\(correctAnswer) \(signString) \(modiferString)"
                var wrongAnswer = answerFromString(equationString: wrongString)
               
                if wrongAnswer < 1 || wrongAnswer == correctAnswer || wrongAnswer > 24{
                    var revisedAnswer = 0
                    while revisedAnswer < 1 || revisedAnswer == correctAnswer || revisedAnswer > 24{
                        //print("Answer is less than 1")
                        let revisedSignIndex = Int(arc4random_uniform(UInt32(signsArray.count)))
                        let revisedModifierIndex = Int(arc4random_uniform(UInt32(modifierArray.count)))
                        signString = signsArray[revisedSignIndex]
                        modiferString = modifierArray[revisedModifierIndex]
                        let revisedString = "\(correctAnswer) \(signString) \(modiferString)"
                        
                        revisedAnswer = answerFromString(equationString: revisedString)
                        print("False made - Right Answer:\(correctAnswer) :: Wrong Answer:\(revisedAnswer)")
                        
                    }
                    wrongAnswer = revisedAnswer
                    print("\(index) - F: \(finalString) = \(revisedAnswer)")
                    currentEquationSet.append((equationString:"\(finalString) = \(revisedAnswer)", TFString:trueFalseString))
                }
                else{
                    print("\(index) - F: \(finalString) = \(wrongAnswer)")
                    currentEquationSet.append((equationString:"\(finalString) = \(wrongAnswer)", TFString:trueFalseString))
                }
                
            }
        }
    }
    
    func boolValue(bool:String) ->Bool{
        var boolValue = false
        if bool == "TRUE"{
            boolValue = true
        }
        return boolValue
    }
    
    
    //MARK: - Circle Delegate
    func circleTapped(_ sender: CircleButton) {
        if sender == backSpaceButton{
            deleteTapped()
        }
        else if sender == trueButton{
            hasSeenEquation = true
            trueButton.selected = true
            falseButton.selected = false
        }
        else if sender == falseButton{
            hasSeenEquation = true
            falseButton.selected = true
            trueButton.selected = false
          
        }
        else{
           //Update Letter Response
            if letterResponseLabelArray.count == currentLetterSet.count{
                AnimationsHelper.shakeView(letterResponseStackView)
            }
            else{
                let currentLabel = letterResponseStackView.arrangedSubviews[letterResponseLabelArray.count] as! UILabel
                currentLabel.text = sender.titleLabel.text
                letterResponseLabelArray.append(currentLabel)
            }
            
        }
      
    }
    
    func checkLetters() -> Bool{
        var lettersAllIn = true
        let finalIndex = currentLetterSet.count - 1
        let label = letterResponseStackView.arrangedSubviews[finalIndex] as! UILabel
        if label.text == "-"{
            lettersAllIn = false
        }
        return lettersAllIn
        
    }
    
    //Check Answers
    func answerCorrect() -> Bool{
        var isCorrect = [Bool]()
        switch currentPhase {
        case kLetterPractice:
            for index in 0...currentLetterSet.count - 1{
                let correctLetter = currentLetterSet[index]
                let label = letterResponseStackView.arrangedSubviews[index] as! UILabel
                if correctLetter == label.text{
                    print("\(label.text) is right")
                    isCorrect.append(true)
                }
                else{
                    print("\(label.text) is wrong")
                    isCorrect.append(false)
                }
            }
        case kMathPractice:
            if trueButton.selected == true && equationTFArray[currentQuestionIndex] == "TRUE"{
                isCorrect.append(true)
                print("TRUE is Correct")
                
            }
            else if falseButton.selected == true && equationTFArray[currentQuestionIndex] == "FALSE"{
                isCorrect.append(true)
                print("FALSE is Correct")
                
            }
            else{
                isCorrect.append(false)
            }
            trueButton.selected = false
            falseButton.selected = false
            
        case kBothPractice,kBothTest:
            if hasSetupTestData == false{
                //At the End of a sequence
                for index in 0...currentLetterSet.count - 1{
                    let correctLetter = currentLetterSet[index]
                    let label = letterResponseStackView.arrangedSubviews[index] as! UILabel
                    if correctLetter == label.text{
                        print("\(label.text!) is right")
                        isCorrect.append(true)
                        OSpanTotalCorrect += 1
                    }
                    else{
                        print("\(label.text!) is wrong")
                        isCorrect.append(false)
                    }
                }
            }
            else{
                //In the middle of a sequence
                if trueButton.selected == true && currentEquationSet[currentQuestionIndex].TFString == "TRUE"{
                    isCorrect.append(true)
                    print("TRUE is Correct")
                 
                }
                else if falseButton.selected == true && currentEquationSet[currentQuestionIndex].TFString == "FALSE"{
                    isCorrect.append(true)
                    print("FALSE is Correct")
                  
                }
                else{
                    isCorrect.append(false)
                }
                trueButton.selected = false
                falseButton.selected = false
            }
        
        default:
            print("")
        }
        var finalCorrect = true
        if isCorrect.contains(false){
            finalCorrect = false
        }
        return finalCorrect
    }
    
    
    //Time offset
    func offsetinSecondsFrom(_ fromDate:Date, toDate:Date) -> Double{
        
        let second: NSCalendar.Unit = [.second]
        let difference = (Calendar.current as NSCalendar).components(second, from: fromDate, to: toDate, options: [])
        
        
        let startDouble = fromDate.timeIntervalSince1970
        let endDouble = toDate.timeIntervalSince1970
        let diffDouble = endDouble - startDouble
        print("SecondDouble: \(diffDouble)")
        print("SecondInt: \(difference.second!)")
        return diffDouble
    }
    //MARK:- Stats
    func mean(_ scores:[Double]) -> Double{
        var totalScore:Double = 0
        for score in scores{
            totalScore += score
        }
        if scores.count == 0{
            return 0.0
        }
        return Double(totalScore)/Double(scores.count)
    }
    
    func variance(_ scores:[Double]) -> Double{
        var sum:Double = 0.0
        let meanScore = mean(scores)
        for score in scores{
            let result = Double(score) - meanScore
            let resultSquared = powf(Float(result), 2.0)
            sum += Double(resultSquared)
        }
        let variance = sum / Double(scores.count-1)
        return variance
    }
    
    func standardDeviation(_ scores:[Double]) -> Double{
        let sampleVariance = variance(scores)
        return sqrt(sampleVariance)
    }


}
//MARK: - CONSTANTS
struct OSpanConstants {
    
    //Instructions
    var instructionsArray = [String]()
    
    //Practice
    var practiceOperationsArray = [String]()
    var practiceAnswerArray = [String]()
    var lettersArray = [String]()
    var practiceTrueFalseArray = [String]()
    
    //Test
    var setCountArray = [Int]()
    var testOperationsArray = [String]()
    var modifiersArray = [String]()
    var signsArray = [String]()
    var trueFalseArray = [String]()
    
    init() {
        
        //Pracice
        practiceOperationsArray = ["(1 x 2) + 1","(1 / 1) - 1","(7 x 3) - 3","(4 x 3) + 4","(3 / 3) + 2","(2 x 6) - 4","(8 x 9) - 8","(4 x 5) - 5","(4 x 2) + 6","(4 / 4) + 7","(8 x 2) - 8","(2 x 9) - 9","(8 / 2) + 9","(3 x 8) - 1","(6 / 3) + 1","(9 / 3) - 2"]//16 of these
        practiceAnswerArray = ["3","2","18","16","1","6","64","11","14","12","2","9","7","23","3","7"]//16 of these
        
        practiceTrueFalseArray = ["TRUE", "FALSE", "TRUE", "TRUE", "FALSE", "FALSE", "TRUE", "FALSE",
            "TRUE", "FALSE", "FALSE", "TRUE", "FALSE", "TRUE", "TRUE", "FALSE"]//16 of these
 
        //Test
        testOperationsArray = ["(1 / 1)", "(2 / 1)", "(2 / 2)", "(3 / 1)", "(3 / 3)", "(4 / 1)", "(4 / 2)", "(4 / 4)",
        "(5 / 1)", "(5 / 5)", "(6 / 1)", "(6 / 2)", "(6 / 3)", "(6 / 6)", "(7 / 1)", "(7 / 7)",
        "(8 / 1)", "(8 / 2)", "(8 / 4)", "(8 / 8)", "(9 / 1)", "(9 / 3)", "(9 / 9)", "(1 x 2)",
        "(1 x 3)", "(2 x 2)", "(1 x 4)", "(1 x 5)", "(3 x 2)", "(2 x 3)", "(1 x 6)", "(1 x 7)",
        "(4 x 2)", "(2 x 4)", "(1 x 8)", "(3 x 3)", "(1 x 9)", "(5 x 2)", "(2 x 5)", "(6 x 2)",
        "(4 x 3)", "(3 x 4)", "(2 x 6)", "(7 x 2)", "(2 x 7)", "(5 x 3)", "(3 x 5)", "(8 x 2)"]
        
        
        lettersArray = ["F","P","Q","J","H","K","T","S","N","R","Y","L"]
        
        testOperationsArray = ["(1 / 1)", "(2 / 1)", "(2 / 2)", "(3 / 1)", "(3 / 3)", "(4 / 1)", "(4 / 2)", "(4 / 4)","(5 / 1)", "(5 / 5)", "(6 / 1)", "(6 / 2)", "(6 / 3)", "(6 / 6)", "(7 / 1)", "(7 / 7)","(8 / 1)", "(8 / 2)", "(8 / 4)", "(8 / 8)", "(9 / 1)", "(9 / 3)", "(9 / 9)", "(1 x 2)","(1 x 3)", "(2 x 2)", "(1 x 4)", "(1 x 5)", "(3 x 2)", "(2 x 3)", "(1 x 6)", "(1 x 7)",
                "(4 x 2)", "(2 x 4)", "(1 x 8)", "(3 x 3)", "(1 x 9)", "(5 x 2)", "(2 x 5)", "(6 x 2)","(4 x 3)", "(3 x 4)", "(2 x 6)", "(7 x 2)", "(2 x 7)", "(5 x 3)", "(3 x 5)", "(8 x 2)"]
   
        
        modifiersArray = ["1", "2", "3", "4", "5", "6", "7", "8", "9",]
        signsArray = ["+", "+", "+", "+", "+", "+", "+", "+", "+","-", "-", "-", "-", "-", "-", "-", "-", "-"]
       
        trueFalseArray = ["TRUE", "TRUE", "TRUE", "TRUE", "TRUE","FALSE", "FALSE", "FALSE", "FALSE", "FALSE"]
        setCountArray = [3,3,3,4,4,4,5,5,5,6,6,6,7,7,7]
        
        /*
        let instruction4 = "For this set of practice questions, simple math problems will appear on the screen one at a time, like this:\n\n(2  x  1) + 1 = ?\n\nAs soon as you see the math problem, you should calculate the  answer in your head, then tap the confirm button to contue. In the above problem, the answer 3 is correct.\n\nWhen you know the correct answer, you will Tap the Confirm button below .\n\nTap the Confirm button below  to continue."
        
        let instruction5 = "You will see a number displayed on the next screen, along with a box marked TRUE and a box marked FALSE.\n\nIf the number on the screen is the correct answer to the math problem, <%expressions.buttoninstruct3%> on the TRUE box with the mouse. If the number is not the correct answer, <%expressions.buttoninstruct3%> on the FALSE box.\n\nFor example, if you see the problem\n\n(2  x  2) + 1 = ?\n\nand the number on the following screen is 5 <%expressions.buttoninstruct3%> the TRUE box, because the answer is correct.\n\nIf you see the problem\n\n(2  x  2) + 1 =  ?\n\nand the number on the next screen is 6 <%expressions.buttoninstruct3%> the FALSE box, because the correct answer is 5, not 6.\n\nAfter you <%expressions.buttoninstruct3%> on one of the boxes, the computer will tell you if you made the right choice.\n\nTap the Confirm button below  to continue."
        
        let instruction6 = "It is VERY important that you get the math problems correct. It is also important that you try and solve the problem as quickly as you can.\n\nDo you have any questions?\n\nWhen you're ready, Tap the Confirm button below  to try some practice problems."
        
        let instruction7 = "Now you will practice doing both parts of the experiment at the same time.~r\n\nIn the next practice set, you will be given one of the math problems. Once you make your decision about the math problem, a letter will appear on the screen. Try and remember the letter.\n\nIn the previous section where you only solved math problems, the computer computed your average time to solve the problems.\n\nIf you take longer than your average time, the computer will automatically move you onto the next letter part, thus skipping the True or False part and will count that problem as a math error.\n\nTherefore it is VERY important to solve the problems as quickly and as accurately as possible.\n\nTap the Confirm button below  to continue."
        
        let instruction8 = "After the letter goes away, another math problem will appear, and then another letter.\n\nAt the end of each set of letters and math problems, a recall screen will appear. Use the mouse to select the letters you just saw. Try your best to get the letters in the correct order.\n\nIt is important to work QUICKLY and ACCURATELY on the math. Make sure you know the answer to the math problem before clicking to the next screen. You will not be told if your answer to the math problem is correct.\n\nAfter the recall screen, you will be given feedback about your performance regarding both the number of letters recalled and the percent correct on the math problems.\n\nDo you have any questions?\n\nTap the Confirm button below  to continue."
        
        let instruction9 = "During the feedback, you will see a number in red in the top right of the screen. This indicates your percent correct for the math problems for the entire experiment.\n\nIt is VERY important for you to keep this at least at 85%. For our purposes, we can only use data where the participant was at least 85% accurate on the math.\n\nTherefore, in order for you to be asked to come back for future experiments, you must perform at least at 85% on the math problems WHILE doing your best to recall as many letters as possible.\n\nDo you have any questions?\n\nTap the Confirm button below  to try some practice problems."
        
        let instruction10 = "That is the end of the practice.~r\n\nThe real trials will look like the practice trials you just completed. First you will get a math problem to solve, then a letter to remember.\n\nWhen you see the recall screen, select the letters in the order presented. If you forget a letter, <%expressions.buttoninstruct3%> the BLANK box to mark where it should go.\n\nSome of the sets will have more math problems and letters than others.\n\nIt is important that you do your best on both the math problems and the letter recall parts of this experiment.\n\nRemember on the math you must work as QUICKLY and ACCURATELY as possible. Also, remember to keep your math accuracy at 85% or above.\n\nDo you have any questions?\n\nIf not, Tap the Confirm button below  to begin the experiment."
        
        let instruction11 = "Thank you for your participation."
        instructionsArray = [instruction5,instruction6,instruction7,instruction8,instruction9,instruction10,instruction11]
 */
    }
}


