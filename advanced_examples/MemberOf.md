# Examples of MemberOf configuration

## Enable MemberOf 

Use the following values to enable `memberof` attribute:

This configuration works regardless of the `replication` configuration (`enabled` or `disabled`)

```
# Default configuration for openldap as environment variables. These get injected directly in the container.
# Use the env variables from https://github.com/osixia/docker-openldap#beginner-guide
env:
 BITNAMI_DEBUG: "true"
 LDAP_LOGLEVEL: "256"
 LDAP_TLS_ENFORCE: "false"
 LDAPTLS_REQCERT: "never"
 LDAP_ENABLE_TLS: "yes"
 LDAP_CONFIG_ADMIN_ENABLED: "yes"
 LDAP_SKIP_DEFAULT_TREE: "no"

customLdifFiles:
  00-root.ldif: |-
    # Root creation
    dn: dc=example,dc=org
    objectClass: dcObject
    objectClass: organization
    o: Example, Inc
  01-default-user.ldif: |-
    dn: cn=Jean Dupond,dc=example,dc=org
    cn: Jean Dupond
    gidnumber: 500
    givenname: Jean
    homedirectory: /home/users/jdupond
    objectclass: inetOrgPerson
    objectclass: posixAccount
    objectclass: top
    sn: Dupond
    uid: jdupond
    uidnumber: 1000
    userpassword: {MD5}KOULhzfBhPTq9k7a9XfCGw==
  02-default-group.ldif: |-
    dn: cn=myGroup,dc=example,dc=org
    cn: myGroup
    gidnumber: 500
    objectclass: posixGroup
    objectclass: top
    add: memberUid
    memberUid: jdupond    
  03-test-memberof.ldif: |-
    dn: ou=Group,dc=example,dc=org
    objectclass: organizationalUnit
    ou: Group

    dn: ou=People,dc=example,dc=org
    objectclass: organizationalUnit
    ou: People

    dn: uid=test1,ou=People,dc=example,dc=org
    objectclass: account
    uid: test1

    dn: cn=testgroup,ou=Group,dc=example,dc=org
    objectclass: groupOfNames
    cn: testgroup
    member: uid=test1,ou=People,dc=example,dc=org
customSchemaFiles:
  #enable memberOf ldap search functionality, users automagically track groups they belong to
  00-memberof.ldif: |-
    # Load memberof module
    dn: cn=module,cn=config
    cn: module
    objectClass: olcModuleList
    olcModuleLoad: memberof
    olcModulePath: /opt/bitnami/openldap/lib/openldap

  01-memberof.ldif: |-
    dn: olcOverlay=memberof,olcDatabase={2}mdb,cn=config
    changetype: add
    objectClass: olcOverlayConfig
    objectClass: olcMemberOf
    olcOverlay: memberof
    olcMemberOfRefint: TRUE
```

Connect to your openldap instance and execute:

```
LDAPTLS_REQCERT=never ldapsearch -x -D 'cn=admin,dc=example,dc=org' -w Not@SecurePassw0rd -H ldaps://127.0.0.1:1636 -b 'dc=example,dc=org' "(memberOf=cn=testgroup,ou=Group,dc=example,dc=org)"
```
You should get the following result: 
```
# extended LDIF
#
# LDAPv3
# base <dc=example,dc=org> with scope subtree
# filter: (memberOf=cn=testgroup,ou=Group,dc=example,dc=org)
# requesting: ALL
#

# test1, People, example.org
dn: uid=test1,ou=People,dc=example,dc=org
objectClass: account
uid: test1

# search result
search: 2
result: 0 Success

# numResponses: 2
# numEntries: 1
```