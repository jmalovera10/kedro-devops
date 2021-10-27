provider "google" {
  # TODO: replace this name with placeholder
  project     = "the-name-of-your-project"
  region      = "us-east1"
  zone        = "us-east1-b"
  credentials = file("credentials.json")
}