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

  def smallest_directory_to_delete(filesystem, disk_size:, total_required_unused_space:)
    sizes = size_by_directory(filesystem)

    used_space = sizes[['/']]
    unused_space = disk_size - used_space
    remaining_required_unused_space = total_required_unused_space - unused_space

    return unless remaining_required_unused_space.positive?

    dir, size = sizes.sort_by { |_dir, size| size }
                     .find { |_dir, size| size >= remaining_required_unused_space }

    { dir: dir, size: size }
  end

  private

  def size_by_directory(filesystem)
    # not including sub-dir sizes
    sizes = filesystem.to_h do |dir_name, dir|
      [dir_name, size_of_files_directly_in_directory(dir)]
    end

    sizes.keys.to_h do |dir_name|
      [
        dir_name,
        size_of_directory(dir_name, sizes, filesystem)
      ]
    end
  end

  def size_of_files_directly_in_directory(dir)
    dir[:files].sum { |_file_name, file| file[:size] }
  end

  def size_of_directory(dir_name, sizes, filesystem)
    sizes[dir_name] + size_of_sub_dirs(dir_name, sizes, filesystem)
  end

  def size_of_sub_dirs(dir_name, sizes, filesystem)
    filesystem[dir_name][:sub_dirs].sum do |sub_dir_name|
      size_of_directory(sub_dir_name, sizes, filesystem)
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  filesystem = Parser.parse_filesystem('data/day_07.txt')

  pp FilesystemExplorer
    .combined_size_of_small_directories(filesystem, max_dir_size: 100_000)

  pp FilesystemExplorer
    .smallest_directory_to_delete(
      filesystem,
      disk_size: 70_000_000,
      total_required_unused_space: 30_000_000
    )[:size]
end
