ExUnit.start
ExUnit.configure exclude: :pending, trace: true

defmodule AlignSeqTest do
  use ExUnit.Case
  doctest AlignSeq

  @scoring {4, -2, -2}

  @tag :pending
  test "one length string" do
    input = 
    """
    A
    A
    """
    output = 
    """
    A
    A
    """
    assert AlignSeq.align(input, @scoring) == output
  end

  @tag :pending
  test "test medium string" do
    output =
    """
    TC-CAAATA
    TCGCAAATA
    """

    input = 
    """
    TCCAAATA
    TCGCAAATA
    """
    assert AlignSeq.align(input, @scoring) == output
  end

  @tag :pending
  test "test input 1" do
    output =
    """
    TC-CAAATAGAC
    TCGCAAATATAC
    """

    input = 
    """
    TCCAAATAGAC
    TCGCAAATATAC
    """
    assert AlignSeq.align(input, @scoring) == output
  end

  @tag :pending
  test "align short sequences with one mismatch" do
    input = 
    """
    ACTG
    ACGG
    """
    assert AlignSeq.align(input, @scoring) == input
  end

  #@tag :pending
  test "align short sequences with one gap" do
    input = 
    """
    ACTG
    ACG
    """
    output =
    """
    ACTG
    AC-G
    """
    assert AlignSeq.align(input, @scoring) == output
  end

  @tag :pending
  test "align short equal strings" do
    input =
    """
    ACTG
    ACTG
    """
    assert AlignSeq.align(input, @scoring) == input
  end

  @tag :pending
  @tag timeout: 1000000
  test "test input 2" do
    input =
    """
    AGGTCAAATACTGAGGGAATAGTGGAATGAAGGTTCATTTTTCATTCTCACCTAAACTAATGAAACCCTG
    AGTGCCAGTTAAGACTATAGTGGAATGAAGGTTAATTCATTCTCACAAACTAATACCCTGCTT
    """
    output = 
    """
    AG-GTCAAATACTGAGGGA--ATAGTGGAATGAAGGTTCATTTTTCATTCTCACCTAAACTAATGAAACCCTG---
    AGTG-CCAGT--T-A-AGACTATAGTGGAATGAAGGTT-A--ATTCATTCTCA-C-AAACTAAT---ACCCTGCTT
    """

    assert AlignSeq.align(input, @scoring) == output
  end

  input = 
  """
  

  """
end
