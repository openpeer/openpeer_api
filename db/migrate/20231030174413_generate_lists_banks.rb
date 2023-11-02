class GenerateListsBanks < ActiveRecord::Migration[7.0]
  def change
    List.find_each do |list|
      next unless list.bank.present?

      list.banks << list.bank
    end
  end
end
