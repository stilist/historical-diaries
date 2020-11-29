# frozen_string_literal: true

require_relative '../_lib/collections'
require 'jekyll'

module Jekyll
  module PersonFilters
    include ::DataCollection

    def person_name(key, default_text = nil)
      default_text || key
    end

    def person_tag(key, display_text = nil)
      return "<span class='data-person is-unknown-reference'>#{display_text}</span>" if !display_text.nil?

      combined = combine_person_name_parts(key) do |part|
        attributes = {
          itemprop: part['type'],
          itemid: part['id'],
        }.reject { |_, value| value.nil? }
         .map { |key, value| "#{key}=#{value}" }
         .join(' ')

        "<span #{attributes}>#{part['text']}</span>"
      end
      return "<span class='data-person is-unknown-reference'>#{key}</span>" if combined.nil?

      <<~EOM
      <span class="data-person" itemscope itemtype="http://schema.org/Person">
      #{combined}
      </span>
      EOM
    end

    private

    def person_name_parts(key)
      data_collection_entry('people', key)&.dig('name')
    end

    def combine_person_name_parts(key)
      parts = person_name_parts(key)
      if parts.nil?
        Jekyll.logger.info("Unable to find name data for '#{key}'")
        return
      end

      formatted = parts.map do |part|
        if block_given?
          yield(part)
        else
          part['text']
        end
      end

      joined = formatted.compact.join(' ')
      joined if joined != ''
    end
  end
end
Liquid::Template.register_filter(Jekyll::PersonFilters)
