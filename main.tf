resource "aws_db_event_subscription" "default" {
  count = var.aws_sns_topic_arn != "" ? 1 : 0

  name_prefix = "rds-event-sub"
  sns_topic   = var.aws_sns_topic_arn

  source_type = "db-instance"
  source_ids  = var.db_instance_ids

  event_categories = [
    "failure",
  ]
}
