class TimetrapToggl::Formatter
  TOGGABLE_REGEX = /@(.*)/

  attr_reader :entry, :config

  def initialize(entry, config)
    @entry  = entry
    @config = config
  end

  def format
    if project && project["id"]
      {
        "description" => description,
        "duration" => duration,
        "start" =>   start,
        "pid" => project["id"],
        "created_with" => "timetrap-toggl",
      }
    else
      {
        error: "Project #{code} does not exist",
        note: entry[:note]
      }
    end
  end

  def start
    TogglV8::API.new.iso8601(entry[:start].to_datetime)
  end

  def project
    if config.aliases[code]
      config.projects.find do |p|
        p["name"] == config.aliases[code]
      end
    else
      config.projects.find do |p|
        code == p["name"].downcase.gsub(/[^a-zA-Z\d\s]/, '').gsub(/\s+/, '-')
      end
    end
  end

  def task_id
    alias_config[:task_id]
  end

  def round_in_minutes
    config.round_in_minutes
  end

  def code
    if match = TOGGABLE_REGEX.match(entry[:note])
      code = match[1].downcase
    end
  end

  def description
    entry[:note].gsub("@#{code}", '').strip
  end

  def duration
    seconds_for_time(entry[:start], entry[:end])
  end

  def seconds_for_time(start_time, end_time)
    (end_time - start_time).to_i
  end
end
