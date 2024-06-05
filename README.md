What are S3 Buckets?

Amazon S3 (Simple Storage Service) is a scalable object storage service provided by Amazon Web Services (AWS). An S3 bucket is a container in which objects are stored. These objects can be files, images, videos, backups, and any other type of digital data. Each bucket is identified by a unique name within the AWS global namespace, and users can specify access controls and configurations for their buckets.
Why Enumerate S3 Buckets?

Enumerating S3 buckets can be important for several reasons:

    Security Testing: Identifying misconfigured or publicly accessible buckets to ensure sensitive data is not exposed.
    Data Discovery: Finding publicly available data which could be used for competitive analysis, research, or to gather information about a company.
    Penetration Testing: Ethical hackers often look for publicly accessible S3 buckets as part of their security assessments to highlight potential security issues.

How This Tool Works

This tool is a Ruby script designed to enumerate (bruteforce) S3 bucket names. It uses a list of common prefixes and permutations of these prefixes to generate potential S3 bucket names and checks if they exist.

Here's a breakdown of how the tool operates:

  Wordlist Generation:
        The script starts by generating a wordlist of potential S3 bucket names.
        It takes a common prefix (e.g., a company name or project name) and combines it with various environment names (e.g., dev, prod) and wordlist entries to create permutations.

   Bucket Checking:
        For each generated bucket name, the tool constructs the S3 bucket URL and makes an HTTP request to check if the bucket exists.
        The script uses the Net::HTTP library to send HTTP requests and checks the HTTP response code. If the response code is not 404, the bucket is considered to exist.

  Output:
        If a bucket is found to exist, the tool outputs the bucket name along with the HTTP response code in red color for visibility.

Detailed Code Explanation

ruby code :-

    #!/usr/bin/env ruby

    require 'net/http'
    
    require 'timeout'
    
    
    
    class String
    
      def red; "\e[31m#{self}\e[0m" end
    
    end
    
    
    
    class S3
    
      attr_reader :bucket, :domain, :code
    
    
    
      def initialize(bucket)

    @bucket = bucket

    @domain = format('http://%s.s3.amazonaws.com', bucket)

      end
    
    
    
      def exists?
    
        code != 404
    
      end
    
    
    
      def code

    http && http.code.to_i

      end
    
    
    
      private
    
    
    
      def http

    Timeout::timeout(5) do

      @http ||= Net::HTTP.get_response(URI.parse(@domain))

    end

      rescue
    
      end
    
    end
    
    
    
    class Scanner
    
      def initialize(list)
    
        @list = list
    
      end
    
    
    
      def scan

    @list.each do |word|

      bucket = S3.new word



      if bucket.exists?

        puts "Found bucket: #{bucket.bucket}.s3.amazonaws.com (#{bucket.code})".red

      end

    end

    end

    end
    
    
    
    class Wordlist
    
      ENVIRONMENTS = %w(dev development stage s3 staging prod production test)
    
      PERMUTATIONS = %i(permutation_raw permutation_envs permutation_host)
    
    
    
      class << self

    def generate(common_prefix, prefix_wordlist)

      [].tap do |list|

        PERMUTATIONS.each do |permutation|

          list << send(permutation, common_prefix, prefix_wordlist)

        end

      end.flatten.uniq

    end



    def from_file(prefix, file)

      generate(prefix, IO.read(file).split("\n"))

    end



    def permutation_raw(common_prefix, _prefix_wordlist)

      common_prefix

    end



    def permutation_envs(common_prefix, prefix_wordlist)

      [].tap do |permutations|

        prefix_wordlist.each do |word|

          ENVIRONMENTS.each do |environment|

            ['%s-%s-%s', '%s-%s.%s', '%s-%s%s', '%s.%s-%s', '%s.%s.%s'].each do |bucket_format|

              permutations << format(bucket_format, common_prefix, word, environment)

            end

          end

        end

      end

    end



    def permutation_host(common_prefix, prefix_wordlist)

      [].tap do |permutations|

        prefix_wordlist.each do |word|

          ['%s.%s', '%s-%s', '%s%s'].each do |bucket_format|

            permutations << format(bucket_format, common_prefix, word)

            permutations << format(bucket_format, word, common_prefix)

          end

        end

      end

    end

    end

    end
    
    
    
    wordlist = Wordlist.from_file(ARGV[0], 'common_bucket_prefixes.txt')
    
    
    
    puts "Generated wordlist from file, #{wordlist.length} items..."
    
    
    
    Scanner.new(wordlist).scan



How to Use the Tool

  Prepare the Wordlist: Create a text file named common_bucket_prefixes.txt with common bucket name prefixes, each on a new line.

   Run the Script: Execute the script in the terminal with the common prefix as an argument:

   sh

    ./s3_enum.rb myprefix

  This command will generate potential bucket names using the common prefix and the entries in common_bucket_prefixes.txt.

    Review Output: The script will print out any found buckets in red text.

This tool is useful for security professionals and researchers needing to discover and audit S3 bucket configurations and accessibility.
