apiVersion: apps/v1
kind: Deployment
metadata:
  name: ${image_name}
  namespace: ${image_name}
  labels:
    app: ${image_name}
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ${image_name}
  template:
    metadata:
      labels:
        app: ${image_name}
    spec:
      containers:
      - name: ${image_name}
        image: ${repository_uri}:${image_tag}
        ports:
        - name: http
          containerPort: 8080
        imagePullPolicy: Always

---
apiVersion: v1
kind: Service
metadata:
  name: ${image_name}-lb
  namespace: ${image_name}
spec:
  type: LoadBalancer
  selector:
    app: ${image_name}
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
