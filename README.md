# dual-nic-nfs-server

```
#!/bin/bash  -x 


fdisk -l


sudo parted -s -a optimal /dev/sdb mklabel gpt
sudo echo "y" |mkfs -t ext4   /dev/sdb


fstab=/etc/fstab

if [[ $(grep -q "sdb" "$fstab") ]]
then
    sudo oecho "#nfs-disc" >> /etc/fstab
    sudo echo "/dev/sdb /mnt/nfs_share ext4 defaults 0 2" >> /etc/fstab
else
    echo "Entry in fstab exists."
fi


sudo mkdir -p /mnt/nfs_share
sudo mount /dev/sdb /mnt/nfs_share




apt update
apt install -y nfs-kernel-server
mkdir -p /mnt/nfs_share
chmod 777 /mnt/nfs_share/
echo "/mnt/nfs_share   *(rw,sync,no_subtree_check)" >> /etc/exports
exportfs -a
systemctl restart nfs-kernel-server


```


nfs-pv.yaml:

```
nfs-pv.yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: nfs-pv
spec:
  storageClassName: "standard"
  capacity:
    storage: 2048Gi
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  claimRef:
    namespace: foobar
    name: nfs-pvc
  nfs:
    path: /mnt/nfs_share
    server: 192.168.0.15

```

nfs-pvc.yaml:

```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: nfs-pvc
spec:
  accessModes:
  - ReadWriteOnce
  resources:
     requests:
       storage: 204Gi
  volumeName: "nfs-pv"
```

deployment.yaml:

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-nfs-pod
  labels:
    name: nginx-nfs-pod
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: nginx-nfs-pod
          image: gcr.io/delta-carving-312819/nginx:latest
          ports:
            - name: web
              containerPort: 80
          volumeMounts:
            - name: nfsvol
              mountPath: /usr/share/nginx/html
      securityContext:
          supplementalGroups: [100003]
      volumes:
        - name: nfsvol
          persistentVolumeClaim:
            claimName: nfs-pvc

```
