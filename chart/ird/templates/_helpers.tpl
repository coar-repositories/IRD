{{/*
Expand the name of the chart.
*/}}
{{- define "ird.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Name for webapp
*/}}
{{- define "ird.webapp.name" -}}
{{- default "web" .Values.webapp.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Name for jobs
*/}}
{{- define "ird.jobs.name" -}}
{{- default "jobs" .Values.jobs.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Name for postgres backup
*/}}
{{- define "ird.postgresbackup.name" -}}
{{- default "postgres-backup" .Values.postgresbackup.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "ird.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
fully qualified app name for webapp.
*/}}
{{- define "ird.webapp.fullname" -}}
{{- if .Values.webapp.fullnameOverride }}
{{- .Values.webapp.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default "web" .Values.webapp.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
fully qualified app name for jobs.
*/}}
{{- define "ird.jobs.fullname" -}}
{{- if .Values.jobs.fullnameOverride }}
{{- .Values.jobs.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default "jobs" .Values.jobs.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
fully qualified app name for postgres backup.
*/}}
{{- define "ird.postgresbackup.fullname" -}}
{{- if .Values.postgresbackup.fullnameOverride }}
{{- .Values.postgresbackup.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default "postgres-backup" .Values.postgresbackup.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "ird.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}