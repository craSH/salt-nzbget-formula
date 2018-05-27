{%- from "nzbget/map.jinja" import nzbget with context -%}

nzbget_ppa_repo:
  pkgrepo.managed:
    - ppa: modriscoll/nzbget
    - keyid: 0778B73662C73F57DB254490780F1E2D6CDE748F
    - keyserver: keyserver.ubuntu.com
    - require_in:
      - nzbget_package

nzbget_package:
  pkg.installed:
    - name: {{ nzbget.package }}
    - version: '{{ nzbget.release.version }}*'
