namespace GroverSudoku {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Arithmetic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Measurement;

    operation XOR(q1: Qubit, q2: Qubit, output: Qubit): Unit is Adj {
        CNOT(q1, output);
        CNOT(q2, output);
    }
    
    operation SudokuOracle(input: Qubit[], tmp: Qubit[], output: Qubit): Unit {
        within {
            XOR(input[0], input[1], tmp[0]);
            XOR(input[1], input[3], tmp[1]);
            XOR(input[0], input[2], tmp[2]);
            XOR(input[2], input[3], tmp[3]);
        } apply {
            Controlled X(tmp, output);
        }
    }
    
    operation ReflectZero(input: Qubit[]) : Unit {
        within {
            ApplyToEachA(X, input);
        } apply {
            Controlled Z(Most(input), Tail(input));
        }
    }

    operation ReflectInitial(InitOp: Qubit[] => Unit is Adj, input: Qubit[]) : Unit {
        within {
            Adjoint InitOp(input);
        } apply {
            ReflectZero(input);
        }
    }

    // @EntryPoint()
    operation DrawGrover(input: Qubit[], ancillas: Qubit[], pkb: Qubit) : String {

        let PrepareInitialState = CurriedOpA(ApplyToEachA)(H);
        
        PrepareInitialState(input);

        X(pkb);
        H(pkb);

        for _ in 1..2 {
            SudokuOracle(input, ancillas, pkb);           
            ReflectInitial(PrepareInitialState, input);
        }

        let result = Fold((a, b) -> a + b, "", Mapped(x -> x == Zero ? "0" | "1", MultiM(input)));
        ResetAll(input + ancillas + [pkb]);

        return result;
    }

    // @EntryPoint()
    // operation Main() : Unit {
    //     use input = Qubit[4];
    //     use ancillas = Qubit[4];
    //     use pkb = Qubit();

    //     for s in DrawMany(DrawGrover, 512, (input, ancillas, pkb)) {
    //         Message(s);
    //     }
    // }
}