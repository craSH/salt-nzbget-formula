{%- from "nzbget/map.jinja" import nzbget with context -%}

{%- set main_dir = salt['pillar.get']('nzbget:config:main_dir',
                                      nzbget.data_dir) -%}
{%- set scripts_dir = salt['pillar.get']('nzbget:config:script_dir',
                                         main_dir ~ '/scripts') -%}
{%- set scripts = salt['pillar.get']('nzbget:scripts', []) -%}

include:
  - nzbget

nzbget_config_dir:
  file.directory:
    - name: {{ nzbget.config_dir }}

nzbget_config_file:
  file.managed:
    - name: {{ nzbget.config_file }}
    - source: salt://nzbget/files/nzbget.conf.jinja
    - template: jinja
    - require:
      - file: nzbget_config_dir

{% if scripts -%}
nzbget_scripts_dir:
  file.directory:
    - name: {{ scripts_dir }}

{% for script in scripts %}
nzbget_script_{{ script }}:
  file.managed:
    - name: {{ scripts_dir }}/{{ script }}
    - source: salt://nzbget/files/scripts/{{ script }}
    - mode: 755
    - require:
      - file: nzbget_scripts_dir
{% endfor %}
{%- endif %}
