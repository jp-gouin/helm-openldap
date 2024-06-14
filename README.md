
# OpenLDAP Helm Chart
## Disclaimer
This version now use the [Bitnami Openldap](https://hub.docker.com/r/bitnami/openldap) container image.

More detail on the container image can be found [here](https://github.com/bitnami/containers/tree/main/bitnami/openldap)

The chart now support `Bitnami/Openldap 2.6.6`. 


To install the chart with the release name `my-release`:

```bash
$ helm repo add dbildungsplattform https://dbildungsplattform.github.io/helm-charts-registry/
$ helm install my-release dbildungsplattform/openldap-stack
```


### Global section

Global parameters to configure the deployment of the application.

| Parameter                          | Description                                                                                                                               | Default             |
| ---------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------- | ------------------- |
| `global.imageRegistry`                     | Global image registry                                                                                                                        | `""`                 |
| `global.imagePullSecrets`                     | Global list of imagePullSecrets                                                                                                                        | `[]`                 |
| `global.ldapDomain`                     | Domain LDAP can be explicit `dc=example,dc=org` or domain based `example.org`                                                                                                                         | `example.org`                 |
| `global.existingSecret`                     | Use existing secret for credentials - the expected keys are LDAP_ADMIN_PASSWORD and LDAP_CONFIG_ADMIN_PASSWORD                                         | `""`                |
| `global.adminUser`                     | Openldap database admin user                                                                                                                        | `admin`                 |
| `global.adminPassword`                     | Administration password of Openldap                                                                                                                        | `Not@SecurePassw0rd`                 |
| `global.configUserEnabled`                     |  Whether to create a configuration admin user                                                                                                                       | `true`                 |
| `global.configUser`                     |  Openldap configuration admin user                                                                                                                       | `admin`                 |
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
| `initTLSSecret.tls_enabled`                      | Set to enable TLS/LDAPS with custom certificate - Please also set `initTLSSecret.secret`, otherwise it will not take effect                                                                                    | `false`             |
| `initTLSSecret.secret`                       | Secret containing TLS cert and key must contain the keys tls.key , tls.crt and ca.crt                                                                       | `""`                |
| `customSchemaFiles` | Custom openldap schema files used in addition to default schemas                                                                    | `""`                |
| `customLdifFiles`                       | Custom openldap configuration files used to override default settings                                                                      | `""`                |
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
For all possible chart parameters see chart's [README.md](./charts/phpldapadmin/README.md)


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
| `service.enableLdapPort`                 | Enable LDAP port on the service and headless service                                                                                | `true`              |
| `service.enableSslLdapPort`                 | Enable SSL LDAP port on the service and headless service                                                                         | `true`              |
| `service.ldapPortNodePort`                 | Nodeport of External service port for LDAP if service.type is NodePort                                                                                                            | `nil`               |
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
| `existingConfigmap`              | existingConfigmap The name of an existing ConfigMap with your custom configuration for OPENLDAP  | `` |
| `podLabels`              | podLabels Extra labels for OPENLDAP  pods| `{}` |
| `podAnnotations`              | podAnnotations Extra annotations for OPENLDAP  pods | `{}` |
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
    # Assuming that ingress-nginx is used
    ingressClassName: nginx
    path: /
    ## Ingress Host
    hosts:
    - phpldapadmin.local
  env:
    PHPLDAPADMIN_LDAP_CLIENT_TLS_REQCERT: "never"
```