# Pattern matching homework
# by Alejandro fernandez del valle Herrera

defmodule Hw.Excersise do

  # Exercise 1
  @doc """
  insert takes lst, n
  Inserts n in order
  """
  def insert(lst, n), do: loop_insertion(lst, n, [])
  defp loop_insertion([], n, result) do
    if n in result do 
      Enum.reverse(result) 
    else
      Enum.reverse([n | result]) 
    end
  end
  defp loop_insertion([head | tail], n, result) do
      if head < n do 
        loop_insertion(tail, n, [head | result]) 
      else
        if n in result do
          loop_insertion(tail, n, [head | result]) 
        else
          loop_insertion(tail, n, [head | [n | result]])
        end
      end
  end

  # Excersise 2
  @doc """
  insertion_sort takes lst.
  Sorts lst in order from small to big
  Has to use insert using insert() function
  """
  def insertion_sort(lst), do: loop_insertionSort(lst, [])
  defp loop_insertionSort([], build), do: build
  defp loop_insertionSort([head | tail], build), 
    do: loop_insertionSort(tail, insert(build, head))

  # Excersise 3
  @doc """
  rotate_left takes n and lst
  moves lst left by n ammount
  """
  def rotate_left(lst, 0), do: lst # if no flip, do nothing
  def rotate_left(lst, n) do
    if n < 0 do
      # list gets reversed to ensure mantaining order and using same algorythm
      loop_leftRotation(n * -1, Enum.reverse(lst), true) 
    else
      # flag set to false to not get flipped
      loop_leftRotation(n, lst, false)
    end
  end

  # if list is empty, return empty list
  defp loop_leftRotation(n, [], reverse), do: []

  # end of loop with n
  defp loop_leftRotation(0, lst, reverse) do
    # Reverse if needed
    if reverse do
      Enum.reverse(lst)
    else
      lst
    end
  end

  # main loop
  defp loop_leftRotation(n, [head | tail], reverse), do:
    loop_leftRotation(n - 1, tail ++ [head], reverse)


  # Excersise 10
  @doc """
  encode takes lst
  returns the ammount of repetitions in lst [in format ((reppetitions item) (reppetitions item))]
  """
  def encode([]), do: [] # empty list do nothing 
  def encode(list), do: loop_encode(list, nil, 0, []) # nil es null

  # exit loop
  defp loop_encode([], prev, n, build), do: Enum.reverse([{n, prev} | build]) 
  # main loop
  defp loop_encode([head | tail], prev, n, build) do
    # if has not changed, add one to n
    if head == prev do
      loop_encode(tail, prev, n + 1, build)
    else
      # test for null value 
      if prev == nil do
        loop_encode(tail, head, 1, build)
      else
        # add and go to next in list
        loop_encode(tail, head, 1, [{n, prev} | build])
      end
    end
  end
end
