class SakaiData < OracleDatabase

  def self.table_prefix
    Settings.campusdb.bspace_prefix || ''
  end

  def self.get_connection
    connection
  end

  # Oracle and H2 have no timestamp formatting function in common.
  def self.timestamp_format(timestamp_column)
    if test_data?
      "formatdatetime(#{timestamp_column}, 'yyyy-MM-dd HH:mm:ss')"
    else
      "to_char(#{timestamp_column}, 'yyyy-mm-dd hh24:mi:ss')"
    end
  end
  def self.timestamp_parse(datetime)
    if test_data?
      "parsedatetime('#{datetime.utc.to_s(:db)}', 'yyyy-MM-dd HH:mm:ss')"
    else
      "to_date('#{datetime.utc.to_s(:db)}', 'yyyy-mm-dd hh24:mi:ss')"
    end
  end

  # TODO This is another fairly stable query.
  def self.get_announcement_tool_id(site_id)
    sql = <<-SQL
    select tool_id from #{table_prefix}sakai_site_tool
      where site_id = #{connection.quote(site_id)} and registration = 'sakai.announcements'
    SQL
    if (row = connection.select_one(sql))
      row['tool_id']
    end
  end

  # Get a site's published announcements within a time range.
  #
  # Announcements which are due to be released at a given time are fairly common. If longer-lived
  # caching is enabled, the "up to this time" DB query parameter should be set after "now", and the
  # release date-time should be checked by the proxy service.
  #
  # TODO This only finds site-wide announcements. Sakai can also broadcast announcements to a
  # subset of site members. But since that does not seem to be used very often locally, it's
  # not yet handled here.
  def self.get_announcements(site_id, from_datetime, to_datetime)
    channel_id = "/announcement/channel/#{site_id}/main"
    announcements = []
    sql = <<-SQL.squish
    select message_id, channel_id, #{timestamp_format('message_date')} as message_date, owner, xml from #{table_prefix}announcement_message
      where draft = 0 and channel_id = #{connection.quote(channel_id)}
        and message_date >= #{timestamp_parse(from_datetime)} and message_date <= #{timestamp_parse(to_datetime)}
      order by message_date desc
    SQL
    connection.select_all(sql)
  end

  def self.get_hidden_site_ids(sakai_user_id)
    sites = []
    sql = <<-SQL
    select xml from #{table_prefix}sakai_preferences
      where preferences_id = #{connection.quote(sakai_user_id)}
    SQL
    if (xml = connection.select_one(sql))
      xml = Nokogiri::XML::Document.parse(xml['xml'])
      xml.xpath('preferences/prefs/properties/property[@name="exclude"]').each do |el|
        sites.push(Base64.decode64(el['value']))
      end
    end
    sites
  end

  # TODO This query can be cached forever, more or less.
  def self.get_sakai_user_id(person_id)
    sql = <<-SQL
    select user_id from #{table_prefix}sakai_user_id_map
      where eid = #{connection.quote(person_id)}
    SQL
    if (user_id = connection.select_one(sql))
      user_id = user_id['user_id']
    end
    user_id
  end

  # Only returns published Course and Project sites, not special sites like the user's dashboard or the administrative workspace.
  def self.get_users_sites(sakai_user_id)
    sql = <<-SQL
    select s.site_id, s.type, s.title, s.short_desc, s.description, sp.value as term
    from #{table_prefix}sakai_site s join #{table_prefix}sakai_site_user su on
      su.user_id = #{connection.quote(sakai_user_id)} and su.site_id = s.site_id and s.published = 1 and s.type in ('course', 'project')
      left outer join #{table_prefix}sakai_site_property sp on s.site_id = sp.site_id and sp.name = 'term'
    SQL
    connection.select_all(sql)
  end

end