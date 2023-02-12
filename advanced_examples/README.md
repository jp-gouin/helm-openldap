# Examples of advanced configurations

You will find here some examples of advanced configurations.


## Use your own logos
To use your own logos for password portal and phpmyadmin, first create a configmap with your logos.  
For instance, a configmap with 2 keys:  
- my-logo.png: logo with size for instance 450x128 pixels
- my-logo_50.png: smaller logo, for instance 180x50 pixels

Next, configure your values so that your logos are installed in the containers:
```yaml
ltb-passwd:
   initContainers:
     - name: install-logo
       image: "{{ tpl .Values.image.repository . }}:{{ tpl .Values.image.tag . }}"
       command: [sh, -c]
       args:
         - |-
           cat <<EOF >/data/31-logo
           #!/command/with-contenv bash
           source /assets/functions/00-container
           PROCESS_NAME="logo"
           cp /tmp/ltb-logo.png /www/ssp/images/ltb-logo.png
           chmod +x /data/31-logo
           liftoff
           EOF
       volumeMounts:
         - name: data
           mountPath: /data
  volumes:
    - name: logos
      configMap:
        name: logos
    - name: data
      emptyDir: {}
  volumeMounts:
    - name: logos
      mountPath: /tmp/ltb-logo.png
      subPath: my-logo.png
    - name: data
      mountPath: /etc/cont-init.d/31-logo
      subPath: 31-logo

phpldapadmin:
  initContainers:
     - name: modify-configuration
       image: "{{ tpl .Values.image.repository . }}:{{ tpl .Values.image.tag . }}"
       command: [sh, -c]
       args:
         - |-
           # modify startup script in order to use logos
           cp -p /container/service/phpldapadmin/startup.sh /data/
           sed -i -e 's/exit 0/# exit 0/' /data/startup.sh
           cat <<'EOF' >>/data/startup.sh
           cp /logos/my-logo.png /var/www/phpldapadmin/htdocs/images/default/logo.png
           cp /logos/my-logo_50.png /var/www/phpldapadmin/htdocs/images/default/logo-small.png
           exit 0
           EOF
       volumeMounts:
         - mountPath: /data
           name: data
  volumes:
    - name: data
      emptyDir: {}
    - name: logos
      configMap:
        name: logos
  volumeMounts:
    - name: data
      mountPath: /data
    - name: logos
      mountPath: /logos
    - name: data
      mountPath: /container/service/phpldapadmin/startup.sh
      subPath: startup.sh
```

## Use a user with restricted permissions for password portal
By default ```cn=admin``` account is used by the password portal to retrieve the users.  
We will define here a user with restricted permissions (only read-only on attributes except passwords).  
His password is set in a separated secret (allowing vault solutions).  
For that, we need to define a custom ldif and custom acls.  
First, create a custom ldif file (or add it directly in the values file):
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-customldif
data:
  00-root.ldif: |-
    dn: dc=mydomain,dc=com
    objectClass: top
    objectClass: dcObject
    objectClass: organization
    o: MY-DOMAIN
    dc: mydomain
  01-admin-read-user.ldif: |-
    dn: cn=admin-read,dc=mydomain,dc=com
    cn: admin-read
    mail: admin-read@mydomain.com
    objectClass: inetOrgPerson
    objectClass: top
    userPassword:: {SSHA}xxxxxxxxxxxx
    sn: Admin read only
  02-users-group.ldif: |-
    dn: ou=users,dc=mydomain,dc=com
    ou: users
    objectClass: organizationalUnit
    objectClass: top
  03-foo-user.ldif: |-
    dn: cn=foo,ou=users,dc=mydomain,dc=com
    cn: foo
    objectClass: inetOrgPerson
    objectClass: top
    sn: Foo Foo
    mail: foo@mydomain.com
    userPassword:: {SSHA}xxxxxxxxx
```
Now create a secret for the passwords:
```yaml
kind: Secret
apiVersion: v1
metadata:
  name: openldap-secrets
type: Opaque
stringData:
  LDAP_ADMIN_PASSWORD: xxxxxxxx
  LDAP_CONFIG_ADMIN_PASSWORD: xxxxxxxx
  LDAP_ADMIN_READ_PASSWORD: xxxxxxxx
```

Next configure the values to use this secret, set the correct acls for ```admin-read``` and configure password portal to use this account:
```yaml
global:
  existingSecret: "openldap-secrets"

