# Quizware app

## Main Screen
* Will show available quizes.
  * User should be able to delete a quiz. Deleting a quiz will delete all quiz history.
    * Use swipe right to delete a quiz. Also, have an edit button at the top
      where user can select the quizes they want to delete by selecting them and tapping
      the trash button (see the mail app on the iPhone for an example) 
  * User should be able to edit a quiz (e.g. add/change/delete questions)
* Will have a + button in upper right corner for adding a new quiz

## Quiz Details (expanded view)
* When user taps a quiz on the main screen, the quiz will expand and show details about the quiz as follows:
  * the number of questions in the quiz
  * the number of times the quiz was taken
  * the number of correct and incorrect questions
  * the overall success percentage (num correct / total questions across all quizes)
  * a button the user can press to view the detailed quiz history (this will be another screen)
  * a buton the user can press to take the quiz

## Take Quiz Screen
* When the user presses the button to take the quiz, this screen will be shown.
* The app will cycle through each question and allow the user to enter their answers.
* The user will be able to go backwards and forwards through the questions and change their answers.
* Once the user answers the last question, they'll be taken to another screen where they can
  submit the quiz.
* Once the user submits the quiz, the app will grade it and store the results. 
