provider "google" {
  project     = "sumz-laboratorios"
  region      = "us-east1"
  zone        = "us-east1-b"
  credentials = file("credentials.json")
}
