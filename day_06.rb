# frozen_string_literal: true

def start_of_packet_marker?(string)
  string.chars.uniq.count == string.length
end

def n_chars_needed_to_receive_unique_marker(datastream_buffer, marker_length:)
  0..(datastream_buffer.length - (marker_length - 1)).times do |index|
    return index + marker_length if start_of_packet_marker?(datastream_buffer[index, marker_length])
  end
end

if __FILE__ == $PROGRAM_NAME
  input_filepath = 'data/day_06.txt'
  datastream_buffer = File.read(input_filepath)

  puts n_chars_needed_to_receive_unique_marker(datastream_buffer, marker_length: 4)
  puts n_chars_needed_to_receive_unique_marker(datastream_buffer, marker_length: 14)
end
