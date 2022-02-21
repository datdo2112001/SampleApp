require "csv"

class ExportCsvService
  def initialize objects, attributes, type
    @attributes = attributes
    @objects = objects
    if (type == 1) 
      @header = attributes.map { |attr| I18n.t("header_csv_1.#{attr}") }
    elsif (type == 2)
      @header = attributes.map { |attr| I18n.t("header_csv_2.#{attr}") }
    elsif (type == 3)
      @header = attributes.map { |attr| I18n.t("header_csv_3.#{attr}") }
    end
  end

  def perform
    CSV.generate do |csv|
      csv << header
      objects.each do |object|
        csv << attributes.map{ |attr| object.public_send(attr) }
      end
    end
  end

  private
  attr_reader :attributes, :objects, :header
end