defmodule DP.ConvertFiles do
  @input_path System.get_env("DOCM_INPUT_PATH", "data/docm_files")
  @output_path System.get_env("MD_OUTPUT_PATH", "data/md_files")
  @pandoc_path System.get_env("PANDOC_PATH", "pandoc")

  def convert_docm_to_md do
    # Ensure output directory exists
    File.mkdir_p!(@output_path)

    # Log paths
    IO.puts("Searching in path: #{@input_path}")
    IO.puts("Output path: #{@output_path}")
    IO.puts("Using Pandoc at: #{@pandoc_path}")

    # Verify pandoc executable (best-effort)
    if System.find_executable(Path.basename(@pandoc_path)) == nil and
         not File.exists?(@pandoc_path) do
      IO.puts("Warning: Pandoc not found at configured path!")
      {:error, "Pandoc executable not found"}
    else
      # Check if base path exists
      if !File.exists?(@input_path) do
        IO.puts("Warning: Base path #{@input_path} does not exist!")
        {:error, "Base path does not exist!"}
      else
        files = Path.wildcard(Path.join(@input_path, "**/*.docm"))
        IO.puts("Found #{length(files)} files")

        if files != [] do
          IO.puts("First matched file: #{inspect(Enum.take(files, 1))}")
        end

        # Convert each file to Markdown using pandoc
        results =
          Enum.map(files, fn file ->
            filename = Path.basename(file, ".docm")
            target_path = Path.join(@output_path, "#{filename}.md")

            IO.puts("Converting #{file} to #{target_path}")

            case convert_with_pandoc(file, target_path) do
              :ok ->
                {:ok, filename}

              {:error, reason} ->
                IO.puts("Error converting #{filename}: #{inspect(reason)}")
                {:error, filename, reason}
            end
          end)

        # Summarize results
        {:ok,
         %{
           total_files_found: length(files),
           files_converted:
             Enum.count(results, fn
               {:ok, _} -> true
               _ -> false
             end),
           failed_files:
             Enum.filter(results, fn
               {:error, _, _} -> true
               _ -> false
             end),
           output_path: @output_path
         }}
      end
    end
  end

  # Internal: run pandoc to convert a file
  defp convert_with_pandoc(source_path, target_path) do
    try do
      # Use quoted paths for safety; avoid embedding machine-specific separators
      src = Path.expand(source_path)
      tgt = Path.expand(target_path)
      pandoc = @pandoc_path

      IO.puts("  Source: #{src}")
      IO.puts("  Target: #{tgt}")
      IO.puts("  Pandoc: #{pandoc}")

      case System.cmd(pandoc, ["-f", "docx", "-t", "markdown", "-o", tgt, src],
             stderr_to_stdout: true
           ) do
        {output, 0} ->
          IO.puts("Conversion successful")
          :ok

        {output, exit_code} ->
          IO.puts("Pandoc direct call failed with exit code #{exit_code}: #{output}")

          # Fallback: run via shell if direct exec fails
          cmd = "\"#{pandoc}\" -f docx -t markdown -o \"#{tgt}\" \"#{src}\""
          IO.puts("Trying through shell: #{cmd}")

          case System.cmd("cmd.exe", ["/c", cmd], stderr_to_stdout: true) do
            {cmd_output, 0} ->
              IO.puts("Conversion through shell successful")
              :ok

            {cmd_output, cmd_exit_code} ->
              IO.puts("Shell execution failed with exit code #{cmd_exit_code}: #{cmd_output}")
              {:error, "Pandoc conversion failed: #{cmd_output}"}
          end
      end
    rescue
      e ->
        IO.puts("Error during conversion: #{inspect(e)}")
        {:error, e}
    end
  end
end
