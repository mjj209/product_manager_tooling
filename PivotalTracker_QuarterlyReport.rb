#!/usr/bin/env ruby

require 'net/https'
require 'json'
require 'yaml'
require 'time'

#readme
#to run this, do "ruby reportCycleTimeEpics.rb <tracker-id> <pivotal-tracker-token>"

if ARGV.length != 2
  puts "Please provide the project_id and then pivotal-tracker token"
  exit
end

$project_id = ARGV[0]
$token = ARGV[1]

class Numeric
  def duration
    secs  = self.to_int
    mins  = secs / 60
    hours = mins / 60
    days  = hours / 24

    if days > 0
      time = (days * 9) + [hours % 24, 9].min
      "#{time}"
    elsif hours > 0
      time = [hours % 24, 9].min
      "#{time}"
    elsif mins > 0
      "1"
    elsif secs >= 0
      "1"
    end
  end
end


class CycleTimeForAcceptedStories
  @@tracker_host = ENV['TRACKER_HOST'] ||
    # 'http://localhost:3000' ||  # comment this out to default to prod
    'https://www.pivotaltracker.com'

  def run
    stories = {}
    #using an offset of 0 starts with the newest stories
    offset = 0
    limit = 200
    total = nil
    count = 0
    begin


      puts sprintf("this is one get cycle")
      activity_with_envelope = get("projects/#{$project_id}/activity", "offset=#{offset}&envelope=true")
      activity_items = activity_with_envelope['data']
      #set the total to the total number of activities we want to scan 15000 will give us about 6 months.
      total = 500

      activity_items.each do |activity|
        activity['changes'].each do |change_info|
          count+=1
          STDERR.print ". " if (count + 1) % 100 == 0
          if is_state_change(change_info)

            story_id = change_info['id']
            stories[story_id] ||= {}
            stories[story_id]['id'] ||= story_id
            if change_info['new_values']['current_state'] == 'started'
              stories[story_id]['started_at'] = activity['occurred_at']
            elsif stories[story_id]['accepted_at'].nil? && change_info['new_values']['current_state'] == 'accepted'
              stories[story_id]['accepted_at'] = activity['occurred_at']
            end
          end
        end
      end

      offset += activity_with_envelope['pagination']['limit']
      puts offset
      puts total
    end while total > offset
    STDERR.puts ""

    # look up name and type for each story
    stories.keys.each_slice(100) do |story_ids|
      search_results = get("projects/#{$project_id}/search", "query=id:#{story_ids.join(',')}%20includedone:true")
      #search_results = getstory("projects/939266/stories/#{story_ids.join(',')}")
      search_results['stories']['stories'].each do |story_hash|
        stories[story_hash['id']]['name'] = story_hash['name']
        #get all labels & extra trash
        #last known good config stories[story_hash['id']]['labels'] = story_hash['labels']
        stories[story_hash['id']]['labels'] = story_hash['labels']
        stories[story_hash['id']]['story_type'] = story_hash['story_type']
        stories[story_hash['id']]['points'] = 1

        if story_hash['story_type'] == 'feature'
          story_id = story_hash['id']
          points_result = get("projects/#{$project_id}/stories/#{story_id}", "")
          stories[story_hash['id']]['points'] = points_result['estimate']
        end

      end
    end

    # drop stories where we can't compute cycle time (including all releases), and compute it for the ones left
    stories = stories.values.
        #select {|story_info| story_info['story_type'] != 'release'}.
        select {|story_info| story_info.has_key?('started_at') && story_info.has_key?('accepted_at') && story_info.has_key?('labels')}.
        map do |story_info|
          story_info['cycle_time'] = Time.parse(story_info['accepted_at']) - Time.parse(story_info['started_at'])
          story_info
        end

    puts sprintf("Story_ID;duration_hours;Accepted_at;Month;Year;Quarter;Points;Raw_Tags;Filtered_Tags;Type;Name")
    stories.
        sort_by { |story_info| story_info['started_at'] }.
        each do |story_info|
          name =  story_info['name'] || '*deleted*'
          month = Time.parse(story_info['accepted_at']).month
          year = Time.parse(story_info['accepted_at']).year
          quarter = Time.parse(story_info['accepted_at']).year.to_s + " Q" + (((Time.parse(story_info['accepted_at']).month  - 1) / 3) + 1).to_s
          puts "#{story_info['id']};#{story_info['cycle_time'].duration};#{story_info['accepted_at']};#{month};#{year};#{quarter};#{story_info['points']};#{get_tags_from_labels_mess(story_info['labels'])};#{get_filtered_label(story_info['labels'])};#{story_info['story_type']};#{name}"
        end

  end

  def get_tags_from_labels_mess(labels)
    ret = []
    labels.each do |label|
      ret.push(label['name'])
    end
    ret.join ","
  end

  def get_filtered_label(labels)
    ret = []
    labels.each do |label|
    ret.push(label['name'])
       end
    full_tags = ret.join ","

       #This is where we can set the epic priorities
       epic_priority_01 = "gcp-provisioner"
       epic_priority_02 = "env-mgmt"
       epic_priority_03 = "envs-app"
       epic_priority_04 = "concourse"
       epic_priority_05 = "nsx"
       epic_priority_06 = "hardware mgmt"
       epic_priority_07 = "cf-deployment"
       epic_priority_08 = "pools of resources"
       epic_priority_09 = "gitbot-v2.0"
       epic_priority_10 = "azure-stack"
       epic_priority_11 = "ssl"
       epic_priority_12 = "openstack"
       epic_priority_13 = "pks"
       epic_priority_14 = "wavefront"
       epic_priority_15 = "k8s"
       epic_priority_16 = "sred-work"


    if full_tags.include? epic_priority_01
      ret = epic_priority_01
    elsif full_tags.include? epic_priority_02
      ret = epic_priority_02
    elsif full_tags.include? epic_priority_03
      ret = epic_priority_03
    elsif full_tags.include? epic_priority_04
      ret = epic_priority_04
    elsif full_tags.include? epic_priority_05
      ret = epic_priority_05
    elsif full_tags.include? epic_priority_06
      ret = epic_priority_06
    elsif full_tags.include? epic_priority_07
      ret = epic_priority_07
    elsif full_tags.include? epic_priority_08
      ret = epic_priority_08
    elsif full_tags.include? epic_priority_09
      ret = epic_priority_09
    elsif full_tags.include? epic_priority_10
      ret = epic_priority_10
    elsif full_tags.include? epic_priority_11
      ret = epic_priority_11
    elsif full_tags.include? epic_priority_12
      ret = epic_priority_12
    elsif full_tags.include? epic_priority_13
      ret = epic_priority_13
    elsif full_tags.include? epic_priority_14
      ret = epic_priority_14
    elsif full_tags.include? epic_priority_15
      ret = epic_priority_15
    elsif full_tags.include? epic_priority_16
      ret = epic_priority_16

    else
    ret = "maintenance"
    end
  end

  def is_state_change(change_info)
    change_info['kind'] == 'story' &&
      change_info['new_values'] &&
      change_info['new_values'].has_key?('current_state')
  end

  def get(url, query)
    request_header = {
      'X-TrackerToken' => $token
    }

    uri_string = @@tracker_host + '/services/v5/' + url
#    puts uri_string    # print the URI of each GET request made
    resource_uri = URI.parse(uri_string)
    # resource_uri.query = URI.encode_www_form(query)
    http = Net::HTTP.new(resource_uri.host, resource_uri.port)
    http.use_ssl = @@tracker_host.start_with?('https')

    response = http.start do
      http.get(resource_uri.path + '?' + query, request_header)
    end

    JSON.load(response.body)
  end
end

CycleTimeForAcceptedStories.new.run
