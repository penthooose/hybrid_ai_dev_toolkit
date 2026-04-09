defmodule DP.ExtractFiles do
  @db_path System.get_env("DP_DB_PATH") || "data/gutachten"
  @all_docm_files System.get_env("DP_OUTPUT_DOCM") || "data/docm_files"

  def extract_docm_files do
    # Ensure output directory exists
    File.mkdir_p!(@all_docm_files)

    # Log paths
    IO.puts("Searching in path: #{@db_path}")
    IO.puts("Output path: #{@all_docm_files}")

    # Verify base path and list contents
    if !File.exists?(@db_path) do
      IO.puts("Warning: Base path #{@db_path} does not exist!")

      %{
        total_files_found: 0,
        files_copied: 0,
        failed_files: [],
        all_docm_files: @all_docm_files
      }
    else
      IO.puts("Base path exists. Checking directory contents:")

      # List top-level items
      case File.ls(@db_path) do
        {:ok, files} ->
          IO.puts("Total items in directory: #{length(files)}")

        {:error, reason} ->
          IO.puts("Error reading directory: #{inspect(reason)}")
      end

      files = Path.wildcard("#{@db_path}/**/*GA*01.docm")
      IO.puts("Found #{length(files)} files")

      if files != [] do
        IO.puts("First few matched files: #{inspect(Enum.take(files, 3))}")
      end

      # Copy matched files to output
      results =
        Enum.map(files, fn file ->
          filename = Path.basename(file)
          target_path = Path.join(@all_docm_files, filename)

          IO.puts("Copying #{file} to #{target_path}")

          case File.cp(file, target_path) do
            :ok ->
              {:ok, filename}

            {:error, reason} ->
              IO.puts("Error copying #{filename}: #{inspect(reason)}")
              {:error, filename, reason}
          end
        end)

      # Summarize results
      successes =
        Enum.count(results, fn
          {:ok, _} -> true
          _ -> false
        end)

      failures =
        Enum.filter(results, fn
          {:error, _, _} -> true
          _ -> false
        end)

      # Return summary
      %{
        total_files_found: length(files),
        files_copied: successes,
        failed_files: failures,
        all_docm_files: @all_docm_files
      }
    end
  end
end
