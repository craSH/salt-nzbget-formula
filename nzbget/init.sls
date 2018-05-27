{%- from "nzbget/map.jinja" import nzbget with context -%}

nzbget_ppa_repo:
  pkgrepo.managed:
    - ppa: modriscoll/nzbget
    - require_in:
      - nzbget_package

nzbget_package:
  pkg.installed:
    - name: {{ nzbget.package }}
    - version: '{{ nzbget.release.version }}*'
