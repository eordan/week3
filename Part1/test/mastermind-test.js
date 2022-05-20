//[assignment] write your own unit test to show that your Mastermind variation circuit is working as expected

const chai = require("chai");
const path = require("path");

const wasm_tester = require("circom_tester").wasm;

const F1Field = require("ffjavascript").F1Field;
const Scalar = require("ffjavascript").Scalar;
exports.p = Scalar.fromString("21888242871839275222246405745257275088548364400416034343698204186575808495617");
const Fr = new F1Field(exports.p);

const assert = chai.assert;

describe("MastermindVariation test", function () {
    this.timeout(100000);

    it("Check the witness is valid", async () => {
        const circuit = await wasm_tester("contracts/circuits/MastermindVariation.circom");
        await circuit.loadConstraints();

        const INPUT = {
            "guess1": "4",
            "guess2": "2",
            "guess3": "6",
            "numFermi": "3",
            "numPico": "0",
            "solthHash": "15496971953174846750288032663195265916685559067294034719362628384263034942602",
            "soltn1": "4",
            "soltn2": "2",
            "soltn3": "6",
            "salt": "6555585765876587"
        }

        const witness = await circuit.calculateWitness(INPUT, true);

        await circuit.checkConstraints(witness);
    });

    it("Compile the circuit", async () => {
        const circuit = await wasm_tester("contracts/circuits/MastermindVariation.circom");
        await circuit.loadConstraints();

        const INPUT = {
            "guess1": "4",
            "guess2": "2",
            "guess3": "6",
            "numFermi": "3",
            "numPico": "0",
            "solthHash": "15496971953174846750288032663195265916685559067294034719362628384263034942602",
            "soltn1": "4",
            "soltn2": "2",
            "soltn3": "6",
            "salt": "6555585765876587"
        }

        const witness = await circuit.calculateWitness(INPUT, true);

        assert(Fr.eq(Fr.e(witness[0]),Fr.e(1)));
        assert(Fr.eq(Fr.e(witness[1]),Fr.e("15496971953174846750288032663195265916685559067294034719362628384263034942602")));
    });
});