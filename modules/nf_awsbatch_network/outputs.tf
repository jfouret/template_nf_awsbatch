/*
   Copyright 2024 Julien FOURET

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/

output "subnet_ids_for_batch" {
  description = "List of subnet IDs for use with awsbatch"
  value       = var.network_type == "private" ? aws_subnet.private.*.id : aws_subnet.public.*.id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = aws_subnet.public.*.id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = aws_subnet.private.*.id
}

output "sg_id" {
  description = "The ID of the security group for ECS/AWS Batch"
  value       = aws_security_group.ecs_batch_sg.id
}


