gitrepos:
  - name: www-data
    user: www-data
    group: users
    user_home: /srv/www
    postreceive:
      - type: ruby
        target: /srv/www/one.uppercase.no
    deployers:
      - id: oc
  - name: two
    user: www-data
    group: www-data
    user_home: /srv/www
    postreceive:
      - type: ruby
        target: /srv/www/two.uppercase.no
    deployers:
      - id: oc