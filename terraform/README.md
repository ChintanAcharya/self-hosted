# Terraform Configuration

- Create a Reserved IP from DigitalOcean console: https://cloud.digitalocean.com/networking/reserved_ips
- Populate the `secrets.hcl` file using `secrets.hcl.sample`

## Building the Packer image

- `cd images`
- `packer init`
- `packer build reverse-proxy.packer.hcl --var-file=../secrets.hcl`

## Creating the Droplet

- `cd instances`
- `terraform init`
- `terraform plan --var-file=../secrets.hcl`
- `terraform apply --var-file=../secrets.hcl`
