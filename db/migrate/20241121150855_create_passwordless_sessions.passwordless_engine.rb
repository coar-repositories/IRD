# frozen_string_literal: true

# This migration comes from passwordless_engine (originally 20171104221735)
class CreatePasswordlessSessions < ActiveRecord::Migration[6.0]
  def change
    create_table(:passwordless_sessions) do |t|
      t.belongs_to(
        :authenticatable,
        type: :string,
        polymorphic: true,
        index: {name: "authenticatable"}
      )

      t.datetime(:timeout_at, null: false)
      t.datetime(:expires_at, null: false)
      t.datetime(:claimed_at)
      t.string(:token_digest, null: false)
      t.string(:identifier, null: false, index: {unique: true}, length: 36)

      t.timestamps
    end
  end
end
