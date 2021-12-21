# Reference to the default compute engine service account. Replace the placeholder
# with the of the compute engine default service account that you find in
# https://console.cloud.google.com/iam-admin/serviceaccounts?project=YOUR_GCP_PROJECT
data "google_service_account" "default_compute_sa" {
  account_id = "115465598842233646903"
}


resource "google_compute_instance" "kedro" {
  name                      = "kedro"
  machine_type              = "e2-micro"
  allow_stopping_for_update = true

  # Defintion of disk specifications
  boot_disk {
    initialize_params {
      size = 20
      # This type of image is specialized for containers and will help us run our 
      # kedro container
      image = "cos-cloud/cos-89-lts"
    }
  }

  network_interface {
    # Here we are referencing our network information from our network.tf file
    network = data.google_compute_network.default.name

    access_config {
    }
  }

  # The purpose of this script is to recreate the instance every time there are changes 
  # on our definition. It is a workaround to a synchronization issue that Terraform has 
  # with the GCP API.
  metadata_startup_script = <<EOT
  echo "Starting image ${var.docker_worker_image_digest}"
  EOT

  metadata = {
    # This multiline container declaration is structured as a Kubernetes YAML file.
    # The overall purpose is to create a single pod with the image we created and 
    # add a restart policy to respond to unexpected failures in the container.
    gce-container-declaration = <<EOT
    kind: Deployment
    metadata:
      name: kedro-pod
      labels:
        tier: kedro
    spec:
      containers:
        - name: kedro-service
          image: ${var.docker_worker_image_digest}
          stdin: false
          restartPolicy: Always
    EOT
  }

  # Here we are defining the service account that our instance will have in order
  # to access GCP APIs. By default, te instance will use the default compute service account
  service_account {
    # Google recommends custom service accounts that have cloud-platform scope 
    # and permissions granted via IAM Roles.
    email  = data.google_service_account.default_compute_sa.email
    scopes = ["cloud-platform"]
  }
}
