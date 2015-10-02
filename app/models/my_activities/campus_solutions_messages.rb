module MyActivities
  class CampusSolutionsMessages
    include ClassLogger, DatedFeed, HtmlSanitizer, SafeJsonParser

    def self.append!(uid, activities)
      messages = get_feed uid
      activities.concat messages
    end

    def self.get_feed(uid)
      feed = CampusSolutions::PendingMessages.new(user_id: uid).get[:feed]
      results = []
      if feed && feed[:commMessagePendingResponse]
        feed[:commMessagePendingResponse].each do |message|
          results << {
            emitter: 'Campus Solutions', # TODO what's the right emitter?
            id: '',
            linkText: message[:descr],
            source: message[:commCategory], # TODO is this right?
            summary: message[:commCenterDescr],
            type: 'campus_solutions',
            title: message[:descr],
            user_id: uid,
            date: format_date(strptime_in_time_zone(message[:lastupddttm], "%Y-%m-%d-%H.%M.%S.000000")), # 2015-08-26-16.36.29.000000
            sourceUrl: message[:url],
            url: message[:url]
          }
        end
      end
      results
    end

  end
end
