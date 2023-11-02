class PaymentMethod < ApplicationRecord
  belongs_to :user
  belongs_to :bank
  has_many :lists

  validate :validate_bank_schema

  def validate_bank_schema
    return unless bank.present?

    bank_schema = bank.account_info_schema
    payment_method_values = values || {}

    # Check if all required fields are present
    bank_schema.each do |field|
      if field['required'] && payment_method_values[field['id']].blank?
        errors.add(field['id'].to_sym, 'should be present')
      end
    end

    # Check if there are extra values in payment method that are not in bank schema
    payment_method_values.each_key do |field|
      unless bank_schema.find { |f| f['id'] == field }.present?
        errors.add(field['id'].to_sym, 'is not a valid field')
      end
    end
  end
end
