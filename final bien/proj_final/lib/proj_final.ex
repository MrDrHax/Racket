defmodule ProjFinal do
  @moduledoc """
  Documentation for `ProjFinal`.

  This project aims to make a JSON parser. It holds the ability of running various files in parallel, to improve time.
  """

  @doc """
  read a lot of files and parse it to formated HTML.
  Uses paralellism to save time

  ## Examples

      iex> ProjFinal.parseFiles(["/path/to/file/one.json", "relative/path/toJson.json"], "/path/to/output/folder")
      reads the files and writes the files as name in the folder given
  """
  def parseFiles(paths, outFolder) do
    time = Time.utc_now()

    # makes the necessary directories
    File.mkdir_p!(Path.dirname("#{outFolder}/elements/"))

    # coppy the style.css for required HTML stuff
    File.copy("lib/elements/style.css", "#{outFolder}/elements/style.css")

    # summon all threads
    for file <- paths do
      IO.puts(Enum.join([file, Enum.join([outFolder, "/", Regex.replace(~r/.+\/(.+)\.json/, file, "\\1.html")])], " | "))
      spawn(ProjFinal, :read, [file, Enum.join([outFolder, "/", Regex.replace(~r/.+\/(.+)\.json/, file, "\\1.html")])])
    end

    # print execution times
    executionTime = Time.diff(Time.utc_now(), time, :millisecond)
    IO.puts("Finished starting threads in #{executionTime}ms")
  end

  @doc """
  read a file.

  ## Examples

      iex> ProjFinal.read("input.json", "output.html")
      reads the file and writes the file as given name

  """
  def read(in_filename, out_filename) do
    IO.puts("Working on file #{in_filename}...")

    time = Time.utc_now()

    # read necesarry files and run parser
    text = stateStart(String.split(File.read!(in_filename), ""))

    # data2 = File.stream!("base.html") #Lista de renglones

    # read necesarry files
    text2 = File.read!("lib/elements/base.html")

    File.write(out_filename, "#{text2}#{text}\n</p>\n</body>\n</html>")

    executionTime = Time.diff(Time.utc_now(), time, :millisecond)

    IO.puts("Finished file #{in_filename}! (#{executionTime}ms)")
  end

  def stateStart([hd | tl]) do
    # starts the file, gets run only once
    case hd do
      "[" -> modoCorchete(tl, "", "") # [
      "{" -> modoLlave(tl, "", "") # {
      _ -> stateStart(tl)
    end
  end

  def modoCorchete(tl, build, stack) do
    # puts the necesarry html tags when starting a [
    modoValor(tl, Enum.join([build, "<span class=\"parentesis1\">[</span><br><div class=\"indent\">"]), ["[" | stack])
  end

  # end functions for ]
  def modoCorcheteF([], build, _), do: build
  def modoCorcheteF(_, build, [_ | ""]) do
    Enum.join([build, "</div><span class=\"parentesis1\">]</span><br>"])
  end
  def modoCorcheteF([_ | tl], build, [_ | stack]) do
    [next | _] = stack
    # makes sure that the next item in the stack gets chosen, so that it continues where it left off
    case next do
      "[" -> modoIterarCorchete(tl, Enum.join([build, "</div><span class=\"parentesis1\">]</span><br>"]), stack)
      "{" -> modoIterarLlave(tl, Enum.join([build, "</div><span class=\"parentesis1\">]</span><br>"]), stack)
    end
  end

  def modoIterarCorchete(_, build, []), do: build
  def modoIterarCorchete([], build, _), do: build
  def modoIterarCorchete([hd | tl], build, stack) do
    # itterates on what should be done next
    case hd do
      "," -> modoValor(tl, Enum.join([build, hd, "<br>"]), stack)
      "]" -> modoCorcheteF([hd | tl], build, stack)
      _ -> modoIterarCorchete(tl, build, stack)
    end
  end

  def modoCientrifico([hd | tl], build, stack) do
    # for scientific numbers
    cond do
      Regex.match?(~r/^\d$/, hd) -> modoCientrifico(tl, Enum.join([build, hd]), stack)
      hd == "+" or hd == "-" -> modoCientrifico(tl, Enum.join([build, hd]), stack)
      true -> modoIterarCorchete([hd | tl], Enum.join([build, "</span>"]), stack)
    end
  end

  def modoFloat([hd | tl], build, stack) do
    # for floats
    cond do
      Regex.match?(~r/^\d$/, hd) -> modoFloat(tl, Enum.join([build, hd]), stack)
      hd == "E" -> modoCientrifico(tl, Enum.join([build, hd]), stack)
      true -> modoIterarCorchete([hd | tl], Enum.join([build, "</span>"]), stack)
    end
  end

  def modoInt([hd | tl], build, stack) do
    # for ints
    cond do
      Regex.match?(~r/^\d$/, hd) -> modoInt(tl, Enum.join([build, hd]), stack)
      hd == "." -> modoFloat(tl, Enum.join([build, hd]), stack)
      true -> modoIterarCorchete([hd | tl], Enum.join([build, "</span>"]), stack)
    end
  end

  def modoEspecial([hd | tl], build, stack) do
    # for true, false, and null
    cond do
      Regex.match?(~r/[truefalsn]/, hd) -> modoEspecial(tl, Enum.join([build, hd]), stack)
      true -> modoIterarCorchete([hd | tl], Enum.join([build, "</span>"]), stack)
    end
  end

  def modoString([hd | tl], build, stack) do
    # To itterate over strings
    case hd do
      "\""-> modoIterarCorchete(tl, Enum.join([build, hd, "</span>"]), stack)
      _ -> modoString(tl, Enum.join([build, hd]), stack)
    end
  end

  def modoValor([], build, _), do: build
  def modoValor([hd | tl], build, stack) do
    # itterates and asks what is needed next
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

  # NOTE: all values return to modoIterar in its type, below is the same but for dictionaries

  ### ------------------------------------------------------------------------------------------------------
  ## Key search
  def modoLlave(tl, build, stack) do
    modoTagLlave(tl, Enum.join([build, "<span class=\"parentesis1\">{</span><br><div class=\"indent\"><span class=\"key\">"]), ["{" | stack])
  end

  def modoLlaveF([], build, _), do: build
  def modoLlaveF(_, build, [_ | ""]) do
    Enum.join([build, "</div><span class=\"parentesis1\">}</span><br>"])
  end
  def modoLlaveF([_ | tl], build, [_ | stack]) do
    [next | _] = stack
    case next do
      "[" -> modoIterarCorchete(tl, Enum.join([build, "</div><span class=\"parentesis1\">}</span><br>"]), stack)
      "{" -> modoIterarLlave(tl, Enum.join([build, "</div><span class=\"parentesis1\">}</span><br>"]), stack)
    end
  end

  def modoIterarLlave(_, build, []), do: build
  def modoIterarLlave([], build, _), do: build
  def modoIterarLlave([hd | tl], build, stack) do
    case hd do
      "," -> modoTagLlave(tl, Enum.join([build, hd, "<br><span class=\"key\">"]), stack)
      "}" -> modoLlaveF([hd | tl], build, stack)
      _ -> modoIterarLlave(tl, build, stack)
    end
  end

  def modoTagLlave([hd | tl], build, stack) do
    # only difference between array, this part checks for the key and continues afterwards
    case hd do
      ":" -> modoValorLlave(tl, Enum.join([build, ":</span> "]), stack)
      "}" -> modoLlaveF(tl, Enum.join([build, "</span>"]), stack)
      _ -> modoTagLlave(tl, Enum.join([build, hd]), stack)
    end
  end

  def modoCientrificoLlave([hd | tl], build, stack) do
    cond do
      Regex.match?(~r/^\d$/, hd) -> modoCientrificoLlave(tl, Enum.join([build, hd]), stack)
      hd == "+" or hd == "-" -> modoCientrificoLlave(tl, Enum.join([build, hd]), stack)
      true -> modoIterarLlave([hd | tl], Enum.join([build, "</span>"]), stack)
    end
  end

  def modoFloatLlave([hd | tl], build, stack) do
    cond do
      Regex.match?(~r/^\d$/, hd) -> modoFloatLlave(tl, Enum.join([build, hd]), stack)
      hd == "E" -> modoCientrificoLlave(tl, Enum.join([build, hd]), stack)
      true -> modoIterarLlave([hd | tl], Enum.join([build, "</span>"]), stack)
    end
  end

  def modoIntLlave([hd | tl], build, stack) do
    cond do
      Regex.match?(~r/^\d$/, hd) -> modoIntLlave(tl, Enum.join([build, hd]), stack)
      hd == "." -> modoFloatLlave(tl, Enum.join([build, hd]), stack)
      true -> modoIterarLlave([hd | tl], Enum.join([build, "</span>"]), stack)
    end
  end

  def modoEspecialLlave([hd | tl], build, stack) do
    cond do
      Regex.match?(~r/[truefalsn]/, hd) -> modoEspecialLlave(tl, Enum.join([build, hd]), stack)
      true -> modoIterarLlave([hd | tl], Enum.join([build, "</span>"]), stack)
    end
  end

  def modoStringLlave([hd | tl], build, stack) do
    case hd do
      "\""-> modoIterarLlave(tl, Enum.join([build, hd, "</span>"]), stack)
      _ -> modoStringLlave(tl, Enum.join([build, hd]), stack)
    end
  end

  def modoValorLlave([], build, _), do: build
  def modoValorLlave([hd | tl], build, stack) do
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
