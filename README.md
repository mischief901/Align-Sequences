# AlignSeq

Run the align sequence program by escript align "File_Name" [--options]

The options for align_seq are: --match INTEGER --mismatch INTEGER --gap INTEGER

All three options Must be specified to take affect. The program defaults to scores
of Match: 4, Mismatch: -2, Gap: -2

The program runs in less than a tenth of a second for aligntest.input2 (~75 basepairs),
so none of the speed modifications outlined in Setubal and Meidanis were considered 
necessary. The program could be modified to split a sequence into smaller chunks
and run concurrently.
