module ring_oscillator (
    input  logic en,
    output logic out
);

    logic nand_out;
    logic not1_out;

    
    nand #5 N0 (nand_out, out, en); // NAND gate with 5 time units delay
    not #5 N1 (not1_out, nand_out); // NOT1 gate with 5 time units delay
    not #5 N2 (out, not1_out);      // NOT2 gate with 5 time units delay

endmodule