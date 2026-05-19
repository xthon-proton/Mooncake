{{/* =====================================================================
     _helpers.tpl — 通用模板片段
     ===================================================================== */}}

{{- define "mooncake.name" -}}
mooncake-master
{{- end -}}

{{- define "mooncake.fullname" -}}
mooncake-store-server
{{- end -}}

{{- define "mooncake.headlessName" -}}
mooncake-master-headless
{{- end -}}

{{- define "mooncake.labels" -}}
app: {{ include "mooncake.fullname" . }}
{{- end -}}

{{- define "mooncake.annotations" -}}
gde.huawei.com/isolation-when-data-network-abnormal: "true"
application.kubernetes.io/logsrotate: '[{"name":"msslog", "rotate":"Daily","annotations":{"maxZipCount": "10", "maxZipSize": "20"}}]'
paas.kubernetes.io/resource-limits: '{"mooncake-store-server":{"docker/ulimit.nofile":"50000:50000","docker/ulimit.nproc":"50000:50000"}}'
{{- end -}}

{{- define "mooncake.selectorLabels" -}}
app: {{ include "mooncake.fullname" . }}
{{- end -}}