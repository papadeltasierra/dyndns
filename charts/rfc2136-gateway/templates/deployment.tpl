apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "rfc2136-gateway.fullname" . }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: {{ include "rfc2136-gateway.name" . }}
  template:
    metadata:
      labels:
        app: {{ include "rfc2136-gateway.name" . }}
    spec:
      containers:
        - name: rfc2136-gateway
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          ports:
            - name: tcp-53
              containerPort: 53
              protocol: TCP
            - name: udp-53
              containerPort: 53
              protocol: UDP
          env:
            - name: LOG_LEVEL
              value: "{{ .Values.config.logLevel }}"
            - name: DNS_ZONE
              value: "{{ .Values.config.dnsZone }}"
            - name: TSIG_KEY
              valueFrom:
                secretKeyRef:
                  name: {{ include "rfc2136-gateway.fullname" . }}
                  key: tsigKey
          resources:
{{ toYaml .Values.resources | indent 12 }}
