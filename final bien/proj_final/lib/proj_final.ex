defmodule ProjFinal do
  @moduledoc """
  Documentation for `ProjFinal`.

  This project aims to make a JSON parser. It holds the ability of running various files in parallel, to improve time.
  """

  @doc """
  read a file.

  ## Examples

      iex> ProjFinal.read("input.json", "output.html")
      reads the file and writes the file as given name

  """
  def read(in_filename, out_filename) do
    IO.puts("Working...")
    # data = File.stream!(in_filename) #Lista de renglones

    #Using pipe operator to link the calls
    text = stateStart(String.split(File.read!(in_filename), ""))

    # data2 = File.stream!("base.html") #Lista de renglones

    #Using pipe operator to link the calls
    text2 = File.read!("elements/base.html")

    IO.puts("Done!")

    File.write(out_filename, "#{text2}#{text}\n</p>\n</body>\n</html>")
  end

  def stateStart([hd | tl]) do
    IO.puts(hd)
    case hd do
      "[" -> modoCorchete(tl, "", "") # [
      "{" -> modoLlave(tl, "", "") # {
      _ -> stateStart(tl)
    end
  end

  def modoCorchete(tl, build, stack) do
    modoValor(tl, Enum.join([build, "<span class=\"parentesis\">[</span><br><div class=\"indent\">"]), ["[" | stack])
  end

  def modoCorcheteF([], build, _), do: build

  def modoCorcheteF([_ | tl], build, [next | stack]) do
    case next do
      "[" -> modoValor(tl, Enum.join([build, "</div><class=\"parentesis\">]</span><br>"]), stack)
      "{" -> modoValor(tl, Enum.join([build, "</div><class=\"parentesis\">]</span><br>"]), stack) # TODO cambiar por modo llave
      _ -> modoCorcheteF(tl, build, [next | stack])
    end
  end

  def modoIterarCorchete([hd | tl], build, stack) do
    IO.puts("#{hd}: ITERAR CORCHETE")
    case hd do
      "," -> modoValor(tl, Enum.join([build, hd, "<br>"]), stack)
      "]" -> modoCorcheteF([hd | tl], build, stack)
      _ -> modoIterarCorchete(tl, build, stack)
    end
  end

  def modoString([hd | tl], build, stack) do
    IO.puts("#{hd}: MODO STRING")
    case hd do
      "\""-> modoIterarCorchete(tl, Enum.join([build, hd, "</span>"]), stack)
      _ -> modoString(tl, Enum.join([build, hd]), stack)
    end
  end

  def modoValor([], build, _), do: build
  def modoValor([hd | tl], build, stack) do
    IO.puts(hd)
    case hd do
      "[" -> modoCorchete(tl, build, stack)
      "{" -> modoLlave(tl, build, stack)
      "\""-> modoString(tl, Enum.join([build, "<span class=\"string\">\""]), stack)
      "]" -> modoCorcheteF(tl, build, stack)
      _ -> modoValor(tl, build, stack)
    end
  end

  def modoLlave([_ | tl], build, stack) do
    modoValor(tl, Enum.join([build, "<span class=\"parentesis\">{</span><br>"]), stack)
  end
end

ProjFinal.read("inputTests/test1.json", "output.html")
