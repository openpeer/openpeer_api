class ChangeContractsVersions < ActiveRecord::Migration[7.0]
  def change
    Contract.where(version: "2").update_all(version: "3")
    Setting["contract_version"] = "3"
  end
end
