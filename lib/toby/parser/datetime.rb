# frozen_string_literal: true

module Toby
  module Parser
    # @see https://toml.io/en/v1.0.0-rc.3#offset-date-time
    class OffsetDateTime < Time
      def to_s
        strftime('%Y-%m-%dT%H:%M:%S%z')
      end
    end

    # @see https://toml.io/en/v1.0.0-rc.3#local-date-time
    class LocalDateTime < Time
      def to_s
        strftime('%Y-%m-%dT%H:%M:%S')
      end
    end

    # @see https://toml.io/en/v1.0.0-rc.3#local-date
    class LocalDate < Time
      def to_s
        strftime('%Y-%m-%d')
      end
    end

    # @see https://toml.io/en/v1.0.0-rc.3#local-time
    class LocalTime < Time
      def to_s
        utc.strftime('%H:%M:%S.%L')
      end
    end

    module Match
      # @see https://toml.io/en/v1.0.0-rc.3#offset-date-time
      module OffsetDateTime
        def value
          skeleton = captures[:datetime_skeleton].first
          year, mon, day, hour, min, sec, sec_frac = skeleton.value
          offset = captures[:date_offset].first || '+00:00'
          sec = "#{sec}.#{sec_frac}".to_f

          Toby::Parser::OffsetDateTime.new(year, mon, day, hour, min, sec, offset.to_s)
        end
      end

      # @see https://toml.io/en/v1.0.0-rc.3#local-date-time
      module LocalDateTime
        def value
          year, mon, day = captures[:date_skeleton].first.value
          hour, min, sec, sec_frac = captures[:time_skeleton].first.value
          usec = sec_frac.to_s.ljust(6, '0')

          Toby::LocalDateTime.local(year, mon, day, hour, min, sec, usec)
        end
      end

      # @see https://toml.io/en/v1.0.0-rc.3#local-date
      module LocalDate
        def value
          year, mon, day = captures[:date_skeleton].first.value
          Toby::Parser::LocalDate.local(year, mon, day)
        end
      end

      # @see https://toml.io/en/v1.0.0-rc.3#local-time
      module LocalTime
        def value
          hour, min, sec, sec_frac = captures[:time_skeleton].first.value
          usec = sec_frac.to_s.ljust(6, '0')

          Toby::Parser::LocalTime.at(3600 * hour.to_i + 60 * min.to_i + sec.to_i, usec.to_i)
        end
      end
    end
  end
end
