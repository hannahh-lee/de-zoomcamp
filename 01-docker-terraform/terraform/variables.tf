variable "credentials" {
  description = "My Credentials"
  default     = "/Users/hannahlee/terrarunner/keys/my-credentials.json"
}

variable "project" {
  description = "Project"
  default     = "abiding-kingdom-447001-e7"
}

variable "region" {
  description = "Region"
  #Update the below to your desired region
  default     = "us-east1"
}

variable "location" {
  description = "Project Location"
  #Update the below to your desired location
  default     = "US"
}

variable "bq_dataset_name" {
  description = "My BigQuery Dataset Name"
  #Update the below to what you want your dataset to be called
  default     = "taxi_dataset"
}

variable "gcs_bucket_name" {
  description = "My Storage Bucket Name"
  #Update the below to a unique bucket name
  default     = "abiding-kingdom-447001-e7-taxidata-bucket"
}

variable "gcs_storage_class" {
  description = "Bucket Storage Class"
  default     = "STANDARD"
}