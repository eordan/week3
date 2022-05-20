pragma circom 2.0.0;

// [assignment] implement a variation of mastermind from https://en.wikipedia.org/wiki/Mastermind_(board_game)#Variation as a circuit

// The variation that I chose to implement is Bagels
// Implementation is based on the code of hitandblow.circom provided with the assignment

include "../../node_modules/circomlib/circuits/comparators.circom";
include "../../node_modules/circomlib/circuits/bitify.circom";
include "../../node_modules/circomlib/circuits/poseidon.circom";

template MastermindVariation() {

    // Public inputs: three guess numbers, numbers of fermi and pico and a solution hash
    signal input guess1;
    signal input guess2;
    signal input guess3;
    signal input numFermi;
    signal input numPico;
    signal input solthHash;

    // Private inputs: three guesses and 
    signal input soltn1;
    signal input soltn2;
    signal input soltn3;
    signal input salt;

    // Output
    signal output soltnHashOut;

    // Two arrays: one for guesses and one for solutions
    var guess[3] = [guess1, guess2, guess3];
    var soltn[3] = [soltn1, soltn2, soltn3];

    // Variables for loops
    var i = 0;
    var j = 0;
    var equalIndex = 0;

    // Three component arrays
    component lessThan[6]; // Three for guesses and three for solutions
    component equalGuess[3]; // Three possible combinations of digits
    component equalSoltn[3]; // Three possible combinations of digits

    // Assert that solution and guess digits are all less than 10
    for (i=0; i<3; i++) {
        lessThan[i] = LessThan(3);
        lessThan[i+3] = LessThan(3);

        lessThan[i].in[0] <== guess[i];
        lessThan[i].in[1] <== 10;

        lessThan[i+3].in[0] <== soltn[i];
        lessThan[i+3].in[1] <== 10;

        assert(lessThan[i].out == 1);
        assert(lessThan[i+3].out == 1);
        
        // Assert that the solution and guess digits are unique, no duplication
        for (j=i+1; j<3; j++) {
            equalGuess[equalIndex] = IsEqual();
            equalSoltn[equalIndex] = IsEqual();

            equalGuess[equalIndex].in[0] <== guess[i];
            equalGuess[equalIndex].in[1] <== guess[j];

            equalSoltn[equalIndex].in[0] <== soltn[i];
            equalSoltn[equalIndex].in[1] <== soltn[j];

            equalGuess[equalIndex].out === 0;
            equalSoltn[equalIndex].out === 0;

            equalIndex++;
        }
    }

    // Count fermi & pico
    var fermi = 0;
    var pico = 0;

    component equalFermiPico[9];

    for (i=0; i<3; i++) {
        for (j=0; j<3; j++) {
            equalFermiPico[3*i+j] = IsEqual();

            equalFermiPico[3*i+j].in[0] <== guess[i];
            equalFermiPico[3*i+j].in[1] <== soltn[j];

            pico += equalFermiPico[3*i+j].out;

            if (i == j) {
                fermi += equalFermiPico[3*i+j].out;
                pico -= equalFermiPico[3*i+j].out;
            }
        }
    }

    // Create a constraint around the number of fermi
    component equalFermi = IsEqual();

    equalFermi.in[0] <== numFermi;
    equalFermi.in[1] <== fermi;

    equalFermi.out === 1;
    
    // Create a constraint around the number of pico
    component equalPico = IsEqual();

    equalPico.in[0] <== numPico;
    equalPico.in[1] <== pico;

    equalPico.out === 1;

    // Calculate hash for solution
    component poseidonSoltn = Poseidon(4);
    poseidonSoltn.inputs[0] <== salt;
    poseidonSoltn.inputs[1] <== soltn1;
    poseidonSoltn.inputs[2] <== soltn2;
    poseidonSoltn.inputs[3] <== soltn3;

    soltnHashOut <== poseidonSoltn.out;
    solthHash === soltnHashOut;
}

component main {public [guess1, guess2, guess3, numFermi, numPico, solthHash]} = MastermindVariation();