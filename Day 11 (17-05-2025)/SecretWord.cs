using System;

namespace Secret
{
    internal class Secret_Word
    {
        public static void Run()
        {
            Console.Write("Please Enter the secret word: ");
            string secretWord = Program.GetStringInput().Trim();

            int attempts = 0;
            const int maxAttempts = 3;

            while (attempts < maxAttempts)
            {
                Console.Write("Please Enter your guess: ");
                string guessWord = Program.GetStringInput().Trim();

                if (secretWord.Length != guessWord.Length)
                {
                    Console.WriteLine("Guess word length does not match the secret word. Try again.");
                    continue;
                }

                int cows = 0, bulls = 0;

                for (int i = 0; i < secretWord.Length; i++)
                {
                    if (secretWord[i] == guessWord[i])
                    {
                        bulls++;
                    }
                    else if (secretWord.Contains(guessWord[i]))
                    {
                        cows++;
                    }
                }

                if (bulls == secretWord.Length)
                {
                    Console.WriteLine("Congratulations! You guessed the word exactly.");
                    return;
                }
                else
                {
                    Console.WriteLine($"Cows: {cows}, Bulls: {bulls}");
                    attempts++;
                }
            }

            Console.WriteLine("Sorry, you've used all your attempts. Game over.");
        }
    }
}
