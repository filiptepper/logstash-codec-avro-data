# encoding: utf-8
require 'logstash/codecs/base'
require 'avro'

# This  codec will append a string to the message field
# of an event, either in the decoding or encoding methods
#
# This is only intended to be used as an example.
#
# input {
#   stdin { codec =>  }
# }
#
# or
#
# output {
#   stdout { codec =>  }
# }
#
class LogStash::Codecs::AvroData < LogStash::Codecs::Base
  # The codec name
  config_name 'avro-data'

  # Set the directory where logstash will store the tmp files before processing them.
  # default to the current OS temporary directory in linux /tmp/logstash
  config :temporary_directory, :validate => :string, :default => File.join(Dir.tmpdir, "logstash")

  def register
    FileUtils.mkdir_p(@temporary_directory) unless Dir.exist?(@temporary_directory)
  end # def register

  def decode(data)
    Tempfile.create('avro-data', temporary_directory) do |temporary_file|
      temporary_file.binmode
      temporary_file.write(data)
      temporary_file.close

      Avro::DataFile.open(temporary_file.path).each do |datum|
        yield LogStash::Event.new(datum)
      end
    end
  end # def decode

end # class LogStash::Codecs::AvroData
