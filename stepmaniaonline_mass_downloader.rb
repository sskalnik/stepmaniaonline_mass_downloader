#!/usr/bin/env ruby
require 'rubygems'
require 'mechanize'
require 'optparse'
require 'pp'

class Downloader
  @@USER_AGENTS = [
    'Linux Firefox',
    'Linux Konqueror',
    'Linux Mozilla',
    'Windows Firefox',
    'Windows Mozilla',
    'Windows Chrome',
    'Windows IE 11',
    'Windows Edge',
    'Mac Firefox',
    'Mac Mozilla'
  ]

  attr :options
  attr_accessor :agent

  def initialize
    config!
    renew_agent!
    set_up_directory!
  end

  def config!
    @options = {start_index: 1, end_index: 2, proxy_port: nil, save_dir: './simfiles'}

    option_parser = OptionParser.new do |option_parser|
      option_parser.banner = 'Example usage: ./stepmaniaonline_mass_downloader.rb --start=1 --end=1234 -p 8118'
      option_parser.on('-s', '--start=INTEGER', Integer, 'ID of first simfile ID to download') { |o| options[:start_index] = o }
      option_parser.on('-e', '--end=INTEGER', Integer, 'Last index of simfile ID range') { |o| options[:end_index] = o }
      option_parser.on('-p', '--proxy_port=INTEGER', Integer, 'Port number for local proxy') { |o| options[:proxy_port] = o }
      option_parser.on('-d', '--simfile_dir=STRING', String, 'Name of the directory where simfiles will be saved') { |o| options[:save_dir] = o }
    end

    option_parser.parse(ARGV)
    pp options
  end

  def random_user_agent
    @@USER_AGENTS[rand(@@USER_AGENTS.size-1)]
  end

  def spawn_bot(proxy_port: nil)
    agent = Mechanize.new
    agent.set_proxy('localhost', proxy_port) if proxy_port
    agent.user_agent_alias = random_user_agent
    agent.max_history = 0 # No need to keep track!
    agent.max_file_buffer = 268435456 # Less than 256MB files are stored in memory
    agent.follow_meta_refresh = true # Follow "click if page doesn't automatically refresh"
    agent
  end

  def renew_agent!
    puts 'Spawning a new Mechanize instance...'
    @agent = spawn_bot(proxy_port: options[:proxy_port])
  end

  def set_up_directory!(save_dir: options[:save_dir])
    Dir.mkdir(save_dir) unless File.directory? save_dir
    # Set the download behavior for .zip files to save to a simfile folder
    #agent.pluggable_parser['application/octet-stream'] = Mechanize::DirectorySaver.save_to(save_dir)
    #agent.pluggable_parser['application/zip'] = Mechanize::DirectorySaver.save_to(save_dir)
  end

  def get_pack_page(id)
    retries = 0
    begin
      link = "https://search.stepmaniaonline.net/pack/id/#{id}"
      puts "Attempting to visit #{link}..."
      page = agent.get link
    rescue Mechanize::ResponseCodeError, Net::ReadTimeout => e
      puts e
      if retries < 2
        renew_agent!
        retry
      else
        puts "Failed after #{retries + 1} attempts!"
        return
      end
      retries += 1
    end
  end

  def download_simfile_pack(download_link, save_dir: options[:save_dir])
    # file_name = /stepmania-online\.com\/(.+\.zip)/.match(download_link.href)[1]
    file_name = download_link.uri.path.sub('/', '').strip
    full_path = File.join(save_dir, file_name)
    puts "#{file_name} will be saved under #{save_dir}"

    if File.exist? full_path
      if File.zero? full_path
        puts "File \"#{file_name}\" already exists in directory \"#{save_dir}\, but it is empty and will be replaced!"
      else
        puts "File \"#{file_name}\" already exists in directory \"#{save_dir}\"! Skipping..."
        return
      end
    end

    begin
      puts 'Clicking on the download button...'
      resp = agent.click download_link
      puts "Downloading and saving the simfile pack named \"#{file_name}\" under \"#{save_dir}\"..."
      saved_file_name = resp.save(File.join('./simfiles', resp.uri.path.strip))
      puts "Successfully saved #{saved_file_name}!"
      #agent.get(download_link).save!
      #downloader = Mechanize::DirectorySaver.save_to(save_dir) #, {overwrite: true})
      # Mechanize::Parser expects a URI object, not a String!
      # Passing download_link.href => NoMethodError (undefined method `path' for #<String:0x00000000037cb930>)
      #pp download_link
      #downloader.new download_link
    rescue StandardError => e
      puts e
      return
    end
  end

  # Loop through all of the simfile pack pages, downloading each pack
  def mass_download!(start_index: options[:start_index], end_index: options[:end_index])
    (start_index..end_index).each do |i|
      page = get_pack_page i
      begin
        puts 'Searching for the "Download" button for this simfile pack...'
        download_link = page.link(text: 'Download')
        puts download_link.href
      rescue StandardError => e
        puts e
        next
      end
      download_simfile_pack(download_link)
    end
  end
end

downloader = Downloader.new
downloader.mass_download!
