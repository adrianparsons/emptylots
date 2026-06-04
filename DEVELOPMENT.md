# Development

## Data

Requirements:

- Google cloud creds (contact maintainer)

- Google cloud [CLI](https://docs.cloud.google.com/sdk/docs/install-sdk)

- [dbt core](https://docs.getdbt.com/docs/local/install-dbt?version=2.0&name=Fusion#dbt-core) with the bigquery adapter


### Creating a dbt "development" dataset:

Add a "dev" target to `~/.dbt/profiles.yml`. Specify a dataset with a name like `yourname_dev` (this will be created automatically)

`profiles.yml` can define a default target, or you can specify a target when running dbt. For example: `dbt run --target=dev`

Example `profiles.yaml`:
```
empty_lots:
  outputs:
    dev:
      dataset: amp_dev
      location: us-east4
      keyfile: /path/to/sa-private-key.json
      method: service-account
      priority: interactive
      project: empty-lots
      threads: 1
      type: bigquery
    prod:
      dataset: nyc_pluto_historical
      location: us-east4
      keyfile: /path/to/sa-private-key.json
      method: service-account
      project: empty-lots
      threads: 1
      type: bigquery
  target: dev
```

## Build/Infrastructure

Pull Requests trigger branch-specific builds including a publicly accessible preview, so testing may not require building the project locally.

[Docker](https://www.docker.com/products/docker-desktop/) (or other container manager) is used by multiple `Makefile` targets.

Infrastructure is primarily on GCP and managed by [terraform](https://developer.hashicorp.com/terraform/install).

Contact the maintainer for terraform state access and for private variables. Private keys and variable names live in `terraform/terraform.tfvars`.

## Frontend

Google Streetview requires an API key to work locally (contact maintainer for this). The key is pulled from `.env.development`