customAcls: |-
  dn: olcDatabase={2}mdb,cn=config
  changetype: modify
  replace: olcAccess
  olcAccess: {0}to *
    by dn.exact=gidNumber=0+uidNumber=1001,cn=peercred,cn=external,cn=auth manage
    by * break
  olcAccess: {1}to attrs=userPassword,shadowLastChange
    by self write
    by dn="cn=admin,dc=mydomain,dc=com" write
    by anonymous auth by * none
  olcAccess: {2}to *
    by dn="cn=admin-read,dc=mydomain,dc=com" read
    by dn="cn=admin,dc=mydomain,dc=com" write
    by self read
    by * none

ltb-passwd:
  ldap:
    searchBase: "ou=users,dc=mydomain,dc=com"
    bindDN: "cn=admin-read,dc=mydomain,dc=com"
    passKey: LDAP_ADMIN_READ_PASSWORD
```

## Allow login to phpldapadmin using only cn attribute
It is easier to login on phpldapadmin using only your cn attribute instead of cn=xxx,dc=xxx,dc=xxxx.  
At the same time, use the previous read only admin account to retrieve the user.  
Here is the values.yaml to use:
```yaml
phpldapadmin:
  initContainers:
     - name: modify-configuration
       image: "{{ tpl .Values.image.repository . }}:{{ tpl .Values.image.tag . }}"
       command: [sh, -c]
       args:
         - |-
           # adapt config.php: allow login without complete dn (only username) - needs admin read account
           # use also binddn with restricted permissions (read only)
           cat <<EOF >/data/my_config.php
           \$servers->setValue('login','attr','cn');
           \$servers->setValue('login','bind_id','cn=admin-read,dc=mydomain,dc=com');
           \$servers->setValue('login','bind_pass','${LDAP_ADMIN_READ_PASSWORD}');
           EOF
           # modify startup script in order to use modified config.php and logos
           cp -p /container/service/phpldapadmin/startup.sh /data/
           sed -i -e 's/exit 0/# exit 0/' /data/startup.sh
           cat <<'EOF' >>/data/startup.sh
           sed -i -e 's/\($servers->setValue..login.,.bind_id\)/#\1/' /var/www/phpldapadmin/config/config.php
           cat /data/my_config.php >> /var/www/phpldapadmin/config/config.php
           exit 0
           EOF
       volumeMounts:
         - mountPath: /data
           name: data
       env:
         - name: LDAP_ADMIN_READ_PASSWORD
           valueFrom:
             secretKeyRef:
               name: openldap-secrets
               key: LDAP_ADMIN_READ_PASSWORD
  volumes:
    - name: data
      emptyDir: {}
  volumeMounts:
    - name: data
      mountPath: /data
    - name: data
      mountPath: /container/service/phpldapadmin/startup.sh
      subPath: startup.sh
```

## Allow a user to have admin permissions
More tricky, we now authorize users to be administrator according to the value of the attribute ```employeeType```. If this attribute has a value of ```LDAP_ADMIN``` the user will be LDAP administrator.  
Using the previous ```my-customldif``` configmap just add the following line in the foo user section:
```yaml
    employeeType: LDAP_ADMIN
```
In long:
```yaml
  03-foo-user.ldif: |-
    dn: cn=foo,ou=users,dc=mydomain,dc=com
    cn: foo
    objectClass: inetOrgPerson
    objectClass: top
    sn: Foo Foo
    mail: foo@mydomain.com
    employeeType: LDAP_ADMIN
    userPassword:: {SSHA}xxxxxxxxx
```
Now modify the custom acls in the values file using the ```set``` feature:
```yaml
customAcls: |-
  dn: olcDatabase={2}mdb,cn=config
  changetype: modify
  replace: olcAccess
  olcAccess: {0}to *
    by dn.exact=gidNumber=0+uidNumber=1001,cn=peercred,cn=external,cn=auth manage
    by * break
  olcAccess: {1}to attrs=userPassword,shadowLastChange
    by self write
    by dn="cn=admin,dc=mydomain,dc=com" write
    by set="user/employeeType & [ldap_admin]" write
    by anonymous auth by * none
  olcAccess: {2}to *
    by dn="cn=admin-read,dc=mydomain,dc=com" read
    by dn="cn=admin,dc=mydomain,dc=com" write
    by set="user/employeeType & [ldap_admin]" write
    by self read
    by * none
```

Putting all together, the user ```foo``` can now login on phpldapadmin with only *foo* as username and his password, and with full permissions to manage the ldap database.

