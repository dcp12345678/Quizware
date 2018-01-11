# Testware app

## Main Screen
* Will show available tests.
  * User should be able to delete a test. Deleting a test will delete all test history.
    * Use swipe right to delete a test. Also, have an edit button at the top
      where user can select the tests they want to delete by selecting them and tapping
      the trash button (see the mail app on the iPhone for an example) 
  * User should be able to edit a test (e.g. add/change/delete questions)
* Will have a + button in upper right corner for adding a new test

## Test Details (expanded view)
* When user taps a test on the main screen, the test will expand and show details about the test as follows:
  * the number of questions in the test
  * the number of times the test was taken
  * the number of correct and incorrect questions
  * the overall success percentage (num correct / total questions across all tests)
  * a button the user can press to view the detailed test history (this will be another screen)
  * a button the user can press to take the test

## Take Test Screen
* When the user presses the button to take the test, this screen will be shown.
* The app will cycle through each question and allow the user to enter their answers.
* The user will be able to go backwards and forwards through the questions and change their answers.
* Once the user answers the last question, they'll be taken to another screen where they can
  submit the test.
* Once the user submits the test, the app will grade it and store the results. 
