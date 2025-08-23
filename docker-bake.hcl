# Image Args
variable "OCI_REGISTRY" { default = "docker.io" }
variable "OCI_REPOSITORY" { default = "dxcontainer/s6-overlay" }
variable "OCI_TAG" { default = "" }

variable "OCI_TITLE" { default = "s6-overlay" }
variable "OCI_DESCRIPTION" { default = "'s6-overlay' for DxContainer." }
variable "OCI_SOURCE" { default = "https://github.com/dxcontainer/s6-overlay.git" }
variable "OCI_LICENSE" { default = " GPL-3.0-or-later" }
variable "OCI_VENDOR" { default = "The DxContainer Authors." }

# Build Args
variable "ALPINE_VERSION" { default = "latest" }

variable "S6_OVERLAY_VERSION" { default = "3.2.1.0" }

group "default" {
    targets = [ "s6-overlay" ]
}

target "s6-overlay" {
    dockerfile = "s6-overlay.Dockerfile"
    
    # Arguments
    args = {
        "ALPINE_VERSION" = ALPINE_VERSION

        "S6_OVERLAY_VERSION" = S6_OVERLAY_VERSION
    }

    # Cache
    no-cache = true
    pull = true

    # Description
    description = OCI_DESCRIPTION
    
    # Tags
    tags = [ 
        "${OCI_REGISTRY}/${OCI_REPOSITORY}:latest",
        "${OCI_REGISTRY}/${OCI_REPOSITORY}:${S6_OVERLAY_VERSION}",
        notequal("", OCI_TAG) ? "${OCI_REGISTRY}/${OCI_REPOSITORY}:${OCI_TAG}" : ""
    ]

    # Metadata
    labels = {
        "org.opencontainers.image.title" = OCI_TITLE
        "org.opencontainers.image.description" = OCI_DESCRIPTION
        "org.opencontainers.image.source" = OCI_SOURCE
        "org.opencontainers.image.licenses" = OCI_LICENSE
        "org.opencontainers.image.vendor" = OCI_VENDOR
    }

    # Attestations
    attest = [ 
        "type=provenance,mode=max",
        "type=sbom",
    ]

    # Platforms
    platforms = [
        "linux/amd64",
        "linux/arm64"
    ]
}