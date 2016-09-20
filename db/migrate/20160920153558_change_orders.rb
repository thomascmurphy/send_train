class ChangeOrders < ActiveRecord::Migration
  def change
    rename_column :exercise_metric_options, :order, :order_in_metric
    rename_column :exercise_metrics, :order, :order_in_exercise
  end
end
