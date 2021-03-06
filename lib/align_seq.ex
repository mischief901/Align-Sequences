defmodule AlignSeq do
  
  def main(args) do # parses CLI and sets options if applicable
    {options, file_path, _} = OptionParser.parse(args, switches: 
            [match: :integer, mismatch: :integer, gap: :integer])

    scoring = cond do
      length(options) == 3 ->
        IO.puts("Scoring set to Match: #{options[:match]}, Mismatch: #{options[:mismatch]}, Gap: #{options[:gap]}")
        {options[:match], options[:mismatch], options[:gap]}
      true ->
        IO.puts("Scoring defaults to Match: 4, Mismatch: -2, Gap: -2
Change the scoring by setting all three parameters such as: --match 4 --mismatch -2 --gap -2\n\n")
        {4, -2, -2}
    end

    alignment = File.read!(file_path)
    |> String.split("\n")
    |> remove_descriptions("")
    |> align(scoring)
    IO.puts(alignment)
    File.write("my.output", alignment)
    IO.puts("Aligned sequences are also saved in the my.output file in the same directory.\n
The my.output file will be overwritten next time this program is run.")
  end

  # removes the FASTA-formatted descriptions, separating sequences by newline.
  defp remove_descriptions([], acc), do: acc
  defp remove_descriptions([head | rest], ""=acc) do
    if String.first(head) == ">" do
      remove_descriptions(rest, acc)
    else
      remove_descriptions(rest, acc <> head)
    end
  end
  defp remove_descriptions([head | rest], acc) do
    if String.first(head) == ">" do
      remove_descriptions(rest, acc <> "\n")
    else
      remove_descriptions(rest, acc <> head)
    end
  end

  def align(string, {_match_score, _mismatch_score, _gap_score}=scores) do

    #splits sequence into a list of lists of each sequence letter.
    [sequence1, sequence2] =
    string
    |> String.split
    |> Enum.map(&String.codepoints/1)

    Map.new()
    |> create_scored_matrix(sequence1, sequence2, scores)
    |> get_in([length(sequence1), length(sequence2)])
    |> format
  end

  # format places each sequence into a format string separated by a newline
  defp format({_score, aligned_seq1, aligned_seq2}) do
    """
    #{aligned_seq1}
    #{aligned_seq2}
    """
  end

  # %{x => %{y => {score, letter_x, letter_y}}}
  # Creates a nested map to simulate an array. Maps are constant time access.
  # The first map stores by the x-axis for the length of sequence 1 and the 
  # nested map stores by the y-axis for the length of sequence 2. The nested map
  # stores a tuple with the score of the array at that point and the sequence up
  # to that point in the array.
  defp create_scored_matrix(matrix, sequence1, sequence2, scores) do
    create_scored_matrix(matrix, sequence1, sequence2, 0, 0, scores)
  end

  defp create_scored_matrix(matrix, sequence1, sequence2, x, y, scores) when 
                                                        x < length(sequence1) do
    cross_diag(matrix, sequence1, sequence2, x, y, scores)
    |> create_scored_matrix(sequence1, sequence2, x+1, y, scores)
  end

  defp create_scored_matrix(matrix, sequence1, sequence2, x, y, scores) when 
                            x == length(sequence1) and y < length(sequence2) do
    cross_diag(matrix, sequence1, sequence2, x, y, scores)
    |> create_scored_matrix(sequence1, sequence2, x, y+1, scores)
  end

  defp create_scored_matrix(matrix, sequence1, sequence2, x, y, scores) when 
                            x == length(sequence1) and y == length(sequence2) do
    cross_diag(matrix, sequence1, sequence2, x, y, scores)
  end


  # The cross_diag function scores the array by crossing the array in the {i,0} 
  # to {0,j} manner. This allows for the array to access the scores of the previous
  # locations in the array.
  defp cross_diag(matrix, _sequence1, _sequence2, 0=x, 0=y, _scores) do
    Map.put(matrix, x, %{y => {0, "", ""}})
  end

  defp cross_diag(matrix, _sequence1, sequence2, 0=x, y, {_match, _mismatch, gap}) do
    {score, previous_x, previous_y} = get_in(matrix, [x, y-1])
    letter_y = Enum.at(sequence2, y-1, "-")
    new_pos = %{y => {gap + score, previous_x <> "-", previous_y <> letter_y}}
    Map.update(matrix, x, new_pos, &Map.merge(&1, new_pos))
  end

  defp cross_diag(matrix, sequence1, sequence2, x, 0=y, {_match, _mismatch, gap}=scores) do
    {score, previous_x, previous_y} = get_in(matrix, [x-1, y])
    letter_x = Enum.at(sequence1, x-1, "-")
    new_pos = %{y => {gap + score, previous_x <> letter_x, previous_y <> "-"}}
    Map.update(matrix, x, new_pos, &(Map.merge(&1, new_pos)))
    |> cross_diag(sequence1, sequence2, x-1, y+1, scores)
  end

  defp cross_diag(matrix, sequence1, sequence2, x, y, {_match, _mismatch, gap}=scores) when 
                                                      y <= length(sequence2) do
    {score_diag, _diagx, _diagy} = diag = get_in(matrix, [x-1, y-1])
    {score_up, _upx, _upy} = up = get_in(matrix, [x, y-1])
    {score_left, _leftx, _lefty} = left = get_in(matrix, [x-1, y])
    
    letter_x = Enum.at(sequence1, x-1, "-")
    letter_y = Enum.at(sequence2, y-1, "-")

    {score, previous_x, previous_y} = max = 
    if score_diag + match(letter_x, letter_y, scores) >= score_up + gap and 
      score_diag + match(letter_x, letter_y, scores) >= score_left + gap do
      diag
    else
      if score_up > score_left do
        up
      else
        left
      end
    end

    new_pos = cond do
      max == diag ->
        %{y => {score + match(letter_x, letter_y, scores), previous_x <> letter_x, 
                                                        previous_y <> letter_y}}
      max == up ->
        %{y => {gap + score, previous_x <> "-", previous_y <> letter_y}}
      max == left ->
        %{y => {gap + score, previous_x <> letter_x, previous_y <> "-"}}
    end

    Map.update(matrix, x, new_pos, &Map.merge(&1, new_pos))
    |> cross_diag(sequence1, sequence2, x-1, y+1, scores)
  end

  defp cross_diag(matrix, _sequence1, _sequence2, _x, _y, _scores) do
    matrix
  end

  # returns the match score if the letters match and the mismatch score if the
  # letters don't match.
  defp match(match, match, {match_score, _mismatch, _gap}), do: match_score
  defp match(_mis1, _mis2, {_match, mismatch_score, _gap}), do: mismatch_score
end