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
    IO.puts("#{tl}: INICIAR CORCHETE, siguientes: #{stack}")
    modoValor(tl, Enum.join([build, "<span class=\"parentesis\">[</span><br><div class=\"indent\">"]), ["[" | stack])
  end

  def modoCorcheteF([], build, _), do: build
  def modoCorcheteF([hd | _], build, [next | ""]) do
    IO.puts("#{hd}: TERMINAR CORCHETE #{next}")
    Enum.join([build, "</div><class=\"parentesis\">]</span><br>"])
  end
  def modoCorcheteF([hd | tl], build, [this | stack]) do
    [next | _] = stack
    IO.puts("#{hd}: TERMINAR CORCHETE #{this}, #{next}, siguientes: #{stack}")
    case next do
      "[" -> modoIterarCorchete(tl, Enum.join([build, "</div><class=\"parentesis\">]</span><br>"]), stack)
      "{" -> modoIterarLlave(tl, Enum.join([build, "</div><class=\"parentesis\">]</span><br>"]), stack)
    end
  end

  def modoIterarCorchete(_, build, []), do: build
  def modoIterarCorchete([], build, _), do: build
  def modoIterarCorchete([hd | tl], build, stack) do
    IO.puts("#{hd}: ITERAR CORCHETE")
    case hd do
      "," -> modoValor(tl, Enum.join([build, hd, "<br>"]), stack)
      "]" -> modoCorcheteF([hd | tl], build, stack)
      _ -> modoIterarCorchete(tl, build, stack)
    end
  end

  def modoCientrifico([hd | tl], build, stack) do
    IO.puts("#{hd}: MODO CIENTIFICO")
    cond do
      Regex.match?(~r/^\d$/, hd) -> modoCientrifico(tl, Enum.join([build, hd]), stack)
      hd == "+" or hd == "-" -> modoCientrifico(tl, Enum.join([build, hd]), stack)
      true -> modoIterarCorchete([hd | tl], Enum.join([build, "</span>"]), stack)
    end
  end

  def modoFloat([hd | tl], build, stack) do
    IO.puts("#{hd}: MODO FLOAT")
    cond do
      Regex.match?(~r/^\d$/, hd) -> modoFloat(tl, Enum.join([build, hd]), stack)
      hd == "E" -> modoCientrifico(tl, Enum.join([build, hd]), stack)
      true -> modoIterarCorchete([hd | tl], Enum.join([build, "</span>"]), stack)
    end
  end

  def modoInt([hd | tl], build, stack) do
    IO.puts("#{hd}: MODO INT")
    cond do
      Regex.match?(~r/^\d$/, hd) -> modoInt(tl, Enum.join([build, hd]), stack)
      hd == "." -> modoFloat(tl, Enum.join([build, hd]), stack)
      true -> modoIterarCorchete([hd | tl], Enum.join([build, "</span>"]), stack)
    end
  end

  def modoEspecial([hd | tl], build, stack) do
    IO.puts("#{hd}: MODO NULL,TRUE,FALSE")
    cond do
      Regex.match?(~r/[truefalsn]/, hd) -> modoEspecial(tl, Enum.join([build, hd]), stack)
      true -> modoIterarCorchete([hd | tl], Enum.join([build, "</span>"]), stack)
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
    IO.puts("#{hd}: MODO VALOR")
    cond do
      hd == "[" -> modoCorchete(tl, build, stack)
      hd == "{" -> modoLlave(tl, build, stack)
      hd == "\""-> modoString(tl, Enum.join([build, "<span class=\"string\">\""]), stack)
      Regex.match?(~r/^\d$/, hd) -> modoInt([hd | tl], Enum.join([build, "<span class=\"int\">"]), stack)
      Regex.match?(~r/[truefalsn]/, hd) -> modoEspecial([hd | tl], Enum.join([build, "<span class=\"esp\">"]), stack)
      hd == "]" -> modoCorcheteF([hd | tl], build, stack)
      true -> modoValor(tl, build, stack)
    end
  end

  ### ------------------------------------------------------------------------------------------------------
  ## Key search
  def modoLlave(tl, build, stack) do
    IO.puts("#{tl}: INICIAR LLAVE, siguientes: #{stack}")
    modoTagLlave(tl, Enum.join([build, "<span class=\"parentesis\">{</span><br><div class=\"indent\"><span class=\"key\">"]), ["{" | stack])
  end

  def modoLlaveF([], build, _), do: build
  def modoLlaveF([hd | _], build, [next | ""]) do
    IO.puts("#{hd}: TERMINAR LLAVE #{next}")
    Enum.join([build, "</div><class=\"parentesis\">}</span><br>"])
  end
  def modoLlaveF([hd | tl], build, [this | stack]) do
    [next | _] = stack
    IO.puts("#{hd}: TERMINAR LLAVE #{this}, #{next}, siguientes: #{stack}")
    case next do
      "[" -> modoIterarCorchete(tl, Enum.join([build, "</div><class=\"parentesis\">}</span><br>"]), stack)
      "{" -> modoIterarLlave(tl, Enum.join([build, "</div><class=\"parentesis\">}</span><br>"]), stack)
    end
  end

  def modoIterarLlave(_, build, []), do: build
  def modoIterarLlave([], build, _), do: build
  def modoIterarLlave([hd | tl], build, stack) do
    IO.puts("#{hd}: ITERAR LLAVE")
    case hd do
      "," -> modoTagLlave(tl, Enum.join([build, hd, "<br><span class=\"key\">"]), stack)
      "}" -> modoLlaveF([hd | tl], build, stack)
      _ -> modoIterarLlave(tl, build, stack)
    end
  end

  def modoTagLlave([hd | tl], build, stack) do
    IO.puts("#{hd}: ITERAR LLAVE STRING")
    case hd do
      ":" -> modoValorLlave(tl, Enum.join([build, ":</span> "]), stack)
      "}" -> modoLlaveF(tl, Enum.join([build, "</span>"]), stack)
      _ -> modoTagLlave(tl, Enum.join([build, hd]), stack)
    end
  end

  def modoCientrificoLlave([hd | tl], build, stack) do
    IO.puts("#{hd}: MODO CIENTIFICO")
    cond do
      Regex.match?(~r/^\d$/, hd) -> modoCientrificoLlave(tl, Enum.join([build, hd]), stack)
      hd == "+" or hd == "-" -> modoCientrificoLlave(tl, Enum.join([build, hd]), stack)
      true -> modoIterarLlave([hd | tl], Enum.join([build, "</span>"]), stack)
    end
  end

  def modoFloatLlave([hd | tl], build, stack) do
    IO.puts("#{hd}: MODO FLOAT")
    cond do
      Regex.match?(~r/^\d$/, hd) -> modoFloatLlave(tl, Enum.join([build, hd]), stack)
      hd == "E" -> modoCientrificoLlave(tl, Enum.join([build, hd]), stack)
      true -> modoIterarLlave([hd | tl], Enum.join([build, "</span>"]), stack)
    end
  end

  def modoIntLlave([hd | tl], build, stack) do
    IO.puts("#{hd}: MODO INT")
    cond do
      Regex.match?(~r/^\d$/, hd) -> modoIntLlave(tl, Enum.join([build, hd]), stack)
      hd == "." -> modoFloatLlave(tl, Enum.join([build, hd]), stack)
      true -> modoIterarLlave([hd | tl], Enum.join([build, "</span>"]), stack)
    end
  end

  def modoEspecialLlave([hd | tl], build, stack) do
    IO.puts("#{hd}: MODO NULL,TRUE,FALSE")
    cond do
      Regex.match?(~r/[truefalsn]/, hd) -> modoEspecialLlave(tl, Enum.join([build, hd]), stack)
      true -> modoIterarLlave([hd | tl], Enum.join([build, "</span>"]), stack)
    end
  end

  def modoStringLlave([hd | tl], build, stack) do
    IO.puts("#{hd}: MODO STRING")
    case hd do
      "\""-> modoIterarLlave(tl, Enum.join([build, hd, "</span>"]), stack)
      _ -> modoStringLlave(tl, Enum.join([build, hd]), stack)
    end
  end

  def modoValorLlave([], build, _), do: build
  def modoValorLlave([hd | tl], build, stack) do
    IO.puts("#{hd}: MODO VALOR")
    cond do
      hd == "[" -> modoCorchete(tl, build, stack)
      hd == "{" -> modoLlave(tl, build, stack)
      hd == "\""-> modoStringLlave(tl, Enum.join([build, "<span class=\"string\">\""]), stack)
      Regex.match?(~r/^\d$/, hd) -> modoIntLlave([hd | tl], Enum.join([build, "<span class=\"int\">"]), stack)
      Regex.match?(~r/[truefalsn]/, hd) -> modoEspecialLlave([hd | tl], Enum.join([build, "<span class=\"esp\">"]), stack)
      hd == "}" -> modoLlaveF([hd | tl], build, stack)
      true -> modoValorLlave(tl, build, stack)
    end
  end
end

ProjFinal.read("inputTests/test3.json", "output.html")
