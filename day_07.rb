# frozen_string_literal: true

module Parser
  extend self

  def parse_filesystem(input_filepath)
    terminal_output = File.readlines(input_filepath).map(&:strip)

    current_dir_stack = []
    filesystem = {}

    terminal_output.each do |line|
      if cd(line)
        destination_dir = cd(line)
        case destination_dir
        when '..'
          current_dir_stack.pop
        else
          current_dir_stack.push(destination_dir)
        end
      elsif ls(line)
        filesystem[current_dir_stack.dup] ||= empty_dir
      elsif dir(line)
        absolute_path = current_dir_stack + [dir(line)]
        filesystem[current_dir_stack.dup][:sub_dirs].push(absolute_path)
      elsif file(line)
        filesystem[current_dir_stack.dup][:files].merge!(file(line))
      end
    end

    filesystem
  end

  private

  def cd(line)
    match = line.match(/\$\scd\s(.+)/)

    return unless match

    match[1]
  end

  def ls(line)
    line.match(/\$\sls/)
  end

  def dir(line)
    match = line.match(/dir\s(.+)/)

    return unless match

    match[1]
  end

  def file(line)
    match = line.match(/(\d+)\s(.+)/)

    return unless match

    name = match[2]
    size = match[1].to_i

    {
      name => {
        size: size
      }
    }
  end

  def empty_dir
    {
      sub_dirs: [],
      files: {}
    }
  end
end

module FilesystemExplorer
  extend self

  def combined_size_of_small_directories(filesystem, max_dir_size:)
    size_by_directory(filesystem)
      .select { |_dir, size| size <= max_dir_size }
      .sum { |_dir, size| size }
  end

  def smallest_directory_to_delete(filesystem, total_space_on_filesystem:, unused_space_requirement:)
    sizes = size_by_directory(filesystem)

    unmet_space_requirement = unmet_space_requirement(
      total_space_on_filesystem: total_space_on_filesystem,
      unused_space_requirement: unused_space_requirement,
      sizes: sizes
    )

    raise 'space requirement already met' unless unmet_space_requirement.positive?

    dir = sizes.sort_by { |_dir, size| size }
               .find { |_dir, size| size >= unmet_space_requirement }

    raise 'unable to find a single dir' unless dir

    { dir: dir[0], size: dir[1] }
  end

  private

  def size_by_directory(filesystem)
    filesystem
      .keys
      .to_h { |dir_name| [dir_name, size_of_directory(dir_name, filesystem)] }
  end

  def size_of_directory(dir_name, filesystem)
    size_of_sub_dirs = filesystem[dir_name][:sub_dirs].sum do |sub_dir_name|
      size_of_directory(sub_dir_name, filesystem)
    end

    size_of_sub_dirs + size_of_files_in_dir(dir_name, filesystem)
  end

  def size_of_files_in_dir(dir_name, filesystem)
    filesystem[dir_name][:files].sum { |_file_name, file| file[:size] }
  end

  def unmet_space_requirement(
    total_space_on_filesystem:, unused_space_requirement:, sizes:
  )
    size_of_root_dir = sizes[['/']]
    used_space = size_of_root_dir
    unused_space = total_space_on_filesystem - used_space

    unused_space_requirement - unused_space
  end
end

if __FILE__ == $PROGRAM_NAME
  filesystem = Parser.parse_filesystem('data/day_07.txt')

  puts FilesystemExplorer.combined_size_of_small_directories(
    filesystem,
    max_dir_size: 100_000
  )

  puts FilesystemExplorer.smallest_directory_to_delete(
    filesystem,
    total_space_on_filesystem: 70_000_000,
    unused_space_requirement: 30_000_000
  )[:size]
end
