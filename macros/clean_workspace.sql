{# 
Adapted from https://github.com/randypitcherii/dbt_workspace/blob/production/dbt/macros/snowflake_utils/cleanup/clean_workspace.sql
#}

{% macro clean_workspace(database=target.database, dry_run=True, schema_like=None, schema_not_like=None) %}

    {%- set msg -%}
        Starting clean_workspace...
          adapter:         {{ target.type }}
          {%- if target.database %}
          database:        {{ database }} 
          {%- endif %}
          dry_run:         {{ dry_run }} 
          {%- if schema_like %}
          schema_like:     {{ schema_like }} 
          {%- endif %}
          {%- if schema_not_like %}
          schema_not_like: {{ schema_not_like }} 
          {%- endif %}
    {%- endset -%}

    {% do log(msg, info=True) %}

    {{ return(adapter.dispatch('clean_workspace', 'dbt_helpers')(database, dry_run, schema_like, schema_not_like)) }}

{% endmacro %}

{% macro databricks__clean_workspace(database, dry_run, schema_like, schema_not_like) %}

    {%- set query -%}
        show schemas 
        {%- if schema_like %}
        like '{{ schema_like }}'
        {%- endif -%}
    {%- endset -%}

    {%- if execute -%}
        {%- set matching_schemas = run_query(query).columns[0].values() -%}
        {%- if matching_schemas | length > 0 -%}
            {%- for schema in matching_schemas -%}
                {%- if dry_run -%}
                    {%- do log('Found matching schema: ' ~ schema, True) -%}
                {%- else -%}
                    {% do log('Dropping schema: ' ~ schema, True) %}
                    {% set drop_query = 'drop schema ' ~ schema ~ ' cascade' %}
                    {% do run_query(drop_query) %}
                    {% do log('Dropped  schema: ' ~ schema, True) %}
                {%- endif -%}
            {%- endfor -%}
            {%- if dry_run -%}
                {%- set msg -%}
          Use the following dbt command to drop matching schemas:
          dbt run-operation clean_workspace --args '{"schema_like": "{{ schema_like }}", dry_run: False}'
                {%- endset -%}
                {% do log(msg, True) %}
            {%- endif -%}
        {%- else -%}
            {%- do log('No matching schemas found for pattern "' ~ schema_like ~ '"', True) -%}
        {%- endif -%}
    {%- endif -%}

{% endmacro %}

{% macro spark__clean_workspace(database, dry_run, schema_like, schema_not_like) %}
    {{ return(databricks__clean_workspace(database, dry_run, schema_like, schema_not_like)) }}
{% endmacro %}
