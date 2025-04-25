class CreateSolidQueueScheduledExecutions < ActiveRecord::Migration[7.1]
  def change
    create_table :solid_queue_scheduled_executions do |t|
      t.bigint   :job_id, null: false
      t.string   :queue_name, null: false
      t.integer  :priority, default: 0, null: false
      t.datetime :scheduled_at, null: false
      t.datetime :created_at, null: false
      t.index [:job_id], unique: true
      t.index [:scheduled_at, :priority, :job_id], name: "index_solid_queue_scheduled_executions_for_dispatch"
      t.index [:queue_name, :scheduled_at, :priority, :job_id], name: "index_solid_queue_scheduled_executions_for_polling"
    end
  end
end
