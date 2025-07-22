import java.util.Random;
import java.util.Scanner;

public class GuessingGame {
    public static void main (String [] args){
        // Initialize objects and Generate random number 
        Scanner scanner = new Scanner(System.in);
        Random random = new Random();

        int randomNumber = random.nextInt(100) + 1;
        int userInput;
        int attempts = 0;

        System.out.println("");
        System.out.println("Welcome to the Random Number Guessing Game!");
        System.out.println("Try to correctly guess a number between 1 and 100");

        do {
            System.out.println("");
            System.out.print("Enter your guess: ");
            userInput = scanner.nextInt();
            attempts++;

            if (userInput < randomNumber) {
                System.out.println("");
                System.out.println("Guess is too low! Try again."); 
            } else if (userInput > randomNumber) {
                System.out.println("");
                System.out.println("Guess is too high! Try again.");
            } else {
                System.out.println("");
                System.out.println("Congratulations! You guessed correctly. The correct number is " + userInput + ".");
            } 
            
        } while (userInput != randomNumber);  
          scanner.close();
    }
}