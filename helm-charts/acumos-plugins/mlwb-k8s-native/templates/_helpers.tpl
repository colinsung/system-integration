#
#============LICENSE_START=======================================================
# Acumos Apache-2.0
#================================================================================
# Copyright (C) 2020 AT&T Intellectual Property & Tech Mahindra.
# All rights reserved.
#================================================================================
# This Acumos software file is distributed by AT&T and Tech Mahindra
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ============LICENSE_END=========================================================
#
{{- define "workbench.component.env" }}
- name: dashboardComponent
  value: "https://{{ .Values.mlwb.dashboardWebcomponent.svcName }}.{{ .Values.mlwb.namespace }}:{{ .Values.mlwb.dashboardWebcomponent.svcPort }}"
- name: datasourceComponent
  value: "https://{{ .Values.mlwb.datasourceWebcomponent.svcName }}.{{ .Values.mlwb.namespace }}:{{ .Values.mlwb.datasourceWebcomponent.svcPort }}"
- name: datasourceCatalogComponent
  value: "https://{{ .Values.mlwb.datasourceCatalogWebcomponent.svcName }}.{{ .Values.mlwb.namespace }}:{{ .Values.mlwb.datasourceCatalogWebcomponent.svcPort }}"
- name: notebookComponent
  value: "https://{{ .Values.mlwb.notebookWebcomponent.svcName }}.{{ .Values.mlwb.namespace }}:{{ .Values.mlwb.notebookWebcomponent.svcPort }}"
- name: notebookCatalogComponent
  value: "https://{{ .Values.mlwb.notebookCatalogWebcomponent.svcName }}.{{ .Values.mlwb.namespace }}:{{ .Values.mlwb.notebookCatalogWebcomponent.svcPort }}"
- name: pipelineComponent
  value: "https://{{ .Values.mlwb.pipelineWebcomponent.svcName }}.{{ .Values.mlwb.namespace }}:{{ .Values.mlwb.pipelineWebcomponent.svcPort }}"
- name: pipelineCatalogComponent
  value: "https://{{ .Values.mlwb.pipelineCatalogWebcomponent.svcName }}.{{ .Values.mlwb.namespace }}:{{ .Values.mlwb.pipelineCatalogWebcomponent.svcPort }}"
- name: projectComponent
  value: "https://{{ .Values.mlwb.projectWebcomponent.svcName }}.{{ .Values.mlwb.namespace }}:{{ .Values.mlwb.projectWebcomponent.svcPort }}"
- name: projectCatalogComponent
  value: "https://{{ .Values.mlwb.projectCatalogWebcomponent.svcName }}.{{ .Values.mlwb.namespace }}:{{ .Values.mlwb.projectCatalogWebcomponent.svcPort }}"
{{- end }}

{{- define "workbench.msURL.env" }}
- name: datasourcemSURL
  value: "http://{{ .Values.mlwb.datasourceService.svcName }}.{{ .Values.mlwb.namespace }}:{{ .Values.mlwb.datasourceService.svcPort }}/mlWorkbench/v1/datasource"
- name: notebookmSURL
  value: "http://{{ .Values.mlwb.notebookService.svcName }}.{{ .Values.mlwb.namespace }}:{{ .Values.mlwb.notebookService.svcPort }}/mlWorkbench/v1/notebook"
- name: pipelinemSURL
  value: "http://{{ .Values.mlwb.pipelineService.svcName }}.{{ .Values.mlwb.namespace }}:{{ .Values.mlwb.pipelineService.svcPort }}/mlWorkbench/v1/pipeline"
- name: projectmSURL
  value: "http://{{ .Values.mlwb.projectService.svcName }}.{{ .Values.mlwb.namespace }}:{{ .Values.mlwb.projectService.svcPort }}/mlWorkbench/v1/project"
{{- end }}
