#!/usr/bin/env ruby
require 'rubygems'
require 'mechanize'
require 'optparse'
require 'pp'

class Downloader
  @@USER_AGENTS = ['Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)',
                'Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; .NET CLR 1.1.4322; .NET CLR 2.0.50727)',
                'Mozilla/5.0 (Windows; U; Windows NT 5.0; en-US; rv:1.4b) Gecko/20030516 Mozilla Firebird/0.6',
                'Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_2; de-at) AppleWebKit/531.21.8 (KHTML, like Gecko) Version/4.0.4 Safari/531.21.10',
                'Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; en-US; rv:1.9.2) Gecko/20100115 Firefox/3.6',
                'Mozilla/5.0 (Macintosh; U; PPC Mac OS X Mach-O; en-US; rv:1.4a) Gecko/20030401',
                'Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.4) Gecko/20030624',
                'Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.2.1) Gecko/20100122 firefox/3.6.1',
                'Mozilla/5.0 (compatible; Konqueror/3; Linux)',
                'Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/28.0.1500.71 Safari/537.36',
                'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/29.0.1547.62 Safari/537.36',
                'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.22 (KHTML, like Gecko) Chrome/25.0.1364.172 Safari/537.22',
                'Mozilla/5.0 (MSIE 8.0; Windows NT 6.3; WOW64; Trident/7.0; rv:11.0) like Gecko',
                'Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 6.1; WOW64; Trident/5.0; SLCC2; .NET CLR 2.0.50727; .NET CLR 3.5.30729; .NET CLR 3.0.30729; Media Center',
                'Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/28.0.1500.71 Safari/537.36',
                'Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.0; Trident/4.0; Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1) ; .NET CLR 3.5.30729)']


  attr :options
  attr_accessor :agent

  def initialize
    config!
    @agent = spawn_bot(proxy_port: options[:proxy_port])
    set_up_directory!
  end

  def config!
    @options = {start_index: 1, end_index: 2, proxy_port: nil}

    option_parser = OptionParser.new do |option_parser|
      option_parser.banner = 'Example usage: ./stepmaniaonline_mass_downloader.rb --start=1 --end=1234 -p 8118'
      option_parser.on('-s', '--start=INTEGER', Integer, 'ID of first simfile ID to download') { |o| options[:start_index] = o }
      option_parser.on('-e', '--end=INTEGER', Integer, 'Last index of simfile ID range') { |o| options[:end_index] = o }
      option_parser.on('-p', '--proxy_port=INTEGER', Integer, 'Port number for local proxy') { |o| options[:proxy_port] = o }
    end

    option_parser.parse(ARGV)
    pp options
  end

  def random_agent
    @@USER_AGENTS[rand(@@USER_AGENTS.size-1)]
  end

  def spawn_bot(proxy_port: nil)
    agent = Mechanize.new
    agent.set_proxy('localhost', proxy_port) if proxy_port
    agent.user_agent = random_agent
    agent.max_history = 0 # No need to keep track!
    agent
  end

  def set_up_directory!(dir_name: 'simfiles')
    Dir.mkdir(dir_name) unless File.directory? dir_name
    agent.pluggable_parser.default = Mechanize::DirectorySaver.save_to(dir_name)
  end

  def mass_download!(start_index: options[:start_index], end_index: options[:end_index])
    # Loop through all of the simfile pack pages, downloading each pack
    (start_index..end_index).each do |i|
      begin
        link = "https://search.stepmaniaonline.net/pack/id/#{i}"
        puts "Attempting to visit #{link}..."
        page = agent.get link
      rescue Mechanize::ResponseCodeError, Net::ReadTimeout => e
        puts e
        next
      end
  
      begin
        puts 'Searching for the "Download" button for this simfile pack...'
        download_link = page.link(text: 'Download').href
        puts download_link
      rescue e
        puts e
        next
      end

      begin
        puts 'Downloading and saving the simfile pack under "./simfiles/"...'
        agent.get(download_link).save if /\.zip$/.match download_link
      rescue e
        puts e
        next
      end
    end
  end
end

downloader = Downloader.new
downloader.mass_download!
