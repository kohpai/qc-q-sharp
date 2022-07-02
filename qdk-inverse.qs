namespace QDKInverse {
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Intrinsic;

    operation MyOperator(q: Qubit) : Unit is Adj {
        X(q);
        H(q);
    }

    @EntryPoint()
    operation Main() : Unit {
        use q = Qubit();

        MyOperator(q);
        Adjoint MyOperator(q);

        DumpMachine();
        Reset(q);
    }

}
