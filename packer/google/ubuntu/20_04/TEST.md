# Creating a VM from a Google Compute Image

## Prerequisites

* Google Compute service account credentials
* Google Cloud SDK ([gcloud](https://cloud.google.com/sdk/docs/install))


## Authenticate

A number of options exist, but this simplest may be to

```
gcloud auth application-default login
```

then if you're on MacOs or Linux

```
export GOOGLE_APPLICATION_CREDENTIALS="$HOME/.config/gcloud/application_default_credentials.json"
```

or Windows

```
export GOOGLE_APPLICATION_CREDENTIALS="%APPDATA%/gcloud/application_default_credentials.json"
```

## Create VM

```
gcloud beta compute instances create {INSTANCE_NAME} \
    --zone {AVAILABILITY_ZONE} \
    --image=https://www.googleapis.com/compute/v1/projects/{PROJECT_ID}/global/images/k8s-toolset-{TIMESTAMP} \
    --machine-type {MACHINE_TYPE}
```
> Replace `{INSTANCE_NAME}` with the name you want to assign the VM.  Replace `{AVAILABILITY_ZONE}` with one of `gcloud compute zones list`.  Replace `{PROJECT_ID}` with a valid [project identifier](https://cloud.google.com/resource-manager/docs/creating-managing-projects).  Replace `{TIMESTAMP}` as the suffix of a k8s-toolset custom image that had already been created.  Finally, replace `{MACHINE_TYPE}` with one of `gcloud compute machine-types list`.


## Connect to VM

```
gcloud beta compute ssh --zone "{AVAILABILITY_ZONE}" --project "{PROJECT_ID}" "{INSTANCE_NAME}"
```
> Replace `{AVAILABILTY_ZONE}`, `{PROJECT_ID}`, and `{INSTANCE_NAME}` with the same values you used to create the VM.


## Destroy VM

```
gcloud compute instances delete --zone "{AVAILABILITY_ZONE}" --project "{PROJECT_ID}" "{INSTANCE_NAME}" -q
```
> Replace `{AVAILABILTY_ZONE}`, `{PROJECT_ID}`, and `{INSTANCE_NAME}` with the same values you used to create the VM.