{%- from "nzbget/map.jinja" import nzbget with context -%}
{%- set config = salt['pillar.get']('nzbget:config', {}) -%}
{%- set secure_cert = config.get('secure_cert', '') -%}
{%- set secure_key = config.get('secure_key', '') -%}
{%- set unpack_pass_file = config.get('unpack_pass_file', '') -%}

include:
  - nzbget
  - nzbget.config

nzbget-group:
  group.present:
    - name: {{ nzbget.group }}

nzbget-user:
  user.present:
    - name: {{ nzbget.user }}
    - groups:
      - {{ nzbget.group }}
    - home: {{ nzbget.data_dir }}
    - createhome: False
    - shell: /usr/sbin/nologin
    - system: True
    - require:
      - group: nzbget-group

nzbget-data-dir:
  file.directory:
    - name: {{ nzbget.data_dir }}
    - user: {{ nzbget.user }}
    - group: {{ nzbget.group }}
    - require:
      - user: nzbget-user

nzbget-log-dir:
  file.directory:
    - name: {{ nzbget.log_dir }}
    - user: {{ nzbget.user }}
    - group: {{ nzbget.group }}
    - require:
      - user: nzbget-user

nzbget-secure-dir:
  file.directory:
    - name: {{ nzbget.secure_dir }}
    - user: {{ nzbget.user }}
    - group: {{ nzbget.group }}
    - mode: 0700
    - require:
      - user: nzbget-user

{% if secure_cert %}
nzbget-secure-cert:
  file.managed:
    - name: {{ nzbget.secure_dir ~ 'secure.cert'}}
    - contents_pillar: secure_cert
    - user: {{ nzbget.user }}
    - group: {{ nzbget.group }}
    - mode: 0400
    - require:
      - file: nzbget-secure-dir
{% endif %}

{% if secure_key %}
nzbget-secure-key:
  file.managed:
    - name: {{ nzbget.secure_dir ~ 'secure.key' }}
    - contents_pillar: secure_key
    - user: {{ nzbget.user }}
    - group: {{ nzbget.group }}
    - mode: 0400
    - require:
      - file: nzbget-secure-dir
{% endif %}

{% if unpack_pass_file %}
nzbget-secure-pass-file:
  file.managed:
    - name: {{ nzbget.secure_dir ~ 'passwds'}}
    - contents_pillar: unpack_pass_file
    - user: {{ nzbget.user }}
    - group: {{ nzbget.group }}
    - mode: 0400
    - require:
      - file: nzbget-secure-dir
{% endif %}    

nzbget-service-file:
  file.managed:
    - name: /etc/systemd/system/{{ nzbget.service }}.service
    - source: salt://nzbget/files/nzbget.systemd.jinja
    - template: jinja

nzbget-service:
  service.running:
    - name: {{ nzbget.service }}
    - enable: True
    - require:
      - file: nzbget-service-file
      - file: nzbget-config-file
      - file: nzbget-data-dir
      - file: nzbget-log-dir

nzbget-restart:
  module.wait:
    - name: service.restart
    - m_name: {{ nzbget.service }}
    - require:
      - service: nzbget-service
    - watch:
      - file: nzbget-config-file
