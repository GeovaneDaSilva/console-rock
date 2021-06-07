# :nodoc
module ReportHelper
  DNS_ENTRY_TYPES = {
    "1" => "A", "2" => "NS", "5" => "CNAME", "6" => "SOA", "12" => "PTR", "15" => "MX",
    "16" => "TEXT", "18" => "AFSDB", "19" => "X25", "20" => "ISDN", "21" => "RT",
    "22" => "NSAP", "23" => "NSAPPTR", "24" => "SIG", "25" => "KEY", "26" => "PX",
    "27" => "GPOS", "28" => "AAAA", "29" => "LOC", "33" => "SRV"
  }.freeze

  MACHINE_TYPES = {
    "0x1d3" => "Matsushita AM33", "0x8664" => "x64", "0x1c0" => "ARM little endian",
    "0x1c4" => "ARM Thumb-2 little endian", "0xebc" => "EFI byte code",
    "0x14c" => "Intel 386",
    "0x200" => "Intel Itanium", "0x9041" => "Mitsubishi M32R little endian",
    "0x266" => "MIPS16", "0x366" => "MIPS with FPU", "0x466" => "MIPS16 with FPU",
    "0x1f0" => "Power PC little endian", "0x1f1" => "Power PC with floating point support",
    "0x166" => "MIPS little endian", "0x5032" => "RISC-V 32-bit", "0x5064" => "RISC-V 64-bit",
    "0x5128" => "RISC-V 128-bit", "0x1a2" => "Hitachi SH3", "0x1a3" => "Hitachi SH3 DSP",
    "0x1a6" => "Hitachi SH4", "0x1a8" => "Hitachi SH5", "0x1c2" => "Thumb",
    "0x169" => "MIPS little-endian WCE v2"
  }.freeze

  def chapter_description(chapter)
    description = Report.chapter_description(chapter)
    i = Report::ORDERED_CHAPTERS.index(chapter) + 1

    "CH. #{i} #{description}"
  end

  def paginate_or_render_count(results, paginate_opts, render_opts)
    if rendered_for_pdf? then render_count results, render_opts
    elsif paginate_opts then paginate(results, **paginate_opts)
    else paginate results
    end
  end

  def render_count(results, phrase:, subject:)
    remaining = results.total_count - results.count

    "+ #{remaining} #{phrase} #{subject.pluralize(remaining)}" unless remaining.zero?
  end

  def chart_color_json
    %w[#D12149 #F47920 #FFDD00 #39597E #3AA9C8].to_json
  end

  def report_type_path(report, report_type, options = {})
    if report.persisted?
      send "r_#{report_type}_path", report, options
    else
      send "r_all_#{report_type}_path", options
    end
  end

  def report_path(report, options = {})
    if report.persisted?
      r_path report, options
    else
      root_path options
    end
  end

  def dns_entry_type(value)
    DNS_ENTRY_TYPES[value.to_s] || value
  end

  def machine_type(integer)
    type_as_hex = format("%<int>#x", int: integer)

    MACHINE_TYPES[type_as_hex] || "Unknown"
  end

  def report_path_resolver(params)
    case report
    when :executive_summary
      r_executive_summary_path(params)
    when :breaches
      r_breaches_path(params)
    else
      raise NotImplementedError, "path resolver for report: #{report} is not implemented"
    end
  end
end
