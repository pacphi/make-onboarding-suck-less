# Ubuntu 20.04

## Authentication

Login with

* _username_ = `vagrant`
* _password_ = `vagrant`


## Troubleshooting

When shutting down from VirtualBox UI if VM fails to shutdown...

```
ps -eaf | grep VBoxHeadless
kill -9 {pid}
VBoxManage list vms
VBoxManage unregistervm {image-uuid} --delete
```
