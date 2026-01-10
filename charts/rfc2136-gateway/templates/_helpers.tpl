{{- define "rfc2136-gateway.fullname" -}}
{{ include "rfc2136-gateway.name" . }}-{{ .Release.Name }}
{{- end }}

{{- define "rfc2136-gateway.name" -}}
{{ .Chart.Name }}
{{- end }}
