data "google_service_account" "default_compute_sa" {
  account_id = "114141047980381842642"
}

resource "google_compute_instance" "worker" {
  name                      = "worker"
  machine_type              = "e2-micro"
  allow_stopping_for_update = true

  tags = ["fliipa-backend", "web-application"]

  boot_disk {
    initialize_params {
      size  = 20
      image = "cos-cloud/cos-89-lts"
    }
  }

  network_interface {
    network = data.google_compute_network.default.name

    access_config {
    }
  }

  metadata = {
    gce-container-declaration = <<EOT
    kind: Deployment
    metadata:
      name: backend-pod
      labels:
        tier: backend
    spec:
      containers:
        - name: backend-service
          image: ${var.docker_worker_image_digest}
          stdin: false
          restartPolicy: Always
    EOT
  }

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = data.google_service_account.default_compute_sa.email
    scopes = ["cloud-platform"]
  }
}