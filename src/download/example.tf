terraform {
  required_providers {
    time = {
      source  = "hashicorp/time"
      version = "= 0.12.0"
    }
  }
}

provider "time" {}

resource "time_static" "example" {}

output "current_time" {
  value = time_static.example.rfc3339
}
