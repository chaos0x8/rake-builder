gem 'bundler'

require 'bundler'
Bundler.require(:default, :test)

require_relative '../../lib/rake-builder'

describe 'c8' do
  describe 'erb' do
    it 'nothing to evaluate' do
      val = 42

      result = C8.erb({}) do
        "value = #{val}"
      end

      expect(result).to be == 'value = 42'
    end

    it 'evaluates simple template' do
      result = C8.erb val: 42 do
        'value = <%= val %>'
      end

      expect(result).to be == 'value = 42'
    end

    it 'evaluates complex template' do
      result = C8.erb val: 1..5 do
        <<~INLINE
          <%- val.each do |v| -%>
          <%= v * 10 %>
          <%- end -%>
        INLINE
      end

      expect(result).to be == <<~INLINE
        10
        20
        30
        40
        50
      INLINE
    end
  end
end
