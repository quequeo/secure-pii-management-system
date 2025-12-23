require 'rails_helper'

RSpec.describe Sanitizable do
  let(:dummy_class) do
    Class.new(ActiveRecord::Base) do
      self.table_name = 'people'
      
      include Sanitizable
      
      sanitize_attributes :first_name, :last_name
      
      def self.name
        'DummyModel'
      end
    end
  end

  before do
    stub_request(:post, "http://localhost:8080/api/v1/ssn/validate")
      .to_return(status: 200, body: { valid: true }.to_json, headers: { 'Content-Type' => 'application/json' })
  end

  describe 'XSS attack prevention' do
    it 'strips HTML script tags' do
      record = dummy_class.new(first_name: '<script>alert("xss")</script>John')
      record.valid?
      expect(record.first_name).to eq('John')
    end

    it 'removes HTML tags from input' do
      record = dummy_class.new(first_name: '<b>Bold</b> Name')
      record.valid?
      expect(record.first_name).to eq('Bold Name')
    end

    it 'removes script tags with attributes' do
      record = dummy_class.new(first_name: '<script src="evil.js">alert("xss")</script>Test')
      record.valid?
      expect(record.first_name).to eq('Test')
    end

    it 'removes iframe tags' do
      record = dummy_class.new(first_name: '<iframe src="evil.com"></iframe>Name')
      record.valid?
      expect(record.first_name).to eq('Name')
    end

    it 'removes onclick event handlers' do
      record = dummy_class.new(first_name: '<div onclick="alert(\'xss\')">Click</div>')
      record.valid?
      expect(record.first_name).to eq('Click')
    end

    it 'removes onerror event handlers' do
      record = dummy_class.new(first_name: '<img src=x onerror="alert(\'xss\')">Name')
      record.valid?
      expect(record.first_name).to eq('Name')
    end

    it 'removes javascript protocol' do
      record = dummy_class.new(first_name: '<a href="javascript:alert(\'xss\')">Link</a>')
      record.valid?
      expect(record.first_name).to eq('Link')
    end

    it 'removes data URIs with scripts' do
      record = dummy_class.new(first_name: '<a href="data:text/html,<script>alert(\'xss\')</script>">Link</a>')
      record.valid?
      expect(record.first_name).to eq('Link')
    end
  end

  describe 'SQL injection prevention' do
    it 'escapes single quotes' do
      record = dummy_class.new(first_name: "O'Brien")
      record.valid?
      expect(record.first_name).to eq("O'Brien")
    end

    it 'removes SQL comments' do
      record = dummy_class.new(first_name: "Name -- DROP TABLE")
      record.valid?
      expect(record.first_name).to eq("Name -- DROP TABLE")
    end
  end

  describe 'whitespace normalization' do
    it 'trims leading whitespace' do
      record = dummy_class.new(first_name: '   John')
      record.valid?
      expect(record.first_name).to eq('John')
    end

    it 'trims trailing whitespace' do
      record = dummy_class.new(first_name: 'John   ')
      record.valid?
      expect(record.first_name).to eq('John')
    end

    it 'squishes multiple spaces' do
      record = dummy_class.new(first_name: 'John    Doe')
      record.valid?
      expect(record.first_name).to eq('John Doe')
    end

    it 'removes newlines and tabs' do
      record = dummy_class.new(first_name: "John\n\tDoe")
      record.valid?
      expect(record.first_name).to eq('John Doe')
    end
  end

  describe 'special characters' do
    it 'removes angle brackets' do
      record = dummy_class.new(first_name: 'Name < > Test')
      record.valid?
      expect(record.first_name).to eq('Name Test')
    end

    it 'preserves valid special characters' do
      record = dummy_class.new(first_name: "O'Brien-Smith")
      record.valid?
      expect(record.first_name).to eq("O'Brien-Smith")
    end

    it 'preserves accented characters' do
      record = dummy_class.new(first_name: 'José García')
      record.valid?
      expect(record.first_name).to eq('José García')
    end
  end

  describe 'edge cases' do
    it 'handles nil values' do
      record = dummy_class.new(first_name: nil)
      record.valid?
      expect(record.first_name).to be_nil
    end

    it 'handles empty strings' do
      record = dummy_class.new(first_name: '')
      record.valid?
      expect(record.first_name).to eq('')
    end

    it 'handles only whitespace' do
      record = dummy_class.new(first_name: '   ')
      record.send(:sanitize_text_fields)
      expect(record.first_name).to eq('')
    end

    it 'handles only HTML tags' do
      record = dummy_class.new(first_name: '<div></div>')
      record.valid?
      expect(record.first_name).to eq('')
    end
  end

  describe 'sanitizes all configured attributes' do
    it 'sanitizes first_name' do
      record = dummy_class.new(first_name: '<b>John</b>')
      record.valid?
      expect(record.first_name).to eq('John')
    end

    it 'sanitizes last_name' do
      record = dummy_class.new(last_name: '<i>Doe</i>')
      record.valid?
      expect(record.last_name).to eq('Doe')
    end

    it 'does not affect non-configured attributes' do
      record = dummy_class.new(middle_name: '<b>Middle</b>')
      record.valid?
      expect(record.middle_name).to eq('<b>Middle</b>')
    end
  end
end

