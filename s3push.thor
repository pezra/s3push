#!/usr/bin/env ruby
$KCODE='UTF8'
 
require 'rubygems'
require 'aws/s3'
require 'parallel_each'
 
class S3Push < Thor
  desc "push /Pictures --to-bucket=my-picture-bucket", "push all the files in a directory to s3"
  method_option :bucket, :type => :string, :require => true, :aliases => '--to-bucket'
  method_option :file_pattern, :type => :string, :default => '*', :aliases => '--file-pattern'
  def push(directory)
    AWS::S3::Base.establish_connection!(
      :access_key_id => ENV['AWS_ACCESS_KEY_ID'],
      :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY']
    )
    bucket = options[:bucket]

    push_glob = File.join('**', options[:file_pattern])

    STDOUT << "Pushing `#{File.join(directory, push_glob)}` to S3 bucket #{bucket}\n"
 
    child_process_count = 0
    Dir.chdir(directory)
    
    Dir.glob(push_glob) do |f|
      next if File.directory?(f)
      
      if child_process_count > 10
        Process.wait
        child_process_count -= 1
      end
      
      Process.fork do 
        $0="s3push #{f}"
        
        AWS::S3::Base.establish_connection!(
                                            :access_key_id => ENV['AWS_ACCESS_KEY_ID'],
                                            :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY']
                                            )
        
        if AWS::S3::S3Object.exists?(f, bucket)
          STDOUT << '.'
          STDOUT.flush
          next
        end
          
        STDOUT << "\npushing #{f}"
        STDOUT.flush
        
        AWS::S3::S3Object.store(f, open(f), bucket)
        
      end
      child_process_count += 1
    end
    
    Process.waitall
  end
    
end
