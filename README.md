# scaleway-kubernetes
Scaleway image to run Kubernetes

This will create a highly-available (multi-master) Kubernetes cluster on top of scaleway, built on top of the scaleway docker image. Currently, this has only been tested with x86_64 however armhf support will be added soon.

Because scaleway does not support multiple-IPs per server, nor does it support loadbalancers, you'll need to use round-robin DNS to balance traffic across each Kubernetes node.

---

## Setup

Due to the limited configuration parameters with Scaleway, it is required that you build your own image with Kubernetes certificates baked into your image. Because of this, setup is slightly more complex than I'd like it to be.

1. Spin-up an image builder instance on scaleway, and clone this repository onto it:

```bash
$ git clone https://github.com/munnerz/scaleway-k8s.git
```

2. Place your keys, certificate, cluster CA and auth files into rootfs/etc/kubernetes:

* `apiserver-key.pem`: the apiserver private key
* `apiserver.pem`: the api server certificate
* `basic_auth.csv`: basic auth accounts
* `ca.pem`: the cluster CA certificate
* `known_tokens.csv`: token auth accounts

You can generate the openssl certificates using the CoreOS guide: https://coreos.com/kubernetes/docs/latest/openssl.html

3. Run `make install` - this by default will write everything needed to the volume attached to your builder instance at `/dev/nbd1`. To change the volume name, set the `DISK` environment variables (eg. `DISK=/dev/vdb make install`)

4. Shut down your builder instance and snapshot the attached disk. You can then create an image from this snapshot and then a new VM from your new image.

5. When creating the new servers, make sure to select the `docker` boot script.

6. If you start a new cluster you need an etcd discovery link as start point. You can get one at https://discovery.etcd.io/new?size=3 (adjust the `size` parameter according to how many etcd nodes you will initially have in your cluster)

7. Add your discover link as a tag to your server in format discover:https://discovery.etcd.io/secretkeyyougot. Make sure it is the first tag!

8. Set a second tag with your Scaleway access key and token in format api:accesskey:token.

Repeat steps 5-8 for each instance that should be in your etcd cluster.

The cluster will take a few minutes to properly come online.