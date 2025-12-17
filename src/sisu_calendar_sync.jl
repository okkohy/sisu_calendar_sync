module sisu_calendar_sync

using HTTP
using Dates

URL = readline("link.url")

function load()
  response = HTTP.get(URL)
  body = String(response.body)
  split(body, "\r\n")
end

function get_events(lines)
  begin_pattern = r"^BEGIN:VEVENT"
  end_pattern = r"^END:VEVENT"
  header = []
  header_ends = false
  events = []
  for (idx, line) in enumerate(lines)
    if match(begin_pattern, line) !== nothing
      header_ends = true
      event_lines = []
      ln = line
      ix = idx
      while match(end_pattern, ln) === nothing
        push!(event_lines, ln)
        ix = ix + 1
        ln = lines[ix]
      end
      push!(event_lines, "END:VEVENT")
      push!(events, event_lines)
    elseif !header_ends
      push!(header, line)
    end
  end
  push!(header, "END:VTIMEZONE")
  join(header[1:end-1], "\n"), events
end

function filter_courses(courses)
  
  summaries = Set()
  for event in courses
    
    summary = event[5]
    datestamp = event[3]
    durationtag = event[4]
    # DTSTART:20260119T121500Z
    # DURATION:PT2H45M\r
    date = DateTime(datestamp[9:21], dateformat"yyyymmddTHHMM")
    duration = Time(parse(Int, durationtag[12]), parse(Int, durationtag[14:15]))
    # println(date, " - ", datestamp)
    if date > today()
      push!(summaries, (
                        summary[9:end-2]
                        , dayofweek(date) |> dayname
                        , hour(date) + 2 # utc + 2
                        , minute(date)
                        , duration
                       ))
    end

  end
  sort(collect(summaries), by=f(x) = x[1])
end

function main()
  event_lines = load()
  header, courses = get_events(event_lines)
  tail = "END:VCALENDAR"
  event_choices = filter_courses(courses)

  answers = []
  for (summ, day, h, m, dt) in event_choices
    println("Do you want to include this event:")
    println("$h:$m, $day ($dt) :: $summ")
    print("y/n: ")
    ans = readline()
    if contains(lowercase(ans), "y")
      push!(answers, summ)
    end
  end

  result = [header]
  for course in courses
    if course[5][9:end-2] in answers # summary
      push!(result, join(course, "\n"))
    end
  end
  push!(result, tail)
  result = join(result, "\n")
  if !isfile("export.ics")
    write("export.ics", result)
  else
    a = 1
    while isfile("export-$a.ics")
      a += 1
    end
    write("export-$a.ics", result)
  end
end

end # module sisu_calendar_sync
