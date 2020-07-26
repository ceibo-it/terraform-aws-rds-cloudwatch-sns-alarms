# terraform-aws-rds-cloudwatch-sns-alarms

Terraform module that configures important RDS alerts using CloudWatch and sends them to the chosen SNS topic.

Create a set of sane RDS CloudWatch alerts for monitoring the health of an RDS instance.

## Usage


| area    | metric           | comparison operator  | threshold | rationale                                                                                                                                                                                              |
|---------|------------------|----------------------|-----------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Storage | BurstBalance     | `<`                  | 20 %      | 20 % of credits allow you to burst for a few minutes which gives you enough time to a) fix the inefficiency, b) add capacity or c) switch to io1 storage type.                                         |
| Storage | DiskQueueDepth   | `>`                  | 64        | This number is calculated from our experience with RDS workloads.                                                                                                                                      |
| Storage | FreeStorageSpace | `<`                  | 2 GB      | 2 GB usually provides enough time to a) fix why so much space is consumed or b) add capacity. You can also modify this value to 10% of your database capacity.                                         |
| CPU     | CPUUtilization   | `>`                  | 80 %      | Queuing theory tells us the latency increases exponentially with utilization. In practice, we see higher latency when utilization exceeds 80% and unacceptable high latency with utilization above 90% |
| CPU     | CPUCreditBalance | `<`                  | 20        | One credit equals 1 minute of 100% usage of a vCPU. 20 credits should give you enough time to a) fix the inefficiency, b) add capacity or c) don't use t2 type.                                        |
| Memory  | FreeableMemory   | `<`                  | 64 MB     | This number is calculated from our experience with RDS workloads.                                                                                                                                      |
| Memory  | SwapUsage        | `>`                  | 256 MB    | Sometimes you can not entirely avoid swapping. But once the database accesses paged memory, it will slow down.                                                                                         |

The module will also alert on `failure` type events. See https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_Events.html for a list of events.



## Examples


See the [`examples/`](examples/) directory for working examples.

```hcl
resource "aws_db_instance" "default" {
  allocated_storage    = 10
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  identifier_prefix    = "rds-server-example"
  name                 = "mydb"
  username             = "foo"
  password             = "foobarbaz"
  parameter_group_name = "default.mysql5.7"
  apply_immediately    = "true"
  skip_final_snapshot  = "true"
}

module "rds_alarms" {
  source         = "git::https://github.com/ceibo-it/terraform-aws-rds-cloudwatch-sns-alarms.git?ref=tags/0.0.1"
  db_instance_ids = [aws_db_instance.default.id]
  aws_sns_topic_arn = aws_sns_topic.default.arn
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| db_instance_ids | The instance IDs of the RDS database instance that you want to monitor. | list | - | yes |
| aws_sns_topic_arn | ARN of SNS topic to use. | string | - | yes |
| name_prefix | Alarm name prefix for each alarm. | string | `` | no |
| period | The threshold is analyzed over the last X seconds, where X is alarm_period | string | `600` | no |
| evaluation_periods | The number of periods over which data is compared to the specified threshold. | string | `1` | no |
| burst_balance_threshold | The minimum percent of General Purpose SSD (gp2) burst-bucket I/O credits available. | string | `20` | no |
| cpu_credit_balance_threshold | The minimum number of CPU credits (t2 instances only) available. | string | `20` | no |
| cpu_utilization_threshold | The maximum percentage of CPU utilization. | string | `80` | no |
| disk_queue_depth_threshold | The maximum number of outstanding IOs (read/write requests) waiting to access the disk. | string | `64` | no |
| free_storage_space_threshold | The minimum amount of available storage space in Byte. | string | `2000000000` | no |
| freeable_memory_threshold | The minimum amount of available random access memory in Byte. | string | `64000000` | no |
| swap_usage_threshold | The maximum amount of swap space used on the DB instance in Byte. | string | `256000000` | no |

## Copyright

Copyright © 2020 [Ceibo IT](https://ceibo.it/copyright)

## License 

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) 

See [LICENSE](LICENSE) for full details.

    Licensed to the Apache Software Foundation (ASF) under one
    or more contributor license agreements.  See the NOTICE file
    distributed with this work for additional information
    regarding copyright ownership.  The ASF licenses this file
    to you under the Apache License, Version 2.0 (the
    "License"); you may not use this file except in compliance
    with the License.  You may obtain a copy of the License at

      https://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing,
    software distributed under the License is distributed on an
    "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
    KIND, either express or implied.  See the License for the
    specific language governing permissions and limitations
    under the License.


## Trademarks

All other trademarks referenced herein are the property of their respective owners.

## NOTICE

terraform-aws-rds-cloudwatch-sns-alarms
Copyright 2020 Ceibo


This product includes software developed by
Cloud Posse, LLC (c) (https://cloudposse.com/)
Licensed under Apache License, Version 2.0
Copyright © 2017-2019 Cloud Posse, LLC