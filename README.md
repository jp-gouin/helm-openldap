[![build](https://github.com/jp-gouin/helm-openldap/actions/workflows/ci.yml/badge.svg?branch=master)](https://github.com/jp-gouin/helm-openldap/actions/workflows/ci.yml)
[![Artifact HUB](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/helm-openldap)](https://artifacthub.io/packages/search?repo=helm-openldap)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://github.com/apache/apisix/blob/master/LICENSE)
![Version](https://img.shields.io/static/v1?label=Openldap&message=2.6.3&color=blue)

# OpenLDAP Helm Chart
## Disclaimer
This version now use the [Bitnami Openldap](https://hub.docker.com/r/bitnami/openldap) container image.

More detail on the container image can be found [here](https://github.com/bitnami/containers/tree/main/bitnami/openldap)

There are some major changes between the Osixia version and the Bitnami version , ergo the major gap of the chart version.

- Upgrade may not work fine between `3.x` and `4.x`
- Ldap and Ldaps port are non privileged ports (`1389` and `1636`) internally but are exposed through `global.ldapPort` and `global.sslLdapPort` (389 and 636)
- Replication is now purely setup by configuration. Extra schemas are loaded using `LDAP_EXTRA_SCHEMAS: "cosine,inetorgperson,nis,syncprov,serverid,csyncprov,rep,bsyncprov,brep,acls`. You can add your own schemas via the `customSchemaFiles` option.

A default tree (Root organisation, users and group) is created during startup, this can be skipped using `LDAP_SKIP_DEFAULT_TREE` , however you need to use `customLdifFiles` or `customLdifCm` to create a root organisation.

- This will be improved in a future update.

## Prerequisites Details
* Kubernetes 1.8+
* PV support on the underlying infrastructure

## Chart Details
This chart will do the following:

* Instantiate 3 instances of OpenLDAP server with multi-master replication
* A phpldapadmin to administrate the OpenLDAP server
* ltb-passwd for self service password

## TL;DR

To install the chart with the release name `my-release`:

```bash
$ helm repo add helm-openldap https://jp-gouin.github.io/helm-openldap/
$ helm install my-release helm-openldap/openldap-stack-ha
```



## Configuration

We use the container images provided by https://github.com/bitnami/containers/tree/main/bitnami/openldap. The container image is highly configurable and well documented. Please consult to documentation of the image for more information.

The following table lists the configurable parameters of the openldap chart and their default values.

### Global section

Global parameters to configure the deployment of the application.

| Parameter                          | Description                                                                                                                               | Default             |
| ---------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------- | ------------------- |
| `global.imageRegistry`                     | Global image registry                                                                                                                        | `""`                 |
| `global.imagePullSecrets`                     | Global list of imagePullSecrets                                                                                                                        | `[]`                 |
| `global.ldapDomain`                     | Domain LDAP can be explicit `dc=example,dc=org` or domain based `example.org`                                                                                                                         | `example.org`                 |
| `global.existingSecret`                     | Use existing secret for credentials - the expected keys are LDAP_ADMIN_PASSWORD and LDAP_CONFIG_ADMIN_PASSWORD                                         | `""`                |
| `global.adminPassword`                     | Administration password of Openldap                                                                                                                        | `Not@SecurePassw0rd`                 |
| `global.configPassword`                     | Configuration password of Openldap                                                                                                                        | `Not@SecurePassw0rd`                 |
| `global.ldapPort`                     | Ldap port                                                                                                                         | `389`                 |
| `global.sslLdapPort`                     | Ldaps port                                                                                                                         | `636`                 |

### Application parameters

Parameters related to the configuration of the application.

| Parameter                          | Description                                                                                                                               | Default             |
| ---------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------- | ------------------- |
| `replicaCount`                     | Number of replicas                                                                                                                        | `3`                 |
| `users`          | User list to create (comma separated list) , can't be use with customLdifFiles | "" |
| `userPasswords`          | User password to create (comma seprated list)  | "" |
| `group`          | Group to create and add list of user above | "" |
| `env`                              | List of key value pairs as env variables to be sent to the docker image. See https://github.com/bitnami/containers/tree/main/bitnami/openldap for available ones | `[see values.yaml]` |
| `customTLS.enabled`                      | Set to enable TLS/LDAPS with custom certificate - should also set `tls.secret`                                                                                    | `false`             |
| `customTLS.secret`                       | Secret containing TLS cert and key must contain the keys tls.key , tls.crt and ca.crt                                                                       | `""`                |
| `customSchemaFiles` | Custom openldap schema files used in addition to default schemas                                                                    | `""`                |
| `customLdifFiles`                       | Custom openldap configuration files used to override default settings                                                                      | `""`                |
| `customLdifCm`                       | Existing configmap with custom ldif. Can't be use with customLdifFiles                                                            | `""`                |
| `customAcls`                       | Custom openldap ACLs. Overrides default ones.                                                                      | `""`                |
| `replication.enabled`              | Enable the multi-master replication | `true` |
| `replication.retry`              | retry period for replication in sec | `60` |
| `replication.timeout`              | timeout for replication  in sec| `1` |
| `replication.starttls`              | starttls replication | `critical` |
| `replication.tls_reqcert`              | tls certificate validation for replication | `never` |
| `replication.interval`             | interval for replication | `00:00:00:10` |
| `replication.clusterName`          | Set the clustername for replication | "cluster.local" |

### Phpladadmin configuration

Parameters related to PHPLdapAdmin

| Parameter                          | Description                                                                                                                               | Default             |
| ---------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------- | ------------------- |
| `phpldapadmin.enabled`             | Enable the deployment of PhpLdapAdmin | `true`|
| `phpldapadmin.ingress`             | Ingress of Phpldapadmin | `{}` |
| `phpldapadmin.env`  | Environment variables for PhpldapAdmin| `{PHPLDAPADMIN_LDAP_CLIENT_TLS_REQCERT: "never"}` |

For more advance configuration see [README.md](./advanced_examples/README.md)

### Self-service password configuration

Parameters related to Self-service password.

| Parameter                          | Description                                                                                                                               | Default             |
| ---------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------- | ------------------- |
|`ltb-passwd.enabled`| Enable the deployment of Ltb-Passwd| `true` |
|`ltb-passwd.ingress`| Ingress of the Ltb-Passwd service | `{}` |

For more advance configuration see [README.md](./advanced_examples/README.md)

### Kubernetes parameters

Parameters related to Kubernetes.

| Parameter                          | Description                                                                                                                               | Default             |
| ---------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------- | ------------------- |
| `updateStrategy`                   | StatefulSet update strategy                                                                                                               | `{}`                |
| `kubeVersion`                 | kubeVersion Override Kubernetes version                                                                                                                | `""`   |
| `nameOverride`                        | String to partially override common.names.fullname                                                                                                                       | `""`            |
| `fullnameOverride`                 | fullnameOverride String to fully override common.names.fullname                                                                                                                     | `""`      |
| `commonLabels`                      | commonLabels Labels to add to all deployed objects                                                                                                            | `{}`                |
| `clusterDomain`                   | clusterDomain Kubernetes cluster domain name                                                                                                             | `cluster.local`                |
| `extraDeploy`                   | extraDeploy Array of extra objects to deploy with the release                                                                                | `""`                |
| `service.annotations`              | Annotations to add to the service                                                                                                         | `{}`                |
| `service.externalIPs`              | Service external IP addresses                                                                                                             | `[]`                |
| `service.ldapPortNodePort`                 | Nodeport of External service port for LDAP if service.type is NodePort                                                                                                            | `nil`               |
| `service.loadBalancerIP`           | IP address to assign to load balancer (if supported)                                                                                      | `""`                |
| `service.loadBalancerSourceRanges` | List of IP CIDRs allowed access to load balancer (if supported)                                                                           | `[]`                |
| `service.sslLdapPortNodePort`                 | Nodeport of External service port for SSL if service.type is NodePort                                                                                                            | `nil`               |
| `service.type`                     | Service type can be ClusterIP, NodePort, LoadBalancer                                                                                                                              | `ClusterIP`         |
| `persistence.enabled`              | Whether to use PersistentVolumes or not                                                                                                   | `false`             |
| `persistence.storageClass`         | Storage class for PersistentVolumes.                                                                                                      | `<unset>`           |
| `persistence.existingClaim`        | Add existing Volumes Claim. | `<unset>`           |
| `persistence.accessMode`           | Access mode for PersistentVolumes                                                                                                         | `ReadWriteOnce`     |
| `persistence.size`                 | PersistentVolumeClaim storage size                                                                                                        | `8Gi`               |
| `extraVolumes`                     | Allow add extra volumes which could be mounted to statefulset | None |
| `extraVolumeMounts`                | Add extra volumes to statefulset | None |
| `customReadinessProbe`                    | Liveness probe configuration                                                                                                              | `[see values.yaml]` |
| `customLivenessProbe`                   | Readiness probe configuration                                                                                                             | `[see values.yaml]` |
| `customStartupProbe`                     | Startup probe configuration                                                                                                               | `[see values.yaml]` |
| `resources`                        | Container resource requests and limits in yaml                                                                                            | `{}`                |
| `podSecurityContext`              | Enabled OPENLDAP  pods' Security Context | `true` |``
| `containerSecurityContext`              | Set OPENLDAP  pod's Security Context fsGroup | `true` |
| `existingConfigmap`              | existingConfigmap The name of an existing ConfigMap with your custom configuration for OPENLDAP  | `` |
| `podLabels`              | podLabels Extra labels for OPENLDAP  pods| `{}` |
| `podAnnotations`              | Enable the multi-master replication | `true` |
| `podAffinityPreset`              | podAffinityPreset Pod affinity preset. Ignored if `affinity` is set. Allowed values: `soft` or `hard`| `` |
| `podAntiAffinityPreset`              | podAntiAffinityPreset Pod anti-affinity preset. Ignored if `affinity` is set. Allowed values: `soft` or `hard` | `soft` |
| `pdb.enabled`                      | Enable Pod Disruption Budget                                                                                                              | `false`             |
| `pdb.minAvailable`                 | Configure PDB to have at least this many health replicas.                                                                                 | `1`                 |
| `pdb.maxUnavailable`               | Configure PDB to have at most this many unhealth replicas.                                                                                | `<unset>`           |
| `nodeAffinityPreset`              | nodeAffinityPreset.type Node affinity preset type. Ignored if `affinity` is set. Allowed values: `soft` or `hard` | `true` |
| `affinity`              | affinity Affinity for OPENLDAP  pods assignment | `` |
| `nodeSelector`              | nodeSelector Node labels for OPENLDAP  pods assignment | `` |
| `sidecars`              | sidecars Add additional sidecar containers to the OPENLDAP  pod(s) | `` |
| `initContainers`              | initContainers Add additional init containers to the OPENLDAP  pod(s) | `` |
| `volumePermissions`              | 'volumePermissions' init container parameters | `` |
| `priorityClassName`              | OPENLDAP pods' priority class name | `` |
| `tolerations`              | Tolerations for pod assignment | [] |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```bash
$ helm install --name my-release -f values.yaml stable/openldap
```

> **Tip**: You can use the default [values.yaml](values.yaml)


## PhpLdapAdmin
To enable PhpLdapAdmin set `phpldapadmin.enabled`  to `true`

Ingress can be configure if you want to expose the service.
Setup the env part of the configuration to access the OpenLdap server

**Note** : The ldap host should match the following `namespace.Appfullname`

Example :
```
phpldapadmin:
  enabled: true
  ingress:
    enabled: true
    annotations: {}
    path: /
    ## Ingress Host
    hosts:
    - phpldapadmin.local
  env:
    PHPLDAPADMIN_LDAP_CLIENT_TLS_REQCERT: "never"

```
## Self-service-password
To enable Self-service-password set `ltb-passwd.enabled`  to `true`

Ingress can be configure if you want to expose the service.

Setup the `ldap` part with the information of the OpenLdap server.

Set `bindDN` accordingly to your ldap domain

**Note** : The ldap server host should match the following `ldap://namespace.Appfullname`

Example :
```
ltb-passwd:
  enabled : true
  ingress:
    enabled: true
    annotations: {}
    host: "ssl-ldap2.local"

```

## Cleanup orphaned Persistent Volumes

Deleting the Deployment will not delete associated Persistent Volumes if persistence is enabled.

Do the following after deleting the chart release to clean up orphaned Persistent Volumes.

```bash
$ kubectl delete pvc -l release=${RELEASE-NAME}
```

## Custom Secret

`global.existingSecret` can be used to override the default secret.yaml provided


## Troubleshoot

You can increase the level of log using `env.LDAP_LOGLEVEL`

Valid log levels can be found [here](https://www.openldap.org/doc/admin24/slapdconfig.html)

### Boostrap custom ldif

**Warning** when using custom ldif in the `customLdifFiles` or `customLdifCm` section you  have to create the high level object `organization`

```
dn: dc=test,dc=example
dc: test
o: Example Inc.
objectclass: top
objectclass: dcObject
objectclass: organization
```

**note** the admin user is created by the application and should not be added as a custom ldif

All internal configuration like `cn=config` , `cn=module{0},cn=config` cannot be configured yet.

## Changelog/Updating

### To 4.0.0

This major update switch the base image from [Osixia](https://github.com/osixia/docker-openldap) to [Bitnami Openldap](https://github.com/bitnami/containers/tree/main/bitnami/openldap)

- Upgrade may not work fine between `3.x` and `4.x`
- Ldap and Ldaps port are non privileged ports (`1389` and `1636`)
- Replication is now purely setup by configuration
- Extra schema cannot be added/modified

A default tree (Root organisation, users and group) is created during startup, this can be skipped using `LDAP_SKIP_DEFAULT_TREE` , however you need to use `customLdifFiles` or `customLdifCm` to create a root organisation.

- This will be improved in a future update.

### To 3.0.0

This major update of the chart enable new feature for the deployment such as :

- supporting initcontainer
- supporting sidecar
- use global parameters to ease the configuration of the app
- out of the box integration with phpldapadmin and self-service password in a secure way
