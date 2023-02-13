# LTB Password Self Service Helm Chart

This repository contains the helm chart for the LTB password change webapp.
It is based on several other projects, namely:

- [LTB Self-Service Password](https://ltb-project.org/documentation/self-service-password)
- [LTB Self-Service Password Github Repo](https://github.com/ltb-project/self-service-password)
- [tiredofit Docker Image for the LTB repo](https://github.com/tiredofit/docker-self-service-password)

## Prerequisites

- Kubernetes 1.8+

## Chart Details

This chart will do the following:

- Instantiate an instance of the LTB LDAP Self-Service Password webapp.

## Installing the Chart

To install the chart with the release name `my-release`:

```bash
$ helm install --name my-release $PATH_TO_THIS_REPO
```

## Configuration

We use this image as base image, please refer to the documentation for specific options.

- [tiredofit Docker Image for the LTB repo](https://github.com/tiredofit/docker-self-service-password)

Configuration is done within `values.yaml`:

| Parameter                          | Description                                                                                                                               | Default                            |
| ---------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------- |
| `env`                              | List of key value pairs as env variables to be sent to the docker image. See https://github.com/tiredofit/docker-self-service-password for available ones | `[see values.yaml]`|
| `ldap.bindDN`                      | bindDN to authenticate on LDAP. Optional. Default to cn=admin,dc=...                                                                      | ` `                                |
| `ldap.passkey`                     | key of credential secret to authenticate on LDAP. Optional. Default to LDAP_ADMIN_PASSWORD                                                | ` `                                |
| `ldap.searchBase`                  | LDAP Search base for users. Default to dc=...                                                                                             | ` `                                |
| `ldap.custom`                      | LDAP client custom configuration                                                                                                          | ` `                                |
| `replicaCount`                     | Number of replicas                                                                                                                        | `1`                                |
| `image.repository`                 | Container image repository                                                                                                                | ` tiredofit/self-service-password` |
| `image.tag`                        | Container image tag                                                                                                                       | `latest`                           |
| `image.pullPolicy`                 | Container pull policy                                                                                                                     | `Default`                          |
| `service.port`                     | External port for the WebApp                                                                                                              | `80`                               |
| `service.type`                     | Service type                                                                                                                              | `ClusterIP`                        |
| `ingress.enabled`                  | Whether to generate ingress resources                                                                                                     | `false`                            |
| `ingress.annotations`              | Annotations to add to the ingress                                                                                                         | `{}`                               |
| `ingress.hosts`                    | Hostnames to redirect to the webapp                                                                                                       | `[]`                               |
| `ingress.tls`                      | TLS Configuration                                                                                                                         | `[]`                               |
| `resources`                        | Container resource requests and limits in yaml                                                                                            | `{}`                               |
| `initContainers`                   | Init containers to add to the application                                                                                                 | `[]`                               |
| `volumeMounts`                     | Additional volumeMounts to the application main container                                                                                 | `[]`                               |
| `volumes`                          | Additional volumes to the application pod                                                                                                 | `[]`                               |
| `nodeSelector`                     | NodeSelector to run the image on                                                                                                          | `{}`                               |
| `tolerations`                      | Tolerations for the service pod                                                                                                           | `[]`                               |
| `affinity`                         | Attractions for the service pod                                                                                                           | `{}`                               |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```bash
$ helm install --name my-release -f values.yaml $PATH_TO_THIS_REPO
```