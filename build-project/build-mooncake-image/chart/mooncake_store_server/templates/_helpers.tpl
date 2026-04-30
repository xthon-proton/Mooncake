{{/* =====================================================================
     _helpers.tpl — 通用模板片段
     ===================================================================== */}}

{{- define "mooncake.name" -}}
mooncake-master
{{- end -}}

{{- define "mooncake.fullname" -}}
mooncake-master
{{- end -}}

{{- define "mooncake.headlessName" -}}
mooncake-master-headless
{{- end -}}

{{- define "mooncake.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
{{- default (include "mooncake.fullname" .) .Values.serviceAccount.name -}}
{{- else -}}
{{- default "default" .Values.serviceAccount.name -}}
{{- end -}}
{{- end -}}

{{- define "mooncake.labels" -}}
app: {{ include "mooncake.name" . }}
app.kubernetes.io/name: {{ include "mooncake.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "mooncake.selectorLabels" -}}
app: {{ include "mooncake.name" . }}
{{- end -}}
