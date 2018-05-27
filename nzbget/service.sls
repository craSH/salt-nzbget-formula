{%- from "nzbget/map.jinja" import nzbget with context -%}
{%- set config = salt['pillar.get']('nzbget:config', {}) -%}
{%- set secure_cert = config.get('secure_cert', '') -%}
{%- set secure_key = config.get('secure_key', '') -%}
{%- set unpack_pass_file = config.get('unpack_pass_file', '') -%}

include:
  - nzbget
  - nzbget.config

nzbget_group:
  group.present:
    - name: {{ nzbget.group }}

nzbget_user:
  user.present:
    - name: {{ nzbget.user }}
    - groups:
      - {{ nzbget.group }}
    - home: {{ nzbget.data_dir }}
    - createhome: False
    - shell: /usr/sbin/nologin
    - system: True
    - require:
      - group: nzbget_group

nzbget_data_dir:
  file.directory:
    - name: {{ nzbget.data_dir }}
    - user: {{ nzbget.user }}
    - group: {{ nzbget.group }}
    - require:
      - user: nzbget_user

nzbget_log_dir:
  file.directory:
    - name: {{ nzbget.log_dir }}
    - user: {{ nzbget.user }}
    - group: {{ nzbget.group }}
    - require:
      - user: nzbget_user

nzbget_secure_dir:
  file.directory:
    - name: {{ nzbget.secure_dir }}
    - user: {{ nzbget.user }}
    - group: {{ nzbget.group }}
    - mode: 0700
    - require:
      - user: nzbget_user

{% if secure_cert %}
nzbget_secure_cert:
  file.managed:
    - name: {{ nzbget.secure_dir ~ '/' ~ 'secure.cert'}}
    - contents_pillar: nzbget:config:secure_cert
    - user: {{ nzbget.user }}
    - group: {{ nzbget.group }}
    - mode: 0400
    - require:
      - file: nzbget_secure_dir
{% endif %}

{% if secure_key %}
nzbget_secure_key:
  file.managed:
    - name: {{ nzbget.secure_dir ~ '/' ~ 'secure.key' }}
    - contents_pillar: nzbget:config:secure_key
    - user: {{ nzbget.user }}
    - group: {{ nzbget.group }}
    - mode: 0400
    - require:
      - file: nzbget_secure_dir
{% endif %}

{% if unpack_pass_file %}
nzbget_secure_pass_file:
  file.managed:
    - name: {{ nzbget.secure_dir ~ '/' ~ 'passwds'}}
    - contents_pillar: nzbget:config:unpack_pass_file
    - user: {{ nzbget.user }}
    - group: {{ nzbget.group }}
    - mode: 0400
    - require:
      - file: nzbget_secure_dir
{% endif %}

nzbget_service_file:
  file.managed:
    - name: /etc/systemd/system/{{ nzbget.service }}.service
    - source: salt://nzbget/files/nzbget.systemd.jinja
    - template: jinja

nzbget_service:
  service.running:
    - name: {{ nzbget.service }}
    - enable: True
    - require:
      - file: nzbget_service_file
      - file: nzbget_config_file
      - file: nzbget_data_dir
      - file: nzbget_log_dir

nzbget_restart:
  module.wait:
    - name: service.restart
    - m_name: {{ nzbget.service }}
    - require:
      - service: nzbget_service
    - watch:
      - file: nzbget_config_file
