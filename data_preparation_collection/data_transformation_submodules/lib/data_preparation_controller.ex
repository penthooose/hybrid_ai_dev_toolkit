defmodule DataPreparationController do
  @moduledoc """
  API for data preparation tools; provides functions and a __using__ macro
  to import common helpers.
  """

  defmacro __using__(_) do
    quote do
      def extract_files do
        DP.ExtractFiles.extract_docm_files()
      end

      def filter_files do
        DP.ExtractFiles.filter_docm_files()
      end

      def convert_to_markdown do
        DP.ConvertFiles.convert_docm_to_md()
      end

      def filter_md_files do
        DP.FilterFiles.filter_md_files()
      end

      def partition_md_files do
        DP.PartitionData.partition_md_files()
      end

      def prepare_format_for_prompts do
        DP.PrepareTrainingData.prepare_format_for_prompts()
      end

      def prepare_json_for_prompts do
        DP.PrepareTrainingData.prepare_json_for_prompts()
      end

      def extract_single_chapter_filenames do
        Statistics.extract_single_chapter_filenames()
      end

      def check_low_chapter_count do
        Statistics.check_low_chapter_count()
      end
    end
  end

  # Shell-accessible wrappers
  def extract_files, do: DP.ExtractFiles.extract_docm_files()
  def filter_files, do: DP.ExtractFiles.filter_docm_files()
  def convert_to_markdown, do: DP.ConvertFiles.convert_docm_to_md()
  def filter_md_files, do: DP.FilterFiles.filter_md_files()
  def partition_md_files, do: DP.PartitionData.partition_md_files()

  def partition_md_files(input, output, include_subchapters \\ true),
    do: DP.PartitionData.partition_md_files(input, output, include_subchapters)

  def prepare_format_for_prompts, do: DP.PrepareTrainingData.prepare_format_for_prompts()
  def prepare_json_for_prompts, do: DP.PrepareTrainingData.prepare_json_for_prompts()
  def extract_single_chapter_filenames, do: Statistics.extract_single_chapter_filenames()
  def check_low_chapter_count, do: Statistics.check_low_chapter_count()
end
