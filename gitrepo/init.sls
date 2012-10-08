{% for repo in pillar['gitrepos'] %}
{{ repo.user }}:
  user.present:
    - home: {{ repo.user_home }}
    - gid: {{ repo.group }}
{{ repo.user_home }}:
  file.directory:
    - user: {{ repo.user }}
    - group: {{ repo.group }}
    - mode: 750
    - makedirs: True
    - require:
      - user: {{ repo.user }}
{{ repo.user_home }}/.ssh:
  file.directory:
    - user: {{ repo.user }}
    - group: {{ repo.group }}
    - mode: 700
    - makedirs: True
    - require:
      - file: {{ repo.user_home }}
{% for deployer in repo.deployers %}
grant-repo-{{ repo.name }}-{{ deployer.id }}:
  ssh_auth:
    - present
    - user: {{ repo.user }}
    - source: salt://ssh-keys/{{ deployer.id }}.id_rsa.pub
    - require:
      - file: {{ repo.user_home }}/.ssh
{% endfor %}
/var/git/{{ repo.name }}:
  file.directory:
    - name: /var/git/{{ repo.name }}.git
    - user: {{ repo.user }}
    - group: {{ repo.user }}
    - mode: 750
    - makedirs: True
    - require:
      - user: {{ repo.user }}
git-init-{{ repo.name }}:
  cmd.run:
    - name: git init --bare /var/git/{{ repo.name }}.git
    - unless: ls /var/git/{{ repo.name }}.git/config
    - user: {{ repo.user }}
    - group: {{ repo.user }}
    - cwd: {{ repo.user_home }}
    - shell: /bin/bash
    - require:
      - file: /var/git/{{ repo.name }}.git
{% for postreceive in repo.postreceive %}
/var/git/{{ repo.name }}.git/hooks/post-receive:
  file.managed:
    - source: salt://gitrepo/hooks/{{ postreceive.type }}-post-receive.jinja
    - template: jinja
    - user: {{ repo.user }}
    - group: {{ repo.group }}
    - mode: 750
    - defaults:
      type: {{ postreceive.target or 'ruby' }}
      target: {{ postreceive.target }}
    - require:
      - cmd: git-init-{{ repo.name }}
{% endfor %}
{% endfor %}