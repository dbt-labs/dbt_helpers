## dbt_helpers

### Installation

Add to your `packages.yml` file:

```yaml
# packages.yml
packages:
  - git: "https://github.com/dbt-labs/dbt_helpers"
    revision: 0.1
```

Run the following:

```
dbt deps
```

### Macros

`clean_workspace`

> Adapted from [dbt_workspace](https://github.com/randypitcherii/dbt_workspace/blob/production/dbt/macros/snowflake_utils/cleanup/clean_workspace.sql) to work on databricks.

```
dbt run-operation clean_workspace
```

#### Databricks / Spark

Uses the [`show schemas` syntax](https://docs.databricks.com/sql/language-manual/sql-ref-syntax-aux-show-schemas.html) to list schemas that match a regex pattern.

Args:

- `dry_run` (`bool`, default `True`):
  - Dry run flag. If `True`, will simply print out matching schemas. If `False`, will drop matching schemas.
- `schemas_like` (`string`, default `None`):
  - Case-insensitive regex pattern to search for. Note that with databricks, this is a regex, so to match a schema with the name `dbt_cloud_pr_123`, we would use the string `"dbt_cloud_pr*"` and not `"dbt_cloud_pr%"`.

Examples:

```
dbt run-operation clean_workspace --args '{schema_like: "dbt_cloud_pr*"}'
# Prints out schemas that match the regex pattern above - e.g. "dbt_cloud_pr_123", "dbt_cloud_pr_test_123".

dbt run-operation clean_workspace --args '{schema_like: "dbt_cloud_pr*", dry_run: False}'
# Drops schemas that match the regex pattern above.
```
