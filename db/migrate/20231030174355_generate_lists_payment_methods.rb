class GenerateListsPaymentMethods < ActiveRecord::Migration[7.0]
  def change
    List.find_each do |list|
      next unless list.payment_method.present?

      list.payment_methods << list.payment_method
    end
  end
end
