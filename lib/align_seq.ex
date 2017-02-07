defmodule AlignSeq do
  @gap -2

  def align(string) do
    [sequence1, sequence2] =
    string
    |> String.split
    |> Enum.map(&String.codepoints/1)

    matrix =
    Map.new()
    |> create_scored_matrix(sequence1, sequence2)
  end

  #%{x => %{y => {score, letter_x, letter_y}}}

  defp create_scored_matrix(matrix, sequence1, sequence2) do
    create_scored_matrix(matrix, sequence1, sequence2, 0, 0)
  end

  defp create_scored_matrix(matrix, sequence1, sequence2, x, y) when x < length(sequence1) do
    cross_diag(matrix, sequence1, sequence2, x, y)
    |> create_scored_matrix(sequence1, sequence2, x+1, y)
  end

  defp create_scored_matrix(matrix, sequence1, sequence2, x, y) when x == length(sequence1) and y < length(sequence2) do
    cross_diag(matrix, sequence1, sequence2, x, y)
    |> create_scored_matrix(sequence1, sequence2, x, y+1)
  end

  defp create_scored_matrix(matrix, sequence1, sequence2, x, y) when x == length(sequence1) and y == length(sequence2) do
    cross_diag(matrix, sequence1, sequence2, x, y)
  end

  defp cross_diag(matrix, sequence1, sequence2, 0=x, 0=y) do
    Map.put(matrix, 0, %{0 => {0, "", ""}})
  end

  defp cross_diag(matrix, sequence1, sequence2, 0=x, y) do
    {score, previous_x, previous_y} = get_in(matrix, [x, y-1])
    letter_y = Enum.at(sequence2, y-1, "-")
    new_pos = %{y => {@gap + score, previous_x <> "-", previous_y <> letter_y}}
    Map.update(matrix, 0, new_pos, &Map.merge(&1, new_pos))
  end

  defp cross_diag(matrix, sequence1, sequence2, x, 0=y) do
    {score, previous_x, previous_y} = get_in(matrix, [x-1, y])
    letter_x = Enum.at(sequence1, x-1, "-")
    new_pos = %{y => {@gap + score, previous_x <> letter_x, previous_y <> "-"}}
    Map.update(matrix, x, new_pos, &(Map.merge(&1, new_pos)))
    |> cross_diag(sequence1, sequence2, x-1, y+1)
  end

  defp cross_diag(matrix, sequence1, sequence2, x, y) do
    up = get_in(matrix, [x, y-1])
    diag = get_in(matrix, [x-1, y-1])
    left = get_in(matrix, [x-1, y])
    # IO.inspect([up, diag, left, x, y])
    # IO.inspect(matrix)
    {score, previous_x, previous_y}=max = Enum.max_by([up, diag, left], fn {score, _, _} -> score end)
    letter_x = Enum.at(sequence1, x-1)
    letter_y = Enum.at(sequence2, y-1)
    new_pos = cond do
      max == up ->
        %{y => {@gap + score, previous_x <> letter_x, previous_y <> "-"}}
      max == diag ->
        %{y => {score + match(letter_x, letter_y), previous_x <> letter_x, previous_y <> letter_y}}
      max == left ->
        %{y => {@gap + score, previous_x <> "-", previous_y <> letter_y}}
    end
    |> IO.inspect
    Map.update(matrix, x, new_pos, &Map.merge(&1, new_pos))
    |> cross_diag(sequence1, sequence2, x-1, y+1)
  end

  defp match(match, match), do: 4
  defp match(_mis1, _mis2), do: -2
end